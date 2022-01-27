`ifndef _CA_RESET_CFG_
`define _CA_RESET_CFG_
///////////////////////////////////////////////////////////

class ca_reset_cfg_c extends uvm_object;
   
    // UVM Factory Registration Macro
    `uvm_object_utils(ca_reset_cfg_c)
 
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
    extern function new(string name = "ca_reset_cfg");
    extern function void build_phase( uvm_phase phase );
    extern function void connect_phase( uvm_phase phase );
    extern virtual function void configure( );

endclass: ca_reset_cfg_c

///////////////////////////////////////////////////////////
function ca_reset_cfg_c::new(string name = "ca_reset_cfg");
   
    super.new(name);

endfunction
 
//------------------------------------------
function void ca_reset_cfg_c::build_phase( uvm_phase phase );
    //

endfunction: build_phase
//------------------------------------------
function void ca_reset_cfg_c::connect_phase( uvm_phase phase );
    //

endfunction: connect_phase

//------------------------------------------
function void ca_reset_cfg_c::configure( );
   
    active = UVM_ACTIVE;
    has_func_cov = 0;

endfunction: configure

//////////////////////////////////////////////////////////
`endif
