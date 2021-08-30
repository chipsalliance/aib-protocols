module axi_st_d128_asym_quarter_slave_name  (

  // st channel
  output logic [  63:   0]   user_tkeep          ,
  output logic [ 511:   0]   user_tdata          ,
  output logic [   3:   0]   user_tuser          ,
  output logic               user_tvalid         ,
  input  logic               user_tready         ,
  output logic [   3:   0]   user_enable         ,

  // Logic Link Interfaces
  input  logic               user_st_valid       ,
  input  logic [ 583:   0]   rxfifo_st_data      ,
  output logic               user_st_ready       ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_tvalid                        = user_st_valid                      ;
  assign user_st_ready                      = user_tready                        ;
  assign user_tkeep           [   0 +:  16] = rxfifo_st_data       [   0 +:  16] ;
  assign user_tdata           [   0 +: 128] = rxfifo_st_data       [  16 +: 128] ;
  assign user_tuser           [   0 +:   1] = rxfifo_st_data       [ 144 +:   1] ;
  assign user_enable          [   0 +:   1] = rxfifo_st_data       [ 580 +:   1] ;
  assign user_tkeep           [  16 +:  16] = rxfifo_st_data       [ 145 +:  16] ;
  assign user_tdata           [ 128 +: 128] = rxfifo_st_data       [ 161 +: 128] ;
  assign user_tuser           [   1 +:   1] = rxfifo_st_data       [ 289 +:   1] ;
  assign user_enable          [   1 +:   1] = rxfifo_st_data       [ 581 +:   1] ;
  assign user_tkeep           [  32 +:  16] = rxfifo_st_data       [ 290 +:  16] ;
  assign user_tdata           [ 256 +: 128] = rxfifo_st_data       [ 306 +: 128] ;
  assign user_tuser           [   2 +:   1] = rxfifo_st_data       [ 434 +:   1] ;
  assign user_enable          [   2 +:   1] = rxfifo_st_data       [ 582 +:   1] ;
  assign user_tkeep           [  48 +:  16] = rxfifo_st_data       [ 435 +:  16] ;
  assign user_tdata           [ 384 +: 128] = rxfifo_st_data       [ 451 +: 128] ;
  assign user_tuser           [   3 +:   1] = rxfifo_st_data       [ 579 +:   1] ;
  assign user_enable          [   3 +:   1] = rxfifo_st_data       [ 583 +:   1] ;

endmodule
