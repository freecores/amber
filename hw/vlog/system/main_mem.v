//////////////////////////////////////////////////////////////////
//                                                              //
//  Main memory for simulations.                                //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Non-synthesizable main memory. Holds 128MBytes              //
//  The memory path in this module is purely combinational.     //
//  Addresses and write_cmd_req data are registered as          //
//  the leave the execute module and read data is registered    //
//  as it enters the instruction_decode module.                 //
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


module main_mem
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
output                         o_wb_err

);

`include "memory_configuration.v"

reg     [127:0]     ram   [2**(MAIN_MSB-2)-1:0];
wire                start_write;
wire                start_read;
reg                 start_read_d1;
reg                 start_read_d2;
wire    [127:0]     rd_data;
wire    [127:0]     masked_wdata;

reg                 wr_en           = 'd0;
reg     [15:0]      wr_mask         = 'd0;
reg     [127:0]     wr_data         = 'd0;
reg     [27:0]      addr_d1         = 'd0;
wire                busy;
genvar              i;


assign start_write = i_wb_stb &&  i_wb_we && !busy;
assign start_read  = i_wb_stb && !i_wb_we && !busy;
assign busy        = start_read_d1 || start_read_d2;

assign o_wb_err    = 'd0;


// ------------------------------------------------------
// Write
// ------------------------------------------------------
always @( posedge i_clk )
    begin
    wr_en          <= start_write;
    wr_mask        <= i_wb_adr[3:2] == 2'd0 ? { 12'hfff, ~i_wb_sel          } : 
                      i_wb_adr[3:2] == 2'd1 ? { 8'hff,   ~i_wb_sel, 4'hf    } : 
                      i_wb_adr[3:2] == 2'd2 ? { 4'hf,    ~i_wb_sel, 8'hff   } : 
                                              {          ~i_wb_sel, 12'hfff } ; 
    wr_data        <= {4{i_wb_dat}};

                      // Wrap the address at 32 MB, or full width
    addr_d1        <= i_mem_ctrl ? {5'd0, i_wb_adr[24:2]} : i_wb_adr[29:2];
    
    if ( wr_en )
        ram [addr_d1[27:2]]  <= masked_wdata;
    end


generate
for (i=0;i<16;i=i+1) begin : masked
    assign masked_wdata[8*i+7:8*i] = wr_mask[i] ? rd_data[8*i+7:8*i] : wr_data[8*i+7:8*i];
end
endgenerate

    

// ------------------------------------------------------
// Read
// ------------------------------------------------------
assign rd_data = ram [addr_d1[27:2]];


always @( posedge i_clk )
    begin
    start_read_d1   <= start_read;
    start_read_d2   <= start_read_d1;
    if ( start_read_d1 )
        begin
        o_wb_dat  <= addr_d1[1:0] == 2'd0 ? rd_data[ 31: 0] :
                     addr_d1[1:0] == 2'd1 ? rd_data[ 63:32] :
                     addr_d1[1:0] == 2'd2 ? rd_data[ 95:64] :
                                            rd_data[127:96] ;
        end
    end
                    
assign o_wb_ack = i_wb_stb && ( start_write || start_read_d2 );


endmodule




