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
// By varying both, stb_bit_sel as "not one hot encoded" value and
// stb_wd_sel as "outside the BUS_BITWIDTH", 
// stb_pos_coding_error and stb_pos_error in both tx and rx side will be achieved in this test case.
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_STROBE_ERROR_TEST_
`define _CA_STROBE_ERROR_TEST_
////////////////////////////////////////////////////////////

class ca_strobe_error_test_c extends base_ca_test_c;
 
    // UVM Factory Registration Macro
    `uvm_component_utils(ca_strobe_error_test_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    ca_seq_lib_c        ca_vseq;
    ca_traffic_seq_c    ca_traffic_seq;
    bit                 test_end_tx_a;
    bit                 test_end_tx_b;
    bit                 test_end_rx_a;
    bit                 test_end_rx_b;
    bit                 test_end_loc;
    int                 tx_stb_intv_bkp;
    // Component Members
    //------------------------------------------
 
    //------------------------------------------
    // Methods
    //------------------------------------------
 
    // Standard UVM Methods:
    extern function new(string name = "ca_strobe_error_test", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void start_of_simulation( );
    extern task chk_stb_error( );
    extern task strobe_err_clr_send_traffic( );
    extern task run_phase( uvm_phase phase);
    extern task run_test( uvm_phase phase );
 
endclass:ca_strobe_error_test_c
////////////////////////////////////////////////////////////

//------------------------------------------
function ca_strobe_error_test_c::new(string name = "ca_strobe_error_test", uvm_component parent = null);
    super.new(name, parent);
endfunction : new
 
//------------------------------------------
function void ca_strobe_error_test_c::build_phase( uvm_phase phase );
    // build in base test 
    super.build_phase(phase);
endfunction: build_phase

//------------------------------------------
function void ca_strobe_error_test_c::start_of_simulation( );
    //
endfunction: start_of_simulation
 
//------------------------------------------
// run phase 
task ca_strobe_error_test_c::run_phase(uvm_phase phase);

     ca_traffic_seq = ca_traffic_seq_c::type_id::create("ca_traffic_seq");

    fork
        run_test(phase);
        global_timer(); // and check for error count
        ck_eot(phase);
        chk_stb_error();
        strobe_err_clr_send_traffic();
    join

endtask : run_phase

//------------------------------------------
task ca_strobe_error_test_c::run_test(uvm_phase phase);

     bit result = 0;
    `uvm_info("ca_strobe_error_test ::run_phase", "START test...", UVM_LOW);
     ca_vseq        = ca_seq_lib_c::type_id::create("ca_vseq");
     ca_cfg.ca_die_a_tx_tb_in_cfg.align_error_afly0_test =   1;
     ca_cfg.ca_die_b_tx_tb_in_cfg.align_error_afly0_test =   1;
     ca_cfg.ca_die_a_rx_tb_in_cfg.align_error_afly0_test =   1;
     ca_cfg.ca_die_b_rx_tb_in_cfg.align_error_afly0_test =   1;

     ca_vseq.start(ca_top_env.virt_seqr);

    `uvm_info("ca_strobe_error_test ::run_phase", "wait_started for 1st drv_tfr_complete ..\n", UVM_LOW);
     wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
     `uvm_info("ca_strobe_error_test ::run_phase", "wait_ended for 1st drv_tfr_complete..\n", UVM_LOW);

     result =  ck_xfer_cnt_a(1);
     result =  ck_xfer_cnt_b(1);
     `uvm_info("ca_strobe_error_test ::run_phase", "SCOREBOARD comparison completed for first set of traffic ..\n", UVM_LOW);
     
     sbd_counts_clear(); 

      ca_cfg.ca_die_a_tx_tb_in_cfg.stb_error_test       = 1;
      ca_cfg.ca_die_b_tx_tb_in_cfg.stb_error_test       = 1;
      ca_cfg.ca_die_a_rx_tb_in_cfg.stb_error_test       = 1;
      ca_cfg.ca_die_b_rx_tb_in_cfg.stb_error_test       = 1;
      ca_cfg.ca_die_a_tx_tb_out_cfg.stb_error_test      = 1;
      ca_cfg.ca_die_b_tx_tb_out_cfg.stb_error_test      = 1;

    `uvm_info("ca_strobe_error_test::run_phase", "START test...", UVM_LOW);
     
      ca_cfg.ca_die_a_tx_tb_in_cfg.stop_monitor    =   1;
      ca_cfg.ca_die_b_tx_tb_in_cfg.stop_monitor    =   1;
      ca_cfg.ca_die_a_rx_tb_in_cfg.stop_monitor    =   1;
      ca_cfg.ca_die_b_rx_tb_in_cfg.stop_monitor    =   1;

      `uvm_info("ca_strobe_error_test ::run_phase", "stop_monitor = 1..\n", UVM_LOW);

          if(ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv > ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv) begin
             tx_stb_intv_bkp = ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv;
          end else begin
             tx_stb_intv_bkp = ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv;
          end
      `uvm_info("ca_strobe_error_test ::run_phase", $sformatf("tx_stb_intv_bkp = %0d..\n",tx_stb_intv_bkp), UVM_LOW);
 
       ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_wd_sel  = 4;  
       ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_wd_sel  = 4;
       ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_bit_sel = 3;
       ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_bit_sel = 3;
       ca_cfg.configure();

      `uvm_info("ca_strobe_error_test ::run_phase", "generate_stb_beat in SBD started ..\n", UVM_LOW);
       ca_top_env.ca_scoreboard.generate_stb_beat();
      `uvm_info("ca_strobe_error_test ::run_phase", "generate_stb_beat in SBD ended ..\n", UVM_LOW);

      `uvm_info("ca_strobe_error_test ::run_phase", "generate_stb_beat in TX_TB_IN_MON started ..\n", UVM_LOW);
       ca_top_env.ca_die_a_tx_tb_in_agent.mon.test_call_gen_stb_beat();
       ca_top_env.ca_die_b_tx_tb_in_agent.mon.test_call_gen_stb_beat();
      `uvm_info("ca_strobe_error_test ::run_phase", "generate_stb_beat in TX_TB_IN_MON ended ..\n", UVM_LOW);

      `uvm_info("ca_strobe_error_test ::run_phase", "generate_stb_beat in RX_TB_IN_MON started ..\n", UVM_LOW);
       ca_top_env.ca_die_a_rx_tb_in_agent.mon.test_call_gen_stb_beat();
       ca_top_env.ca_die_b_rx_tb_in_agent.mon.test_call_gen_stb_beat();
      `uvm_info("ca_strobe_error_test ::run_phase", "generate_stb_beat in RX_TB_IN_MON ended ..\n", UVM_LOW);

      `uvm_info("ca_strobe_error_test ::run_phase", "stop_monitor= 0..\n", UVM_LOW);
       ca_cfg.ca_die_a_tx_tb_in_cfg.stop_monitor     = 0;
       ca_cfg.ca_die_b_tx_tb_in_cfg.stop_monitor     = 0;
       ca_cfg.ca_die_a_rx_tb_in_cfg.stop_monitor     = 0;
       ca_cfg.ca_die_b_rx_tb_in_cfg.stop_monitor     = 0;

    `uvm_info("ca_strobe_error_test::run_phase", "ca_vseq startsss..\n", UVM_LOW);
     ca_traffic_seq.start(ca_top_env.virt_seqr);
    `uvm_info("ca_strobe_error_test::run_phase", "ca_vseq endsss...\n", UVM_LOW);
  endtask : run_test
 
//------------------------------------------
task ca_strobe_error_test_c::chk_stb_error();
     forever begin
        repeat(1)@(posedge vif.clk); 
          if((ca_cfg.ca_die_a_tx_tb_in_cfg.num_of_stb_error == 1) && (test_end_tx_a == 0)) test_end_tx_a = 1; 
          if((ca_cfg.ca_die_b_tx_tb_in_cfg.num_of_stb_error == 1) && (test_end_tx_b == 0)) test_end_tx_b = 1; 
          if((ca_cfg.ca_die_a_rx_tb_in_cfg.num_of_stb_error == 1) && (test_end_rx_a == 0)) test_end_rx_a = 1;
          if((ca_cfg.ca_die_b_rx_tb_in_cfg.num_of_stb_error == 1) && (test_end_rx_b == 0)) test_end_rx_b = 1;
              if((test_end_tx_a && test_end_tx_b && test_end_rx_a && test_end_rx_b) && (test_end_loc == 0)) begin
                test_end_loc = 1;  ////variable in base_test
                $display("inside_stb_error_test : %0d",test_end_loc);
              end
     end
endtask:chk_stb_error
 
//------------------------------------------
task ca_strobe_error_test_c::strobe_err_clr_send_traffic();
     bit result;

     wait(test_end_loc==1);
     ca_top_env.virt_seqr.stop_sequences();

     test_end_loc = 0;

     ca_cfg.ca_die_a_tx_tb_in_cfg.stop_monitor    =   1;
     ca_cfg.ca_die_b_tx_tb_in_cfg.stop_monitor    =   1;
     ca_cfg.ca_die_a_rx_tb_in_cfg.stop_monitor    =   1;
     ca_cfg.ca_die_b_rx_tb_in_cfg.stop_monitor    =   1;

      `uvm_info("ca_strobe_error_test ::run_phase", "stop_monitor = 1..\n", UVM_LOW);

          if(ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv > ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv) begin
             tx_stb_intv_bkp = ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv;
          end else begin
             tx_stb_intv_bkp = ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv;
          end
      `uvm_info("ca_strobe_error_test ::run_phase", $sformatf("tx_stb_intv_bkp = %0d..\n",tx_stb_intv_bkp), UVM_LOW);


    `uvm_info("error ca_tx_tb_out_cfg", $sformatf("bit_shift: %0d  tx_stb_bit_sel: %0h ",ca_cfg.ca_die_a_tx_tb_out_cfg.bit_shift,ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_bit_sel), UVM_LOW);
    `uvm_info("error ca_tx_tb_out_cfg", $sformatf("bit_shift: %0d  tx_stb_bit_sel: %0h ",ca_cfg.ca_die_a_tx_tb_out_cfg.bit_shift,ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_bit_sel), UVM_LOW);

     ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_bit_sel = 1;
     ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_bit_sel = 1;
     ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_wd_sel  = 1;
     ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_wd_sel  = 1;
     ca_cfg.configure();
    `uvm_info("actual ca_tx_tb_out_cfg", $sformatf("bit_shift: %0d  tx_stb_bit_sel: %0h ",ca_cfg.ca_die_a_tx_tb_out_cfg.bit_shift,ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_bit_sel), UVM_LOW);
    `uvm_info("actual ca_tx_tb_out_cfg", $sformatf("bit_shift: %0d  tx_stb_bit_sel: %0h ",ca_cfg.ca_die_a_tx_tb_out_cfg.bit_shift,ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_bit_sel), UVM_LOW);

      `uvm_info("ca_strobe_error_test ::run_phase", "generate_stb_beat in SBD started ..\n", UVM_LOW);
       ca_top_env.ca_scoreboard.generate_stb_beat();
      `uvm_info("ca_strobe_error_test ::run_phase", "generate_stb_beat in SBD ended ..\n", UVM_LOW);

      `uvm_info("ca_strobe_error_test ::run_phase", "generate_stb_beat in TX_TB_IN_MON started ..\n", UVM_LOW);
       ca_top_env.ca_die_a_tx_tb_in_agent.mon.test_call_gen_stb_beat();
       ca_top_env.ca_die_b_tx_tb_in_agent.mon.test_call_gen_stb_beat();
      `uvm_info("ca_strobe_error_test ::run_phase", "generate_stb_beat in TX_TB_IN_MON ended ..\n", UVM_LOW);

       repeat(tx_stb_intv_bkp)@ (posedge vif.clk); 
      `uvm_info("ca_strobe_error_test ::run_phase", "generate_stb_beat in RX_TB_IN_MON started ..\n", UVM_LOW);
       ca_top_env.ca_die_a_rx_tb_in_agent.mon.test_call_gen_stb_beat();
       ca_top_env.ca_die_b_rx_tb_in_agent.mon.test_call_gen_stb_beat();
      `uvm_info("ca_strobe_error_test ::run_phase", "generate_stb_beat in RX_TB_IN_MON ended ..\n", UVM_LOW);

      `uvm_info("ca_strobe_error_test ::run_phase", "stop_monitor= 0..\n", UVM_LOW);
       ca_cfg.ca_die_a_tx_tb_in_cfg.stop_monitor     = 0;
       ca_cfg.ca_die_b_tx_tb_in_cfg.stop_monitor     = 0;
       ca_cfg.ca_die_a_rx_tb_in_cfg.stop_monitor     = 0;
       ca_cfg.ca_die_b_rx_tb_in_cfg.stop_monitor     = 0;

       ca_cfg.ca_die_a_tx_tb_in_cfg.stb_error_test   = 0;
       ca_cfg.ca_die_b_tx_tb_in_cfg.stb_error_test   = 0;
       ca_cfg.ca_die_a_rx_tb_in_cfg.stb_error_test   = 0;
       ca_cfg.ca_die_b_rx_tb_in_cfg.stb_error_test   = 0;
       ca_cfg.ca_die_a_tx_tb_out_cfg.stb_error_test  = 0;
       ca_cfg.ca_die_b_tx_tb_out_cfg.stb_error_test  = 0;

     sbd_counts_clear();
 
    `uvm_info("ca_strobe_error_test_c::run_phase", "second ca_traffic_seq starts..\n", UVM_LOW);
     ca_traffic_seq.start(ca_top_env.virt_seqr);
    `uvm_info("ca_strobe_error_test_c::run_phase", "second ca_traffic_seq ends..\n", UVM_LOW);

     wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
    `uvm_info("ca_strobe_error_test_c::run_phase", "after_2nd drv_tfr_complete..\n", UVM_LOW);

     repeat(10)@ (posedge vif.clk);
     result =  ck_xfer_cnt_a(1);
     result =  ck_xfer_cnt_b(1);
     `uvm_info("ca_strobe_error_test ::run_phase", "SCOREBOARD comparison completed for second set of traffic ..\n", UVM_LOW);

     test_end = 1; 
   
    `uvm_info("ca_strobe_error_test::run_phase", "END test...\n", UVM_LOW);

endtask:strobe_err_clr_send_traffic

////////////////////////////////////////////////////////////////
`endif
