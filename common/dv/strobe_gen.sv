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
////////////////////////////////////////////////////////////
module strobe_gen (

  input logic        clk,
  input logic        rst_n,

  input logic [15:0] interval,          // Set to 0 for back to back strobes. Otherwise, interval is the time between strobes (so if you want a strobe every 10 cycles, set to 9)
  input logic        user_marker,       // Effectiely the OR reduction of all user_marker bits. We only increment strobe count when we send a remote side word
  input logic        online,            // Set to 1 to begin strobe generation (0 to stop)

  output logic       user_strobe

);

logic        marker_dly_reg;
logic [15:0] count_reg;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  marker_dly_reg <= 1'h0;
else
  marker_dly_reg <= user_marker;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  count_reg <= 16'h0;
else if (~online)
  count_reg <= 16'h0;
else if ((marker_dly_reg) & (count_reg[15:1] == 15'h0)) // If we get a marker and we are empty or at 1.
  count_reg <= interval;
else if (|count_reg)
  count_reg <= count_reg - 16'h1;

assign user_strobe = (count_reg == 16'h1) & online;


endmodule
