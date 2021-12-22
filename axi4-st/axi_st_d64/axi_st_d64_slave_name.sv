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

module axi_st_d64_slave_name  (

  // st channel
  output logic [   7:   0]   user_tkeep          ,
  output logic [  63:   0]   user_tdata          ,
  output logic               user_tlast          ,
  output logic               user_tvalid         ,
  input  logic               user_tready         ,

  // Logic Link Interfaces
  input  logic               user_st_vld         ,
  input  logic [  72:   0]   rxfifo_st_data      ,
  output logic               user_st_ready       ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_tvalid                        = user_st_vld                        ;
  assign user_st_ready                      = user_tready                        ;
  assign user_tkeep           [   0 +:   8] = rxfifo_st_data       [   0 +:   8] ;
  assign user_tdata           [   0 +:  64] = rxfifo_st_data       [   8 +:  64] ;
  assign user_tlast                         = rxfifo_st_data       [  72 +:   1] ;

endmodule
