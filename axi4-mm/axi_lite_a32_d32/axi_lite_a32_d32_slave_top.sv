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

module axi_lite_a32_d32_slave_top  (
  input  logic               clk_wr              ,
  input  logic               rst_wr_n            ,

  // Control signals
  input  logic               tx_online           ,
  input  logic               rx_online           ,

  input  logic [7:0]         init_r_lite_credit  ,
  input  logic [7:0]         init_b_lite_credit  ,

  // PHY Interconnect
  output logic [ 159:   0]   tx_phy0             ,
  input  logic [ 159:   0]   rx_phy0             ,

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

  // Debug Status Outputs
  output logic [31:0]        rx_ar_lite_debug_status,
  output logic [31:0]        rx_aw_lite_debug_status,
  output logic [31:0]        rx_w_lite_debug_status,
  output logic [31:0]        tx_r_lite_debug_status,
  output logic [31:0]        tx_b_lite_debug_status,

  // Configuration
  input  logic               m_gen2_mode         ,


  input  logic [15:0]        delay_x_value       ,
  input  logic [15:0]        delay_y_value       ,
  input  logic [15:0]        delay_z_value       

);

//////////////////////////////////////////////////////////////////
// Interconnect Wires
  logic                                          rx_ar_lite_pushbit            ;
  logic                                          user_ar_lite_vld              ;
  logic [  31:   0]                              rx_ar_lite_data               ;
  logic [  31:   0]                              rxfifo_ar_lite_data           ;
  logic                                          tx_ar_lite_credit             ;
  logic                                          user_ar_lite_ready            ;
  logic                                          rx_ar_lite_push_ovrd          ;

  logic                                          rx_aw_lite_pushbit            ;
  logic                                          user_aw_lite_vld              ;
  logic [  31:   0]                              rx_aw_lite_data               ;
  logic [  31:   0]                              rxfifo_aw_lite_data           ;
  logic                                          tx_aw_lite_credit             ;
  logic                                          user_aw_lite_ready            ;
  logic                                          rx_aw_lite_push_ovrd          ;

  logic                                          rx_w_lite_pushbit             ;
  logic                                          user_w_lite_vld               ;
  logic [  35:   0]                              rx_w_lite_data                ;
  logic [  35:   0]                              rxfifo_w_lite_data            ;
  logic                                          tx_w_lite_credit              ;
  logic                                          user_w_lite_ready             ;
  logic                                          rx_w_lite_push_ovrd           ;

  logic                                          tx_r_lite_pushbit             ;
  logic                                          user_r_lite_vld               ;
  logic [  33:   0]                              tx_r_lite_data                ;
  logic [  33:   0]                              txfifo_r_lite_data            ;
  logic                                          rx_r_lite_credit              ;
  logic                                          user_r_lite_ready             ;
  logic                                          tx_r_lite_pop_ovrd            ;

  logic                                          tx_b_lite_pushbit             ;
  logic                                          user_b_lite_vld               ;
  logic [   1:   0]                              tx_b_lite_data                ;
  logic [   1:   0]                              txfifo_b_lite_data            ;
  logic                                          rx_b_lite_credit              ;
  logic                                          user_b_lite_ready             ;
  logic                                          tx_b_lite_pop_ovrd            ;

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

      ll_receive #(.WIDTH(32), .DEPTH(8'd8)) ll_receive_iar_lite
        (// Outputs
         .rxfifo_i_data                    (rxfifo_ar_lite_data[31:0]),
         .user_i_valid                     (user_ar_lite_vld),
         .tx_i_credit                      (tx_ar_lite_credit),
         .rx_i_debug_status                (rx_ar_lite_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .tx_online                        (tx_online_delay),
         .rx_i_push_ovrd                   (rx_ar_lite_push_ovrd),
         .rx_i_data                        (rx_ar_lite_data[31:0]),
         .rx_i_pushbit                     (rx_ar_lite_pushbit),
         .user_i_ready                     (user_ar_lite_ready));

      ll_receive #(.WIDTH(32), .DEPTH(8'd8)) ll_receive_iaw_lite
        (// Outputs
         .rxfifo_i_data                    (rxfifo_aw_lite_data[31:0]),
         .user_i_valid                     (user_aw_lite_vld),
         .tx_i_credit                      (tx_aw_lite_credit),
         .rx_i_debug_status                (rx_aw_lite_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .tx_online                        (tx_online_delay),
         .rx_i_push_ovrd                   (rx_aw_lite_push_ovrd),
         .rx_i_data                        (rx_aw_lite_data[31:0]),
         .rx_i_pushbit                     (rx_aw_lite_pushbit),
         .user_i_ready                     (user_aw_lite_ready));

      ll_receive #(.WIDTH(36), .DEPTH(8'd128)) ll_receive_iw_lite
        (// Outputs
         .rxfifo_i_data                    (rxfifo_w_lite_data[35:0]),
         .user_i_valid                     (user_w_lite_vld),
         .tx_i_credit                      (tx_w_lite_credit),
         .rx_i_debug_status                (rx_w_lite_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .tx_online                        (tx_online_delay),
         .rx_i_push_ovrd                   (rx_w_lite_push_ovrd),
         .rx_i_data                        (rx_w_lite_data[35:0]),
         .rx_i_pushbit                     (rx_w_lite_pushbit),
         .user_i_ready                     (user_w_lite_ready));

      ll_transmit #(.WIDTH(34), .DEPTH(8'd1), .TX_CRED_SIZE(3'h1), .ASYMMETRIC_CREDIT(1'b0), .DEFAULT_TX_CRED(8'd128)) ll_transmit_ir_lite
        (// Outputs
         .user_i_ready                     (user_r_lite_ready),
         .tx_i_data                        (tx_r_lite_data[33:0]),
         .tx_i_pushbit                     (tx_r_lite_pushbit),
         .tx_i_debug_status                (tx_r_lite_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .end_of_txcred_coal               (1'b1),
         .tx_online                        (tx_online_delay),
         .rx_online                        (rx_online_delay),
         .init_i_credit                    (init_r_lite_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_r_lite_pop_ovrd),
         .txfifo_i_data                    (txfifo_r_lite_data[33:0]),
         .user_i_valid                     (user_r_lite_vld),
         .rx_i_credit                      ({3'b0,rx_r_lite_credit}));

      ll_transmit #(.WIDTH(2), .DEPTH(8'd1), .TX_CRED_SIZE(3'h1), .ASYMMETRIC_CREDIT(1'b0), .DEFAULT_TX_CRED(8'd8)) ll_transmit_ib_lite
        (// Outputs
         .user_i_ready                     (user_b_lite_ready),
         .tx_i_data                        (tx_b_lite_data[1:0]),
         .tx_i_pushbit                     (tx_b_lite_pushbit),
         .tx_i_debug_status                (tx_b_lite_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .end_of_txcred_coal               (1'b1),
         .tx_online                        (tx_online_delay),
         .rx_online                        (rx_online_delay),
         .init_i_credit                    (init_b_lite_credit[7:0]),
         .tx_i_pop_ovrd                    (tx_b_lite_pop_ovrd),
         .txfifo_i_data                    (txfifo_b_lite_data[1:0]),
         .user_i_valid                     (user_b_lite_vld),
         .rx_i_credit                      ({3'b0,rx_b_lite_credit}));

// Logic Link Instantiation
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// User Interface

      axi_lite_a32_d32_slave_name axi_lite_a32_d32_slave_name
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
         .rxfifo_ar_lite_data              (rxfifo_ar_lite_data[  31:   0]),
         .user_ar_lite_ready               (user_ar_lite_ready),
         .user_aw_lite_vld                 (user_aw_lite_vld),
         .rxfifo_aw_lite_data              (rxfifo_aw_lite_data[  31:   0]),
         .user_aw_lite_ready               (user_aw_lite_ready),
         .user_w_lite_vld                  (user_w_lite_vld),
         .rxfifo_w_lite_data               (rxfifo_w_lite_data[  35:   0]),
         .user_w_lite_ready                (user_w_lite_ready),
         .user_r_lite_vld                  (user_r_lite_vld),
         .txfifo_r_lite_data               (txfifo_r_lite_data[  33:   0]),
         .user_r_lite_ready                (user_r_lite_ready),
         .user_b_lite_vld                  (user_b_lite_vld),
         .txfifo_b_lite_data               (txfifo_b_lite_data[   1:   0]),
         .user_b_lite_ready                (user_b_lite_ready),

         .m_gen2_mode                      (m_gen2_mode)

      );
// User Interface                                                 
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// PHY Interface

      axi_lite_a32_d32_slave_concat axi_lite_a32_d32_slave_concat
      (
         .rx_ar_lite_data                  (rx_ar_lite_data[   0 +:  32]),
         .rx_ar_lite_push_ovrd             (rx_ar_lite_push_ovrd),
         .rx_ar_lite_pushbit               (rx_ar_lite_pushbit),
         .tx_ar_lite_credit                (tx_ar_lite_credit),
         .rx_aw_lite_data                  (rx_aw_lite_data[   0 +:  32]),
         .rx_aw_lite_push_ovrd             (rx_aw_lite_push_ovrd),
         .rx_aw_lite_pushbit               (rx_aw_lite_pushbit),
         .tx_aw_lite_credit                (tx_aw_lite_credit),
         .rx_w_lite_data                   (rx_w_lite_data[   0 +:  36]),
         .rx_w_lite_push_ovrd              (rx_w_lite_push_ovrd),
         .rx_w_lite_pushbit                (rx_w_lite_pushbit),
         .tx_w_lite_credit                 (tx_w_lite_credit),
         .tx_r_lite_data                   (tx_r_lite_data[   0 +:  34]),
         .tx_r_lite_pop_ovrd               (tx_r_lite_pop_ovrd),
         .tx_r_lite_pushbit                (tx_r_lite_pushbit),
         .rx_r_lite_credit                 (rx_r_lite_credit),
         .tx_b_lite_data                   (tx_b_lite_data[   0 +:   2]),
         .tx_b_lite_pop_ovrd               (tx_b_lite_pop_ovrd),
         .tx_b_lite_pushbit                (tx_b_lite_pushbit),
         .rx_b_lite_credit                 (rx_b_lite_credit),

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
