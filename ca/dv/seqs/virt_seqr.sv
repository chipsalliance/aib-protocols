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

`ifndef _CA_VIRT_SEQR_
`define _CA_VIRT_SEQR_
/////////////////////////////////////////////////////////
class virt_seqr_c extends uvm_sequencer ;
    
    `uvm_component_utils(virt_seqr_c)

    reset_seqr_c              reset_seqr;
    ca_tx_tb_out_seqr_c       ca_die_a_tx_tb_out_seqr;
    ca_tx_tb_out_seqr_c       ca_die_b_tx_tb_out_seqr;
    ca_cfg_c                  ca_cfg;
    virtual ca_gen_if         gen_vif;

    //------------------------------------------
    extern function new(string name = "virt_seqr", uvm_component parent);
    extern function void build_phase ( uvm_phase phase );

endclass : virt_seqr_c

////////////////////////////////////////////////////////////
//------------------------------------------
function virt_seqr_c::new(string name = "virt_seqr", uvm_component parent);
    
   super.new(name, parent);

endfunction : new
//------------------------------------------
function void virt_seqr_c::build_phase( uvm_phase  phase );
   
     if( !uvm_config_db #( ca_cfg_c )::get(this, "" , "ca_cfg", ca_cfg) )
      `uvm_fatal("build_phase", ">>> UNABLE to get ca_cfg !!! <<<") 
   
    if( !uvm_config_db #( virtual ca_gen_if )::get(this, "" , "gen_vif", gen_vif) )
        `uvm_fatal("build_phase", "unable to get gen_vif")
    
endfunction : build_phase 
/////////////////////////////////////////////////////////
`endif

