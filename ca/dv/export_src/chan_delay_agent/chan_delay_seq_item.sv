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

`ifndef _CHAN_DELAY_SEQ_ITEM_
`define _CHAN_DELAY_SEQ_ITEM_
////////////////////////////////////////////////////////////

`include "uvm_macros.svh"

class chan_delay_seq_item_c extends uvm_sequence_item ;
    
    //------------------------------------------
    // Data Members
    //------------------------------------------
    int              chan_num = -1;

    int              init_delay_clk = 0; // inital delay before sending 1st xfer
    int              chan_delay_clk = 0; // delay each xfer

    bit              burst_en  = 0;
    int              burst_cnt = 0;

    bit [320-1:0]    data = 0; // max size could make an array for later improvement
   

    //------------------------------------------
    // Sideband Data Members
    //------------------------------------------

    `uvm_object_utils_begin(chan_delay_seq_item_c)
        `uvm_field_int(chan_num, UVM_DEFAULT);
        `uvm_field_int(init_delay_clk, UVM_DEFAULT);
        `uvm_field_int(chan_delay_clk, UVM_DEFAULT);
        `uvm_field_int(burst_en, UVM_DEFAULT);
        `uvm_field_int(burst_cnt, UVM_DEFAULT);
        `uvm_field_int(data, UVM_DEFAULT);
    `uvm_object_utils_end

    //------------------------------------------
    // constraints 
    //------------------------------------------
   
    // Standard UVM Methods:
    extern function new(string name = "chan_delay_seq_item");

endclass : chan_delay_seq_item_c

////////////////////////////////////////////////////////////
//--------------------------------------------------
function chan_delay_seq_item_c::new (string name = "chan_delay_seq_item");

    super.new(name);

endfunction : new

//--------------------------------------------------
////////////////////////////////////////////////////////////
`endif
