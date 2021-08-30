`ifndef _RESET_PKG_
`define _RESET_PKG_
////////////////////////////////////////////////////////////////////
package reset_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    `include "./reset_seq_item.sv"
    `include "./reset_cfg.sv"
    `include "./reset_drv.sv"
    `include "./reset_mon.sv"
    `include "./reset_seq.sv"
    `include "./reset_seqr.sv"
    //`include "./reset_fcov_mon.sv"
    `include "./reset_agent.sv"

////////////////////////////////////////////////////////////////////
endpackage : reset_pkg
`endif
