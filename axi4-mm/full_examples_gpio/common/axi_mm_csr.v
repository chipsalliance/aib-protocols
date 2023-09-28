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

module axi_mm_csr #(parameter AXI_CHNL_NUM = 1)(
	input 					clk,	
	input 					rst_n,
	
	input	[31:0]				master_address,       // width = 32,       master.address
    	output	[31:0]				master_readdata,      // width = 32,             .readdata
    	input					master_read,          //  width = 1,             .read
    	input					master_write,         //  width = 1,             .write
    	input	[31:0]				master_writedata,     // width = 32,             .writedata
    	output					master_waitrequest,   //  width = 1,             .waitrequest
    	output					master_readdatavalid, //  width = 1,             .readdatavalid
    	output	[3:0]				master_byteenable,    //  width = 4,             .byteenable
	
	input  [(AXI_CHNL_NUM*64)-1:0]		data_out_first,
	input  					data_out_first_valid,
	input  [(AXI_CHNL_NUM*64)-1:0]		data_out_last,
	input  					data_out_last_valid,
	
	input  [(AXI_CHNL_NUM*64)-1:0]		data_in_first,
	input  					data_in_first_valid,
	input  [(AXI_CHNL_NUM*64)-1:0]		data_in_last,
	input  					data_in_last_valid,

`ifdef AXIMM_DUPLEX
	input 				s2m_read_complete,
	input 				s2m_write_complete,

	input  [(AXI_CHNL_NUM*64)-1:0]	s2m_data_out_first,
	input  				s2m_data_out_first_valid,
	input  [(AXI_CHNL_NUM*64)-1:0]	s2m_data_out_last,
	input  				s2m_data_out_last_valid,
	
	input  [(AXI_CHNL_NUM*64)-1:0]	s2m_data_in_first,
	input  				s2m_data_in_first_valid,
	input  [(AXI_CHNL_NUM*64)-1:0]	s2m_data_in_last,
	input  				s2m_data_in_last_valid,
	
	output 				s2m_aximm_wr,
	output 				s2m_aximm_rd,
	output 	[7:0]			s2m_aximm_rw_length,
	output 	[1:0]			s2m_aximm_rw_burst,
	output 	[2:0]			s2m_aximm_rw_size,
	output 	[31:0]			s2m_aximm_rw_addr,	
	input 	[1:0]			s2m_chkr_pass,
`endif	
	
	input 	[1:0]				chkr_pass,
	input					read_complete,
	input					write_complete,
	input					align_error,
	input					f2l_align_error,
	input 					ldr_tx_online,
	input 					ldr_rx_online,
	input 					fllr_tx_online,
	input 					fllr_rx_online,
	output	[31:0]				o_delay_x_value,
	output	[31:0]				o_delay_y_value,
	output	[31:0]				o_delay_z_value,
	
	output 					axist_rstn_out,
	output 					aximm_wr,
	output 					aximm_rd,
	output 	[7:0]				aximm_rw_length,
	output 	[1:0]				aximm_rw_burst,
	output 	[2:0]				aximm_rw_size,
	output 	[31:0]				aximm_rw_addr	

	
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
	.mgmt_clk_reset_n(1'b0),
	.mgmt_clk(1'b0),	
	.wr_rd_addr(csr_wr_rd_addr),		
	.wr_en(csr_wr_en),
	.rd_en(csr_rd_en),
	.wr_data(csr_wr_data),
	
	.rd_datain(csr_rd_datain),
	.csr_rd_dvalid(csr_rd_dvalid)
	
);

mm_csr_ctrl #(.AXI_CHNL_NUM(AXI_CHNL_NUM)) csr(
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
	.data_out_first(data_out_first),
	`ifdef AXIMM_DUPLEX
	.s2m_data_out_first(s2m_data_out_first),
	.s2m_data_out_first_valid(s2m_data_out_first_valid),
	.s2m_data_out_last(s2m_data_out_last),
	.s2m_data_out_last_valid(s2m_data_out_last_valid),
	
	.s2m_data_in_first(s2m_data_in_first),
	.s2m_data_in_first_valid(s2m_data_in_first_valid),
	.s2m_data_in_last(s2m_data_in_last),
	.s2m_data_in_last_valid(s2m_data_in_last_valid),
	
	.s2m_chkr_pass(s2m_chkr_pass),
	.s2m_read_complete(s2m_read_complete),
	.s2m_write_complete(s2m_write_complete),
	.s2m_aximm_wr(s2m_aximm_wr),
	.s2m_aximm_rd(s2m_aximm_rd),
	.s2m_aximm_rw_length(s2m_aximm_rw_length),
	.s2m_aximm_rw_burst(s2m_aximm_rw_burst),
	.s2m_aximm_rw_size(s2m_aximm_rw_size),
	.s2m_aximm_rw_addr(s2m_aximm_rw_addr),
	`endif
	.data_out_first_valid(data_out_first_valid),
	.data_out_last(data_out_last),
	.data_out_last_valid(data_out_last_valid),
	
	.data_in_first(data_in_first),
	.data_in_first_valid(data_in_first_valid),
	.data_in_last(data_in_last),
	.data_in_last_valid(data_in_last_valid),
	
	.axist_rstn_out(axist_rstn_out),
	.chkr_pass(chkr_pass),
	.f2l_align_error(f2l_align_error),
	.align_error(align_error),
	.ldr_tx_online(ldr_tx_online),
	.ldr_rx_online(ldr_rx_online),
	.fllr_tx_online(fllr_tx_online),
	.fllr_rx_online(fllr_rx_online),
	.read_complete(read_complete),
	.write_complete(write_complete),
	.aximm_wr(aximm_wr),
	.aximm_rd(aximm_rd),
	.aximm_rw_length(aximm_rw_length),
	.aximm_rw_burst(aximm_rw_burst),
	.aximm_rw_size(aximm_rw_size),
	.aximm_rw_addr(aximm_rw_addr)	
	
	
);

endmodule
