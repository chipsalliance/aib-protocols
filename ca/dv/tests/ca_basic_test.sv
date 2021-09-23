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

    fork
        run_test(phase);
        global_timer(); // and check for error count
        ck_eot(phase);
    join

endtask : run_phase

//------------------------------------------
task ca_basic_test_c::run_test(uvm_phase phase);

    `uvm_info("ca_basic_test_c::run_phase", "START test...", UVM_LOW);
     ca_vseq = ca_seq_lib_c::type_id::create("ca_vseq");
     //ca_top_env.ca_scoreboard.do_compare_rx_dout = 1'b0; ///Don't compare RxDout with expected rx_dout (tx-dout)
     ca_vseq.start(ca_top_env.virt_seqr);
    `uvm_info("ca_basic_test_c::run_phase", "END test...\n", UVM_LOW);

endtask : run_test
////////////////////////////////////////////////////////////////
`endif
