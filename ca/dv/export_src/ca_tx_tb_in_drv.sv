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

`ifndef _CA_TX_TB_IN_DRV_
`define _CA_TX_TB_IN_DRV_

///////////////////////////////////////////////////////////
class ca_tx_tb_in_drv_c #(int BUS_BIT_WIDTH=80, int NUM_CHANNELS=2) extends uvm_driver #(ca_data_pkg::ca_seq_item_c, ca_data_pkg::ca_seq_item_c);

    // UVM Factory Registration Macro
    `uvm_component_param_utils(ca_tx_tb_in_drv_c #(BUS_BIT_WIDTH, NUM_CHANNELS))
    
    //------------------------------------------
    // Data Members
    //------------------------------------------
    virtual ca_tx_tb_in_if     #(.BUS_BIT_WIDTH(BUS_BIT_WIDTH), .NUM_CHANNELS(NUM_CHANNELS)) vif;
    ca_tx_tb_in_cfg_c          cfg; // share w/ out agent
    string                      my_name = "";

    // queues for holding seq items for injection into RTL
    ca_data_pkg::ca_seq_item_c        tx_q[$];
    bit                               got_tx = 0;
    int	                              max_tb_inj_depth = 50;

    //------------------------------------------
    // Standard UVM Methods:
    //------------------------------------------
    extern function new(string name = "ca_tx_tb_in_drv", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task get_item_from_seq();
    extern virtual function void check_phase(uvm_phase phase);
    
    //------------------------------------------
    // Custom UVM Methods:
    //------------------------------------------
    extern task drv_tx();
    extern function void drv_tx_idle();

endclass: ca_tx_tb_in_drv_c

////////////////////////////////////////////////////////////
//----------------------------------------------
function ca_tx_tb_in_drv_c::new(string name = "ca_tx_tb_in_drv", uvm_component parent = null);
    
    super.new(name, parent);
    
        `uvm_info("ca_tx_tb_in_drv_c::new", $sformatf("%s BUS_BIT_WIDTH == %0d", my_name, BUS_BIT_WIDTH), UVM_LOW);
        `uvm_info("ca_tx_tb_in_drv_c::new", $sformatf("%s NUM_CHANNELS  == %0d", my_name, NUM_CHANNELS), UVM_LOW);

   endfunction : new

//----------------------------------------------
function void ca_tx_tb_in_drv_c::build_phase(uvm_phase phase);

    // get the interface
    if( !uvm_config_db #( virtual ca_tx_tb_in_if #(BUS_BIT_WIDTH, NUM_CHANNELS) )::get(this, "" , "ca_tx_tb_in_vif", vif) ) 
    `uvm_fatal("build_phase", "unable to get ca_tx_tb_in vif")

endfunction : build_phase

//----------------------------------------------
task ca_tx_tb_in_drv_c::run_phase(uvm_phase phase);
    
   fork
        get_item_from_seq();
        drv_tx();
    join
endtask : run_phase

//---------------------------------------------
task ca_tx_tb_in_drv_c::get_item_from_seq();
    
    ca_data_pkg::ca_seq_item_c    req_item;
    int                           req_cnt = 0;
    
    forever begin @(posedge vif.clk)
        while(tx_q.size() < max_tb_inj_depth) begin
            seq_item_port.get_next_item(req_item);
            req_cnt++;
            `uvm_info("get_item_from_seq", $sformatf("%s rx-ing %0d pkt from seq tx_q: %0d/%0d", 
                my_name, req_cnt, tx_q.size(), max_tb_inj_depth), UVM_MEDIUM);
            tx_q.push_back(req_item);
            seq_item_port.item_done();
        end // while
    end // forever

endtask : get_item_from_seq 

//----------------------------------------------
task ca_tx_tb_in_drv_c::drv_tx();
    
    ca_data_pkg::ca_seq_item_c     tx_item;      
    int                            tx_xfer = 0;
    bit [7:0]	                   count = 0;
    
    bit [((BUS_BIT_WIDTH*NUM_CHANNELS)-1):0]  tx_data = 0; 
    
    forever begin @(posedge vif.clk)
        if(vif.rst_n === 1'b0) begin // reset state
            drv_tx_idle();
            while(tx_q.size() > 0) tx_item = tx_q.pop_front(); 
        end // reset
        else begin // non reset state

        end // non reset
    end // forever clk
endtask: drv_tx

//----------------------------------------------
function void ca_tx_tb_in_drv_c::drv_tx_idle();
        

endfunction : drv_tx_idle

//----------------------------------------------
function void ca_tx_tb_in_drv_c::check_phase(uvm_phase phase);

    bit  pass = 1;

    `uvm_info("check_phase", $sformatf("Starting ca_tx_tb_in_drv check_phase..."), UVM_LOW);
                
    if((got_tx == 1) || (tx_q.size() > 0)) begin
        `uvm_warning("check_phase", $sformatf("%s ca_tx_tb_in thread active: in transcation: %s queued : %0d", 
            my_name, got_tx ? "T":"F", tx_q.size()));
         pass = 0;
        end

    if(pass == 1) begin
        `uvm_info("check_phase", $sformatf("%s ca_tx_tb_in_drv check_phase ok", my_name), UVM_LOW);
    end
    else begin
        `uvm_error("check_phase", $sformatf("%s ca_tx_tb_in_drv check_phase FAIL - work still pending!", my_name));
    end

endfunction : check_phase

//////////////////////////////////////////////////////////////////////////////
`endif
