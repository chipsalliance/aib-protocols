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
// TEST_CASE_DESCRIPTION
// sending traffic and Data matching in scorebaord => 
// calling reset_seq (configuring RESET LOW,then RESET_HIGH =>
// sending TRAFFIC and Data matching in scoreboard 
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_TRAFFIC_RESET_TRAFFIC_TEST_
`define _CA_TRAFFIC_RESET_TRAFFIC_TEST_
////////////////////////////////////////////////////////////

class ca_traffic_reset_traffic_test_c extends base_ca_test_c;
 
    // UVM Factory Registration Macro
    `uvm_component_utils(ca_traffic_reset_traffic_test_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    ca_seq_lib_c         ca_vseq;
    bit[15:0]            tx_stb_intv;
    int                  tx_stb_intv_bkp;
    int                  bit_shift;
 
    //------------------------------------------
    // Component Members
    //------------------------------------------
 
    //------------------------------------------
    // Methods
    //------------------------------------------
 
    // Standard UVM Methods:
    extern function new(string name = "ca_traffic_reset_traffic_test", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void start_of_simulation( );
    extern task run_phase( uvm_phase phase);
    extern task run_test( uvm_phase phase );
 
endclass:ca_traffic_reset_traffic_test_c 
////////////////////////////////////////////////////////////

//------------------------------------------
function ca_traffic_reset_traffic_test_c::new(string name = "ca_traffic_reset_traffic_test", uvm_component parent = null);
    super.new(name, parent);
endfunction : new
 
//------------------------------------------
function void ca_traffic_reset_traffic_test_c::build_phase( uvm_phase phase );
    // build in base test 
    super.build_phase(phase);
endfunction: build_phase

//------------------------------------------
function void ca_traffic_reset_traffic_test_c::start_of_simulation( );
    //
endfunction: start_of_simulation 
 
//------------------------------------------
// run phase 
task ca_traffic_reset_traffic_test_c::run_phase(uvm_phase phase);
    fork
        run_test(phase);
        global_timer(); // and check for error count
        ck_eot(phase);
    join
endtask : run_phase

//------------------------------------------
task ca_traffic_reset_traffic_test_c::run_test(uvm_phase phase);

     bit result = 0;

      `uvm_info("ca_traffic_reset_traffic_test ::run_phase", "START test...", UVM_LOW);

      ca_vseq        = ca_seq_lib_c::type_id::create("ca_vseq");

     `uvm_info("ca_traffic_reset_traffic_test ::run_phase", "first ca_vseq started  ..\n", UVM_LOW);
      ca_vseq.start(ca_top_env.virt_seqr);
     `uvm_info("ca_traffic_reset_traffic_test ::run_phase", "first ca_vseq started  ..\n", UVM_LOW);

     `uvm_info("ca_traffic_reset_traffic_test ::run_phase", "wait_started for 1st drv_tfr_complete ..\n", UVM_LOW);
      wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
     `uvm_info("ca_traffic_reset_traffic_test ::run_phase", "wait_ended for 1st drv_tfr_complete..\n", UVM_LOW);

      repeat(10)@ (posedge vif.clk);
      result =  ck_xfer_cnt_a(1);
      result =  ck_xfer_cnt_b(1);
     `uvm_info("ca_traffic_reset_traffic_test ::run_phase", "SCOREBOARD comparison completed for first set of traffic ..\n", UVM_LOW);
      repeat(20)@ (posedge vif.clk);

       sbd_counts_clear();
       
      `uvm_info("ca_traffic_reset_traffic_test ::run_phase", "second ca_vseq started  ..\n", UVM_LOW);
       ca_vseq.start(ca_top_env.virt_seqr);// {reset,traffic}
      `uvm_info("ca_traffic_reset_traffic_test ::run_phase", "second ca_vseq ended ..\n", UVM_LOW);

      `uvm_info("ca_traffic_reset_traffic_test ::run_phase", "wait_started for second drv_tfr_complete ..\n", UVM_LOW);
       wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
      `uvm_info("ca_traffic_reset_traffic_test ::run_phase", "wait_ended for second drv_tfr_complete ..\n", UVM_LOW);

       repeat(10)@ (posedge vif.clk);
       result =  ck_xfer_cnt_a(1);
       result =  ck_xfer_cnt_b(1);
      `uvm_info("ca_traffic_reset_traffic_test ::run_phase", "SCOREBOARD comparison completed for second set of traffic ..\n", UVM_LOW);
       repeat(20)@ (posedge vif.clk);

       test_end = 1; 
      `uvm_info("ca_traffic_reset_traffic_test ::run_phase", "END test...\n", UVM_LOW);

endtask : run_test
////////////////////////////////////////////////////////////////
`endif

