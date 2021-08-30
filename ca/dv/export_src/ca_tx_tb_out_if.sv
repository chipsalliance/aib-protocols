`ifndef _CA_TX_TB_OUT_IF_
`define _CA_TX_TB_OUT_IF_
/////////////////////////////////////////////////////////

`include "uvm_macros.svh"

interface ca_tx_tb_out_if #(int BUS_BIT_WIDTH=80, int NUM_CHANNELS=2) (input clk, rst_n);
   
    // signal declaration...
    //---------------------------------------------------
    logic  [((NUM_CHANNELS*BUS_BIT_WIDTH)-1):0]   tx_din;
    logic                                         com_clk;
    logic                                         tx_online;
    logic                                         tx_stb_en;
    logic                                         tx_stb_rcvr;
    logic  [7:0]                                  tx_stb_wd_sel;
    logic  [39:0]                                 tx_stb_bit_sel;
    logic  [7:0]                                  tx_stb_intv;
    logic  [24-1:0]                               ld_ms_rx_transfer_en;
    logic  [24-1:0]                               ld_sl_rx_transfer_en;
    logic  [24-1:0]                               fl_ms_rx_transfer_en;
    logic  [24-1:0]                               fl_sl_rx_transfer_en;
    logic                                         align_done;

    // modports... 
    //---------------------------------------------------
    modport drv (  
        input     clk,
        input     rst_n,
        //
        output    tx_din,
        output    com_clk,
        output    tx_online,
        output    tx_stb_en,
        output    tx_stb_wd_sel,
        output    tx_stb_bit_sel,
        output    tx_stb_intv,
        input     ld_ms_rx_transfer_en,
        input     ld_sl_rx_transfer_en,
        input     fl_ms_rx_transfer_en,
        input     fl_sl_rx_transfer_en,
        input     align_done
    );

    modport mon (
        input     clk,
        input     rst_n,
        //
        input     tx_din,
        input     com_clk,
        input     tx_online,
        input     tx_stb_en,
        input     tx_stb_rcvr,
        input     tx_stb_wd_sel,
        input     tx_stb_bit_sel,
        input     tx_stb_intv,
        input     ld_ms_rx_transfer_en,
        input     ld_sl_rx_transfer_en,
        input     fl_ms_rx_transfer_en,
        input     fl_sl_rx_transfer_en,
        input     align_done
    ); 
    
endinterface : ca_tx_tb_out_if
/////////////////////////////////////////////////////////
`endif
