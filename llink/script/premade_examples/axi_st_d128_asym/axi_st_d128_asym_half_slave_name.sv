////////////////////////////////////////////////////////////
//
//        Copyright (C) 2021 Eximius Design
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

module axi_st_d128_asym_half_slave_name  (

  // st channel
  output logic [  31:   0]   user_tkeep          ,
  output logic [ 255:   0]   user_tdata          ,
  output logic [   1:   0]   user_tuser          ,
  output logic               user_tvalid         ,
  input  logic               user_tready         ,
  output logic [   1:   0]   user_enable         ,

  // Logic Link Interfaces
  input  logic               user_st_valid       ,
  input  logic [ 291:   0]   rxfifo_st_data      ,
  output logic               user_st_ready       ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_tvalid                        = user_st_valid                      ;
  assign user_st_ready                      = user_tready                        ;
  assign user_tkeep           [   0 +:  16] = rxfifo_st_data       [   0 +:  16] ;
  assign user_tdata           [   0 +: 128] = rxfifo_st_data       [  16 +: 128] ;
  assign user_tuser           [   0 +:   1] = rxfifo_st_data       [ 144 +:   1] ;
  assign user_enable          [   0 +:   1] = rxfifo_st_data       [ 290 +:   1] ;
  assign user_tkeep           [  16 +:  16] = rxfifo_st_data       [ 145 +:  16] ;
  assign user_tdata           [ 128 +: 128] = rxfifo_st_data       [ 161 +: 128] ;
  assign user_tuser           [   1 +:   1] = rxfifo_st_data       [ 289 +:   1] ;
  assign user_enable          [   1 +:   1] = rxfifo_st_data       [ 291 +:   1] ;

endmodule
