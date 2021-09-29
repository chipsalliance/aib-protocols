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

module axi_fourchan_tier2_master_top  (
  input  logic               clk_wr              ,
  input  logic               rst_wr_n            ,

  // Control signals
  input  logic               tx_online           ,
  input  logic               rx_online           ,

  input  logic [7:0]         init_tx_credit      ,

  // PHY Interconnect
  output logic [ 319:   0]   tx_phy0             ,
  input  logic [ 319:   0]   rx_phy0             ,

  // tx channel
  input  logic [  73:   0]   ch0_tx_data         ,
  input  logic [  73:   0]   ch1_tx_data         ,
  input  logic [  73:   0]   ch2_tx_data         ,
  input  logic [  73:   0]   ch3_tx_data         ,

  // rx channel
  output logic [  73:   0]   ch0_rx_data         ,
  output logic [  73:   0]   ch1_rx_data         ,
  output logic [  73:   0]   ch2_rx_data         ,
  output logic [  73:   0]   ch3_rx_data         ,

  // Debug Status Outputs
  output logic [31:0]        tx_tx_debug_status  ,
  output logic [31:0]        rx_rx_debug_status  ,

  // Configuration
  input  logic               m_gen2_mode         ,

  input  logic [   3:   0]   tx_mrk_userbit      ,
  input  logic               tx_stb_userbit      ,

  input  logic [7:0]         delay_x_value       , // In single channel, no CA, this is Word Alignment Time. In multie-channel, this is 0 and RX_ONLINE tied to channel_alignment_done
  input  logic [7:0]         delay_xz_value      ,
  input  logic [7:0]         delay_yz_value      

);

//////////////////////////////////////////////////////////////////
// Interconnect Wires
  logic [ 295:   0]                              tx_tx_data                    ;
  logic [ 295:   0]                              txfifo_tx_data                ;
  logic                                          tx_tx_pop_ovrd                ;

  logic [ 295:   0]                              rx_rx_data                    ;
  logic [ 295:   0]                              rxfifo_rx_data                ;
  logic                                          rx_rx_push_ovrd               ;

  logic [   3:   0]                              tx_auto_mrk_userbit           ;
  logic                                          tx_auto_stb_userbit           ;
  logic                                          tx_online_delay               ;
  logic                                          rx_online_delay               ;

// Interconnect Wires
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Auto Sync

   ll_auto_sync #(.MARKER_WIDTH(4),
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

  // No AXI Valid or Ready, so bypassing main Logic Link FIFO and Credit logic.
  assign tx_tx_data           [   0 +: 296] = txfifo_tx_data       [   0 +: 296] ;
  assign tx_tx_debug_status   [   0 +:  32] = 32'h0                              ;

  // No AXI Valid or Ready, so bypassing main Logic Link FIFO and Credit logic.
  assign rxfifo_rx_data       [   0 +: 296] = rx_rx_data           [   0 +: 296] ;
  assign rx_rx_debug_status   [   0 +:  32] = 32'h0                              ;

// Logic Link Instantiation
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// User Interface

      axi_fourchan_tier2_master_name axi_fourchan_tier2_master_name
      (
         .ch0_tx_data                      (ch0_tx_data[  73:   0]),
         .ch1_tx_data                      (ch1_tx_data[  73:   0]),
         .ch2_tx_data                      (ch2_tx_data[  73:   0]),
         .ch3_tx_data                      (ch3_tx_data[  73:   0]),
         .ch0_rx_data                      (ch0_rx_data[  73:   0]),
         .ch1_rx_data                      (ch1_rx_data[  73:   0]),
         .ch2_rx_data                      (ch2_rx_data[  73:   0]),
         .ch3_rx_data                      (ch3_rx_data[  73:   0]),

         .txfifo_tx_data                   (txfifo_tx_data[ 295:   0]),
         .rxfifo_rx_data                   (rxfifo_rx_data[ 295:   0]),

         .m_gen2_mode                      (m_gen2_mode)

      );
// User Interface                                                 
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// PHY Interface

      axi_fourchan_tier2_master_concat axi_fourchan_tier2_master_concat
      (
         .tx_tx_data                       (tx_tx_data[   0 +: 296]),
         .tx_tx_pop_ovrd                   (tx_tx_pop_ovrd),
         .rx_rx_data                       (rx_rx_data[   0 +: 296]),
         .rx_rx_push_ovrd                  (rx_rx_push_ovrd),

         .tx_phy0                          (tx_phy0[319:0]),
         .rx_phy0                          (rx_phy0[319:0]),

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
