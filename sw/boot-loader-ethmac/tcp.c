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


#include "amber_registers.h"
#include "address_map.h"
#include "line-buffer.h"
#include "timer.h"
#include "utilities.h"
#include "packet.h"
#include "tcp.h"
#include "telnet.h"


/* Global variables */
int         tcp_checksum_errors_g = 0;


void parse_tcp_packet(char * buf, packet_t* rx_packet)
{
    int i;
    int ptr;
    socket_t* socket;
    
    /* TCP Length */
    rx_packet->tcp_len         = rx_packet->ip_len - rx_packet->ip_header_len*4;
    rx_packet->tcp_hdr_len     = (buf[12]>>4)*4;
    
    // Guard against incorrect tcp_hdr_len value
    if (rx_packet->tcp_hdr_len < rx_packet->tcp_len)
        rx_packet->tcp_payload_len = rx_packet->tcp_len - rx_packet->tcp_hdr_len;
    else
        rx_packet->tcp_payload_len = 0;
    
    /* Verify the TCP checksum is correct */
    if (tcp_checksum(buf, rx_packet, 0)) {
        tcp_checksum_errors_g++;
        goto error_out;
    }
     
     
    rx_packet->tcp_src_port    = buf[0]<<8|buf[1];
    rx_packet->tcp_dst_port    = buf[2]<<8|buf[3];
    rx_packet->tcp_seq         = buf[4]<<24|buf[5]<<16|buf[6]<<8|buf[7];
    rx_packet->tcp_ack         = buf[8]<<24|buf[9]<<16|buf[10]<<8|buf[11];
    rx_packet->tcp_flags       = buf[13];
    rx_packet->tcp_window_size = buf[14]<<8|buf[15];   

    
    if (rx_packet->tcp_hdr_len > 20) {
        /* Get the source time stamp */
        parse_tcp_options(buf, rx_packet);    
        }


    /*  --------------------------------------------------
        Assign the received packet to a socket 
        -------------------------------------------------- */

    /* socket 0 open and matches ? */
    if (socket0_g->tcp_connection_state != TCP_CLOSED &&
        socket0_g->rx_packet->tcp_src_port == rx_packet->tcp_src_port)
        socket = socket0_g;

    /* socket 1 open and matches ? */
    else if (socket1_g->tcp_connection_state != TCP_CLOSED &&
        socket1_g->rx_packet->tcp_src_port == rx_packet->tcp_src_port)
        socket = socket1_g;

    /* no matches. Pick an unused socket */
    else if (socket0_g->tcp_connection_state == TCP_CLOSED)
        socket = socket0_g;
    else if (socket1_g->tcp_connection_state == TCP_CLOSED)
        socket = socket1_g;
    else
        goto error_out;


    /* Copy the rx_packet structure into the socket */
    memcpy(socket->rx_packet, rx_packet, sizeof(packet_t));
    
    tcp_response(buf, socket);

    error_out:
        return;
}


/* Get the tcp source time stamp by walking through the options */
void parse_tcp_options(char * buf, packet_t* rx_packet)
{
    int ptr;

    ptr = 20;
    while (ptr < rx_packet->tcp_hdr_len-1) {
        switch (buf[ptr]) {
            case 0:  ptr=rx_packet->tcp_hdr_len; break; // end of options
            case 1:  ptr++; break;
            case 2:  ptr = ptr + buf[ptr+1]; break;  // max segment size 
            case 3:  ptr = ptr + buf[ptr+1]; break;  // Window Scale
            case 4:  ptr = ptr + buf[ptr+1]; break;  // SACK Permitted
            case 5:  ptr = ptr + buf[ptr+1]; break;  // SACK
            case 8:  
                // Time Stamp Option 
                rx_packet->tcp_src_time_stamp = buf[ptr+2]<<24|buf[ptr+3]<<16|buf[ptr+4]<<8|buf[ptr+5];
                ptr = ptr + buf[ptr+1];  
                break;
                
            case 28:  // User Timeout Option
                ptr = ptr + buf[ptr+1]; break;                   
                
            default:
                ptr++; break;                   
            } 
        }
}


