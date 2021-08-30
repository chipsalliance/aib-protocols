
////////////////////////////////////////////////////////////
// Proprietary Information of Eximius Design
//
//        (C) Copyright 2021 Eximius Design
//                All Rights Reserved
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Eximius Design
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//Functional Descript:
//
//
////////////////////////////////////////////////////////////
module spis_wrap 
 #(
    parameter S_FIFO_WIDTH = 32,
    parameter S_FIFO_DEPTH = 64
)
( 
input	logic		rst_n,
input	logic           sclk,
output	logic   	miso,
input	logic   	ss_n, 
input	logic  	        mosi,

// AVMM Interface common signals
input   logic 	       s_avmm_rst_n,
input   logic          s_avmm_clk,

// AVMM0 Interface
output  logic  [16:0]	s_avmm0_addr,
output  logic  [3:0]	s_avmm0_byte_en,
output  logic           s_avmm0_write,
output  logic           s_avmm0_read,
output  logic  [31:0]   s_avmm0_wdata,
input   logic  [31:0]   s_avmm0_rdata,
input   logic           s_avmm0_rdatavld,
input   logic           s_avmm0_waitreq,

// AVMM1 Interface
output  logic  [16:0]	s_avmm1_addr,
output  logic  [3:0]	s_avmm1_byte_en,
output  logic           s_avmm1_write,
output  logic           s_avmm1_read,
output  logic  [31:0]	s_avmm1_wdata,
input   logic  [31:0]	s_avmm1_rdata,
input   logic           s_avmm1_rdatavld,
input   logic           s_avmm1_waitreq,

// AVMM02Interface
output  logic [16:0]    s_avmm2_addr,
output  logic [3:0]     s_avmm2_byte_en,
output  logic           s_avmm2_write,
output  logic           s_avmm2_read,
output  logic [31:0]    s_avmm2_wdata,
input   logic [31:0]    s_avmm2_rdata,
input   logic           s_avmm2_rdatavld,
input   logic           s_avmm2_waitreq

);



logic   	miso_int;
logic   	ss_n_int; 
logic  	        mosi_int;
logic  [16:0]	s_avmm0_addr_int;
logic  [3:0]	s_avmm0_byte_en_int;
logic           s_avmm0_write_int;
logic           s_avmm0_read_int;
logic  [31:0]   s_avmm0_wdata_int;
logic  [31:0]   s_avmm0_rdata_int;
logic           s_avmm0_rdatavld_int;
logic           s_avmm0_waitreq_int;
logic  [16:0]	s_avmm1_addr_int;
logic  [3:0]	s_avmm1_byte_en_int;
logic           s_avmm1_write_int;
logic           s_avmm1_read_int;
logic  [31:0]	s_avmm1_wdata_int;
logic  [31:0]	s_avmm1_rdata_int;
logic           s_avmm1_rdatavld_int;
logic           s_avmm1_waitreq_int;
logic [16:0]    s_avmm2_addr_int;
logic [3:0]     s_avmm2_byte_en_int;
logic           s_avmm2_write_int;
logic           s_avmm2_read_int;
logic [31:0]    s_avmm2_wdata_int;
logic [31:0]    s_avmm2_rdata_int;
logic           s_avmm2_rdatavld_int;
logic           s_avmm2_waitreq_int;
logic           avmm_active_int;

always @ (posedge sclk or negedge rst_n)
  if (~rst_n) begin 
   miso   <= 1'b0;
   ss_n_int       <= 1'b0; 
   mosi_int       <= 1'b0;
  end
  else begin
   miso   <= miso_int;
   ss_n_int       <= ss_n; 
   mosi_int       <= mosi;
  end



