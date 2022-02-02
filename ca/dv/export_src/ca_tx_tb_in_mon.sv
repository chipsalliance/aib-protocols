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

`ifndef _CA_TX_TB_IN_MON_
`define _CA_TX_TB_IN_MON_
///////////////////////////////////////////////////////////////////
class ca_tx_tb_in_mon_c #(int BUS_BIT_WIDTH=80, int NUM_CHANNELS=2) extends uvm_monitor ;
    
    // register w/ the factory
    //------------------------------------------
    `uvm_component_param_utils(ca_tx_tb_in_mon_c #(BUS_BIT_WIDTH, NUM_CHANNELS))

    // Virtual Interface
    //------------------------------------------
    ca_tx_tb_in_cfg_c             cfg; // share cfg w/ out agent
    ca_data_pkg::ca_seq_item_c    stb_item;
    ca_data_pkg::ca_seq_item_c    die_a_exp_rx_dout_q[$];    
    ca_data_pkg::ca_seq_item_c    die_b_exp_rx_dout_q[$]; 
    virtual ca_tx_tb_in_if        #(.BUS_BIT_WIDTH(BUS_BIT_WIDTH), .NUM_CHANNELS(NUM_CHANNELS)) vif;  

    //------------------------------------------
    // Data Members
    //------------------------------------------
    bit                      tx_active = 0;
    string                   my_name = "";
    int                      tx_cnt = 0;
    int                      stb_cnt = 0;
    int                      stb_beat_cnt = 0;
    bit                      stb_sync = 0;
    bit[1:0]                 is_stb_mark=0; 
    int                      first_time_rst;
    bit[15:0]                l_tx_stb_intv; 
    logic [((BUS_BIT_WIDTH*NUM_CHANNELS)-1):0]    onlymark_data = 0; 
    logic [((BUS_BIT_WIDTH*NUM_CHANNELS)-1):0]    onlystb_data  = 0; 
    logic [((BUS_BIT_WIDTH*NUM_CHANNELS)-1):0]    markstb_data  = 0; 
    bit   [((BUS_BIT_WIDTH*NUM_CHANNELS)-1):0]    exp_stb_data  = 0; 
    //------------------------------------------
    // Component Members
    //------------------------------------------
    uvm_analysis_port #(ca_data_pkg::ca_seq_item_c) aport;

    //------------------------------------------
    // Standard UVM Methods:
    //------------------------------------------
    extern function new(string name = "ca_tx_tb_in_mon", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    
    extern task mon_tx(); 
    extern task mon_err_sig();

    extern function void test_call_gen_stb_beat();
    extern function void gen_stb_beat();
    extern function void set_item(ca_data_pkg::ca_seq_item_c  item);
    extern function void verify_tx_stb();

    extern virtual function void check_phase(uvm_phase phase);

endclass : ca_tx_tb_in_mon_c

/////////////////////////////////////////////////

//----------------------------------------------
function ca_tx_tb_in_mon_c::new(string name = "ca_tx_tb_in_mon", uvm_component parent = null);
    
    super.new(name, parent);
    `uvm_info("ca_tx_tb_in_mon_c::new", $sformatf("BUS_BIT_WIDTH == %0d", BUS_BIT_WIDTH), UVM_LOW);
    `uvm_info("ca_tx_tb_in_mon_c::new", $sformatf("NUM_CHANNELS  == %0d", NUM_CHANNELS), UVM_LOW);

endfunction : new

//----------------------------------------------
function void ca_tx_tb_in_mon_c::build_phase(uvm_phase phase);
    
    aport = new("aport", this);

    // get the interface
    if( !uvm_config_db #( virtual ca_tx_tb_in_if #(BUS_BIT_WIDTH, NUM_CHANNELS) )::get(this, "" , "ca_tx_tb_in_vif", vif) )  
        `uvm_fatal("build_phase", "unable to get ca_tx_tb_in vif")

endfunction: build_phase