void tcp_response(char * buf, socket_t* socket)
{
    socket->packets_received++;
    
    /* Mark the ack in the tcp tx packet buffer so the tx packet does not get resent */
    if (socket->rx_packet->tcp_flags & 0x10) // ack flag set ?    
        tcp_ack(socket);
    

    // Other side requesting to reset a connection ?
    if (socket->rx_packet->tcp_flags & 0x04) { // RST 
        // Reset the connection
        socket->tcp_disconnect = 1;
        }
        
    // open a connection
    else if (socket->tcp_connection_state == TCP_CLOSED) {   
        
        if (socket->rx_packet->tcp_flags & 0x02) { // SYN 
            // Open connection
            tcp_open(socket);
            socket->tcp_connection_state = TCP_PENDING;
            }
            
        /* ACK any FIN received */
        else if (socket->rx_packet->tcp_flags & 0x01) // FIN 
            tcp_reply(socket, NULL, 0);        
        }

        
    // Sent the first ack packet to establish a connection.
    // Have just received the second packet from the server    
    else if (socket->tcp_connection_state == TCP_PENDING) { 
        /* Add 1 to the sequence number as a special case to open
           the connection */
        socket->tcp_seq++;  
        socket->tcp_connection_state = TCP_OPEN;     
        }
        
        
    // connection is already open
    else {
      
        /* contains tcp payload */
        if (socket->rx_packet->tcp_payload_len != 0) {
            /* Ack the packet only if the payload length is non-zero */
            tcp_reply(socket, NULL, 0);
                        
            /* Process the tcp contents */
            if (socket->rx_packet->tcp_dst_port == TELNET_PORT)
                /* telnet */
                parse_telnet_options(&buf[socket->rx_packet->tcp_hdr_len], socket);
            }                           
        }
}


void tcp_disconnect(socket_t * socket)
{
    if (socket->tcp_connection_state != TCP_CLOSED) {
        socket->tcp_connection_state = TCP_CLOSED;
        socket->telnet_connection_state = TELNET_CLOSED;
        socket->telnet_options_sent = 0;
        socket->telnet_sent_opening_message = 0;
        tcp_reply(socket, NULL, 0);
        socket->tcp_disconnect = 0;
        socket->telnet_echo_mode = 0;  // reset this setting
    }
}



/* Transmit a string of length line_len
   Suspend interrupts so this process does not get interrupted */                          
void tcp_tx(socket_t* socket, char* buf, int len)
{
    /* Disable ethmac_int interrupt */                                    
    *(unsigned int *) ( ADR_AMBER_IC_IRQ0_ENABLECLR ) = 0x100;            
                                                                      
    tcp_reply(socket, buf, len);                                    
                                                                      
    /* Enable ethmac_int interrupt */                                     
    *(unsigned int *) ( ADR_AMBER_IC_IRQ0_ENABLESET ) = 0x100;            
}



