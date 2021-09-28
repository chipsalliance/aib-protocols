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

`ifndef _CHAN_DELAY_IF_
`define _CHAN_DELAY_IF_
/////////////////////////////////////////////////////////

`include "uvm_macros.svh"

interface chan_delay_if #(int BUS_BIT_WIDTH=80) (input  clk, rst_n);
   
    // signal declaration...
    //---------------------------------------------------
    logic  [BUS_BIT_WIDTH-1:0]   din;
    logic  [BUS_BIT_WIDTH-1:0]   dout;

    // modports... 
    //---------------------------------------------------
    modport mon (
        input     clk,
        input     rst_n,
        //
        input     dout,
        input     din
    ); 
    //---------------------------------------------------
    modport drv (
        input     clk,
        input     rst_n,
        //
        output    dout,
        input     din
    ); 
    
endinterface : chan_delay_if
/////////////////////////////////////////////////////////
`endif
