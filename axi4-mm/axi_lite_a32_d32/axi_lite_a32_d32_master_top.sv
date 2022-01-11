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

module axi_lite_a32_d32_master_top  (
  input  logic               clk_wr              ,
  input  logic               rst_wr_n            ,

  // Control signals
  input  logic               tx_online           ,
  input  logic               rx_online           ,

  input  logic [7:0]         init_ar_lite_credit ,
  input  logic [7:0]         init_aw_lite_credit ,
  input  logic [7:0]         init_w_lite_credit  ,

  // PHY Interconnect
  output logic [ 159:   0]   tx_phy0             ,
  input  logic [ 159:   0]   rx_phy0             ,

  // ar_lite channel
  input  logic [  31:   0]   user_araddr         ,
  input  logic               user_arvalid        ,
  output logic               user_arready        ,

  // aw_lite channel
  input  logic [  31:   0]   user_awaddr         ,
  input  logic               user_awvalid        ,
  output logic               user_awready        ,

  // w_lite channel
  input  logic [  31:   0]   user_wdata          ,
  input  logic [   3:   0]   user_wstrb          ,
  input  logic               user_wvalid         ,
  output logic               user_wready         ,

  // r_lite channel
  output logic [  31:   0]   user_rdata          ,
  output logic [   1:   0]   user_rresp          ,
  output logic               user_rvalid         ,
  input  logic               user_rready         ,

  // b_lite channel
  output logic [   1:   0]   user_bresp          ,
  output logic               user_bvalid         ,
  input  logic               user_bready         ,

  // Debug Status Outputs
  output logic [31:0]        tx_ar_lite_debug_status,
  output logic [31:0]        tx_aw_lite_debug_status,
  output logic [31:0]        tx_w_lite_debug_status,
  output logic [31:0]        rx_r_lite_debug_status,
  output logic [31:0]        rx_b_lite_debug_status,

  // Configuration
  input  logic               m_gen2_mode         ,


  input  logic [15:0]        delay_x_value       ,
  input  logic [15:0]        delay_y_value       ,
  input  logic [15:0]        delay_z_value       

);

//////////////////////////////////////////////////////////////////
// Interconnect Wires
  logic                                          tx_ar_lite_pushbit            ;
  logic                                          user_ar_lite_vld              ;
  logic [  31:   0]                              tx_ar_lite_data               ;
  logic [  31:   0]                              txfifo_ar_lite_data           ;
  logic                                          rx_ar_lite_credit             ;
  logic                                          user_ar_lite_ready            ;
  logic                                          tx_ar_lite_pop_ovrd           ;

  logic                                          tx_aw_lite_pushbit            ;
  logic                                          user_aw_lite_vld              ;
  logic [  31:   0]                              tx_aw_lite_data               ;
  logic [  31:   0]                              txfifo_aw_lite_data           ;
  logic                                          rx_aw_lite_credit             ;
  logic                                          user_aw_lite_ready            ;
  logic                                          tx_aw_lite_pop_ovrd           ;

  logic                                          tx_w_lite_pushbit             ;
  logic                                          user_w_lite_vld               ;
  logic [  35:   0]                              tx_w_lite_data                ;
  logic [  35:   0]                              txfifo_w_lite_data            ;
  logic                                          rx_w_lite_credit              ;
  logic                                          user_w_lite_ready             ;
  logic                                          tx_w_lite_pop_ovrd            ;

  logic                                          rx_r_lite_pushbit             ;
  logic                                          user_r_lite_vld               ;
  logic [  33:   0]                              rx_r_lite_data                ;
  logic [  33:   0]                              rxfifo_r_lite_data            ;
  logic                                          tx_r_lite_credit              ;
  logic                                          user_r_lite_ready             ;
  logic                                          rx_r_lite_push_ovrd           ;

  logic                                          rx_b_lite_pushbit             ;
  logic                                          user_b_lite_vld               ;
  logic [   1:   0]                              rx_b_lite_data                ;
  logic [   1:   0]                              rxfifo_b_lite_data            ;
  logic                                          tx_b_lite_credit              ;
  logic                                          user_b_lite_ready             ;
  logic                                          rx_b_lite_push_ovrd           ;

  logic [   1:   0]                              tx_auto_mrk_userbit           ;
  logic                                          tx_auto_stb_userbit           ;
  logic                                          tx_online_delay               ;
  logic                                          rx_online_delay               ;
  logic                                          rx_online_holdoff             ;
  logic [   1:   0]                              tx_mrk_userbit                ; // No TX User Marker, so tie off
  logic                                          tx_stb_userbit                ; // No TX User Strobe, so tie off
  assign tx_mrk_userbit                     = '0                                 ;
  assign tx_stb_userbit                     = '1                                 ;

