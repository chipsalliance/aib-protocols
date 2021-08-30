module axi_st_d128_asym_full_master_name  (

  // st channel
  input  logic [  15:   0]   user_tkeep          ,
  input  logic [ 127:   0]   user_tdata          ,
  input  logic [   0:   0]   user_tuser          ,
  input  logic               user_tvalid         ,
  output logic               user_tready         ,

  // Logic Link Interfaces
  output logic               user_st_valid       ,
  output logic [ 144:   0]   txfifo_st_data      ,
  input  logic               user_st_ready       ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_st_valid                      = user_tvalid                        ;
  assign user_tready                        = user_st_ready                      ;
  assign txfifo_st_data       [   0 +:  16] = user_tkeep           [   0 +:  16] ;
  assign txfifo_st_data       [  16 +: 128] = user_tdata           [   0 +: 128] ;
  assign txfifo_st_data       [ 144 +:   1] = user_tuser           [   0 +:   1] ;

endmodule
