// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: AXIMM half to half wrapper
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////
module aximm_d128_h2h_wrapper_top#(parameter AXI_CHNL_NUM = 1, parameter SYNC_FIFO = 0)(
  input  logic               L_clk_wr              ,
  input  logic               L_rst_wr_n            ,
  input  logic               por_in            ,
  input [1:0]		     lane_clk_a,
  input [1:0]		     lane_clk_b,
  input  logic [7:0]         init_ar_credit      ,
  input  logic [7:0]         init_aw_credit      ,
  input  logic [7:0]         init_w_credit       ,
  input 		     usermode_en,
  // ar channel
  input  logic [   3:   0]   L_user_arid           ,
  input  logic [   2:   0]   L_user_arsize         ,
  input  logic [   7:   0]   L_user_arlen          ,
  input  logic [   1:   0]   L_user_arburst        ,
  input  logic [  31:   0]   L_user_araddr         ,
  input  logic               L_user_arvalid        ,
  output logic               L_user_arready        ,

  // aw channel
  input  logic [   3:   0]   L_user_awid           ,
  input  logic [   2:   0]   L_user_awsize         ,
  input  logic [   7:   0]   L_user_awlen          ,
  input  logic [   1:   0]   L_user_awburst        ,
  input  logic [  31:   0]   L_user_awaddr         ,
  input  logic               L_user_awvalid        ,
  output logic               L_user_awready        ,

  // w channel
  input  logic [   3:   0]   L_user_wid            ,
  input  logic [ (64*AXI_CHNL_NUM)-1:   0]   L_user_wdata          ,
  input  logic [  15:   0]   L_user_wstrb          ,
  input  logic               L_user_wlast          ,
  input  logic               L_user_wvalid         ,
  output logic               L_user_wready         ,

  // r channel
  output logic [   3:   0]   L_user_rid            ,
  output logic [ (64*AXI_CHNL_NUM)-1:   0]   L_user_rdata          ,
  output logic               L_user_rlast          ,
  output logic [   1:   0]   L_user_rresp          ,
  output logic               L_user_rvalid         ,
  input  logic               L_user_rready         ,

  // b channel
  output logic [   3:   0]   L_user_bid            ,
  output logic [   1:   0]   L_user_bresp          ,
  output logic               L_user_bvalid         ,
  input  logic               L_user_bready         ,

  // Debug Status Outputs
  output logic [31:0]        tx_ar_debug_status  ,
  output logic [31:0]        tx_aw_debug_status  ,
  output logic [31:0]        tx_w_debug_status   ,
  output logic [31:0]        rx_r_debug_status   ,
  output logic [31:0]        rx_b_debug_status   ,

  // Configuration
  input  logic               l_gen_mode         ,
  input  logic               f_gen_mode         ,


	
  input [31:0]		     i_delay_x_value,
  input [31:0]		     i_delay_y_value,
  input [31:0]		     i_delay_z_value,
  
   input  logic              F_clk_wr              ,
   input  logic              F_rst_wr_n            ,

  // Control signals
  input  logic [7:0]         init_r_credit       ,
  input  logic [7:0]         init_b_credit       ,

  
  output logic [   3:   0]   F_user_arid           ,
  output logic [   2:   0]   F_user_arsize         ,
  output logic [   7:   0]   F_user_arlen          ,
  output logic [   1:   0]   F_user_arburst        ,
  output logic [  31:   0]   F_user_araddr         ,
  output logic               F_user_arvalid        ,
  input  logic               F_user_arready        ,

  // aw channel
  output logic [   3:   0]   F_user_awid           ,
  output logic [   2:   0]   F_user_awsize         ,
  output logic [   7:   0]   F_user_awlen          ,
  output logic [   1:   0]   F_user_awburst        ,
  output logic [  31:   0]   F_user_awaddr         ,
  output logic               F_user_awvalid        ,
  input  logic               F_user_awready        ,

  // w channel
  output logic [   3:   0]   F_user_wid            ,
  output logic [ (64*AXI_CHNL_NUM)-1:   0]   F_user_wdata          ,
  output logic [  15:   0]   F_user_wstrb          ,
  output logic               F_user_wlast          ,
  output logic               F_user_wvalid         ,
  input  logic               F_user_wready         ,

  // r channel
  input  logic [   3:   0]   F_user_rid            ,
  input  logic [ (64*AXI_CHNL_NUM)-1:   0]   F_user_rdata          ,
  input  logic               F_user_rlast          ,
  input  logic [   1:   0]   F_user_rresp          ,
  input  logic               F_user_rvalid         ,
  output logic               F_user_rready         ,

  // b channel
  input  logic [   3:   0]   F_user_bid            ,
  input  logic [   1:   0]   F_user_bresp          ,
  input  logic               F_user_bvalid         ,
  output logic               F_user_bready         , 

  input [1:0]		     master_sl_tx_transfer_en,
  input [1:0]		     master_ms_tx_transfer_en,
  input [1:0]		     slave_ms_tx_transfer_en,
  input [1:0]		     slave_sl_tx_transfer_en,

  output  [ (80*AXI_CHNL_NUM)-1 :  0]	 tx_dout_L_ca2phy      ,
  output  [ (80*AXI_CHNL_NUM)-1 :  0]	 tx_dout_F_ca2phy      ,
  input  [ (80*AXI_CHNL_NUM)-1 :  0]	 rx_din_L_phy2ca	   ,
  input  [ (80*AXI_CHNL_NUM)-1 :  0]	 rx_din_F_phy2ca	   ,
  output 		     ca_L_align_done	   ,
  output 		     ca_L_align_error      ,
  output 		     ca_F_align_done	   ,
  output 		     ca_F_align_error
);


