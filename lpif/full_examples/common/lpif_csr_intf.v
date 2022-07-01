// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: CSR control top module
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////

module lpif_csr_intf (
	input 					clk,	
	input 					rst_n,
	
	input	[31:0]			master_address,       // width = 32,       master.address
    output	[31:0]			master_readdata,      // width = 32,             .readdata
    input					master_read,          //  width = 1,             .read
    input					master_write,         //  width = 1,             .write
    input	[31:0]			master_writedata,     // width = 32,             .writedata
    output					master_waitrequest,   //  width = 1,             .waitrequest
    output					master_readdatavalid, //  width = 1,             .readdatavalid
    output	[3:0]			master_byteenable,    //  width = 4,             .byteenable
	
	input 	[1:0]			chkr_pass,
	input					test_complete,
	input					align_error,
	input					align_done,
	input 					die_a_tx_online,
	input 					die_a_rx_online,
	input 					die_b_tx_online,
	input 					die_b_rx_online,
	output	[31:0]			o_delay_x_value,
	output	[31:0]			o_delay_y_value,
	output	[31:0]			o_delay_z_value,
	
	output					flit_wr_en

	
	);
	
	wire [15:0]				csr_wr_rd_addr;		
	wire					csr_wr_en;
	wire					csr_rd_en;
	wire [31:0]				csr_wr_data;
	
	wire [31:0]				csr_rd_datain;
	wire					csr_rd_dvalid;
	
	
	jtag2avmm_bridge jtag_bridge(

	.clk (clk),
	.rst_n (rst_n),
    
	.master_address(master_address),       // width = 32,       master.address
    .master_readdata(master_readdata),      // width = 32,             .readdata
    .master_read(master_read),          //  width = 1,             .read
    .master_write(master_write),         //  width = 1,             .write
    .master_writedata(master_writedata),     // width = 32,             .writedata
    .master_waitrequest(master_waitrequest),   //  width = 1,             .waitrequest
    .master_readdatavalid(master_readdatavalid), //  width = 1,             .readdatavalid
    .master_byteenable(master_byteenable),    //  width = 4,             .byteenable
	
	.wr_rd_addr(csr_wr_rd_addr),		
	.wr_en(csr_wr_en),
	.rd_en(csr_rd_en),
	.wr_data(csr_wr_data),
	
	.rd_datain(csr_rd_datain),
	.rd_dvalid(csr_rd_dvalid)
	
);

lpif_csr csr(
	
	.clk(clk),	
	.rst_n(rst_n),
	
	.wr_rd_addr(csr_wr_rd_addr),		
	.wr_en(csr_wr_en),
	.rd_en(csr_rd_en),
	.wr_data(csr_wr_data),
	
	.rd_datain(csr_rd_datain),
	.rd_dvalid(csr_rd_dvalid),
	
	.o_delay_x_value(o_delay_x_value),
	.o_delay_y_value(o_delay_y_value),
	.o_delay_z_value(o_delay_z_value),
	
	.test_complete(test_complete),
	.chkr_pass(chkr_pass),
	.align_error(align_error),
	.die_a_tx_online(die_a_tx_online),
	.die_a_rx_online(die_a_rx_online),
	.die_b_tx_online(die_b_tx_online),
	.die_b_rx_online(die_b_rx_online),
	.align_done(align_done),
	
	.flit_wr_en(flit_wr_en)
	
);

endmodule
