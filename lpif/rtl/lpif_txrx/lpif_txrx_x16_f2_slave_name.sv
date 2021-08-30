module lpif_txrx_x16_f2_slave_name  (

  // downstream channel
  output logic [   3:   0]   dstrm_state         ,
  output logic [   1:   0]   dstrm_protid        ,
  output logic [ 255:   0]   dstrm_data          ,
  output logic [   4:   0]   dstrm_bstart        ,
  output logic [  31:   0]   dstrm_bvalid        ,
  output logic [   0:   0]   dstrm_valid         ,

  // upstream channel
  input  logic [   3:   0]   ustrm_state         ,
  input  logic [   1:   0]   ustrm_protid        ,
  input  logic [ 255:   0]   ustrm_data          ,
  input  logic [   4:   0]   ustrm_bstart        ,
  input  logic [  31:   0]   ustrm_bvalid        ,
  input  logic [   0:   0]   ustrm_valid         ,

  // Logic Link Interfaces
  input  logic [ 299:   0]   rxfifo_downstream_data,

  output logic [ 299:   0]   txfifo_upstream_data,

  input  logic               m_gen2_mode         

);

  // Connect Data

  // user_downstream_valid is unused
  assign user_downstream_ready               = 1'b1                               ; // user_downstream_ready is unused
  assign dstrm_state          [   0 +:   4] = rxfifo_downstream_data [   0 +:   4] ;
  assign dstrm_protid         [   0 +:   2] = rxfifo_downstream_data [   4 +:   2] ;
  assign dstrm_data           [   0 +: 256] = rxfifo_downstream_data [   6 +: 256] ;
  assign dstrm_bstart         [   0 +:   5] = rxfifo_downstream_data [ 262 +:   5] ;
  assign dstrm_bvalid         [   0 +:  32] = rxfifo_downstream_data [ 267 +:  32] ;
  assign dstrm_valid          [   0 +:   1] = rxfifo_downstream_data [ 299 +:   1] ;

  assign user_upstream_valid                = 1'b1                               ; // user_upstream_valid is unused
  // user_upstream_ready is unused
  assign txfifo_upstream_data [   0 +:   4] = ustrm_state          [   0 +:   4] ;
  assign txfifo_upstream_data [   4 +:   2] = ustrm_protid         [   0 +:   2] ;
  assign txfifo_upstream_data [   6 +: 256] = ustrm_data           [   0 +: 256] ;
  assign txfifo_upstream_data [ 262 +:   5] = ustrm_bstart         [   0 +:   5] ;
  assign txfifo_upstream_data [ 267 +:  32] = ustrm_bvalid         [   0 +:  32] ;
  assign txfifo_upstream_data [ 299 +:   1] = ustrm_valid          [   0 +:   1] ;

endmodule
