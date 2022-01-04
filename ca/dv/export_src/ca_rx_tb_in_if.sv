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

`ifndef _CA_RX_TB_IN_IF_
`define _CA_RX_TB_IN_IF_
/////////////////////////////////////////////////////////

`include "uvm_macros.svh"

interface ca_rx_tb_in_if #(int BUS_BIT_WIDTH=80, int NUM_CHANNELS=2) (input clk, rst_n);

    // signal declaration...
    //---------------------------------------------------
    logic  [((NUM_CHANNELS*BUS_BIT_WIDTH)-1):0]   rx_dout;
    logic  [((NUM_CHANNELS*BUS_BIT_WIDTH)-1):0]   rx_din;
    logic                                         align_done;
    logic  [24-1:0]                               ld_rx_align_done;
    logic  [24-1:0]                               fl_rx_align_done;
    logic                                         align_err;
    logic                                         rx_online;
    logic                                         align_fly;
    logic [2:0]                                   rden_dly;
    logic [15:0]                                  delay_x_value ;
    logic [15:0]                                  delay_xz_value ;
    logic                                         tx_stb_rcvr;
    logic                                         rx_stb_pos_err;
    logic                                         rx_stb_pos_coding_err;
    logic [7:0]                                   rx_stb_wd_sel;
    logic [39:0]                                  rx_stb_bit_sel;
    logic [15:0]                                  rx_stb_intv;
    logic [5:0]                                   fifo_full_val;
    logic [5:0]                                   fifo_pfull_val;
    logic [2:0]                                   fifo_empty_val;
    logic [2:0]                                   fifo_pempty_val;
    logic [NUM_CHANNELS-1:0]                      fifo_full;
    logic [NUM_CHANNELS-1:0]                      fifo_pfull;
    logic [NUM_CHANNELS-1:0]                      fifo_empty;
    logic [NUM_CHANNELS-1:0]                      fifo_pempty;
    logic [24-1:0]                                ld_ms_rx_transfer_en;
    logic [24-1:0]                                ld_sl_rx_transfer_en;
    logic [24-1:0]                                fl_ms_rx_transfer_en;
    logic [24-1:0]                                fl_sl_rx_transfer_en;
    logic[3:0]                                    user_marker;
    logic                                         user_stb;
    logic [7:0]                                   strobe_gen_m_interval;
    logic [7:0]                                   strobe_gen_s_interval;

    // modports...
    //---------------------------------------------------
    modport mon (
        input     clk,
        input     rst_n,
        //
        input     rx_dout,
        input     rx_din,
        input     align_done,
        input     ld_rx_align_done,
        input     fl_rx_align_done,
        input     align_err,
        input     rx_online,
        input     align_fly,
        input     rden_dly,
        input     rx_stb_pos_err,
        input     rx_stb_pos_coding_err,
        input     rx_stb_wd_sel,
        input     rx_stb_bit_sel,
        input     rx_stb_intv,
        input     fifo_full_val,
        input     fifo_pfull_val,
        input     fifo_empty_val,
        input     fifo_pempty_val,
        input     fifo_full,
        input     fifo_pfull,
        input     fifo_empty,
        input     fifo_pempty
    );
    //---------------------------------------------------
    modport drv (
        input     clk,
        input     rst_n,
        //
        input     rx_dout,
        input     rx_din,
        input     align_done,
        input     ld_rx_align_done,
        input     fl_rx_align_done,
        input     align_err,
        output    rx_online,
        output    align_fly,
        output    rden_dly,
        output    tx_stb_rcvr,
        input     rx_stb_pos_err,
        input     rx_stb_pos_coding_err,
        output    rx_stb_wd_sel,
        output    rx_stb_bit_sel,
        output    rx_stb_intv,
        output    fifo_full_val,
        output    fifo_pfull_val,
        output    fifo_empty_val,
        output    fifo_pempty_val,
        input     fifo_full,
        input     fifo_pfull,
        input     fifo_empty,
        input     fifo_pempty
    );

endinterface : ca_rx_tb_in_if
/////////////////////////////////////////////////////////
`endif
