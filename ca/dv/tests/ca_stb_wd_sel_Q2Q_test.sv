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
// ca_stb_wd_sel_Q2Q_test.sv -Description 
// tx_stb_wd_sel of all possible combinations verified. 
// Q2Q test case has maximum datawidth(320).
// So Q2Q configuration used in this test case
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_STB_WD_SEL_Q2Q_TEST_
`define _CA_STB_WD_SEL_Q2Q_TEST_
////////////////////////////////////////////////////////////

class ca_stb_wd_sel_Q2Q_test_c extends base_ca_test_c;
 
    // UVM Factory Registration Macro
    `uvm_component_utils(ca_stb_wd_sel_Q2Q_test_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    ca_seq_lib_c    ca_vseq;
 
    //------------------------------------------
    // Component Members
    //------------------------------------------
 
    //------------------------------------------
    // Methods
    //------------------------------------------
 
    // Standard UVM Methods:
    extern function new(string name = "ca_stb_wd_sel_Q2Q_test", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void start_of_simulation( );
    extern task run_phase( uvm_phase phase);
    extern task run_test( uvm_phase phase );

endclass:ca_stb_wd_sel_Q2Q_test_c 
////////////////////////////////////////////////////////////

//------------------------------------------
function ca_stb_wd_sel_Q2Q_test_c::new(string name = "ca_stb_wd_sel_Q2Q_test", uvm_component parent = null);
    super.new(name, parent);
endfunction : new
 
//------------------------------------------
function void ca_stb_wd_sel_Q2Q_test_c::build_phase( uvm_phase phase );
    // build in base test 
    super.build_phase(phase);
endfunction: build_phase

//------------------------------------------
function void ca_stb_wd_sel_Q2Q_test_c::start_of_simulation( );
    //
endfunction: start_of_simulation 
 
//------------------------------------------
// run phase 
task ca_stb_wd_sel_Q2Q_test_c::run_phase(uvm_phase phase);
    fork
        run_test(phase);
        global_timer(); // and check for error count
        ck_eot(phase);
    join

endtask : run_phase

//------------------------------------------
task ca_stb_wd_sel_Q2Q_test_c::run_test(uvm_phase phase);
     bit result = 0;

    `uvm_info("ca_stb_wd_sel_Q2Q_test ::run_phase", "START test...", UVM_LOW);
     ca_vseq = ca_seq_lib_c::type_id::create("ca_vseq");
     ca_vseq.start(ca_top_env.virt_seqr); //stb_wd_sel = 0 by default 

    `uvm_info("ca_stb_wd_sel_Q2Q_test ::run_phase", "wait_started for drv_tfr_complete ..\n", UVM_LOW);
     wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
     `uvm_info("ca_stb_wd_sel_Q2Q_test ::run_phase", "after_1st drv_tfr_complete..\n", UVM_LOW);

     result =  ck_xfer_cnt_a(1);
     result =  ck_xfer_cnt_b(1);
     `uvm_info("ca_stb_wd_sel_test ::run_phase", "SCOREBOARD COMPARISON FIRST SET COMPLETED..\n", UVM_LOW);

     repeat(20)@ (posedge vif.clk);
    for(int i=1;i<=7;i++) begin  
        ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_wd_sel = 'h0;
        ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_wd_sel = 'h0; 
        ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_wd_sel[i] = 1'b1;
        ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_wd_sel[i] = 1'b1;
        ca_cfg.configure();

        sbd_counts_clear(); 
        `uvm_info("ca_stb_wd_sel_Q2Q_test ::run_phase", "ca_vseq startss..\n", UVM_LOW);
        ca_vseq.start(ca_top_env.virt_seqr);
        `uvm_info("ca_stb_wd_sel_Q2Q_test ::run_phase", "ca_vseq endsss..\n", UVM_LOW);

         wait(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab == 1); 
        `uvm_info("ca_stb_wd_sel_Q2Q_test ::run_phase", "after_2nd drv_tfr_complete..\n", UVM_LOW);

        repeat(10)@ (posedge vif.clk);
        result =  ck_xfer_cnt_a(1);
        result =  ck_xfer_cnt_b(1);
       `uvm_info("ca_stb_wd_sel_test ::run_phase", "SCOREBOARD COMPARISON COMPLETED..\n", UVM_LOW);
    end 

        test_end = 1; 
        `uvm_info("ca_stb_wd_sel_Q2Q_test ::run_phase", "END test...\n", UVM_LOW);

endtask : run_test
////////////////////////////////////////////////////////////////
`endif
