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

module axi_dual_st_d64_master_top  (
  input  logic               clk_wr              ,
  input  logic               rst_wr_n            ,

  // Control signals
  input  logic               tx_online           ,
  input  logic               rx_online           ,

  input  logic [7:0]         init_ST_M2S_credit  ,

  // PHY Interconnect
  output logic [  79:   0]   tx_phy0             ,
  input  logic [  79:   0]   rx_phy0             ,

  // ST_M2S channel
  input  logic [   7:   0]   user_m2s_tkeep      ,
  input  logic [  63:   0]   user_m2s_tdata      ,
  input  logic               user_m2s_tlast      ,
  input  logic               user_m2s_tvalid     ,
  output logic               user_m2s_tready     ,

  // ST_S2M channel
  output logic [   7:   0]   user_s2m_tkeep      ,
  output logic [  63:   0]   user_s2m_tdata      ,
  output logic               user_s2m_tlast      ,
  output logic               user_s2m_tvalid     ,
  input  logic               user_s2m_tready     ,

  // Debug Status Outputs
  output logic [31:0]        tx_ST_M2S_debug_status,
  output logic [31:0]        rx_ST_S2M_debug_status,

  // Configuration
  input  logic               m_gen2_mode         ,


  input  logic [15:0]        delay_x_value       ,
  input  logic [15:0]        delay_y_value       ,
  input  logic [15:0]        delay_z_value       

);

//////////////////////////////////////////////////////////////////
// Interconnect Wires
  logic                                          tx_ST_M2S_pushbit             ;
  logic                                          user_ST_M2S_vld               ;
  logic [  72:   0]                              tx_ST_M2S_data                ;
  logic [  72:   0]                              txfifo_ST_M2S_data            ;
  logic                                          rx_ST_M2S_credit              ;
  logic                                          user_ST_M2S_ready             ;
  logic                                          tx_ST_M2S_pop_ovrd            ;

  logic                                          rx_ST_S2M_pushbit             ;
  logic                                          user_ST_S2M_vld               ;
  logic [  72:   0]                              rx_ST_S2M_data                ;
  logic [  72:   0]                              rxfifo_ST_S2M_data            ;
  logic                                          tx_ST_S2M_credit              ;
  logic                                          user_ST_S2M_ready             ;
  logic                                          rx_ST_S2M_push_ovrd           ;

  logic [   0:   0]                              tx_auto_mrk_userbit           ;
  logic                                          tx_auto_stb_userbit           ;
  logic                                          tx_online_delay               ;
  logic                                          rx_online_delay               ;
  logic                                          rx_online_holdoff             ;
  logic [   0:   0]                              tx_mrk_userbit                ; // No TX User Marker, so tie off
  logic                                          tx_stb_userbit                ; // No TX User Strobe, so tie off
  assign tx_mrk_userbit                     = '0                                 ;
  assign tx_stb_userbit                     = '1                                 ;

// Interconnect Wires
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Auto Sync

  assign rx_online_holdoff                  = 1'b0                               ;

   ll_auto_sync #(.MARKER_WIDTH(1),
                  .PERSISTENT_MARKER(1'b0),
                  .NO_MARKER(1'b1),
                  .PERSISTENT_STROBE(1'b0)) ll_auto_sync_i
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
      .rx_online_holdoff                (rx_online_holdoff),
      .delay_x_value                    (delay_x_value[15:0]));

// Auto Sync
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Logic Link Instantiation

      ll_transmit #(.WIDTH(73), .DEPTH(8'd1), .TX_CRED_SIZE(3'h1), .ASYMMETRIC_CREDIT(1'b0), .DEFAULT_TX_CRED(8'd128)) ll_transmit_iST_M2S
        (// Outputs
         .user_i_ready                     (user_ST_M2S_ready),
         .tx_i_data                        (tx_ST_M2S_data[72:0]),
         .tx_i_pushbit                     (tx_ST_M2S_pushbit),
         .tx_i_debug_status                (tx_ST_M2S_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .end_of_txcred_coal               (1'b1),
         .tx_online                        (tx_online_delay),
         .rx_online                        (rx_online_delay),
         .init_i_credit                    (init_ST_M2S_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ST_M2S_pop_ovrd),
         .txfifo_i_data                    (txfifo_ST_M2S_data[72:0]),
         .user_i_valid                     (user_ST_M2S_vld),
         .rx_i_credit                      ({3'b0,rx_ST_M2S_credit}));

      ll_receive #(.WIDTH(73), .DEPTH(8'd128)) ll_receive_iST_S2M
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ST_S2M_data[72:0]),
         .user_i_valid                     (user_ST_S2M_vld),
         .tx_i_credit                      (tx_ST_S2M_credit),
         .rx_i_debug_status                (rx_ST_S2M_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .tx_online                        (tx_online_delay),
         .rx_i_push_ovrd                   (rx_ST_S2M_push_ovrd),
         .rx_i_data                        (rx_ST_S2M_data[72:0]),
         .rx_i_pushbit                     (rx_ST_S2M_pushbit),
         .user_i_ready                     (user_ST_S2M_ready));

// Logic Link Instantiation
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// User Interface

      axi_dual_st_d64_master_name axi_dual_st_d64_master_name
      (
         .user_m2s_tkeep                   (user_m2s_tkeep[   7:   0]),
         .user_m2s_tdata                   (user_m2s_tdata[  63:   0]),
         .user_m2s_tlast                   (user_m2s_tlast),
         .user_m2s_tvalid                  (user_m2s_tvalid),
         .user_m2s_tready                  (user_m2s_tready),
         .user_s2m_tkeep                   (user_s2m_tkeep[   7:   0]),
         .user_s2m_tdata                   (user_s2m_tdata[  63:   0]),
         .user_s2m_tlast                   (user_s2m_tlast),
         .user_s2m_tvalid                  (user_s2m_tvalid),
         .user_s2m_tready                  (user_s2m_tready),

         .user_ST_M2S_vld                  (user_ST_M2S_vld),
         .txfifo_ST_M2S_data               (txfifo_ST_M2S_data[  72:   0]),
         .user_ST_M2S_ready                (user_ST_M2S_ready),
         .user_ST_S2M_vld                  (user_ST_S2M_vld),
         .rxfifo_ST_S2M_data               (rxfifo_ST_S2M_data[  72:   0]),
         .user_ST_S2M_ready                (user_ST_S2M_ready),

         .m_gen2_mode                      (m_gen2_mode)

      );
// User Interface                                                 
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// PHY Interface

      axi_dual_st_d64_master_concat axi_dual_st_d64_master_concat
      (
         .tx_ST_M2S_data                   (tx_ST_M2S_data[   0 +:  73]),
         .tx_ST_M2S_pop_ovrd               (tx_ST_M2S_pop_ovrd),
         .tx_ST_M2S_pushbit                (tx_ST_M2S_pushbit),
         .rx_ST_M2S_credit                 (rx_ST_M2S_credit),
         .rx_ST_S2M_data                   (rx_ST_S2M_data[   0 +:  73]),
         .rx_ST_S2M_push_ovrd              (rx_ST_S2M_push_ovrd),
         .rx_ST_S2M_pushbit                (rx_ST_S2M_pushbit),
         .tx_ST_S2M_credit                 (tx_ST_S2M_credit),

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
