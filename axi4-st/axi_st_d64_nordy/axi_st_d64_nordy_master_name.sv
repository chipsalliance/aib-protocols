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

module axi_st_d64_nordy_master_name  (

  // st channel
  input  logic [   7:   0]   user_tkeep          ,
  input  logic [  63:   0]   user_tdata          ,
  input  logic               user_tlast          ,
  input  logic               user_tvalid         ,

  // Logic Link Interfaces
  output logic [  73:   0]   txfifo_st_data      ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_st_valid                      = 1'b1                               ; // user_st_valid is unused
  // user_st_ready is unused
  assign txfifo_st_data       [   0 +:   8] = user_tkeep           [   0 +:   8] ;
  assign txfifo_st_data       [   8 +:  64] = user_tdata           [   0 +:  64] ;
  assign txfifo_st_data       [  72 +:   1] = user_tlast                         ;
  assign txfifo_st_data       [  73 +:   1] = user_tvalid                        ;

endmodule
