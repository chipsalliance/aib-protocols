// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: AXIMM AIB top
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////
`timescale 1ps/1ps
`define SIMULATION
module aximm_aib_top#(parameter LEADER_MODE = 1, parameter FOLLOWER_MODE = 2,parameter DATAWIDTH = 40, parameter TOTAL_CHNL_NUM = 24, parameter ADDRWIDTH = 32, parameter DWIDTH = 128)
  (
	input 			i_w_m_wr_rst_n,
	input 			i_w_s_wr_rst_n,
	
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
					
	input  [31:0] 	i_wr_addr, 
	input  [31:0] 	i_wrdata, 
	input 			i_wren, 
	input 			i_rden,
	output			o_master_readdatavalid,
	output [31:0] 	o_master_readdata,	
	
	input 			avmm_clk, 
	input 			osc_clk
	
);


wire [TOTAL_CHNL_NUM-1:0]    			s1_ms_rx_transfer_en;
wire [TOTAL_CHNL_NUM-1:0]    			s1_ms_tx_transfer_en;
wire [TOTAL_CHNL_NUM-1:0]    			s1_sl_rx_transfer_en;
wire [TOTAL_CHNL_NUM-1:0]    			s1_sl_tx_transfer_en;
wire [TOTAL_CHNL_NUM-1:0]    			m1_ms_tx_transfer_en;
wire [TOTAL_CHNL_NUM-1:0]    			m1_ms_rx_transfer_en;
wire [TOTAL_CHNL_NUM-1:0]    			m1_sl_tx_transfer_en;
wire [TOTAL_CHNL_NUM-1:0]    			m1_sl_rx_transfer_en;

wire [TOTAL_CHNL_NUM*DATAWIDTH*8-1:0]	data_in_f;
wire [TOTAL_CHNL_NUM*DATAWIDTH*8-1:0]	data_out_f;
wire [TOTAL_CHNL_NUM*DATAWIDTH*2-1:0]   gen1_data_in_f;
wire [TOTAL_CHNL_NUM*DATAWIDTH*2-1:0]   gen1_data_out_f;
wire 									por_out;
wire [TOTAL_CHNL_NUM*DATAWIDTH*2-1:0]   data_in;
wire [TOTAL_CHNL_NUM*DATAWIDTH*2-1:0]   data_out;
wire [TOTAL_CHNL_NUM-1 : 0]				w_m1_m_fs_rcv_clk;
wire [TOTAL_CHNL_NUM-1 : 0]				w_m1_m_fs_fwd_clk;
wire [TOTAL_CHNL_NUM-1 : 0]				w_s1_m_fs_fwd_clk;

wire 									slave_align_err;
wire 									slave_align_done ;
wire 									master_align_done;


wire [159:0]							w_tx_dout_L_ca2phy;
wire [159:0]							w_tx_dout_F_ca2phy;
wire [159:0]							w_rx_din_L_phy2ca;
wire [159:0]							w_rx_din_F_phy2ca;
wire [31:0]			 					delay_x_value;
wire [31:0]			 					delay_y_value;
wire [31:0]			 					delay_z_value;

wire [7:0] 			  					w_axi_rw_length;
wire [1:0] 			  					w_axi_rw_burst;
wire [2:0] 			  					w_axi_rw_size;
wire [ADDRWIDTH-1:0] 					w_axi_rw_addr;
wire									w_axi_wr;
wire                    				w_axi_rd;

wire [   3:   0]   						w_user_arid          ;
wire [   2:   0]   						w_user_arsize        ;
wire [   7:   0]   						w_user_arlen         ;
wire [   1:   0]   						w_user_arburst       ;
wire [  31:   0]   						w_user_araddr        ;
wire               						w_user_arvalid       ;
wire               						w_user_arready       ;

