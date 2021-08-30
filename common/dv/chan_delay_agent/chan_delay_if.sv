`ifndef _CHAN_DELAY_IF_
`define _CHAN_DELAY_IF_
/////////////////////////////////////////////////////////

`include "uvm_macros.svh"

interface chan_delay_if #(int BUS_BIT_WIDTH=80) (input  clk, rst_n);
   
    // signal declaration...
    //---------------------------------------------------
    logic  [BUS_BIT_WIDTH-1:0]   din;
    logic  [BUS_BIT_WIDTH-1:0]   dout;

    // modports... 
    //---------------------------------------------------
    modport mon (
        input     clk,
        input     rst_n,
        //
        input     dout,
        input     din
    ); 
    //---------------------------------------------------
    modport drv (
        input     clk,
        input     rst_n,
        //
        output    dout,
        input     din
    ); 
    
endinterface : chan_delay_if
/////////////////////////////////////////////////////////
`endif
