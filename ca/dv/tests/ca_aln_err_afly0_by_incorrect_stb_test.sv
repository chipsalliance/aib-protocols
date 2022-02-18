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
// TESTCASE DESCTIPTION
// align_fly = 0, tx_stb_enb = 0 =>  CA driver drives strobes externally
// except one channel. align_error will be seen due to missing stb_interval.  
// check align_error is asserted and then test ended.
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_ALN_ERR_AFLY0_BY_INCORRECT_STB_TEST_
`define _CA_ALN_ERR_AFLY0_BY_INCORRECT_STB_TEST_
////////////////////////////////////////////////////////////

class ca_aln_err_afly0_by_incorrect_stb_test_c extends base_ca_test_c;
 
    // UVM Factory Registration Macro
    `uvm_component_utils(ca_aln_err_afly0_by_incorrect_stb_test_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    ca_data_pkg::ca_seq_item_c    seq_item;

    ca_seq_lib_c    ca_vseq;
    bit             shift_stb_intv_complt; 
    bit             update_do_compare; 
    bit             aft_aln_err; 
    bit             die_a_aln_err; 
    bit             die_b_aln_err; 
    //------------------------------------------
    // Component Members
    //------------------------------------------
 
    //------------------------------------------
    // Methods
    //------------------------------------------
 
    // Standard UVM Methods:
    extern function new(string name = "ca_aln_err_afly0_by_incorrect_stb_test", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void start_of_simulation( );
    extern task run_phase( uvm_phase phase);
    extern task run_test( uvm_phase phase );
    extern task aln_err_chk( );
 
endclass:ca_aln_err_afly0_by_incorrect_stb_test_c 
////////////////////////////////////////////////////////////

//------------------------------------------
function ca_aln_err_afly0_by_incorrect_stb_test_c::new(string name = "ca_aln_err_afly0_by_incorrect_stb_test", uvm_component parent = null);
    super.new(name, parent);
endfunction : new
 
//------------------------------------------
function void ca_aln_err_afly0_by_incorrect_stb_test_c::build_phase( uvm_phase phase );
    // build in base test 
    super.build_phase(phase);
endfunction: build_phase

//------------------------------------------
function void ca_aln_err_afly0_by_incorrect_stb_test_c::start_of_simulation( );
    //
endfunction: start_of_simulation 
 
//------------------------------------------
// run phase 
task ca_aln_err_afly0_by_incorrect_stb_test_c::run_phase(uvm_phase phase);
    fork
        aln_err_chk();
        run_test(phase);
        global_timer(); // and check for error count
        ck_eot(phase);   
    join
  
endtask : run_phase

//------------------------------------------
task ca_aln_err_afly0_by_incorrect_stb_test_c::aln_err_chk();

   fork 
       begin 
           wait(ca_cfg.ca_die_a_tx_tb_out_cfg.align_done_assert == 1) ;
           repeat(ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv*2)@(posedge vif.clk);
           ca_cfg.ca_die_a_rx_tb_in_cfg.align_fly               = 1;
           ca_cfg.ca_die_b_rx_tb_in_cfg.align_fly               = 1;
           ca_top_env.ca_scoreboard.do_compare                  = 0;
           ca_cfg.ca_die_a_tx_tb_in_cfg.stop_monitor            = 1;
           ca_cfg.ca_die_b_tx_tb_in_cfg.stop_monitor            = 1;
           ca_cfg.ca_die_a_rx_tb_in_cfg.stop_monitor            = 1;
           ca_cfg.ca_die_b_rx_tb_in_cfg.stop_monitor            = 1;
           ca_cfg.ca_die_a_tx_tb_out_cfg.shift_stb_intv_enb     = 1;
           ca_cfg.ca_die_b_tx_tb_out_cfg.shift_stb_intv_enb     = 1;
       end
   join_none

   fork 
       begin
            wait(gen_if.die_a_align_error == 1);
              sbd_counts_clear();
              die_a_aln_err = 1;
              `uvm_info("ca_aln_err_afly0_by_incorrect_stb_test", "align_error seen due to incorrect stb intv ...", UVM_LOW);
       end
   join_none

   fork 
       begin
            wait(gen_if.die_b_align_error == 1);
              sbd_counts_clear();
              die_b_aln_err = 1;
              `uvm_info("ca_aln_err_afly0_by_incorrect_stb_test", "align_error seen due to incorrect stb intv ...", UVM_LOW);
       end
   join_none

   fork 
       begin
            wait((die_a_aln_err == 1) && (die_b_aln_err == 1));
             test_end = 1;
       end
  join_none

endtask:aln_err_chk

//------------------------------------------
task ca_aln_err_afly0_by_incorrect_stb_test_c::run_test(uvm_phase phase);
     bit result = 0;

    `uvm_info("ca_aln_err_afly0_by_incorrect_stb_test ::run_phase", "START test...", UVM_LOW);

     ca_cfg.ca_die_a_tx_tb_out_cfg.align_error_test  = 1;
     ca_cfg.ca_die_b_tx_tb_out_cfg.align_error_test  = 1;
     ca_cfg.ca_die_a_tx_tb_in_cfg.align_error_test   = 1;
     ca_cfg.ca_die_b_tx_tb_in_cfg.align_error_test   = 1;
     ca_cfg.ca_die_a_rx_tb_in_cfg.align_error_test   = 1;
     ca_cfg.ca_die_b_rx_tb_in_cfg.align_error_test   = 1;

     ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_en              = 0;
     ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_en              = 0;

     ca_cfg.ca_die_a_rx_tb_in_cfg.align_fly               = 0;
     ca_cfg.ca_die_b_rx_tb_in_cfg.align_fly               = 0;

     ca_vseq = ca_seq_lib_c::type_id::create("ca_vseq");
     ca_vseq.start(ca_top_env.virt_seqr);

    `uvm_info("ca_aln_err_afly0_by_incorrect_stb_test ::run_phase", "wait_started for drv_tfr_complete ..\n", UVM_LOW);
     wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
    `uvm_info("ca_aln_err_afly0_by_incorrect_stb_test ::run_phase", "after_1st drv_tfr_complete..\n", UVM_LOW);

     result =  ck_xfer_cnt_a(1);
     result =  ck_xfer_cnt_b(1);
    `uvm_info("ca_aln_err_afly0_by_incorrect_stb_test ::run_phase", "SCOREBOARD COMPARISON COMPLETED..\n", UVM_LOW);
     repeat(20)@ (posedge vif.clk);
     test_end = 1;

endtask : run_test
////////////////////////////////////////////////////////////////
`endif 
