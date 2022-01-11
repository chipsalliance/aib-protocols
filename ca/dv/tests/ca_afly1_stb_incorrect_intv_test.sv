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
// tx_stb_en = 0( CA driver injects strobes). By missing stb_bit position as a part of tx_din,
// (align_fly = 1) align_err will occur.
//  Tx driver will start driving corrected strobe input. Due to "fifo_soft_reset" feature in CA DUT,
//  alignment is achieved again.  
//  no loss of align_done should be seen.
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_ALIGN_FLY1_STB_INCORRECT_INTV_TEST_
`define _CA_ALIGN_FLY1_STB_INCORRECT_INTV_TEST_
////////////////////////////////////////////////////////////

class ca_afly1_stb_incorrect_intv_test_c extends base_ca_test_c;
 
    // UVM Factory Registration Macro
    `uvm_component_utils(ca_afly1_stb_incorrect_intv_test_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
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
    extern function new(string name = "ca_afly1_stb_incorrect_intv_test", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void start_of_simulation( );
    extern task run_phase( uvm_phase phase);
    extern task run_test( uvm_phase phase );
    extern task shift_stb_intv( );
    extern task aln_err_chk( );
 
endclass:ca_afly1_stb_incorrect_intv_test_c 
////////////////////////////////////////////////////////////

//------------------------------------------
function ca_afly1_stb_incorrect_intv_test_c::new(string name = "ca_afly1_stb_incorrect_intv_test", uvm_component parent = null);
    super.new(name, parent);
endfunction : new
 
//------------------------------------------
function void ca_afly1_stb_incorrect_intv_test_c::build_phase( uvm_phase phase );
    // build in base test 
    super.build_phase(phase);
endfunction: build_phase

//------------------------------------------
function void ca_afly1_stb_incorrect_intv_test_c::start_of_simulation( );
    //
endfunction: start_of_simulation 
 
//------------------------------------------
// run phase 
task ca_afly1_stb_incorrect_intv_test_c::run_phase(uvm_phase phase);

    fork
        aln_err_chk();
        run_test(phase);
        global_timer(); // and check for error count
        ck_eot(phase);   
        shift_stb_intv();
    join

endtask : run_phase

//------------------------------------------
task ca_afly1_stb_incorrect_intv_test_c::run_test(uvm_phase phase);
     bit result = 0;

    `uvm_info("ca_afly1_stb_incorrect_intv_test ::run_phase", "START test...", UVM_LOW);
     ca_cfg.ca_die_a_tx_tb_in_cfg.ca_afly1_stb_incorrect_intv_test= 1;
     ca_cfg.ca_die_b_tx_tb_in_cfg.ca_afly1_stb_incorrect_intv_test= 1;
     ca_cfg.ca_die_a_rx_tb_in_cfg.ca_afly1_stb_incorrect_intv_test= 1;
     ca_cfg.ca_die_b_rx_tb_in_cfg.ca_afly1_stb_incorrect_intv_test= 1;

     ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_en = 0;
     ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_en = 0;
     ca_cfg.ca_die_a_rx_tb_in_cfg.align_fly  = 1;
     ca_cfg.ca_die_b_rx_tb_in_cfg.align_fly  = 1;

     ca_vseq = ca_seq_lib_c::type_id::create("ca_vseq");
     ca_vseq.start(ca_top_env.virt_seqr);

    `uvm_info("ca_afly1_stb_incorrect_intv_test ::run_phase", "wait_started for drv_tfr_complete ..\n", UVM_LOW);
     
     wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
     `uvm_info("ca_afly1_stb_incorrect_intv_test ::run_phase", "after_1st drv_tfr_complete..\n", UVM_LOW);
     repeat(100)@ (posedge vif.clk);
     `uvm_info("ca_afly1_stb_incorrect_intv_test ::run_phase", "after 100 clks wait completion ..\n", UVM_LOW);
     result =  ck_xfer_cnt_a(1);
     result =  ck_xfer_cnt_b(1);
     repeat(20)@ (posedge vif.clk);

     test_end = 1; 
     `uvm_info("ca_afly1_stb_incorrect_intv_test ::run_phase", "END test...\n", UVM_LOW);

endtask : run_test

//------------------------------------------
task ca_afly1_stb_incorrect_intv_test_c::shift_stb_intv();

      forever begin
          repeat(1)@(posedge vif.clk);
          if((shift_stb_intv_complt == 0) &&
             (ca_cfg.ca_die_a_tx_tb_out_cfg.align_done_assert == 1))begin
              repeat(20)@(posedge vif.clk);
              ca_cfg.ca_die_a_tx_tb_out_cfg.shift_stb_intv_enb =  1;
              ca_cfg.ca_die_b_tx_tb_out_cfg.shift_stb_intv_enb =  1;
          end
      end

endtask : shift_stb_intv 

//------------------------------------------
task ca_afly1_stb_incorrect_intv_test_c::aln_err_chk();
  
   fork 
        begin
            wait (gen_if.die_a_align_error == 1);
            ca_top_env.ca_scoreboard.do_compare = 0; 
            `uvm_info("ca_afly1_stb_incorrect_intv_test", "align_error seen due to incorrect stb intv ...", UVM_LOW);
            die_a_aln_err = 1;
        end
   join_none

   fork 
        begin
            wait (gen_if.die_b_align_error == 1);
            ca_top_env.ca_scoreboard.do_compare = 0; 
            `uvm_info("ca_afly1_stb_incorrect_intv_test", "align_error seen due to incorrect stb intv ...", UVM_LOW);
            die_b_aln_err = 1;
        end
  join_none

   fork 
        begin
            wait((die_a_aln_err == 1) && (die_b_aln_err == 1));
              `uvm_info("ca_afly1_stb_incorrect_intv_test", "after align_error_check......", UVM_LOW);
               sbd_counts_clear();
               shift_stb_intv_complt =1;
               //disable fork; 
        end
   join_none

   fork 
        begin
          wait(shift_stb_intv_complt == 1) ;
	      repeat(ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_intv*3)@(posedge vif.clk);
              ca_cfg.ca_die_a_tx_tb_out_cfg.shift_stb_intv_enb =  0;
              ca_cfg.ca_die_b_tx_tb_out_cfg.shift_stb_intv_enb =  0;
          end
   join_none

   fork 
        begin
          wait(shift_stb_intv_complt == 1) ;
          wait(ca_cfg.ca_die_a_tx_tb_out_cfg.align_done_assert == 1);
             if(update_do_compare == 0) begin
               sbd_counts_only_clear();
              `uvm_info("ca_afly1_stb_incorrect_intv_test", "after align_error gone,align_done come,start SCOREBOARD comparision...", UVM_LOW);
               ca_top_env.ca_scoreboard.do_compare = 1;
               update_do_compare = 1;
             end
        end
   join_none

endtask : aln_err_chk

////////////////////////////////////////////////////////////////
`endif //_CA_ALIGN_FLY1_STB_INCORRECT_INTV_TEST_
