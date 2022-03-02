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
// Functional Description: Channel Alignment Testbench File
// delay_x,xz values randomized in this test case
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_DEALY_X_XZ_VALUE_TEST_
`define _CA_DEALY_X_XZ_VALUE_TEST_
////////////////////////////////////////////////////////////

class ca_delay_x_xz_values_test_c extends base_ca_test_c;
 
    // UVM Factory Registration Macro
    `uvm_component_utils(ca_delay_x_xz_values_test_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    ca_seq_lib_c        ca_vseq;
    ca_traffic_seq_c    ca_traffic_seq;
    int                 delay_xz_value; 
    int                 delay_x_value; 
    //------------------------------------------
    // Component Members
    //------------------------------------------
 
    //------------------------------------------
    // Methods
    //------------------------------------------
 
    // Standard UVM Methods:
    extern function new(string name = "ca_delay_x_xz_values_test", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void start_of_simulation( );
    extern task run_phase( uvm_phase phase);
    extern task run_test( uvm_phase phase );

endclass:ca_delay_x_xz_values_test_c 
////////////////////////////////////////////////////////////

//------------------------------------------
function ca_delay_x_xz_values_test_c::new(string name = "ca_delay_x_xz_values_test", uvm_component parent = null);
    super.new(name, parent);
endfunction : new
 
//------------------------------------------
function void ca_delay_x_xz_values_test_c::build_phase( uvm_phase phase );
    // build in base test 
    super.build_phase(phase);
endfunction: build_phase

//------------------------------------------
function void ca_delay_x_xz_values_test_c::start_of_simulation( );
    //
endfunction: start_of_simulation 
 
//------------------------------------------
// run phase 
task ca_delay_x_xz_values_test_c::run_phase(uvm_phase phase);

    fork
        run_test(phase);
        global_timer(); // and check for error count
        ck_eot(phase);
    join

endtask : run_phase

//------------------------------------------
task ca_delay_x_xz_values_test_c::run_test(uvm_phase phase);

       bit result = 0;
  
       `uvm_info("ca_delay_x_xz_values_test ::run_phase", "START test...", UVM_LOW);
  
       ca_cfg.ca_die_a_tx_tb_in_cfg.stop_stb_checker    =   1; 
       ca_cfg.ca_die_b_tx_tb_in_cfg.stop_stb_checker    =   1;
       ca_cfg.ca_die_a_rx_tb_in_cfg.stop_stb_checker    =   1;
       ca_cfg.ca_die_b_rx_tb_in_cfg.stop_stb_checker    =   1;
  
       ca_vseq        = ca_seq_lib_c::type_id::create("ca_vseq");
       ca_traffic_seq = ca_traffic_seq_c::type_id::create("ca_traffic_seq");
  
       ca_vseq.start(ca_top_env.virt_seqr); 

      `uvm_info("ca_delay_x_xz_values_test ::run_phase", "wait_started for drv_tfr_complete ..\n", UVM_LOW);
       wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
      `uvm_info("ca_delay_x_xz_values_test ::run_phase", "after_1st drv_tfr_complete..\n", UVM_LOW);

       result =  ck_xfer_cnt_a(1);
       result =  ck_xfer_cnt_b(1);
      `uvm_info("ca_delay_x_xz_values_test ::run_phase", "SCOREBOARD COMPARISON FIRST SET COMPLETED..\n", UVM_LOW);

       repeat(20)@ (posedge vif.clk);
       sbd_counts_clear();

    ///////////////////////////////////////////////////////////////////
    for(int i=21;i<31;i++) begin 
         vif.reset_l         = 1'b0; /////assert reset to CA
         gen_if.delay_xz_value      =  i*$urandom_range(30,(i*20));
         delay_x_value       =  gen_if.delay_xz_value/8;

        // $display("\n TEST::X=%0d  Z=%0d  at %0t",delay_x_value,gen_if.delay_xz_value,$time);

         ca_cfg.ca_die_a_rx_tb_in_cfg.delay_x_value  = delay_x_value;
         ca_cfg.ca_die_a_rx_tb_in_cfg.delay_xz_value = gen_if.delay_xz_value;

         ca_cfg.ca_die_b_rx_tb_in_cfg.delay_x_value  = delay_x_value;
         ca_cfg.ca_die_b_rx_tb_in_cfg.delay_xz_value = gen_if.delay_xz_value;

         sbd_counts_clear();
         ca_cfg.ca_die_a_tx_tb_out_cfg.stop_monitor     =   1;
         ca_cfg.ca_die_b_tx_tb_out_cfg.stop_monitor     =   1;
         ca_cfg.ca_die_a_tx_tb_in_cfg.stop_monitor      =   1;
         ca_cfg.ca_die_b_tx_tb_in_cfg.stop_monitor      =   1;
         ca_cfg.ca_die_a_rx_tb_in_cfg.stop_monitor      =   1;
         ca_cfg.ca_die_b_rx_tb_in_cfg.stop_monitor      =   1;

         gen_if.second_traffic_seq = 1;

         ca_top_env.ca_scoreboard.generate_stb_beat();
         `uvm_info("ca_delay_x_xz_values_test ::run_phase", "generate_stb_beat in SBD ended ..\n", UVM_LOW);

         `uvm_info("ca_delay_x_xz_values_test::run_phase", "generate_stb_beat in TX_TB_OUT_MON started ..\n", UVM_LOW);
          ca_top_env.ca_die_a_tx_tb_out_agent.mon.clr_strobe_params();
          ca_top_env.ca_die_b_tx_tb_out_agent.mon.clr_strobe_params();
         `uvm_info("ca_delay_x_xz_values_test::run_phase", "generate_stb_beat in TX_TB_OUT_MON ended ..\n", UVM_LOW);

         `uvm_info("ca_delay_x_xz_values_test ::run_phase", "generate_stb_beat in TX_TB_IN_MON started ..\n", UVM_LOW);
         ca_top_env.ca_die_a_tx_tb_in_agent.mon.test_call_gen_stb_beat();
         ca_top_env.ca_die_b_tx_tb_in_agent.mon.test_call_gen_stb_beat();
         `uvm_info("ca_delay_x_xz_values_test ::run_phase", "generate_stb_beat in TX_TB_IN_MON ended ..\n", UVM_LOW);

         if(ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv > ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv) begin
             tx_stb_intv_bkp = ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv;
         end else begin
             tx_stb_intv_bkp = ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv;
         end
         `uvm_info("ca_delay_x_xz_values_test ::run_phase", $sformatf("tx_stb_intv_bkp = %0d..\n",tx_stb_intv_bkp), UVM_LOW);

         `uvm_info("ca_delay_x_xz_values_test ::run_phase", "tx_stb_intv_bkp_wait started..\n", UVM_LOW);
         repeat(4*tx_stb_intv_bkp) @(posedge vif.clk);
         `uvm_info("ca_delay_x_xz_values_test ::run_phase", "tx_stb_intv_bkp_wait ended..\n", UVM_LOW);

         `uvm_info("ca_delay_x_xz_values_test::run_phase", "generate_stb_beat in RX_TB_IN_MON started ..\n", UVM_LOW);
         ca_top_env.ca_die_a_rx_tb_in_agent.mon.test_call_gen_stb_beat();
         ca_top_env.ca_die_b_rx_tb_in_agent.mon.test_call_gen_stb_beat();
         `uvm_info("ca_delay_x_xz_values_test::run_phase", "generate_stb_beat in RX_TB_IN_MON ended ..\n", UVM_LOW);
         //user_marker will be updated after some clocks
         repeat(20)@ (posedge vif.clk);

         `uvm_info("ca_delay_x_xz_values_test ::run_phase", "stop_monitor= 0..\n", UVM_LOW);
         ca_cfg.ca_die_a_tx_tb_out_cfg.stop_monitor   =   0;
         ca_cfg.ca_die_b_tx_tb_out_cfg.stop_monitor   =   0;
         ca_cfg.ca_die_a_tx_tb_in_cfg.stop_monitor    =   0;
         ca_cfg.ca_die_b_tx_tb_in_cfg.stop_monitor    =   0;
         ca_cfg.ca_die_a_rx_tb_in_cfg.stop_monitor    =   0;
         ca_cfg.ca_die_b_rx_tb_in_cfg.stop_monitor    =   0;

         //ca_traffic_seq.start(ca_top_env.virt_seqr);
         `uvm_info("ca_delay_x_xz_values_test ::run_phase", "second ca_traffic_seq starts..\n", UVM_LOW);
          ca_vseq.start(ca_top_env.virt_seqr);  ////helps de-assert reset_l
         `uvm_info("ca_delay_x_xz_values_test ::run_phase", "second ca_traffic_seq ends..\n", UVM_LOW);

        `uvm_info("ca_delay_x_xz_values_test ::run_phase", "wait started after_2nd drv_tfr_complete..\n", UVM_LOW);
         wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1);//will be updated by Scoreboard 
        `uvm_info("ca_delay_x_xz_values_test ::run_phase", "wait ended after_2nd drv_tfr_complete..\n", UVM_LOW);

        repeat(10)@ (posedge vif.clk);
        result =  ck_xfer_cnt_a(1);
        result =  ck_xfer_cnt_b(1);
        `uvm_info("ca_delay_x_xz_values_test ::run_phase", "SCOREBOARD COMPARISON FOR SECOND SET COMPLETED..\n", UVM_LOW);

        repeat(100)@ (posedge vif.clk);
        ca_cfg.ca_die_a_rx_tb_in_cfg.delay_x_value  = 0;
        ca_cfg.ca_die_a_rx_tb_in_cfg.delay_xz_value = 4;
        ca_cfg.ca_die_b_rx_tb_in_cfg.delay_xz_value = 4;
        ca_cfg.ca_die_b_rx_tb_in_cfg.delay_x_value  = 0;
        repeat(2)@ (posedge vif.clk);
    end//for i
    test_end = 1; 
    `uvm_info("ca_delay_x_xz_values_test ::run_phase", "END test...\n", UVM_LOW);
endtask : run_test

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`endif
