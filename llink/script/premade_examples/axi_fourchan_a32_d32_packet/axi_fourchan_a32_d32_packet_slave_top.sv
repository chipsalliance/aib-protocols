module axi_fourchan_a32_d32_packet_slave_top  (
  input  logic              clk_wr              ,
  input  logic              rst_wr_n            ,

  // Control signals
  input  logic              tx_online           ,
  input  logic              rx_online           ,

  input  logic [7:0]        init_ch0_r_credit   ,
  input  logic [7:0]        init_ch0_b_credit   ,
  input  logic [7:0]        init_ch1_r_credit   ,
  input  logic [7:0]        init_ch1_b_credit   ,
  input  logic [7:0]        init_ch2_r_credit   ,
  input  logic [7:0]        init_ch2_b_credit   ,
  input  logic [7:0]        init_ch3_r_credit   ,
  input  logic [7:0]        init_ch3_b_credit   ,

  // PHY Interconnect
  output logic [319:  0]    tx_phy0             ,
  input  logic [319:  0]    rx_phy0             ,

  // ch0_ar channel
  output logic [  1:  0]    user0_arsize        ,
  output logic [  7:  0]    user0_arlen         ,
  output logic [  1:  0]    user0_arburst       ,
  output logic [ 47:  0]    user0_araddr        ,
  output logic              user0_arvalid       ,
  input  logic              user0_arready       ,

  // ch0_aw channel
  output logic [  1:  0]    user0_awsize        ,
  output logic [  7:  0]    user0_awlen         ,
  output logic [  1:  0]    user0_awburst       ,
  output logic [ 47:  0]    user0_awaddr        ,
  output logic              user0_awvalid       ,
  input  logic              user0_awready       ,

  // ch0__w channel
  output logic [ 63:  0]    user0_wdata         ,
  output logic              user0_wlast         ,
  output logic              user0_wvalid        ,
  input  logic              user0_wready        ,

  // ch0_r channel
  input  logic [ 63:  0]    user0_rdata         ,
  input  logic              user0_rlast         ,
  input  logic [  1:  0]    user0_rresp         ,
  input  logic              user0_rvalid        ,
  output logic              user0_rready        ,

  // ch0_b channel
  input  logic [  1:  0]    user0_bresp         ,
  input  logic              user0_bvalid        ,
  output logic              user0_bready        ,

  // ch1_ar channel
  output logic [  1:  0]    user1_arsize        ,
  output logic [  7:  0]    user1_arlen         ,
  output logic [  1:  0]    user1_arburst       ,
  output logic [ 47:  0]    user1_araddr        ,
  output logic              user1_arvalid       ,
  input  logic              user1_arready       ,

  // ch1_aw channel
  output logic [  1:  0]    user1_awsize        ,
  output logic [  7:  0]    user1_awlen         ,
  output logic [  1:  0]    user1_awburst       ,
  output logic [ 47:  0]    user1_awaddr        ,
  output logic              user1_awvalid       ,
  input  logic              user1_awready       ,

  // ch1__w channel
  output logic [ 63:  0]    user1_wdata         ,
  output logic              user1_wlast         ,
  output logic              user1_wvalid        ,
  input  logic              user1_wready        ,

  // ch1_r channel
  input  logic [ 63:  0]    user1_rdata         ,
  input  logic              user1_rlast         ,
  input  logic [  1:  0]    user1_rresp         ,
  input  logic              user1_rvalid        ,
  output logic              user1_rready        ,

  // ch1_b channel
  input  logic [  1:  0]    user1_bresp         ,
  input  logic              user1_bvalid        ,
  output logic              user1_bready        ,

  // ch2_ar channel
  output logic [  1:  0]    user2_arsize        ,
  output logic [  7:  0]    user2_arlen         ,
  output logic [  1:  0]    user2_arburst       ,
  output logic [ 47:  0]    user2_araddr        ,
  output logic              user2_arvalid       ,
  input  logic              user2_arready       ,

  // ch2_aw channel
  output logic [  1:  0]    user2_awsize        ,
  output logic [  7:  0]    user2_awlen         ,
  output logic [  1:  0]    user2_awburst       ,
  output logic [ 47:  0]    user2_awaddr        ,
  output logic              user2_awvalid       ,
  input  logic              user2_awready       ,

  // ch2__w channel
  output logic [ 63:  0]    user2_wdata         ,
  output logic              user2_wlast         ,
  output logic              user2_wvalid        ,
  input  logic              user2_wready        ,

  // ch2_r channel
  input  logic [ 63:  0]    user2_rdata         ,
  input  logic              user2_rlast         ,
  input  logic [  1:  0]    user2_rresp         ,
  input  logic              user2_rvalid        ,
  output logic              user2_rready        ,

  // ch2_b channel
  input  logic [  1:  0]    user2_bresp         ,
  input  logic              user2_bvalid        ,
  output logic              user2_bready        ,

  // ch3_ar channel
  output logic [  1:  0]    user3_arsize        ,
  output logic [  7:  0]    user3_arlen         ,
  output logic [  1:  0]    user3_arburst       ,
  output logic [ 47:  0]    user3_araddr        ,
  output logic              user3_arvalid       ,
  input  logic              user3_arready       ,

  // ch3_aw channel
  output logic [  1:  0]    user3_awsize        ,
  output logic [  7:  0]    user3_awlen         ,
  output logic [  1:  0]    user3_awburst       ,
  output logic [ 47:  0]    user3_awaddr        ,
  output logic              user3_awvalid       ,
  input  logic              user3_awready       ,

  // ch3__w channel
  output logic [ 63:  0]    user3_wdata         ,
  output logic              user3_wlast         ,
  output logic              user3_wvalid        ,
  input  logic              user3_wready        ,

  // ch3_r channel
  input  logic [ 63:  0]    user3_rdata         ,
  input  logic              user3_rlast         ,
  input  logic [  1:  0]    user3_rresp         ,
  input  logic              user3_rvalid        ,
  output logic              user3_rready        ,

  // ch3_b channel
  input  logic [  1:  0]    user3_bresp         ,
  input  logic              user3_bvalid        ,
  output logic              user3_bready        ,

  // Debug Status Outputs
  output logic [31:0]       rx_ch0_ar_debug_status,
  output logic [31:0]       rx_ch0_aw_debug_status,
  output logic [31:0]       rx_ch0__w_debug_status,
  output logic [31:0]       tx_ch0_r_debug_status,
  output logic [31:0]       tx_ch0_b_debug_status,
  output logic [31:0]       rx_ch1_ar_debug_status,
  output logic [31:0]       rx_ch1_aw_debug_status,
  output logic [31:0]       rx_ch1__w_debug_status,
  output logic [31:0]       tx_ch1_r_debug_status,
  output logic [31:0]       tx_ch1_b_debug_status,
  output logic [31:0]       rx_ch2_ar_debug_status,
  output logic [31:0]       rx_ch2_aw_debug_status,
  output logic [31:0]       rx_ch2__w_debug_status,
  output logic [31:0]       tx_ch2_r_debug_status,
  output logic [31:0]       tx_ch2_b_debug_status,
  output logic [31:0]       rx_ch3_ar_debug_status,
  output logic [31:0]       rx_ch3_aw_debug_status,
  output logic [31:0]       rx_ch3__w_debug_status,
  output logic [31:0]       tx_ch3_r_debug_status,
  output logic [31:0]       tx_ch3_b_debug_status,

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
  logic                                          rx_ch0_ar_pushbit             ;
  logic                                          user_ch0_ar_valid             ;
  logic [ 59:  0]                                rx_ch0_ar_data                ;
  logic [ 59:  0]                                rxfifo_ch0_ar_data            ;
  logic                                          tx_ch0_ar_credit              ;
  logic                                          user_ch0_ar_ready             ;
  logic                                          rx_ch0_ar_push_ovrd           ;

  logic                                          rx_ch0_aw_pushbit             ;
  logic                                          user_ch0_aw_valid             ;
  logic [ 59:  0]                                rx_ch0_aw_data                ;
  logic [ 59:  0]                                rxfifo_ch0_aw_data            ;
  logic                                          tx_ch0_aw_credit              ;
  logic                                          user_ch0_aw_ready             ;
  logic                                          rx_ch0_aw_push_ovrd           ;

  logic                                          rx_ch0__w_pushbit             ;
  logic                                          user_ch0__w_valid             ;
  logic [ 64:  0]                                rx_ch0__w_data                ;
  logic [ 64:  0]                                rxfifo_ch0__w_data            ;
  logic                                          tx_ch0__w_credit              ;
  logic                                          user_ch0__w_ready             ;
  logic                                          rx_ch0__w_push_ovrd           ;

  logic                                          tx_ch0_r_pushbit              ;
  logic                                          user_ch0_r_valid              ;
  logic [ 66:  0]                                tx_ch0_r_data                 ;
  logic [ 66:  0]                                txfifo_ch0_r_data             ;
  logic                                          rx_ch0_r_credit               ;
  logic                                          user_ch0_r_ready              ;
  logic                                          tx_ch0_r_pop_ovrd             ;

  logic                                          tx_ch0_b_pushbit              ;
  logic                                          user_ch0_b_valid              ;
  logic [  1:  0]                                tx_ch0_b_data                 ;
  logic [  1:  0]                                txfifo_ch0_b_data             ;
  logic                                          rx_ch0_b_credit               ;
  logic                                          user_ch0_b_ready              ;
  logic                                          tx_ch0_b_pop_ovrd             ;

  logic                                          rx_ch1_ar_pushbit             ;
  logic                                          user_ch1_ar_valid             ;
  logic [ 59:  0]                                rx_ch1_ar_data                ;
  logic [ 59:  0]                                rxfifo_ch1_ar_data            ;
  logic                                          tx_ch1_ar_credit              ;
  logic                                          user_ch1_ar_ready             ;
  logic                                          rx_ch1_ar_push_ovrd           ;

  logic                                          rx_ch1_aw_pushbit             ;
  logic                                          user_ch1_aw_valid             ;
  logic [ 59:  0]                                rx_ch1_aw_data                ;
  logic [ 59:  0]                                rxfifo_ch1_aw_data            ;
  logic                                          tx_ch1_aw_credit              ;
  logic                                          user_ch1_aw_ready             ;
  logic                                          rx_ch1_aw_push_ovrd           ;

  logic                                          rx_ch1__w_pushbit             ;
  logic                                          user_ch1__w_valid             ;
  logic [ 64:  0]                                rx_ch1__w_data                ;
  logic [ 64:  0]                                rxfifo_ch1__w_data            ;
  logic                                          tx_ch1__w_credit              ;
  logic                                          user_ch1__w_ready             ;
  logic                                          rx_ch1__w_push_ovrd           ;

  logic                                          tx_ch1_r_pushbit              ;
  logic                                          user_ch1_r_valid              ;
  logic [ 66:  0]                                tx_ch1_r_data                 ;
  logic [ 66:  0]                                txfifo_ch1_r_data             ;
  logic                                          rx_ch1_r_credit               ;
  logic                                          user_ch1_r_ready              ;
  logic                                          tx_ch1_r_pop_ovrd             ;

  logic                                          tx_ch1_b_pushbit              ;
  logic                                          user_ch1_b_valid              ;
  logic [  1:  0]                                tx_ch1_b_data                 ;
  logic [  1:  0]                                txfifo_ch1_b_data             ;
  logic                                          rx_ch1_b_credit               ;
  logic                                          user_ch1_b_ready              ;
  logic                                          tx_ch1_b_pop_ovrd             ;

  logic                                          rx_ch2_ar_pushbit             ;
  logic                                          user_ch2_ar_valid             ;
  logic [ 59:  0]                                rx_ch2_ar_data                ;
  logic [ 59:  0]                                rxfifo_ch2_ar_data            ;
  logic                                          tx_ch2_ar_credit              ;
  logic                                          user_ch2_ar_ready             ;
  logic                                          rx_ch2_ar_push_ovrd           ;

  logic                                          rx_ch2_aw_pushbit             ;
  logic                                          user_ch2_aw_valid             ;
  logic [ 59:  0]                                rx_ch2_aw_data                ;
  logic [ 59:  0]                                rxfifo_ch2_aw_data            ;
  logic                                          tx_ch2_aw_credit              ;
  logic                                          user_ch2_aw_ready             ;
  logic                                          rx_ch2_aw_push_ovrd           ;

  logic                                          rx_ch2__w_pushbit             ;
  logic                                          user_ch2__w_valid             ;
  logic [ 64:  0]                                rx_ch2__w_data                ;
  logic [ 64:  0]                                rxfifo_ch2__w_data            ;
  logic                                          tx_ch2__w_credit              ;
  logic                                          user_ch2__w_ready             ;
  logic                                          rx_ch2__w_push_ovrd           ;

  logic                                          tx_ch2_r_pushbit              ;
  logic                                          user_ch2_r_valid              ;
  logic [ 66:  0]                                tx_ch2_r_data                 ;
  logic [ 66:  0]                                txfifo_ch2_r_data             ;
  logic                                          rx_ch2_r_credit               ;
  logic                                          user_ch2_r_ready              ;
  logic                                          tx_ch2_r_pop_ovrd             ;

  logic                                          tx_ch2_b_pushbit              ;
  logic                                          user_ch2_b_valid              ;
  logic [  1:  0]                                tx_ch2_b_data                 ;
  logic [  1:  0]                                txfifo_ch2_b_data             ;
  logic                                          rx_ch2_b_credit               ;
  logic                                          user_ch2_b_ready              ;
  logic                                          tx_ch2_b_pop_ovrd             ;

  logic                                          rx_ch3_ar_pushbit             ;
  logic                                          user_ch3_ar_valid             ;
  logic [ 59:  0]                                rx_ch3_ar_data                ;
  logic [ 59:  0]                                rxfifo_ch3_ar_data            ;
  logic                                          tx_ch3_ar_credit              ;
  logic                                          user_ch3_ar_ready             ;
  logic                                          rx_ch3_ar_push_ovrd           ;

  logic                                          rx_ch3_aw_pushbit             ;
  logic                                          user_ch3_aw_valid             ;
  logic [ 59:  0]                                rx_ch3_aw_data                ;
  logic [ 59:  0]                                rxfifo_ch3_aw_data            ;
  logic                                          tx_ch3_aw_credit              ;
  logic                                          user_ch3_aw_ready             ;
  logic                                          rx_ch3_aw_push_ovrd           ;

  logic                                          rx_ch3__w_pushbit             ;
  logic                                          user_ch3__w_valid             ;
  logic [ 64:  0]                                rx_ch3__w_data                ;
  logic [ 64:  0]                                rxfifo_ch3__w_data            ;
  logic                                          tx_ch3__w_credit              ;
  logic                                          user_ch3__w_ready             ;
  logic                                          rx_ch3__w_push_ovrd           ;

  logic                                          tx_ch3_r_pushbit              ;
  logic                                          user_ch3_r_valid              ;
  logic [ 66:  0]                                tx_ch3_r_data                 ;
  logic [ 66:  0]                                txfifo_ch3_r_data             ;
  logic                                          rx_ch3_r_credit               ;
  logic                                          user_ch3_r_ready              ;
  logic                                          tx_ch3_r_pop_ovrd             ;

  logic                                          tx_ch3_b_pushbit              ;
  logic                                          user_ch3_b_valid              ;
  logic [  1:  0]                                tx_ch3_b_data                 ;
  logic [  1:  0]                                txfifo_ch3_b_data             ;
  logic                                          rx_ch3_b_credit               ;
  logic                                          user_ch3_b_ready              ;
  logic                                          tx_ch3_b_pop_ovrd             ;

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

      ll_receive #(.WIDTH(60), .DEPTH(8'd8)) ll_receive_ich0_ar
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch0_ar_data[59:0]),
         .user_i_valid                     (user_ch0_ar_valid),
         .tx_i_credit                      (tx_ch0_ar_credit),
         .rx_i_debug_status                (rx_ch0_ar_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch0_ar_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch0_ar_data[59:0]),
         .rx_i_pushbit                     (rx_ch0_ar_pushbit),
         .user_i_ready                     (user_ch0_ar_ready));

      ll_receive #(.WIDTH(60), .DEPTH(8'd8)) ll_receive_ich0_aw
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch0_aw_data[59:0]),
         .user_i_valid                     (user_ch0_aw_valid),
         .tx_i_credit                      (tx_ch0_aw_credit),
         .rx_i_debug_status                (rx_ch0_aw_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch0_aw_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch0_aw_data[59:0]),
         .rx_i_pushbit                     (rx_ch0_aw_pushbit),
         .user_i_ready                     (user_ch0_aw_ready));

      ll_receive #(.WIDTH(65), .DEPTH(8'd128)) ll_receive_ich0__w
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch0__w_data[64:0]),
         .user_i_valid                     (user_ch0__w_valid),
         .tx_i_credit                      (tx_ch0__w_credit),
         .rx_i_debug_status                (rx_ch0__w_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch0__w_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch0__w_data[64:0]),
         .rx_i_pushbit                     (rx_ch0__w_pushbit),
         .user_i_ready                     (user_ch0__w_ready));

      ll_transmit #(.WIDTH(67), .DEPTH(8'd1)) ll_transmit_ich0_r
        (// Outputs
         .user_i_ready                     (user_ch0_r_ready),
         .tx_i_data                        (tx_ch0_r_data[66:0]),
         .tx_i_pushbit                     (tx_ch0_r_pushbit),
         .tx_i_debug_status                (tx_ch0_r_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch0_r_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch0_r_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch0_r_data[66:0]),
         .user_i_valid                     (user_ch0_r_valid),
         .rx_i_credit                      (rx_ch0_r_credit));

      ll_transmit #(.WIDTH(2), .DEPTH(8'd1)) ll_transmit_ich0_b
        (// Outputs
         .user_i_ready                     (user_ch0_b_ready),
         .tx_i_data                        (tx_ch0_b_data[1:0]),
         .tx_i_pushbit                     (tx_ch0_b_pushbit),
         .tx_i_debug_status                (tx_ch0_b_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch0_b_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch0_b_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch0_b_data[1:0]),
         .user_i_valid                     (user_ch0_b_valid),
         .rx_i_credit                      (rx_ch0_b_credit));

      ll_receive #(.WIDTH(60), .DEPTH(8'd8)) ll_receive_ich1_ar
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch1_ar_data[59:0]),
         .user_i_valid                     (user_ch1_ar_valid),
         .tx_i_credit                      (tx_ch1_ar_credit),
         .rx_i_debug_status                (rx_ch1_ar_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch1_ar_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch1_ar_data[59:0]),
         .rx_i_pushbit                     (rx_ch1_ar_pushbit),
         .user_i_ready                     (user_ch1_ar_ready));

      ll_receive #(.WIDTH(60), .DEPTH(8'd8)) ll_receive_ich1_aw
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch1_aw_data[59:0]),
         .user_i_valid                     (user_ch1_aw_valid),
         .tx_i_credit                      (tx_ch1_aw_credit),
         .rx_i_debug_status                (rx_ch1_aw_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch1_aw_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch1_aw_data[59:0]),
         .rx_i_pushbit                     (rx_ch1_aw_pushbit),
         .user_i_ready                     (user_ch1_aw_ready));

      ll_receive #(.WIDTH(65), .DEPTH(8'd128)) ll_receive_ich1__w
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch1__w_data[64:0]),
         .user_i_valid                     (user_ch1__w_valid),
         .tx_i_credit                      (tx_ch1__w_credit),
         .rx_i_debug_status                (rx_ch1__w_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch1__w_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch1__w_data[64:0]),
         .rx_i_pushbit                     (rx_ch1__w_pushbit),
         .user_i_ready                     (user_ch1__w_ready));

      ll_transmit #(.WIDTH(67), .DEPTH(8'd1)) ll_transmit_ich1_r
        (// Outputs
         .user_i_ready                     (user_ch1_r_ready),
         .tx_i_data                        (tx_ch1_r_data[66:0]),
         .tx_i_pushbit                     (tx_ch1_r_pushbit),
         .tx_i_debug_status                (tx_ch1_r_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch1_r_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch1_r_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch1_r_data[66:0]),
         .user_i_valid                     (user_ch1_r_valid),
         .rx_i_credit                      (rx_ch1_r_credit));

      ll_transmit #(.WIDTH(2), .DEPTH(8'd1)) ll_transmit_ich1_b
        (// Outputs
         .user_i_ready                     (user_ch1_b_ready),
         .tx_i_data                        (tx_ch1_b_data[1:0]),
         .tx_i_pushbit                     (tx_ch1_b_pushbit),
         .tx_i_debug_status                (tx_ch1_b_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch1_b_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch1_b_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch1_b_data[1:0]),
         .user_i_valid                     (user_ch1_b_valid),
         .rx_i_credit                      (rx_ch1_b_credit));

      ll_receive #(.WIDTH(60), .DEPTH(8'd8)) ll_receive_ich2_ar
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch2_ar_data[59:0]),
         .user_i_valid                     (user_ch2_ar_valid),
         .tx_i_credit                      (tx_ch2_ar_credit),
         .rx_i_debug_status                (rx_ch2_ar_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch2_ar_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch2_ar_data[59:0]),
         .rx_i_pushbit                     (rx_ch2_ar_pushbit),
         .user_i_ready                     (user_ch2_ar_ready));

      ll_receive #(.WIDTH(60), .DEPTH(8'd8)) ll_receive_ich2_aw
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch2_aw_data[59:0]),
         .user_i_valid                     (user_ch2_aw_valid),
         .tx_i_credit                      (tx_ch2_aw_credit),
         .rx_i_debug_status                (rx_ch2_aw_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch2_aw_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch2_aw_data[59:0]),
         .rx_i_pushbit                     (rx_ch2_aw_pushbit),
         .user_i_ready                     (user_ch2_aw_ready));

      ll_receive #(.WIDTH(65), .DEPTH(8'd128)) ll_receive_ich2__w
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch2__w_data[64:0]),
         .user_i_valid                     (user_ch2__w_valid),
         .tx_i_credit                      (tx_ch2__w_credit),
         .rx_i_debug_status                (rx_ch2__w_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch2__w_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch2__w_data[64:0]),
         .rx_i_pushbit                     (rx_ch2__w_pushbit),
         .user_i_ready                     (user_ch2__w_ready));

      ll_transmit #(.WIDTH(67), .DEPTH(8'd1)) ll_transmit_ich2_r
        (// Outputs
         .user_i_ready                     (user_ch2_r_ready),
         .tx_i_data                        (tx_ch2_r_data[66:0]),
         .tx_i_pushbit                     (tx_ch2_r_pushbit),
         .tx_i_debug_status                (tx_ch2_r_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch2_r_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch2_r_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch2_r_data[66:0]),
         .user_i_valid                     (user_ch2_r_valid),
         .rx_i_credit                      (rx_ch2_r_credit));

      ll_transmit #(.WIDTH(2), .DEPTH(8'd1)) ll_transmit_ich2_b
        (// Outputs
         .user_i_ready                     (user_ch2_b_ready),
         .tx_i_data                        (tx_ch2_b_data[1:0]),
         .tx_i_pushbit                     (tx_ch2_b_pushbit),
         .tx_i_debug_status                (tx_ch2_b_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch2_b_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch2_b_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch2_b_data[1:0]),
         .user_i_valid                     (user_ch2_b_valid),
         .rx_i_credit                      (rx_ch2_b_credit));

      ll_receive #(.WIDTH(60), .DEPTH(8'd8)) ll_receive_ich3_ar
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch3_ar_data[59:0]),
         .user_i_valid                     (user_ch3_ar_valid),
         .tx_i_credit                      (tx_ch3_ar_credit),
         .rx_i_debug_status                (rx_ch3_ar_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch3_ar_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch3_ar_data[59:0]),
         .rx_i_pushbit                     (rx_ch3_ar_pushbit),
         .user_i_ready                     (user_ch3_ar_ready));

      ll_receive #(.WIDTH(60), .DEPTH(8'd8)) ll_receive_ich3_aw
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch3_aw_data[59:0]),
         .user_i_valid                     (user_ch3_aw_valid),
         .tx_i_credit                      (tx_ch3_aw_credit),
         .rx_i_debug_status                (rx_ch3_aw_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch3_aw_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch3_aw_data[59:0]),
         .rx_i_pushbit                     (rx_ch3_aw_pushbit),
         .user_i_ready                     (user_ch3_aw_ready));

      ll_receive #(.WIDTH(65), .DEPTH(8'd128)) ll_receive_ich3__w
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ch3__w_data[64:0]),
         .user_i_valid                     (user_ch3__w_valid),
         .tx_i_credit                      (tx_ch3__w_credit),
         .rx_i_debug_status                (rx_ch3__w_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ch3__w_push_ovrd),
         .delay_x_value                    (delay_x_value[7:0]),
         .rx_i_data                        (rx_ch3__w_data[64:0]),
         .rx_i_pushbit                     (rx_ch3__w_pushbit),
         .user_i_ready                     (user_ch3__w_ready));

      ll_transmit #(.WIDTH(67), .DEPTH(8'd1)) ll_transmit_ich3_r
        (// Outputs
         .user_i_ready                     (user_ch3_r_ready),
         .tx_i_data                        (tx_ch3_r_data[66:0]),
         .tx_i_pushbit                     (tx_ch3_r_pushbit),
         .tx_i_debug_status                (tx_ch3_r_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch3_r_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch3_r_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch3_r_data[66:0]),
         .user_i_valid                     (user_ch3_r_valid),
         .rx_i_credit                      (rx_ch3_r_credit));

      ll_transmit #(.WIDTH(2), .DEPTH(8'd1)) ll_transmit_ich3_b
        (// Outputs
         .user_i_ready                     (user_ch3_b_ready),
         .tx_i_data                        (tx_ch3_b_data[1:0]),
         .tx_i_pushbit                     (tx_ch3_b_pushbit),
         .tx_i_debug_status                (tx_ch3_b_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ch3_b_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ch3_b_pop_ovrd),
         .txfifo_i_data                    (txfifo_ch3_b_data[1:0]),
         .user_i_valid                     (user_ch3_b_valid),
         .rx_i_credit                      (rx_ch3_b_credit));

