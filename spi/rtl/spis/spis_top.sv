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

// spis_top - top level module for SPI Slave
// 

module spis_top 
#( 
parameter S_FIFO_WIDTH = 32,
//parameter S_FIFO_DEPTH = 64
parameter S_FIFO_DEPTH = 512
) 
(
// SPI Interface
input 		rst_n,
input           sclk,
input   	ss_n, 
input   	mosi,
output  	miso,

// AVMM Interface common signals
input           s_avmm_rst_n,
input           s_avmm_clk,

// AVMM0 Interface
output  [16:0]	s_avmm0_addr,
output 	[3:0]	s_avmm0_byte_en,
output		s_avmm0_write,
output		s_avmm0_read,
output 	[31:0]	s_avmm0_wdata,
input	[31:0]	s_avmm0_rdata,
input		s_avmm0_rdatavld,
input		s_avmm0_waitreq,

// AVMM1 Interface
output  [16:0]	s_avmm1_addr,
output 	[3:0]	s_avmm1_byte_en,
output		s_avmm1_write,
output		s_avmm1_read,
output 	[31:0]	s_avmm1_wdata,
input	[31:0]	s_avmm1_rdata,
input		s_avmm1_rdatavld,
input		s_avmm1_waitreq,

// AVMM02Interface
output  [16:0]	s_avmm2_addr,
output 	[3:0]	s_avmm2_byte_en,
output		s_avmm2_write,
output		s_avmm2_read,
output 	[31:0]	s_avmm2_wdata,
input	[31:0]	s_avmm2_rdata,
input		s_avmm2_rdatavld,
input		s_avmm2_waitreq,

// Misc
output		avmm_active
);


// local declarations

logic	[31:0]	miso_data;
logic	[31:0]	mosi_data;
logic		miso_int;
logic		spi_write;
logic		spi_read;
logic	[15:0]	spi_wr_addr;
logic	[15:0]	spi_rd_addr;
logic		cmd_is_read;
logic		cmd_is_write;
logic		bc_zero;

logic	[7:0] 	avmm_brstlen;
logic	[1:0]	avmm_sel;
logic	[16:0]	avmm_offset;
logic		avmm_transvld;
logic		avmm_rdnwr;
logic		avmmtransvld_up;
logic	[31:0]	reg2avb_wdata;
logic	[31:0]	avb2reg_rdata_q;
logic	[15:0]	avb2reg_addr;
logic		avb2reg_write;
logic		avb2reg_read_pulse;
logic		rst_n_avmmclk;
logic		rst_n_sclk;
logic	[31:0]	dbg_bus0;
logic	[31:0]	dbg_bus1;
logic           ssn_off_pulse;
logic           single_read;



// spis_intf 
spis_intf  i_spis_intf ( 
	.rst_n			(rst_n_sclk),
	.sclk			(sclk),
	.ss_n			(ss_n),
	.mosi			(mosi),
	
	.tx_rdata		(miso_data),
	
	.miso			(miso_int),
        .single_read            (single_read),
	.spi_write		(spi_write),  // to spisreg_top for spi write indication
	.spi_read		(spi_read),   // to spisreg_top for spi read indication
	.spi_wr_addr_2reg	(spi_wr_addr),   // to spisreg_top for spi read indication
	.spi_rd_addr		(spi_rd_addr),   // to spisreg_top for spi read indication
	.ssn_off_pulse		(ssn_off_pulse),
	.cmd_is_read		(cmd_is_read),
	.cmd_is_write		(cmd_is_write),
	.bc_zero		(bc_zero),
	.dbg_bus0               (dbg_bus0),
	.rx_wdata		(mosi_data)

);

// spisreg
spisreg_top  
#( 
    .FIFO_WIDTH (S_FIFO_WIDTH), 
    .FIFO_DEPTH (S_FIFO_DEPTH)
) 
i_spisreg_top (
	.sclk 			(sclk),
	.s_avmm_clk 		(s_avmm_clk),
	.rst_n 			(rst_n_sclk),
	.s_avmm_rst_n 		(rst_n_avmmclk),
        .single_read            (single_read),
	.ssn_off_pulse_sclk	(ssn_off_pulse),
	.miso_data 		(miso_data), // spi_rdata, - read data from slave to master
	.spi_write 		(spi_write), // from m_cmd - read data from write buf and send to slave
	.spi_read 		(spi_read),  // from m_cmd - receive read data from slave and write to read buf
	.spi_wr_addr 		(spi_wr_addr),  // from spim intf 
	.spi_rd_addr 		(spi_rd_addr),  // from spim intf 
	.mosi_data 		(mosi_data), //spi_wdata, - write data from master to slave
	.dbg_bus0               (dbg_bus0),
	.dbg_bus1               (dbg_bus1),
	.ss_n                   (ss_n),
	.reg2avb_wdata 		(reg2avb_wdata), // write data from spis wr_buf for AVB channel
	.avb2reg_write 		(avb2reg_write),
	.avb2reg_read_pulse 	(avb2reg_read_pulse),
	.avb2reg_addr 		(avb2reg_addr),
	.avb2reg_rdata 		(avb2reg_rdata_q), // read data from avb channel to slave (rd_buf)
	.avmmtransvld_up 	(avmmtransvld_up), // Indication from spisavb to update (set to 1'b0) avmm_transvld 
	.avmm_active		(avmm_active),
	.avmm_brstlen 		(avmm_brstlen),
	.avmm_sel 		(avmm_sel),
	.avmm_offset 		(avmm_offset),
	.avmm_rdnwr 		(avmm_rdnwr),
	.avmm_transvld  	(avmm_transvld),
	.bc_zero		(bc_zero),
	.cmd_is_read		(cmd_is_read)

);

