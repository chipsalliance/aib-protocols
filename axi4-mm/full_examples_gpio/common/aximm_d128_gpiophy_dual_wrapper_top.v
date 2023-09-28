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
module aximm_d128_gpiophy_dual_wrapper_top#(parameter AXI_TDATA_FACTOR = 1, parameter PHY_WIDTH = 20)(
  input  logic               L_clk_wr              ,
  input  logic               L_rst_wr_n            ,
  input  logic               por_in            ,

  input  logic [7:0]         init_ar_m2s_credit  ,
  input  logic [7:0]         init_aw_m2s_credit  ,
  input  logic [7:0]         init_w_m2s_credit   ,
  input  logic [7:0]         init_r_s2m_credit   ,
  input  logic [7:0]         init_b_s2m_credit   ,
	
  input 		     usermode_en,
  // ar channel
  input  logic [   3:   0]   L_user_m2s_arid           ,
  input  logic [   2:   0]   L_user_m2s_arsize         ,
  input  logic [   7:   0]   L_user_m2s_arlen          ,
  input  logic [   1:   0]   L_user_m2s_arburst        ,
  input  logic [  31:   0]   L_user_m2s_araddr         ,
  input  logic               L_user_m2s_arvalid        ,
  output logic               L_user_m2s_arready        ,

  // aw channel
  input  logic [   3:   0]   L_user_m2s_awid           ,
  input  logic [   2:   0]   L_user_m2s_awsize         ,
  input  logic [   7:   0]   L_user_m2s_awlen          ,
  input  logic [   1:   0]   L_user_m2s_awburst        ,
  input  logic [  31:   0]   L_user_m2s_awaddr         ,
  input  logic               L_user_m2s_awvalid        ,
  output logic               L_user_m2s_awready        ,

  // w channel
  input  logic [   3:   0]   L_user_m2s_wid            ,
  input  logic [ (64*AXI_TDATA_FACTOR)-1:   0]   L_user_m2s_wdata          ,
  input  logic [  15:   0]   L_user_m2s_wstrb          ,
  input  logic               L_user_m2s_wlast          ,
  input  logic               L_user_m2s_wvalid         ,
  output logic               L_user_m2s_wready         ,

  // r channel
  output logic [   3:   0]   L_user_m2s_rid            ,
  output logic [ (64*AXI_TDATA_FACTOR)-1:   0]   L_user_m2s_rdata          ,
  output logic               L_user_m2s_rlast          ,
  output logic [   1:   0]   L_user_m2s_rresp          ,
  output logic               L_user_m2s_rvalid         ,
  input  logic               L_user_m2s_rready         ,

  // b channel
  output logic [   3:   0]   L_user_m2s_bid            ,
  output logic [   1:   0]   L_user_m2s_bresp          ,
  output logic               L_user_m2s_bvalid         ,
  input  logic               L_user_m2s_bready         ,

  // ar channel
  output  logic [   3:   0]   L_user_s2m_arid           ,
  output  logic [   2:   0]   L_user_s2m_arsize         ,
  output  logic [   7:   0]   L_user_s2m_arlen          ,
  output  logic [   1:   0]   L_user_s2m_arburst        ,
  output  logic [  31:   0]   L_user_s2m_araddr         ,
  output  logic               L_user_s2m_arvalid        ,
  input logic               L_user_s2m_arready        ,

  // aw channel
  output  logic [   3:   0]   L_user_s2m_awid           ,
  output  logic [   2:   0]   L_user_s2m_awsize         ,
  output  logic [   7:   0]   L_user_s2m_awlen          ,
  output  logic [   1:   0]   L_user_s2m_awburst        ,
  output  logic [  31:   0]   L_user_s2m_awaddr         ,
  output  logic               L_user_s2m_awvalid        ,
  input logic               L_user_s2m_awready        ,

  // w channel
  output  logic [   3:   0]   L_user_s2m_wid            ,
  output  logic [ (64*AXI_TDATA_FACTOR)-1:   0]   L_user_s2m_wdata          ,
  output  logic [  15:   0]   L_user_s2m_wstrb          ,
  output  logic               L_user_s2m_wlast          ,
  output  logic               L_user_s2m_wvalid         ,
  input logic               L_user_s2m_wready         ,

  // r channel
  input logic [   3:   0]   L_user_s2m_rid            ,
  input logic [ (64*AXI_TDATA_FACTOR)-1:   0]   L_user_s2m_rdata          ,
  input logic               L_user_s2m_rlast          ,
  input logic [   1:   0]   L_user_s2m_rresp          ,
  input logic               L_user_s2m_rvalid         ,
  output  logic               L_user_s2m_rready         ,

  // b channel
  input logic [   3:   0]   L_user_s2m_bid            ,
  input logic [   1:   0]   L_user_s2m_bresp          ,
  input logic               L_user_s2m_bvalid         ,
  output  logic               L_user_s2m_bready         ,




  // Debug Status Outputs
  output logic [31:0]        tx_ar_m2s_debug_status,
  output logic [31:0]        tx_aw_m2s_debug_status,
  output logic [31:0]        tx_w_m2s_debug_status,
  output logic [31:0]        rx_r_m2s_debug_status,
  output logic [31:0]        rx_b_m2s_debug_status,
  output logic [31:0]        rx_ar_s2m_debug_status,
  output logic [31:0]        rx_aw_s2m_debug_status,
  output logic [31:0]        rx_w_s2m_debug_status,
  output logic [31:0]        tx_r_s2m_debug_status,
  output logic [31:0]        tx_b_s2m_debug_status,

  // Configuration
  input  logic               l_gen_mode         ,
  input  logic               f_gen_mode         ,


	
  input [31:0]		     i_delay_x_value,
  input [31:0]		     i_delay_y_value,
  input [31:0]		     i_delay_z_value,
  
   input  logic              F_clk_wr              ,
   input  logic              F_rst_wr_n            ,

  // Control signals
  input  logic [7:0]         init_r_m2s_credit   ,
  input  logic [7:0]         init_b_m2s_credit   ,
  input  logic [7:0]         init_ar_s2m_credit  ,
  input  logic [7:0]         init_aw_s2m_credit  ,
  input  logic [7:0]         init_w_s2m_credit   ,
  
  output logic [   3:   0]   F_user_m2s_arid           ,
  output logic [   2:   0]   F_user_m2s_arsize         ,
  output logic [   7:   0]   F_user_m2s_arlen          ,
  output logic [   1:   0]   F_user_m2s_arburst        ,
  output logic [  31:   0]   F_user_m2s_araddr         ,
  output logic               F_user_m2s_arvalid        ,
  input  logic               F_user_m2s_arready        ,

  // aw channel
  output logic [   3:   0]   F_user_m2s_awid           ,
  output logic [   2:   0]   F_user_m2s_awsize         ,
  output logic [   7:   0]   F_user_m2s_awlen          ,
  output logic [   1:   0]   F_user_m2s_awburst        ,
  output logic [  31:   0]   F_user_m2s_awaddr         ,
  output logic               F_user_m2s_awvalid        ,
  input  logic               F_user_m2s_awready        ,

  // w channel
  output logic [   3:   0]   F_user_m2s_wid            ,
  output logic [ (64*AXI_TDATA_FACTOR)-1:   0]   F_user_m2s_wdata          ,
  output logic [  15:   0]   F_user_m2s_wstrb          ,
  output logic               F_user_m2s_wlast          ,
  output logic               F_user_m2s_wvalid         ,
  input  logic               F_user_m2s_wready         ,

  // r channel
  input  logic [   3:   0]   F_user_m2s_rid            ,
  input  logic [ (64*AXI_TDATA_FACTOR)-1:   0]   F_user_m2s_rdata          ,
  input  logic               F_user_m2s_rlast          ,
  input  logic [   1:   0]   F_user_m2s_rresp          ,
  input  logic               F_user_m2s_rvalid         ,
  output logic               F_user_m2s_rready         ,

  // b channel
  input  logic [   3:   0]   F_user_m2s_bid            ,
  input  logic [   1:   0]   F_user_m2s_bresp          ,
  input  logic               F_user_m2s_bvalid         ,
  output logic               F_user_m2s_bready         , 

  
  input logic [   3:   0]   F_user_s2m_arid           ,
  input logic [   2:   0]   F_user_s2m_arsize         ,
  input logic [   7:   0]   F_user_s2m_arlen          ,
  input logic [   1:   0]   F_user_s2m_arburst        ,
  input logic [  31:   0]   F_user_s2m_araddr         ,
  input logic               F_user_s2m_arvalid        ,
  output  logic               F_user_s2m_arready        ,

  // aw channel
  input logic [   3:   0]   F_user_s2m_awid           ,
  input logic [   2:   0]   F_user_s2m_awsize         ,
  input logic [   7:   0]   F_user_s2m_awlen          ,
  input logic [   1:   0]   F_user_s2m_awburst        ,
  input logic [  31:   0]   F_user_s2m_awaddr         ,
  input logic               F_user_s2m_awvalid        ,
  output  logic               F_user_s2m_awready        ,

  // w channel
  input logic [   3:   0]   F_user_s2m_wid            ,
  input logic [ (64*AXI_TDATA_FACTOR)-1:   0]   F_user_s2m_wdata          ,
  input logic [  15:   0]   F_user_s2m_wstrb          ,
  input logic               F_user_s2m_wlast          ,
  input logic               F_user_s2m_wvalid         ,
  output  logic               F_user_s2m_wready         ,

  // r channel
  output  logic [   3:   0]   F_user_s2m_rid            ,
  output  logic [ (64*AXI_TDATA_FACTOR)-1:   0]   F_user_s2m_rdata          ,
  output  logic               F_user_s2m_rlast          ,
  output  logic [   1:   0]   F_user_s2m_rresp          ,
  output  logic               F_user_s2m_rvalid         ,
  input logic               F_user_s2m_rready         ,

  // b channel
  output  logic [   3:   0]   F_user_s2m_bid            ,
  output  logic [   1:   0]   F_user_s2m_bresp          ,
  output  logic               F_user_s2m_bvalid         ,
  input logic               F_user_s2m_bready         , 




  input [1:0]		     master_sl_tx_transfer_en,
  input [1:0]		     master_ms_tx_transfer_en,
  input [1:0]		     slave_ms_tx_transfer_en,
  input [1:0]		     slave_sl_tx_transfer_en

);


