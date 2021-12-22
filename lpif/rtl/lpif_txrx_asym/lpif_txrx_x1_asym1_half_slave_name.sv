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

module lpif_txrx_x1_asym1_half_slave_name  (

  // downstream channel
  output logic [   7:   0]   dstrm_state         ,
  output logic [   3:   0]   dstrm_protid        ,
  output logic [  63:   0]   dstrm_data          ,
  output logic [   1:   0]   dstrm_dvalid        ,
  output logic [   1:   0]   dstrm_crc           ,
  output logic [   1:   0]   dstrm_crc_valid     ,
  output logic [   1:   0]   dstrm_valid         ,

  // upstream channel
  input  logic [   7:   0]   ustrm_state         ,
  input  logic [   3:   0]   ustrm_protid        ,
  input  logic [  63:   0]   ustrm_data          ,
  input  logic [   1:   0]   ustrm_dvalid        ,
  input  logic [   1:   0]   ustrm_crc           ,
  input  logic [   1:   0]   ustrm_crc_valid     ,
  input  logic [   1:   0]   ustrm_valid         ,

  // Logic Link Interfaces
  input  logic [  83:   0]   rxfifo_downstream_data,

  output logic [  83:   0]   txfifo_upstream_data,

  input  logic               m_gen2_mode         

);

  // Connect Data

  // user_downstream_vld is unused
  assign dstrm_state          [   0 +:   4] = rxfifo_downstream_data [   0 +:   4] ;
  assign dstrm_protid         [   0 +:   2] = rxfifo_downstream_data [   4 +:   2] ;
  assign dstrm_data           [   0 +:  32] = rxfifo_downstream_data [   6 +:  32] ;
  assign dstrm_dvalid         [   0 +:   1] = rxfifo_downstream_data [  38 +:   1] ;
  assign dstrm_crc            [   0 +:   1] = rxfifo_downstream_data [  39 +:   1] ;
  assign dstrm_crc_valid      [   0 +:   1] = rxfifo_downstream_data [  40 +:   1] ;
  assign dstrm_valid          [   0 +:   1] = rxfifo_downstream_data [  41 +:   1] ;
  assign dstrm_state          [   4 +:   4] = rxfifo_downstream_data [  42 +:   4] ;
  assign dstrm_protid         [   2 +:   2] = rxfifo_downstream_data [  46 +:   2] ;
  assign dstrm_data           [  32 +:  32] = rxfifo_downstream_data [  48 +:  32] ;
  assign dstrm_dvalid         [   1 +:   1] = rxfifo_downstream_data [  80 +:   1] ;
  assign dstrm_crc            [   1 +:   1] = rxfifo_downstream_data [  81 +:   1] ;
  assign dstrm_crc_valid      [   1 +:   1] = rxfifo_downstream_data [  82 +:   1] ;
  assign dstrm_valid          [   1 +:   1] = rxfifo_downstream_data [  83 +:   1] ;

  assign user_upstream_vld                  = 1'b1                               ; // user_upstream_vld is unused
  assign txfifo_upstream_data [   0 +:   4] = ustrm_state          [   0 +:   4] ;
  assign txfifo_upstream_data [   4 +:   2] = ustrm_protid         [   0 +:   2] ;
  assign txfifo_upstream_data [   6 +:  32] = ustrm_data           [   0 +:  32] ;
  assign txfifo_upstream_data [  38 +:   1] = ustrm_dvalid         [   0 +:   1] ;
  assign txfifo_upstream_data [  39 +:   1] = ustrm_crc            [   0 +:   1] ;
  assign txfifo_upstream_data [  40 +:   1] = ustrm_crc_valid      [   0 +:   1] ;
  assign txfifo_upstream_data [  41 +:   1] = ustrm_valid          [   0 +:   1] ;
  assign txfifo_upstream_data [  42 +:   4] = ustrm_state          [   4 +:   4] ;
  assign txfifo_upstream_data [  46 +:   2] = ustrm_protid         [   2 +:   2] ;
  assign txfifo_upstream_data [  48 +:  32] = ustrm_data           [  32 +:  32] ;
  assign txfifo_upstream_data [  80 +:   1] = ustrm_dvalid         [   1 +:   1] ;
  assign txfifo_upstream_data [  81 +:   1] = ustrm_crc            [   1 +:   1] ;
  assign txfifo_upstream_data [  82 +:   1] = ustrm_crc_valid      [   1 +:   1] ;
  assign txfifo_upstream_data [  83 +:   1] = ustrm_valid          [   1 +:   1] ;

endmodule
