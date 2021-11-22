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

`ifndef _CA_SEQ_ITEM_
`define _CA_SEQ_ITEM_
////////////////////////////////////////////////////////////

`include "uvm_macros.svh"

class ca_seq_item_c extends uvm_sequence_item ;
    
    //------------------------------------------
    // Data Members
    //------------------------------------------
    // tx
    rand bit [7:0]                 fbyte;
    bit                            is_tx = 0; // 0 is rx, 1 is tx

    bit                            stb_en             = 0;
    bit [7:0]                      stb_wd_sel         = 0;
    bit [39:0]                     stb_bit_sel        = 0;
    bit [7:0]                      stb_intv           = 0;
    bit                            stb_pos_err        = 0;
    bit                            stb_pos_coding_err = 0;

    bit                            align_err = 0;

    //------------------------------------------
    // Sideband Data Members
    //------------------------------------------
    int                            bus_bit_width = -1;
    int                            num_channels = -1;
    string                         my_name = "NO_NAME";
    bit                            add_stb = 0;
    rand int                       inj_delay;
    int                            bcnt = 0;
    int                            size_mul= 0;
    bit [7:0]                      databytes[];
    bit [7:0]                      tx_data_fin[]; 
    int                            die_a_exp_rx_dout_q[$];    
    int                            die_b_exp_rx_dout_q[$];  
    bit                            tx_data_rdy=0;  
    int                            clk_cnt=0;
    bit [639:0]                    tx_mark_din = 0; 
    bit [3:0]                      user_marker; 
    int                            user_marker_loc; 
    real                           cnt_mul;
    int                            last_tx_cnt_a;
    int                            last_tx_cnt_b;
    `uvm_object_utils_begin(ca_seq_item_c)
    `uvm_field_int(fbyte, UVM_DEFAULT);
    `uvm_field_int(inj_delay, UVM_DEFAULT);
    `uvm_object_utils_end

    //------------------------------------------
    // constraints 
    //------------------------------------------
    constraint c_inj_delay { inj_delay >= 0 ; inj_delay <= 0; }
   
    // Standard UVM Methods:
    extern function new(string name = "ca_seq_item");
    extern function void init_xfer(int size_l);
    extern function void dprint(int bytes_per_line = 5);
    extern function void build_tx_beat(ca_seq_item_c  stb_beat);
    extern function bit [1:0] is_stb_beat(ca_seq_item_c  stb_beat);
    extern function void calc_stb_beat();
    extern function void add_stb_beat(ca_seq_item_c  stb_beat);
    extern function void clr_stb_beat(ca_seq_item_c  stb_beat);
    extern function void check_input();
    extern function bit  compare_beat(ca_seq_item_c  act_beat,bit tx_or_rx_compare_chk=1'b0);

endclass : ca_seq_item_c

////////////////////////////////////////////////////////////
//--------------------------------------------------
function ca_seq_item_c::new (string name = "ca_seq_item");

    super.new(name);

endfunction : new

//--------------------------------------------------
function void ca_seq_item_c::init_xfer(int size_l);

  `ifndef CA_ASYMMETRIC
     databytes = new[size_l];
     bcnt      = size_l;
  `else
     databytes   = new[size_l*4]; //*4    to accommodate F2Q
     tx_data_fin = new[size_l*4];
     bcnt        = size_l;
  `endif
   //$display("bcnt %0d,size_l %0d,bus_bit_width %0d,time %0t",bcnt, size_l,bus_bit_width,$time);
endfunction : init_xfer

