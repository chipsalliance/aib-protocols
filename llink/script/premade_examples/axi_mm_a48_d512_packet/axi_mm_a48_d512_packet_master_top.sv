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

module axi_mm_a48_d512_packet_master_top  (
  input  logic               clk_wr              ,
  input  logic               rst_wr_n            ,

  // Control signals
  input  logic               tx_online           ,
  input  logic               rx_online           ,

  input  logic [7:0]         init_ar_credit      ,
  input  logic [7:0]         init_aw_credit      ,
  input  logic [7:0]         init_w_credit       ,

  // PHY Interconnect
  output logic [ 319:   0]   tx_phy0             ,
  input  logic [ 319:   0]   rx_phy0             ,
  output logic [ 319:   0]   tx_phy1             ,
  input  logic [ 319:   0]   rx_phy1             ,

  // ar channel
  input  logic [   3:   0]   user_arid           ,
  input  logic [   2:   0]   user_arsize         ,
  input  logic [   7:   0]   user_arlen          ,
  input  logic [   1:   0]   user_arburst        ,
  input  logic [  47:   0]   user_araddr         ,
  input  logic               user_arvalid        ,
  output logic               user_arready        ,

  // aw channel
  input  logic [   3:   0]   user_awid           ,
  input  logic [   2:   0]   user_awsize         ,
  input  logic [   7:   0]   user_awlen          ,
  input  logic [   1:   0]   user_awburst        ,
  input  logic [  47:   0]   user_awaddr         ,
  input  logic               user_awvalid        ,
  output logic               user_awready        ,

  // w channel
  input  logic [   3:   0]   user_wid            ,
  input  logic [ 511:   0]   user_wdata          ,
  input  logic [  15:   0]   user_wstrb          ,
  input  logic               user_wlast          ,
  input  logic               user_wvalid         ,
  output logic               user_wready         ,

  // r channel
  output logic [   3:   0]   user_rid            ,
  output logic [ 511:   0]   user_rdata          ,
  output logic               user_rlast          ,
  output logic [   1:   0]   user_rresp          ,
  output logic               user_rvalid         ,
  input  logic               user_rready         ,

  // b channel
  output logic [   3:   0]   user_bid            ,
  output logic [   1:   0]   user_bresp          ,
  output logic               user_bvalid         ,
  input  logic               user_bready         ,

  // Debug Status Outputs
  output logic [31:0]        tx_ar_debug_status  ,
  output logic [31:0]        tx_aw_debug_status  ,
  output logic [31:0]        tx_w_debug_status   ,
  output logic [31:0]        rx_r_debug_status   ,
  output logic [31:0]        rx_b_debug_status   ,

  // Configuration
  input  logic               m_gen2_mode         ,


  input  logic [15:0]        delay_x_value       , // In single channel, no CA, this is Word Alignment Time. In multie-channel, this is 0 and RX_ONLINE tied to channel_alignment_done
  input  logic [15:0]        delay_y_value       ,
  input  logic [15:0]        delay_z_value       

);

//////////////////////////////////////////////////////////////////
// Interconnect Wires
  logic                                          tx_ar_pushbit                 ;
  logic                                          user_ar_vld                   ;
  logic [  64:   0]                              tx_ar_data                    ;
  logic [  64:   0]                              txfifo_ar_data                ;
  logic                                          rx_ar_credit                  ;
  logic                                          user_ar_ready                 ;
  logic                                          tx_ar_pop_ovrd                ;

  logic                                          tx_aw_pushbit                 ;
  logic                                          user_aw_vld                   ;
  logic [  64:   0]                              tx_aw_data                    ;
  logic [  64:   0]                              txfifo_aw_data                ;
  logic                                          rx_aw_credit                  ;
  logic                                          user_aw_ready                 ;
  logic                                          tx_aw_pop_ovrd                ;

  logic                                          tx_w_pushbit                  ;
  logic                                          user_w_vld                    ;
  logic [ 532:   0]                              tx_w_data                     ;
  logic [ 532:   0]                              txfifo_w_data                 ;
  logic                                          rx_w_credit                   ;
  logic                                          user_w_ready                  ;
  logic                                          tx_w_pop_ovrd                 ;

  logic                                          rx_r_pushbit                  ;
  logic                                          user_r_vld                    ;
  logic [ 518:   0]                              rx_r_data                     ;
  logic [ 518:   0]                              rxfifo_r_data                 ;
  logic                                          tx_r_credit                   ;
  logic                                          user_r_ready                  ;
  logic                                          rx_r_push_ovrd                ;

  logic                                          rx_b_pushbit                  ;
  logic                                          user_b_vld                    ;
  logic [   5:   0]                              rx_b_data                     ;
  logic [   5:   0]                              rxfifo_b_data                 ;
  logic                                          tx_b_credit                   ;
  logic                                          user_b_ready                  ;
  logic                                          rx_b_push_ovrd                ;

  logic [   3:   0]                              tx_auto_mrk_userbit           ;
  logic                                          tx_auto_stb_userbit           ;
  logic                                          tx_online_delay               ;
  logic                                          rx_online_delay               ;
  logic [   3:   0]                              tx_mrk_userbit                ; // No TX User Marker, so tie off
  logic                                          tx_stb_userbit                ; // No TX User Strobe, so tie off
  assign tx_mrk_userbit                     = '0                                 ;
  assign tx_stb_userbit                     = '1                                 ;