//----------------------------------------------
task ca_tx_tb_in_mon_c::run_phase(uvm_phase phase);
    
    fork
        if((cfg.stop_monitor == 0) && (cfg.align_error_test == 0))begin
          mon_tx();
        end
        mon_err_sig();
    join 

endtask : run_phase

//----------------------------------------------
function void ca_tx_tb_in_mon_c::set_item(ca_data_pkg::ca_seq_item_c  item);

    item.is_tx          = 1;
    item.my_name        = my_name;
    item.bus_bit_width  = BUS_BIT_WIDTH;
    item.num_channels   = NUM_CHANNELS;
    item.stb_wd_sel     = cfg.tx_stb_wd_sel;
    item.stb_bit_sel    = cfg.tx_stb_bit_sel;
    item.stb_intv       = cfg.tx_stb_intv;

endfunction : set_item

//----------------------------------------------
function void ca_tx_tb_in_mon_c::gen_stb_beat();

    `uvm_info("gen_stb_beat", $sformatf("TX ca_tx_tb_in_mon:"), UVM_LOW);
    stb_item = ca_data_pkg::ca_seq_item_c::type_id::create("stb_item") ;
    set_item(stb_item);
    stb_item.calc_stb_beat();

endfunction : gen_stb_beat

function void ca_tx_tb_in_mon_c::test_call_gen_stb_beat();

    ///CLEAR required variables HERE
      tx_cnt           = 0;
      stb_cnt          = 0;
      stb_sync         = 0;
      first_time_rst   = 0;
      markstb_data     = 0;
      onlystb_data     = 0;
      onlymark_data    = 0;
     //calc_stb_beat computation will be in below one
      this.gen_stb_beat();

endfunction : test_call_gen_stb_beat

//----------------------------------------------
task ca_tx_tb_in_mon_c::mon_tx(); 

    logic [((BUS_BIT_WIDTH*NUM_CHANNELS)-1):0]                tx_data = 0; 
    logic [((BUS_BIT_WIDTH*NUM_CHANNELS)-1):0]                tx_data_bkp = 0; 
    logic [((BUS_BIT_WIDTH*NUM_CHANNELS)-1):0]                tx_data_prev[4]; 
    logic [((BUS_BIT_WIDTH*NUM_CHANNELS*4)-1):0]              tx_data_fin=0; 
    logic [((BUS_BIT_WIDTH*NUM_CHANNELS*4)-1):0]              tx_data_fin_prev=0; 
    ca_data_pkg::ca_seq_item_c                                ca_item;
    bit                                                       calc_stb = 1;
    int                                                       i_max;
    bit [2:0]                                                 clk_cnt;
    bit                                                       tx_compare_start=0;
    int                                                       index, stb_bit_pos;
    forever begin @(posedge vif.clk)
       
        if (vif.rst_n == 1'b1) begin
            first_time_rst = first_time_rst + 1;
        end
        if (first_time_rst == 5) begin
           //$display("tx_tb_in_mon first_time_rst : %0d, marker %0d,my_name %s,time %0t",first_time_rst,vif.user_marker,my_name,$time);
            index = 0;
             for (int i=0; i<40; i+=1) begin  ////tx_stb_bit_sel is always 39:0
                 if (cfg.tx_stb_bit_sel[i]) begin
                     index = i;
                     break;
                 end
             end
             if (cfg.tx_stb_wd_sel[7:0]  == 8'h01) begin
                 stb_bit_pos = index;
             end else begin
                 stb_bit_pos = ($clog2(cfg.tx_stb_wd_sel[7:0])*40) + (index);
             end
            for (int i=0, ch=0; i<(BUS_BIT_WIDTH*NUM_CHANNELS); i+=1) begin
                 if ((i!=0) && (i%BUS_BIT_WIDTH == 0)) ch++;
             `ifdef GEN2
               `ifdef CA_ASYMMETRIC
                   if (BUS_BIT_WIDTH == 80) begin //F2F
                       onlymark_data[(ch*BUS_BIT_WIDTH) + `CA_TX_MARKER_LOC]  = vif.user_marker; 
                       markstb_data[(ch*BUS_BIT_WIDTH)  + `CA_TX_MARKER_LOC]  = vif.user_marker;
                       markstb_data[(ch*BUS_BIT_WIDTH)+ stb_bit_pos]          = 1'b1; ///only for asym
                       onlystb_data[(ch*BUS_BIT_WIDTH)+ stb_bit_pos]          = 1'b1; ///only for asym
                   end 
               `endif//CA_ASYMMETRIC
                if (BUS_BIT_WIDTH == 160) begin 
                  for(int mk=0;mk<=1;mk++)begin ///80,160
                    onlymark_data[(ch*BUS_BIT_WIDTH) + (mk*80) + `CA_TX_MARKER_LOC]    = vif.user_marker[mk];  
                    markstb_data[(ch*BUS_BIT_WIDTH)  + (mk*80) +`CA_TX_MARKER_LOC]     = vif.user_marker[mk]; 
                  end
                    markstb_data[(ch*BUS_BIT_WIDTH)+ stb_bit_pos]                      = 1'b1; 
                    onlystb_data[(ch*BUS_BIT_WIDTH)+ stb_bit_pos]                      = 1'b1; 
                end  else if (BUS_BIT_WIDTH == 320) begin 
                  for(int mk=0;mk<=3;mk++)begin ///80,160,240,320
                    onlymark_data[(ch*BUS_BIT_WIDTH) + (mk*80) + `CA_TX_MARKER_LOC]    = vif.user_marker[mk]; 
                    markstb_data[(ch*BUS_BIT_WIDTH)  + (mk*80) + `CA_TX_MARKER_LOC]    = vif.user_marker[mk];
                  end
                    markstb_data[(ch*BUS_BIT_WIDTH)+ stb_bit_pos]                      = 1'b1; 
                    onlystb_data[(ch*BUS_BIT_WIDTH)+ stb_bit_pos]                      = 1'b1; 
                end
             `else
                if (BUS_BIT_WIDTH == 40) begin
                    onlymark_data[(ch*BUS_BIT_WIDTH) + `CA_TX_MARKER_LOC]    = vif.user_marker; 
                    markstb_data[(ch*BUS_BIT_WIDTH) + `CA_TX_MARKER_LOC]     = vif.user_marker; 
                    markstb_data[(ch*BUS_BIT_WIDTH)+ stb_bit_pos]            = 1'b1;
                    onlystb_data[(ch*BUS_BIT_WIDTH)+ stb_bit_pos]            = 1'b1;
                end else if (BUS_BIT_WIDTH == 80) begin
                    onlymark_data[(ch*BUS_BIT_WIDTH) + `CA_TX_MARKER_LOC]         = vif.user_marker;  
                    onlymark_data[(ch*BUS_BIT_WIDTH) + 40 + `CA_TX_MARKER_LOC]    = vif.user_marker;  
                    markstb_data[(ch*BUS_BIT_WIDTH)  + `CA_TX_MARKER_LOC]         = vif.user_marker; 
                    markstb_data[(ch*BUS_BIT_WIDTH)  + 40 + `CA_TX_MARKER_LOC]    = vif.user_marker; 
                    markstb_data[(ch*BUS_BIT_WIDTH)+ stb_bit_pos]                 = 1'b1;
                    onlystb_data[(ch*BUS_BIT_WIDTH)+ stb_bit_pos]                 = 1'b1;
                end 
             `endif //GEN1
            end  //of NUM_CHANNELS
        end // for first_time_rst

     if(cfg.stop_monitor == 0)begin 
        if(vif.rst_n === 1'b0) begin 
            // reset state
            tx_active = 0; 
            tx_cnt = 0;
            stb_cnt = 0;
            stb_sync = 0;
            first_time_rst   = 0;
            markstb_data     = 0;
            onlystb_data     = 0;
            onlymark_data    = 0;
            //tx_compare_start = 0;
           if(calc_stb == 1) begin
                calc_stb = 0;
                gen_stb_beat();
            end
         end //rst_n =0
        else if((vif.tx_online === 1'b1) && (vif.align_done === 1'b1)) begin // non reset state
   
            calc_stb        = 1;
            stb_cnt        += 1;

            tx_data         = vif.tx_dout; ////DUT tx-out -> AIB in data

            tx_data_prev[3] = tx_data_prev[2];             
            tx_data_prev[2] = tx_data_prev[1];             
            tx_data_prev[1] = tx_data_prev[0];             
            tx_data_prev[0] = tx_data; 
            tx_data_bkp     = tx_data; 
                `ifdef GEN1
                   //MARKERS will be removed from AIB.So,for comparison 0 is updated at marker bit position
                     for (int i=0; i< NUM_CHANNELS; i++) begin
                        for(int mk=0; mk< (BUS_BIT_WIDTH/40); mk++)begin 
                           tx_data_bkp[(i*BUS_BIT_WIDTH)+ (mk*40) + `CA_TX_MARKER_LOC]   = 0;
                        end
                     end
                `endif 
                 if(my_name == "DIE_A") begin
                      l_tx_stb_intv = vif.strobe_gen_m_interval;
                 end else begin
                      l_tx_stb_intv = vif.strobe_gen_s_interval;
                 end
      `ifndef CA_ASYMMETRIC
           if((|tx_data !== 1'b0) && ((^tx_data) !== 1'bx)) begin 
                tx_cnt++;
                tx_data_prev[0] = tx_data;
                ca_item = ca_data_pkg::ca_seq_item_c::type_id::create("ca_item");
                set_item(ca_item);
                ca_item.init_xfer((BUS_BIT_WIDTH*NUM_CHANNELS) / 8);
 
                `uvm_info("mon_tx_tb_in", $sformatf("%s rx-ing txRTL --> TB xfer: %0d tx_din: 0x%h", my_name, tx_cnt, tx_data), UVM_MEDIUM);
                for(int i = 0; i < (BUS_BIT_WIDTH*NUM_CHANNELS) / 8; i++) begin
                    ca_item.databytes[i] = tx_data[7:0];
                    tx_data = tx_data >> 8;
                    ca_item.tx_data_bkp[i] = tx_data_bkp[7:0];
                    tx_data_bkp = tx_data_bkp >> 8;
                 end // for
                 case(ca_item.is_stb_beat(stb_item))
                     2'b01: begin
                         ca_item.add_stb = 0;
                         if(((`TB_DIE_A_BUS_BIT_WIDTH == 160) && (`TB_DIE_B_BUS_BIT_WIDTH == 160)) || 
                            ((`TB_DIE_A_BUS_BIT_WIDTH == 320) && (`TB_DIE_B_BUS_BIT_WIDTH == 320)))begin
                             //$display("tx_tb_in_mon.sv 2'b01 inside H2H,Q2Q loop,time %0t onlymark_data=%h",$time,onlymark_data);
                             if(onlymark_data != tx_data_prev[0]) begin
                                 aport.write(ca_item);
                             end
                         end else begin
                             aport.write(ca_item); // data only
                         end
                     end
                     2'b10: begin
                             //$display("tx_tb_in_mon.sv 2'b10 inside  loop,time %0t onlymark_data=%h",$time,onlymark_data);
                             if((cfg.with_external_stb_test == 0) && (cfg.stb_error_test == 0) && (cfg.stop_stb_checker == 0)) begin //dont check stbs after align_done case
                                 verify_tx_stb();  // stb only
                             end
                     end
                     2'b11: begin // both data and stb
                                ca_item.add_stb = 1;
                       `ifdef GEN2
                           if(((`TB_DIE_A_BUS_BIT_WIDTH == 160) && (`TB_DIE_B_BUS_BIT_WIDTH == 160)) || 
                              ((`TB_DIE_A_BUS_BIT_WIDTH == 320) && (`TB_DIE_B_BUS_BIT_WIDTH == 320)))begin
                               //$display("tx_tb_in_mon.sv 2'b11 inside H2H,Q2Q loop,time %0t markstb_data=%h, my_name %0s,tx_data_prev[0] = %h",$time,markstb_data,my_name,tx_data_prev[0]);
                                 if((cfg.with_external_stb_test == 0) && (cfg.stb_error_test == 0) && (cfg.stop_stb_checker == 0)) begin //dont check stbs after align_done case
                                   verify_tx_stb();  
                                 end
                                 if(markstb_data != tx_data_prev[0]) begin
                                   aport.write(ca_item);
                                 end
                           end else begin
                               if((cfg.with_external_stb_test == 0) && (cfg.stb_error_test == 0) && (cfg.stop_stb_checker == 0))begin //dont check stbs after align_done case
                                  verify_tx_stb();  
                               end
                                  aport.write(ca_item);
                           end
                        `else
                           if((`TB_DIE_A_BUS_BIT_WIDTH == 80) && (`TB_DIE_B_BUS_BIT_WIDTH == 80))begin //H2H
                               if(markstb_data != tx_data_prev[0]) begin
                                 if((cfg.with_external_stb_test == 0) && (cfg.stb_error_test == 0) && (cfg.stop_stb_checker == 0)) begin //dont check stbs after align_done case
                                   verify_tx_stb();  
                                 end
                                   aport.write(ca_item);
                               end
                           end else begin//F2F
                               if((cfg.with_external_stb_test == 0) && (cfg.stb_error_test == 0) && (cfg.stop_stb_checker == 0))begin //dont check stbs after align_done case
                                  verify_tx_stb();  
                               end
                                  aport.write(ca_item);
                           end
                        `endif 
                     end
                     default: begin
                         //`uvm_fatal("mon_tx_tb_in", $sformatf("BAD case in is_stb"));
                         `uvm_error("mon_tx_tb_in", $sformatf("BAD case in is_stb"));
                     end
                 endcase
             end // if
      `else //CA_ASYMMETRIC=0
            //$display("ca_tx_tb_in_mon_c ::: onlystb_data = %h onlymark_data = %h markstb_data %h,tx_data %h,time %0t,my_name %s",onlystb_data,onlymark_data,markstb_data,tx_data,$time,my_name);

            if((tx_compare_start == 1'b1) && ((onlystb_data == tx_data) || (onlymark_data == tx_data ) || (markstb_data == tx_data) || (tx_data == 0 )) ) begin
                tx_compare_start = 0;  ///marks end-of actual Tx data out from DUT
            end else if((tx_compare_start == 1'b0) && ((onlystb_data != tx_data) && (onlymark_data != tx_data ) && (markstb_data != tx_data) && (tx_data != 0 )) ) begin
                tx_compare_start = 1;  ///marks start-of actual Tx data out from DUT
            end

            if(((tx_compare_start == 1))&& ((^tx_data) !== 1'bx)) begin 
                if (((onlystb_data != tx_data) && (onlymark_data != tx_data ) && (markstb_data != tx_data)) && (tx_data != 0 )) begin
                    tx_cnt++;
                    `uvm_info("mon_tx_tb_in", $sformatf("%s rx-ing txRTL --> TB xfer: %0d tx_din: 0x%h,clk_cnt=%0d", my_name, tx_cnt, tx_data,clk_cnt), UVM_MEDIUM);
                end
                ca_item = ca_data_pkg::ca_seq_item_c::type_id::create("ca_item");
                clk_cnt += 1'b1; 
                set_item(ca_item);
                ca_item.init_xfer((BUS_BIT_WIDTH*NUM_CHANNELS) / 8);
                ////below update for databytes is for tx-in to tx-out comparison
                for(int i = 0; i < (BUS_BIT_WIDTH*NUM_CHANNELS) / 8; i++) begin
                    ca_item.databytes[i] = tx_data[7:0];
                    tx_data = tx_data >> 8;
                end // for

                i_max = (BUS_BIT_WIDTH*NUM_CHANNELS*cfg.slave_rate)/8; //40*2*2/8
            ////////////////////////////////////////////////////////////////////////////////
                if ((cfg.master_rate == 1) && (cfg.slave_rate == 4)) begin //F2Q (Gen2:80to320)
                    if(clk_cnt == cfg.slave_rate/cfg.master_rate)  begin
                        for (int i=0; i< NUM_CHANNELS; i++) begin
                            tx_data_fin[4*(i*BUS_BIT_WIDTH) +: 4*BUS_BIT_WIDTH]  = {tx_data_prev[0][(i*BUS_BIT_WIDTH) +: BUS_BIT_WIDTH],tx_data_prev[1][(i*BUS_BIT_WIDTH) +: BUS_BIT_WIDTH],tx_data_prev[2][(i*BUS_BIT_WIDTH) +: BUS_BIT_WIDTH],tx_data_prev[3][(i*BUS_BIT_WIDTH) +: BUS_BIT_WIDTH]}; 
                        end//for
                        clk_cnt=0;
                        ca_item.tx_data_rdy = 1;
                    end
                end
                if ((cfg.master_rate == 1) && (cfg.slave_rate == 2)) begin //F2H (Gen2:80to160 or Gen1:40to80)
                    if(clk_cnt == cfg.slave_rate/cfg.master_rate)  begin
                        for (int i=0; i< NUM_CHANNELS; i++) begin
                         `ifdef GEN1
                            for(int mk=0; mk < (BUS_BIT_WIDTH/40); mk++)begin ///40,80
                              tx_data_prev[0][(i*BUS_BIT_WIDTH)+ (mk*40) + `CA_TX_MARKER_LOC]  = 0; 
                              tx_data_prev[1][(i*BUS_BIT_WIDTH)+ (mk*40) + `CA_TX_MARKER_LOC]  = 0; 
                            end
                         `endif
                            tx_data_fin[2*(i*BUS_BIT_WIDTH) +: 2*BUS_BIT_WIDTH]  = {tx_data_prev[0][(i*BUS_BIT_WIDTH) +: BUS_BIT_WIDTH],tx_data_prev[1][(i*BUS_BIT_WIDTH) +: BUS_BIT_WIDTH]}; 
                        end//for
                        clk_cnt=0;
                        ca_item.tx_data_rdy = 1;
                    end
                end
 //H2Q
                if ((cfg.master_rate == 2) && (cfg.slave_rate == 4)) begin //H2Q (Gen2:160to320)
                    if(clk_cnt == cfg.slave_rate/cfg.master_rate)  begin
                        for (int i=0; i< NUM_CHANNELS; i++) begin
                          tx_data_fin[2*(i*BUS_BIT_WIDTH) +: 2*BUS_BIT_WIDTH]  = {tx_data_prev[0][(i*BUS_BIT_WIDTH) +: BUS_BIT_WIDTH],tx_data_prev[1][(i*BUS_BIT_WIDTH) +: BUS_BIT_WIDTH]}; 
                        end //for
                        clk_cnt=0;
                        ca_item.tx_data_rdy = 1;
                    end
                end

                if ((cfg.master_rate == 2) && (cfg.slave_rate == 1)) begin //H2F (Gen2:160to80 or Gen1:80to40) //F2H 
                      tx_data_fin         = tx_data_prev[0];
                      ca_item.tx_data_rdy = 1;
                  `ifdef GEN1
                     //MARKERS will be removed from AIB.So, marker bits removed before sending to SCB.
                      for (int i=0; i< NUM_CHANNELS; i++) begin
                         for(int mk=0; mk < (BUS_BIT_WIDTH / 40); mk++)begin ///80,160,240,320
                              if(tx_data_fin[(i*BUS_BIT_WIDTH)+ (mk*40) + `CA_TX_MARKER_LOC] == 1) begin
                                tx_data_fin[(i*BUS_BIT_WIDTH)+ (mk*40) + `CA_TX_MARKER_LOC]  = 0;  //M2S1F2H
                               end
                         end
                      end
                   `endif
                end
//Q2H            
                if ((cfg.master_rate == 4) && (cfg.slave_rate == 2)) begin //Q2H (Gen2:320to160)
                      tx_data_fin         = tx_data_prev[0];
                      //for (int i=0; i< NUM_CHANNELS; i++) begin
                      //   if(tx_data_fin[(i*BUS_BIT_WIDTH)+`CA_TX_MARKER_LOC] == 1) begin
                      //      tx_data_fin[(i*BUS_BIT_WIDTH)+`CA_TX_MARKER_LOC] = 0;
                      //   end
                      //end
                      ca_item.tx_data_rdy = 1;
                end

                if ((cfg.master_rate == 4) && (cfg.slave_rate == 1)) begin //Q2F (Gen2:320to80)
                      tx_data_fin         = tx_data_prev[0];
                      //for (int i=0; i< NUM_CHANNELS; i++) begin
                      //   for(int mk=0; mk<3; mk++)begin ///80,160,240,320
                      //       if(tx_data_fin[(i*BUS_BIT_WIDTH)+ (mk*80) + `CA_TX_MARKER_LOC] == 1) begin
                      //          tx_data_fin[(i*BUS_BIT_WIDTH)+ (mk*80) + `CA_TX_MARKER_LOC]  = 0;
                      //       end
                      //   end //for mk
                      //end //for i
                      ca_item.tx_data_rdy = 1;
                end
               //////////////////////////////////////////////////////////////////////////////////////////
               //  $display("TX::interval m %0d,s %0d",vif.strobe_gen_m_interval,vif.strobe_gen_s_interval);

                 tx_data_fin_prev = tx_data_fin;

                 //// Prepare ca_item data ready to be written to scoreboard from tx-dout
                 if(ca_item.tx_data_rdy == 1) begin
                     for(int i = 0; i < i_max; i++) begin
                         ca_item.tx_data_fin[i] = tx_data_fin[7:0];
                         tx_data_fin = tx_data_fin >> 8;
                     end // for
                 end //end if tx_data_rdy
                case(ca_item.is_stb_beat(stb_item))
                     2'b01: begin
                             ca_item.add_stb = 0;
                             if(onlymark_data != tx_data_fin_prev) begin
                                 aport.write(ca_item);
                             end
                     end
                     2'b10: begin
                             if((cfg.with_external_stb_test == 0) && (cfg.stb_error_test == 0) && (cfg.stop_stb_checker == 0)) begin //dont check stbs after align_done case
                                 verify_tx_stb();  // stb only
                             end
                     end
                     2'b11: begin // both data and stb
                             ca_item.add_stb = 1;
                             if(markstb_data != tx_data_fin_prev) begin
                                 if((cfg.with_external_stb_test == 0) && (cfg.stb_error_test == 0) && (cfg.stop_stb_checker == 0)) begin //dont check stbs after align_done case
                                   verify_tx_stb();  
                                 end
                                 aport.write(ca_item);
                             end
                     end
                     default: begin
                         `uvm_error("mon_tx_tb_in", $sformatf("BAD case in is_stb"));
                     end
                 endcase
             end // if tx_data != x
 `endif
        end // non reset 
    end // stop_monitor = 0
    end // clk

endtask : mon_tx
    
//---------------------------------------------
task ca_tx_tb_in_mon_c::mon_err_sig(); 

    ca_data_pkg::ca_seq_item_c                ca_item;

    forever begin @(posedge vif.clk)
        
        if(vif.rst_n === 1'b0) begin 
            // reset state
            end
        else if(vif.tx_online === 1'b1) begin // non reset state
    
            if((vif.tx_stb_pos_err !== 1'b0 ) || (vif.tx_stb_pos_coding_err !== 1'b0)) begin 
                ca_item = ca_data_pkg::ca_seq_item_c::type_id::create("ca_item");
                set_item(ca_item);
              if(cfg.stb_error_test == 0) begin
                `uvm_warning("mon_tx", $sformatf("%s rx-ing error: tx_stb_pos_err: %0d  tx_stb_pos_coding_err: %0d",
                    my_name, vif.tx_stb_pos_err, vif.tx_stb_pos_coding_err));
                    ca_item.stb_pos_err        = vif.tx_stb_pos_err;
                    ca_item.stb_pos_coding_err = vif.tx_stb_pos_coding_err;
                    aport.write(ca_item); 
              end else begin
                    cfg.num_of_stb_error++;
                   `uvm_info("mon_tx", $sformatf("%s rx-ing error : tx_stb_pos_err %0d tx_stb_pos_coding_err %0d,tx_num_of_errors =%0d",
                    my_name, vif.tx_stb_pos_err, vif.tx_stb_pos_coding_err,cfg.num_of_stb_error), UVM_LOW);
              end 
            end // non error 
        end // non reset 
    
    end // clk
endtask : mon_err_sig
    
//---------------------------------------------
function void ca_tx_tb_in_mon_c::verify_tx_stb();
  
    stb_beat_cnt++;
    if(stb_sync == 0) begin
        stb_sync = 1;
        if(stb_cnt >= 2 * l_tx_stb_intv)begin
            `uvm_error("verify_tx_stb", $sformatf("INIT: %s did NOT rx stb tx_dout beat within tx_stb_intv: %0d | act: %0d",
              my_name, l_tx_stb_intv, stb_cnt));
        end
    end
    else begin // sync
        if(stb_cnt != l_tx_stb_intv) begin 
         `uvm_error("verify_tx_stb", $sformatf("%s TX did NOT rx stb_cnt: %0d tx_dout beat within tx_stb_intv: %0d | act: %0d",
              my_name, stb_beat_cnt, l_tx_stb_intv, stb_cnt));
        end  
        else begin
          `uvm_info("verify_tx_stb", $sformatf("%s rx stb_cnt: %0d tx_dout beat within tx_stb_intv: %0d | act: %0d",
              my_name, stb_beat_cnt,l_tx_stb_intv, stb_cnt), UVM_MEDIUM);
        end
   end

    stb_cnt = 0; 

endfunction : verify_tx_stb
    
//---------------------------------------------
function void ca_tx_tb_in_mon_c::check_phase(uvm_phase phase);
     
    bit pass = 1; 

    if((cfg.with_external_stb_test == 0) &&(cfg.stb_error_test == 0) && (cfg.align_error_test == 0) && (cfg.ca_tx_online_test == 0) && (cfg.stop_stb_checker == 0))begin
       if((cfg.tx_en_stb_check == 1) && (stb_beat_cnt == 0) && (cfg.tx_stb_en == 1)) begin
          `uvm_error("check_phase", $sformatf("%s tx_stb_en == 1 and NO stb received!", my_name));
       end
    end

    if((cfg.stb_error_test == 0) && (cfg.align_error_test == 0) && (cfg.ca_tx_online_test == 0) && (vif.align_done !== 1'b1)) begin
       if(cfg.no_external_stb_test == 0)begin
         `uvm_error("check_phase", $sformatf("%s align_done NEVER asserted! act: %0h", my_name, vif.align_done));
       end else begin
            pass = 1;
            if (cfg.no_external_stb_test == 1) begin 
            `uvm_info("check_phase", "no_external_strobes_test: align_done not asserted as expected in tx_tb_in_mon :\n", UVM_NONE); 
            end //no_external_strobes_test == 1
            if (cfg.align_error_test == 1) begin
            `uvm_info("check_phase", "align_error_test: align_done not asserted as expected  in tx_tb_in_mon:\n", UVM_NONE);
            end  //align_error_test == 1
       end  //no_external_strobes_test = 0 , align_error_test = 0
    end 

    if ((cfg.stb_error_test == 1) && (cfg.num_of_stb_error == 0))begin
         pass = 0;
    end

    if ((cfg.no_external_stb_test == 1) && (vif.align_done == 1))begin
         pass = 0;
    end

    if(pass == 1) begin
        `uvm_info("check_phase", "passed\n", UVM_NONE);  
    end
    else begin
        `uvm_error("check_phase", ">> FAIL <<  Please see above msg\n"); 
    end

endfunction : check_phase

////////////////////////////////////////////////////////////
`endif

