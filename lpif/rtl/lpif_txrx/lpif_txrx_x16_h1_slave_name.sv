////////////////////////////////////////////////////////////
// Proprietary Information of Eximius Design
//
//        (C) Copyright 2021 Eximius Design
//                All Rights Reserved
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Eximius Design
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

module lpif_txrx_x16_h1_slave_name  (

  // downstream channel
  output logic [   3:   0]   dstrm_state         ,
  output logic [   1:   0]   dstrm_protid        ,
  output logic [1023:   0]   dstrm_data          ,
  output logic [   6:   0]   dstrm_bstart        ,
  output logic [ 127:   0]   dstrm_bvalid        ,
  output logic [   0:   0]   dstrm_valid         ,

  // upstream channel
  input  logic [   3:   0]   ustrm_state         ,
  input  logic [   1:   0]   ustrm_protid        ,
  input  logic [1023:   0]   ustrm_data          ,
  input  logic [   6:   0]   ustrm_bstart        ,
  input  logic [ 127:   0]   ustrm_bvalid        ,
  input  logic [   0:   0]   ustrm_valid         ,

  // Logic Link Interfaces
  input  logic [1165:   0]   rxfifo_downstream_data,

  output logic [1165:   0]   txfifo_upstream_data,

  input  logic               m_gen2_mode         

);

  // Connect Data

  // user_downstream_valid is unused
  assign user_downstream_ready               = 1'b1                               ; // user_downstream_ready is unused
  assign dstrm_state          [   0 +:   4] = rxfifo_downstream_data [   0 +:   4] ;
  assign dstrm_protid         [   0 +:   2] = rxfifo_downstream_data [   4 +:   2] ;
  assign dstrm_data           [   0 +:1024] = rxfifo_downstream_data [   6 +:1024] ;
  assign dstrm_bstart         [   0 +:   7] = rxfifo_downstream_data [1030 +:   7] ;
  assign dstrm_bvalid         [   0 +: 128] = rxfifo_downstream_data [1037 +: 128] ;
  assign dstrm_valid          [   0 +:   1] = rxfifo_downstream_data [1165 +:   1] ;

  assign user_upstream_valid                = 1'b1                               ; // user_upstream_valid is unused
  // user_upstream_ready is unused
  assign txfifo_upstream_data [   0 +:   4] = ustrm_state          [   0 +:   4] ;
  assign txfifo_upstream_data [   4 +:   2] = ustrm_protid         [   0 +:   2] ;
  assign txfifo_upstream_data [   6 +:1024] = ustrm_data           [   0 +:1024] ;
  assign txfifo_upstream_data [1030 +:   7] = ustrm_bstart         [   0 +:   7] ;
  assign txfifo_upstream_data [1037 +: 128] = ustrm_bvalid         [   0 +: 128] ;
  assign txfifo_upstream_data [1165 +:   1] = ustrm_valid          [   0 +:   1] ;

endmodule
