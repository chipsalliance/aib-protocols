`ifndef _CA_RESET_SEQ_
`define _CA_RESET_SEQ_
////////////////////////////////////////////////////////////

class ca_reset_seq_c extends uvm_sequence #(ca_reset_seq_item_c);

   int               active_cycle_cnt ;
   int               post_cycle_cnt ;
    `uvm_object_utils(ca_reset_seq_c)

    extern function new(string name = "ca_reset_seq");
    extern task body();

endclass : ca_reset_seq_c

////////////////////////////////////////////////////////////

//------------------------------------------
function ca_reset_seq_c::new(string name = "ca_reset_seq");
    super.new(name);
endfunction : new

//------------------------------------------
// body
//------------------------------------------
task ca_reset_seq_c::body();

    ca_reset_seq_item_c   reset_trig;

    `uvm_info("body", "START reset seq...", UVM_LOW);
   
     reset_trig = ca_reset_seq_item_c::type_id::create("reset_trig");

    reset_trig.active_cycle_cnt =  this.active_cycle_cnt;
    reset_trig.post_cycle_cnt   =  this.post_cycle_cnt;

    `uvm_info("body", "Sending reset trigger", UVM_MEDIUM);
     start_item(reset_trig);
     finish_item(reset_trig);

    `uvm_info("body", "END reset seq...\n", UVM_LOW);

endtask : body
////////////////////////////////////////////////////////////
`endif
