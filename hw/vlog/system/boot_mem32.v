//////////////////////////////////////////////////////////////////
//                                                              //
//  8KBytes SRAM configured with boot software                  //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Holds just enough software to get the system going.         //
//  The boot loader fits into this 8KB embedded SRAM on the     //
//  FPGA and enables it to load large applications via the      //
//  serial port (UART) into the DDR3 memory                     //
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


module boot_mem32 #(
parameter WB_DWIDTH   = 32,
parameter WB_SWIDTH   = 4,
parameter MADDR_WIDTH = 11
)(
input                       i_wb_clk,     // WISHBONE clock

input       [31:0]          i_wb_adr,
input       [WB_SWIDTH-1:0] i_wb_sel,
input                       i_wb_we,
output      [WB_DWIDTH-1:0] o_wb_dat,
input       [WB_DWIDTH-1:0] i_wb_dat,
input                       i_wb_cyc,
input                       i_wb_stb,
output                      o_wb_ack,
output                      o_wb_err

);

wire                    start_write;
wire                    start_read;
reg                     start_read_r = 'd0;
wire [WB_DWIDTH-1:0]    read_data;
wire [WB_DWIDTH-1:0]    write_data;
wire [WB_SWIDTH-1:0]    byte_enable;
wire [MADDR_WIDTH-1:0]  address;


// Can't start a write while a read is completing. The ack for the read cycle
// needs to be sent first
assign start_write = i_wb_stb &&  i_wb_we && !start_read_r;
assign start_read  = i_wb_stb && !i_wb_we && !start_read_r;


always @( posedge i_wb_clk )
    start_read_r <= start_read;

assign o_wb_err = 1'd0;

assign write_data  = i_wb_dat;
assign byte_enable = i_wb_sel;
assign o_wb_dat    = read_data;
assign address     = i_wb_adr[MADDR_WIDTH+1:2];
assign o_wb_ack    = i_wb_stb && ( start_write || start_read_r );

// ------------------------------------------------------
// Instantiate SRAMs
// ------------------------------------------------------
//         
`ifdef XILINX_FPGA

    `ifdef XILINX_SPARTAN6_FPGA
        xs6_sram_2048x32_byte_en
    `endif 
    `ifdef XILINX_VIRTEX6_FPGA
        xv6_sram_2048x32_byte_en
    `endif 

#(
// This file holds a software image used for FPGA simulations
// This pre-processor syntax works with both the simulator
// and ISE, which I couldn't get to work with giving it the
// file name as a define.

`ifdef BOOT_MEM_PARAMS_FILE
    `include `BOOT_MEM_PARAMS_FILE
`else
    // default file
    `include "boot-loader_memparams32.v"
`endif

)
`endif 

`ifndef XILINX_FPGA
generic_sram_byte_en
#(
    .DATA_WIDTH     ( WB_DWIDTH             ),
    .ADDRESS_WIDTH  ( MADDR_WIDTH           )
)
`endif 
u_mem (
    .i_clk          ( i_wb_clk             ),
    .i_write_enable ( start_write          ),
    .i_byte_enable  ( byte_enable          ),
    .i_address      ( address              ),  // 2048 words, 32 bits
    .o_read_data    ( read_data            ),
    .i_write_data   ( write_data           )
);


// =======================================================================================
// =======================================================================================
// =======================================================================================
// Non-synthesizable debug code
// =======================================================================================


//synopsys translate_off
`ifdef XILINX_SPARTAN6_FPGA
    `ifdef BOOT_MEM_PARAMS_FILE
        initial
            $display("Boot mem file is %s", `BOOT_MEM_PARAMS_FILE );
    `endif
`endif
//synopsys translate_on
    
endmodule


