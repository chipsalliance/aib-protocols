module lpif_txrx_x16_f1_master_name  (

  // downstream channel
  input  logic [   3:   0]   dstrm_state         ,
  input  logic [   1:   0]   dstrm_protid        ,
  input  logic [ 511:   0]   dstrm_data          ,
  input  logic [   5:   0]   dstrm_bstart        ,
  input  logic [  63:   0]   dstrm_bvalid        ,
  input  logic [   0:   0]   dstrm_valid         ,

  // upstream channel
  output logic [   3:   0]   ustrm_state         ,
  output logic [   1:   0]   ustrm_protid        ,
  output logic [ 511:   0]   ustrm_data          ,
  output logic [   5:   0]   ustrm_bstart        ,
  output logic [  63:   0]   ustrm_bvalid        ,
  output logic [   0:   0]   ustrm_valid         ,

  // Logic Link Interfaces
  output logic [ 588:   0]   txfifo_downstream_data,

  input  logic [ 588:   0]   rxfifo_upstream_data,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_downstream_valid               = 1'b1                               ; // user_downstream_valid is unused
  // user_downstream_ready is unused
  assign txfifo_downstream_data [   0 +:   4] = dstrm_state          [   0 +:   4] ;
  assign txfifo_downstream_data [   4 +:   2] = dstrm_protid         [   0 +:   2] ;
  assign txfifo_downstream_data [   6 +: 512] = dstrm_data           [   0 +: 512] ;
  assign txfifo_downstream_data [ 518 +:   6] = dstrm_bstart         [   0 +:   6] ;
  assign txfifo_downstream_data [ 524 +:  64] = dstrm_bvalid         [   0 +:  64] ;
  assign txfifo_downstream_data [ 588 +:   1] = dstrm_valid          [   0 +:   1] ;

  // user_upstream_valid is unused
  assign user_upstream_ready                = 1'b1                               ; // user_upstream_ready is unused
  assign ustrm_state          [   0 +:   4] = rxfifo_upstream_data [   0 +:   4] ;
  assign ustrm_protid         [   0 +:   2] = rxfifo_upstream_data [   4 +:   2] ;
  assign ustrm_data           [   0 +: 512] = rxfifo_upstream_data [   6 +: 512] ;
  assign ustrm_bstart         [   0 +:   6] = rxfifo_upstream_data [ 518 +:   6] ;
  assign ustrm_bvalid         [   0 +:  64] = rxfifo_upstream_data [ 524 +:  64] ;
  assign ustrm_valid          [   0 +:   1] = rxfifo_upstream_data [ 588 +:   1] ;

endmodule
