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
//Functional Descript: LPIF Adapter IP Wrapper for FPGA
//
//
//
////////////////////////////////////////////////////////////

localparam AIB_VERSION = 2;
localparam AIB_GENERATION = 1;
localparam AIB_LANES = 16;
localparam AIB_BITS_PER_LANE = 80;
localparam AIB_CLOCK_RATE = 500;
localparam LPIF_CLOCK_RATE = 500;
localparam LPIF_DATA_WIDTH = 128;
localparam LPIF_PIPELINE_STAGES = 1;
localparam MEM_CACHE_STREAM_ID = 3'b001;
localparam IO_STREAM_ID = 3'b010;
localparam ARB_MUX_STREAM_ID = 3'b100;
localparam PTM_RX_DELAY = 4;
localparam LPIF_PL_PROTOCOL = 3'h4;
localparam LPIF_IS_HOST = 1'b0;
localparam LPIF_VALID_WIDTH = ((LPIF_DATA_WIDTH == 128) ? 2 : 1);
localparam LPIF_CRC_WIDTH = ((LPIF_DATA_WIDTH == 128) ? 32 : 16);

module lpif_wrap
/* -----\/----- EXCLUDED -----\/-----
  #(
    parameter AIB_VERSION = 2,
    parameter AIB_GENERATION = 1,
    parameter AIB_LANES = 16,
    parameter AIB_BITS_PER_LANE = 80,
    parameter AIB_CLOCK_RATE = 500,
    parameter LPIF_CLOCK_RATE = 500,
    parameter LPIF_DATA_WIDTH = 128,
    parameter LPIF_PIPELINE_STAGES = 1,
    parameter MEM_CACHE_STREAM_ID = 3'b001,
    parameter IO_STREAM_ID = 3'b010,
    parameter ARB_MUX_STREAM_ID = 3'b100,
    localparam LPIF_VALID_WIDTH = ((LPIF_DATA_WIDTH == 128) ? 2 : 1),
    localparam LPIF_CRC_WIDTH = ((LPIF_DATA_WIDTH == 128) ? 32 : 16)
    )
 -----/\----- EXCLUDED -----/\----- */
  (
   input logic                                      lclk,
   input logic                                      reset,

   input logic                                      align_done_i,
   input logic                                      align_err_i,
   input logic [15:0]                               delay_x_value_i,
   input logic [15:0]                               delay_y_value_i,
   input logic [15:0]                               delay_z_value_i,
   input logic [(AIB_LANES*AIB_BITS_PER_LANE)-1:0]  dout_i,
   input logic                                      dual_mode_select_i,
   input logic [AIB_LANES-1:0]                      fifo_empty_i,
   input logic [AIB_LANES-1:0]                      fifo_full_i,
   input logic [AIB_LANES-1:0]                      fifo_pempty_i,
   input logic [AIB_LANES-1:0]                      fifo_pfull_i,
   input logic                                      fs_mac_rdy_i,
   input logic                                      i_conf_done_i,
   input logic [7:0]                                lp_cfg_i,
   input logic                                      lp_cfg_vld_i,
   input logic [LPIF_DATA_WIDTH*8-1:0]              lp_data_i,
   input logic                                      lp_exit_cg_ack_i,
   input logic                                      lp_flushed_all_i,
   input logic                                      lp_force_detect_i,
   input logic                                      lp_irdy_i,
   input logic                                      lp_linkerror_i,
   input logic                                      lp_rcvd_crc_err_i,
   input logic                                      lp_stallack_i,
   input logic [3:0]                                lp_state_req_i,
   input logic [7:0]                                lp_stream_i,
   input logic                                      lp_tmstmp_i,
   input logic [7:0]                                lp_tmstmp_stream_i,
   input logic [LPIF_DATA_WIDTH-1:0]                lp_valid_i,
   input logic                                      lp_wake_req_i,
   input logic                                      lpbk_en_i,
   input logic [LPIF_CRC_WIDTH-1:0]                 lp_crc_i,
   input logic                                      lp_crc_valid_i,
   input logic [1:0]                                lp_pri_i,
   input logic                                      lp_device_present_i,
   input logic                                      lp_clk_ack_i,
   input logic                                      m_gen2_mode_i,
   input logic [AIB_LANES-1:0]                      m_rxfifo_align_done_i,
   input logic [AIB_LANES-1:0]                      ms_rx_transfer_en_i,
   input logic [AIB_LANES-1:0]                      ms_tx_transfer_en_i,
   input logic [AIB_LANES-1:0]                      power_on_reset_i,
   input logic [AIB_LANES-1:0]                      sl_rx_transfer_en_i,
   input logic [AIB_LANES-1:0]                      sl_tx_transfer_en_i,
   input logic [AIB_LANES-1:0]                      wa_error_i,
   input logic [AIB_LANES-1:0]                      wa_error_cnt_i,
   input logic [1:0]                                remote_rate_i,

   output logic                                     rx_online_o,
   output logic                                     tx_online_o,
   output logic                                     align_fly_o,
   output logic [(AIB_LANES*AIB_BITS_PER_LANE)-1:0] data_in_f_o,
   output logic [2:0]                               fifo_empty_val_o,
   output logic [5:0]                               fifo_full_val_o,
   output logic [2:0]                               fifo_pempty_val_o,
   output logic [5:0]                               fifo_pfull_val_o,
   output logic [AIB_LANES-1:0]                     ns_adapter_rstn_o,
   output logic                                     ns_mac_rdy_o,
   output logic                                     pl_cerror_o,
   output logic [7:0]                               pl_cfg_o,
   output logic                                     pl_cfg_vld_o,
   output logic [2:0]                               pl_clr_lnkeqreq_o,
   output logic [LPIF_DATA_WIDTH*8-1:0]             pl_data_o,
   output logic                                     pl_err_pipestg_o,
   output logic                                     pl_error_o,
   output logic                                     pl_exit_cg_req_o,
   output logic                                     pl_inband_pres_o,
   output logic [2:0]                               pl_lnk_cfg_o,
   output logic                                     pl_lnk_up_o,
   output logic                                     pl_phyinl1_o,
   output logic                                     pl_phyinl2_o,
   output logic                                     pl_phyinrecenter_o,
   output logic                                     pl_portmode_o,
   output logic                                     pl_portmode_val_o,
   output logic [2:0]                               pl_protocol_o,
   output logic                                     pl_protocol_vld_o,
   output logic [7:0]                               pl_ptm_rx_delay_o,
   output logic                                     pl_quiesce_o,
   output logic                                     pl_rxframe_errmask_o,
   output logic [2:0]                               pl_set_lnkeqreq_o,
   output logic                                     pl_setlabs_o,
   output logic                                     pl_setlbms_o,
   output logic [2:0]                               pl_speedmode_o,
   output logic                                     pl_stallreq_o,
   output logic [3:0]                               pl_state_sts_o,
   output logic [7:0]                               pl_stream_o,
   output logic                                     pl_surprise_lnk_down_o,
   output logic                                     pl_tmstmp_o,
   output logic [7:0]                               pl_tmstmp_stream_o,
   output logic                                     pl_trainerror_o,
   output logic                                     pl_trdy_o,
   output logic [LPIF_VALID_WIDTH-1:0]              pl_valid_o,
   output logic                                     pl_wake_ack_o,
   output logic [LPIF_CRC_WIDTH-1:0]                pl_crc_o,
   output logic                                     pl_crc_valid_o,
   output logic                                     pl_clk_req_o,
   output logic [2:0]                               rden_dly_o,
   output logic [39:0]                              rx_stb_bit_sel_o,
   output logic [15:0]                              rx_stb_intv_o,
   output logic [7:0]                               rx_stb_wd_sel_o,
   output logic [39:0]                              tx_stb_bit_sel_o,
   output logic [15:0]                              tx_stb_intv_o,
   output logic [7:0]                               tx_stb_wd_sel_o
   );

  logic                                             align_done;
  logic                                             align_err;
  logic [15:0]                                      delay_x_value;
  logic [15:0]                                      delay_y_value;
  logic [15:0]                                      delay_z_value;
  logic [(AIB_LANES*AIB_BITS_PER_LANE)-1:0]         dout;
  logic                                             dual_mode_select;
  logic [AIB_LANES-1:0]                             fifo_empty;
  logic [AIB_LANES-1:0]                             fifo_full;
  logic [AIB_LANES-1:0]                             fifo_pempty;
  logic [AIB_LANES-1:0]                             fifo_pfull;
  logic                                             fs_mac_rdy;
  logic                                             i_conf_done;
  logic [7:0]                                       lp_cfg;
  logic                                             lp_cfg_vld;
  logic [LPIF_DATA_WIDTH*8-1:0]                     lp_data;
  logic                                             lp_exit_cg_ack;
  logic                                             lp_flushed_all;
  logic                                             lp_force_detect;
  logic                                             lp_irdy;
  logic                                             lp_linkerror;
  logic                                             lp_rcvd_crc_err;
  logic                                             lp_stallack;
  logic [3:0]                                       lp_state_req;
  logic [7:0]                                       lp_stream;
  logic                                             lp_tmstmp;
  logic [7:0]                                       lp_tmstmp_stream;
  logic [LPIF_DATA_WIDTH-1:0]                       lp_valid;
  logic                                             lp_wake_req;
  logic                                             lpbk_en;
  logic [LPIF_CRC_WIDTH-1:0]                        lp_crc;
  logic                                             lp_crc_valid;
  logic [1:0]                                       lp_pri;
  logic                                             lp_device_present;
  logic                                             lp_clk_ack;
  logic                                             m_gen2_mode;
  logic [AIB_LANES-1:0]                             m_rxfifo_align_done;
  logic [AIB_LANES-1:0]                             ms_rx_transfer_en;
  logic [AIB_LANES-1:0]                             ms_tx_transfer_en;
  logic [AIB_LANES-1:0]                             power_on_reset;
  logic                                             rx_online;
  logic [AIB_LANES-1:0]                             sl_rx_transfer_en;
  logic [AIB_LANES-1:0]                             sl_tx_transfer_en;
  logic                                             tx_online;
  logic [AIB_LANES-1:0]                             wa_error;
  logic [AIB_LANES-1:0]                             wa_error_cnt;
  logic [1:0]                                       remote_rate;

  logic                                             align_fly;
  logic [(AIB_LANES*AIB_BITS_PER_LANE)-1:0]         data_in_f;
  logic [2:0]                                       fifo_empty_val;
  logic [5:0]                                       fifo_full_val;
  logic [2:0]                                       fifo_pempty_val;
  logic [5:0]                                       fifo_pfull_val;
  logic [AIB_LANES-1:0]                             ns_adapter_rstn;
  logic                                             ns_mac_rdy;
  logic                                             pl_cerror;
  logic [7:0]                                       pl_cfg;
  logic                                             pl_cfg_vld;
  logic [2:0]                                       pl_clr_lnkeqreq;
  logic [LPIF_DATA_WIDTH*8-1:0]                     pl_data;
  logic                                             pl_err_pipestg;
  logic                                             pl_error;
  logic                                             pl_exit_cg_req;
  logic                                             pl_inband_pres;
  logic [2:0]                                       pl_lnk_cfg;
  logic                                             pl_lnk_up;
  logic                                             pl_phyinl1;
  logic                                             pl_phyinl2;
  logic                                             pl_phyinrecenter;
  logic                                             pl_portmode;
  logic                                             pl_portmode_val;
  logic [2:0]                                       pl_protocol;
  logic                                             pl_protocol_vld;
  logic [7:0]                                       pl_ptm_rx_delay;
  logic                                             pl_quiesce;
  logic                                             pl_rxframe_errmask;
  logic [2:0]                                       pl_set_lnkeqreq;
  logic                                             pl_setlabs;
  logic                                             pl_setlbms;
  logic [2:0]                                       pl_speedmode;
  logic                                             pl_stallreq;
  logic [3:0]                                       pl_state_sts;
  logic [7:0]                                       pl_stream;
  logic                                             pl_surprise_lnk_down;
  logic                                             pl_tmstmp;
  logic [7:0]                                       pl_tmstmp_stream;
  logic                                             pl_trainerror;
  logic                                             pl_trdy;
  logic [LPIF_VALID_WIDTH-1:0]                      pl_valid;
  logic                                             pl_wake_ack;
  logic [LPIF_CRC_WIDTH-1:0]                        pl_crc;
  logic                                             pl_crc_valid;
  logic                                             pl_clk_req;
  logic [2:0]                                       rden_dly;
  logic [39:0]                                      rx_stb_bit_sel;
  logic [15:0]                                      rx_stb_intv;
  logic [7:0]                                       rx_stb_wd_sel;
  logic [39:0]                                      tx_stb_bit_sel;
  logic [15:0]                                      tx_stb_intv;
  logic [7:0]                                       tx_stb_wd_sel;

  always_ff @(posedge lclk)
    begin
      align_done <= align_done_i;
      align_err <= align_err_i;
      delay_x_value <= delay_x_value_i;
      delay_y_value <= delay_y_value_i;
      delay_z_value <= delay_z_value_i;
      dout <= dout_i;
      dual_mode_select <= dual_mode_select_i;
      fifo_empty <= fifo_empty_i;
      fifo_full <= fifo_full_i;
      fifo_pempty <= fifo_pempty_i;
      fifo_pfull <= fifo_pfull_i;
      fs_mac_rdy <= fs_mac_rdy_i;
      i_conf_done <= i_conf_done_i;
      lp_cfg <= lp_cfg_i;
      lp_cfg_vld <= lp_cfg_vld_i;
      lp_data <= lp_data_i;
      lp_exit_cg_ack <= lp_exit_cg_ack_i;
      lp_flushed_all <= lp_flushed_all_i;
      lp_force_detect <= lp_force_detect_i;
      lp_irdy <= lp_irdy_i;
      lp_linkerror <= lp_linkerror_i;
      lp_rcvd_crc_err <= lp_rcvd_crc_err_i;
      lp_stallack <= lp_stallack_i;
      lp_state_req <= lp_state_req_i;
      lp_stream <= lp_stream_i;
      lp_tmstmp <= lp_tmstmp_i;
      lp_tmstmp_stream <= lp_tmstmp_stream_i;
      lp_valid <= lp_valid_i;
      lp_wake_req <= lp_wake_req_i;
      lpbk_en <= lpbk_en_i;
      lp_crc <= lp_crc_i;
      lp_crc_valid <= lp_crc_valid_i;
      lp_pri <= lp_pri_i;
      lp_device_present <= lp_device_present_i;
      lp_clk_ack <= lp_clk_ack_i;
      m_gen2_mode <= m_gen2_mode_i;
      m_rxfifo_align_done <= m_rxfifo_align_done_i;
      ms_rx_transfer_en <= ms_rx_transfer_en_i;
      ms_tx_transfer_en <= ms_tx_transfer_en_i;
      power_on_reset <= power_on_reset_i;
      sl_rx_transfer_en <= sl_rx_transfer_en_i;
      sl_tx_transfer_en <= sl_tx_transfer_en_i;
      wa_error <= wa_error_i;
      wa_error_cnt <= wa_error_cnt_i;
      remote_rate <= remote_rate_i;
    end // always_ff @ (posedge lclk)

  always_ff @(posedge lclk)
    begin
      align_fly_o <= align_fly;
      data_in_f_o <= data_in_f;
      fifo_empty_val_o <= fifo_empty_val;
      fifo_full_val_o <= fifo_full_val;
      fifo_pempty_val_o <= fifo_pempty_val;
      fifo_pfull_val_o <= fifo_pfull_val;
      ns_adapter_rstn_o <= ns_adapter_rstn;
      ns_mac_rdy_o <= ns_mac_rdy;
      pl_cerror_o <= pl_cerror;
      pl_cfg_o <= pl_cfg;
      pl_cfg_vld_o <= pl_cfg_vld;
      pl_clr_lnkeqreq_o <= pl_clr_lnkeqreq;
      pl_data_o <= pl_data;
      pl_err_pipestg_o <= pl_err_pipestg;
      pl_error_o <= pl_error;
      pl_exit_cg_req_o <= pl_exit_cg_req;
      pl_inband_pres_o <= pl_inband_pres;
      pl_lnk_cfg_o <= pl_lnk_cfg;
      pl_lnk_up_o <= pl_lnk_up;
      pl_phyinl1_o <= pl_phyinl1;
      pl_phyinl2_o <= pl_phyinl2;
      pl_phyinrecenter_o <= pl_phyinrecenter;
      pl_portmode_o <= pl_portmode;
      pl_portmode_val_o <= pl_portmode_val;
      pl_protocol_o <= pl_protocol;
      pl_protocol_vld_o <= pl_protocol_vld;
      pl_ptm_rx_delay_o <= pl_ptm_rx_delay;
      pl_quiesce_o <= pl_quiesce;
      pl_rxframe_errmask_o <= pl_rxframe_errmask;
      pl_set_lnkeqreq_o <= pl_set_lnkeqreq;
      pl_setlabs_o <= pl_setlabs;
      pl_setlbms_o <= pl_setlbms;
      pl_speedmode_o <= pl_speedmode;
      pl_stallreq_o <= pl_stallreq;
      pl_state_sts_o <= pl_state_sts;
      pl_stream_o <= pl_stream;
      pl_surprise_lnk_down_o <= pl_surprise_lnk_down;
      pl_tmstmp_o <= pl_tmstmp;
      pl_tmstmp_stream_o <= pl_tmstmp_stream;
      pl_trainerror_o <= pl_trainerror;
      pl_trdy_o <= pl_trdy;
      pl_valid_o <= pl_valid;
      pl_wake_ack_o <= pl_wake_ack;
      pl_crc_o <= pl_crc;
      pl_crc_valid_o <= pl_crc_valid;
      pl_clk_req_o <= pl_clk_req;
      rden_dly_o <= rden_dly;
      rx_stb_bit_sel_o <= rx_stb_bit_sel;
      rx_stb_intv_o <= rx_stb_intv;
      rx_stb_wd_sel_o <= rx_stb_wd_sel;
      tx_stb_bit_sel_o <= tx_stb_bit_sel;
      tx_stb_intv_o <= tx_stb_intv;
      tx_stb_wd_sel_o <= tx_stb_wd_sel;
      rx_online_o <= rx_online;
      tx_online_o <= tx_online;
    end; // always_ff @ (posedge lclk)

  /* lpif AUTO_TEMPLATE (
   ); */

  lpif
    #(/*AUTOINSTPARAM*/
      // Parameters
      .AIB_VERSION                      (AIB_VERSION),
      .AIB_GENERATION                   (AIB_GENERATION),
      .AIB_LANES                        (AIB_LANES),
      .AIB_BITS_PER_LANE                (AIB_BITS_PER_LANE),
      .AIB_CLOCK_RATE                   (AIB_CLOCK_RATE),
      .LPIF_CLOCK_RATE                  (LPIF_CLOCK_RATE),
      .LPIF_DATA_WIDTH                  (LPIF_DATA_WIDTH),
      .LPIF_PIPELINE_STAGES             (LPIF_PIPELINE_STAGES),
      .MEM_CACHE_STREAM_ID              (MEM_CACHE_STREAM_ID),
      .IO_STREAM_ID                     (IO_STREAM_ID),
      .ARB_MUX_STREAM_ID                (ARB_MUX_STREAM_ID),
      .PTM_RX_DELAY                     (PTM_RX_DELAY),
      .LPIF_PL_PROTOCOL                 (LPIF_PL_PROTOCOL),
      .LPIF_IS_HOST                     (LPIF_IS_HOST))
  lpif_i
    (/*AUTOINST*/
     // Outputs
     .pl_trdy                           (pl_trdy),
     .pl_data                           (pl_data[LPIF_DATA_WIDTH*8-1:0]),
     .pl_valid                          (pl_valid[LPIF_VALID_WIDTH-1:0]),
     .pl_stream                         (pl_stream[7:0]),
     .pl_error                          (pl_error),
     .pl_trainerror                     (pl_trainerror),
     .pl_cerror                         (pl_cerror),
     .pl_stallreq                       (pl_stallreq),
     .pl_tmstmp                         (pl_tmstmp),
     .pl_tmstmp_stream                  (pl_tmstmp_stream[7:0]),
     .pl_phyinl1                        (pl_phyinl1),
     .pl_phyinl2                        (pl_phyinl2),
     .pl_state_sts                      (pl_state_sts[3:0]),
     .pl_quiesce                        (pl_quiesce),
     .pl_lnk_cfg                        (pl_lnk_cfg[2:0]),
     .pl_lnk_up                         (pl_lnk_up),
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
     .pl_phyinrecenter                  (pl_phyinrecenter),
     .pl_exit_cg_req                    (pl_exit_cg_req),
     .pl_cfg                            (pl_cfg[7:0]),
     .pl_cfg_vld                        (pl_cfg_vld),
     .pl_crc                            (pl_crc[LPIF_CRC_WIDTH-1:0]),
     .pl_crc_valid                      (pl_crc_valid),
     .pl_clk_req                        (pl_clk_req),
     .data_in_f                         (data_in_f[(AIB_LANES*AIB_BITS_PER_LANE)-1:0]),
     .ns_mac_rdy                        (ns_mac_rdy),
     .ns_adapter_rstn                   (ns_adapter_rstn[AIB_LANES-1:0]),
     .align_fly                         (align_fly),
     .tx_stb_wd_sel                     (tx_stb_wd_sel[7:0]),
     .tx_stb_bit_sel                    (tx_stb_bit_sel[39:0]),
     .tx_stb_intv                       (tx_stb_intv[15:0]),
     .rx_stb_wd_sel                     (rx_stb_wd_sel[7:0]),
     .rx_stb_bit_sel                    (rx_stb_bit_sel[39:0]),
     .rx_stb_intv                       (rx_stb_intv[15:0]),
     .fifo_full_val                     (fifo_full_val[5:0]),
     .fifo_pfull_val                    (fifo_pfull_val[5:0]),
     .fifo_empty_val                    (fifo_empty_val[2:0]),
     .fifo_pempty_val                   (fifo_pempty_val[2:0]),
     .rden_dly                          (rden_dly[2:0]),
     .tx_online                         (tx_online),
     .rx_online                         (rx_online),
     // Inputs
     .lclk                              (lclk),
     .reset                             (reset),
     .lp_irdy                           (lp_irdy),
     .lp_data                           (lp_data[LPIF_DATA_WIDTH*8-1:0]),
     .lp_valid                          (lp_valid[LPIF_VALID_WIDTH-1:0]),
     .lp_stream                         (lp_stream[7:0]),
     .lp_stallack                       (lp_stallack),
     .lp_state_req                      (lp_state_req[3:0]),
     .lp_tmstmp                         (lp_tmstmp),
     .lp_tmstmp_stream                  (lp_tmstmp_stream[7:0]),
     .lp_linkerror                      (lp_linkerror),
     .lp_flushed_all                    (lp_flushed_all),
     .lp_rcvd_crc_err                   (lp_rcvd_crc_err),
     .lp_wake_req                       (lp_wake_req),
     .lp_force_detect                   (lp_force_detect),
     .lp_exit_cg_ack                    (lp_exit_cg_ack),
     .lp_cfg                            (lp_cfg[7:0]),
     .lp_cfg_vld                        (lp_cfg_vld),
     .lp_crc                            (lp_crc[LPIF_CRC_WIDTH-1:0]),
     .lp_crc_valid                      (lp_crc_valid),
     .lp_device_present                 (lp_device_present),
     .lp_clk_ack                        (lp_clk_ack),
     .lp_pri                            (lp_pri[1:0]),
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
     .dout                              (dout[(AIB_LANES*AIB_BITS_PER_LANE)-1:0]),
     .align_done                        (align_done),
     .align_err                         (align_err),
     .fifo_full                         (fifo_full[AIB_LANES-1:0]),
     .fifo_pfull                        (fifo_pfull[AIB_LANES-1:0]),
     .fifo_empty                        (fifo_empty[AIB_LANES-1:0]),
     .fifo_pempty                       (fifo_pempty[AIB_LANES-1:0]),
     .delay_x_value                     (delay_x_value[15:0]),
     .delay_y_value                     (delay_y_value[15:0]),
     .delay_z_value                     (delay_z_value[15:0]),
     .lpbk_en                           (lpbk_en),
     .remote_rate                       (remote_rate[1:0]));

endmodule // lpif_wrap

// Local Variables:
// verilog-library-directories:("." "${PROJ_DIR}/lpif/rtl" "${PROJ_DIR}/common/rtl")
// verilog-auto-inst-param-value:t
// End:
