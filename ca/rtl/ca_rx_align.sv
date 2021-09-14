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
//
// Functional Descript: Channel Alignment IP, RX channel alignment
//
//
//
////////////////////////////////////////////////////////////

module ca_rx_align
  #(
    parameter NUM_CHANNELS = 2,
    parameter BITS_PER_CHANNEL = 80,
    parameter AD_WIDTH = 4,
    parameter SYNC_FIFO = 1
    )
  (
   input logic [NUM_CHANNELS-1:0]                   lane_clk,
   input logic [NUM_CHANNELS-1:0]                   rst_lane_n,
   input logic                                      com_clk,
   input logic                                      rst_com_n,

   input logic                                      rx_online,
   input logic                                      align_fly,
   input logic [2:0]                                rden_dly,
   input logic [7:0]                                count_x,

   input logic [7:0]                                rx_stb_wd_sel,
   input logic [39:0]                               rx_stb_bit_sel,
   input logic [7:0]                                rx_stb_intv,

   input logic [NUM_CHANNELS*BITS_PER_CHANNEL-1:0]  rx_din,
   output logic [NUM_CHANNELS*BITS_PER_CHANNEL-1:0] rx_dout,

   output logic                                     align_done,
   output logic                                     align_err,
   output logic                                     rx_stb_pos_err,
   output logic                                     rx_stb_pos_coding_err,

   input logic [4:0]                                fifo_full_val,
   input logic [4:0]                                fifo_pfull_val,
   input logic [2:0]                                fifo_empty_val,
   input logic [2:0]                                fifo_pempty_val,

   output logic [NUM_CHANNELS-1:0]                  fifo_full,
   output logic [NUM_CHANNELS-1:0]                  fifo_pfull,
   output logic [NUM_CHANNELS-1:0]                  fifo_empty,
   output logic [NUM_CHANNELS-1:0]                  fifo_pempty
   );

  logic                                             fifo_pop;
  logic [2:0]                                       rd_dly;
  logic                                             rx_online_del;
  logic                                             d_align_done;
  logic                                             d_align_err;
  logic                                             fifo_soft_reset;

  logic [BITS_PER_CHANNEL-1:0]                      rx_din_ch [NUM_CHANNELS-1:0];
  logic [BITS_PER_CHANNEL-1:0]                      rx_dout_ch [NUM_CHANNELS-1:0];

  logic [NUM_CHANNELS-1:0]                          stb_det, d_stb_det;
  logic [NUM_CHANNELS-1:0]                          first_stb_det;
  logic [NUM_CHANNELS-1:0]                          align_err_stb_intv;
  logic [NUM_CHANNELS-1:0]                          align_err_stb_intv_com;
  logic [NUM_CHANNELS-1:0]                          fifo_wr;
  logic [7:0]                                       timer_x [NUM_CHANNELS-1:0];

  logic [39:0]                                      word [NUM_CHANNELS-1:0];

  logic [319:0]                                     rx_din_ch_tmp[NUM_CHANNELS-1:0];

  logic                                             rx_state_idle;
  logic                                             rx_state_aligned, rx_next_state_aligned;
  logic                                             rx_state_done;

  logic                                             all_fifos_not_empty;
  logic [7:0]                                       stb_intv_count [NUM_CHANNELS-1:0];

  logic [NUM_CHANNELS-1:0]                          rd_empty;

  logic [NUM_CHANNELS-1:0]                          rx_online_sync;
  logic [NUM_CHANNELS-1:0]                          rx_online_sync_del;

  logic                                             align_err_intv;
  assign align_err_intv = |align_err_stb_intv_com;

  logic [8:0]                                       rx_word_start;
  logic [5:0]                                       rx_bit;
  logic [8:0]                                       rx_stb_loc;
  logic [4:0]                                       rx_stb_wd_sel_ones;
  logic [5:0]                                       rx_stb_bit_sel_ones;
  logic [5:0]                                       rx_stb_bit_sel_pos;

  /* levelsync AUTO_TEMPLATE (
   .RESET_VALUE (1'b0),
   .clk_dest    (lane_clk[i]),
   .rst_dest_n  (rst_lane_n[i]),
   .src_data    (rx_online),
   .dest_data   (rx_online_sync[i]),
   ); */

  genvar                                            i;
  generate
    for (i = 0; i < NUM_CHANNELS; i++)
      begin : rx_online_syncs
        levelsync
             #(/*AUTOINSTPARAM*/
               // Parameters
               .RESET_VALUE             (1'b0))                  // Templated
        level_sync_i
             (/*AUTOINST*/
              // Outputs
              .dest_data                (rx_online_sync[i]),     // Templated
              // Inputs
              .rst_dest_n               (rst_lane_n[i]),         // Templated
              .clk_dest                 (lane_clk[i]),           // Templated
              .src_data                 (rx_online));             // Templated

      end
  endgenerate

  always_comb
    begin : rx_dout_asm
      for (int i = 0; i < NUM_CHANNELS; i++)
        rx_dout[i*BITS_PER_CHANNEL+:BITS_PER_CHANNEL] = rx_dout_ch[i];
    end

  /* RX alignment FIFOs */

  /* ca_rx_align_fifo AUTO_TEMPLATE (
   .lane_clk          (lane_clk[i]),
   .rst_lane_n        (rst_lane_n[i]),
   .rx_din            (rx_din_ch[i]),
   .rx_dout           (rx_dout_ch[i]),
   .fifo_push         (fifo_wr[i]),
   .rd_empty          (rd_empty[i]),
   .fifo_full         (fifo_full[i]),
   .fifo_pfull        (fifo_pfull[i]),
   .fifo_empty        (fifo_empty[i]),
   .fifo_pempty       (fifo_pempty[i]),
   .soft_reset        (fifo_soft_reset),
   ); */

  generate
    for (i = 0; i < NUM_CHANNELS; i++)
      begin : rx_align_fifos
        assign rx_din_ch[i] = (rx_din[(i+1)*BITS_PER_CHANNEL-1:i*BITS_PER_CHANNEL]);

        ca_rx_align_fifo
          #(/*AUTOINSTPARAM*/
            // Parameters
            .BITS_PER_CHANNEL           (BITS_PER_CHANNEL),
            .AD_WIDTH                   (AD_WIDTH),
            .SYNC_FIFO                  (SYNC_FIFO))
        ca_rx_align_fifo_i
          (/*AUTOINST*/
           // Outputs
           .rx_dout                     (rx_dout_ch[i]),         // Templated
           .rd_empty                    (rd_empty[i]),           // Templated
           .fifo_full                   (fifo_full[i]),          // Templated
           .fifo_pfull                  (fifo_pfull[i]),         // Templated
           .fifo_empty                  (fifo_empty[i]),         // Templated
           .fifo_pempty                 (fifo_pempty[i]),        // Templated
           // Inputs
           .lane_clk                    (lane_clk[i]),           // Templated
           .rst_lane_n                  (rst_lane_n[i]),         // Templated
           .com_clk                     (com_clk),
           .rst_com_n                   (rst_com_n),
           .fifo_push                   (fifo_wr[i]),            // Templated
           .fifo_pop                    (fifo_pop),
           .soft_reset                  (fifo_soft_reset),       // Templated
           .rx_din                      (rx_din_ch[i]),          // Templated
           .fifo_full_val               (fifo_full_val[4:0]),
           .fifo_pfull_val              (fifo_pfull_val[4:0]),
           .fifo_empty_val              (fifo_empty_val[2:0]),
           .fifo_pempty_val             (fifo_pempty_val[2:0]));
      end
  endgenerate

  /* FIFO writes */

  always_comb
    begin : rx_din_tmp
      for (int i =0; i < NUM_CHANNELS; i++)
        begin
          for (int j =0; j < 320; j++)
            if (j < BITS_PER_CHANNEL)
              rx_din_ch_tmp[i][j] = rx_din_ch[i][j];
            else
              rx_din_ch_tmp[i][j] = 1'b0;
        end
    end

  generate
    for (i = 0; i < NUM_CHANNELS; i++)
      begin : stb_dets
        always_comb
          begin
            word[i] = 39'b0;
            case (1'b1)
              rx_stb_wd_sel[0]: word[i] = rx_din_ch_tmp[i][39+0*40:0+0*40];
              rx_stb_wd_sel[1]: word[i] = rx_din_ch_tmp[i][39+1*40:0+1*40];
              rx_stb_wd_sel[2]: word[i] = rx_din_ch_tmp[i][39+2*40:0+2*40];
              rx_stb_wd_sel[3]: word[i] = rx_din_ch_tmp[i][39+3*40:0+3*40];
              rx_stb_wd_sel[4]: word[i] = rx_din_ch_tmp[i][39+4*40:0+4*40];
              rx_stb_wd_sel[5]: word[i] = rx_din_ch_tmp[i][39+5*40:0+5*40];
              rx_stb_wd_sel[6]: word[i] = rx_din_ch_tmp[i][39+6*40:0+6*40];
              rx_stb_wd_sel[7]: word[i] = rx_din_ch_tmp[i][39+7*40:0+7*40];
              default: word[i] = rx_din_ch_tmp[i][39+0*40:0+0*40];
            endcase // case (1'b1)
          end

        assign d_stb_det[i] = |(word[i] & rx_stb_bit_sel);

        always_ff @(posedge lane_clk[i] or negedge rst_lane_n[i])
          if (~rst_lane_n[i])
            begin
              timer_x[i] <= 8'b0;
              stb_det[i] <= 1'b0;
              first_stb_det[i] <= 1'b0;
              fifo_wr[i] <= 1'b0;
              rx_online_sync_del[i] <= 1'b0;
            end
          else
            begin
              rx_online_sync_del[i] <= rx_online_sync[i];
              if (rx_online_sync[i])
                begin
                  if (fifo_soft_reset)
                    begin
                      stb_det[i] <= 1'b0;
                      first_stb_det[i] <= 1'b0;
                      fifo_wr[i] <= 1'b0;
                    end
                  else
                    begin
                      stb_det[i] <= d_stb_det[i];
                      if (~|timer_x[i])
                        first_stb_det[i] <= first_stb_det[i] ? 1'b1 : stb_det[i];
                      fifo_wr[i] <= fifo_wr[i] ? 1'b1 : d_stb_det[i];
                    end
                end
              if (rx_online_sync[i] & ~rx_online_sync_del[i])
                timer_x[i] <= count_x;
              else if (|timer_x[i])
                timer_x[i] <= timer_x[i] - 1'b1;
            end
      end // block: stb_dets
  endgenerate

  /* FIFO read enable delay */

  always_ff @(posedge com_clk or negedge rst_com_n)
    if (~rst_com_n)
      begin
        rx_online_del <= 1'b0;
        rd_dly <= 3'b0;
        align_err <= 1'b0;
        align_done <= 1'b0;
      end
    else
      begin
        rx_online_del <= rx_online;
        if (rx_online & ~rx_online_del)
          rd_dly <= rden_dly;
        else if (all_fifos_not_empty & |rd_dly)
          rd_dly <= rd_dly - 1'b1;
        align_err <= d_align_err | align_err_intv;
        align_done <= d_align_done;
      end

  /* FIFO reads */

  assign all_fifos_not_empty = &first_stb_det;
  assign fifo_pop = all_fifos_not_empty & ~|rd_dly;

  // RX state machine, in com_clk domain

  localparam [2:0] /* auto enum state_info */
    RX_IDLE		= 3'h0,
    RX_ONLINE		= 3'h1,
    RX_ALIGNED		= 3'h2,
    RX_MON		= 3'h3,
    RX_ERR		= 3'h4,
    RX_DONE		= 3'h5,
    RX_SOFT_RESET	= 3'h6;

  logic [2:0] /* auto enum state_info */
              rx_state, d_rx_state;

  /*AUTOASCIIENUM("rx_state", "rx_state_ascii", "")*/
  // Beginning of automatic ASCII enum decoding
  reg [103:0]           rx_state_ascii;         // Decode of rx_state
  always @(rx_state) begin
    case ({rx_state})
      RX_IDLE:       rx_state_ascii = "rx_idle      ";
      RX_ONLINE:     rx_state_ascii = "rx_online    ";
      RX_ALIGNED:    rx_state_ascii = "rx_aligned   ";
      RX_MON:        rx_state_ascii = "rx_mon       ";
      RX_ERR:        rx_state_ascii = "rx_err       ";
      RX_DONE:       rx_state_ascii = "rx_done      ";
      RX_SOFT_RESET: rx_state_ascii = "rx_soft_reset";
      default:       rx_state_ascii = "%Error       ";
    endcase
  end
  // End of automatics

  assign rx_state_idle = rx_state == RX_IDLE;
  assign rx_state_aligned = rx_state == RX_ALIGNED;
  assign rx_next_state_aligned = d_rx_state == RX_ALIGNED;
  assign rx_state_done = rx_state == RX_DONE;

  always_ff @(posedge com_clk or negedge rst_com_n)
    if (~rst_com_n)
      rx_state <= RX_IDLE;
    else
      rx_state <= d_rx_state;

  always_comb
    begin : rx_state_next
      d_rx_state = rx_state;
      d_align_done = 1'b0;
      d_align_err = 1'b0;
      fifo_soft_reset = 1'b0;
      case (rx_state)
        RX_IDLE: begin
          if (rx_online)
            d_rx_state = RX_ONLINE;
        end
        RX_ONLINE: begin
          if (|fifo_full)
            d_rx_state = align_fly ? RX_SOFT_RESET : RX_ERR;
          else if (all_fifos_not_empty)
            d_rx_state = RX_ALIGNED;
        end
        RX_ALIGNED: begin
          if (~|rd_dly)
            d_rx_state = RX_DONE;
        end
        RX_MON: begin
          d_align_done = 1'b1;
          if (align_err_intv)
            d_rx_state = RX_ERR;
        end
        RX_ERR: begin
          d_align_err = 1'b1;
        end
        RX_DONE: begin
          d_align_done = 1'b1;
        end
        RX_SOFT_RESET: begin
          fifo_soft_reset = 1'b1;
          d_rx_state = RX_ONLINE;
        end
        default: d_rx_state = RX_IDLE;
      endcase // case (rx_state)
    end

  /* errors */

  always_comb
    begin : rx_stb_word_start
      rx_word_start = 9'h0;
      case (1'b1)
        rx_stb_wd_sel[0]: rx_word_start = 9'h0;
        rx_stb_wd_sel[1]: rx_word_start = 9'h28;
        rx_stb_wd_sel[2]: rx_word_start = 9'h50;
        rx_stb_wd_sel[3]: rx_word_start = 9'h78;
        rx_stb_wd_sel[4]: rx_word_start = 9'hA0;
        rx_stb_wd_sel[5]: rx_word_start = 9'hC8;
        rx_stb_wd_sel[6]: rx_word_start = 9'hF0;
        rx_stb_wd_sel[7]: rx_word_start = 9'h118;
        default: rx_word_start = 9'h0;
      endcase // case (1'b1)
    end

  always_comb
    begin : rx_stb_bit
      rx_bit = 0;
      for (int i = 0; i < 40; i++)
        if (rx_stb_bit_sel[i])
          rx_bit = i;
    end

  assign rx_stb_loc = rx_word_start + rx_bit;
  assign rx_stb_pos_coding_err = (rx_stb_wd_sel_ones != 5'h1) | (rx_stb_bit_sel_ones != 6'h1);
  assign rx_stb_pos_err = (rx_stb_loc > BITS_PER_CHANNEL);

  always_comb
    begin : stb_ones
      rx_stb_wd_sel_ones = 5'b0;
      for (int i = 0; i < 8; i++)
        rx_stb_wd_sel_ones += rx_stb_wd_sel[i];
      rx_stb_bit_sel_ones = 6'b0;
      for (int i = 0; i < 40; i++)
        rx_stb_bit_sel_ones += rx_stb_bit_sel[i];
      rx_stb_bit_sel_pos = 6'b0;
      for (int i = 0; i < 40; i++)
        if (rx_stb_bit_sel[i])
          rx_stb_bit_sel_pos = i;
    end

  /* strobe interval counters */

  /* levelsync AUTO_TEMPLATE (
   .RESET_VALUE (1'b0),
   .clk_dest    (com_clk),
   .rst_dest_n  (rst_com_n),
   .src_data    (align_err_stb_intv[i]),
   .dest_data   (align_err_stb_intv_com[i]),
   ); */

  generate
    for (i = 0; i < NUM_CHANNELS; i++)
      begin : stb_intv_counters
        always_ff @(posedge lane_clk[i] or negedge rst_lane_n[i])
          if (~rst_lane_n[i])
            begin
              stb_intv_count[i] <= 8'b0;
              align_err_stb_intv[i] <= 1'b0;
            end
          else
            begin
              if (stb_det[i])
                stb_intv_count[i] <= rx_stb_intv;
              else if (first_stb_det[i])
                if (stb_intv_count[i] == 8'h1)
                  begin
                    if (~stb_det[i])
                      align_err_stb_intv[i] <= align_fly;
                    stb_intv_count[i] <= rx_stb_intv;
                  end
                else
                  begin
                    stb_intv_count[i] <= stb_intv_count[i] - 1'b1;
                  end
            end

        levelsync
          #(/*AUTOINSTPARAM*/
            // Parameters
            .RESET_VALUE                (1'b0))                  // Templated
        level_sync_i
          (/*AUTOINST*/
           // Outputs
           .dest_data                   (align_err_stb_intv_com[i]), // Templated
           // Inputs
           .rst_dest_n                  (rst_com_n),             // Templated
           .clk_dest                    (com_clk),               // Templated
           .src_data                    (align_err_stb_intv[i])); // Templated

      end
  endgenerate

endmodule // ca_rx_align

// Local Variables:
// verilog-library-directories:("." "${PROJ_DIR}/common/rtl")
// verilog-auto-inst-param-value:t
// End:
