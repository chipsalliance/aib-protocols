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

`ifndef _CHAN_DELAY_MON_
`define _CHAN_DELAY_MON_
///////////////////////////////////////////////////////////////////
class chan_delay_mon_c #(int BUS_BIT_WIDTH=80) extends uvm_monitor ;
    
    // register w/ the factory
    //------------------------------------------
    `uvm_component_param_utils(chan_delay_mon_c #(BUS_BIT_WIDTH))

    // Virtual Interface
    //------------------------------------------
    chan_delay_cfg_c        cfg;
    virtual chan_delay_if   #(.BUS_BIT_WIDTH(BUS_BIT_WIDTH)) vif;  

    //------------------------------------------
    // Data Members
    //------------------------------------------
    int                     chan_num = -1;
    
    //------------------------------------------
    // Component Members
    //------------------------------------------
    uvm_analysis_port #(chan_delay_seq_item_c) aport;

    //------------------------------------------
    // Standard UVM Methods:
    //------------------------------------------
    extern function new(string name = "chan_delay_mon", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    
    extern task mon_delay(); 
    extern virtual function void check_phase(uvm_phase phase);

endclass : chan_delay_mon_c

/////////////////////////////////////////////////

//----------------------------------------------
function chan_delay_mon_c::new(string name = "chan_delay_mon", uvm_component parent = null);
    
    super.new(name, parent);
    `uvm_info("chan_delay_mon_c::new", $sformatf("BUS_BIT_WIDTH == %0d", BUS_BIT_WIDTH), UVM_LOW);

endfunction : new

//----------------------------------------------
function void chan_delay_mon_c::build_phase(uvm_phase phase);
    
    aport = new("aport", this);

    // get the interface
    if( !uvm_config_db #( virtual chan_delay_if #(BUS_BIT_WIDTH))::get(this, "" , "chan_delay_vif", vif) )  
        `uvm_fatal("build_phase", "unable to get chan_delay vif")

endfunction: build_phase

//----------------------------------------------
task chan_delay_mon_c::run_phase(uvm_phase phase);
    
    fork
        mon_delay();
    join 

endtask : run_phase

//----------------------------------------------
task chan_delay_mon_c::mon_delay(); 

    bit [BUS_BIT_WIDTH-1:0]              data = 0; 
    chan_delay_seq_item_c                delay_item;

    forever begin @(posedge vif.clk)
        
        if(vif.rst_n === 1'b0) begin 
            // reset state
            end
        else begin // non reset state
           /* 
           delay_item = chan_delay_seq_item_c::type_id::create("ca_item");
           delay_item.chan_num        = chan_num;
           aport.write(delay_item); 
           */ 
        end // non reset 
    
    end // clk

endtask : mon_delay
    
//---------------------------------------------
function void chan_delay_mon_c::check_phase(uvm_phase phase);
    //
endfunction : check_phase

////////////////////////////////////////////////////////////
`endif

