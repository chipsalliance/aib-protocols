////////////////////////////////////////////////////////////////////////////////////////////////////
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
// Functional Descript: Channel Alignment Testbench File
//
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_TX_TB_OUT_CFG_
`define _CA_TX_TB_OUT_CFG_

////////////////////////////////////////////////////////////
class ca_tx_tb_out_cfg_c extends uvm_object;
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    // Whether env analysis components are used:
    bit    agent_active  = UVM_ACTIVE;
    bit    has_func_cov  = 0;

    string           my_name = "";
    bit [7:0]        tx_stb_wd_sel  = `CA_TX_STB_WD_SEL;
    bit [39:0]       tx_stb_bit_sel = `CA_TX_STB_BIT_SEL;
    bit              tx_online      = 1;    // default
    bit              tx_stb_en      = `CA_TX_STB_EN;    // default
    bit              tx_stb_rcvr    = 0;    // default
    bit [15:0]       tx_stb_intv   = `CA_TX_STB_INTV ;
    rand int         bit_shift ;
    int              bits_per_channel = 0;
    bit              stb_error_test;
    bit              align_error_test;
    bit              stop_strobes_inject;
    bit              align_done_assert;
    bit              shift_stb_intv_enb;
    bit              shift_stb_bit_pos_en;
    int              max_wd_sel = 0 ; 
    bit              ca_afly1_stb_incorrect_intv_test;
    bit              ca_tx_online_test;
    int              req_cnt;
    bit              ca_stb_rcvr_aft_aln_done_test;
    bit [15:0]       delay_xz_value;
    bit              stop_monitor;
    bit              tx_q_not_zero; 
    //------------------------------------------
    // UVM Factory Registration Macro
    //------------------------------------------
    `uvm_object_utils_begin(ca_tx_tb_out_cfg_c)
        `uvm_field_string(my_name,       UVM_DEFAULT);
        `uvm_field_int(agent_active,     UVM_DEFAULT);
        `uvm_field_int(has_func_cov,     UVM_DEFAULT);
        `uvm_field_int(tx_stb_wd_sel,    UVM_DEFAULT);
        `uvm_field_int(tx_stb_bit_sel,   UVM_DEFAULT);
        `uvm_field_int(tx_online,        UVM_DEFAULT);
        `uvm_field_int(tx_stb_en,        UVM_DEFAULT);
        `uvm_field_int(tx_stb_rcvr,      UVM_DEFAULT);
        `uvm_field_int(tx_stb_intv,      UVM_DEFAULT);
        `uvm_field_int(bits_per_channel, UVM_DEFAULT);
    `uvm_object_utils_end
 
    //------------------------------------------
    // constraints 
    //------------------------------------------
     constraint c_bit_shift      { bit_shift  inside {[0:37]}; }
    //constraint c_tx_stb_intv    { tx_stb_intv  inside {[4:16]}; } // FIXME - need min/max for distribution

    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:
    extern function new(string name = "ca_tx_tb_out_cfg");
    extern function void build_phase( uvm_phase phase );
    extern function void set_bits_per_channel(int _bits_per_channel);
    extern virtual function void configure( );
 
endclass: ca_tx_tb_out_cfg_c
////////////////////////////////////////////////////////////

function ca_tx_tb_out_cfg_c::new(string name = "ca_tx_tb_out_cfg");
    super.new(name);
endfunction
 
//
//------------------------------------------
function void ca_tx_tb_out_cfg_c::build_phase( uvm_phase phase );


endfunction: build_phase

//------------------------------------------
function void ca_tx_tb_out_cfg_c::set_bits_per_channel(int _bits_per_channel);
    bits_per_channel = _bits_per_channel;
    `uvm_info("ca_tx_tb_out_cfg", $sformatf("%s set bits per channel: %0d", my_name, bits_per_channel), UVM_MEDIUM);
endfunction : set_bits_per_channel

//------------------------------------------
function void ca_tx_tb_out_cfg_c::configure( );
   
    int wd_shift   = 0 ;

    if(bits_per_channel == 0) `uvm_fatal("configure", $sformatf("bits_per_channel != 0"));
    max_wd_sel = bits_per_channel/40;
    if(max_wd_sel > 1) wd_shift =  $urandom_range((max_wd_sel-1),0);

    tx_stb_bit_sel = tx_stb_bit_sel << bit_shift;
    tx_stb_wd_sel  = tx_stb_wd_sel << wd_shift;
    `uvm_info("ca_tx_tb_out_cfg", $sformatf("%s bit_shift: %0d wd_shift: %0d tx_stb_bit_sel: %0b  tx_stb_wd_sel: %0b", 
        my_name, bit_shift, wd_shift, tx_stb_bit_sel, tx_stb_wd_sel), UVM_LOW);

endfunction: configure 
////////////////////////////////////////////////////////////
`endif
