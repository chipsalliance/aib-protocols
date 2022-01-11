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

`ifndef _CA_RX_TB_IN_CFG_
`define _CA_RX_TB_IN_CFG_

////////////////////////////////////////////////////////////
class ca_rx_tb_in_cfg_c extends uvm_object;
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    // Whether env analysis components are used:
    bit    agent_active  = UVM_ACTIVE;
    bit    has_func_cov  = 0;

    string           my_name = "";
    bit [7:0]        rx_stb_wd_sel    = `CA_RX_STB_WD_SEL ;
    bit [39:0]       rx_stb_bit_sel   = `CA_RX_STB_BIT_SEL;
    bit              rx_online        = 1;    // default
    bit              rx_stb_en        = `CA_RX_STB_EN; 
    bit              align_fly        = `ALIGN_FLY;
    bit [5:0]        fifo_full_val    = `CA_FIFO_FULL -1 ;
    bit [5:0]        fifo_pfull_val   = `CA_FIFO_PFULL;
    bit [2:0]        fifo_empty_val   = `CA_FIFO_EMPTY; 
    bit [2:0]        fifo_pempty_val  = `CA_FIFO_PEMPTY;
    bit [2:0]        rden_dly         = `CA_RDEN_DLY; 
    bit [15:0]       delay_x_value    = 10; 
    bit [15:0]       delay_xz_value   = 14; 
    rand bit [15:0]   rx_stb_intv;
    bit              tx_stb_rcvr;
    rand int         bit_shift;
    int              bits_per_channel = 0;
    bit [2:0]        master_rate      = `MSR_GEAR;
    bit [2:0]        slave_rate       = `SLV_GEAR;

    bit              en_rx_stb_check = 1;
    bit              tx_stb_en      = `CA_TX_STB_EN;    // default
    bit [7:0]        tx_stb_wd_sel  = `CA_TX_STB_WD_SEL;
    bit [39:0]       tx_stb_bit_sel = `CA_TX_STB_BIT_SEL;
    int              last_tx_cnt_a;
    int              last_tx_cnt_b;
    bit              drv_tfr_complete_a;
    bit              drv_tfr_complete_b;
    bit              drv_tfr_complete_ab;
    bit              test_end;
    bit              stb_error_test;
    bit              align_error_test;
    int              num_of_stb_error;
    int              num_of_align_error;
    bit              no_external_stb_test;
    bit              with_external_stb_test;
    bit              ca_afly1_stb_incorrect_intv_test;
    bit              ca_afly_toggling_test;
    bit              stop_stb_checker;
    bit              stop_monitor;
    bit              ca_tx_online_test;
    bit              ca_fifo_ptr_values_variations_test;
    int              very_first_rx_dout_time;
    int              very_first_align_done_time;
    bit              ca_stb_rcvr_aft_aln_done_test;
    bit              align_error_afly0_test;
    //------------------------------------------
    // UVM Factory Registration Macro
    //------------------------------------------
    `uvm_object_utils_begin(ca_rx_tb_in_cfg_c)
        `uvm_field_string(my_name,       UVM_DEFAULT);
        `uvm_field_int(agent_active,     UVM_DEFAULT);
        `uvm_field_int(has_func_cov,     UVM_DEFAULT);
        `uvm_field_int(rx_stb_wd_sel,    UVM_DEFAULT);
        `uvm_field_int(rx_stb_bit_sel,   UVM_DEFAULT);
        `uvm_field_int(rx_online,        UVM_DEFAULT);
        `uvm_field_int(rx_stb_en,        UVM_DEFAULT);
        `uvm_field_int(rx_stb_intv,      UVM_DEFAULT);
        `uvm_field_int(align_fly,        UVM_DEFAULT);
        `uvm_field_int(fifo_full_val,    UVM_DEFAULT);
        `uvm_field_int(fifo_pfull_val,   UVM_DEFAULT);
        `uvm_field_int(fifo_empty_val,   UVM_DEFAULT);
        `uvm_field_int(fifo_pempty_val,  UVM_DEFAULT);
        `uvm_field_int(bits_per_channel, UVM_DEFAULT);
        `uvm_field_int(en_rx_stb_check,  UVM_DEFAULT);
    `uvm_object_utils_end
 
    //------------------------------------------
    // constraints 
    //------------------------------------------
    constraint c_bit_shift      { bit_shift  inside {[0:37]}; }
    constraint c_rx_stb_intv    { rx_stb_intv  inside {[96:300]}; } // FIXME - need min/max for distribution
    constraint c_rden_dly       { rden_dly  inside {[4:7]}; } // FIXME - need min/max for distribution

    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:
    extern function new(string name = "ca_rx_tb_in_cfg");
    extern function void build_phase( uvm_phase phase );
    extern function void set_bits_per_channel(int _bits_per_channel);
    extern virtual function void configure( );
 
endclass: ca_rx_tb_in_cfg_c
////////////////////////////////////////////////////////////

function ca_rx_tb_in_cfg_c::new(string name = "ca_rx_tb_in_cfg");
    super.new(name);
endfunction
 
//
//------------------------------------------
function void ca_rx_tb_in_cfg_c::build_phase( uvm_phase phase );


endfunction: build_phase

//------------------------------------------
function void ca_rx_tb_in_cfg_c::set_bits_per_channel(int _bits_per_channel);
    bits_per_channel = _bits_per_channel;
    `uvm_info("ca_rx_tb_in_cfg", $sformatf("%s set bits per channel: %0d", my_name, bits_per_channel), UVM_MEDIUM);
endfunction : set_bits_per_channel

//------------------------------------------
function void ca_rx_tb_in_cfg_c::configure( );
   
    int max_wd_sel = 0 ; 
    int wd_shift   = 0 ;

    if(my_name == "DIE_A" )begin
        master_rate = `MSR_GEAR ;
        slave_rate  = `SLV_GEAR ;
    end else begin
        master_rate = `SLV_GEAR ;
        slave_rate  = `MSR_GEAR ;
    end

//    if(bits_per_channel == 0) `uvm_fatal("configure", $sformatf("bits_per_channel != 0"));

//    if(bits_per_channel == 0) `uvm_fatal("configure", $sformatf("bits_per_channel != 0"));
//    max_wd_sel = bits_per_channel/40;
//    if(max_wd_sel > 1) wd_shift =  $urandom_range((max_wd_sel-1),0);
//
//    rx_stb_bit_sel = rx_stb_bit_sel << bit_shift;
//    rx_stb_wd_sel  = rx_stb_wd_sel << wd_shift;
//    `uvm_info("ca_rx_tb_in_cfg", $sformatf("%s bit_shift: %0d wd_shift: %0d rx_stb_bit_sel: %0h  rx_stb_wd_sel: %0d", 
//        my_name, bit_shift, wd_shift, rx_stb_bit_sel, rx_stb_wd_sel), UVM_MEDIUM);

endfunction: configure 
////////////////////////////////////////////////////////////
`endif
