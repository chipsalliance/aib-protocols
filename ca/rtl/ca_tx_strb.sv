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
// Functional Descript: Channel Alignment IP, TX alignment strobe generator
//
//
//
////////////////////////////////////////////////////////////

module ca_tx_strb
  #(
    parameter NUM_CHANNELS = 2,
    parameter BITS_PER_CHANNEL = 80
    )
  (
   input logic                                      com_clk,
   input logic                                      rst_n,

   input logic                                      tx_online,
   input logic                                      tx_stb_en,
   input logic                                      tx_stb_rcvr,
   input logic [15:0]                               delay_z_value,

   input logic [7:0]                                tx_stb_wd_sel,
   input logic [39:0]                               tx_stb_bit_sel,
   input logic [7:0]                                tx_stb_intv,

   input logic [NUM_CHANNELS*BITS_PER_CHANNEL-1:0]  tx_din,
   output logic [NUM_CHANNELS*BITS_PER_CHANNEL-1:0] tx_dout,

   output logic                                     tx_stb_pos_err,
   output logic                                     tx_stb_pos_coding_err
   );

  logic                                             tx_online_del;
  logic [7:0]                                       stb_intv_count;
  logic                                             tx_userbit;
  logic                                             tx_state_gen_stb;
  logic                                             tx_state_done;
  logic                                             tx_stb_en_final;
  logic [BITS_PER_CHANNEL-1:0]                      tx_din_ch [NUM_CHANNELS-1:0];
  logic [BITS_PER_CHANNEL-1:0]                      tx_dout_ch [NUM_CHANNELS-1:0];

  logic [8:0] tx_word_start;
  logic [5:0] tx_bit;
  logic [8:0] tx_stb_loc;
  logic [4:0] tx_stb_wd_sel_ones;
  logic [5:0] tx_stb_bit_sel_ones;
  logic [5:0] tx_stb_bit_sel_pos;

  assign tx_userbit = (stb_intv_count == 8'h1) & tx_state_gen_stb;
  assign tx_stb_en_final = tx_stb_en & (tx_stb_rcvr ? (~tx_state_done) : 1'b1);

  always_comb
    begin : tx_dout_asm
      for (int i = 0; i < NUM_CHANNELS; i++)
        tx_dout[i*BITS_PER_CHANNEL +: BITS_PER_CHANNEL] = tx_stb_en_final ? tx_dout_ch[i] : tx_din_ch[i];
    end

  /* TX mux */

  /* ca_tx_mux AUTO_TEMPLATE (
   .CH_WIDTH    (BITS_PER_CHANNEL),
   .data_out    (tx_dout_ch[i]),
   .data_in     (tx_din_ch[i]),
   .stb_loc     (tx_stb_loc[]),
   ); */

  genvar                                            i;
  generate
    for (i = 0; i < NUM_CHANNELS; i++)
      begin : ca_tx_muxes
        assign tx_din_ch[i] = (tx_din[i*BITS_PER_CHANNEL +: BITS_PER_CHANNEL]);
        ca_tx_mux
          #(/*AUTOINSTPARAM*/
            // Parameters
            .CH_WIDTH                   (BITS_PER_CHANNEL))      // Templated
        ca_tx_mux_i
          (/*AUTOINST*/
           // Outputs
           .data_out                    (tx_dout_ch[i]),         // Templated
           // Inputs
           .data_in                     (tx_din_ch[i]),          // Templated
           .stb_loc                     (tx_stb_loc[8:0]),       // Templated
           .tx_userbit                  (tx_userbit));
      end
  endgenerate


  /* level_delay AUTO_TEMPLATE (
      .delayed_en   (tx_online_del),
      .rst_core_n   (rst_com_n),
      .clk_core	    (com_clk),
      .enable	    (tx_online),
      .delay_value  (delay_z_value[]));
   ); */

   level_delay level_delay_i_zvalue
     (/*AUTOINST*/
      // Outputs
      .delayed_en                       (tx_online_del),         // Templated
      // Inputs
      .rst_core_n                       (rst_com_n),             // Templated
      .clk_core                         (com_clk),               // Templated
      .enable                           (tx_online),             // Templated
      .delay_value                      (delay_z_value[15:0]));   // Templated

  /* strobe interval counters */

  always_ff @(posedge com_clk or negedge rst_n)
    if (~rst_n)
      begin
        stb_intv_count <= 8'b0;
      end
    else
      begin
        if (tx_online & ~tx_online_del)
          begin
            stb_intv_count <= 8'h1;
          end
        else
          begin
            if (tx_state_gen_stb)
              if ((stb_intv_count == 8'h1) & ~tx_stb_rcvr)
                stb_intv_count <= tx_stb_intv;
              else if (|stb_intv_count)
                stb_intv_count <= stb_intv_count - 1'b1;
          end
      end

  // TX state machine, in com_clk domain

  localparam [2:0] /* auto enum state_info */
    TX_IDLE	= 3'h0,
    TX_ONLINE	= 3'h1,
    TX_GEN_STB	= 3'h2,
    TX_DONE	= 3'h3;

  logic [2:0]                                       /* auto enum state_info */
                                                    tx_state, d_tx_state;

  /*AUTOASCIIENUM("tx_state", "tx_state_ascii", "")*/
  // Beginning of automatic ASCII enum decoding
  reg [79:0]            tx_state_ascii;         // Decode of tx_state
  always @(tx_state) begin
    case ({tx_state})
      TX_IDLE:    tx_state_ascii = "tx_idle   ";
      TX_ONLINE:  tx_state_ascii = "tx_online ";
      TX_GEN_STB: tx_state_ascii = "tx_gen_stb";
      TX_DONE:    tx_state_ascii = "tx_done   ";
      default:    tx_state_ascii = "%Error    ";
    endcase
  end
  // End of automatics

  assign tx_state_gen_stb = tx_state == TX_GEN_STB;
  assign tx_state_done    = tx_state == TX_DONE;

  always_ff @(posedge com_clk or negedge rst_n)
    if (~rst_n)
      tx_state <= TX_IDLE;
    else
      tx_state <= d_tx_state;

  always_comb
    begin : tx_state_next
      d_tx_state = tx_state;
      case (tx_state)
        TX_IDLE: begin
          if (tx_online)
            d_tx_state = TX_ONLINE;
        end
        TX_ONLINE: begin
          if (tx_stb_en & tx_online_del)
            d_tx_state = TX_GEN_STB;
        end
        TX_GEN_STB: begin
          if (tx_stb_rcvr)
            d_tx_state = TX_DONE;
        end
        TX_DONE: begin
          d_tx_state = TX_DONE;
        end
        default: d_tx_state = TX_IDLE;
      endcase // case (tx_state)
    end

  /* errors */

  always_comb
    begin : tx_stb_word_start
      tx_word_start = 9'h0;
      case (1'b1)
        tx_stb_wd_sel[0]: tx_word_start = 9'h0;
        tx_stb_wd_sel[1]: tx_word_start = 9'h28;
        tx_stb_wd_sel[2]: tx_word_start = 9'h50;
        tx_stb_wd_sel[3]: tx_word_start = 9'h78;
        tx_stb_wd_sel[4]: tx_word_start = 9'hA0;
        tx_stb_wd_sel[5]: tx_word_start = 9'hC8;
        tx_stb_wd_sel[6]: tx_word_start = 9'hF0;
        tx_stb_wd_sel[7]: tx_word_start = 9'h118;
        default: tx_word_start = 9'h0;
      endcase // case (1'b1)
    end

  always_comb
    begin : tx_stb_bit
      tx_bit = 0;
      for (int i = 0; i < 40; i++)
        if (tx_stb_bit_sel[i])
          tx_bit = i;
    end

  assign tx_stb_loc = tx_word_start + tx_bit;
  assign tx_stb_pos_coding_err = (tx_stb_wd_sel_ones != 5'h1) | (tx_stb_bit_sel_ones != 6'h1);
  assign tx_stb_pos_err = (tx_stb_loc > BITS_PER_CHANNEL);

  always_comb
    begin : stb_ones
      tx_stb_wd_sel_ones = 5'b0;
      for (int i = 0; i < 8; i++)
        tx_stb_wd_sel_ones += tx_stb_wd_sel[i];
      tx_stb_bit_sel_ones = 6'b0;
      for (int i = 0; i < 40; i++)
        tx_stb_bit_sel_ones += tx_stb_bit_sel[i];
      tx_stb_bit_sel_pos = 6'b0;
      for (int i = 0; i < 40; i++)
        if (tx_stb_bit_sel[i])
          tx_stb_bit_sel_pos = i;
    end

endmodule // ca_tx_strb

// Local Variables:
// verilog-library-directories:("." "${PROJ_DIR}/llink/rtl" "${PROJ_DIR}/common/rtl")
// verilog-auto-inst-param-value:t
// End:
