module lpif_txrx_x16_f2_slave_name  (

  // downstream channel
  output logic [   3:   0]   dstrm_state         ,
  output logic [   1:   0]   dstrm_protid        ,
  output logic [ 255:   0]   dstrm_data          ,
  output logic [   0:   0]   dstrm_dvalid        ,
  output logic [  15:   0]   dstrm_crc           ,
  output logic [   0:   0]   dstrm_crc_valid     ,
  output logic [   0:   0]   dstrm_valid         ,

  // upstream channel
  input  logic [   3:   0]   ustrm_state         ,
  input  logic [   1:   0]   ustrm_protid        ,
  input  logic [ 255:   0]   ustrm_data          ,
  input  logic [   0:   0]   ustrm_dvalid        ,
  input  logic [  15:   0]   ustrm_crc           ,
  input  logic [   0:   0]   ustrm_crc_valid     ,
  input  logic [   0:   0]   ustrm_valid         ,

  // Logic Link Interfaces
  input  logic [ 280:   0]   rxfifo_downstream_data,

  output logic [ 280:   0]   txfifo_upstream_data,

  input  logic               m_gen2_mode         

);

  // Connect Data

  // user_downstream_valid is unused
  assign user_downstream_ready               = 1'b1                               ; // user_downstream_ready is unused
  assign dstrm_state          [   0 +:   4] = rxfifo_downstream_data [   0 +:   4] ;
  assign dstrm_protid         [   0 +:   2] = rxfifo_downstream_data [   4 +:   2] ;
  assign dstrm_data           [   0 +: 256] = rxfifo_downstream_data [   6 +: 256] ;
  assign dstrm_dvalid         [   0 +:   1] = rxfifo_downstream_data [ 262 +:   1] ;
  assign dstrm_crc            [   0 +:  16] = rxfifo_downstream_data [ 263 +:  16] ;
  assign dstrm_crc_valid      [   0 +:   1] = rxfifo_downstream_data [ 279 +:   1] ;
  assign dstrm_valid          [   0 +:   1] = rxfifo_downstream_data [ 280 +:   1] ;

  assign user_upstream_valid                = 1'b1                               ; // user_upstream_valid is unused
  // user_upstream_ready is unused
  assign txfifo_upstream_data [   0 +:   4] = ustrm_state          [   0 +:   4] ;
  assign txfifo_upstream_data [   4 +:   2] = ustrm_protid         [   0 +:   2] ;
  assign txfifo_upstream_data [   6 +: 256] = ustrm_data           [   0 +: 256] ;
  assign txfifo_upstream_data [ 262 +:   1] = ustrm_dvalid         [   0 +:   1] ;
  assign txfifo_upstream_data [ 263 +:  16] = ustrm_crc            [   0 +:  16] ;
  assign txfifo_upstream_data [ 279 +:   1] = ustrm_crc_valid      [   0 +:   1] ;
  assign txfifo_upstream_data [ 280 +:   1] = ustrm_valid          [   0 +:   1] ;

endmodule
