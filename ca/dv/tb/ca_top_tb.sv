////////////////////////////////////////////////////////////////////////////////////////////////////
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
// Functional Descript: Channel Alignment Testbench File
//
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_TOP_TB_
`define _CA_TOP_TB_

//.........TIMESCALE.............
`timescale 1ps/1ps

//.........CONFIG.............
`include "ca_config_define.svi"
`include "ca_GENERATED_defines.svh"

////////////////////////////////////////////////////////////
module ca_top_tb;

    import uvm_pkg::*;
    import ca_pkg::*;
    //-----------------------------------
     parameter osc_period  = 1000;                        // 1 ns  = 1GHz
     parameter avmm_period = osc_period*4;                // 4 ns  = 250MHz
     `ifdef GEN2
       parameter fwd_period     = osc_period/2;             // 2GHz
     `endif
     `ifdef GEN1
       parameter fwd_period     = osc_period;             // 1GHz
     `endif
     parameter msr_wr_period  = `MSR_GEAR * fwd_period; 
     parameter msr_rd_period  = `MSR_GEAR * fwd_period;
     parameter slv_wr_period  = `SLV_GEAR * fwd_period;
     parameter slv_rd_period  = `SLV_GEAR * fwd_period;

    // used to communicate w/ AIB network
    logic [(`TB_DIE_A_BUS_BIT_WIDTH*`MAX_NUM_CHANNELS)-1:0] die_a_tx_dout;
    logic [(`TB_DIE_B_BUS_BIT_WIDTH*`MAX_NUM_CHANNELS)-1:0] die_b_tx_dout;
    //
    logic [(`TB_DIE_A_BUS_BIT_WIDTH*`MAX_NUM_CHANNELS)-1:0] die_a_rx_din;
    logic [(`TB_DIE_B_BUS_BIT_WIDTH*`MAX_NUM_CHANNELS)-1:0] die_b_rx_din;

    logic [(`TB_DIE_A_BUS_BIT_WIDTH*`MAX_NUM_CHANNELS)-1:0] delay_rxdin_die_a;
    logic [(`TB_DIE_B_BUS_BIT_WIDTH*`MAX_NUM_CHANNELS)-1:0] delay_rxdin_die_b;

    logic [(`TB_DIE_A_BUS_BIT_WIDTH*`MAX_NUM_CHANNELS)-1:0] die_a_dout_delay;
    logic [(`TB_DIE_B_BUS_BIT_WIDTH*`MAX_NUM_CHANNELS)-1:0] die_b_dout_delay;

    //-----------------------------------
    reg    [`MAX_NUM_CHANNELS-1:0]   clk_lane_a;
    reg    [`MAX_NUM_CHANNELS-1:0]   clk_lane_b;

    reg    clk_die_a                 = 1'b0;
    reg    clk_die_b                 = 1'b0;

    // AIB clks
    reg    avmm_clk     = 1'b0;
    reg    osc_clk      = 1'b0;
    reg    fwd_clk      = 1'b0;
    reg    msr_rd_clk   = 1'b0;
    reg    msr_wr_clk   = 1'b0;
    reg    slv_rd_clk   = 1'b0;
    reg    slv_wr_clk   = 1'b0;

    reg [`MLLPHY_WIDTH*`CA_NUM_CHAN-1 :0] aib_ddelay_in_m,   aib_ddelay_out_m,  aib_no_ddelay_out_m;
    reg [`SLLPHY_WIDTH*`CA_NUM_CHAN-1 :0] aib_ddelay_in_s,   aib_ddelay_out_s,  aib_no_ddelay_out_s;
    reg [`CA_NUM_CHAN-1:0]                s_rx_align_done_d, m_rx_align_done_d, fs_mac_rdy_d;
    // wires
    //--------------------------------------------------------------
    wire   tb_reset_l;

    wire   die_a_align_done;
    wire   die_b_align_done;
    logic [23:0]		master_ver1_tx_transfer_en;
    logic [23:0]		master_ver1_rx_transfer_en;

    wire [`CA_NUM_CHAN-1:0] ms_tx_transfer_en_d, ms_rx_transfer_en_d;
    wire [`CA_NUM_CHAN-1:0] sl_tx_transfer_en_d, sl_rx_transfer_en_d;

    localparam DELAY_X_VALUE         = 8'd10; // Should be greater than DLL_TIME. Indicates when RX CA is ready for Strobe
    localparam DELAY_XZ_VALUE        = 8'd14; // Should be greater than DELAY_X_VALUE. Indicates when TX CA should send 1shot strobe
    localparam DELAY_Z_VALUE         = 8'd4;  // Should be greater than DELAY_X_VALUE. Indicates when TX LLINK to stop user strobe
    localparam DELAY_YZ_VALUE        = 8'd30; // Should be greater than DELAY_XZ_VALUE. Indicates when TX LLINK can use reuse strobes and send data.
    logic [`MAX_NUM_CHANNELS-1:0]        p2p_master_sl_tx_transfer_en;     
    logic [`MAX_NUM_CHANNELS-1:0]        p2p_master_ms_tx_transfer_en;     
    logic [`MAX_NUM_CHANNELS-1:0]        p2p_slave_ms_tx_transfer_en;      
    logic [`MAX_NUM_CHANNELS-1:0]        p2p_slave_sl_tx_transfer_en;      
    logic               master_align_err;             
    logic               master_tx_stb_pos_coding_err; 
    logic               master_tx_stb_pos_err;        
    logic               master_rx_stb_pos_coding_err; 
    logic               master_rx_stb_pos_err;        

`ifdef P2P_LITE
    parameter FULL                   = 4'h1;
    parameter HALF                   = 4'h2;
    parameter QUARTER                = 4'h4;

    localparam CHAN_0_M2S_LATENCY    = 8'd2; // This number equates to how many s_wr_clk cycles it takes to go from the data (MAC) input of one PHY to the data (MAC) output of the other PHY.
    localparam CHAN_1_M2S_LATENCY    = 8'd1; // This number equates to how many s_wr_clk cycles it takes to go from the data (MAC) input of one PHY to the data (MAC) output of the other PHY.
    localparam CHAN_0_S2M_LATENCY    = 8'd7; // This number equates to how many m_wr_clk cycles it takes to go from the data (MAC) input of one PHY to the data (MAC) output of the other PHY.
    localparam CHAN_1_S2M_LATENCY    = 8'd5; // This number equates to how many m_wr_clk cycles it takes to go from the data (MAC) input of one PHY to the data (MAC) output of the other PHY.

     // This determines how long it takes for Word Markers to Align int he RX
    localparam CHAN_0_M2S_DLL_TIME   = 8'd5;
    localparam CHAN_1_M2S_DLL_TIME   = 8'd5;
    localparam CHAN_0_S2M_DLL_TIME   = 8'd5;
    localparam CHAN_1_S2M_DLL_TIME   = 8'd5;

    localparam CHAN_M2S_MARKER_LOC   = 8'd39;
    localparam CHAN_S2M_MARKER_LOC   = 8'd39;

    int        m2s_delay_p2p[`MAX_NUM_CHANNELS-1:0] = '{`MAX_NUM_CHANNELS{$urandom_range(`CHAN_DELAY_MAX, `CHAN_DELAY_MIN)}};
    int        s2m_delay_p2p[`MAX_NUM_CHANNELS-1:0] = '{`MAX_NUM_CHANNELS{$urandom_range(`CHAN_DELAY_MAX, `CHAN_DELAY_MIN)}};
`endif

`ifdef P2P_LITE
    logic  tb_do_aib_reset = 0;
    logic  tb_do_aib_prog  = 0;
`else
    logic  tb_do_aib_reset = 1;
    logic  tb_do_aib_prog  = 1;
`endif
    logic               aib_ready    = 0;


   //// RESET
    assign tb_reset_l = reset_if_0.reset_l;

    logic       slave_user_stb;
    logic       master_user_stb;
    bit [3:0]   slv_gear_4bit, msr_gear_4bit;
    assign      slv_gear_4bit = `SLV_GEAR;
    assign      msr_gear_4bit = `MSR_GEAR;

marker_gen marker_gen_im
     (/*AUTOINST*/
      // Outputs
      //.user_marker                      (tx_mrk_userbit_master[3:0]), // Templated
      .user_marker                      (ca_die_a_tx_tb_out_if.user_marker), // Templated
      // Inputs
      .clk                              (msr_wr_clk),            // Templated
      .rst_n                            (tb_reset_l),            // Templated
      .local_rate                       (msr_gear_4bit),         // Templated
      .remote_rate                      (slv_gear_4bit));        // Templated

 marker_gen marker_gen_is
     (/*AUTOINST*/
      // Outputs
     .user_marker                       (ca_die_b_tx_tb_out_if.user_marker), // Templated
      // Inputs
      .clk                              (slv_wr_clk),                        // Templated
      .rst_n                            (tb_reset_l),                        // Templated
      .local_rate                       (slv_gear_4bit),         // Templated
      .remote_rate                      (msr_gear_4bit));        // Templated


   // Should be remote side's expected interval, multiplied by Remote Rate / Local Rate.
   assign ca_die_a_tx_tb_in_if.strobe_gen_m_interval = ((ca_s_if.rx_stb_intv * `SLV_GEAR) / `MSR_GEAR);
   assign ca_die_b_tx_tb_in_if.strobe_gen_s_interval = ((ca_m_if.rx_stb_intv * `MSR_GEAR) / `SLV_GEAR);

   strobe_gen strobe_gen_im (
      .clk      (msr_wr_clk),
      .rst_n    (tb_reset_l),
      .interval (ca_die_a_tx_tb_in_if.strobe_gen_m_interval),
      .user_marker(|ca_die_a_tx_tb_out_if.user_marker),
      .online(1'b1),
      .user_strobe(ca_die_a_tx_tb_out_if.user_stb));

   strobe_gen strobe_gen_is (

      .clk      (slv_wr_clk),
      .rst_n    (tb_reset_l),
      .interval (ca_die_b_tx_tb_in_if.strobe_gen_s_interval),
      .user_marker(|ca_die_b_tx_tb_out_if.user_marker),
      .online(1'b1),
      .user_strobe(ca_die_b_tx_tb_out_if.user_stb));

assign ca_die_a_tx_tb_in_if.user_marker = ca_die_a_tx_tb_out_if.user_marker;
assign ca_die_b_tx_tb_in_if.user_marker = ca_die_b_tx_tb_out_if.user_marker;
assign ca_die_a_rx_tb_in_if.user_marker = ca_die_a_tx_tb_out_if.user_marker;
assign ca_die_b_rx_tb_in_if.user_marker = ca_die_b_tx_tb_out_if.user_marker;
assign ca_die_a_tx_tb_in_if.user_stb    = ca_die_a_tx_tb_out_if.user_stb;
assign ca_die_b_tx_tb_in_if.user_stb    = ca_die_b_tx_tb_out_if.user_stb;
assign ca_die_a_rx_tb_in_if.user_stb    = ca_die_a_tx_tb_out_if.user_stb;
assign ca_die_b_rx_tb_in_if.user_stb    = ca_die_b_tx_tb_out_if.user_stb;

  `ifdef MS_AIB_GEN1  // Master ver1 dont have transfer_en Terry Fix ??
   // RX/TX may appear swapped below, but that is right. tx_transfer_en = ..... rx_transfer_en and vice versa.
  assign master_ver1_tx_transfer_en [23:0] =
     {ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_23.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_22.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_21.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_20.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_19.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_18.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_17.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_16.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_15.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_14.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_13.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_12.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_11.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_10.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_9.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en ,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_8.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en ,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_7.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en ,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_6.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en ,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_5.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en ,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_4.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en ,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_3.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en ,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_2.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en ,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_1.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en ,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_0.c3aibadapt.adapt_rxchnl.rxrst_ctl.rx_hrdrst_hssi_rx_transfer_en };

   assign master_ver1_rx_transfer_en [23:0] =
     {ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_23.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_22.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_21.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_20.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_19.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_18.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_17.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_16.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_15.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_14.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_13.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_12.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_11.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_10.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_9.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en ,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_8.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en ,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_7.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en ,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_6.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en ,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_5.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en ,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_4.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en ,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_3.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en ,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_2.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en ,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_1.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en ,
      ca_top_tb.aib_m0.dut.u_aib_top.u_c3aibadapt_wrap_top.u_c3aibadapt_0.c3aibadapt.adapt_txchnl.txrst_ctl.tx_hrdrst_hssi_tx_transfer_en };
  `endif // MS_AIB_GEN1  // Master ver1 dont have transfer_en Terry Fix ??



`ifdef CA_YELLOW_OVAL
        assign ca_die_a_rx_tb_in_if.rx_dout  = ca_m_if.rx_dout;
        assign ca_die_b_rx_tb_in_if.rx_dout  = ca_s_if.rx_dout;
        assign ca_m_if.tx_din                = ca_die_a_tx_tb_out_if.tx_din;
        assign ca_s_if.tx_din                = ca_die_b_tx_tb_out_if.tx_din;
 `ifdef AIB_DATA_DELAY
   `ifdef MS_AIB_GEN1  // Master ver1 dont have transfer_en Terry Fix ??
       assign ca_die_a_tx_tb_out_if.tx_online         = &{master_ver1_tx_transfer_en[`CA_NUM_CHAN-1:0],master_ver1_rx_transfer_en[`CA_NUM_CHAN-1:0]};
       assign ca_die_a_rx_tb_in_if.rx_online          = &{master_ver1_tx_transfer_en[`CA_NUM_CHAN-1:0],master_ver1_rx_transfer_en[`CA_NUM_CHAN-1:0]};
   `else
        assign ca_die_a_tx_tb_out_if.tx_online        = &ms_tx_transfer_en_d[`CA_NUM_CHAN-1:0];
        assign ca_die_a_rx_tb_in_if.rx_online         = &ms_rx_transfer_en_d[`CA_NUM_CHAN-1:0];
    `endif
        assign ca_die_b_tx_tb_out_if.tx_online        = &sl_tx_transfer_en_d[`CA_NUM_CHAN-1:0];
        assign ca_die_b_rx_tb_in_if.rx_online         = &sl_rx_transfer_en_d[`CA_NUM_CHAN-1:0];
   `else
  `ifdef MS_AIB_GEN1  // Master ver1 dont have transfer_en Terry Fix ??
       assign ca_die_a_tx_tb_out_if.tx_online         = &{master_ver1_tx_transfer_en[`CA_NUM_CHAN-1:0],master_ver1_rx_transfer_en[`CA_NUM_CHAN-1:0]};
       assign ca_die_a_rx_tb_in_if.rx_online          = &{master_ver1_tx_transfer_en[`CA_NUM_CHAN-1:0],master_ver1_rx_transfer_en[`CA_NUM_CHAN-1:0]};
   `else
       assign ca_die_a_tx_tb_out_if.tx_online         = &aib_mac_if_m0.ms_tx_transfer_en[`CA_NUM_CHAN-1:0];
       assign ca_die_a_rx_tb_in_if.rx_online          = &aib_mac_if_m0.ms_rx_transfer_en[`CA_NUM_CHAN-1:0];  
   `endif
        assign ca_die_b_tx_tb_out_if.tx_online        = &aib_mac_if_s0.sl_tx_transfer_en[`CA_NUM_CHAN-1:0]; 
        assign ca_die_b_rx_tb_in_if.rx_online         = &aib_mac_if_s0.sl_rx_transfer_en[`CA_NUM_CHAN-1:0]; 
   `endif  

//
// `ifdef AIB_DATA_DELAY
//        assign ca_die_a_tx_tb_out_if.tx_online        = &ms_tx_transfer_en_d[`CA_NUM_CHAN-1:0];
//        assign ca_die_a_rx_tb_in_if.rx_online         = &ms_rx_transfer_en_d[`CA_NUM_CHAN-1:0];
//        assign ca_die_b_tx_tb_out_if.tx_online        = &sl_tx_transfer_en_d[`CA_NUM_CHAN-1:0];
//        assign ca_die_b_rx_tb_in_if.rx_online         = &sl_rx_transfer_en_d[`CA_NUM_CHAN-1:0];
//   `else
//        assign ca_die_a_tx_tb_out_if.tx_online        = &aib_mac_if_m0.ms_tx_transfer_en[`CA_NUM_CHAN-1:0];
//        assign ca_die_a_rx_tb_in_if.rx_online         = &aib_mac_if_m0.ms_rx_transfer_en[`CA_NUM_CHAN-1:0];  
//        assign ca_die_a_tx_tb_out_if.tx_online        = &aib_mac_if_s0.sl_tx_transfer_en[`CA_NUM_CHAN-1:0]; 
//        assign ca_die_b_rx_tb_in_if.rx_online         = &aib_mac_if_s0.sl_rx_transfer_en[`CA_NUM_CHAN-1:0]; 
//   `endif
        assign ca_die_a_tx_tb_in_if.tx_online         = ca_die_a_tx_tb_out_if.tx_online; 
        assign ca_die_b_tx_tb_in_if.tx_online         = ca_die_b_tx_tb_out_if.tx_online;
        //force0_tx_rx_online will be used in tx_online_test 
        assign ca_m_if.tx_online                     = (~gen_if.force0_tx_rx_online) & ca_die_a_tx_tb_out_if.tx_online; 
        assign ca_s_if.tx_online                     = (~gen_if.force0_tx_rx_online) & ca_die_b_tx_tb_out_if.tx_online;  
        assign ca_m_if.rx_online                     = (~gen_if.force0_tx_rx_online) & ca_die_a_rx_tb_in_if.rx_online; 
        assign ca_s_if.rx_online                     = (~gen_if.force0_tx_rx_online) & ca_die_b_rx_tb_in_if.rx_online; 

        assign ca_die_a_rx_tb_in_if.align_err              = ca_m_if.align_err;  
        assign ca_die_a_tx_tb_in_if.tx_stb_pos_err         = ca_m_if.tx_stb_pos_err;  
        assign ca_die_a_tx_tb_in_if.tx_stb_pos_coding_err  = ca_m_if.tx_stb_pos_coding_err;  
        assign ca_die_a_rx_tb_in_if.rx_stb_pos_err         = ca_m_if.rx_stb_pos_err;  
        assign ca_die_a_rx_tb_in_if.rx_stb_pos_coding_err  = ca_m_if.rx_stb_pos_coding_err; 
 
        assign ca_die_b_rx_tb_in_if.align_err              = ca_s_if.align_err;  
        assign ca_die_b_tx_tb_in_if.tx_stb_pos_err         = ca_s_if.tx_stb_pos_err;  
        assign ca_die_b_tx_tb_in_if.tx_stb_pos_coding_err  = ca_s_if.tx_stb_pos_coding_err;  
        assign ca_die_b_rx_tb_in_if.rx_stb_pos_err         = ca_s_if.rx_stb_pos_err;  
        assign ca_die_b_rx_tb_in_if.rx_stb_pos_coding_err  = ca_s_if.rx_stb_pos_coding_err;  
            
        assign ca_m_if.align_fly        = ca_die_a_rx_tb_in_if.align_fly;
        assign ca_s_if.align_fly        = ca_die_b_rx_tb_in_if.align_fly;
        assign ca_m_if.tx_stb_en        = ca_die_a_tx_tb_out_if.tx_stb_en;
        assign ca_s_if.tx_stb_en        = ca_die_b_tx_tb_out_if.tx_stb_en;
        assign ca_m_if.tx_stb_rcvr      = ca_die_a_rx_tb_in_if.tx_stb_rcvr;
        assign ca_s_if.tx_stb_rcvr      = ca_die_b_rx_tb_in_if.tx_stb_rcvr;
        assign ca_m_if.rden_dly         = ca_die_a_rx_tb_in_if.rden_dly;
        assign ca_s_if.rden_dly         = ca_die_a_rx_tb_in_if.rden_dly;

        assign ca_m_if.delay_x_value    = ca_die_a_rx_tb_in_if.delay_x_value;
        assign ca_m_if.delay_z_value    = ca_die_a_rx_tb_in_if.delay_xz_value;
        assign ca_s_if.delay_x_value    = ca_die_b_rx_tb_in_if.delay_x_value;
        assign ca_s_if.delay_z_value    = ca_die_b_rx_tb_in_if.delay_xz_value;


        assign ca_m_if.fifo_full_val    = ca_die_a_rx_tb_in_if.fifo_full_val;
        assign ca_m_if.fifo_pfull_val   = ca_die_a_rx_tb_in_if.fifo_pfull_val;
        assign ca_m_if.fifo_empty_val   = ca_die_a_rx_tb_in_if.fifo_empty_val;
        assign ca_m_if.fifo_pempty_val  = ca_die_a_rx_tb_in_if.fifo_pempty_val;
        assign ca_s_if.fifo_full_val    = ca_die_b_rx_tb_in_if.fifo_full_val;
        assign ca_s_if.fifo_pfull_val   = ca_die_b_rx_tb_in_if.fifo_pfull_val;
        assign ca_s_if.fifo_empty_val   = ca_die_b_rx_tb_in_if.fifo_empty_val;
        assign ca_s_if.fifo_pempty_val  = ca_die_b_rx_tb_in_if.fifo_pempty_val;
   
	assign ca_m_if.tx_stb_wd_sel	= ca_die_a_tx_tb_out_if.tx_stb_wd_sel;
	assign ca_m_if.tx_stb_bit_sel 	= ca_die_a_tx_tb_out_if.tx_stb_bit_sel; 
	assign ca_m_if.tx_stb_intv 	= ca_die_a_tx_tb_out_if.tx_stb_intv;

        assign ca_m_if.rx_stb_wd_sel  	= ca_die_a_rx_tb_in_if.rx_stb_wd_sel;
        assign ca_m_if.rx_stb_bit_sel 	= ca_die_a_rx_tb_in_if.rx_stb_bit_sel;
        assign ca_m_if.rx_stb_intv	= ca_die_a_rx_tb_in_if.rx_stb_intv;

        assign ca_s_if.tx_stb_wd_sel  	= ca_die_b_tx_tb_out_if.tx_stb_wd_sel; 
        assign ca_s_if.tx_stb_bit_sel 	= ca_die_b_tx_tb_out_if.tx_stb_bit_sel;
        assign ca_s_if.tx_stb_intv	= ca_die_b_tx_tb_out_if.tx_stb_intv;

        assign ca_s_if.rx_stb_wd_sel	= ca_die_b_rx_tb_in_if.rx_stb_wd_sel;
        assign ca_s_if.rx_stb_bit_sel 	= ca_die_b_rx_tb_in_if.rx_stb_bit_sel;
        assign ca_s_if.rx_stb_intv	= ca_die_b_rx_tb_in_if.rx_stb_intv;

        assign gen_if.die_a_align_error    = ca_m_if.align_err;
        assign gen_if.die_b_align_error    = ca_s_if.align_err;
        assign gen_if.die_a_align_done     = ca_m_if.align_done;
        assign gen_if.die_b_align_done     = ca_s_if.align_done;
        assign gen_if.die_a_rx_stb_pos_err = ca_m_if.rx_stb_pos_err;         
        assign gen_if.die_b_rx_stb_pos_err = ca_s_if.rx_stb_pos_err;         
        assign gen_if.die_a_rx_stb_pos_coding_err = ca_m_if.rx_stb_pos_coding_err;  
        assign gen_if.die_b_rx_stb_pos_coding_err = ca_s_if.rx_stb_pos_coding_err; 
        assign gen_if.die_a_tx_dout         = ca_m_if.tx_dout;
        assign gen_if.die_b_tx_dout         = ca_s_if.tx_dout;
        assign gen_if.die_a_tx_online       = ca_m_if.tx_online;
        assign gen_if.die_b_tx_online       = ca_s_if.tx_online;
    genvar ch;
    generate
       for(ch=0; ch< `TB_DIE_A_NUM_CHANNELS; ch++) begin 
           assign gen_if.die_a_fifo_full[ch]      = ca_m_if.fifo_full[ch];
           assign gen_if.die_a_fifo_pfull[ch]     = ca_m_if.fifo_pfull[ch];  
           assign gen_if.die_a_fifo_empty[ch]     = ca_m_if.fifo_empty[ch];  
           assign gen_if.die_a_fifo_pempty[ch]    = ca_m_if.fifo_pempty[ch];  
           assign gen_if.die_b_fifo_full[ch]      = ca_s_if.fifo_full[ch];  
           assign gen_if.die_b_fifo_pfull[ch]     = ca_s_if.fifo_pfull[ch];  
           assign gen_if.die_b_fifo_empty[ch]     = ca_s_if.fifo_empty[ch];  
           assign gen_if.die_b_fifo_pempty[ch]    = ca_s_if.fifo_pempty[ch]; 
       end
  endgenerate
/////////////////////////  DUT instantiation started  ////////////////////////////////////////

  ca_if #( .DWIDTH (`TB_DIE_A_BUS_BIT_WIDTH),   .CHNL_NUM (`CA_NUM_CHAN))
           ca_m_if();
  ca_if #( .DWIDTH (`TB_DIE_B_BUS_BIT_WIDTH),   .CHNL_NUM (`CA_NUM_CHAN))
           ca_s_if();

  ca_DUT_wrapper #(.NUM_CHANNELS      (`TB_DIE_A_NUM_CHANNELS),
                   .BITS_PER_CHANNEL  (`TB_DIE_A_BUS_BIT_WIDTH),
                   .AD_WIDTH          (`TB_DIE_A_AD_WIDTH),
                   .SYNC_FIFO         (`SYNC_FIFO))
  ca_DUT_wrapper_m0 (
        clk_lane_a[`TB_DIE_A_NUM_CHANNELS-1:0],
        clk_lane_a[0],    //This is com_clk
        tb_reset_l,
        ca_m_if
  );

  ca_DUT_wrapper #(.NUM_CHANNELS      (`TB_DIE_B_NUM_CHANNELS),
                   .BITS_PER_CHANNEL  (`TB_DIE_B_BUS_BIT_WIDTH),
                   .AD_WIDTH          (`TB_DIE_B_AD_WIDTH),
                   .SYNC_FIFO         (`SYNC_FIFO))
  ca_DUT_wrapper_s0 (
        clk_lane_b[`TB_DIE_B_NUM_CHANNELS-1:0],
        clk_lane_b[0],
        tb_reset_l,
        ca_s_if
  );

`include "../../../aib/dv/top/phy_to_aib.sv"
////////////////////////////////////////////////////
`else
    //--------------------------------------------------------------
    // Channel Alignment DIE A : DUT instance
    //--------------------------------------------------------------
    ca #(.NUM_CHANNELS      (`TB_DIE_A_NUM_CHANNELS),
         .BITS_PER_CHANNEL  (`TB_DIE_A_BUS_BIT_WIDTH),
         .AD_WIDTH          (`TB_DIE_A_AD_WIDTH),
         .SYNC_FIFO         (`SYNC_FIFO)
        ) ca_die_a (

             .lane_clk               (`SYNC_FIFO ? {`TB_DIE_A_NUM_CHANNELS{clk_die_a}} : clk_lane_a[`TB_DIE_A_NUM_CHANNELS-1:0]),
             .com_clk                (clk_die_a),
             .rst_n                  (tb_reset_l),
             .tx_online              (ca_die_a_tx_tb_out_if.tx_online),
             .rx_online              (ca_die_a_rx_tb_in_if.rx_online),
             .tx_stb_en              (ca_die_a_tx_tb_out_if.tx_stb_en),
             .tx_stb_rcvr            (ca_die_a_tx_tb_out_if.tx_stb_rcvr),
             .align_fly              (ca_die_a_rx_tb_in_if.align_fly),
             .rden_dly               (ca_die_a_rx_tb_in_if.rden_dly),
             .delay_x_value          (16'h2), // FIXME
             .delay_z_value          (16'h2), // FIXME
             .tx_stb_wd_sel          (ca_die_a_tx_tb_out_if.tx_stb_wd_sel),
             .tx_stb_bit_sel         (ca_die_a_tx_tb_out_if.tx_stb_bit_sel),
             .tx_stb_intv            (ca_die_a_tx_tb_out_if.tx_stb_intv),
             .rx_stb_wd_sel          (ca_die_a_rx_tb_in_if.rx_stb_wd_sel),
             .rx_stb_bit_sel         (ca_die_a_rx_tb_in_if.rx_stb_bit_sel),
             .rx_stb_intv            (ca_die_a_rx_tb_in_if.rx_stb_intv),
             .tx_din                 (ca_die_a_tx_tb_out_if.tx_din),
             .tx_dout                (die_a_tx_dout[(`TB_DIE_A_BUS_BIT_WIDTH*`TB_DIE_A_NUM_CHANNELS)-1:0]),
          `ifdef CHAN_DELAY_ENB
             .rx_din                 (die_b_dout_delay[(`TB_DIE_A_BUS_BIT_WIDTH*`TB_DIE_A_NUM_CHANNELS)-1:0]),
          `else
             .rx_din                 (die_a_rx_din[(`TB_DIE_A_BUS_BIT_WIDTH*`TB_DIE_A_NUM_CHANNELS)-1:0]),
          `endif
             .rx_dout                (ca_die_a_rx_tb_in_if.rx_dout),
             .align_done             (die_a_align_done),
             .align_err              (ca_die_a_rx_tb_in_if.align_err),
             .tx_stb_pos_err         (ca_die_a_tx_tb_in_if.tx_stb_pos_err),
             .tx_stb_pos_coding_err  (ca_die_a_tx_tb_in_if.tx_stb_pos_coding_err),
             .rx_stb_pos_err         (ca_die_a_rx_tb_in_if.rx_stb_pos_err),
             .rx_stb_pos_coding_err  (ca_die_a_rx_tb_in_if.rx_stb_pos_coding_err),
             .fifo_full_val          (ca_die_a_rx_tb_in_if.fifo_full_val),
             .fifo_pfull_val         (ca_die_a_rx_tb_in_if.fifo_pfull_val),
             .fifo_empty_val         (ca_die_a_rx_tb_in_if.fifo_empty_val),
             .fifo_pempty_val        (ca_die_a_rx_tb_in_if.fifo_pempty_val),
             .fifo_full              (ca_die_a_rx_tb_in_if.fifo_full),
             .fifo_pfull             (ca_die_a_rx_tb_in_if.fifo_pfull),
             .fifo_empty             (ca_die_a_rx_tb_in_if.fifo_empty),
             .fifo_pempty            (ca_die_a_rx_tb_in_if.fifo_pempty)
         );

    //--------------------------------------------------------------
    // Channel Alignment DIE B : DUT instance
    //--------------------------------------------------------------
    ca #(.NUM_CHANNELS      (`TB_DIE_B_NUM_CHANNELS),
         .BITS_PER_CHANNEL  (`TB_DIE_B_BUS_BIT_WIDTH),
         .AD_WIDTH          (`TB_DIE_B_AD_WIDTH),
         .SYNC_FIFO         (`SYNC_FIFO)
        ) ca_die_b (
             .lane_clk               (`SYNC_FIFO ? {`TB_DIE_B_NUM_CHANNELS{clk_die_b}} : clk_lane_b[`TB_DIE_B_NUM_CHANNELS-1:0]),
             .com_clk                (clk_die_b),
             .rst_n                  (tb_reset_l),
             .tx_online              (ca_die_b_tx_tb_out_if.tx_online),
             .rx_online              (ca_die_b_rx_tb_in_if.rx_online),
             .tx_stb_en              (ca_die_b_tx_tb_out_if.tx_stb_en),
             .tx_stb_rcvr            (ca_die_b_tx_tb_out_if.tx_stb_rcvr),
             .align_fly              (ca_die_b_rx_tb_in_if.align_fly),
             .rden_dly               (ca_die_b_rx_tb_in_if.rden_dly),
             .delay_x_value          (16'h2), // FIXME
             .delay_z_value          (16'h2), // FIXME
             .tx_stb_wd_sel          (ca_die_b_tx_tb_out_if.tx_stb_wd_sel),
             .tx_stb_bit_sel         (ca_die_b_tx_tb_out_if.tx_stb_bit_sel),
             .tx_stb_intv            (ca_die_b_tx_tb_out_if.tx_stb_intv),
             .rx_stb_wd_sel          (ca_die_b_rx_tb_in_if.rx_stb_wd_sel),
             .rx_stb_bit_sel         (ca_die_b_rx_tb_in_if.rx_stb_bit_sel),
             .rx_stb_intv            (ca_die_b_rx_tb_in_if.rx_stb_intv),
             .tx_din                 (ca_die_b_tx_tb_out_if.tx_din),
             .tx_dout                (die_b_tx_dout[(`TB_DIE_B_BUS_BIT_WIDTH*`TB_DIE_B_NUM_CHANNELS)-1:0]),
          `ifdef CHAN_DELAY_ENB
             .rx_din                 (die_a_dout_delay[(`TB_DIE_B_BUS_BIT_WIDTH*`TB_DIE_B_NUM_CHANNELS)-1:0]),
          `else
             .rx_din                 (die_b_rx_din[(`TB_DIE_B_BUS_BIT_WIDTH*`TB_DIE_B_NUM_CHANNELS)-1:0]),
          `endif
             .rx_dout                (ca_die_b_rx_tb_in_if.rx_dout),
             .align_done             (die_b_align_done),
             .align_err              (ca_die_b_rx_tb_in_if.align_err),
             .tx_stb_pos_err         (ca_die_b_tx_tb_in_if.tx_stb_pos_err),
             .tx_stb_pos_coding_err  (ca_die_b_tx_tb_in_if.tx_stb_pos_coding_err),
             .rx_stb_pos_err         (ca_die_b_rx_tb_in_if.rx_stb_pos_err),
             .rx_stb_pos_coding_err  (ca_die_b_rx_tb_in_if.rx_stb_pos_coding_err),
             .fifo_full_val          (ca_die_b_rx_tb_in_if.fifo_full_val),
             .fifo_pfull_val         (ca_die_b_rx_tb_in_if.fifo_pfull_val),
             .fifo_empty_val         (ca_die_b_rx_tb_in_if.fifo_empty_val),
             .fifo_pempty_val        (ca_die_b_rx_tb_in_if.fifo_pempty_val),
             .fifo_full              (ca_die_b_rx_tb_in_if.fifo_full),
             .fifo_pfull             (ca_die_b_rx_tb_in_if.fifo_pfull),
             .fifo_empty             (ca_die_b_rx_tb_in_if.fifo_empty),
             .fifo_pempty            (ca_die_b_rx_tb_in_if.fifo_pempty)
         );
`endif

///////////////////////DUT instantiation completed////////////////////////////////////
`ifdef P2P_LITE
genvar i;
generate
 for(i=0;i<`MAX_NUM_CHANNELS;i+=1) begin : p2p_inst
    p2p_lite p2p_i(
       .master_sl_tx_transfer_en     (p2p_master_sl_tx_transfer_en[i]),
       .master_ms_tx_transfer_en     (p2p_master_ms_tx_transfer_en[i]),
       .slave_sl_tx_transfer_en      (p2p_slave_sl_tx_transfer_en[i]) ,
       .slave_ms_tx_transfer_en      (p2p_slave_ms_tx_transfer_en[i]) ,
       .s2m_data_out                 (die_a_rx_din[((i+1)*`TB_DIE_A_BUS_BIT_WIDTH-1):(i*`TB_DIE_A_BUS_BIT_WIDTH)]),
       .m2s_data_out                 (die_b_rx_din[((i+1)*`TB_DIE_B_BUS_BIT_WIDTH-1):(i*`TB_DIE_B_BUS_BIT_WIDTH)]),
       .fwd_clk                      (fwd_clk),
       .ns_adapter_rstn              (tb_reset_l),
       .m_wr_clk                     (msr_wr_clk),
       .s_wr_clk                     (msr_rd_clk),
       .m2s_data_in                  (die_a_tx_dout[((i+1)*`TB_DIE_A_BUS_BIT_WIDTH-1):(i*`TB_DIE_A_BUS_BIT_WIDTH)]),
       .s2m_data_in                  (die_b_tx_dout[((i+1)*`TB_DIE_B_BUS_BIT_WIDTH-1):(i*`TB_DIE_B_BUS_BIT_WIDTH)]),
       //`ifdef GEN1
        // .tb_m2s_marker_loc          (CHAN_M2S_MARKER_LOC),
        // .tb_s2m_marker_loc          (CHAN_S2M_MARKER_LOC),
       // `endif
       //`ifdef GEN2
       .tb_m2s_marker_loc            (8'd77),
       .tb_s2m_marker_loc            (8'd77),
       //`endif
       .tb_master_rate               (MASTER_RATE),
       .tb_slave_rate                (SLAVE_RATE),
       .m_gen2_mode                  (`MODE_GEN2),  /////0:gen1    1:gen2  in ca_GENERATED_defines
`ifdef P2P_LITE_CH_DELAY_ENB
       .tb_m2s_latency               (m2s_delay_p2p[i]),
       .tb_s2m_latency               (s2m_delay_p2p[i]),
`else
       .tb_m2s_latency               (CHAN_0_M2S_LATENCY),
       .tb_s2m_latency               (CHAN_0_S2M_LATENCY),
`endif
       .tb_master_rx_dll_time        (CHAN_0_M2S_DLL_TIME),
       .tb_slave_rx_dll_time         (CHAN_0_M2S_DLL_TIME),
       .tb_en_asymmetric             (1'b0));
  end
endgenerate
`endif //P2P_LITE

    //--------------------------------------------------------------
    // agent hookups
    //--------------------------------------------------------------
    // ++++++
    // die a
    // ++++++
    ca_tx_tb_out_if #(.BUS_BIT_WIDTH (`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS)) ca_die_a_tx_tb_out_if (.clk(clk_lane_a[0]), .rst_n(tb_reset_l));
    ca_tx_tb_in_if  #(.BUS_BIT_WIDTH (`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS)) ca_die_a_tx_tb_in_if  (.clk(clk_lane_a[0]), .rst_n(tb_reset_l));
    ca_rx_tb_in_if  #(.BUS_BIT_WIDTH (`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS)) ca_die_a_rx_tb_in_if  (.clk(clk_die_a), .rst_n(tb_reset_l));
    // ++++++
    // die b
    // ++++++
    ca_tx_tb_out_if #(.BUS_BIT_WIDTH (`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS)) ca_die_b_tx_tb_out_if (.clk(clk_lane_b[0]), .rst_n(tb_reset_l));
    ca_tx_tb_in_if  #(.BUS_BIT_WIDTH (`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS)) ca_die_b_tx_tb_in_if  (.clk(clk_lane_b[0]), .rst_n(tb_reset_l));
    ca_rx_tb_in_if  #(.BUS_BIT_WIDTH (`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS)) ca_die_b_rx_tb_in_if  (.clk(clk_die_b), .rst_n(tb_reset_l));

`ifdef CA_YELLOW_OVAL
     assign ca_die_a_tx_tb_out_if.com_clk         = clk_lane_a[0];
     assign ca_die_a_tx_tb_in_if.tx_dout          = ca_m_if.tx_dout; 
     assign ca_die_a_tx_tb_out_if.align_done      = ca_m_if.align_done & ca_s_if.align_done;
     assign ca_die_a_tx_tb_in_if.align_done       = ca_m_if.align_done & ca_s_if.align_done;
     assign ca_die_a_rx_tb_in_if.align_done       = ca_m_if.align_done & ca_s_if.align_done;

     assign ca_die_b_tx_tb_out_if.com_clk         = clk_lane_b[0];
     assign ca_die_b_tx_tb_in_if.tx_dout          = ca_s_if.tx_dout; 
     assign ca_die_b_tx_tb_out_if.align_done      = ca_m_if.align_done & ca_s_if.align_done; 
     assign ca_die_b_tx_tb_in_if.align_done       = ca_m_if.align_done & ca_s_if.align_done;
     assign ca_die_b_rx_tb_in_if.align_done       = ca_m_if.align_done & ca_s_if.align_done;

`else
    assign ca_die_a_tx_tb_out_if.com_clk = clk_die_a;
    assign ca_die_a_tx_tb_in_if.tx_dout  = ca_die_a.tx_dout;

  `ifdef P2P_LITE
     assign ca_die_a_tx_tb_out_if.tx_online            = &{p2p_master_sl_tx_transfer_en[`TB_DIE_A_NUM_CHANNELS-1:0],p2p_master_ms_tx_transfer_en[`TB_DIE_A_NUM_CHANNELS-1:0]};
     assign ca_die_a_tx_tb_in_if.tx_online             = &{p2p_master_sl_tx_transfer_en[`TB_DIE_A_NUM_CHANNELS-1:0],p2p_master_ms_tx_transfer_en[`TB_DIE_A_NUM_CHANNELS-1:0]};
     assign ca_die_a_rx_tb_in_if.rx_online             = &{p2p_master_sl_tx_transfer_en[`TB_DIE_A_NUM_CHANNELS-1:0],p2p_master_ms_tx_transfer_en[`TB_DIE_A_NUM_CHANNELS-1:0]};
  `endif

     assign ca_die_a_tx_tb_out_if.align_done           = die_a_align_done & die_b_align_done;
     assign ca_die_a_tx_tb_in_if.align_done            = die_a_align_done & die_b_align_done;
     assign ca_die_a_rx_tb_in_if.align_done            = die_a_align_done & die_b_align_done;

    // ++++++
    // die b    ///moved in common to P2P and CA_YELLOW_OVAL
    // ++++++
    assign ca_die_b_tx_tb_out_if.com_clk = clk_die_b;
    assign ca_die_b_tx_tb_in_if.tx_dout  = ca_die_b.tx_dout;

  `ifdef P2P_LITE
     assign ca_die_b_tx_tb_out_if.tx_online            = &{p2p_slave_sl_tx_transfer_en[`TB_DIE_B_NUM_CHANNELS-1:0],p2p_slave_ms_tx_transfer_en[`TB_DIE_B_NUM_CHANNELS-1:0]};
     assign ca_die_b_tx_tb_in_if.tx_online             = &{p2p_slave_sl_tx_transfer_en[`TB_DIE_B_NUM_CHANNELS-1:0],p2p_slave_ms_tx_transfer_en[`TB_DIE_B_NUM_CHANNELS-1:0]};
     assign ca_die_b_rx_tb_in_if.rx_online             = &{p2p_slave_sl_tx_transfer_en[`TB_DIE_B_NUM_CHANNELS-1:0],p2p_slave_ms_tx_transfer_en[`TB_DIE_B_NUM_CHANNELS-1:0]};
    `endif

    assign ca_die_b_tx_tb_out_if.align_done            = die_a_align_done & die_b_align_done;
    assign ca_die_b_tx_tb_in_if.align_done             = die_a_align_done & die_b_align_done;
    assign ca_die_b_rx_tb_in_if.align_done             = die_a_align_done & die_b_align_done;
  `endif //of CA_YELLOW_OVAL

    chan_delay_if #(.BUS_BIT_WIDTH (`TB_DIE_A_BUS_BIT_WIDTH)) chan_delay_die_a_if (.clk(clk_die_a), .rst_n(tb_reset_l));
    chan_delay_if #(.BUS_BIT_WIDTH (`TB_DIE_B_BUS_BIT_WIDTH)) chan_delay_die_b_if (.clk(clk_die_b), .rst_n(tb_reset_l));
    reset_if   reset_if_0 (.clk(clk_die_a));
    ca_gen_if  gen_if(.clk(clk_die_a), .rst_n(tb_reset_l));
    assign gen_if.aib_ready = aib_ready;

    // UVM initial block:
    // Virtual interface wrapping & run_test()
    //--------------------------------------------------------------
    initial begin
        /// display seed
        // die a
        $display("Test SEED: %0d", unsigned'($get_initial_random_seed));
        uvm_config_db #(virtual ca_tx_tb_out_if #(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS)))::set( null, "*.ca_die_a_tx_tb_out_agent.*", "ca_tx_tb_out_vif", ca_die_a_tx_tb_out_if);
        uvm_config_db #(virtual ca_tx_tb_in_if #(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS)))::set( null, "*.ca_die_a_tx_tb_in_agent.*", "ca_tx_tb_in_vif", ca_die_a_tx_tb_in_if);
        uvm_config_db #(virtual ca_rx_tb_in_if #(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS)))::set( null, "*.ca_die_a_rx_tb_in_agent.*", "ca_rx_tb_in_vif", ca_die_a_rx_tb_in_if);
        // die b
        uvm_config_db #(virtual ca_tx_tb_out_if #(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS)))::set( null, "*.ca_die_b_tx_tb_out_agent.*", "ca_tx_tb_out_vif", ca_die_b_tx_tb_out_if);
        uvm_config_db #(virtual ca_tx_tb_in_if #(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS)))::set( null, "*.ca_die_b_tx_tb_in_agent.*", "ca_tx_tb_in_vif", ca_die_b_tx_tb_in_if);
        uvm_config_db #(virtual ca_rx_tb_in_if #(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS)))::set( null, "*.ca_die_b_rx_tb_in_agent.*", "ca_rx_tb_in_vif", ca_die_b_rx_tb_in_if);
        // reset
        uvm_config_db #(virtual reset_if)::set( null, "*", "reset_vif", reset_if_0);
        uvm_config_db #(virtual ca_gen_if)::set( null, "*", "gen_vif", gen_if);

        for(int j = 0; j < `MAX_NUM_CHANNELS; j++) begin
            uvm_config_db #(virtual chan_delay_if #(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH)))::set(uvm_root::get(), $sformatf("*.chan_delay_die_b_agent_%0d.*",j), "chan_delay_vif", chan_delay_die_b_if);
        end
        for(int k = 0; k < `MAX_NUM_CHANNELS; k++) begin
             uvm_config_db #(virtual chan_delay_if #(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH)))::set(uvm_root::get(), $sformatf("*.chan_delay_die_a_agent_%0d.*",k), "chan_delay_vif", chan_delay_die_a_if);
        end

        run_test();
        end

    //
    // clocking...
    //
    initial begin //// CA :  com_clk
        clk_die_a = 1'b1;
        forever begin
            #(`TB_DIE_A_CLK/2) clk_die_a <= ~clk_die_a;
        end
    end

    initial begin //// CA : com_clk 
        clk_die_b = 1'b1;
        forever begin
            #(`TB_DIE_B_CLK/2) clk_die_b <= ~clk_die_b;
        end
    end
    
    //......................................................
    // clks for AIB
    //......................................................
    initial begin
        avmm_clk <= 1'b0;
        forever begin
            #(avmm_period/2) avmm_clk <= ~avmm_clk;
        end
    end
    
    initial begin
        osc_clk <= 1'b1;
        forever begin
            #(osc_period/2) osc_clk <= ~osc_clk;
        end
    end
    
    initial begin
        fwd_clk <= 1'b1;
        forever begin
            #(fwd_period/2) fwd_clk  <= ~fwd_clk;
        end
    end
    
    initial begin
        msr_wr_clk <= 1'b1;
        forever begin
            #(msr_wr_period/2) msr_wr_clk <= ~msr_wr_clk;
        end
    end
    
    initial begin
        slv_wr_clk <= 1'b1;
        forever begin
            #(slv_wr_period/2) slv_wr_clk <= ~slv_wr_clk;
        end
    end

    initial begin
        msr_rd_clk <= 1'b1;
        forever begin
            #(msr_rd_period/2) msr_rd_clk <= ~msr_rd_clk; 
        end
    end

    initial begin
        slv_rd_clk <= 1'b1;
        forever begin
            #(slv_rd_period/2) slv_rd_clk <= ~slv_rd_clk;
        end
    end


    //.......................................................
    genvar aclk;
    generate
        for(aclk = 0; aclk < `TB_DIE_A_NUM_CHANNELS; aclk = aclk + 1) begin
            initial begin
                clk_lane_a[aclk] <= 1'b1;
                if(`SYNC_FIFO == 0) #(($urandom_range(3,0)) * (250/2)); // random phase shit delays
                forever begin
                    #(`TB_DIE_A_CLK/2) clk_lane_a[aclk] = ~clk_lane_a[aclk];
                end
            end // int
        end // for
    endgenerate
`ifdef P2P_LITE
    genvar aclk_p2p;
    generate
        for (aclk_p2p = `TB_DIE_A_NUM_CHANNELS; aclk_p2p <`MAX_NUM_CHANNELS  ;aclk_p2p += 1) begin
            initial begin
                clk_lane_a[aclk_p2p] <= 1'b1;
            end // int
        end // for
    endgenerate
`endif
    
    genvar bclk;
    generate
        for(bclk = 0; bclk < `TB_DIE_B_NUM_CHANNELS; bclk = bclk + 1) begin
            initial begin
                clk_lane_b[bclk] <= 1'b1;
                if(`SYNC_FIFO == 0) #(($urandom_range(3,0)) * (250/2)); // random phase shit delays
                forever begin
                    #(`TB_DIE_B_CLK/2) clk_lane_b[bclk] = ~clk_lane_b[bclk];
                end
            end // int
        end // for
    endgenerate
`ifdef P2P_LITE
    genvar bclk_p2p;
    generate
        for (bclk_p2p = `TB_DIE_B_NUM_CHANNELS; bclk_p2p <`MAX_NUM_CHANNELS  ;bclk_p2p += 1) begin
            initial begin
                clk_lane_b[bclk_p2p] <= 1'b1;
            end // int
        end // for
    endgenerate
`endif

    // WAVES
    //--------------------------------------------------------------
`ifndef CA_YELLOW_OVAL
    initial begin
        $shm_open( , 0, , ); $shm_probe( ca_die_a, "CA_DIE_A");
        $shm_open( , 0, , ); $shm_probe( ca_die_b, "CA_DIE_B");
    end
`else
`endif
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`ifdef CA_YELLOW_OVAL
`include "../../../aib/dv/top/aib_vip_top.sv"

////int aib_delay_mem [`MAX_AIB_IF_CNT*2]; ///MAX_AIB_IF_CNT in AIB model limited to 8
int aib_delay_mem[`MAX_NUM_CHANNELS*2];

     initial begin
         for(int j=0; j<`CA_NUM_CHAN; j++) begin
            `ifdef INTER_CHAN_SKEW_S2M
               aib_delay_mem[2*j + 0] = (`INTER_CHAN_SKEW_S2M >> (8*j)) & 8'hff; // S2M aka M RX
            `elsif GLOBAL_MAX_INTER_CH_SKEW
               aib_delay_mem[2*j + 0] = $urandom_range (0, `GLOBAL_MAX_INTER_CH_SKEW); // S2M aka M RX
            `else
               aib_delay_mem[2*j + 0] = 0; // NO SKEW
            `endif

            `ifdef INTER_CHAN_SKEW_M2S
               aib_delay_mem[2*j + 1] = (`INTER_CHAN_SKEW_M2S >> (8*j)) & 8'hff; // M2S aka S Rx
            `elsif GLOBAL_MAX_INTER_CH_SKEW
               aib_delay_mem[2*j + 1] = $urandom_range (0, `GLOBAL_MAX_INTER_CH_SKEW); // M2S aka S Rx
            `else
               aib_delay_mem[2*j + 1] = 0 ; // M2S aka S Rx
            `endif

             $display(" Channel %d Delay Value [Master_RX, Slave_RX] = [%0d,%0d]",
                     j,aib_delay_mem[2*j],aib_delay_mem[2*j + 1]);
         end //for j
     end


genvar i;
    generate
      for (i=0; i<`CA_NUM_CHAN; i++) begin
        assign aib_mac_if_m0.din_ch[i][`MLLPHY_WIDTH :0] = ca_m_if.tx_dout[`MLLPHY_WIDTH*(i+1)-1:`MLLPHY_WIDTH*i];
        assign aib_mac_if_s0.din_ch[i][`SLLPHY_WIDTH :0] = ca_s_if.tx_dout[`SLLPHY_WIDTH*(i+1)-1:`SLLPHY_WIDTH*i];
        // delay_unit #(.delay_bits(`MLLPHY_WIDTH)) ca_mdelay_unit (aib_mac_if_m0.dout_ch[i], ca_m_if.rx_din[`MLLPHY_WIDTH*(i+1)-1:`MLLPHY_WIDTH*i]);
        // delay_unit #(.delay_bits(`SLLPHY_WIDTH)) ca_sdelay_unit (aib_mac_if_s0.dout_ch[i], ca_s_if.rx_din[`SLLPHY_WIDTH*(i+1)-1:`SLLPHY_WIDTH*i]);

     `ifdef MS_AIB_GEN1 // Gen1 40 bits
         assign aib_no_ddelay_out_m[`MLLPHY_WIDTH*(i+1)-1:`MLLPHY_WIDTH*i] = aib_mac_if_m0.dout_ch[i];
         assign aib_ddelay_in_m[`MLLPHY_WIDTH*(i+1)-1:`MLLPHY_WIDTH*i] = aib_mac_if_m0.dout_ch[i];
     `else // AIB2.0 model always 320 bit
         assign aib_no_ddelay_out_m[`MLLPHY_WIDTH*(i+1)-1:`MLLPHY_WIDTH*i] = (aib_mac_if_m0.rx_reg_mode == 1) ?
         aib_mac_if_m0.data_out_reg_mode[80*(i+1)-1:80*i] : aib_mac_if_m0.data_out[320*(i+1)-1:320*i];
         assign aib_ddelay_in_m[`MLLPHY_WIDTH*(i+1)-1:`MLLPHY_WIDTH*i] = (aib_mac_if_m0.rx_reg_mode == 1) ?
         aib_mac_if_m0.data_out_reg_mode[80*(i+1)-1:80*i] : aib_mac_if_m0.data_out[320*(i+1)-1:320*i];
     `endif
     `ifdef SL_AIB_GEN1 // Gen1 80 bits
         assign aib_no_ddelay_out_s[`SLLPHY_WIDTH*(i+1)-1:`SLLPHY_WIDTH*i] = aib_mac_if_s0.dout_ch[i];
         assign aib_ddelay_in_s[`SLLPHY_WIDTH*(i+1)-1:`SLLPHY_WIDTH*i] = aib_mac_if_s0.dout_ch[i];
     `else
         assign aib_no_ddelay_out_s[`SLLPHY_WIDTH*(i+1)-1:`SLLPHY_WIDTH*i] = (aib_mac_if_s0.rx_reg_mode == 1) ?
         aib_mac_if_s0.data_out_reg_mode[80*(i+1)-1:80*i]: aib_mac_if_s0.data_out[320*(i+1)-1:320*i];

         assign aib_ddelay_in_s[`SLLPHY_WIDTH*(i+1)-1:`SLLPHY_WIDTH*i] = (aib_mac_if_s0.rx_reg_mode == 1) ?
         aib_mac_if_s0.data_out_reg_mode[80*(i+1)-1:80*i]: aib_mac_if_s0.data_out[320*(i+1)-1:320*i];
     `endif

        delay_clk_unit #(`MLLPHY_WIDTH) aib_ddely_m (.clk(aib_mac_if_m0.rd_clk[i]), .clk_delay(aib_delay_mem[2*i]),
                        .ax(aib_ddelay_in_m[`MLLPHY_WIDTH*(i+1)-1: `MLLPHY_WIDTH*i]), .ax_o(aib_ddelay_out_m[`MLLPHY_WIDTH*(i+1)-1:`MLLPHY_WIDTH*i]));
        delay_clk_unit #(`SLLPHY_WIDTH) aib_ddely_s (.clk(aib_mac_if_s0.rd_clk[i]), .clk_delay(aib_delay_mem[2*i+1]),
                        .ax(aib_ddelay_in_s[`SLLPHY_WIDTH*(i+1)-1: `SLLPHY_WIDTH*i]), .ax_o(aib_ddelay_out_s[`SLLPHY_WIDTH*(i+1)-1:`SLLPHY_WIDTH*i]));

     `ifdef AIB_DATA_DELAY // Enable AIB to CA delay unit
        assign ca_m_if.rx_din[`MLLPHY_WIDTH*(i+1)-1:`MLLPHY_WIDTH*i] = aib_ddelay_out_m[`MLLPHY_WIDTH*(i+1)-1:`MLLPHY_WIDTH*i];
        assign ca_s_if.rx_din[`SLLPHY_WIDTH*(i+1)-1:`SLLPHY_WIDTH*i] = aib_ddelay_out_s[`SLLPHY_WIDTH*(i+1)-1:`SLLPHY_WIDTH*i];
     `else
        assign ca_m_if.rx_din[`MLLPHY_WIDTH*(i+1)-1:`MLLPHY_WIDTH*i] = aib_no_ddelay_out_m[`MLLPHY_WIDTH*(i+1)-1:`MLLPHY_WIDTH*i];
        assign ca_s_if.rx_din[`SLLPHY_WIDTH*(i+1)-1:`SLLPHY_WIDTH*i] = aib_no_ddelay_out_s[`SLLPHY_WIDTH*(i+1)-1:`SLLPHY_WIDTH*i];
     `endif


        delay_clk_unit #(.delay_bits(1)) ca_ms_tx_transfer_delay_unit (.clk(aib_mac_if_m0.rd_clk[i]), .clk_delay(aib_delay_mem[2*i]),
                .ax(aib_mac_if_m0.ms_tx_transfer_en[i]), .ax_o(ms_tx_transfer_en_d[i]));
        delay_clk_unit #(.delay_bits(1)) ca_ms_rx_transfer_delay_unit (.clk(aib_mac_if_m0.rd_clk[i]), .clk_delay(aib_delay_mem[2*i]),
                .ax(aib_mac_if_m0.ms_rx_transfer_en[i]), .ax_o(ms_rx_transfer_en_d[i]));
        delay_clk_unit #(.delay_bits(1)) ca_sl_tx_transfer_delay_unit (.clk(aib_mac_if_s0.rd_clk[i]), .clk_delay(aib_delay_mem[2*i+1]),
                .ax(aib_mac_if_s0.sl_tx_transfer_en[i]), .ax_o(sl_tx_transfer_en_d[i]));
        delay_clk_unit #(.delay_bits(1)) ca_sl_rx_transfer_delay_unit (.clk(aib_mac_if_s0.rd_clk[i]), .clk_delay(aib_delay_mem[2*i+1]),
                .ax(aib_mac_if_s0.sl_rx_transfer_en[i]), .ax_o(sl_rx_transfer_en_d[i]));


        delay_clk_unit #(.delay_bits(1)) ca_ms_mac_rdy_delay_unit (.clk(aib_mac_if_m0.rd_clk[i]), .clk_delay(aib_delay_mem[2*i]),
                .ax(aib_mac_if_m0.fs_mac_rdy[i]), .ax_o(fs_mac_rdy_d[i]));
        delay_clk_unit #(.delay_bits(1)) ca_ms_rx_align_done_delay_unit (.clk(aib_mac_if_m0.rd_clk[i]), .clk_delay(aib_delay_mem[2*i]),
                .ax(aib_mac_if_m0.m_rx_align_done[i]), .ax_o(m_rx_align_done_d[i]));
        delay_clk_unit #(.delay_bits(1)) ca_sl_rx_align_done_delay_unit (.clk(aib_mac_if_s0.rd_clk[i]), .clk_delay(aib_delay_mem[2*i+1]),
                .ax(aib_mac_if_s0.m_rx_align_done[i]), .ax_o(s_rx_align_done_d[i]));
      end //for
    endgenerate

//////////////////////////////////////////N////////////////////////////////////////////////

//// ///////////////////////////////////////////N-1////////////////////////////////////////////////
////      genvar i;
////     generate
////        for (i=0; i<`CA_NUM_CHAN; i++) begin
////            assign aib_mac_if_m0.din_ch[i][`TB_DIE_A_BUS_BIT_WIDTH-1:0] = ca_m_if.tx_dout[`TB_DIE_A_BUS_BIT_WIDTH*(i+1)-1:`TB_DIE_A_BUS_BIT_WIDTH*i];
////            assign aib_mac_if_s0.din_ch[i][`TB_DIE_B_BUS_BIT_WIDTH-1:0] = ca_s_if.tx_dout[`TB_DIE_B_BUS_BIT_WIDTH*(i+1)-1:`TB_DIE_B_BUS_BIT_WIDTH*i];
////         //  delay_unit #(.delay_bits(`MLLPHY_WIDTH)) ca_mdelay_unit (aib_mac_if_m0.dout_ch[i], ca_m_if.rx_din[`MLLPHY_WIDTH*(i+1)-1:`MLLPHY_WIDTH*i]);
////         //  delay_unit #(.delay_bits(`SLLPHY_WIDTH)) ca_sdelay_unit (aib_mac_if_s0.dout_ch[i], ca_s_if.rx_din[`SLLPHY_WIDTH*(i+1)-1:`SLLPHY_WIDTH*i]);
//// 
////      `ifdef MS_AIB_GEN1 // Gen1 40 bits
////  assign ca_m_if.rx_din[`TB_DIE_A_BUS_BIT_WIDTH*(i+1)-1:`TB_DIE_A_BUS_BIT_WIDTH*i] = aib_mac_if_m0.dout_ch[i];
////      `else   // AIB2.0 model always 320 bit
////  assign ca_m_if.rx_din[`TB_DIE_A_BUS_BIT_WIDTH*(i+1)-1:`TB_DIE_A_BUS_BIT_WIDTH*i] = (aib_mac_if_m0.rx_reg_mode == 1) ? aib_mac_if_m0.data_out_reg_mode[80*(i+1)-1:80*i] : aib_mac_if_m0.data_out[320*(i+1)-1:320*i];
////       `endif
//// 
////      `ifdef SL_AIB_GEN1 // Gen1 80 bits
////  assign ca_s_if.rx_din[`TB_DIE_B_BUS_BIT_WIDTH*(i+1)-1:`TB_DIE_B_BUS_BIT_WIDTH*i] = aib_mac_if_s0.dout_ch[i];
////      `else
////  assign ca_s_if.rx_din[`TB_DIE_B_BUS_BIT_WIDTH*(i+1)-1:`TB_DIE_B_BUS_BIT_WIDTH*i] = (aib_mac_if_s0.rx_reg_mode == 1) ? aib_mac_if_s0.data_out_reg_mode[80*(i+1)-1:80*i]: aib_mac_if_s0.data_out[320*(i+1)-1:320*i];
////      `endif
//// 
////         delay_unit #(.delay_bits(`CA_NUM_CHAN-1)) ca_ms_tx_transfer_delay_unit (aib_mac_if_m0.ms_tx_transfer_en, ms_tx_transfer_en_d);
////         delay_unit #(.delay_bits(`CA_NUM_CHAN-1)) ca_ms_rx_transfer_delay_unit (aib_mac_if_m0.ms_rx_transfer_en, ms_rx_transfer_en_d);
////         delay_unit #(.delay_bits(`CA_NUM_CHAN-1)) ca_sl_tx_transfer_delay_unit (aib_mac_if_s0.sl_tx_transfer_en, sl_tx_transfer_en_d);
////         delay_unit #(.delay_bits(`CA_NUM_CHAN-1)) ca_sl_rx_transfer_delay_unit (aib_mac_if_s0.sl_rx_transfer_en, sl_rx_transfer_en_d);
////        end
////     endgenerate
//// ///////////////////////////////////////////N-1////////////////////////////////////////////////
`else   ///// not CA_YELLOW_OVAL

    genvar dout_a;
    for(dout_a = 0; dout_a < `MAX_NUM_CHANNELS; dout_a++) begin : dout_a_inst 
      assign die_a_dout_delay[(`TB_DIE_A_BUS_BIT_WIDTH+(`TB_DIE_A_BUS_BIT_WIDTH*dout_a))-1:`TB_DIE_A_BUS_BIT_WIDTH*dout_a]   = chan_delay_die_a_inst[dout_a].chan_delay_die_a_if.dout[(`TB_DIE_A_BUS_BIT_WIDTH-1):0];
    end

    genvar dout_b;
    for(dout_b = 0; dout_b < `MAX_NUM_CHANNELS; dout_b++) begin : dout_b_inst 
       assign die_b_dout_delay[(`TB_DIE_B_BUS_BIT_WIDTH+(`TB_DIE_B_BUS_BIT_WIDTH*dout_b))-1:`TB_DIE_B_BUS_BIT_WIDTH*dout_b]  = chan_delay_die_b_inst[dout_b].chan_delay_die_b_if.dout[(`TB_DIE_B_BUS_BIT_WIDTH-1):0];
    end

    genvar j;
    for(j = 0; j < `MAX_NUM_CHANNELS; j++) begin : chan_delay_die_b_inst
        chan_delay_if #(.BUS_BIT_WIDTH (`TB_DIE_B_BUS_BIT_WIDTH)) chan_delay_die_b_if (.clk(clk_die_b), .rst_n(tb_reset_l));
        `ifdef P2P_LITE
            assign chan_delay_die_b_if.din = p2p_inst[j].p2p_i.s2m_data_out[(`TB_DIE_B_BUS_BIT_WIDTH-1):0];
        `endif 
        initial uvm_config_db #(virtual chan_delay_if #(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH)))::set(uvm_root::get(), $sformatf("*.chan_delay_die_b_agent_%0d.*",j), "chan_delay_vif", chan_delay_die_b_if);
    end // genvar j

    genvar k;
    for(k = 0; k < `MAX_NUM_CHANNELS; k++) begin : chan_delay_die_a_inst
        chan_delay_if #(.BUS_BIT_WIDTH (`TB_DIE_A_BUS_BIT_WIDTH)) chan_delay_die_a_if (.clk(clk_die_a), .rst_n(tb_reset_l));
        `ifdef P2P_LITE
            assign chan_delay_die_a_if.din = p2p_inst[k].p2p_i.m2s_data_out[(`TB_DIE_A_BUS_BIT_WIDTH-1):0];
        `endif
        initial uvm_config_db #(virtual chan_delay_if #(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH)))::set(uvm_root::get(), $sformatf("*.chan_delay_die_a_agent_%0d.*",k), "chan_delay_vif", chan_delay_die_a_if);
    end // genvar k
`endif //CA_YELLOW_OVAL

//////////////////////////////////////////////////////////////////////////////////////////
endmodule: ca_top_tb
///////////////////////////////////////////////////////
`endif
