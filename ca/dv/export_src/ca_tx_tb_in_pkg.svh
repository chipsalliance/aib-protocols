`ifndef _CA_TX_TB_IN_PKG_
`define _CA_TX_TB_IN_PKG_
////////////////////////////////////////////////////////////////////
package ca_tx_tb_in_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    `include "./ca_seq_item.sv"
    `include "./ca_tx_tb_in_cfg.sv"
    `include "./ca_tx_tb_in_drv.sv"
    `include "./ca_tx_tb_in_mon.sv"
    `include "./ca_tx_tb_in_seqr.sv"
    //`include "./ca_tx_tb_in_fcov_mon.sv"
    `include "./ca_tx_tb_in_agent.sv"

////////////////////////////////////////////////////////////////////
endpackage : ca_tx_tb_in_pkg
`endif