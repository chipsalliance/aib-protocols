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
// align_fly = 1 , tx_stb_intv  changes from one value to other value
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_AFLY1_STB_INTV_TEST_
`define _CA_AFLY1_STB_INTV_TEST_
////////////////////////////////////////////////////////////

class ca_afly1_stb_intv_variations_test_c extends base_ca_test_c;
 
    // UVM Factory Registration Macro
    `uvm_component_utils(ca_afly1_stb_intv_variations_test_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    ca_seq_lib_c        ca_vseq;
    ca_traffic_seq_c    ca_traffic_seq;
    rand bit[7:0]       tx_stb_intv[255];
 
    //------------------------------------------
    // Component Members
    //------------------------------------------
 
    //------------------------------------------
    // Methods
    //------------------------------------------
 
    // Standard UVM Methods:
    extern function new(string name = "ca_afly1_stb_intv_variations_test", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void start_of_simulation( );
    extern task run_phase( uvm_phase phase);
    extern task run_test( uvm_phase phase );
 
endclass:ca_afly1_stb_intv_variations_test_c 
////////////////////////////////////////////////////////////

//------------------------------------------
function ca_afly1_stb_intv_variations_test_c::new(string name = "ca_afly1_stb_intv_variations_test", uvm_component parent = null);
    super.new(name, parent);
endfunction : new
 
//------------------------------------------
function void ca_afly1_stb_intv_variations_test_c::build_phase( uvm_phase phase );
    // build in base test 
    super.build_phase(phase);
endfunction: build_phase

//------------------------------------------
function void ca_afly1_stb_intv_variations_test_c::start_of_simulation( );
    //
endfunction: start_of_simulation 
 
//------------------------------------------
// run phase 
task ca_afly1_stb_intv_variations_test_c::run_phase(uvm_phase phase);
    fork
        run_test(phase);
        global_timer(); // and check for error count
        ck_eot(phase);
    join
endtask : run_phase

//------------------------------------------
task ca_afly1_stb_intv_variations_test_c::run_test(uvm_phase phase);

     bit result = 0;

     `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "START test...", UVM_LOW);
     ca_cfg.ca_die_a_rx_tb_in_cfg.align_fly  = 1;
     ca_cfg.ca_die_b_rx_tb_in_cfg.align_fly  = 1;
     ca_vseq        = ca_seq_lib_c::type_id::create("ca_vseq");
     ca_traffic_seq = ca_traffic_seq_c::type_id::create("ca_traffic_seq");

     ca_vseq.start(ca_top_env.virt_seqr);

     `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "wait_started for 1st drv_tfr_complete ..\n", UVM_LOW);
     wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
     `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "wait_ended for 1st drv_tfr_complete..\n", UVM_LOW);

     result =  ck_xfer_cnt_a(1);
     result =  ck_xfer_cnt_b(1);
     `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "SCOREBOARD comparison completed for first set of traffic ..\n", UVM_LOW);

     repeat(20)@ (posedge vif.clk);
   //  foreach (tx_stb_intv[i]) begin
   //     if(i >= 20)  tx_stb_intv[i] = i;  
   //  end
   ////// ++++++++++++++++++++++++ another value for stb_intv++++++++++++++++++++ ////
   //   tx_stb_intv.shuffle();
   //   foreach(tx_stb_intv[i])begin
   //       ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv    =  tx_stb_intv[i];
   //       ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv    =  tx_stb_intv[i];
   //   end 
          ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv    =  $urandom_range(65, 100);
          ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv    =  $urandom_range(70, 120);
      ca_cfg.configure();

      `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase",$sformatf("tx_stb_intv = %h,tx_stb_bit_sel= %h,tx_stb_wd_sel=%h configured..\n", ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv,ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_bit_sel,ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_wd_sel),UVM_LOW);
      `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase",$sformatf("tx_stb_intv = %h,tx_stb_bit_sel= %h,tx_stb_wd_sel=%h configured..\n", ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv,ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_bit_sel,ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_wd_sel),UVM_LOW);

      sbd_counts_clear();

      `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "ca_traffic_seq started ..\n", UVM_LOW);
       //ca_traffic_seq.start(ca_top_env.virt_seqr);
       ca_vseq.start(ca_top_env.virt_seqr);
      `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "ca_traffic_seq ended ..\n", UVM_LOW);

      `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "wait_started for second drv_tfr_complete ..\n", UVM_LOW);
       wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
      `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "wait_ended for second drv_tfr_complete ..\n", UVM_LOW);

       repeat(10)@ (posedge vif.clk);
       result =  ck_xfer_cnt_a(1);
       result =  ck_xfer_cnt_b(1);
      `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "SCOREBOARD comparison completed for second set of traffic ..\n", UVM_LOW);

       test_end = 1; 
      `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "END test...\n", UVM_LOW);

endtask : run_test
////////////////////////////////////////////////////////////////
`endif
