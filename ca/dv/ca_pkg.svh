`ifndef _CA_PKG_
`define _CA_PKG_
////////////////////////////////////////////////////////////////////
package ca_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // TB generated defines
    //--------------------------------------------------- 
    
    // TB knobs 
    //--------------------------------------------------- 
    `include "./tests/ca_knobs.sv"
    
    // seq items and data structs 
    //--------------------------------------------------- 
    import ca_data_pkg::*;
    
    // agent pkgs 
    //--------------------------------------------------- 
    import reset_pkg::*;
    import chan_delay_pkg::*;
    import ca_tx_tb_out_pkg::*;
    import ca_tx_tb_in_pkg::*;
    import ca_rx_tb_in_pkg::*;

    // cfg class 
    //--------------------------------------------------- 
    `include "./tests/ca_cfg.sv"

    // scoreboard 
    //--------------------------------------------------- 
    `include "./export_src/ca_coverage.sv"
    `include "./export_src/ca_scoreboard.sv"
    
    // seqs classes
    //--------------------------------------------------- 
    `include "./seqs/virt_seqr.sv"
    `include "./seqs/ca_tx_traffic_seq.sv"
    `include "./seqs/ca_seq_lib.sv"

    // env 
    //--------------------------------------------------- 
    `include "./tb/ca_top_env.sv"
 
    // tests 
    //--------------------------------------------------- 
    `include "./tests/base_ca_test.sv"
    `include "./tests/ca_basic_test.sv"
    
////////////////////////////////////////////////////////////////////
endpackage : ca_pkg
`endif
