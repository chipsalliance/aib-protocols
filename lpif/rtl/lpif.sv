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
// Functional Descript: LPIF Adapter IP
//
//
//
////////////////////////////////////////////////////////////

module lpif
    #(
      parameter AIB_VERSION = 2,
      parameter AIB_GENERATION = 2,
      parameter AIB_LANES = 4,
      parameter AIB_BITS_PER_LANE = 320,
      parameter AIB_CLOCK_RATE = 1000,
      parameter LPIF_CLOCK_RATE = 1000,
      parameter LPIF_DATA_WIDTH = 128,
      parameter LPIF_PIPELINE_STAGES = 1,
      parameter MEM_CACHE_STREAM_ID = 8'h1,
      parameter IO_STREAM_ID = 8'h2,
      parameter ARB_MUX_STREAM_ID = 8'h3,
      localparam LPIF_VALID_WIDTH = ((LPIF_DATA_WIDTH == 128) ? 2 : 1),
      localparam LPIF_CRC_WIDTH = ((LPIF_DATA_WIDTH == 128) ? 32 : 16)
      )
  (
   // LPIF Interface
   input logic                                      lclk,
   input logic                                      reset,

   output logic                                     pl_trdy,
   output logic [LPIF_DATA_WIDTH*8-1:0]             pl_data,
   output logic [LPIF_VALID_WIDTH-1:0]              pl_valid,
   output logic [7:0]                               pl_stream,
   output logic                                     pl_error,
   output logic                                     pl_trainerror,
   output logic                                     pl_cerror,
   output logic                                     pl_stallreq,
   output logic                                     pl_tmstmp,
   output logic [7:0]                               pl_tmstmp_stream,
   output logic                                     pl_phyinl1,
   output logic                                     pl_phyinl2,

   input logic                                      lp_irdy,
   input logic [LPIF_DATA_WIDTH*8-1:0]              lp_data,
   input logic [LPIF_VALID_WIDTH-1:0]               lp_valid,
   input logic [7:0]                                lp_stream,
   input logic                                      lp_stallack,
   input logic [3:0]                                lp_state_req,
   output logic [3:0]                               pl_state_sts,
   input logic                                      lp_tmstmp,
   input logic                                      lp_linkerror,
   output logic                                     pl_quiesce,
   input logic                                      lp_flushed_all,
   input logic                                      lp_rcvd_crc_err,
   output logic [2:0]                               pl_lnk_cfg,
   output logic                                     pl_lnk_up,
   output logic                                     pl_rxframe_errmask,
   output logic                                     pl_portmode,
   output logic                                     pl_portmode_val,
   output logic [2:0]                               pl_speedmode,
   output logic [2:0]                               pl_clr_lnkeqreq,
   output logic [2:0]                               pl_set_lnkeqreq,
   output logic                                     pl_inband_pres,
   output logic [7:0]                               pl_ptm_rx_delay,
   output logic                                     pl_setlabs,
   output logic                                     pl_setlbms,
   output logic                                     pl_surprise_lnk_down,
   output logic [2:0]                               pl_protocol,
   output logic                                     pl_protocol_vld,
   output logic                                     pl_err_pipestg,
   input logic                                      lp_wake_req,
   output logic                                     pl_wake_ack,
   input logic                                      lp_force_detect,
   output logic                                     pl_phyinrecenter,
   output logic                                     pl_exit_cg_req,
   input logic                                      lp_exit_cg_ack,
   output logic [7:0]                               pl_cfg,
   output logic                                     pl_cfg_vld,
   input logic [7:0]                                lp_cfg,
   input logic                                      lp_cfg_vld,

   output logic [LPIF_CRC_WIDTH-1:0]                pl_crc,
   output logic [LPIF_VALID_WIDTH-1:0]              pl_crc_valid,
   input logic [LPIF_CRC_WIDTH-1:0]                 lp_crc,
   input logic [LPIF_VALID_WIDTH-1:0]               lp_crc_valid,
   input logic                                      lp_device_present,
   output logic                                     pl_clk_req,
   input logic                                      lp_clk_ack,
   input logic [1:0]                                lp_pri,

   // AIB Interface
   input logic                                      m_wr_clk,
   output logic [(AIB_LANES*AIB_BITS_PER_LANE)-1:0] data_in_f,
   output logic                                     ns_mac_rdy,
   input logic                                      fs_mac_rdy,
   output logic [AIB_LANES-1:0]                     ns_adapter_rstn,
   input logic [AIB_LANES-1:0]                      sl_rx_transfer_en,
   input logic [AIB_LANES-1:0]                      ms_tx_transfer_en,
   input logic [AIB_LANES-1:0]                      ms_rx_transfer_en,
   input logic [AIB_LANES-1:0]                      sl_tx_transfer_en,
   input logic [AIB_LANES-1:0]                      m_rxfifo_align_done,
   input logic [AIB_LANES-1:0]                      wa_error,
   input logic [AIB_LANES-1:0]                      wa_error_cnt,
   input logic                                      dual_mode_select,
   input logic                                      m_gen2_mode,
   input logic                                      i_conf_done,
   input logic [AIB_LANES-1:0]                      power_on_reset,
   input logic                                      com_clk,
   input logic [(AIB_LANES*AIB_BITS_PER_LANE)-1:0]  dout,
   input logic                                      rst_n,

   // Channel Alignment
   input logic                                      align_done,
   input logic                                      align_err,
   input logic                                      fifo_full,
   input logic                                      fifo_pfull,
   input logic                                      fifo_empty,
   input logic                                      fifo_pempty,
   output logic                                     align_fly,
   output logic [7:0]                               tx_stb_wd_sel,
   output logic [39:0]                              tx_stb_bit_sel,
   output logic [7:0]                               tx_stb_intv,
   output logic [7:0]                               rx_stb_wd_sel,
   output logic [39:0]                              rx_stb_bit_sel,
   output logic [7:0]                               rx_stb_intv,
   output logic [4:0]                               fifo_full_val,
   output logic [4:0]                               fifo_pfull_val,
   output logic [2:0]                               fifo_empty_val,
   output logic [2:0]                               fifo_pempty_val,
   output logic [2:0]                               rden_dly,

   output logic                                     tx_online,
   output logic                                     rx_online,
   input logic [7:0]                                delay_x_value,
   input logic [7:0]                                delay_xz_value,
   input logic [7:0]                                delay_yz_value,

   input logic                                      lpbk_en
   );

  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  logic                 ctl_link_up;            // From lpif_ctl_i of lpif_ctl.v
  logic [(AIB_LANES*AIB_BITS_PER_LANE)-1:0] dout_lpbk;// From lpif_lpbk_i of lpif_lpbk.v
  logic [LPIF_CRC_WIDTH-1:0] dstrm_crc;         // From lpif_ctl_i of lpif_ctl.v
  logic [LPIF_VALID_WIDTH-1:0] dstrm_crc_valid; // From lpif_ctl_i of lpif_ctl.v
  logic [1023:0]        dstrm_data;             // From lpif_ctl_i of lpif_ctl.v
  logic [LPIF_VALID_WIDTH-1:0] dstrm_dvalid;    // From lpif_ctl_i of lpif_ctl.v
  logic [1:0]           dstrm_protid;           // From lpif_ctl_i of lpif_ctl.v
  logic [3:0]           dstrm_state;            // From lpif_ctl_i of lpif_ctl.v
  logic                 dstrm_valid;            // From lpif_ctl_i of lpif_ctl.v
  logic [3:0]           lsm_dstrm_state;        // From lpif_lsm_i of lpif_lsm.v
  logic [2:0]           lsm_lnk_cfg;            // From lpif_lsm_i of lpif_lsm.v
  logic [2:0]           lsm_speedmode;          // From lpif_lsm_i of lpif_lsm.v
  logic                 lsm_state_active;       // From lpif_lsm_i of lpif_lsm.v
  logic [31:0]          rx_upstream_debug_status;// From lpif_txrx_i of lpif_txrx.v
  logic [31:0]          tx_downstream_debug_status;// From lpif_txrx_i of lpif_txrx.v
  logic [LPIF_CRC_WIDTH-1:0] ustrm_crc;         // From lpif_txrx_i of lpif_txrx.v
  logic [LPIF_VALID_WIDTH-1:0] ustrm_crc_valid; // From lpif_txrx_i of lpif_txrx.v
  logic [1023:0]        ustrm_data;             // From lpif_txrx_i of lpif_txrx.v
  logic [LPIF_VALID_WIDTH-1:0] ustrm_dvalid;    // From lpif_txrx_i of lpif_txrx.v
  logic [1:0]           ustrm_protid;           // From lpif_txrx_i of lpif_txrx.v
  logic [3:0]           ustrm_state;            // From lpif_txrx_i of lpif_txrx.v
  logic                 ustrm_valid;            // From lpif_txrx_i of lpif_txrx.v
  // End of automatics

  assign pl_clk_req = 1'b0; // FIX THIS

  logic [319:0]                                     tx_phy0, tx_phy1, tx_phy2, tx_phy3;
  logic [319:0]                                     tx_phy4, tx_phy5, tx_phy6, tx_phy7;
  logic [319:0]                                     tx_phy8, tx_phy9, tx_phy10, tx_phy11;
  logic [319:0]                                     tx_phy12, tx_phy13, tx_phy14, tx_phy15;

  logic [319:0]                                     rx_phy0, rx_phy1, rx_phy2, rx_phy3;
  logic [319:0]                                     rx_phy4, rx_phy5, rx_phy6, rx_phy7;
  logic [319:0]                                     rx_phy8, rx_phy9, rx_phy10, rx_phy11;
  logic [319:0]                                     rx_phy12, rx_phy13, rx_phy14, rx_phy15;

  generate
    always_comb
      begin : phy_sigs
        rx_phy15 = '0;
        rx_phy14 = '0;
        rx_phy13 = '0;
        rx_phy12 = '0;
        rx_phy11 = '0;
        rx_phy10 = '0;
        rx_phy9 = '0;
        rx_phy8 = '0;
        rx_phy7 = '0;
        rx_phy6 = '0;
        rx_phy5 = '0;
        rx_phy4 = '0;
        rx_phy3 = '0;
        rx_phy2 = '0;
        rx_phy1 = '0;
        rx_phy0 = '0;

        if (AIB_LANES == 4)
          begin
            data_in_f = {
                         tx_phy3[0+:AIB_BITS_PER_LANE],
                         tx_phy2[0+:AIB_BITS_PER_LANE],
                         tx_phy1[0+:AIB_BITS_PER_LANE],
                         tx_phy0[0+:AIB_BITS_PER_LANE]
                         };
            {
             rx_phy3[0+:AIB_BITS_PER_LANE],
             rx_phy2[0+:AIB_BITS_PER_LANE],
             rx_phy1[0+:AIB_BITS_PER_LANE],
             rx_phy0[0+:AIB_BITS_PER_LANE]
             }
              = dout_lpbk;
          end
        else if (AIB_LANES == 16)
          begin
            data_in_f = {
                         tx_phy15[0+:AIB_BITS_PER_LANE],
                         tx_phy14[0+:AIB_BITS_PER_LANE],
                         tx_phy13[0+:AIB_BITS_PER_LANE],
                         tx_phy12[0+:AIB_BITS_PER_LANE],
                         tx_phy11[0+:AIB_BITS_PER_LANE],
                         tx_phy10[0+:AIB_BITS_PER_LANE],
                         tx_phy9[0+:AIB_BITS_PER_LANE],
                         tx_phy8[0+:AIB_BITS_PER_LANE],
                         tx_phy7[0+:AIB_BITS_PER_LANE],
                         tx_phy6[0+:AIB_BITS_PER_LANE],
                         tx_phy5[0+:AIB_BITS_PER_LANE],
                         tx_phy4[0+:AIB_BITS_PER_LANE],
                         tx_phy3[0+:AIB_BITS_PER_LANE],
                         tx_phy2[0+:AIB_BITS_PER_LANE],
                         tx_phy1[0+:AIB_BITS_PER_LANE],
                         tx_phy0[0+:AIB_BITS_PER_LANE]
                         };
            {
             rx_phy15[0+:AIB_BITS_PER_LANE],
             rx_phy14[0+:AIB_BITS_PER_LANE],
             rx_phy13[0+:AIB_BITS_PER_LANE],
             rx_phy12[0+:AIB_BITS_PER_LANE],
             rx_phy11[0+:AIB_BITS_PER_LANE],
             rx_phy10[0+:AIB_BITS_PER_LANE],
             rx_phy9[0+:AIB_BITS_PER_LANE],
             rx_phy8[0+:AIB_BITS_PER_LANE],
             rx_phy7[0+:AIB_BITS_PER_LANE],
             rx_phy6[0+:AIB_BITS_PER_LANE],
             rx_phy5[0+:AIB_BITS_PER_LANE],
             rx_phy4[0+:AIB_BITS_PER_LANE],
             rx_phy3[0+:AIB_BITS_PER_LANE],
             rx_phy2[0+:AIB_BITS_PER_LANE],
             rx_phy1[0+:AIB_BITS_PER_LANE],
             rx_phy0[0+:AIB_BITS_PER_LANE]
             }
              = dout_lpbk;
          end
      end // block: phy_sigs
  endgenerate

  /* TX & RX datapath */

  /* lpif_txrx AUTO_TEMPLATE (
   .clk_wr                 (com_clk),
   .rst_wr_n               (~reset),
   .init_downstream_credit (8'hff),
   .tx_mrk_userbit         (4'b0), // FIX THIS
   .tx_stb_userbit         (1'b0), // FIX THIS
   ); */

  lpif_txrx
    #(/*AUTOINSTPARAM*/
      // Parameters
      .AIB_VERSION                      (AIB_VERSION),
      .AIB_GENERATION                   (AIB_GENERATION),
      .LPIF_DATA_WIDTH                  (LPIF_DATA_WIDTH),
      .LPIF_CLOCK_RATE                  (LPIF_CLOCK_RATE))
  lpif_txrx_i
    (/*AUTOINST*/
     // Outputs
     .tx_phy0                           (tx_phy0[319:0]),
     .tx_phy1                           (tx_phy1[319:0]),
     .tx_phy2                           (tx_phy2[319:0]),
     .tx_phy3                           (tx_phy3[319:0]),
     .tx_phy4                           (tx_phy4[319:0]),
     .tx_phy5                           (tx_phy5[319:0]),
     .tx_phy6                           (tx_phy6[319:0]),
     .tx_phy7                           (tx_phy7[319:0]),
     .tx_phy8                           (tx_phy8[319:0]),
     .tx_phy9                           (tx_phy9[319:0]),
     .tx_phy10                          (tx_phy10[319:0]),
     .tx_phy11                          (tx_phy11[319:0]),
     .tx_phy12                          (tx_phy12[319:0]),
     .tx_phy13                          (tx_phy13[319:0]),
     .tx_phy14                          (tx_phy14[319:0]),
     .tx_phy15                          (tx_phy15[319:0]),
     .ustrm_state                       (ustrm_state[3:0]),
     .ustrm_protid                      (ustrm_protid[1:0]),
     .ustrm_data                        (ustrm_data[1023:0]),
     .ustrm_dvalid                      (ustrm_dvalid[LPIF_VALID_WIDTH-1:0]),
     .ustrm_crc                         (ustrm_crc[LPIF_CRC_WIDTH-1:0]),
     .ustrm_crc_valid                   (ustrm_crc_valid[LPIF_VALID_WIDTH-1:0]),
     .ustrm_valid                       (ustrm_valid),
     .rx_upstream_debug_status          (rx_upstream_debug_status[31:0]),
     .tx_downstream_debug_status        (tx_downstream_debug_status[31:0]),
     // Inputs
     .com_clk                           (com_clk),
     .rst_n                             (rst_n),
     .tx_online                         (tx_online),
     .rx_online                         (rx_online),
     .m_gen2_mode                       (m_gen2_mode),
     .delay_x_value                     (delay_x_value[7:0]),
     .delay_xz_value                    (delay_xz_value[7:0]),
     .delay_yz_value                    (delay_yz_value[7:0]),
     .rx_phy0                           (rx_phy0[319:0]),
     .rx_phy1                           (rx_phy1[319:0]),
     .rx_phy2                           (rx_phy2[319:0]),
     .rx_phy3                           (rx_phy3[319:0]),
     .rx_phy4                           (rx_phy4[319:0]),
     .rx_phy5                           (rx_phy5[319:0]),
     .rx_phy6                           (rx_phy6[319:0]),
     .rx_phy7                           (rx_phy7[319:0]),
     .rx_phy8                           (rx_phy8[319:0]),
     .rx_phy9                           (rx_phy9[319:0]),
     .rx_phy10                          (rx_phy10[319:0]),
     .rx_phy11                          (rx_phy11[319:0]),
     .rx_phy12                          (rx_phy12[319:0]),
     .rx_phy13                          (rx_phy13[319:0]),
     .rx_phy14                          (rx_phy14[319:0]),
     .rx_phy15                          (rx_phy15[319:0]),
     .dstrm_state                       (dstrm_state[3:0]),
     .dstrm_protid                      (dstrm_protid[1:0]),
     .dstrm_data                        (dstrm_data[1023:0]),
     .dstrm_dvalid                      (dstrm_dvalid[LPIF_VALID_WIDTH-1:0]),
     .dstrm_crc                         (dstrm_crc[LPIF_CRC_WIDTH-1:0]),
     .dstrm_crc_valid                   (dstrm_crc_valid[LPIF_VALID_WIDTH-1:0]),
     .dstrm_valid                       (dstrm_valid),
     .tx_mrk_userbit                    (4'b0),                  // Templated
     .tx_stb_userbit                    (1'b0));                  // Templated

  /* Loopback */

  /* lpif_lpbk AUTO_TEMPLATE (
   ); */

  lpif_lpbk
    #(/*AUTOINSTPARAM*/
      // Parameters
      .AIB_LANES                        (AIB_LANES),
      .AIB_BITS_PER_LANE                (AIB_BITS_PER_LANE))
  lpif_lpbk_i
    (/*AUTOINST*/
     // Outputs
     .dout_lpbk                         (dout_lpbk[(AIB_LANES*AIB_BITS_PER_LANE)-1:0]),
     // Inputs
     .m_wr_clk                          (m_wr_clk),
     .com_clk                           (com_clk),
     .rst_n                             (rst_n),
     .lpbk_en                           (lpbk_en),
     .data_in_f                         (data_in_f[(AIB_LANES*AIB_BITS_PER_LANE)-1:0]),
     .dout                              (dout[(AIB_LANES*AIB_BITS_PER_LANE)-1:0]));

  /* Control */

  /* lpif_ctl AUTO_TEMPLATE (
   ); */

  lpif_ctl
    #(/*AUTOINSTPARAM*/
      // Parameters
      .AIB_LANES                        (AIB_LANES),
      .LPIF_DATA_WIDTH                  (LPIF_DATA_WIDTH),
      .LPIF_PIPELINE_STAGES             (LPIF_PIPELINE_STAGES),
      .MEM_CACHE_STREAM_ID              (MEM_CACHE_STREAM_ID),
      .IO_STREAM_ID                     (IO_STREAM_ID),
      .ARB_MUX_STREAM_ID                (ARB_MUX_STREAM_ID))
  lpif_ctl_i
    (/*AUTOINST*/
     // Outputs
     .pl_trdy                           (pl_trdy),
     .dstrm_state                       (dstrm_state[3:0]),
     .dstrm_protid                      (dstrm_protid[1:0]),
     .dstrm_data                        (dstrm_data[1023:0]),
     .dstrm_dvalid                      (dstrm_dvalid[LPIF_VALID_WIDTH-1:0]),
     .dstrm_crc                         (dstrm_crc[LPIF_CRC_WIDTH-1:0]),
     .dstrm_crc_valid                   (dstrm_crc_valid[LPIF_VALID_WIDTH-1:0]),
     .dstrm_valid                       (dstrm_valid),
     .pl_data                           (pl_data[LPIF_DATA_WIDTH*8-1:0]),
     .pl_crc                            (pl_crc[LPIF_CRC_WIDTH-1:0]),
     .pl_crc_valid                      (pl_crc_valid[LPIF_VALID_WIDTH-1:0]),
     .pl_valid                          (pl_valid[LPIF_VALID_WIDTH-1:0]),
     .pl_stream                         (pl_stream[7:0]),
     .pl_error                          (pl_error),
     .pl_trainerror                     (pl_trainerror),
     .pl_cerror                         (pl_cerror),
     .pl_tmstmp                         (pl_tmstmp),
     .pl_tmstmp_stream                  (pl_tmstmp_stream[7:0]),
     .pl_quiesce                        (pl_quiesce),
     .pl_lnk_cfg                        (pl_lnk_cfg[2:0]),
     .pl_rxframe_errmask                (pl_rxframe_errmask),
     .pl_portmode                       (pl_portmode),
     .pl_portmode_val                   (pl_portmode_val),
     .pl_speedmode                      (pl_speedmode[2:0]),
     .pl_clr_lnkeqreq                   (pl_clr_lnkeqreq[2:0]),
     .pl_set_lnkeqreq                   (pl_set_lnkeqreq[2:0]),
     .pl_inband_pres                    (pl_inband_pres),
     .pl_ptm_rx_delay                   (pl_ptm_rx_delay[7:0]),
     .pl_setlabs                        (pl_setlabs),
     .pl_setlbms                        (pl_setlbms),
     .pl_surprise_lnk_down              (pl_surprise_lnk_down),
     .pl_protocol                       (pl_protocol[2:0]),
     .pl_protocol_vld                   (pl_protocol_vld),
     .pl_err_pipestg                    (pl_err_pipestg),
     .pl_wake_ack                       (pl_wake_ack),
     .pl_cfg                            (pl_cfg[7:0]),
     .pl_cfg_vld                        (pl_cfg_vld),
     .ns_mac_rdy                        (ns_mac_rdy),
     .ns_adapter_rstn                   (ns_adapter_rstn[AIB_LANES-1:0]),
     .align_fly                         (align_fly),
     .tx_stb_wd_sel                     (tx_stb_wd_sel[7:0]),
     .tx_stb_bit_sel                    (tx_stb_bit_sel[39:0]),
     .tx_stb_intv                       (tx_stb_intv[7:0]),
     .rx_stb_wd_sel                     (rx_stb_wd_sel[7:0]),
     .rx_stb_bit_sel                    (rx_stb_bit_sel[39:0]),
     .rx_stb_intv                       (rx_stb_intv[7:0]),
     .fifo_full_val                     (fifo_full_val[4:0]),
     .fifo_pfull_val                    (fifo_pfull_val[4:0]),
     .fifo_empty_val                    (fifo_empty_val[2:0]),
     .fifo_pempty_val                   (fifo_pempty_val[2:0]),
     .rden_dly                          (rden_dly[2:0]),
     .tx_online                         (tx_online),
     .rx_online                         (rx_online),
     .ctl_link_up                       (ctl_link_up),
     // Inputs
     .lclk                              (lclk),
     .reset                             (reset),
     .lp_irdy                           (lp_irdy),
     .lp_data                           (lp_data[LPIF_DATA_WIDTH*8-1:0]),
     .lp_crc                            (lp_crc[LPIF_CRC_WIDTH-1:0]),
     .lp_crc_valid                      (lp_crc_valid[LPIF_VALID_WIDTH-1:0]),
     .lp_valid                          (lp_valid[LPIF_VALID_WIDTH-1:0]),
     .lp_stream                         (lp_stream[7:0]),
     .ustrm_state                       (ustrm_state[3:0]),
     .ustrm_protid                      (ustrm_protid[1:0]),
     .ustrm_data                        (ustrm_data[LPIF_DATA_WIDTH*8-1:0]),
     .ustrm_dvalid                      (ustrm_dvalid[LPIF_VALID_WIDTH-1:0]),
     .ustrm_crc                         (ustrm_crc[LPIF_CRC_WIDTH-1:0]),
     .ustrm_crc_valid                   (ustrm_crc_valid[LPIF_VALID_WIDTH-1:0]),
     .ustrm_valid                       (ustrm_valid),
     .lp_tmstmp                         (lp_tmstmp),
     .lp_linkerror                      (lp_linkerror),
     .lp_flushed_all                    (lp_flushed_all),
     .lp_rcvd_crc_err                   (lp_rcvd_crc_err),
     .lp_wake_req                       (lp_wake_req),
     .lp_force_detect                   (lp_force_detect),
     .com_clk                           (com_clk),
     .rst_n                             (rst_n),
     .fs_mac_rdy                        (fs_mac_rdy),
     .sl_rx_transfer_en                 (sl_rx_transfer_en[AIB_LANES-1:0]),
     .ms_tx_transfer_en                 (ms_tx_transfer_en[AIB_LANES-1:0]),
     .ms_rx_transfer_en                 (ms_rx_transfer_en[AIB_LANES-1:0]),
     .sl_tx_transfer_en                 (sl_tx_transfer_en[AIB_LANES-1:0]),
     .m_rxfifo_align_done               (m_rxfifo_align_done[AIB_LANES-1:0]),
     .wa_error                          (wa_error[AIB_LANES-1:0]),
     .wa_error_cnt                      (wa_error_cnt[AIB_LANES-1:0]),
     .dual_mode_select                  (dual_mode_select),
     .m_gen2_mode                       (m_gen2_mode),
     .i_conf_done                       (i_conf_done),
     .power_on_reset                    (power_on_reset[AIB_LANES-1:0]),
     .align_done                        (align_done),
     .align_err                         (align_err),
     .fifo_full                         (fifo_full),
     .fifo_pfull                        (fifo_pfull),
     .fifo_empty                        (fifo_empty),
     .fifo_pempty                       (fifo_pempty),
     .lsm_dstrm_state                   (lsm_dstrm_state[3:0]),
     .lsm_lnk_cfg                       (lsm_lnk_cfg[2:0]),
     .lsm_speedmode                     (lsm_speedmode[2:0]),
     .lsm_state_active                  (lsm_state_active));

  /* Link State Machine */

  /* lpif_lsm AUTO_TEMPLATE (
   ); */

  lpif_lsm
    #(/*AUTOINSTPARAM*/)
  lpif_lsm_i
    (/*AUTOINST*/
     // Outputs
     .pl_state_sts                      (pl_state_sts[3:0]),
     .lsm_state_active                  (lsm_state_active),
     .pl_exit_cg_req                    (pl_exit_cg_req),
     .pl_stallreq                       (pl_stallreq),
     .pl_phyinl1                        (pl_phyinl1),
     .pl_phyinl2                        (pl_phyinl2),
     .pl_phyinrecenter                  (pl_phyinrecenter),
     .pl_lnk_up                         (pl_lnk_up),
     .lsm_dstrm_state                   (lsm_dstrm_state[3:0]),
     .lsm_lnk_cfg                       (lsm_lnk_cfg[2:0]),
     .lsm_speedmode                     (lsm_speedmode[2:0]),
     // Inputs
     .lclk                              (lclk),
     .rst_n                             (rst_n),
     .lp_state_req                      (lp_state_req[3:0]),
     .ustrm_state                       (ustrm_state[3:0]),
     .ctl_link_up                       (ctl_link_up),
     .lp_exit_cg_ack                    (lp_exit_cg_ack),
     .lp_stallack                       (lp_stallack));

endmodule // lpif

// Local Variables:
// verilog-library-directories:("." "./lpif_txrx" "${PROJ_DIR}/common/rtl")
// verilog-auto-inst-param-value:t
// End:
