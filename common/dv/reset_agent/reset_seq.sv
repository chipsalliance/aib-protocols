`ifndef _RESET_SEQ_
`define _RESET_SEQ_
////////////////////////////////////////////////////////////

class reset_seq_c extends uvm_sequence #(reset_seq_item_c);

    `uvm_object_utils(reset_seq_c)

    extern function new(string name = "reset_seq");
    extern task body();

endclass : reset_seq_c

////////////////////////////////////////////////////////////

//------------------------------------------
function reset_seq_c::new(string name = "reset_seq");
    super.new(name);
endfunction : new

//------------------------------------------
// body
//------------------------------------------
task reset_seq_c::body();

    reset_seq_item_c   reset_trig;

    `uvm_info("body", "START reset seq...", UVM_LOW);
   
     reset_trig = reset_seq_item_c::type_id::create("reset_trig");

    `uvm_info("body", "Sending reset trigger", UVM_MEDIUM);
     start_item(reset_trig);
     finish_item(reset_trig);

    `uvm_info("body", "END reset seq...\n", UVM_LOW);

endtask : body
////////////////////////////////////////////////////////////
`endif