always @ (posedge s_avmm_clk or negedge s_avmm_rst_n)
  if (~s_avmm_rst_n) begin 
   s_avmm0_addr         <= 'b0;
   s_avmm0_byte_en         <= 'b0;
   s_avmm0_write        <= 1'b0;
   s_avmm0_read         <= 1'b0;
   s_avmm0_wdata        <= 'b0;
   s_avmm0_rdata_int    <= 'b0;
   s_avmm0_rdatavld_int <= 1'b0;
   s_avmm0_waitreq_int  <= 1'b0;
   s_avmm1_addr         <= 'b0;
   s_avmm1_byte_en         <= 'b0;
   s_avmm1_write        <= 1'b0;
   s_avmm1_read         <= 1'b0;
   s_avmm1_wdata        <= 'b0;
   s_avmm1_rdata_int    <= 'b0;
   s_avmm1_rdatavld_int <= 1'b0;
   s_avmm1_waitreq_int  <= 1'b0;
   s_avmm2_addr         <= 'b0;
   s_avmm2_byte_en         <= 'b0;
   s_avmm2_write        <= 1'b0;
   s_avmm2_read         <= 1'b0;
   s_avmm2_wdata        <= 'b0;
   s_avmm2_rdata_int    <= 'b0;
   s_avmm2_rdatavld_int <= 1'b0;
   s_avmm2_waitreq_int  <= 1'b0;
  end 
  else  begin
   s_avmm0_addr         <= s_avmm0_addr_int;
   s_avmm0_byte_en      <= s_avmm0_byte_en_int;
   s_avmm0_write        <= s_avmm0_write_int;
   s_avmm0_read         <= s_avmm0_read_int;
   s_avmm0_wdata        <= s_avmm0_wdata_int;
   s_avmm0_rdata_int    <= s_avmm0_rdata;
   s_avmm0_rdatavld_int <= s_avmm0_rdatavld;
   s_avmm0_waitreq_int  <= s_avmm0_waitreq;
   s_avmm1_addr         <= s_avmm1_addr_int;
   s_avmm1_byte_en      <= s_avmm1_byte_en_int;
   s_avmm1_write        <= s_avmm1_write_int;
   s_avmm1_read         <= s_avmm1_read_int;
   s_avmm1_wdata        <= s_avmm1_wdata_int;
   s_avmm1_rdata_int    <= s_avmm1_rdata;
   s_avmm1_rdatavld_int <= s_avmm1_rdatavld;
   s_avmm1_waitreq_int  <= s_avmm1_waitreq;
   s_avmm2_addr         <= s_avmm2_addr_int;
   s_avmm2_byte_en      <= s_avmm2_byte_en_int;
   s_avmm2_write        <= s_avmm2_write_int;
   s_avmm2_read         <= s_avmm2_read_int;
   s_avmm2_wdata        <= s_avmm2_wdata_int;
   s_avmm2_rdata_int    <= s_avmm2_rdata;
   s_avmm2_rdatavld_int <= s_avmm2_rdatavld;
   s_avmm2_waitreq_int  <= s_avmm2_waitreq;
  end



spis_top
 #(
  .S_FIFO_WIDTH (S_FIFO_WIDTH),
  .S_FIFO_DEPTH (S_FIFO_DEPTH)
  ) 
i_spis_top  
(
// SPI Interface
	.rst_n		   (rst_n),
	.sclk           (sclk),
	.ss_n		   (ss_n_int), 
	.mosi		   (mosi_int),
	.miso		   (miso_int),
	.s_avmm_rst_n	   (s_avmm_rst_n),
	.s_avmm_clk	   (s_avmm_clk),
	.s_avmm0_addr	   (s_avmm0_addr_int),
	.s_avmm0_byte_en   (s_avmm0_byte_en_int),
	.s_avmm0_write	   (s_avmm0_write_int),
	.s_avmm0_read	   (s_avmm0_read_int),
	.s_avmm0_wdata	   (s_avmm0_wdata_int),
	.s_avmm0_rdata	   (s_avmm0_rdata_int),
	.s_avmm0_rdatavld  (s_avmm0_rdatavld_int),
	.s_avmm0_waitreq   (s_avmm0_waitreq_int),
	.s_avmm1_addr	   (s_avmm1_addr_int),
	.s_avmm1_byte_en   (s_avmm1_byte_en_int),
	.s_avmm1_write	   (s_avmm1_write_int),
	.s_avmm1_read	   (s_avmm1_read_int),
	.s_avmm1_wdata	   (s_avmm1_wdata_int),
	.s_avmm1_rdata	   (s_avmm1_rdata_int),
	.s_avmm1_rdatavld  (s_avmm1_rdatavld_int),
	.s_avmm1_waitreq   (s_avmm1_waitreq_int),
	.s_avmm2_addr	   (s_avmm2_addr_int),
	.s_avmm2_byte_en   (s_avmm2_byte_en_int),
	.s_avmm2_write	   (s_avmm2_write_int),
	.s_avmm2_read	   (s_avmm2_read_int),
	.s_avmm2_wdata	   (s_avmm2_wdata_int),
	.s_avmm2_rdata	   (s_avmm2_rdata_int),
	.s_avmm2_rdatavld  (s_avmm2_rdatavld_int),
	.s_avmm2_waitreq   (s_avmm2_waitreq_int),
        .avmm_active       ()
);


endmodule

