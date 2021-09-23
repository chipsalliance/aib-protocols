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

module axi_mm_a32_d128_slave_name  (

  // ar channel
  output logic [   3:   0]   user_arid           ,
  output logic [   2:   0]   user_arsize         ,
  output logic [   7:   0]   user_arlen          ,
  output logic [   1:   0]   user_arburst        ,
  output logic [  31:   0]   user_araddr         ,
  output logic               user_arvalid        ,
  input  logic               user_arready        ,

  // aw channel
  output logic [   3:   0]   user_awid           ,
  output logic [   2:   0]   user_awsize         ,
  output logic [   7:   0]   user_awlen          ,
  output logic [   1:   0]   user_awburst        ,
  output logic [  31:   0]   user_awaddr         ,
  output logic               user_awvalid        ,
  input  logic               user_awready        ,

  // w channel
  output logic [   3:   0]   user_wid            ,
  output logic [ 127:   0]   user_wdata          ,
  output logic [  15:   0]   user_wstrb          ,
  output logic               user_wlast          ,
  output logic               user_wvalid         ,
  input  logic               user_wready         ,

  // r channel
  input  logic [   3:   0]   user_rid            ,
  input  logic [ 127:   0]   user_rdata          ,
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
  input  logic               user_ar_valid       ,
  input  logic [  48:   0]   rxfifo_ar_data      ,
  output logic               user_ar_ready       ,

  input  logic               user_aw_valid       ,
  input  logic [  48:   0]   rxfifo_aw_data      ,
  output logic               user_aw_ready       ,

  input  logic               user_w_valid        ,
  input  logic [ 148:   0]   rxfifo_w_data       ,
  output logic               user_w_ready        ,

  output logic               user_r_valid        ,
  output logic [ 134:   0]   txfifo_r_data       ,
  input  logic               user_r_ready        ,

  output logic               user_b_valid        ,
  output logic [   5:   0]   txfifo_b_data       ,
  input  logic               user_b_ready        ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_arvalid                       = user_ar_valid                      ;
  assign user_ar_ready                      = user_arready                       ;
  assign user_arid            [   0 +:   4] = rxfifo_ar_data       [   0 +:   4] ;
  assign user_arsize          [   0 +:   3] = rxfifo_ar_data       [   4 +:   3] ;
  assign user_arlen           [   0 +:   8] = rxfifo_ar_data       [   7 +:   8] ;
  assign user_arburst         [   0 +:   2] = rxfifo_ar_data       [  15 +:   2] ;
  assign user_araddr          [   0 +:  32] = rxfifo_ar_data       [  17 +:  32] ;

  assign user_awvalid                       = user_aw_valid                      ;
  assign user_aw_ready                      = user_awready                       ;
  assign user_awid            [   0 +:   4] = rxfifo_aw_data       [   0 +:   4] ;
  assign user_awsize          [   0 +:   3] = rxfifo_aw_data       [   4 +:   3] ;
  assign user_awlen           [   0 +:   8] = rxfifo_aw_data       [   7 +:   8] ;
  assign user_awburst         [   0 +:   2] = rxfifo_aw_data       [  15 +:   2] ;
  assign user_awaddr          [   0 +:  32] = rxfifo_aw_data       [  17 +:  32] ;

  assign user_wvalid                        = user_w_valid                       ;
  assign user_w_ready                       = user_wready                        ;
  assign user_wid             [   0 +:   4] = rxfifo_w_data        [   0 +:   4] ;
  assign user_wdata           [   0 +: 128] = rxfifo_w_data        [   4 +: 128] ;
  assign user_wstrb           [   0 +:  16] = rxfifo_w_data        [ 132 +:  16] ;
  assign user_wlast                         = rxfifo_w_data        [ 148 +:   1] ;

  assign user_r_valid                       = user_rvalid                        ;
  assign user_rready                        = user_r_ready                       ;
  assign txfifo_r_data        [   0 +:   4] = user_rid             [   0 +:   4] ;
  assign txfifo_r_data        [   4 +: 128] = user_rdata           [   0 +: 128] ;
  assign txfifo_r_data        [ 132 +:   1] = user_rlast                         ;
  assign txfifo_r_data        [ 133 +:   2] = user_rresp           [   0 +:   2] ;

  assign user_b_valid                       = user_bvalid                        ;
  assign user_bready                        = user_b_ready                       ;
  assign txfifo_b_data        [   0 +:   4] = user_bid             [   0 +:   4] ;
  assign txfifo_b_data        [   4 +:   2] = user_bresp           [   0 +:   2] ;

endmodule