`define CA_TX_STB_INTV	    16'd24
`define CA_RX_STB_INTV	    16'd24


parameter FULL          = 4'h1;
parameter HALF          = 4'h2;
parameter QUARTER       = 4'h4;

parameter MASTER_RATE 	= HALF;
parameter SLAVE_RATE  	= HALF;

wire [(AXI_CHNL_NUM * 80)-1 : 0] tx_phy_L_ll2ca;
wire [(AXI_CHNL_NUM * 80)-1 : 0] tx_phy_F_ll2ca;
wire [(AXI_CHNL_NUM * 80)-1 : 0] rx_dout_F_ca2ll;
wire [(AXI_CHNL_NUM * 80)-1 : 0] rx_dout_L_ca2ll;

reg [15:0] m_delay_x_value_reg1;
reg [15:0] m_delay_x_value_reg2;
reg [15:0] m_delay_y_value_reg1;
reg [15:0] m_delay_y_value_reg2;
reg [15:0] m_delay_z_value_reg1;
reg [15:0] m_delay_z_value_reg2;

reg [15:0] s_delay_x_value_reg1;
reg [15:0] s_delay_x_value_reg2;
reg [15:0] s_delay_y_value_reg1;
reg [15:0] s_delay_y_value_reg2;
reg [15:0] s_delay_z_value_reg1;
reg [15:0] s_delay_z_value_reg2;

wire [15:0] MASTER_DELAY_X_VALUE;
wire [15:0] MASTER_DELAY_Y_VALUE;
wire [15:0] MASTER_DELAY_Z_VALUE;

wire [15:0] SLAVE_DELAY_X_VALUE ;
wire [15:0] SLAVE_DELAY_Y_VALUE ;
wire [15:0] SLAVE_DELAY_Z_VALUE ;


logic                   m_wr_rst_n;
logic                   s_wr_rst_n;

assign m_wr_rst_n = ~por_in & L_rst_wr_n;
assign s_wr_rst_n = ~por_in & F_rst_wr_n;



always@(posedge L_clk_wr)
	if(!m_wr_rst_n)
	begin
		m_delay_x_value_reg1	<= 'b0;
		m_delay_x_value_reg2	<= 'b0;
		m_delay_y_value_reg1	<= 'b0;
		m_delay_y_value_reg2	<= 'b0;
		m_delay_z_value_reg1	<= 'b0;
		m_delay_z_value_reg2	<= 'b0;
	end
	else
	begin
		m_delay_x_value_reg1	<= i_delay_x_value;
	    	m_delay_x_value_reg2    <= m_delay_x_value_reg1;
		
		m_delay_y_value_reg1	<= i_delay_y_value;
	    	m_delay_y_value_reg2    <= m_delay_y_value_reg1;
		
		m_delay_z_value_reg1	<= i_delay_z_value;
	    	m_delay_z_value_reg2    <= m_delay_z_value_reg1;
		
	end

