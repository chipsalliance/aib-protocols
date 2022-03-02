////////////////////////////////////////////////////////////
//
//        Copyright (C) 2021 Eximius Design
//
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
// Functional Descript: LPIF Adapter IP Control
//
//
//
////////////////////////////////////////////////////////////

module lpif_ctl
  #(
    parameter AIB_VERSION = 2,
    parameter AIB_GENERATION = 2,
    parameter AIB_LANES = 4,
    parameter AIB_BITS_PER_LANE = 80,
    parameter LPIF_DATA_WIDTH = 64,
    parameter LPIF_CLOCK_RATE = 2000,
    parameter LPIF_PIPELINE_STAGES = 1,
    parameter MEM_CACHE_STREAM_ID = 8'h1,
    parameter IO_STREAM_ID = 8'h2,
    parameter ARB_MUX_STREAM_ID = 8'h3,
    parameter PTM_RX_DELAY = 4,
    localparam LPIF_VALID_WIDTH = ((LPIF_DATA_WIDTH == 128) ? 2 : 1),
    localparam LPIF_CRC_WIDTH = ((LPIF_DATA_WIDTH == 128) ? 32 : 16)
    )
  (
   // LPIF Interface
   input logic                          lclk,
   input logic                          rst_n,

   input logic                          lp_irdy,
   input logic [LPIF_DATA_WIDTH*8-1:0]  lp_data,
   input logic [LPIF_CRC_WIDTH-1:0]     lp_crc,
   input logic                          lp_crc_valid,
   input logic [LPIF_VALID_WIDTH-1:0]   lp_valid,
   input logic                          lp_trans_valid, // Indicates valid transaction with at least one valid.
   input logic [7:0]                    lp_stream,
   output logic                         pl_trdy,

   output logic                         flit_in_queue,
   input logic                          lp_stallack,

   output logic [3:0]                   dstrm_state,
   output logic [1:0]                   dstrm_protid,
   output logic [LPIF_DATA_WIDTH*8-1:0] dstrm_data,
   output logic [LPIF_VALID_WIDTH-1:0]  dstrm_dvalid,
   output logic [LPIF_CRC_WIDTH-1:0]    dstrm_crc,
   output logic                         dstrm_crc_valid,
   output logic                         dstrm_valid,

   input logic [3:0]                    ustrm_state,
   input logic [1:0]                    ustrm_protid,
   input logic [LPIF_DATA_WIDTH*8-1:0]  ustrm_data,
   input logic [LPIF_VALID_WIDTH-1:0]   ustrm_dvalid,
   input logic [LPIF_CRC_WIDTH-1:0]     ustrm_crc,
   input logic                          ustrm_crc_valid,
   input logic                          ustrm_valid,

   output logic [LPIF_DATA_WIDTH*8-1:0] pl_data,
   output logic [LPIF_CRC_WIDTH-1:0]    pl_crc,
   output logic                         pl_crc_valid,
   output logic [LPIF_VALID_WIDTH-1:0]  pl_valid,
   output logic [7:0]                   pl_stream,

   output logic                         pl_error,
   output logic                         pl_trainerror,
   output logic                         pl_cerror,
   output logic                         pl_tmstmp,
   output logic [7:0]                   pl_tmstmp_stream,
   input logic                          lp_tmstmp,
   input logic [7:0]                    lp_tmstmp_stream,

   input logic                          lp_linkerror,
   output logic                         pl_quiesce,
   input logic                          lp_flushed_all,
   input logic                          lp_rcvd_crc_err,
   output logic [2:0]                   pl_lnk_cfg,
   output logic                         pl_rxframe_errmask,
   output logic [2:0]                   pl_speedmode,
   output logic [2:0]                   pl_clr_lnkeqreq,
   output logic [2:0]                   pl_set_lnkeqreq,
   output logic [7:0]                   pl_ptm_rx_delay,
   output logic                         pl_setlabs,
   output logic                         pl_setlbms,
   output logic                         pl_surprise_lnk_down,
   output logic                         pl_err_pipestg,
   input logic                          lp_force_detect,
   output logic [7:0]                   pl_cfg,
   output logic                         pl_cfg_vld,

   // AIB Interface
   output logic                         ns_mac_rdy,
   input logic                          fs_mac_rdy,
   output logic [AIB_LANES-1:0]         ns_adapter_rstn,
   input logic [AIB_LANES-1:0]          sl_rx_transfer_en,
   input logic [AIB_LANES-1:0]          ms_tx_transfer_en,
   input logic [AIB_LANES-1:0]          ms_rx_transfer_en,
   input logic [AIB_LANES-1:0]          sl_tx_transfer_en,
   input logic [AIB_LANES-1:0]          m_rxfifo_align_done,
   input logic [AIB_LANES-1:0]          wa_error,
   input logic [AIB_LANES-1:0]          wa_error_cnt,
   input logic                          dual_mode_select,
   input logic                          m_gen2_mode,
   input logic                          i_conf_done,
   input logic [AIB_LANES-1:0]          power_on_reset,

   // Channel Alignment
   input logic                          align_done,
   input logic                          align_err,
   output logic                         align_fly,
   output logic [7:0]                   tx_stb_wd_sel,
   output logic [39:0]                  tx_stb_bit_sel,
   output logic [15:0]                  tx_stb_intv,
   output logic [7:0]                   rx_stb_wd_sel,
   output logic [39:0]                  rx_stb_bit_sel,
   output logic [15:0]                  rx_stb_intv,
   output logic [2:0]                   rden_dly,
   output logic                         tx_online,
   output logic                         rx_online,

   input logic [15:0]                   lpif_tx_stb_intv,
   input logic [15:0]                   lpif_rx_stb_intv,

   // lsm

   input logic [3:0]                    lsm_dstrm_state,
   input logic [2:0]                    lsm_speedmode,

   // misc

   input logic                          tx_mrk_userbit_vld,
   output logic                         ctl_link_up,
   input logic                          lsm_state_active,
   output logic                         ctl_phy_err
   );

  // phy to link layer

  // tied-off as described in LPIF Adapter White Paper
  assign pl_cerror = 1'b0;
  assign pl_clr_lnkeqreq = 3'b0;
  assign pl_set_lnkeqreq = 3'b0;
  assign pl_err_pipestg = 1'b0;
  assign pl_error = 1'b0;
  assign pl_quiesce = 1'b0;
  assign pl_rxframe_errmask = 1'b0;
  assign pl_setlbms = 1'b0;
  assign pl_setlabs = 1'b0;
  assign pl_surprise_lnk_down = 1'b0;

  // tied-off for now
  assign pl_trainerror = 1'b0;

  // optional as described in LPIF Adapter White Paper
  assign pl_cfg_vld = 1'b0;
  assign pl_cfg = 8'b0;

  // lpif to ca

  assign align_fly = 1'b1;
  assign tx_stb_wd_sel = 8'h1;    // these must match the value in the config file
  assign tx_stb_bit_sel = 40'h2;
  assign tx_stb_intv = lpif_tx_stb_intv;
  assign rx_stb_wd_sel = 8'h1;    // these must match the value in the config file
  assign rx_stb_bit_sel = 40'h2;
  assign rx_stb_intv = lpif_rx_stb_intv;
  assign rden_dly = 3'h0;

  // misc

  logic                                 d_ns_mac_rdy;
  logic [AIB_LANES-1:0]                 d_ns_adapter_rstn;

  logic                                 d_tx_online;
  logic                                 d_rx_online;

  wire                                  phy_err = ~&{ms_tx_transfer_en, sl_tx_transfer_en} |
                                        (|wa_error) | align_err |
                                        lp_linkerror;

