//////////////////////////////////////////////////////////////////
//                                                              //
//  Wishbone Slave to Xilinx Spartan-6 MCB (DDR3 controller)    //
//  Bridge                                                      //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Converts wishbone read and write accesses to the signalling //
//  used by the Xilinx DDR3 Controller in Spartan-6 FPGAs.      //
//                                                              //
//  The MCB is configured with a single 128-bit port.           //
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


module wb_xs6_ddr3_bridge
(
input                          i_clk,

input                          i_mem_ctrl,  // 0=128MB, 1=32MB

// Wishbone Bus
input       [31:0]             i_wb_adr,
input       [3:0]              i_wb_sel,
input                          i_wb_we,
output reg  [31:0]             o_wb_dat         = 'd0,
input       [31:0]             i_wb_dat,
input                          i_wb_cyc,
input                          i_wb_stb,
output                         o_wb_ack,
output                         o_wb_err,

output                         o_cmd_en,                // Command Enable
output reg [2:0]               o_cmd_instr      = 'd0,  // write = 000, read = 001
output reg [29:0]              o_cmd_byte_addr  = 'd0,  // Memory address
input                          i_cmd_full,              // DDR3 I/F Command FIFO is full

input                          i_wr_full,               // DDR3 I/F Write Data FIFO is full
output                         o_wr_en,                 // Write data enable
output reg [15:0]              o_wr_mask        = 'd0,  // 1 bit per byte
output reg [127:0]             o_wr_data        = 'd0,  // 16 bytes write data
input      [127:0]             i_rd_data,               // 16 bytes of read data
input                          i_rd_empty               // low when read data is valid

);
                 
wire            start_write;
wire            start_read;
reg             start_write_d1;
reg             start_read_d1;
reg             start_read_hold = 'd0;
reg  [29:0]     wb_adr_d1;
wire            ddr3_busy;
reg             read_ack = 'd0;
reg             read_ready = 1'd1;
reg             cmd_en_r = 'd0;
reg             wr_en_r = 'd0;

assign start_write = i_wb_stb && i_wb_we && !start_read_d1;
assign start_read  = i_wb_stb && !i_wb_we && read_ready;
assign ddr3_busy   = i_cmd_full;// || i_wr_full;

assign o_wb_err    = 'd0;

// ------------------------------------------------------
// Outputs
// ------------------------------------------------------

// Command FIFO
always @( posedge i_clk )
    if ( !ddr3_busy )
        begin
        o_cmd_byte_addr  <= {wb_adr_d1[29:4], 4'd0};
        cmd_en_r         <= ( start_write_d1 || start_read_d1 );
        o_cmd_instr      <= start_write_d1 ? 3'd0 : 3'd1;
        end

assign o_cmd_en = cmd_en_r && !i_cmd_full;

// ------------------------------------------------------
// Write
// ------------------------------------------------------
always @( posedge i_clk )
    if ( !ddr3_busy )
        begin
        wr_en_r    <= start_write;
        
        o_wr_mask  <= i_wb_adr[3:2] == 2'd0 ? { 12'hfff, ~i_wb_sel          } : 
                      i_wb_adr[3:2] == 2'd1 ? { 8'hff,   ~i_wb_sel, 4'hf    } : 
                      i_wb_adr[3:2] == 2'd2 ? { 4'hf,    ~i_wb_sel, 8'hff   } : 
                                              {          ~i_wb_sel, 12'hfff } ; 
        
        o_wr_data  <= {4{i_wb_dat}};
        end

assign o_wr_en = wr_en_r && !i_cmd_full;
 
// ------------------------------------------------------
// Read
// ------------------------------------------------------
always @( posedge i_clk )
    begin
    if ( read_ack )
        read_ready <= 1'd1;
    else if ( start_read )
        read_ready <= 1'd0;
    
    if ( !ddr3_busy )
        begin
        start_write_d1  <= start_write;
        start_read_d1   <= start_read;
        wb_adr_d1       <= i_mem_ctrl ? {5'd0, i_wb_adr[24:0]} : i_wb_adr[29:0];
        end
        
    if ( start_read  )
        start_read_hold <= 1'd1;
    else if ( read_ack )
        start_read_hold <= 1'd0;
    
    if ( i_rd_empty == 1'd0 && start_read_hold )
        begin
        o_wb_dat  <= i_wb_adr[3:2] == 2'd0 ? i_rd_data[ 31: 0] :
                     i_wb_adr[3:2] == 2'd1 ? i_rd_data[ 63:32] :
                     i_wb_adr[3:2] == 2'd2 ? i_rd_data[ 95:64] :
                                             i_rd_data[127:96] ;
        read_ack  <= 1'd1;
        end
    else
        read_ack  <= 1'd0;
    end
                    
assign o_wb_ack = i_wb_stb && ( start_write || read_ack ) && !i_cmd_full;

    
endmodule

