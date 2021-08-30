module axi_st_d256_gen1_gen2_slave_name  (

  // st channel
  output logic [ 31:  0]    user_tkeep          ,
  output logic [255:  0]    user_tdata          ,
  output logic              user_tlast          ,
  output logic              user_tvalid         ,
  input  logic              user_tready         ,

  // Logic Link Interfaces
  input  logic              user_st_valid       ,
  input  logic [288:  0]    rxfifo_st_data      ,
  output logic              user_st_ready       ,

  input  logic              m_gen2_mode         

);

  assign user_tvalid                      = user_st_valid                    ;
  assign user_st_ready                    = user_tready                      ;
  assign user_tkeep           [  0 +: 32] = rxfifo_st_data       [  0 +: 32] ;
  assign user_tdata           [  0 +:256] = rxfifo_st_data       [ 32 +:256] ;
  assign user_tlast                       = rxfifo_st_data       [288 +:  1] ;

endmodule
