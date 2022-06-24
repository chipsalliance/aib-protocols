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

module axi_dual_st_d256_multichannel_full_slave_name  (

  // ST_M2S channel
  output logic [ 255:   0]   user_m2s_tdata      ,
  output logic               user_m2s_tvalid     ,
  input  logic               user_m2s_tready     ,
  output logic [   0:   0]   user_m2s_enable     ,

  // ST_S2M channel
  input  logic [ 255:   0]   user_s2m_tdata      ,
  input  logic               user_s2m_tvalid     ,
  output logic               user_s2m_tready     ,

  // Logic Link Interfaces
  input  logic               user_ST_M2S_vld     ,
  input  logic [ 256:   0]   rxfifo_ST_M2S_data  ,
  output logic               user_ST_M2S_ready   ,

  output logic               user_ST_S2M_vld     ,
  output logic [ 256:   0]   txfifo_ST_S2M_data  ,
  input  logic               user_ST_S2M_ready   ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_m2s_tvalid                    = user_ST_M2S_vld                    ;
  assign user_ST_M2S_ready                  = user_m2s_tready                    ;
  assign user_m2s_tdata       [   0 +: 256] = rxfifo_ST_M2S_data   [   0 +: 256] ;
  assign user_m2s_enable      [   0 +:   1] = rxfifo_ST_M2S_data   [ 256 +:   1] ;

  assign user_ST_S2M_vld                    = user_s2m_tvalid                    ;
  assign user_s2m_tready                    = user_ST_S2M_ready                  ;
  assign txfifo_ST_S2M_data   [   0 +: 256] = user_s2m_tdata       [   0 +: 256] ;

endmodule
