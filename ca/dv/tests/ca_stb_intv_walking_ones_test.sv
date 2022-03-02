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
// TEST CASE Description 
// walking 1s of tx_stb_intv from 7th bt to 15thbit (0to 6th bit covered already )
// verified in this test case. 
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_STB_INTV_WALKING_ONES_TEST_
`define _CA_STB_INTV_WALKING_ONES_TEST_
////////////////////////////////////////////////////////////

class ca_stb_intv_walking_ones_test_c extends base_ca_test_c;
 
    // UVM Factory Registration Macro
    `uvm_component_utils(ca_stb_intv_walking_ones_test_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    ca_seq_lib_c          ca_vseq;
    ca_traffic_seq_c      ca_traffic_seq;
    ca_knobs_stb_intv_c   ca_knobs_stb_intv;
 
    //------------------------------------------
    // Component Members
    //------------------------------------------
 
    //------------------------------------------
    // Methods
    //------------------------------------------
 
    // Standard UVM Methods:
    extern function new(string name = "ca_stb_intv_walking_ones_test", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void start_of_simulation( );
    extern task run_phase( uvm_phase phase);
    extern task run_test( uvm_phase phase );


endclass:ca_stb_intv_walking_ones_test_c 
////////////////////////////////////////////////////////////

//------------------------------------------
function ca_stb_intv_walking_ones_test_c::new(string name = "ca_stb_intv_walking_ones_test", uvm_component parent = null);
      super.new(name, parent);
      ca_knobs_stb_intv                = ca_knobs_stb_intv_c::type_id::create("ca_knobs_stb_intv");
      if(!(ca_knobs_stb_intv.randomize())) `uvm_fatal("CA_CFG", $sformatf("ca_knobs_stb_intv randomize FAILED !!"));
endfunction : new
 
//------------------------------------------
function void ca_stb_intv_walking_ones_test_c::build_phase( uvm_phase phase );
    // build in base test 
    super.build_phase(phase);
endfunction: build_phase

//------------------------------------------
function void ca_stb_intv_walking_ones_test_c::start_of_simulation( );
    //
endfunction: start_of_simulation 
 
//------------------------------------------
// run phase 
task ca_stb_intv_walking_ones_test_c::run_phase(uvm_phase phase);

    fork
        run_test(phase);
        global_timer(); // and check for error count
        ck_eot(phase);
    join

endtask : run_phase

//------------------------------------------
task ca_stb_intv_walking_ones_test_c::run_test(uvm_phase phase);

    bit result = 0;

    `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", "START test...", UVM_LOW);
    ca_vseq        = ca_seq_lib_c::type_id::create("ca_vseq");
    ca_traffic_seq = ca_traffic_seq_c::type_id::create("ca_traffic_seq");

    ca_cfg.ca_knobs.tx_xfer_cnt_die_a = 65500;
    ca_cfg.ca_knobs.tx_xfer_cnt_die_b = 65500;

    ca_vseq.start(ca_top_env.virt_seqr); //stb_bit_sel = 0 by default 

    `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", "wait_started for 1st drv_tfr_complete ..\n", UVM_LOW);
    wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
    `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", "after_1st drv_tfr_complete..\n", UVM_LOW);

    repeat(10)@ (posedge vif.clk);
    result =  ck_xfer_cnt_a(1);
    result =  ck_xfer_cnt_b(1);
    `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", "SCOREBOARD COMPARISON FIRST SET COMPLETED..\n", UVM_LOW);
    
    ca_cfg.override_align_done_timeout = 1; //In high iteration test cases, align_done timeout should not be 60us.so overide timout here.  
    for(int i=7;i<=16;i++) begin 
       
        if (i<=15) begin
          repeat(50)@ (posedge vif.clk);
          vif.reset_l =1'b0;  //assert reset
          `uvm_info("ca_stb_wd_sel_test ::run_phase", "reset_LOW   ..\n", UVM_LOW);
          repeat(10)@ (posedge vif.clk);

          ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv    = 'h0;
          ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv    = 'h0;

          ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv[i] = 1'b1;
          ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv[i] = 1'b1;
          ca_cfg.configure();

          repeat(50)@ (posedge vif.clk);
          vif.reset_l =1'b1;  //de-assert reset
          `uvm_info("ca_stb_wd_sel_test ::run_phase", "reset_HIGH   ..\n", UVM_LOW);
          sbd_counts_clear(); 

          gen_if.second_traffic_seq = 1; //new_stb_params_cfg

          ca_cfg.ca_die_a_tx_tb_out_cfg.stop_monitor     =   1;
          ca_cfg.ca_die_b_tx_tb_out_cfg.stop_monitor     =   1;
          ca_cfg.ca_die_a_tx_tb_in_cfg.stop_monitor      =   1;
          ca_cfg.ca_die_b_tx_tb_in_cfg.stop_monitor      =   1;
          ca_cfg.ca_die_a_rx_tb_in_cfg.stop_monitor      =   1;
          ca_cfg.ca_die_b_rx_tb_in_cfg.stop_monitor      =   1;

          ca_top_env.ca_scoreboard.generate_stb_beat();
          `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", "generate_stb_beat in SBD ended ..\n", UVM_LOW);

          `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", "generate_stb_beat in TX_TB_OUT_MON started ..\n", UVM_LOW);
          ca_top_env.ca_die_a_tx_tb_out_agent.mon.clr_strobe_params();
          ca_top_env.ca_die_b_tx_tb_out_agent.mon.clr_strobe_params();
          `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", "generate_stb_beat in TX_TB_OUT_MON ended ..\n", UVM_LOW);

          `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", "generate_stb_beat in TX_TB_IN_MON started ..\n", UVM_LOW);
          ca_top_env.ca_die_a_tx_tb_in_agent.mon.test_call_gen_stb_beat();
          ca_top_env.ca_die_b_tx_tb_in_agent.mon.test_call_gen_stb_beat();
          `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", "generate_stb_beat in TX_TB_IN_MON ended ..\n", UVM_LOW);

          if(ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv > ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv) begin
              tx_stb_intv_bkp = ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv;
          end else begin
              tx_stb_intv_bkp = ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv;
          end
          `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", $sformatf("tx_stb_intv_bkp = %0d..\n",tx_stb_intv_bkp), UVM_LOW);

          `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", "tx_stb_intv_bkp_wait started..\n", UVM_LOW);
          repeat(tx_stb_intv_bkp) @(posedge vif.clk);
          `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", "tx_stb_intv_bkp_wait ended..\n", UVM_LOW);

          `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", "generate_stb_beat in RX_TB_IN_MON started ..\n", UVM_LOW);
          ca_top_env.ca_die_a_rx_tb_in_agent.mon.test_call_gen_stb_beat();
          ca_top_env.ca_die_b_rx_tb_in_agent.mon.test_call_gen_stb_beat();
          `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", "generate_stb_beat in RX_TB_IN_MON ended ..\n", UVM_LOW);

           //user_marker will be updated after some clocks
           repeat(20)@ (posedge vif.clk);

          `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", "stop_monitor= 0..\n", UVM_LOW);
          ca_cfg.ca_die_a_tx_tb_out_cfg.stop_monitor   =   0;
          ca_cfg.ca_die_b_tx_tb_out_cfg.stop_monitor   =   0;
          ca_cfg.ca_die_a_tx_tb_in_cfg.stop_monitor    =   0;
          ca_cfg.ca_die_b_tx_tb_in_cfg.stop_monitor    =   0;
          ca_cfg.ca_die_a_rx_tb_in_cfg.stop_monitor    =   0;
          ca_cfg.ca_die_b_rx_tb_in_cfg.stop_monitor    =   0;

          ca_traffic_seq.start(ca_top_env.virt_seqr);
          `uvm_info("*************************ca_stb_intv_walking_ones_test ::run_phase", "ca_traffic_seq ends..\n", UVM_LOW);

          `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", "wait_started for 2nd drv_tfr_complete ..\n", UVM_LOW);
           wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
          `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", "after_2nd drv_tfr_complete..\n", UVM_LOW);

          repeat(10)@ (posedge vif.clk);
          result =  ck_xfer_cnt_a(1);
          result =  ck_xfer_cnt_b(1);
          `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", $sformatf("SCOREBOARD COMPARISON COMPLETED FOR i == %0d th stb_bit_sel", i), UVM_LOW);
          repeat(150)@ (posedge vif.clk); 
        end else begin //i == 16 Just for toggle coverage 
            ca_cfg.ca_die_a_tx_tb_out_cfg.stop_monitor     =   1;
            ca_cfg.ca_die_b_tx_tb_out_cfg.stop_monitor     =   1;
            ca_cfg.ca_die_a_tx_tb_in_cfg.stop_monitor      =   1;
            ca_cfg.ca_die_b_tx_tb_in_cfg.stop_monitor      =   1;
            ca_cfg.ca_die_a_rx_tb_in_cfg.stop_monitor      =   1;
            ca_cfg.ca_die_b_rx_tb_in_cfg.stop_monitor      =   1;
            // repeat(50)@ (posedge vif.clk);
             ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv    = 'h0;
             ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv    = 'h0;
             ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv[3] = 1'b1;
             ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv[3] = 1'b1;
             ca_cfg.configure();
             sbd_counts_clear(); 
        end //if 
    end //for
     test_end = 1; 
     `uvm_info("ca_stb_intv_walking_ones_test ::run_phase", "END test...\n", UVM_LOW);

endtask : run_test
////////////////////////////////////////////////////////////////
`endif
