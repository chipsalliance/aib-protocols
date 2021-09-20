
////////////////////////////////////////////////////////////
//
//        Copyright (C) 2021 Eximius Design
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
//
////////////////////////////////////////////////////////////
module spim_wrap 
#( 
parameter M_FIFO_WIDTH = 32, 
parameter M_FIFO_DEPTH = 64	
) 
(
input	logic		rst_n,
input	logic 		sclk_in,
input	logic   	miso,
output	logic   	ss_n_0, 
output	logic   	ss_n_1, 
output	logic   	ss_n_2, 
output	logic   	ss_n_3, 
output	logic 		sclk,
output	logic  	        mosi,

// AVMM Interface
input	logic   	m_avmm_rst_n,
input	logic   	m_avmm_clk,
input	logic  	[16:0]	m_avmm_addr,
input	logic 	[3:0]	m_avmm_byte_en,
input	logic		m_avmm_write,
input	logic		m_avmm_read,
input	logic 	[31:0]	m_avmm_wdata,
output	logic	[31:0]	m_avmm_rdata,
output	logic		m_avmm_rdatavld,
output	logic		m_avmm_waitreq


);

logic   	miso_int;
logic   	ss_n_0_int; 
logic   	ss_n_1_int; 
logic   	ss_n_2_int; 
logic   	ss_n_3_int; 
logic  	        mosi_int;

logic  	[16:0]	m_avmm_addr_int;
logic 	[3:0]	m_avmm_byte_en_int;
logic		m_avmm_write_int;
logic		m_avmm_read_int;
logic 	[31:0]	m_avmm_wdata_int;
logic	[31:0]	m_avmm_rdata_int;
logic		m_avmm_rdatavld_int;
logic		m_avmm_waitreq_int;

always @ (posedge sclk_in or negedge rst_n)
  if (~rst_n) begin 
   miso_int   <= 1'b0;
   ss_n_0     <= 1'b0; 
   ss_n_1     <= 1'b0; 
   ss_n_2     <= 1'b0; 
   ss_n_3     <= 1'b0; 
   mosi       <= 1'b0;
  end
  else begin
   miso_int   <= miso;
   ss_n_0     <= ss_n_0_int; 
   ss_n_1     <= ss_n_1_int;
   ss_n_2     <= ss_n_2_int;
   ss_n_3     <= ss_n_3_int;
   mosi       <= mosi_int;
  end

always @ (posedge m_avmm_clk or negedge m_avmm_rst_n)
  if (~m_avmm_rst_n) begin 
   m_avmm_addr_int    <= 'b0;
   m_avmm_byte_en_int <= 'b0;
   m_avmm_write_int   <= 1'b0;
   m_avmm_read_int    <= 1'b0;
   m_avmm_wdata_int   <= 'b0;
   m_avmm_rdata       <= 'b0;
   m_avmm_rdatavld    <= 1'b0;
   m_avmm_waitreq     <= 1'b0;
  end 
  else  begin
   m_avmm_addr_int    <= m_avmm_addr;
   m_avmm_byte_en_int <= m_avmm_byte_en;
   m_avmm_write_int   <= m_avmm_write;
   m_avmm_read_int    <= m_avmm_read;
   m_avmm_wdata_int   <= m_avmm_wdata;
   m_avmm_rdata       <= m_avmm_rdata_int;
   m_avmm_rdatavld    <= m_avmm_rdatavld_int;
   m_avmm_waitreq     <= m_avmm_waitreq_int;
  end


spim_top
#( 
    .M_FIFO_WIDTH (M_FIFO_WIDTH), 
    .M_FIFO_DEPTH (M_FIFO_DEPTH)
) 
 dut_spim (
	.rst_n (rst_n),
	.sclk_in (sclk_in),
	.miso (miso_int),
	.ss_n_0 (ss_n_0_int), 
	.ss_n_1 (ss_n_1_int), 
	.ss_n_2 (ss_n_2_int), 
	.ss_n_3 (ss_n_3_int), 
	.sclk (sclk),
	.mosi (mosi_int),
	.m_avmm_rst_n (m_avmm_rst_n),
	.m_avmm_clk (m_avmm_clk),
	.m_avmm_addr (m_avmm_addr_int),
	.m_avmm_byte_en (m_avmm_byte_en_int),
	.m_avmm_write (m_avmm_write_int),
	.m_avmm_read (m_avmm_read_int),
	.m_avmm_wdata (m_avmm_wdata_int),
	.m_avmm_rdata (m_avmm_rdata_int),
	.m_avmm_rdatavld (m_avmm_rdatavld_int),
	.m_avmm_waitreq (m_avmm_waitreq_int),
        .spi_active (),
	.ready_int ()
);

endmodule

