`ifndef _RESET_IF_
`define _RESET_IF_
/////////////////////////////////////////////////////////

`include "uvm_macros.svh"

interface reset_if (input clk);
   
    logic   reset_l;

    //---------------------------------------------------
    modport drv (  
        input   clk,
        output  reset_l
    );

    modport mon (
        input   clk,
        input   reset_l
    ); 
    
endinterface : reset_if

/////////////////////////////////////////////////////////
`endif
