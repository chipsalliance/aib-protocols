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
//Functional Descript: Channel Alignment IP Wrapper for FPGA
//
//
//
////////////////////////////////////////////////////////////

module ca_wrap
  #(
    parameter NUM_CHANNELS = 4,
    parameter BITS_PER_CHANNEL = 80,
    parameter AD_WIDTH = 3,
    SYNC_FIFO = 1
    )
  (
   input logic [NUM_CHANNELS-1:0]                   lane_clk,
   input logic                                      com_clk,
   input logic                                      rst_n,

   input logic                                      tx_online_i,
   input logic                                      rx_online_i,
   input logic                                      tx_stb_en_i,
   input logic                                      tx_stb_rcvr_i,
   input logic                                      align_fly_i,
   input logic [2:0]                                rden_dly_i,
   input logic [7:0]                                count_x_i,
   input logic [7:0]                                count_xz_i,

   input logic [7:0]                                tx_stb_wd_sel_i,
   input logic [39:0]                               tx_stb_bit_sel_i,
   input logic [7:0]                                tx_stb_intv_i,

   input logic [7:0]                                rx_stb_wd_sel_i,
   input logic [39:0]                               rx_stb_bit_sel_i,
   input logic [7:0]                                rx_stb_intv_i,

   input logic [NUM_CHANNELS*BITS_PER_CHANNEL-1:0]  tx_din_i,
   output logic [NUM_CHANNELS*BITS_PER_CHANNEL-1:0] tx_dout_o,

   input logic [NUM_CHANNELS*BITS_PER_CHANNEL-1:0]  rx_din_i,
   output logic [NUM_CHANNELS*BITS_PER_CHANNEL-1:0] rx_dout_o,

   output logic                                     align_done_o,
   output logic                                     align_err_o,
   output logic                                     tx_stb_pos_err_o,
   output logic                                     tx_stb_pos_coding_err_o,
   output logic                                     rx_stb_pos_err_o,
   output logic                                     rx_stb_pos_coding_err_o,

   input logic [4:0]                                fifo_full_val_i,
   input logic [4:0]                                fifo_pfull_val_i,
   input logic [2:0]                                fifo_empty_val_i,
   input logic [2:0]                                fifo_pempty_val_i,

   output logic [NUM_CHANNELS-1:0]                  fifo_full_o,
   output logic [NUM_CHANNELS-1:0]                  fifo_pfull_o,
   output logic [NUM_CHANNELS-1:0]                  fifo_empty_o,
   output logic [NUM_CHANNELS-1:0]                  fifo_pempty_o
   );

  logic                                             tx_online;
  logic                                             rx_online;
  logic                                             tx_stb_en;
  logic                                             tx_stb_rcvr;
  logic                                             align_fly;
  logic [2:0]                                       rden_dly;
  logic [7:0]                                       count_x;
  logic [7:0]                                       count_xz;

  logic [7:0]                                       tx_stb_wd_sel;
  logic [39:0]                                      tx_stb_bit_sel;
  logic [7:0]                                       tx_stb_intv;

  logic [7:0]                                       rx_stb_wd_sel;
  logic [39:0]                                      rx_stb_bit_sel;
  logic [7:0]                                       rx_stb_intv;

  logic [NUM_CHANNELS*BITS_PER_CHANNEL-1:0]         tx_din;
  logic [NUM_CHANNELS*BITS_PER_CHANNEL-1:0]         tx_dout;

  logic [NUM_CHANNELS*BITS_PER_CHANNEL-1:0]         rx_din;
  logic [NUM_CHANNELS*BITS_PER_CHANNEL-1:0]         rx_dout;

  logic                                             align_done;
  logic                                             align_err;
  logic                                             tx_stb_pos_err;
  logic                                             tx_stb_pos_coding_err;
  logic                                             rx_stb_pos_err;
  logic                                             rx_stb_pos_coding_err;

  logic [4:0]                                       fifo_full_val;
  logic [4:0]                                       fifo_pfull_val;
  logic [2:0]                                       fifo_empty_val;
  logic [2:0]                                       fifo_pempty_val;

  logic [NUM_CHANNELS-1:0]                          fifo_full;
  logic [NUM_CHANNELS-1:0]                          fifo_pfull;
  logic [NUM_CHANNELS-1:0]                          fifo_empty;
  logic [NUM_CHANNELS-1:0]                          fifo_pempty;

  always_ff @(posedge com_clk)
    begin
      tx_online <= tx_online_i ;
      rx_online <= rx_online_i ;
      tx_stb_en <= tx_stb_en_i ;
      tx_stb_rcvr <= tx_stb_rcvr_i ;
      align_fly <= align_fly_i ;
      rden_dly <= rden_dly_i ;
      count_x <= count_x_i ;
      count_xz <= count_xz_i ;

      tx_stb_wd_sel <= tx_stb_wd_sel_i ;
      tx_stb_bit_sel <= tx_stb_bit_sel_i ;
      tx_stb_intv <= tx_stb_intv_i ;

      rx_stb_wd_sel <= rx_stb_wd_sel_i ;
      rx_stb_bit_sel <= rx_stb_bit_sel_i ;
      rx_stb_intv <= rx_stb_intv_i ;

      tx_din <= tx_din_i ;
      tx_dout_o <= tx_dout ;

      rx_din <= rx_din_i ;
      rx_dout_o <= rx_dout ;

      align_done_o <= align_done ;
      align_err_o <= align_err ;
      tx_stb_pos_err_o <= tx_stb_pos_err ;
      tx_stb_pos_coding_err_o <= tx_stb_pos_coding_err ;
      rx_stb_pos_err_o <= rx_stb_pos_err ;
      rx_stb_pos_coding_err_o <= rx_stb_pos_coding_err ;

      fifo_full_val <= fifo_full_val_i ;
      fifo_pfull_val <= fifo_pfull_val_i ;
      fifo_empty_val <= fifo_empty_val_i ;
      fifo_pempty_val <= fifo_pempty_val_i ;

      fifo_full_o <= fifo_full ;
      fifo_pfull_o <= fifo_pfull ;
      fifo_empty_o <= fifo_empty ;
      fifo_pempty_o <= fifo_pempty ;
    end // always_ff @ (posedge com_clk)

  /* ca AUTO_TEMPLATE (
   .lane_clk ({NUM_CHANNELS{com_clk}}),
   ); */

  /* Channel Alignment IP */

  ca
    #(/*AUTOINSTPARAM*/
      // Parameters
      .NUM_CHANNELS                     (NUM_CHANNELS),
      .BITS_PER_CHANNEL                 (BITS_PER_CHANNEL),
      .AD_WIDTH                         (AD_WIDTH),
      .SYNC_FIFO                        (SYNC_FIFO))
  ca_i
    (/*AUTOINST*/
     // Outputs
     .tx_dout                           (tx_dout[NUM_CHANNELS*BITS_PER_CHANNEL-1:0]),
     .rx_dout                           (rx_dout[NUM_CHANNELS*BITS_PER_CHANNEL-1:0]),
     .align_done                        (align_done),
     .align_err                         (align_err),
     .tx_stb_pos_err                    (tx_stb_pos_err),
     .tx_stb_pos_coding_err             (tx_stb_pos_coding_err),
     .rx_stb_pos_err                    (rx_stb_pos_err),
     .rx_stb_pos_coding_err             (rx_stb_pos_coding_err),
     .fifo_full                         (fifo_full[NUM_CHANNELS-1:0]),
     .fifo_pfull                        (fifo_pfull[NUM_CHANNELS-1:0]),
     .fifo_empty                        (fifo_empty[NUM_CHANNELS-1:0]),
     .fifo_pempty                       (fifo_pempty[NUM_CHANNELS-1:0]),
     // Inputs
     .lane_clk                          ({NUM_CHANNELS{com_clk}}), // Templated
     .com_clk                           (com_clk),
     .rst_n                             (rst_n),
     .tx_online                         (tx_online),
     .rx_online                         (rx_online),
     .tx_stb_en                         (tx_stb_en),
     .tx_stb_rcvr                       (tx_stb_rcvr),
     .align_fly                         (align_fly),
     .rden_dly                          (rden_dly[2:0]),
     .count_x                           (count_x[7:0]),
     .count_xz                          (count_xz[7:0]),
     .tx_stb_wd_sel                     (tx_stb_wd_sel[7:0]),
     .tx_stb_bit_sel                    (tx_stb_bit_sel[39:0]),
     .tx_stb_intv                       (tx_stb_intv[7:0]),
     .rx_stb_wd_sel                     (rx_stb_wd_sel[7:0]),
     .rx_stb_bit_sel                    (rx_stb_bit_sel[39:0]),
     .rx_stb_intv                       (rx_stb_intv[7:0]),
     .tx_din                            (tx_din[NUM_CHANNELS*BITS_PER_CHANNEL-1:0]),
     .rx_din                            (rx_din[NUM_CHANNELS*BITS_PER_CHANNEL-1:0]),
     .fifo_full_val                     (fifo_full_val[4:0]),
     .fifo_pfull_val                    (fifo_pfull_val[4:0]),
     .fifo_empty_val                    (fifo_empty_val[2:0]),
     .fifo_pempty_val                   (fifo_pempty_val[2:0]));

endmodule // ca_wrap

// Local Variables:
// verilog-library-directories:("." "${PROJ_DIR}/ca/rtl" "${PROJ_DIR}/common/rtl")
// verilog-auto-inst-param-value:t
// End:
