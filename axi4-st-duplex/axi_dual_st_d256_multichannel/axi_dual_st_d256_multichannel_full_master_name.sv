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

module axi_dual_st_d256_multichannel_full_master_name  (

  // ST_M2S channel
  input  logic [ 255:   0]   user_m2s_tdata      ,
  input  logic               user_m2s_tvalid     ,
  output logic               user_m2s_tready     ,

  // ST_S2M channel
  output logic [ 255:   0]   user_s2m_tdata      ,
  output logic               user_s2m_tvalid     ,
  input  logic               user_s2m_tready     ,
  output logic [   0:   0]   user_s2m_enable     ,

  // Logic Link Interfaces
  output logic               user_ST_M2S_vld     ,
  output logic [ 256:   0]   txfifo_ST_M2S_data  ,
  input  logic               user_ST_M2S_ready   ,

  input  logic               user_ST_S2M_vld     ,
  input  logic [ 256:   0]   rxfifo_ST_S2M_data  ,
  output logic               user_ST_S2M_ready   ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_ST_M2S_vld                    = user_m2s_tvalid                    ;
  assign user_m2s_tready                    = user_ST_M2S_ready                  ;
  assign txfifo_ST_M2S_data   [   0 +: 256] = user_m2s_tdata       [   0 +: 256] ;

  assign user_s2m_tvalid                    = user_ST_S2M_vld                    ;
  assign user_ST_S2M_ready                  = user_s2m_tready                    ;
  assign user_s2m_tdata       [   0 +: 256] = rxfifo_ST_S2M_data   [   0 +: 256] ;
  assign user_s2m_enable      [   0 +:   1] = rxfifo_ST_S2M_data   [ 256 +:   1] ;

endmodule