// Logic Link Instantiation
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// User Interface

      axi_fourchan_a32_d32_packet_slave_name axi_fourchan_a32_d32_packet_slave_name
      (
         .user0_arsize                     (user0_arsize[1:0]),
         .user0_arlen                      (user0_arlen[7:0]),
         .user0_arburst                    (user0_arburst[1:0]),
         .user0_araddr                     (user0_araddr[47:0]),
         .user0_arvalid                    (user0_arvalid),
         .user0_arready                    (user0_arready),
         .user0_awsize                     (user0_awsize[1:0]),
         .user0_awlen                      (user0_awlen[7:0]),
         .user0_awburst                    (user0_awburst[1:0]),
         .user0_awaddr                     (user0_awaddr[47:0]),
         .user0_awvalid                    (user0_awvalid),
         .user0_awready                    (user0_awready),
         .user0_wdata                      (user0_wdata[63:0]),
         .user0_wlast                      (user0_wlast),
         .user0_wvalid                     (user0_wvalid),
         .user0_wready                     (user0_wready),
         .user0_rdata                      (user0_rdata[63:0]),
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
         .user1_araddr                     (user1_araddr[47:0]),
         .user1_arvalid                    (user1_arvalid),
         .user1_arready                    (user1_arready),
         .user1_awsize                     (user1_awsize[1:0]),
         .user1_awlen                      (user1_awlen[7:0]),
         .user1_awburst                    (user1_awburst[1:0]),
         .user1_awaddr                     (user1_awaddr[47:0]),
         .user1_awvalid                    (user1_awvalid),
         .user1_awready                    (user1_awready),
         .user1_wdata                      (user1_wdata[63:0]),
         .user1_wlast                      (user1_wlast),
         .user1_wvalid                     (user1_wvalid),
         .user1_wready                     (user1_wready),
         .user1_rdata                      (user1_rdata[63:0]),
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
         .user2_araddr                     (user2_araddr[47:0]),
         .user2_arvalid                    (user2_arvalid),
         .user2_arready                    (user2_arready),
         .user2_awsize                     (user2_awsize[1:0]),
         .user2_awlen                      (user2_awlen[7:0]),
         .user2_awburst                    (user2_awburst[1:0]),
         .user2_awaddr                     (user2_awaddr[47:0]),
         .user2_awvalid                    (user2_awvalid),
         .user2_awready                    (user2_awready),
         .user2_wdata                      (user2_wdata[63:0]),
         .user2_wlast                      (user2_wlast),
         .user2_wvalid                     (user2_wvalid),
         .user2_wready                     (user2_wready),
         .user2_rdata                      (user2_rdata[63:0]),
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
         .user3_araddr                     (user3_araddr[47:0]),
         .user3_arvalid                    (user3_arvalid),
         .user3_arready                    (user3_arready),
         .user3_awsize                     (user3_awsize[1:0]),
         .user3_awlen                      (user3_awlen[7:0]),
         .user3_awburst                    (user3_awburst[1:0]),
         .user3_awaddr                     (user3_awaddr[47:0]),
         .user3_awvalid                    (user3_awvalid),
         .user3_awready                    (user3_awready),
         .user3_wdata                      (user3_wdata[63:0]),
         .user3_wlast                      (user3_wlast),
         .user3_wvalid                     (user3_wvalid),
         .user3_wready                     (user3_wready),
         .user3_rdata                      (user3_rdata[63:0]),
         .user3_rlast                      (user3_rlast),
         .user3_rresp                      (user3_rresp[1:0]),
         .user3_rvalid                     (user3_rvalid),
         .user3_rready                     (user3_rready),
         .user3_bresp                      (user3_bresp[1:0]),
         .user3_bvalid                     (user3_bvalid),
         .user3_bready                     (user3_bready),

         .user_ch0_ar_valid                (user_ch0_ar_valid),
         .rxfifo_ch0_ar_data               (rxfifo_ch0_ar_data[59:0]),
         .user_ch0_ar_ready                (user_ch0_ar_ready),
         .user_ch0_aw_valid                (user_ch0_aw_valid),
         .rxfifo_ch0_aw_data               (rxfifo_ch0_aw_data[59:0]),
         .user_ch0_aw_ready                (user_ch0_aw_ready),
         .user_ch0__w_valid                (user_ch0__w_valid),
         .rxfifo_ch0__w_data               (rxfifo_ch0__w_data[64:0]),
         .user_ch0__w_ready                (user_ch0__w_ready),
         .user_ch0_r_valid                 (user_ch0_r_valid),
         .txfifo_ch0_r_data                (txfifo_ch0_r_data[66:0]),
         .user_ch0_r_ready                 (user_ch0_r_ready),
         .user_ch0_b_valid                 (user_ch0_b_valid),
         .txfifo_ch0_b_data                (txfifo_ch0_b_data[1:0]),
         .user_ch0_b_ready                 (user_ch0_b_ready),
         .user_ch1_ar_valid                (user_ch1_ar_valid),
         .rxfifo_ch1_ar_data               (rxfifo_ch1_ar_data[59:0]),
         .user_ch1_ar_ready                (user_ch1_ar_ready),
         .user_ch1_aw_valid                (user_ch1_aw_valid),
         .rxfifo_ch1_aw_data               (rxfifo_ch1_aw_data[59:0]),
         .user_ch1_aw_ready                (user_ch1_aw_ready),
         .user_ch1__w_valid                (user_ch1__w_valid),
         .rxfifo_ch1__w_data               (rxfifo_ch1__w_data[64:0]),
         .user_ch1__w_ready                (user_ch1__w_ready),
         .user_ch1_r_valid                 (user_ch1_r_valid),
         .txfifo_ch1_r_data                (txfifo_ch1_r_data[66:0]),
         .user_ch1_r_ready                 (user_ch1_r_ready),
         .user_ch1_b_valid                 (user_ch1_b_valid),
         .txfifo_ch1_b_data                (txfifo_ch1_b_data[1:0]),
         .user_ch1_b_ready                 (user_ch1_b_ready),
         .user_ch2_ar_valid                (user_ch2_ar_valid),
         .rxfifo_ch2_ar_data               (rxfifo_ch2_ar_data[59:0]),
         .user_ch2_ar_ready                (user_ch2_ar_ready),
         .user_ch2_aw_valid                (user_ch2_aw_valid),
         .rxfifo_ch2_aw_data               (rxfifo_ch2_aw_data[59:0]),
         .user_ch2_aw_ready                (user_ch2_aw_ready),
         .user_ch2__w_valid                (user_ch2__w_valid),
         .rxfifo_ch2__w_data               (rxfifo_ch2__w_data[64:0]),
         .user_ch2__w_ready                (user_ch2__w_ready),
         .user_ch2_r_valid                 (user_ch2_r_valid),
         .txfifo_ch2_r_data                (txfifo_ch2_r_data[66:0]),
         .user_ch2_r_ready                 (user_ch2_r_ready),
         .user_ch2_b_valid                 (user_ch2_b_valid),
         .txfifo_ch2_b_data                (txfifo_ch2_b_data[1:0]),
         .user_ch2_b_ready                 (user_ch2_b_ready),
         .user_ch3_ar_valid                (user_ch3_ar_valid),
         .rxfifo_ch3_ar_data               (rxfifo_ch3_ar_data[59:0]),
         .user_ch3_ar_ready                (user_ch3_ar_ready),
         .user_ch3_aw_valid                (user_ch3_aw_valid),
         .rxfifo_ch3_aw_data               (rxfifo_ch3_aw_data[59:0]),
         .user_ch3_aw_ready                (user_ch3_aw_ready),
         .user_ch3__w_valid                (user_ch3__w_valid),
         .rxfifo_ch3__w_data               (rxfifo_ch3__w_data[64:0]),
         .user_ch3__w_ready                (user_ch3__w_ready),
         .user_ch3_r_valid                 (user_ch3_r_valid),
         .txfifo_ch3_r_data                (txfifo_ch3_r_data[66:0]),
         .user_ch3_r_ready                 (user_ch3_r_ready),
         .user_ch3_b_valid                 (user_ch3_b_valid),
         .txfifo_ch3_b_data                (txfifo_ch3_b_data[1:0]),
         .user_ch3_b_ready                 (user_ch3_b_ready),

         .m_gen2_mode                      (m_gen2_mode)

      );
