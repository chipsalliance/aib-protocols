module axi_mm_a32_d128_packet_master_name  (

  // ar channel
  input  logic [   3:   0]   user_arid           ,
  input  logic [   2:   0]   user_arsize         ,
  input  logic [   7:   0]   user_arlen          ,
  input  logic [   1:   0]   user_arburst        ,
  input  logic [  31:   0]   user_araddr         ,
  input  logic               user_arvalid        ,
  output logic               user_arready        ,

  // aw channel
  input  logic [   3:   0]   user_awid           ,
  input  logic [   2:   0]   user_awsize         ,
  input  logic [   7:   0]   user_awlen          ,
  input  logic [   1:   0]   user_awburst        ,
  input  logic [  31:   0]   user_awaddr         ,
  input  logic               user_awvalid        ,
  output logic               user_awready        ,

  // w channel
  input  logic [   3:   0]   user_wid            ,
  input  logic [ 127:   0]   user_wdata          ,
  input  logic [  15:   0]   user_wstrb          ,
  input  logic               user_wlast          ,
  input  logic               user_wvalid         ,
  output logic               user_wready         ,

  // r channel
  output logic [   3:   0]   user_rid            ,
  output logic [ 127:   0]   user_rdata          ,
  output logic               user_rlast          ,
  output logic [   1:   0]   user_rresp          ,
  output logic               user_rvalid         ,
  input  logic               user_rready         ,

  // b channel
  output logic [   3:   0]   user_bid            ,
  output logic [   1:   0]   user_bresp          ,
  output logic               user_bvalid         ,
  input  logic               user_bready         ,

  // Logic Link Interfaces
  output logic               user_ar_valid       ,
  output logic [  48:   0]   txfifo_ar_data      ,
  input  logic               user_ar_ready       ,

  output logic               user_aw_valid       ,
  output logic [  48:   0]   txfifo_aw_data      ,
  input  logic               user_aw_ready       ,

  output logic               user_w_valid        ,
  output logic [ 148:   0]   txfifo_w_data       ,
  input  logic               user_w_ready        ,

  input  logic               user_r_valid        ,
  input  logic [ 134:   0]   rxfifo_r_data       ,
  output logic               user_r_ready        ,

  input  logic               user_b_valid        ,
  input  logic [   5:   0]   rxfifo_b_data       ,
  output logic               user_b_ready        ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_ar_valid                      = user_arvalid                       ;
  assign user_arready                       = user_ar_ready                      ;
  assign txfifo_ar_data       [   0 +:   4] = user_arid            [   0 +:   4] ;
  assign txfifo_ar_data       [   4 +:   3] = user_arsize          [   0 +:   3] ;
  assign txfifo_ar_data       [   7 +:   8] = user_arlen           [   0 +:   8] ;
  assign txfifo_ar_data       [  15 +:   2] = user_arburst         [   0 +:   2] ;
  assign txfifo_ar_data       [  17 +:  32] = user_araddr          [   0 +:  32] ;

  assign user_aw_valid                      = user_awvalid                       ;
  assign user_awready                       = user_aw_ready                      ;
  assign txfifo_aw_data       [   0 +:   4] = user_awid            [   0 +:   4] ;
  assign txfifo_aw_data       [   4 +:   3] = user_awsize          [   0 +:   3] ;
  assign txfifo_aw_data       [   7 +:   8] = user_awlen           [   0 +:   8] ;
  assign txfifo_aw_data       [  15 +:   2] = user_awburst         [   0 +:   2] ;
  assign txfifo_aw_data       [  17 +:  32] = user_awaddr          [   0 +:  32] ;

  assign user_w_valid                       = user_wvalid                        ;
  assign user_wready                        = user_w_ready                       ;
  assign txfifo_w_data        [   0 +:   4] = user_wid             [   0 +:   4] ;
  assign txfifo_w_data        [   4 +: 128] = user_wdata           [   0 +: 128] ;
  assign txfifo_w_data        [ 132 +:  16] = user_wstrb           [   0 +:  16] ;
  assign txfifo_w_data        [ 148 +:   1] = user_wlast                         ;

  assign user_rvalid                        = user_r_valid                       ;
  assign user_r_ready                       = user_rready                        ;
  assign user_rid             [   0 +:   4] = rxfifo_r_data        [   0 +:   4] ;
  assign user_rdata           [   0 +: 128] = rxfifo_r_data        [   4 +: 128] ;
  assign user_rlast                         = rxfifo_r_data        [ 132 +:   1] ;
  assign user_rresp           [   0 +:   2] = rxfifo_r_data        [ 133 +:   2] ;

  assign user_bvalid                        = user_b_valid                       ;
  assign user_b_ready                       = user_bready                        ;
  assign user_bid             [   0 +:   4] = rxfifo_b_data        [   0 +:   4] ;
  assign user_bresp           [   0 +:   2] = rxfifo_b_data        [   4 +:   2] ;

endmodule
