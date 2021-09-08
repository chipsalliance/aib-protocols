module axi_st_d64_nordy_slave_name  (

  // st channel
  output logic [   7:   0]   user_tkeep          ,
  output logic [  63:   0]   user_tdata          ,
  output logic               user_tlast          ,
  output logic               user_tvalid         ,

  // Logic Link Interfaces
  input  logic [  73:   0]   rxfifo_st_data      ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  // user_st_valid is unused
  assign user_st_ready                      = 1'b1                               ; // user_st_ready is unused
  assign user_tkeep           [   0 +:   8] = rxfifo_st_data       [   0 +:   8] ;
  assign user_tdata           [   0 +:  64] = rxfifo_st_data       [   8 +:  64] ;
  assign user_tlast                         = rxfifo_st_data       [  72 +:   1] ;
  assign user_tvalid                        = rxfifo_st_data       [  73 +:   1] ;

endmodule
