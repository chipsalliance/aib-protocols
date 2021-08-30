module top (
    input  logic                                clk_wr    ,
    input  logic                                rst_wr_n    ,

    input  logic                                m_gen2_mode_flop    ,

    // Master
    // AR channel
    input  logic  [3:0]                         user1_arid_flop    ,
    input  logic  [2:0]                         user1_arsize_flop    ,
    input  logic  [7:0]                         user1_arlen_flop    ,
    input  logic  [1:0]                         user1_arburst_flop    ,
    input  logic  [31:0]                        user1_araddr_flop    ,
    input  logic                                user1_arvalid_flop    ,
    output logic                                user1_arready_flop    ,

    // AW channel
    input  logic  [3:0]                         user1_awid_flop    ,
    input  logic  [2:0]                         user1_awsize_flop    ,
    input  logic  [7:0]                         user1_awlen_flop    ,
    input  logic  [1:0]                         user1_awburst_flop    ,
    input  logic  [31:0]                        user1_awaddr_flop    ,
    input  logic                                user1_awvalid_flop    ,
    output logic                                user1_awready_flop    ,

    // W channel
    input  logic  [3:0]                         user1_wid_flop    ,
    input  logic  [127:0]                       user1_wdata_flop    ,
    input  logic  [15:0]                        user1_wstrb_flop    ,
    input  logic                                user1_wlast_flop    ,
    input  logic                                user1_wvalid_flop    ,
    output logic                                user1_wready_flop    ,

    // R channel
    output logic   [3:0]                        user1_rid_flop    ,
    output logic   [127:0]                      user1_rdata_flop    ,
    output logic                                user1_rlast_flop    ,
    output logic   [1:0]                        user1_rresp_flop    ,
    output logic                                user1_rvalid_flop    ,
    input  logic                                user1_rready_flop    ,

    // B channel
    output logic   [3:0]                        user1_bid_flop    ,
    output logic   [1:0]                        user1_bresp_flop    ,
    output logic                                user1_bvalid_flop    ,
    input  logic                                user1_bready_flop    ,


  // SLAVE IF
    // AR channel
    output logic  [3:0]                         user2_arid_flop    ,
    output logic  [2:0]                         user2_arsize_flop    ,
    output logic  [7:0]                         user2_arlen_flop    ,
    output logic  [1:0]                         user2_arburst_flop    ,
    output logic  [31:0]                        user2_araddr_flop    ,
    output logic                                user2_arvalid_flop    ,
    input  logic                                user2_arready_flop    ,

    // AW channel
    output logic  [3:0]                         user2_awid_flop    ,
    output logic  [2:0]                         user2_awsize_flop    ,
    output logic  [7:0]                         user2_awlen_flop    ,
    output logic  [1:0]                         user2_awburst_flop    ,
    output logic  [31:0]                        user2_awaddr_flop    ,
    output logic                                user2_awvalid_flop    ,
    input  logic                                user2_awready_flop    ,

    // W channel
    output logic  [3:0]                         user2_wid_flop    ,
    output logic  [127:0]                       user2_wdata_flop    ,
    output logic  [15:0]                        user2_wstrb_flop    ,
    output logic                                user2_wlast_flop    ,
    output logic                                user2_wvalid_flop    ,
    input  logic                                user2_wready_flop    ,

    // R channel
    input  logic   [3:0]                        user2_rid_flop    ,
    input  logic   [127:0]                      user2_rdata_flop    ,
    input  logic                                user2_rlast_flop    ,
    input  logic   [1:0]                        user2_rresp_flop    ,
    input  logic                                user2_rvalid_flop    ,
    output logic                                user2_rready_flop    ,

    // B channel
    input  logic   [3:0]                        user2_bid_flop    ,
    input  logic   [1:0]                        user2_bresp_flop    ,
    input  logic                                user2_bvalid_flop    ,
    output logic                                user2_bready_flop    ,

    // All status have same format
    // debug_status [7:0] = current dpeth of FIFO
    // debug_status [15:8] = configured DEPTH of FIFO
    // debug_status [16] = overflow_sticky
    // debug_status [17] = underflow_sticky
    // debug_status [23:18] = 0
    // debug_status [31:24] = current transmit credits (on TX only)

    output logic [31:0]                         rx_ar_debug_status_flop    ,
    output logic [31:0]                         rx_aw_debug_status_flop    ,
    output logic [31:0]                         rx_b_debug_status_flop    ,
    output logic [31:0]                         rx_r_debug_status_flop    ,
    output logic [31:0]                         rx_w_debug_status_flop    ,
    output logic [31:0]                         tx_ar_debug_status_flop    ,
    output logic [31:0]                         tx_aw_debug_status_flop    ,
    output logic [31:0]                         tx_b_debug_status_flop    ,
    output logic [31:0]                         tx_r_debug_status_flop    ,
    output logic [31:0]                         tx_w_debug_status_flop

   );


     reg  [1:0]               user1_arburst           ;
     reg  [1:0]               user1_awburst           ;
     reg  [1:0]               user2_bresp             ;
     reg  [1:0]               user2_rresp             ;
     reg  [127:0]             user1_wdata             ;
     reg  [127:0]             user2_rdata             ;
     reg  [15:0]              user1_wstrb             ;
     reg  [2:0]               user1_arsize            ;
     reg  [2:0]               user1_awsize            ;
     reg  [3:0]               user1_arid              ;
     reg  [3:0]               user1_awid              ;
     reg  [3:0]               user1_wid               ;
     reg  [3:0]               user2_bid               ;
     reg  [3:0]               user2_rid               ;
     reg  [31:0]              user1_araddr            ;
     reg  [31:0]              user1_awaddr            ;
     reg  [7:0]               user1_arlen             ;
     reg  [7:0]               user1_awlen             ;
     reg                      user1_arvalid           ;
     reg                      user1_awvalid           ;
     reg                      user1_bready            ;
     reg                      user1_rready            ;
     reg                      user1_wlast             ;
     reg                      user1_wvalid            ;
     reg                      user2_arready           ;
     reg                      user2_awready           ;
     reg                      user2_bvalid            ;
     reg                      user2_rlast             ;
     reg                      user2_rvalid            ;
     reg                      user2_wready            ;
     reg                      m_gen2_mode             ;

     reg  [1:0]               user1_bresp             ;
     reg  [1:0]               user1_rresp             ;
     reg  [1:0]               user2_arburst           ;
     reg  [1:0]               user2_awburst           ;
     reg  [127:0]             user1_rdata             ;
     reg  [127:0]             user2_wdata             ;
     reg  [15:0]              user2_wstrb             ;
     reg  [2:0]               user2_arsize            ;
     reg  [2:0]               user2_awsize            ;
     reg  [3:0]               user1_bid               ;
     reg  [3:0]               user1_rid               ;
     reg  [3:0]               user2_arid              ;
     reg  [3:0]               user2_awid              ;
     reg  [3:0]               user2_wid               ;
     reg  [31:0]              rx_ar_debug_status      ;
     reg  [31:0]              rx_aw_debug_status      ;
     reg  [31:0]              rx_b_debug_status       ;
     reg  [31:0]              rx_r_debug_status       ;
     reg  [31:0]              rx_w_debug_status       ;
     reg  [31:0]              tx_ar_debug_status      ;
     reg  [31:0]              tx_aw_debug_status      ;
     reg  [31:0]              tx_b_debug_status       ;
     reg  [31:0]              tx_r_debug_status       ;
     reg  [31:0]              tx_w_debug_status       ;
     reg  [31:0]              user2_araddr            ;
     reg  [31:0]              user2_awaddr            ;
     reg  [7:0]               user2_arlen             ;
     reg  [7:0]               user2_awlen             ;
     reg                      user1_arready           ;
     reg                      user1_awready           ;
     reg                      user1_bvalid            ;
     reg                      user1_rlast             ;
     reg                      user1_rvalid            ;
     reg                      user1_wready            ;
     reg                      user2_arvalid           ;
     reg                      user2_awvalid           ;
     reg                      user2_bready            ;
     reg                      user2_rready            ;
     reg                      user2_wlast             ;
     reg                      user2_wvalid            ;



