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

`ifndef _CA_TX_TB_IN_IF_
`define _CA_TX_TB_IN_IF_
/////////////////////////////////////////////////////////

`include "uvm_macros.svh"

interface ca_tx_tb_in_if #(int BUS_BIT_WIDTH=80, int NUM_CHANNELS=2) (input clk, rst_n);
   
    // signal declaration...
    //---------------------------------------------------
    logic                                         align_done;
    logic                                         tx_online;
    logic  [((NUM_CHANNELS*BUS_BIT_WIDTH)-1):0]   tx_dout;
    logic                                         tx_stb_pos_err;
    logic                                         tx_stb_pos_coding_err;
    logic[3:0]                                    user_marker;
    logic                                         user_stb;
    logic [15:0]                                   strobe_gen_m_interval;
    logic [15:0]                                   strobe_gen_s_interval;

    // modports... 
    //---------------------------------------------------
    modport mon (
        input     clk,
        input     rst_n,
        //
        input     align_done,
        input     tx_online,
        input     tx_dout,
        input     tx_stb_pos_err,
        input     tx_stb_pos_coding_err
    ); 
    
endinterface : ca_tx_tb_in_if
/////////////////////////////////////////////////////////
`endif
