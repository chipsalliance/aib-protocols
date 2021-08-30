`ifndef _RESET_SEQR_
`define _RESET_SEQR_

////////////////////////////////////////////////////////////

class reset_seqr_c extends uvm_sequencer #(reset_seq_item_c, reset_seq_item_c);

    // UVM Factory Registration Macro
    `uvm_component_utils(reset_seqr_c)

    // Standard UVM Methods:
    extern function new(string name="reset_seqr", uvm_component parent = null);

endclass: reset_seqr_c
////////////////////////////////////////////////////////////
//---------------------------------------
function reset_seqr_c::new(string name="reset_seqr", uvm_component parent = null);
    super.new(name, parent);
endfunction : new

////////////////////////////////////////////////////////////
`endif
