`ifndef _CA_GEN_IF_
`define _CA_GEN_IF_
/////////////////////////////////////////////////////////

`include "uvm_macros.svh"

interface ca_gen_if (input clk, rst_n);
   
    // signal declaration...
    //---------------------------------------------------
    logic                                         aib_ready;

    // modports... 
    //---------------------------------------------------
    modport mon (  
        input     clk,
        input     rst_n,
        input     aib_ready
    );

endinterface : ca_gen_if
/////////////////////////////////////////////////////////
`endif
