// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: AXIST Dual dut top module
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ps/1ps

module axist_aib_dual_top#(parameter LEADER_MODE = 1, parameter FOLLOWER_MODE = 2,parameter DATAWIDTH = 40, parameter TOTAL_CHNL_NUM = 24)
  (
	input 			i_w_m_wr_rst_n,
	input 			i_w_s_wr_rst_n,
	input 			mgmt_clk,
	
	input			rst_phy_n,
	input			clk_phy,
	input			clk_p_div2,
	input			clk_p_div4,
	
	input 			ms_wr_clk,
	input 			ms_rd_clk,
	input 			ms_fwd_clk,
	
	input			sl_wr_clk,
	input			sl_rd_clk,
	input			sl_fwd_clk,

	output 			tx_online,
	output 			rx_online,
	output [1:0]		test_done,
	
	output [255:0]		o_tb_patdout,
	output          	o_tb_axist_valid,
	output          	o_tb_axist_ready,	
	output [511:0]		o_tb_f2l_patdout,
	output          	o_tb_f2l_axist_valid,
	output          	o_tb_f2l_axist_ready,
	
    	input  [31:0] 		i_wr_addr, 
    	input  [31:0] 		i_wrdata, 
    	input 			i_wren, 
    	input 			i_rden,
    	output			o_master_readdatavalid,
    	output			o_master_waitreq,
    	output [31:0] 		o_master_readdata,	
	
	input 			avmm_clk, 
	input 			osc_clk
	
);

wire [TOTAL_CHNL_NUM-1:0]    		s1_ms_rx_transfer_en;
wire [TOTAL_CHNL_NUM-1:0]    		s1_ms_tx_transfer_en;
wire [TOTAL_CHNL_NUM-1:0]    		s1_sl_rx_transfer_en;
wire [TOTAL_CHNL_NUM-1:0]    		s1_sl_tx_transfer_en;
wire [TOTAL_CHNL_NUM-1:0]    		m1_ms_tx_transfer_en;
wire [TOTAL_CHNL_NUM-1:0]    		m1_ms_rx_transfer_en;
wire [TOTAL_CHNL_NUM-1:0]    		m1_sl_tx_transfer_en;
wire [TOTAL_CHNL_NUM-1:0]    		m1_sl_rx_transfer_en;

wire [TOTAL_CHNL_NUM*DATAWIDTH*8-1:0]	data_in_f;
wire [TOTAL_CHNL_NUM*DATAWIDTH*8-1:0]	data_out_f;
wire [TOTAL_CHNL_NUM*DATAWIDTH*2-1:0]   gen1_data_in_f;
wire [TOTAL_CHNL_NUM*DATAWIDTH*2-1:0]   gen1_data_out_f;
wire 					por_out;
wire [TOTAL_CHNL_NUM-1 : 0]		w_m1_m_fs_rcv_clk;
wire [TOTAL_CHNL_NUM-1 : 0]		w_m1_m_fs_fwd_clk;
wire [TOTAL_CHNL_NUM-1 : 0]		w_s1_m_fs_fwd_clk;

wire [((LEADER_MODE*256)-1):0]		w_m2s_m_tx_axist_tdata;
wire 					w_m2s_m_tx_axist_tvalid;
wire 					w_m2s_m_tx_axist_tready;
wire [(FOLLOWER_MODE*256)-1:0]		w_m2s_s_rx_axist_tdata;
wire 					w_m2s_s_rx_axist_tvalid;
wire 					w_m2s_s_rx_axist_tready;
//lravipax
wire [((FOLLOWER_MODE*256)-1)  :0]	w_s2m_s_tx_axist_tdata;
wire 					w_s2m_s_tx_axist_tvalid;
wire 					w_s2m_s_tx_axist_tready;
wire [(LEADER_MODE*256)-1:0]		w_s2m_m_rx_axist_tdata;
wire 					w_s2m_m_rx_axist_tvalid;
wire 					w_s2m_m_rx_axist_tready;
//lravipax
wire 					csr_patgen_en;
wire [1:0]				csr_patgen_sel;
wire [8:0]				csr_patgen_cnt;
wire 					f2l_csr_patgen_en;
wire [1:0]				f2l_csr_patgen_sel;
wire [8:0]				f2l_csr_patgen_cnt;
wire 					patgen_data_wr;
wire 					s2m_patgen_data_wr;
wire [(LEADER_MODE*40)-1:0] 		patgen_exp_dout;
wire [(FOLLOWER_MODE*40)-1:0] 		s2m_patgen_exp_dout;
wire [1:0]				patchkr_out;
wire [1:0]				f2l_patchkr_out;
wire 					cntuspatt_en;
wire 					w_m2s_chkr_fifo_full;
wire 					w_s2m_chkr_fifo_full;
wire 					slave_align_err;
wire 					slave_align_done ;
wire 					master_align_done;
wire 					w_axist_rstn;
wire [TOTAL_CHNL_NUM*DATAWIDTH*2-1:0]	data_in_reg;

