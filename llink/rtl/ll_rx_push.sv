`ifndef _COMMON_LL_RX_PUSH_SV
`define _COMMON_LL_RX_PUSH_SV
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
// Receive push logic.
//
////////////////////////////////////////////////////////////

module ll_rx_push (
    // Control Logic
    input  logic                                rx_online ,
    input  logic                                rx_i_push_ovrd ,

    // From Upstream
    input  logic                                rx_i_pushbit ,

    // To FIFO
    output logic                                rxfifo_i_push
  );


assign rxfifo_i_push = rx_i_pushbit & (!rx_i_push_ovrd) & rx_online;


endmodule
`endif

