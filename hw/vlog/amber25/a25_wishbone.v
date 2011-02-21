//////////////////////////////////////////////////////////////////
//                                                              //
//  Wishbone master interface for the Amber 25 core             //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  Turns memory access requests from the execute stage and     //
//  instruction and data caches into wishbone bus cycles.       //
//  For 4-word read requests from either cache and swap         //
//  accesses ( read followed by write to the same address)      //
//  from the execute stage, a block transfer is done.           //
//  All other requests result in single word transfers.         //
//                                                              //
//  Write accesses can be done in a single clock cycle on       //
//  the wishbone bus, is the destination allows it. The         //
//  next transfer will begin immediately on the                 //
//  next cycle on the bus. This looks like a block transfer     //
//  and does hold ownership of the wishbone bus, preventing     //
//  the other master ( the ethernet MAC) from gaining           //
//  ownership between those two cycles. But otherwise it would  //
//  be necessary to insert a wait cycle after every write,      //
//  slowing down the performance of the core by around 5 to     //
//  10%.                                                        //
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


module a25_wishbone
(
input                       i_clk,

    // Instruction Cache Accesses
input                       i_icache_req,
input                       i_icache_qword,
input       [31:0]          i_icache_address,
output      [31:0]          o_icache_read_data,
output                      o_icache_ready,

    // Data Cache Accesses
input                       i_exclusive,      // high for read part of swap access
input                       i_dcache_cached_req,
input                       i_dcache_uncached_req,
input                       i_dcache_qword,
input                       i_dcache_write,
input       [31:0]          i_dcache_write_data,
input       [3:0]           i_dcache_byte_enable,    // valid for writes only
input       [31:0]          i_dcache_address,
output      [31:0]          o_dcache_read_data,
output                      o_dcache_cached_ready,
output                      o_dcache_uncached_ready,

// Wishbone Bus
output reg  [31:0]          o_wb_adr = 'd0,
output reg  [3:0]           o_wb_sel = 'd0,
output reg                  o_wb_we  = 'd0,
input       [31:0]          i_wb_dat,
output reg  [31:0]          o_wb_dat = 'd0,
output reg                  o_wb_cyc = 'd0,
output reg                  o_wb_stb = 'd0,
input                       i_wb_ack,
input                       i_wb_err

);


localparam [3:0] WB_IDLE            = 3'd0,
                 WB_BURST1          = 3'd1,
                 WB_BURST2          = 3'd2,
                 WB_BURST3          = 3'd3,
                 WB_WAIT_ACK        = 3'd4;

reg     [2:0]               wishbone_st = WB_IDLE;

wire                        icache_read_req_c;
wire                        icache_read_qword_c;
wire    [31:0]              icache_read_addr_c;
wire                        dcache_read_qword_c;

wire                        dcache_req_c;
wire                        write_req_c;
wire                        dcache_cached_rreq_c;
wire                        dcache_cached_wreq_c;
wire                        dcache_uncached_rreq_c;
wire                        dcache_uncached_wreq_c;

wire                        dcache_cached_rreq_in;
wire                        dcache_cached_wreq_in;
wire                        dcache_uncached_rreq_in;
wire                        dcache_uncached_wreq_in;

reg                         dcache_cached_rreq_r   = 'd0;
reg                         dcache_cached_wreq_r   = 'd0;
reg                         dcache_uncached_rreq_r = 'd0;
reg                         dcache_uncached_wreq_r = 'd0;

wire                        dcache_cached_wready;
wire                        dcache_uncached_wready;
wire                        dcache_cached_rready;
wire                        dcache_uncached_rready;

wire                        start_access;
wire    [3:0]               byte_enable;
reg                         exclusive_access = 'd0;
wire                        read_ack;
wire                        wait_write_ack;
reg                         icache_read_req_r  = 'd0;
reg                         icache_read_qword_r  = 'd0;
reg     [31:0]              icache_read_addr_r  = 'd0;
reg                         dcache_read_qword_r  = 'd0;
wire                        icache_read_req_in;
wire                        icache_read_ready;
reg                         servicing_dcache_cached_read_r = 'd0;
reg                         servicing_dcache_uncached_read_r = 'd0;
reg                         servicing_icache_r = 'd0;
wire                        extra_write;
reg                         extra_write_r = 'd0;
reg     [31:0]              extra_write_data_r;
reg     [31:0]              extra_write_address_r;
reg     [3:0]               extra_write_be_r;

assign read_ack                 = !o_wb_we && i_wb_ack;

assign dcache_cached_rready     = dcache_cached_rreq_r   && servicing_dcache_cached_read_r   && read_ack;
assign dcache_uncached_rready   = dcache_uncached_rreq_r && servicing_dcache_uncached_read_r && read_ack;


assign o_dcache_cached_ready    = dcache_cached_rready   || dcache_cached_wready;
assign o_dcache_uncached_ready  = dcache_uncached_rready || dcache_uncached_wready;
assign o_dcache_read_data       = i_wb_dat;
                                 
assign icache_read_ready        = servicing_icache_r && read_ack;
assign o_icache_ready           = icache_read_ready; 
assign o_icache_read_data       = i_wb_dat;


assign dcache_cached_rreq_in    = i_dcache_cached_req   && !i_dcache_write;
assign dcache_cached_wreq_in    = i_dcache_cached_req   &&  i_dcache_write;
assign dcache_uncached_rreq_in  = i_dcache_uncached_req && !i_dcache_write;
assign dcache_uncached_wreq_in  = i_dcache_uncached_req &&  i_dcache_write;
assign icache_read_req_in       = i_icache_req && !o_icache_ready;

assign dcache_cached_rreq_c     = ( dcache_cached_rreq_in   || dcache_cached_rreq_r   ) && !(servicing_dcache_cached_read_r   && read_ack);
assign dcache_uncached_rreq_c   = ( dcache_uncached_rreq_in || dcache_uncached_rreq_r ) && !(servicing_dcache_uncached_read_r && read_ack);

assign dcache_read_qword_c      = ( i_dcache_qword       || dcache_read_qword_r ) && !(servicing_dcache_cached_read_r && read_ack);

assign icache_read_req_c        = ( icache_read_req_in   || icache_read_req_r   ) && !(servicing_icache_r && read_ack);
assign icache_read_qword_c      = ( i_icache_qword       || icache_read_qword_r ) && !(servicing_icache_r && read_ack);
assign icache_read_addr_c       = i_icache_req ?  i_icache_address : icache_read_addr_r;

assign dcache_req_c             = dcache_cached_rreq_c || dcache_cached_wreq_c || dcache_uncached_rreq_c || dcache_uncached_wreq_c;
assign write_req_c              = dcache_cached_wreq_c || dcache_uncached_wreq_c;

assign start_access             = !wait_write_ack && (dcache_req_c || icache_read_req_c);

// For writes the byte enable is always 4'hf
assign byte_enable              = write_req_c ? i_dcache_byte_enable : 4'hf;
                                    

assign dcache_cached_wready     = (dcache_cached_wreq_c && wishbone_st == WB_IDLE);
assign dcache_uncached_wready   = (dcache_uncached_wreq_c && wishbone_st == WB_IDLE);
assign dcache_cached_wreq_c     = dcache_cached_wreq_in   || dcache_cached_wreq_r;
assign dcache_uncached_wreq_c   = dcache_uncached_wreq_in || dcache_uncached_wreq_r;


// ======================================
// Register Accesses
// ======================================

assign extra_write =  wishbone_st == WB_IDLE && !i_wb_ack && ((dcache_cached_wreq_c && dcache_cached_wready)||
                                                              (dcache_uncached_wreq_c && dcache_uncached_wready));

