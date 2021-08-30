module lpif_txrx_x16_f2_master_name  (

  // downstream channel
  input  logic [   3:   0]   dstrm_state         ,
  input  logic [   1:   0]   dstrm_protid        ,
  input  logic [ 255:   0]   dstrm_data          ,
  input  logic [   4:   0]   dstrm_bstart        ,
  input  logic [  31:   0]   dstrm_bvalid        ,
  input  logic [   0:   0]   dstrm_valid         ,

  // upstream channel
  output logic [   3:   0]   ustrm_state         ,
  output logic [   1:   0]   ustrm_protid        ,
  output logic [ 255:   0]   ustrm_data          ,
  output logic [   4:   0]   ustrm_bstart        ,
  output logic [  31:   0]   ustrm_bvalid        ,
  output logic [   0:   0]   ustrm_valid         ,

  // Logic Link Interfaces
  output logic [ 299:   0]   txfifo_downstream_data,

  input  logic [ 299:   0]   rxfifo_upstream_data,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_downstream_valid               = 1'b1                               ; // user_downstream_valid is unused
  // user_downstream_ready is unused
  assign txfifo_downstream_data [   0 +:   4] = dstrm_state          [   0 +:   4] ;
  assign txfifo_downstream_data [   4 +:   2] = dstrm_protid         [   0 +:   2] ;
  assign txfifo_downstream_data [   6 +: 256] = dstrm_data           [   0 +: 256] ;
  assign txfifo_downstream_data [ 262 +:   5] = dstrm_bstart         [   0 +:   5] ;
  assign txfifo_downstream_data [ 267 +:  32] = dstrm_bvalid         [   0 +:  32] ;
  assign txfifo_downstream_data [ 299 +:   1] = dstrm_valid          [   0 +:   1] ;

  // user_upstream_valid is unused
  assign user_upstream_ready                = 1'b1                               ; // user_upstream_ready is unused
  assign ustrm_state          [   0 +:   4] = rxfifo_upstream_data [   0 +:   4] ;
  assign ustrm_protid         [   0 +:   2] = rxfifo_upstream_data [   4 +:   2] ;
  assign ustrm_data           [   0 +: 256] = rxfifo_upstream_data [   6 +: 256] ;
  assign ustrm_bstart         [   0 +:   5] = rxfifo_upstream_data [ 262 +:   5] ;
  assign ustrm_bvalid         [   0 +:  32] = rxfifo_upstream_data [ 267 +:  32] ;
  assign ustrm_valid          [   0 +:   1] = rxfifo_upstream_data [ 299 +:   1] ;

endmodule
