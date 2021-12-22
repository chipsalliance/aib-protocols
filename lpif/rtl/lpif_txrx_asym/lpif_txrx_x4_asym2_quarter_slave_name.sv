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

module lpif_txrx_x4_asym2_quarter_slave_name  (

  // downstream channel
  output logic [  15:   0]   dstrm_state         ,
  output logic [   7:   0]   dstrm_protid        ,
  output logic [ 255:   0]   dstrm_data          ,
  output logic [   3:   0]   dstrm_dvalid        ,
  output logic [  15:   0]   dstrm_crc           ,
  output logic [   3:   0]   dstrm_crc_valid     ,
  output logic [   3:   0]   dstrm_valid         ,

  // upstream channel
  input  logic [  15:   0]   ustrm_state         ,
  input  logic [   7:   0]   ustrm_protid        ,
  input  logic [ 255:   0]   ustrm_data          ,
  input  logic [   3:   0]   ustrm_dvalid        ,
  input  logic [  15:   0]   ustrm_crc           ,
  input  logic [   3:   0]   ustrm_crc_valid     ,
  input  logic [   3:   0]   ustrm_valid         ,

  // Logic Link Interfaces
  input  logic [ 307:   0]   rxfifo_downstream_data,

  output logic [ 307:   0]   txfifo_upstream_data,

  input  logic               m_gen2_mode         

);

  // Connect Data

  // user_downstream_vld is unused
  assign dstrm_state          [   0 +:   4] = rxfifo_downstream_data [   0 +:   4] ;
  assign dstrm_protid         [   0 +:   2] = rxfifo_downstream_data [   4 +:   2] ;
  assign dstrm_data           [   0 +:  64] = rxfifo_downstream_data [   6 +:  64] ;
  assign dstrm_dvalid         [   0 +:   1] = rxfifo_downstream_data [  70 +:   1] ;
  assign dstrm_crc            [   0 +:   4] = rxfifo_downstream_data [  71 +:   4] ;
  assign dstrm_crc_valid      [   0 +:   1] = rxfifo_downstream_data [  75 +:   1] ;
  assign dstrm_valid          [   0 +:   1] = rxfifo_downstream_data [  76 +:   1] ;
  assign dstrm_state          [   4 +:   4] = rxfifo_downstream_data [  77 +:   4] ;
  assign dstrm_protid         [   2 +:   2] = rxfifo_downstream_data [  81 +:   2] ;
  assign dstrm_data           [  64 +:  64] = rxfifo_downstream_data [  83 +:  64] ;
  assign dstrm_dvalid         [   1 +:   1] = rxfifo_downstream_data [ 147 +:   1] ;
  assign dstrm_crc            [   4 +:   4] = rxfifo_downstream_data [ 148 +:   4] ;
  assign dstrm_crc_valid      [   1 +:   1] = rxfifo_downstream_data [ 152 +:   1] ;
  assign dstrm_valid          [   1 +:   1] = rxfifo_downstream_data [ 153 +:   1] ;
  assign dstrm_state          [   8 +:   4] = rxfifo_downstream_data [ 154 +:   4] ;
  assign dstrm_protid         [   4 +:   2] = rxfifo_downstream_data [ 158 +:   2] ;
  assign dstrm_data           [ 128 +:  64] = rxfifo_downstream_data [ 160 +:  64] ;
  assign dstrm_dvalid         [   2 +:   1] = rxfifo_downstream_data [ 224 +:   1] ;
  assign dstrm_crc            [   8 +:   4] = rxfifo_downstream_data [ 225 +:   4] ;
  assign dstrm_crc_valid      [   2 +:   1] = rxfifo_downstream_data [ 229 +:   1] ;
  assign dstrm_valid          [   2 +:   1] = rxfifo_downstream_data [ 230 +:   1] ;
  assign dstrm_state          [  12 +:   4] = rxfifo_downstream_data [ 231 +:   4] ;
  assign dstrm_protid         [   6 +:   2] = rxfifo_downstream_data [ 235 +:   2] ;
  assign dstrm_data           [ 192 +:  64] = rxfifo_downstream_data [ 237 +:  64] ;
  assign dstrm_dvalid         [   3 +:   1] = rxfifo_downstream_data [ 301 +:   1] ;
  assign dstrm_crc            [  12 +:   4] = rxfifo_downstream_data [ 302 +:   4] ;
  assign dstrm_crc_valid      [   3 +:   1] = rxfifo_downstream_data [ 306 +:   1] ;
  assign dstrm_valid          [   3 +:   1] = rxfifo_downstream_data [ 307 +:   1] ;

  assign user_upstream_vld                  = 1'b1                               ; // user_upstream_vld is unused
  assign txfifo_upstream_data [   0 +:   4] = ustrm_state          [   0 +:   4] ;
  assign txfifo_upstream_data [   4 +:   2] = ustrm_protid         [   0 +:   2] ;
  assign txfifo_upstream_data [   6 +:  64] = ustrm_data           [   0 +:  64] ;
  assign txfifo_upstream_data [  70 +:   1] = ustrm_dvalid         [   0 +:   1] ;
  assign txfifo_upstream_data [  71 +:   4] = ustrm_crc            [   0 +:   4] ;
  assign txfifo_upstream_data [  75 +:   1] = ustrm_crc_valid      [   0 +:   1] ;
  assign txfifo_upstream_data [  76 +:   1] = ustrm_valid          [   0 +:   1] ;
  assign txfifo_upstream_data [  77 +:   4] = ustrm_state          [   4 +:   4] ;
  assign txfifo_upstream_data [  81 +:   2] = ustrm_protid         [   2 +:   2] ;
  assign txfifo_upstream_data [  83 +:  64] = ustrm_data           [  64 +:  64] ;
  assign txfifo_upstream_data [ 147 +:   1] = ustrm_dvalid         [   1 +:   1] ;
  assign txfifo_upstream_data [ 148 +:   4] = ustrm_crc            [   4 +:   4] ;
  assign txfifo_upstream_data [ 152 +:   1] = ustrm_crc_valid      [   1 +:   1] ;
  assign txfifo_upstream_data [ 153 +:   1] = ustrm_valid          [   1 +:   1] ;
  assign txfifo_upstream_data [ 154 +:   4] = ustrm_state          [   8 +:   4] ;
  assign txfifo_upstream_data [ 158 +:   2] = ustrm_protid         [   4 +:   2] ;
  assign txfifo_upstream_data [ 160 +:  64] = ustrm_data           [ 128 +:  64] ;
  assign txfifo_upstream_data [ 224 +:   1] = ustrm_dvalid         [   2 +:   1] ;
  assign txfifo_upstream_data [ 225 +:   4] = ustrm_crc            [   8 +:   4] ;
  assign txfifo_upstream_data [ 229 +:   1] = ustrm_crc_valid      [   2 +:   1] ;
  assign txfifo_upstream_data [ 230 +:   1] = ustrm_valid          [   2 +:   1] ;
  assign txfifo_upstream_data [ 231 +:   4] = ustrm_state          [  12 +:   4] ;
  assign txfifo_upstream_data [ 235 +:   2] = ustrm_protid         [   6 +:   2] ;
  assign txfifo_upstream_data [ 237 +:  64] = ustrm_data           [ 192 +:  64] ;
  assign txfifo_upstream_data [ 301 +:   1] = ustrm_dvalid         [   3 +:   1] ;
  assign txfifo_upstream_data [ 302 +:   4] = ustrm_crc            [  12 +:   4] ;
  assign txfifo_upstream_data [ 306 +:   1] = ustrm_crc_valid      [   3 +:   1] ;
  assign txfifo_upstream_data [ 307 +:   1] = ustrm_valid          [   3 +:   1] ;

endmodule
