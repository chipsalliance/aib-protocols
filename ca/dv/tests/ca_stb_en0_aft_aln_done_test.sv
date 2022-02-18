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
// stb_enb = 1 , stb_rcvr = 0 ,afly = 0
// stb_enb = 0 after aln_done  = > aln_error comes=> 
// stb_enb = 1, aln_done comes , with diff stb_inv and afly = 1
// send traffic
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_STB_EN0_AFT_ALN_DONE_TEST_
`define _CA_STB_EN0_AFT_ALN_DONE_TEST_
////////////////////////////////////////////////////////////

class ca_stb_en0_aft_aln_done_test_c extends base_ca_test_c;
 
    // UVM Factory Registration Macro
    `uvm_component_utils(ca_stb_en0_aft_aln_done_test_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    ca_seq_lib_c       ca_vseq;
    ca_traffic_seq_c   ca_traffic_seq;
    bit                tx_stb_rcvr_to_be_enb_diea; 
    bit                tx_stb_rcvr_to_be_enb_dieb; 
    bit                aft_aln_err;
    //------------------------------------------
    // Component Members
    //------------------------------------------
 
    //------------------------------------------
    // Methods
    //------------------------------------------
 
    // Standard UVM Methods:
    extern function new(string name = "ca_stb_en0_aft_aln_done_test", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void start_of_simulation( );
    extern task run_phase( uvm_phase phase);
    extern task run_test( uvm_phase phase );
    extern task aln_err_chk( );
    extern task chk_align_done( );
 
endclass:ca_stb_en0_aft_aln_done_test_c
////////////////////////////////////////////////////////////

//------------------------------------------
function ca_stb_en0_aft_aln_done_test_c::new(string name = "ca_stb_en0_aft_aln_done_test", uvm_component parent = null);
    super.new(name, parent);
endfunction : new
 
//------------------------------------------
function void ca_stb_en0_aft_aln_done_test_c::build_phase( uvm_phase phase );
    // build in base test 
    super.build_phase(phase);
endfunction: build_phase

//------------------------------------------
function void ca_stb_en0_aft_aln_done_test_c::start_of_simulation( );
    //
endfunction: start_of_simulation 
 
//------------------------------------------
// run phase 
task ca_stb_en0_aft_aln_done_test_c::run_phase(uvm_phase phase);
    fork
        run_test(phase);
        global_timer(); // and check for error count
        ck_eot(phase);
        chk_align_done();
        aln_err_chk();
    join

endtask : run_phase
 
//------------------------------------------
task ca_stb_en0_aft_aln_done_test_c::chk_align_done();

 // After align_done, tx_stb_rcvr = 1
    fork
        begin
            wait (tx_stb_rcvr_to_be_enb_diea == 1);
            wait (ca_cfg.ca_die_a_tx_tb_out_cfg.align_done_assert == 1);
                repeat(tx_stb_intv_bkp * 2)@(posedge vif.clk);
                ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_en = 0;
                ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_en = 0;
                ca_cfg.ca_die_a_tx_tb_out_cfg.stop_strobes_inject = 1;
                ca_cfg.ca_die_b_tx_tb_out_cfg.stop_strobes_inject = 1;
                tx_stb_rcvr_to_be_enb_diea              = 0;
                `uvm_info("ca_stb_en0_aft_aln_done_test::run_phase", "DIE_A_generate_stb_beat in scoreboard started ..\n", UVM_LOW);
                 ca_top_env.ca_scoreboard.generate_stb_beat(); //To update stb_rcvr_enb in scoreboard
                `uvm_info("ca_stb_en0_aft_aln_done_test::run_phase", "DIE_A_generate_stb_beat in TX_TB_IN_MON started ..\n", UVM_LOW);
                disable fork;
         end
    join_none

endtask: chk_align_done
  
task ca_stb_en0_aft_aln_done_test_c::aln_err_chk();
     forever begin
        repeat(1)@(posedge vif.clk); 
          if ((gen_if.die_a_align_error  == 1) && (gen_if.die_b_align_error == 1)) begin
               repeat(tx_stb_intv_bkp * 2)@(posedge vif.clk);
                 ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_en = 1;
                 ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_en = 1;
                `uvm_info("ca_stb_en0_aft_aln_done_test::run_phase", "DIE_A_generate_stb_beat in scoreboard started ..\n", UVM_LOW);
                 ca_top_env.ca_scoreboard.generate_stb_beat(); //To update stb_rcvr_enb in scoreboard
                `uvm_info("ca_stb_en0_aft_aln_done_test::run_phase", "DIE_A_generate_stb_beat in TX_TB_IN_MON started ..\n", UVM_LOW);
                 wait (gen_if.die_a_align_error == 1);
                 wait (gen_if.die_b_align_error == 1);
                 wait (gen_if.die_a_align_done  == 1); 
                 wait (gen_if.die_b_align_done  == 1); 
              `uvm_info("ca_stb_en0_aft_aln_done_test_c", "DIE_A_align_error seen due to missing strobes ...", UVM_LOW);
          end
     end
endtask : aln_err_chk
//------------------------------------------
task ca_stb_en0_aft_aln_done_test_c::run_test(uvm_phase phase);
     
     bit result=0;

    `uvm_info("ca_stb_en0_aft_aln_done_test ::run_phase", "START test...", UVM_LOW);
     ca_cfg.ca_die_a_tx_tb_out_cfg.ca_stb_rcvr_aft_aln_done_test = 1;
     ca_cfg.ca_die_b_tx_tb_out_cfg.ca_stb_rcvr_aft_aln_done_test = 1;
     ca_cfg.ca_die_a_rx_tb_in_cfg.ca_stb_rcvr_aft_aln_done_test  = 1;
     ca_cfg.ca_die_b_rx_tb_in_cfg.ca_stb_rcvr_aft_aln_done_test  = 1;

     ca_cfg.ca_die_a_tx_tb_in_cfg.with_external_stb_test   = 1;
     ca_cfg.ca_die_b_tx_tb_in_cfg.with_external_stb_test   = 1;
     ca_cfg.ca_die_a_rx_tb_in_cfg.with_external_stb_test   = 1;
     ca_cfg.ca_die_b_rx_tb_in_cfg.with_external_stb_test   = 1;
  
     if(ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv > ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv) begin
         tx_stb_intv_bkp = ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv;
     end else begin
         tx_stb_intv_bkp = ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv;
     end
     `uvm_info("ca_stb_en0_aft_aln_done_test::run_phase", $sformatf("tx_stb_intv_bkp = %0d..\n",tx_stb_intv_bkp), UVM_LOW);
 
     ca_cfg.ca_die_a_rx_tb_in_cfg.tx_stb_rcvr              = 0;
     ca_cfg.ca_die_b_rx_tb_in_cfg.tx_stb_rcvr              = 0;
     ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_en               = 1;
     ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_en               = 1;
     ca_cfg.ca_die_a_rx_tb_in_cfg.align_fly                = 0;
     ca_cfg.ca_die_b_rx_tb_in_cfg.align_fly                = 0;

     tx_stb_rcvr_to_be_enb_diea =  1;
     tx_stb_rcvr_to_be_enb_dieb =  1;

     ca_vseq        = ca_seq_lib_c::type_id::create("ca_vseq");
     ca_traffic_seq = ca_traffic_seq_c::type_id::create("ca_traffic_seq");
     ca_vseq.start(ca_top_env.virt_seqr);

    `uvm_info("ca_stb_en0_aft_aln_done_test ::run_phase", "wait_started for 1st drv_tfr_complete..\n", UVM_LOW);
     wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
    `uvm_info("ca_stb_en0_aft_aln_done_test ::run_phase", "wait_ended for 1st drv_tfr_complete..\n", UVM_LOW);

     result =  ck_xfer_cnt_a(1);
     result =  ck_xfer_cnt_b(1);
     `uvm_info("ca_stb_en0_aft_aln_done_test ::run_phase", "Scoreboard comparison completed for first set of traffic ..\n", UVM_LOW);
     
     repeat((tx_stb_intv_bkp * 2)+2)@(posedge vif.clk);
      ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv          = 16'h80;
      ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv          = 16'h80;
      ca_cfg.ca_die_a_rx_tb_in_cfg.align_fly             = 1;
      ca_cfg.ca_die_b_rx_tb_in_cfg.align_fly             = 1; /////2 clock after this align_err output of DUT == 0 ...to be checked
      ca_cfg.ca_die_a_tx_tb_out_cfg.align_done_assert    = 0; 
      ca_cfg.ca_die_b_tx_tb_out_cfg.align_done_assert    = 0;
      ca_cfg.configure();
     if(ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv > ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv) begin
          tx_stb_intv_bkp = ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv;
     end else begin
         tx_stb_intv_bkp = ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_intv;
     end
     `uvm_info("ca_stb_en0_aft_aln_done_test::run_phase", $sformatf("tx_stb_intv_bkp = %0d..\n",tx_stb_intv_bkp), UVM_LOW);

    `uvm_info("ca_stb_en0_aft_aln_done_test ::run_phase", "align_error wait_started..\n", UVM_LOW);
     repeat(tx_stb_intv_bkp * 1)@(posedge vif.clk);
      wait (gen_if.die_a_align_error == 0);
      wait (gen_if.die_b_align_error == 0);
    `uvm_info("ca_stb_en0_aft_aln_done_test ::run_phase", "align_error wait_ended..\n", UVM_LOW);

    `uvm_info("ca_stb_en0_aft_aln_done_test ::run_phase", "align_done_wait_started..\n", UVM_LOW);
     repeat(tx_stb_intv_bkp * 1)@(posedge vif.clk);
      wait (gen_if.die_a_align_done == 1); 
      wait (gen_if.die_b_align_done == 1); 
    `uvm_info("ca_stb_en0_aft_aln_done_test ::run_phase", "align_done_wait_ended..\n", UVM_LOW);

    `uvm_info("ca_stb_en0_aft_aln_done_test ::run_phase", "align_error second_wait_started..\n", UVM_LOW);
      wait (gen_if.die_a_align_error == 0);
      wait (gen_if.die_b_align_error == 0);
    `uvm_info("ca_stb_en0_aft_aln_done_test ::run_phase", "align_error second_wait_ended..\n", UVM_LOW);

     repeat(4)@(posedge vif.clk);
     ca_top_env.ca_scoreboard.generate_stb_beat(); //To update stb_rcvr_enb in scoreboard
    `uvm_info("ca_stb_en0_aft_aln_done_test::run_phase", "aft_rcvr_0_generate_stb_beat in TX_TB_IN_MON started ..\n", UVM_LOW);

     sbd_counts_clear;

     // second_traffic_started = 1;
     `uvm_info("ca_stb_en0_aft_aln_done_test ::run_phase", "before_ca_traffic starts ..\n", UVM_LOW);
      ca_traffic_seq.start(ca_top_env.virt_seqr);
      `uvm_info("ca_stb_en0_aft_aln_done_test ::run_phase", "after_ca_traffic starts ..\n", UVM_LOW);

     `uvm_info("ca_stb_en0_aft_aln_done_test ::run_phase", "wait_started for 2nd drv_tfr_complete ..\n", UVM_LOW);
      wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
     `uvm_info("ca_stb_en0_aft_aln_done_test ::run_phase", "wait_ended for 2nd drv_tfr_complete ..\n", UVM_LOW);

      repeat(10)@ (posedge vif.clk);
      result =  ck_xfer_cnt_a(1);
      result =  ck_xfer_cnt_b(1);
     `uvm_info("ca_stb_en0_aft_aln_done_test ::run_phase", "Scoreboard comparison completed for second set of traffic ..\n", UVM_LOW);

     test_end = 1; 
     `uvm_info("ca_stb_en0_aft_aln_done_test ::run_phase", "END test...\n", UVM_LOW);

endtask : run_test
////////////////////////////////////////////////////////////////
`endif
