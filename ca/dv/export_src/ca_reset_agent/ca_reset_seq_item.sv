`ifndef _CA_RESET_SEQ_ITEM_
`define _CA_RESET_SEQ_ITEM_
//////////////////////////////////////////////////////////
class ca_reset_seq_item_c extends uvm_sequence_item ;
    

    //------------------------------------------
    // Data Members
    //------------------------------------------

  int               active_cycle_cnt ;
  int               post_cycle_cnt ;

    //------------------------------------------
    // UVM Factory Registration Macro
    //------------------------------------------
    `uvm_object_utils_begin(ca_reset_seq_item_c)
        `uvm_field_int(active_cycle_cnt,      UVM_DEFAULT);
        `uvm_field_int(post_cycle_cnt,        UVM_DEFAULT);
    `uvm_object_utils_end
    //------------------------------------------
    // Sideband Data Members
    //------------------------------------------

    //------------------------------------------
    // constraints 
    //------------------------------------------
    //constraint c_active_cycle_cnt { active_cycle_cnt >= 10 ; active_cycle_cnt <= 20; }
    constraint c_active_cycle_cnt { active_cycle_cnt == 200 ; active_cycle_cnt == 200; }
    constraint c_post_cyce_cnt { post_cycle_cnt >= 0 ; post_cycle_cnt <= 5; }
   
    // Standard UVM Methods:
    extern function new(string name = "ca_reset_seq_item");

endclass : ca_reset_seq_item_c

////////////////////////////////////////////////////////////

//--------------------------------------------------
function ca_reset_seq_item_c::new (string name = "ca_reset_seq_item");
    super.new(name);
endfunction : new

//////////////////////////////////////////////////////////
`endif
