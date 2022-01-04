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
// sending traffic, During ongoing traffic,reset seq called 
// {configuring reset_low and then reset_high}
// sending traffic again check data comparison in SCB.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_RESET_DURING_TRAFFIC_TEST_
`define _CA_RESET_DURING_TRAFFIC_TEST_
////////////////////////////////////////////////////////////

class ca_reset_during_traffic_test_c extends base_ca_test_c;
 
    // UVM Factory Registration Macro
    `uvm_component_utils(ca_reset_during_traffic_test_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    ca_seq_lib_c         ca_vseq;
    ca_traffic_seq_c    ca_traffic_seq;
    bit[15:0]            tx_stb_intv;
    int                  tx_stb_intv_bkp;
    int                  bit_shift;
    bit                  start_traffic_after_reset;
    //------------------------------------------
    // Component Members
    //------------------------------------------
 
    //------------------------------------------
    // Methods
    //------------------------------------------
 
    // Standard UVM Methods:
    extern function new(string name = "ca_reset_during_traffic_test", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void start_of_simulation( );
    extern task run_phase( uvm_phase phase);
    extern task run_test( uvm_phase phase );
    extern task resume_traffic( );
 
endclass:ca_reset_during_traffic_test_c 
////////////////////////////////////////////////////////////

//------------------------------------------
function ca_reset_during_traffic_test_c::new(string name = "ca_reset_during_traffic_test", uvm_component parent = null);
    super.new(name, parent);
endfunction : new
 
//------------------------------------------
function void ca_reset_during_traffic_test_c::build_phase( uvm_phase phase );
    // build in base test 
    super.build_phase(phase);
endfunction: build_phase

//------------------------------------------
function void ca_reset_during_traffic_test_c::start_of_simulation( );
    //
endfunction: start_of_simulation 
 
//------------------------------------------
// run phase 
task ca_reset_during_traffic_test_c::run_phase(uvm_phase phase);
    fork
        run_test(phase);
        global_timer(); // and check for error count
        ck_eot(phase);
        resume_traffic();
    join
endtask : run_phase

//------------------------------------------
task ca_reset_during_traffic_test_c::run_test(uvm_phase phase);

      bit result = 0;

      `uvm_info("ca_reset_during_traffic_test ::run_phase", "START test...", UVM_LOW);
      ca_vseq          = ca_seq_lib_c::type_id::create("ca_vseq");
      ca_traffic_seq   = ca_traffic_seq_c::type_id::create("ca_traffic_seq");
      fork
          begin
              `uvm_info("ca_reset_during_traffic_test ::run_phase", "first_ca_vseq started  ..\n", UVM_LOW);
              ca_vseq.start(ca_top_env.virt_seqr);
              `uvm_info("ca_reset_during_traffic_test ::run_phase", "first_ca_vseq ended  ..\n", UVM_LOW);
          end
          begin
              wait(ca_cfg.ca_die_a_tx_tb_out_cfg.align_done_assert == 1);
              `uvm_info("ca_reset_during_traffic_test ::run_phase", "align_done_assert entered  ..\n", UVM_LOW);
              repeat(50)@ (posedge vif.clk);
              vif.reset_l =1'b0;  //assert reset
              `uvm_info("ca_reset_during_traffic_test ::run_phase", "reset_low   ..\n", UVM_LOW);
              ca_top_env.virt_seqr.stop_sequences();
              `uvm_info("ca_reset_during_traffic_test ::run_phase", "wait_of_50_clk ended  ..\n", UVM_LOW);

              sbd_counts_clear();
              //After some clockss/ some transfer packets,we can stop comparison, to configure reset_low
              ca_top_env.ca_scoreboard.do_compare          =   0;
              ca_cfg.ca_die_a_tx_tb_in_cfg.stop_monitor    =   1;
              ca_cfg.ca_die_b_tx_tb_in_cfg.stop_monitor    =   1;
              ca_cfg.ca_die_a_rx_tb_in_cfg.stop_monitor    =   1;
              ca_cfg.ca_die_b_rx_tb_in_cfg.stop_monitor    =   1;

              `uvm_info("ca_reset_during_traffic_test ::run_phase", "SBD counts cleared,comparison stopped ..\n", UVM_LOW);
               repeat(50)@ (posedge vif.clk);
               `uvm_info("ca_reset_during_traffic_test ::run_phase", "reset_high   ..\n", UVM_LOW);
                vif.reset_l =1'b1;  //de-assert reset
               start_traffic_after_reset = 1;     
         end
     join_none
 
endtask : run_test
    
//------------------------------------------
task ca_reset_during_traffic_test_c::resume_traffic();

     bit result = 0;

       wait(start_traffic_after_reset ==1);     
       `uvm_info("ca_reset_during_traffic_test ::resume_traffic ", "start_traffic_after_reset..\n", UVM_LOW);
       ca_top_env.ca_scoreboard.do_compare          =   1;
       ca_cfg.ca_die_a_tx_tb_in_cfg.stop_monitor    =   0;
       ca_cfg.ca_die_b_tx_tb_in_cfg.stop_monitor    =   0;
       ca_cfg.ca_die_a_rx_tb_in_cfg.stop_monitor    =   0;
       ca_cfg.ca_die_b_rx_tb_in_cfg.stop_monitor    =   0;
       `uvm_info("ca_reset_during_traffic_test ::resume_traffic ", "second_ca_vseq started  ..\n", UVM_LOW);
        ca_traffic_seq.start(ca_top_env.virt_seqr);
       `uvm_info("ca_reset_during_traffic_test ::resume_traffic ", "second_ca_vseq ended ..\n", UVM_LOW);

      `uvm_info("ca_reset_during_traffic_test ::resume_traffic ", "wait_started for second drv_tfr_complete ..\n", UVM_LOW);
       wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
      `uvm_info("ca_reset_during_traffic_test ::resume_traffic ", "wait_ended for second drv_tfr_complete ..\n", UVM_LOW);

       repeat(10)@ (posedge vif.clk);
       result =  ck_xfer_cnt_a(1);
       result =  ck_xfer_cnt_b(1);
      `uvm_info("ca_reset_during_traffic_test ::resume_traffic ", "SCOREBOARD comparison completed for second set of traffic ..\n", UVM_LOW);
       repeat(20)@ (posedge vif.clk);

       test_end = 1; 
      `uvm_info("ca_reset_during_traffic_test ::resume_traffic ", "END test...\n", UVM_LOW);

endtask :resume_traffic 
////////////////////////////////////////////////////////////////
`endif
