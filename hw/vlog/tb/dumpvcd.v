//////////////////////////////////////////////////////////////////
//                                                              //
//  Waveform Dumping Control                                    //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Its useful in very long simulations to be able to record    //
//  a set of signals for a limited window of time, so           //
//  that the dump file does not get too large.                  //
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
//////////////////////////////////////////////////////////////////

`timescale  1 ns / 1 ps
`include "global_defines.v"

module dumpvcd();

    
// ======================================
// Dump Waves to VCD File
// ======================================
`ifdef AMBER_DUMP_VCD
initial
    begin
    $display ("VCD Dump enabled from %d to %d", 
    ( `AMBER_DUMP_START                ),
    ( `AMBER_DUMP_START + `AMBER_DUMP_LENGTH ) );
    
    $dumpfile(`AMBER_VCD_FILE);
    $dumpvars(1, `U_TB.clk_count);
    
    $dumpvars(1, `U_FETCH.o_read_data);
    $dumpvars(1, `U_DECOMPILE.xINSTRUCTION_EXECUTE);
    $dumpvars(1, `U_DECODE.firq_request);
    $dumpvars(1, `U_DECODE.irq_request);
    $dumpvars(1, `U_DECODE.swi_request);
    $dumpvars(1, `U_DECODE.interrupt);
    $dumpvars(1, `U_DECODE.next_interrupt);
    $dumpvars(1, `U_DECODE.interrupt_mode);
    $dumpvars(1, `U_DECODE.instruction_valid);
    $dumpvars(1, `U_DECODE.instruction_execute);
    $dumpvars(1, `U_DECODE.instruction);
    $dumpvars(1, `U_EXECUTE.i_fetch_stall);
    $dumpvars(1, `U_EXECUTE.o_write_enable);
    $dumpvars(1, `U_EXECUTE.o_exclusive);
    $dumpvars(1, `U_EXECUTE.o_write_data);
    $dumpvars(1, `U_EXECUTE.o_address);
    $dumpvars(1, `U_EXECUTE.base_address);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r0);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r1);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r2);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r3);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r4);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r5);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r6);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r7);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r8);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r9);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r10);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r11);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r12);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r13_out);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r14_out);
    $dumpvars(1, `U_EXECUTE.u_register_bank.r15);


    $dumpvars(1, `U_COPRO15);
    $dumpvars(1, `U_CACHE);
    $dumpvars(1, `U_WISHBONE);
    $dumpvars(1, `U_AMBER);    

    $dumpvars(1, `U_SYSTEM.u_main_mem); 

    $dumpoff;    
    end
    
always @(posedge `U_DECOMPILE.i_clk)
    begin
    if ( `U_DECOMPILE.clk_count == 10 )
        begin
        $dumpon;
        $display("Dump on at  %d ticks", `U_DECOMPILE.clk_count);
        end
            
    if ( `U_DECOMPILE.clk_count == 20 )
        begin
        $dumpoff;
        $display("Dump off at %d ticks", `U_DECOMPILE.clk_count);
        end


    if ( `U_DECOMPILE.clk_count == ( `AMBER_DUMP_START + 0 ) )
        begin
        $dumpon;
        $display("Dump on at  %d ticks", `U_DECOMPILE.clk_count);
        end
                                   
    if ( `U_DECOMPILE.clk_count == ( `AMBER_DUMP_START + `AMBER_DUMP_LENGTH ) )
        begin
        $dumpoff;
        $display("Dump off at %d ticks", `U_DECOMPILE.clk_count);
        end
        
    `ifdef AMBER_TERMINATE
    if ( `U_DECOMPILE.clk_count == ( `AMBER_DUMP_START + `AMBER_DUMP_LENGTH + 100) )
        begin
        $display("Automatic test termination after dump has completed");
        `TB_ERROR_MESSAGE
        end
    `endif
    end
    
    
    
`endif


    
endmodule
