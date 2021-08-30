`ifndef _CHAN_DELAY_SEQR_
`define _CHAN_DELAY_SEQR_

////////////////////////////////////////////////////////////

class chan_delay_seqr_c extends uvm_sequencer #(chan_delay_seq_item_c, chan_delay_seq_item_c);

    // UVM Factory Registration Macro
    `uvm_component_utils(chan_delay_seqr_c)

    // Standard UVM Methods:
    extern function new(string name="chan_delay_seqr", uvm_component parent = null);

endclass: chan_delay_seqr_c
////////////////////////////////////////////////////////////
//---------------------------------------
function chan_delay_seqr_c::new(string name="chan_delay_seqr", uvm_component parent = null);
    super.new(name, parent);
endfunction : new

////////////////////////////////////////////////////////////
`endif
