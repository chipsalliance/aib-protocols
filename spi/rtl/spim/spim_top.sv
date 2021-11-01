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

// spim_top - top level module for SPI Master
// 

module spim_top 
#( 
parameter M_FIFO_WIDTH = 32, 
//parameter M_FIFO_DEPTH = 64	
parameter M_FIFO_DEPTH = 512	
) 
(
// SPI Interface
input 	logic		rst_n,
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
output	logic		m_avmm_waitreq,

// Misc
output	logic		spi_active,
input	logic		ready_int
);


// local declarations

logic 	[13:0]	burstlength;
logic		s_transvld_sclk;
logic		stransvld_up;
logic		spim_rdnwr;
logic		spi_read;
logic		spi_write;
logic		cmd_is_read;
logic		cmd_is_write;
logic		avbreg_read;
logic		avbreg_write;
logic		avbreg_rdatavld;
logic		avbreg_waitreq;
logic	[15:0]	spi_wr_addr;
logic	[15:0]	spi_rd_addr;
logic	[31:0]	dbg_bus0;
logic	[31:0]	dbg_bus1;
logic	[31:0]	miso_data;
logic	[31:0]	mosi_data;
logic	[31:0]	avbreg_wdata;
logic	[15:0]	avbreg_addr;
logic	[31:0]	avbreg_rdata;
logic	[3:0]	avbbyte_en;
logic	[1:0]	spim_sselect;
logic		rst_n_avmmclk;
logic		rst_n_sclk;
logic 		ssn_off_pulse;
logic 		ssn_on_pulse;

// spim_intf 
spim_intf  i_spim_intf ( 
	.rst_n		(rst_n_sclk),
	.sclk_in	(sclk_in),
	.ss_n_0		(ss_n_0),
	.ss_n_1		(ss_n_1),
	.ss_n_2		(ss_n_2),
	.ss_n_3		(ss_n_3),
	.ssn_off_pulse	(ssn_off_pulse),
	.ssn_on_pulse	(ssn_on_pulse),
	.miso		(miso),
	
	.tx_rdata	(mosi_data),   // mosi data to slave
	.spi_write 	(spi_write), // from m_cmd Nios write - read data from m_write buf and send to slave s_write_buf
	.spi_read 	(spi_read),  // from m_cmd Niso read - receive read data from slave s_rdbuf and write to m_read buf
	.cmd_is_read	(cmd_is_read),
	.cmd_is_write	(cmd_is_write),
 	.spi_wr_addr_2reg	(spi_wr_addr),	
 	.spi_rd_addr	(spi_rd_addr),	
	.sclk		(sclk),	     
	.mosi		(mosi),
	.spim_brstlen	(burstlength),
	.s_transvld	(s_transvld_sclk),
	.spim_rdnwr	(spim_rdnwr),
	.stransvld_up	(stransvld_up),
	.spim_sselect 	(spim_sselect),
        .dbg_bus0       (dbg_bus0),
	.rx_wdata	(miso_data)   //miso data from slave

);

// spimreg
spimreg_top  
#( 
    .FIFO_WIDTH (M_FIFO_WIDTH), 
    .FIFO_DEPTH (M_FIFO_DEPTH)
) 
i_spimreg_top (
	.sclk_in 		(sclk_in),
	.m_avmm_clk 	(m_avmm_clk),
	.rst_n 		(rst_n_sclk),
	.m_avmm_rst_n 	(rst_n_avmmclk),
	.miso_data 	(miso_data), // spi_wdata, - read data from slave
	.spi_write 	(spi_write), // from m_cmd - read data from write buf and send to slave
	.spi_read 	(spi_read),  // from m_cmd - receive read data from slave and write to read buf
	.cmd_is_read	(cmd_is_read),
	.cmd_is_write	(cmd_is_write),
        .dbg_bus0       (dbg_bus0),
        .dbg_bus1       (dbg_bus1),
	.spi_wr_addr 	(spi_wr_addr),  // from spim intf 
	.spi_rd_addr 	(spi_rd_addr),  // from spim intf 
	.mosi_data 	(mosi_data), //spi_rdata, - write data to slave
	.avbreg_wdata 	(avbreg_wdata), // write data to master
	.avbreg_write 	(avbreg_write),
	.avbreg_read 	(avbreg_read),
	.avbreg_addr 	(avbreg_addr),
	.avbreg_rdata 	(avbreg_rdata), // read data from master
	.avbreg_rdatavld 	(avbreg_rdatavld),
	.avbreg_waitreq 	(avbreg_waitreq),
	.stransvld_up 	(stransvld_up), // Indication to update (set to 1'b0) s_transvld from SPIM Intf
	.spim_brstlen 	(burstlength),
	.s_transvld_sclk_d1 	(s_transvld_sclk),
	.s_transvld 	(spi_active),
	.spim_sselect 	(spim_sselect),
	.ssn_off_pulse_sclk	(ssn_off_pulse),
	.ssn_on_pulse_sclk	(ssn_on_pulse),
	.spim_rdnwr 	(spim_rdnwr)

);

//spimavb 
spimavb i_spimavb (
	.m_avmm_rst_n (rst_n_avmmclk),
	.m_avmm_clk (m_avmm_clk),
	.m_avmm_addr (m_avmm_addr),
	.m_avmm_byte_en (m_avmm_byte_en),
	.m_avmm_write (m_avmm_write),
	.m_avmm_read (m_avmm_read),
	.m_avmm_wdata (m_avmm_wdata),
	.m_avmm_rdata (m_avmm_rdata),
	.m_avmm_rdatavld (m_avmm_rdatavld),
	.m_avmm_waitreq (m_avmm_waitreq),
	
        .dbg_bus1       (dbg_bus1),
	.avbreg_rdata (avbreg_rdata),
	.avbreg_waitreq (avbreg_waitreq),  
	.avbreg_rdatavld (avbreg_rdatavld),
	.avbreg_wdata (avbreg_wdata),
	.avbreg_addr (avbreg_addr), 
	.avbbyte_en (avbbyte_en),
	.avbreg_write (avbreg_write),
	.avbreg_read (avbreg_read) 
);


rst_regen_low i_rstsync_rstn
(
 	.clk		(sclk_in),
 	.async_rst_n	(rst_n), 
 	.rst_n		(rst_n_sclk)
);

rst_regen_low i_rstsync_arstn
(
 	.clk		(m_avmm_clk),
 	.async_rst_n	(m_avmm_rst_n), 
 	.rst_n		(rst_n_avmmclk)
);

endmodule
