//// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: CSR control top module
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////

module axi_st_h2h_csr (
	input 				clk,	
	input 				rst_n,
	input 				mgmt_clk,
	input 				mgmt_clk_reset_n,
	
	input	[31:0]			master_address,       
   	output	[31:0]			master_readdata,    
   	input				master_read,      
   	input				master_write,    
   	input	[31:0]			master_writedata, 
   	output				master_waitrequest, 
   	output				master_readdatavalid,
   	output	[3:0]			master_byteenable, 
	
	input	[1:0]			chkr_pass,
	input					align_error,
	input 				ldr_tx_online,
	input 				ldr_rx_online,
	input 				fllr_tx_online,
	input 				fllr_rx_online,
	output	[31:0]			o_delay_x_value,
	output	[31:0]			o_delay_y_value,
	output	[31:0]			o_delay_z_value,
	input  				data_out_first_valid,
	input  				data_out_last_valid,
	input  				data_in_first_valid,
	input  				data_in_last_valid,

	  `ifdef FOUR_CHNL	
		input  [255:0]			data_out_first,	
		input  [255:0]			data_out_last,	
		input  [255:0]			data_in_first,	
		input  [255:0]			data_in_last,
	  `else 
	  	input  [63:0]			data_out_first,	
		input  [63:0]			data_out_last,	
		input  [63:0]			data_in_first,	
		input  [63:0]			data_in_last,	  
	  `endif
	
	`ifdef AXIST_DUAL
	  input 	[1:0]			f2l_chkr_pass,
	  input					f2l_align_error,
	  output 				f2l_csr_patgen_en,
	  output 	[1:0]			f2l_csr_patgen_sel,
	  output 	[8:0]			f2l_csr_patgen_cnt,
	  output 				f2l_csr_cntuspatt_en,
	  input  				f2l_data_out_first_valid,
	  input  				f2l_data_out_last_valid,
	  input  				f2l_data_in_first_valid,
	  input  				f2l_data_in_last_valid,
	  `ifdef FOUR_CHNL
	  	input  [255:0]		f2l_data_out_first,	  
	  	input  [255:0]		f2l_data_out_last,	  
	  	input  [255:0]		f2l_data_in_first,	  
	  	input  [255:0]		f2l_data_in_last,
	  `else
		input  [63:0]		f2l_data_out_first,	  
	  	input  [63:0]		f2l_data_out_last,	  
	  	input  [63:0]		f2l_data_in_first,	  
	  	input  [63:0]		f2l_data_in_last,
	  `endif
	
	`endif
	
	output 				axist_rstn_out,
	output 				csr_patgen_en,
	output 	[1:0]			csr_patgen_sel,
	output 	[8:0]			csr_patgen_cnt,
	output 				csr_cntuspatt_en	

	);
	
	wire [15:0]			csr_wr_rd_addr;		
	wire				csr_wr_en;
	wire				csr_rd_en;
	wire [31:0]			csr_wr_data;
	wire [31:0]			csr_rd_datain;
	wire				csr_rd_dvalid;
	
	
	jtag2avmm_bridge jtag_bridge(

	.clk (clk),
	.rst_n (rst_n),
	.mgmt_clk (mgmt_clk),
  	.mgmt_clk_reset_n(mgmt_clk_reset_n),

	.master_address(master_address),       		
   	.master_readdata(master_readdata),   
   	.master_read(master_read),       
   	.master_write(master_write),      
   	.master_writedata(master_writedata),   
   	.master_waitrequest(master_waitrequest),   
   	.master_readdatavalid(master_readdatavalid), 
   	.master_byteenable(master_byteenable),   
	
	.wr_rd_addr(csr_wr_rd_addr),		
	.wr_en(csr_wr_en),
	.rd_en(csr_rd_en),
	.wr_data(csr_wr_data),
	
	.rd_datain(csr_rd_datain),
	.csr_rd_dvalid(csr_rd_dvalid)
	
	);

csr_ctrl_h2h csr(
	.clk(clk),	
	.rst_n(rst_n),
	
	.wr_rd_addr(csr_wr_rd_addr),		
	.wr_en(csr_wr_en),
	.rd_en(csr_rd_en),
	.wr_data(csr_wr_data),
	
	.rd_datain(csr_rd_datain),
	.rd_dvalid(csr_rd_dvalid),
	
	.chkr_pass(chkr_pass),
	.align_error(align_error),
	.ldr_tx_online(ldr_tx_online),
	.ldr_rx_online(ldr_rx_online),
	.fllr_tx_online(fllr_tx_online),
	.fllr_rx_online(fllr_rx_online),
	.o_delay_x_value(o_delay_x_value),
	.o_delay_y_value(o_delay_y_value),
	.o_delay_z_value(o_delay_z_value),
	.axist_rstn_out(axist_rstn_out),
	.data_out_first(data_out_first),
	.data_out_first_valid(data_out_first_valid),
	.data_out_last(data_out_last),
	.data_out_last_valid(data_out_last_valid),
	
	.data_in_first(data_in_first),
	.data_in_first_valid(data_in_first_valid),
	.data_in_last(data_in_last),
	.data_in_last_valid(data_in_last_valid),
	
	
	`ifdef AXIST_DUAL
	  .f2l_chkr_pass(f2l_chkr_pass),
	  .f2l_align_error(f2l_align_error),
	  .f2l_csr_patgen_en(f2l_csr_patgen_en),
	  .f2l_csr_patgen_sel(f2l_csr_patgen_sel),
	  .f2l_csr_patgen_cnt(f2l_csr_patgen_cnt),
	  .f2l_csr_cntuspatt_en(f2l_csr_cntuspatt_en),
	  .f2l_data_out_first(f2l_data_out_first),
	  .f2l_data_out_first_valid(f2l_data_out_first_valid),
	  .f2l_data_out_last(f2l_data_out_last),
	  .f2l_data_out_last_valid(f2l_data_out_last_valid),
	  
	  .f2l_data_in_first(f2l_data_in_first),
	  .f2l_data_in_first_valid(f2l_data_in_first_valid),
	  .f2l_data_in_last(f2l_data_in_last),
	  .f2l_data_in_last_valid(f2l_data_in_last_valid),
	`endif
	.csr_patgen_en(csr_patgen_en),
	.csr_patgen_sel(csr_patgen_sel),
	.csr_patgen_cnt(csr_patgen_cnt),
	.csr_cntuspatt_en(csr_cntuspatt_en)
	
	
);

endmodule
