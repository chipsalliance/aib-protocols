// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: AXIST simplex dut top module
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps
module axist_gpiophy_top#(parameter AXI_TDATA_FACTOR = 4, parameter LEADER_MODE = 1, parameter FOLLOWER_MODE = 2, parameter  DATAWIDTH = 40)
  (
	input 				i_w_m_wr_rst_n,
	input 				i_w_s_wr_rst_n,
	input 				mgmt_clk,
	
	input				rst_phy_n,
	input				clk_phy,
	input				clk_p_div2,
	input				clk_p_div4,
	
	input 				ms_wr_clk,
	input 				ms_rd_clk,
	input 				ms_fwd_clk,
	output 				tx_online,
	output				rx_online,
	output [1:0]			test_done,
	
	input				sl_wr_clk,
	input				sl_rd_clk,
	input				sl_fwd_clk,
	output [(64*AXI_TDATA_FACTOR)-1:0]	o_tb_patdout,
	output         			o_tb_axist_valid,
	output         			o_tb_axist_ready,
					
	input  [31:0] 			i_wr_addr, 
	input  [31:0] 			i_wrdata, 
	input 				i_wren, 
	input 				i_rden,
	output				o_master_readdatavalid,
	output				o_master_waitreq,
	output [31:0] 			o_master_readdata,	
	
	input 				avmm_clk, 
	input 				osc_clk
	
);

parameter FULL = 1;
parameter HALF = 2;

wire [23:0]    			s1_ms_rx_transfer_en;
wire [23:0]    			s1_ms_tx_transfer_en;
wire [23:0]    			s1_sl_rx_transfer_en;
wire [23:0]    			s1_sl_tx_transfer_en;
wire [23:0]    			m1_ms_tx_transfer_en;
wire [23:0]    			m1_ms_rx_transfer_en;
wire [23:0]    			m1_sl_tx_transfer_en;
wire [23:0]    			m1_sl_rx_transfer_en;

wire [(64*AXI_TDATA_FACTOR)-1:0]			w_m_tx_axist_tdata;
wire 						w_m_tx_axist_tvalid;
wire 						w_m_tx_axist_tready;
wire [(64*AXI_TDATA_FACTOR)-1:0]			w_s_rx_axist_tdata;
wire 						w_s_rx_axist_tvalid;
wire 						w_s_rx_axist_tready;
wire 						usermode_en;
wire 						csr_patgen_en;
wire [1:0]					csr_patgen_sel;
wire [8:0]					csr_patgen_cnt;
wire 						patgen_data_wr;
wire [(64*AXI_TDATA_FACTOR)-1:0] 			patgen_exp_dout;
wire [1:0]					patchkr_out;
wire 						cntuspatt_en;
wire 						w_chkr_fifo_full;
wire 						slave_align_err;
wire 						slave_align_done ;
wire 						master_align_done;
wire 						w_axist_rstn;

wire						w_m_wr_rst_n;
wire						w_s_wr_rst_n;
wire [(DATAWIDTH*8)-1 : 0]			w_gen1_data_in_f;
wire [(DATAWIDTH*8)-1 : 0]			w_gen2_data_in_f;
wire [(DATAWIDTH*8)-1 : 0]			w_gen3_data_in_f;
wire [(DATAWIDTH*8)-1 : 0]			w_gen4_data_in_f;
wire [(DATAWIDTH*8)-1 : 0]			w_gen5_data_in_f;
wire [(DATAWIDTH*8)-1 : 0]			w_gen6_data_in_f;
wire [(DATAWIDTH*8)-1 : 0]			w_gen7_data_in_f;

wire [31:0]					w_delay_x_value;
wire [31:0]					w_delay_y_value;
wire [31:0]					w_delay_z_value;
wire [(64*AXI_TDATA_FACTOR)-1:0]			w_data_out_first;
wire 						w_data_out_first_valid;
wire [(64*AXI_TDATA_FACTOR)-1:0]			w_data_out_last;
wire 						w_data_out_last_valid;
wire [(64*AXI_TDATA_FACTOR)-1:0]			w_data_in_first;
wire 						w_data_in_first_valid;
wire [(64*AXI_TDATA_FACTOR)-1:0]			w_data_in_last;
wire 						w_data_in_last_valid;
wire						master_sl_tx_transfer_en;
wire						master_ms_tx_transfer_en;
wire						slave_sl_tx_transfer_en;
wire						slave_ms_tx_transfer_en;
wire						mgmtclk_reset_n;
wire	[1:0]					w_s_user_enable;


