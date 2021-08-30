////////////////////////////////////////////////////////////
// Proprietary Information of Eximius Design
//
//        (C) Copyright 2021 Eximius Design
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
  output                        tx_will_have_credit ,

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
logic                           txfifo_i_has_data;
logic                           tx_coal_tx_credit_reg;
logic                           tx_credit_dec;
logic [2:0]                     rx_credit_enc;
logic [7:0]                     tx_credit_nxt;

assign txfifo_i_has_data    = ~txfifo_i_empty;

assign tx_i_pushbit          = txfifo_i_has_data & will_have_credit_reg;
assign txfifo_i_pop          = tx_i_pushbit & !tx_i_pop_ovrd;

assign rx_credit_enc  = {2'b0,rx_i_credit[3]} + {2'b0,rx_i_credit[2]} + {2'b0,rx_i_credit[1]} + {2'b0,rx_i_credit[0]};

// We delay txonline and look for a rising edge.
// The rising edge latches the initial transmit credit.
always @(posedge clk_wr or negedge rst_wr_n)
if (!rst_wr_n)
  txonline_dly <= 1'b0;
else
  txonline_dly <= tx_online;

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

assign tx_credit_dec = end_of_txcred_coal & (txfifo_i_pop | tx_coal_tx_credit_reg);




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


// TODO, we don't check for TX Credit underflow... logic kinda prevents that,is is worth adding logic to checking?
always @(posedge clk_wr or negedge rst_wr_n)
if (!rst_wr_n)
  tx_credit_reg <= 8'b0;
else if (tx_online == 1'b0)
  tx_credit_reg <= 8'b0;
else if (tx_online & !txonline_dly)
  tx_credit_reg <= (init_i_credit == 8'h0) ? DEFAULT_TX_CRED : init_i_credit;
else
  tx_credit_reg <= tx_credit_nxt;

assign tx_credit_nxt = tx_credit_reg - (tx_credit_dec ? actual_credit_usage : 3'h0) + rx_credit_enc; // spyglass disable W484


//  if ((tx_credit_dec && rx_i_credit))
//   tx_credit_reg <= tx_credit_reg;
// else if ((tx_credit_dec               ) && ( (|tx_credit_reg)))
//   tx_credit_reg <= tx_credit_reg - 8'h1;
// else if ((                 rx_i_credit) && (~(&tx_credit_reg)))
//   tx_credit_reg <= tx_credit_reg + 8'h1;

always @(posedge clk_wr or negedge rst_wr_n)
if (!rst_wr_n)
  will_have_credit_reg <= 1'b0;
else if (tx_online == 1'b0)
  will_have_credit_reg <= 1'b0;
else
  will_have_credit_reg <= (tx_credit_nxt >= {5'h0,actual_credit_usage});

assign tx_will_have_credit = will_have_credit_reg;

assign dbg_curr_i_credit = tx_credit_reg;

endmodule // tx_cred //