always@(posedge F_clk_wr)
	if(!s_wr_rst_n)
	begin
		s_delay_x_value_reg1	<= 'b0;
		s_delay_x_value_reg2	<= 'b0;
		s_delay_y_value_reg1	<= 'b0;
		s_delay_y_value_reg2	<= 'b0;
		s_delay_z_value_reg1	<= 'b0;
		s_delay_z_value_reg2	<= 'b0;
	end
	else
	begin
		s_delay_x_value_reg1	<= i_delay_x_value;
	    	s_delay_x_value_reg2    <= s_delay_x_value_reg1;
		
		s_delay_y_value_reg1	<= i_delay_y_value;
	    	s_delay_y_value_reg2    <= s_delay_y_value_reg1;
		
		s_delay_z_value_reg1	<= i_delay_z_value;
	        s_delay_z_value_reg2    <= s_delay_z_value_reg1;
		
	end

assign MASTER_DELAY_X_VALUE = m_delay_x_value_reg2 / MASTER_RATE;
assign MASTER_DELAY_Y_VALUE = m_delay_y_value_reg2 / MASTER_RATE;
assign MASTER_DELAY_Z_VALUE = m_delay_z_value_reg2 / MASTER_RATE;

assign SLAVE_DELAY_X_VALUE = s_delay_x_value_reg2 / SLAVE_RATE;
assign SLAVE_DELAY_Y_VALUE = s_delay_y_value_reg2 / SLAVE_RATE;
assign SLAVE_DELAY_Z_VALUE = s_delay_z_value_reg2 / SLAVE_RATE;


generate 
if(AXI_CHNL_NUM==1)
begin

assign ca_L_align_done  	= 1'b1;
assign ca_F_align_done  	= 1'b1;
assign ca_L_align_error 	= 1'b0;
assign ca_F_align_error 	= 1'b0;
assign tx_dout_F_ca2phy   	= tx_phy_F_ll2ca;
assign rx_dout_F_ca2ll    	= rx_din_F_phy2ca;
assign tx_dout_L_ca2phy   	= tx_phy_L_ll2ca;
assign rx_dout_L_ca2ll 	  	= rx_din_L_phy2ca;

axi_mm_master_top  aximm_leader(
  .clk_wr              (L_clk_wr ),
  .rst_wr_n            (L_rst_wr_n),
  .tx_online           (&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}),
  .rx_online           (&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}),
  .init_ar_credit      (init_ar_credit),
  .init_aw_credit      (init_aw_credit),
  .init_w_credit       (init_w_credit ),
  .tx_phy0             (tx_phy_L_ll2ca[(1*80)-1:(0*80)]),
  .rx_phy0             (rx_dout_L_ca2ll[(1*80)-1:(0*80)]),
  .user_arid           (L_user_arid    ),
  .user_arsize         (L_user_arsize  ),
  .user_arlen          (L_user_arlen   ),
  .user_arburst        (L_user_arburst ),
  .user_araddr         (L_user_araddr  ),
  .user_arvalid        (L_user_arvalid ),
  .user_arready        (L_user_arready ),
  .user_awid           (L_user_awid   ),
  .user_awsize         (L_user_awsize ),
  .user_awlen          (L_user_awlen  ),
  .user_awburst        (L_user_awburst),
  .user_awaddr         (L_user_awaddr ),
  .user_awvalid        (L_user_awvalid),
  .user_awready        (L_user_awready),
  .user_wid            (L_user_wid     ),
  .user_wdata          (L_user_wdata   ),
  .user_wstrb          (L_user_wstrb[7:0]   ),
  .user_wlast          (L_user_wlast   ),
  .user_wvalid         (L_user_wvalid  ),
  .user_wready         (L_user_wready  ),
  .user_rid            (L_user_rid     ),
  .user_rdata          (L_user_rdata   ),
  .user_rlast          (L_user_rlast   ),
  .user_rresp          (L_user_rresp   ),
  .user_rvalid         (L_user_rvalid  ),
  .user_rready         (L_user_rready  ),
  .user_bid            (L_user_bid     ),
  .user_bresp          (L_user_bresp   ),
  .user_bvalid         (L_user_bvalid  ),
  .user_bready         (L_user_bready  ),
  .tx_ar_debug_status  (),
  .tx_aw_debug_status  (),
  .tx_w_debug_status   (),
  .rx_r_debug_status   (),
  .rx_b_debug_status   (),
  .m_gen2_mode         (l_gen_mode),
  .delay_x_value       (MASTER_DELAY_X_VALUE),
  .delay_y_value       (MASTER_DELAY_Y_VALUE),
  .delay_z_value       (MASTER_DELAY_Z_VALUE)

);