//spisavb 
spisavb i_spisavb (
	// AVMM Interface
	.s_avmm_rst_n		(rst_n_avmmclk),
	.s_avmm_clk		(s_avmm_clk),
	.s_avmm0_addr		(s_avmm0_addr),   	// AVB chnl reg address for Read/write
	.s_avmm0_byte_en	(s_avmm0_byte_en), 	// AVB data byte en
	.s_avmm0_write		(s_avmm0_write),   	// AVB chnl write
	.s_avmm0_read		(s_avmm0_read),   	// AVB chnl read
	.s_avmm0_wdata		(s_avmm0_wdata),   	// AVB chnl write data
	.s_avmm0_rdata		(s_avmm0_rdata),   	// AVB chnl read data
	.s_avmm0_rdatavld	(s_avmm0_rdatavld),// AVB chnl read data valid
	.s_avmm0_waitreq	(s_avmm0_waitreq), 	// AVB chnl wait request
	.s_avmm1_addr		(s_avmm1_addr),   	// AVB chnl reg address for Read/write
	.s_avmm1_byte_en	(s_avmm1_byte_en), 	// AVB data byte en
	.s_avmm1_write		(s_avmm1_write),   	// AVB chnl write
	.s_avmm1_read		(s_avmm1_read),   	// AVB chnl read
	.s_avmm1_wdata		(s_avmm1_wdata),   	// AVB chnl write data
	.s_avmm1_rdata		(s_avmm1_rdata),   	// AVB chnl read data
	.s_avmm1_rdatavld	(s_avmm1_rdatavld),// AVB chnl read data valid
	.s_avmm1_waitreq	(s_avmm1_waitreq), 	// AVB chnl wait request
	.s_avmm2_addr		(s_avmm2_addr),   	// AVB chnl reg address for Read/write
	.s_avmm2_byte_en	(s_avmm2_byte_en), 	// AVB data byte en
	.s_avmm2_write		(s_avmm2_write),   	// AVB chnl write
	.s_avmm2_read		(s_avmm2_read),   	// AVB chnl read
	.s_avmm2_wdata		(s_avmm2_wdata),   	// AVB chnl write data
	.s_avmm2_rdata		(s_avmm2_rdata),   	// AVB chnl read data
	.s_avmm2_rdatavld	(s_avmm2_rdatavld),// AVB chnl read data valid
	.s_avmm2_waitreq	(s_avmm2_waitreq), 	// AVB chnl wait request
	.avb2reg_rdata_q	(avb2reg_rdata_q),   	// AVB chnl rdata to spis rd_buf
	.reg2avb_wdata		(reg2avb_wdata),   	// Wdata from spis wr_buf for AVB channel
	.avb2reg_addr		(avb2reg_addr), 	// Only 12 bits required to address  wrt_buf, rd_buf
						// To spis reg to read wr_buf or write to rd_buf from AVB 
	.dbg_bus1               (dbg_bus1),
	
	// inputs from s_cmd register
	.avmm_brstlen		(avmm_brstlen),  	// Burstlength in DWords
	.avmm_sel		(avmm_sel),		// To select AVMM interface
	.avmm_offset		(avmm_offset),		// starting offset for AVB Chnl register
	.avmm_transvld		(avmm_transvld),
	.avmm_rdnwr		(avmm_rdnwr),		// rd/wr burst length
	.avmmtransvld_up	(avmmtransvld_up),
	.avb2reg_write		(avb2reg_write), 	// write to spis reg rd_buf
	.avb2reg_read_pulse	(avb2reg_read_pulse)  	// read from spis reg wr_buf
);

rst_regen_low i_rstsync_rstn
(
 	.clk			(sclk),                 // continuous clock
 	.async_rst_n		(rst_n), 
 	.rst_n			(rst_n_sclk)
);

rst_regen_low i_rstsync_arstn
(
 	.clk			(s_avmm_clk),
 	.async_rst_n		(s_avmm_rst_n), 
 	.rst_n			(rst_n_avmmclk)
);

spis_miso_buf i_spis_miso_buf 
(
	.sel			(ss_n),
	.data_in		(miso_int),
	.data_out		(miso)
);

endmodule
