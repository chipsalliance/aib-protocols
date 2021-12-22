////////////////////////////////////////////////////////////////////////////////////////////////////
//
//        Copyright (C) 2021 Eximius Design
//
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Functional Descript: Channel Alignment Testbench File
//
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CHAN_DELAY_AGENT_
`define _CHAN_DELAY_AGENT_

////////////////////////////////////////////////////////////////////////////
class chan_delay_agent_c #(int BUS_BIT_WIDTH=80) extends uvm_component;
 
    
    // UVM Factory Registration Macro
    //
    `uvm_component_param_utils(chan_delay_agent_c #(BUS_BIT_WIDTH))
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    
    //------------------------------------------
    // Component Members
    //------------------------------------------
    uvm_analysis_port #(chan_delay_seq_item_c)         aport;
    int                                                chan_num = -1;
    chan_delay_mon_c                                   #(BUS_BIT_WIDTH) mon;
    chan_delay_drv_c                                   #(BUS_BIT_WIDTH) drv;
    chan_delay_cfg_c                                   cfg;
    chan_delay_seqr_c                                  seqr;
    //chan_delay_cov_mon_c                             fcov_mon;
    
    //------------------------------------------
    // Methods
    //------------------------------------------
 
    // Standard UVM Methods:
    extern function new(string name = "chan_delay_agent", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void connect_phase( uvm_phase phase );
    extern function void set_chan_num( int _chan );

endclass: chan_delay_agent_c

////////////////////////////////////////////////////////////

function chan_delay_agent_c::new(string name = "chan_delay_agent", uvm_component parent = null);
    
    super.new(name, parent);
    `uvm_info("chan_delay_agent_c::new", $sformatf("BUS_BIT_WIDTH == %0d", BUS_BIT_WIDTH), UVM_LOW);

endfunction

//------------------------------------------
function void chan_delay_agent_c::build_phase( uvm_phase phase );

    // get the interface
    if( !uvm_config_db #( chan_delay_cfg_c )::get(this, "" , "chan_delay_cfg", cfg) )  
        `uvm_fatal("chan_delay_agent::build_phase", "unable to get cfg")

    // analysis port
    aport = new("aport", this);
    
    // Monitor is always present
    mon = chan_delay_mon_c #(BUS_BIT_WIDTH)::type_id::create("mon", this);
    mon.cfg = cfg;

    // Only build the driver and sequencer if active
    if(cfg.agent_active == UVM_ACTIVE) begin
        drv     = chan_delay_drv_c #(BUS_BIT_WIDTH)::type_id::create("drv", this);
        drv.cfg = cfg;
        drv.chan_num = cfg.chan_num;
        seqr = chan_delay_seqr_c::type_id::create("seqr", this);
    end
    
    if(cfg.has_func_cov == 1) begin
        //fcov_mon = chan_delay_agent_cov_mon_c::type_id::create("chan_delay_agent_cov_mon", this);
    end
endfunction: build_phase

//------------------------------------------
function void chan_delay_agent_c::connect_phase( uvm_phase phase );
    
    // connect monitor analysis port
    aport = mon.aport;

    // Only connect the driver and the sequencer if active
    if(cfg.agent_active == UVM_ACTIVE) begin
        drv.seq_item_port.connect(seqr.seq_item_export);
    end

    if(cfg.has_func_cov == 1) begin
        //mon.aport.connect(fcov_mon.fcov_export);
    end

endfunction: connect_phase

//------------------------------------------
function void chan_delay_agent_c::set_chan_num( int _chan );
   chan_num      = _chan;
   if(cfg.agent_active == UVM_ACTIVE) drv.chan_num  = _chan;
   mon.chan_num  = _chan;
endfunction : set_chan_num
////////////////////////////////////////////////////////////////////////////////////
`endif
