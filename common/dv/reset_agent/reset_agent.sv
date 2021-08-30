`ifndef _RESET_AGENT_
`define _RESET_AGENT_
//////////////////////////////////////////////////////
class reset_agent_c extends uvm_component;
 
   
    // UVM Factory Registration Macro
    `uvm_component_utils(reset_agent_c)
 
   
    //------------------------------------------
    // Data Members
    //------------------------------------------
   
    reset_cfg_c    reset_cfg;

    //------------------------------------------
    // Component Members
    //------------------------------------------
    uvm_analysis_port #(reset_seq_item_c)  aport;
    reset_mon_c                            reset_mon; 
    reset_seqr_c                           reset_seqr;
    reset_drv_c                            reset_drv;
    //reset_cov_mon_c                        reset_fcov_mon;
   
    //------------------------------------------
    // Methods
    //------------------------------------------
    // Standard UVM Methods:
    //------------------------------------------
    extern function new(string name = "reset_agent", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void connect_phase( uvm_phase phase );

endclass: reset_agent_c

////////////////////////////////////////////////////////////
function reset_agent_c::new(string name = "reset_agent", uvm_component parent = null);
   
    super.new(name, parent);

endfunction : new

//------------------------------------------
function void reset_agent_c::build_phase( uvm_phase phase );
   
    if( !uvm_config_db #( reset_cfg_c )::get(this, "", "reset_cfg", reset_cfg) ) 
        `uvm_fatal("build_phase", "unable to get reset config")

    //analysis port
    aport = new("aport", this);
   
    // Monitor is always present
   
    reset_mon = reset_mon_c::type_id::create("reset_mon", this);
    reset_mon.reset_cfg = reset_cfg;

    // Only build the driver and sequencer if active
    if(reset_cfg.active == UVM_ACTIVE) begin
        reset_drv = reset_drv_c::type_id::create("reset_drv", this);
        reset_drv.reset_cfg = reset_cfg;
        reset_seqr = reset_seqr_c::type_id::create("reset_seqr", this);
    end

    if(reset_cfg.has_func_cov == 1) begin
        //reset_cov_mon = reset_cov_mon_c::type_id::create("reset_cov_mon", this);
    end

endfunction: build_phase

//------------------------------------------
function void reset_agent_c::connect_phase( uvm_phase phase );
   
    // connect monitor analysis port
    reset_mon.aport.connect(aport);
   
    // Only connect the driver and the sequencer if active
    if(reset_cfg.active == UVM_ACTIVE) begin
        reset_drv.seq_item_port.connect(reset_seqr.seq_item_export);
    end

    if(reset_cfg.has_func_cov == 1) begin
        //reset_fcov_mon.aport.connect(reset__mon.analysis_export);
    end

endfunction: connect_phase
////////////////////////////////////////////////////////////
`endif