/* TODO merge this into tcp_reply */
void tcp_open(socket_t* socket)
{

    int i, j;
    unsigned short header_checksum;
    mac_ip_t target;
    int ip_length;
    char * buf;

    
    buf = socket->tcp_buf[socket->tcp_current_buf]->buf;
    
    
    target.mac[0] = socket->rx_packet->src_mac[0];
    target.mac[1] = socket->rx_packet->src_mac[1];
    target.mac[2] = socket->rx_packet->src_mac[2];
    target.mac[3] = socket->rx_packet->src_mac[3];
    target.mac[4] = socket->rx_packet->src_mac[4];
    target.mac[5] = socket->rx_packet->src_mac[5];
    target.ip[0]  = socket->rx_packet->src_ip[0];
    target.ip[1]  = socket->rx_packet->src_ip[1];
    target.ip[2]  = socket->rx_packet->src_ip[2];
    target.ip[3]  = socket->rx_packet->src_ip[3];


    /* Include 20 bytes of tcp options */
    ip_length = 20+20+20; /* 20 bytes ip header, 20 bytes tcp header, 20 bytes tcp options */
            
    socket->tcp_buf[socket->tcp_current_buf]->payload_valid = 1;
    socket->tcp_buf[socket->tcp_current_buf]->ack_received = 0;
    socket->tcp_buf[socket->tcp_current_buf]->starting_seq = tcp_header(&buf[34], socket, 0, TCP_NEW); 
    socket->tcp_buf[socket->tcp_current_buf]->ending_seq   = socket->tcp_buf[socket->tcp_current_buf]->starting_seq + 1;
    set_timer(&socket->tcp_buf[socket->tcp_current_buf]->resend_time, 500);
    
    ip_header(&buf[14], &target, ip_length, 6); /* 20 byes of tcp  options, bytes 14 to 33, ip_proto = 6, TCP*/
    ethernet_header(buf, &target, 0x0800);  /* bytes 0 to 13*/
    
    socket->tcp_buf[socket->tcp_current_buf]->len_bytes = 14+ip_length;
    
    strncpy((char*)ETHMAC_TX_BUFFER, buf, socket->tcp_buf[socket->tcp_current_buf]->len_bytes);

    tx_packet(socket->tcp_buf[socket->tcp_current_buf]->len_bytes);  // MAC header, IP header, TCP header, TCP options
    socket->packets_sent++;


    /* Pick the next tx buffer to use */    
    if (socket->tcp_current_buf == TCP_TX_BUFFERS-1)
        socket->tcp_current_buf=0;
    else
        socket->tcp_current_buf++;
}



void tcp_reply(socket_t* socket, char* telnet_payload, int telnet_payload_length)
{

    int i, j;
    mac_ip_t target;
    int ip_length;
    char * buf;

    
    buf = socket->tcp_buf[socket->tcp_current_buf]->buf;
    
    target.mac[0] = socket->rx_packet->src_mac[0];
    target.mac[1] = socket->rx_packet->src_mac[1];
    target.mac[2] = socket->rx_packet->src_mac[2];
    target.mac[3] = socket->rx_packet->src_mac[3];
    target.mac[4] = socket->rx_packet->src_mac[4];
    target.mac[5] = socket->rx_packet->src_mac[5];
    target.ip[0]  = socket->rx_packet->src_ip[0];
    target.ip[1]  = socket->rx_packet->src_ip[1];
    target.ip[2]  = socket->rx_packet->src_ip[2];
    target.ip[3]  = socket->rx_packet->src_ip[3];

    ip_length = 20+20 + telnet_payload_length;
    
    /* Copy the payload into the transmit buffer */
    if (telnet_payload_length != 0) {
        for (i=14+ip_length-telnet_payload_length, j=0; i<14+ip_length;i++,j++) {
            buf[i] = telnet_payload[j];
            }
        }
    
    if (telnet_payload_length)
        socket->tcp_buf[socket->tcp_current_buf]->payload_valid = 1;
    else
        socket->tcp_buf[socket->tcp_current_buf]->payload_valid = 0;
    
    socket->tcp_buf[socket->tcp_current_buf]->ack_received = 0;
    socket->tcp_buf[socket->tcp_current_buf]->starting_seq = tcp_header(&buf[34], socket, telnet_payload_length, TCP_NORMAL); 
    socket->tcp_buf[socket->tcp_current_buf]->ending_seq   = socket->tcp_buf[socket->tcp_current_buf]->starting_seq + telnet_payload_length;
    set_timer(&socket->tcp_buf[socket->tcp_current_buf]->resend_time, 500);

    ip_header(&buf[14], &target, ip_length, 6); /* 20 byes of tcp  options, bytes 14 to 33, ip_proto = 6, TCP*/
    ethernet_header(buf, &target, 0x0800);  /*bytes 0 to 13*/

    socket->tcp_buf[socket->tcp_current_buf]->len_bytes = 14+ip_length;
    
    strncpy((char*)ETHMAC_TX_BUFFER, buf, socket->tcp_buf[socket->tcp_current_buf]->len_bytes);

    tx_packet(socket->tcp_buf[socket->tcp_current_buf]->len_bytes);  // MAC header, IP header, TCP header, TCP options
    socket->packets_sent++;


    /* Pick the next tx buffer to use */    
    if (socket->tcp_current_buf == TCP_TX_BUFFERS-1)
        socket->tcp_current_buf=0;
    else
        socket->tcp_current_buf++;
}




