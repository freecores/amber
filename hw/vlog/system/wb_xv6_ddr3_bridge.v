//////////////////////////////////////////////////////////////////
//                                                              //
//  Wishbone Slave to Xilinx Virtex-6 DDR3 controller           //
//  Bridge                                                      //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Converts wishbone read and write accesses to the signalling //
//  used by the Xilinx DDR3 Controller in Virtex-6 FPGAs.       //
//                                                              //
//  The MCB is confgiured with a single 128-bit port.           //
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


module wb_xv6_ddr3_bridge
(
input                          i_sys_clk,
input                          i_ddr_clk,

input                          i_mem_ctrl,  // 0=128MB, 1=32MB

// Wishbone Ports
input       [31:0]             i_wb_adr,
input       [3:0]              i_wb_sel,
input                          i_wb_we,
output      [31:0]             o_wb_dat,
input       [31:0]             i_wb_dat,
input                          i_wb_cyc,
input                          i_wb_stb,
output                         o_wb_ack,
output                         o_wb_err,

input                          i_phy_init_done,
output                         o_phy_init_done,

output                         o_ddr_cmd_en,           // Command Enable
output     [2:0]               o_ddr_cmd_instr,        // write = 000, read = 001
output     [26:0]              o_ddr_cmd_byte_addr,    // Memory address
input                          i_ddr_cmd_full,         // DDR3 I/F Command FIFO is full

input                          i_ddr_wr_full,          // DDR3 I/F Write Data FIFO is full
output                         o_ddr_wr_en,            // Write data enable
output                         o_ddr_wr_end,           // Mark the second 64-byte word of the transfer
output     [7:0]               o_ddr_wr_mask,          // 1 bit per byte
output     [63:0]              o_ddr_wr_data,          // 8 bytes write data

input      [63:0]              i_ddr_rd_data,          // 8 bytes of read data
input                          i_ddr_rd_valid          // low when read data is valid

);
                 
wire            start_write;
wire            start_read;
wire            busy;
reg             read_busy = 1'd0;

wire            cmd_en;
wire  [2:0]     cmd_instr;
wire  [26:0]    cmd_addr;
wire            cmd_full;
wire            wr_full;
wire            rd_valid;
wire  [26:0]    ddr_cmd_byte_addr;
wire  [31:0]    ddr_wr_data;
wire  [31:0]    ddr_rd_data;
wire  [3:0]     ddr_wr_mask;
wire  [7:0]     wr_mask64;
wire  [1:0]     ddr_wr_addr_32;
wire            ddr_addr2;
reg             ddr_addr2_r     = 1'd0;
wire            ddr_wr_en;
reg             ddr_wr_en_r     = 1'd0;
wire            ddr_rd_valid;
reg             ddr_rd_valid_r  = 1'd0;

reg             cmd_en_r    = 'd0;
reg [2:0]       cmd_instr_r = 'd0;
reg [26:0]      cmd_addr_r  = 'd0;
reg [11:0]      phy_init_count = 'd0;


