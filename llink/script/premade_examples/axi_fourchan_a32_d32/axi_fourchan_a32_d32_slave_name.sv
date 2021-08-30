module axi_fourchan_a32_d32_slave_name  (

  // ch0_ar channel
  output logic [  1:  0]    user0_arsize        ,
  output logic [  7:  0]    user0_arlen         ,
  output logic [  1:  0]    user0_arburst       ,
  output logic [ 31:  0]    user0_araddr        ,
  output logic              user0_arvalid       ,
  input  logic              user0_arready       ,

  // ch0_aw channel
  output logic [  1:  0]    user0_awsize        ,
  output logic [  7:  0]    user0_awlen         ,
  output logic [  1:  0]    user0_awburst       ,
  output logic [ 31:  0]    user0_awaddr        ,
  output logic              user0_awvalid       ,
  input  logic              user0_awready       ,

  // ch0_w channel
  output logic [ 31:  0]    user0_wdata         ,
  output logic [ 15:  0]    user0_wstrb         ,
  output logic              user0_wlast         ,
  output logic              user0_wvalid        ,
  input  logic              user0_wready        ,

  // ch0_r channel
  input  logic [ 31:  0]    user0_rdata         ,
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
  output logic [ 31:  0]    user1_araddr        ,
  output logic              user1_arvalid       ,
  input  logic              user1_arready       ,

  // ch1_aw channel
  output logic [  1:  0]    user1_awsize        ,
  output logic [  7:  0]    user1_awlen         ,
  output logic [  1:  0]    user1_awburst       ,
  output logic [ 31:  0]    user1_awaddr        ,
  output logic              user1_awvalid       ,
  input  logic              user1_awready       ,

  // ch1_w channel
  output logic [ 31:  0]    user1_wdata         ,
  output logic [ 15:  0]    user1_wstrb         ,
  output logic              user1_wlast         ,
  output logic              user1_wvalid        ,
  input  logic              user1_wready        ,

  // ch1_r channel
  input  logic [ 31:  0]    user1_rdata         ,
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
  output logic [ 31:  0]    user2_araddr        ,
  output logic              user2_arvalid       ,
  input  logic              user2_arready       ,

  // ch2_aw channel
  output logic [  1:  0]    user2_awsize        ,
  output logic [  7:  0]    user2_awlen         ,
  output logic [  1:  0]    user2_awburst       ,
  output logic [ 31:  0]    user2_awaddr        ,
  output logic              user2_awvalid       ,
  input  logic              user2_awready       ,

  // ch2_w channel
  output logic [ 31:  0]    user2_wdata         ,
  output logic [ 15:  0]    user2_wstrb         ,
  output logic              user2_wlast         ,
  output logic              user2_wvalid        ,
  input  logic              user2_wready        ,

  // ch2_r channel
  input  logic [ 31:  0]    user2_rdata         ,
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
  output logic [ 31:  0]    user3_araddr        ,
  output logic              user3_arvalid       ,
  input  logic              user3_arready       ,

  // ch3_aw channel
  output logic [  1:  0]    user3_awsize        ,
  output logic [  7:  0]    user3_awlen         ,
  output logic [  1:  0]    user3_awburst       ,
  output logic [ 31:  0]    user3_awaddr        ,
  output logic              user3_awvalid       ,
  input  logic              user3_awready       ,

  // ch3_w channel
  output logic [ 31:  0]    user3_wdata         ,
  output logic [ 15:  0]    user3_wstrb         ,
  output logic              user3_wlast         ,
  output logic              user3_wvalid        ,
  input  logic              user3_wready        ,

  // ch3_r channel
  input  logic [ 31:  0]    user3_rdata         ,
  input  logic              user3_rlast         ,
  input  logic [  1:  0]    user3_rresp         ,
  input  logic              user3_rvalid        ,
  output logic              user3_rready        ,

  // ch3_b channel
  input  logic [  1:  0]    user3_bresp         ,
  input  logic              user3_bvalid        ,
  output logic              user3_bready        ,

  // Logic Link Interfaces
  input  logic              user_ch0_ar_valid   ,
  input  logic [ 43:  0]    rxfifo_ch0_ar_data  ,
  output logic              user_ch0_ar_ready   ,

  input  logic              user_ch0_aw_valid   ,
  input  logic [ 43:  0]    rxfifo_ch0_aw_data  ,
  output logic              user_ch0_aw_ready   ,

  input  logic              user_ch0_w_valid    ,
  input  logic [ 48:  0]    rxfifo_ch0_w_data   ,
  output logic              user_ch0_w_ready    ,

  output logic              user_ch0_r_valid    ,
  output logic [ 34:  0]    txfifo_ch0_r_data   ,
  input  logic              user_ch0_r_ready    ,

  output logic              user_ch0_b_valid    ,
  output logic [  1:  0]    txfifo_ch0_b_data   ,
  input  logic              user_ch0_b_ready    ,

  input  logic              user_ch1_ar_valid   ,
  input  logic [ 43:  0]    rxfifo_ch1_ar_data  ,
  output logic              user_ch1_ar_ready   ,

  input  logic              user_ch1_aw_valid   ,
  input  logic [ 43:  0]    rxfifo_ch1_aw_data  ,
  output logic              user_ch1_aw_ready   ,

  input  logic              user_ch1_w_valid    ,
  input  logic [ 48:  0]    rxfifo_ch1_w_data   ,
  output logic              user_ch1_w_ready    ,

  output logic              user_ch1_r_valid    ,
  output logic [ 34:  0]    txfifo_ch1_r_data   ,
  input  logic              user_ch1_r_ready    ,

  output logic              user_ch1_b_valid    ,
  output logic [  1:  0]    txfifo_ch1_b_data   ,
  input  logic              user_ch1_b_ready    ,

  input  logic              user_ch2_ar_valid   ,
  input  logic [ 43:  0]    rxfifo_ch2_ar_data  ,
  output logic              user_ch2_ar_ready   ,

  input  logic              user_ch2_aw_valid   ,
  input  logic [ 43:  0]    rxfifo_ch2_aw_data  ,
  output logic              user_ch2_aw_ready   ,

  input  logic              user_ch2_w_valid    ,
  input  logic [ 48:  0]    rxfifo_ch2_w_data   ,
  output logic              user_ch2_w_ready    ,

  output logic              user_ch2_r_valid    ,
  output logic [ 34:  0]    txfifo_ch2_r_data   ,
  input  logic              user_ch2_r_ready    ,

  output logic              user_ch2_b_valid    ,
  output logic [  1:  0]    txfifo_ch2_b_data   ,
  input  logic              user_ch2_b_ready    ,

  input  logic              user_ch3_ar_valid   ,
  input  logic [ 43:  0]    rxfifo_ch3_ar_data  ,
  output logic              user_ch3_ar_ready   ,

  input  logic              user_ch3_aw_valid   ,
  input  logic [ 43:  0]    rxfifo_ch3_aw_data  ,
  output logic              user_ch3_aw_ready   ,

  input  logic              user_ch3_w_valid    ,
  input  logic [ 48:  0]    rxfifo_ch3_w_data   ,
  output logic              user_ch3_w_ready    ,

  output logic              user_ch3_r_valid    ,
  output logic [ 34:  0]    txfifo_ch3_r_data   ,
  input  logic              user_ch3_r_ready    ,

  output logic              user_ch3_b_valid    ,
  output logic [  1:  0]    txfifo_ch3_b_data   ,
  input  logic              user_ch3_b_ready    ,

  input  logic              m_gen2_mode         

);

  assign user0_arvalid                    = user_ch0_ar_valid                ;
  assign user_ch0_ar_ready                = user0_arready                    ;
  assign user0_arsize         [  0 +:  2] = rxfifo_ch0_ar_data   [  0 +:  2] ;
  assign user0_arlen          [  0 +:  8] = rxfifo_ch0_ar_data   [  2 +:  8] ;
  assign user0_arburst        [  0 +:  2] = rxfifo_ch0_ar_data   [ 10 +:  2] ;
  assign user0_araddr         [  0 +: 32] = rxfifo_ch0_ar_data   [ 12 +: 32] ;

  assign user0_awvalid                    = user_ch0_aw_valid                ;
  assign user_ch0_aw_ready                = user0_awready                    ;
  assign user0_awsize         [  0 +:  2] = rxfifo_ch0_aw_data   [  0 +:  2] ;
  assign user0_awlen          [  0 +:  8] = rxfifo_ch0_aw_data   [  2 +:  8] ;
  assign user0_awburst        [  0 +:  2] = rxfifo_ch0_aw_data   [ 10 +:  2] ;
  assign user0_awaddr         [  0 +: 32] = rxfifo_ch0_aw_data   [ 12 +: 32] ;

  assign user0_wvalid                     = user_ch0_w_valid                 ;
  assign user_ch0_w_ready                 = user0_wready                     ;
  assign user0_wdata          [  0 +: 32] = rxfifo_ch0_w_data    [  0 +: 32] ;
  assign user0_wstrb          [  0 +: 16] = rxfifo_ch0_w_data    [ 32 +: 16] ;
  assign user0_wlast                      = rxfifo_ch0_w_data    [ 48 +:  1] ;

  assign user_ch0_r_valid                 = user0_rvalid                     ;
  assign user0_rready                     = user_ch0_r_ready                 ;
  assign txfifo_ch0_r_data    [  0 +: 32] = user0_rdata          [  0 +: 32] ;
  assign txfifo_ch0_r_data    [ 32 +:  1] = user0_rlast                      ;
  assign txfifo_ch0_r_data    [ 33 +:  2] = user0_rresp          [  0 +:  2] ;

  assign user_ch0_b_valid                 = user0_bvalid                     ;
  assign user0_bready                     = user_ch0_b_ready                 ;
  assign txfifo_ch0_b_data    [  0 +:  2] = user0_bresp          [  0 +:  2] ;

  assign user1_arvalid                    = user_ch1_ar_valid                ;
  assign user_ch1_ar_ready                = user1_arready                    ;
  assign user1_arsize         [  0 +:  2] = rxfifo_ch1_ar_data   [  0 +:  2] ;
  assign user1_arlen          [  0 +:  8] = rxfifo_ch1_ar_data   [  2 +:  8] ;
  assign user1_arburst        [  0 +:  2] = rxfifo_ch1_ar_data   [ 10 +:  2] ;
  assign user1_araddr         [  0 +: 32] = rxfifo_ch1_ar_data   [ 12 +: 32] ;

  assign user1_awvalid                    = user_ch1_aw_valid                ;
  assign user_ch1_aw_ready                = user1_awready                    ;
  assign user1_awsize         [  0 +:  2] = rxfifo_ch1_aw_data   [  0 +:  2] ;
  assign user1_awlen          [  0 +:  8] = rxfifo_ch1_aw_data   [  2 +:  8] ;
  assign user1_awburst        [  0 +:  2] = rxfifo_ch1_aw_data   [ 10 +:  2] ;
  assign user1_awaddr         [  0 +: 32] = rxfifo_ch1_aw_data   [ 12 +: 32] ;

  assign user1_wvalid                     = user_ch1_w_valid                 ;
  assign user_ch1_w_ready                 = user1_wready                     ;
  assign user1_wdata          [  0 +: 32] = rxfifo_ch1_w_data    [  0 +: 32] ;
  assign user1_wstrb          [  0 +: 16] = rxfifo_ch1_w_data    [ 32 +: 16] ;
  assign user1_wlast                      = rxfifo_ch1_w_data    [ 48 +:  1] ;

  assign user_ch1_r_valid                 = user1_rvalid                     ;
  assign user1_rready                     = user_ch1_r_ready                 ;
  assign txfifo_ch1_r_data    [  0 +: 32] = user1_rdata          [  0 +: 32] ;
  assign txfifo_ch1_r_data    [ 32 +:  1] = user1_rlast                      ;
  assign txfifo_ch1_r_data    [ 33 +:  2] = user1_rresp          [  0 +:  2] ;

  assign user_ch1_b_valid                 = user1_bvalid                     ;
  assign user1_bready                     = user_ch1_b_ready                 ;
  assign txfifo_ch1_b_data    [  0 +:  2] = user1_bresp          [  0 +:  2] ;

  assign user2_arvalid                    = user_ch2_ar_valid                ;
  assign user_ch2_ar_ready                = user2_arready                    ;
  assign user2_arsize         [  0 +:  2] = rxfifo_ch2_ar_data   [  0 +:  2] ;
  assign user2_arlen          [  0 +:  8] = rxfifo_ch2_ar_data   [  2 +:  8] ;
  assign user2_arburst        [  0 +:  2] = rxfifo_ch2_ar_data   [ 10 +:  2] ;
  assign user2_araddr         [  0 +: 32] = rxfifo_ch2_ar_data   [ 12 +: 32] ;

  assign user2_awvalid                    = user_ch2_aw_valid                ;
  assign user_ch2_aw_ready                = user2_awready                    ;
  assign user2_awsize         [  0 +:  2] = rxfifo_ch2_aw_data   [  0 +:  2] ;
  assign user2_awlen          [  0 +:  8] = rxfifo_ch2_aw_data   [  2 +:  8] ;
  assign user2_awburst        [  0 +:  2] = rxfifo_ch2_aw_data   [ 10 +:  2] ;
  assign user2_awaddr         [  0 +: 32] = rxfifo_ch2_aw_data   [ 12 +: 32] ;

  assign user2_wvalid                     = user_ch2_w_valid                 ;
  assign user_ch2_w_ready                 = user2_wready                     ;
  assign user2_wdata          [  0 +: 32] = rxfifo_ch2_w_data    [  0 +: 32] ;
  assign user2_wstrb          [  0 +: 16] = rxfifo_ch2_w_data    [ 32 +: 16] ;
  assign user2_wlast                      = rxfifo_ch2_w_data    [ 48 +:  1] ;

  assign user_ch2_r_valid                 = user2_rvalid                     ;
  assign user2_rready                     = user_ch2_r_ready                 ;
  assign txfifo_ch2_r_data    [  0 +: 32] = user2_rdata          [  0 +: 32] ;
  assign txfifo_ch2_r_data    [ 32 +:  1] = user2_rlast                      ;
  assign txfifo_ch2_r_data    [ 33 +:  2] = user2_rresp          [  0 +:  2] ;

  assign user_ch2_b_valid                 = user2_bvalid                     ;
  assign user2_bready                     = user_ch2_b_ready                 ;
  assign txfifo_ch2_b_data    [  0 +:  2] = user2_bresp          [  0 +:  2] ;

  assign user3_arvalid                    = user_ch3_ar_valid                ;
  assign user_ch3_ar_ready                = user3_arready                    ;
  assign user3_arsize         [  0 +:  2] = rxfifo_ch3_ar_data   [  0 +:  2] ;
  assign user3_arlen          [  0 +:  8] = rxfifo_ch3_ar_data   [  2 +:  8] ;
  assign user3_arburst        [  0 +:  2] = rxfifo_ch3_ar_data   [ 10 +:  2] ;
  assign user3_araddr         [  0 +: 32] = rxfifo_ch3_ar_data   [ 12 +: 32] ;

  assign user3_awvalid                    = user_ch3_aw_valid                ;
  assign user_ch3_aw_ready                = user3_awready                    ;
  assign user3_awsize         [  0 +:  2] = rxfifo_ch3_aw_data   [  0 +:  2] ;
  assign user3_awlen          [  0 +:  8] = rxfifo_ch3_aw_data   [  2 +:  8] ;
  assign user3_awburst        [  0 +:  2] = rxfifo_ch3_aw_data   [ 10 +:  2] ;
  assign user3_awaddr         [  0 +: 32] = rxfifo_ch3_aw_data   [ 12 +: 32] ;

  assign user3_wvalid                     = user_ch3_w_valid                 ;
  assign user_ch3_w_ready                 = user3_wready                     ;
  assign user3_wdata          [  0 +: 32] = rxfifo_ch3_w_data    [  0 +: 32] ;
  assign user3_wstrb          [  0 +: 16] = rxfifo_ch3_w_data    [ 32 +: 16] ;
  assign user3_wlast                      = rxfifo_ch3_w_data    [ 48 +:  1] ;

  assign user_ch3_r_valid                 = user3_rvalid                     ;
  assign user3_rready                     = user_ch3_r_ready                 ;
  assign txfifo_ch3_r_data    [  0 +: 32] = user3_rdata          [  0 +: 32] ;
  assign txfifo_ch3_r_data    [ 32 +:  1] = user3_rlast                      ;
  assign txfifo_ch3_r_data    [ 33 +:  2] = user3_rresp          [  0 +:  2] ;

  assign user_ch3_b_valid                 = user3_bvalid                     ;
  assign user3_bready                     = user_ch3_b_ready                 ;
  assign txfifo_ch3_b_data    [  0 +:  2] = user3_bresp          [  0 +:  2] ;

endmodule