always @( posedge i_clk )
    if ( wishbone_st == WB_WAIT_ACK && i_wb_ack && extra_write_r )
        o_wb_dat <= extra_write_data_r;
    else if ( start_access )
        o_wb_dat <= i_dcache_write_data;
   


always @( posedge i_clk )
    begin
    icache_read_req_r   <= icache_read_req_in  || icache_read_req_c;
    icache_read_qword_r <= i_icache_qword      || icache_read_qword_c;
    if ( i_icache_req ) icache_read_addr_r  <= i_icache_address;
        
    dcache_read_qword_r    <= i_dcache_qword      || dcache_read_qword_c;
    dcache_cached_wreq_r   <= dcache_cached_wreq_c   && (wishbone_st != WB_IDLE || (o_wb_stb && !i_wb_ack));
    dcache_uncached_wreq_r <= dcache_uncached_wreq_c && (wishbone_st != WB_IDLE || (o_wb_stb && !i_wb_ack));
    
    
    // A buffer to hold a second write while on eis in progress
    if ( extra_write )
        begin
        extra_write_data_r      <= i_dcache_write_data;
        extra_write_address_r   <= i_dcache_address;
        extra_write_be_r        <= i_dcache_byte_enable;
        end


    // The flag can be set during any state but only cleared during WB_IDLE or WB_WAIT_ACK
    if ( dcache_cached_rreq_r )
        begin
        if ( wishbone_st == WB_IDLE || wishbone_st == WB_WAIT_ACK )
            dcache_cached_rreq_r <= dcache_cached_rreq_c && !o_dcache_cached_ready;
        end    
    else    
        dcache_cached_rreq_r <= dcache_cached_rreq_c && !o_dcache_cached_ready;
    if ( dcache_uncached_rreq_r )
        begin
        if ( wishbone_st == WB_IDLE || wishbone_st == WB_WAIT_ACK )
            dcache_uncached_rreq_r <= dcache_uncached_rreq_c && !o_dcache_uncached_ready;
        end    
    else    
        dcache_uncached_rreq_r <= dcache_uncached_rreq_c && !o_dcache_uncached_ready;
    end
    
assign wait_write_ack = o_wb_stb && o_wb_we && !i_wb_ack;