wire					w_m_wr_rst_n;
wire					w_s_wr_rst_n;
wire 					usermode_en;
					
wire [31:0]				w_delay_x_value;
wire [31:0]				w_delay_y_value;
wire [31:0]				w_delay_z_value;

wire [(DATAWIDTH*8)-1 : 0]		w_gen1_data_in_f;
wire [(DATAWIDTH*8)-1 : 0]		w_gen2_data_in_f;
wire [(DATAWIDTH*8)-1 : 0]		w_gen3_data_in_f;
wire [(DATAWIDTH*8)-1 : 0]		w_gen4_data_in_f;
wire [(DATAWIDTH*8)-1 : 0]		w_gen5_data_in_f;
wire [(DATAWIDTH*8)-1 : 0]		w_gen6_data_in_f;
wire [(DATAWIDTH*8)-1 : 0]		w_gen7_data_in_f;
wire [1:0]				w_m2s_s_enable;

wire [255:0]				w_data_out_first;
wire 					w_data_out_first_valid;
wire [255:0]				w_data_out_last;
wire 					w_data_out_last_valid;
wire [511:0]				w_data_in_first;
wire 					w_data_in_first_valid;
wire [511:0]				w_data_in_last;
wire 					w_data_in_last_valid;
wire [511:0]				w_f2l_data_in_first;
wire 					w_f2l_data_in_first_valid;
wire [511:0]				w_f2l_data_in_last;
wire 					w_f2l_data_in_last_valid;

wire [255:0]				w_f2l_data_out_first;			
wire					w_f2l_data_out_first_valid;    
wire [255:0]				w_f2l_data_out_last;           
wire					w_f2l_data_out_last_valid;     
wire					master_sl_tx_transfer_en;     
wire					master_ms_tx_transfer_en;     
wire					slave_sl_tx_transfer_en;     
wire					slave_ms_tx_transfer_en;     
wire					mgmtclk_reset_n;     
wire 					w_user_s2m_m_enable;
wire 					w_read_pong_out;
	 

assign o_tb_patdout	       = w_m2s_m_tx_axist_tdata[255:0]; 
assign o_tb_axist_valid        = w_m2s_m_tx_axist_tvalid; 
assign o_tb_axist_ready        = w_m2s_m_tx_axist_tready; 

assign o_tb_f2l_patdout	       = w_s2m_s_tx_axist_tdata[511:0];
assign o_tb_f2l_axist_valid    = w_s2m_s_tx_axist_tvalid ;
assign o_tb_f2l_axist_ready    = w_s2m_s_tx_axist_tready ;

