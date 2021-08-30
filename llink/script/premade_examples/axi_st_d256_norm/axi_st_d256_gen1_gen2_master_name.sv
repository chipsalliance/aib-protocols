module axi_st_d256_gen1_gen2_master_name  (

  // st channel
  input  logic [ 31:  0]    user_tkeep          ,
  input  logic [255:  0]    user_tdata          ,
  input  logic              user_tlast          ,
  input  logic              user_tvalid         ,
  output logic              user_tready         ,

  // Logic Link Interfaces
  output logic              user_st_valid       ,
  output logic [288:  0]    txfifo_st_data      ,
  input  logic              user_st_ready       ,

  input  logic              m_gen2_mode         

);

  assign user_st_valid                    = user_tvalid                      ;
  assign user_tready                      = user_st_ready                    ;
  assign txfifo_st_data       [  0 +: 32] = user_tkeep           [  0 +: 32] ;
  assign txfifo_st_data       [ 32 +:256] = user_tdata           [  0 +:256] ;
  assign txfifo_st_data       [288 +:  1] = user_tlast                       ;

endmodule