//--------------------------------------------------
function void ca_seq_item_c::dprint(int bytes_per_line = 5);

    int     i = 0;
    string  sout = "";
    string  sbyte = "";

   if(bcnt == 0) `uvm_warning("dprint", "bcnt == 0  NOTHING to print!")
   else `uvm_info("dprint", $sformatf("displaying bytes: %0d", bcnt), UVM_MEDIUM);  
 
   `ifndef CA_ASYMMETRIC
    for(i = 0; i < (bcnt) ; i++) begin
   `else
    for(i = 0; i < (bcnt*4) ; i++) begin
   `endif
        sbyte.hextoa(databytes[i]);

        if(databytes[i] <= 'hf) sbyte = { "0", sbyte };

        //sout = { sout, " ", sbyte };
        sout = { sbyte, " ", sout };  

        if((i + 1) % bytes_per_line == 0) begin 
           //`uvm_info("dprint", $sformatf("%6d: %s :%6d", (i/bytes_per_line) * bytes_per_line ,sout, i), UVM_MEDIUM);
           `uvm_info("dprint", $sformatf("%6d: %s :%6d", i, sout, (i/bytes_per_line) * bytes_per_line), UVM_MEDIUM);
            sout = "";
            end
        end

        if(bcnt % bytes_per_line != 0) 
            `uvm_info("dprint", $sformatf("%6d: %s ", (i/bytes_per_line) * bytes_per_line ,sout), UVM_MEDIUM);

endfunction: dprint
    
