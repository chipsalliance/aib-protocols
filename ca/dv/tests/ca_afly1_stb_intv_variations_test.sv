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
// {align_fly = 1}, tx_stb_intv value randomized in this test case.
// Traffic ( tx_stb_intv as per sailrock) => Traffic ( randomized value of tx_stb_intv ) 

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
     ca_cfg.ca_die_a_tx_tb_in_cfg.stop_stb_checker    =   1;
     ca_cfg.ca_die_b_tx_tb_in_cfg.stop_stb_checker    =   1;
     ca_cfg.ca_die_a_rx_tb_in_cfg.stop_stb_checker    =   1;
     ca_cfg.ca_die_b_rx_tb_in_cfg.stop_stb_checker    =   1;

     ca_cfg.ca_die_a_rx_tb_in_cfg.align_fly           =   1;
     ca_cfg.ca_die_b_rx_tb_in_cfg.align_fly           =   1;

     ca_vseq        = ca_seq_lib_c::type_id::create("ca_vseq");
     ca_traffic_seq = ca_traffic_seq_c::type_id::create("ca_traffic_seq");

     ca_vseq.start(ca_top_env.virt_seqr);

     `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "wait_started for 1st drv_tfr_complete ..\n", UVM_LOW);
     wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
     `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "wait_ended for 1st drv_tfr_complete..\n", UVM_LOW);

     result =  ck_xfer_cnt_a(1);
     result =  ck_xfer_cnt_b(1);
     `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "SCOREBOARD comparison completed for first set of traffic ..\n", UVM_LOW);

        sbd_counts_clear();
        ca_cfg.ca_die_a_tx_tb_out_cfg.stop_monitor     =   1;
        ca_cfg.ca_die_a_tx_tb_out_cfg.stop_monitor     =   1;
        ca_cfg.ca_die_b_tx_tb_in_cfg.stop_monitor      =   1;
        ca_cfg.ca_die_b_tx_tb_in_cfg.stop_monitor      =   1;
        ca_cfg.ca_die_a_rx_tb_in_cfg.stop_monitor      =   1;
        ca_cfg.ca_die_b_rx_tb_in_cfg.stop_monitor      =   1;

        gen_if.second_traffic_seq = 1; //new_stb_params_cfg

        repeat(50)@ (posedge vif.clk);
        vif.reset_l =1'b0;  //assert reset
        `uvm_info("ca_stb_wd_sel_test ::run_phase", "reset_LOW   ..\n", UVM_LOW);
        repeat(10)@ (posedge vif.clk);

        ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv      =  $urandom_range(100, 250);
        ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv      =  $urandom_range(100, 250);
        ca_cfg.configure();

       `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase",$sformatf("DIE_A tx_stb_intv = %h configured..\n", ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv),UVM_LOW);
       `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase",$sformatf("DIE_B tx_stb_intv = %h configured..\n", ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv),UVM_LOW);

        repeat(50)@ (posedge vif.clk);
        vif.reset_l =1'b1;  //de-assert reset
       `uvm_info("ca_stb_wd_sel_test ::run_phase", "reset_HIGH   ..\n", UVM_LOW);

       `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "generate_stb_beat in SBD started ..\n", UVM_LOW);
        ca_top_env.ca_scoreboard.generate_stb_beat();
       `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "generate_stb_beat in SBD ended ..\n", UVM_LOW);

       `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "generate_stb_beat in TX_TB_OUT_MON started ..\n", UVM_LOW);
        ca_top_env.ca_die_a_tx_tb_out_agent.mon.clr_strobe_params();
        ca_top_env.ca_die_b_tx_tb_out_agent.mon.clr_strobe_params();
       `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "generate_stb_beat in TX_TB_OUT_MON ended ..\n", UVM_LOW);

       `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "generate_stb_beat in TX_TB_IN_MON started ..\n", UVM_LOW);
        ca_top_env.ca_die_a_tx_tb_in_agent.mon.test_call_gen_stb_beat();
        ca_top_env.ca_die_b_tx_tb_in_agent.mon.test_call_gen_stb_beat();
       `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "generate_stb_beat in TX_TB_IN_MON ended ..\n", UVM_LOW);

          if(ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv > ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv) begin
             tx_stb_intv_bkp = ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv;
          end else begin
             tx_stb_intv_bkp = ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv;
          end

      `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", $sformatf("tx_stb_intv_bkp = %0d..\n",tx_stb_intv_bkp), UVM_LOW);

      `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "tx_stb_intv_bkp_wait started..\n", UVM_LOW);
       repeat(4*tx_stb_intv_bkp)@ (posedge vif.clk);
      `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "tx_stb_intv_bkp_wait ended..\n", UVM_LOW);

      `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "generate_stb_beat in RX_TB_IN_MON started ..\n", UVM_LOW);
       ca_top_env.ca_die_a_rx_tb_in_agent.mon.test_call_gen_stb_beat();
       ca_top_env.ca_die_b_rx_tb_in_agent.mon.test_call_gen_stb_beat();
      `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "generate_stb_beat in RX_TB_IN_MON ended ..\n", UVM_LOW);

      `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "stop_monitor= 0..\n", UVM_LOW);
       ca_cfg.ca_die_a_tx_tb_out_cfg.stop_monitor   =   0;
       ca_cfg.ca_die_a_tx_tb_out_cfg.stop_monitor   =   0;
       ca_cfg.ca_die_b_tx_tb_in_cfg.stop_monitor    =   0;
       ca_cfg.ca_die_b_tx_tb_in_cfg.stop_monitor    =   0;
       ca_cfg.ca_die_a_rx_tb_in_cfg.stop_monitor    =   0;
       ca_cfg.ca_die_b_rx_tb_in_cfg.stop_monitor    =   0;

      `uvm_info("ca_afly1_stb_intv_variations_test ::run_phase", "ca_traffic_seq started ..\n", UVM_LOW);
       ca_traffic_seq.start(ca_top_env.virt_seqr);
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
