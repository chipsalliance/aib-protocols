`ifndef _CA_TX_TB_OUT_PKG_
`define _CA_TX_TB_OUT_PKG_
////////////////////////////////////////////////////////////////////
package ca_tx_tb_out_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
//    `include "./ca_seq_item.sv"
    `include "./ca_tx_tb_out_cfg.sv"
    `include "./ca_tx_tb_out_drv.sv"
    `include "./ca_tx_tb_out_mon.sv"
    `include "./ca_tx_tb_out_seqr.sv"
    //`include "./ca_tx_tb_out_fcov_mon.sv"
    `include "./ca_tx_tb_out_agent.sv"

////////////////////////////////////////////////////////////////////
endpackage : ca_tx_tb_out_pkg
`endif
