`ifndef _COMMON_LL_TX_CRED_SV
`define _COMMON_LL_TX_CRED_SV
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
// Transmit credit handling block.
//
////////////////////////////////////////////////////////////

module ll_tx_cred (

  input                         clk_wr         ,
  input                         rst_wr_n       ,

  // FIFO IF
  output logic                  txfifo_i_pop   ,
  input  logic                  txfifo_i_empty ,

  // Push bit
  output logic                  tx_i_pushbit   ,
  input  logic                  end_of_txcred_coal   , // While this is low, we coalesce TX credits. If tied to 1, every cycle is its own credit

  // Initial Credits
  input logic                   tx_online      ,
  input logic [7:0]             init_i_credit  ,

  // Receive Credits
  input logic [3:0]             rx_i_credit    ,

  // Packetizing holdoff of pop
  input logic                   tx_i_pop_ovrd  ,

  // Debug
  output logic [7:0]            dbg_curr_i_credit

);

parameter ASYMMETRIC_CREDIT     = 1'h1;
parameter TX_CRED_SIZE          = 3'h1;
parameter DEFAULT_TX_CRED       = 8'd01;

logic [7:0]                     tx_credit_reg;
logic                           will_have_credit_reg;
logic                           txonline_dly;
logic                           txonline_dly2;
logic                           txfifo_i_has_data;
logic                           tx_coal_tx_credit_reg;
logic                           tx_credit_inc_nonasym;
logic                           tx_credit_dec;
logic [2:0]                     rx_credit_enc_asym;
logic [7:0]                     tx_credit_nxt;
logic [7:0]                     tx_credit_nxt_nonasym;
logic [7:0]                     tx_credit_nxt_asym;
logic [7:0]                     tx_credit_min1_reg;
logic [7:0]                     tx_credit_pls1_reg;

////////////////////////////////////////////////////////////
// Pop generation
// If pop override is low and we have data, then we just sent that data on line.
// and we should generate a pop

assign txfifo_i_has_data    = ~txfifo_i_empty;

assign tx_i_pushbit          = txfifo_i_has_data & will_have_credit_reg;
assign txfifo_i_pop          = tx_i_pushbit & !tx_i_pop_ovrd;

// Pop generation
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Register credit return for timing reasons

always @(posedge clk_wr or negedge rst_wr_n)
if (!rst_wr_n)
begin
  rx_credit_enc_asym    <= 3'b0;
  tx_credit_inc_nonasym <= 1'b0;
end
else
begin
  rx_credit_enc_asym    <= ({2'b0,rx_i_credit[3]} + {2'b0,rx_i_credit[2]} + {2'b0,rx_i_credit[1]} + {2'b0,rx_i_credit[0]}) ;
  tx_credit_inc_nonasym <= rx_i_credit[0];
end

// Register credit return for timing reasons
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// We delay txonline and look for a rising edge.
// The rising edge latches the initial transmit credit.
always @(posedge clk_wr or negedge rst_wr_n)
if (!rst_wr_n)
begin
  txonline_dly  <= 1'b0;
  txonline_dly2 <= 1'b0;
end
else
begin
  txonline_dly  <= tx_online;
  txonline_dly2 <= txonline_dly;
end

// We delay txonline and look for a rising edge.
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Asymmetric credit support

// In asymmetric mode, we'll set end_of_txcred_coal high
// on the upper bit (marker). As a result, we'll use one
// credit per remote word.
always @(posedge clk_wr or negedge rst_wr_n)
if (!rst_wr_n)
  tx_coal_tx_credit_reg <= 1'b0;
else if (end_of_txcred_coal)
  tx_coal_tx_credit_reg <= 1'b0;
else if (txfifo_i_pop)
  tx_coal_tx_credit_reg <= 1'b1;

assign tx_credit_dec = ASYMMETRIC_CREDIT ? (end_of_txcred_coal & (txfifo_i_pop | tx_coal_tx_credit_reg)) : txfifo_i_pop;




