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
// TEST CASE DESCRIPTION
// fifo_full_Val , fifo_pfull_Val, fifo_empty_val,fifo_pempty_val 
// changed in this test case. complement values of previous  
// fifo values configured for DUT, to achieve Toggle coverage.
// Then proper fifo_values configured and send traffic 
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_FIFO_VALUE_VARIATIONS_TEST_
`define _CA_FIFO_VALUE_VARIATIONS_TEST_
////////////////////////////////////////////////////////////

class ca_fifo_ptr_values_variations_test_c extends base_ca_test_c;
 
    // UVM Factory Registration Macro
    `uvm_component_utils(ca_fifo_ptr_values_variations_test_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    ca_seq_lib_c        ca_vseq;
    ca_traffic_seq_c    ca_traffic_seq;
 
    //------------------------------------------
    // Component Members
    //------------------------------------------
 
    //------------------------------------------
    // Methods
    //------------------------------------------
 
    // Standard UVM Methods:
    extern function new(string name = "ca_fifo_ptr_values_variations_test", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void start_of_simulation( );
    extern task run_phase( uvm_phase phase);
    extern task run_test( uvm_phase phase );
 
endclass:ca_fifo_ptr_values_variations_test_c 
////////////////////////////////////////////////////////////

//------------------------------------------
function ca_fifo_ptr_values_variations_test_c::new(string name = "ca_fifo_ptr_values_variations_test", uvm_component parent = null);
    super.new(name, parent);
endfunction : new
 
//------------------------------------------
function void ca_fifo_ptr_values_variations_test_c::build_phase( uvm_phase phase );
    // build in base test 
    super.build_phase(phase);
endfunction: build_phase

//------------------------------------------
function void ca_fifo_ptr_values_variations_test_c::start_of_simulation( );
    //
endfunction: start_of_simulation 
 
//------------------------------------------
// run phase 
task ca_fifo_ptr_values_variations_test_c::run_phase(uvm_phase phase);
    fork
        run_test(phase);
        global_timer(); // and check for error count
        ck_eot(phase);
    join

endtask : run_phase

//------------------------------------------
task ca_fifo_ptr_values_variations_test_c::run_test(uvm_phase phase);

      bit result = 0;

      `uvm_info("ca_fifo_ptr_values_variations_test ::run_phase", "START test...", UVM_LOW);
      ca_vseq        = ca_seq_lib_c::type_id::create("ca_vseq");
      ca_traffic_seq = ca_traffic_seq_c::type_id::create("ca_traffic_seq");

      ca_vseq.start(ca_top_env.virt_seqr); // Default value of fifo_ptr*  configured here 

      `uvm_info("ca_fifo_ptr_values_variations_test ::run_phase", "wait_started for 1st drv_tfr_complete ..\n", UVM_LOW);
      wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
      `uvm_info("ca_fifo_ptr_values_variations_test ::run_phase", "wait_ended for 1st drv_tfr_complete..\n", UVM_LOW);

      result =  ck_xfer_cnt_a(1);
      result =  ck_xfer_cnt_b(1);
      `uvm_info("ca_fifo_ptr_values_variations_test ::run_phase", "SCOREBOARD comparison completed for first set of traffic ..\n", UVM_LOW);

      repeat(20)@ (posedge vif.clk);
      ///// For toggle coverage [some values may be invalid as they are just complemented for toggle]
      ca_cfg.ca_die_a_rx_tb_in_cfg.fifo_full_val    = 32; //complement default value here 
      ca_cfg.ca_die_a_rx_tb_in_cfg.fifo_pfull_val   = 35; //complement default value here 
      ca_cfg.ca_die_a_rx_tb_in_cfg.fifo_empty_val   = 7;  //complement default value here 
      ca_cfg.ca_die_a_rx_tb_in_cfg.fifo_pempty_val  = 5;  //complement default value here 
      ca_cfg.ca_die_b_rx_tb_in_cfg.fifo_full_val    = 32; //complement default value here 
      ca_cfg.ca_die_b_rx_tb_in_cfg.fifo_pfull_val   = 35; //complement default value here 
      ca_cfg.ca_die_b_rx_tb_in_cfg.fifo_empty_val   = 7;  //complement default value here 
      ca_cfg.ca_die_b_rx_tb_in_cfg.fifo_pempty_val  = 5;  //complement default value here 

      repeat(20)@ (posedge vif.clk);
    
     ca_cfg.ca_die_a_rx_tb_in_cfg.fifo_full_val    = 31; //proper vaues configured here 
     ca_cfg.ca_die_a_rx_tb_in_cfg.fifo_pfull_val   = 28; //proper vaues configured here 
     ca_cfg.ca_die_a_rx_tb_in_cfg.fifo_empty_val   = 0;  //proper vaues configured here 
     ca_cfg.ca_die_a_rx_tb_in_cfg.fifo_pempty_val  = 2;  //proper vaues configured here 
     ca_cfg.ca_die_b_rx_tb_in_cfg.fifo_full_val    = 31; //proper vaues configured here 
     ca_cfg.ca_die_b_rx_tb_in_cfg.fifo_pfull_val   = 28; //proper vaues configured here 
     ca_cfg.ca_die_b_rx_tb_in_cfg.fifo_empty_val   = 0;  //proper vaues configured here 
     ca_cfg.ca_die_b_rx_tb_in_cfg.fifo_pempty_val  = 2;  //proper vaues configured here 

      repeat(20)@ (posedge vif.clk);
      sbd_counts_clear();
      ///Checking traffic with different fifo_ptr values than defaults 
     ca_cfg.ca_die_a_rx_tb_in_cfg.fifo_full_val    = 6; //proper vaues configured here 
     ca_cfg.ca_die_a_rx_tb_in_cfg.fifo_pfull_val   = 5; //proper vaues configured here 
     ca_cfg.ca_die_a_rx_tb_in_cfg.fifo_empty_val   = 1;  //proper vaues configured here 
     ca_cfg.ca_die_a_rx_tb_in_cfg.fifo_pempty_val  = 3;  //proper vaues configured here 
     ca_cfg.ca_die_b_rx_tb_in_cfg.fifo_full_val    = 5; //proper vaues configured here 
     ca_cfg.ca_die_b_rx_tb_in_cfg.fifo_pfull_val   = 4; //proper vaues configured here 
     ca_cfg.ca_die_b_rx_tb_in_cfg.fifo_empty_val   = 3;  //proper vaues configured here 
     ca_cfg.ca_die_b_rx_tb_in_cfg.fifo_pempty_val  = 4;  //proper vaues configured here 

     `uvm_info("ca_fifo_ptr_values_variations_test ::run_phase", "ca_traffic_seq started ..\n", UVM_LOW);
      ca_traffic_seq.start(ca_top_env.virt_seqr);
      //ca_vseq.start(ca_top_env.virt_seqr);
     `uvm_info("ca_fifo_ptr_values_variations_test ::run_phase", "ca_traffic_seq ended ..\n", UVM_LOW);

     `uvm_info("ca_fifo_ptr_values_variations_test ::run_phase", "wait_started for second drv_tfr_complete ..\n", UVM_LOW);
      wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
     `uvm_info("ca_fifo_ptr_values_variations_test ::run_phase", "wait_ended for second drv_tfr_complete ..\n", UVM_LOW);

      repeat(10)@ (posedge vif.clk);
      result =  ck_xfer_cnt_a(1);
      result =  ck_xfer_cnt_b(1);
     `uvm_info("ca_fifo_ptr_values_variations_test ::run_phase", "SCOREBOARD comparison completed for second set of traffic ..\n", UVM_LOW);

      test_end = 1; 
     `uvm_info("ca_fifo_ptr_values_variations_test ::run_phase", "END test...\n", UVM_LOW);

endtask : run_test
////////////////////////////////////////////////////////////////
`endif
