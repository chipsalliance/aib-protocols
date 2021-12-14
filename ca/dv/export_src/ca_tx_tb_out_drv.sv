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

`ifndef _CA_TX_TB_OUT_DRV_
`define _CA_TX_TB_OUT_DRV_

///////////////////////////////////////////////////////////
class ca_tx_tb_out_drv_c #(int BUS_BIT_WIDTH=80, int NUM_CHANNELS=2) extends uvm_driver #(ca_data_pkg::ca_seq_item_c, ca_data_pkg::ca_seq_item_c);

    // UVM Factory Registration Macro
    `uvm_component_param_utils(ca_tx_tb_out_drv_c #(BUS_BIT_WIDTH, NUM_CHANNELS))
    
    //------------------------------------------
    // Data Members
    //------------------------------------------
    virtual ca_tx_tb_out_if     #(.BUS_BIT_WIDTH(BUS_BIT_WIDTH), .NUM_CHANNELS(NUM_CHANNELS)) vif;
    ca_tx_tb_out_cfg_c          cfg;
    int                         max_tb_inj_depth = 50;
    string                      my_name = "NO_NAME";
    bit                         got_tx = 0;
    bit                         tx_online = 0;
    int                         tx_cnt = 0;
    bit [((BUS_BIT_WIDTH*NUM_CHANNELS)-1):0]  idle_data = 0; 

    // queues for holding seq items for injection into RTL
    ca_data_pkg::ca_seq_item_c    tx_q[$];
    ca_data_pkg::ca_seq_item_c    stb_item;

    //------------------------------------------
    // Standard UVM Methods:
    //------------------------------------------
    extern function new(string name = "ca_tx_tb_out_drv", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task get_item_from_seq();
    extern virtual function void check_phase(uvm_phase phase);

    //------------------------------------------
    // Custom UVM Methods:
    //------------------------------------------
    extern task drv_tx();
    extern task drv_tx_online();
    extern function void drv_tx_idle();
    extern function void gen_stb_beat();
    extern function void set_item(ca_data_pkg::ca_seq_item_c  item);

endclass: ca_tx_tb_out_drv_c

////////////////////////////////////////////////////////////
//----------------------------------------------
function ca_tx_tb_out_drv_c::new(string name = "ca_tx_tb_out_drv", uvm_component parent = null);
    
    super.new(name, parent);
    
        `uvm_info("ca_tx_tb_out_drv_c::new", $sformatf("%s BUS_BIT_WIDTH == %0d", my_name, BUS_BIT_WIDTH), UVM_LOW);
        `uvm_info("ca_tx_tb_out_drv_c::new", $sformatf("%s NUM_CHANNELS  == %0d", my_name, NUM_CHANNELS), UVM_LOW);

   endfunction : new

//----------------------------------------------
function void ca_tx_tb_out_drv_c::build_phase(uvm_phase phase);

    // get the interface
    if( !uvm_config_db #( virtual ca_tx_tb_out_if #(BUS_BIT_WIDTH, NUM_CHANNELS) )::get(this, "" , "ca_tx_tb_out_vif", vif) ) 
    `uvm_fatal("build_phase", "unable to get ca_tx_tb_out vif")

endfunction : build_phase

//----------------------------------------------
task ca_tx_tb_out_drv_c::run_phase(uvm_phase phase);
    
   fork
        get_item_from_seq();
        drv_tx();
        drv_tx_online();
    join
endtask : run_phase

//---------------------------------------------
task ca_tx_tb_out_drv_c::get_item_from_seq();
    
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
task ca_tx_tb_out_drv_c::drv_tx_online();
    
    forever begin @(posedge vif.clk)
        if(vif.rst_n === 1'b0) begin // reset state
            //vif.tx_online  <=  1'b0;
            tx_online = 0;
        end // reset
        else begin
          `ifdef CA_YELLOW_OVAL
               tx_online = vif.tx_online;
          `elsif P2P_LITE
               //vif.tx_online <=  cfg.tx_online; ////already driven at tb_top directly
               tx_online = vif.tx_online;
          `else 
            if((vif.ld_ms_rx_transfer_en === 24'hff_ffff) &&
               (vif.ld_sl_rx_transfer_en === 24'hff_ffff) &&
               (vif.fl_ms_rx_transfer_en === 24'hff_ffff) && 
               (vif.fl_sl_rx_transfer_en === 24'hff_ffff)) begin
               vif.tx_online <=  cfg.tx_online;
               if(tx_online == 0) `uvm_info("drv_tx_online", $sformatf("===>>> %s tx_online == %0d <<<===", my_name, cfg.tx_online), UVM_NONE);
               tx_online = 1;
            end 
          `endif 
        end // non reset
    end // forever clk

endtask : drv_tx_online

//----------------------------------------------
function void ca_tx_tb_out_drv_c::set_item(ca_data_pkg::ca_seq_item_c  item);

    item.is_tx          = 1;
    item.my_name        = my_name;
    item.bus_bit_width  = BUS_BIT_WIDTH;
    item.num_channels   = NUM_CHANNELS;
    item.stb_wd_sel     = cfg.tx_stb_wd_sel;
    item.stb_bit_sel    = cfg.tx_stb_bit_sel;
    item.stb_intv       = cfg.tx_stb_intv;

endfunction : set_item

//----------------------------------------------
function void ca_tx_tb_out_drv_c::gen_stb_beat();

    `uvm_info("gen_stb_beat", $sformatf("TX ca_tx_tb_out_drv:"), UVM_LOW);
    stb_item = ca_data_pkg::ca_seq_item_c::type_id::create("stb_item") ;
    set_item(stb_item);
    stb_item.calc_stb_beat();

endfunction : gen_stb_beat

//----------------------------------------------
task  ca_tx_tb_out_drv_c::drv_tx();
    ca_data_pkg::ca_seq_item_c                tx_item;      
    bit [((BUS_BIT_WIDTH*NUM_CHANNELS)-1):0]  tx_data; 
    bit [7:0]                                 count;
    bit                                       calc_stb = 1;
    bit                                       marker_b4_data_done, marker_b4_data_done_p;
    int                                       index, stb_bit_pos; 
    int                                       ch; 
    
    forever begin @(posedge vif.clk)
        if(vif.rst_n === 1'b0) begin // reset state
            if(calc_stb == 1) begin
                calc_stb = 0;
                gen_stb_beat();
            end
            drv_tx_idle();
            tx_cnt = 0;
            while(tx_q.size() > 0) tx_item = tx_q.pop_front(); 
        end // reset
        else begin // non reset state
            calc_stb = 1;
            if((got_tx == 0) && (tx_q.size() > 0) && (tx_online === 1'b1) && (vif.align_done === 1'b1)) begin
                tx_item = tx_q.pop_front();
                set_item(tx_item);
                tx_item.build_tx_beat(stb_item);
                got_tx = 1;
                cfg.align_done_assert = 1; 
            end
        
            if(got_tx == 1)  begin
                idle_data = 0;
               `ifndef CA_ASYMMETRIC
                    marker_b4_data_done = 1'b1;
               `endif 
                if (((marker_b4_data_done == 1'b0)&&(tx_item.inj_delay==0)) || (tx_item.inj_delay > 0)) begin
                    if (tx_item.inj_delay > 0) tx_item.inj_delay--;
                   `ifdef CA_ASYMMETRIC
                    for (int i=0, ch=0; i<(BUS_BIT_WIDTH*NUM_CHANNELS); i+=1) begin
                        if ((i!=0) && (i%BUS_BIT_WIDTH == 0)) ch++;

                        if ((i == `CA_TX_MARKER_LOC) || (i == ((ch*BUS_BIT_WIDTH)+`CA_TX_MARKER_LOC))) begin
                        `ifdef GEN2
                            if(BUS_BIT_WIDTH == 80) begin //FULL
                                idle_data[(ch*BUS_BIT_WIDTH) + 0 + `CA_TX_MARKER_LOC]  = vif.user_marker[0];
                                if ((tx_item.inj_delay<=1)&&(vif.user_marker[0] == 1'b1)) marker_b4_data_done = 1'b1;
                            end
                            if(BUS_BIT_WIDTH == 160)begin //HALF
                               idle_data[(ch*BUS_BIT_WIDTH) + 0 + `CA_TX_MARKER_LOC]  = vif.user_marker[0];
                               idle_data[(ch*BUS_BIT_WIDTH) + 80 + `CA_TX_MARKER_LOC] = vif.user_marker[1];
                                if ((tx_item.inj_delay<=1)&&(vif.user_marker[1] == 1'b1)) marker_b4_data_done = 1'b1;
                            end
                            if(BUS_BIT_WIDTH == 320) begin //QUARTER
                               idle_data[(ch*BUS_BIT_WIDTH) + 0  + `CA_TX_MARKER_LOC] = vif.user_marker[0];
                               idle_data[(ch*BUS_BIT_WIDTH) + 80 + `CA_TX_MARKER_LOC] = vif.user_marker[1];
                               idle_data[(ch*BUS_BIT_WIDTH) +160 + `CA_TX_MARKER_LOC] = vif.user_marker[2];
                               idle_data[(ch*BUS_BIT_WIDTH) +240 + `CA_TX_MARKER_LOC] = vif.user_marker[3];
                               if ((tx_item.inj_delay<=1)&&(vif.user_marker[3] == 1'b1)) marker_b4_data_done = 1'b1;
                            end

                        `else //GEN1 //FULL=40,HALF=80 //Always marker location has fixed value as 39
                            if(BUS_BIT_WIDTH == 40) begin
                               idle_data[(ch*BUS_BIT_WIDTH) + 39] = vif.user_marker[0];
                               if ((tx_item.inj_delay<=1)&&(vif.user_marker[0] == 1'b1)) marker_b4_data_done = 1'b1;
                            end
                            else if(BUS_BIT_WIDTH == 80) begin
                               idle_data[(ch*BUS_BIT_WIDTH) + 39] = vif.user_marker[0];
                               idle_data[(ch*BUS_BIT_WIDTH) + 79] = vif.user_marker[1];
                               if ((tx_item.inj_delay<=1)&&(vif.user_marker[1:0] == 2'b11)) marker_b4_data_done = 1'b1;
                            end
                        `endif
                        end //of marker_loc
                    end //for loop (i, ch)
                  `else //SYMMETRIC (GEN2 H2H and Q2Q only considered)
                    for (int i=0, ch=0; i<(BUS_BIT_WIDTH*NUM_CHANNELS); i+=1) begin
                        if ((i!=0) && (i%BUS_BIT_WIDTH == 0)) ch++;
                        if(BUS_BIT_WIDTH == 160)begin //HALF
                            idle_data[(ch*BUS_BIT_WIDTH) + 0 + `CA_TX_MARKER_LOC]  = vif.user_marker[0];
                            idle_data[(ch*BUS_BIT_WIDTH) + 80 + `CA_TX_MARKER_LOC] = vif.user_marker[1];
                        end
                        if(BUS_BIT_WIDTH == 320) begin //QUARTER
                            idle_data[(ch*BUS_BIT_WIDTH) + 0  + `CA_TX_MARKER_LOC] = vif.user_marker[0];
                            idle_data[(ch*BUS_BIT_WIDTH) + 80 + `CA_TX_MARKER_LOC] = vif.user_marker[1];
                            idle_data[(ch*BUS_BIT_WIDTH) +160 + `CA_TX_MARKER_LOC] = vif.user_marker[2];
                            idle_data[(ch*BUS_BIT_WIDTH) +240 + `CA_TX_MARKER_LOC] = vif.user_marker[3];
                        end
                    end //for
                  `endif //CA_ASYMMETRIC
                   if ((cfg.tx_stb_en == 1'b0) && (cfg.stop_strobes_inject == 0)) begin //mainly with asymmetrical modes
                        if (cfg.tx_stb_wd_sel[7:0]  == 8'h01) begin ///Strobe position in First 39:0 bits
                            stb_bit_pos = index;
                        end else begin
                            stb_bit_pos = ($clog2(cfg.tx_stb_wd_sel[7:0])*40) + (index);
                        end
                        for (int i=0, k=0; i<(BUS_BIT_WIDTH*NUM_CHANNELS); i+=1) begin
                            if ((i!=0) && (i%BUS_BIT_WIDTH == 0)) k++;  //// represents Channel
                            if ((i == stb_bit_pos) || (i == ((BUS_BIT_WIDTH*k)+stb_bit_pos))) begin
                            //$display("inside stb_inject part1.time,i = %0d,stb_bit_pos = %0d",$time,i,stb_bit_pos);
                                if((cfg.shift_stb_intv_enb == 1) && (k ==1)) begin
                                    idle_data[i] = 0;
                                end else begin
                                    idle_data[i] = vif.user_stb;
                                end
                            end
                        end //for
                    end //if
                  drv_tx_idle();
                end else begin // no delay case (inj_delay==0)
                        // send data
                        tx_data = 0;
                        for(int i = 0; i < (BUS_BIT_WIDTH*NUM_CHANNELS)/8; i++) begin //320*2/8=>80//160*2/8 =>40//80*2/8=>20
                            tx_data = tx_data << 8;
                            tx_data[7:0] = tx_item.databytes[i];
                        end // for
                        `ifdef CA_ASYMMETRIC
                            ////Insert Markers + Strobes(when tx_stb_en=0)
                            ////39(Gen1) OR 76/77/78/79 (Gen2) + Rate dependent insertion in every 80-bits
                            for (int i=0, ch=0; i<(BUS_BIT_WIDTH*NUM_CHANNELS); i+=1) begin
                                if ((i!=0) && (i%BUS_BIT_WIDTH == 0)) ch++;
                                if ((i == `CA_TX_MARKER_LOC) || (i == ((ch*BUS_BIT_WIDTH)+`CA_TX_MARKER_LOC))) begin
                                  `ifdef GEN2//Full=80,HAlf=160,Quarter=320
                                    if(BUS_BIT_WIDTH == 80) begin
                                        tx_data[(ch*BUS_BIT_WIDTH) + 0 + `CA_TX_MARKER_LOC]  = vif.user_marker[0];
                                    end
                                    if(BUS_BIT_WIDTH == 160)begin
                                       tx_data[(ch*BUS_BIT_WIDTH) + 0 +  `CA_TX_MARKER_LOC]  = vif.user_marker[0];
                                       tx_data[(ch*BUS_BIT_WIDTH) + 80 + `CA_TX_MARKER_LOC] = vif.user_marker[1];
                                    end
                                    if(BUS_BIT_WIDTH == 320) begin 
                                       tx_data[(ch*BUS_BIT_WIDTH) + 0  + `CA_TX_MARKER_LOC] = vif.user_marker[0];
                                       tx_data[(ch*BUS_BIT_WIDTH) + 80 + `CA_TX_MARKER_LOC] = vif.user_marker[1];
                                       tx_data[(ch*BUS_BIT_WIDTH) +160 + `CA_TX_MARKER_LOC] = vif.user_marker[2];
                                       tx_data[(ch*BUS_BIT_WIDTH) +240 + `CA_TX_MARKER_LOC] = vif.user_marker[3];
                                    end
                                  `else //GEN1 //bus-width FULL=40,HALF=80 : marker always @39
                                    if(BUS_BIT_WIDTH == 40) begin
                                       tx_data[(ch*BUS_BIT_WIDTH)+39] = vif.user_marker[0];
                                    end
                                    else if(BUS_BIT_WIDTH == 80) begin
                                       tx_data[(ch*BUS_BIT_WIDTH) + 39] = vif.user_marker[0];
                                       tx_data[(ch*BUS_BIT_WIDTH) + 79] = vif.user_marker[1];
                                    end
                                  `endif
                                end //of marker_loc
                            end //of for loop
                        `else
                            for (int i=0, ch=0; i<(BUS_BIT_WIDTH*NUM_CHANNELS); i+=1) begin
                                if ((i!=0) && (i%BUS_BIT_WIDTH == 0)) ch++;
                                if(BUS_BIT_WIDTH == 160)begin //HALF
                                    tx_data[(ch*BUS_BIT_WIDTH) + 0 + `CA_TX_MARKER_LOC]  = vif.user_marker[0];
                                    tx_data[(ch*BUS_BIT_WIDTH) + 80 + `CA_TX_MARKER_LOC] = vif.user_marker[1];
                                end
                                if(BUS_BIT_WIDTH == 320) begin //QUARTER
                                    tx_data[(ch*BUS_BIT_WIDTH) + 0  + `CA_TX_MARKER_LOC] = vif.user_marker[0];
                                    tx_data[(ch*BUS_BIT_WIDTH) + 80 + `CA_TX_MARKER_LOC] = vif.user_marker[1];
                                    tx_data[(ch*BUS_BIT_WIDTH) +160 + `CA_TX_MARKER_LOC] = vif.user_marker[2];
                                    tx_data[(ch*BUS_BIT_WIDTH) +240 + `CA_TX_MARKER_LOC] = vif.user_marker[3];
                                end
                            end //for
                        `endif //CA_ASYMMETRIC
                           if ((cfg.tx_stb_en == 1'b0) && (cfg.stop_strobes_inject == 0)) begin
                                if (cfg.tx_stb_wd_sel[7:0]  == 8'h01) begin
                                    stb_bit_pos = index; //int'(cfg.tx_stb_bit_sel[39:0]);
                                end else begin
                                    stb_bit_pos = ($clog2(cfg.tx_stb_wd_sel[7:0])*40) + (index);
                                end
                                for (int i=0, k=0; i<(BUS_BIT_WIDTH*NUM_CHANNELS); i+=1) begin
                                    if ((i!=0) && (i%BUS_BIT_WIDTH == 0)) k++;  //// represents Channel
                                    if ((i == stb_bit_pos) || (i == ((BUS_BIT_WIDTH*k)+stb_bit_pos))) begin
                                        //$display("inside stb_inject part2.time, i = %0d",$time,i);
                                        if((cfg.shift_stb_intv_enb == 1) && (k ==1)) begin
                                           tx_data[i] = 0;
                                        end else begin
                                           tx_data[i] = vif.user_stb;
                                        end
                                    end
                                end //for
                            end //if
                        tx_cnt++;
                        vif.tx_din = tx_data;
                        `uvm_info("drv_tx", $sformatf("%s Driving transfer %0d TB ---> tx_din: 0x%h", my_name, tx_cnt, tx_data), UVM_MEDIUM);
                        got_tx = 0;
                end // no delay
            end // got pkt == 1
            else begin //Send IDLE
                idle_data = 0 ;
             `ifdef CA_ASYMMETRIC
                for (int i=0, ch=0; i<(BUS_BIT_WIDTH*NUM_CHANNELS); i+=1) begin

                    if ((i!=0) && (i%BUS_BIT_WIDTH == 0)) ch++;

                    if ((i == `CA_TX_MARKER_LOC) || (i == ((ch*BUS_BIT_WIDTH)+`CA_TX_MARKER_LOC))) begin
                    `ifdef GEN2//Full=80,HAlf=160,Quarter=320
                        if(BUS_BIT_WIDTH == 80) begin
                            idle_data[(ch*BUS_BIT_WIDTH) + 0 + `CA_TX_MARKER_LOC]  = vif.user_marker[0];
                        end
                        if(BUS_BIT_WIDTH == 160)begin
                           idle_data[(ch*BUS_BIT_WIDTH) + 0 + `CA_TX_MARKER_LOC]  = vif.user_marker[0];
                           idle_data[(ch*BUS_BIT_WIDTH) + 80 + `CA_TX_MARKER_LOC] = vif.user_marker[1];
                        end
                        if(BUS_BIT_WIDTH == 320) begin 
                           idle_data[(ch*BUS_BIT_WIDTH) + 0  + `CA_TX_MARKER_LOC] = vif.user_marker[0];
                           idle_data[(ch*BUS_BIT_WIDTH) + 80 + `CA_TX_MARKER_LOC] = vif.user_marker[1];
                           idle_data[(ch*BUS_BIT_WIDTH) +160 + `CA_TX_MARKER_LOC] = vif.user_marker[2];
                           idle_data[(ch*BUS_BIT_WIDTH) +240 + `CA_TX_MARKER_LOC] = vif.user_marker[3];
                        end
                    `else //GEN1 //FULL=40,HALF=80
                        if(BUS_BIT_WIDTH == 40) begin
                           idle_data[(ch*BUS_BIT_WIDTH) +39] = vif.user_marker[0];
                        end else if(BUS_BIT_WIDTH == 80) begin
                            idle_data[(ch*80)+39]  = vif.user_marker[0];
                            idle_data[(ch*80)+79]  = vif.user_marker[1];
                        end
                    `endif
                    end //of marker_loc
                end //of for loop
             `else //SYMMETRIC
                for (int i=0, ch=0; i<(BUS_BIT_WIDTH*NUM_CHANNELS); i+=1) begin
                    if ((i!=0) && (i%BUS_BIT_WIDTH == 0)) ch++;
                    if(BUS_BIT_WIDTH == 160)begin //HALF
                        idle_data[(ch*BUS_BIT_WIDTH) + 0 + `CA_TX_MARKER_LOC]  = vif.user_marker[0];
                        idle_data[(ch*BUS_BIT_WIDTH) + 80 + `CA_TX_MARKER_LOC] = vif.user_marker[1];
                    end
                    if(BUS_BIT_WIDTH == 320) begin //QUARTER
                        idle_data[(ch*BUS_BIT_WIDTH) + 0  + `CA_TX_MARKER_LOC] = vif.user_marker[0];
                        idle_data[(ch*BUS_BIT_WIDTH) + 80 + `CA_TX_MARKER_LOC] = vif.user_marker[1];
                        idle_data[(ch*BUS_BIT_WIDTH) +160 + `CA_TX_MARKER_LOC] = vif.user_marker[2];
                        idle_data[(ch*BUS_BIT_WIDTH) +240 + `CA_TX_MARKER_LOC] = vif.user_marker[3];
                    end
                end //for
             `endif //CA_ASYMMETRIC
////Inject Strobe in Tx Data at appropriate channel position, when CA-DUT input tx_stb_en=0
                if ((cfg.tx_stb_en == 1'b0) && (cfg.stop_strobes_inject == 0)) begin
                    index = 0;
                    for (int i=0; i<40; i+=1) begin
                        if (cfg.tx_stb_bit_sel[i]) begin
                            index = i;
                            break;
                        end
                    end
                    if (cfg.tx_stb_wd_sel[7:0]  == 8'b1) begin
                        stb_bit_pos = index;  ///Strobe position in First 39:0 bits
                    end else begin
                        stb_bit_pos = ($clog2(cfg.tx_stb_wd_sel[7:0])*40) + (index);
                    end
                    for (int i=0, k=0; i<(BUS_BIT_WIDTH*NUM_CHANNELS); i+=1) begin
                        if ((i!=0) && (i%BUS_BIT_WIDTH == 0)) k++; //Channel Num select
                        if ((i == stb_bit_pos) || (i == ((BUS_BIT_WIDTH*k)+stb_bit_pos))) begin
                           if((cfg.shift_stb_intv_enb == 1) && (k ==1)) begin
                              idle_data[i] = 0;
                           end else begin
                              idle_data[i] = vif.user_stb;
                           end
                        end
                    end //for
                end //if (ca_cfg.tx_stb_en == 0)

                drv_tx_idle();
            end //send IDLE
        end // non reset
    end // forever clk
endtask: drv_tx

//----------------------------------------------
function void ca_tx_tb_out_drv_c::drv_tx_idle();
        
    vif.tx_din           <=  idle_data;
    vif.tx_stb_en        <=  cfg.tx_stb_en;
    vif.tx_stb_rcvr      <=  cfg.tx_stb_rcvr;
    vif.tx_stb_wd_sel    <=  cfg.tx_stb_wd_sel;
    vif.tx_stb_bit_sel   <=  cfg.tx_stb_bit_sel;
    vif.tx_stb_intv      <=  cfg.tx_stb_intv;
    //`uvm_info("drv_tx", $sformatf("Driving transfer TB ---> tx_din: 0x%h", vif.tx_din), UVM_DEBUG);

endfunction : drv_tx_idle

//----------------------------------------------
function void ca_tx_tb_out_drv_c::check_phase(uvm_phase phase);

    bit  pass = 1;

    `uvm_info("check_phase", $sformatf("Starting ca_tx_tb_out_drv check_phase..."), UVM_LOW);
                
    if(((cfg.stop_strobes_inject == 0) && (cfg.stb_error_test == 0) && (cfg.align_error_test == 0) ) && ((got_tx == 1) || (tx_q.size() > 0))) begin
        `uvm_warning("check_phase", $sformatf("%s ca_tx_tb_out thread active: in transcation: %s queued : %0d", 
            my_name, got_tx ? "T":"F", tx_q.size()));
         pass = 0;
    end

    if(pass == 1) begin
        `uvm_info("check_phase", $sformatf("%s ca_tx_tb_out_drv check_phase ok", my_name), UVM_LOW);
    end
    else begin
        `uvm_error("check_phase", $sformatf("%s ca_tx_tb_out_drv check_phase FAIL - work still pending!", my_name));
    end

endfunction : check_phase

//////////////////////////////////////////////////////////////////////////////
`endif
