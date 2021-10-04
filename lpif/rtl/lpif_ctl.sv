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
// Functional Descript: LPIF Adapter IP Control
//
//
//
////////////////////////////////////////////////////////////

module lpif_ctl
  #(
    parameter AIB_LANES = 4,
    parameter LPIF_DATA_WIDTH = 64,
    parameter LPIF_PIPELINE_STAGES = 1,
    parameter MEM_CACHE_STREAM_ID = 8'h1,
    parameter IO_STREAM_ID = 8'h2,
    parameter ARB_MUX_STREAM_ID = 8'h3,
    localparam LPIF_VALID_WIDTH = ((LPIF_DATA_WIDTH == 128) ? 2 : 1),
    localparam LPIF_CRC_WIDTH = ((LPIF_DATA_WIDTH == 128) ? 32 : 16)
    )
  (
   // LPIF Interface
   input logic                          lclk,
   input logic                          reset,

   input logic                          lp_irdy,
   input logic [LPIF_DATA_WIDTH*8-1:0]  lp_data,
   input logic [LPIF_CRC_WIDTH-1:0]     lp_crc,
   input logic [LPIF_VALID_WIDTH-1:0]   lp_crc_valid,
   input logic [LPIF_VALID_WIDTH-1:0]   lp_valid,
   input logic [7:0]                    lp_stream,
   output logic                         pl_trdy,

   output logic [3:0]                   dstrm_state,
   output logic [1:0]                   dstrm_protid,
   output logic [1023:0]                dstrm_data,
   output logic [LPIF_VALID_WIDTH-1:0]  dstrm_dvalid,
   output logic [LPIF_CRC_WIDTH-1:0]    dstrm_crc,
   output logic [LPIF_VALID_WIDTH-1:0]  dstrm_crc_valid,
   output logic                         dstrm_valid,

   input logic [3:0]                    ustrm_state,
   input logic [1:0]                    ustrm_protid,
   input logic [LPIF_DATA_WIDTH*8-1:0]  ustrm_data,
   input logic [LPIF_VALID_WIDTH-1:0]   ustrm_dvalid,
   input logic [LPIF_CRC_WIDTH-1:0]     ustrm_crc,
   input logic [LPIF_VALID_WIDTH-1:0]   ustrm_crc_valid,
   input logic                          ustrm_valid,

   output logic [LPIF_DATA_WIDTH*8-1:0] pl_data,
   output logic [LPIF_CRC_WIDTH-1:0]    pl_crc,
   output logic [LPIF_VALID_WIDTH-1:0]  pl_crc_valid,
   output logic [LPIF_VALID_WIDTH-1:0]  pl_valid,
   output logic [7:0]                   pl_stream,

   output logic                         pl_error,
   output logic                         pl_trainerror,
   output logic                         pl_cerror,
   output logic                         pl_tmstmp,
   output logic [7:0]                   pl_tmstmp_stream,

   input logic                          lp_tmstmp,
   input logic                          lp_linkerror,
   output logic                         pl_quiesce,
   input logic                          lp_flushed_all,
   input logic                          lp_rcvd_crc_err,
   output logic [2:0]                   pl_lnk_cfg,
   output logic                         pl_rxframe_errmask,
   output logic                         pl_portmode,
   output logic                         pl_portmode_val,
   output logic [2:0]                   pl_speedmode,
   output logic [2:0]                   pl_clr_lnkeqreq,
   output logic [2:0]                   pl_set_lnkeqreq,
   output logic                         pl_inband_pres,
   output logic [7:0]                   pl_ptm_rx_delay,
   output logic                         pl_setlabs,
   output logic                         pl_setlbms,
   output logic                         pl_surprise_lnk_down,
   output logic [2:0]                   pl_protocol,
   output logic                         pl_protocol_vld,
   output logic                         pl_err_pipestg,
   input logic                          lp_wake_req,
   output logic                         pl_wake_ack,
   input logic                          lp_force_detect,
   output logic [7:0]                   pl_cfg,
   output logic                         pl_cfg_vld,

   // AIB Interface
   input logic                          com_clk,
   input logic                          rst_n,

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
   input logic                          fifo_full,
   input logic                          fifo_pfull,
   input logic                          fifo_empty,
   input logic                          fifo_pempty,
   output logic                         align_fly,
   output logic [7:0]                   tx_stb_wd_sel,
   output logic [39:0]                  tx_stb_bit_sel,
   output logic [7:0]                   tx_stb_intv,
   output logic [7:0]                   rx_stb_wd_sel,
   output logic [39:0]                  rx_stb_bit_sel,
   output logic [7:0]                   rx_stb_intv,
   output logic [4:0]                   fifo_full_val,
   output logic [4:0]                   fifo_pfull_val,
   output logic [2:0]                   fifo_empty_val,
   output logic [2:0]                   fifo_pempty_val,
   output logic [2:0]                   rden_dly,
   output logic                         tx_online,
   output logic                         rx_online,

   // lsm

   input logic [3:0]                    lsm_dstrm_state,
   input logic [2:0]                    lsm_lnk_cfg,
   input logic [2:0]                    lsm_speedmode,

   // misc

   output logic                         ctl_link_up,
   input logic                          lsm_state_active
   );

  // phy to link layer

  // tied-off as described in LPIF Adapter White Paper
  assign pl_cerror = 1'b0;
  assign pl_clr_lnkeqreq = 3'b0;
  assign pl_set_lnkeqreq = 3'b0;
  assign pl_err_pipestg = 1'b0;
  assign pl_error = 1'b0;
  assign pl_inband_pres = 1'b1;
  assign pl_portmode = 1'b1;
  assign pl_portmode_val = 1'b1;
  assign pl_protocol = 3'b100; // CXL.2 [Multi-Protocol]
  assign pl_protocol_vld = 1'b1;
  assign pl_ptm_rx_delay = 8'h0;
  assign pl_quiesce = 1'b0;
  assign pl_rxframe_errmask = 1'b0;
  assign pl_setlbms = 1'b0;
  assign pl_setlabs = 1'b0;
  assign pl_surprise_lnk_down = 1'b0;
  assign pl_tmstmp = 1'b0;
  assign pl_tmstmp_stream = 8'b0;

  // tied-off for now
  assign pl_trainerror = 1'b0;
  assign pl_wake_ack = 1'b0;

  // optional as described in LPIF Adapter White Paper
  assign pl_cfg_vld = 1'b0;
  assign pl_cfg = 8'b0;

  // lpif to ca

  assign align_fly = 1'b1;
  assign tx_stb_wd_sel = 8'h1;    // these must match the value in the config file
  assign tx_stb_bit_sel = 40'h2;
  assign tx_stb_intv = 8'h4;
  assign rx_stb_wd_sel = 8'h1;    // these must match the value in the config file
  assign rx_stb_bit_sel = 40'h2;
  assign rx_stb_intv = 8'h4;
  assign fifo_full_val = 5'h1F;
  assign fifo_pfull_val = 5'h10;
  assign fifo_empty_val = 3'h0;
  assign fifo_pempty_val = 3'h4;
  assign rden_dly = 3'h0;

  // misc

  logic                                 d_ns_mac_rdy;
  logic [AIB_LANES-1:0]                 d_ns_adapter_rstn;

  logic                                 d_dstrm_valid;

  logic                                 d_tx_online;
  logic                                 d_rx_online;

  always_comb
    begin
      pl_trdy = lsm_state_active;
    end

  localparam [1:0] /* auto enum protid_info */
    PROTID_CACHE	= 2'h0,
    PROTID_IO		= 2'h1,
    PROTID_ARB_MUX	= 2'h2;

  logic [1:0] d_dstrm_protid;
  logic [1:0] /* auto enum protid_info */
              protid;

  assign d_dstrm_protid = protid;

  /*AUTOASCIIENUM("protid", "protid_ascii", "")*/
  // Beginning of automatic ASCII enum decoding
  reg [111:0] protid_ascii;           // Decode of protid
  always @(protid) begin
    case ({protid})
      PROTID_CACHE:   protid_ascii = "protid_cache  ";
      PROTID_IO:      protid_ascii = "protid_io     ";
      PROTID_ARB_MUX: protid_ascii = "protid_arb_mux";
      default:        protid_ascii = "%Error        ";
    endcase
  end
  // End of automatics

  always_comb
    begin : protocol_id
      case (lp_stream)
        MEM_CACHE_STREAM_ID: protid = PROTID_CACHE;
        IO_STREAM_ID: protid = PROTID_IO;
        ARB_MUX_STREAM_ID: protid = PROTID_ARB_MUX;
        default: MEM_CACHE_STREAM_ID: protid = PROTID_CACHE;
      endcase // case (lp_stream)
    end

  logic [7:0] /* auto enum protid_info */
              pl_stream_int;
  logic [7:0] d_pl_stream;
  assign d_pl_stream = pl_stream_int;

  /*AUTOASCIIENUM("pl_stream_int", "pl_stream_int_ascii", "")*/
  // Beginning of automatic ASCII enum decoding
  reg [111:0] pl_stream_int_ascii;    // Decode of pl_stream_int
  always @(pl_stream_int) begin
    case ({pl_stream_int})
      PROTID_CACHE:   pl_stream_int_ascii = "protid_cache  ";
      PROTID_IO:      pl_stream_int_ascii = "protid_io     ";
      PROTID_ARB_MUX: pl_stream_int_ascii = "protid_arb_mux";
      default:        pl_stream_int_ascii = "%Error        ";
    endcase
  end
  // End of automatics
  always_comb
    begin : lp_stream_id
      case (ustrm_protid)
        PROTID_CACHE: pl_stream_int = MEM_CACHE_STREAM_ID;
        PROTID_IO: pl_stream_int = IO_STREAM_ID;
        PROTID_ARB_MUX: pl_stream_int = ARB_MUX_STREAM_ID;
        default: pl_stream_int = MEM_CACHE_STREAM_ID;
      endcase // case (ustrm_protid)
    end

  // Control State Machine

  localparam [2:0] /* auto enum ctl_state_info */
    CTL_IDLE		= 3'h0,
    CTL_PHY_INIT	= 3'h1,
    CTL_CFG		= 3'h2,
    CTL_CALIB		= 3'h3,
    CTL_WAIT_CA_ALIGN	= 3'h4,
    CTL_CA_ALIGNED	= 3'h5,
    CTL_LINK_UP		= 3'h6,
    CTL_HALT		= 3'h7;

  logic [2:0] /* auto enum ctl_state_info */
              ctl_state, d_ctl_state;

  /*AUTOASCIIENUM("ctl_state", "ctl_state_ascii", "")*/
  // Beginning of automatic ASCII enum decoding
  reg [135:0] ctl_state_ascii;        // Decode of ctl_state
  always @(ctl_state) begin
    case ({ctl_state})
      CTL_IDLE:          ctl_state_ascii = "ctl_idle         ";
      CTL_PHY_INIT:      ctl_state_ascii = "ctl_phy_init     ";
      CTL_CFG:           ctl_state_ascii = "ctl_cfg          ";
      CTL_CALIB:         ctl_state_ascii = "ctl_calib        ";
      CTL_WAIT_CA_ALIGN: ctl_state_ascii = "ctl_wait_ca_align";
      CTL_CA_ALIGNED:    ctl_state_ascii = "ctl_ca_aligned   ";
      CTL_LINK_UP:       ctl_state_ascii = "ctl_link_up      ";
      CTL_HALT:          ctl_state_ascii = "ctl_halt         ";
      default:           ctl_state_ascii = "%Error           ";
    endcase
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
      d_dstrm_valid = dstrm_valid;
      d_tx_online = tx_online;
      d_rx_online = rx_online;
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
              d_ctl_state = CTL_WAIT_CA_ALIGN;
            end
        end
        CTL_WAIT_CA_ALIGN: begin
          if (align_done)
            d_ctl_state = CTL_LINK_UP;
        end
        CTL_CA_ALIGNED: begin
          d_ctl_state = CTL_CA_ALIGNED;
        end
        CTL_LINK_UP: begin
          d_ctl_state = CTL_LINK_UP;
        end
        default: d_ctl_state = CTL_IDLE;
      endcase // case (ctl_state)
    end // block: ctl_state_next

  always_ff @(posedge  com_clk or negedge rst_n)
    begin
      if (~rst_n)
        begin
          dstrm_state <= 4'b0;
          dstrm_protid <= 2'b0;
          dstrm_data <= 1024'b0;
          dstrm_dvalid <= {LPIF_VALID_WIDTH{1'b0}};
          dstrm_crc <= 32'b0;
          dstrm_crc_valid <= 1'b0;
          dstrm_valid <= 1'b0;

          ns_mac_rdy <= 1'b0;
          ns_adapter_rstn <= {AIB_LANES{1'b0}};

          pl_lnk_cfg <= 3'b0;
          pl_speedmode <= 3'b0;

          pl_data <= {LPIF_DATA_WIDTH*8{1'b0}};
          pl_valid <= {LPIF_VALID_WIDTH{1'b0}};
          pl_crc <= {LPIF_CRC_WIDTH{1'b0}};
          pl_crc_valid <= {LPIF_VALID_WIDTH{1'b0}};
          pl_stream <= 8'b0;

          tx_online <= 1'b0;
          rx_online <= 1'b0;
        end
      else
        begin
          dstrm_state <= lsm_dstrm_state;
          dstrm_protid <= d_dstrm_protid;
          dstrm_data <= lp_data;
          dstrm_dvalid <= lp_valid;
          dstrm_crc <= lp_crc;
          dstrm_crc_valid <= lp_crc_valid;
          dstrm_valid <= d_dstrm_valid;

          ns_mac_rdy <= d_ns_mac_rdy;
          ns_adapter_rstn <= d_ns_adapter_rstn;

          pl_lnk_cfg <= lsm_lnk_cfg;
          pl_speedmode <= lsm_speedmode;

          pl_data <= ustrm_data;
          pl_valid <= ustrm_dvalid;
          pl_crc <= ustrm_crc;
          pl_crc_valid <= ustrm_crc_valid;
          pl_stream <= d_pl_stream;

          tx_online <= d_tx_online;
          rx_online <= d_rx_online;
        end // else: !if(~rst_n)
    end // always_ff @ (posedge  com_clk or negedge rst_n)

endmodule // lpif_ctl

// Local Variables:
// verilog-library-directories:("." "${PROJ_DIR}/common/rtl")
// verilog-auto-inst-param-value:t
// End:
