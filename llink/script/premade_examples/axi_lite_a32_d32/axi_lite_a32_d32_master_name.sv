module axi_lite_a32_d32_master_name  (

  // ar_lite channel
  input  logic [ 31:  0]    user_araddr         ,
  input  logic              user_arvalid        ,
  output logic              user_arready        ,

  // aw_lite channel
  input  logic [ 31:  0]    user_awaddr         ,
  input  logic              user_awvalid        ,
  output logic              user_awready        ,

  // w_lite channel
  input  logic [ 31:  0]    user_wdata          ,
  input  logic [  3:  0]    user_wstrb          ,
  input  logic              user_wvalid         ,
  output logic              user_wready         ,

  // r_lite channel
  output logic [ 31:  0]    user_rdata          ,
  output logic [  1:  0]    user_rresp          ,
  output logic              user_rvalid         ,
  input  logic              user_rready         ,

  // b_lite channel
  output logic [  1:  0]    user_bresp          ,
  output logic              user_bvalid         ,
  input  logic              user_bready         ,

  // Logic Link Interfaces
  output logic              user_ar_lite_valid  ,
  output logic [ 31:  0]    txfifo_ar_lite_data ,
  input  logic              user_ar_lite_ready  ,

  output logic              user_aw_lite_valid  ,
  output logic [ 31:  0]    txfifo_aw_lite_data ,
  input  logic              user_aw_lite_ready  ,

  output logic              user_w_lite_valid   ,
  output logic [ 35:  0]    txfifo_w_lite_data  ,
  input  logic              user_w_lite_ready   ,

  input  logic              user_r_lite_valid   ,
  input  logic [ 33:  0]    rxfifo_r_lite_data  ,
  output logic              user_r_lite_ready   ,

  input  logic              user_b_lite_valid   ,
  input  logic [  1:  0]    rxfifo_b_lite_data  ,
  output logic              user_b_lite_ready   ,

  input  logic              m_gen2_mode         

);

  assign user_ar_lite_valid               = user_arvalid                     ;
  assign user_arready                     = user_ar_lite_ready               ;
  assign txfifo_ar_lite_data  [  0 +: 32] = user_araddr          [  0 +: 32] ;

  assign user_aw_lite_valid               = user_awvalid                     ;
  assign user_awready                     = user_aw_lite_ready               ;
  assign txfifo_aw_lite_data  [  0 +: 32] = user_awaddr          [  0 +: 32] ;

  assign user_w_lite_valid                = user_wvalid                      ;
  assign user_wready                      = user_w_lite_ready                ;
  assign txfifo_w_lite_data   [  0 +: 32] = user_wdata           [  0 +: 32] ;
  assign txfifo_w_lite_data   [ 32 +:  4] = user_wstrb           [  0 +:  4] ;

  assign user_rvalid                      = user_r_lite_valid                ;
  assign user_r_lite_ready                = user_rready                      ;
  assign user_rdata           [  0 +: 32] = rxfifo_r_lite_data   [  0 +: 32] ;
  assign user_rresp           [  0 +:  2] = rxfifo_r_lite_data   [ 32 +:  2] ;

  assign user_bvalid                      = user_b_lite_valid                ;
  assign user_b_lite_ready                = user_bready                      ;
  assign user_bresp           [  0 +:  2] = rxfifo_b_lite_data   [  0 +:  2] ;

endmodule