// aw channel
wire [   3:   0]   						w_user_awid           ;
wire [   2:   0]   						w_user_awsize         ;
wire [   7:   0]   						w_user_awlen          ;
wire [   1:   0]   						w_user_awburst        ;
wire [  31:   0]   						w_user_awaddr         ;
wire               						w_user_awvalid        ;
wire               						w_user_awready        ;
					
// w channel						
wire [   3:   0]   						w_user_wid            ;
wire [ 127:   0]   						w_user_wdata          ;
wire [  15:   0]   						w_user_wstrb          ;
wire               						w_user_wlast          ;
wire               						w_user_wvalid         ;
wire               						w_user_wready         ;
	
// r channel	
wire [   3:   0]   						w_user_rid            ;
wire [ 127:   0]   						w_user_rdata          ;
wire               						w_user_rlast          ;
wire [   1:   0]   						w_user_rresp          ;
wire               						w_user_rvalid         ;
wire               						w_user_rready         ;

// b channel
wire [   3:   0]   						w_user_bid            ;
wire [   1:   0]   						w_user_bresp          ;
wire               						w_user_bvalid         ;
wire               						w_user_bready         ;

wire [3:0]								w_F_user_arid  	;
wire [2:0]								w_F_user_arsize ;
wire [7:0]								w_F_user_arlen  ;
wire [1:0]								w_F_user_arburst;
wire [31:0]								w_F_user_araddr ;
wire 									w_F_user_arvalid;
wire 									w_F_user_arready;
wire [3:0]								w_F_user_awid   ;
wire [2:0]								w_F_user_awsize ;
wire [7:0]								w_F_user_awlen  ;
wire [1:0]								w_F_user_awburst ;
wire [31:0]								w_F_user_awaddr ;
wire 									w_F_user_awvalid ;
wire 									w_F_user_awready ;
wire [3:0]								w_F_user_wid    ;
wire [127:0]							w_F_user_wdata  ;
wire [15:0]								w_F_user_wstrb  ;
wire 									w_F_user_wlast  ;
wire 									w_F_user_wvalid ;
wire 									w_F_user_wready ;
wire [3:0]								w_F_user_rid    ;
wire [127:0]							w_F_user_rdata  ;
wire 									w_F_user_rlast  ;
wire [1:0]								w_F_user_rresp  ;
wire 									w_F_user_rvalid ;
wire 									w_F_user_rready ;
wire [3:0]								w_F_user_bid    ;
wire [1:0]								w_F_user_bresp  ;
wire 									w_F_user_bvalid ;
wire 									w_F_user_bready ;

wire [7:0]								w_mem_wr_addr;
wire [7:0]								w_mem_rd_addr;
wire [127:0]							w_mem_wr_data;
wire [127:0]							w_mem_rd_data;
wire 									w_mem_wr_en  ;
wire 									w_patgen_data_wr ;
wire 									w_read_complete ;
wire 									w_write_complete ;
wire [127:0]							w_patgen_exp_dout;
wire [1:0]								chkr_out;
wire 									master_align_err;
wire [127:0]							w_data_out_first;
wire 									w_data_out_first_valid;
wire [127:0]							w_data_out_last;
wire 									w_data_out_last_valid;
wire [127:0]							w_data_in_first;
wire 									w_data_in_first_valid;
wire [127:0]							w_data_in_last;
wire 									w_data_in_last_valid;



assign w_rx_din_F_phy2ca 		  = gen1_data_out_f[159:0];
								  
assign w_rx_din_L_phy2ca[79:0] 	  = data_out_f[79:0];
assign w_rx_din_L_phy2ca[159:80]  = data_out_f[399:320];

assign data_in	= 'b0;

assign gen1_data_in_f[(DATAWIDTH*2*1)-1 : (DATAWIDTH*2*0)] = w_tx_dout_F_ca2phy[79 : 0];
assign gen1_data_in_f[(DATAWIDTH*2*2)-1 : (DATAWIDTH*2*1)] = w_tx_dout_F_ca2phy[159:80];

genvar i;

