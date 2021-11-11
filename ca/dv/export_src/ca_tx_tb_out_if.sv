////////////////////////////////////////////////////////////////////////////////////////////////////
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
// Functional Descript: Channel Alignment Testbench File
//
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_TX_TB_OUT_IF_
`define _CA_TX_TB_OUT_IF_
/////////////////////////////////////////////////////////

`include "uvm_macros.svh"

interface ca_tx_tb_out_if #(int BUS_BIT_WIDTH=80, int NUM_CHANNELS=2) (input clk, rst_n);
   
    // signal declaration...
    //---------------------------------------------------
    logic[3:0]                                    user_marker;
    logic                                         user_stb;
    logic  [((NUM_CHANNELS*BUS_BIT_WIDTH)-1):0]   tx_din;
    logic                                         com_clk;
    logic                                         tx_online;
    logic                                         tx_stb_en;
    logic                                         tx_stb_rcvr;
    logic  [7:0]                                  tx_stb_wd_sel;
    logic  [39:0]                                 tx_stb_bit_sel;
    logic  [7:0]                                  tx_stb_intv;
    logic  [24-1:0]                               ld_ms_rx_transfer_en;
    logic  [24-1:0]                               ld_sl_rx_transfer_en;
    logic  [24-1:0]                               fl_ms_rx_transfer_en;
    logic  [24-1:0]                               fl_sl_rx_transfer_en;
    logic                                         align_done;

    // modports... 
    //---------------------------------------------------
    modport drv (  
        input     clk,
        input     rst_n,
        //
        output    tx_din,
        output    com_clk,
        output    tx_online,
        output    tx_stb_en,
        output    tx_stb_wd_sel,
        output    tx_stb_bit_sel,
        output    tx_stb_intv,
        input     ld_ms_rx_transfer_en,
        input     ld_sl_rx_transfer_en,
        input     fl_ms_rx_transfer_en,
        input     fl_sl_rx_transfer_en,
        input     align_done
    );

    modport mon (
        input     clk,
        input     rst_n,
        //
        input     tx_din,
        input     com_clk,
        input     tx_online,
        input     tx_stb_en,
        input     tx_stb_rcvr,
        input     tx_stb_wd_sel,
        input     tx_stb_bit_sel,
        input     tx_stb_intv,
        input     ld_ms_rx_transfer_en,
        input     ld_sl_rx_transfer_en,
        input     fl_ms_rx_transfer_en,
        input     fl_sl_rx_transfer_en,
        input     align_done
    ); 
    
endinterface : ca_tx_tb_out_if
/////////////////////////////////////////////////////////
`endif
