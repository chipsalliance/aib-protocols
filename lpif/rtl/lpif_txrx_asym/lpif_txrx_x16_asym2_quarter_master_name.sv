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

module lpif_txrx_x16_asym2_quarter_master_name  (

  // downstream channel
  input  logic [  15:   0]   dstrm_state         ,
  input  logic [   7:   0]   dstrm_protid        ,
  input  logic [1023:   0]   dstrm_data          ,
  input  logic [   3:   0]   dstrm_dvalid        ,
  input  logic [  63:   0]   dstrm_crc           ,
  input  logic [   3:   0]   dstrm_crc_valid     ,
  input  logic [   3:   0]   dstrm_valid         ,

  // upstream channel
  output logic [  15:   0]   ustrm_state         ,
  output logic [   7:   0]   ustrm_protid        ,
  output logic [1023:   0]   ustrm_data          ,
  output logic [   3:   0]   ustrm_dvalid        ,
  output logic [  63:   0]   ustrm_crc           ,
  output logic [   3:   0]   ustrm_crc_valid     ,
  output logic [   3:   0]   ustrm_valid         ,

  // Logic Link Interfaces
  output logic [1123:   0]   txfifo_downstream_data,

  input  logic [1123:   0]   rxfifo_upstream_data,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_downstream_vld                = 1'b1                               ; // user_downstream_vld is unused
  assign txfifo_downstream_data [   0 +:   4] = dstrm_state          [   0 +:   4] ;
  assign txfifo_downstream_data [   4 +:   2] = dstrm_protid         [   0 +:   2] ;
  assign txfifo_downstream_data [   6 +: 256] = dstrm_data           [   0 +: 256] ;
  assign txfifo_downstream_data [ 262 +:   1] = dstrm_dvalid         [   0 +:   1] ;
  assign txfifo_downstream_data [ 263 +:  16] = dstrm_crc            [   0 +:  16] ;
  assign txfifo_downstream_data [ 279 +:   1] = dstrm_crc_valid      [   0 +:   1] ;
  assign txfifo_downstream_data [ 280 +:   1] = dstrm_valid          [   0 +:   1] ;
  assign txfifo_downstream_data [ 281 +:   4] = dstrm_state          [   4 +:   4] ;
  assign txfifo_downstream_data [ 285 +:   2] = dstrm_protid         [   2 +:   2] ;
  assign txfifo_downstream_data [ 287 +: 256] = dstrm_data           [ 256 +: 256] ;
  assign txfifo_downstream_data [ 543 +:   1] = dstrm_dvalid         [   1 +:   1] ;
  assign txfifo_downstream_data [ 544 +:  16] = dstrm_crc            [  16 +:  16] ;
  assign txfifo_downstream_data [ 560 +:   1] = dstrm_crc_valid      [   1 +:   1] ;
  assign txfifo_downstream_data [ 561 +:   1] = dstrm_valid          [   1 +:   1] ;
  assign txfifo_downstream_data [ 562 +:   4] = dstrm_state          [   8 +:   4] ;
  assign txfifo_downstream_data [ 566 +:   2] = dstrm_protid         [   4 +:   2] ;
  assign txfifo_downstream_data [ 568 +: 256] = dstrm_data           [ 512 +: 256] ;
  assign txfifo_downstream_data [ 824 +:   1] = dstrm_dvalid         [   2 +:   1] ;
  assign txfifo_downstream_data [ 825 +:  16] = dstrm_crc            [  32 +:  16] ;
  assign txfifo_downstream_data [ 841 +:   1] = dstrm_crc_valid      [   2 +:   1] ;
  assign txfifo_downstream_data [ 842 +:   1] = dstrm_valid          [   2 +:   1] ;
  assign txfifo_downstream_data [ 843 +:   4] = dstrm_state          [  12 +:   4] ;
  assign txfifo_downstream_data [ 847 +:   2] = dstrm_protid         [   6 +:   2] ;
  assign txfifo_downstream_data [ 849 +: 256] = dstrm_data           [ 768 +: 256] ;
  assign txfifo_downstream_data [1105 +:   1] = dstrm_dvalid         [   3 +:   1] ;
  assign txfifo_downstream_data [1106 +:  16] = dstrm_crc            [  48 +:  16] ;
  assign txfifo_downstream_data [1122 +:   1] = dstrm_crc_valid      [   3 +:   1] ;
  assign txfifo_downstream_data [1123 +:   1] = dstrm_valid          [   3 +:   1] ;

  // user_upstream_vld is unused
  assign ustrm_state          [   0 +:   4] = rxfifo_upstream_data [   0 +:   4] ;
  assign ustrm_protid         [   0 +:   2] = rxfifo_upstream_data [   4 +:   2] ;
  assign ustrm_data           [   0 +: 256] = rxfifo_upstream_data [   6 +: 256] ;
  assign ustrm_dvalid         [   0 +:   1] = rxfifo_upstream_data [ 262 +:   1] ;
  assign ustrm_crc            [   0 +:  16] = rxfifo_upstream_data [ 263 +:  16] ;
  assign ustrm_crc_valid      [   0 +:   1] = rxfifo_upstream_data [ 279 +:   1] ;
  assign ustrm_valid          [   0 +:   1] = rxfifo_upstream_data [ 280 +:   1] ;
  assign ustrm_state          [   4 +:   4] = rxfifo_upstream_data [ 281 +:   4] ;
  assign ustrm_protid         [   2 +:   2] = rxfifo_upstream_data [ 285 +:   2] ;
  assign ustrm_data           [ 256 +: 256] = rxfifo_upstream_data [ 287 +: 256] ;
  assign ustrm_dvalid         [   1 +:   1] = rxfifo_upstream_data [ 543 +:   1] ;
  assign ustrm_crc            [  16 +:  16] = rxfifo_upstream_data [ 544 +:  16] ;
  assign ustrm_crc_valid      [   1 +:   1] = rxfifo_upstream_data [ 560 +:   1] ;
  assign ustrm_valid          [   1 +:   1] = rxfifo_upstream_data [ 561 +:   1] ;
  assign ustrm_state          [   8 +:   4] = rxfifo_upstream_data [ 562 +:   4] ;
  assign ustrm_protid         [   4 +:   2] = rxfifo_upstream_data [ 566 +:   2] ;
  assign ustrm_data           [ 512 +: 256] = rxfifo_upstream_data [ 568 +: 256] ;
  assign ustrm_dvalid         [   2 +:   1] = rxfifo_upstream_data [ 824 +:   1] ;
  assign ustrm_crc            [  32 +:  16] = rxfifo_upstream_data [ 825 +:  16] ;
  assign ustrm_crc_valid      [   2 +:   1] = rxfifo_upstream_data [ 841 +:   1] ;
  assign ustrm_valid          [   2 +:   1] = rxfifo_upstream_data [ 842 +:   1] ;
  assign ustrm_state          [  12 +:   4] = rxfifo_upstream_data [ 843 +:   4] ;
  assign ustrm_protid         [   6 +:   2] = rxfifo_upstream_data [ 847 +:   2] ;
  assign ustrm_data           [ 768 +: 256] = rxfifo_upstream_data [ 849 +: 256] ;
  assign ustrm_dvalid         [   3 +:   1] = rxfifo_upstream_data [1105 +:   1] ;
  assign ustrm_crc            [  48 +:  16] = rxfifo_upstream_data [1106 +:  16] ;
  assign ustrm_crc_valid      [   3 +:   1] = rxfifo_upstream_data [1122 +:   1] ;
  assign ustrm_valid          [   3 +:   1] = rxfifo_upstream_data [1123 +:   1] ;

endmodule
