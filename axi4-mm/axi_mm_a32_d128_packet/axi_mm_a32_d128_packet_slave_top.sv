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

module axi_mm_a32_d128_packet_slave_top  (
  input  logic               clk_wr              ,
  input  logic               rst_wr_n            ,

  // Control signals
  input  logic               tx_online           ,
  input  logic               rx_online           ,

  input  logic [7:0]         init_r_credit       ,
  input  logic [7:0]         init_b_credit       ,

  // PHY Interconnect
  output logic [  79:   0]   tx_phy0             ,
  input  logic [  79:   0]   rx_phy0             ,

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

  // Debug Status Outputs
  output logic [31:0]        rx_ar_debug_status  ,
  output logic [31:0]        rx_aw_debug_status  ,
  output logic [31:0]        rx_w_debug_status   ,
  output logic [31:0]        tx_r_debug_status   ,
  output logic [31:0]        tx_b_debug_status   ,

  // Configuration
  input  logic               m_gen2_mode         ,

  input  logic [   0:   0]   tx_mrk_userbit      ,
  input  logic               tx_stb_userbit      ,

  input  logic [7:0]         delay_x_value       , // In single channel, no CA, this is Word Alignment Time. In multie-channel, this is 0 and RX_ONLINE tied to channel_alignment_done
  input  logic [7:0]         delay_xz_value      ,
  input  logic [7:0]         delay_yz_value      

);

//////////////////////////////////////////////////////////////////
// Interconnect Wires
  logic                                          rx_ar_pushbit                 ;
  logic                                          user_ar_valid                 ;
  logic [  48:   0]                              rx_ar_data                    ;
  logic [  48:   0]                              rxfifo_ar_data                ;
  logic                                          tx_ar_credit                  ;
  logic                                          user_ar_ready                 ;
  logic                                          rx_ar_push_ovrd               ;

  logic                                          rx_aw_pushbit                 ;
  logic                                          user_aw_valid                 ;
  logic [  48:   0]                              rx_aw_data                    ;
  logic [  48:   0]                              rxfifo_aw_data                ;
  logic                                          tx_aw_credit                  ;
  logic                                          user_aw_ready                 ;
  logic                                          rx_aw_push_ovrd               ;

  logic                                          rx_w_pushbit                  ;
  logic                                          user_w_valid                  ;
  logic [ 148:   0]                              rx_w_data                     ;
  logic [ 148:   0]                              rxfifo_w_data                 ;
  logic                                          tx_w_credit                   ;
  logic                                          user_w_ready                  ;
  logic                                          rx_w_push_ovrd                ;

  logic                                          tx_r_pushbit                  ;
  logic                                          user_r_valid                  ;
  logic [ 134:   0]                              tx_r_data                     ;
  logic [ 134:   0]                              txfifo_r_data                 ;
  logic                                          rx_r_credit                   ;
  logic                                          user_r_ready                  ;
  logic                                          tx_r_pop_ovrd                 ;

  logic                                          tx_b_pushbit                  ;
  logic                                          user_b_valid                  ;
  logic [   5:   0]                              tx_b_data                     ;
  logic [   5:   0]                              txfifo_b_data                 ;
  logic                                          rx_b_credit                   ;
  logic                                          user_b_ready                  ;
  logic                                          tx_b_pop_ovrd                 ;

  logic [   0:   0]                              tx_auto_mrk_userbit           ;
  logic                                          tx_auto_stb_userbit           ;
  logic                                          tx_online_delay               ;
  logic                                          rx_online_delay               ;

// Interconnect Wires
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Auto Sync

   ll_auto_sync #(.MARKER_WIDTH(1),
                  .PERSISTENT_MARKER(1'b1),
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
      .delay_xz_value                   (delay_xz_value[7:0]),
      .delay_yz_value                   (delay_yz_value[7:0]),
      .tx_mrk_userbit                   (tx_mrk_userbit),
      .tx_stb_userbit                   (tx_stb_userbit),
      .rx_online                        (rx_online),
      .delay_x_value                    (delay_x_value[7:0]));

