`ifndef _CA_TX_TB_IN_IF_
`define _CA_TX_TB_IN_IF_
/////////////////////////////////////////////////////////

`include "uvm_macros.svh"

interface ca_tx_tb_in_if #(int BUS_BIT_WIDTH=80, int NUM_CHANNELS=2) (input clk, rst_n);
   
    // signal declaration...
    //---------------------------------------------------
    logic                                         align_done;
    logic                                         tx_online;
    logic  [((NUM_CHANNELS*BUS_BIT_WIDTH)-1):0]   tx_dout;
    logic                                         tx_stb_pos_err;
    logic                                         tx_stb_pos_coding_err;

    // modports... 
    //---------------------------------------------------
    modport mon (
        input     clk,
        input     rst_n,
        //
        input     align_done,
        input     tx_online,
        input     tx_dout,
        input     tx_stb_pos_err,
        input     tx_stb_pos_coding_err
    ); 
    
endinterface : ca_tx_tb_in_if
/////////////////////////////////////////////////////////
`endif
