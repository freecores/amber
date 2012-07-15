/*----------------------------------------------------------------
//                                                              //
//  boot-loader-ethmac.c                                        //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  The main functions for the boot loader application. This    //
//  application is embedded in the FPGA's SRAM and is used      // 
//  to load larger applications into the DDR3 memory on         //
//  the development board.                                      //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2011 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
----------------------------------------------------------------*/

// TODO list
// tcp.c clean up
// Cleanup self_g structure and usage
// tcp window - what is it, whats it set to? Add it to status stuff
// Get A25 version working
// test with booting linux

#include "amber_registers.h"
#include "address_map.h"
#include "line-buffer.h"
#include "timer.h"
#include "utilities.h"

#include "ethmac.h"
#include "packet.h"
#include "tcp.h"
#include "udp.h"
#include "telnet.h"

#include "elfsplitter.h"
#include "boot-loader-ethmac.h"


int main ( void ) {
    char* line;
    time_t* led_flash_timer;
    time_t* reboot_timer;
    socket_t* socket = socket0_g;
    int reboot_stage = 0;
    
    /* Turn off all LEDs as a starting point */
    led_clear();

    /* this must be first, because all the other init functions call malloc */
    init_malloc();
        
    /* Initialize current time and some timers */
    init_current_time();
    led_flash_timer = init_timer();
    set_timer(led_flash_timer, 500);    
    reboot_timer = init_timer();
    
        
    /* receive packet buffer */
    rx_packet_g = malloc(sizeof(packet_t));
    
    /* socket init */
    socket0_g = init_socket(0);
    socket1_g = init_socket(1);
        
    /* open ethernet port and wait for connection requests 
       keep trying forever */
    while (!open_link());
        
    /* infinite loop. Everything is timer, interrupt and queue driven from here on down */
    while (1) {
        
        /* Flash a heartbeat LED */
        if (timer_expired(led_flash_timer)) {
            led_flip(0);
            set_timer(led_flash_timer, 500);
            }
            
            
        /* Check for newly downloaded tftp file. Add to all tx buffers */
        /* Has a file been uploaded via tftp ? */
        if (udp_file_g != NULL) {
            /* Notify telnet clients that file has been received */
            if (udp_file_g->ready) {
                udp_file_g->ready = 0;
                telnet_broadcast("Received file %s, %d bytes, linux %d\r\n",
                    udp_file_g->filename, udp_file_g->total_bytes, udp_file_g->linux_boot);
                if (process_file(socket0_g) == 0)
                    /* Disconnect in 1 second */
                    set_timer(reboot_timer, 1000);
                else
                    telnet_broadcast("Not an elf file\r\n");
                }
            }
            
            
        /* reboot timer expired */
        if (timer_expired(reboot_timer)) {
            /* First stage of reboot sequence is to nicely disconnect */
            if (reboot_stage == 0) {
                set_timer(reboot_timer, 1000);
                reboot_stage = 1;
                socket0_g->tcp_disconnect = 1;
                socket1_g->tcp_disconnect = 1;
                } 
            else {
            /* Second stage of reboot sequence is to turn off ethmac and then jump to restart vector */
                close_link();
                reboot();
                }
            }


        /* Poll both sockets in turn for activity */
        if (socket == socket0_g)
            socket = socket1_g;
        else
            socket = socket0_g;
            
            
        /* Check if any tcp packets need to be re-transmitted */
        tcp_retransmit(socket);


        /* Handle exit command */
        if (socket->tcp_disconnect && socket->tcp_connection_state == TCP_OPEN) {
            tcp_disconnect(socket);
            }
            

        /* Reset connection */
        if (socket->tcp_reset) {
            socket->tcp_connection_state = TCP_CLOSED;
            socket->telnet_connection_state = TELNET_CLOSED;
            socket->telnet_options_sent = 0;
            tcp_reply(socket, NULL, 0);
            socket->tcp_reset = 0;
            }
                     
        
        /* Send telnet options */             
        if (socket->tcp_connection_state == TCP_OPEN && !socket->telnet_options_sent){
            telnet_options(socket);
            socket->telnet_options_sent = 1;
            }
            
        /* telnet connection open 
           Communicate with client */
        else if (socket->telnet_connection_state == TELNET_OPEN) {
            /* Send telnet greeting */
            if (!socket->telnet_sent_opening_message){
                put_line (socket->telnet_txbuf, "Amber Processor Boot Loader\r\n> ");
                socket->telnet_sent_opening_message = 1;
                }
                
            /* Parse telnet rx buffer */
            if (get_line(socket->telnet_rxbuf, &line)) 
                parse_command (socket, line);

            /* Transmit text from telnet tx buffer */
            telnet_tx(socket, socket->telnet_txbuf);
        }
    }
}