axi_mm_slave_top  aximm_follower(
  .clk_wr            (F_clk_wr  )  ,
  .rst_wr_n          (F_rst_wr_n & usermode_en)  ,
  .tx_online         (&{slave_sl_tx_transfer_en,slave_ms_tx_transfer_en})  ,
  .rx_online         (&{slave_sl_tx_transfer_en,slave_ms_tx_transfer_en})  ,
  .init_r_credit     (init_r_credit)  ,
  .init_b_credit     (init_b_credit)  ,
  .tx_phy0           (tx_phy_F_ll2ca[(1*80)-1:(0*80)])  ,
  .rx_phy0           (rx_dout_F_ca2ll[(1*80)-1:(0*80)])  , 
  
  .user_arid         (F_user_arid    )  ,
  .user_arsize       (F_user_arsize  )  ,
  .user_arlen        (F_user_arlen   )  ,
  .user_arburst      (F_user_arburst )  ,
  .user_araddr       (F_user_araddr  )  ,
  .user_arvalid      (F_user_arvalid )  ,
  .user_arready      (F_user_arready )  ,
  .user_awid         (F_user_awid     )  ,
  .user_awsize       (F_user_awsize   )  ,
  .user_awlen        (F_user_awlen    )  ,
  .user_awburst      (F_user_awburst  )  ,
  .user_awaddr       (F_user_awaddr   )  ,
  .user_awvalid      (F_user_awvalid  )  ,
  .user_awready      (F_user_awready  )  ,
  .user_wid          (F_user_wid   )  ,
  .user_wdata        (F_user_wdata )  ,
  .user_wstrb        (F_user_wstrb[7:0] )  ,
  .user_wlast        (F_user_wlast )  ,
  .user_wvalid       (F_user_wvalid)  ,
  .user_wready       (F_user_wready)  ,
  .user_rid          (F_user_rid   )  ,
  .user_rdata        (F_user_rdata )  ,
  .user_rlast        (F_user_rlast )  ,
  .user_rresp        (F_user_rresp )  ,
  .user_rvalid       (F_user_rvalid)  ,
  .user_rready       (F_user_rready)  ,
  .user_bid          (F_user_bid   )  ,
  .user_bresp        (F_user_bresp )  ,
  .user_bvalid       (F_user_bvalid)  ,
  .user_bready       (F_user_bready)  ,
  .rx_ar_debug_status()  ,
  .rx_aw_debug_status()  ,
  .rx_w_debug_status ()  ,
  .tx_r_debug_status ()  ,
  .tx_b_debug_status ()  ,
  .m_gen2_mode       (f_gen_mode)  ,
  .delay_x_value     (SLAVE_DELAY_X_VALUE)  ,
  .delay_y_value     (SLAVE_DELAY_Y_VALUE)  ,
  .delay_z_value     (SLAVE_DELAY_Z_VALUE)  

);
end
else
begin
axi_mm_master_top  aximm_leader(
  .clk_wr              (L_clk_wr ),
  .rst_wr_n            (L_rst_wr_n),
  .tx_online           (&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}),
  .rx_online           (ca_L_align_done),
  .init_ar_credit      (init_ar_credit),
  .init_aw_credit      (init_aw_credit),
  .init_w_credit       (init_w_credit ),
  .tx_phy0             (tx_phy_L_ll2ca[(1*80)-1:(0*80)]),
  .rx_phy0             (rx_dout_L_ca2ll[(1*80)-1:(0*80)]),
   .tx_phy1             (tx_phy_L_ll2ca[(2*80)-1:(1*80)]),
   .rx_phy1             (rx_dout_L_ca2ll[(2*80)-1:(1*80)]),
  .user_arid           (L_user_arid    ),
  .user_arsize         (L_user_arsize  ),
  .user_arlen          (L_user_arlen   ),
  .user_arburst        (L_user_arburst ),
  .user_araddr         (L_user_araddr  ),
  .user_arvalid        (L_user_arvalid ),
  .user_arready        (L_user_arready ),
  .user_awid           (L_user_awid   ),
  .user_awsize         (L_user_awsize ),
  .user_awlen          (L_user_awlen  ),
  .user_awburst        (L_user_awburst),
  .user_awaddr         (L_user_awaddr ),
  .user_awvalid        (L_user_awvalid),
  .user_awready        (L_user_awready),
  .user_wid            (L_user_wid     ),
  .user_wdata          (L_user_wdata   ),
  .user_wstrb          (L_user_wstrb   ),
  .user_wlast          (L_user_wlast   ),
  .user_wvalid         (L_user_wvalid  ),
  .user_wready         (L_user_wready  ),
  .user_rid            (L_user_rid     ),
  .user_rdata          (L_user_rdata   ),
  .user_rlast          (L_user_rlast   ),
  .user_rresp          (L_user_rresp   ),
  .user_rvalid         (L_user_rvalid  ),
  .user_rready         (L_user_rready  ),
  .user_bid            (L_user_bid     ),
  .user_bresp          (L_user_bresp   ),
  .user_bvalid         (L_user_bvalid  ),
  .user_bready         (L_user_bready  ),
  .tx_ar_debug_status  (),
  .tx_aw_debug_status  (),
  .tx_w_debug_status   (),
  .rx_r_debug_status   (),
  .rx_b_debug_status   (),
  .m_gen2_mode         (l_gen_mode),
  .delay_x_value       (MASTER_DELAY_X_VALUE),
  .delay_y_value       (MASTER_DELAY_Y_VALUE),
  .delay_z_value       (MASTER_DELAY_Z_VALUE)

);

