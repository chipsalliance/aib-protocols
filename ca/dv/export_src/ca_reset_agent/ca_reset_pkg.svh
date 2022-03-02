`ifndef _CA_RESET_PKG_
`define _CA_RESET_PKG_
////////////////////////////////////////////////////////////////////
package ca_reset_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    `include "./ca_reset_seq_item.sv"
    `include "./ca_reset_cfg.sv"
    `include "./ca_reset_drv.sv"
    `include "./ca_reset_mon.sv"
    `include "./ca_reset_seq.sv"
    `include "./ca_reset_seqr.sv"
    //`include "./ca_reset_fcov_mon.sv"
    `include "./ca_reset_agent.sv"

////////////////////////////////////////////////////////////////////
endpackage : ca_reset_pkg
`endif