/* Find the packets lower than or equal to seq and mark them as acked */
void tcp_ack(socket_t* socket)
{
    int i, ack_valid;
    unsigned int ack      = socket->rx_packet->tcp_ack;
    unsigned int last_ack = socket->tcp_last_ack;
    
    for (i=0;i<TCP_TX_BUFFERS;i=i+1) {
        if (socket->tcp_buf[i]->payload_valid) {
        
            if (ack > last_ack) {
                ack_valid = (socket->tcp_buf[i]->ending_seq > last_ack) && 
                            (socket->tcp_buf[i]->ending_seq <= ack);
                }
            else { /* ack is a little after 0, last_ack is a little before 0 */
                if (socket->tcp_buf[i]->ending_seq < last_ack)
                    /* ending sequence is a little after 0 */
                    ack_valid = socket->tcp_buf[i]->ending_seq <= ack;
                else
                    ack_valid = 1;
                }
                
            if (ack_valid)  {
                socket->tcp_buf[i]->ack_received = 1;
                if (socket->tcp_buf[i]->ending_seq == ack) break;
                }
            }
        }
        
   socket->tcp_last_ack = ack;
}


/* Check if any tcp packets need to be re-transmitted */
void tcp_retransmit(socket_t* socket) 
{
    int i;
    
    /* Find the packet that matches seq */
    for (i=0;i<TCP_TX_BUFFERS;i=i+1) {
        if (socket->tcp_buf[i]->payload_valid && !socket->tcp_buf[i]->ack_received) {
            if (timer_expired(&socket->tcp_buf[i]->resend_time))  {
            
                /* Update the timer to trigger again in another little while */
                set_timer(&socket->tcp_buf[i]->resend_time, 500);
                
                socket->packets_resent++;
                
                /* Disable ethmac_int interrupt */
                *(unsigned int *) ( ADR_AMBER_IC_IRQ0_ENABLECLR ) = 0x100;
            
                strncpy((char*)ETHMAC_TX_BUFFER, socket->tcp_buf[i]->buf, socket->tcp_buf[i]->len_bytes);
                tx_packet(socket->tcp_buf[i]->len_bytes);  // MAC header, IP header, TCP header, TCP options
                socket->packets_sent++;
                
                
                /* Enable ethmac_int interrupt */
                *(unsigned int *) ( ADR_AMBER_IC_IRQ0_ENABLESET ) = 0x100;
                break;
                }
            }
        }
}


