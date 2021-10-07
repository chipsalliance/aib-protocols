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
//Functional Descript:
//
//
//
////////////////////////////////////////////////////////////


module pulse_sync (
input logic  src_pulse,
input logic  clk_src,
input logic  rst_src_n,
input logic clk_dest,
input logic rst_dest_n,
output logic dest_pulse 
);

logic src_pulse_int;
logic src_lvl_int;
logic dest_lvl; 
logic dest_lvl_int; 

assign src_pulse_int = src_pulse ^ src_lvl_int;

always @(posedge clk_src or negedge rst_src_n)
       if (~rst_src_n)
          src_lvl_int <= 1'b0;
       else
          src_lvl_int <= src_pulse_int;


levelsync sync_pulse (
   	.dest_data (dest_lvl_int),
   	.clk_dest (clk_dest), 
   	.rst_dest_n (rst_dest_n), 
   	.src_data (src_lvl_int)
   );

always @(posedge clk_dest or negedge rst_dest_n)
       if (~rst_dest_n)
          dest_lvl <= 1'b0;
       else
          dest_lvl <= dest_lvl_int;

assign dest_pulse = dest_lvl_int ^ dest_lvl;

endmodule
