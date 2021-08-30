module axi_fourchan_a32_d32_packet_master_name  (

  // ch0_ar channel
  input  logic [  1:  0]    user0_arsize        ,
  input  logic [  7:  0]    user0_arlen         ,
  input  logic [  1:  0]    user0_arburst       ,
  input  logic [ 47:  0]    user0_araddr        ,
  input  logic              user0_arvalid       ,
  output logic              user0_arready       ,

  // ch0_aw channel
  input  logic [  1:  0]    user0_awsize        ,
  input  logic [  7:  0]    user0_awlen         ,
  input  logic [  1:  0]    user0_awburst       ,
  input  logic [ 47:  0]    user0_awaddr        ,
  input  logic              user0_awvalid       ,
  output logic              user0_awready       ,

  // ch0__w channel
  input  logic [ 63:  0]    user0_wdata         ,
  input  logic              user0_wlast         ,
  input  logic              user0_wvalid        ,
  output logic              user0_wready        ,

  // ch0_r channel
  output logic [ 63:  0]    user0_rdata         ,
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
  input  logic [ 47:  0]    user1_araddr        ,
  input  logic              user1_arvalid       ,
  output logic              user1_arready       ,

  // ch1_aw channel
  input  logic [  1:  0]    user1_awsize        ,
  input  logic [  7:  0]    user1_awlen         ,
  input  logic [  1:  0]    user1_awburst       ,
  input  logic [ 47:  0]    user1_awaddr        ,
  input  logic              user1_awvalid       ,
  output logic              user1_awready       ,

  // ch1__w channel
  input  logic [ 63:  0]    user1_wdata         ,
  input  logic              user1_wlast         ,
  input  logic              user1_wvalid        ,
  output logic              user1_wready        ,

  // ch1_r channel
  output logic [ 63:  0]    user1_rdata         ,
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
  input  logic [ 47:  0]    user2_araddr        ,
  input  logic              user2_arvalid       ,
  output logic              user2_arready       ,

  // ch2_aw channel
  input  logic [  1:  0]    user2_awsize        ,
  input  logic [  7:  0]    user2_awlen         ,
  input  logic [  1:  0]    user2_awburst       ,
  input  logic [ 47:  0]    user2_awaddr        ,
  input  logic              user2_awvalid       ,
  output logic              user2_awready       ,

  // ch2__w channel
  input  logic [ 63:  0]    user2_wdata         ,
  input  logic              user2_wlast         ,
  input  logic              user2_wvalid        ,
  output logic              user2_wready        ,

  // ch2_r channel
  output logic [ 63:  0]    user2_rdata         ,
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
  input  logic [ 47:  0]    user3_araddr        ,
  input  logic              user3_arvalid       ,
  output logic              user3_arready       ,

  // ch3_aw channel
  input  logic [  1:  0]    user3_awsize        ,
  input  logic [  7:  0]    user3_awlen         ,
  input  logic [  1:  0]    user3_awburst       ,
  input  logic [ 47:  0]    user3_awaddr        ,
  input  logic              user3_awvalid       ,
  output logic              user3_awready       ,

  // ch3__w channel
  input  logic [ 63:  0]    user3_wdata         ,
  input  logic              user3_wlast         ,
  input  logic              user3_wvalid        ,
  output logic              user3_wready        ,

  // ch3_r channel
  output logic [ 63:  0]    user3_rdata         ,
  output logic              user3_rlast         ,
  output logic [  1:  0]    user3_rresp         ,
  output logic              user3_rvalid        ,
  input  logic              user3_rready        ,

  // ch3_b channel
  output logic [  1:  0]    user3_bresp         ,
  output logic              user3_bvalid        ,
  input  logic              user3_bready        ,

  // Logic Link Interfaces
  output logic              user_ch0_ar_valid   ,
  output logic [ 59:  0]    txfifo_ch0_ar_data  ,
  input  logic              user_ch0_ar_ready   ,

  output logic              user_ch0_aw_valid   ,
  output logic [ 59:  0]    txfifo_ch0_aw_data  ,
  input  logic              user_ch0_aw_ready   ,

  output logic              user_ch0__w_valid   ,
  output logic [ 64:  0]    txfifo_ch0__w_data  ,
  input  logic              user_ch0__w_ready   ,

  input  logic              user_ch0_r_valid    ,
  input  logic [ 66:  0]    rxfifo_ch0_r_data   ,
  output logic              user_ch0_r_ready    ,

  input  logic              user_ch0_b_valid    ,
  input  logic [  1:  0]    rxfifo_ch0_b_data   ,
  output logic              user_ch0_b_ready    ,

  output logic              user_ch1_ar_valid   ,
  output logic [ 59:  0]    txfifo_ch1_ar_data  ,
  input  logic              user_ch1_ar_ready   ,

  output logic              user_ch1_aw_valid   ,
  output logic [ 59:  0]    txfifo_ch1_aw_data  ,
  input  logic              user_ch1_aw_ready   ,

  output logic              user_ch1__w_valid   ,
  output logic [ 64:  0]    txfifo_ch1__w_data  ,
  input  logic              user_ch1__w_ready   ,

  input  logic              user_ch1_r_valid    ,
  input  logic [ 66:  0]    rxfifo_ch1_r_data   ,
  output logic              user_ch1_r_ready    ,

  input  logic              user_ch1_b_valid    ,
  input  logic [  1:  0]    rxfifo_ch1_b_data   ,
  output logic              user_ch1_b_ready    ,

  output logic              user_ch2_ar_valid   ,
  output logic [ 59:  0]    txfifo_ch2_ar_data  ,
  input  logic              user_ch2_ar_ready   ,

  output logic              user_ch2_aw_valid   ,
  output logic [ 59:  0]    txfifo_ch2_aw_data  ,
  input  logic              user_ch2_aw_ready   ,

  output logic              user_ch2__w_valid   ,
  output logic [ 64:  0]    txfifo_ch2__w_data  ,
  input  logic              user_ch2__w_ready   ,

  input  logic              user_ch2_r_valid    ,
  input  logic [ 66:  0]    rxfifo_ch2_r_data   ,
  output logic              user_ch2_r_ready    ,

  input  logic              user_ch2_b_valid    ,
  input  logic [  1:  0]    rxfifo_ch2_b_data   ,
  output logic              user_ch2_b_ready    ,

  output logic              user_ch3_ar_valid   ,
  output logic [ 59:  0]    txfifo_ch3_ar_data  ,
  input  logic              user_ch3_ar_ready   ,

  output logic              user_ch3_aw_valid   ,
  output logic [ 59:  0]    txfifo_ch3_aw_data  ,
  input  logic              user_ch3_aw_ready   ,

  output logic              user_ch3__w_valid   ,
  output logic [ 64:  0]    txfifo_ch3__w_data  ,
  input  logic              user_ch3__w_ready   ,

  input  logic              user_ch3_r_valid    ,
  input  logic [ 66:  0]    rxfifo_ch3_r_data   ,
  output logic              user_ch3_r_ready    ,

  input  logic              user_ch3_b_valid    ,
  input  logic [  1:  0]    rxfifo_ch3_b_data   ,
  output logic              user_ch3_b_ready    ,

  input  logic              m_gen2_mode         

);

  assign user_ch0_ar_valid                = user0_arvalid                    ;
  assign user0_arready                    = user_ch0_ar_ready                ;
  assign txfifo_ch0_ar_data   [  0 +:  2] = user0_arsize         [  0 +:  2] ;
  assign txfifo_ch0_ar_data   [  2 +:  8] = user0_arlen          [  0 +:  8] ;
  assign txfifo_ch0_ar_data   [ 10 +:  2] = user0_arburst        [  0 +:  2] ;
  assign txfifo_ch0_ar_data   [ 12 +: 48] = user0_araddr         [  0 +: 48] ;

  assign user_ch0_aw_valid                = user0_awvalid                    ;
  assign user0_awready                    = user_ch0_aw_ready                ;
  assign txfifo_ch0_aw_data   [  0 +:  2] = user0_awsize         [  0 +:  2] ;
  assign txfifo_ch0_aw_data   [  2 +:  8] = user0_awlen          [  0 +:  8] ;
  assign txfifo_ch0_aw_data   [ 10 +:  2] = user0_awburst        [  0 +:  2] ;
  assign txfifo_ch0_aw_data   [ 12 +: 48] = user0_awaddr         [  0 +: 48] ;

  assign user_ch0__w_valid                = user0_wvalid                     ;
  assign user0_wready                     = user_ch0__w_ready                ;
  assign txfifo_ch0__w_data   [  0 +: 64] = user0_wdata          [  0 +: 64] ;
  assign txfifo_ch0__w_data   [ 64 +:  1] = user0_wlast                      ;

  assign user0_rvalid                     = user_ch0_r_valid                 ;
  assign user_ch0_r_ready                 = user0_rready                     ;
  assign user0_rdata          [  0 +: 64] = rxfifo_ch0_r_data    [  0 +: 64] ;
  assign user0_rlast                      = rxfifo_ch0_r_data    [ 64 +:  1] ;
  assign user0_rresp          [  0 +:  2] = rxfifo_ch0_r_data    [ 65 +:  2] ;

  assign user0_bvalid                     = user_ch0_b_valid                 ;
  assign user_ch0_b_ready                 = user0_bready                     ;
  assign user0_bresp          [  0 +:  2] = rxfifo_ch0_b_data    [  0 +:  2] ;

  assign user_ch1_ar_valid                = user1_arvalid                    ;
  assign user1_arready                    = user_ch1_ar_ready                ;
  assign txfifo_ch1_ar_data   [  0 +:  2] = user1_arsize         [  0 +:  2] ;
  assign txfifo_ch1_ar_data   [  2 +:  8] = user1_arlen          [  0 +:  8] ;
  assign txfifo_ch1_ar_data   [ 10 +:  2] = user1_arburst        [  0 +:  2] ;
  assign txfifo_ch1_ar_data   [ 12 +: 48] = user1_araddr         [  0 +: 48] ;

  assign user_ch1_aw_valid                = user1_awvalid                    ;
  assign user1_awready                    = user_ch1_aw_ready                ;
  assign txfifo_ch1_aw_data   [  0 +:  2] = user1_awsize         [  0 +:  2] ;
  assign txfifo_ch1_aw_data   [  2 +:  8] = user1_awlen          [  0 +:  8] ;
  assign txfifo_ch1_aw_data   [ 10 +:  2] = user1_awburst        [  0 +:  2] ;
  assign txfifo_ch1_aw_data   [ 12 +: 48] = user1_awaddr         [  0 +: 48] ;

  assign user_ch1__w_valid                = user1_wvalid                     ;
  assign user1_wready                     = user_ch1__w_ready                ;
  assign txfifo_ch1__w_data   [  0 +: 64] = user1_wdata          [  0 +: 64] ;
  assign txfifo_ch1__w_data   [ 64 +:  1] = user1_wlast                      ;

  assign user1_rvalid                     = user_ch1_r_valid                 ;
  assign user_ch1_r_ready                 = user1_rready                     ;
  assign user1_rdata          [  0 +: 64] = rxfifo_ch1_r_data    [  0 +: 64] ;
  assign user1_rlast                      = rxfifo_ch1_r_data    [ 64 +:  1] ;
  assign user1_rresp          [  0 +:  2] = rxfifo_ch1_r_data    [ 65 +:  2] ;

  assign user1_bvalid                     = user_ch1_b_valid                 ;
  assign user_ch1_b_ready                 = user1_bready                     ;
  assign user1_bresp          [  0 +:  2] = rxfifo_ch1_b_data    [  0 +:  2] ;

  assign user_ch2_ar_valid                = user2_arvalid                    ;
  assign user2_arready                    = user_ch2_ar_ready                ;
  assign txfifo_ch2_ar_data   [  0 +:  2] = user2_arsize         [  0 +:  2] ;
  assign txfifo_ch2_ar_data   [  2 +:  8] = user2_arlen          [  0 +:  8] ;
  assign txfifo_ch2_ar_data   [ 10 +:  2] = user2_arburst        [  0 +:  2] ;
  assign txfifo_ch2_ar_data   [ 12 +: 48] = user2_araddr         [  0 +: 48] ;

  assign user_ch2_aw_valid                = user2_awvalid                    ;
  assign user2_awready                    = user_ch2_aw_ready                ;
  assign txfifo_ch2_aw_data   [  0 +:  2] = user2_awsize         [  0 +:  2] ;
  assign txfifo_ch2_aw_data   [  2 +:  8] = user2_awlen          [  0 +:  8] ;
  assign txfifo_ch2_aw_data   [ 10 +:  2] = user2_awburst        [  0 +:  2] ;
  assign txfifo_ch2_aw_data   [ 12 +: 48] = user2_awaddr         [  0 +: 48] ;

  assign user_ch2__w_valid                = user2_wvalid                     ;
  assign user2_wready                     = user_ch2__w_ready                ;
  assign txfifo_ch2__w_data   [  0 +: 64] = user2_wdata          [  0 +: 64] ;
  assign txfifo_ch2__w_data   [ 64 +:  1] = user2_wlast                      ;

  assign user2_rvalid                     = user_ch2_r_valid                 ;
  assign user_ch2_r_ready                 = user2_rready                     ;
  assign user2_rdata          [  0 +: 64] = rxfifo_ch2_r_data    [  0 +: 64] ;
  assign user2_rlast                      = rxfifo_ch2_r_data    [ 64 +:  1] ;
  assign user2_rresp          [  0 +:  2] = rxfifo_ch2_r_data    [ 65 +:  2] ;

  assign user2_bvalid                     = user_ch2_b_valid                 ;
  assign user_ch2_b_ready                 = user2_bready                     ;
  assign user2_bresp          [  0 +:  2] = rxfifo_ch2_b_data    [  0 +:  2] ;

  assign user_ch3_ar_valid                = user3_arvalid                    ;
  assign user3_arready                    = user_ch3_ar_ready                ;
  assign txfifo_ch3_ar_data   [  0 +:  2] = user3_arsize         [  0 +:  2] ;
  assign txfifo_ch3_ar_data   [  2 +:  8] = user3_arlen          [  0 +:  8] ;
  assign txfifo_ch3_ar_data   [ 10 +:  2] = user3_arburst        [  0 +:  2] ;
  assign txfifo_ch3_ar_data   [ 12 +: 48] = user3_araddr         [  0 +: 48] ;

  assign user_ch3_aw_valid                = user3_awvalid                    ;
  assign user3_awready                    = user_ch3_aw_ready                ;
  assign txfifo_ch3_aw_data   [  0 +:  2] = user3_awsize         [  0 +:  2] ;
  assign txfifo_ch3_aw_data   [  2 +:  8] = user3_awlen          [  0 +:  8] ;
  assign txfifo_ch3_aw_data   [ 10 +:  2] = user3_awburst        [  0 +:  2] ;
  assign txfifo_ch3_aw_data   [ 12 +: 48] = user3_awaddr         [  0 +: 48] ;

  assign user_ch3__w_valid                = user3_wvalid                     ;
  assign user3_wready                     = user_ch3__w_ready                ;
  assign txfifo_ch3__w_data   [  0 +: 64] = user3_wdata          [  0 +: 64] ;
  assign txfifo_ch3__w_data   [ 64 +:  1] = user3_wlast                      ;

  assign user3_rvalid                     = user_ch3_r_valid                 ;
  assign user_ch3_r_ready                 = user3_rready                     ;
  assign user3_rdata          [  0 +: 64] = rxfifo_ch3_r_data    [  0 +: 64] ;
  assign user3_rlast                      = rxfifo_ch3_r_data    [ 64 +:  1] ;
  assign user3_rresp          [  0 +:  2] = rxfifo_ch3_r_data    [ 65 +:  2] ;

  assign user3_bvalid                     = user_ch3_b_valid                 ;
  assign user_ch3_b_ready                 = user3_bready                     ;
  assign user3_bresp          [  0 +:  2] = rxfifo_ch3_b_data    [  0 +:  2] ;

endmodule