// User Interface                                                 
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// PHY Interface

      axi_fourchan_a32_d32_packet_slave_concat axi_fourchan_a32_d32_packet_slave_concat
      (
         .rx_ch0_ar_data                   (rx_ch0_ar_data[59:0]),
         .rx_ch0_ar_push_ovrd              (rx_ch0_ar_push_ovrd),
         .rx_ch0_ar_pushbit                (rx_ch0_ar_pushbit),
         .tx_ch0_ar_credit                 (tx_ch0_ar_credit),
         .rx_ch0_aw_data                   (rx_ch0_aw_data[59:0]),
         .rx_ch0_aw_push_ovrd              (rx_ch0_aw_push_ovrd),
         .rx_ch0_aw_pushbit                (rx_ch0_aw_pushbit),
         .tx_ch0_aw_credit                 (tx_ch0_aw_credit),
         .rx_ch0__w_data                   (rx_ch0__w_data[64:0]),
         .rx_ch0__w_push_ovrd              (rx_ch0__w_push_ovrd),
         .rx_ch0__w_pushbit                (rx_ch0__w_pushbit),
         .tx_ch0__w_credit                 (tx_ch0__w_credit),
         .tx_ch0_r_data                    (tx_ch0_r_data[66:0]),
         .tx_ch0_r_pop_ovrd                (tx_ch0_r_pop_ovrd),
         .tx_ch0_r_pushbit                 (tx_ch0_r_pushbit),
         .rx_ch0_r_credit                  (rx_ch0_r_credit),
         .tx_ch0_b_data                    (tx_ch0_b_data[1:0]),
         .tx_ch0_b_pop_ovrd                (tx_ch0_b_pop_ovrd),
         .tx_ch0_b_pushbit                 (tx_ch0_b_pushbit),
         .rx_ch0_b_credit                  (rx_ch0_b_credit),
         .rx_ch1_ar_data                   (rx_ch1_ar_data[59:0]),
         .rx_ch1_ar_push_ovrd              (rx_ch1_ar_push_ovrd),
         .rx_ch1_ar_pushbit                (rx_ch1_ar_pushbit),
         .tx_ch1_ar_credit                 (tx_ch1_ar_credit),
         .rx_ch1_aw_data                   (rx_ch1_aw_data[59:0]),
         .rx_ch1_aw_push_ovrd              (rx_ch1_aw_push_ovrd),
         .rx_ch1_aw_pushbit                (rx_ch1_aw_pushbit),
         .tx_ch1_aw_credit                 (tx_ch1_aw_credit),
         .rx_ch1__w_data                   (rx_ch1__w_data[64:0]),
         .rx_ch1__w_push_ovrd              (rx_ch1__w_push_ovrd),
         .rx_ch1__w_pushbit                (rx_ch1__w_pushbit),
         .tx_ch1__w_credit                 (tx_ch1__w_credit),
         .tx_ch1_r_data                    (tx_ch1_r_data[66:0]),
         .tx_ch1_r_pop_ovrd                (tx_ch1_r_pop_ovrd),
         .tx_ch1_r_pushbit                 (tx_ch1_r_pushbit),
         .rx_ch1_r_credit                  (rx_ch1_r_credit),
         .tx_ch1_b_data                    (tx_ch1_b_data[1:0]),
         .tx_ch1_b_pop_ovrd                (tx_ch1_b_pop_ovrd),
         .tx_ch1_b_pushbit                 (tx_ch1_b_pushbit),
         .rx_ch1_b_credit                  (rx_ch1_b_credit),
         .rx_ch2_ar_data                   (rx_ch2_ar_data[59:0]),
         .rx_ch2_ar_push_ovrd              (rx_ch2_ar_push_ovrd),
         .rx_ch2_ar_pushbit                (rx_ch2_ar_pushbit),
         .tx_ch2_ar_credit                 (tx_ch2_ar_credit),
         .rx_ch2_aw_data                   (rx_ch2_aw_data[59:0]),
         .rx_ch2_aw_push_ovrd              (rx_ch2_aw_push_ovrd),
         .rx_ch2_aw_pushbit                (rx_ch2_aw_pushbit),
         .tx_ch2_aw_credit                 (tx_ch2_aw_credit),
         .rx_ch2__w_data                   (rx_ch2__w_data[64:0]),
         .rx_ch2__w_push_ovrd              (rx_ch2__w_push_ovrd),
         .rx_ch2__w_pushbit                (rx_ch2__w_pushbit),
         .tx_ch2__w_credit                 (tx_ch2__w_credit),
         .tx_ch2_r_data                    (tx_ch2_r_data[66:0]),
         .tx_ch2_r_pop_ovrd                (tx_ch2_r_pop_ovrd),
         .tx_ch2_r_pushbit                 (tx_ch2_r_pushbit),
         .rx_ch2_r_credit                  (rx_ch2_r_credit),
         .tx_ch2_b_data                    (tx_ch2_b_data[1:0]),
         .tx_ch2_b_pop_ovrd                (tx_ch2_b_pop_ovrd),
         .tx_ch2_b_pushbit                 (tx_ch2_b_pushbit),
         .rx_ch2_b_credit                  (rx_ch2_b_credit),
         .rx_ch3_ar_data                   (rx_ch3_ar_data[59:0]),
         .rx_ch3_ar_push_ovrd              (rx_ch3_ar_push_ovrd),
         .rx_ch3_ar_pushbit                (rx_ch3_ar_pushbit),
         .tx_ch3_ar_credit                 (tx_ch3_ar_credit),
         .rx_ch3_aw_data                   (rx_ch3_aw_data[59:0]),
         .rx_ch3_aw_push_ovrd              (rx_ch3_aw_push_ovrd),
         .rx_ch3_aw_pushbit                (rx_ch3_aw_pushbit),
         .tx_ch3_aw_credit                 (tx_ch3_aw_credit),
         .rx_ch3__w_data                   (rx_ch3__w_data[64:0]),
         .rx_ch3__w_push_ovrd              (rx_ch3__w_push_ovrd),
         .rx_ch3__w_pushbit                (rx_ch3__w_pushbit),
         .tx_ch3__w_credit                 (tx_ch3__w_credit),
         .tx_ch3_r_data                    (tx_ch3_r_data[66:0]),
         .tx_ch3_r_pop_ovrd                (tx_ch3_r_pop_ovrd),
         .tx_ch3_r_pushbit                 (tx_ch3_r_pushbit),
         .rx_ch3_r_credit                  (rx_ch3_r_credit),
         .tx_ch3_b_data                    (tx_ch3_b_data[1:0]),
         .tx_ch3_b_pop_ovrd                (tx_ch3_b_pop_ovrd),
         .tx_ch3_b_pushbit                 (tx_ch3_b_pushbit),
         .rx_ch3_b_credit                  (rx_ch3_b_credit),

         .tx_phy0                          (tx_phy0[319:0]),
         .rx_phy0                          (rx_phy0[319:0]),

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