// Interconnect Wires
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Auto Sync

  assign rx_online_holdoff                  = 1'b0                               ;

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
      .rx_online_holdoff                (rx_online_holdoff),
      .delay_x_value                    (delay_x_value[15:0]));

// Auto Sync
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Logic Link Instantiation

      ll_transmit #(.WIDTH(32), .DEPTH(8'd1), .TX_CRED_SIZE(3'h1), .ASYMMETRIC_CREDIT(1'b0), .DEFAULT_TX_CRED(8'd8)) ll_transmit_iar_lite
        (// Outputs
         .user_i_ready                     (user_ar_lite_ready),
         .tx_i_data                        (tx_ar_lite_data[31:0]),
         .tx_i_pushbit                     (tx_ar_lite_pushbit),
         .tx_i_debug_status                (tx_ar_lite_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .end_of_txcred_coal               (1'b1),
         .tx_online                        (tx_online_delay),
         .rx_online                        (rx_online_delay),
         .init_i_credit                    (init_ar_lite_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_ar_lite_pop_ovrd),
         .txfifo_i_data                    (txfifo_ar_lite_data[31:0]),
         .user_i_valid                     (user_ar_lite_vld),
         .rx_i_credit                      ({3'b0,rx_ar_lite_credit}));

      ll_transmit #(.WIDTH(32), .DEPTH(8'd1), .TX_CRED_SIZE(3'h1), .ASYMMETRIC_CREDIT(1'b0), .DEFAULT_TX_CRED(8'd8)) ll_transmit_iaw_lite
        (// Outputs
         .user_i_ready                     (user_aw_lite_ready),
         .tx_i_data                        (tx_aw_lite_data[31:0]),
         .tx_i_pushbit                     (tx_aw_lite_pushbit),
         .tx_i_debug_status                (tx_aw_lite_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .end_of_txcred_coal               (1'b1),
         .tx_online                        (tx_online_delay),
         .rx_online                        (rx_online_delay),
         .init_i_credit                    (init_aw_lite_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_aw_lite_pop_ovrd),
         .txfifo_i_data                    (txfifo_aw_lite_data[31:0]),
         .user_i_valid                     (user_aw_lite_vld),
         .rx_i_credit                      ({3'b0,rx_aw_lite_credit}));

      ll_transmit #(.WIDTH(36), .DEPTH(8'd1), .TX_CRED_SIZE(3'h1), .ASYMMETRIC_CREDIT(1'b0), .DEFAULT_TX_CRED(8'd128)) ll_transmit_iw_lite
        (// Outputs
         .user_i_ready                     (user_w_lite_ready),
         .tx_i_data                        (tx_w_lite_data[35:0]),
         .tx_i_pushbit                     (tx_w_lite_pushbit),
         .tx_i_debug_status                (tx_w_lite_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .end_of_txcred_coal               (1'b1),
         .tx_online                        (tx_online_delay),
         .rx_online                        (rx_online_delay),
         .init_i_credit                    (init_w_lite_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_w_lite_pop_ovrd),
         .txfifo_i_data                    (txfifo_w_lite_data[35:0]),
         .user_i_valid                     (user_w_lite_vld),
         .rx_i_credit                      ({3'b0,rx_w_lite_credit}));

      ll_receive #(.WIDTH(34), .DEPTH(8'd128)) ll_receive_ir_lite
        (// Outputs
         .rxfifo_i_data                    (rxfifo_r_lite_data[33:0]),
         .user_i_valid                     (user_r_lite_vld),
         .tx_i_credit                      (tx_r_lite_credit),
         .rx_i_debug_status                (rx_r_lite_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .tx_online                        (tx_online_delay),
         .rx_i_push_ovrd                   (rx_r_lite_push_ovrd),
         .rx_i_data                        (rx_r_lite_data[33:0]),
         .rx_i_pushbit                     (rx_r_lite_pushbit),
         .user_i_ready                     (user_r_lite_ready));

      ll_receive #(.WIDTH(2), .DEPTH(8'd8)) ll_receive_ib_lite
        (// Outputs
         .rxfifo_i_data                    (rxfifo_b_lite_data[1:0]),
         .user_i_valid                     (user_b_lite_vld),
         .tx_i_credit                      (tx_b_lite_credit),
         .rx_i_debug_status                (rx_b_lite_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .tx_online                        (tx_online_delay),
         .rx_i_push_ovrd                   (rx_b_lite_push_ovrd),
         .rx_i_data                        (rx_b_lite_data[1:0]),
         .rx_i_pushbit                     (rx_b_lite_pushbit),
         .user_i_ready                     (user_b_lite_ready));

// Logic Link Instantiation
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// User Interface

      axi_lite_a32_d32_master_name axi_lite_a32_d32_master_name
      (
         .user_araddr                      (user_araddr[  31:   0]),
         .user_arvalid                     (user_arvalid),
         .user_arready                     (user_arready),
         .user_awaddr                      (user_awaddr[  31:   0]),
         .user_awvalid                     (user_awvalid),
         .user_awready                     (user_awready),
         .user_wdata                       (user_wdata[  31:   0]),
         .user_wstrb                       (user_wstrb[   3:   0]),
         .user_wvalid                      (user_wvalid),
         .user_wready                      (user_wready),
         .user_rdata                       (user_rdata[  31:   0]),
         .user_rresp                       (user_rresp[   1:   0]),
         .user_rvalid                      (user_rvalid),
         .user_rready                      (user_rready),
         .user_bresp                       (user_bresp[   1:   0]),
         .user_bvalid                      (user_bvalid),
         .user_bready                      (user_bready),

         .user_ar_lite_vld                 (user_ar_lite_vld),
         .txfifo_ar_lite_data              (txfifo_ar_lite_data[  31:   0]),
         .user_ar_lite_ready               (user_ar_lite_ready),
         .user_aw_lite_vld                 (user_aw_lite_vld),
         .txfifo_aw_lite_data              (txfifo_aw_lite_data[  31:   0]),
         .user_aw_lite_ready               (user_aw_lite_ready),
         .user_w_lite_vld                  (user_w_lite_vld),
         .txfifo_w_lite_data               (txfifo_w_lite_data[  35:   0]),
         .user_w_lite_ready                (user_w_lite_ready),
         .user_r_lite_vld                  (user_r_lite_vld),
         .rxfifo_r_lite_data               (rxfifo_r_lite_data[  33:   0]),
         .user_r_lite_ready                (user_r_lite_ready),
         .user_b_lite_vld                  (user_b_lite_vld),
         .rxfifo_b_lite_data               (rxfifo_b_lite_data[   1:   0]),
         .user_b_lite_ready                (user_b_lite_ready),

         .m_gen2_mode                      (m_gen2_mode)

      );
// User Interface                                                 
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// PHY Interface

      axi_lite_a32_d32_master_concat axi_lite_a32_d32_master_concat
      (
         .tx_ar_lite_data                  (tx_ar_lite_data[   0 +:  32]),
         .tx_ar_lite_pop_ovrd              (tx_ar_lite_pop_ovrd),
         .tx_ar_lite_pushbit               (tx_ar_lite_pushbit),
         .rx_ar_lite_credit                (rx_ar_lite_credit),
         .tx_aw_lite_data                  (tx_aw_lite_data[   0 +:  32]),
         .tx_aw_lite_pop_ovrd              (tx_aw_lite_pop_ovrd),
         .tx_aw_lite_pushbit               (tx_aw_lite_pushbit),
         .rx_aw_lite_credit                (rx_aw_lite_credit),
         .tx_w_lite_data                   (tx_w_lite_data[   0 +:  36]),
         .tx_w_lite_pop_ovrd               (tx_w_lite_pop_ovrd),
         .tx_w_lite_pushbit                (tx_w_lite_pushbit),
         .rx_w_lite_credit                 (rx_w_lite_credit),
         .rx_r_lite_data                   (rx_r_lite_data[   0 +:  34]),
         .rx_r_lite_push_ovrd              (rx_r_lite_push_ovrd),
         .rx_r_lite_pushbit                (rx_r_lite_pushbit),
         .tx_r_lite_credit                 (tx_r_lite_credit),
         .rx_b_lite_data                   (rx_b_lite_data[   0 +:   2]),
         .rx_b_lite_push_ovrd              (rx_b_lite_push_ovrd),
         .rx_b_lite_pushbit                (rx_b_lite_pushbit),
         .tx_b_lite_credit                 (tx_b_lite_credit),

         .tx_phy0                          (tx_phy0[159:0]),
         .rx_phy0                          (rx_phy0[159:0]),

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
