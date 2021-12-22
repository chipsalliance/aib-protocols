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

module lpif_txrx_x2_asym1_full_master_name  (

  // downstream channel
  input  logic [   3:   0]   dstrm_state         ,
  input  logic [   1:   0]   dstrm_protid        ,
  input  logic [  63:   0]   dstrm_data          ,
  input  logic [   0:   0]   dstrm_dvalid        ,
  input  logic [   1:   0]   dstrm_crc           ,
  input  logic [   0:   0]   dstrm_crc_valid     ,
  input  logic [   0:   0]   dstrm_valid         ,

  // upstream channel
  output logic [   3:   0]   ustrm_state         ,
  output logic [   1:   0]   ustrm_protid        ,
  output logic [  63:   0]   ustrm_data          ,
  output logic [   0:   0]   ustrm_dvalid        ,
  output logic [   1:   0]   ustrm_crc           ,
  output logic [   0:   0]   ustrm_crc_valid     ,
  output logic [   0:   0]   ustrm_valid         ,

  // Logic Link Interfaces
  output logic [  74:   0]   txfifo_downstream_data,

  input  logic [  74:   0]   rxfifo_upstream_data,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_downstream_vld                = 1'b1                               ; // user_downstream_vld is unused
  assign txfifo_downstream_data [   0 +:   4] = dstrm_state          [   0 +:   4] ;
  assign txfifo_downstream_data [   4 +:   2] = dstrm_protid         [   0 +:   2] ;
  assign txfifo_downstream_data [   6 +:  64] = dstrm_data           [   0 +:  64] ;
  assign txfifo_downstream_data [  70 +:   1] = dstrm_dvalid         [   0 +:   1] ;
  assign txfifo_downstream_data [  71 +:   2] = dstrm_crc            [   0 +:   2] ;
  assign txfifo_downstream_data [  73 +:   1] = dstrm_crc_valid      [   0 +:   1] ;
  assign txfifo_downstream_data [  74 +:   1] = dstrm_valid          [   0 +:   1] ;

  // user_upstream_vld is unused
  assign ustrm_state          [   0 +:   4] = rxfifo_upstream_data [   0 +:   4] ;
  assign ustrm_protid         [   0 +:   2] = rxfifo_upstream_data [   4 +:   2] ;
  assign ustrm_data           [   0 +:  64] = rxfifo_upstream_data [   6 +:  64] ;
  assign ustrm_dvalid         [   0 +:   1] = rxfifo_upstream_data [  70 +:   1] ;
  assign ustrm_crc            [   0 +:   2] = rxfifo_upstream_data [  71 +:   2] ;
  assign ustrm_crc_valid      [   0 +:   1] = rxfifo_upstream_data [  73 +:   1] ;
  assign ustrm_valid          [   0 +:   1] = rxfifo_upstream_data [  74 +:   1] ;

endmodule
