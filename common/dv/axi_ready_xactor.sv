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
module axi_ready_xactor (

  input logic        clk,
  input logic        rst_n,

  input logic        disable_flowcontrol,       // Set to 1 to disable all flow control.
  input logic  [7:0] max_span,                  // Set to maximum clock span each "event" will last (100 is good starting point) Minimum is 1 clock cycle.
  input logic  [7:0] max_assert_flowcontrol,    // Set to percentage chance that each span will be asserting flow control.

  output logic       axi_ready

);

logic [7:0] rand_percent_ready_delay;

logic [7:0] rand_ready_delay_value;


always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  axi_ready <= 1'b1;
end
else
begin
  rand_ready_delay_value   = $urandom_range(1,{24'h0,max_span});
  rand_percent_ready_delay = $urandom_range(1,100);

  axi_ready <= disable_flowcontrol ? 1'b1 : (rand_percent_ready_delay >= max_assert_flowcontrol);

  repeat (rand_ready_delay_value) @(posedge clk);
end


endmodule
