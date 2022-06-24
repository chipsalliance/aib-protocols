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

module axi_dual_st_d64_slave_name  (

  // ST_M2S channel
  output logic [   7:   0]   user_m2s_tkeep      ,
  output logic [  63:   0]   user_m2s_tdata      ,
  output logic               user_m2s_tlast      ,
  output logic               user_m2s_tvalid     ,
  input  logic               user_m2s_tready     ,

  // ST_S2M channel
  input  logic [   7:   0]   user_s2m_tkeep      ,
  input  logic [  63:   0]   user_s2m_tdata      ,
  input  logic               user_s2m_tlast      ,
  input  logic               user_s2m_tvalid     ,
  output logic               user_s2m_tready     ,

  // Logic Link Interfaces
  input  logic               user_ST_M2S_vld     ,
  input  logic [  72:   0]   rxfifo_ST_M2S_data  ,
  output logic               user_ST_M2S_ready   ,

  output logic               user_ST_S2M_vld     ,
  output logic [  72:   0]   txfifo_ST_S2M_data  ,
  input  logic               user_ST_S2M_ready   ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_m2s_tvalid                    = user_ST_M2S_vld                    ;
  assign user_ST_M2S_ready                  = user_m2s_tready                    ;
  assign user_m2s_tkeep       [   0 +:   8] = rxfifo_ST_M2S_data   [   0 +:   8] ;
  assign user_m2s_tdata       [   0 +:  64] = rxfifo_ST_M2S_data   [   8 +:  64] ;
  assign user_m2s_tlast                     = rxfifo_ST_M2S_data   [  72 +:   1] ;

  assign user_ST_S2M_vld                    = user_s2m_tvalid                    ;
  assign user_s2m_tready                    = user_ST_S2M_ready                  ;
  assign txfifo_ST_S2M_data   [   0 +:   8] = user_s2m_tkeep       [   0 +:   8] ;
  assign txfifo_ST_S2M_data   [   8 +:  64] = user_s2m_tdata       [   0 +:  64] ;
  assign txfifo_ST_S2M_data   [  72 +:   1] = user_s2m_tlast                     ;

endmodule
