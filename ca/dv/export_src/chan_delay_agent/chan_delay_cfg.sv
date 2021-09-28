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

`ifndef _CHAN_DELAY_CFG_
`define _CHAN_DELAY_CFG_

////////////////////////////////////////////////////////////
class chan_delay_cfg_c extends uvm_object;
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    bit              agent_active  = UVM_ACTIVE;
    bit              has_func_cov  = 0;

    int              chan_num = -1;
    string           my_name = "";

    int              fast_clk_multiplier = 10;

    rand int         init_delay_clk; // inital delay before sending 1st xfer
    rand int         chan_delay_clk; // delay each xfer

    rand bit         burst_en;
    rand int         burst_cnt;
   

    //------------------------------------------
    // UVM Factory Registration Macro
    //------------------------------------------
    `uvm_object_utils_begin(chan_delay_cfg_c)
        `uvm_field_int(agent_active,     UVM_DEFAULT);
        `uvm_field_int(has_func_cov,     UVM_DEFAULT);
        `uvm_field_string(my_name,       UVM_DEFAULT);
        `uvm_field_int(chan_num,         UVM_DEFAULT);
        `uvm_field_int(init_delay_clk,   UVM_DEFAULT);
        `uvm_field_int(chan_delay_clk,   UVM_DEFAULT);
        `uvm_field_int(burst_en,         UVM_DEFAULT);
        `uvm_field_int(burst_cnt,        UVM_DEFAULT);
    `uvm_object_utils_end
 
    //------------------------------------------
    // constraints 
    //------------------------------------------
    constraint c_init_delay_clk   { init_delay_clk  inside {[10:100]}; }
    constraint c_chan_delay_clk   { chan_delay_clk  inside {[1:7]}; } // FIXME - need min/max for distribution
    constraint c_burst_cnt        { burst_cnt       inside {[2:8]}; } // FIXME - need min/max for distribution

    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:
    extern function new(string name = "chan_delay_cfg");
    extern function void build_phase( uvm_phase phase );
    extern function void set_chan_num(int _chan);
    extern virtual function void configure( );
 
endclass: chan_delay_cfg_c
////////////////////////////////////////////////////////////

function chan_delay_cfg_c::new(string name = "chan_delay_cfg");
    super.new(name);
endfunction
 
//
//------------------------------------------
function void chan_delay_cfg_c::build_phase( uvm_phase phase );


endfunction: build_phase

//------------------------------------------
function void chan_delay_cfg_c::set_chan_num(int _chan);
    chan_num = _chan;
    `uvm_info("chan_delay_cfg", $sformatf("set chan_num: %0d", chan_num), UVM_MEDIUM);
endfunction : set_chan_num

//------------------------------------------
function void chan_delay_cfg_c::configure( );
   

endfunction: configure 
////////////////////////////////////////////////////////////
`endif
