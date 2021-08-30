module axi_st_d64_master_name  (

  // st channel
  input  logic [   7:   0]   user_tkeep          ,
  input  logic [  63:   0]   user_tdata          ,
  input  logic               user_tlast          ,
  input  logic               user_tvalid         ,
  output logic               user_tready         ,

  // Logic Link Interfaces
  output logic               user_st_valid       ,
  output logic [  72:   0]   txfifo_st_data      ,
  input  logic               user_st_ready       ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_st_valid                      = user_tvalid                        ;
  assign user_tready                        = user_st_ready                      ;
  assign txfifo_st_data       [   0 +:   8] = user_tkeep           [   0 +:   8] ;
  assign txfifo_st_data       [   8 +:  64] = user_tdata           [   0 +:  64] ;
  assign txfifo_st_data       [  72 +:   1] = user_tlast                         ;

endmodule
