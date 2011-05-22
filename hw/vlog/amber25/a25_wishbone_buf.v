//////////////////////////////////////////////////////////////////
//                                                              //
//  Wishbone master interface port buffer                       //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  This is a sub-module of the Amber wishbone master           //
//  interface. The wishbone master interface connects a number  //
//  of internal amber ports to the wishbone bus. The ports      //
//  are;                                                        //
//       instruction cache read accesses                        //
//       data cache read and write accesses (cached)            //
//       data cache read and write accesses (uncached)          //
//                                                              //
//  The buffer module buffers a single port. For write          //
//  requests, this allows the processor core to continue        //
//  executing withont having to wait for the wishbone write     //
//  operation to complete.                                      //
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
//////////////////////////////////////////////////////////////////

module a25_wishbone_buf (
input                       i_clk,

// Core side
input                       i_req,
input                       i_write,
input       [127:0]         i_wdata,
input       [15:0]          i_be,
input       [31:0]          i_addr,
output      [127:0]         o_rdata,
output                      o_ready,

// Wishbone side
output                      o_valid,
input                       i_accepted,
output                      o_write,
output      [127:0]         o_wdata,
output      [15:0]          o_be,
output      [31:0]          o_addr,
input       [127:0]         i_rdata,
input                       i_rdata_valid
);


// ----------------------------------------------------
// Signals
// ----------------------------------------------------
reg                         wbuf_used_r = 'd0;
reg  [127:0]                wbuf_wdata_r;
reg  [31:0]                 wbuf_addr_r;
reg  [15:0]                 wbuf_be_r;
reg                         wbuf_write_r = 'd0;
wire                        in_wreq = i_req && i_write;
reg                         busy_reading_r = 'd0;


// ----------------------------------------------------
// Access Buffer
// ----------------------------------------------------
always @(posedge i_clk)
    if (i_req && !wbuf_used_r)
        begin
        wbuf_used_r     <= !i_accepted;
        wbuf_wdata_r    <= i_wdata;
        wbuf_addr_r     <= i_addr;
        wbuf_be_r       <= i_write ? i_be : 16'hffff;
        wbuf_write_r    <= i_write;
        end
    else if ( i_req && wbuf_used_r && o_valid && i_accepted)   
        begin
        wbuf_used_r     <= 1'd1;
        wbuf_wdata_r    <= i_wdata;
        wbuf_addr_r     <= i_addr;
        wbuf_be_r       <= i_write ? i_be : 16'hffff;
        wbuf_write_r    <= i_write;
        end
    else if (o_valid && i_accepted && wbuf_write_r)
        wbuf_used_r     <= 1'd0;
    else if (i_rdata_valid && !wbuf_write_r)
        wbuf_used_r     <= 1'd0;


// ----------------------------------------------------
// Output logic
// ----------------------------------------------------
assign o_wdata = wbuf_used_r ? wbuf_wdata_r : i_wdata;
assign o_write = wbuf_used_r ? wbuf_write_r : i_write;
assign o_addr  = wbuf_used_r ? wbuf_addr_r  : i_addr;
assign o_be    = wbuf_used_r ? wbuf_be_r    : i_write ? i_be : 16'hffff;

assign o_valid   = (wbuf_used_r || i_req) && !busy_reading_r;

assign o_rdata = i_rdata;
assign o_ready = in_wreq ? (!wbuf_used_r || i_accepted) : i_rdata_valid;


always@(posedge i_clk)
    if (o_valid && !o_write && i_accepted)
        busy_reading_r <= 1'd1;
    else if (i_rdata_valid)
        busy_reading_r <= 1'd0;



endmodule