// Interconnect Wires
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Auto Sync

   ll_auto_sync #(.MARKER_WIDTH(4),
                  .PERSISTENT_MARKER(1'b1),
                  .NO_MARKER(1'b1),
                  .PERSISTENT_STROBE(1'b1)) ll_auto_sync_i
     (// Outputs
      .tx_online_delay                  (tx_online_delay),
      .tx_auto_mrk_userbit              (tx_auto_mrk_userbit),
      .tx_auto_stb_userbit              (tx_auto_stb_userbit),
      .rx_online_delay                  (rx_online_delay),
      // Inputs
      .clk_wr                           (clk_wr),
      .rst_wr_n                         (rst_wr_n),
      .tx_online                        (tx_online),
      .delay_z_value                    (delay_z_value[15:0]),
      .delay_y_value                    (delay_y_value[15:0]),
      .tx_mrk_userbit                   (tx_mrk_userbit),
      .tx_stb_userbit                   (tx_stb_userbit),
      .rx_online                        (rx_online),
      .delay_x_value                    (delay_x_value[15:0]));

// Auto Sync
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Logic Link Instantiation

      ll_transmit #(.WIDTH(65), .DEPTH(8'd1), .TX_CRED_SIZE(3'h1), .ASYMMETRIC_CREDIT(1'b0), .DEFAULT_TX_CRED(8'd8)) ll_transmit_iar
        (// Outputs
         .user_i_ready                     (user_ar_ready),
         .tx_i_data                        (tx_ar_data[64:0]),
         .tx_i_pushbit                     (tx_ar_pushbit),
         .tx_i_debug_status                (tx_ar_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .end_of_txcred_coal               (1'b1),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_ar_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ar_pop_ovrd),
         .txfifo_i_data                    (txfifo_ar_data[64:0]),
         .user_i_valid                     (user_ar_vld),
         .rx_i_credit                      ({3'b0,rx_ar_credit}));

      ll_transmit #(.WIDTH(65), .DEPTH(8'd1), .TX_CRED_SIZE(3'h1), .ASYMMETRIC_CREDIT(1'b0), .DEFAULT_TX_CRED(8'd8)) ll_transmit_iaw
        (// Outputs
         .user_i_ready                     (user_aw_ready),
         .tx_i_data                        (tx_aw_data[64:0]),
         .tx_i_pushbit                     (tx_aw_pushbit),
         .tx_i_debug_status                (tx_aw_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .end_of_txcred_coal               (1'b1),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_aw_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_aw_pop_ovrd),
         .txfifo_i_data                    (txfifo_aw_data[64:0]),
         .user_i_valid                     (user_aw_vld),
         .rx_i_credit                      ({3'b0,rx_aw_credit}));

      ll_transmit #(.WIDTH(533), .DEPTH(8'd1), .TX_CRED_SIZE(3'h1), .ASYMMETRIC_CREDIT(1'b0), .DEFAULT_TX_CRED(8'd64)) ll_transmit_iw
        (// Outputs
         .user_i_ready                     (user_w_ready),
         .tx_i_data                        (tx_w_data[532:0]),
         .tx_i_pushbit                     (tx_w_pushbit),
         .tx_i_debug_status                (tx_w_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .end_of_txcred_coal               (1'b1),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_w_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_w_pop_ovrd),
         .txfifo_i_data                    (txfifo_w_data[532:0]),
         .user_i_valid                     (user_w_vld),
         .rx_i_credit                      ({3'b0,rx_w_credit}));

      ll_receive #(.WIDTH(519), .DEPTH(8'd64)) ll_receive_ir
        (// Outputs
         .rxfifo_i_data                    (rxfifo_r_data[518:0]),
         .user_i_valid                     (user_r_vld),
         .tx_i_credit                      (tx_r_credit),
         .rx_i_debug_status                (rx_r_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .tx_online                        (tx_online_delay),
         .rx_i_push_ovrd                   (rx_r_push_ovrd),
         .rx_i_data                        (rx_r_data[518:0]),
         .rx_i_pushbit                     (rx_r_pushbit),
         .user_i_ready                     (user_r_ready));

      ll_receive #(.WIDTH(6), .DEPTH(8'd8)) ll_receive_ib
        (// Outputs
         .rxfifo_i_data                    (rxfifo_b_data[5:0]),
         .user_i_valid                     (user_b_vld),
         .tx_i_credit                      (tx_b_credit),
         .rx_i_debug_status                (rx_b_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .tx_online                        (tx_online_delay),
         .rx_i_push_ovrd                   (rx_b_push_ovrd),
         .rx_i_data                        (rx_b_data[5:0]),
         .rx_i_pushbit                     (rx_b_pushbit),
         .user_i_ready                     (user_b_ready));

// Logic Link Instantiation
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// User Interface

      axi_mm_a48_d512_packet_master_name axi_mm_a48_d512_packet_master_name
      (
         .user_arid                        (user_arid[   3:   0]),
         .user_arsize                      (user_arsize[   2:   0]),
         .user_arlen                       (user_arlen[   7:   0]),
         .user_arburst                     (user_arburst[   1:   0]),
         .user_araddr                      (user_araddr[  47:   0]),
         .user_arvalid                     (user_arvalid),
         .user_arready                     (user_arready),
         .user_awid                        (user_awid[   3:   0]),
         .user_awsize                      (user_awsize[   2:   0]),
         .user_awlen                       (user_awlen[   7:   0]),
         .user_awburst                     (user_awburst[   1:   0]),
         .user_awaddr                      (user_awaddr[  47:   0]),
         .user_awvalid                     (user_awvalid),
         .user_awready                     (user_awready),
         .user_wid                         (user_wid[   3:   0]),
         .user_wdata                       (user_wdata[ 511:   0]),
         .user_wstrb                       (user_wstrb[  15:   0]),
         .user_wlast                       (user_wlast),
         .user_wvalid                      (user_wvalid),
         .user_wready                      (user_wready),
         .user_rid                         (user_rid[   3:   0]),
         .user_rdata                       (user_rdata[ 511:   0]),
         .user_rlast                       (user_rlast),
         .user_rresp                       (user_rresp[   1:   0]),
         .user_rvalid                      (user_rvalid),
         .user_rready                      (user_rready),
         .user_bid                         (user_bid[   3:   0]),
         .user_bresp                       (user_bresp[   1:   0]),
         .user_bvalid                      (user_bvalid),
         .user_bready                      (user_bready),

         .user_ar_vld                      (user_ar_vld),
         .txfifo_ar_data                   (txfifo_ar_data[  64:   0]),
         .user_ar_ready                    (user_ar_ready),
         .user_aw_vld                      (user_aw_vld),
         .txfifo_aw_data                   (txfifo_aw_data[  64:   0]),
         .user_aw_ready                    (user_aw_ready),
         .user_w_vld                       (user_w_vld),
         .txfifo_w_data                    (txfifo_w_data[ 532:   0]),
         .user_w_ready                     (user_w_ready),
         .user_r_vld                       (user_r_vld),
         .rxfifo_r_data                    (rxfifo_r_data[ 518:   0]),
         .user_r_ready                     (user_r_ready),
         .user_b_vld                       (user_b_vld),
         .rxfifo_b_data                    (rxfifo_b_data[   5:   0]),
         .user_b_ready                     (user_b_ready),

         .m_gen2_mode                      (m_gen2_mode)

      );
// User Interface                                                 
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// PHY Interface

      axi_mm_a48_d512_packet_master_concat axi_mm_a48_d512_packet_master_concat
      (
         .tx_ar_data                       (tx_ar_data[   0 +:  65]),
         .tx_ar_pop_ovrd                   (tx_ar_pop_ovrd),
         .tx_ar_pushbit                    (tx_ar_pushbit),
         .rx_ar_credit                     (rx_ar_credit),
         .tx_aw_data                       (tx_aw_data[   0 +:  65]),
         .tx_aw_pop_ovrd                   (tx_aw_pop_ovrd),
         .tx_aw_pushbit                    (tx_aw_pushbit),
         .rx_aw_credit                     (rx_aw_credit),
         .tx_w_data                        (tx_w_data[   0 +: 533]),
         .tx_w_pop_ovrd                    (tx_w_pop_ovrd),
         .tx_w_pushbit                     (tx_w_pushbit),
         .rx_w_credit                      (rx_w_credit),
         .rx_r_data                        (rx_r_data[   0 +: 519]),
         .rx_r_push_ovrd                   (rx_r_push_ovrd),
         .rx_r_pushbit                     (rx_r_pushbit),
         .tx_r_credit                      (tx_r_credit),
         .rx_b_data                        (rx_b_data[   0 +:   6]),
         .rx_b_push_ovrd                   (rx_b_push_ovrd),
         .rx_b_pushbit                     (rx_b_pushbit),
         .tx_b_credit                      (tx_b_credit),

         .tx_phy0                          (tx_phy0[319:0]),
         .rx_phy0                          (rx_phy0[319:0]),
         .tx_phy1                          (tx_phy1[319:0]),
         .rx_phy1                          (rx_phy1[319:0]),

         .clk_wr                           (clk_wr),
         .clk_rd                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rst_rd_n                         (rst_wr_n),

         .m_gen2_mode                      (m_gen2_mode),
         .tx_online                        (tx_online_delay),

         .tx_stb_userbit                   (tx_auto_stb_userbit),
         .tx_mrk_userbit                   (tx_auto_mrk_userbit)

      );

// PHY Interface
//////////////////////////////////////////////////////////////////


endmodule