axi_mm_slave_top  aximm_follower(
  .clk_wr            (F_clk_wr  )  ,
  .rst_wr_n          (F_rst_wr_n & usermode_en)  ,
  .tx_online         (&{slave_sl_tx_transfer_en,slave_ms_tx_transfer_en})  ,
  .rx_online         (ca_F_align_done)  ,
  .init_r_credit     (init_r_credit)  ,
  .init_b_credit     (init_b_credit)  ,
  .tx_phy0           (tx_phy_F_ll2ca[(1*80)-1:(0*80)])  ,
  .rx_phy0           (rx_dout_F_ca2ll[(1*80)-1:(0*80)])  , 
  
   .tx_phy1           (tx_phy_F_ll2ca[(2*80)-1:(1*80)])  ,
   .rx_phy1           (rx_dout_F_ca2ll[(2*80)-1:(1*80)])  ,
  
  .user_arid         (F_user_arid    )  ,
  .user_arsize       (F_user_arsize  )  ,
  .user_arlen        (F_user_arlen   )  ,
  .user_arburst      (F_user_arburst )  ,
  .user_araddr       (F_user_araddr  )  ,
  .user_arvalid      (F_user_arvalid )  ,
  .user_arready      (F_user_arready )  ,
  .user_awid         (F_user_awid     )  ,
  .user_awsize       (F_user_awsize   )  ,
  .user_awlen        (F_user_awlen    )  ,
  .user_awburst      (F_user_awburst  )  ,
  .user_awaddr       (F_user_awaddr   )  ,
  .user_awvalid      (F_user_awvalid  )  ,
  .user_awready      (F_user_awready  )  ,
  .user_wid          (F_user_wid   )  ,
  .user_wdata        (F_user_wdata )  ,
  .user_wstrb        (F_user_wstrb )  ,
  .user_wlast        (F_user_wlast )  ,
  .user_wvalid       (F_user_wvalid)  ,
  .user_wready       (F_user_wready)  ,
  .user_rid          (F_user_rid   )  ,
  .user_rdata        (F_user_rdata )  ,
  .user_rlast        (F_user_rlast )  ,
  .user_rresp        (F_user_rresp )  ,
  .user_rvalid       (F_user_rvalid)  ,
  .user_rready       (F_user_rready)  ,
  .user_bid          (F_user_bid   )  ,
  .user_bresp        (F_user_bresp )  ,
  .user_bvalid       (F_user_bvalid)  ,
  .user_bready       (F_user_bready)  ,
  .rx_ar_debug_status()  ,
  .rx_aw_debug_status()  ,
  .rx_w_debug_status ()  ,
  .tx_r_debug_status ()  ,
  .tx_b_debug_status ()  ,
  .m_gen2_mode       (f_gen_mode)  ,
  .delay_x_value     (SLAVE_DELAY_X_VALUE)  ,
  .delay_y_value     (SLAVE_DELAY_Y_VALUE)  ,
  .delay_z_value     (SLAVE_DELAY_Z_VALUE)  

);
end
endgenerate

 generate
  if (AXI_CHNL_NUM == 2)
   begin

 ca 
   #(
     .NUM_CHANNELS(2),
     .BITS_PER_CHANNEL(80),
     .AD_WIDTH (8),
     .SYNC_FIFO(SYNC_FIFO)
     )
  ca_leader(
    .lane_clk(lane_clk_a),
    .com_clk(L_clk_wr),
    .rst_n(L_rst_wr_n),
    .tx_online(&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}),
    .rx_online(&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}),
    .tx_stb_en(1'b1),
    .tx_stb_rcvr(1'b0),
    .align_fly(1'b1),
    .rden_dly(3'b0),
    .delay_x_value(MASTER_DELAY_X_VALUE),
    .delay_z_value(MASTER_DELAY_Z_VALUE),
    .tx_stb_wd_sel(8'h1),
    .tx_stb_bit_sel(40'h0000000080),
    .tx_stb_intv((`CA_TX_STB_INTV*SLAVE_RATE)/MASTER_RATE),
    .rx_stb_wd_sel(8'h01),
    .rx_stb_bit_sel(40'h0000000080),
    .rx_stb_intv(`CA_RX_STB_INTV),
    .tx_din(tx_phy_L_ll2ca),
    .tx_dout(tx_dout_L_ca2phy),
    .rx_din(rx_din_L_phy2ca),
    .rx_dout(rx_dout_L_ca2ll),
    .align_done(ca_L_align_done),
    .align_err(ca_L_align_error),
    .tx_stb_pos_err(),
    .tx_stb_pos_coding_err(),
    .rx_stb_pos_err(),
    .rx_stb_pos_coding_err(),
    .fifo_full_val  (6'd08),
    .fifo_pfull_val (6'd04),
    .fifo_empty_val (3'd0),
    .fifo_pempty_val(3'd2),
    .fifo_full(),
    .fifo_pfull(),
    .fifo_empty(),
    .fifo_pempty()
    );

 ca 
   #(
   .NUM_CHANNELS(2),
     .BITS_PER_CHANNEL(80),
     .AD_WIDTH (8),
     .SYNC_FIFO(SYNC_FIFO)
     )
   ca_follower(
    .lane_clk(lane_clk_b),
    .com_clk(F_clk_wr),
    .rst_n(F_rst_wr_n & usermode_en),
    .tx_online(&{slave_sl_tx_transfer_en,slave_ms_tx_transfer_en}),
    .rx_online(&{slave_sl_tx_transfer_en,slave_ms_tx_transfer_en}),
    .tx_stb_en(1'b1),
    .tx_stb_rcvr(1'b0),
    .align_fly(1'b1),
    .rden_dly(3'b0),
    .delay_x_value(SLAVE_DELAY_X_VALUE),
    .delay_z_value(SLAVE_DELAY_Z_VALUE),
    .tx_stb_wd_sel(8'h01),
    .tx_stb_bit_sel(40'h0000000080),
    .tx_stb_intv((`CA_RX_STB_INTV*MASTER_RATE)/SLAVE_RATE),
    .rx_stb_wd_sel(8'h01),
    .rx_stb_bit_sel(40'h0000000080),
   .rx_stb_intv(`CA_TX_STB_INTV),
    .tx_din(tx_phy_F_ll2ca),
    .tx_dout(tx_dout_F_ca2phy),
    .rx_din(rx_din_F_phy2ca),
    .rx_dout(rx_dout_F_ca2ll),
   .align_done(ca_F_align_done),
    .align_err(ca_F_align_error),
    .tx_stb_pos_err(),
    .tx_stb_pos_coding_err(),
    .rx_stb_pos_err(),
    .rx_stb_pos_coding_err(),
    .fifo_full_val(6'd08),
    .fifo_pfull_val(6'd4),
    .fifo_empty_val(3'd0),
    .fifo_pempty_val(3'd2),
    .fifo_full(),
    .fifo_pfull(),
    .fifo_empty(),
    .fifo_pempty()
    );
end
endgenerate

endmodule
