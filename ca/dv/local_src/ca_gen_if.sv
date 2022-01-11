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

`ifndef _CA_GEN_IF_
`define _CA_GEN_IF_
/////////////////////////////////////////////////////////

`include "uvm_macros.svh"

interface ca_gen_if (input clk, rst_n);
   
    // signal declaration...
    //---------------------------------------------------
    logic                                         aib_ready;
    logic                                         force0_tx_rx_online=1'b0;
    logic                                         die_a_align_error;
    logic                                         die_a_align_done;
    logic                                         die_b_align_error;
    logic                                         die_b_align_done;
    logic                                         die_a_rx_stb_pos_err;
    logic                                         die_b_rx_stb_pos_err;
    logic                                         die_a_rx_stb_pos_coding_err;
    logic                                         die_b_rx_stb_pos_coding_err;
    logic [`TB_DIE_A_NUM_CHANNELS-1:0]                      die_a_fifo_full;
    logic [`TB_DIE_A_NUM_CHANNELS-1:0]                      die_a_fifo_pfull;
    logic [`TB_DIE_A_NUM_CHANNELS-1:0]                      die_a_fifo_empty;
    logic [`TB_DIE_A_NUM_CHANNELS-1:0]                      die_a_fifo_pempty;
    logic [`TB_DIE_A_NUM_CHANNELS-1:0]                      die_b_fifo_full;
    logic [`TB_DIE_A_NUM_CHANNELS-1:0]                      die_b_fifo_pfull;
    logic [`TB_DIE_A_NUM_CHANNELS-1:0]                      die_b_fifo_empty;
    logic [`TB_DIE_A_NUM_CHANNELS-1:0]                      die_b_fifo_pempty;

    // modports... 
    //---------------------------------------------------
    modport mon (  
        input     clk,
        input     rst_n,
        input     aib_ready
    );

endinterface : ca_gen_if
/////////////////////////////////////////////////////////
`endif
