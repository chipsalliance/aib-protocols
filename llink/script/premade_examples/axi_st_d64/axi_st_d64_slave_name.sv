module axi_st_d64_slave_name  (

  // st channel
  output logic [   7:   0]   user_tkeep          ,
  output logic [  63:   0]   user_tdata          ,
  output logic               user_tlast          ,
  output logic               user_tvalid         ,
  input  logic               user_tready         ,

  // Logic Link Interfaces
  input  logic               user_st_valid       ,
  input  logic [  72:   0]   rxfifo_st_data      ,
  output logic               user_st_ready       ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_tvalid                        = user_st_valid                      ;
  assign user_st_ready                      = user_tready                        ;
  assign user_tkeep           [   0 +:   8] = rxfifo_st_data       [   0 +:   8] ;
  assign user_tdata           [   0 +:  64] = rxfifo_st_data       [   8 +:  64] ;
  assign user_tlast                         = rxfifo_st_data       [  72 +:   1] ;

endmodule
