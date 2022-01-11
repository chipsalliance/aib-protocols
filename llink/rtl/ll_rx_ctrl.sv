`ifndef _COMMON_LL_RX_CTRL_SV
`define _COMMON_LL_RX_CTRL_SV
////////////////////////////////////////////////////////////
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
//Functional Descript:
//
// Logic Link Receive Control block.
//
////////////////////////////////////////////////////////////


module ll_rx_ctrl #(parameter FIFO_COUNT_MSB=4) (
    // clk, reset
    input  logic                        clk_wr ,
    input  logic                        rst_wr_n ,

    // To Downstream
    output logic                        user_i_valid,
    input  logic                        user_i_ready,

    // To FIFO
    output logic                        rxfifo_i_pop,
    input  logic                        rxfifo_i_empty,
    input  logic [FIFO_COUNT_MSB:0]     dbg_rxfifo_i_numfilled,
    input  logic                        rxfifo_i_push,

    // To Upstream
    input  logic                        tx_online,
    output logic                        tx_i_credit
  );

// With a 1 cycle read latency RAM, there is a cornercase where
// RAM has 1 entry and then in same cycle, FIFO is pushed/popped.
// FIFO technically has 1 entry, and the next cycle will be a read of
// the written address. However, since there is no write through,
// the data was not be valid until the next cycle. So detected
// and account for thise cornercase in "empty" signaling.

logic rxfifo_corner_case_reg;

always_ff @(posedge clk_wr or negedge rst_wr_n)
if (~rst_wr_n)
  rxfifo_corner_case_reg <= 1'b0;
else
  rxfifo_corner_case_reg <= rxfifo_i_push & rxfifo_i_pop & (dbg_rxfifo_i_numfilled == 1);

logic rxfifo_i_has_data;
logic rxfifo_i_empty_dly_reg;

always_ff @(posedge clk_wr or negedge rst_wr_n)
if (~rst_wr_n)
  rxfifo_i_empty_dly_reg <= 1'b1;
else if (tx_online == 1'b0) // If we cannot respond with credits, lets hold the data until we can to not lose credits
  rxfifo_i_empty_dly_reg <= 1'b1;
else
  rxfifo_i_empty_dly_reg <= rxfifo_i_empty;


assign rxfifo_i_has_data     = ~rxfifo_i_empty_dly_reg & ~rxfifo_i_empty & ~rxfifo_corner_case_reg;
assign user_i_valid          = rxfifo_i_has_data; // Note, we could use RX_ONLINE, but nothing should be in FIFO unless RX_ONLINE=1

assign rxfifo_i_pop          = user_i_ready & user_i_valid;

// This may need to be a fill/spill counter, not a single credit... we'll see.
assign tx_i_credit          = rxfifo_i_pop;

endmodule
`endif

