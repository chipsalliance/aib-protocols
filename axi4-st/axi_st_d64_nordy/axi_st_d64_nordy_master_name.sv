module axi_st_d64_nordy_master_name  (

  // st channel
  input  logic [   7:   0]   user_tkeep          ,
  input  logic [  63:   0]   user_tdata          ,
  input  logic               user_tlast          ,
  input  logic               user_tvalid         ,

  // Logic Link Interfaces
  output logic [  73:   0]   txfifo_st_data      ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_st_valid                      = 1'b1                               ; // user_st_valid is unused
  // user_st_ready is unused
  assign txfifo_st_data       [   0 +:   8] = user_tkeep           [   0 +:   8] ;
  assign txfifo_st_data       [   8 +:  64] = user_tdata           [   0 +:  64] ;
  assign txfifo_st_data       [  72 +:   1] = user_tlast                         ;
  assign txfifo_st_data       [  73 +:   1] = user_tvalid                        ;

endmodule
