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
   input logic                         com_clk,
   input logic                         rst_n,

   input logic                         tx_online,
   input logic                         rx_online,
   input logic                         m_gen2_mode,

   input logic [7:0]                   delay_x_value,
   input logic [7:0]                   delay_xz_value,
   input logic [7:0]                   delay_yz_value,

   input logic [319:0]                 rx_phy0,
   input logic [319:0]                 rx_phy1,
   input logic [319:0]                 rx_phy2,
   input logic [319:0]                 rx_phy3,
   input logic [319:0]                 rx_phy4,
   input logic [319:0]                 rx_phy5,
   input logic [319:0]                 rx_phy6,
   input logic [319:0]                 rx_phy7,
   input logic [319:0]                 rx_phy8,
   input logic [319:0]                 rx_phy9,
   input logic [319:0]                 rx_phy10,
   input logic [319:0]                 rx_phy11,
   input logic [319:0]                 rx_phy12,
   input logic [319:0]                 rx_phy13,
   input logic [319:0]                 rx_phy14,
   input logic [319:0]                 rx_phy15,

   input logic [3:0]                   dstrm_state,
   input logic [1:0]                   dstrm_protid,
   input logic [1023:0]                dstrm_data,
   input logic [LPIF_VALID_WIDTH-1:0]  dstrm_dvalid,
   input logic [LPIF_CRC_WIDTH-1:0]    dstrm_crc,
   input logic [LPIF_VALID_WIDTH-1:0]  dstrm_crc_valid,
   input logic                         dstrm_valid,

   output logic [319:0]                tx_phy0,
   output logic [319:0]                tx_phy1,
   output logic [319:0]                tx_phy2,
   output logic [319:0]                tx_phy3,
   output logic [319:0]                tx_phy4,
   output logic [319:0]                tx_phy5,
   output logic [319:0]                tx_phy6,
   output logic [319:0]                tx_phy7,
   output logic [319:0]                tx_phy8,
   output logic [319:0]                tx_phy9,
   output logic [319:0]                tx_phy10,
   output logic [319:0]                tx_phy11,
   output logic [319:0]                tx_phy12,
   output logic [319:0]                tx_phy13,
   output logic [319:0]                tx_phy14,
   output logic [319:0]                tx_phy15,

   output logic [3:0]                  ustrm_state,
   output logic [1:0]                  ustrm_protid,
   output logic [1023:0]               ustrm_data,
   output logic [LPIF_VALID_WIDTH-1:0] ustrm_dvalid,
   output logic [LPIF_CRC_WIDTH-1:0]   ustrm_crc,
   output logic [LPIF_VALID_WIDTH-1:0] ustrm_crc_valid,
   output logic                        ustrm_valid,

   input [3:0]                         tx_mrk_userbit,
   input                               tx_stb_userbit,

   output logic [31:0]                 rx_upstream_debug_status,
   output logic [31:0]                 tx_downstream_debug_status
   );

  /*AUTOWIRE*/

  // FIX THIS
  logic [6:0]                         ustrm_bstart;
  logic [127:0]                       ustrm_bvalid;
  logic [6:0]                         dstrm_bstart;
  logic [127:0]                       dstrm_bvalid;
  //  assign ustrm_bstart = 7'b0;
  //  assign ustrm_bvalid = 128'b0;
  assign ustrm_bstart = 7'b0;
  assign ustrm_bvalid = 128'b0;

  /* TX & RX datapath */

  /* lpif_txrx_x16_q2_master_top AUTO_TEMPLATE (
   .clk_wr                 (com_clk),
   .rst_wr_n               (rst_n),
   .init_downstream_credit (8'hff),
   .ustrm_valid            (ustrm_valid),
   .dstrm_valid            (dstrm_valid),
   ); */

  /* lpif_txrx_x16_h2_master_top AUTO_TEMPLATE (
   .clk_wr                 (com_clk),
   .rst_wr_n               (rst_n),
   .init_downstream_credit (8'hff),
   .ustrm_valid            (ustrm_valid),
   .dstrm_valid            (dstrm_valid),
   ); */

  /* lpif_txrx_x16_f2_master_top AUTO_TEMPLATE (
   .clk_wr                 (com_clk),
   .rst_wr_n               (rst_n),
   .init_downstream_credit (8'hff),
   .ustrm_valid            (ustrm_valid),
   .dstrm_valid            (dstrm_valid),
   ); */

  /* lpif_txrx_x16_h1_master_top AUTO_TEMPLATE (
   .clk_wr                 (com_clk),
   .rst_wr_n               (rst_n),
   .init_downstream_credit (8'hff),
   .ustrm_valid            (ustrm_valid),
   .dstrm_valid            (dstrm_valid),
   ); */

  /* lpif_txrx_x16_f1_master_top AUTO_TEMPLATE (
   .clk_wr                 (com_clk),
   .rst_wr_n               (rst_n),
   .init_downstream_credit (8'hff),
   .ustrm_valid            (ustrm_valid),
   .dstrm_valid            (dstrm_valid),
   ); */

  genvar                              i;
  generate
    if ((AIB_VERSION == 2) && (AIB_GENERATION == 2))
      begin
        if (LPIF_CLOCK_RATE == 500) // quarter rate
          begin
            lpif_txrx_x16_q2_master_top
              #(/*AUTOINSTPARAM*/)
            lpif_txrx_x16_q2_master_top_i
              (/*AUTOINST*/
               // Outputs
               .tx_phy0                 (tx_phy0[319:0]),
               .tx_phy1                 (tx_phy1[319:0]),
               .tx_phy2                 (tx_phy2[319:0]),
               .tx_phy3                 (tx_phy3[319:0]),
               .ustrm_state             (ustrm_state[3:0]),
               .ustrm_protid            (ustrm_protid[1:0]),
               .ustrm_data              (ustrm_data[1023:0]),
               .ustrm_dvalid            (ustrm_dvalid[1:0]),
               .ustrm_crc               (ustrm_crc[31:0]),
               .ustrm_crc_valid         (ustrm_crc_valid[1:0]),
               .ustrm_valid             (ustrm_valid),           // Templated
               .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
               .rx_upstream_debug_status(rx_upstream_debug_status[31:0]),
               // Inputs
               .clk_wr                  (com_clk),               // Templated
               .rst_wr_n                (rst_n),                 // Templated
               .tx_online               (tx_online),
               .rx_online               (rx_online),
               .init_downstream_credit  (8'hff),                 // Templated
               .rx_phy0                 (rx_phy0[319:0]),
               .rx_phy1                 (rx_phy1[319:0]),
               .rx_phy2                 (rx_phy2[319:0]),
               .rx_phy3                 (rx_phy3[319:0]),
               .dstrm_state             (dstrm_state[3:0]),
               .dstrm_protid            (dstrm_protid[1:0]),
               .dstrm_data              (dstrm_data[1023:0]),
               .dstrm_dvalid            (dstrm_dvalid[1:0]),
               .dstrm_crc               (dstrm_crc[31:0]),
               .dstrm_crc_valid         (dstrm_crc_valid[1:0]),
               .dstrm_valid             (dstrm_valid),           // Templated
               .m_gen2_mode             (m_gen2_mode),
               .tx_mrk_userbit          (tx_mrk_userbit[3:0]),
               .tx_stb_userbit          (tx_stb_userbit),
               .delay_x_value           (delay_x_value[7:0]),
               .delay_xz_value          (delay_xz_value[7:0]),
               .delay_yz_value          (delay_yz_value[7:0]));
          end // if (LPIF_CLOCK_RATE == 500)
        else if (LPIF_CLOCK_RATE == 1000) // half rate
          begin
            lpif_txrx_x16_h2_master_top
              #(/*AUTOINSTPARAM*/)
            lpif_txrx_x16_h2_master_top_i
              (/*AUTOINST*/
               // Outputs
               .tx_phy0                 (tx_phy0[159:0]),
               .tx_phy1                 (tx_phy1[159:0]),
               .tx_phy2                 (tx_phy2[159:0]),
               .tx_phy3                 (tx_phy3[159:0]),
               .ustrm_state             (ustrm_state[3:0]),
               .ustrm_protid            (ustrm_protid[1:0]),
               .ustrm_data              (ustrm_data[511:0]),
               .ustrm_dvalid            (ustrm_dvalid[0:0]),
               .ustrm_crc               (ustrm_crc[15:0]),
               .ustrm_crc_valid         (ustrm_crc_valid[0:0]),
               .ustrm_valid             (ustrm_valid),           // Templated
               .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
               .rx_upstream_debug_status(rx_upstream_debug_status[31:0]),
               // Inputs
               .clk_wr                  (com_clk),               // Templated
               .rst_wr_n                (rst_n),                 // Templated
               .tx_online               (tx_online),
               .rx_online               (rx_online),
               .init_downstream_credit  (8'hff),                 // Templated
               .rx_phy0                 (rx_phy0[159:0]),
               .rx_phy1                 (rx_phy1[159:0]),
               .rx_phy2                 (rx_phy2[159:0]),
               .rx_phy3                 (rx_phy3[159:0]),
               .dstrm_state             (dstrm_state[3:0]),
               .dstrm_protid            (dstrm_protid[1:0]),
               .dstrm_data              (dstrm_data[511:0]),
               .dstrm_dvalid            (dstrm_dvalid[0:0]),
               .dstrm_crc               (dstrm_crc[15:0]),
               .dstrm_crc_valid         (dstrm_crc_valid[0:0]),
               .dstrm_valid             (dstrm_valid),           // Templated
               .m_gen2_mode             (m_gen2_mode),
               .tx_mrk_userbit          (tx_mrk_userbit[1:0]),
               .tx_stb_userbit          (tx_stb_userbit),
               .delay_x_value           (delay_x_value[7:0]),
               .delay_xz_value          (delay_xz_value[7:0]),
               .delay_yz_value          (delay_yz_value[7:0]));
          end // if (LPIF_CLOCK_RATE == 1000)
        else if (LPIF_CLOCK_RATE == 2000) // full rate
          begin
            lpif_txrx_x16_f2_master_top
              #(/*AUTOINSTPARAM*/)
            lpif_txrx_x16_f2_master_top_i
              (/*AUTOINST*/
               // Outputs
               .tx_phy0                 (tx_phy0[79:0]),
               .tx_phy1                 (tx_phy1[79:0]),
               .tx_phy2                 (tx_phy2[79:0]),
               .tx_phy3                 (tx_phy3[79:0]),
               .ustrm_state             (ustrm_state[3:0]),
               .ustrm_protid            (ustrm_protid[1:0]),
               .ustrm_data              (ustrm_data[255:0]),
               .ustrm_dvalid            (ustrm_dvalid[0:0]),
               .ustrm_crc               (ustrm_crc[15:0]),
               .ustrm_crc_valid         (ustrm_crc_valid[0:0]),
               .ustrm_valid             (ustrm_valid),           // Templated
               .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
               .rx_upstream_debug_status(rx_upstream_debug_status[31:0]),
               // Inputs
               .clk_wr                  (com_clk),               // Templated
               .rst_wr_n                (rst_n),                 // Templated
               .tx_online               (tx_online),
               .rx_online               (rx_online),
               .init_downstream_credit  (8'hff),                 // Templated
               .rx_phy0                 (rx_phy0[79:0]),
               .rx_phy1                 (rx_phy1[79:0]),
               .rx_phy2                 (rx_phy2[79:0]),
               .rx_phy3                 (rx_phy3[79:0]),
               .dstrm_state             (dstrm_state[3:0]),
               .dstrm_protid            (dstrm_protid[1:0]),
               .dstrm_data              (dstrm_data[255:0]),
               .dstrm_dvalid            (dstrm_dvalid[0:0]),
               .dstrm_crc               (dstrm_crc[15:0]),
               .dstrm_crc_valid         (dstrm_crc_valid[0:0]),
               .dstrm_valid             (dstrm_valid),           // Templated
               .m_gen2_mode             (m_gen2_mode),
               .tx_mrk_userbit          (tx_mrk_userbit[0:0]),
               .tx_stb_userbit          (tx_stb_userbit),
               .delay_x_value           (delay_x_value[7:0]),
               .delay_xz_value          (delay_xz_value[7:0]),
               .delay_yz_value          (delay_yz_value[7:0]));
          end // if (LPIF_CLOCK_RATE == 2000)
      end // if ((AIB_VERSION == 2) && (AIB_GENERATION == 2))
    else if ((AIB_VERSION == 2) && (AIB_GENERATION == 1))
      begin
        if (LPIF_CLOCK_RATE == 500) // quarter rate
          begin
            lpif_txrx_x16_h1_master_top
              #(/*AUTOINSTPARAM*/)
            lpif_txrx_x16_h1_master_top_i
              (/*AUTOINST*/
               // Outputs
               .tx_phy0                 (tx_phy0[79:0]),
               .tx_phy1                 (tx_phy1[79:0]),
               .tx_phy2                 (tx_phy2[79:0]),
               .tx_phy3                 (tx_phy3[79:0]),
               .tx_phy4                 (tx_phy4[79:0]),
               .tx_phy5                 (tx_phy5[79:0]),
               .tx_phy6                 (tx_phy6[79:0]),
               .tx_phy7                 (tx_phy7[79:0]),
               .tx_phy8                 (tx_phy8[79:0]),
               .tx_phy9                 (tx_phy9[79:0]),
               .tx_phy10                (tx_phy10[79:0]),
               .tx_phy11                (tx_phy11[79:0]),
               .tx_phy12                (tx_phy12[79:0]),
               .tx_phy13                (tx_phy13[79:0]),
               .tx_phy14                (tx_phy14[79:0]),
               .tx_phy15                (tx_phy15[79:0]),
               .ustrm_state             (ustrm_state[3:0]),
               .ustrm_protid            (ustrm_protid[1:0]),
               .ustrm_data              (ustrm_data[1023:0]),
               .ustrm_bstart            (ustrm_bstart[6:0]),
               .ustrm_bvalid            (ustrm_bvalid[127:0]),
               .ustrm_valid             (ustrm_valid),           // Templated
               .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
               .rx_upstream_debug_status(rx_upstream_debug_status[31:0]),
               // Inputs
               .clk_wr                  (com_clk),               // Templated
               .rst_wr_n                (rst_n),                 // Templated
               .tx_online               (tx_online),
               .rx_online               (rx_online),
               .init_downstream_credit  (8'hff),                 // Templated
               .rx_phy0                 (rx_phy0[79:0]),
               .rx_phy1                 (rx_phy1[79:0]),
               .rx_phy2                 (rx_phy2[79:0]),
               .rx_phy3                 (rx_phy3[79:0]),
               .rx_phy4                 (rx_phy4[79:0]),
               .rx_phy5                 (rx_phy5[79:0]),
               .rx_phy6                 (rx_phy6[79:0]),
               .rx_phy7                 (rx_phy7[79:0]),
               .rx_phy8                 (rx_phy8[79:0]),
               .rx_phy9                 (rx_phy9[79:0]),
               .rx_phy10                (rx_phy10[79:0]),
               .rx_phy11                (rx_phy11[79:0]),
               .rx_phy12                (rx_phy12[79:0]),
               .rx_phy13                (rx_phy13[79:0]),
               .rx_phy14                (rx_phy14[79:0]),
               .rx_phy15                (rx_phy15[79:0]),
               .dstrm_state             (dstrm_state[3:0]),
               .dstrm_protid            (dstrm_protid[1:0]),
               .dstrm_data              (dstrm_data[1023:0]),
               .dstrm_bstart            (dstrm_bstart[6:0]),
               .dstrm_bvalid            (dstrm_bvalid[127:0]),
               .dstrm_valid             (dstrm_valid),           // Templated
               .m_gen2_mode             (m_gen2_mode),
               .delay_x_value           (delay_x_value[7:0]),
               .delay_xz_value          (delay_xz_value[7:0]),
               .delay_yz_value          (delay_yz_value[7:0]));
          end // if (LPIF_CLOCK_RATE == 500)
        else if (LPIF_CLOCK_RATE == 1000) // half rate
          begin
            lpif_txrx_x16_f1_master_top
              #(/*AUTOINSTPARAM*/)
            lpif_txrx_x16_f1_master_top_i
              (/*AUTOINST*/
               // Outputs
               .tx_phy0                 (tx_phy0[39:0]),
               .tx_phy1                 (tx_phy1[39:0]),
               .tx_phy2                 (tx_phy2[39:0]),
               .tx_phy3                 (tx_phy3[39:0]),
               .tx_phy4                 (tx_phy4[39:0]),
               .tx_phy5                 (tx_phy5[39:0]),
               .tx_phy6                 (tx_phy6[39:0]),
               .tx_phy7                 (tx_phy7[39:0]),
               .tx_phy8                 (tx_phy8[39:0]),
               .tx_phy9                 (tx_phy9[39:0]),
               .tx_phy10                (tx_phy10[39:0]),
               .tx_phy11                (tx_phy11[39:0]),
               .tx_phy12                (tx_phy12[39:0]),
               .tx_phy13                (tx_phy13[39:0]),
               .tx_phy14                (tx_phy14[39:0]),
               .tx_phy15                (tx_phy15[39:0]),
               .ustrm_state             (ustrm_state[3:0]),
               .ustrm_protid            (ustrm_protid[1:0]),
               .ustrm_data              (ustrm_data[511:0]),
               .ustrm_bstart            (ustrm_bstart[5:0]),
               .ustrm_bvalid            (ustrm_bvalid[63:0]),
               .ustrm_valid             (ustrm_valid),           // Templated
               .tx_downstream_debug_status(tx_downstream_debug_status[31:0]),
               .rx_upstream_debug_status(rx_upstream_debug_status[31:0]),
               // Inputs
               .clk_wr                  (com_clk),               // Templated
               .rst_wr_n                (rst_n),                 // Templated
               .tx_online               (tx_online),
               .rx_online               (rx_online),
               .init_downstream_credit  (8'hff),                 // Templated
               .rx_phy0                 (rx_phy0[39:0]),
               .rx_phy1                 (rx_phy1[39:0]),
               .rx_phy2                 (rx_phy2[39:0]),
               .rx_phy3                 (rx_phy3[39:0]),
               .rx_phy4                 (rx_phy4[39:0]),
               .rx_phy5                 (rx_phy5[39:0]),
               .rx_phy6                 (rx_phy6[39:0]),
               .rx_phy7                 (rx_phy7[39:0]),
               .rx_phy8                 (rx_phy8[39:0]),
               .rx_phy9                 (rx_phy9[39:0]),
               .rx_phy10                (rx_phy10[39:0]),
               .rx_phy11                (rx_phy11[39:0]),
               .rx_phy12                (rx_phy12[39:0]),
               .rx_phy13                (rx_phy13[39:0]),
               .rx_phy14                (rx_phy14[39:0]),
               .rx_phy15                (rx_phy15[39:0]),
               .dstrm_state             (dstrm_state[3:0]),
               .dstrm_protid            (dstrm_protid[1:0]),
               .dstrm_data              (dstrm_data[511:0]),
               .dstrm_bstart            (dstrm_bstart[5:0]),
               .dstrm_bvalid            (dstrm_bvalid[63:0]),
               .dstrm_valid             (dstrm_valid),           // Templated
               .m_gen2_mode             (m_gen2_mode),
               .delay_x_value           (delay_x_value[7:0]),
               .delay_xz_value          (delay_xz_value[7:0]),
               .delay_yz_value          (delay_yz_value[7:0]));
          end // if (LPIF_CLOCK_RATE == 1000)
      end // if ((AIB_VERSION == 2) && (AIB_GENERATION == 1))
  endgenerate

endmodule // lpif_txrx

// Local Variables:
// verilog-library-directories:("." "./lpif_txrx" "${PROJ_DIR}/common/rtl")
// verilog-auto-inst-param-value:t
// End:
