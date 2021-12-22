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
// TESTCASE DESCRIPTION
// tx_stb_enb = 0 and no strobes injected from CA driver(tx_din) to DUT.
// align_done won't assert from this cfg. test ended after some fixed time.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_NO_EXTERNAL_STROBES_TEST_
`define _CA_NO_EXTERNAL_STROBES_TEST_
////////////////////////////////////////////////////////////

class ca_no_external_strobes_test_c extends base_ca_test_c;
 
    // UVM Factory Registration Macro
    `uvm_component_utils(ca_no_external_strobes_test_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    ca_seq_lib_c    ca_vseq;
 
    //------------------------------------------
    // Component Members
    //------------------------------------------
 
    //------------------------------------------
    // Methods
    //------------------------------------------
 
    // Standard UVM Methods:
    extern function new(string name = "ca_no_external_strobes_test", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void start_of_simulation( );
    extern task run_phase( uvm_phase phase);
    extern task run_test( uvm_phase phase );
    extern task update_test_end( );
 
endclass:ca_no_external_strobes_test_c
////////////////////////////////////////////////////////////

//------------------------------------------
function ca_no_external_strobes_test_c::new(string name = "ca_no_external_strobes_test", uvm_component parent = null);
    super.new(name, parent);
endfunction : new
 
//------------------------------------------
function void ca_no_external_strobes_test_c::build_phase( uvm_phase phase );
    // build in base test 
    super.build_phase(phase);
endfunction: build_phase

//------------------------------------------
function void ca_no_external_strobes_test_c::start_of_simulation( );
    //
endfunction: start_of_simulation 
 
//------------------------------------------
// run phase 
task ca_no_external_strobes_test_c::run_phase(uvm_phase phase);
    fork
        run_test(phase);
        global_timer(); // and check for error count
        ck_eot(phase);
        update_test_end();
    join
endtask : run_phase
 
//------------------------------------------
task ca_no_external_strobes_test_c::update_test_end();
     forever begin
        repeat(10000)@(posedge vif.clk); ///fixed-delay
             ca_top_env.virt_seqr.stop_sequences();
             if(test_end == 0) begin
               test_end = 1; 
               `uvm_info("ca_no_external_strobes_test ::run_phase", "END test...\n", UVM_LOW);
             end
     end
endtask: update_test_end 

//------------------------------------------
task ca_no_external_strobes_test_c::run_test(uvm_phase phase);

    `uvm_info("ca_no_external_strobes_test ::run_phase", "START test...", UVM_LOW);
     ca_cfg.ca_die_a_tx_tb_in_cfg.no_external_stb_test   = 1;
     ca_cfg.ca_die_b_tx_tb_in_cfg.no_external_stb_test   = 1;
     ca_cfg.ca_die_a_rx_tb_in_cfg.no_external_stb_test   = 1;
     ca_cfg.ca_die_b_rx_tb_in_cfg.no_external_stb_test   = 1;
     ca_cfg.ca_die_a_tx_tb_out_cfg.stop_strobes_inject   = 1;
     ca_cfg.ca_die_b_tx_tb_out_cfg.stop_strobes_inject   = 1;
     ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_en             = 0;
     ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_en             = 0;
     ca_cfg.configure(); 
     ca_vseq = ca_seq_lib_c::type_id::create("ca_vseq");
     ca_vseq.start(ca_top_env.virt_seqr);

endtask : run_test
////////////////////////////////////////////////////////////////
`endif
