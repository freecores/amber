/*----------------------------------------------------------------
//                                                              //
//  start.S                                                     //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Assembly routines for boot-loader.                          //
//  As boot-loader is a stand-alone application, it needs a     //
//  simple start function written in assembly to call the       //
//  C code main() function.                                     //
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


	.section .text
	.globl	start 
start:               
        /* 0x00 Reset Interrupt vector address */
        b       startup

        /* 0x04 Undefined Instruction Interrupt vector address */
        b       _testfail
        
        /* 0x08 SWI Interrupt vector address */
        b       _testfail
        
        /* 0x0c Prefetch abort Interrupt vector address */
        b       _testfail
        
        /* 0x10 Data abort Interrupt vector address */
        b       _testfail
        b       _testfail
        
        /* 0x18 IRQ vector address */
        b       _testfail
        
        /* 0x1c FIRQ vector address */
        b       _testfail
        
startup:
        /* Switch to User Mode */
        /* and unset interrupt mask bits */
        mov     r0,   #0x00000000
        teqp    pc, r0 
 
        @ Enable the cache
        mov     r0,  #0xffffffff
	mcr	p15, 0, r0, c3, c0, 0   @ cacheable area
        mov     r0,  #1
	mcr	p15, 0, r0, c2, c0, 0   @ cache enable
        
        @ init SP
        ldr     sp, AdrStack

        .extern main
        bl      main
                
        @ jump to program at 0x8000
	.globl _jump_to_program
_jump_to_program:

        @ disable Interrupts
        teqp    pc, #0x0c000000
                
        @ jump to start of program
        ldr     pc, AdrInit


        @ ----------------------------------------------
        @ Print CPU Core status
        @ ----------------------------------------------
	.globl	 _core_status
_core_status:
        stmdb   sp!,{lr}
        stmdb   sp!,{r0-r12}
        mov     r4, #0
        mov     r5, sp
        mov     r6, lr
        
1:      ldr     r0, =Status_Message
        mov     r1, r4
        ldr     r2, [r5], #4
        bl      printf
        
        cmp     r4, #13
        addne   r4, r4, #1
        bne     1b
        
        @ Stack Pointer
        ldr     r0, =SPStatus_Message
        mov     r1, sp
        bl      printf
        
        @ Program Counter - Use Link Register value because
        @ want the PC value of whatever called this function
        ldr     r0, =PCStatus_Message
        sub     r1, r6, #4
        bl      printf
                
        ldmia  sp!,{r0-r12}
        ldmia  sp!,{pc}^
        

/* stack at top of ddr3 memory space */
AdrStack:                          .word 0x08000000
AdrInit:                           .word 0x00008000

/* core status messages */
Status_Message:                    .ascii "r%2d  0x%08x\n\00"
SPStatus_Message:                  .ascii "sp   0x%08x\n\00"
PCStatus_Message:                  .ascii "pc   0x%08x\n\00"