assign o_tb_patdout			= w_m_tx_axist_tdata ; 
assign o_tb_axist_valid     		= w_m_tx_axist_tvalid; 
assign o_tb_axist_ready     		= w_m_tx_axist_tready; 


assign tx_online = &{master_sl_tx_transfer_en,master_ms_tx_transfer_en,slave_sl_tx_transfer_en,slave_ms_tx_transfer_en} ;
assign rx_online = master_align_done & slave_align_done;
assign test_done = patchkr_out;

  reset_control reset_sync_mgmtclk(
	.clk(mgmt_clk),	
	.rst_n(w_m_wr_rst_n),
	.reset_out(),
	.reset_out_n(mgmtclk_reset_n)
	);

assign m1_ms_tx_transfer_en = 24'hFFFFFF; 
assign m1_ms_rx_transfer_en = 24'hFFFFFF;
assign m1_sl_tx_transfer_en = 24'hFFFFFF;
assign m1_sl_rx_transfer_en = 24'hFFFFFF;
assign s1_ms_rx_transfer_en = 24'hFFFFFF;
assign s1_ms_tx_transfer_en = 24'hFFFFFF;
assign s1_sl_rx_transfer_en = 24'hFFFFFF;
assign s1_sl_tx_transfer_en = 24'hFFFFFF;

	assign usermode_en = 1'b1;

	axi_st_simplex_gpio_phy_top #(.AXI_TDATA_FACTOR(AXI_TDATA_FACTOR), .LEADER_MODE(LEADER_MODE), .FOLLOWER_MODE(FOLLOWER_MODE), .PHY_DWIDTH(FULL)) axi_st_inst(

	.m_wr_clk_in(ms_wr_clk),
	.s_wr_clk_in(sl_wr_clk),	
	.axist_rstn_in(w_axist_rstn),
	.usermode_en(usermode_en),
	.por_in(1'b0),
	.m_gen2_mode(1'b0),	
	.w_m_wr_rst_n(i_w_m_wr_rst_n),
	.w_s_wr_rst_n(i_w_s_wr_rst_n),
	
	.i_delay_x_value(w_delay_x_value),
	.i_delay_y_value(w_delay_y_value),
	.i_delay_z_value(w_delay_z_value),
	
	
	.master_sl_tx_transfer_en(m1_sl_tx_transfer_en[((AXI_TDATA_FACTOR)-1):0]),
	.master_ms_tx_transfer_en(m1_ms_tx_transfer_en[((AXI_TDATA_FACTOR)-1):0]),
	.slave_ms_tx_transfer_en(s1_ms_tx_transfer_en[((AXI_TDATA_FACTOR)-1):0]),
   	.slave_sl_tx_transfer_en(s1_sl_tx_transfer_en[((AXI_TDATA_FACTOR)-1):0]),
	.o_slave_align_done (slave_align_done ), 
	.o_master_align_done(master_align_done),
	
	.m_tx_axist_tdata(w_m_tx_axist_tdata),
    	.m_tx_axist_tvalid(w_m_tx_axist_tvalid),
    	.m_tx_axist_tready(w_m_tx_axist_tready),
    
    	.s_rx_axist_tdata(w_s_rx_axist_tdata),
    	.s_rx_axist_tvalid(w_s_rx_axist_tvalid),
    	.s_rx_axist_tready(w_s_rx_axist_tready),
	.o_master_sl_tx_transfer_en(master_sl_tx_transfer_en),
	.o_master_ms_tx_transfer_en(master_ms_tx_transfer_en),
	.o_slave_sl_tx_transfer_en(slave_sl_tx_transfer_en ),
	.o_slave_ms_tx_transfer_en(slave_ms_tx_transfer_en ),
	.o_w_m_wr_rst_n(w_m_wr_rst_n),
	.o_s_wr_rst_n  (w_s_wr_rst_n)
);

axi_st_h2h_patgen_top #(.AXI_CHNL_NUM(AXI_TDATA_FACTOR), .LEADER_MODE(LEADER_MODE)) pat_gen(

	.wr_clk				(ms_wr_clk), 
	.rst_n				(w_m_wr_rst_n), 
	.patgen_en			(csr_patgen_en), 
	.patgen_sel			(csr_patgen_sel), 
	.patgen_cnt			(csr_patgen_cnt), 
	.patgen_dout			(w_m_tx_axist_tdata[(64*AXI_TDATA_FACTOR)-1:0]),
	.patgen_exp_dout		(patgen_exp_dout),
	.patgen_data_wr			(patgen_data_wr),
	.chkr_fifo_full			(w_chkr_fifo_full),
	.data_out_first			(w_data_out_first),
	.data_out_first_valid		(w_data_out_first_valid),
	.data_out_last		 	(w_data_out_last),
	.data_out_last_valid 		(w_data_out_last_valid),
	
	.cntuspatt_en			(cntuspatt_en),
	.axist_valid			(w_m_tx_axist_tvalid),
	.axist_rdy			(w_m_tx_axist_tready)

);

