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

`ifndef _CA_TX_TB_IN_CFG_
`define _CA_TX_TB_IN_CFG_

////////////////////////////////////////////////////////////
class ca_tx_tb_in_cfg_c extends uvm_object;
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    // Whether env analysis components are used:
    bit         agent_active  = UVM_PASSIVE;
    bit         has_func_cov  = 0;
    bit [7:0]   tx_stb_intv = 0;
    bit              tx_stb_en         = `CA_TX_STB_EN;    // default
    bit [7:0]        tx_stb_wd_sel     = `CA_TX_STB_WD_SEL;
    bit [39:0]       tx_stb_bit_sel    = `CA_TX_STB_BIT_SEL;
    bit              tx_en_stb_check   = 1;
    logic [3:0]      user_marker;
    bit [2:0]        master_rate       = `MSR_GEAR;
    bit [2:0]        slave_rate        = `SLV_GEAR;
    string           my_name = "";
    int              last_tx_cnt_a;
    int              last_tx_cnt_b;

    //------------------------------------------
    // UVM Factory Registration Macro
    //------------------------------------------
    `uvm_object_utils_begin(ca_tx_tb_in_cfg_c)
        `uvm_field_int(agent_active,     UVM_DEFAULT);
        `uvm_field_int(has_func_cov,     UVM_DEFAULT);
        `uvm_field_int(tx_stb_intv,      UVM_DEFAULT);
        `uvm_field_int(tx_stb_bit_sel,   UVM_DEFAULT);
        `uvm_field_int(tx_stb_wd_sel,    UVM_DEFAULT);
        `uvm_field_int(tx_stb_en,        UVM_DEFAULT);
        `uvm_field_int(tx_en_stb_check,  UVM_DEFAULT);
    `uvm_object_utils_end
 
    //------------------------------------------
    // constraints 
    //------------------------------------------

    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:
    extern function new(string name = "ca_tx_tb_in_cfg");
    extern function void build_phase( uvm_phase phase );
    extern virtual function void cp( ca_tx_tb_out_pkg::ca_tx_tb_out_cfg_c  out_cfg);
    extern virtual function void configure( );
 
endclass: ca_tx_tb_in_cfg_c
////////////////////////////////////////////////////////////

function ca_tx_tb_in_cfg_c::new(string name = "ca_tx_tb_in_cfg");
    super.new(name);
endfunction
 
//
//------------------------------------------
function void ca_tx_tb_in_cfg_c::build_phase( uvm_phase phase );


endfunction: build_phase
    
//------------------------------------------
function void ca_tx_tb_in_cfg_c::cp( ca_tx_tb_out_pkg::ca_tx_tb_out_cfg_c  out_cfg);
    
    tx_stb_wd_sel  = out_cfg.tx_stb_wd_sel;
    tx_stb_bit_sel = out_cfg.tx_stb_bit_sel;
    tx_stb_en      = out_cfg.tx_stb_en;    
    tx_stb_intv    = out_cfg.tx_stb_intv;

endfunction : cp

//------------------------------------------
function void ca_tx_tb_in_cfg_c::configure( );
    if(my_name == "DIE_A" )begin
        master_rate = `MSR_GEAR ;
        slave_rate  = `SLV_GEAR ;
    end else begin
        master_rate = `SLV_GEAR ;
        slave_rate  = `MSR_GEAR ;
    end

endfunction: configure 
////////////////////////////////////////////////////////////
`endif
