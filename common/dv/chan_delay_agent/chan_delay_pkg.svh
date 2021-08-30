`ifndef _CHAN_DELAY_PKG_
`define _CHAN_DELAY_PKG_
////////////////////////////////////////////////////////////////////
package chan_delay_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    `include "./chan_delay_seq_item.sv"
    `include "./chan_delay_cfg.sv"
    `include "./chan_delay_drv.sv"
    `include "./chan_delay_mon.sv"
    `include "./chan_delay_seqr.sv"
    //`include "./chan_delay_fcov_mon.sv"
    `include "./chan_delay_agent.sv"

////////////////////////////////////////////////////////////////////
endpackage : chan_delay_pkg
`endif
