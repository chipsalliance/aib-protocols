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

`ifndef _ca_GENERATED_defines_
`define _ca_GENERATED_defines_
///////////////////////////////////////////////////////////
// *** AUTO GENERATED FILE do not alter && check in ***
///////////////////////////////////////////////////////////
// 
// COMMON
`define MIN_BUS_BIT_WIDTH       40
`define MAX_BUS_BIT_WIDTH       320 
`define MAX_NUM_CHANNELS        24
`define SYNC_FIFO               1 
`define AIB_PROG_FIFO_MODE      1  

// DIE A
`define TB_DIE_A_AIB            2
`define TB_DIE_A_NUM_CHANNELS   8
`define TB_DIE_A_AD_WIDTH       4

// DIE B
`define TB_DIE_B_AIB            2
`define TB_DIE_B_NUM_CHANNELS   8
`define TB_DIE_B_AD_WIDTH       4

//GEN1 mode, bits_per_ch 40,1GHZ 
`define TB_DIE_A_BUS_BIT_WIDTH  40 
`define TB_DIE_A_CLK            1000 
`define TB_DIE_B_BUS_BIT_WIDTH  40 
`define TB_DIE_B_CLK            1000 

//GEN1 mode, bits_per_ch 80,500MHZ 
//`define TB_DIE_A_BUS_BIT_WIDTH  80 
//`define TB_DIE_A_CLK            2000 
//`define TB_DIE_B_BUS_BIT_WIDTH  80 
//`define TB_DIE_B_CLK            2000
// 
////GEN2 mode, bits_per_ch 80,2GHZ 
//`define TB_DIE_A_BUS_BIT_WIDTH  80 
//`define TB_DIE_A_CLK            500 
//`define TB_DIE_B_BUS_BIT_WIDTH  80 
//`define TB_DIE_B_CLK            500
// 
////GEN2 mode, bits_per_ch 160,1GHZ 
//`define TB_DIE_A_BUS_BIT_WIDTH  160 
//`define TB_DIE_A_CLK            1000 
//`define TB_DIE_B_BUS_BIT_WIDTH  160
//`define TB_DIE_B_CLK            1000
 
////GEN2 mode, bits_per_ch 320,500MHZ 
//`define TB_DIE_A_BUS_BIT_WIDTH  320 
//`define TB_DIE_A_CLK            2000 
//`define TB_DIE_B_BUS_BIT_WIDTH  320
//`define TB_DIE_B_CLK            2000 
///////////////////////////////////////////////////////////
`define MODE_GEN2                 1'b0
`define CHAN_DELAY_MIN            1
`define CHAN_DELAY_MAX            15
`define ALIGN_FLY                 1'b0

`endif
