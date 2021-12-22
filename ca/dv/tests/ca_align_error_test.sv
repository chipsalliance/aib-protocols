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
// TEST CASE DESCRIPTION
// By configuring in sailrock_cfg.txt FIFO_DEPTH = 8 and interchannel skew as 0A01, 
// align_err achieved  in this test case (num of active ch=2)
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_ALIGN_ERROR_TEST_
`define _CA_ALIGN_ERROR_TEST_
////////////////////////////////////////////////////////////

class ca_align_error_test_c extends base_ca_test_c;
 
    // UVM Factory Registration Macro
    `uvm_component_utils(ca_align_error_test_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    ca_seq_lib_c    ca_vseq;
    bit             test_end_rx_a;
    bit             test_end_rx_b;
    //------------------------------------------
    // Component Members
    //------------------------------------------
 
    //------------------------------------------
    // Methods
    //------------------------------------------
 
    // Standard UVM Methods:
    extern function new(string name = "ca_align_error_test", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void start_of_simulation( );
    extern task chk_align_error( );
    extern task run_phase( uvm_phase phase);
    extern task run_test( uvm_phase phase );
 
endclass:ca_align_error_test_c
////////////////////////////////////////////////////////////

//------------------------------------------
function ca_align_error_test_c::new(string name = "ca_align_error_test", uvm_component parent = null);
    super.new(name, parent);
endfunction : new
 
//------------------------------------------
function void ca_align_error_test_c::build_phase( uvm_phase phase );
    // build in base test 
    super.build_phase(phase);
endfunction: build_phase

//------------------------------------------
function void ca_align_error_test_c::start_of_simulation( );
    //
endfunction: start_of_simulation 
 
//------------------------------------------
task ca_align_error_test_c::chk_align_error();
     forever begin
        repeat(1)@(posedge vif.clk); 
        if((ca_cfg.ca_die_a_rx_tb_in_cfg.num_of_align_error == 1) && (test_end_rx_a == 0)) test_end_rx_a = 1;

        if((ca_cfg.ca_die_b_rx_tb_in_cfg.num_of_align_error == 1) && (test_end_rx_b == 0)) test_end_rx_b = 1;

        if((test_end_rx_a && test_end_rx_b) && (test_end == 0)) begin
            test_end = 1;  ////variable in base_test
        end
     end
endtask:chk_align_error 
//------------------------------------------
// run phase 
task ca_align_error_test_c::run_phase(uvm_phase phase);
    fork
        run_test(phase);
        global_timer(); // and check for error count
        ck_eot(phase);
        chk_align_error();
    join
endtask : run_phase

//------------------------------------------
task ca_align_error_test_c::run_test(uvm_phase phase);

     ca_cfg.ca_die_a_tx_tb_out_cfg.align_error_test  = 1;
     ca_cfg.ca_die_b_tx_tb_out_cfg.align_error_test  = 1;
     ca_cfg.ca_die_a_tx_tb_in_cfg.align_error_test   = 1;
     ca_cfg.ca_die_b_tx_tb_in_cfg.align_error_test   = 1;
     ca_cfg.ca_die_a_rx_tb_in_cfg.align_error_test   = 1;
     ca_cfg.ca_die_b_rx_tb_in_cfg.align_error_test   = 1;

    `uvm_info("ca_align_error_test::run_phase", "START test...", UVM_LOW);
     ca_vseq = ca_seq_lib_c::type_id::create("ca_vseq");

    `uvm_info("ca_align_error_test::run_phase", "ca_vseq starts..\n", UVM_LOW);
     ca_vseq.start(ca_top_env.virt_seqr);
    `uvm_info("ca_align_error_test::run_phase", "ca_vseq ends...\n", UVM_LOW);

  endtask : run_test
////////////////////////////////////////////////////////////////
`endif
