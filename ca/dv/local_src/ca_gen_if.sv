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

`ifndef _CA_GEN_IF_
`define _CA_GEN_IF_
/////////////////////////////////////////////////////////

`include "uvm_macros.svh"

interface ca_gen_if (input clk, rst_n);
   
    // signal declaration...
    //---------------------------------------------------
    logic                                         aib_ready;

    // modports... 
    //---------------------------------------------------
    modport mon (  
        input     clk,
        input     rst_n,
        input     aib_ready
    );

endinterface : ca_gen_if
/////////////////////////////////////////////////////////
`endif