`include "lpif_configs.svh"

  wire                                  one_channel = (aib_lanes == 16'h1);

  // multi-cycle data transfers

  // one less than number of beats
  // for 32B LPIF Data Width, number is doubled
  logic [3:0]                           num_lpdat_beats;

  generate
    if (X16_Q2 | X16_H2 | X16_F2 | X16_H1 | X16_F1)
      assign num_lpdat_beats = 4'h0;
    else if (X8_Q2 | X8_H2 | X8_F2 | X8_H1 | X8_F1)
      assign num_lpdat_beats = 4'h1;
    else if (X4_Q2 | X4_H2 | X4_F2 | X4_H1 | X4_F1)
      assign num_lpdat_beats = 4'h3;
    else if (X2_H1 | X2_F1)
      assign num_lpdat_beats = 4'h7;
    else if (X1_H1 | X1_F1)
      assign num_lpdat_beats = 4'hF;
  endgenerate

  // handle lp -> dstrm multi-cycle transfers

  logic                                 lp_datbeat_is_0, d_lp_datbeat_is_0;
  logic [3:0]                           lp_data_beat, d_lp_data_beat;
  logic                                 lp_data_count_en;

  //  lpif data fifo
  // lp_data + lp_crc + lp_crc_valid + lp_valid + lp_stream
  localparam LP_FIFO_WIDTH = (LPIF_DATA_WIDTH*8)+LPIF_CRC_WIDTH+1+LPIF_VALID_WIDTH+8;
  localparam LP_FIFO_DEPTH = 2;
  localparam FIFO_WIDTH_MSB = LP_FIFO_WIDTH-1;
  localparam FIFO_COUNT_MSB = 1;

  logic [LP_FIFO_WIDTH-1:0]             lp_fifo_wrdata;
  logic [LP_FIFO_WIDTH-1:0]             lp_fifo_rddata;
  logic [FIFO_COUNT_MSB:0]              lp_fifo_numfilled, lp_fifo_numempty;
  logic                                 lp_fifo_push, lp_fifo_pop, lp_fifo_full, lp_fifo_empty;
  logic                                 lp_fifo_underflow_pulse, lp_fifo_overflow_pulse;
  logic [LPIF_DATA_WIDTH*8-1:0]         lp_fifo_data;
  logic [LPIF_CRC_WIDTH-1:0]            lp_fifo_crc;
  logic                                 lp_fifo_crc_valid;
  logic [LPIF_VALID_WIDTH-1:0]          lp_fifo_valid;
  logic [7:0]                           lp_fifo_stream;

  logic                                 d_aib_aligned_to_tx;
  logic                                 aib_aligned_to_tx;
  logic                                 dstrm_fifo_has_half_flit;
  logic                                 hold_start_tx_due_to_half_flit;
  logic [3:0]                           tx_marker_counter;
  logic                                 hold_start_tx_due_to_marker;
  logic                                 clear_to_tx;
  logic                                 lp_fifo_earlyfull;


  // Pre timing optimization    assign pl_trdy = lsm_state_active & ~lp_fifo_full ;
  always_ff @(posedge lclk or negedge rst_n)
    if (~rst_n)
      begin
        pl_trdy <= 1'b0;
      end
    else
      begin
        pl_trdy <= lsm_state_active & ~(lp_fifo_earlyfull | lp_fifo_full) ;
      end

  assign lp_fifo_earlyfull = (lp_fifo_push & (~lp_fifo_pop) & (lp_fifo_numempty == 1));

  assign flit_in_queue = lp_trans_valid | (~lp_fifo_empty);

  always_comb
    begin
      d_lp_data_beat = lp_data_beat;
      lp_data_count_en = clear_to_tx;
      if (lp_data_count_en )
        d_lp_data_beat = ~|lp_data_beat ? num_lpdat_beats : lp_data_beat - 1'b1;
      else if (lp_fifo_empty)
        d_lp_data_beat = num_lpdat_beats;

      d_lp_datbeat_is_0 = (d_lp_data_beat == 0);
    end

  always_ff @(posedge lclk or negedge rst_n)
    if (~rst_n)
      begin
        lp_data_beat         <= num_lpdat_beats;
        lp_datbeat_is_0      <= 1'b0;
      end
    else
      begin
        lp_data_beat         <= d_lp_data_beat;
        lp_datbeat_is_0      <= d_lp_datbeat_is_0;
      end

  // handle ustrm -> pl multi-cycle transfers

  logic [3:0]                           ustrm_data_beat, d_ustrm_data_beat;
  logic                                 ustrm_data_xfr_done;
  logic [3:0]                           ustrm_data_max_beat;
  logic                                 ustrm_data_xfr_flg, d_ustrm_data_xfr_flg;
  logic                                 ustrm_data_count_en;

  logic [LPIF_DATA_WIDTH*8-1:0]         d_pl_data;
  logic [LPIF_CRC_WIDTH-1:0]            d_pl_crc;
  logic                                 d_pl_crc_valid;
  logic [LPIF_VALID_WIDTH-1:0]          d_pl_valid;
  logic [0:0]                           d_pl_hold_valid;
  logic [0:0]                           pl_hold_valid;

  always_comb
    begin
      ustrm_data_max_beat = num_lpdat_beats;
      ustrm_data_xfr_done = ~|ustrm_data_beat;

      d_ustrm_data_xfr_flg = ustrm_data_xfr_flg;
      d_ustrm_data_beat = ustrm_data_beat;
      ustrm_data_count_en = ustrm_valid | ustrm_data_xfr_flg;

      if (ustrm_data_xfr_done)
        d_ustrm_data_xfr_flg = 1'b0;
      else if (ustrm_valid)
        d_ustrm_data_xfr_flg = 1'b1;

      if (ustrm_data_xfr_done)
        d_ustrm_data_beat = ustrm_data_max_beat;
      else if (ustrm_data_count_en & !ustrm_data_xfr_done)
        d_ustrm_data_beat = ustrm_data_beat - 1'b1;
    end

  // pl data generation

  generate
    if (X16_Q2 | X16_H2 | X16_F2 | X16_H1 | X16_F1)
      always_comb
        begin
          d_pl_data = ustrm_data;
          d_pl_valid = (ustrm_data_xfr_flg & ustrm_data_xfr_done) | ustrm_dvalid;
          d_pl_crc_valid = ustrm_crc_valid;
          d_pl_crc = ustrm_crc;
          d_pl_hold_valid = pl_hold_valid ;
        end

    else if (X8_Q2)
      always_comb
        begin
          d_pl_valid      = pl_valid      ;
          d_pl_hold_valid = pl_hold_valid ;
          d_pl_data       = pl_data       ;
          d_pl_crc_valid  = pl_crc_valid  ;
          d_pl_crc        = pl_crc        ;

          case (ustrm_data_beat)
            4'h0: begin
              d_pl_valid[1] = ustrm_valid & ustrm_dvalid[0];
              d_pl_valid[0] = pl_hold_valid[0];
              d_pl_data[1*512+:512] = ustrm_data;
              d_pl_crc_valid = pl_crc_valid | ustrm_crc_valid;
              d_pl_crc[1*16+:16] = ustrm_crc[0*16+:16];
            end
            4'h1: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_hold_valid[0] = ustrm_valid & ustrm_dvalid[0];
              d_pl_data[0*512+:512] = ustrm_data;
              d_pl_crc_valid = ustrm_crc_valid;
              d_pl_crc[0*16+:16] = ustrm_crc[0*16+:16];
            end
            default: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_hold_valid[0] = ustrm_valid & ustrm_dvalid[0];
              d_pl_data[0*512+:512] = ustrm_data;
              d_pl_crc_valid = ustrm_crc_valid;
              d_pl_crc[0*16+:16] = ustrm_crc[0*16+:16];
            end
          endcase // case (ustrm_data_beat)
        end
    else if (X8_H2)
      always_comb
        begin
          d_pl_valid      = pl_valid      ;
          d_pl_hold_valid = pl_hold_valid ;
          d_pl_data       = pl_data       ;
          d_pl_crc_valid  = pl_crc_valid  ;
          d_pl_crc        = pl_crc        ;
          case (ustrm_data_beat)
            4'h0: begin
              d_pl_valid[0] = ustrm_valid & ustrm_dvalid[0];
              d_pl_data[1*256+:256] = ustrm_data;
              d_pl_crc_valid = ustrm_crc_valid;
              d_pl_crc[0*16+:16] = ustrm_crc[0*16+:16];
            end
            4'h1: begin
              d_pl_valid[0] = 1'b0;
              d_pl_data[0*256+:256] = ustrm_data;
              d_pl_crc_valid = 1'b0;
              d_pl_crc[0*16+:16] = 16'h0;
            end
            default: begin
              d_pl_valid[0] = 1'b0;
              d_pl_data[0*256+:256] = ustrm_data;
              d_pl_crc_valid = 1'b0;
              d_pl_crc[0*16+:16] = ustrm_crc[0*16+:16];
            end
          endcase // case (ustrm_data_beat)
        end
    else if (X8_F2)
      always_comb
        begin
          d_pl_valid      = pl_valid      ;
          d_pl_hold_valid = pl_hold_valid ;
          d_pl_data       = pl_data       ;
          d_pl_crc_valid  = pl_crc_valid  ;
          d_pl_crc        = pl_crc        ;
          case (ustrm_data_beat)
            4'h0: begin
              d_pl_valid[0] = ustrm_valid & ustrm_dvalid[0];
              d_pl_data[1*128+:128] = ustrm_data;
              d_pl_crc_valid = ustrm_crc_valid;
              d_pl_crc[1*8+:8] = ustrm_crc[0*8+:8];
            end
            4'h1: begin
              d_pl_valid[0] = 1'b0;
              d_pl_data[0*128+:128] = ustrm_data;
              d_pl_crc_valid = 1'b0;
              d_pl_crc[0*8+:8] = ustrm_crc[0*8+:8];
            end
            default: begin
              d_pl_valid[0] = 1'b0;
              d_pl_data[0*128+:128] = ustrm_data;
              d_pl_crc_valid = 1'b0;
              d_pl_crc[0*8+:8] = ustrm_crc[0*8+:8];
            end
          endcase // case (ustrm_data_beat)
        end

    else if (X4_Q2)
      always_comb
        begin
          d_pl_valid      = pl_valid      ;
          d_pl_hold_valid = pl_hold_valid ;
          d_pl_data       = pl_data       ;
          d_pl_crc_valid  = pl_crc_valid  ;
          d_pl_crc        = pl_crc        ;

          case (ustrm_data_beat)
            4'h0: begin
              d_pl_valid[1] = ustrm_valid & ustrm_dvalid[0];
              d_pl_valid[0] = pl_hold_valid[0];
              d_pl_data[3*256+:256] = ustrm_data[0*256+:256];
              d_pl_crc_valid = pl_crc_valid | ustrm_crc_valid;
              d_pl_crc[1*16+:16] = ustrm_crc[0*16+:16];
            end
            4'h1: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_hold_valid[0] = pl_hold_valid[0];
              d_pl_data[2*256+:256] = ustrm_data[0*256+:256];
              d_pl_crc_valid = pl_crc_valid;
              d_pl_crc = pl_crc;
            end
            4'h2: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_hold_valid[0] = ustrm_valid & ustrm_dvalid[0];
              d_pl_data[1*256+:256] = ustrm_data[0*256+:256];
              d_pl_crc_valid = ustrm_crc_valid;
              d_pl_crc[0*16+:16] = ustrm_crc[0*16+:16];
            end
            4'h3: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_hold_valid[0] = 2'b0;
              d_pl_data[0*256+:256] = ustrm_data[0*256+:256];
              d_pl_crc_valid = pl_crc_valid;
              d_pl_crc = pl_crc;
            end
            default: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_hold_valid[0] = ustrm_valid & ustrm_dvalid[0];
              d_pl_data[0*256+:256] = ustrm_data[0*256+:256];
              d_pl_crc_valid = ustrm_crc_valid;
              d_pl_crc = pl_crc;
            end
          endcase // case (ustrm_data_beat)
        end
    else if (X4_H2)
      always_comb
        begin
          d_pl_valid      = pl_valid      ;
          d_pl_hold_valid = pl_hold_valid ;
          d_pl_data       = pl_data       ;
          d_pl_crc_valid  = pl_crc_valid  ;
          d_pl_crc        = pl_crc        ;

          case (ustrm_data_beat)
            4'h0: begin
              d_pl_valid[0] = ustrm_valid & ustrm_dvalid[0];
              d_pl_data[3*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = ustrm_crc_valid;
              d_pl_crc[1*8+:8] = ustrm_crc[0*8+:8];
            end
            4'h1: begin
              d_pl_valid[0] = 1'b0;
              d_pl_data[2*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = 1'b0;
              d_pl_crc[0*8+:8] = ustrm_crc[0*8+:8];
            end
            4'h2: begin
              d_pl_valid[0] = 1'b0;
              d_pl_data[1*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = 1'b0;
              d_pl_crc = pl_crc;
            end
            4'h3: begin
              d_pl_valid[0] = 1'b0;
              d_pl_data[0*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = 1'b0;
              d_pl_crc = pl_crc;
            end
            default: begin
              d_pl_valid[0] = 1'b0;
              d_pl_data[0*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = 1'b0;
              d_pl_crc = pl_crc;
            end
          endcase // case (ustrm_data_beat)
        end
    else if (X4_F2)
      always_comb
        begin
          d_pl_valid      = pl_valid      ;
          d_pl_hold_valid = pl_hold_valid ;
          d_pl_data       = pl_data       ;
          d_pl_crc_valid  = pl_crc_valid  ;
          d_pl_crc        = pl_crc        ;
          case (ustrm_data_beat)
            4'h0: begin
              d_pl_valid[0] = ustrm_valid & ustrm_dvalid[0];
              d_pl_data[3*64+:64] = ustrm_data[0*64+:64];
              d_pl_crc_valid = ustrm_crc_valid;
              d_pl_crc[3*4+:4] = ustrm_crc[0*4+:4];
            end
            4'h1: begin
              d_pl_valid[0] = 1'b0;
              d_pl_data[2*64+:64] = ustrm_data[0*64+:64];
              d_pl_crc_valid = 1'b0;
              d_pl_crc[2*4+:4] = ustrm_crc[0*4+:4];
            end
            4'h2: begin
              d_pl_valid[0] = 1'b0;
              d_pl_data[1*64+:64] = ustrm_data[0*64+:64];
              d_pl_crc_valid = 1'b0;
              d_pl_crc[1*4+:4] = ustrm_crc[0*4+:4];
            end
            4'h3: begin
              d_pl_valid[0] = 1'b0;
              d_pl_data[0*64+:64] = ustrm_data[0*64+:64];
              d_pl_crc_valid = 1'b0;
              d_pl_crc[0*4+:4] = ustrm_crc[0*4+:4];
            end
            default: begin
              d_pl_valid[0] = 1'b0;
              d_pl_data[0*64+:64] = ustrm_data[0*64+:64];
              d_pl_crc_valid = 1'b0;
              d_pl_crc[0*4+:4] = ustrm_crc[0*4+:4];
            end
          endcase // case (ustrm_data_beat)
        end
    else if (X8_H1)
      always_comb
        begin
          d_pl_valid      = pl_valid      ;
          d_pl_hold_valid = pl_hold_valid ;
          d_pl_data       = pl_data       ;
          d_pl_crc_valid  = pl_crc_valid  ;
          d_pl_crc        = pl_crc        ;

          case (ustrm_data_beat)
            4'h0: begin
              d_pl_valid[1] = ustrm_valid & ustrm_dvalid[0];
              d_pl_valid[0] = pl_hold_valid[0];
              d_pl_data[1*512+:512] = ustrm_data[0*512+:512];
              d_pl_crc_valid = pl_crc_valid | ustrm_crc_valid;
              d_pl_crc[1*16+:16] = ustrm_crc[0*16+:16];
            end
            4'h1: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_hold_valid[0] = ustrm_valid & ustrm_dvalid[0];
              d_pl_data[0*512+:512] = ustrm_data;
              d_pl_crc_valid = ustrm_crc_valid;
              d_pl_crc[0*16+:16] = ustrm_crc[0*16+:16];
            end
            default: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_hold_valid[0] = ustrm_valid & ustrm_dvalid[0];
              d_pl_data[0*512+:512] = ustrm_data[0*512+:512];
              d_pl_crc_valid = ustrm_crc_valid;
              d_pl_crc[0*16+:16] = ustrm_crc[0*16+:16];
            end
          endcase // case (ustrm_data_beat)
        end
    else if (X8_F1)
      always_comb
        begin
          d_pl_valid      = pl_valid      ;
          d_pl_hold_valid = pl_hold_valid ;
          d_pl_data       = pl_data       ;
          d_pl_crc_valid  = pl_crc_valid  ;
          d_pl_crc        = pl_crc        ;
          case (ustrm_data_beat)

            4'h0: begin
              d_pl_valid[0] = ustrm_valid & ustrm_dvalid[0];
              d_pl_data[1*256+:256] = ustrm_data;
              d_pl_crc_valid = ustrm_crc_valid;
              d_pl_crc[1*8+:8] = ustrm_crc[0*8+:8];
            end
            4'h1: begin
              d_pl_valid[0] = 1'b0;
              d_pl_data[0*256+:256] = ustrm_data;
              d_pl_crc_valid = 1'b0;
              d_pl_crc[0*8+:8] = ustrm_crc[0*8+:8];
            end
            default: begin
              d_pl_valid[0] = 1'b0;
              d_pl_data[0*256+:256] = ustrm_data;
              d_pl_crc_valid = 1'b0;
              d_pl_crc[0*8+:8] = ustrm_crc[0*8+:8];
            end
          endcase // case (ustrm_data_beat)
        end
    else if (X4_H1)
      always_comb
        begin
          d_pl_valid      = pl_valid      ;
          d_pl_hold_valid = pl_hold_valid ;
          d_pl_data       = pl_data       ;
          d_pl_crc_valid  = pl_crc_valid  ;
          d_pl_crc        = pl_crc        ;

          case (ustrm_data_beat)
            4'h0: begin
              d_pl_valid[1] = ustrm_valid & ustrm_dvalid[0];
              d_pl_valid[0] = pl_hold_valid[0];
              d_pl_data[3*256+:256] = ustrm_data[0*256+:256];
              d_pl_crc_valid = pl_crc_valid | ustrm_crc_valid;
              d_pl_crc[3*8+:8] = ustrm_crc[0*8+:8];
            end
            4'h1: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_hold_valid[0] = pl_hold_valid[0];
              d_pl_data[2*256+:256] = ustrm_data[0*256+:256];
              d_pl_crc_valid = pl_crc_valid;
              d_pl_crc[2*8+:8] = ustrm_crc[0*8+:8];
            end
            4'h2: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_hold_valid[0] = ustrm_valid & ustrm_dvalid[0];
              d_pl_data[1*256+:256] = ustrm_data[0*256+:256];
              d_pl_crc_valid = ustrm_crc_valid;
              d_pl_crc[1*8+:8] = ustrm_crc[0*8+:8];
            end
            4'h3: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_hold_valid[0] = 2'b0;
              d_pl_data[0*256+:256] = ustrm_data[0*256+:256];
              d_pl_crc_valid = pl_crc_valid;
              d_pl_crc[0*8+:8] = ustrm_crc[0*8+:8];
            end
            default: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_hold_valid[0] = ustrm_valid & ustrm_dvalid[0];
              d_pl_data[0*256+:256] = ustrm_data[0*256+:256];
              d_pl_crc_valid = pl_crc_valid;
              d_pl_crc[0*8+:8] = ustrm_crc[0*8+:8];
            end
          endcase // case (ustrm_data_beat)
        end
    else if (X4_F1)
      always_comb
        begin
          d_pl_valid      = pl_valid      ;
          d_pl_hold_valid = pl_hold_valid ;
          d_pl_data       = pl_data       ;
          d_pl_crc_valid  = pl_crc_valid  ;
          d_pl_crc        = pl_crc        ;

          case (ustrm_data_beat)
            4'h0: begin
              d_pl_valid[0] = ustrm_valid & ustrm_dvalid[0];
              d_pl_data[3*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = ustrm_crc_valid;
              d_pl_crc[3*4+:4] = ustrm_crc[0*4+:4];
            end
            4'h1: begin
              d_pl_valid[0] = 1'b0;
              d_pl_data[2*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = 1'b0;
              d_pl_crc[2*4+:4] = ustrm_crc[0*4+:4];
            end
            4'h2: begin
              d_pl_valid[0] = 1'b0;
              d_pl_data[1*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = 1'b0;
              d_pl_crc[1*4+:4] = ustrm_crc[0*4+:4];
            end
            4'h3: begin
              d_pl_valid[0] = 1'b0;
              d_pl_data[0*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = 1'b0;
              d_pl_crc[0*4+:4] = ustrm_crc[0*4+:4];
            end
            default: begin
              d_pl_valid[0] = 1'b0;
              d_pl_data[0*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = 1'b0;
              d_pl_crc[0*4+:4] = ustrm_crc[0*4+:4];
            end
          endcase // case (ustrm_data_beat)
        end
    else if (X2_H1)
      always_comb
        begin
          d_pl_valid = pl_valid;
          d_pl_hold_valid = pl_hold_valid ;
          d_pl_data = pl_data;
          d_pl_crc_valid = pl_crc_valid;
          d_pl_crc = pl_crc;

          case (ustrm_data_beat)
            4'h0: begin
              d_pl_valid[1] = ustrm_valid & ustrm_dvalid[0];
              d_pl_valid[0] = pl_hold_valid[0];
              d_pl_data[7*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = pl_crc_valid | ustrm_crc_valid;
              d_pl_crc[7*4+:4] = ustrm_crc[0*4+:4];
            end
            4'h1: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_data[6*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = pl_crc_valid;
              d_pl_crc[6*4+:4] = ustrm_crc[0*4+:4];
            end
            4'h2: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_data[5*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = pl_crc_valid;
              d_pl_crc[5*4+:4] = ustrm_crc[0*4+:4];
            end
            4'h3: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_data[4*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = pl_crc_valid;
              d_pl_crc[4*4+:4] = ustrm_crc[0*4+:4];
            end
            4'h4: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_hold_valid[0] = ustrm_valid & ustrm_dvalid[0];
              d_pl_data[3*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = ustrm_crc_valid;
              d_pl_crc[3*4+:4] = ustrm_crc[0*4+:4];
            end
            4'h5: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_data[2*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = pl_crc_valid;
              d_pl_crc[2*4+:4] = ustrm_crc[0*4+:4];
            end
            4'h6: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_data[1*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = pl_crc_valid;
              d_pl_crc[1*4+:4] = ustrm_crc[0*4+:4];
            end
            4'h7: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_data[0*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = pl_crc_valid;
              d_pl_crc[0*4+:4] = ustrm_crc[0*4+:4];
            end
            default: begin
              d_pl_valid[1:0] = 2'b0;
              d_pl_data[0*128+:128] = ustrm_data[0*128+:128];
              d_pl_crc_valid = pl_crc_valid;
              d_pl_crc[0*4+:4] = ustrm_crc[0*4+:4];
            end
          endcase // case (ustrm_data_beat)
        end // always_comb
    else if (X2_F1)
      always_comb
        begin
          d_pl_valid = pl_valid;
          d_pl_hold_valid = pl_hold_valid ;
          d_pl_data = pl_data;
          d_pl_crc_valid = pl_crc_valid;
          d_pl_crc = pl_crc;

          case (ustrm_data_beat)
            4'h0: begin
              d_pl_valid = ustrm_valid & ustrm_dvalid[0];
              d_pl_data[7*64+:64] = ustrm_data;
              d_pl_crc_valid = ustrm_crc_valid;
              d_pl_crc[7*2+:2] = ustrm_crc[1:0];
            end
            4'h1: begin
              d_pl_valid = 1'b0;
              d_pl_data[6*64+:64] = ustrm_data;
              d_pl_crc_valid = 1'b0;
              d_pl_crc[6*2+:2] = ustrm_crc[1:0];
            end
            4'h2: begin
              d_pl_valid = 1'b0;
              d_pl_data[5*64+:64] = ustrm_data;
              d_pl_crc_valid = 1'b0;
              d_pl_crc[5*2+:2] = ustrm_crc[1:0];
            end
            4'h3: begin
              d_pl_valid = 1'b0;
              d_pl_data[4*64+:64] = ustrm_data;
              d_pl_crc_valid = 1'b0;
              d_pl_crc[4*2+:2] = ustrm_crc[1:0];
            end
            4'h4: begin
              d_pl_valid = 1'b0;
              d_pl_data[3*64+:64] = ustrm_data;
              d_pl_crc_valid = ustrm_crc_valid;
              d_pl_crc[3*2+:2] = ustrm_crc[1:0];
            end
            4'h5: begin
              d_pl_valid = 1'b0;
              d_pl_data[2*64+:64] = ustrm_data;
              d_pl_crc_valid = 1'b0;
              d_pl_crc[2*2+:2] = ustrm_crc[1:0];
            end
            4'h6: begin
              d_pl_valid = 1'b0;
              d_pl_data[1*64+:64] = ustrm_data;
              d_pl_crc_valid = 1'b0;
              d_pl_crc[1*2+:2] = ustrm_crc[1:0];
            end
            4'h7: begin
              d_pl_valid = 1'b0;
              d_pl_data[0*64+:64] = ustrm_data;
              d_pl_crc_valid = 1'b0;
              d_pl_crc[0*2+:2] = ustrm_crc[1:0];
            end
            default: begin
              d_pl_valid = 1'b0;
              d_pl_data[0*64+:64] = ustrm_data;
              d_pl_crc_valid = 1'b0;
              d_pl_crc[0*2+:2] = ustrm_crc[1:0];
            end
          endcase // case (ustrm_data_beat)
        end // always_comb
  endgenerate

  // pl_lnk_cfg encodings

  localparam [2:0]
    LNK_CFG_X1	= 3'b000,
    LNK_CFG_X2	= 3'b001,
    LNK_CFG_X4	= 3'b010,
    LNK_CFG_X8	= 3'b011,
    LNK_CFG_X16	= 3'b101;

  logic [2:0]                   d_pl_lnk_cfg;

  generate
    if (X16_Q2 | X16_H2 | X16_F2 | X16_H1 | X16_F1)
      assign d_pl_lnk_cfg = LNK_CFG_X16;
    else if (X8_Q2 | X8_F2 | X8_H2 | X8_H1 | X8_F1)
      assign d_pl_lnk_cfg = LNK_CFG_X8;
    else if (X4_Q2 | X4_H2 | X4_F2 | X4_H1 | X4_F1)
      assign d_pl_lnk_cfg = LNK_CFG_X4;
    else if (X2_H1 | X2_F1)
      assign d_pl_lnk_cfg = LNK_CFG_X2;
    else if (X1_H1 | X1_F1)
      assign d_pl_lnk_cfg = LNK_CFG_X1;
    else
      assign d_pl_lnk_cfg = LNK_CFG_X1;
  endgenerate

  always_ff @(posedge lclk or negedge rst_n)
    if (~rst_n)
      begin
        ustrm_data_beat <= ustrm_data_max_beat;
        ustrm_data_xfr_flg <= 1'b0;
      end
    else
      begin
        ustrm_data_beat <= d_ustrm_data_beat;
        ustrm_data_xfr_flg <= d_ustrm_data_xfr_flg;
      end

  localparam [7:0] /* auto enum protid_info */
    PROTID_CACHE	= 8'h0,
    PROTID_IO		= 8'h1,
    PROTID_ARB_MUX	= 8'h2;

  logic [7:0] /* auto enum protid_info */
              protid;

  /*AUTOASCIIENUM("protid", "protid_ascii", "")*/
  // Beginning of automatic ASCII enum decoding
  reg [111:0]           protid_ascii;           // Decode of protid
  always @(protid) begin
    case ({protid})
      PROTID_CACHE:   protid_ascii = "protid_cache  ";
      PROTID_IO:      protid_ascii = "protid_io     ";
      PROTID_ARB_MUX: protid_ascii = "protid_arb_mux";
      default:        protid_ascii = "%Error        ";
    endcase // case ({protid})
  end
  // End of automatics

  always_comb
    begin : protocol_id
      case (lp_fifo_stream)
        MEM_CACHE_STREAM_ID: protid = PROTID_CACHE;
        IO_STREAM_ID: protid = PROTID_IO;
        ARB_MUX_STREAM_ID: protid = PROTID_ARB_MUX;
        default: MEM_CACHE_STREAM_ID: protid = PROTID_CACHE;
      endcase // case (lp_fifo_stream)
    end

  logic [7:0] pl_stream_int;
  logic [7:0] d_pl_stream;
  assign d_pl_stream = pl_stream_int;

  wire        pl_stream_mem_cache_stream_id = (pl_stream == MEM_CACHE_STREAM_ID);
  wire        pl_stream_io_stream_id = (pl_stream == IO_STREAM_ID);
  wire        pl_stream_arb_mux_stream_id = (pl_stream == ARB_MUX_STREAM_ID);

  always_comb
    begin : pl_stream_id
      case ({6'b0, ustrm_protid})
        PROTID_CACHE: pl_stream_int = MEM_CACHE_STREAM_ID;
        PROTID_IO: pl_stream_int = IO_STREAM_ID;
        PROTID_ARB_MUX: pl_stream_int = ARB_MUX_STREAM_ID;
        default: pl_stream_int = MEM_CACHE_STREAM_ID;
      endcase // case ({6'b0, ustrm_protid})
    end

  // Control State Machine

  localparam [2:0] /* auto enum ctl_state_info */
    CTL_IDLE		= 3'h0,
    CTL_PHY_INIT	= 3'h1,
    CTL_CFG		= 3'h2,
    CTL_CALIB		= 3'h3,
    CTL_WAIT_CA_ALIGN	= 3'h4,
    CTL_LINK_UP		= 3'h5,
    CTL_PHY_ERR		= 3'h6;

  logic [2:0] /* auto enum ctl_state_info */
              ctl_state, d_ctl_state;

  /*AUTOASCIIENUM("ctl_state", "ctl_state_ascii", "")*/
  // Beginning of automatic ASCII enum decoding
  reg [135:0]           ctl_state_ascii;        // Decode of ctl_state
  always @(ctl_state) begin
    case ({ctl_state})
      CTL_IDLE:          ctl_state_ascii = "ctl_idle         ";
      CTL_PHY_INIT:      ctl_state_ascii = "ctl_phy_init     ";
      CTL_CFG:           ctl_state_ascii = "ctl_cfg          ";
      CTL_CALIB:         ctl_state_ascii = "ctl_calib        ";
      CTL_WAIT_CA_ALIGN: ctl_state_ascii = "ctl_wait_ca_align";
      CTL_LINK_UP:       ctl_state_ascii = "ctl_link_up      ";
      CTL_PHY_ERR:       ctl_state_ascii = "ctl_phy_err      ";
      default:           ctl_state_ascii = "%Error           ";
    endcase // case ({ctl_state})
  end
  // End of automatics

  assign ctl_link_up = (ctl_state == CTL_LINK_UP);

  always_ff @(posedge lclk or negedge rst_n)
    if (~rst_n)
      ctl_state <= CTL_IDLE;
    else
      ctl_state <= d_ctl_state;

  always_comb
    begin : ctl_state_next
      d_ctl_state = ctl_state;
      d_ns_mac_rdy = ns_mac_rdy;
      d_ns_adapter_rstn = ns_adapter_rstn;
      d_tx_online = tx_online;
      d_rx_online = rx_online;
      ctl_phy_err = 1'b0;
      case (ctl_state)
        CTL_IDLE: begin
          d_ctl_state = CTL_PHY_INIT;
        end
        CTL_PHY_INIT: begin
          if (i_conf_done)
            begin
              d_ns_mac_rdy = 1'b1;
              d_ctl_state = CTL_CFG;
            end
        end
        CTL_CFG: begin
          d_ns_adapter_rstn = {AIB_LANES{1'b1}};
          d_ctl_state = CTL_CALIB;
        end
        CTL_CALIB: begin
          if (&{ms_tx_transfer_en, sl_tx_transfer_en})
            begin
              d_tx_online = 1'b1;
              d_rx_online = 1'b1;
              d_ctl_state = one_channel ? CTL_LINK_UP : CTL_WAIT_CA_ALIGN;
            end
        end
        CTL_WAIT_CA_ALIGN: begin
          if (align_done)
            d_ctl_state = CTL_LINK_UP;
        end
        CTL_LINK_UP: begin
          if (phy_err)
            d_ctl_state = CTL_PHY_ERR;
        end
        CTL_PHY_ERR: begin
          ctl_phy_err = 1'b1;
        end
        default: d_ctl_state = CTL_IDLE;
      endcase // case (ctl_state)
    end // block: ctl_state_next

  always_ff @(posedge lclk or negedge rst_n)
    begin
      if (~rst_n)
        begin
          dstrm_state <= 4'b0;

          ns_mac_rdy <= 1'b0;
          ns_adapter_rstn <= {AIB_LANES{1'b0}};

          pl_lnk_cfg <= 3'b0;
          pl_speedmode <= 3'b0;

          pl_valid <= {LPIF_VALID_WIDTH{1'b0}};
          pl_hold_valid <= 1'b0;
          pl_data <= {LPIF_DATA_WIDTH*8{1'b0}};
          pl_crc_valid <= 1'b0;
          pl_crc <= {LPIF_CRC_WIDTH{1'b0}};
          pl_stream <= 8'b0;

         tx_online <= 1'b0;
          rx_online <= 1'b0;
        end
      else
        begin
          dstrm_state <= lsm_dstrm_state;

          ns_mac_rdy <= d_ns_mac_rdy;
          ns_adapter_rstn <= d_ns_adapter_rstn;

          pl_lnk_cfg <= d_pl_lnk_cfg;
          pl_speedmode <= lsm_speedmode;

          pl_valid <= d_pl_valid;
          pl_hold_valid <= d_pl_hold_valid;
          pl_data <= d_pl_data;
          pl_crc_valid <= d_pl_crc_valid;
          pl_crc <= d_pl_crc;
          pl_stream <= d_pl_stream;

          tx_online <= d_tx_online;
          rx_online <= d_rx_online;
        end
    end // always_ff @ (posedge lclk or negedge rst_n)

  genvar   i_ptm_delay;
  generate
    logic [0:0] lp_tmstmp_delay        [0:PTM_RX_DELAY-1+1]; // PTM_RX_DELAY depth + 1 for the initial value
    logic [7:0] lp_tmstmp_stream_delay [0:PTM_RX_DELAY-1+1]; // PTM_RX_DELAY depth + 1 for the initial value

    assign lp_tmstmp_delay        [0] = lp_tmstmp;
    assign lp_tmstmp_stream_delay [0] = lp_tmstmp_stream;

    assign pl_tmstmp        = lp_tmstmp_delay        [PTM_RX_DELAY];
    assign pl_tmstmp_stream = lp_tmstmp_stream_delay [PTM_RX_DELAY];

    for (i_ptm_delay = 0; i_ptm_delay < PTM_RX_DELAY; i_ptm_delay++)
      begin : gen_blk_ptm_delay

        always_ff @(posedge lclk or negedge rst_n)
          begin
            if (~rst_n)
              begin
                lp_tmstmp_delay        [i_ptm_delay+1] <= 1'b0;
                lp_tmstmp_stream_delay [i_ptm_delay+1] <= 8'b0;
              end
            else
              begin
                lp_tmstmp_delay        [i_ptm_delay+1] <= lp_tmstmp_delay        [i_ptm_delay];
                lp_tmstmp_stream_delay [i_ptm_delay+1] <= lp_tmstmp_stream_delay [i_ptm_delay];
              end
          end
      end
  endgenerate

  // This is logically what the ptm_rx_delay does, but lint didn't like the code.
  // So we recoded using the below logic.
  //  localparam LPIF_CLOCK_PERIOD = 1_000_000 / LPIF_CLOCK_RATE; // This converts Freq expressed in 1MHz to ps
  //  assign pl_ptm_rx_delay = (PTM_RX_DELAY * LPIF_CLOCK_PERIOD)/1000;
  assign pl_ptm_rx_delay = (LPIF_CLOCK_RATE == 500)  ? (PTM_RX_DELAY<<1) :
                           (LPIF_CLOCK_RATE == 1000) ? (PTM_RX_DELAY   ) :
                                                       (PTM_RX_DELAY>>1) ;


  assign lp_fifo_wrdata = {lp_data,      lp_crc,      lp_crc_valid,      lp_valid,      lp_stream};
  assign                  {lp_fifo_data, lp_fifo_crc, lp_fifo_crc_valid, lp_fifo_valid, lp_fifo_stream} =  lp_fifo_rddata;

  assign lp_fifo_push = lp_trans_valid & pl_trdy;

  assign lp_fifo_pop = clear_to_tx & lp_datbeat_is_0;


  //////////////////////////////////////////////////////////////////////////////
  // Schedule Start of Transmission

  // For all G2F cases, we want to handle the case where the link layer sends us 1/2 of the flit and then waits
  // a significant time before it sends us the other half. To do this, we'll keep track of the number of
  // 1/2 flits being pushed into the FIFO. If we have only half a flit in FIFO, we wait until
  // get the other half, or have at least one full flit int he FIFO.

  generate
    if (G2F)
    begin
      always_ff @(posedge lclk or negedge rst_n)
      if (~rst_n)
        dstrm_fifo_has_half_flit <= 1'b0;
      else if (lp_fifo_push)
        dstrm_fifo_has_half_flit <= ~dstrm_fifo_has_half_flit;

      assign hold_start_tx_due_to_half_flit = (lp_fifo_numfilled >= 2) ? 1'b0 :
                                              (lp_fifo_numfilled == 1) ? (dstrm_fifo_has_half_flit & (~lp_fifo_push)) : 1'b1;
    end
    else
    begin
      assign dstrm_fifo_has_half_flit = 1'b0;
      assign hold_start_tx_due_to_half_flit = 1'b0;
    end
  endgenerate



  //  X8 should have at least 2 "tx markers" between transmission to make sure we don't
  //  send half a flit on the tail end of a previous transmission (i.e. in F2Q we use 4
  //  beats of Full to form one Quarter word). If link layer sends us one full flit, and
  //  waits 1 cycle to send us  second full flit, we'll end up sending the second flit
  //  partially in the first quarter word and partially in the second. Easiest wayt to
  //  handle this is to not schedule new transmissions until we are aligned to an integer
  //  number of margers. For x8, that is 2 markers.
  //  For x4, but 4 markers.
  //  x16 has not restrictions.

  generate
    if (G2X16 | G1X16)
    begin
      assign tx_marker_counter = 3'h0;
    end
    else if (G2X8 | G1X8)
    begin
      always_ff @(posedge lclk or negedge rst_n)
      if (~rst_n)
        tx_marker_counter <= 3'h0;
      else if ((tx_mrk_userbit_vld == 1'b1) && (tx_marker_counter == 0) && (~d_aib_aligned_to_tx))
        tx_marker_counter <= 3'h0;
      else if ((tx_mrk_userbit_vld == 1'b1) && (tx_marker_counter == 3'h1))
        tx_marker_counter <= 3'h0;
      else if (tx_mrk_userbit_vld == 1'b1)
        tx_marker_counter <= tx_marker_counter + 3'h1;
    end
    else if (G2X4 | G1X4)
    begin
      always_ff @(posedge lclk or negedge rst_n)
      if (~rst_n)
        tx_marker_counter <= 3'h0;
      else if ((tx_mrk_userbit_vld == 1'b1) && (tx_marker_counter == 0) && (~d_aib_aligned_to_tx))
        tx_marker_counter <= 3'h0;
      else if ((tx_mrk_userbit_vld == 1'b1) && (tx_marker_counter == 3'h3))
        tx_marker_counter <= 3'h0;
      else if (tx_mrk_userbit_vld == 1'b1)
        tx_marker_counter <= tx_marker_counter + 3'h1;
    end
    else if (G1X2)
    begin
      always_ff @(posedge lclk or negedge rst_n)
      if (~rst_n)
        tx_marker_counter <= 3'h0;
      else if ((tx_mrk_userbit_vld == 1'b1) && (tx_marker_counter == 0) && (~d_aib_aligned_to_tx))
        tx_marker_counter <= 3'h0;
      else if ((tx_mrk_userbit_vld == 1'b1) && (tx_marker_counter == 3'h7))
        tx_marker_counter <= 3'h0;
      else if (tx_mrk_userbit_vld == 1'b1)
        tx_marker_counter <= tx_marker_counter + 3'h1;
    end

  endgenerate

  assign hold_start_tx_due_to_marker = (tx_marker_counter != 0);



  // We evaluate the aib_aligned_to_tx when the marker bit is high, so we can
  // begin transmission on the next cycle with the lsbeat of the remote side AIB word.
  always_comb
  if (lp_fifo_pop & (~lp_fifo_push) && (lp_fifo_numfilled == 1))
    d_aib_aligned_to_tx = 1'b0;
  else if (tx_mrk_userbit_vld & (~hold_start_tx_due_to_marker) & (~hold_start_tx_due_to_half_flit))
    d_aib_aligned_to_tx = (lp_fifo_push || ~lp_fifo_empty);
  else
    d_aib_aligned_to_tx = aib_aligned_to_tx;

  always_ff @(posedge lclk or negedge rst_n)
  if (~rst_n)
    aib_aligned_to_tx <= 1'b0;
  else
    aib_aligned_to_tx <= d_aib_aligned_to_tx;


  assign clear_to_tx = aib_aligned_to_tx;

  // Schedule Transmission
  //////////////////////////////////////////////////////////////////////////////




  /* syncfifo_reg AUTO_TEMPLATE (
   .FIFO_WIDTH_WID  (LP_FIFO_WIDTH),
   .FIFO_DEPTH_WID  (LP_FIFO_DEPTH),
   .clk_core        (lclk),
   .rst_core_n      (rst_n),
   .soft_reset      (1'b0),
   .rddata          (lp_fifo_rddata[]),
   .numfilled       (lp_fifo_numfilled[]),
   .numempty        (lp_fifo_numempty[]),
   .wrdata          (lp_fifo_wrdata[]),
   .write_push      (lp_fifo_push),
   .read_pop        (lp_fifo_pop),
   .full            (lp_fifo_full),
   .empty           (lp_fifo_empty),
   .overflow_pulse  (lp_fifo_overflow_pulse),
   .underflow_pulse (lp_fifo_underflow_pulse),
   ); */

  syncfifo_reg
    #(/*AUTOINSTPARAM*/
      // Parameters
      .FIFO_WIDTH_WID                   (LP_FIFO_WIDTH),         // Templated
      .FIFO_DEPTH_WID                   (LP_FIFO_DEPTH))         // Templated
  syncfifo_i
    (/*AUTOINST*/
     // Outputs
     .rddata                            (lp_fifo_rddata[FIFO_WIDTH_MSB:0]), // Templated
     .numfilled                         (lp_fifo_numfilled[FIFO_COUNT_MSB:0]), // Templated
     .numempty                          (lp_fifo_numempty[FIFO_COUNT_MSB:0]), // Templated
     .full                              (lp_fifo_full),          // Templated
     .empty                             (lp_fifo_empty),         // Templated
     .overflow_pulse                    (lp_fifo_overflow_pulse), // Templated
     .underflow_pulse                   (lp_fifo_underflow_pulse), // Templated
     // Inputs
     .clk_core                          (lclk),                  // Templated
     .rst_core_n                        (rst_n),                 // Templated
     .soft_reset                        (1'b0),                  // Templated
     .write_push                        (lp_fifo_push),          // Templated
     .wrdata                            (lp_fifo_wrdata[FIFO_WIDTH_MSB:0]), // Templated
     .read_pop                          (lp_fifo_pop));           // Templated

  // dstrm generation

  generate
    if (X16_Q2 | X16_H2 | X16_F2 | X16_F1 | X16_H1)
      begin
        always_comb
          begin
            if (lp_fifo_pop)
              begin
                dstrm_valid = 1'b1;
                dstrm_dvalid = lp_fifo_valid & {LPIF_VALID_WIDTH{clear_to_tx}};
                dstrm_data = lp_fifo_data;
                dstrm_crc_valid = lp_fifo_crc_valid & clear_to_tx;
                dstrm_crc = lp_fifo_crc;
                dstrm_protid = protid[1:0];
              end
            else
              begin
                dstrm_valid = 1'b0;
                dstrm_dvalid = {LPIF_VALID_WIDTH{1'b0}};
                dstrm_data = {LPIF_VALID_WIDTH*8{1'b0}};
                dstrm_crc_valid = 1'b0;
                dstrm_crc = {LPIF_CRC_WIDTH{1'b0}};
                dstrm_protid = 2'b0;
              end
          end
      end
    else if (X8_Q2)
      begin
        always_comb
          begin
            dstrm_valid = |lp_fifo_valid & clear_to_tx;
            dstrm_protid = protid[1:0];

            case (lp_data_beat)
              4'h0: begin
                dstrm_dvalid = lp_fifo_valid[1];
                dstrm_data = lp_fifo_data[1*512+:512];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[1*16+:16];
              end
              4'h1: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[0*512+:512];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[0*16+:16];
              end
              default: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[0*512+:512];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[0*16+:16];
              end
            endcase // case (lp_data_beat)
          end
      end
    else if (X8_H2)
      begin
        always_comb
          begin
            dstrm_valid = |lp_fifo_valid & clear_to_tx;
            dstrm_protid = protid[1:0];

            case (lp_data_beat)
              4'h0: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[1*256+:256];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[0*16+:16]; // We purposely replicated the CRC (index=0*16 is correct)
              end
              4'h1: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[0*256+:256];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[0*16+:16];
              end
              default: begin
                dstrm_dvalid = 1'b0;
                dstrm_data = lp_fifo_data[0*256+:256];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[0*16+:16];
              end
            endcase // case (lp_data_beat)
          end
      end
    else if (X8_F2)
      begin
        always_comb
          begin
            dstrm_valid = |lp_fifo_valid & clear_to_tx;
            dstrm_protid = protid[1:0];

            case (lp_data_beat)
              4'h0: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[1*128+:128];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[1*8+:8];
              end
              4'h1: begin
                dstrm_dvalid = 1'b0;
                dstrm_data = lp_fifo_data[0*128+:128];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[0*8+:8];
              end
              default: begin
                dstrm_dvalid = 1'b0;
                dstrm_data = lp_fifo_data[0*128+:128];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[0*8+:8];
              end
            endcase // case (lp_data_beat)
          end
      end
    else if (X4_Q2)
      begin
        always_comb
          begin
            dstrm_valid = |lp_fifo_valid & clear_to_tx;
            dstrm_protid = protid[1:0];

            case (lp_data_beat)
              4'h0: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[1]};
                dstrm_data = lp_fifo_data[3*256+:256];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[1*16+:16];
              end
              4'h1: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[1]};
                dstrm_data = lp_fifo_data[2*256+:256];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = 16'h0;
              end
              4'h2: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[0]};
                dstrm_data = lp_fifo_data[1*256+:256];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[0*16+:16];
              end
              4'h3: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[0]};
                dstrm_data = lp_fifo_data[0*256+:256];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = 16'h0;
              end
              default: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[0]};
                dstrm_data = lp_fifo_data[0*256+:256];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = 16'h0;
              end
            endcase // case (lp_data_beat)
          end
      end
    else if (X4_H2)
      begin
        always_comb
          begin
            dstrm_valid = |lp_fifo_valid & clear_to_tx;
            dstrm_protid = protid[1:0];

            case (lp_data_beat)
              4'h0: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[3*128+:128];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[1*8+:8];
              end
              4'h1: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[2*128+:128];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[0*8+:8];
              end
              4'h2: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[1*128+:128];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = 8'h0;
              end
              4'h3: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[0*128+:128];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = 8'h0;
              end
              default: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[0*128+:128];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = 8'h0;
              end
            endcase // case (lp_data_beat)
          end
      end
    else if (X4_F2)
      begin
        always_comb
          begin
            dstrm_valid = |lp_fifo_valid & clear_to_tx;
            dstrm_protid = protid[1:0];

            case (lp_data_beat)
              4'h0: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[3*64+:64];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[3*4+:4];
              end
              4'h1: begin
                dstrm_dvalid = 1'b0;
                dstrm_data = lp_fifo_data[2*64+:64];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[2*4+:4];
              end
              4'h2: begin
                dstrm_dvalid = 1'b0;
                dstrm_data = lp_fifo_data[1*64+:64];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[1*4+:4];
              end
              4'h3: begin
                dstrm_dvalid = 1'b0;
                dstrm_data = lp_fifo_data[0*64+:64];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[0*4+:4];
              end
              default: begin
                dstrm_dvalid = 1'b0;
                dstrm_data = lp_fifo_data[0*64+:64];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[0*4+:4];
              end
            endcase // case (lp_data_beat)
          end
      end
    else if (X8_H1)
      begin
        always_comb
          begin
            dstrm_valid = |lp_fifo_valid & clear_to_tx;
            dstrm_protid = protid[1:0];

            case (lp_data_beat)
              4'h0: begin
                dstrm_dvalid = lp_fifo_valid[1];
                dstrm_data = lp_fifo_data[1*512+:512];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[1*16+:16];
              end
              4'h1: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[0*512+:512];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[0*16+:16];
              end
              default: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[0*512+:512];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[0*16+:16];
              end
            endcase // case (lp_data_beat)
          end
      end
    else if (X8_F1)
      begin
        always_comb
          begin
            dstrm_valid = |lp_fifo_valid & clear_to_tx;
            dstrm_protid = protid[1:0];

            case (lp_data_beat)
              4'h0: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[1*256+:256];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[1*8+:8];
              end
              4'h1: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[0*256+:256];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[0*8+:8];
              end
              default: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[0*256+:256];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[0*8+:8];
              end
            endcase // case (lp_data_beat)
          end
      end
    else if (X4_H1)
      begin
        always_comb
          begin
            dstrm_valid = |lp_fifo_valid & clear_to_tx;
            dstrm_protid = protid[1:0];

            case (lp_data_beat)
              4'h0: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[1]};
                dstrm_data = lp_fifo_data[3*256+:256];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[3*8+:8];
              end
              4'h1: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[1]};
                dstrm_data = lp_fifo_data[2*256+:256];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[2*8+:8];
              end
              4'h2: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[0]};
                dstrm_data = lp_fifo_data[1*256+:256];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[1*8+:8];
              end
              4'h3: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[0]};
                dstrm_data = lp_fifo_data[0*256+:256];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[0*8+:8];
              end
              default: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[0]};
                dstrm_data = lp_fifo_data[0*256+:256];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[0*8+:8];
              end
            endcase // case (lp_data_beat)
          end
      end
    else if (X4_F1)
      begin
        always_comb
          begin
            dstrm_valid = |lp_fifo_valid & clear_to_tx;
            dstrm_protid = protid[1:0];

            case (lp_data_beat)
              4'h0: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[3*128+:128];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[3*4+:4];
              end
              4'h1: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[2*128+:128];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[2*4+:4];
              end
              4'h2: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[1*128+:128];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[1*4+:4];
              end
              4'h3: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[0*128+:128];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[0*4+:4];
              end
              default: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[0*128+:128];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = 4'h0;
              end
            endcase // case (lp_data_beat)
          end
      end
     else if (X2_H1)
       begin
        always_comb
          begin
            dstrm_valid = |lp_fifo_valid & clear_to_tx;
            dstrm_protid = protid[1:0];

            case (lp_data_beat)
              4'h0: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[1]};
                dstrm_data = lp_fifo_data[7*128+:128];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[7*4+:4];
              end
              4'h1: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[1]};
                dstrm_data = lp_fifo_data[6*128+:128];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[6*4+:4];
              end
              4'h2: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[1]};
                dstrm_data = lp_fifo_data[5*128+:128];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[5*4+:4];
              end
              4'h3: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[1]};
                dstrm_data = lp_fifo_data[4*128+:128];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[4*4+:4];
              end
              4'h4: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[0]};
                dstrm_data = lp_fifo_data[3*128+:128];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[3*4+:4];
              end
              4'h5: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[0]};
                dstrm_data = lp_fifo_data[2*128+:128];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[2*4+:4];
              end
              4'h6: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[0]};
                dstrm_data = lp_fifo_data[1*128+:128];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[1*4+:4];
              end
              4'h7: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[0]};
                dstrm_data = lp_fifo_data[0*128+:128];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[0*4+:4];
              end
              default: begin
                dstrm_dvalid = {1'b0, lp_fifo_valid[0]};
                dstrm_data = lp_fifo_data[0*128+:128];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[0*4+:4];
              end
            endcase // case (lp_data_beat)
          end // always_comb
       end // if (X2_H1)
     else if (X2_F1)
       begin
        always_comb
          begin
            dstrm_valid = |lp_fifo_valid & clear_to_tx;
            dstrm_protid = protid[1:0];

            case (lp_data_beat)
              4'h0: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[7*64+:64];
                dstrm_crc_valid = lp_fifo_crc_valid;
                dstrm_crc = lp_fifo_crc[7*2+:2];
              end
              4'h1: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[6*64+:64];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[6*2+:2];
              end
              4'h2: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[5*64+:64];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[5*2+:2];
              end
              4'h3: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[4*64+:64];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[4*2+:2];
              end
              4'h4: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[3*64+:64];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[3*2+:2];
              end
              4'h5: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[2*64+:64];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[2*2+:2];
              end
              4'h6: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[1*64+:64];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[1*2+:2];
              end
              4'h7: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[0*64+:64];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[0*2+:2];
              end
              default: begin
                dstrm_dvalid = lp_fifo_valid[0];
                dstrm_data = lp_fifo_data[0*64+:64];
                dstrm_crc_valid = 1'b0;
                dstrm_crc = lp_fifo_crc[0*2+:2];
              end
            endcase // case (lp_data_beat)
          end // always_comb
       end // if (X2_F1)
  endgenerate

endmodule // lpif_ctl

// Local Variables:
// verilog-library-directories:("." "${PROJ_DIR}/common/rtl")
// verilog-auto-inst-param-value:t
// End:
