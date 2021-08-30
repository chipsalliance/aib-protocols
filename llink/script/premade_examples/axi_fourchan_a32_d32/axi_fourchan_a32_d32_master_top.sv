module axi_fourchan_a32_d32_master_top  (
  input  logic              clk_wr              ,
  input  logic              rst_wr_n            ,

  // Control signals
  input  logic              tx_online           ,
  input  logic              rx_online           ,

  input  logic [7:0]        init_ch0_ar_credit  ,
  input  logic [7:0]        init_ch0_aw_credit  ,
  input  logic [7:0]        init_ch0_w_credit   ,
  input  logic [7:0]        init_ch1_ar_credit  ,
  input  logic [7:0]        init_ch1_aw_credit  ,
  input  logic [7:0]        init_ch1_w_credit   ,
  input  logic [7:0]        init_ch2_ar_credit  ,
  input  logic [7:0]        init_ch2_aw_credit  ,
  input  logic [7:0]        init_ch2_w_credit   ,
  input  logic [7:0]        init_ch3_ar_credit  ,
  input  logic [7:0]        init_ch3_aw_credit  ,
  input  logic [7:0]        init_ch3_w_credit   ,

  // PHY Interconnect
  output logic [319:  0]    tx_phy0             ,
  input  logic [319:  0]    rx_phy0             ,
  output logic [319:  0]    tx_phy1             ,
  input  logic [319:  0]    rx_phy1             ,

  // ch0_ar channel
  input  logic [  1:  0]    user0_arsize        ,
  input  logic [  7:  0]    user0_arlen         ,
  input  logic [  1:  0]    user0_arburst       ,
  input  logic [ 31:  0]    user0_araddr        ,
  input  logic              user0_arvalid       ,
  output logic              user0_arready       ,

  // ch0_aw channel
  input  logic [  1:  0]    user0_awsize        ,
  input  logic [  7:  0]    user0_awlen         ,
  input  logic [  1:  0]    user0_awburst       ,
  input  logic [ 31:  0]    user0_awaddr        ,
  input  logic              user0_awvalid       ,
  output logic              user0_awready       ,

  // ch0_w channel
  input  logic [ 31:  0]    user0_wdata         ,
  input  logic [ 15:  0]    user0_wstrb         ,
  input  logic              user0_wlast         ,
  input  logic              user0_wvalid        ,
  output logic              user0_wready        ,

  // ch0_r channel
  output logic [ 31:  0]    user0_rdata         ,
  output logic              user0_rlast         ,
  output logic [  1:  0]    user0_rresp         ,
  output logic              user0_rvalid        ,
  input  logic              user0_rready        ,

  // ch0_b channel
  output logic [  1:  0]    user0_bresp         ,
  output logic              user0_bvalid        ,
  input  logic              user0_bready        ,

  // ch1_ar channel
  input  logic [  1:  0]    user1_arsize        ,
  input  logic [  7:  0]    user1_arlen         ,
  input  logic [  1:  0]    user1_arburst       ,
  input  logic [ 31:  0]    user1_araddr        ,
  input  logic              user1_arvalid       ,
  output logic              user1_arready       ,

  // ch1_aw channel
  input  logic [  1:  0]    user1_awsize        ,
  input  logic [  7:  0]    user1_awlen         ,
  input  logic [  1:  0]    user1_awburst       ,
  input  logic [ 31:  0]    user1_awaddr        ,
  input  logic              user1_awvalid       ,
  output logic              user1_awready       ,

  // ch1_w channel
  input  logic [ 31:  0]    user1_wdata         ,
  input  logic [ 15:  0]    user1_wstrb         ,
  input  logic              user1_wlast         ,
  input  logic              user1_wvalid        ,
  output logic              user1_wready        ,

  // ch1_r channel
  output logic [ 31:  0]    user1_rdata         ,
  output logic              user1_rlast         ,
  output logic [  1:  0]    user1_rresp         ,
  output logic              user1_rvalid        ,
  input  logic              user1_rready        ,

  // ch1_b channel
  output logic [  1:  0]    user1_bresp         ,
  output logic              user1_bvalid        ,
  input  logic              user1_bready        ,

  // ch2_ar channel
  input  logic [  1:  0]    user2_arsize        ,
  input  logic [  7:  0]    user2_arlen         ,
  input  logic [  1:  0]    user2_arburst       ,
  input  logic [ 31:  0]    user2_araddr        ,
  input  logic              user2_arvalid       ,
  output logic              user2_arready       ,

  // ch2_aw channel
  input  logic [  1:  0]    user2_awsize        ,
  input  logic [  7:  0]    user2_awlen         ,
  input  logic [  1:  0]    user2_awburst       ,
  input  logic [ 31:  0]    user2_awaddr        ,
  input  logic              user2_awvalid       ,
  output logic              user2_awready       ,

  // ch2_w channel
  input  logic [ 31:  0]    user2_wdata         ,
  input  logic [ 15:  0]    user2_wstrb         ,
  input  logic              user2_wlast         ,
  input  logic              user2_wvalid        ,
  output logic              user2_wready        ,

  // ch2_r channel
  output logic [ 31:  0]    user2_rdata         ,
  output logic              user2_rlast         ,
  output logic [  1:  0]    user2_rresp         ,
  output logic              user2_rvalid        ,
  input  logic              user2_rready        ,

  // ch2_b channel
  output logic [  1:  0]    user2_bresp         ,
  output logic              user2_bvalid        ,
  input  logic              user2_bready        ,

  // ch3_ar channel
  input  logic [  1:  0]    user3_arsize        ,
  input  logic [  7:  0]    user3_arlen         ,
  input  logic [  1:  0]    user3_arburst       ,
  input  logic [ 31:  0]    user3_araddr        ,
  input  logic              user3_arvalid       ,
  output logic              user3_arready       ,

  // ch3_aw channel
  input  logic [  1:  0]    user3_awsize        ,
  input  logic [  7:  0]    user3_awlen         ,
  input  logic [  1:  0]    user3_awburst       ,
  input  logic [ 31:  0]    user3_awaddr        ,
  input  logic              user3_awvalid       ,
  output logic              user3_awready       ,

  // ch3_w channel
  input  logic [ 31:  0]    user3_wdata         ,
  input  logic [ 15:  0]    user3_wstrb         ,
  input  logic              user3_wlast         ,
  input  logic              user3_wvalid        ,
  output logic              user3_wready        ,

  // ch3_r channel
  output logic [ 31:  0]    user3_rdata         ,
  output logic              user3_rlast         ,
  output logic [  1:  0]    user3_rresp         ,
  output logic              user3_rvalid        ,
  input  logic              user3_rready        ,

  // ch3_b channel
  output logic [  1:  0]    user3_bresp         ,
  output logic              user3_bvalid        ,
  input  logic              user3_bready        ,

  // Debug Status Outputs
  output logic [31:0]       tx_ch0_ar_debug_status,
  output logic [31:0]       tx_ch0_aw_debug_status,
  output logic [31:0]       tx_ch0_w_debug_status,
  output logic [31:0]       rx_ch0_r_debug_status,
  output logic [31:0]       rx_ch0_b_debug_status,
  output logic [31:0]       tx_ch1_ar_debug_status,
  output logic [31:0]       tx_ch1_aw_debug_status,
  output logic [31:0]       tx_ch1_w_debug_status,
  output logic [31:0]       rx_ch1_r_debug_status,
  output logic [31:0]       rx_ch1_b_debug_status,
  output logic [31:0]       tx_ch2_ar_debug_status,
  output logic [31:0]       tx_ch2_aw_debug_status,
  output logic [31:0]       tx_ch2_w_debug_status,
  output logic [31:0]       rx_ch2_r_debug_status,
  output logic [31:0]       rx_ch2_b_debug_status,
  output logic [31:0]       tx_ch3_ar_debug_status,
  output logic [31:0]       tx_ch3_aw_debug_status,
  output logic [31:0]       tx_ch3_w_debug_status,
  output logic [31:0]       rx_ch3_r_debug_status,
  output logic [31:0]       rx_ch3_b_debug_status,

  // Configuration
  input  logic              m_gen2_mode         ,

  input  logic [  3:  0]    tx_mrk_userbit      ,
  input  logic              tx_stb_userbit      ,

  input  logic [7:0]        delay_x_value       , // In single channel, no CA, this is Word Alignment Time. In multie-channel, this is 0 and RX_ONLINE tied to channel_alignment_done
  input  logic [7:0]        delay_xz_value      ,
  input  logic [7:0]        delay_yz_value      

);

////////////////////////////////////////////////////////////
// Interconnect Wires
  logic                                          tx_ch0_ar_pushbit             ;
  logic                                          user_ch0_ar_valid             ;
  logic [ 43:  0]                                tx_ch0_ar_data                ;
  logic [ 43:  0]                                txfifo_ch0_ar_data            ;
  logic                                          rx_ch0_ar_credit              ;
  logic                                          user_ch0_ar_ready             ;
  logic                                          tx_ch0_ar_pop_ovrd            ;

  logic                                          tx_ch0_aw_pushbit             ;
  logic                                          user_ch0_aw_valid             ;
  logic [ 43:  0]                                tx_ch0_aw_data                ;
  logic [ 43:  0]                                txfifo_ch0_aw_data            ;
  logic                                          rx_ch0_aw_credit              ;
  logic                                          user_ch0_aw_ready             ;
  logic                                          tx_ch0_aw_pop_ovrd            ;

  logic                                          tx_ch0_w_pushbit              ;
  logic                                          user_ch0_w_valid              ;
  logic [ 48:  0]                                tx_ch0_w_data                 ;
  logic [ 48:  0]                                txfifo_ch0_w_data             ;
  logic                                          rx_ch0_w_credit               ;
  logic                                          user_ch0_w_ready              ;
  logic                                          tx_ch0_w_pop_ovrd             ;

  logic                                          rx_ch0_r_pushbit              ;
  logic                                          user_ch0_r_valid              ;
  logic [ 34:  0]                                rx_ch0_r_data                 ;
  logic [ 34:  0]                                rxfifo_ch0_r_data             ;
  logic                                          tx_ch0_r_credit               ;
  logic                                          user_ch0_r_ready              ;
  logic                                          rx_ch0_r_push_ovrd            ;

  logic                                          rx_ch0_b_pushbit              ;
  logic                                          user_ch0_b_valid              ;
  logic [  1:  0]                                rx_ch0_b_data                 ;
  logic [  1:  0]                                rxfifo_ch0_b_data             ;
  logic                                          tx_ch0_b_credit               ;
  logic                                          user_ch0_b_ready              ;
  logic                                          rx_ch0_b_push_ovrd            ;

  logic                                          tx_ch1_ar_pushbit             ;
  logic                                          user_ch1_ar_valid             ;
  logic [ 43:  0]                                tx_ch1_ar_data                ;
  logic [ 43:  0]                                txfifo_ch1_ar_data            ;
  logic                                          rx_ch1_ar_credit              ;
  logic                                          user_ch1_ar_ready             ;
  logic                                          tx_ch1_ar_pop_ovrd            ;

  logic                                          tx_ch1_aw_pushbit             ;
  logic                                          user_ch1_aw_valid             ;
  logic [ 43:  0]                                tx_ch1_aw_data                ;
  logic [ 43:  0]                                txfifo_ch1_aw_data            ;
  logic                                          rx_ch1_aw_credit              ;
  logic                                          user_ch1_aw_ready             ;
  logic                                          tx_ch1_aw_pop_ovrd            ;

  logic                                          tx_ch1_w_pushbit              ;
  logic                                          user_ch1_w_valid              ;
  logic [ 48:  0]                                tx_ch1_w_data                 ;
  logic [ 48:  0]                                txfifo_ch1_w_data             ;
  logic                                          rx_ch1_w_credit               ;
  logic                                          user_ch1_w_ready              ;
  logic                                          tx_ch1_w_pop_ovrd             ;

  logic                                          rx_ch1_r_pushbit              ;
  logic                                          user_ch1_r_valid              ;
  logic [ 34:  0]                                rx_ch1_r_data                 ;
  logic [ 34:  0]                                rxfifo_ch1_r_data             ;
  logic                                          tx_ch1_r_credit               ;
  logic                                          user_ch1_r_ready              ;
  logic                                          rx_ch1_r_push_ovrd            ;

  logic                                          rx_ch1_b_pushbit              ;
  logic                                          user_ch1_b_valid              ;
  logic [  1:  0]                                rx_ch1_b_data                 ;
  logic [  1:  0]                                rxfifo_ch1_b_data             ;
  logic                                          tx_ch1_b_credit               ;
  logic                                          user_ch1_b_ready              ;
  logic                                          rx_ch1_b_push_ovrd            ;

  logic                                          tx_ch2_ar_pushbit             ;
  logic                                          user_ch2_ar_valid             ;
  logic [ 43:  0]                                tx_ch2_ar_data                ;
  logic [ 43:  0]                                txfifo_ch2_ar_data            ;
  logic                                          rx_ch2_ar_credit              ;
  logic                                          user_ch2_ar_ready             ;
  logic                                          tx_ch2_ar_pop_ovrd            ;

  logic                                          tx_ch2_aw_pushbit             ;
  logic                                          user_ch2_aw_valid             ;
  logic [ 43:  0]                                tx_ch2_aw_data                ;
  logic [ 43:  0]                                txfifo_ch2_aw_data            ;
  logic                                          rx_ch2_aw_credit              ;
  logic                                          user_ch2_aw_ready             ;
  logic                                          tx_ch2_aw_pop_ovrd            ;

  logic                                          tx_ch2_w_pushbit              ;
  logic                                          user_ch2_w_valid              ;
  logic [ 48:  0]                                tx_ch2_w_data                 ;
  logic [ 48:  0]                                txfifo_ch2_w_data             ;
  logic                                          rx_ch2_w_credit               ;
  logic                                          user_ch2_w_ready              ;
  logic                                          tx_ch2_w_pop_ovrd             ;

  logic                                          rx_ch2_r_pushbit              ;
  logic                                          user_ch2_r_valid              ;
  logic [ 34:  0]                                rx_ch2_r_data                 ;
  logic [ 34:  0]                                rxfifo_ch2_r_data             ;
  logic                                          tx_ch2_r_credit               ;
  logic                                          user_ch2_r_ready              ;
  logic                                          rx_ch2_r_push_ovrd            ;

  logic                                          rx_ch2_b_pushbit              ;
  logic                                          user_ch2_b_valid              ;
  logic [  1:  0]                                rx_ch2_b_data                 ;
  logic [  1:  0]                                rxfifo_ch2_b_data             ;
  logic                                          tx_ch2_b_credit               ;
  logic                                          user_ch2_b_ready              ;
  logic                                          rx_ch2_b_push_ovrd            ;

  logic                                          tx_ch3_ar_pushbit             ;
  logic                                          user_ch3_ar_valid             ;
  logic [ 43:  0]                                tx_ch3_ar_data                ;
  logic [ 43:  0]                                txfifo_ch3_ar_data            ;
  logic                                          rx_ch3_ar_credit              ;
  logic                                          user_ch3_ar_ready             ;
  logic                                          tx_ch3_ar_pop_ovrd            ;

  logic                                          tx_ch3_aw_pushbit             ;
  logic                                          user_ch3_aw_valid             ;
  logic [ 43:  0]                                tx_ch3_aw_data                ;
  logic [ 43:  0]                                txfifo_ch3_aw_data            ;
  logic                                          rx_ch3_aw_credit              ;
  logic                                          user_ch3_aw_ready             ;
  logic                                          tx_ch3_aw_pop_ovrd            ;

  logic                                          tx_ch3_w_pushbit              ;
  logic                                          user_ch3_w_valid              ;
  logic [ 48:  0]                                tx_ch3_w_data                 ;
  logic [ 48:  0]                                txfifo_ch3_w_data             ;
  logic                                          rx_ch3_w_credit               ;
  logic                                          user_ch3_w_ready              ;
  logic                                          tx_ch3_w_pop_ovrd             ;

  logic                                          rx_ch3_r_pushbit              ;
  logic                                          user_ch3_r_valid              ;
  logic [ 34:  0]                                rx_ch3_r_data                 ;
  logic [ 34:  0]                                rxfifo_ch3_r_data             ;
  logic                                          tx_ch3_r_credit               ;
  logic                                          user_ch3_r_ready              ;
  logic                                          rx_ch3_r_push_ovrd            ;

  logic                                          rx_ch3_b_pushbit              ;
  logic                                          user_ch3_b_valid              ;
  logic [  1:  0]                                rx_ch3_b_data                 ;
  logic [  1:  0]                                rxfifo_ch3_b_data             ;
  logic                                          tx_ch3_b_credit               ;
  logic                                          user_ch3_b_ready              ;
  logic                                          rx_ch3_b_push_ovrd            ;

  logic [  3:  0]                                tx_auto_mrk_userbit           ;
  logic                                          tx_auto_stb_userbit           ;
  logic                                          tx_online_delay               ;
  logic                                          rx_online_delay               ;


