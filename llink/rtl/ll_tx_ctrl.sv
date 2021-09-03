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
// Transmit control block.
//
////////////////////////////////////////////////////////////

module ll_tx_ctrl (

  output logic txfifo_i_push,
  input  logic txfifo_i_full,
  input  logic txfifo_i_pop ,
  input  logic tx_will_have_credit , // Unused signal, but may be useful for timing closure, so left in place.

  input  logic user_i_valid,
  output logic user_i_ready,

  input logic tx_online

);

logic txfifo_i_has_space;

// Guranteed to have credit if we are popping an entry.
assign txfifo_i_has_space    = (~txfifo_i_full) | txfifo_i_pop;
assign user_i_ready          = txfifo_i_has_space & tx_online;
assign txfifo_i_push         = user_i_valid & user_i_ready;

endmodule