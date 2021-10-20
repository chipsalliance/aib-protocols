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
//
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_SEQ_LIB_
`define _CA_SEQ_LIB_
////////////////////////////////////////////////////////////

typedef uvm_sequence #(uvm_sequence_item) uvm_virtual_sequence ;

class ca_seq_lib_c extends uvm_virtual_sequence ;
    
    `uvm_object_utils(ca_seq_lib_c)
    `uvm_declare_p_sequencer(virt_seqr_c)

    reset_seq_c          reset_seq;
    ca_tx_traffic_seq_c  ca_die_a_tx_traffic_seq;
    ca_tx_traffic_seq_c  ca_die_b_tx_traffic_seq;
    
    //------------------------------------------
    extern function new(string name = "ca_seq_lib");
    extern task body();
    extern function void set_vars();

endclass : ca_seq_lib_c

////////////////////////////////////////////////////////////
//------------------------------------------
function ca_seq_lib_c::new(string name = "ca_seq_lib");
    
    super.new(name);

endfunction : new

//------------------------------------------
function void ca_seq_lib_c::set_vars();
    
    reset_seq                = reset_seq_c::type_id::create("reset_seq");

    ca_die_a_tx_traffic_seq  = ca_tx_traffic_seq_c::type_id::create("ca_die_a_tx_traffic_seq");
    ca_die_a_tx_traffic_seq.my_name = "DIE_A";
    ca_die_a_tx_traffic_seq.xfer_cnt = p_sequencer.ca_cfg.ca_knobs.tx_xfer_cnt_die_a;
    ca_die_a_tx_traffic_seq.ca_cfg = p_sequencer.ca_cfg;
    if(ca_die_a_tx_traffic_seq.ca_cfg == null) `uvm_fatal("CA_SEQ_LIB", $sformatf("ca_die_a_tx_traffic_seq.ca_cfg == NULL !!!"))

    ca_die_b_tx_traffic_seq  = ca_tx_traffic_seq_c::type_id::create("ca_die_b_tx_traffic_seq");
    ca_die_b_tx_traffic_seq.my_name = "DIE_B";
    ca_die_b_tx_traffic_seq.xfer_cnt = p_sequencer.ca_cfg.ca_knobs.tx_xfer_cnt_die_b;
    ca_die_b_tx_traffic_seq.ca_cfg = p_sequencer.ca_cfg;
    if(ca_die_b_tx_traffic_seq.ca_cfg == null) `uvm_fatal("CA_SEQ_LIB", $sformatf("ca_die_b_tx_traffic_seq.ca_cfg == NULL !!!"))

endfunction : set_vars

//------------------------------------------
task ca_seq_lib_c::body();

    set_vars(); 
    `uvm_info("body", "START SEQ LIB...", UVM_LOW);

    reset_seq.start (p_sequencer.reset_seqr, this);
 
   `ifdef CA_YELLOW_OVAL
        wait(100)@(posedge p_sequencer.gen_vif.clk);
   `else 
        `ifndef P2P_LITE
         while(p_sequencer.gen_vif.aib_ready !== 1'b1) begin
             wait(100)@(posedge p_sequencer.gen_vif.clk);
         end
        `else
             wait(100)@(posedge p_sequencer.gen_vif.clk);
        `endif
    `endif
    
    fork
        ca_die_a_tx_traffic_seq.start (p_sequencer.ca_die_a_tx_tb_out_seqr, this);
        ca_die_b_tx_traffic_seq.start (p_sequencer.ca_die_b_tx_tb_out_seqr, this);
    join
    
    `uvm_info("ca_seq_lib_c::body", "END body of seq lib...\n", UVM_LOW);

endtask : body

////////////////////////////////////////////////////////////
`endif
