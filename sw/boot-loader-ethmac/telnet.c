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

#include "address_map.h"
#include "timer.h"
#include "line-buffer.h"
#include "packet.h"
#include "tcp.h"
#include "telnet.h"

void parse_telnet_options(char* buf, socket_t* socket)
{
    int     i;
    int     stage = 0;
    char    stage1;

    for (i=0;i<socket->rx_packet->tcp_payload_len;i++) {

        if (stage == 0) {
            switch (buf[i]) {
                case 241: stage = 0; break;  // NOP
                case 255: stage = 1;
                                 if (socket->telnet_connection_state == TELNET_CLOSED) {
                                     socket->telnet_connection_state = TELNET_OPEN;
                                    }
                         break;  // IAC

                default:  if (buf[i] < 128)
                    goto telnet_payload;
            }

        } else if (stage == 1) {
            stage1 = buf[i];
            switch (buf[i]) {
                case 241        : stage = 0; break;  // NOP
                case 250        : stage = 2; break;  // SB
                case TELNET_WILL: stage = 2; break;  // 0xfb WILL
                case TELNET_WONT: stage = 2; break;  // 0xfc WONT
                case TELNET_DO  : stage = 2; break;  // 0xfd DO
                case TELNET_DONT: stage = 2; break;  // 0xfe DONT
                default         : stage = 2; break;
            }

        } else {  // stage = 2
            stage = 0;
            switch (buf[i]) {
                case 1:   // echo
                    /* Client request that server echos stuff back to client */
                    if (stage1 == TELNET_DO)
                        socket->telnet_echo_mode = 1;
                    /* Client request that server does not echo stuff back to client */
                    else if (stage1 == TELNET_DONT)
                        socket->telnet_echo_mode = 0;
                    break;

                case 3:   break;  // suppress go ahead
                case 5:   break;  // status
                case 6:   break;  // time mark
                case 24:  break;  // terminal type
                case 31:  break;  // window size
                case 32:  break;  // terminal speed
                case 33:  break;  // remote flow control
                case 34:  break;  // linemode
                case 35:  break;  // X display location
                case 39:  break;  // New environmental variable option
                default:  break;
                }
            }
        }

    return;

    telnet_payload:
        socket->rx_packet->telnet_payload_len = socket->rx_packet->tcp_payload_len - i;
        parse_telnet_payload(&buf[i], socket);
}


void parse_telnet_payload(char * buf, socket_t* socket)
{
    int i;
    int cr = 0;
    int windows = 0;
    for (i=0;i<socket->rx_packet->telnet_payload_len;i++) {
        if (buf[i] == '\n')
            windows = 1;
        else if (buf[i] < 128 && buf[i] != 0) {
            /* end of a line */
            /* receive \r\n from Windows, \r from Linux */
            if (buf[i] == '\r') {
                cr=1;
                put_byte(socket->telnet_rxbuf, buf[i], 1); /* last byte of line */
                }
            else {
                put_byte(socket->telnet_rxbuf, buf[i], 0); /* not last byte of line */
                }
            }
        }

    if (socket->telnet_echo_mode) {
        if (cr && !windows) {
            buf[socket->rx_packet->telnet_payload_len] = '\n';
            socket->rx_packet->telnet_payload_len++;
            }
        tcp_reply(socket, buf, socket->rx_packet->telnet_payload_len);
        }
}


void telnet_options(socket_t* socket)
{
    char buf[3];

    // telnet options
    // Will echo - advertise that I have the ability to echo back commands to the client
    buf[0] = 0xff; buf[1] = TELNET_WILL; buf[2] = 0x01;
    tcp_reply(socket, buf, 3);

}


void telnet_tx(socket_t* socket, line_buf_t* txbuf)
{
    int line_len;
    int total_line_len;
    char* line;
    char* first_line;

    /* Parse telnet tx buffer
       Grab as many lines as possible to stuff into a packet to transmit */
    line_len = get_line(txbuf, &first_line);
    if (line_len) {
        total_line_len = line_len;
        while (total_line_len < MAX_TELNET_TX && line_len) {
            line_len = get_line(txbuf, &line);
            total_line_len += line_len;
            }
        tcp_tx(socket, first_line, total_line_len);
        }
}


void process_telnet(socket_t* socket)
{
    char* line;

    if (!socket->telnet_options_sent){
        telnet_options(socket);
        socket->telnet_options_sent = 1;
        }

    else {
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