always @(posedge clk_wr)
begin
  m_gen2_mode             <= m_gen2_mode_flop ;
  user1_arburst           <= user1_arburst_flop ;
  user1_awburst           <= user1_awburst_flop ;
  user2_bresp             <= user2_bresp_flop   ;
  user2_rresp             <= user2_rresp_flop   ;
  user1_wdata             <= user1_wdata_flop   ;
  user2_rdata             <= user2_rdata_flop   ;
  user1_wstrb             <= user1_wstrb_flop   ;
  user1_arsize            <= user1_arsize_flop  ;
  user1_awsize            <= user1_awsize_flop  ;
  user1_arid              <= user1_arid_flop    ;
  user1_awid              <= user1_awid_flop    ;
  user1_wid               <= user1_wid_flop     ;
  user2_bid               <= user2_bid_flop     ;
  user2_rid               <= user2_rid_flop     ;
  user1_araddr            <= user1_araddr_flop  ;
  user1_awaddr            <= user1_awaddr_flop  ;
  user1_arlen             <= user1_arlen_flop   ;
  user1_awlen             <= user1_awlen_flop   ;
  user1_arvalid           <= user1_arvalid_flop ;
  user1_awvalid           <= user1_awvalid_flop ;
  user1_bready            <= user1_bready_flop  ;
  user1_rready            <= user1_rready_flop  ;
  user1_wlast             <= user1_wlast_flop   ;
  user1_wvalid            <= user1_wvalid_flop  ;
  user2_arready           <= user2_arready_flop ;
  user2_awready           <= user2_awready_flop ;
  user2_bvalid            <= user2_bvalid_flop  ;
  user2_rlast             <= user2_rlast_flop   ;
  user2_rvalid            <= user2_rvalid_flop  ;
  user2_wready            <= user2_wready_flop  ;

  user1_bresp_flop        <= user1_bresp        ;
  user1_rresp_flop        <= user1_rresp        ;
  user2_arburst_flop      <= user2_arburst      ;
  user2_awburst_flop      <= user2_awburst      ;
  user1_rdata_flop        <= user1_rdata        ;
  user2_wdata_flop        <= user2_wdata        ;
  user2_wstrb_flop        <= user2_wstrb        ;
  user2_arsize_flop       <= user2_arsize       ;
  user2_awsize_flop       <= user2_awsize       ;
  user1_bid_flop          <= user1_bid          ;
  user1_rid_flop          <= user1_rid          ;
  user2_arid_flop         <= user2_arid         ;
  user2_awid_flop         <= user2_awid         ;
  user2_wid_flop          <= user2_wid          ;
  rx_ar_debug_status_flop <= rx_ar_debug_status ;
  rx_aw_debug_status_flop <= rx_aw_debug_status ;
  rx_b_debug_status_flop  <= rx_b_debug_status  ;
  rx_r_debug_status_flop  <= rx_r_debug_status  ;
  rx_w_debug_status_flop  <= rx_w_debug_status  ;
  tx_ar_debug_status_flop <= tx_ar_debug_status ;
  tx_aw_debug_status_flop <= tx_aw_debug_status ;
  tx_b_debug_status_flop  <= tx_b_debug_status  ;
  tx_r_debug_status_flop  <= tx_r_debug_status  ;
  tx_w_debug_status_flop  <= tx_w_debug_status  ;
  user2_araddr_flop       <= user2_araddr       ;
  user2_awaddr_flop       <= user2_awaddr       ;
  user2_arlen_flop        <= user2_arlen        ;
  user2_awlen_flop        <= user2_awlen        ;
  user1_arready_flop      <= user1_arready      ;
  user1_awready_flop      <= user1_awready      ;
  user1_bvalid_flop       <= user1_bvalid       ;
  user1_rlast_flop        <= user1_rlast        ;
  user1_rvalid_flop       <= user1_rvalid       ;
  user1_wready_flop       <= user1_wready       ;
  user2_arvalid_flop      <= user2_arvalid      ;
  user2_awvalid_flop      <= user2_awvalid      ;
  user2_bready_flop       <= user2_bready       ;
  user2_rready_flop       <= user2_rready       ;
  user2_wlast_flop        <= user2_wlast        ;
  user2_wvalid_flop       <= user2_wvalid       ;
