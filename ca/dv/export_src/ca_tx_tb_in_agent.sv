////////////////////////////////////////////////////////////////////////////////////////////////////
//
//        Copyright (C) 2021 Eximius Design
//                All Rights Reserved
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Eximius Design
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

`ifndef _TX_CA_TB_IN_AGENT_
`define _TX_CA_TB_IN_AGENT_

////////////////////////////////////////////////////////////////////////////
class ca_tx_tb_in_agent_c #(int BUS_BIT_WIDTH=80, int NUM_CHANNELS=2) extends uvm_component;
 
    
    // UVM Factory Registration Macro
    //
    `uvm_component_param_utils(ca_tx_tb_in_agent_c #(BUS_BIT_WIDTH, NUM_CHANNELS))
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    
    //------------------------------------------
    // Component Members
    //------------------------------------------
    uvm_analysis_port #(ca_data_pkg::ca_seq_item_c)     aport;
    string                                              my_name = "";
    ca_tx_tb_in_mon_c                                   #(BUS_BIT_WIDTH, NUM_CHANNELS) mon;
    ca_tx_tb_in_drv_c                                   #(BUS_BIT_WIDTH, NUM_CHANNELS) drv;
    ca_tx_tb_in_cfg_c                                   cfg; // share w/ out agent
    ca_tx_tb_in_seqr_c                                  seqr;
    //ca_tx_tb_in_cov_mon_c                             fcov_mon;
    
    //------------------------------------------
    // Methods
    //------------------------------------------
 
    // Standard UVM Methods:
    extern function new(string name = "ca_tx_tb_in_agent", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void connect_phase( uvm_phase phase );
    extern function void set_my_name( string _name );

endclass: ca_tx_tb_in_agent_c

////////////////////////////////////////////////////////////

function ca_tx_tb_in_agent_c::new(string name = "ca_tx_tb_in_agent", uvm_component parent = null);
    
    super.new(name, parent);
    `uvm_info("ca_tx_tb_in_agent_c::new", $sformatf("BUS_BIT_WIDTH == %0d", BUS_BIT_WIDTH), UVM_LOW);
    `uvm_info("ca_tx_tb_in_agent_c::new", $sformatf("NUM_CHANNELS  == %0d", NUM_CHANNELS), UVM_LOW);

endfunction

//------------------------------------------
function void ca_tx_tb_in_agent_c::build_phase( uvm_phase phase );

    // get the cfg 
    if( !uvm_config_db #( ca_tx_tb_in_cfg_c )::get(this, "" , "ca_tx_tb_in_cfg", cfg) )  
        `uvm_fatal("ca_tx_tb_in_agent::build_phase", "unable to get cfg")

    // analysis port
    aport = new("aport", this);
    
    // Monitor is always present
    mon = ca_tx_tb_in_mon_c #(BUS_BIT_WIDTH, NUM_CHANNELS)::type_id::create("mon", this);
    mon.cfg = cfg;

    // Only build the driver and sequencer if active
    if(cfg.agent_active == UVM_ACTIVE) begin
        drv     = ca_tx_tb_in_drv_c #(BUS_BIT_WIDTH, NUM_CHANNELS)::type_id::create("drv", this);
        drv.cfg = cfg;
        seqr = ca_tx_tb_in_seqr_c::type_id::create("seqr", this);
    end
    
    if(cfg.has_func_cov == 1) begin
        //fcov_mon = ca_tx_tb_in_agent_cov_mon_c::type_id::create("ca_tx_tb_in_agent_cov_mon", this);
    end
endfunction: build_phase

//------------------------------------------
function void ca_tx_tb_in_agent_c::connect_phase( uvm_phase phase );
    
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
function void ca_tx_tb_in_agent_c::set_my_name( string _name );
   my_name      = _name;
   if(cfg.agent_active == UVM_ACTIVE) begin
       drv.my_name  = _name;
   end
   mon.my_name  = _name;
endfunction : set_my_name
////////////////////////////////////////////////////////////////////////////////////
`endif