parameter FULL          = 4'h1;
parameter HALF          = 4'h2;
parameter QUARTER       = 4'h4;

parameter MASTER_RATE 	= HALF;
parameter SLAVE_RATE  	= HALF;

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

wire [PHY_WIDTH-1:0] tx_phy0_ldr;
wire [PHY_WIDTH-1:0] rx_phy0_ldr;


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


axi_mm_master_top  aximm_leader(
  .clk_wr              (L_clk_wr ),
  .rst_wr_n            (L_rst_wr_n),
  .tx_online           (&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}),
  .rx_online           (&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}),
  .init_ar_m2s_credit      (init_ar_m2s_credit),
  .init_aw_m2s_credit      (init_aw_m2s_credit),
  .init_w_m2s_credit       (init_w_m2s_credit ),
  .init_r_s2m_credit       (init_r_s2m_credit ),
  .init_b_s2m_credit       (init_b_s2m_credit ),
  .tx_phy0             (tx_phy0_ldr),
  .rx_phy0             (rx_phy0_ldr),
  .user_m2s_arid           (L_user_m2s_arid    ),
  .user_m2s_arsize         (L_user_m2s_arsize  ),
  .user_m2s_arlen          (L_user_m2s_arlen   ),
  .user_m2s_arburst        (L_user_m2s_arburst ),
  .user_m2s_araddr         (L_user_m2s_araddr  ),
  .user_m2s_arvalid        (L_user_m2s_arvalid ),
  .user_m2s_arready        (L_user_m2s_arready ),
  .user_m2s_awid           (L_user_m2s_awid   ),
  .user_m2s_awsize         (L_user_m2s_awsize ),
  .user_m2s_awlen          (L_user_m2s_awlen  ),
  .user_m2s_awburst        (L_user_m2s_awburst),
  .user_m2s_awaddr         (L_user_m2s_awaddr ),
  .user_m2s_awvalid        (L_user_m2s_awvalid),
  .user_m2s_awready        (L_user_m2s_awready),
  .user_m2s_wid            (L_user_m2s_wid     ),
  .user_m2s_wdata          (L_user_m2s_wdata   ),
  .user_m2s_wstrb          (L_user_m2s_wstrb   ),
  .user_m2s_wlast          (L_user_m2s_wlast   ),
  .user_m2s_wvalid         (L_user_m2s_wvalid  ),
  .user_m2s_wready         (L_user_m2s_wready  ),
  .user_m2s_rid            (L_user_m2s_rid     ),
  .user_m2s_rdata          (L_user_m2s_rdata   ),
  .user_m2s_rlast          (L_user_m2s_rlast   ),
  .user_m2s_rresp          (L_user_m2s_rresp   ),
  .user_m2s_rvalid         (L_user_m2s_rvalid  ),
  .user_m2s_rready         (L_user_m2s_rready  ),
  .user_m2s_bid            (L_user_m2s_bid     ),
  .user_m2s_bresp          (L_user_m2s_bresp   ),
  .user_m2s_bvalid         (L_user_m2s_bvalid  ),
  .user_m2s_bready         (L_user_m2s_bready  ),
  .user_s2m_arid           (L_user_s2m_arid    ),
  .user_s2m_arsize         (L_user_s2m_arsize  ),
  .user_s2m_arlen          (L_user_s2m_arlen   ),
  .user_s2m_arburst        (L_user_s2m_arburst ),
  .user_s2m_araddr         (L_user_s2m_araddr  ),
  .user_s2m_arvalid        (L_user_s2m_arvalid ),
  .user_s2m_arready        (L_user_s2m_arready ),
  .user_s2m_awid           (L_user_s2m_awid   ),
  .user_s2m_awsize         (L_user_s2m_awsize ),
  .user_s2m_awlen          (L_user_s2m_awlen  ),
  .user_s2m_awburst        (L_user_s2m_awburst),
  .user_s2m_awaddr         (L_user_s2m_awaddr ),
  .user_s2m_awvalid        (L_user_s2m_awvalid),
  .user_s2m_awready        (L_user_s2m_awready),
  .user_s2m_wid            (L_user_s2m_wid     ),
  .user_s2m_wdata          (L_user_s2m_wdata   ),
  .user_s2m_wstrb          (L_user_s2m_wstrb   ),
  .user_s2m_wlast          (L_user_s2m_wlast   ),
  .user_s2m_wvalid         (L_user_s2m_wvalid  ),
  .user_s2m_wready         (L_user_s2m_wready  ),
  .user_s2m_rid            (L_user_s2m_rid     ),
  .user_s2m_rdata          (L_user_s2m_rdata   ),
  .user_s2m_rlast          (L_user_s2m_rlast   ),
  .user_s2m_rresp          (L_user_s2m_rresp   ),
  .user_s2m_rvalid         (L_user_s2m_rvalid  ),
  .user_s2m_rready         (L_user_s2m_rready  ),
  .user_s2m_bid            (L_user_s2m_bid     ),
  .user_s2m_bresp          (L_user_s2m_bresp   ),
  .user_s2m_bvalid         (L_user_s2m_bvalid  ),
  .user_s2m_bready         (L_user_s2m_bready  ),	
  .tx_ar_m2s_debug_status  (),
  .tx_aw_m2s_debug_status  (),
  .tx_w_m2s_debug_status   (),
  .rx_r_m2s_debug_status   (),
  .rx_b_m2s_debug_status   (),
  .rx_ar_s2m_debug_status  (),
  .rx_aw_s2m_debug_status  (),
  .rx_w_s2m_debug_status   (),
  .tx_r_s2m_debug_status   (),
  .tx_b_s2m_debug_status   (),
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
  .init_r_m2s_credit     (init_r_m2s_credit)  ,
  .init_b_m2s_credit     (init_b_m2s_credit)  ,
  .init_ar_s2m_credit     (init_ar_s2m_credit)  ,
  .init_aw_s2m_credit     (init_aw_s2m_credit)  ,
  .init_w_s2m_credit     (init_w_s2m_credit)  ,
  .tx_phy0           (rx_phy0_ldr)  ,
  .rx_phy0           (tx_phy0_ldr)  , 
  
  .user_m2s_arid         (F_user_m2s_arid    )  ,
  .user_m2s_arsize       (F_user_m2s_arsize  )  ,
  .user_m2s_arlen        (F_user_m2s_arlen   )  ,
  .user_m2s_arburst      (F_user_m2s_arburst )  ,
  .user_m2s_araddr       (F_user_m2s_araddr  )  ,
  .user_m2s_arvalid      (F_user_m2s_arvalid )  ,
  .user_m2s_arready      (F_user_m2s_arready )  ,
  .user_m2s_awid         (F_user_m2s_awid     )  ,
  .user_m2s_awsize       (F_user_m2s_awsize   )  ,
  .user_m2s_awlen        (F_user_m2s_awlen    )  ,
  .user_m2s_awburst      (F_user_m2s_awburst  )  ,
  .user_m2s_awaddr       (F_user_m2s_awaddr   )  ,
  .user_m2s_awvalid      (F_user_m2s_awvalid  )  ,
  .user_m2s_awready      (F_user_m2s_awready  )  ,
  .user_m2s_wid          (F_user_m2s_wid   )  ,
  .user_m2s_wdata        (F_user_m2s_wdata )  ,
  .user_m2s_wstrb        (F_user_m2s_wstrb )  ,
  .user_m2s_wlast        (F_user_m2s_wlast )  ,
  .user_m2s_wvalid       (F_user_m2s_wvalid)  ,
  .user_m2s_wready       (F_user_m2s_wready)  ,
  .user_m2s_rid          (F_user_m2s_rid   )  ,
  .user_m2s_rdata        (F_user_m2s_rdata )  ,
  .user_m2s_rlast        (F_user_m2s_rlast )  ,
  .user_m2s_rresp        (F_user_m2s_rresp )  ,
  .user_m2s_rvalid       (F_user_m2s_rvalid)  ,
  .user_m2s_rready       (F_user_m2s_rready)  ,
  .user_m2s_bid          (F_user_m2s_bid   )  ,
  .user_m2s_bresp        (F_user_m2s_bresp )  ,
  .user_m2s_bvalid       (F_user_m2s_bvalid)  ,
  .user_m2s_bready       (F_user_m2s_bready)  ,
  .user_s2m_arid         (F_user_s2m_arid    )  ,
  .user_s2m_arsize       (F_user_s2m_arsize  )  ,
  .user_s2m_arlen        (F_user_s2m_arlen   )  ,
  .user_s2m_arburst      (F_user_s2m_arburst )  ,
  .user_s2m_araddr       (F_user_s2m_araddr  )  ,
  .user_s2m_arvalid      (F_user_s2m_arvalid )  ,
  .user_s2m_arready      (F_user_s2m_arready )  ,
  .user_s2m_awid         (F_user_s2m_awid     )  ,
  .user_s2m_awsize       (F_user_s2m_awsize   )  ,
  .user_s2m_awlen        (F_user_s2m_awlen    )  ,
  .user_s2m_awburst      (F_user_s2m_awburst  )  ,
  .user_s2m_awaddr       (F_user_s2m_awaddr   )  ,
  .user_s2m_awvalid      (F_user_s2m_awvalid  )  ,
  .user_s2m_awready      (F_user_s2m_awready  )  ,
  .user_s2m_wid          (F_user_s2m_wid   )  ,
  .user_s2m_wdata        (F_user_s2m_wdata )  ,
  .user_s2m_wstrb        (F_user_s2m_wstrb )  ,
  .user_s2m_wlast        (F_user_s2m_wlast )  ,
  .user_s2m_wvalid       (F_user_s2m_wvalid)  ,
  .user_s2m_wready       (F_user_s2m_wready)  ,
  .user_s2m_rid          (F_user_s2m_rid   )  ,
  .user_s2m_rdata        (F_user_s2m_rdata )  ,
  .user_s2m_rlast        (F_user_s2m_rlast )  ,
  .user_s2m_rresp        (F_user_s2m_rresp )  ,
  .user_s2m_rvalid       (F_user_s2m_rvalid)  ,
  .user_s2m_rready       (F_user_s2m_rready)  ,
  .user_s2m_bid          (F_user_s2m_bid   )  ,
  .user_s2m_bresp        (F_user_s2m_bresp )  ,
  .user_s2m_bvalid       (F_user_s2m_bvalid)  ,
  .user_s2m_bready       (F_user_s2m_bready)  ,

  .rx_ar_m2s_debug_status()  ,
  .rx_aw_m2s_debug_status()  ,
  .rx_w_m2s_debug_status ()  ,
  .tx_r_m2s_debug_status ()  ,
  .tx_b_m2s_debug_status ()  ,
  .tx_ar_s2m_debug_status()  ,
  .tx_aw_s2m_debug_status()  ,
  .tx_w_s2m_debug_status ()  ,
  .rx_r_s2m_debug_status ()  ,
  .rx_b_s2m_debug_status ()  ,
  .m_gen2_mode       (f_gen_mode)  ,
  .delay_x_value     (SLAVE_DELAY_X_VALUE)  ,
  .delay_y_value     (SLAVE_DELAY_Y_VALUE)  ,
  .delay_z_value     (SLAVE_DELAY_Z_VALUE)  

);
endmodule