end

   /* two_axi_mm_chiplet.sv AUTO_TEMPLATE ".*_i\(.+\)"  (
    );
    */
   two_axi_mm_chiplet  two_axi_mm_chiplet
     (/*AUTOINST*/
      // Outputs
      .user1_arready			(user1_arready),
      .user1_awready			(user1_awready),
      .user1_wready			(user1_wready),
      .user1_rid			(user1_rid[3:0]),
      .user1_rdata			(user1_rdata[127:0]),
      .user1_rlast			(user1_rlast),
      .user1_rresp			(user1_rresp[1:0]),
      .user1_rvalid			(user1_rvalid),
      .user1_bid			(user1_bid[3:0]),
      .user1_bresp			(user1_bresp[1:0]),
      .user1_bvalid			(user1_bvalid),
      .user2_arid			(user2_arid[3:0]),
      .user2_arsize			(user2_arsize[2:0]),
      .user2_arlen			(user2_arlen[7:0]),
      .user2_arburst			(user2_arburst[1:0]),
      .user2_araddr			(user2_araddr[31:0]),
      .user2_arvalid			(user2_arvalid),
      .user2_awid			(user2_awid[3:0]),
      .user2_awsize			(user2_awsize[2:0]),
      .user2_awlen			(user2_awlen[7:0]),
      .user2_awburst			(user2_awburst[1:0]),
      .user2_awaddr			(user2_awaddr[31:0]),
      .user2_awvalid			(user2_awvalid),
      .user2_wid			(user2_wid[3:0]),
      .user2_wdata			(user2_wdata[127:0]),
      .user2_wstrb			(user2_wstrb[15:0]),
      .user2_wlast			(user2_wlast),
      .user2_wvalid			(user2_wvalid),
      .user2_rready			(user2_rready),
      .user2_bready			(user2_bready),
      .rx_ar_debug_status		(rx_ar_debug_status[31:0]),
      .rx_aw_debug_status		(rx_aw_debug_status[31:0]),
      .rx_b_debug_status		(rx_b_debug_status[31:0]),
      .rx_r_debug_status		(rx_r_debug_status[31:0]),
      .rx_w_debug_status		(rx_w_debug_status[31:0]),
      .tx_ar_debug_status		(tx_ar_debug_status[31:0]),
      .tx_aw_debug_status		(tx_aw_debug_status[31:0]),
      .tx_b_debug_status		(tx_b_debug_status[31:0]),
      .tx_r_debug_status		(tx_r_debug_status[31:0]),
      .tx_w_debug_status		(tx_w_debug_status[31:0]),
      // Inputs
      .clk_wr				(clk_wr),
      .rst_wr_n				(rst_wr_n),
      .m_gen2_mode			(m_gen2_mode),
      .user1_arid			(user1_arid[3:0]),
      .user1_arsize			(user1_arsize[2:0]),
      .user1_arlen			(user1_arlen[7:0]),
      .user1_arburst			(user1_arburst[1:0]),
      .user1_araddr			(user1_araddr[31:0]),
      .user1_arvalid			(user1_arvalid),
      .user1_awid			(user1_awid[3:0]),
      .user1_awsize			(user1_awsize[2:0]),
      .user1_awlen			(user1_awlen[7:0]),
      .user1_awburst			(user1_awburst[1:0]),
      .user1_awaddr			(user1_awaddr[31:0]),
      .user1_awvalid			(user1_awvalid),
      .user1_wid			(user1_wid[3:0]),
      .user1_wdata			(user1_wdata[127:0]),
      .user1_wstrb			(user1_wstrb[15:0]),
      .user1_wlast			(user1_wlast),
      .user1_wvalid			(user1_wvalid),
      .user1_rready			(user1_rready),
      .user1_bready			(user1_bready),
      .user2_arready			(user2_arready),
      .user2_awready			(user2_awready),
      .user2_wready			(user2_wready),
      .user2_rid			(user2_rid[3:0]),
      .user2_rdata			(user2_rdata[127:0]),
      .user2_rlast			(user2_rlast),
      .user2_rresp			(user2_rresp[1:0]),
      .user2_rvalid			(user2_rvalid),
      .user2_bid			(user2_bid[3:0]),
      .user2_bresp			(user2_bresp[1:0]),
      .user2_bvalid			(user2_bvalid));


endmodule // top //



// Local Variables:
// verilog-library-directories:("." "dut_rtl" )
// verilog-auto-inst-param-value:()
// End:
//
