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

`ifndef _CA_TX_TB_OUT_MON_
`define _CA_TX_TB_OUT_MON_
///////////////////////////////////////////////////////////////////
class ca_tx_tb_out_mon_c #(int BUS_BIT_WIDTH=80, int NUM_CHANNELS=2) extends uvm_monitor ;
    
    // register w/ the factory
    //------------------------------------------
    `uvm_component_param_utils(ca_tx_tb_out_mon_c #(BUS_BIT_WIDTH, NUM_CHANNELS))

    // Virtual Interface
    //------------------------------------------
    ca_tx_tb_out_cfg_c        cfg;
    virtual ca_tx_tb_out_if   #(.BUS_BIT_WIDTH(BUS_BIT_WIDTH), .NUM_CHANNELS(NUM_CHANNELS)) vif;  

    //------------------------------------------
    // Data Members
    //------------------------------------------
    bit                      tx_active = 0;
    string                   my_name = "";
    int                      tx_cnt = 0;
    
    //------------------------------------------
    // Component Members
    //------------------------------------------
    uvm_analysis_port #(ca_data_pkg::ca_seq_item_c) aport;

    //------------------------------------------
    // Standard UVM Methods:
    //------------------------------------------
    extern function new(string name = "ca_tx_tb_out_mon", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    
    extern task mon_tx(); 
    extern virtual function void check_phase(uvm_phase phase);

endclass : ca_tx_tb_out_mon_c

/////////////////////////////////////////////////

//----------------------------------------------
function ca_tx_tb_out_mon_c::new(string name = "ca_tx_tb_out_mon", uvm_component parent = null);
    
    super.new(name, parent);
    `uvm_info("ca_tx_tb_out_mon_c::new", $sformatf("BUS_BIT_WIDTH == %0d", BUS_BIT_WIDTH), UVM_LOW);
    `uvm_info("ca_tx_tb_out_mon_c::new", $sformatf("NUM_CHANNELS  == %0d", NUM_CHANNELS), UVM_LOW);

endfunction : new

//----------------------------------------------
function void ca_tx_tb_out_mon_c::build_phase(uvm_phase phase);
    
    aport = new("aport", this);

    // get the interface
    if( !uvm_config_db #( virtual ca_tx_tb_out_if #(BUS_BIT_WIDTH, NUM_CHANNELS) )::get(this, "" , "ca_tx_tb_out_vif", vif) )  
        `uvm_fatal("build_phase", "unable to get ca_tx_tb_out vif")

endfunction: build_phase

//----------------------------------------------
task ca_tx_tb_out_mon_c::run_phase(uvm_phase phase);
    
    fork
        mon_tx();
    join 

endtask : run_phase

//----------------------------------------------
task ca_tx_tb_out_mon_c::mon_tx(); 

    logic [((BUS_BIT_WIDTH*NUM_CHANNELS)-1):0]  tx_data = 0; 
    ca_data_pkg::ca_seq_item_c                  ca_item;

    forever begin @(posedge vif.clk)
        
        if(vif.rst_n === 1'b0) begin 
            // reset state
            tx_active = 0;
            tx_cnt = 0;
            end
        else if((vif.align_done === 1'b1) && (vif.tx_online === 1'b1)) begin // non reset state
     
            // check strb

            //-------------------- 
            if((|vif.tx_din !== 'h0) && (^vif.tx_din !== 'hx)) begin 
                ca_item = ca_data_pkg::ca_seq_item_c::type_id::create("ca_item");
                ca_item.init_xfer((BUS_BIT_WIDTH*NUM_CHANNELS) / 8);
                tx_data = vif.tx_din;
                tx_cnt++;
                `uvm_info("mon_tx_tb_out", $sformatf("%s rx-ing TB --> tx_din RTL xfer: %0d tx_din: 0x%h", my_name, tx_cnt, tx_data), UVM_MEDIUM);
                for(int i = 0; i < (BUS_BIT_WIDTH*NUM_CHANNELS) / 8; i++) begin
                    ca_item.databytes[i] = tx_data[7:0];
                    tx_data = tx_data >> 8;
                end
                ca_item.my_name     = my_name;
                ca_item.stb_en      = vif.tx_stb_en;
                ca_item.stb_wd_sel  = vif.tx_stb_wd_sel;
                ca_item.stb_bit_sel = vif.tx_stb_bit_sel;
                ca_item.stb_intv    = vif.tx_stb_intv;
                aport.write(ca_item); 
            end // if not 0
        end // non reset 
    
    end // clk

endtask : mon_tx
    
//---------------------------------------------
function void ca_tx_tb_out_mon_c::check_phase(uvm_phase phase);

    if(tx_active == 1) `uvm_error("check_phase", $sformatf("TX pkt tx_active still active at EOT!"));

endfunction : check_phase

////////////////////////////////////////////////////////////
`endif

