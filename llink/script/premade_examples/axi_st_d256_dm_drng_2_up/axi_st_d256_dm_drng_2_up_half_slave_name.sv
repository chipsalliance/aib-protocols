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

module axi_st_d256_dm_drng_2_up_half_slave_name  (

  // st channel
  output logic [ 511:   0]   user_tdata          ,
  output logic               user_tvalid         ,
  input  logic               user_tready         ,
  output logic [   1:   0]   user_enable         ,

  // Logic Link Interfaces
  input  logic               user_st_valid       ,
  input  logic [ 513:   0]   rxfifo_st_data      ,
  output logic               user_st_ready       ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_tvalid                        = user_st_valid                      ;
  assign user_st_ready                      = user_tready                        ;
  assign user_tdata           [   0 +: 256] = rxfifo_st_data       [   0 +: 256] ;
  assign user_enable          [   0 +:   1] = rxfifo_st_data       [ 512 +:   1] ;
  assign user_tdata           [ 256 +: 256] = rxfifo_st_data       [ 256 +: 256] ;
  assign user_enable          [   1 +:   1] = rxfifo_st_data       [ 513 +:   1] ;

endmodule