always @( posedge i_clk )
    case ( wishbone_st )
        WB_IDLE :
            begin 
            extra_write_r <= extra_write;
            
            if ( start_access )
                begin
                o_wb_stb            <= 1'd1; 
                o_wb_cyc            <= 1'd1; 
                o_wb_sel            <= byte_enable;
                end
            else if ( !wait_write_ack )
                begin
                o_wb_stb            <= 1'd0;
                
                // Hold cyc high after an exclusive access
                // to hold ownership of the wishbone bus
                o_wb_cyc            <= exclusive_access;
                end

            if ( wait_write_ack )
                begin
                // still waiting for last (write) access to complete
                wishbone_st                      <= WB_WAIT_ACK;
                servicing_dcache_cached_read_r   <= dcache_cached_rreq_c;
                servicing_dcache_uncached_read_r <= dcache_uncached_rreq_c;
                end 
            // dcache accesses have priority over icache     
            else if ( dcache_cached_rreq_c || dcache_uncached_rreq_c )
                begin
                if ( dcache_cached_rreq_c )
                    servicing_dcache_cached_read_r <= 1'd1;
                else if ( dcache_uncached_rreq_c )
                    servicing_dcache_uncached_read_r <= 1'd1;
                
                if ( dcache_read_qword_c )
                    wishbone_st         <= WB_BURST1;
                else
                    wishbone_st         <= WB_WAIT_ACK;
                exclusive_access    <= i_exclusive;
                end                    
           // The core does not currently issue exclusive write requests
           // but there's no reason why this might not be added some
           // time in the future so allow for it here
            else if ( write_req_c )
                begin
                exclusive_access            <= i_exclusive;
                end
            // do a burst of 4 read to fill a cache line                   
            else if ( icache_read_req_c && icache_read_qword_c )
                begin
                wishbone_st                 <= WB_BURST1;
                exclusive_access            <= 1'd0;
                servicing_icache_r          <= 1'd1;
                end                    
            // single word read request from fetch stage                   
            else if ( icache_read_req_c )
                begin
                wishbone_st                 <= WB_WAIT_ACK;
                exclusive_access            <= 1'd0;
                servicing_icache_r          <= 1'd1;
                end                    

                            
            if ( start_access )
                begin
                if ( dcache_req_c )
                    begin
                    o_wb_we              <= write_req_c;
                    // only update these on new wb access to make debug easier
                    o_wb_adr[31:2]       <= i_dcache_address[31:2];
                    o_wb_adr[1:0]        <= byte_enable == 4'b0001 ? 2'd0 :
                                            byte_enable == 4'b0010 ? 2'd1 :
                                            byte_enable == 4'b0100 ? 2'd2 :
                                            byte_enable == 4'b1000 ? 2'd3 :
                                           
                                            byte_enable == 4'b0011 ? 2'd0 :
                                            byte_enable == 4'b1100 ? 2'd2 :
                                           
                                                                     2'd0 ;
                    end                                                 
                else 
                    begin
                    o_wb_we              <= 1'd0;
                    o_wb_adr[31:0]       <= {icache_read_addr_c[31:2], 2'd0};
                    end                                                
                end
            end
                    

        // Read burst, wait for first ack
        WB_BURST1:  
            if ( i_wb_ack )
                begin
                // burst of 4 that wraps
                o_wb_adr[3:2]   <= o_wb_adr[3:2] + 1'd1;
                wishbone_st     <= WB_BURST2;
                end
            
            
        // Read burst, wait for second ack
        WB_BURST2:  
            if ( i_wb_ack )
                begin
                // burst of 4 that wraps
                o_wb_adr[3:2]   <= o_wb_adr[3:2] + 1'd1;
                wishbone_st     <= WB_BURST3;
                end
            
            
        // Read burst, wait for third ack
        WB_BURST3:  
            if ( i_wb_ack )
                begin
                // burst of 4 that wraps
                o_wb_adr[3:2]   <= o_wb_adr[3:2] + 1'd1;
                wishbone_st     <= WB_WAIT_ACK;
                end


        // Wait for the wishbone ack to be asserted
        WB_WAIT_ACK:   
            if ( i_wb_ack )
                // Another write that was acked and needs to be sent before returning to IDLE ?
                if ( extra_write_r )
                    begin
                    extra_write_r                       <= 'd0;
                    o_wb_stb                            <= 1'd1; 
                    o_wb_cyc                            <= exclusive_access; 
                    o_wb_sel                            <= extra_write_be_r;
                    o_wb_we                             <= 1'd1;
                    o_wb_adr[31:0]                      <= extra_write_address_r;
                    end
                else    
                    begin
                    wishbone_st                         <= WB_IDLE;
                    o_wb_stb                            <= 1'd0; 
                    o_wb_cyc                            <= exclusive_access; 
                    o_wb_we                             <= 1'd0;
                    servicing_dcache_cached_read_r      <= 1'd0;
                    servicing_dcache_uncached_read_r    <= 1'd0;
                    servicing_icache_r                  <= 1'd0;
                    end
                         
            
    endcase

// ========================================================
// Debug Wishbone bus - not synthesizable
// ========================================================
//synopsys translate_off
wire    [(14*8)-1:0]   xWB_STATE;


assign xWB_STATE  = wishbone_st == WB_IDLE       ? "WB_IDLE"       :
                    wishbone_st == WB_BURST1     ? "WB_BURST1"     :
                    wishbone_st == WB_BURST2     ? "WB_BURST2"     :
                    wishbone_st == WB_BURST3     ? "WB_BURST3"     :
                    wishbone_st == WB_WAIT_ACK   ? "WB_WAIT_ACK"   :
                                                   "UNKNOWN"       ;

//synopsys translate_on
    
endmodule