generate
	for(i=2; i<24; i=i+1) begin
		assign gen1_data_in_f[(DATAWIDTH*2*(i+1))-1 : (DATAWIDTH*2*i)] = 	'b0;
	end
endgenerate


generate
	for(i=0; i<2; i=i+1) begin
		assign data_in_f[(DATAWIDTH*8)*(i+1)-1:(DATAWIDTH*8)*i] = 	{240'b0,w_tx_dout_L_ca2phy[(DATAWIDTH*2)*(i+1)-1 : (DATAWIDTH*2)*i]};
	end
endgenerate

generate
	for(i=2; i<24; i=i+1) begin
		assign data_in_f[(DATAWIDTH*8)*(i+1)-1:(DATAWIDTH*8)*i] = 	'b0;
	end
endgenerate

top_aib #(.DWIDTH(DATAWIDTH), .TOTAL_CHNL_NUM(TOTAL_CHNL_NUM)) aib_model_inst(
	.avmm_clk(avmm_clk),
	.osc_clk(osc_clk),
	.m1_data_in_f(data_in_f),
    .m1_data_out_f(data_out_f),
    .m1_data_in(data_in), //output data to pad
    .m1_data_out(data_out),
	.m1_m_ns_fwd_clk({TOTAL_CHNL_NUM{ms_fwd_clk}}), //output data clock
    .m1_m_ns_rcv_clk({TOTAL_CHNL_NUM{ms_fwd_clk}}),
    .m1_m_fs_rcv_clk(w_m1_m_fs_rcv_clk),
    .m1_m_fs_fwd_clk(w_m1_m_fs_fwd_clk),
    .m1_m_wr_clk({TOTAL_CHNL_NUM{ms_wr_clk}}),
    .m1_m_rd_clk({TOTAL_CHNL_NUM{ms_rd_clk}}),

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

aximm_d128_h2h_wrapper_top aximm_inst(
  .L_clk_wr              (ms_wr_clk),
  .L_rst_wr_n            (i_w_m_wr_rst_n),
  .por_in				 (por_out),
 
  .init_ar_credit        (8'h00),
  .init_aw_credit        (8'h00),
  .init_w_credit         (8'h00),
  .L_user_arid           (w_user_arid   ),
  .L_user_arsize         (w_user_arsize ),
  .L_user_arlen          (w_user_arlen  ),
  .L_user_arburst        (w_user_arburst),
  .L_user_araddr         (w_user_araddr ),
  .L_user_arvalid        (w_user_arvalid),
  .L_user_arready        (w_user_arready),
  .L_user_awid           (w_user_awid   ),
  .L_user_awsize         (w_user_awsize ),
  .L_user_awlen          (w_user_awlen  ),
  .L_user_awburst        (w_user_awburst),
  .L_user_awaddr         (w_user_awaddr ),
  .L_user_awvalid        (w_user_awvalid),
  .L_user_awready        (w_user_awready),
  .L_user_wid            (w_user_wid   ),
  .L_user_wdata          (w_user_wdata ),
  .L_user_wstrb          (w_user_wstrb ),
  .L_user_wlast          (w_user_wlast ),
  .L_user_wvalid         (w_user_wvalid),
  .L_user_wready         (w_user_wready),
  .L_user_rid            (w_user_rid     ),
  .L_user_rdata          (w_user_rdata   ),
  .L_user_rlast          (w_user_rlast   ),
  .L_user_rresp          (w_user_rresp   ),
  .L_user_rvalid         (w_user_rvalid  ),
  .L_user_rready         (w_user_rready  ),
  .L_user_bid            (w_user_bid    ),
  .L_user_bresp          (w_user_bresp  ),
  .L_user_bvalid         (w_user_bvalid ),
  .L_user_bready         (w_user_bready ),
  .tx_ar_debug_status  	 (),
  .tx_aw_debug_status  	 (),
  .tx_w_debug_status   	 (),
  .rx_r_debug_status   	 (),
  .rx_b_debug_status   	 (),
  .l_gen_mode         	 (1'b0),
  .f_gen_mode         	 (1'b0),

  .i_delay_x_value		 (delay_x_value),
  .i_delay_y_value		 (delay_y_value),
  .i_delay_z_value		 (delay_z_value),
  
  .F_clk_wr              (sl_wr_clk),
  .F_rst_wr_n            (i_w_s_wr_rst_n),

  // Control signals
  
  .init_r_credit       (8'h00),
  .init_b_credit       (8'h00),
  .F_user_arid           (w_F_user_arid    ),
  .F_user_arsize         (w_F_user_arsize  ),
  .F_user_arlen          (w_F_user_arlen   ),
  .F_user_arburst        (w_F_user_arburst ),
  .F_user_araddr         (w_F_user_araddr  ),
  .F_user_arvalid        (w_F_user_arvalid ),
  .F_user_arready        (w_F_user_arready),
  .F_user_awid           (w_F_user_awid   ),
  .F_user_awsize         (w_F_user_awsize ),
  .F_user_awlen          (w_F_user_awlen  ),
  .F_user_awburst        (w_F_user_awburst),
  .F_user_awaddr         (w_F_user_awaddr ),
  .F_user_awvalid        (w_F_user_awvalid),
  .F_user_awready        (w_F_user_awready),
  .F_user_wid            (w_F_user_wid   ),
  .F_user_wdata          (w_F_user_wdata ),
  .F_user_wstrb          (w_F_user_wstrb ),
  .F_user_wlast          (w_F_user_wlast ),
  .F_user_wvalid         (w_F_user_wvalid),
  .F_user_wready         (w_F_user_wready),
  .F_user_rid            (w_F_user_rid   ),
  .F_user_rdata          (w_F_user_rdata ),
  .F_user_rlast          (w_F_user_rlast ),
  .F_user_rresp          (w_F_user_rresp ),
  .F_user_rvalid         (w_F_user_rvalid),
  .F_user_rready         (w_F_user_rready),
  .F_user_bid            (w_F_user_bid   ),
  .F_user_bresp          (w_F_user_bresp ),
  .F_user_bvalid         (w_F_user_bvalid),
  .F_user_bready         (w_F_user_bready), 
  .master_sl_tx_transfer_en(m1_sl_tx_transfer_en[1:0]),
  .master_ms_tx_transfer_en(m1_ms_tx_transfer_en[1:0]),
  .slave_ms_tx_transfer_en(s1_ms_tx_transfer_en[1:0]),
  .slave_sl_tx_transfer_en(s1_sl_tx_transfer_en[1:0]),
  .tx_dout_L_ca2phy      (w_tx_dout_L_ca2phy),//connect
  .tx_dout_F_ca2phy      (w_tx_dout_F_ca2phy),
  .rx_din_L_phy2ca	   	 (w_rx_din_L_phy2ca),
  .rx_din_F_phy2ca	   	 (w_rx_din_F_phy2ca),//connect
  .ca_L_align_done	   	 (master_align_done),
  .ca_L_align_error      (master_align_err),  
  .ca_F_align_done	   	 (slave_align_done),                 
  .ca_F_align_error		 (slave_align_err)
);

aximm_leader_app#(
					.ADDRWIDTH(32),
					.DWIDTH(128)) 
	aximm_leader_user_intf(
	.clk(ms_wr_clk),
	.rst_n(i_w_m_wr_rst_n),
	.axi_rw_length		 (w_axi_rw_length),
	.axi_rw_burst 		 (w_axi_rw_burst ),
	.axi_rw_size  		 (w_axi_rw_size  ),
	.axi_rw_addr  		 (w_axi_rw_addr  ),
	.axi_wr		  		 (w_axi_wr		  ),
	.axi_rd		  		 (w_axi_rd		  ),
	.data_out_first		 (w_data_out_first),
	.data_out_first_valid(w_data_out_first_valid),
	.data_out_last		 (w_data_out_last),
	.data_out_last_valid (w_data_out_last_valid),
	.patgen_data_wr 	 (w_patgen_data_wr ),
	.patgen_exp_dout	 (w_patgen_exp_dout),
	.write_complete		 (w_write_complete),
	.user_arid           (w_user_arid     ),
	.user_arsize         (w_user_arsize   ),
	.user_arlen          (w_user_arlen    ),
	.user_arburst        (w_user_arburst  ),
	.user_araddr         (w_user_araddr   ),
	.user_arvalid        (w_user_arvalid  ),
	.user_arready        (w_user_arready  ),
	.user_awid           (w_user_awid     ),
	.user_awsize         (w_user_awsize   ),
	.user_awlen          (w_user_awlen    ),
	.user_awburst        (w_user_awburst  ),
	.user_awaddr         (w_user_awaddr   ),
	.user_awvalid        (w_user_awvalid  ),
	.user_awready        (w_user_awready  ),
	.user_wid            (w_user_wid   	  ),
	.user_wdata          (w_user_wdata 	  ),
	.user_wstrb          (w_user_wstrb 	  ),
	.user_wlast          (w_user_wlast 	  ),
	.user_wvalid         (w_user_wvalid	  ),
	.user_wready         (w_user_wready	  ),
	
	// r channel
	.user_rid            (w_user_rid   	  ),
	.user_rdata          (w_user_rdata 	  ),
	.user_rlast          (w_user_rlast 	  ),
	.user_rresp          (w_user_rresp 	  ),
	.user_rvalid         (w_user_rvalid	  ),
	.user_rready         (w_user_rready	  ),
	
	.user_bid            (w_user_bid   	  ),
	.user_bresp          (w_user_bresp 	  ),
	.user_bvalid         (w_user_bvalid	  ),
	.user_bready      	 (w_user_bready	  )   


);

aximm_follower_app #(
					.DWIDTH(128), 
					.ADDRWIDTH (32))
	aximm_follower_user_intf(
	.clk(ms_wr_clk),
	.rst_n(i_w_m_wr_rst_n),
	
	.mem_wr_addr(w_mem_wr_addr),
	.mem_wr_data(w_mem_wr_data),
	.mem_wr_en	(w_mem_wr_en  ),
	.mem_rd_data(w_mem_rd_data),
	.mem_rd_addr(w_mem_rd_addr),
	.read_complete(w_read_complete),
	.data_in_first(w_data_in_first),
	.data_in_first_valid(w_data_in_first_valid),
	.data_in_last(w_data_in_last),
	.data_in_last_valid(w_data_in_last_valid),
	
	
	.F_user_arid           (w_F_user_arid   ),
	.F_user_arsize         (w_F_user_arsize ),
	.F_user_arlen          (w_F_user_arlen  ),
	.F_user_arburst        (w_F_user_arburst),
	.F_user_araddr         (w_F_user_araddr ),
	.F_user_arvalid        (w_F_user_arvalid),
	.F_user_arready        (w_F_user_arready),

	// aw channel
	.F_user_awid           (w_F_user_awid   ),
	.F_user_awsize         (w_F_user_awsize ),
	.F_user_awlen          (w_F_user_awlen  ),
	.F_user_awburst        (w_F_user_awburst),
	.F_user_awaddr         (w_F_user_awaddr ),
	.F_user_awvalid        (w_F_user_awvalid),
	.F_user_awready        (w_F_user_awready),
	
	// w channel
	.user_wid              (w_F_user_wid   ),
	.user_wdata            (w_F_user_wdata ),
	.user_wstrb            (w_F_user_wstrb ),
	.user_wlast            (w_F_user_wlast ),
	.user_wvalid           (w_F_user_wvalid),
	.user_wready           (w_F_user_wready),
	
	// r channel
	.F_user_rid            (w_F_user_rid   ),
	.F_user_rdata          (w_F_user_rdata ),
	.F_user_rlast          (w_F_user_rlast ),
	.F_user_rresp          (w_F_user_rresp ),
	.F_user_rvalid         (w_F_user_rvalid),
	.F_user_rready         (w_F_user_rready),
	
	// b channel
	.F_user_bid            (w_F_user_bid   ),
	.F_user_bresp          (w_F_user_bresp ),
	.F_user_bvalid         (w_F_user_bvalid),
	.F_user_bready         (w_F_user_bready)   


);

syncfifo_mem1r1w
   ram_mem(/*AUTOARG*/
   //Outputs
   .rddata(w_mem_rd_data),
   //Inputs
   .clk_write(ms_wr_clk), 
   .clk_read(ms_wr_clk), 
   .rst_write_n(i_w_m_wr_rst_n), 
   .rst_read_n(i_w_m_wr_rst_n), 
   .rdaddr(w_mem_rd_addr), 
   .wraddr(w_mem_wr_addr), 
   .wrdata(w_mem_wr_data), 
   .wrstrobe(w_mem_wr_en)
   );
   
   defparam ram_mem.FIFO_WIDTH_WID = 128;
   defparam ram_mem.FIFO_DEPTH_WID = 256;

axi_mm_patchkr_top 
aximm_patchkr(

	.rdclk (ms_wr_clk),
	.wrclk (ms_wr_clk),
	.rst_n (i_w_m_wr_rst_n),
	.patchkr_en (w_axi_wr),
	.patgen_cnt (8'h80),
	.patgen_din(w_patgen_exp_dout),
	.patgen_din_wr(w_patgen_data_wr),
	.cntuspatt_en(1'b0),
	.chkr_fifo_full(),
	.axist_valid(w_F_user_rvalid),
	.axist_rcv_data(w_F_user_rdata),
	.axist_tready(w_F_user_rready),
	.patchkr_out(chkr_out)

);

axi_mm_csr u_axi_mm_csr(
	.clk(ms_wr_clk),	
	.rst_n(i_w_m_wr_rst_n),

	.master_address(i_wr_addr),      
    .master_readdata(o_master_readdata),     
    .master_read(i_rden),         
    .master_write(i_wren),        
    .master_writedata(i_wrdata),    
    .master_waitrequest(),  
    .master_readdatavalid(o_master_readdatavalid),
    .master_byteenable(),   
	                        
	.data_out_first		 (w_data_out_first		 ),						
	.data_out_first_valid(w_data_out_first_valid),						
	.data_out_last		 (w_data_out_last		 ),						
	.data_out_last_valid (w_data_out_last_valid ),	
	.data_in_first(w_data_in_first),
    .data_in_first_valid(w_data_in_first_valid),
    .data_in_last(w_data_in_last),
	.data_in_last_valid(w_data_in_last_valid),
	.o_delay_x_value(delay_x_value),     		
	.o_delay_y_value(delay_y_value),             
	.o_delay_z_value(delay_z_value),             
	                                
	.chkr_pass(chkr_out),                   
	.align_error(slave_align_err),                 
	.f2l_align_error(master_align_err),                 
	.ldr_tx_online(&{m1_sl_tx_transfer_en[1:0],m1_ms_tx_transfer_en[1:0]}),
	.ldr_rx_online(master_align_done),
	.fllr_tx_online(&{s1_sl_tx_transfer_en[1:0],s1_ms_tx_transfer_en[1:0]}),
	.fllr_rx_online(slave_align_done),
	.read_complete(w_read_complete),
	.write_complete(w_write_complete),
	
	.axist_rstn_out(w_axist_rstn),
	
	.aximm_wr(w_axi_wr),
	.aximm_rd(w_axi_rd),
	.aximm_rw_length(w_axi_rw_length),
	.aximm_rw_burst(w_axi_rw_burst),
	.aximm_rw_size(w_axi_rw_size),
	.aximm_rw_addr(w_axi_rw_addr)	


);

endmodule