assign o_wb_err             = 'd0;
assign o_wb_ack             = i_wb_stb && ( start_write || rd_valid );
assign o_ddr_cmd_byte_addr  = {ddr_cmd_byte_addr[26:3], 3'd0};
assign ddr_addr2            = ddr_cmd_byte_addr[2];

assign o_ddr_wr_en          = ddr_wr_en | ddr_wr_en_r;
assign o_ddr_wr_end         = ddr_wr_en_r;
assign o_ddr_wr_data        = ddr_wr_en_r ?  64'h0 : {2{ddr_wr_data}};
assign o_ddr_wr_mask        = ddr_wr_en_r ?  8'hff : wr_mask64;
assign wr_mask64            = ddr_wr_addr_32[0] ?  {ddr_wr_mask, 4'hf} : {4'hf, ddr_wr_mask} ;

assign start_write          = i_wb_stb &&  i_wb_we && !busy;
assign start_read           = i_wb_stb && !i_wb_we && !busy;
assign busy                 = cmd_full | wr_full | read_busy;

assign cmd_en               = start_write || start_read;
assign cmd_instr            = start_write ? 3'd0 : 3'd1;
assign cmd_addr             = i_mem_ctrl ? {2'd0, i_wb_adr[24:0]} : i_wb_adr[26:0];

assign ddr_rd_valid         = i_ddr_rd_valid && !ddr_rd_valid_r;
assign ddr_rd_data          = ddr_addr2_r ? i_ddr_rd_data[63:32] : i_ddr_rd_data[31:00];


// Delay the phy_init_done signal.
// The memory model issues an error if
// it is accesses striaght away after
// phy_init_done done go9es high. May be a 
// configuration issue, but this is a simple work
// around
always @( posedge i_sys_clk )
    if ( i_phy_init_done && !o_phy_init_done )
        phy_init_count <= phy_init_count + 1'd1;
        
assign o_phy_init_done = phy_init_count == 12'hfff;


// Use the read_busy reg to gate start_read
// so that it only pulses high for 1 tick at the
// start of a read sequence
always @( posedge i_sys_clk )
    if ( rd_valid )
        read_busy <= 1'd0;
    else if ( start_read )
        read_busy <= 1'd1;


always @( posedge i_sys_clk )
    if ( !cmd_full )
        begin
        cmd_en_r    <= cmd_en;
        cmd_instr_r <= cmd_instr;
        cmd_addr_r  <= cmd_addr;
        end

    
always @( posedge i_ddr_clk )
    begin
    ddr_wr_en_r     <= ddr_wr_en;
    ddr_rd_valid_r  <= i_ddr_rd_valid;
    if ( o_ddr_cmd_en ) 
        ddr_addr2_r <= ddr_addr2;
    end

    
ddr3_afifo#(
            .ADDR_WIDTH             ( 27                    ),
            .DATA_WIDTH             ( 32                    )
            )
       u_ddr3_afifo (
            .i_sys_clk              ( i_sys_clk             ),
            .i_ddr_clk              ( i_ddr_clk             ),

            // Wishbone Side
            .i_cmd_en               ( cmd_en_r              ),     
            .i_cmd_instr            ( cmd_instr_r           ),     
            .i_cmd_byte_addr        ( cmd_addr_r            ),     
            .o_cmd_full             ( cmd_full              ),     
            
            .o_wr_full              ( wr_full               ),     
            .i_wr_en                ( start_write           ),     
            .i_wr_mask              ( ~i_wb_sel             ),    
            .i_wr_data              ( i_wb_dat              ), 
            .i_wr_addr_32           ( i_wb_adr[3:2]         ), 
                
            .o_rd_data              ( o_wb_dat              ),     
            .o_rd_valid             ( rd_valid              ),     

            // DDR3 Side
            .o_ddr_cmd_en           ( o_ddr_cmd_en          ),  
            .o_ddr_cmd_instr        ( o_ddr_cmd_instr       ),  
            .o_ddr_cmd_byte_addr    ( ddr_cmd_byte_addr     ),  
            .i_ddr_cmd_full         ( i_ddr_cmd_full        ),
            
            .i_ddr_wr_full          ( i_ddr_wr_full         ),  
            .o_ddr_wr_en            ( ddr_wr_en             ),  
            .o_ddr_wr_mask          ( ddr_wr_mask           ),  
            .o_ddr_wr_data          ( ddr_wr_data           ),
            .o_ddr_wr_addr_32       ( ddr_wr_addr_32        ),
            
            .i_ddr_rd_data          ( ddr_rd_data           ),  
            .i_ddr_rd_valid         ( ddr_rd_valid          )
            );
    

// =======================================================================================
// =======================================================================================
// =======================================================================================
// Non-synthesizable debug code
// =======================================================================================


//synopsys translate_off
reg [7:0] cmd_full_count = 8'hff;

always @( posedge i_ddr_clk )
    begin
    if ( o_ddr_cmd_en && !i_ddr_cmd_full )
        cmd_full_count <= 'd0;
    else if ( cmd_full_count != 8'hff )
        begin
        if ( i_ddr_cmd_full )
            begin
            if ( cmd_full_count != 8'hfe )
                cmd_full_count <= cmd_full_count + 1'd1;
            else
                cmd_full_count <= 'd0;
            end
        else
            cmd_full_count <= 'd0;
        end
        
    if ( cmd_full_count == 8'hfe )
        begin
        `TB_ERROR_MESSAGE
        $display("Virtex-6 DDR3 Command I/F stuck full");
        end
    end
    
    
//synopsys translate_on

endmodule


