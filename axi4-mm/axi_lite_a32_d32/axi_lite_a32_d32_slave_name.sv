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

module axi_lite_a32_d32_slave_name  (

  // ar_lite channel
  output logic [  31:   0]   user_araddr         ,
  output logic               user_arvalid        ,
  input  logic               user_arready        ,

  // aw_lite channel
  output logic [  31:   0]   user_awaddr         ,
  output logic               user_awvalid        ,
  input  logic               user_awready        ,

  // w_lite channel
  output logic [  31:   0]   user_wdata          ,
  output logic [   3:   0]   user_wstrb          ,
  output logic               user_wvalid         ,
  input  logic               user_wready         ,

  // r_lite channel
  input  logic [  31:   0]   user_rdata          ,
  input  logic [   1:   0]   user_rresp          ,
  input  logic               user_rvalid         ,
  output logic               user_rready         ,

  // b_lite channel
  input  logic [   1:   0]   user_bresp          ,
  input  logic               user_bvalid         ,
  output logic               user_bready         ,

  // Logic Link Interfaces
  input  logic               user_ar_lite_vld    ,
  input  logic [  31:   0]   rxfifo_ar_lite_data ,
  output logic               user_ar_lite_ready  ,

  input  logic               user_aw_lite_vld    ,
  input  logic [  31:   0]   rxfifo_aw_lite_data ,
  output logic               user_aw_lite_ready  ,

  input  logic               user_w_lite_vld     ,
  input  logic [  35:   0]   rxfifo_w_lite_data  ,
  output logic               user_w_lite_ready   ,

  output logic               user_r_lite_vld     ,
  output logic [  33:   0]   txfifo_r_lite_data  ,
  input  logic               user_r_lite_ready   ,

  output logic               user_b_lite_vld     ,
  output logic [   1:   0]   txfifo_b_lite_data  ,
  input  logic               user_b_lite_ready   ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_arvalid                       = user_ar_lite_vld                   ;
  assign user_ar_lite_ready                 = user_arready                       ;
  assign user_araddr          [   0 +:  32] = rxfifo_ar_lite_data  [   0 +:  32] ;

  assign user_awvalid                       = user_aw_lite_vld                   ;
  assign user_aw_lite_ready                 = user_awready                       ;
  assign user_awaddr          [   0 +:  32] = rxfifo_aw_lite_data  [   0 +:  32] ;

  assign user_wvalid                        = user_w_lite_vld                    ;
  assign user_w_lite_ready                  = user_wready                        ;
  assign user_wdata           [   0 +:  32] = rxfifo_w_lite_data   [   0 +:  32] ;
  assign user_wstrb           [   0 +:   4] = rxfifo_w_lite_data   [  32 +:   4] ;

  assign user_r_lite_vld                    = user_rvalid                        ;
  assign user_rready                        = user_r_lite_ready                  ;
  assign txfifo_r_lite_data   [   0 +:  32] = user_rdata           [   0 +:  32] ;
  assign txfifo_r_lite_data   [  32 +:   2] = user_rresp           [   0 +:   2] ;

  assign user_b_lite_vld                    = user_bvalid                        ;
  assign user_bready                        = user_b_lite_ready                  ;
  assign txfifo_b_lite_data   [   0 +:   2] = user_bresp           [   0 +:   2] ;

endmodule