//--------------------------------------------------
function void ca_seq_item_c::clr_stb_beat(ca_seq_item_c  stb_beat);

    if(bcnt != stb_beat.bcnt) `uvm_fatal("clr_stb_beat", $sformatf("bcnt: %0d !== stb_bcnt: %0d", bcnt, stb_beat.bcnt));

    `uvm_info("clr_stb_beat", $sformatf("stb_beat:"), UVM_MEDIUM);
    stb_beat.dprint();
    for(int i = 0; i < bcnt; i++) begin
        databytes[i] = databytes[i] & (stb_beat.databytes[i] ^ 8'hff);
    end
    `uvm_info("clr_stb_beat", $sformatf("src_data - stb_beat:"), UVM_MEDIUM);
    dprint();

endfunction : clr_stb_beat
    
//--------------------------------------------------
function void ca_seq_item_c::add_stb_beat(ca_seq_item_c  stb_beat);

    if(bcnt != stb_beat.bcnt) `uvm_fatal("add_stb_beat", $sformatf("bcnt: %0d !== stb_bcnt: %0d", bcnt, stb_beat.bcnt));

    `uvm_info("add_stb_beat", $sformatf("stb_beat:"), UVM_MEDIUM);
    stb_beat.dprint();
    for(int i = 0; i < bcnt; i++) begin
        databytes[i] = databytes[i] | stb_beat.databytes[i];
    end
    `uvm_info("add_stb_beat", $sformatf("src_data + stb_beat:"), UVM_MEDIUM);
    dprint();

endfunction : add_stb_beat
    
//--------------------------------------------------
function bit [1:0] ca_seq_item_c::is_stb_beat(ca_seq_item_c  stb_beat);

    bit  is_stb  = 1;
    bit  is_data = 0;

    if(bcnt != stb_beat.bcnt) begin
        `uvm_fatal("is_stb_beat", $sformatf("bcnt NOT equal act: %0d | stb: %0d", bcnt, stb_beat.bcnt));
    end
    else begin
        for(int i = 0; i < bcnt; i++) begin
            if((databytes[i] & stb_beat.databytes[i]) != stb_beat.databytes[i]) begin
                is_stb = 0;
                break;
            end
        end // for i
        for(int i = 0; i < bcnt; i++) begin
            if((databytes[i] & (stb_beat.databytes[i] ^ 8'hff)) != 'h0) begin
                is_data = 1;
                break;
            end
        end // for i
    end

    `uvm_info("is_stb_beat", $sformatf("is_stb: %0d is_data: %0d", is_stb, is_data), UVM_MEDIUM);
    is_stb_beat = {is_stb, is_data};
    return is_stb_beat;

endfunction : is_stb_beat

//--------------------------------------------------
function void ca_seq_item_c::check_input();

    if(bus_bit_width <= 0) `uvm_fatal("check_input", $sformatf("bus_bit_width NOT set!!"));
    if(num_channels <= 0)  `uvm_fatal("check_input", $sformatf("bus_bit_width NOT set!!"));

endfunction : check_input

//--------------------------------------------------
function void ca_seq_item_c::build_tx_beat(ca_seq_item_c  stb_beat);
    
    check_input();
    init_xfer((bus_bit_width*num_channels) / 8);
    //$display("bus_bit_width %0d,num_channels %0d,time %0t",bus_bit_width,num_channels,$time);
    if(stb_beat.bcnt != bcnt) `uvm_fatal("build_tx_beat", $sformatf("stb_bcnt: %0d != bcnt: %0d", stb_beat, bcnt));

    for(int i = 0; i < bcnt; i++) begin
        randcase
           4: databytes[i] = fbyte + i;
           4: databytes[i] = fbyte - i;
           1: databytes[i] = 8'hff;
        endcase
    end

    // apply stb mask  // FIXME  this should not be needed
    for(int i = 0; i < bcnt; i++) begin
        //`uvm_info("build_tx_beat", $sformatf("byte: %0d data: 0x%h stb: 0x%h == 0x%h", 
        //    i, databytes[i], stb_beat.databytes[i], (databytes[i] & (stb_beat.databytes[i] ^ 8'hff))), UVM_MEDIUM);
    `ifndef CA_ASYMMETRIC 
      databytes[i] = databytes[i] & (stb_beat.databytes[i] ^ 8'hff);
    `endif
   end

endfunction : build_tx_beat

//--------------------------------------------------
function void ca_seq_item_c::calc_stb_beat();

    bit [`MIN_BUS_BIT_WIDTH-1:0]  stb_wd   = 'h0;
    int                           index    = 0;

    // set up exp strobe beat/data

    index    = 0;
    check_input();

    init_xfer((bus_bit_width*num_channels) / 8);
    for(int k = 0; k < num_channels; k++) begin
        for(int i = 1; i <= bus_bit_width/`MIN_BUS_BIT_WIDTH; i++) begin
            if(stb_wd_sel[i-1]) begin
                stb_wd = stb_bit_sel ;
            end
            else begin
                stb_wd = 0;
            end
            `uvm_info("calc_stb_beat", $sformatf("%s %s exp i: %0d stb_wd: 0x%h,stb_wd_bin : %b", my_name, is_tx ? "TX":"RX", i, stb_wd,stb_wd), UVM_NONE);

            for(int j = 0; j < (`MIN_BUS_BIT_WIDTH/8); j++) begin
                databytes[index] = stb_wd[7:0];
                stb_wd = stb_wd >> 8;
                //`uvm_info("calc_stb_beat", $sformatf("calc_stb_beat, stb_beat[%0d] = %h", index,databytes[index]), UVM_MEDIUM);
                index +=1; 
            end // for j
        end // for i
    end // for k

    `uvm_info("calc_stb_beat", $sformatf("%s %s exp stb stb_wd_sel: 0x%0h stb_bit_sel: 0x%0h bus_bit_width: %0d num_channels: %0d",
        my_name, is_tx ? "TX":"RX", stb_wd_sel, stb_bit_sel, bus_bit_width, num_channels), UVM_LOW);

    dprint();

endfunction : calc_stb_beat

//--------------------------------------------------
function bit  ca_seq_item_c::compare_beat(ca_seq_item_c  act_beat, bit tx_or_rx_compare_chk=1'b0);

    bit [7:0] dbyte = 0; 
    int size_mul;

               compare_beat = 1;
               if(tx_or_rx_compare_chk == 1) begin  //RX comparison
                  `ifdef CA_ASYMMETRIC
                    `ifdef GEN1
                       //die_a to die_b busbitwidth check 40,80    f2h/h2f ,f2f,h2h =same bcnt
                       //if((act_item.my_name == "DIE_A" ) && ((act_item.bus_bit_width == 40)  && act_item.bus_bit_width == 80))) size_mul = 2;
                       if((my_name == "DIE_A" ) && (bus_bit_width == 40)) size_mul = 2; //ASYM,F2H
                       if((my_name == "DIE_B" ) && (bus_bit_width == 80)) size_mul = 2; //ASYM H2F
                    `else
                       if((my_name == "DIE_A" )      && (bus_bit_width ==  80)  && (`TB_DIE_B_BUS_BIT_WIDTH == 160)) size_mul = 2;//F2H-A
                       else if((my_name == "DIE_A" ) && (bus_bit_width == 160)  && (`TB_DIE_B_BUS_BIT_WIDTH ==  80)) size_mul = 2;//H2F-A
                       else if((my_name == "DIE_A" ) && (bus_bit_width ==  80)  && (`TB_DIE_B_BUS_BIT_WIDTH == 320)) size_mul = 4;//F2Q-A
                       else if((my_name == "DIE_A" ) && (bus_bit_width == 320)  && (`TB_DIE_B_BUS_BIT_WIDTH ==  80)) size_mul = 4;//Q2F-A
                       else if((my_name == "DIE_A" ) && (bus_bit_width == 160)  && (`TB_DIE_B_BUS_BIT_WIDTH == 320)) size_mul = 2;//H2Q-A
                       else if((my_name == "DIE_A" ) && (bus_bit_width == 320)  && (`TB_DIE_B_BUS_BIT_WIDTH == 160)) size_mul = 2;//Q2H-A


                       if((my_name == "DIE_B" )      && (bus_bit_width == 80)   && (`TB_DIE_A_BUS_BIT_WIDTH == 160)) size_mul = 2;//F2H-B
                       else if((my_name == "DIE_B" ) && (bus_bit_width == 160)  && (`TB_DIE_A_BUS_BIT_WIDTH == 80))  size_mul = 2;//H2F-B
                       else if((my_name == "DIE_B" ) && (bus_bit_width == 80)   && (`TB_DIE_A_BUS_BIT_WIDTH == 320)) size_mul = 4;//F2Q-B
                       else if((my_name == "DIE_B" ) && (bus_bit_width == 320)  && (`TB_DIE_A_BUS_BIT_WIDTH == 80))  size_mul = 4;//Q2F-B
                       else if((my_name == "DIE_B" ) && (bus_bit_width == 160)  && (`TB_DIE_A_BUS_BIT_WIDTH == 320)) size_mul = 2;//H2Q-B
                       else if((my_name == "DIE_B" ) && (bus_bit_width == 320)  && (`TB_DIE_A_BUS_BIT_WIDTH == 160)) size_mul = 2;//Q2H-B
                       //Update need to be done for all combinations 
                     `endif
                       // $display("SCBD_BEFORE src_BCNT = %0d,act_BCNT = %0d,size_mul %0d,my_name %s,bus_bit_width %0d",
                                  //bcnt,act_beat.bcnt ,size_mul,my_name,bus_bit_width);
                         
                        if(my_name == "DIE_A") begin
                           if(`TB_DIE_A_BUS_BIT_WIDTH < `TB_DIE_B_BUS_BIT_WIDTH) begin //80-(160 or 320)  160->320 etc
                               bcnt = bcnt * size_mul ;
                           end else begin
                               act_beat.bcnt = act_beat.bcnt * size_mul ;
                           end
                        end
                        if(my_name == "DIE_B") begin
                           if(`TB_DIE_A_BUS_BIT_WIDTH < `TB_DIE_B_BUS_BIT_WIDTH) begin
                              act_beat.bcnt = act_beat.bcnt * size_mul ;
                           end else begin
                               bcnt = bcnt * size_mul ;
                           end
                        end
                        //$display("SCBD_AFTER src_BCNT = %0d,act_BCNT = %0d,size_mul %0d,my_name %s,bus_bit_width %0d",bcnt,act_beat.bcnt ,size_mul,my_name,bus_bit_width);
                  `endif //CA_ASYMMETRIC
               end

    if(bcnt != act_beat.bcnt) begin
        compare_beat = 0;
        `uvm_warning("compare_beat", $sformatf("byte count MISMATCH exp: %0d | act: %0d ",
            bcnt, act_beat.bcnt));
    end
    else begin
        // compare
        for(int i = 0; i < bcnt; i++) begin
            if(databytes[i] !== act_beat.databytes[i]) begin
                compare_beat = 0;
                `uvm_warning("compare_beat", $sformatf("byte: %0d data MISMATCH exp: 0x%h | act: 0x%h ",
                    i, databytes[i], act_beat.databytes[i]));
                break;
            end // if
        end // for
    end

    return compare_beat;

endfunction : compare_beat
////////////////////////////////////////////////////////////
`endif
