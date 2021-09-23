////////////////////////////////////////////////////////////
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
////////////////////////////////////////////////////////////
module strobe_gen (

  input logic        clk,
  input logic        rst_n,

  input logic  [7:0] interval,          // Set to 0 for back to back strobes. Otherwise, interval is the time between strobes (so if you want a strobe every 10 cycles, set to 9)
  input logic        user_marker,       // Effectiely the OR reduction of all user_marker bits. We only increment strobe count when we send a remote side word

  output logic       user_strobe

);

parameter TX_STROBE_QUICKLY = 0; // If set, we'll send the strobe on cycle 0. Otherwise we wait one interval before sending strobe.

logic [7:0] count_reg;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  count_reg <= 8'h0;
else if ((user_marker) & (count_reg == interval))
  count_reg <= 8'h0;
else if (user_marker)
  count_reg <= count_reg + 1;

assign user_strobe = (count_reg == (TX_STROBE_QUICKLY ? 8'h0 : interval));


endmodule