axi_st_h2h_csr axist_csr(
	.clk				(ms_wr_clk),	
	.rst_n				(w_m_wr_rst_n),
	.mgmt_clk			(mgmt_clk),
	.mgmt_clk_reset_n		(mgmtclk_reset_n),

	.master_address			(i_wr_addr),       				
	.master_readdata		(o_master_readdata), 
	.master_read			(i_rden),   
	.master_write			(i_wren),  
	.master_writedata		(i_wrdata),  
	.master_readdatavalid		(o_master_readdatavalid), 
	.master_byteenable		(),   
	.master_waitrequest		(o_master_waitreq),  
	.data_out_first			(w_data_out_first),						
	.data_out_first_valid		(w_data_out_first_valid),						
	.data_out_last		 	(w_data_out_last		 ),						
	.data_out_last_valid 		(w_data_out_last_valid ),	
	.data_in_first			(w_data_in_first),
    	.data_in_first_valid		(w_data_in_first_valid),
    	.data_in_last			(w_data_in_last),
	.data_in_last_valid		(w_data_in_last_valid),
	
	.o_delay_x_value		(w_delay_x_value),
	.o_delay_y_value		(w_delay_y_value),
	.o_delay_z_value		(w_delay_z_value),
	.chkr_pass			(patchkr_out),
	.ldr_tx_online			(&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}),
	.fllr_tx_online			(&{slave_sl_tx_transfer_en,slave_ms_tx_transfer_en}),
	.fllr_rx_online			(&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}),
	.ldr_rx_online			(&{slave_sl_tx_transfer_en,slave_ms_tx_transfer_en,w_m_tx_axist_tready}), //ready signal is added in 1ch as delay X,Y and Z values might cause FIFO overflow and improper data receive
	.align_error			(1'b0),

	.axist_rstn_out			(w_axist_rstn),
	
	.csr_patgen_en			(csr_patgen_en),		 
	.csr_patgen_sel			(csr_patgen_sel),    
	.csr_patgen_cnt			(csr_patgen_cnt),
	.csr_cntuspatt_en		(cntuspatt_en)
	
	);
		
axi_st_h2h_patchkr_top #(.AXI_CHNL_NUM(AXI_TDATA_FACTOR), .LEADER_MODE(LEADER_MODE), .FOLLOWER_MODE(FOLLOWER_MODE)) pattern_checker(
	.rdclk				(sl_wr_clk) ,
	.wrclk				(ms_wr_clk) ,
	.rst_n				(w_s_wr_rst_n) ,
	.patchkr_en			(csr_patgen_en) ,
	.patgen_cnt			(csr_patgen_cnt) ,
	.patgen_din			(patgen_exp_dout),
	.patgen_din_wr			(patgen_data_wr),
	.cntuspatt_en			(cntuspatt_en),
	.axist_tready			(w_s_rx_axist_tready),
	.chkr_fifo_full			(w_chkr_fifo_full),
	.axist_valid			(w_s_rx_axist_tvalid),
	.axist_enable			(w_s_user_enable),
	.data_in_first			(w_data_in_first),
	.data_in_first_valid		(w_data_in_first_valid),
	.data_in_last			(w_data_in_last),
	.data_in_last_valid		(w_data_in_last_valid),
	
	.axist_rcv_data			(w_s_rx_axist_tdata[(64*AXI_TDATA_FACTOR)-1:0]),
	.patchkr_out			(patchkr_out)

);

endmodule
