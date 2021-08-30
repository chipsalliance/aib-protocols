module axi_st_d256_multichannel_full_slave_name  (

  // st channel
  output logic [ 255:   0]   user_tdata          ,
  output logic               user_tvalid         ,
  input  logic               user_tready         ,
  output logic [   0:   0]   user_enable         ,

  // Logic Link Interfaces
  input  logic               user_st_valid       ,
  input  logic [ 256:   0]   rxfifo_st_data      ,
  output logic               user_st_ready       ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_tvalid                        = user_st_valid                      ;
  assign user_st_ready                      = user_tready                        ;
  assign user_tdata           [   0 +: 256] = rxfifo_st_data       [   0 +: 256] ;
  assign user_enable          [   0 +:   1] = rxfifo_st_data       [ 256 +:   1] ;

endmodule
