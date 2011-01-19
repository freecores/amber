//////////////////////////////////////////////////////////////////
//                                                              //
//  Wrapper for Xilinx Virtex-6 RAM Block                       //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  256 words x 128 bits with a write enable per byte           //
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


module xv6_sram_256x128_byte_en 

#(
parameter DATA_WIDTH    = 128,
parameter ADDRESS_WIDTH = 8
)

(
input                           i_clk,
input      [DATA_WIDTH-1:0]     i_write_data,
input                           i_write_enable,
input      [ADDRESS_WIDTH-1:0]  i_address,
input      [DATA_WIDTH/8-1:0]   i_byte_enable,
output     [DATA_WIDTH-1:0]     o_read_data

);

wire [DATA_WIDTH/8-1:0] wea = {DATA_WIDTH/8{i_write_enable}} & i_byte_enable;


RAMB36E1 #(
    .DOA_REG ( 0 ),
    .DOB_REG ( 0 ),
    .EN_ECC_READ ( "FALSE" ),
    .EN_ECC_WRITE ( "FALSE" ),
    .SRVAL_A ( 36'h000000000 ),
    .SRVAL_B ( 36'h000000000 ),
    .RAM_EXTENSION_A ( "NONE" ),
    .RAM_EXTENSION_B ( "NONE" ),
    .SIM_COLLISION_CHECK ( "ALL" ),
    .INIT_A ( 36'h000000000 ),
    .INIT_B ( 36'h000000000 ),

    .RAM_MODE           ( "TDP"                         ),
    .READ_WIDTH_A       ( 36                            ),
    .READ_WIDTH_B       ( 36                            ),
    .WRITE_WIDTH_A      ( 36                            ),
    .WRITE_WIDTH_B      ( 36                            ),
    .RSTREG_PRIORITY_A  ( "REGCE"                       ),
    .RSTREG_PRIORITY_B  ( "REGCE"                       ),
    .WRITE_MODE_A       ( "READ_FIRST"                  ),
    .WRITE_MODE_B       ( "READ_FIRST"                  ))
u_sram1  (
    .CASCADEINA         ( 1'd0                          ),
    .CASCADEINB         ( 1'd0                          ),
    .CASCADEOUTA        (                               ),
    .CASCADEOUTB        (                               ),
    .CLKARDCLK          ( i_clk                         ),
    .CLKBWRCLK          ( i_clk                         ),
    .DBITERR            (                               ),
    .ENARDEN            ( 1'd1                          ),
    .ENBWREN            ( 1'd1                          ),
    .INJECTDBITERR      ( 1'd0                          ),
    .INJECTSBITERR      ( 1'd0                          ),
    .REGCEAREGCE        ( 1'd0                          ),
    .REGCEB             ( 1'd0                          ),
    .RSTRAMARSTRAM      ( 1'd0                          ),
    .RSTRAMB            ( 1'd0                          ),
    .RSTREGARSTREG      ( 1'd0                          ),
    .RSTREGB            ( 1'd0                          ),
    .SBITERR            (                               ),
    .ADDRARDADDR        ( {2'd0, i_address[7:0], 6'd0}  ),
    .ADDRBWRADDR        ( {2'd2, i_address[7:0], 6'd32} ),
    .DIADI              ( {i_write_data[95:64]}         ),
    .DIBDI              ( {i_write_data[127:96]}        ),
    .DIPADIP            ( 4'd0                          ),
    .DIPBDIP            ( 4'd0                          ),
    .DOADO              ( {o_read_data[95:64]}          ),
    .DOBDO              ( {o_read_data[127:96]}         ),
    .DOPADOP            (                               ),
    .DOPBDOP            (                               ),
    .ECCPARITY          (                               ),
    .RDADDRECC          (                               ),
    .WEA                ( wea[11:8]                     ),
    .WEBWE              ( {4'd0, wea[15:12]}            )
  );



RAMB36E1 #(
    .DOA_REG ( 0 ),
    .DOB_REG ( 0 ),
    .EN_ECC_READ ( "FALSE" ),
    .EN_ECC_WRITE ( "FALSE" ),
    .SRVAL_A ( 36'h000000000 ),
    .SRVAL_B ( 36'h000000000 ),
    .RAM_EXTENSION_A ( "NONE" ),
    .RAM_EXTENSION_B ( "NONE" ),
    .SIM_COLLISION_CHECK ( "ALL" ),
    .INIT_A ( 36'h000000000 ),
    .INIT_B ( 36'h000000000 ),

    .RAM_MODE           ( "TDP"                         ),
    .READ_WIDTH_A       ( 36                            ),
    .READ_WIDTH_B       ( 36                            ),
    .WRITE_WIDTH_A      ( 36                            ),
    .WRITE_WIDTH_B      ( 36                            ),
    .RSTREG_PRIORITY_A  ( "REGCE"                       ),
    .RSTREG_PRIORITY_B  ( "REGCE"                       ),
    .WRITE_MODE_A       ( "READ_FIRST"                  ),
    .WRITE_MODE_B       ( "READ_FIRST"                  ))
u_sram0  (
    .CASCADEINA         ( 1'd0                          ),
    .CASCADEINB         ( 1'd0                          ),
    .CASCADEOUTA        (                               ),
    .CASCADEOUTB        (                               ),
    .CLKARDCLK          ( i_clk                         ),
    .CLKBWRCLK          ( i_clk                         ),
    .DBITERR            (                               ),
    .ENARDEN            ( 1'd1                          ),
    .ENBWREN            ( 1'd1                          ),
    .INJECTDBITERR      ( 1'd0                          ),
    .INJECTSBITERR      ( 1'd0                          ),
    .REGCEAREGCE        ( 1'd0                          ),
    .REGCEB             ( 1'd0                          ),
    .RSTRAMARSTRAM      ( 1'd0                          ),
    .RSTRAMB            ( 1'd0                          ),
    .RSTREGARSTREG      ( 1'd0                          ),
    .RSTREGB            ( 1'd0                          ),
    .SBITERR            (                               ),
    .ADDRARDADDR        ( {2'd2, i_address[7:0],6'd0}   ),
    .ADDRBWRADDR        ( {2'd2, i_address[7:0],6'd32}  ),
    .DIADI              ( {i_write_data[31:0]}          ),
    .DIBDI              ( {i_write_data[63:32]}         ),
    .DIPADIP            ( 4'd0                          ),
    .DIPBDIP            ( 4'd0                          ),
    .DOADO              ( {o_read_data[31:0]}           ),
    .DOBDO              ( {o_read_data[63:32]}          ),
    .DOPADOP            (                               ),
    .DOPBDOP            (                               ),
    .ECCPARITY          (                               ),
    .RDADDRECC          (                               ),
    .WEA                ( {wea[3:0]}                    ),
    .WEBWE              ( {4'd0, wea[7:4]}              )
  );



//synopsys translate_off
initial
    begin
    if ( DATA_WIDTH    != 128 ) $display("%M Warning: Incorrect parameter DATA_WIDTH");
    if ( ADDRESS_WIDTH != 8   ) $display("%M Warning: Incorrect parameter ADDRESS_WIDTH");
    end
//synopsys translate_on

endmodule

