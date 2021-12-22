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
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CA_BASIC_TEST_
`define _CA_BASIC_TEST_
////////////////////////////////////////////////////////////

class ca_basic_test_c extends base_ca_test_c;
 
    // UVM Factory Registration Macro
    `uvm_component_utils(ca_basic_test_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    ca_seq_lib_c    ca_vseq;
    uvm_event       sinit_event;
 
    //------------------------------------------
    // Component Members
    //------------------------------------------
 
    //------------------------------------------
    // Methods
    //------------------------------------------
 
    // Standard UVM Methods:
    extern function new(string name = "ca_basic_test", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void start_of_simulation( );
    extern task run_phase( uvm_phase phase);
    extern task run_test( uvm_phase phase );
 
endclass: ca_basic_test_c
////////////////////////////////////////////////////////////

//------------------------------------------
function ca_basic_test_c::new(string name = "ca_basic_test", uvm_component parent = null);
    super.new(name, parent);
endfunction : new
 
//------------------------------------------
function void ca_basic_test_c::build_phase( uvm_phase phase );
    // build in base test 
    super.build_phase(phase);
endfunction: build_phase

//------------------------------------------
function void ca_basic_test_c::start_of_simulation( );
    //
endfunction: start_of_simulation 
 
//------------------------------------------
// run phase 
task ca_basic_test_c::run_phase(uvm_phase phase);
`ifdef CA_YELLOW_OVAL
    super.run_phase(phase);
    $display("\n CA TEST :: run phase at %0t waiting for sinit_event",$time);
     sinit_event = uvm_event_pool::get_global("ev_ab");	
     `uvm_info(get_type_name(),$sformatf(" Wating done for AIB initialization ready event ... starting CA test"), UVM_LOW)
     ////sinit_event.wait_trigger;
`endif

    fork
        run_test(phase);
        global_timer(); // and check for error count
        ck_eot(phase);
    join
    #1us;
    $display("\n CA END OF TEST %0t",$time);

endtask : run_phase

//------------------------------------------
task ca_basic_test_c::run_test(uvm_phase phase);

    `uvm_info("ca_basic_test_c::run_phase", "START test...", UVM_LOW);
     ca_vseq = ca_seq_lib_c::type_id::create("ca_vseq");
     base_test = 1;
     ca_vseq.start(ca_top_env.virt_seqr);
    `uvm_info("ca_basic_test_c::run_phase", "END test...\n", UVM_LOW);

endtask : run_test
////////////////////////////////////////////////////////////////
`endif