/* Parse a command line passed from main and execute the command */
/* returns the length of the reply string */
int parse_command (socket_t* socket, char* line) 
{    
    unsigned int start_addr;
    unsigned int address;
    unsigned int range;
    int len, error = 0;
    
    /* All commands are just a single character.
       Just ignore anything else  */
    switch (line[0]) {
        /* Disconnect */
        case 'e':
        case 'x':
        case 'q':  
            socket->tcp_disconnect = 1;
            return 0;
            
        case 'r': /* Read mem */    
            {
            if (len = get_hex (&line[2], &start_addr)) { 
                if (len = get_hex (&line[3+len], &range)) {
                    for (address=start_addr; address<start_addr+range; address+=4) {
                        put_line (socket->telnet_txbuf, "0x%08x 0x%08x\r\n", 
                                    address, *(unsigned int *)address);
                        }
                    }
                else {
                    put_line (socket->telnet_txbuf, "0x%08x 0x%08x\r\n", 
                                    start_addr, *(unsigned int *)start_addr);
                    }
                }
            else 
                error=1;
            break;                
            }
                

        case 'h': {/* Help */    
            put_line (socket->telnet_txbuf, "You need help alright\r\n");
            break;                
            }

            
        case 's': {/* Status */    
            put_line (socket->telnet_txbuf, "Socket ID           %d\r\n", socket->id);
            put_line (socket->telnet_txbuf, "Packets received    %d\r\n", socket->packets_received);
            put_line (socket->telnet_txbuf, "Packets transmitted %d\r\n", socket->packets_sent);
            put_line (socket->telnet_txbuf, "Packets resent      %d\r\n", socket->packets_resent);
            put_line (socket->telnet_txbuf, "TCP checksum errors %d\r\n", tcp_checksum_errors_g);
            
            put_line (socket->telnet_txbuf, "Counterparty IP %d.%d.%d.%d\r\n",
                socket->rx_packet->src_ip[0],
                socket->rx_packet->src_ip[1],
                socket->rx_packet->src_ip[2],
                socket->rx_packet->src_ip[3]);
            
            put_line (socket->telnet_txbuf, "Counterparty Port %d\r\n",
                socket->rx_packet->tcp_src_port);
                
            put_line (socket->telnet_txbuf, "Malloc pointer 0x%08x\r\n",
                *(unsigned int *)(ADR_MALLOC_POINTER));
            put_line (socket->telnet_txbuf, "Malloc count %d\r\n",
                *(unsigned int *)(ADR_MALLOC_COUNT));
            put_line (socket->telnet_txbuf, "Uptime %d seconds\r\n", current_time_g->seconds);
            break;
            }
            
            
        default: {
            error=1; break;
            }                
        }
        
    
    if (error)
            put_line (socket->telnet_txbuf, "You're not making any sense\r\n", 
                        line[0], line[1], line[2]);
     
    put_line (socket->telnet_txbuf, "> ");
    return 0;
}


/* copy tftp file into a single contiguous buffer so
   if can be processed by elf splitter */
int process_file(socket_t* socket)
{   
    block_t* block;
    char*    buf512;
    char*    tftp_file;
    char*    line;
    int      line_len;
    int      ret;
           
    tftp_file = malloc(udp_file_g->total_bytes);
   
    block = udp_file_g;
    buf512= tftp_file;
   
    while (block->next) {
        memcpy(buf512, block->buf512, block->bytes);
        buf512=&buf512[512];
        block=block->next;
        }
    memcpy(buf512, block->buf512, block->bytes);
    buf512=&buf512[512];
    
    return elfsplitter(tftp_file, socket);
}


/* Disable interrupts
   Load new values into the interrupt vector memory space
   Jump to address 0
*/
void reboot()
{
   int i;
   
   /* Disable all interrupts */
   /* Disable ethmac_int interrupt */                                    
   /* Disable timer 0 interrupt in interrupt controller */
   *(unsigned int *) ( ADR_AMBER_IC_IRQ0_ENABLECLR ) = 0x120;

   for(i=0;i<MEM_BUF_ENTRIES;i++)
       if (elf_mem0_g->entry[i].valid)
           *(char *)(i) = elf_mem0_g->entry[i].data;
           
   if (udp_file_g->linux_boot)
      _jump_to_program(LINUX_JUMP_ADR);
   else
      _restart();
}

