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

`include "ca_config_define.svi"   //// auto generated from sailrock_cfg.txt
///////////////////////////////////////////////////////////
`define AIB_CH_CNT              `CA_NUM_CHAN

// COMMON
`define MIN_BUS_BIT_WIDTH       40
`define MAX_BUS_BIT_WIDTH       320 
`define MAX_NUM_CHANNELS        24
`define SYNC_FIFO               1 
`define AIB_PROG_FIFO_MODE      1  

// DIE A
`define TB_DIE_A_AIB            2 //unused in testbench 
`define TB_DIE_A_NUM_CHANNELS   `CA_NUM_CHAN  
`define TB_DIE_A_AD_WIDTH       $clog2(`CA_FIFO_DEPTH)

// DIE B
`define TB_DIE_B_AIB            2 //unused in testbench 
`define TB_DIE_B_NUM_CHANNELS   `CA_NUM_CHAN
`define TB_DIE_B_AD_WIDTH       $clog2(`CA_FIFO_DEPTH)

///////////////////////////////////////////////////////////
`define ALIGN_FLY                 `CA_ALIGN_FLY
`ifdef GEN1
    `define MODE_GEN2                 1'b0
`else
    `define MODE_GEN2                 1'b1
`endif
`define CHAN_DELAY_MIN            1
`define CHAN_DELAY_MAX            5
parameter osc_period  = 1000;

///////////////////////////////////////////////////////////
`ifdef GEN1
  `ifdef TX_RATE_F
          `define MLLPHY_WIDTH            40
          `define TB_DIE_A_BUS_BIT_WIDTH  40 
          `define TB_DIE_A_CLK            1000 
          `define MASTER_RATE             FULL 
  `endif
  `ifdef RX_RATE_F
          `define SLLPHY_WIDTH            40
          `define TB_DIE_B_BUS_BIT_WIDTH  40 
          `define TB_DIE_B_CLK            1000 
          `define SLAVE_RATE              FULL 
  `endif
  `ifdef TX_RATE_H
          `define MLLPHY_WIDTH            80
          `define TB_DIE_A_BUS_BIT_WIDTH  80 
          `define TB_DIE_A_CLK            2000 
          `define MASTER_RATE             HALF 
  `endif
  `ifdef RX_RATE_H
          `define SLLPHY_WIDTH            80
          `define TB_DIE_B_BUS_BIT_WIDTH  80 
          `define TB_DIE_B_CLK            2000
          `define SLAVE_RATE              HALF 
  `endif
`endif //GEN1

`ifdef GEN2
  `ifdef TX_RATE_F
          `define MLLPHY_WIDTH            80
          `define TB_DIE_A_BUS_BIT_WIDTH  80 
          `define TB_DIE_A_CLK            500 
          `define MASTER_RATE             FULL 
  `endif
  `ifdef RX_RATE_F
          `define SLLPHY_WIDTH            80
          `define TB_DIE_B_BUS_BIT_WIDTH  80 
          `define TB_DIE_B_CLK            500
          `define SLAVE_RATE              FULL 
  `endif
  `ifdef TX_RATE_H
          `define MLLPHY_WIDTH            160
          `define TB_DIE_A_BUS_BIT_WIDTH  160 
          `define TB_DIE_A_CLK            1000 
          `define MASTER_RATE             HALF 
  `endif
  `ifdef RX_RATE_H
          `define SLLPHY_WIDTH            160
          `define TB_DIE_B_BUS_BIT_WIDTH  160
          `define TB_DIE_B_CLK            1000
          `define SLAVE_RATE              HALF 
  `endif
  `ifdef TX_RATE_Q
          `define MLLPHY_WIDTH            320
          `define TB_DIE_A_BUS_BIT_WIDTH  320 
          `define TB_DIE_A_CLK            2000 
          `define MASTER_RATE             QUARTER 
  `endif
  `ifdef RX_RATE_Q
          `define SLLPHY_WIDTH            320
          `define TB_DIE_B_BUS_BIT_WIDTH  320
          `define TB_DIE_B_CLK            2000 
          `define SLAVE_RATE              QUARTER 
  `endif
`endif //GEN2
`endif //_ca_GENERATED_defines_
