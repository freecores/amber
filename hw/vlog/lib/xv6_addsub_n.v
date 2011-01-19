//////////////////////////////////////////////////////////////////
//                                                              //
//  Wrapper for Xilinx Virtex-6 DSP48 Block                     //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  DSP block configured as a 32-bit adder and substractor      //
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


module xv6_addsub_n #(
parameter WIDTH=32
)(
input [WIDTH-1:0]   i_a,
input [WIDTH-1:0]   i_b,
input               i_cin,
input               i_sub,

output [WIDTH-1:0]  o_sum,
output              o_co
);


wire [47:0] in_a, in_b;
wire [47:0] out;

assign in_a   = {{48-WIDTH{1'd0}}, i_a};
assign in_b   = {{48-WIDTH{1'd0}}, i_b};
assign o_sum  = out[WIDTH-1:0];
assign o_co   = out[WIDTH];


DSP48E1  #(
    .ACASCREG                           ( 0 ),
    .ALUMODEREG                         ( 0                 ),
    .AREG                               ( 0                 ),
    .A_INPUT                            ( "DIRECT"          ),
    .BCASCREG                           ( 0                 ),
    .DREG                               ( 0                 ),
    .ADREG                              ( 0                 ),
    .BREG                               ( 0                 ),
    .B_INPUT                            ( "DIRECT"          ),
    .CARRYINREG                         ( 0                 ),
    .CARRYINSELREG                      ( 0                 ),
    .CREG                               ( 0                 ),
    .PATTERN                            ( 48'h000000000000  ),
    .MREG                               ( 0                 ), 
    .OPMODEREG                          ( 0                 ), 
    .PREG                               ( 0                 ), 
    .SEL_MASK                           ( "MASK"            ),
    .SEL_PATTERN                        ( "PATTERN"         ),
    .USE_MULT                           ( "NONE"            ),
    .USE_PATTERN_DETECT                 ( "NO_PATDET"       ),
    .USE_SIMD                           ( "ONE48"           ),
    .MASK                               ( 48'h3FFFFFFFFFFF  )

)

u_dsp48 (
    // Outputs
    .BCOUT         (                        ),
    .CARRYOUT      (                        ),
    .P             ( out                    ),
    .PCOUT         (                        ),
                                           
    // Inputs
    .CLK           ( 1'd0                   ),
                                           
    .A             ( {12'd0, in_b[35:18]}   ),
    .B             (         in_b[17:00]    ),
    .C             (         in_a           ),
    .D             ( {13'd0, in_b[47:36]}   ),

    .CARRYIN       ( i_cin                  ),  // uses opmode bit 5 for carry in
    .BCIN          ( 18'd0                  ),
    .PCIN          ( 48'd0                  ),

    // Clock enables
    .CEC           ( 1'd1                   ),
    .CED           ( 1'd1                   ),
    .CEM           ( 1'd1                   ),
    .CEP           ( 1'd1                   ),
    .CECARRYIN     ( 1'd1                   ),
    
    // Register Resets
    .RSTA          ( 1'd0                   ),
    .RSTB          ( 1'd0                   ),
    .RSTC          ( 1'd0                   ),
    .RSTALLCARRYIN ( 1'd0                   ),
    .RSTD          ( 1'd0                   ),
    .RSTM          ( 1'd0                   ),
    .RSTP          ( 1'd0                   ),
    
    // Virtex-6
    .ACIN          ( 30'd0                  ),
    .ACOUT         (                        ),

    .ALUMODE       ( {2'd0, i_sub, i_sub}   ),  // Z - ( X + CIN )
    .INMODE        ( 5'b10001               ),  // A Mult = A1, B Mult = B1
    .OPMODE        ( 7'b0110011             ),  // X = {A,B}, Y = 0, Z = C
    .CARRYINSEL    ( 3'b000                 ),  // CIN = CARRYIN

    .CARRYCASCIN   ( 1'd0                   ),
    .CARRYCASCOUT  (                        ),
    .MULTSIGNOUT   (                        ),
    .OVERFLOW      (                        ),
    .PATTERNBDETECT(                        ),
    .PATTERNDETECT (                        ),
    .UNDERFLOW     (                        ),
    .CEALUMODE     ( 1'd1                   ),
    .CEA1          ( 1'd1                   ),
    .CEA2          ( 1'd1                   ),
    .CEB1          ( 1'd1                   ),
    .CEB2          ( 1'd1                   ),
    .CECTRL        ( 1'd1                   ),
    .CEINMODE      ( 1'd1                   ),
    .MULTSIGNIN    ( 1'd0                   ),
    .RSTALUMODE    ( 1'd0                   ),
    .RSTCTRL       ( 1'd0                   ),
    .RSTINMODE     ( 1'd0                   ),
    .CEAD          ( 1'd1                   )
    
    );
    
    
endmodule

