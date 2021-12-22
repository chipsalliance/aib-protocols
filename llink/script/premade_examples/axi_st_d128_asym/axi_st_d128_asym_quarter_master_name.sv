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

module axi_st_d128_asym_quarter_master_name  (

  // st channel
  input  logic [  63:   0]   user_tkeep          ,
  input  logic [ 511:   0]   user_tdata          ,
  input  logic [   3:   0]   user_tuser          ,
  input  logic               user_tvalid         ,
  output logic               user_tready         ,

  // Logic Link Interfaces
  output logic               user_st_vld         ,
  output logic [ 579:   0]   txfifo_st_data      ,
  input  logic               user_st_ready       ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_st_vld                        = user_tvalid                        ;
  assign user_tready                        = user_st_ready                      ;
  assign txfifo_st_data       [   0 +:  16] = user_tkeep           [   0 +:  16] ;
  assign txfifo_st_data       [  16 +: 128] = user_tdata           [   0 +: 128] ;
  assign txfifo_st_data       [ 144 +:   1] = user_tuser           [   0 +:   1] ;
  assign txfifo_st_data       [ 145 +:  16] = user_tkeep           [  16 +:  16] ;
  assign txfifo_st_data       [ 161 +: 128] = user_tdata           [ 128 +: 128] ;
  assign txfifo_st_data       [ 289 +:   1] = user_tuser           [   1 +:   1] ;
  assign txfifo_st_data       [ 290 +:  16] = user_tkeep           [  32 +:  16] ;
  assign txfifo_st_data       [ 306 +: 128] = user_tdata           [ 256 +: 128] ;
  assign txfifo_st_data       [ 434 +:   1] = user_tuser           [   2 +:   1] ;
  assign txfifo_st_data       [ 435 +:  16] = user_tkeep           [  48 +:  16] ;
  assign txfifo_st_data       [ 451 +: 128] = user_tdata           [ 384 +: 128] ;
  assign txfifo_st_data       [ 579 +:   1] = user_tuser           [   3 +:   1] ;

endmodule
