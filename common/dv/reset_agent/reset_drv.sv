`ifndef _RESET_DRV_
`define _RESET_DRV_

////////////////////////////////////////////////////////////

class reset_drv_c extends uvm_driver #(reset_seq_item_c, reset_seq_item_c);

    // UVM Factory Registration Macro
    `uvm_component_utils(reset_drv_c)

    //------------------------------------------
    // Data Members
    //------------------------------------------
    reset_cfg_c          reset_cfg;
    virtual reset_if     vif;
    string               name = "";

    // size of the req fifo used for back pressure
 
    // Standard UVM Methods:
    extern function new(string name = "reset_drv", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task drv_reset( );

endclass: reset_drv_c
////////////////////////////////////////////////////////////

//----------------------------------------------
function reset_drv_c::new(string name = "reset_drv", uvm_component parent = null);
    super.new(name, parent);
endfunction : new

//----------------------------------------------
function void reset_drv_c::build_phase(uvm_phase phase);
 
   if (!uvm_config_db #(reset_cfg_c)::get(this, "", "reset_cfg", reset_cfg) )
       `uvm_fatal("build_phase", "Cannot get() configuration reset_cfg from uvm_config_db. Have you set() it?")
   
   if( !uvm_config_db #( virtual reset_if )::get(this, "" , "reset_vif", vif) )
       `uvm_error("build_phase", "unable to get reset vif")

 
endfunction : build_phase

//----------------------------------------------
task reset_drv_c::run_phase(uvm_phase phase);
    fork
        drv_reset();
    join
endtask : run_phase

//----------------------------------------------
task reset_drv_c::drv_reset();

    reset_seq_item_c    trig ;    

    vif.reset_l <= 1'b0;

    forever begin
        seq_item_port.get_next_item(trig);
        `uvm_info ("RESET DRV", "GOT seq item", UVM_LOW)

        // drive reset
        vif.reset_l <= 1'b0;
        `uvm_info ("drv_reset", "reset ^^^\.....", UVM_LOW)

        // hold reset
        repeat(trig.active_cycle_cnt)@(posedge vif.clk);

        // release
        vif.reset_l <= 1'b1;
        repeat(trig.post_cycle_cnt)@(posedge vif.clk);
        `uvm_info ("drv_reset", ".../^^^ reset done ^^^", UVM_MEDIUM)

        seq_item_port.item_done(trig);
        end

endtask : drv_reset
////////////////////////////////////////////////////////////
`endif
