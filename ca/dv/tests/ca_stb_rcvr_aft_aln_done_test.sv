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
// TEST_CASE DESCRIPTION
// tx_stb_rcvr = 0 ,after align_done tx_stb_rcvr changed to  1.
// {tx_stb_rcvr 0-1-0 toggle coverage achieved} 
// {tx_state changed to TX_DONE state in this test case}
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_STB_RCVR_AFT_ALN_DONE_TEST_
`define _CA_STB_RCVR_AFT_ALN_DONE_TEST_
////////////////////////////////////////////////////////////

class ca_stb_rcvr_aft_aln_done_test_c extends base_ca_test_c;
 
    // UVM Factory Registration Macro
    `uvm_component_utils(ca_stb_rcvr_aft_aln_done_test_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    ca_seq_lib_c       ca_vseq;
    ca_traffic_seq_c   ca_traffic_seq;
    bit                tx_stb_rcvr_to_be_enb_diea; 
    bit                tx_stb_rcvr_to_be_enb_dieb; 
    //------------------------------------------
    // Component Members
    //------------------------------------------
 
    //------------------------------------------
    // Methods
    //------------------------------------------
 
    // Standard UVM Methods:
    extern function new(string name = "ca_stb_rcvr_aft_aln_done_test", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void start_of_simulation( );
    extern task run_phase( uvm_phase phase);
    extern task run_test( uvm_phase phase );
    extern task chk_align_done( );
 
endclass:ca_stb_rcvr_aft_aln_done_test_c
////////////////////////////////////////////////////////////

//------------------------------------------
function ca_stb_rcvr_aft_aln_done_test_c::new(string name = "ca_stb_rcvr_aft_aln_done_test", uvm_component parent = null);
    super.new(name, parent);
endfunction : new
 
//------------------------------------------
function void ca_stb_rcvr_aft_aln_done_test_c::build_phase( uvm_phase phase );
    // build in base test 
    super.build_phase(phase);
endfunction: build_phase

//------------------------------------------
function void ca_stb_rcvr_aft_aln_done_test_c::start_of_simulation( );
    //
endfunction: start_of_simulation 
 
//------------------------------------------
// run phase 
task ca_stb_rcvr_aft_aln_done_test_c::run_phase(uvm_phase phase);
    fork
        run_test(phase);
        global_timer(); // and check for error count
        ck_eot(phase);
        chk_align_done();
    join

endtask : run_phase
 
//------------------------------------------
task ca_stb_rcvr_aft_aln_done_test_c::chk_align_done();

 // After align_done, tx_stb_rcvr = 1
    fork
        begin
            wait (tx_stb_rcvr_to_be_enb_diea == 1);
            wait (ca_cfg.ca_die_a_tx_tb_out_cfg.align_done_assert == 1);
                 //repeat(tx_stb_intv_bkp + 2)@(posedge vif.clk);
                ca_cfg.ca_die_a_rx_tb_in_cfg.tx_stb_rcvr        =  1;
                tx_stb_rcvr_to_be_enb_diea                      =  0;
                // repeat(4)@(posedge vif.clk);
                `uvm_info("ca_stb_rcvr_aft_aln_done_test::run_phase", "DIE_A_generate_stb_beat in scoreboard started ..\n", UVM_LOW);
                 ca_top_env.ca_scoreboard.generate_stb_beat(); //To update stb_rcvr_enb in scoreboard
                `uvm_info("ca_stb_rcvr_aft_aln_done_test::run_phase", "DIE_A_generate_stb_beat in TX_TB_IN_MON started ..\n", UVM_LOW);
                 ca_top_env.ca_die_a_tx_tb_in_agent.mon.test_call_gen_stb_beat();
                 ca_top_env.ca_die_b_tx_tb_in_agent.mon.test_call_gen_stb_beat();
                `uvm_info("ca_stb_rcvr_aft_aln_done_test::run_phase", "DIE_A_generate_stb_beat in TX_TB_IN_MON ended ..\n", UVM_LOW);
                `uvm_info("ca_stb_rcvr_aft_aln_done_test::run_phase", "DIE_A_generate_stb_beat in RX_TB_IN_MON started ..\n", UVM_LOW);
                 ca_top_env.ca_die_a_rx_tb_in_agent.mon.test_call_gen_stb_beat();
                 ca_top_env.ca_die_b_rx_tb_in_agent.mon.test_call_gen_stb_beat();
                `uvm_info("ca_stb_rcvr_aft_aln_done_test::run_phase", "DIE_A_generate_stb_beat in RX_TB_IN_MON ended ..\n", UVM_LOW);
                disable fork;
         end
    join_none
 
    fork
        begin
            wait (tx_stb_rcvr_to_be_enb_dieb == 1);
            wait (ca_cfg.ca_die_b_tx_tb_out_cfg.align_done_assert == 1);
                //repeat(tx_stb_intv_bkp + 2)@(posedge vif.clk);
                ca_cfg.ca_die_b_rx_tb_in_cfg.tx_stb_rcvr        =  1;
                tx_stb_rcvr_to_be_enb_dieb                      =  0;
                 //repeat(4)@(posedge vif.clk);
                `uvm_info("ca_stb_rcvr_aft_aln_done_test::run_phase", "DIE_B_generate_stb_beat in scoreboard started ..\n", UVM_LOW);
                ca_top_env.ca_scoreboard.generate_stb_beat(); //To update stb_rcvr_enb in scoreboard
                `uvm_info("ca_stb_rcvr_aft_aln_done_test::run_phase", "DIE_B_generate_stb_beat in TX_TB_IN_MON started ..\n", UVM_LOW);
                 ca_top_env.ca_die_a_tx_tb_in_agent.mon.test_call_gen_stb_beat();
                 ca_top_env.ca_die_b_tx_tb_in_agent.mon.test_call_gen_stb_beat();
                `uvm_info("ca_stb_rcvr_aft_aln_done_test::run_phase", "DIE_B_generate_stb_beat in TX_TB_IN_MON ended ..\n", UVM_LOW);
                `uvm_info("ca_stb_rcvr_aft_aln_done_test::run_phase", "DIE_B_generate_stb_beat in RX_TB_IN_MON started ..\n", UVM_LOW);
                 ca_top_env.ca_die_a_rx_tb_in_agent.mon.test_call_gen_stb_beat();
                 ca_top_env.ca_die_b_rx_tb_in_agent.mon.test_call_gen_stb_beat();
                `uvm_info("ca_stb_rcvr_aft_aln_done_test::run_phase", "DIE_B_generate_stb_beat in RX_TB_IN_MON ended ..\n", UVM_LOW);
                disable fork;
         end
    join_none 

endtask: chk_align_done

//------------------------------------------
task ca_stb_rcvr_aft_aln_done_test_c::run_test(uvm_phase phase);
     
     bit result=0;

    `uvm_info("ca_stb_rcvr_aft_aln_done_test ::run_phase", "START test...", UVM_LOW);
     ca_cfg.ca_die_a_tx_tb_in_cfg.align_error_afly0_test =   1;
     ca_cfg.ca_die_b_tx_tb_in_cfg.align_error_afly0_test =   1;
     ca_cfg.ca_die_a_rx_tb_in_cfg.align_error_afly0_test =   1;
     ca_cfg.ca_die_b_rx_tb_in_cfg.align_error_afly0_test =   1;
     ca_cfg.ca_die_a_tx_tb_out_cfg.ca_stb_rcvr_aft_aln_done_test = 1;
     ca_cfg.ca_die_b_tx_tb_out_cfg.ca_stb_rcvr_aft_aln_done_test = 1;
     ca_cfg.ca_die_a_rx_tb_in_cfg.ca_stb_rcvr_aft_aln_done_test = 1;
     ca_cfg.ca_die_b_rx_tb_in_cfg.ca_stb_rcvr_aft_aln_done_test = 1;
      // $display("stb_rcvr %0d",ca_cfg.ca_die_a_rx_tb_in_cfg.ca_stb_rcvr_aft_aln_done_test);
      // $display("stb_rcvr %0d",ca_cfg.ca_die_b_rx_tb_in_cfg.ca_stb_rcvr_aft_aln_done_test);
     ca_cfg.ca_die_a_tx_tb_in_cfg.with_external_stb_test   = 1;
     ca_cfg.ca_die_b_tx_tb_in_cfg.with_external_stb_test   = 1;
     ca_cfg.ca_die_a_rx_tb_in_cfg.with_external_stb_test   = 1;
     ca_cfg.ca_die_b_rx_tb_in_cfg.with_external_stb_test   = 1;
  
     if(ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv > ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv) begin
         tx_stb_intv_bkp = ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv;
     end else begin
         tx_stb_intv_bkp = ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv;
     end
     `uvm_info("ca_stb_related_test ::run_phase", $sformatf("tx_stb_intv_bkp = %0d..\n",tx_stb_intv_bkp), UVM_LOW);
 
     ca_cfg.ca_die_a_rx_tb_in_cfg.tx_stb_rcvr              = 0;
     ca_cfg.ca_die_b_rx_tb_in_cfg.tx_stb_rcvr              = 0;

     tx_stb_rcvr_to_be_enb_diea =  1;
     tx_stb_rcvr_to_be_enb_dieb =  1;


     ca_vseq        = ca_seq_lib_c::type_id::create("ca_vseq");
     ca_traffic_seq = ca_traffic_seq_c::type_id::create("ca_traffic_seq");
     ca_vseq.start(ca_top_env.virt_seqr);

    `uvm_info("ca_stb_rcvr_aft_aln_done_test ::run_phase", "wait_started for 1st drv_tfr_complete..\n", UVM_LOW);
     wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
    `uvm_info("ca_stb_rcvr_aft_aln_done_test ::run_phase", "wait_ended for 1st drv_tfr_complete..\n", UVM_LOW);

     result =  ck_xfer_cnt_a(1);
     result =  ck_xfer_cnt_b(1);
     `uvm_info("ca_stb_rcvr_aft_aln_done_test ::run_phase", "Scoreboard comparison completed for first set of traffic ..\n", UVM_LOW);
      
     repeat(20)@ (posedge vif.clk);
     ca_cfg.ca_die_a_tx_tb_out_cfg.align_done_assert       = 0; 
     ca_cfg.ca_die_b_tx_tb_out_cfg.align_done_assert       = 0; 

     ca_cfg.ca_die_a_rx_tb_in_cfg.tx_stb_rcvr              = 0;
     ca_cfg.ca_die_b_rx_tb_in_cfg.tx_stb_rcvr              = 0;

     repeat(4)@(posedge vif.clk);
     ca_top_env.ca_scoreboard.generate_stb_beat(); //To update stb_rcvr_enb in scoreboard
    `uvm_info("ca_stb_rcvr_aft_aln_done_test::run_phase", "aft_rcvr_0_generate_stb_beat in TX_TB_IN_MON started ..\n", UVM_LOW);
     ca_top_env.ca_die_a_tx_tb_in_agent.mon.test_call_gen_stb_beat();
     ca_top_env.ca_die_b_tx_tb_in_agent.mon.test_call_gen_stb_beat();
    `uvm_info("ca_stb_rcvr_aft_aln_done_test::run_phase", "aft_rcvr_0_generate_stb_beat in TX_TB_IN_MON ended ..\n", UVM_LOW);
    `uvm_info("ca_stb_rcvr_aft_aln_done_test::run_phase", "aft_rcvr_0_generate_stb_beat in RX_TB_IN_MON started ..\n", UVM_LOW);
     ca_top_env.ca_die_a_rx_tb_in_agent.mon.test_call_gen_stb_beat();
     ca_top_env.ca_die_b_rx_tb_in_agent.mon.test_call_gen_stb_beat();
    `uvm_info("ca_stb_rcvr_aft_aln_done_test::run_phase", "aft_rcvr_0_generate_stb_beat in RX_TB_IN_MON ended ..\n", UVM_LOW);

     sbd_counts_clear;

     `uvm_info("ca_stb_rcvr_aft_aln_done_test ::run_phase", "before ca_traffic_seq starts ..\n", UVM_LOW);
      ca_vseq.start(ca_top_env.virt_seqr);
      `uvm_info("ca_stb_rcvr_aft_aln_done_test ::run_phase", "after ca_traffic_seq starts ..\n", UVM_LOW);

     `uvm_info("ca_stb_rcvr_aft_aln_done_test ::run_phase", "wait_started for 2nd drv_tfr_complete ..\n", UVM_LOW);
      wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
     `uvm_info("ca_stb_rcvr_aft_aln_done_test ::run_phase", "wait_ended for 2nd drv_tfr_complete ..\n", UVM_LOW);

      repeat(10)@ (posedge vif.clk);
      result =  ck_xfer_cnt_a(1);
      result =  ck_xfer_cnt_b(1);
     `uvm_info("ca_stb_rcvr_aft_aln_done_test ::run_phase", "Scoreboard comparison completed for second set of traffic ..\n", UVM_LOW);

     test_end = 1; 
     `uvm_info("ca_stb_rcvr_aft_aln_done_test ::run_phase", "END test...\n", UVM_LOW);

endtask : run_test
////////////////////////////////////////////////////////////////
`endif
