`ifndef _CA_RESET_SEQR_
`define _CA_RESET_SEQR_

////////////////////////////////////////////////////////////

class ca_reset_seqr_c extends uvm_sequencer #(ca_reset_seq_item_c, ca_reset_seq_item_c);

    // UVM Factory Registration Macro
    `uvm_component_utils(ca_reset_seqr_c)

    // Standard UVM Methods:
    extern function new(string name="ca_reset_seqr", uvm_component parent = null);

endclass: ca_reset_seqr_c
////////////////////////////////////////////////////////////
//---------------------------------------
function ca_reset_seqr_c::new(string name="ca_reset_seqr", uvm_component parent = null);
    super.new(name, parent);
endfunction : new

////////////////////////////////////////////////////////////
`endif
