/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests lsl, ror                                              //
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

/* lsl 0 */
        mov     r1, #1
        mov     r2, r1, lsl #0
        mov     r3, #0x1
        cmp     r2, r3
        bne     testfail

/* lsl 1 */
        mov     r4, #1
        mov     r5, r4, lsl #1
        mov     r6, #2
        cmp     r5, r6
        bne     testfail        
        
/* lsl 31 */
        mov     r7, #1
        mov     r8, r1, lsl #31
        mov     r9, #0x80000000
        cmp     r8, r9
        bne     testfail
        
/* lsr 1 */
        mov     r1, #2
        mov     r2, r1, lsr #1
        mov     r3, #0x1
        cmp     r2, r3
        bne     testfail
        
/* lsr 8 */
        mov     r4, #0xff00
        mov     r5, r4, lsr #8
        cmp     r5, #0xff
        bne     testfail
        
/* ror 8 */
        ldr     r6, Data1
        mov     r7, r6, ror #8
        ldr     r8, Data2
        cmp     r7, r8
        bne     testfail


        b       testpass
                

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
Data1:          .word  0x12345678
Data2:          .word  0x78123456

/* ========================================================================= */
/* ========================================================================= */
        

