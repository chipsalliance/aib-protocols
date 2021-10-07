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
// Functional Descript: Channel Alignment IP
//
//
//
////////////////////////////////////////////////////////////

module ca
  #(
    parameter NUM_CHANNELS = 2,
    parameter BITS_PER_CHANNEL = 80,
    parameter AD_WIDTH = 4,
    parameter SYNC_FIFO = 1
    )
  (
   input logic [NUM_CHANNELS-1:0]                   lane_clk,
   input logic                                      com_clk,
   input logic                                      rst_n,

   input logic                                      tx_online,
   input logic                                      rx_online,
   input logic                                      tx_stb_en,
   input logic                                      tx_stb_rcvr,
   input logic                                      align_fly,
   input logic [2:0]                                rden_dly,
   input logic [7:0]                                count_x,
   input logic [7:0]                                count_xz,

   input logic [7:0]                                tx_stb_wd_sel,
   input logic [39:0]                               tx_stb_bit_sel,
   input logic [7:0]                                tx_stb_intv,

   input logic [7:0]                                rx_stb_wd_sel,
   input logic [39:0]                               rx_stb_bit_sel,
   input logic [7:0]                                rx_stb_intv,

   input logic [NUM_CHANNELS*BITS_PER_CHANNEL-1:0]  tx_din,
   output logic [NUM_CHANNELS*BITS_PER_CHANNEL-1:0] tx_dout,

   input logic [NUM_CHANNELS*BITS_PER_CHANNEL-1:0]  rx_din,
   output logic [NUM_CHANNELS*BITS_PER_CHANNEL-1:0] rx_dout,

   output logic                                     align_done,
   output logic                                     align_err,
   output logic                                     tx_stb_pos_err,
   output logic                                     tx_stb_pos_coding_err,
   output logic                                     rx_stb_pos_err,
   output logic                                     rx_stb_pos_coding_err,

   input logic [5:0]                                fifo_full_val,
   input logic [5:0]                                fifo_pfull_val,
   input logic [2:0]                                fifo_empty_val,
   input logic [2:0]                                fifo_pempty_val,

   output logic [NUM_CHANNELS-1:0]                  fifo_full,
   output logic [NUM_CHANNELS-1:0]                  fifo_pfull,
   output logic [NUM_CHANNELS-1:0]                  fifo_empty,
   output logic [NUM_CHANNELS-1:0]                  fifo_pempty
   );

  logic [NUM_CHANNELS*BITS_PER_CHANNEL-1:0]         tx_dout_o;

  always_ff @(posedge com_clk or negedge rst_n)
    if (~rst_n)
      tx_dout <= {NUM_CHANNELS*BITS_PER_CHANNEL{1'b0}};
    else
      tx_dout <= tx_dout_o;

    /* ca_tx_strb AUTO_TEMPLATE (
     .tx_dout    (tx_dout_o[]),
     ); */

    /* TX alignment strobe generator */

    ca_tx_strb
      #(/*AUTOINSTPARAM*/
        // Parameters
        .NUM_CHANNELS                   (NUM_CHANNELS),
        .BITS_PER_CHANNEL               (BITS_PER_CHANNEL))
    ca_tx_strb_i
      (/*AUTOINST*/
       // Outputs
       .tx_dout                         (tx_dout_o[NUM_CHANNELS*BITS_PER_CHANNEL-1:0]), // Templated
       .tx_stb_pos_err                  (tx_stb_pos_err),
       .tx_stb_pos_coding_err           (tx_stb_pos_coding_err),
       // Inputs
       .com_clk                         (com_clk),
       .rst_n                           (rst_n),
       .tx_online                       (tx_online),
       .tx_stb_en                       (tx_stb_en),
       .tx_stb_rcvr                     (tx_stb_rcvr),
       .count_xz                        (count_xz[7:0]),
       .tx_stb_wd_sel                   (tx_stb_wd_sel[7:0]),
       .tx_stb_bit_sel                  (tx_stb_bit_sel[39:0]),
       .tx_stb_intv                     (tx_stb_intv[7:0]),
       .tx_din                          (tx_din[NUM_CHANNELS*BITS_PER_CHANNEL-1:0]));

    logic                    rst_com_n;
    logic [NUM_CHANNELS-1:0] rst_lane_n;
    assign rst_com_n = rst_n;

    /* sync reset to lane clock domains */

    /* rst_regen_low AUTO_TEMPLATE (
     .rst_n (rst_lane_n[i]),
     .clk   (lane_clk[i]),
     .async_rst_n (rst_n),
     ); */

    genvar i;
    generate
      for (i = 0; i < NUM_CHANNELS; i++)
        begin : rst_syncs
          rst_regen_low
               #(/*AUTOINSTPARAM*/)
          rst_regen_low_i
               (/*AUTOINST*/
                // Outputs
                .rst_n                  (rst_lane_n[i]),         // Templated
                // Inputs
                .clk                    (lane_clk[i]),           // Templated
                .async_rst_n            (rst_n));                 // Templated
        end
    endgenerate

    /* RX channel alignment */

    ca_rx_align
      #(/*AUTOINSTPARAM*/
        // Parameters
        .NUM_CHANNELS                   (NUM_CHANNELS),
        .BITS_PER_CHANNEL               (BITS_PER_CHANNEL),
        .AD_WIDTH                       (AD_WIDTH),
        .SYNC_FIFO                      (SYNC_FIFO))
    ca_rx_align_i
      (/*AUTOINST*/
       // Outputs
       .rx_dout                         (rx_dout[NUM_CHANNELS*BITS_PER_CHANNEL-1:0]),
       .align_done                      (align_done),
       .align_err                       (align_err),
       .rx_stb_pos_err                  (rx_stb_pos_err),
       .rx_stb_pos_coding_err           (rx_stb_pos_coding_err),
       .fifo_full                       (fifo_full[NUM_CHANNELS-1:0]),
       .fifo_pfull                      (fifo_pfull[NUM_CHANNELS-1:0]),
       .fifo_empty                      (fifo_empty[NUM_CHANNELS-1:0]),
       .fifo_pempty                     (fifo_pempty[NUM_CHANNELS-1:0]),
       // Inputs
       .lane_clk                        (lane_clk[NUM_CHANNELS-1:0]),
       .rst_lane_n                      (rst_lane_n[NUM_CHANNELS-1:0]),
       .com_clk                         (com_clk),
       .rst_com_n                       (rst_com_n),
       .rx_online                       (rx_online),
       .align_fly                       (align_fly),
       .rden_dly                        (rden_dly[2:0]),
       .count_x                         (count_x[7:0]),
       .rx_stb_wd_sel                   (rx_stb_wd_sel[7:0]),
       .rx_stb_bit_sel                  (rx_stb_bit_sel[39:0]),
       .rx_stb_intv                     (rx_stb_intv[7:0]),
       .rx_din                          (rx_din[NUM_CHANNELS*BITS_PER_CHANNEL-1:0]),
       .fifo_full_val                   (fifo_full_val[4:0]),
       .fifo_pfull_val                  (fifo_pfull_val[4:0]),
       .fifo_empty_val                  (fifo_empty_val[2:0]),
       .fifo_pempty_val                 (fifo_pempty_val[2:0]));

    endmodule // ca

// Local Variables:
// verilog-library-directories:("." "${PROJ_DIR}/common/rtl")
// verilog-auto-inst-param-value:t
// End:
