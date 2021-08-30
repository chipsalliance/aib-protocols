`ifndef _RESET_MON_
`define _RESET_MON_

////////////////////////////////////////////////////////////

class reset_mon_c extends uvm_monitor ;

    // register w/ the factory
   `uvm_component_utils(reset_mon_c)

    // Virtual Interface
    virtual reset_if  vif;

    //------------------------------------------
    // Data Members
    //------------------------------------------
    reset_cfg_c     reset_cfg;

    //------------------------------------------
    // Component Members
    //------------------------------------------
    uvm_analysis_port #(reset_seq_item_c) aport;

    //------------------------------------------
    // Methods
    //------------------------------------------
    // Standard UVM Methods:
    //------------------------------------------
    extern function new(string name = "reset_mon", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task mon_reset();

endclass : reset_mon_c

/////////////////////////////////////////////////
//----------------------------------------------
function reset_mon_c::new(string name = "reset_mon", uvm_component parent = null);
    super.new(name, parent);
endfunction

//----------------------------------------------
function void reset_mon_c::build_phase(uvm_phase phase);
    aport = new("aport", this);

    //if (!uvm_config_db #(reset_cfg_c)::get(this, "", "reset_cfg", reset_cfg) )
    //    `uvm_fatal("build_phase", "Cannot get() configuration reset_cfg from uvm_config_db. Have you set() it?")

   if( !uvm_config_db #( virtual reset_if )::get(this, "" , "reset_vif", vif) )
       `uvm_error("build_phase", "unable to get avalon vif")

endfunction: build_phase

//----------------------------------------------
task reset_mon_c::run_phase(uvm_phase phase);
    fork
        mon_reset();
    join
endtask : run_phase

//----------------------------------------------
task reset_mon_c::mon_reset();

    bit                 in_reset = 0 ;
    reset_seq_item_c    reset_si ;

    forever begin @(posedge vif.clk)

        if(vif.reset_l === 1'b0) begin
            if(in_reset == 0) begin
                in_reset = 1;
                reset_si = reset_seq_item_c::type_id::create("reset_si");
                // notify scoreboard that a reset has occured
                `uvm_info ("mon_reset", "reset --> scoreboard", UVM_LOW)
                aport.write(reset_si);  
                end
            end // reset_l
        else begin // reset_l = 1 non reset
            `uvm_info ("mon_reset", "reset re-armed", UVM_HIGH)
             in_reset = 0;
        end // begin

    end // posedge clk

endtask : mon_reset
/////////////////////////////////////////////////////////
`endif
