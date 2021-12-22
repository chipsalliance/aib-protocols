module axi_mm_master_top (/*AUTOARG*/
   // Outputs
   tx_phy0, ch3_user_wready, ch3_user_rvalid, ch3_user_rresp,
   ch3_user_rlast, ch3_user_rid, ch3_user_rdata, ch3_user_bvalid,
   ch3_user_bresp, ch3_user_bid, ch3_user_awready, ch3_user_arready,
   ch3_tx_w_debug_status, ch3_tx_aw_debug_status,
   ch3_tx_ar_debug_status, ch3_rx_r_debug_status,
   ch3_rx_b_debug_status, ch2_user_wready, ch2_user_rvalid,
   ch2_user_rresp, ch2_user_rlast, ch2_user_rid, ch2_user_rdata,
   ch2_user_bvalid, ch2_user_bresp, ch2_user_bid, ch2_user_awready,
   ch2_user_arready, ch2_tx_w_debug_status, ch2_tx_aw_debug_status,
   ch2_tx_ar_debug_status, ch2_rx_r_debug_status,
   ch2_rx_b_debug_status, ch1_user_wready, ch1_user_rvalid,
   ch1_user_rresp, ch1_user_rlast, ch1_user_rid, ch1_user_rdata,
   ch1_user_bvalid, ch1_user_bresp, ch1_user_bid, ch1_user_awready,
   ch1_user_arready, ch1_tx_w_debug_status, ch1_tx_aw_debug_status,
   ch1_tx_ar_debug_status, ch1_rx_r_debug_status,
   ch1_rx_b_debug_status, ch0_user_wready, ch0_user_rvalid,
   ch0_user_rresp, ch0_user_rlast, ch0_user_rid, ch0_user_rdata,
   ch0_user_bvalid, ch0_user_bresp, ch0_user_bid, ch0_user_awready,
   ch0_user_arready, ch0_tx_w_debug_status, ch0_tx_aw_debug_status,
   ch0_tx_ar_debug_status, ch0_rx_r_debug_status,
   ch0_rx_b_debug_status,
   // Inputs
   tx_online, rx_phy0, rx_online, rst_wr_n, m_gen2_mode,
   delay_z_value, delay_y_value, delay_x_value, clk_wr,
   ch3_user_wvalid, ch3_user_wstrb, ch3_user_wlast, ch3_user_wid,
   ch3_user_wdata, ch3_user_rready, ch3_user_bready, ch3_user_awvalid,
   ch3_user_awsize, ch3_user_awlen, ch3_user_awid, ch3_user_awburst,
   ch3_user_awaddr, ch3_user_arvalid, ch3_user_arsize, ch3_user_arlen,
   ch3_user_arid, ch3_user_arburst, ch3_user_araddr, ch2_user_wvalid,
   ch2_user_wstrb, ch2_user_wlast, ch2_user_wid, ch2_user_wdata,
   ch2_user_rready, ch2_user_bready, ch2_user_awvalid,
   ch2_user_awsize, ch2_user_awlen, ch2_user_awid, ch2_user_awburst,
   ch2_user_awaddr, ch2_user_arvalid, ch2_user_arsize, ch2_user_arlen,
   ch2_user_arid, ch2_user_arburst, ch2_user_araddr, ch1_user_wvalid,
   ch1_user_wstrb, ch1_user_wlast, ch1_user_wid, ch1_user_wdata,
   ch1_user_rready, ch1_user_bready, ch1_user_awvalid,
   ch1_user_awsize, ch1_user_awlen, ch1_user_awid, ch1_user_awburst,
   ch1_user_awaddr, ch1_user_arvalid, ch1_user_arsize, ch1_user_arlen,
   ch1_user_arid, ch1_user_arburst, ch1_user_araddr, ch0_user_wvalid,
   ch0_user_wstrb, ch0_user_wlast, ch0_user_wid, ch0_user_wdata,
   ch0_user_rready, ch0_user_bready, ch0_user_awvalid,
   ch0_user_awsize, ch0_user_awlen, ch0_user_awid, ch0_user_awburst,
   ch0_user_awaddr, ch0_user_arvalid, ch0_user_arsize, ch0_user_arlen,
   ch0_user_arid, ch0_user_arburst, ch0_user_araddr
   );

  /*AUTOOUTPUT*/
  // Beginning of automatic outputs (from unused autoinst outputs)
  output logic [31:0]	ch0_rx_b_debug_status;	// From aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch0_rx_r_debug_status;	// From aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch0_tx_ar_debug_status;	// From aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch0_tx_aw_debug_status;	// From aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch0_tx_w_debug_status;	// From aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  output logic		ch0_user_arready;	// From aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  output logic		ch0_user_awready;	// From aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  output logic [3:0]	ch0_user_bid;		// From aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  output logic [1:0]	ch0_user_bresp;		// From aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  output logic		ch0_user_bvalid;	// From aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  output logic [63:0]	ch0_user_rdata;		// From aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  output logic [3:0]	ch0_user_rid;		// From aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  output logic		ch0_user_rlast;		// From aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  output logic [1:0]	ch0_user_rresp;		// From aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  output logic		ch0_user_rvalid;	// From aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  output logic		ch0_user_wready;	// From aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch1_rx_b_debug_status;	// From aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch1_rx_r_debug_status;	// From aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch1_tx_ar_debug_status;	// From aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch1_tx_aw_debug_status;	// From aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch1_tx_w_debug_status;	// From aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  output logic		ch1_user_arready;	// From aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  output logic		ch1_user_awready;	// From aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  output logic [3:0]	ch1_user_bid;		// From aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  output logic [1:0]	ch1_user_bresp;		// From aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  output logic		ch1_user_bvalid;	// From aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  output logic [63:0]	ch1_user_rdata;		// From aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  output logic [3:0]	ch1_user_rid;		// From aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  output logic		ch1_user_rlast;		// From aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  output logic [1:0]	ch1_user_rresp;		// From aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  output logic		ch1_user_rvalid;	// From aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  output logic		ch1_user_wready;	// From aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch2_rx_b_debug_status;	// From aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch2_rx_r_debug_status;	// From aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch2_tx_ar_debug_status;	// From aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch2_tx_aw_debug_status;	// From aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch2_tx_w_debug_status;	// From aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  output logic		ch2_user_arready;	// From aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  output logic		ch2_user_awready;	// From aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  output logic [3:0]	ch2_user_bid;		// From aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  output logic [1:0]	ch2_user_bresp;		// From aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  output logic		ch2_user_bvalid;	// From aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  output logic [63:0]	ch2_user_rdata;		// From aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  output logic [3:0]	ch2_user_rid;		// From aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  output logic		ch2_user_rlast;		// From aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  output logic [1:0]	ch2_user_rresp;		// From aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  output logic		ch2_user_rvalid;	// From aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  output logic		ch2_user_wready;	// From aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch3_rx_b_debug_status;	// From aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch3_rx_r_debug_status;	// From aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch3_tx_ar_debug_status;	// From aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch3_tx_aw_debug_status;	// From aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  output logic [31:0]	ch3_tx_w_debug_status;	// From aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  output logic		ch3_user_arready;	// From aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  output logic		ch3_user_awready;	// From aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  output logic [3:0]	ch3_user_bid;		// From aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  output logic [1:0]	ch3_user_bresp;		// From aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  output logic		ch3_user_bvalid;	// From aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  output logic [63:0]	ch3_user_rdata;		// From aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  output logic [3:0]	ch3_user_rid;		// From aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  output logic		ch3_user_rlast;		// From aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  output logic [1:0]	ch3_user_rresp;		// From aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  output logic		ch3_user_rvalid;	// From aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  output logic		ch3_user_wready;	// From aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  output logic [319:0]	tx_phy0;		// From aximm_ll_multi_tier2_master_top_i0 of aximm_ll_multi_tier2_master_top.v
  // End of automatics

  /*AUTOINPUT*/
  // Beginning of automatic inputs (from unused autoinst inputs)
  input logic [31:0]	ch0_user_araddr;	// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic [1:0]	ch0_user_arburst;	// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic [3:0]	ch0_user_arid;		// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic [7:0]	ch0_user_arlen;		// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic [2:0]	ch0_user_arsize;	// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic		ch0_user_arvalid;	// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic [31:0]	ch0_user_awaddr;	// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic [1:0]	ch0_user_awburst;	// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic [3:0]	ch0_user_awid;		// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic [7:0]	ch0_user_awlen;		// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic [2:0]	ch0_user_awsize;	// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic		ch0_user_awvalid;	// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic		ch0_user_bready;	// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic		ch0_user_rready;	// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic [63:0]	ch0_user_wdata;		// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic [3:0]	ch0_user_wid;		// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic		ch0_user_wlast;		// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic [7:0]	ch0_user_wstrb;		// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic		ch0_user_wvalid;	// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  input logic [31:0]	ch1_user_araddr;	// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic [1:0]	ch1_user_arburst;	// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic [3:0]	ch1_user_arid;		// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic [7:0]	ch1_user_arlen;		// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic [2:0]	ch1_user_arsize;	// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic		ch1_user_arvalid;	// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic [31:0]	ch1_user_awaddr;	// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic [1:0]	ch1_user_awburst;	// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic [3:0]	ch1_user_awid;		// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic [7:0]	ch1_user_awlen;		// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic [2:0]	ch1_user_awsize;	// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic		ch1_user_awvalid;	// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic		ch1_user_bready;	// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic		ch1_user_rready;	// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic [63:0]	ch1_user_wdata;		// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic [3:0]	ch1_user_wid;		// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic		ch1_user_wlast;		// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic [7:0]	ch1_user_wstrb;		// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic		ch1_user_wvalid;	// To aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  input logic [31:0]	ch2_user_araddr;	// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic [1:0]	ch2_user_arburst;	// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic [3:0]	ch2_user_arid;		// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic [7:0]	ch2_user_arlen;		// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic [2:0]	ch2_user_arsize;	// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic		ch2_user_arvalid;	// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic [31:0]	ch2_user_awaddr;	// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic [1:0]	ch2_user_awburst;	// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic [3:0]	ch2_user_awid;		// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic [7:0]	ch2_user_awlen;		// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic [2:0]	ch2_user_awsize;	// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic		ch2_user_awvalid;	// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic		ch2_user_bready;	// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic		ch2_user_rready;	// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic [63:0]	ch2_user_wdata;		// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic [3:0]	ch2_user_wid;		// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic		ch2_user_wlast;		// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic [7:0]	ch2_user_wstrb;		// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic		ch2_user_wvalid;	// To aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  input logic [31:0]	ch3_user_araddr;	// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic [1:0]	ch3_user_arburst;	// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic [3:0]	ch3_user_arid;		// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic [7:0]	ch3_user_arlen;		// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic [2:0]	ch3_user_arsize;	// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic		ch3_user_arvalid;	// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic [31:0]	ch3_user_awaddr;	// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic [1:0]	ch3_user_awburst;	// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic [3:0]	ch3_user_awid;		// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic [7:0]	ch3_user_awlen;		// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic [2:0]	ch3_user_awsize;	// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic		ch3_user_awvalid;	// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic		ch3_user_bready;	// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic		ch3_user_rready;	// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic [63:0]	ch3_user_wdata;		// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic [3:0]	ch3_user_wid;		// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic		ch3_user_wlast;		// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic [7:0]	ch3_user_wstrb;		// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic		ch3_user_wvalid;	// To aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  input logic		clk_wr;			// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v, ...
  input logic [15:0]	delay_x_value;		// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v, ...
  input logic [15:0]	delay_y_value;		// To aximm_ll_multi_tier2_master_top_i0 of aximm_ll_multi_tier2_master_top.v
  input logic [15:0]	delay_z_value;		// To aximm_ll_multi_tier2_master_top_i0 of aximm_ll_multi_tier2_master_top.v
  input logic		m_gen2_mode;		// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v, ...
  input logic		rst_wr_n;		// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v, ...
  input logic		rx_online;		// To aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v, ...
  input logic [319:0]	rx_phy0;		// To aximm_ll_multi_tier2_master_top_i0 of aximm_ll_multi_tier2_master_top.v
  input logic		tx_online;		// To aximm_ll_multi_tier2_master_top_i0 of aximm_ll_multi_tier2_master_top.v
  // End of automatics

  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  logic [78:0]		ch0_rx_data;		// From aximm_ll_multi_tier2_master_top_i0 of aximm_ll_multi_tier2_master_top.v
  logic [78:0]		ch0_tx_data;		// From aximm_ll_multi_tier1_master_top_i0 of aximm_ll_multi_tier1_master_top.v
  logic [78:0]		ch1_rx_data;		// From aximm_ll_multi_tier2_master_top_i0 of aximm_ll_multi_tier2_master_top.v
  logic [78:0]		ch1_tx_data;		// From aximm_ll_multi_tier1_master_top_i1 of aximm_ll_multi_tier1_master_top.v
  logic [78:0]		ch2_rx_data;		// From aximm_ll_multi_tier2_master_top_i0 of aximm_ll_multi_tier2_master_top.v
  logic [78:0]		ch2_tx_data;		// From aximm_ll_multi_tier1_master_top_i2 of aximm_ll_multi_tier1_master_top.v
  logic [78:0]		ch3_rx_data;		// From aximm_ll_multi_tier2_master_top_i0 of aximm_ll_multi_tier2_master_top.v
  logic [78:0]		ch3_tx_data;		// From aximm_ll_multi_tier1_master_top_i3 of aximm_ll_multi_tier1_master_top.v
  logic [31:0]		tier2_tx_debug_status;	// From aximm_ll_multi_tier2_master_top_i0 of aximm_ll_multi_tier2_master_top.v
  // End of automatics

   /* aximm_ll_multi_tier1_master_top AUTO_TEMPLATE ".*_i\(.+\)"  (
      .user_\(.*\)                   (ch@_user_\1[]),
      .user_\(.*\)                   (ch@_user_\1[]),
      .\(.*\)_debug_status           (ch@_\1_debug_status[]),
      .init_\(.*\)_credit            (8'h0),
      .rx_phy0                       (ch@_rx_data[]),
      .tx_phy0                       (ch@_tx_data[]),
      .tx_online                     (tier2_tx_debug_status[19]),
      .delay_x_value                 (delay_x_value[]),
      .delay_y_value                 (16'h0),
      .delay_z_value                 (16'h0),
    );
    */

   aximm_ll_multi_tier1_master_top aximm_ll_multi_tier1_master_top_i0(/*AUTOINST*/
								      // Outputs
								      .tx_phy0		(ch0_tx_data[78:0]), // Templated
								      .user_arready	(ch0_user_arready), // Templated
								      .user_awready	(ch0_user_awready), // Templated
								      .user_wready	(ch0_user_wready), // Templated
								      .user_rid		(ch0_user_rid[3:0]), // Templated
								      .user_rdata	(ch0_user_rdata[63:0]), // Templated
								      .user_rlast	(ch0_user_rlast), // Templated
								      .user_rresp	(ch0_user_rresp[1:0]), // Templated
								      .user_rvalid	(ch0_user_rvalid), // Templated
								      .user_bid		(ch0_user_bid[3:0]), // Templated
								      .user_bresp	(ch0_user_bresp[1:0]), // Templated
								      .user_bvalid	(ch0_user_bvalid), // Templated
								      .tx_ar_debug_status(ch0_tx_ar_debug_status[31:0]), // Templated
								      .tx_aw_debug_status(ch0_tx_aw_debug_status[31:0]), // Templated
								      .tx_w_debug_status(ch0_tx_w_debug_status[31:0]), // Templated
								      .rx_r_debug_status(ch0_rx_r_debug_status[31:0]), // Templated
								      .rx_b_debug_status(ch0_rx_b_debug_status[31:0]), // Templated
								      // Inputs
								      .clk_wr		(clk_wr),
								      .rst_wr_n		(rst_wr_n),
								      .tx_online	(tier2_tx_debug_status[19]), // Templated
								      .rx_online	(rx_online),
								      .init_ar_credit	(8'h0),		 // Templated
								      .init_aw_credit	(8'h0),		 // Templated
								      .init_w_credit	(8'h0),		 // Templated
								      .rx_phy0		(ch0_rx_data[78:0]), // Templated
								      .user_arid	(ch0_user_arid[3:0]), // Templated
								      .user_arsize	(ch0_user_arsize[2:0]), // Templated
								      .user_arlen	(ch0_user_arlen[7:0]), // Templated
								      .user_arburst	(ch0_user_arburst[1:0]), // Templated
								      .user_araddr	(ch0_user_araddr[31:0]), // Templated
								      .user_arvalid	(ch0_user_arvalid), // Templated
								      .user_awid	(ch0_user_awid[3:0]), // Templated
								      .user_awsize	(ch0_user_awsize[2:0]), // Templated
								      .user_awlen	(ch0_user_awlen[7:0]), // Templated
								      .user_awburst	(ch0_user_awburst[1:0]), // Templated
								      .user_awaddr	(ch0_user_awaddr[31:0]), // Templated
								      .user_awvalid	(ch0_user_awvalid), // Templated
								      .user_wid		(ch0_user_wid[3:0]), // Templated
								      .user_wdata	(ch0_user_wdata[63:0]), // Templated
								      .user_wstrb	(ch0_user_wstrb[7:0]), // Templated
								      .user_wlast	(ch0_user_wlast), // Templated
								      .user_wvalid	(ch0_user_wvalid), // Templated
								      .user_rready	(ch0_user_rready), // Templated
								      .user_bready	(ch0_user_bready), // Templated
								      .m_gen2_mode	(m_gen2_mode),
								      .delay_x_value	(delay_x_value[15:0]), // Templated
								      .delay_y_value	(16'h0),	 // Templated
								      .delay_z_value	(16'h0));	 // Templated

   aximm_ll_multi_tier1_master_top aximm_ll_multi_tier1_master_top_i1(/*AUTOINST*/
								      // Outputs
								      .tx_phy0		(ch1_tx_data[78:0]), // Templated
								      .user_arready	(ch1_user_arready), // Templated
								      .user_awready	(ch1_user_awready), // Templated
								      .user_wready	(ch1_user_wready), // Templated
								      .user_rid		(ch1_user_rid[3:0]), // Templated
								      .user_rdata	(ch1_user_rdata[63:0]), // Templated
								      .user_rlast	(ch1_user_rlast), // Templated
								      .user_rresp	(ch1_user_rresp[1:0]), // Templated
								      .user_rvalid	(ch1_user_rvalid), // Templated
								      .user_bid		(ch1_user_bid[3:0]), // Templated
								      .user_bresp	(ch1_user_bresp[1:0]), // Templated
								      .user_bvalid	(ch1_user_bvalid), // Templated
								      .tx_ar_debug_status(ch1_tx_ar_debug_status[31:0]), // Templated
								      .tx_aw_debug_status(ch1_tx_aw_debug_status[31:0]), // Templated
								      .tx_w_debug_status(ch1_tx_w_debug_status[31:0]), // Templated
								      .rx_r_debug_status(ch1_rx_r_debug_status[31:0]), // Templated
								      .rx_b_debug_status(ch1_rx_b_debug_status[31:0]), // Templated
								      // Inputs
								      .clk_wr		(clk_wr),
								      .rst_wr_n		(rst_wr_n),
								      .tx_online	(tier2_tx_debug_status[19]), // Templated
								      .rx_online	(rx_online),
								      .init_ar_credit	(8'h0),		 // Templated
								      .init_aw_credit	(8'h0),		 // Templated
								      .init_w_credit	(8'h0),		 // Templated
								      .rx_phy0		(ch1_rx_data[78:0]), // Templated
								      .user_arid	(ch1_user_arid[3:0]), // Templated
								      .user_arsize	(ch1_user_arsize[2:0]), // Templated
								      .user_arlen	(ch1_user_arlen[7:0]), // Templated
								      .user_arburst	(ch1_user_arburst[1:0]), // Templated
								      .user_araddr	(ch1_user_araddr[31:0]), // Templated
								      .user_arvalid	(ch1_user_arvalid), // Templated
								      .user_awid	(ch1_user_awid[3:0]), // Templated
								      .user_awsize	(ch1_user_awsize[2:0]), // Templated
								      .user_awlen	(ch1_user_awlen[7:0]), // Templated
								      .user_awburst	(ch1_user_awburst[1:0]), // Templated
								      .user_awaddr	(ch1_user_awaddr[31:0]), // Templated
								      .user_awvalid	(ch1_user_awvalid), // Templated
								      .user_wid		(ch1_user_wid[3:0]), // Templated
								      .user_wdata	(ch1_user_wdata[63:0]), // Templated
								      .user_wstrb	(ch1_user_wstrb[7:0]), // Templated
								      .user_wlast	(ch1_user_wlast), // Templated
								      .user_wvalid	(ch1_user_wvalid), // Templated
								      .user_rready	(ch1_user_rready), // Templated
								      .user_bready	(ch1_user_bready), // Templated
								      .m_gen2_mode	(m_gen2_mode),
								      .delay_x_value	(delay_x_value[15:0]), // Templated
								      .delay_y_value	(16'h0),	 // Templated
								      .delay_z_value	(16'h0));	 // Templated

   aximm_ll_multi_tier1_master_top aximm_ll_multi_tier1_master_top_i2(/*AUTOINST*/
								      // Outputs
								      .tx_phy0		(ch2_tx_data[78:0]), // Templated
								      .user_arready	(ch2_user_arready), // Templated
								      .user_awready	(ch2_user_awready), // Templated
								      .user_wready	(ch2_user_wready), // Templated
								      .user_rid		(ch2_user_rid[3:0]), // Templated
								      .user_rdata	(ch2_user_rdata[63:0]), // Templated
								      .user_rlast	(ch2_user_rlast), // Templated
								      .user_rresp	(ch2_user_rresp[1:0]), // Templated
								      .user_rvalid	(ch2_user_rvalid), // Templated
								      .user_bid		(ch2_user_bid[3:0]), // Templated
								      .user_bresp	(ch2_user_bresp[1:0]), // Templated
								      .user_bvalid	(ch2_user_bvalid), // Templated
								      .tx_ar_debug_status(ch2_tx_ar_debug_status[31:0]), // Templated
								      .tx_aw_debug_status(ch2_tx_aw_debug_status[31:0]), // Templated
								      .tx_w_debug_status(ch2_tx_w_debug_status[31:0]), // Templated
								      .rx_r_debug_status(ch2_rx_r_debug_status[31:0]), // Templated
								      .rx_b_debug_status(ch2_rx_b_debug_status[31:0]), // Templated
								      // Inputs
								      .clk_wr		(clk_wr),
								      .rst_wr_n		(rst_wr_n),
								      .tx_online	(tier2_tx_debug_status[19]), // Templated
								      .rx_online	(rx_online),
								      .init_ar_credit	(8'h0),		 // Templated
								      .init_aw_credit	(8'h0),		 // Templated
								      .init_w_credit	(8'h0),		 // Templated
								      .rx_phy0		(ch2_rx_data[78:0]), // Templated
								      .user_arid	(ch2_user_arid[3:0]), // Templated
								      .user_arsize	(ch2_user_arsize[2:0]), // Templated
								      .user_arlen	(ch2_user_arlen[7:0]), // Templated
								      .user_arburst	(ch2_user_arburst[1:0]), // Templated
								      .user_araddr	(ch2_user_araddr[31:0]), // Templated
								      .user_arvalid	(ch2_user_arvalid), // Templated
								      .user_awid	(ch2_user_awid[3:0]), // Templated
								      .user_awsize	(ch2_user_awsize[2:0]), // Templated
								      .user_awlen	(ch2_user_awlen[7:0]), // Templated
								      .user_awburst	(ch2_user_awburst[1:0]), // Templated
								      .user_awaddr	(ch2_user_awaddr[31:0]), // Templated
								      .user_awvalid	(ch2_user_awvalid), // Templated
								      .user_wid		(ch2_user_wid[3:0]), // Templated
								      .user_wdata	(ch2_user_wdata[63:0]), // Templated
								      .user_wstrb	(ch2_user_wstrb[7:0]), // Templated
								      .user_wlast	(ch2_user_wlast), // Templated
								      .user_wvalid	(ch2_user_wvalid), // Templated
								      .user_rready	(ch2_user_rready), // Templated
								      .user_bready	(ch2_user_bready), // Templated
								      .m_gen2_mode	(m_gen2_mode),
								      .delay_x_value	(delay_x_value[15:0]), // Templated
								      .delay_y_value	(16'h0),	 // Templated
								      .delay_z_value	(16'h0));	 // Templated

   aximm_ll_multi_tier1_master_top aximm_ll_multi_tier1_master_top_i3(/*AUTOINST*/
								      // Outputs
								      .tx_phy0		(ch3_tx_data[78:0]), // Templated
								      .user_arready	(ch3_user_arready), // Templated
								      .user_awready	(ch3_user_awready), // Templated
								      .user_wready	(ch3_user_wready), // Templated
								      .user_rid		(ch3_user_rid[3:0]), // Templated
								      .user_rdata	(ch3_user_rdata[63:0]), // Templated
								      .user_rlast	(ch3_user_rlast), // Templated
								      .user_rresp	(ch3_user_rresp[1:0]), // Templated
								      .user_rvalid	(ch3_user_rvalid), // Templated
								      .user_bid		(ch3_user_bid[3:0]), // Templated
								      .user_bresp	(ch3_user_bresp[1:0]), // Templated
								      .user_bvalid	(ch3_user_bvalid), // Templated
								      .tx_ar_debug_status(ch3_tx_ar_debug_status[31:0]), // Templated
								      .tx_aw_debug_status(ch3_tx_aw_debug_status[31:0]), // Templated
								      .tx_w_debug_status(ch3_tx_w_debug_status[31:0]), // Templated
								      .rx_r_debug_status(ch3_rx_r_debug_status[31:0]), // Templated
								      .rx_b_debug_status(ch3_rx_b_debug_status[31:0]), // Templated
								      // Inputs
								      .clk_wr		(clk_wr),
								      .rst_wr_n		(rst_wr_n),
								      .tx_online	(tier2_tx_debug_status[19]), // Templated
								      .rx_online	(rx_online),
								      .init_ar_credit	(8'h0),		 // Templated
								      .init_aw_credit	(8'h0),		 // Templated
								      .init_w_credit	(8'h0),		 // Templated
								      .rx_phy0		(ch3_rx_data[78:0]), // Templated
								      .user_arid	(ch3_user_arid[3:0]), // Templated
								      .user_arsize	(ch3_user_arsize[2:0]), // Templated
								      .user_arlen	(ch3_user_arlen[7:0]), // Templated
								      .user_arburst	(ch3_user_arburst[1:0]), // Templated
								      .user_araddr	(ch3_user_araddr[31:0]), // Templated
								      .user_arvalid	(ch3_user_arvalid), // Templated
								      .user_awid	(ch3_user_awid[3:0]), // Templated
								      .user_awsize	(ch3_user_awsize[2:0]), // Templated
								      .user_awlen	(ch3_user_awlen[7:0]), // Templated
								      .user_awburst	(ch3_user_awburst[1:0]), // Templated
								      .user_awaddr	(ch3_user_awaddr[31:0]), // Templated
								      .user_awvalid	(ch3_user_awvalid), // Templated
								      .user_wid		(ch3_user_wid[3:0]), // Templated
								      .user_wdata	(ch3_user_wdata[63:0]), // Templated
								      .user_wstrb	(ch3_user_wstrb[7:0]), // Templated
								      .user_wlast	(ch3_user_wlast), // Templated
								      .user_wvalid	(ch3_user_wvalid), // Templated
								      .user_rready	(ch3_user_rready), // Templated
								      .user_bready	(ch3_user_bready), // Templated
								      .m_gen2_mode	(m_gen2_mode),
								      .delay_x_value	(delay_x_value[15:0]), // Templated
								      .delay_y_value	(16'h0),	 // Templated
								      .delay_z_value	(16'h0));	 // Templated


   /* aximm_ll_multi_tier2_master_top AUTO_TEMPLATE ".*_i\(.+\)"  (
      .init_\(.*\)_credit            (8'h0),
      .\(.*\)_rx_debug_status        (),
      .\(.*\)_tx_debug_status        (tier2_tx_debug_status[]),
    );
    */

   aximm_ll_multi_tier2_master_top aximm_ll_multi_tier2_master_top_i0 (/*AUTOINST*/
								       // Outputs
								       .tx_phy0		(tx_phy0[319:0]),
								       .ch0_rx_data	(ch0_rx_data[78:0]),
								       .ch1_rx_data	(ch1_rx_data[78:0]),
								       .ch2_rx_data	(ch2_rx_data[78:0]),
								       .ch3_rx_data	(ch3_rx_data[78:0]),
								       .tx_tx_debug_status(tier2_tx_debug_status[31:0]), // Templated
								       .rx_rx_debug_status(),		 // Templated
								       // Inputs
								       .clk_wr		(clk_wr),
								       .rst_wr_n	(rst_wr_n),
								       .tx_online	(tx_online),
								       .rx_online	(rx_online),
								       .init_tx_credit	(8'h0),		 // Templated
								       .rx_phy0		(rx_phy0[319:0]),
								       .ch0_tx_data	(ch0_tx_data[78:0]),
								       .ch1_tx_data	(ch1_tx_data[78:0]),
								       .ch2_tx_data	(ch2_tx_data[78:0]),
								       .ch3_tx_data	(ch3_tx_data[78:0]),
								       .m_gen2_mode	(m_gen2_mode),
								       .delay_x_value	(delay_x_value[15:0]),
								       .delay_y_value	(delay_y_value[15:0]),
								       .delay_z_value	(delay_z_value[15:0]));


endmodule

// Local Variables:
// verilog-library-directories:("*" )
// End:
//aximm_ll_multi_tier1