// Interconnect Wires
////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Auto Sync

   ll_auto_sync #(.MARKER_WIDTH(4)) ll_auto_sync_i
     (// Outputs
      .tx_online_delay                  (tx_online_delay),
      .tx_auto_mrk_userbit              (tx_auto_mrk_userbit),
      .tx_auto_stb_userbit              (tx_auto_stb_userbit),
      .rx_online_delay                  (rx_online_delay),
      // Inputs
      .clk_wr                           (clk_wr),
      .rst_wr_n                         (rst_wr_n),
      .tx_online                        (tx_online),
      .delay_xz_value                   (delay_xz_value[7:0]),
      .delay_yz_value                   (delay_yz_value[7:0]),
      .tx_mrk_userbit                   (tx_mrk_userbit),
      .tx_stb_userbit                   (tx_stb_userbit),
      .rx_online                        (rx_online),
      .delay_x_value                    (delay_x_value[7:0]));

// Auto Sync
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Logic Link Instantiation

      ll_transmit #(.WIDTH(44), .DEPTH(8'd1)) ll_transmit_ich0_ar
        (// Outputs
         .user_i_ready                     (user_ch0_ar_ready),
         .tx_i_data                        (tx_ch0_ar_data[43:0]),
         .tx_i_pushbit                     (tx_ch0_ar_pushbit),
         .tx_i_debug_status                (tx_ch0_ar_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch0_ar_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch0_ar_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch0_ar_data[43:0]),
         .user_i_valid                     (user_ch0_ar_valid),
         .rx_i_credit                      (rx_ch0_ar_credit));

      ll_transmit #(.WIDTH(44), .DEPTH(8'd1)) ll_transmit_ich0_aw
        (// Outputs
         .user_i_ready                     (user_ch0_aw_ready),
         .tx_i_data                        (tx_ch0_aw_data[43:0]),
         .tx_i_pushbit                     (tx_ch0_aw_pushbit),
         .tx_i_debug_status                (tx_ch0_aw_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch0_aw_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch0_aw_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch0_aw_data[43:0]),
         .user_i_valid                     (user_ch0_aw_valid),
         .rx_i_credit                      (rx_ch0_aw_credit));

      ll_transmit #(.WIDTH(49), .DEPTH(8'd1)) ll_transmit_ich0_w
        (// Outputs
         .user_i_ready                     (user_ch0_w_ready),
         .tx_i_data                        (tx_ch0_w_data[48:0]),
         .tx_i_pushbit                     (tx_ch0_w_pushbit),
         .tx_i_debug_status                (tx_ch0_w_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch0_w_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch0_w_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch0_w_data[48:0]),
         .user_i_valid                     (user_ch0_w_valid),
         .rx_i_credit                      (rx_ch0_w_credit));

      ll_receive #(.WIDTH(35), .DEPTH(8'd128)) ll_receive_ich0_r
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch0_r_data[34:0]),
         .user_i_valid                     (user_ch0_r_valid),
         .tx_i_credit                      (tx_ch0_r_credit),
         .rx_i_debug_status                (rx_ch0_r_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch0_r_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch0_r_data[34:0]),
         .rx_i_pushbit                     (rx_ch0_r_pushbit),
         .user_i_ready                     (user_ch0_r_ready));

      ll_receive #(.WIDTH(2), .DEPTH(8'd8)) ll_receive_ich0_b
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch0_b_data[1:0]),
         .user_i_valid                     (user_ch0_b_valid),
         .tx_i_credit                      (tx_ch0_b_credit),
         .rx_i_debug_status                (rx_ch0_b_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch0_b_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch0_b_data[1:0]),
         .rx_i_pushbit                     (rx_ch0_b_pushbit),
         .user_i_ready                     (user_ch0_b_ready));

      ll_transmit #(.WIDTH(44), .DEPTH(8'd1)) ll_transmit_ich1_ar
        (// Outputs
         .user_i_ready                     (user_ch1_ar_ready),
         .tx_i_data                        (tx_ch1_ar_data[43:0]),
         .tx_i_pushbit                     (tx_ch1_ar_pushbit),
         .tx_i_debug_status                (tx_ch1_ar_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch1_ar_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch1_ar_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch1_ar_data[43:0]),
         .user_i_valid                     (user_ch1_ar_valid),
         .rx_i_credit                      (rx_ch1_ar_credit));

      ll_transmit #(.WIDTH(44), .DEPTH(8'd1)) ll_transmit_ich1_aw
        (// Outputs
         .user_i_ready                     (user_ch1_aw_ready),
         .tx_i_data                        (tx_ch1_aw_data[43:0]),
         .tx_i_pushbit                     (tx_ch1_aw_pushbit),
         .tx_i_debug_status                (tx_ch1_aw_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch1_aw_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch1_aw_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch1_aw_data[43:0]),
         .user_i_valid                     (user_ch1_aw_valid),
         .rx_i_credit                      (rx_ch1_aw_credit));

      ll_transmit #(.WIDTH(49), .DEPTH(8'd1)) ll_transmit_ich1_w
        (// Outputs
         .user_i_ready                     (user_ch1_w_ready),
         .tx_i_data                        (tx_ch1_w_data[48:0]),
         .tx_i_pushbit                     (tx_ch1_w_pushbit),
         .tx_i_debug_status                (tx_ch1_w_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch1_w_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch1_w_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch1_w_data[48:0]),
         .user_i_valid                     (user_ch1_w_valid),
         .rx_i_credit                      (rx_ch1_w_credit));

      ll_receive #(.WIDTH(35), .DEPTH(8'd128)) ll_receive_ich1_r
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch1_r_data[34:0]),
         .user_i_valid                     (user_ch1_r_valid),
         .tx_i_credit                      (tx_ch1_r_credit),
         .rx_i_debug_status                (rx_ch1_r_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch1_r_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch1_r_data[34:0]),
         .rx_i_pushbit                     (rx_ch1_r_pushbit),
         .user_i_ready                     (user_ch1_r_ready));

      ll_receive #(.WIDTH(2), .DEPTH(8'd8)) ll_receive_ich1_b
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch1_b_data[1:0]),
         .user_i_valid                     (user_ch1_b_valid),
         .tx_i_credit                      (tx_ch1_b_credit),
         .rx_i_debug_status                (rx_ch1_b_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch1_b_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch1_b_data[1:0]),
         .rx_i_pushbit                     (rx_ch1_b_pushbit),
         .user_i_ready                     (user_ch1_b_ready));

      ll_transmit #(.WIDTH(44), .DEPTH(8'd1)) ll_transmit_ich2_ar
        (// Outputs
         .user_i_ready                     (user_ch2_ar_ready),
         .tx_i_data                        (tx_ch2_ar_data[43:0]),
         .tx_i_pushbit                     (tx_ch2_ar_pushbit),
         .tx_i_debug_status                (tx_ch2_ar_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch2_ar_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch2_ar_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch2_ar_data[43:0]),
         .user_i_valid                     (user_ch2_ar_valid),
         .rx_i_credit                      (rx_ch2_ar_credit));

      ll_transmit #(.WIDTH(44), .DEPTH(8'd1)) ll_transmit_ich2_aw
        (// Outputs
         .user_i_ready                     (user_ch2_aw_ready),
         .tx_i_data                        (tx_ch2_aw_data[43:0]),
         .tx_i_pushbit                     (tx_ch2_aw_pushbit),
         .tx_i_debug_status                (tx_ch2_aw_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch2_aw_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch2_aw_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch2_aw_data[43:0]),
         .user_i_valid                     (user_ch2_aw_valid),
         .rx_i_credit                      (rx_ch2_aw_credit));

      ll_transmit #(.WIDTH(49), .DEPTH(8'd1)) ll_transmit_ich2_w
        (// Outputs
         .user_i_ready                     (user_ch2_w_ready),
         .tx_i_data                        (tx_ch2_w_data[48:0]),
         .tx_i_pushbit                     (tx_ch2_w_pushbit),
         .tx_i_debug_status                (tx_ch2_w_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch2_w_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch2_w_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch2_w_data[48:0]),
         .user_i_valid                     (user_ch2_w_valid),
         .rx_i_credit                      (rx_ch2_w_credit));

      ll_receive #(.WIDTH(35), .DEPTH(8'd128)) ll_receive_ich2_r
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch2_r_data[34:0]),
         .user_i_valid                     (user_ch2_r_valid),
         .tx_i_credit                      (tx_ch2_r_credit),
         .rx_i_debug_status                (rx_ch2_r_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch2_r_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch2_r_data[34:0]),
         .rx_i_pushbit                     (rx_ch2_r_pushbit),
         .user_i_ready                     (user_ch2_r_ready));

      ll_receive #(.WIDTH(2), .DEPTH(8'd8)) ll_receive_ich2_b
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch2_b_data[1:0]),
         .user_i_valid                     (user_ch2_b_valid),
         .tx_i_credit                      (tx_ch2_b_credit),
         .rx_i_debug_status                (rx_ch2_b_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch2_b_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch2_b_data[1:0]),
         .rx_i_pushbit                     (rx_ch2_b_pushbit),
         .user_i_ready                     (user_ch2_b_ready));

      ll_transmit #(.WIDTH(44), .DEPTH(8'd1)) ll_transmit_ich3_ar
        (// Outputs
         .user_i_ready                     (user_ch3_ar_ready),
         .tx_i_data                        (tx_ch3_ar_data[43:0]),
         .tx_i_pushbit                     (tx_ch3_ar_pushbit),
         .tx_i_debug_status                (tx_ch3_ar_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch3_ar_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch3_ar_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch3_ar_data[43:0]),
         .user_i_valid                     (user_ch3_ar_valid),
         .rx_i_credit                      (rx_ch3_ar_credit));

      ll_transmit #(.WIDTH(44), .DEPTH(8'd1)) ll_transmit_ich3_aw
        (// Outputs
         .user_i_ready                     (user_ch3_aw_ready),
         .tx_i_data                        (tx_ch3_aw_data[43:0]),
         .tx_i_pushbit                     (tx_ch3_aw_pushbit),
         .tx_i_debug_status                (tx_ch3_aw_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch3_aw_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch3_aw_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch3_aw_data[43:0]),
         .user_i_valid                     (user_ch3_aw_valid),
         .rx_i_credit                      (rx_ch3_aw_credit));

      ll_transmit #(.WIDTH(49), .DEPTH(8'd1)) ll_transmit_ich3_w
        (// Outputs
         .user_i_ready                     (user_ch3_w_ready),
         .tx_i_data                        (tx_ch3_w_data[48:0]),
         .tx_i_pushbit                     (tx_ch3_w_pushbit),
         .tx_i_debug_status                (tx_ch3_w_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch3_w_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch3_w_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch3_w_data[48:0]),
         .user_i_valid                     (user_ch3_w_valid),
         .rx_i_credit                      (rx_ch3_w_credit));

      ll_receive #(.WIDTH(35), .DEPTH(8'd128)) ll_receive_ich3_r
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch3_r_data[34:0]),
         .user_i_valid                     (user_ch3_r_valid),
         .tx_i_credit                      (tx_ch3_r_credit),
         .rx_i_debug_status                (rx_ch3_r_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch3_r_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch3_r_data[34:0]),
         .rx_i_pushbit                     (rx_ch3_r_pushbit),
         .user_i_ready                     (user_ch3_r_ready));

      ll_receive #(.WIDTH(2), .DEPTH(8'd8)) ll_receive_ich3_b
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch3_b_data[1:0]),
         .user_i_valid                     (user_ch3_b_valid),
         .tx_i_credit                      (tx_ch3_b_credit),
         .rx_i_debug_status                (rx_ch3_b_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch3_b_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch3_b_data[1:0]),
         .rx_i_pushbit                     (rx_ch3_b_pushbit),
         .user_i_ready                     (user_ch3_b_ready));

// Logic Link Instantiation
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// User Interface

      axi_fourchan_a32_d32_master_name axi_fourchan_a32_d32_master_name
      (
         .user0_arsize                     (user0_arsize[1:0]),
         .user0_arlen                      (user0_arlen[7:0]),
         .user0_arburst                    (user0_arburst[1:0]),
         .user0_araddr                     (user0_araddr[31:0]),
         .user0_arvalid                    (user0_arvalid),
         .user0_arready                    (user0_arready),
         .user0_awsize                     (user0_awsize[1:0]),
         .user0_awlen                      (user0_awlen[7:0]),
         .user0_awburst                    (user0_awburst[1:0]),
         .user0_awaddr                     (user0_awaddr[31:0]),
         .user0_awvalid                    (user0_awvalid),
         .user0_awready                    (user0_awready),
         .user0_wdata                      (user0_wdata[31:0]),
         .user0_wstrb                      (user0_wstrb[15:0]),
         .user0_wlast                      (user0_wlast),
         .user0_wvalid                     (user0_wvalid),
         .user0_wready                     (user0_wready),
         .user0_rdata                      (user0_rdata[31:0]),
         .user0_rlast                      (user0_rlast),
         .user0_rresp                      (user0_rresp[1:0]),
         .user0_rvalid                     (user0_rvalid),
         .user0_rready                     (user0_rready),
         .user0_bresp                      (user0_bresp[1:0]),
         .user0_bvalid                     (user0_bvalid),
         .user0_bready                     (user0_bready),
         .user1_arsize                     (user1_arsize[1:0]),
         .user1_arlen                      (user1_arlen[7:0]),
         .user1_arburst                    (user1_arburst[1:0]),
         .user1_araddr                     (user1_araddr[31:0]),
         .user1_arvalid                    (user1_arvalid),
         .user1_arready                    (user1_arready),
         .user1_awsize                     (user1_awsize[1:0]),
         .user1_awlen                      (user1_awlen[7:0]),
         .user1_awburst                    (user1_awburst[1:0]),
         .user1_awaddr                     (user1_awaddr[31:0]),
         .user1_awvalid                    (user1_awvalid),
         .user1_awready                    (user1_awready),
         .user1_wdata                      (user1_wdata[31:0]),
         .user1_wstrb                      (user1_wstrb[15:0]),
         .user1_wlast                      (user1_wlast),
         .user1_wvalid                     (user1_wvalid),
         .user1_wready                     (user1_wready),
         .user1_rdata                      (user1_rdata[31:0]),
         .user1_rlast                      (user1_rlast),
         .user1_rresp                      (user1_rresp[1:0]),
         .user1_rvalid                     (user1_rvalid),
         .user1_rready                     (user1_rready),
         .user1_bresp                      (user1_bresp[1:0]),
         .user1_bvalid                     (user1_bvalid),
         .user1_bready                     (user1_bready),
         .user2_arsize                     (user2_arsize[1:0]),
         .user2_arlen                      (user2_arlen[7:0]),
         .user2_arburst                    (user2_arburst[1:0]),
         .user2_araddr                     (user2_araddr[31:0]),
         .user2_arvalid                    (user2_arvalid),
         .user2_arready                    (user2_arready),
         .user2_awsize                     (user2_awsize[1:0]),
         .user2_awlen                      (user2_awlen[7:0]),
         .user2_awburst                    (user2_awburst[1:0]),
         .user2_awaddr                     (user2_awaddr[31:0]),
         .user2_awvalid                    (user2_awvalid),
         .user2_awready                    (user2_awready),
         .user2_wdata                      (user2_wdata[31:0]),
         .user2_wstrb                      (user2_wstrb[15:0]),
         .user2_wlast                      (user2_wlast),
         .user2_wvalid                     (user2_wvalid),
         .user2_wready                     (user2_wready),
         .user2_rdata                      (user2_rdata[31:0]),
         .user2_rlast                      (user2_rlast),
         .user2_rresp                      (user2_rresp[1:0]),
         .user2_rvalid                     (user2_rvalid),
         .user2_rready                     (user2_rready),
         .user2_bresp                      (user2_bresp[1:0]),
         .user2_bvalid                     (user2_bvalid),
         .user2_bready                     (user2_bready),
         .user3_arsize                     (user3_arsize[1:0]),
         .user3_arlen                      (user3_arlen[7:0]),
         .user3_arburst                    (user3_arburst[1:0]),
         .user3_araddr                     (user3_araddr[31:0]),
         .user3_arvalid                    (user3_arvalid),
         .user3_arready                    (user3_arready),
         .user3_awsize                     (user3_awsize[1:0]),
         .user3_awlen                      (user3_awlen[7:0]),
         .user3_awburst                    (user3_awburst[1:0]),
         .user3_awaddr                     (user3_awaddr[31:0]),
         .user3_awvalid                    (user3_awvalid),
         .user3_awready                    (user3_awready),
         .user3_wdata                      (user3_wdata[31:0]),
         .user3_wstrb                      (user3_wstrb[15:0]),
         .user3_wlast                      (user3_wlast),
         .user3_wvalid                     (user3_wvalid),
         .user3_wready                     (user3_wready),
         .user3_rdata                      (user3_rdata[31:0]),
         .user3_rlast                      (user3_rlast),
         .user3_rresp                      (user3_rresp[1:0]),
         .user3_rvalid                     (user3_rvalid),
         .user3_rready                     (user3_rready),
         .user3_bresp                      (user3_bresp[1:0]),
         .user3_bvalid                     (user3_bvalid),
         .user3_bready                     (user3_bready),

         .user_ch0_ar_valid                (user_ch0_ar_valid),
         .txfifo_ch0_ar_data               (txfifo_ch0_ar_data[43:0]),
         .user_ch0_ar_ready                (user_ch0_ar_ready),
         .user_ch0_aw_valid                (user_ch0_aw_valid),
         .txfifo_ch0_aw_data               (txfifo_ch0_aw_data[43:0]),
         .user_ch0_aw_ready                (user_ch0_aw_ready),
         .user_ch0_w_valid                 (user_ch0_w_valid),
         .txfifo_ch0_w_data                (txfifo_ch0_w_data[48:0]),
         .user_ch0_w_ready                 (user_ch0_w_ready),
         .user_ch0_r_valid                 (user_ch0_r_valid),
         .rxfifo_ch0_r_data                (rxfifo_ch0_r_data[34:0]),
         .user_ch0_r_ready                 (user_ch0_r_ready),
         .user_ch0_b_valid                 (user_ch0_b_valid),
         .rxfifo_ch0_b_data                (rxfifo_ch0_b_data[1:0]),
         .user_ch0_b_ready                 (user_ch0_b_ready),
         .user_ch1_ar_valid                (user_ch1_ar_valid),
         .txfifo_ch1_ar_data               (txfifo_ch1_ar_data[43:0]),
         .user_ch1_ar_ready                (user_ch1_ar_ready),
         .user_ch1_aw_valid                (user_ch1_aw_valid),
         .txfifo_ch1_aw_data               (txfifo_ch1_aw_data[43:0]),
         .user_ch1_aw_ready                (user_ch1_aw_ready),
         .user_ch1_w_valid                 (user_ch1_w_valid),
         .txfifo_ch1_w_data                (txfifo_ch1_w_data[48:0]),
         .user_ch1_w_ready                 (user_ch1_w_ready),
         .user_ch1_r_valid                 (user_ch1_r_valid),
         .rxfifo_ch1_r_data                (rxfifo_ch1_r_data[34:0]),
         .user_ch1_r_ready                 (user_ch1_r_ready),
         .user_ch1_b_valid                 (user_ch1_b_valid),
         .rxfifo_ch1_b_data                (rxfifo_ch1_b_data[1:0]),
         .user_ch1_b_ready                 (user_ch1_b_ready),
         .user_ch2_ar_valid                (user_ch2_ar_valid),
         .txfifo_ch2_ar_data               (txfifo_ch2_ar_data[43:0]),
         .user_ch2_ar_ready                (user_ch2_ar_ready),
         .user_ch2_aw_valid                (user_ch2_aw_valid),
         .txfifo_ch2_aw_data               (txfifo_ch2_aw_data[43:0]),
         .user_ch2_aw_ready                (user_ch2_aw_ready),
         .user_ch2_w_valid                 (user_ch2_w_valid),
         .txfifo_ch2_w_data                (txfifo_ch2_w_data[48:0]),
         .user_ch2_w_ready                 (user_ch2_w_ready),
         .user_ch2_r_valid                 (user_ch2_r_valid),
         .rxfifo_ch2_r_data                (rxfifo_ch2_r_data[34:0]),
         .user_ch2_r_ready                 (user_ch2_r_ready),
         .user_ch2_b_valid                 (user_ch2_b_valid),
         .rxfifo_ch2_b_data                (rxfifo_ch2_b_data[1:0]),
         .user_ch2_b_ready                 (user_ch2_b_ready),
         .user_ch3_ar_valid                (user_ch3_ar_valid),
         .txfifo_ch3_ar_data               (txfifo_ch3_ar_data[43:0]),
         .user_ch3_ar_ready                (user_ch3_ar_ready),
         .user_ch3_aw_valid                (user_ch3_aw_valid),
         .txfifo_ch3_aw_data               (txfifo_ch3_aw_data[43:0]),
         .user_ch3_aw_ready                (user_ch3_aw_ready),
         .user_ch3_w_valid                 (user_ch3_w_valid),
         .txfifo_ch3_w_data                (txfifo_ch3_w_data[48:0]),
         .user_ch3_w_ready                 (user_ch3_w_ready),
         .user_ch3_r_valid                 (user_ch3_r_valid),
         .rxfifo_ch3_r_data                (rxfifo_ch3_r_data[34:0]),
         .user_ch3_r_ready                 (user_ch3_r_ready),
         .user_ch3_b_valid                 (user_ch3_b_valid),
         .rxfifo_ch3_b_data                (rxfifo_ch3_b_data[1:0]),
         .user_ch3_b_ready                 (user_ch3_b_ready),

         .m_gen2_mode                      (m_gen2_mode)


      );

                                                                  
