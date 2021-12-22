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

module axi_fourchan_tier1_a32_d32_packet_slave_name  (

  // ar channel
  output logic [   3:   0]   user_arid           ,
  output logic [   1:   0]   user_arsize         ,
  output logic [   7:   0]   user_arlen          ,
  output logic [   1:   0]   user_arburst        ,
  output logic [  47:   0]   user_araddr         ,
  output logic               user_arvalid        ,
  input  logic               user_arready        ,

  // aw channel
  output logic [   3:   0]   user_awid           ,
  output logic [   1:   0]   user_awsize         ,
  output logic [   7:   0]   user_awlen          ,
  output logic [   1:   0]   user_awburst        ,
  output logic [  47:   0]   user_awaddr         ,
  output logic               user_awvalid        ,
  input  logic               user_awready        ,

  // w channel
  output logic [   3:   0]   user_wid            ,
  output logic [  63:   0]   user_wdata          ,
  output logic               user_wlast          ,
  output logic               user_wvalid         ,
  input  logic               user_wready         ,

  // r channel
  input  logic [   3:   0]   user_rid            ,
  input  logic [  63:   0]   user_rdata          ,
  input  logic               user_rlast          ,
  input  logic [   1:   0]   user_rresp          ,
  input  logic               user_rvalid         ,
  output logic               user_rready         ,

  // b channel
  input  logic [   3:   0]   user_bid            ,
  input  logic [   1:   0]   user_bresp          ,
  input  logic               user_bvalid         ,
  output logic               user_bready         ,

  // Logic Link Interfaces
  input  logic               user_ar_vld         ,
  input  logic [  63:   0]   rxfifo_ar_data      ,
  output logic               user_ar_ready       ,

  input  logic               user_aw_vld         ,
  input  logic [  63:   0]   rxfifo_aw_data      ,
  output logic               user_aw_ready       ,

  input  logic               user_w_vld          ,
  input  logic [  68:   0]   rxfifo_w_data       ,
  output logic               user_w_ready        ,

  output logic               user_r_vld          ,
  output logic [  70:   0]   txfifo_r_data       ,
  input  logic               user_r_ready        ,

  output logic               user_b_vld          ,
  output logic [   5:   0]   txfifo_b_data       ,
  input  logic               user_b_ready        ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_arvalid                       = user_ar_vld                        ;
  assign user_ar_ready                      = user_arready                       ;
  assign user_arid            [   0 +:   4] = rxfifo_ar_data       [   0 +:   4] ;
  assign user_arsize          [   0 +:   2] = rxfifo_ar_data       [   4 +:   2] ;
  assign user_arlen           [   0 +:   8] = rxfifo_ar_data       [   6 +:   8] ;
  assign user_arburst         [   0 +:   2] = rxfifo_ar_data       [  14 +:   2] ;
  assign user_araddr          [   0 +:  48] = rxfifo_ar_data       [  16 +:  48] ;

  assign user_awvalid                       = user_aw_vld                        ;
  assign user_aw_ready                      = user_awready                       ;
  assign user_awid            [   0 +:   4] = rxfifo_aw_data       [   0 +:   4] ;
  assign user_awsize          [   0 +:   2] = rxfifo_aw_data       [   4 +:   2] ;
  assign user_awlen           [   0 +:   8] = rxfifo_aw_data       [   6 +:   8] ;
  assign user_awburst         [   0 +:   2] = rxfifo_aw_data       [  14 +:   2] ;
  assign user_awaddr          [   0 +:  48] = rxfifo_aw_data       [  16 +:  48] ;

  assign user_wvalid                        = user_w_vld                         ;
  assign user_w_ready                       = user_wready                        ;
  assign user_wid             [   0 +:   4] = rxfifo_w_data        [   0 +:   4] ;
  assign user_wdata           [   0 +:  64] = rxfifo_w_data        [   4 +:  64] ;
  assign user_wlast                         = rxfifo_w_data        [  68 +:   1] ;

  assign user_r_vld                         = user_rvalid                        ;
  assign user_rready                        = user_r_ready                       ;
  assign txfifo_r_data        [   0 +:   4] = user_rid             [   0 +:   4] ;
  assign txfifo_r_data        [   4 +:  64] = user_rdata           [   0 +:  64] ;
  assign txfifo_r_data        [  68 +:   1] = user_rlast                         ;
  assign txfifo_r_data        [  69 +:   2] = user_rresp           [   0 +:   2] ;

  assign user_b_vld                         = user_bvalid                        ;
  assign user_bready                        = user_b_ready                       ;
  assign txfifo_b_data        [   0 +:   4] = user_bid             [   0 +:   4] ;
  assign txfifo_b_data        [   4 +:   2] = user_bresp           [   0 +:   2] ;

endmodule
