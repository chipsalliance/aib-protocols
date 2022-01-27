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

`ifndef _CA_KNOBS_
`define _CA_KNOBS_
////////////////////////////////////////////////////////
class ca_knobs_c extends uvm_object;

    //------------------------------------------
    // Data Members
    //------------------------------------------
    // test knobs

    int         GLOBAL_TIMEOUT                  = 2000000; ///1msec considering 0.5nsec clock period
    int         stop_err_cnt                    = 20;
    rand int    tx_xfer_cnt_die_a;
    rand int    tx_xfer_cnt_die_b;

    // values are ignored if they are 0 or -1
    // if the user enters a valid value, the bench uses it
    // tx
    int              tx_stb_wd_sel  = -1;
    int              tx_stb_bit_sel = -1;
    int              tx_online      = -1;    
    int              tx_stb_en      = -1;    
    int              tx_stb_intv    = -1;
    // rx
    int              rx_stb_wd_sel    = -1;
    int              rx_stb_bit_sel   = -1;
    int              rx_online        = -1;    
    int              rx_stb_en        = -1;   
    int              align_fly        = -1;  
    int              fifo_full_val    = -1;   
    int              fifo_pfull_val   = -1;
    int              fifo_empty_val   = -1;   
    int              fifo_pempty_val  = -1;  
    int              rden_dly         = -1;
    int              rx_stb_intv      = -1;
    bit[1:0]         traffic_enb_ab   =  3;

    
    //------------------------------------------
    `uvm_object_utils_begin(ca_knobs_c)
        `uvm_field_int(GLOBAL_TIMEOUT,    UVM_DEFAULT);
        `uvm_field_int(stop_err_cnt,      UVM_DEFAULT);
        `uvm_field_int(tx_xfer_cnt_die_a, UVM_DEFAULT);
        `uvm_field_int(tx_xfer_cnt_die_b, UVM_DEFAULT);
        `uvm_field_int(tx_stb_wd_sel,     UVM_DEFAULT);
        `uvm_field_int(tx_stb_bit_sel,    UVM_DEFAULT);
        `uvm_field_int(tx_online,         UVM_DEFAULT);
        `uvm_field_int(tx_stb_en,         UVM_DEFAULT);
        `uvm_field_int(tx_stb_intv,       UVM_DEFAULT);
        `uvm_field_int(rx_stb_wd_sel,     UVM_DEFAULT);
        `uvm_field_int(rx_stb_bit_sel,    UVM_DEFAULT);
        `uvm_field_int(rx_online,         UVM_DEFAULT);
        `uvm_field_int(rx_stb_en,         UVM_DEFAULT);
        `uvm_field_int(align_fly,         UVM_DEFAULT);
        `uvm_field_int(fifo_full_val,     UVM_DEFAULT);
        `uvm_field_int(fifo_pfull_val,    UVM_DEFAULT);
        `uvm_field_int(fifo_empty_val,    UVM_DEFAULT);
        `uvm_field_int(fifo_pempty_val,   UVM_DEFAULT);
        `uvm_field_int(rden_dly,          UVM_DEFAULT);
        `uvm_field_int(rx_stb_intv,       UVM_DEFAULT);
        `uvm_field_int(traffic_enb_ab,    UVM_DEFAULT);
    `uvm_object_utils_end

    //------------------------------------------
    // Contraints
    //------------------------------------------
       //constraint c_tx_xfer_cnt_die_a {tx_xfer_cnt_die_a >= 100; tx_xfer_cnt_die_a <=500; (tx_xfer_cnt_die_a%2 ==0);}
       //constraint c_tx_xfer_cnt_die_b {tx_xfer_cnt_die_b >= 100; tx_xfer_cnt_die_b <=500; (tx_xfer_cnt_die_b%2 ==0);}
       constraint c_tx_xfer_cnt_die_a {tx_xfer_cnt_die_a >= 100; tx_xfer_cnt_die_a <=500;
                                      ((`TB_DIE_A_BUS_BIT_WIDTH == 320) || (`TB_DIE_B_BUS_BIT_WIDTH == 320 )) ?
                                      (tx_xfer_cnt_die_a%4 == 0) : (tx_xfer_cnt_die_a%2 ==0);}
       constraint c_tx_xfer_cnt_die_b {tx_xfer_cnt_die_b >= 100; tx_xfer_cnt_die_b <=500;
                                      ((`TB_DIE_A_BUS_BIT_WIDTH == 320) || (`TB_DIE_B_BUS_BIT_WIDTH == 320)) ? 
                                      (tx_xfer_cnt_die_b%4 == 0) : (tx_xfer_cnt_die_b%2 ==0);}
    //------------------------------------------
    // Methods
    //------------------------------------------

    extern function new (string name = "ca_knobs");
    extern function void build_phase(uvm_phase phase);
    extern function void connect_phase(uvm_phase phase);
    extern function void display_knobs();

endclass : ca_knobs_c

////////////////////////////////////////////////////////
class ca_knobs_stb_intv_c extends ca_knobs_c;
    
`uvm_object_utils_begin(ca_knobs_stb_intv_c)
        `uvm_field_int(tx_xfer_cnt_die_a, UVM_DEFAULT);
        `uvm_field_int(tx_xfer_cnt_die_b, UVM_DEFAULT);
`uvm_object_utils_end

    constraint c_tx_xfer_cnt_die_a {tx_xfer_cnt_die_a >= 5; tx_xfer_cnt_die_a <=9;}
    constraint c_tx_xfer_cnt_die_b {tx_xfer_cnt_die_b >= 5; tx_xfer_cnt_die_b <=9;}

    extern function new (string name = "ca_knobs_stb_intv");

endclass : ca_knobs_stb_intv_c

////////////////////////////////////////////////////////
function ca_knobs_stb_intv_c::new (string name = "ca_knobs_stb_intv");
   // super.new(name);
    //assert(this.randomize());
endfunction : new

////////////////////////////////////////////////////////
function ca_knobs_c::new (string name = "ca_knobs");
    super.new(name);
    assert(this.randomize());

    if($value$plusargs("GLOBAL_TIMEOUT=%0d", GLOBAL_TIMEOUT)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> GLOBAL_TIMEOUT == %0d", GLOBAL_TIMEOUT), UVM_NONE);
    end

    if($value$plusargs("stop_err_cnt=%0d", stop_err_cnt)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> stop_err_cnt == %0d", stop_err_cnt), UVM_NONE);
    end

    if($value$plusargs("tx_xfer_cnt_die_a=%0d", tx_xfer_cnt_die_a)) begin
        tx_xfer_cnt_die_a.rand_mode(0); // disable constraint
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> tx_xfer_cnt_die_a == %0d", tx_xfer_cnt_die_a), UVM_NONE);
    end

    if($value$plusargs("tx_xfer_cnt_die_b=%0d", tx_xfer_cnt_die_b)) begin
        tx_xfer_cnt_die_b.rand_mode(0); // disable constraint
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> tx_xfer_cnt_die_b == %0d", tx_xfer_cnt_die_b), UVM_NONE);
    end
   
    // tx 
    if($value$plusargs("tx_stb_wd_sel=%0d", tx_stb_wd_sel)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> tx_stb_wd_sel == %0d", tx_stb_wd_sel), UVM_NONE);
    end
    
    if($value$plusargs("tx_stb_bit_sel=%0d", tx_stb_bit_sel)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> tx_stb_bit_sel == %0d", tx_stb_bit_sel), UVM_NONE);
    end
    
    if($value$plusargs("tx_online=%0d", tx_online)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> tx_online == %0d", tx_online), UVM_NONE);
    end
    
    if($value$plusargs("tx_stb_en=%0d", tx_stb_en)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> tx_stb_en == %0d", tx_stb_en), UVM_NONE);
    end
    
    if($value$plusargs("tx_stb_intv=%0d", tx_stb_intv)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> tx_stb_intv == %0d", tx_stb_intv), UVM_NONE);
    end

    // rx 
    if($value$plusargs("rx_stb_wd_sel=%0d", rx_stb_wd_sel)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> rx_stb_wd_sel == %0d", rx_stb_wd_sel), UVM_NONE);
    end
 
    if($value$plusargs("rx_stb_bit_sel=%0d", rx_stb_bit_sel)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> rx_stb_bit_sel == %0d", rx_stb_bit_sel), UVM_NONE);
    end
 
    if($value$plusargs("rx_online=%0d", rx_online)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> rx_online == %0d", rx_online), UVM_NONE);
    end
 
    if($value$plusargs("rx_stb_en=%0d", rx_stb_en)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> rx_stb_en == %0d", rx_stb_en), UVM_NONE);
    end
 
    if($value$plusargs("align_fly=%0d", align_fly)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> align_fly == %0d", align_fly), UVM_NONE);
    end
 
    if($value$plusargs("fifo_full_val=%0d", fifo_full_val)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> fifo_full_val == %0d", fifo_full_val), UVM_NONE);
    end
 
    if($value$plusargs("fifo_pfull_val=%0d", fifo_pfull_val)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> fifo_pfull_val == %0d", fifo_pfull_val), UVM_NONE);
    end
 
    if($value$plusargs("fifo_empty_val=%0d", fifo_empty_val)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> fifo_empty_val == %0d", fifo_empty_val), UVM_NONE);
    end
 
    if($value$plusargs("fifo_pempty_val=%0d", fifo_pempty_val)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> fifo_pempty_val == %0d", fifo_pempty_val), UVM_NONE);
    end
 
    if($value$plusargs("rden_dly=%0d", rden_dly)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> rden_dly == %0d", rden_dly), UVM_NONE);
    end
 
    if($value$plusargs("rx_stb_intv=%0d", rx_stb_intv)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> rx_stb_intv == %0d", rx_stb_intv), UVM_NONE);
    end

    if($value$plusargs("traffic_enb_ab=%0d", traffic_enb_ab)) begin
        `uvm_info("KNOBS", $sformatf("*** cmd line set ***> traffic_enb_ab== %0d", traffic_enb_ab), UVM_NONE);
    end

endfunction : new
//---------------------------------------------------------------
function void ca_knobs_c::build_phase (uvm_phase phase);

endfunction : build_phase

//---------------------------------------------------------------
function void ca_knobs_c::connect_phase (uvm_phase phase);

endfunction : connect_phase

//---------------------------------------------------------------
function void ca_knobs_c::display_knobs();

endfunction : display_knobs
////////////////////////////////////////////////////////
`endif
