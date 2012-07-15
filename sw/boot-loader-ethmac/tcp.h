/*----------------------------------------------------------------
//                                                              //
//  boot-loader.h                                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Defines for the boot-loader application.                    //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2010 Authors and OPENCORES.ORG                 //
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


enum tcp_state {
	TCP_CLOSED    = 0,
	TCP_PENDING   = 1,
	TCP_OPEN      = 2
};


enum tcp_options {
        TCP_NEW         = 0,
        TCP_NORMAL      = 1,
        TCP_RESET       = 2
};


unsigned short  tcp_checksum            (unsigned char *, packet_t*, unsigned short);
unsigned int    tcp_header              (char *, socket_t*, int, int);
void            tcp_reply               (socket_t*, char*, int);
void            tcp_open                (socket_t*);
void            tcp_retransmit          (socket_t*);
void            tcp_ack                 (socket_t*);
void            tcp_response            (char*, socket_t*);
void            tcp_disconnect          (socket_t*);
void            tcp_tx                  (socket_t*, char*, int);
void            parse_tcp_options       (char*, packet_t*);
void            parse_tcp_packet        (char*, packet_t*);

extern int      tcp_checksum_errors_g;


