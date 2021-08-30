module axi_st_d256_dm_drng_2_up_half_master_name  (

  // st channel
  input  logic [ 511:   0]   user_tdata          ,
  input  logic               user_tvalid         ,
  output logic               user_tready         ,

  // Logic Link Interfaces
  output logic               user_st_valid       ,
  output logic [ 511:   0]   txfifo_st_data      ,
  input  logic               user_st_ready       ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_st_valid                      = user_tvalid                        ;
  assign user_tready                        = user_st_ready                      ;
  assign txfifo_st_data       [   0 +: 256] = user_tdata           [   0 +: 256] ;
  assign txfifo_st_data       [ 256 +: 256] = user_tdata           [ 256 +: 256] ;

endmodule
