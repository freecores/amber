/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests sub and subs                                          //
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
*****************************************************************/

#include "amber_registers.h"

	.section .text
	.globl	main        
main:
        @ enable the cache
        mov     r0,  #0x4
	mcr	p15, 0, r0, c1, c0, 0

        @ Load some bytes into the testbench uart
        @ so it can transmit them to the Amber UART
        ldr     r4, AdrTEST_UART_TXD
        ldr     r5, =Message
        ldr     r7, =EndMessage
        ldr     r8, AdrTEST_UART_STATUS       
         
        @ transmit a byte from test uart
1:      ldrb    r6, [r5], #1
        str     r6, [r4]

        @ full message transmitted?
        cmp     r5, r7
        bne     1b

        @ test_uart transmit enable
        ldr     r0, AdrTEST_UART_CONTROL
        mov     r1, #1
        str     r1, [r0]

        /* Enable the UART FIFO */
        ldr     r4, AdrUARTLCR
        mov     r5, #0x10
        str     r5, [r4]

        mov     r8, #10
        mov     lr, #0x800
        mov     sp, #0
        mov     r6, #0
        
3:      mov     r0, #1
        bl      _inbyte
        add     r5, sp, #24
        subs    r7, r0, #0 
        sub     r5, r5, #6 
        add     r3, r6, #4 
        bge     2f
        
        mov     r10, #10
        b       testfail
        
2:      subs    r8, r8, #1
        beq     testpass
        b       3b


        @ r0 is the timeout in mS
	.globl _inbyte      
_inbyte:        
        ldr     r1, AdrUARTDR
        ldr     r3, AdrUARTFR
        
        @ Multiple delay value by 2560
        @ as the delay loop takes about 12 clock cycles running cached
        @ so that factor gives 1:1mS @33MHz
        mov     r2, r0, lsl #11
        add     r2, r2, r0, lsl #9
        
        @ Check the rx empty flag
2:      ldr     r0, [r3]
        ands    r0, r0, #0x10
        ldreqb  r0, [r1]
        moveq   pc, lr
        
        @ decrement timeout
        subs    r2, r2, #1
        bne     2b
        
        mov     r0, #-1
        mov     pc, lr


testfail:
        ldr     r11, AdrTestStatus
        str     r10, [r11]
        b       testfail
        
testpass:             
        ldr     r11, AdrTestStatus
        mov     r10, #17
        str     r10, [r11]
        b       testpass


/* Write 17 to this address to generate a Test Passed message */
AdrTestStatus:  .word  ADR_AMBER_TEST_STATUS
MaxPos:         .word  0x7fffffff
AdrUARTDR:      .word  ADR_AMBER_UART0_DR
AdrUARTFR:      .word  ADR_AMBER_UART0_FR
AdrUARTLCR:     .word  ADR_AMBER_UART0_LCRH

AdrTEST_UART_CONTROL:   .word  ADR_AMBER_TEST_UART_CONTROL     
AdrTEST_UART_STATUS:    .word  ADR_AMBER_TEST_UART_STATUS     
AdrTEST_UART_TXD:       .word  ADR_AMBER_TEST_UART_TXD  

Message:                .ascii "abcdefghijkl"
EndMessage:             .word  0

/* ========================================================================= */
/* ========================================================================= */
        

