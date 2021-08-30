`ifndef _RESET_CFG_
`define _RESET_CFG_
///////////////////////////////////////////////////////////

class reset_cfg_c extends uvm_object;
   
    // UVM Factory Registration Macro
    `uvm_object_utils(reset_cfg_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
   
    uvm_active_passive_enum  active = UVM_ACTIVE;
    bit                      has_func_cov = 0;
   
    //------------------------------------------
    // constraints
    //------------------------------------------
   
    //------------------------------------------
    // Methods
    //------------------------------------------
    // Standard UVM Methods:
    extern function new(string name = "reset_cfg");
    extern function void build_phase( uvm_phase phase );
    extern function void connect_phase( uvm_phase phase );
    extern virtual function void configure( );

endclass: reset_cfg_c

///////////////////////////////////////////////////////////
function reset_cfg_c::new(string name = "reset_cfg");
   
    super.new(name);

endfunction
 
//------------------------------------------
function void reset_cfg_c::build_phase( uvm_phase phase );
    //

endfunction: build_phase
//------------------------------------------
function void reset_cfg_c::connect_phase( uvm_phase phase );
    //

endfunction: connect_phase

//------------------------------------------
function void reset_cfg_c::configure( );
   
    active = UVM_ACTIVE;
    has_func_cov = 0;

endfunction: configure

//////////////////////////////////////////////////////////
`endif