// Auto Sync
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Logic Link Instantiation

      ll_receive #(.WIDTH(49), .DEPTH(8'd8)) ll_receive_iar
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ar_data[48:0]),
         .user_i_valid                     (user_ar_valid),
         .tx_i_credit                      (tx_ar_credit),
         .rx_i_debug_status                (rx_ar_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_ar_push_ovrd),
         .rx_i_data                        (rx_ar_data[48:0]),
         .rx_i_pushbit                     (rx_ar_pushbit),
         .user_i_ready                     (user_ar_ready));

      ll_receive #(.WIDTH(49), .DEPTH(8'd8)) ll_receive_iaw
        (// Outputs
         .rxfifo_i_data                    (rxfifo_aw_data[48:0]),
         .user_i_valid                     (user_aw_valid),
         .tx_i_credit                      (tx_aw_credit),
         .rx_i_debug_status                (rx_aw_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_aw_push_ovrd),
         .rx_i_data                        (rx_aw_data[48:0]),
         .rx_i_pushbit                     (rx_aw_pushbit),
         .user_i_ready                     (user_aw_ready));

      ll_receive #(.WIDTH(149), .DEPTH(8'd128)) ll_receive_iw
        (// Outputs
         .rxfifo_i_data                    (rxfifo_w_data[148:0]),
         .user_i_valid                     (user_w_valid),
         .tx_i_credit                      (tx_w_credit),
         .rx_i_debug_status                (rx_w_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_w_push_ovrd),
         .rx_i_data                        (rx_w_data[148:0]),
         .rx_i_pushbit                     (rx_w_pushbit),
         .user_i_ready                     (user_w_ready));

      ll_transmit #(.WIDTH(135), .DEPTH(8'd1), .TX_CRED_SIZE(3'h1), .ASYMMETRIC_CREDIT(1'b0), .DEFAULT_TX_CRED(8'd128)) ll_transmit_ir
        (// Outputs
         .user_i_ready                     (user_r_ready),
         .tx_i_data                        (tx_r_data[134:0]),
         .tx_i_pushbit                     (tx_r_pushbit),
         .tx_i_debug_status                (tx_r_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .end_of_txcred_coal               (1'b1),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_r_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_r_pop_ovrd),
         .txfifo_i_data                    (txfifo_r_data[134:0]),
         .user_i_valid                     (user_r_valid),
         .rx_i_credit                      ({3'b0,rx_r_credit}));

      ll_transmit #(.WIDTH(6), .DEPTH(8'd1), .TX_CRED_SIZE(3'h1), .ASYMMETRIC_CREDIT(1'b0), .DEFAULT_TX_CRED(8'd8)) ll_transmit_ib
        (// Outputs
         .user_i_ready                     (user_b_ready),
         .tx_i_data                        (tx_b_data[5:0]),
         .tx_i_pushbit                     (tx_b_pushbit),
         .tx_i_debug_status                (tx_b_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .end_of_txcred_coal               (1'b1),
         .tx_online                        (tx_online_delay),
         .init_i_credit                    (init_b_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_b_pop_ovrd),
         .txfifo_i_data                    (txfifo_b_data[5:0]),
         .user_i_valid                     (user_b_valid),
         .rx_i_credit                      ({3'b0,rx_b_credit}));

// Logic Link Instantiation
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// User Interface

      axi_mm_a32_d128_packet_slave_name axi_mm_a32_d128_packet_slave_name
      (
         .user_arid                        (user_arid[   3:   0]),
         .user_arsize                      (user_arsize[   2:   0]),
         .user_arlen                       (user_arlen[   7:   0]),
         .user_arburst                     (user_arburst[   1:   0]),
         .user_araddr                      (user_araddr[  31:   0]),
         .user_arvalid                     (user_arvalid),
         .user_arready                     (user_arready),
         .user_awid                        (user_awid[   3:   0]),
         .user_awsize                      (user_awsize[   2:   0]),
         .user_awlen                       (user_awlen[   7:   0]),
         .user_awburst                     (user_awburst[   1:   0]),
         .user_awaddr                      (user_awaddr[  31:   0]),
         .user_awvalid                     (user_awvalid),
         .user_awready                     (user_awready),
         .user_wid                         (user_wid[   3:   0]),
         .user_wdata                       (user_wdata[ 127:   0]),
         .user_wstrb                       (user_wstrb[  15:   0]),
         .user_wlast                       (user_wlast),
         .user_wvalid                      (user_wvalid),
         .user_wready                      (user_wready),
         .user_rid                         (user_rid[   3:   0]),
         .user_rdata                       (user_rdata[ 127:   0]),
         .user_rlast                       (user_rlast),
         .user_rresp                       (user_rresp[   1:   0]),
         .user_rvalid                      (user_rvalid),
         .user_rready                      (user_rready),
         .user_bid                         (user_bid[   3:   0]),
         .user_bresp                       (user_bresp[   1:   0]),
         .user_bvalid                      (user_bvalid),
         .user_bready                      (user_bready),

         .user_ar_valid                    (user_ar_valid),
         .rxfifo_ar_data                   (rxfifo_ar_data[  48:   0]),
         .user_ar_ready                    (user_ar_ready),
         .user_aw_valid                    (user_aw_valid),
         .rxfifo_aw_data                   (rxfifo_aw_data[  48:   0]),
         .user_aw_ready                    (user_aw_ready),
         .user_w_valid                     (user_w_valid),
         .rxfifo_w_data                    (rxfifo_w_data[ 148:   0]),
         .user_w_ready                     (user_w_ready),
         .user_r_valid                     (user_r_valid),
         .txfifo_r_data                    (txfifo_r_data[ 134:   0]),
         .user_r_ready                     (user_r_ready),
         .user_b_valid                     (user_b_valid),
         .txfifo_b_data                    (txfifo_b_data[   5:   0]),
         .user_b_ready                     (user_b_ready),

         .m_gen2_mode                      (m_gen2_mode)

      );
// User Interface                                                 
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// PHY Interface

      axi_mm_a32_d128_packet_slave_concat axi_mm_a32_d128_packet_slave_concat
      (
         .rx_ar_data                       (rx_ar_data[   0 +:  49]),
         .rx_ar_push_ovrd                  (rx_ar_push_ovrd),
         .rx_ar_pushbit                    (rx_ar_pushbit),
         .tx_ar_credit                     (tx_ar_credit),
         .rx_aw_data                       (rx_aw_data[   0 +:  49]),
         .rx_aw_push_ovrd                  (rx_aw_push_ovrd),
         .rx_aw_pushbit                    (rx_aw_pushbit),
         .tx_aw_credit                     (tx_aw_credit),
         .rx_w_data                        (rx_w_data[   0 +: 149]),
         .rx_w_push_ovrd                   (rx_w_push_ovrd),
         .rx_w_pushbit                     (rx_w_pushbit),
         .tx_w_credit                      (tx_w_credit),
         .tx_r_data                        (tx_r_data[   0 +: 135]),
         .tx_r_pop_ovrd                    (tx_r_pop_ovrd),
         .tx_r_pushbit                     (tx_r_pushbit),
         .rx_r_credit                      (rx_r_credit),
         .tx_b_data                        (tx_b_data[   0 +:   6]),
         .tx_b_pop_ovrd                    (tx_b_pop_ovrd),
         .tx_b_pushbit                     (tx_b_pushbit),
         .rx_b_credit                      (rx_b_credit),

         .tx_phy0                          (tx_phy0[79:0]),
         .rx_phy0                          (rx_phy0[79:0]),

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
