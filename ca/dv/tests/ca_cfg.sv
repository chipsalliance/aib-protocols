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

`ifndef _CA_CFG_
`define _CA_CFG_
///////////////////////////////////////////////////////////

class ca_cfg_c extends uvm_object;
   
    // UVM Factory Registration Macro
    `uvm_object_utils(ca_cfg_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    ca_knobs_c           ca_knobs;
    reset_cfg_c          reset_cfg;

    ca_tx_tb_out_cfg_c   ca_die_a_tx_tb_out_cfg;
    ca_tx_tb_out_cfg_c   ca_die_b_tx_tb_out_cfg;
    
    ca_tx_tb_in_cfg_c    ca_die_a_tx_tb_in_cfg;
    ca_tx_tb_in_cfg_c    ca_die_b_tx_tb_in_cfg;

    ca_rx_tb_in_cfg_c    ca_die_a_rx_tb_in_cfg;     
    ca_rx_tb_in_cfg_c    ca_die_b_rx_tb_in_cfg;     

    chan_delay_cfg_c     ca_die_b_delay_cfg[`MAX_NUM_CHANNELS];
    chan_delay_cfg_c     ca_die_a_delay_cfg[`MAX_NUM_CHANNELS];
 
    bit                  stb_error_test; 
    bit [15:0]           intv_offset;
    //------------------------------------------
    // constraints
    //------------------------------------------
   
    //------------------------------------------
    // Methods
    //------------------------------------------
    // Standard UVM Methods:
    extern function new(string name = "ca_cfg");
    extern function void build_phase( uvm_phase phase );
    extern function void connect_phase( uvm_phase phase );
    extern virtual function void configure( );

endclass: ca_cfg_c

///////////////////////////////////////////////////////////
function ca_cfg_c::new(string name = "ca_cfg");
   
    super.new(name);
    ca_knobs                = ca_knobs_c::type_id::create("ca_knobs");
    reset_cfg               = reset_cfg_c::type_id::create("reset_cfg");
    ca_die_a_tx_tb_out_cfg  = ca_tx_tb_out_cfg_c::type_id::create("ca_die_a_tx_tb_out_cfg");
    ca_die_b_tx_tb_out_cfg  = ca_tx_tb_out_cfg_c::type_id::create("ca_die_b_tx_tb_out_cfg");
    
    ca_die_a_tx_tb_in_cfg   = ca_tx_tb_in_cfg_c::type_id::create("ca_die_a_tx_tb_in_cfg");
    ca_die_b_tx_tb_in_cfg   = ca_tx_tb_in_cfg_c::type_id::create("ca_die_b_tx_tb_in_cfg");

    ca_die_a_tx_tb_in_cfg.my_name = "DIE_A";
    ca_die_a_tx_tb_out_cfg.my_name = "DIE_A";
    ca_die_a_tx_tb_out_cfg.set_bits_per_channel(`TB_DIE_A_BUS_BIT_WIDTH);
    ca_die_b_tx_tb_in_cfg.my_name = "DIE_B";
    ca_die_b_tx_tb_out_cfg.my_name = "DIE_B";
    ca_die_b_tx_tb_out_cfg.set_bits_per_channel(`TB_DIE_B_BUS_BIT_WIDTH);

    ca_die_a_rx_tb_in_cfg  = ca_rx_tb_in_cfg_c::type_id::create("ca_die_a_rx_tb_in_cfg");
    ca_die_b_rx_tb_in_cfg  = ca_rx_tb_in_cfg_c::type_id::create("ca_die_b_rx_tb_in_cfg");
    ca_die_a_rx_tb_in_cfg.my_name = "DIE_A";
    ca_die_b_rx_tb_in_cfg.my_name = "DIE_B";

    for(int i = 0; i < `MAX_NUM_CHANNELS; i++) begin
        ca_die_b_delay_cfg[i] = chan_delay_cfg_c::type_id::create($sformatf("ca_die_b_delay_cfg_%0d",i));
        if(!(ca_die_b_delay_cfg[i].randomize())) `uvm_fatal("CA_CFG", $sformatf("ca_die_b_delay_cfg: %0d randomize FAILED !!",i));
        ca_die_b_delay_cfg[i].my_name = "DIE_B";
        ca_die_b_delay_cfg[i].chan_num = i;
        ca_die_b_delay_cfg[i].chan_delay_clk = $urandom_range(`CHAN_DELAY_MAX, `CHAN_DELAY_MIN);
        ca_die_b_delay_cfg[i].print(); 
    end

    for(int i = 0; i < `MAX_NUM_CHANNELS; i++) begin
        ca_die_a_delay_cfg[i] = chan_delay_cfg_c::type_id::create($sformatf("ca_die_a_delay_cfg_%0d",i));
        if(!(ca_die_a_delay_cfg[i].randomize())) `uvm_fatal("CA_CFG", $sformatf("ca_die_a_delay_cfg: %0d randomize FAILED !!",i));
        ca_die_a_delay_cfg[i].my_name = "DIE_A";
        ca_die_a_delay_cfg[i].chan_num = i;
        ca_die_a_delay_cfg[i].chan_delay_clk = $urandom_range(`CHAN_DELAY_MAX, `CHAN_DELAY_MIN);
        //ca_die_a_delay_cfg[i].chan_delay_clk = i*4 + 2 ; // FIXME to random
        ca_die_a_delay_cfg[i].print(); 
    end

    if(!(ca_die_a_tx_tb_out_cfg.randomize())) `uvm_fatal("CA_CFG", $sformatf("ca_die_a_tx_tb_out_cfg randomize FAILED !!"));
    if(!(ca_die_b_tx_tb_out_cfg.randomize())) `uvm_fatal("CA_CFG", $sformatf("ca_die_b_tx_tb_out_cfg randomize FAILED !!"));
    if(!(reset_cfg.randomize())) `uvm_fatal("CA_CFG", $sformatf("reset_cfg randomize FAILED !!"));
    if(!(ca_knobs.randomize())) `uvm_fatal("CA_CFG", $sformatf("ca_knobs randomize FAILED !!"));

    ca_die_a_rx_tb_in_cfg.last_tx_cnt_a = ca_knobs.tx_xfer_cnt_die_a ;  
    ca_die_b_rx_tb_in_cfg.last_tx_cnt_b = ca_knobs.tx_xfer_cnt_die_b ; 
    ca_die_a_tx_tb_in_cfg.last_tx_cnt_a = ca_knobs.tx_xfer_cnt_die_a; 
    ca_die_b_tx_tb_in_cfg.last_tx_cnt_b = ca_knobs.tx_xfer_cnt_die_b;

endfunction
 
//------------------------------------------
function void ca_cfg_c::build_phase( uvm_phase phase );
    //

endfunction: build_phase
//------------------------------------------
function void ca_cfg_c::connect_phase( uvm_phase phase );
    //

endfunction: connect_phase

//------------------------------------------
function void ca_cfg_c::configure( );

    // *FIXME* added in check for ca_knobs for user defined values from the cmd line
    // if valid, override the random values BEFORE the config is executed

    // randomize the bit/wd select
    //ca_die_a_tx_tb_out_cfg.configure(); 
    //ca_die_b_tx_tb_out_cfg.configure();
 
    ca_die_a_tx_tb_in_cfg.configure(); 
    ca_die_b_tx_tb_in_cfg.configure(); 

    ca_die_a_rx_tb_in_cfg.configure(); 
    ca_die_b_rx_tb_in_cfg.configure();
 
    // copy same configs from tx_out to tx_in
    ca_die_a_tx_tb_in_cfg.cp(ca_die_a_tx_tb_out_cfg); 
    ca_die_b_tx_tb_in_cfg.cp(ca_die_b_tx_tb_out_cfg); 
    
    // *FIXME* add in for gear chaning
    // ADD task in rx cfg to account for changes in bit/wd select when vers/bit bus size changes
    // similar to the tx_in.cp above, but it will dynamically change rx to the correct sizes
    //
    ca_die_b_rx_tb_in_cfg.rx_stb_intv    = ca_die_a_tx_tb_out_cfg.tx_stb_intv;     
    ca_die_b_rx_tb_in_cfg.rx_stb_wd_sel  = ca_die_a_tx_tb_out_cfg.tx_stb_wd_sel;     
    ca_die_b_rx_tb_in_cfg.rx_stb_bit_sel = ca_die_a_tx_tb_out_cfg.tx_stb_bit_sel;     
     
    ca_die_a_rx_tb_in_cfg.rx_stb_intv    = ca_die_b_tx_tb_out_cfg.tx_stb_intv;     
    ca_die_a_rx_tb_in_cfg.rx_stb_wd_sel  = ca_die_b_tx_tb_out_cfg.tx_stb_wd_sel;     
    ca_die_a_rx_tb_in_cfg.rx_stb_bit_sel = ca_die_b_tx_tb_out_cfg.tx_stb_bit_sel;  

    `uvm_info("CA_CFG", $sformatf("*******************************"), UVM_LOW);
    `uvm_info("CA_CFG", $sformatf("TB_DIE_A_BUS_BIT_WIDTH == %0d", `TB_DIE_A_BUS_BIT_WIDTH), UVM_LOW); 
    `uvm_info("CA_CFG", $sformatf("TB_DIE_A_NUM_CHANNELS  == %0d", `TB_DIE_A_NUM_CHANNELS), UVM_LOW); 
    `uvm_info("CA_CFG", $sformatf("TB_DIE_A_AD_WIDTH      == %0d", `TB_DIE_A_AD_WIDTH), UVM_LOW); 
    `uvm_info("CA_CFG", $sformatf("*******************************"), UVM_LOW); 
    `uvm_info("CA_CFG", $sformatf("TB_DIE_B_BUS_BIT_WIDTH == %0d", `TB_DIE_B_BUS_BIT_WIDTH), UVM_LOW); 
    `uvm_info("CA_CFG", $sformatf("TB_DIE_B_NUM_CHANNELS  == %0d", `TB_DIE_B_NUM_CHANNELS), UVM_LOW); 
    `uvm_info("CA_CFG", $sformatf("TB_DIE_B_AD_WIDTH      == %0d", `TB_DIE_B_AD_WIDTH), UVM_LOW); 
    `uvm_info("CA_CFG", $sformatf("*******************************"), UVM_LOW); 
     ca_knobs.print();
    `uvm_info("CA_CFG", $sformatf("*******************************"), UVM_LOW); 
     ca_die_a_tx_tb_out_cfg.print(); 
    `uvm_info("CA_CFG", $sformatf("*******************************"), UVM_LOW); 
     ca_die_b_tx_tb_out_cfg.print(); 
    `uvm_info("CA_CFG", $sformatf("*******************************"), UVM_LOW); 
     ca_die_a_rx_tb_in_cfg.print(); 
    `uvm_info("CA_CFG", $sformatf("*******************************"), UVM_LOW); 
     ca_die_b_rx_tb_in_cfg.print(); 
    `uvm_info("CA_CFG", $sformatf("*******************************"), UVM_LOW); 
   
endfunction: configure

//////////////////////////////////////////////////////////
`endif
