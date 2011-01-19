/*----------------------------------------------------------------
//                                                              //
//  ethermac-test.c                                             //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests the ethernet MAC in loopback mode.                    //
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


#include "amber_registers.h"
#include "stdio.h"

#define TX_BUFFER   0x28001000
#define RX_BUFFER   0x28001200
#define NUM_PACKETS 32

/* Correctly formatted Ethernet Frame */
unsigned int tx_packet[] =  { 0x0e000000,0xa0583e0c,0x554e5300,0x0008304c,
                              0x90000045,0x00400000,0xd5b61140,0x0501a8c0,
                              0x3201a8c0,0x01080203,0xb6c47c00,0xf67d4fc7,
                              0x00000000,0x02000000,0xa3860100,0x03000000,
                              0x06000000,0x01000000,0x18000000,0x025b8f02,
                              0x02000000,0x00003170,0x00000000,0x00000000,
                              0x00000000,0x00000000,0x00000000,0x24000000,
                              0x01070001,0x00143ed5,0x00000000,0x2c043c7f,
                              0x6c41657c,0x8cc37e87,0x2340a928,0x0026048e,
                              0xec587a0e,0x00000000,0x00080000,0x00080000 };

int main () 
{
    int i;
    int packet;
    int timeout;
    int sizeof_packet = sizeof (tx_packet);

    printf ("Starting ethmac-test\n");

    /* Access ethmac */

    /* Write the Transmit Packet Buffer Descriptor */
    /* Buffer Pointer */
    *(unsigned int *) ( ADR_ETHMAC_BDBASE + 0x004 ) = TX_BUFFER + 2;
    /* [31:16] = length in bytes, Bit[15] = ready, Bit [13] = wrap bit */
    *(unsigned int *) ( ADR_ETHMAC_BDBASE + 0x000 ) = 0x00002800 | sizeof_packet <<16;

    /* Write the Receive Packet Buffer Descriptor */
    /* Buffer Pointer */
    *(unsigned int *) ( ADR_ETHMAC_BDBASE + 0x204 ) = RX_BUFFER;
    /* [31:16] = length in bytes, Bit[15] = empty, Bit [13] = wrap bit */
    *(unsigned int *) ( ADR_ETHMAC_BDBASE + 0x200 ) = 0x0000a800;

    /* Write Packet into Tx Buffer */
    memcpy ( TX_BUFFER, tx_packet, sizeof_packet );

    /*
     [15] = Add pads to short frames
     [13] = CRCEN
     [7]  = loopback
     [5]  = 1 for promiscuous, 0 rx only frames that match mac address
     [1]  = txen
     [0]  = rxen
    */
    *(unsigned int *) ( ADR_ETHMAC_MODER ) = 0xa0a3;


    for (packet=0; packet<NUM_PACKETS; packet++) {

        if (!(packet%8)) printf("\ntx %04d\n", packet);
        
       /* Ready Rx buffer */
       *(unsigned int *) ( ADR_ETHMAC_BDBASE + 0x200 ) = 0x0000a800;
       
       /* Start transmit */
       *(unsigned int *) ( ADR_ETHMAC_BDBASE + 0x000 ) = 0x0000a800 | sizeof_packet <<16;
       
       /* Wait until transmit is complete */
       while ( (*(volatile unsigned int *) ( ADR_ETHMAC_BDBASE + 0x000 )) & 0x8000 );
       
       /* Wait until receive complete - Wait for Empty bit to go low */
       timeout = 0;
       while ( (*(volatile unsigned int *) ( ADR_ETHMAC_BDBASE + 0x200 )) & 0x8000 ) {
            if (timeout++ > 200) {
                /* Extra characters at end of printf to flush the uart tx buffer
                   before the sijmulation is stopped */
                printf("Timeout waiting for packet %d rx\n", packet);
                printf("BD entry 0x%08x 0x%08x\n", 
                        *(volatile unsigned int *) ( ADR_ETHMAC_BDBASE + 0x200 ),
                        *(volatile unsigned int *) ( ADR_ETHMAC_BDBASE + 0x204 ));
                
                goto next_packet;        
                }
            }
          
       /* Check some of the received data */
       if ( *(volatile unsigned int *) 0x28001200 != 0x3e0c0e00 ) _testfail(20);
       if ( *(volatile unsigned int *) 0x28001204 != 0x5300a058 ) _testfail(21);
       
       
       /* Check for Ethernet MAC underrun */
       if (  (*(volatile unsigned int *) ( ADR_ETHMAC_BDBASE + 0x000 )) & 0x100 ) {
            printf("underrun error, loop %d\n", packet);
            _testfail (50);   
            }
        
        next_packet: ;
        }
        
    printf ("\nall done.\nCan't return to boot loader because used the boot mem as a packet buffer\n");
    printf ("                   \n");
    _testpass();
}