// User Interface                                                 
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// PHY Interface

      axi_fourchan_a32_d32_master_concat axi_fourchan_a32_d32_master_concat
      (
         .tx_ch0_ar_data                   (tx_ch0_ar_data[43:0]),
         .tx_ch0_ar_pop_ovrd               (tx_ch0_ar_pop_ovrd),
         .tx_ch0_ar_pushbit                (tx_ch0_ar_pushbit),
         .rx_ch0_ar_credit                 (rx_ch0_ar_credit),
         .tx_ch0_aw_data                   (tx_ch0_aw_data[43:0]),
         .tx_ch0_aw_pop_ovrd               (tx_ch0_aw_pop_ovrd),
         .tx_ch0_aw_pushbit                (tx_ch0_aw_pushbit),
         .rx_ch0_aw_credit                 (rx_ch0_aw_credit),
         .tx_ch0_w_data                    (tx_ch0_w_data[48:0]),
         .tx_ch0_w_pop_ovrd                (tx_ch0_w_pop_ovrd),
         .tx_ch0_w_pushbit                 (tx_ch0_w_pushbit),
         .rx_ch0_w_credit                  (rx_ch0_w_credit),
         .rx_ch0_r_data                    (rx_ch0_r_data[34:0]),
         .rx_ch0_r_push_ovrd               (rx_ch0_r_push_ovrd),
         .rx_ch0_r_pushbit                 (rx_ch0_r_pushbit),
         .tx_ch0_r_credit                  (tx_ch0_r_credit),
         .rx_ch0_b_data                    (rx_ch0_b_data[1:0]),
         .rx_ch0_b_push_ovrd               (rx_ch0_b_push_ovrd),
         .rx_ch0_b_pushbit                 (rx_ch0_b_pushbit),
         .tx_ch0_b_credit                  (tx_ch0_b_credit),
         .tx_ch1_ar_data                   (tx_ch1_ar_data[43:0]),
         .tx_ch1_ar_pop_ovrd               (tx_ch1_ar_pop_ovrd),
         .tx_ch1_ar_pushbit                (tx_ch1_ar_pushbit),
         .rx_ch1_ar_credit                 (rx_ch1_ar_credit),
         .tx_ch1_aw_data                   (tx_ch1_aw_data[43:0]),
         .tx_ch1_aw_pop_ovrd               (tx_ch1_aw_pop_ovrd),
         .tx_ch1_aw_pushbit                (tx_ch1_aw_pushbit),
         .rx_ch1_aw_credit                 (rx_ch1_aw_credit),
         .tx_ch1_w_data                    (tx_ch1_w_data[48:0]),
         .tx_ch1_w_pop_ovrd                (tx_ch1_w_pop_ovrd),
         .tx_ch1_w_pushbit                 (tx_ch1_w_pushbit),
         .rx_ch1_w_credit                  (rx_ch1_w_credit),
         .rx_ch1_r_data                    (rx_ch1_r_data[34:0]),
         .rx_ch1_r_push_ovrd               (rx_ch1_r_push_ovrd),
         .rx_ch1_r_pushbit                 (rx_ch1_r_pushbit),
         .tx_ch1_r_credit                  (tx_ch1_r_credit),
         .rx_ch1_b_data                    (rx_ch1_b_data[1:0]),
         .rx_ch1_b_push_ovrd               (rx_ch1_b_push_ovrd),
         .rx_ch1_b_pushbit                 (rx_ch1_b_pushbit),
         .tx_ch1_b_credit                  (tx_ch1_b_credit),
         .tx_ch2_ar_data                   (tx_ch2_ar_data[43:0]),
         .tx_ch2_ar_pop_ovrd               (tx_ch2_ar_pop_ovrd),
         .tx_ch2_ar_pushbit                (tx_ch2_ar_pushbit),
         .rx_ch2_ar_credit                 (rx_ch2_ar_credit),
         .tx_ch2_aw_data                   (tx_ch2_aw_data[43:0]),
         .tx_ch2_aw_pop_ovrd               (tx_ch2_aw_pop_ovrd),
         .tx_ch2_aw_pushbit                (tx_ch2_aw_pushbit),
         .rx_ch2_aw_credit                 (rx_ch2_aw_credit),
         .tx_ch2_w_data                    (tx_ch2_w_data[48:0]),
         .tx_ch2_w_pop_ovrd                (tx_ch2_w_pop_ovrd),
         .tx_ch2_w_pushbit                 (tx_ch2_w_pushbit),
         .rx_ch2_w_credit                  (rx_ch2_w_credit),
         .rx_ch2_r_data                    (rx_ch2_r_data[34:0]),
         .rx_ch2_r_push_ovrd               (rx_ch2_r_push_ovrd),
         .rx_ch2_r_pushbit                 (rx_ch2_r_pushbit),
         .tx_ch2_r_credit                  (tx_ch2_r_credit),
         .rx_ch2_b_data                    (rx_ch2_b_data[1:0]),
         .rx_ch2_b_push_ovrd               (rx_ch2_b_push_ovrd),
         .rx_ch2_b_pushbit                 (rx_ch2_b_pushbit),
         .tx_ch2_b_credit                  (tx_ch2_b_credit),
         .tx_ch3_ar_data                   (tx_ch3_ar_data[43:0]),
         .tx_ch3_ar_pop_ovrd               (tx_ch3_ar_pop_ovrd),
         .tx_ch3_ar_pushbit                (tx_ch3_ar_pushbit),
         .rx_ch3_ar_credit                 (rx_ch3_ar_credit),
         .tx_ch3_aw_data                   (tx_ch3_aw_data[43:0]),
         .tx_ch3_aw_pop_ovrd               (tx_ch3_aw_pop_ovrd),
         .tx_ch3_aw_pushbit                (tx_ch3_aw_pushbit),
         .rx_ch3_aw_credit                 (rx_ch3_aw_credit),
         .tx_ch3_w_data                    (tx_ch3_w_data[48:0]),
         .tx_ch3_w_pop_ovrd                (tx_ch3_w_pop_ovrd),
         .tx_ch3_w_pushbit                 (tx_ch3_w_pushbit),
         .rx_ch3_w_credit                  (rx_ch3_w_credit),
         .rx_ch3_r_data                    (rx_ch3_r_data[34:0]),
         .rx_ch3_r_push_ovrd               (rx_ch3_r_push_ovrd),
         .rx_ch3_r_pushbit                 (rx_ch3_r_pushbit),
         .tx_ch3_r_credit                  (tx_ch3_r_credit),
         .rx_ch3_b_data                    (rx_ch3_b_data[1:0]),
         .rx_ch3_b_push_ovrd               (rx_ch3_b_push_ovrd),
         .rx_ch3_b_pushbit                 (rx_ch3_b_pushbit),
         .tx_ch3_b_credit                  (tx_ch3_b_credit),

         .tx_phy0                          (tx_phy0[319:0]),
         .rx_phy0                          (rx_phy0[319:0]),
         .tx_phy1                          (tx_phy1[319:0]),
         .rx_phy1                          (rx_phy1[319:0]),

         .clk_wr                           (clk_wr),
         .clk_rd                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rst_rd_n                         (rst_wr_n),

         .m_gen2_mode                      (m_gen2_mode),
         .tx_online                        (tx_online_delay),

         .tx_stb_userbit                   (tx_auto_stb_userbit),
         .tx_mrk_userbit                   (tx_auto_mrk_userbit)

      );

// PHY Interface
//////////////////////////////////////////////////////////////////


endmodule