logic [3:0] potential_asym_credit_usage_reg;
logic [2:0] actual_asym_credit_usage_reg;
logic [2:0] actual_credit_usage;
always @(posedge clk_wr or negedge rst_wr_n)
if (!rst_wr_n)
  potential_asym_credit_usage_reg <= TX_CRED_SIZE;
else if (end_of_txcred_coal)
  potential_asym_credit_usage_reg <= TX_CRED_SIZE;
else
  potential_asym_credit_usage_reg <= potential_asym_credit_usage_reg + TX_CRED_SIZE; // spyglass disable W484

always @(posedge clk_wr or negedge rst_wr_n)
if (!rst_wr_n)
  actual_asym_credit_usage_reg <= 3'b0;
else if (end_of_txcred_coal)
  actual_asym_credit_usage_reg <= potential_asym_credit_usage_reg[2:0];

assign actual_credit_usage = (ASYMMETRIC_CREDIT ? actual_asym_credit_usage_reg : TX_CRED_SIZE);

assign tx_credit_nxt_asym    = tx_credit_reg - (tx_credit_dec ? actual_credit_usage : 3'h0) + rx_credit_enc_asym; // spyglass disable W484
// Asymmetric credit support
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Symmetric credit support

// This is equal to the credit minus 1. Used for timing closure in symmetric mode.
always @(posedge clk_wr or negedge rst_wr_n)
if (!rst_wr_n)
  tx_credit_min1_reg <= 8'b0;
else
  tx_credit_min1_reg <= tx_credit_nxt - 8'h01;

// This is equal to the credit plus 1. Used for timing closure in symmetric mode.
always @(posedge clk_wr or negedge rst_wr_n)
if (!rst_wr_n)
  tx_credit_pls1_reg <= 8'b0;
else
  tx_credit_pls1_reg <= tx_credit_nxt + 8'h01;

//assign tx_credit_nxt_nonasym = tx_credit_reg - (tx_credit_dec ? 8'h1 : 8'h0) + (tx_credit_inc_nonasym ? 8'h1 : 8'h0); // spyglass disable W484
assign tx_credit_nxt_nonasym = (tx_credit_inc_nonasym & tx_credit_dec) ? tx_credit_reg      :
                               (tx_credit_inc_nonasym                ) ? tx_credit_pls1_reg :
                               (                        tx_credit_dec) ? tx_credit_min1_reg : tx_credit_reg ;

// Symmetric credit support
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Credit Counter

always @(posedge clk_wr or negedge rst_wr_n)
if (!rst_wr_n)
  tx_credit_reg <= 8'b0;
else if (tx_online == 1'b0)
  tx_credit_reg <= 8'b0;
else if (tx_online & !txonline_dly)
  tx_credit_reg <= (init_i_credit == 8'h0) ? DEFAULT_TX_CRED : init_i_credit;
else
  tx_credit_reg <= tx_credit_nxt;

assign tx_credit_nxt         = ASYMMETRIC_CREDIT ? tx_credit_nxt_asym : tx_credit_nxt_nonasym ;

// Credit Counter
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Calculate if we will have credit for timing closure

always @(posedge clk_wr or negedge rst_wr_n)
if (!rst_wr_n)
  will_have_credit_reg <= 1'b0;
else if (tx_online == 1'b0)
  will_have_credit_reg <= 1'b0;
else if (ASYMMETRIC_CREDIT == 1'b1)
  will_have_credit_reg <= (tx_credit_nxt >= {5'h0,actual_credit_usage});
else if (ASYMMETRIC_CREDIT == 1'b0)
  will_have_credit_reg <= (|tx_credit_reg[7:1]) | tx_credit_inc_nonasym | (!tx_credit_dec & tx_credit_reg[0]); // If we have 2 or more credits or we have a credit inc or if we don't have dec and at least 1 credit.

// Calculate if we will have credit for timing closure
////////////////////////////////////////////////////////////

assign dbg_curr_i_credit = tx_credit_reg;

endmodule // tx_cred //
`endif
