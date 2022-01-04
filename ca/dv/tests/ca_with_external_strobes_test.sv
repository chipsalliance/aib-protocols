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
// TEST_CASE DESCTIPTION
// ca_tx_en = 0. After getting aligndone,stop strobe injection from driver 
// After first traffic data completion, release stop_strobes_inject and 
// with external strobes traffic checked. 
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_WITH_EXTERNAL_STROBES_TEST_
`define _CA_WITH_EXTERNAL_STROBES_TEST_
////////////////////////////////////////////////////////////

class ca_with_external_strobes_test_c extends base_ca_test_c;
 
    // UVM Factory Registration Macro
    `uvm_component_utils(ca_with_external_strobes_test_c)
 
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
    extern function new(string name = "ca_with_external_strobes_test", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void start_of_simulation( );
    extern task run_phase( uvm_phase phase);
    extern task run_test( uvm_phase phase );
    extern task ck_align_done( );
 
endclass:ca_with_external_strobes_test_c
////////////////////////////////////////////////////////////

//------------------------------------------
function ca_with_external_strobes_test_c::new(string name = "ca_with_external_strobes_test", uvm_component parent = null);
    super.new(name, parent);
endfunction : new
 
//------------------------------------------
function void ca_with_external_strobes_test_c::build_phase( uvm_phase phase );
    // build in base test 
    super.build_phase(phase);
endfunction: build_phase

//------------------------------------------
function void ca_with_external_strobes_test_c::start_of_simulation( );
    //
endfunction: start_of_simulation 
 
//------------------------------------------
// run phase 
task ca_with_external_strobes_test_c::run_phase(uvm_phase phase);
    fork
        run_test(phase);
        global_timer(); // and check for error count
        ck_eot(phase);
        ck_align_done();
    join

endtask : run_phase
 
//------------------------------------------
task ca_with_external_strobes_test_c::ck_align_done();
     forever begin
        repeat(1)@(posedge vif.clk);
           // After aligndone stop_strobes_inject and dont feed external strobes
             if(ca_cfg.ca_die_a_tx_tb_out_cfg.align_done_assert == 1)begin
                ca_cfg.ca_die_a_tx_tb_out_cfg.stop_strobes_inject = 1;
             end
             if(ca_cfg.ca_die_b_tx_tb_out_cfg.align_done_assert == 1)begin
                ca_cfg.ca_die_b_tx_tb_out_cfg.stop_strobes_inject = 1;
             end 
     end
endtask: ck_align_done
//------------------------------------------

//------------------------------------------
task ca_with_external_strobes_test_c::run_test(uvm_phase phase);
     
     bit result=0;

    `uvm_info("ca_with_external_strobes_test ::run_phase", "START test...", UVM_LOW);
     ca_cfg.ca_die_a_tx_tb_in_cfg.with_external_stb_test   = 1;
     ca_cfg.ca_die_b_tx_tb_in_cfg.with_external_stb_test   = 1;
     ca_cfg.ca_die_a_rx_tb_in_cfg.with_external_stb_test   = 1;
     ca_cfg.ca_die_b_rx_tb_in_cfg.with_external_stb_test   = 1;
     ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_en               = 0;
     ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_en               = 0;
     ca_vseq = ca_seq_lib_c::type_id::create("ca_vseq");
     ca_vseq.start(ca_top_env.virt_seqr);
    `uvm_info("ca_with_external_strobes_test ::run_phase", "wait_ended for 1st drv_tfr_complete..\n", UVM_LOW);
     wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
     `uvm_info("ca_with_external_strobes_test ::run_phase", "wait_ended for 1st drv_tfr_complete..\n", UVM_LOW);
     result =  ck_xfer_cnt_a(1);
     result =  ck_xfer_cnt_b(1);
     `uvm_info("ca_with_external_strobes_test ::run_phase", "Scoreboard comparison completed for first set of traffic ..\n", UVM_LOW);
     // RELEASE stop_strobes_inject and feed external strobes
     repeat(20)@ (posedge vif.clk);
     ca_cfg.ca_die_a_tx_tb_out_cfg.align_done_assert       = 0; 
     ca_cfg.ca_die_b_tx_tb_out_cfg.align_done_assert       = 0; 
     ca_cfg.ca_die_a_tx_tb_out_cfg.stop_strobes_inject     = 0;
     ca_cfg.ca_die_b_tx_tb_out_cfg.stop_strobes_inject     = 0;
     sbd_counts_clear;

      ca_vseq.start(ca_top_env.virt_seqr);
     `uvm_info("ca_with_external_strobes_test ::run_phase", "wait_started for 2nd drv_tfr_complete ..\n", UVM_LOW);
      wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
     `uvm_info("ca_with_external_strobes_test ::run_phase", "wait_ended for 2nd drv_tfr_complete ..\n", UVM_LOW);
      repeat(10)@ (posedge vif.clk);
      result =  ck_xfer_cnt_a(1);
      result =  ck_xfer_cnt_b(1);
     `uvm_info("ca_with_external_strobes_test ::run_phase", "Scoreboard comparison completed for second set of traffic ..\n", UVM_LOW);
     test_end = 1; 
     `uvm_info("ca_with_external_strobes_test ::run_phase", "END test...\n", UVM_LOW);

endtask : run_test
////////////////////////////////////////////////////////////////
`endif
