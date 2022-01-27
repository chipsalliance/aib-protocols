`ifndef _CA_RESET_IF_
`define _CA_RESET_IF_
/////////////////////////////////////////////////////////

`include "uvm_macros.svh"

interface ca_reset_if (input clk);
   
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
    
endinterface : ca_reset_if

/////////////////////////////////////////////////////////
`endif
