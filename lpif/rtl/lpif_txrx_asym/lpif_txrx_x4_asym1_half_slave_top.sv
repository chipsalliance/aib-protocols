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

module lpif_txrx_x4_asym1_half_slave_top  (
  input  logic               clk_wr              ,
  input  logic               rst_wr_n            ,

  // Control signals
  input  logic               tx_online           ,
  input  logic               rx_online           ,

  input  logic [7:0]         init_upstream_credit,

  // PHY Interconnect
  output logic [  79:   0]   tx_phy0             ,
  input  logic [  79:   0]   rx_phy0             ,
  output logic [  79:   0]   tx_phy1             ,
  input  logic [  79:   0]   rx_phy1             ,
  output logic [  79:   0]   tx_phy2             ,
  input  logic [  79:   0]   rx_phy2             ,
  output logic [  79:   0]   tx_phy3             ,
  input  logic [  79:   0]   rx_phy3             ,

  // downstream channel
  output logic [   7:   0]   dstrm_state         ,
  output logic [   3:   0]   dstrm_protid        ,
  output logic [ 255:   0]   dstrm_data          ,
  output logic [   1:   0]   dstrm_dvalid        ,
  output logic [   7:   0]   dstrm_crc           ,
  output logic [   1:   0]   dstrm_crc_valid     ,
  output logic [   1:   0]   dstrm_valid         ,

  // upstream channel
  input  logic [   7:   0]   ustrm_state         ,
  input  logic [   3:   0]   ustrm_protid        ,
  input  logic [ 255:   0]   ustrm_data          ,
  input  logic [   1:   0]   ustrm_dvalid        ,
  input  logic [   7:   0]   ustrm_crc           ,
  input  logic [   1:   0]   ustrm_crc_valid     ,
  input  logic [   1:   0]   ustrm_valid         ,

  // Debug Status Outputs
  output logic [31:0]        rx_downstream_debug_status,
  output logic [31:0]        tx_upstream_debug_status,

  // Configuration
  input  logic               m_gen2_mode         ,


  input  logic [15:0]        delay_x_value       , // In single channel, no CA, this is Word Alignment Time. In multie-channel, this is 0 and RX_ONLINE tied to channel_alignment_done
  input  logic [15:0]        delay_y_value       ,
  input  logic [15:0]        delay_z_value       

);

//////////////////////////////////////////////////////////////////
// Interconnect Wires
  logic [ 281:   0]                              rx_downstream_data            ;
  logic [ 281:   0]                              rxfifo_downstream_data        ;
  logic                                          rx_downstream_push_ovrd       ;

  logic [ 281:   0]                              tx_upstream_data              ;
  logic [ 281:   0]                              txfifo_upstream_data          ;
  logic                                          tx_upstream_pop_ovrd          ;

  logic [   1:   0]                              tx_auto_mrk_userbit           ;
  logic                                          tx_auto_stb_userbit           ;
  logic                                          tx_online_delay               ;
  logic                                          rx_online_delay               ;
  logic [   1:   0]                              tx_mrk_userbit                ; // No TX User Marker, so tie off
  logic                                          tx_stb_userbit                ; // No TX User Strobe, so tie off
  assign tx_mrk_userbit                     = '0                                 ;
  assign tx_stb_userbit                     = '1                                 ;

// Interconnect Wires
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Auto Sync

   ll_auto_sync #(.MARKER_WIDTH(2),
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

  // No AXI Valid or Ready, so bypassing main Logic Link FIFO and Credit logic.
  assign rxfifo_downstream_data [   0 +: 282] = rx_downstream_data   [   0 +: 282] ;
  assign rx_downstream_debug_status [   0 +:  32] = 32'h0                              ;

  // No AXI Valid or Ready, so bypassing main Logic Link FIFO and Credit logic.
  assign tx_upstream_data     [   0 +: 282] = txfifo_upstream_data [   0 +: 282] ;
  assign tx_upstream_debug_status [   0 +:  32] = 32'h0                              ;

// Logic Link Instantiation
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// User Interface

      lpif_txrx_x4_asym1_half_slave_name lpif_txrx_x4_asym1_half_slave_name
      (
         .dstrm_state                      (dstrm_state[   7:   0]),
         .dstrm_protid                     (dstrm_protid[   3:   0]),
         .dstrm_data                       (dstrm_data[ 255:   0]),
         .dstrm_dvalid                     (dstrm_dvalid[   1:   0]),
         .dstrm_crc                        (dstrm_crc[   7:   0]),
         .dstrm_crc_valid                  (dstrm_crc_valid[   1:   0]),
         .dstrm_valid                      (dstrm_valid[   1:   0]),
         .ustrm_state                      (ustrm_state[   7:   0]),
         .ustrm_protid                     (ustrm_protid[   3:   0]),
         .ustrm_data                       (ustrm_data[ 255:   0]),
         .ustrm_dvalid                     (ustrm_dvalid[   1:   0]),
         .ustrm_crc                        (ustrm_crc[   7:   0]),
         .ustrm_crc_valid                  (ustrm_crc_valid[   1:   0]),
         .ustrm_valid                      (ustrm_valid[   1:   0]),

         .rxfifo_downstream_data           (rxfifo_downstream_data[ 281:   0]),
         .txfifo_upstream_data             (txfifo_upstream_data[ 281:   0]),

         .m_gen2_mode                      (m_gen2_mode)

      );
// User Interface                                                 
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// PHY Interface

      lpif_txrx_x4_asym1_half_slave_concat lpif_txrx_x4_asym1_half_slave_concat
      (
         .rx_downstream_data               (rx_downstream_data[   0 +: 282]),
         .rx_downstream_push_ovrd          (rx_downstream_push_ovrd),
         .tx_upstream_data                 (tx_upstream_data[   0 +: 282]),
         .tx_upstream_pop_ovrd             (tx_upstream_pop_ovrd),

         .tx_phy0                          (tx_phy0[79:0]),
         .rx_phy0                          (rx_phy0[79:0]),
         .tx_phy1                          (tx_phy1[79:0]),
         .rx_phy1                          (rx_phy1[79:0]),
         .tx_phy2                          (tx_phy2[79:0]),
         .rx_phy2                          (rx_phy2[79:0]),
         .tx_phy3                          (tx_phy3[79:0]),
         .rx_phy3                          (rx_phy3[79:0]),

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