assign gen1_data_in_f[(DATAWIDTH*2*1)-1 : (DATAWIDTH*2*0)] = w_gen1_data_in_f[(DATAWIDTH*2)-1 : 0];
assign gen1_data_in_f[(DATAWIDTH*2*2)-1 : (DATAWIDTH*2*1)] = w_gen2_data_in_f[(DATAWIDTH*2)-1 : 0];
assign gen1_data_in_f[(DATAWIDTH*2*3)-1 : (DATAWIDTH*2*2)] = w_gen3_data_in_f[(DATAWIDTH*2)-1 : 0];
assign gen1_data_in_f[(DATAWIDTH*2*4)-1 : (DATAWIDTH*2*3)] = w_gen4_data_in_f[(DATAWIDTH*2)-1 : 0];
assign gen1_data_in_f[(DATAWIDTH*2*5)-1 : (DATAWIDTH*2*4)] = w_gen5_data_in_f[(DATAWIDTH*2)-1 : 0];
assign gen1_data_in_f[(DATAWIDTH*2*6)-1 : (DATAWIDTH*2*5)] = w_gen6_data_in_f[(DATAWIDTH*2)-1 : 0];
assign gen1_data_in_f[(DATAWIDTH*2*7)-1 : (DATAWIDTH*2*6)] = w_gen7_data_in_f[(DATAWIDTH*2)-1 : 0];

assign gen1_data_in_f[TOTAL_CHNL_NUM*DATAWIDTH*2-1:DATAWIDTH*2*7] = 'b0;
assign data_in_f[TOTAL_CHNL_NUM*DATAWIDTH*8-1:7*DATAWIDTH*8] 	  = 'b0;
assign data_in_reg 	= 1920'b0;

assign tx_online = &{master_sl_tx_transfer_en,master_ms_tx_transfer_en,slave_sl_tx_transfer_en,slave_ms_tx_transfer_en} ;
assign rx_online = master_align_done & slave_align_done;
assign test_done = patchkr_out;

top_aib #(.DWIDTH(DATAWIDTH), .TOTAL_CHNL_NUM(TOTAL_CHNL_NUM)) aib_model_inst(
	.avmm_clk(avmm_clk),
	.osc_clk(osc_clk),
	.m1_data_in_f(data_in_f),
    	.m1_data_out_f(data_out_f),
    	.m1_data_in(data_in_reg), //output data to pad
    	.m1_data_out(),
	.m1_m_ns_fwd_clk({TOTAL_CHNL_NUM{ms_fwd_clk}}), //output data clock
    	.m1_m_ns_rcv_clk({TOTAL_CHNL_NUM{ms_fwd_clk}}),
    	.m1_m_fs_rcv_clk(w_m1_m_fs_rcv_clk),
    	.m1_m_fs_fwd_clk(w_m1_m_fs_fwd_clk),
    	.m1_m_wr_clk({TOTAL_CHNL_NUM{ms_wr_clk}}),
    	.m1_m_rd_clk({TOTAL_CHNL_NUM{ms_rd_clk}}),
	 
	.usermode_en(usermode_en),
	.m1_ms_tx_transfer_en(m1_ms_tx_transfer_en),
    	.m1_ms_rx_transfer_en(m1_ms_rx_transfer_en),
    	.m1_sl_tx_transfer_en(m1_sl_tx_transfer_en),
    	.m1_sl_rx_transfer_en(m1_sl_rx_transfer_en),
	.m1_i_osc_clk(osc_clk),   //Only for master mode
	.m1_por_out(por_out),
	.s1_gen1_data_in_f(gen1_data_in_f),
    	.s1_gen1_data_out_f(gen1_data_out_f),   
	.s1_m_wr_clk({TOTAL_CHNL_NUM{sl_wr_clk}}),
    	.s1_m_rd_clk({TOTAL_CHNL_NUM{sl_rd_clk}}),
	.s1_m_ns_fwd_clk({TOTAL_CHNL_NUM{sl_fwd_clk}}),
	.s1_m_fs_fwd_clk(w_s1_m_fs_fwd_clk),
    	.s1_ms_rx_transfer_en(s1_ms_rx_transfer_en),
    	.s1_ms_tx_transfer_en(s1_ms_tx_transfer_en),
    	.s1_sl_rx_transfer_en(s1_sl_rx_transfer_en),
    	.s1_sl_tx_transfer_en(s1_sl_tx_transfer_en)

);