/* return the starting seq number for this packet */
unsigned int tcp_header(char *buf, socket_t* socket, int payload_length, int options)
{
    unsigned short header_checksum;
    unsigned int seq_num;
    unsigned int ack_num;
    char flags = 0;
    unsigned short len_tcp;
    unsigned int starting_seq;
    
    /* Source Port */
    buf[0] = socket->rx_packet->tcp_dst_port >>8; 
    buf[1] = socket->rx_packet->tcp_dst_port &0xff; 

    /* Destination Port */
    buf[2] = socket->rx_packet->tcp_src_port >>8; 
    buf[3] = socket->rx_packet->tcp_src_port &0xff; 

    /* Sequence Number */
    /* Increment the sequence number for the next packet */
    starting_seq = socket->tcp_seq;
    socket->tcp_last_seq = socket->tcp_seq;
    socket->tcp_seq += payload_length;
    
    
    buf[4] =  starting_seq>>24;
    buf[5] = (starting_seq>>16)&0xff;
    buf[6] = (starting_seq>>8)&0xff;
    buf[7] =  starting_seq&0xff;

    
    /* Ack Number */
    if (options == TCP_NEW)
        ack_num = socket->rx_packet->tcp_seq + 1;
    else if (socket->rx_packet->tcp_flags & 0x01) // FIN 
        // +1 to the final ack
        ack_num = socket->rx_packet->tcp_seq + 1;
    else
        ack_num = socket->rx_packet->tcp_seq + socket->rx_packet->tcp_payload_len;
    
    buf[8]  =  ack_num>>24;
    buf[9]  = (ack_num>>16)&0xff;
    buf[10] = (ack_num>>8)&0xff;
    buf[11] =  ack_num&0xff;


    /* Data offset with OPTIONS */
    if (options == TCP_NEW)
        buf[12] = 0xa0;  /* upper 4 bits, min is 5 */
    else
        buf[12] = 0x50;  /* upper 4 bits, min is 5 */

    
    /* Flags */
    flags = 0x10;       /* ACK */    
    if (options == TCP_NEW)    /* Valid in first reply in new connection only */
        flags |= 0x02;  /* SYNchronise */
    if (socket->tcp_disconnect)    
        flags |= 0x01;  /* FINish */
    if (socket->tcp_reset)    
        flags |= 0x04;  /* Reset */
        
    buf[13] = flags;
    
    /* Window Size */
    buf[14] = socket->rx_packet->tcp_window_size >> 8;
    buf[15] = socket->rx_packet->tcp_window_size & 0xff;
    
    /* Checksum */
    buf[16] = 0;
    buf[17] = 0;
    
    /* Urgent Pointer */
    buf[18] = 0;
    buf[19] = 0;
        
    
    if (options == TCP_NEW) {
        /* OPTION: max seg size */
        buf[20] = 0x02;
        buf[21] = 0x04; 
        buf[22] = 0x05;
        buf[23] = 0xb4;
    
        /* OPTION Sack OK */
        buf[24] = 0x04;
        buf[25] = 0x02;
    
        /* OPTION Time Stamp */
        buf[26] = 0x08;
        buf[27] = 0x0a;
        buf[28] = 0x00;
        buf[29] = 0x61;
        buf[30] = 0x1f;
        buf[31] = 0xc6;
        buf[32] =  socket->rx_packet->tcp_src_time_stamp>>24;
        buf[33] = (socket->rx_packet->tcp_src_time_stamp>>16)&0xff;
        buf[34] = (socket->rx_packet->tcp_src_time_stamp>>8)&0xff;
        buf[35] =  socket->rx_packet->tcp_src_time_stamp&0xff;
    
        /* OPTION: NOP */
        buf[36] = 0x01;

        /* OPTION Window Scale */
        buf[37] = 0x03;
        buf[38] = 0x03;
        buf[39] = 0x06;
        }

        
    /* Length */
    if (options == TCP_NEW)
        len_tcp = 40+payload_length;
    else
        len_tcp = 20+payload_length;
      
    
    /* header checksum */
    header_checksum = tcp_checksum(buf, socket->rx_packet, len_tcp);    
    buf[16] = (header_checksum>>8)&0xff;
    buf[17] = header_checksum&0xff;
    
    return starting_seq;
}


unsigned short tcp_checksum(unsigned char *buf, packet_t* rx_packet, unsigned short len_tcp)
{
    unsigned short prot_tcp=6;
    unsigned short word16;
    unsigned long  sum;     
    int i;
	        
    //initialize sum to zero
    sum=0;
    if (!len_tcp) len_tcp = rx_packet->tcp_len;
    
    
    // add the TCP pseudo header which contains:
    // the IP source and destinationn addresses,
    for (i=0;i<4;i=i+2){
            word16 =((rx_packet->src_ip[i]<<8)&0xFF00)+(rx_packet->src_ip[i+1]&0xFF);
            sum=sum+word16; 
    }
    for (i=0;i<4;i=i+2){
            word16 =((rx_packet->dst_ip[i]<<8)&0xFF00)+(rx_packet->dst_ip[i+1]&0xFF);
            sum=sum+word16;         
    }
    // the protocol number and the length of the TCP packet
    sum = sum + prot_tcp + len_tcp;


    return header_checksum16(buf, len_tcp, sum);
}

