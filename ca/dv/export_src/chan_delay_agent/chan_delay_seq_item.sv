`ifndef _CHAN_DELAY_SEQ_ITEM_
`define _CHAN_DELAY_SEQ_ITEM_
////////////////////////////////////////////////////////////

`include "uvm_macros.svh"

class chan_delay_seq_item_c extends uvm_sequence_item ;
    
    //------------------------------------------
    // Data Members
    //------------------------------------------
    int              chan_num = -1;

    int              init_delay_clk = 0; // inital delay before sending 1st xfer
    int              chan_delay_clk = 0; // delay each xfer

    bit              burst_en  = 0;
    int              burst_cnt = 0;

    bit [320-1:0]    data = 0; // max size could make an array for later improvement
   

    //------------------------------------------
    // Sideband Data Members
    //------------------------------------------

    `uvm_object_utils_begin(chan_delay_seq_item_c)
        `uvm_field_int(chan_num, UVM_DEFAULT);
        `uvm_field_int(init_delay_clk, UVM_DEFAULT);
        `uvm_field_int(chan_delay_clk, UVM_DEFAULT);
        `uvm_field_int(burst_en, UVM_DEFAULT);
        `uvm_field_int(burst_cnt, UVM_DEFAULT);
        `uvm_field_int(data, UVM_DEFAULT);
    `uvm_object_utils_end

    //------------------------------------------
    // constraints 
    //------------------------------------------
   
    // Standard UVM Methods:
    extern function new(string name = "chan_delay_seq_item");

endclass : chan_delay_seq_item_c

////////////////////////////////////////////////////////////
//--------------------------------------------------
function chan_delay_seq_item_c::new (string name = "chan_delay_seq_item");

    super.new(name);

endfunction : new

//--------------------------------------------------
////////////////////////////////////////////////////////////
`endif
