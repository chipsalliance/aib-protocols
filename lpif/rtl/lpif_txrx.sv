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
//
// Functional Descript: LPIF Adapter IP txrx datapath
//
//
//
////////////////////////////////////////////////////////////

module lpif_txrx
  #(
    parameter AIB_VERSION = 2,
    parameter AIB_GENERATION = 2,
    parameter LPIF_DATA_WIDTH = 128,
    parameter LPIF_CLOCK_RATE = 2000,
    localparam LPIF_VALID_WIDTH = ((LPIF_DATA_WIDTH == 128) ? 2 : 1),
    localparam LPIF_CRC_WIDTH = ((LPIF_DATA_WIDTH == 128) ? 32 : 16)
    )
  (
   input logic                          com_clk,
   input logic                          rst_n,

   input logic                          tx_online,
   input logic                          rx_online,
   input logic                          m_gen2_mode,

   input logic [7:0]                    delay_x_value,
   input logic [7:0]                    delay_xz_value,
   input logic [7:0]                    delay_yz_value,

   input logic [319:0]                  rx_phy0,
   input logic [319:0]                  rx_phy1,
   input logic [319:0]                  rx_phy2,
   input logic [319:0]                  rx_phy3,
   input logic [319:0]                  rx_phy4,
   input logic [319:0]                  rx_phy5,
   input logic [319:0]                  rx_phy6,
   input logic [319:0]                  rx_phy7,
   input logic [319:0]                  rx_phy8,
   input logic [319:0]                  rx_phy9,
   input logic [319:0]                  rx_phy10,
   input logic [319:0]                  rx_phy11,
   input logic [319:0]                  rx_phy12,
   input logic [319:0]                  rx_phy13,
   input logic [319:0]                  rx_phy14,
   input logic [319:0]                  rx_phy15,

   input logic [3:0]                    dstrm_state,
   input logic [1:0]                    dstrm_protid,
   input logic [LPIF_DATA_WIDTH*8-1:0]  dstrm_data,
   input logic [LPIF_VALID_WIDTH-1:0]   dstrm_dvalid,
   input logic [LPIF_CRC_WIDTH-1:0]     dstrm_crc,
   input logic [LPIF_VALID_WIDTH-1:0]   dstrm_crc_valid,
   input logic                          dstrm_valid,

   output logic [319:0]                 tx_phy0,
   output logic [319:0]                 tx_phy1,
   output logic [319:0]                 tx_phy2,
   output logic [319:0]                 tx_phy3,
   output logic [319:0]                 tx_phy4,
   output logic [319:0]                 tx_phy5,
   output logic [319:0]                 tx_phy6,
   output logic [319:0]                 tx_phy7,
   output logic [319:0]                 tx_phy8,
   output logic [319:0]                 tx_phy9,
   output logic [319:0]                 tx_phy10,
   output logic [319:0]                 tx_phy11,
   output logic [319:0]                 tx_phy12,
   output logic [319:0]                 tx_phy13,
   output logic [319:0]                 tx_phy14,
   output logic [319:0]                 tx_phy15,

   output logic [3:0]                   ustrm_state,
   output logic [1:0]                   ustrm_protid,
   output logic [LPIF_DATA_WIDTH*8-1:0] ustrm_data,
   output logic [LPIF_VALID_WIDTH-1:0]  ustrm_dvalid,
   output logic [LPIF_CRC_WIDTH-1:0]    ustrm_crc,
   output logic [LPIF_VALID_WIDTH-1:0]  ustrm_crc_valid,
   output logic                         ustrm_valid,

   output logic [31:0]                  rx_upstream_debug_status,
   output logic [31:0]                  tx_downstream_debug_status
   );

  /*AUTOWIRE*/

  logic                                 tx_stb_userbit;
  logic [3:0]                           tx_mrk_userbit;

  /* TX & RX datapath */

  localparam X16_Q2 = ((AIB_VERSION == 2) && (AIB_GENERATION == 2) && (LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH == 128));
  localparam X16_H2 = ((AIB_VERSION == 2) && (AIB_GENERATION == 2) && (LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  64));
  localparam X16_F2 = ((AIB_VERSION == 2) && (AIB_GENERATION == 2) && (LPIF_CLOCK_RATE == 2000) && (LPIF_DATA_WIDTH ==  32));

  localparam X8_Q2 =  ((AIB_VERSION == 2) && (AIB_GENERATION == 2) && (LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH ==  64));
  localparam X8_H2 =  ((AIB_VERSION == 2) && (AIB_GENERATION == 2) && (LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  32));
  localparam X8_F2 =  ((AIB_VERSION == 2) && (AIB_GENERATION == 2) && (LPIF_CLOCK_RATE == 2000) && (LPIF_DATA_WIDTH ==  16));

  localparam X4_Q2 =  ((AIB_VERSION == 2) && (AIB_GENERATION == 2) && (LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH ==  32));
  localparam X4_H2 =  ((AIB_VERSION == 2) && (AIB_GENERATION == 2) && (LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  16));
  localparam X4_F2 =  ((AIB_VERSION == 2) && (AIB_GENERATION == 2) && (LPIF_CLOCK_RATE == 2000) && (LPIF_DATA_WIDTH ==   8));

  localparam X16_H1 = ((AIB_VERSION == 2) && (AIB_GENERATION == 1) && (LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH == 128));
  localparam X16_F1 = ((AIB_VERSION == 2) && (AIB_GENERATION == 1) && (LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  64));

  localparam X8_H1 =  ((AIB_VERSION == 2) && (AIB_GENERATION == 1) && (LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH ==  64));
  localparam X8_F1 =  ((AIB_VERSION == 2) && (AIB_GENERATION == 1) && (LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  32));

  localparam X4_H1 =  ((AIB_VERSION == 2) && (AIB_GENERATION == 1) && (LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH ==  32));
  localparam X4_F1 =  ((AIB_VERSION == 2) && (AIB_GENERATION == 1) && (LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  16));

  localparam X2_H1 =  ((AIB_VERSION == 2) && (AIB_GENERATION == 1) && (LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH ==  16));
  localparam X2_F1 =  ((AIB_VERSION == 2) && (AIB_GENERATION == 1) && (LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==   8));

  localparam X1_H1 =  ((AIB_VERSION == 2) && (AIB_GENERATION == 1) && (LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH ==   8));
  localparam X1_F1 =  ((AIB_VERSION == 2) && (AIB_GENERATION == 1) && (LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==   4));

  wire                                  x16_q2 = X16_Q2;
  wire                                  x16_h2 = X16_H2;
  wire                                  x16_f2 = X16_F2;

  wire                                  x8_q2  = X8_Q2;
  wire                                  x8_h2  = X8_H2;
  wire                                  x8_f2  = X8_F2;

  wire                                  x4_q2  = X4_Q2;
  wire                                  x4_h2  = X4_H2;
  wire                                  x4_f2  = X4_F2;

  wire                                  x16_h1 = X16_H1;
  wire                                  x16_f1 = X16_F1;

  wire                                  x8_h1  = X8_H1;
  wire                                  x8_f1  = X8_F1;

  wire                                  x4_h1  = X4_H1;
  wire                                  x4_f1  = X4_F1;

  wire                                  x2_h1  = X2_H1;
  wire                                  x2_f1  = X2_F1;

  wire                                  x1_h1  = X1_H1;
  wire                                  x1_f1  = X1_F1;

  logic [319:0]                         ll_tx_phy0;
  logic [319:0]                         ll_tx_phy1;
  logic [319:0]                         ll_tx_phy2;
  logic [319:0]                         ll_tx_phy3;
  logic [319:0]                         ll_tx_phy4;
  logic [319:0]                         ll_tx_phy5;
  logic [319:0]                         ll_tx_phy6;
  logic [319:0]                         ll_tx_phy7;
  logic [319:0]                         ll_tx_phy8;
  logic [319:0]                         ll_tx_phy9;
  logic [319:0]                         ll_tx_phy10;
  logic [319:0]                         ll_tx_phy11;
  logic [319:0]                         ll_tx_phy12;
  logic [319:0]                         ll_tx_phy13;
  logic [319:0]                         ll_tx_phy14;
  logic [319:0]                         ll_tx_phy15;

  generate
    if (X16_H1 || X16_F1)
      begin
        if (X16_H1)
          begin
            assign tx_phy0  = {240'b0, ll_tx_phy0[79:0]};
            assign tx_phy1  = {240'b0, ll_tx_phy1[79:0]};
            assign tx_phy2  = {240'b0, ll_tx_phy2[79:0]};
            assign tx_phy3  = {240'b0, ll_tx_phy3[79:0]};
            assign tx_phy4  = {240'b0, ll_tx_phy4[79:0]};
            assign tx_phy5  = {240'b0, ll_tx_phy5[79:0]};
            assign tx_phy6  = {240'b0, ll_tx_phy6[79:0]};
            assign tx_phy7  = {240'b0, ll_tx_phy7[79:0]};
            assign tx_phy8  = {240'b0, ll_tx_phy8[79:0]};
            assign tx_phy9  = {240'b0, ll_tx_phy9[79:0]};
            assign tx_phy10 = {240'b0, ll_tx_phy10[79:0]};
            assign tx_phy11 = {240'b0, ll_tx_phy11[79:0]};
            assign tx_phy12 = {240'b0, ll_tx_phy12[79:0]};
            assign tx_phy13 = {240'b0, ll_tx_phy13[79:0]};
            assign tx_phy14 = {240'b0, ll_tx_phy14[79:0]};
            assign tx_phy15  = {240'b0, ll_tx_phy15[79:0]};
          end
        else if (X16_F1)
          begin
            assign tx_phy0  = {280'b0, ll_tx_phy0[39:0]};
            assign tx_phy1  = {280'b0, ll_tx_phy1[39:0]};
            assign tx_phy2  = {280'b0, ll_tx_phy2[39:0]};
            assign tx_phy3  = {280'b0, ll_tx_phy3[39:0]};
            assign tx_phy4  = {280'b0, ll_tx_phy4[39:0]};
            assign tx_phy5  = {280'b0, ll_tx_phy5[39:0]};
            assign tx_phy6  = {280'b0, ll_tx_phy6[39:0]};
            assign tx_phy7  = {280'b0, ll_tx_phy7[39:0]};
            assign tx_phy8  = {280'b0, ll_tx_phy8[39:0]};
            assign tx_phy9  = {280'b0, ll_tx_phy9[39:0]};
            assign tx_phy10 = {280'b0, ll_tx_phy10[39:0]};
            assign tx_phy11 = {280'b0, ll_tx_phy11[39:0]};
            assign tx_phy12 = {280'b0, ll_tx_phy12[39:0]};
            assign tx_phy13 = {280'b0, ll_tx_phy13[39:0]};
            assign tx_phy14 = {280'b0, ll_tx_phy14[39:0]};
            assign tx_phy15  = {280'b0, ll_tx_phy15[39:0]};
          end
      end // if (X16_H1 || X16_F1)
    else if (X8_H1 || X8_H1 || X4_F1)
      begin
        if (X8_H1 || X8_H1)
          begin
            assign tx_phy0  = {240'b0, ll_tx_phy0[79:0]};
            assign tx_phy1  = {240'b0, ll_tx_phy1[79:0]};
            assign tx_phy2  = {240'b0, ll_tx_phy2[79:0]};
            assign tx_phy3  = {240'b0, ll_tx_phy3[79:0]};
            assign tx_phy4  = {240'b0, ll_tx_phy4[79:0]};
            assign tx_phy5  = {240'b0, ll_tx_phy5[79:0]};
            assign tx_phy6  = {240'b0, ll_tx_phy6[79:0]};
            assign tx_phy7  = {240'b0, ll_tx_phy7[79:0]};
          end
        else if (X4_F1)
          begin
            assign tx_phy0  = {280'b0, ll_tx_phy0[39:0]};
            assign tx_phy1  = {280'b0, ll_tx_phy1[39:0]};
            assign tx_phy2  = {280'b0, ll_tx_phy2[39:0]};
            assign tx_phy3  = {280'b0, ll_tx_phy3[39:0]};
            assign tx_phy4  = {280'b0, ll_tx_phy4[39:0]};
            assign tx_phy5  = {280'b0, ll_tx_phy5[39:0]};
            assign tx_phy6  = {280'b0, ll_tx_phy6[39:0]};
            assign tx_phy7  = {280'b0, ll_tx_phy7[39:0]};
          end
        assign tx_phy8  = 320'b0;
        assign tx_phy9  = 320'b0;
        assign tx_phy10 = 320'b0;
        assign tx_phy11 = 320'b0;
        assign tx_phy12 = 320'b0;
        assign tx_phy13 = 320'b0;
        assign tx_phy14 = 320'b0;
        assign tx_phy15 = 320'b0;
      end
    else if (X16_Q2 || X16_H2 || X16_F2 || X4_H1)
      begin
        if (X16_Q2)
          begin
            assign tx_phy0  = ll_tx_phy0[319:0];
            assign tx_phy1  = ll_tx_phy1[319:0];
            assign tx_phy2  = ll_tx_phy2[319:0];
            assign tx_phy3  = ll_tx_phy3[319:0];
          end
        else if (X16_H2)
          begin
            assign tx_phy0  = {160'b0, ll_tx_phy0[159:0]};
            assign tx_phy1  = {160'b0, ll_tx_phy1[159:0]};
            assign tx_phy2  = {160'b0, ll_tx_phy2[159:0]};
            assign tx_phy3  = {160'b0, ll_tx_phy3[159:0]};
          end
        else if (X16_F2 || X4_H1)
          begin
            assign tx_phy0  = {240'b0, ll_tx_phy0[79:0]};
            assign tx_phy1  = {240'b0, ll_tx_phy1[79:0]};
            assign tx_phy2  = {240'b0, ll_tx_phy2[79:0]};
            assign tx_phy3  = {240'b0, ll_tx_phy3[79:0]};
          end
        assign tx_phy4  = 320'b0;
        assign tx_phy5  = 320'b0;
        assign tx_phy6  = 320'b0;
        assign tx_phy7  = 320'b0;
        assign tx_phy8  = 320'b0;
        assign tx_phy9  = 320'b0;
        assign tx_phy10 = 320'b0;
        assign tx_phy11 = 320'b0;
        assign tx_phy12 = 320'b0;
        assign tx_phy13 = 320'b0;
        assign tx_phy14 = 320'b0;
        assign tx_phy15 = 320'b0;
      end
    else if (X2_F1)
      begin
        assign tx_phy0  = {280'b0, ll_tx_phy0[39:0]};
        assign tx_phy1  = {280'b0, ll_tx_phy1[39:0]};
        assign tx_phy2  = {280'b0, ll_tx_phy2[39:0]};
        assign tx_phy3  = 320'b0;
        assign tx_phy4  = 320'b0;
        assign tx_phy5  = 320'b0;
        assign tx_phy6  = 320'b0;
        assign tx_phy7  = 320'b0;
        assign tx_phy8  = 320'b0;
        assign tx_phy9  = 320'b0;
        assign tx_phy10 = 320'b0;
        assign tx_phy11 = 320'b0;
        assign tx_phy12 = 320'b0;
        assign tx_phy13 = 320'b0;
        assign tx_phy14 = 320'b0;
        assign tx_phy15 = 320'b0;
      end
    else if (X8_Q2 || X8_H2 || X8_F2 || X4_F2 || X2_H1 || X1_H1 | X1_F1)
      begin
        if (X8_Q2)
          begin
            assign tx_phy0  = ll_tx_phy0[319:0];
            assign tx_phy1  = ll_tx_phy1[319:0];
          end
        else if (X8_H2)
          begin
            assign tx_phy0  = {160'b0, ll_tx_phy0[159:0]};
            assign tx_phy1  = {160'b0, ll_tx_phy1[159:0]};
          end
        else if (X8_F2 || X4_F2 || X2_H1 || X1_H1)
          begin
            assign tx_phy0  = {240'b0, ll_tx_phy0[79:0]};
            assign tx_phy1  = {240'b0, ll_tx_phy1[79:0]};
          end
        else if (X1_F1)
          begin
            assign tx_phy0  = {280'b0, ll_tx_phy0[39:0]};
            assign tx_phy1  = {280'b0, ll_tx_phy1[39:0]};
          end
        assign tx_phy2  = 320'b0;
        assign tx_phy3  = 320'b0;
        assign tx_phy4  = 320'b0;
        assign tx_phy5  = 320'b0;
        assign tx_phy6  = 320'b0;
        assign tx_phy7  = 320'b0;
        assign tx_phy8  = 320'b0;
        assign tx_phy9  = 320'b0;
        assign tx_phy10 = 320'b0;
        assign tx_phy11 = 320'b0;
        assign tx_phy12 = 320'b0;
        assign tx_phy13 = 320'b0;
        assign tx_phy14 = 320'b0;
        assign tx_phy15 = 320'b0;
      end
    else if (X4_Q2 || X4_H2)
      begin
        if (X4_Q2)
          begin
            assign tx_phy0  = ll_tx_phy0[319:0];
          end
        else if (X4_H2)
          begin
            assign tx_phy0  = {160'b0, ll_tx_phy0[159:0]};
          end
        assign tx_phy1  = 320'b0;
        assign tx_phy2  = 320'b0;
        assign tx_phy3  = 320'b0;
        assign tx_phy4  = 320'b0;
        assign tx_phy5  = 320'b0;
        assign tx_phy6  = 320'b0;
        assign tx_phy7  = 320'b0;
        assign tx_phy8  = 320'b0;
        assign tx_phy9  = 320'b0;
        assign tx_phy10 = 320'b0;
        assign tx_phy11 = 320'b0;
        assign tx_phy12 = 320'b0;
        assign tx_phy13 = 320'b0;
        assign tx_phy14 = 320'b0;
        assign tx_phy15 = 320'b0;
      end
  endgenerate

  /*
   lpif_txrx_x16_q2_master_top AUTO_TEMPLATE
   lpif_txrx_x16_h2_master_top AUTO_TEMPLATE
   lpif_txrx_x16_f2_master_top AUTO_TEMPLATE
   lpif_txrx_x8_q2_master_top AUTO_TEMPLATE
   lpif_txrx_x8_h2_master_top AUTO_TEMPLATE
   lpif_txrx_x8_f2_master_top AUTO_TEMPLATE
   lpif_txrx_x4_q2_master_top AUTO_TEMPLATE
   lpif_txrx_x4_h2_master_top AUTO_TEMPLATE
   lpif_txrx_x4_f2_master_top AUTO_TEMPLATE
   lpif_txrx_x16_h1_master_top AUTO_TEMPLATE
   lpif_txrx_x16_f1_master_top AUTO_TEMPLATE
   lpif_txrx_x8_h1_master_top AUTO_TEMPLATE
   lpif_txrx_x8_f1_master_top AUTO_TEMPLATE
   lpif_txrx_x4_h1_master_top AUTO_TEMPLATE
   lpif_txrx_x4_f1_master_top AUTO_TEMPLATE
   lpif_txrx_x2_h1_master_top AUTO_TEMPLATE
   lpif_txrx_x2_f1_master_top AUTO_TEMPLATE
   lpif_txrx_x1_h1_master_top AUTO_TEMPLATE
   lpif_txrx_x1_f1_master_top AUTO_TEMPLATE (
   .clk_wr                 (com_clk),
   .rst_wr_n               (rst_n),
   .init_downstream_credit (8'hff),
   .ustrm_valid            (ustrm_valid),
   .dstrm_valid            (dstrm_valid),
   .tx_phy\([0-9]+\)       (ll_tx_phy\1[]),
   ); */

  genvar                     i;
  generate
    if (X16_Q2) // quarter rate
      begin
        lpif_txrx_x16_q2_master_top
          lpif_txrx_x16_q2_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[319:0]),     // Templated
             .tx_phy1                   (ll_tx_phy1[319:0]),     // Templated
             .tx_phy2                   (ll_tx_phy2[319:0]),     // Templated
             .tx_phy3                   (ll_tx_phy3[319:0]),     // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[1023:0]),
             .ustrm_dvalid              (ustrm_dvalid[1:0]),
             .ustrm_crc                 (ustrm_crc[31:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[1:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[319:0]),
             .rx_phy1                   (rx_phy1[319:0]),
             .rx_phy2                   (rx_phy2[319:0]),
             .rx_phy3                   (rx_phy3[319:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[1023:0]),
             .dstrm_dvalid              (dstrm_dvalid[1:0]),
             .dstrm_crc                 (dstrm_crc[31:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[1:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .tx_mrk_userbit            (tx_mrk_userbit[3:0]),
             .tx_stb_userbit            (tx_stb_userbit),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end // if (X16_Q2)
    else if (X16_H2) // half rate
      begin
        lpif_txrx_x16_h2_master_top
          lpif_txrx_x16_h2_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[159:0]),     // Templated
             .tx_phy1                   (ll_tx_phy1[159:0]),     // Templated
             .tx_phy2                   (ll_tx_phy2[159:0]),     // Templated
             .tx_phy3                   (ll_tx_phy3[159:0]),     // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[511:0]),
             .ustrm_dvalid              (ustrm_dvalid[0:0]),
             .ustrm_crc                 (ustrm_crc[15:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[0:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[159:0]),
             .rx_phy1                   (rx_phy1[159:0]),
             .rx_phy2                   (rx_phy2[159:0]),
             .rx_phy3                   (rx_phy3[159:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[511:0]),
             .dstrm_dvalid              (dstrm_dvalid[0:0]),
             .dstrm_crc                 (dstrm_crc[15:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[0:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .tx_mrk_userbit            (tx_mrk_userbit[1:0]),
             .tx_stb_userbit            (tx_stb_userbit),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end // if (X16_H2)
    else if (X16_F2) // full rate
      begin
        lpif_txrx_x16_f2_master_top
          lpif_txrx_x16_f2_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[79:0]),      // Templated
             .tx_phy1                   (ll_tx_phy1[79:0]),      // Templated
             .tx_phy2                   (ll_tx_phy2[79:0]),      // Templated
             .tx_phy3                   (ll_tx_phy3[79:0]),      // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[255:0]),
             .ustrm_dvalid              (ustrm_dvalid[0:0]),
             .ustrm_crc                 (ustrm_crc[15:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[0:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[79:0]),
             .rx_phy1                   (rx_phy1[79:0]),
             .rx_phy2                   (rx_phy2[79:0]),
             .rx_phy3                   (rx_phy3[79:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[255:0]),
             .dstrm_dvalid              (dstrm_dvalid[0:0]),
             .dstrm_crc                 (dstrm_crc[15:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[0:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .tx_mrk_userbit            (tx_mrk_userbit[0:0]),
             .tx_stb_userbit            (tx_stb_userbit),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end // if (X16_F2)
    else if (X8_Q2) // quarter rate
      begin
        lpif_txrx_x8_q2_master_top
          lpif_txrx_x8_q2_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[319:0]),     // Templated
             .tx_phy1                   (ll_tx_phy1[319:0]),     // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[511:0]),
             .ustrm_dvalid              (ustrm_dvalid[0:0]),
             .ustrm_crc                 (ustrm_crc[15:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[0:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[319:0]),
             .rx_phy1                   (rx_phy1[319:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[511:0]),
             .dstrm_dvalid              (dstrm_dvalid[0:0]),
             .dstrm_crc                 (dstrm_crc[15:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[0:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .tx_mrk_userbit            (tx_mrk_userbit[3:0]),
             .tx_stb_userbit            (tx_stb_userbit),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end
    else if (X8_H2) // half rate
      begin
        lpif_txrx_x8_h2_master_top
          lpif_txrx_x8_h2_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[159:0]),     // Templated
             .tx_phy1                   (ll_tx_phy1[159:0]),     // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[255:0]),
             .ustrm_dvalid              (ustrm_dvalid[0:0]),
             .ustrm_crc                 (ustrm_crc[15:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[0:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[159:0]),
             .rx_phy1                   (rx_phy1[159:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[255:0]),
             .dstrm_dvalid              (dstrm_dvalid[0:0]),
             .dstrm_crc                 (dstrm_crc[15:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[0:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .tx_mrk_userbit            (tx_mrk_userbit[1:0]),
             .tx_stb_userbit            (tx_stb_userbit),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end
    else if (X8_F2) // full rate
      begin
        lpif_txrx_x8_f2_master_top
          lpif_txrx_x8_f2_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[79:0]),      // Templated
             .tx_phy1                   (ll_tx_phy1[79:0]),      // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[127:0]),
             .ustrm_dvalid              (ustrm_dvalid[0:0]),
             .ustrm_crc                 (ustrm_crc[15:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[0:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[79:0]),
             .rx_phy1                   (rx_phy1[79:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[127:0]),
             .dstrm_dvalid              (dstrm_dvalid[0:0]),
             .dstrm_crc                 (dstrm_crc[15:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[0:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .tx_mrk_userbit            (tx_mrk_userbit[0:0]),
             .tx_stb_userbit            (tx_stb_userbit),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end
    else if (X4_Q2) // quarter rate
      begin
        lpif_txrx_x4_q2_master_top
          lpif_txrx_x8_q2_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[319:0]),     // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[255:0]),
             .ustrm_dvalid              (ustrm_dvalid[0:0]),
             .ustrm_crc                 (ustrm_crc[15:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[0:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[319:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[255:0]),
             .dstrm_dvalid              (dstrm_dvalid[0:0]),
             .dstrm_crc                 (dstrm_crc[15:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[0:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .tx_mrk_userbit            (tx_mrk_userbit[3:0]),
             .tx_stb_userbit            (tx_stb_userbit),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end
    else if (X4_H2) // half rate
      begin
        lpif_txrx_x4_h2_master_top
          lpif_txrx_x4_h2_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[159:0]),     // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[127:0]),
             .ustrm_dvalid              (ustrm_dvalid[0:0]),
             .ustrm_crc                 (ustrm_crc[15:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[0:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[159:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[127:0]),
             .dstrm_dvalid              (dstrm_dvalid[0:0]),
             .dstrm_crc                 (dstrm_crc[15:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[0:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .tx_mrk_userbit            (tx_mrk_userbit[1:0]),
             .tx_stb_userbit            (tx_stb_userbit),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end
    else if (X4_F2) // full rate
      begin
        lpif_txrx_x4_f2_master_top
          lpif_txrx_x4_f2_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[79:0]),      // Templated
             .tx_phy1                   (ll_tx_phy1[79:0]),      // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[63:0]),
             .ustrm_dvalid              (ustrm_dvalid[0:0]),
             .ustrm_crc                 (ustrm_crc[15:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[0:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[79:0]),
             .rx_phy1                   (rx_phy1[79:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[63:0]),
             .dstrm_dvalid              (dstrm_dvalid[0:0]),
             .dstrm_crc                 (dstrm_crc[15:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[0:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .tx_mrk_userbit            (tx_mrk_userbit[0:0]),
             .tx_stb_userbit            (tx_stb_userbit),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end
    else if (X16_H1) // half rate
      begin
        lpif_txrx_x16_h1_master_top
          lpif_txrx_x16_h1_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[79:0]),      // Templated
             .tx_phy1                   (ll_tx_phy1[79:0]),      // Templated
             .tx_phy2                   (ll_tx_phy2[79:0]),      // Templated
             .tx_phy3                   (ll_tx_phy3[79:0]),      // Templated
             .tx_phy4                   (ll_tx_phy4[79:0]),      // Templated
             .tx_phy5                   (ll_tx_phy5[79:0]),      // Templated
             .tx_phy6                   (ll_tx_phy6[79:0]),      // Templated
             .tx_phy7                   (ll_tx_phy7[79:0]),      // Templated
             .tx_phy8                   (ll_tx_phy8[79:0]),      // Templated
             .tx_phy9                   (ll_tx_phy9[79:0]),      // Templated
             .tx_phy10                  (ll_tx_phy10[79:0]),     // Templated
             .tx_phy11                  (ll_tx_phy11[79:0]),     // Templated
             .tx_phy12                  (ll_tx_phy12[79:0]),     // Templated
             .tx_phy13                  (ll_tx_phy13[79:0]),     // Templated
             .tx_phy14                  (ll_tx_phy14[79:0]),     // Templated
             .tx_phy15                  (ll_tx_phy15[79:0]),     // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[1023:0]),
             .ustrm_dvalid              (ustrm_dvalid[1:0]),
             .ustrm_crc                 (ustrm_crc[31:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[1:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[79:0]),
             .rx_phy1                   (rx_phy1[79:0]),
             .rx_phy2                   (rx_phy2[79:0]),
             .rx_phy3                   (rx_phy3[79:0]),
             .rx_phy4                   (rx_phy4[79:0]),
             .rx_phy5                   (rx_phy5[79:0]),
             .rx_phy6                   (rx_phy6[79:0]),
             .rx_phy7                   (rx_phy7[79:0]),
             .rx_phy8                   (rx_phy8[79:0]),
             .rx_phy9                   (rx_phy9[79:0]),
             .rx_phy10                  (rx_phy10[79:0]),
             .rx_phy11                  (rx_phy11[79:0]),
             .rx_phy12                  (rx_phy12[79:0]),
             .rx_phy13                  (rx_phy13[79:0]),
             .rx_phy14                  (rx_phy14[79:0]),
             .rx_phy15                  (rx_phy15[79:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[1023:0]),
             .dstrm_dvalid              (dstrm_dvalid[1:0]),
             .dstrm_crc                 (dstrm_crc[31:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[1:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end // if (X16_H1)
    else if (X16_F1) // full rate
      begin
        lpif_txrx_x16_f1_master_top
          lpif_txrx_x16_f1_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[39:0]),      // Templated
             .tx_phy1                   (ll_tx_phy1[39:0]),      // Templated
             .tx_phy2                   (ll_tx_phy2[39:0]),      // Templated
             .tx_phy3                   (ll_tx_phy3[39:0]),      // Templated
             .tx_phy4                   (ll_tx_phy4[39:0]),      // Templated
             .tx_phy5                   (ll_tx_phy5[39:0]),      // Templated
             .tx_phy6                   (ll_tx_phy6[39:0]),      // Templated
             .tx_phy7                   (ll_tx_phy7[39:0]),      // Templated
             .tx_phy8                   (ll_tx_phy8[39:0]),      // Templated
             .tx_phy9                   (ll_tx_phy9[39:0]),      // Templated
             .tx_phy10                  (ll_tx_phy10[39:0]),     // Templated
             .tx_phy11                  (ll_tx_phy11[39:0]),     // Templated
             .tx_phy12                  (ll_tx_phy12[39:0]),     // Templated
             .tx_phy13                  (ll_tx_phy13[39:0]),     // Templated
             .tx_phy14                  (ll_tx_phy14[39:0]),     // Templated
             .tx_phy15                  (ll_tx_phy15[39:0]),     // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[511:0]),
             .ustrm_dvalid              (ustrm_dvalid[0:0]),
             .ustrm_crc                 (ustrm_crc[15:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[0:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[39:0]),
             .rx_phy1                   (rx_phy1[39:0]),
             .rx_phy2                   (rx_phy2[39:0]),
             .rx_phy3                   (rx_phy3[39:0]),
             .rx_phy4                   (rx_phy4[39:0]),
             .rx_phy5                   (rx_phy5[39:0]),
             .rx_phy6                   (rx_phy6[39:0]),
             .rx_phy7                   (rx_phy7[39:0]),
             .rx_phy8                   (rx_phy8[39:0]),
             .rx_phy9                   (rx_phy9[39:0]),
             .rx_phy10                  (rx_phy10[39:0]),
             .rx_phy11                  (rx_phy11[39:0]),
             .rx_phy12                  (rx_phy12[39:0]),
             .rx_phy13                  (rx_phy13[39:0]),
             .rx_phy14                  (rx_phy14[39:0]),
             .rx_phy15                  (rx_phy15[39:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[511:0]),
             .dstrm_dvalid              (dstrm_dvalid[0:0]),
             .dstrm_crc                 (dstrm_crc[15:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[0:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end // if (X16_F1)
    else if (X8_H1) // half rate
      begin
        lpif_txrx_x8_h1_master_top
          lpif_txrx_x8_h1_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[79:0]),      // Templated
             .tx_phy1                   (ll_tx_phy1[79:0]),      // Templated
             .tx_phy2                   (ll_tx_phy2[79:0]),      // Templated
             .tx_phy3                   (ll_tx_phy3[79:0]),      // Templated
             .tx_phy4                   (ll_tx_phy4[79:0]),      // Templated
             .tx_phy5                   (ll_tx_phy5[79:0]),      // Templated
             .tx_phy6                   (ll_tx_phy6[79:0]),      // Templated
             .tx_phy7                   (ll_tx_phy7[79:0]),      // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[511:0]),
             .ustrm_dvalid              (ustrm_dvalid[0:0]),
             .ustrm_crc                 (ustrm_crc[15:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[0:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[79:0]),
             .rx_phy1                   (rx_phy1[79:0]),
             .rx_phy2                   (rx_phy2[79:0]),
             .rx_phy3                   (rx_phy3[79:0]),
             .rx_phy4                   (rx_phy4[79:0]),
             .rx_phy5                   (rx_phy5[79:0]),
             .rx_phy6                   (rx_phy6[79:0]),
             .rx_phy7                   (rx_phy7[79:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[511:0]),
             .dstrm_dvalid              (dstrm_dvalid[0:0]),
             .dstrm_crc                 (dstrm_crc[15:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[0:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end // if (X8_H1)
    else if (X8_F1) // full rate
      begin
        lpif_txrx_x8_f1_master_top
          lpif_txrx_x8_f1_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[79:0]),      // Templated
             .tx_phy1                   (ll_tx_phy1[79:0]),      // Templated
             .tx_phy2                   (ll_tx_phy2[79:0]),      // Templated
             .tx_phy3                   (ll_tx_phy3[79:0]),      // Templated
             .tx_phy4                   (ll_tx_phy4[79:0]),      // Templated
             .tx_phy5                   (ll_tx_phy5[79:0]),      // Templated
             .tx_phy6                   (ll_tx_phy6[79:0]),      // Templated
             .tx_phy7                   (ll_tx_phy7[79:0]),      // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[255:0]),
             .ustrm_dvalid              (ustrm_dvalid[0:0]),
             .ustrm_crc                 (ustrm_crc[15:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[0:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[79:0]),
             .rx_phy1                   (rx_phy1[79:0]),
             .rx_phy2                   (rx_phy2[79:0]),
             .rx_phy3                   (rx_phy3[79:0]),
             .rx_phy4                   (rx_phy4[79:0]),
             .rx_phy5                   (rx_phy5[79:0]),
             .rx_phy6                   (rx_phy6[79:0]),
             .rx_phy7                   (rx_phy7[79:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[255:0]),
             .dstrm_dvalid              (dstrm_dvalid[0:0]),
             .dstrm_crc                 (dstrm_crc[15:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[0:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end // if (X8_F1)
    else if (X4_H1) // half rate
      begin
        lpif_txrx_x4_h1_master_top
          lpif_txrx_x4_h1_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[79:0]),      // Templated
             .tx_phy1                   (ll_tx_phy1[79:0]),      // Templated
             .tx_phy2                   (ll_tx_phy2[79:0]),      // Templated
             .tx_phy3                   (ll_tx_phy3[79:0]),      // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[255:0]),
             .ustrm_dvalid              (ustrm_dvalid[0:0]),
             .ustrm_crc                 (ustrm_crc[15:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[0:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[79:0]),
             .rx_phy1                   (rx_phy1[79:0]),
             .rx_phy2                   (rx_phy2[79:0]),
             .rx_phy3                   (rx_phy3[79:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[255:0]),
             .dstrm_dvalid              (dstrm_dvalid[0:0]),
             .dstrm_crc                 (dstrm_crc[15:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[0:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end // if (X4_H1)
    else if (X4_F1) // full rate
      begin
        lpif_txrx_x4_f1_master_top
          lpif_txrx_x4_f1_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[39:0]),      // Templated
             .tx_phy1                   (ll_tx_phy1[39:0]),      // Templated
             .tx_phy2                   (ll_tx_phy2[39:0]),      // Templated
             .tx_phy3                   (ll_tx_phy3[39:0]),      // Templated
             .tx_phy4                   (ll_tx_phy4[39:0]),      // Templated
             .tx_phy5                   (ll_tx_phy5[39:0]),      // Templated
             .tx_phy6                   (ll_tx_phy6[39:0]),      // Templated
             .tx_phy7                   (ll_tx_phy7[39:0]),      // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[127:0]),
             .ustrm_dvalid              (ustrm_dvalid[0:0]),
             .ustrm_crc                 (ustrm_crc[15:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[0:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[39:0]),
             .rx_phy1                   (rx_phy1[39:0]),
             .rx_phy2                   (rx_phy2[39:0]),
             .rx_phy3                   (rx_phy3[39:0]),
             .rx_phy4                   (rx_phy4[39:0]),
             .rx_phy5                   (rx_phy5[39:0]),
             .rx_phy6                   (rx_phy6[39:0]),
             .rx_phy7                   (rx_phy7[39:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[127:0]),
             .dstrm_dvalid              (dstrm_dvalid[0:0]),
             .dstrm_crc                 (dstrm_crc[15:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[0:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end // if (X4_F1)
    else if (X2_H1) // half rate
      begin
        lpif_txrx_x2_h1_master_top
          lpif_txrx_x2_h1_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[79:0]),      // Templated
             .tx_phy1                   (ll_tx_phy1[79:0]),      // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[127:0]),
             .ustrm_dvalid              (ustrm_dvalid[0:0]),
             .ustrm_crc                 (ustrm_crc[15:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[0:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[79:0]),
             .rx_phy1                   (rx_phy1[79:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[127:0]),
             .dstrm_dvalid              (dstrm_dvalid[0:0]),
             .dstrm_crc                 (dstrm_crc[15:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[0:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end
    else if (X2_F1) // full rate
      begin
        lpif_txrx_x2_f1_master_top
          lpif_txrx_x2_f1_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[39:0]),      // Templated
             .tx_phy1                   (ll_tx_phy1[39:0]),      // Templated
             .tx_phy2                   (ll_tx_phy2[39:0]),      // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[63:0]),
             .ustrm_dvalid              (ustrm_dvalid[0:0]),
             .ustrm_crc                 (ustrm_crc[15:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[0:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[39:0]),
             .rx_phy1                   (rx_phy1[39:0]),
             .rx_phy2                   (rx_phy2[39:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[63:0]),
             .dstrm_dvalid              (dstrm_dvalid[0:0]),
             .dstrm_crc                 (dstrm_crc[15:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[0:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end
    else if (X1_H1) // half rate
      begin
        lpif_txrx_x1_h1_master_top
          lpif_txrx_x1_h1_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[79:0]),      // Templated
             .tx_phy1                   (ll_tx_phy1[79:0]),      // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[63:0]),
             .ustrm_dvalid              (ustrm_dvalid[0:0]),
             .ustrm_crc                 (ustrm_crc[15:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[0:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[79:0]),
             .rx_phy1                   (rx_phy1[79:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[63:0]),
             .dstrm_dvalid              (dstrm_dvalid[0:0]),
             .dstrm_crc                 (dstrm_crc[15:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[0:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end
    else if (X1_F1) // full rate
      begin
        lpif_txrx_x1_f1_master_top
          lpif_txrx_x1_f1_master_top_i
            (/*AUTOINST*/
             // Outputs
             .tx_phy0                   (ll_tx_phy0[39:0]),      // Templated
             .tx_phy1                   (ll_tx_phy1[39:0]),      // Templated
             .ustrm_state               (ustrm_state[3:0]),
             .ustrm_protid              (ustrm_protid[1:0]),
             .ustrm_data                (ustrm_data[31:0]),
             .ustrm_dvalid              (ustrm_dvalid[0:0]),
             .ustrm_crc                 (ustrm_crc[15:0]),
             .ustrm_crc_valid           (ustrm_crc_valid[0:0]),
             .ustrm_valid               (ustrm_valid),           // Templated
             .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
             .rx_upstream_debug_status  (rx_upstream_debug_status[31:0]),
             // Inputs
             .clk_wr                    (com_clk),               // Templated
             .rst_wr_n                  (rst_n),                 // Templated
             .tx_online                 (tx_online),
             .rx_online                 (rx_online),
             .init_downstream_credit    (8'hff),                 // Templated
             .rx_phy0                   (rx_phy0[39:0]),
             .rx_phy1                   (rx_phy1[39:0]),
             .dstrm_state               (dstrm_state[3:0]),
             .dstrm_protid              (dstrm_protid[1:0]),
             .dstrm_data                (dstrm_data[31:0]),
             .dstrm_dvalid              (dstrm_dvalid[0:0]),
             .dstrm_crc                 (dstrm_crc[15:0]),
             .dstrm_crc_valid           (dstrm_crc_valid[0:0]),
             .dstrm_valid               (dstrm_valid),           // Templated
             .m_gen2_mode               (m_gen2_mode),
             .delay_x_value             (delay_x_value[7:0]),
             .delay_xz_value            (delay_xz_value[7:0]),
             .delay_yz_value            (delay_yz_value[7:0]));
      end
  endgenerate

  localparam STB_INTERVAL = 8'h8;
  localparam STB_DELAY = 8'h14;

  localparam FULL = 4'h1;
  localparam HALF = 4'h2;
  localparam QUARTER = 4'h4;

  wire local_rate_f = x16_f2 | x16_f1;
  wire local_rate_h = x16_h2 | x16_h1;
  wire local_rate_q = x16_q2;

  // symmetric for now
  wire remote_rate_f = local_rate_f;
  wire remote_rate_h = local_rate_h;
  wire remote_rate_q = local_rate_q;

  logic [3:0] local_rate, remote_rate;

  always_comb
    begin
      case ({local_rate_f, local_rate_h, local_rate_q})
        3'b100: local_rate = FULL;
        3'b010: local_rate = HALF;
        3'b001: local_rate = QUARTER;
        default: local_rate = FULL;
      endcase // case ({local_rate_f, local_rate_h, local_rate_q})
      case ({remote_rate_f, remote_rate_h, remote_rate_q})
        3'b100: remote_rate = FULL;
        3'b010: remote_rate = HALF;
        3'b001: remote_rate = QUARTER;
        default: remote_rate = FULL;
      endcase // case ({remote_rate_f, remote_rate_h, remote_rate_q})
    end

  /* strobe_gen_w_delay AUTO_TEMPLATE (
   .clk         (com_clk),
   .rst_n       (rst_n),
   .user_strobe (tx_stb_userbit),
   .interval    (STB_INTERVAL),
   .delay_value (STB_DELAY),
   .user_marker (|tx_mrk_userbit[]),
   .online      (tx_online),
   ); */

  strobe_gen_w_delay
    strobe_gen_w_delay_i
      (/*AUTOINST*/
       // Outputs
       .user_strobe                     (tx_stb_userbit),        // Templated
       // Inputs
       .clk                             (com_clk),               // Templated
       .rst_n                           (rst_n),                 // Templated
       .interval                        (STB_INTERVAL),          // Templated
       .delay_value                     (STB_DELAY),             // Templated
       .user_marker                     (|tx_mrk_userbit),       // Templated
       .online                          (tx_online));             // Templated

  /* marker_gen AUTO_TEMPLATE (
   .clk         (com_clk),
   .rst_n       (rst_n),
   .user_marker (tx_mrk_userbit[]),
   ); */

  marker_gen
    marker_gen_i
      (/*AUTOINST*/
       // Outputs
       .user_marker                     (tx_mrk_userbit[3:0]),   // Templated
       // Inputs
       .clk                             (com_clk),               // Templated
       .rst_n                           (rst_n),                 // Templated
       .local_rate                      (local_rate[3:0]),
       .remote_rate                     (remote_rate[3:0]));

endmodule // lpif_txrx

// Local Variables:
// verilog-library-directories:("." "./lpif_txrx" "${PROJ_DIR}/common/rtl" "${PROJ_DIR}/common/dv")
// verilog-auto-inst-param-value:t
// End:
