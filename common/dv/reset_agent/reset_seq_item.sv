`ifndef _RESET_SEQ_ITEM_
`define _RESET_SEQ_ITEM_
//////////////////////////////////////////////////////////
class reset_seq_item_c extends uvm_sequence_item ;
    
    `uvm_object_utils(reset_seq_item_c)

    //------------------------------------------
    // Data Members
    //------------------------------------------

    bit [15:0]               active_cycle_cnt = 10;
    bit [15:0]               post_cycle_cnt = 5;

    //------------------------------------------
    // Sideband Data Members
    //------------------------------------------

    //------------------------------------------
    // constraints 
    //------------------------------------------
    constraint c_active_cycle_cnt { active_cycle_cnt >= 10 ; active_cycle_cnt <= 20; }
    constraint c_post_cyce_cnt { post_cycle_cnt >= 0 ; post_cycle_cnt <= 5; }
   
    // Standard UVM Methods:
    extern function new(string name = "reset_seq_item");

endclass : reset_seq_item_c

////////////////////////////////////////////////////////////

//--------------------------------------------------
function reset_seq_item_c::new (string name = "reset_seq_item");
    super.new(name);
endfunction : new

//////////////////////////////////////////////////////////
`endif
