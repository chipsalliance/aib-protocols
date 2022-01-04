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
// TEST CASE DESCRIPTION
// tx_online/rx_online configured as 0 to DUT, no traffic is happened due to this
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_TX_RX_ONLINE_TEST_
`define _CA_TX_RX_ONLINE_TEST_
////////////////////////////////////////////////////////////

class ca_tx_rx_online_test_c extends base_ca_test_c;
 
    // UVM Factory Registration Macro
    `uvm_component_utils(ca_tx_rx_online_test_c)
 
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
    extern function new(string name = "ca_tx_rx_online_test_c", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void start_of_simulation( );
    extern task run_phase( uvm_phase phase);
    extern task run_test( uvm_phase phase );
    extern task chk_align_done( );
 
endclass:ca_tx_rx_online_test_c 
////////////////////////////////////////////////////////////

//------------------------------------------
function ca_tx_rx_online_test_c::new(string name = "ca_tx_rx_online_test_c", uvm_component parent = null);
    super.new(name, parent);
endfunction : new
 
//------------------------------------------
function void ca_tx_rx_online_test_c::build_phase( uvm_phase phase );
    // build in base test 
    super.build_phase(phase);
endfunction: build_phase

//------------------------------------------
function void ca_tx_rx_online_test_c::start_of_simulation( );
    //
endfunction: start_of_simulation 
 
//------------------------------------------
// run phase 
task ca_tx_rx_online_test_c::run_phase(uvm_phase phase);
    fork
        run_test(phase);
        global_timer(); // and check for error count
        ck_eot(phase);
        chk_align_done();
    join

endtask : run_phase

//------------------------------------------
task ca_tx_rx_online_test_c::run_test(uvm_phase phase);

      bit result = 0;

      `uvm_info("ca_tx_rx_online_test_c ::run_phase", "START test...", UVM_LOW);
        gen_if.force0_tx_rx_online = 1;
       ca_cfg.ca_die_a_tx_tb_out_cfg.ca_tx_online_test = 1;
       ca_cfg.ca_die_b_tx_tb_out_cfg.ca_tx_online_test = 1;
       ca_cfg.ca_die_a_tx_tb_in_cfg.ca_tx_online_test = 1;
       ca_cfg.ca_die_b_tx_tb_in_cfg.ca_tx_online_test = 1;
       ca_cfg.ca_die_a_rx_tb_in_cfg.ca_tx_online_test = 1;
       ca_cfg.ca_die_b_rx_tb_in_cfg.ca_tx_online_test = 1;

      ca_vseq        = ca_seq_lib_c::type_id::create("ca_vseq");
      ca_traffic_seq = ca_traffic_seq_c::type_id::create("ca_traffic_seq");

      ca_vseq.start(ca_top_env.virt_seqr); // Default value of fifo_ptr*  configured here 

      `uvm_info("ca_tx_rx_online_test_c ::run_phase", "wait_started for 1st drv_tfr_complete ..\n", UVM_LOW);
      wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
      `uvm_info("ca_tx_rx_online_test_c ::run_phase", "wait_ended for 1st drv_tfr_complete..\n", UVM_LOW);

      result =  ck_xfer_cnt_a(1);
      result =  ck_xfer_cnt_b(1);
      `uvm_info("ca_tx_rx_online_test_c ::run_phase", "SCOREBOARD comparison completed for first set of traffic ..\n", UVM_LOW);

      test_end = 1; 
      `uvm_info("ca_tx_rx_online_test_c ::run_phase", "END test...\n", UVM_LOW);

endtask : run_test

//------------------------------------------
task ca_tx_rx_online_test_c::chk_align_done();

     forever begin
        repeat(500)@(posedge vif.clk);
           // ALIGN_DONE is not asserted. because tx_online = 0 to DUT. So tx_state is in IDLE only. 
           // if align_done = 1, then tx_din = some valid values will be driven (.Traffic happened ). 
           // So checking align_done here to finish the test 
            if(ca_cfg.ca_die_a_tx_tb_out_cfg.align_done_assert == 0)  begin
               test_end = 1;  ////variable in base_test
            end
     end

endtask:chk_align_done

//------------------------------------------
////////////////////////////////////////////////////////////////
`endif
