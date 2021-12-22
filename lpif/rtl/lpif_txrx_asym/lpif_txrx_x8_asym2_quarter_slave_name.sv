////////////////////////////////////////////////////////////
//
//        (C) Copyright 2021 Eximius Design
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
////////////////////////////////////////////////////////////

module lpif_txrx_x8_asym2_quarter_slave_name  (

  // downstream channel
  output logic [  15:   0]   dstrm_state         ,
  output logic [   7:   0]   dstrm_protid        ,
  output logic [ 511:   0]   dstrm_data          ,
  output logic [   3:   0]   dstrm_dvalid        ,
  output logic [  31:   0]   dstrm_crc           ,
  output logic [   3:   0]   dstrm_crc_valid     ,
  output logic [   3:   0]   dstrm_valid         ,

  // upstream channel
  input  logic [  15:   0]   ustrm_state         ,
  input  logic [   7:   0]   ustrm_protid        ,
  input  logic [ 511:   0]   ustrm_data          ,
  input  logic [   3:   0]   ustrm_dvalid        ,
  input  logic [  31:   0]   ustrm_crc           ,
  input  logic [   3:   0]   ustrm_crc_valid     ,
  input  logic [   3:   0]   ustrm_valid         ,

  // Logic Link Interfaces
  input  logic [ 579:   0]   rxfifo_downstream_data,

  output logic [ 579:   0]   txfifo_upstream_data,

  input  logic               m_gen2_mode         

);

  // Connect Data

  // user_downstream_vld is unused
  assign dstrm_state          [   0 +:   4] = rxfifo_downstream_data [   0 +:   4] ;
  assign dstrm_protid         [   0 +:   2] = rxfifo_downstream_data [   4 +:   2] ;
  assign dstrm_data           [   0 +: 128] = rxfifo_downstream_data [   6 +: 128] ;
  assign dstrm_dvalid         [   0 +:   1] = rxfifo_downstream_data [ 134 +:   1] ;
  assign dstrm_crc            [   0 +:   8] = rxfifo_downstream_data [ 135 +:   8] ;
  assign dstrm_crc_valid      [   0 +:   1] = rxfifo_downstream_data [ 143 +:   1] ;
  assign dstrm_valid          [   0 +:   1] = rxfifo_downstream_data [ 144 +:   1] ;
  assign dstrm_state          [   4 +:   4] = rxfifo_downstream_data [ 145 +:   4] ;
  assign dstrm_protid         [   2 +:   2] = rxfifo_downstream_data [ 149 +:   2] ;
  assign dstrm_data           [ 128 +: 128] = rxfifo_downstream_data [ 151 +: 128] ;
  assign dstrm_dvalid         [   1 +:   1] = rxfifo_downstream_data [ 279 +:   1] ;
  assign dstrm_crc            [   8 +:   8] = rxfifo_downstream_data [ 280 +:   8] ;
  assign dstrm_crc_valid      [   1 +:   1] = rxfifo_downstream_data [ 288 +:   1] ;
  assign dstrm_valid          [   1 +:   1] = rxfifo_downstream_data [ 289 +:   1] ;
  assign dstrm_state          [   8 +:   4] = rxfifo_downstream_data [ 290 +:   4] ;
  assign dstrm_protid         [   4 +:   2] = rxfifo_downstream_data [ 294 +:   2] ;
  assign dstrm_data           [ 256 +: 128] = rxfifo_downstream_data [ 296 +: 128] ;
  assign dstrm_dvalid         [   2 +:   1] = rxfifo_downstream_data [ 424 +:   1] ;
  assign dstrm_crc            [  16 +:   8] = rxfifo_downstream_data [ 425 +:   8] ;
  assign dstrm_crc_valid      [   2 +:   1] = rxfifo_downstream_data [ 433 +:   1] ;
  assign dstrm_valid          [   2 +:   1] = rxfifo_downstream_data [ 434 +:   1] ;
  assign dstrm_state          [  12 +:   4] = rxfifo_downstream_data [ 435 +:   4] ;
  assign dstrm_protid         [   6 +:   2] = rxfifo_downstream_data [ 439 +:   2] ;
  assign dstrm_data           [ 384 +: 128] = rxfifo_downstream_data [ 441 +: 128] ;
  assign dstrm_dvalid         [   3 +:   1] = rxfifo_downstream_data [ 569 +:   1] ;
  assign dstrm_crc            [  24 +:   8] = rxfifo_downstream_data [ 570 +:   8] ;
  assign dstrm_crc_valid      [   3 +:   1] = rxfifo_downstream_data [ 578 +:   1] ;
  assign dstrm_valid          [   3 +:   1] = rxfifo_downstream_data [ 579 +:   1] ;

  assign user_upstream_vld                  = 1'b1                               ; // user_upstream_vld is unused
  assign txfifo_upstream_data [   0 +:   4] = ustrm_state          [   0 +:   4] ;
  assign txfifo_upstream_data [   4 +:   2] = ustrm_protid         [   0 +:   2] ;
  assign txfifo_upstream_data [   6 +: 128] = ustrm_data           [   0 +: 128] ;
  assign txfifo_upstream_data [ 134 +:   1] = ustrm_dvalid         [   0 +:   1] ;
  assign txfifo_upstream_data [ 135 +:   8] = ustrm_crc            [   0 +:   8] ;
  assign txfifo_upstream_data [ 143 +:   1] = ustrm_crc_valid      [   0 +:   1] ;
  assign txfifo_upstream_data [ 144 +:   1] = ustrm_valid          [   0 +:   1] ;
  assign txfifo_upstream_data [ 145 +:   4] = ustrm_state          [   4 +:   4] ;
  assign txfifo_upstream_data [ 149 +:   2] = ustrm_protid         [   2 +:   2] ;
  assign txfifo_upstream_data [ 151 +: 128] = ustrm_data           [ 128 +: 128] ;
  assign txfifo_upstream_data [ 279 +:   1] = ustrm_dvalid         [   1 +:   1] ;
  assign txfifo_upstream_data [ 280 +:   8] = ustrm_crc            [   8 +:   8] ;
  assign txfifo_upstream_data [ 288 +:   1] = ustrm_crc_valid      [   1 +:   1] ;
  assign txfifo_upstream_data [ 289 +:   1] = ustrm_valid          [   1 +:   1] ;
  assign txfifo_upstream_data [ 290 +:   4] = ustrm_state          [   8 +:   4] ;
  assign txfifo_upstream_data [ 294 +:   2] = ustrm_protid         [   4 +:   2] ;
  assign txfifo_upstream_data [ 296 +: 128] = ustrm_data           [ 256 +: 128] ;
  assign txfifo_upstream_data [ 424 +:   1] = ustrm_dvalid         [   2 +:   1] ;
  assign txfifo_upstream_data [ 425 +:   8] = ustrm_crc            [  16 +:   8] ;
  assign txfifo_upstream_data [ 433 +:   1] = ustrm_crc_valid      [   2 +:   1] ;
  assign txfifo_upstream_data [ 434 +:   1] = ustrm_valid          [   2 +:   1] ;
  assign txfifo_upstream_data [ 435 +:   4] = ustrm_state          [  12 +:   4] ;
  assign txfifo_upstream_data [ 439 +:   2] = ustrm_protid         [   6 +:   2] ;
  assign txfifo_upstream_data [ 441 +: 128] = ustrm_data           [ 384 +: 128] ;
  assign txfifo_upstream_data [ 569 +:   1] = ustrm_dvalid         [   3 +:   1] ;
  assign txfifo_upstream_data [ 570 +:   8] = ustrm_crc            [  24 +:   8] ;
  assign txfifo_upstream_data [ 578 +:   1] = ustrm_crc_valid      [   3 +:   1] ;
  assign txfifo_upstream_data [ 579 +:   1] = ustrm_valid          [   3 +:   1] ;

endmodule