axi_st_d256_multichannel_f2h_dual_top #(.LEADER_MODE(LEADER_MODE), .FOLLOWER_MODE(FOLLOWER_MODE)) axi_st_inst(

	.m_wr_clk_in(ms_wr_clk),
	.s_wr_clk_in(sl_wr_clk),	
	.axist_rstn_in(w_axist_rstn),	
	`ifdef AIB_MODEL
	  .por_in(por_out),
	`else
          .por_in(1'b0),
  	`endif		  
	.m_gen2_mode(1'b0),	
	.w_m_wr_rst_n(i_w_m_wr_rst_n),
	.w_s_wr_rst_n(i_w_s_wr_rst_n),
	.rst_phy_n(rst_phy_n),
	.clk_phy(clk_phy), 
	.clk_p_div2(clk_p_div2),
	.clk_p_div4(clk_p_div4),
	
	.master_sl_tx_transfer_en(m1_sl_tx_transfer_en[6:0]),// From p2p_lite_i0 of p2p_lite.v, ...
	.master_ms_tx_transfer_en(m1_ms_tx_transfer_en[6:0]),// From p2p_lite_i0 of p2p_lite.v, ...
	.slave_ms_tx_transfer_en(s1_ms_tx_transfer_en[6:0]),// From p2p_lite_i0 of p2p_lite.v, ...
   	.slave_sl_tx_transfer_en(s1_sl_tx_transfer_en[6:0]),// From p2p_lite_i0 of p2p_lite.v, ...
	.o_slave_align_done (slave_align_done ), 
	.o_master_align_done(master_align_done),
	.user_s2m_m_enable(w_user_s2m_m_enable),
	.user_m2s_s_enable(w_m2s_s_enable),
	
	.i_delay_x_value(w_delay_x_value),
	.i_delay_y_value(w_delay_y_value),
	.i_delay_z_value(w_delay_z_value),
	.usermode_en(usermode_en),
	
	.master_ca2phy_0(data_in_f[(DATAWIDTH*8*1)-1 : (DATAWIDTH*8*0)]),
	.master_ca2phy_1(data_in_f[(DATAWIDTH*8*2)-1 : (DATAWIDTH*8*1)]),
	.master_ca2phy_2(data_in_f[(DATAWIDTH*8*3)-1 : (DATAWIDTH*8*2)]),
	.master_ca2phy_3(data_in_f[(DATAWIDTH*8*4)-1 : (DATAWIDTH*8*3)]),
	.master_ca2phy_4(data_in_f[(DATAWIDTH*8*5)-1 : (DATAWIDTH*8*4)]),
	.master_ca2phy_5(data_in_f[(DATAWIDTH*8*6)-1 : (DATAWIDTH*8*5)]),
	.master_ca2phy_6(data_in_f[(DATAWIDTH*8*7)-1 : (DATAWIDTH*8*6)]),
	
	.master_phy2ca_0({280'b0,data_out_f[(DATAWIDTH*8*0)+(DATAWIDTH-1) : (DATAWIDTH*8*0)]}),	// From p2p_lite_i0 of p2p_lite.v
	.master_phy2ca_1({280'b0,data_out_f[(DATAWIDTH*8*1)+(DATAWIDTH-1) : (DATAWIDTH*8*1)]}),	// From p2p_lite_i1 of p2p_lite.v
	.master_phy2ca_2({280'b0,data_out_f[(DATAWIDTH*8*2)+(DATAWIDTH-1) : (DATAWIDTH*8*2)]}),	// From p2p_lite_i2 of p2p_lite.v
	.master_phy2ca_3({280'b0,data_out_f[(DATAWIDTH*8*3)+(DATAWIDTH-1) : (DATAWIDTH*8*3)]}),	// From p2p_lite_i3 of p2p_lite.v
	.master_phy2ca_4({280'b0,data_out_f[(DATAWIDTH*8*4)+(DATAWIDTH-1) : (DATAWIDTH*8*4)]}),	// From p2p_lite_i4 of p2p_lite.v
	.master_phy2ca_5({280'b0,data_out_f[(DATAWIDTH*8*5)+(DATAWIDTH-1) : (DATAWIDTH*8*5)]}),	// From p2p_lite_i5 of p2p_lite.v
	.master_phy2ca_6({280'b0,data_out_f[(DATAWIDTH*8*6)+(DATAWIDTH-1) : (DATAWIDTH*8*6)]}),	// From p2p_lite_i6 of p2p_lite.v
	
	.slave_ca2phy_0(w_gen1_data_in_f),
	.slave_ca2phy_1(w_gen2_data_in_f),
	.slave_ca2phy_2(w_gen3_data_in_f),
	.slave_ca2phy_3(w_gen4_data_in_f),
	.slave_ca2phy_4(w_gen5_data_in_f),
	.slave_ca2phy_5(w_gen6_data_in_f),
	.slave_ca2phy_6(w_gen7_data_in_f),
	
	.slave_phy2ca_0({240'b0,gen1_data_out_f[(DATAWIDTH*2*1)-1 : (DATAWIDTH*2*0)]}),		// From p2p_lite_i0 of p2p_lite.v
	.slave_phy2ca_1({240'b0,gen1_data_out_f[(DATAWIDTH*2*2)-1 : (DATAWIDTH*2*1)]}),		// From p2p_lite_i1 of p2p_lite.v
	.slave_phy2ca_2({240'b0,gen1_data_out_f[(DATAWIDTH*2*3)-1 : (DATAWIDTH*2*2)]}),		// From p2p_lite_i2 of p2p_lite.v
	.slave_phy2ca_3({240'b0,gen1_data_out_f[(DATAWIDTH*2*4)-1 : (DATAWIDTH*2*3)]}),		// From p2p_lite_i3 of p2p_lite.v
	.slave_phy2ca_4({240'b0,gen1_data_out_f[(DATAWIDTH*2*5)-1 : (DATAWIDTH*2*4)]}),		// From p2p_lite_i4 of p2p_lite.v
	.slave_phy2ca_5({240'b0,gen1_data_out_f[(DATAWIDTH*2*6)-1 : (DATAWIDTH*2*5)]}),		// From p2p_lite_i5 of p2p_lite.v
	.slave_phy2ca_6({240'b0,gen1_data_out_f[(DATAWIDTH*2*7)-1 : (DATAWIDTH*2*6)]}),	// From p2p_lite_i6 of p2p_lite.v
	//Leader to Follower
    	.user_m2s_m_tdata( w_m2s_m_tx_axist_tdata),
    	.user_m2s_m_tvalid(w_m2s_m_tx_axist_tvalid),
    	.user_m2s_m_tready(w_m2s_m_tx_axist_tready),
    
    	.user_m2s_s_tdata(w_m2s_s_rx_axist_tdata),
    	.user_m2s_s_tvalid(w_m2s_s_rx_axist_tvalid),
    	.user_m2s_s_tready(w_m2s_s_rx_axist_tready),
	
	//Follower to Leader
    	.user_s2m_m_tdata(w_s2m_m_rx_axist_tdata),   
    	.user_s2m_m_tvalid(w_s2m_m_rx_axist_tvalid), 
    	.user_s2m_m_tready(w_s2m_m_rx_axist_tready), 
    
    	.user_s2m_s_tdata(w_s2m_s_tx_axist_tdata),   
    	.user_s2m_s_tvalid(w_s2m_s_tx_axist_tvalid), 
    	.user_s2m_s_tready(w_s2m_s_tx_axist_tready),   

	.o_slave_align_err(slave_align_err),
	.o_master_align_err(master_align_err),
	.o_master_sl_tx_transfer_en(master_sl_tx_transfer_en),
	.o_master_ms_tx_transfer_en(master_ms_tx_transfer_en),
	.o_slave_sl_tx_transfer_en(slave_sl_tx_transfer_en ),
	.o_slave_ms_tx_transfer_en(slave_ms_tx_transfer_en ),
	.o_w_m_wr_rst_n(w_m_wr_rst_n),
	.o_s_wr_rst_n  (w_s_wr_rst_n)
);

axi_st_patgen_dual_top #(.LEADER_MODE(LEADER_MODE)) pat_gen_m2s(

	.wr_clk(ms_wr_clk), 
	.rst_n(w_m_wr_rst_n), 
	.patgen_en(csr_patgen_en), 
	.patgen_sel(csr_patgen_sel), 
	.patgen_cnt(csr_patgen_cnt), 
	.patgen_dout(w_m2s_m_tx_axist_tdata[(LEADER_MODE*256)-1:0]),
	.patgen_exp_dout(patgen_exp_dout),
	.patgen_data_wr(patgen_data_wr),
	.chkr_fifo_full(w_m2s_chkr_fifo_full),
	.data_out_first(w_data_out_first),			
	.data_out_first_valid(w_data_out_first_valid),    
	.data_out_last(w_data_out_last),           
	.data_out_last_valid(w_data_out_last_valid),     
	.cntuspatt_en(cntuspatt_en),
	.axist_valid(w_m2s_m_tx_axist_tvalid),
	.axist_rdy(w_m2s_m_tx_axist_tready)

);


axi_st_patgen_dual_top #(.LEADER_MODE(FOLLOWER_MODE)) pat_gen_s2m(

	.wr_clk(sl_wr_clk), 
	.rst_n(w_m_wr_rst_n), 
	.patgen_en(f2l_csr_patgen_en), 
	.patgen_sel(f2l_csr_patgen_sel), 
	.patgen_cnt(f2l_csr_patgen_cnt), 
	.patgen_dout(w_s2m_s_tx_axist_tdata[(FOLLOWER_MODE*256)-1:0]),
	.patgen_exp_dout(s2m_patgen_exp_dout),
	.patgen_data_wr(s2m_patgen_data_wr),
	.data_out_first(w_f2l_data_out_first),			
	.data_out_first_valid(w_f2l_data_out_first_valid),    
	.data_out_last(w_f2l_data_out_last),           
	.data_out_last_valid(w_f2l_data_out_last_valid),     
	.chkr_fifo_full(w_s2m_chkr_fifo_full),
	.cntuspatt_en(f2l_cntuspatt_en),
	.axist_valid(w_s2m_s_tx_axist_tvalid),
	.axist_rdy(w_s2m_s_tx_axist_tready)
	
);

  reset_control reset_sync_mgmtclk(
	.clk(mgmt_clk),	
	.rst_n(w_m_wr_rst_n),
	.reset_out(),
	.reset_out_n(mgmtclk_reset_n)
	);

axi_st_csr axist_csr(
	.clk(ms_wr_clk),	
	.rst_n(w_m_wr_rst_n),
	.mgmt_clk(mgmt_clk),
	.mgmt_clk_reset_n(mgmtclk_reset_n),
	.master_address(i_wr_addr),       			// width = 32,       master.address
	.master_readdata(o_master_readdata),    		// width = 32,             .readdata
	.master_read(i_rden),          				//  width = 1,             .read
	.master_write(i_wren),         				//  width = 1,             .write
	.master_writedata(i_wrdata),     			// width = 32,             .writedata  
	.master_readdatavalid(o_master_readdatavalid), 		//  width = 1,             .readdatavalid
	.master_byteenable(),    				//  width = 4,             .byteenable
	.master_waitrequest(o_master_waitreq),   				//  width = 1,             .waitrequest
	.o_delay_x_value(w_delay_x_value),
	.o_delay_y_value(w_delay_y_value),
	.o_delay_z_value(w_delay_z_value),
	.data_out_first(w_data_out_first),
	.data_out_first_valid(w_data_out_first_valid),
	.data_out_last(w_data_out_last),
	.data_out_last_valid(w_data_out_last_valid),
	.f2l_data_out_first(w_f2l_data_out_first),			
	.f2l_data_out_first_valid(w_f2l_data_out_first_valid),    
	.f2l_data_out_last(w_f2l_data_out_last),           
	.f2l_data_out_last_valid(w_f2l_data_out_last_valid),     
	
	.f2l_data_in_first(w_f2l_data_in_first),
	.f2l_data_in_first_valid(w_f2l_data_in_first_valid),
	.f2l_data_in_last(w_f2l_data_in_last),
	.f2l_data_in_last_valid(w_f2l_data_in_last_valid),
	.data_in_first(w_data_in_first),
	.data_in_first_valid(w_data_in_first_valid),
	.data_in_last(w_data_in_last),
	.data_in_last_valid(w_data_in_last_valid),
	.chkr_pass(patchkr_out),
	.f2l_chkr_pass(f2l_patchkr_out),
	.align_error(slave_align_err),
	.f2l_align_error(master_align_err),
	.ldr_tx_online(&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}),
	.ldr_rx_online(master_align_done),
	.fllr_tx_online(&{slave_sl_tx_transfer_en,slave_ms_tx_transfer_en}),
	.fllr_rx_online(slave_align_done),
	.axist_rstn_out(w_axist_rstn),
	.csr_patgen_en(csr_patgen_en),		 
	.csr_patgen_sel(csr_patgen_sel),   
	.csr_patgen_cnt(csr_patgen_cnt),
	.csr_cntuspatt_en(cntuspatt_en),
	.f2l_csr_patgen_en(f2l_csr_patgen_en),
	.f2l_csr_patgen_sel(f2l_csr_patgen_sel),
	.f2l_csr_patgen_cnt(f2l_csr_patgen_cnt),
	.f2l_csr_cntuspatt_en(f2l_cntuspatt_en)
	
	
	);
		
	axi_st_patchkr_f2h_top #(.PATGEN_MODE(LEADER_MODE), .PATCHKR_MODE(FOLLOWER_MODE)) pattern_checker_m2s(
	.rdclk(sl_wr_clk) ,
	.wrclk(ms_wr_clk) ,
	.rst_n(w_s_wr_rst_n) ,
	.patchkr_en(csr_patgen_en) ,
	.patgen_cnt(csr_patgen_cnt) ,
	.patgen_din(patgen_exp_dout),
	.axist_denable(w_m2s_s_enable),
	.patgen_din_wr(patgen_data_wr),
	.cntuspatt_en(cntuspatt_en),
	.axist_tready(w_m2s_s_rx_axist_tready),
	.chkr_fifo_full(w_m2s_chkr_fifo_full),
	.axist_valid(w_m2s_s_rx_axist_tvalid),
	.axist_rcv_data(w_m2s_s_rx_axist_tdata[(FOLLOWER_MODE*256)-1:0]),
	.data_in_first(w_data_in_first),			
	.data_in_first_valid(w_data_in_first_valid),     
	.data_in_last(w_data_in_last),            
	.data_in_last_valid(w_data_in_last_valid),      
	.patchkr_out(patchkr_out)

);

	axi_st_patchkr_h2f_top #(.PATGEN_MODE(FOLLOWER_MODE), .PATCHKR_MODE(LEADER_MODE)) pattern_checker_s2m(
	.rdclk(ms_wr_clk ) ,
	.wrclk(sl_wr_clk) ,
	.rst_n(w_s_wr_rst_n) ,
	.read_pong_in(w_read_pong_out),
	.patchkr_en(f2l_csr_patgen_en) ,
	.patgen_cnt(f2l_csr_patgen_cnt) ,
	.patgen_din(s2m_patgen_exp_dout),
	.patgen_din_wr(s2m_patgen_data_wr),
	.cntuspatt_en(f2l_cntuspatt_en),
	.axist_tready(w_s2m_m_rx_axist_tready),
	.chkr_fifo_full(w_s2m_chkr_fifo_full),
	.axist_valid(w_s2m_m_rx_axist_tvalid),
	.axist_rcv_data(w_s2m_m_rx_axist_tdata[(LEADER_MODE*256)-1:0]),
	.axist_s2m_enable(w_user_s2m_m_enable),
	.f2l_data_in_first(w_f2l_data_in_first),			
	.f2l_data_in_first_valid(w_f2l_data_in_first_valid),     
	.f2l_data_in_last(w_f2l_data_in_last),            
	.f2l_data_in_last_valid(w_f2l_data_in_last_valid),      

	.patchkr_out(f2l_patchkr_out)

);

endmodule
