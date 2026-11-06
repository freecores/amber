/*****************************************************************
//                                                              //
//  Amber 2 Core Instruction Test                               //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Tests V preservation by logical flag-setting instructions  //
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
        .globl main
main:
        @ Each logical operation must preserve V set by signed overflow.
        mvn     r0, #0x80000000
        mov     r1, #0
        mov     r2, #1
        mov     r10, #1
        adds    r3, r0, #1
        ands    r4, r0, r2
        bvc     testfail
        eors    r4, r0, r0
        bvc     testfail
        orrs    r4, r1, r2
        bvc     testfail
        bics    r4, r0, r0
        bvc     testfail
        movs    r4, r2, lsl #31
        bvc     testfail
        mvns    r4, #0
        bvc     testfail
        tst     r0, r1
        bvc     testfail
        teq     r0, r0
        bvc     testfail

        @ Arithmetic must still clear V, and logical operations keep it clear.
        mov     r10, #2
        adds    r3, r1, #1
        bvs     testfail
        mvns    r4, #0
        bvs     testfail

        @ A failed predicate preserves both the destination and flags.
        mov     r10, #3
        adds    r3, r0, #1
        movsvc  r4, #0
        bvc     testfail
        cmn     r4, #1
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

AdrTestStatus: .word ADR_AMBER_TEST_STATUS
