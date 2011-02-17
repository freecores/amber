//////////////////////////////////////////////////////////////////
//                                                              //
//  Wrapper for Xilinx Virtex-6 RAM Block                       //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  256 words x 32 bits with a write enable per byte            //
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

module xv6_sram_256x21_line_en
#(
parameter DATA_WIDTH         = 21,
parameter INITIALIZE_TO_ZERO = 0,
parameter ADDRESS_WIDTH      = 8
)

(
input                           i_clk,
input      [DATA_WIDTH-1:0]     i_write_data,
input                           i_write_enable,
input      [ADDRESS_WIDTH-1:0]  i_address,
output     [DATA_WIDTH-1:0]     o_read_data
);                                                     


wire [15:0] read_data_a, read_data_b;

assign o_read_data = { read_data_b[9:0], read_data_a[10:0] };


RAMB18E1 #(
    .RAM_MODE               ( "TDP"                         ),
    .READ_WIDTH_A           ( 18                            ),
    .READ_WIDTH_B           ( 18                            ),
    .RSTREG_PRIORITY_A      ( "REGCE"                       ),
    .RSTREG_PRIORITY_B      ( "REGCE"                       ),
    .SIM_COLLISION_CHECK    ( "ALL"                         ),
    .INIT_A                 ( 18'h00000                     ),
    .INIT_B                 ( 18'h00000                     ),
    .WRITE_MODE_A           ( "READ_FIRST"                  ),
    .WRITE_MODE_B           ( "READ_FIRST"                  ),
    .WRITE_WIDTH_A          ( 18                            ),
    .WRITE_WIDTH_B          ( 18                            ))
u_sram0  (
    .CLKARDCLK              ( i_clk                         ),
    .CLKBWRCLK              ( i_clk                         ),
    .ENARDEN                ( 1'd1                          ),
    .ENBWREN                ( 1'd1                          ),
    .REGCEAREGCE            ( 1'd0                          ),
    .REGCEB                 ( 1'd0                          ),
    .RSTRAMARSTRAM          ( 1'd0                          ),
    .RSTRAMB                ( 1'd0                          ),
    .RSTREGARSTREG          ( 1'd0                          ),
    .RSTREGB                ( 1'd0                          ),
    .ADDRARDADDR            ( {1'd0, i_address[7:0], 5'd0}  ),
    .ADDRBWRADDR            ( {1'd0, i_address[7:0], 5'd16} ),
    .DIADI                  ( {5'd0, i_write_data[10:0]}    ), 
    .DIBDI                  ( {6'd0, i_write_data[20:11]}   ),
    .DIPADIP                ( 2'd0                          ),
    .DIPBDIP                ( 2'd0                          ),
    .DOADO                  ( read_data_a                   ),
    .DOBDO                  ( read_data_b                   ),
    .DOPADOP                (                               ),
    .DOPBDOP                (                               ),
    .WEA                    ( {2{i_write_enable}}           ),
    .WEBWE                  ( {2'd0, {2{i_write_enable}}}   )
  );
 

//synopsys translate_off
initial
    begin
    if ( DATA_WIDTH    != 21  ) 
        $display("%M Warning: Incorrect parameter DATA_WIDTH");
    if ( ADDRESS_WIDTH != 8   ) 
        $display("%M Warning: Incorrect parameter ADDRESS_WIDTH");
    end
//synopsys translate_on

endmodule


