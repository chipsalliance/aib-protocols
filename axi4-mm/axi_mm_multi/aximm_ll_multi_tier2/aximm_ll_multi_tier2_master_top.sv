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

module aximm_ll_multi_tier2_master_top  (
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
  input  logic [  78:   0]   ch0_tx_data         ,
  input  logic [  78:   0]   ch1_tx_data         ,
  input  logic [  78:   0]   ch2_tx_data         ,
  input  logic [  78:   0]   ch3_tx_data         ,

  // rx channel
  output logic [  78:   0]   ch0_rx_data         ,
  output logic [  78:   0]   ch1_rx_data         ,
  output logic [  78:   0]   ch2_rx_data         ,
  output logic [  78:   0]   ch3_rx_data         ,

  // Debug Status Outputs
  output logic [31:0]        tx_tx_debug_status  ,
  output logic [31:0]        rx_rx_debug_status  ,

  // Configuration
  input  logic               m_gen2_mode         ,


  input  logic [15:0]        delay_x_value       ,
  input  logic [15:0]        delay_y_value       ,
  input  logic [15:0]        delay_z_value       

);

//////////////////////////////////////////////////////////////////
// Interconnect Wires
  logic [ 315:   0]                              tx_tx_data                    ;
  logic [ 315:   0]                              txfifo_tx_data                ;
  logic                                          tx_tx_pop_ovrd                ;

  logic [ 315:   0]                              rx_rx_data                    ;
  logic [ 315:   0]                              rxfifo_rx_data                ;
  logic                                          rx_rx_push_ovrd               ;

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

  // No AXI Valid or Ready, so bypassing main Logic Link FIFO and Credit logic.
  assign tx_tx_data           [   0 +: 316] = txfifo_tx_data       [   0 +: 316] ;
  assign tx_tx_debug_status   [   0 +:  32] = {12'h0, tx_online_delay, rx_online_delay, 18'h0} ;               
  // No AXI Valid or Ready, so bypassing main Logic Link FIFO and Credit logic.
  assign rxfifo_rx_data       [   0 +: 316] = rx_rx_data           [   0 +: 316] ;
  assign rx_rx_debug_status   [   0 +:  32] = {12'h0, tx_online_delay, rx_online_delay, 18'h0} ;               
// Logic Link Instantiation
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// User Interface

      aximm_ll_multi_tier2_master_name aximm_ll_multi_tier2_master_name
      (
         .ch0_tx_data                      (ch0_tx_data[  78:   0]),
         .ch1_tx_data                      (ch1_tx_data[  78:   0]),
         .ch2_tx_data                      (ch2_tx_data[  78:   0]),
         .ch3_tx_data                      (ch3_tx_data[  78:   0]),
         .ch0_rx_data                      (ch0_rx_data[  78:   0]),
         .ch1_rx_data                      (ch1_rx_data[  78:   0]),
         .ch2_rx_data                      (ch2_rx_data[  78:   0]),
         .ch3_rx_data                      (ch3_rx_data[  78:   0]),

         .txfifo_tx_data                   (txfifo_tx_data[ 315:   0]),
         .rxfifo_rx_data                   (rxfifo_rx_data[ 315:   0]),

         .m_gen2_mode                      (m_gen2_mode)

      );
// User Interface                                                 
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// PHY Interface

      aximm_ll_multi_tier2_master_concat aximm_ll_multi_tier2_master_concat
      (
         .tx_tx_data                       (tx_tx_data[   0 +: 316]),
         .tx_tx_pop_ovrd                   (tx_tx_pop_ovrd),
         .rx_rx_data                       (rx_rx_data[   0 +: 316]),
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
