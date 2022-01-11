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

`ifndef _CA_SCOREBOARD_
`define _CA_SCOREBOARD_
//////////////////////////////////////////////////////////////////

//------------------------------------------
// imp declarations
//------------------------------------------
`uvm_analysis_imp_decl(_ca_reset)
`uvm_analysis_imp_decl(_ca_tx_tb_out)
`uvm_analysis_imp_decl(_tx_tb_in)
`uvm_analysis_imp_decl(_rx_tb_in)

//////////////////////////////////////////////////////////////////
class ca_scoreboard_c extends uvm_scoreboard;
    
    //------------------------------------------
    // UVM Factory Registration Macro
    //------------------------------------------
    `uvm_component_utils(ca_scoreboard_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    ca_cfg_c         ca_cfg;


    bit  do_compare_rx_dout = 1'b1;
    bit  do_compare         = 1'b1;

    int  tx_xfer_cnt_a        = 0; // number of xfers from TB into RTL on the TX side
    int  tx_xfer_cnt_b        = 0; // number of xfers from TB into RTL on the TX side
    int  xfer_cnt           = 0;
    int  tx_out_cnt_die_a   = 0;
    int  tx_out_cnt_die_b   = 0;
    real rx_out_cnt_die_a   = 0;
    real rx_out_cnt_die_b   = 0;

    real  beat_cnt_a, beat_cnt_b;
    int   beat_cnt;

    ca_data_pkg::ca_seq_item_c  die_a_tx_din_q[$];    
    ca_data_pkg::ca_seq_item_c  die_b_tx_din_q[$]; 
    ca_data_pkg::ca_seq_item_c  die_a_exp_rx_dout_q[$];    
    ca_data_pkg::ca_seq_item_c  die_b_exp_rx_dout_q[$]; 
    
    ca_data_pkg::ca_seq_item_c  die_a_tx_stb_item; 
    ca_data_pkg::ca_seq_item_c  die_b_tx_stb_item; 
    ca_data_pkg::ca_seq_item_c  die_a_rx_stb_item; 
    ca_data_pkg::ca_seq_item_c  die_b_rx_stb_item; 
    //------------------------------------------
    // Component Members
    //------------------------------------------
    uvm_analysis_imp_ca_reset #(reset_seq_item_c, ca_scoreboard_c)  ca_reset_export;
    uvm_analysis_imp_ca_tx_tb_out #(ca_data_pkg::ca_seq_item_c, ca_scoreboard_c) ca_tx_tb_out_export;
    uvm_analysis_imp_tx_tb_in #(ca_data_pkg::ca_seq_item_c, ca_scoreboard_c) tx_tb_in_export;
    uvm_analysis_imp_rx_tb_in #(ca_data_pkg::ca_seq_item_c, ca_scoreboard_c) rx_tb_in_export;
    
    //------------------------------------------
    // Methods
    //------------------------------------------
    // Standard UVM Methods:
    //------------------------------------------
    extern function new(string name = "ca_scoreboard", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void write_ca_reset( reset_seq_item_c  trig );
    extern function void write_ca_tx_tb_out( ca_data_pkg::ca_seq_item_c  tx_tb_out_item );
    extern function void write_tx_tb_in( ca_data_pkg::ca_seq_item_c  tx_tb_in_item );
    extern function void write_rx_tb_in( ca_data_pkg::ca_seq_item_c  rx_tb_in_item );
    
    //------------------------------------------
    // predict functions 
    //------------------------------------------
    extern function void proc_tx_tb_in_err(ca_data_pkg::ca_seq_item_c  tx_tb_in_item);
    extern function void proc_rx_tb_in_err(ca_data_pkg::ca_seq_item_c  rx_tb_in_item);
    extern function void proc_rx_tb_in_aln_err(ca_data_pkg::ca_seq_item_c  rx_tb_in_item);
    extern function void generate_stb_beat( );
    
    //------------------------------------------
    // verify functions
    //------------------------------------------
    extern function void verify_tx_dout(ca_data_pkg::ca_seq_item_c  act_item);
    extern function void verify_rx_dout(ca_data_pkg::ca_seq_item_c  act_item);
    
    //------------------------------------------
    // eot checks
    //------------------------------------------
    extern function bit check_queue(ca_data_pkg::ca_seq_item_c  q_item[$], string q_name);
    
    //------------------------------------------
    // coverage 
    //------------------------------------------
    ca_cfg_covergroup   ca_cfg_cg;    

    //------------------------------------------
    // uvm phase checking
    //------------------------------------------
    extern virtual function void check_phase(uvm_phase phase);

endclass: ca_scoreboard_c
////////////////////////////////////////////////////////////

//------------------------------------------
function ca_scoreboard_c::new(string name = "ca_scoreboard", uvm_component parent = null);

    super.new(name, parent);

endfunction : new
 
//----------------------------------------------
function void ca_scoreboard_c::build_phase(uvm_phase phase);
    
    ca_reset_export        = new("ca_reset_export", this);
    ca_tx_tb_out_export    = new("ca_tx_tb_out_export", this);
    tx_tb_in_export        = new("tx_tb_in_export", this);
    rx_tb_in_export        = new("rx_tb_in_export", this);
    
    // get the cfg 
    if( !uvm_config_db #( ca_cfg_c )::get(this, "" , "ca_cfg", ca_cfg) )  
        `uvm_fatal("build_phase", "unable to get cfg")
    
endfunction : build_phase

//------------------------------------------
function void ca_scoreboard_c::write_ca_reset( reset_seq_item_c  trig );
    
    `uvm_info("write_ca_reset","===> SB RX-ing trig from RESET\n", UVM_MEDIUM);
    generate_stb_beat();

endfunction : write_ca_reset 
//------------------------------------------
function void ca_scoreboard_c::generate_stb_beat( );

    bit [`TB_DIE_A_BUS_BIT_WIDTH-1:0]  stb_wd = 'h0;
    bit [39:0]                         stb_beat = 'h0;

    `uvm_info("generate_stb_beat", $sformatf("generate stb_beat for DIE_A/DIE_B"), UVM_LOW);

    die_a_tx_stb_item = ca_seq_item_c::type_id::create("die_a_tx_stb_item");
    die_b_tx_stb_item = ca_seq_item_c::type_id::create("die_b_tx_stb_item");
    die_a_rx_stb_item = ca_seq_item_c::type_id::create("die_a_rx_stb_item");
    die_b_rx_stb_item = ca_seq_item_c::type_id::create("die_b_rx_stb_item");

    die_a_tx_stb_item.is_tx          = 1;
    die_a_tx_stb_item.my_name        = "DIE_A";
    die_a_tx_stb_item.bus_bit_width  = `TB_DIE_A_BUS_BIT_WIDTH;
    die_a_tx_stb_item.num_channels   = `TB_DIE_A_NUM_CHANNELS;
    die_a_tx_stb_item.stb_wd_sel     = ca_cfg.ca_die_a_tx_tb_in_cfg.tx_stb_wd_sel;
    die_a_tx_stb_item.stb_bit_sel    = ca_cfg.ca_die_a_tx_tb_in_cfg.tx_stb_bit_sel;
    die_a_tx_stb_item.stb_intv       = ca_cfg.ca_die_a_tx_tb_in_cfg.tx_stb_intv;
    die_a_tx_stb_item.stb_en         = ca_cfg.ca_die_a_tx_tb_out_cfg.tx_stb_en;   
    die_a_tx_stb_item.calc_stb_beat();
    die_a_tx_stb_item.dprint();
    
    die_b_tx_stb_item.is_tx          = 1;
    die_b_tx_stb_item.my_name        = "DIE_B";
    die_b_tx_stb_item.bus_bit_width  = `TB_DIE_B_BUS_BIT_WIDTH;
    die_b_tx_stb_item.num_channels   = `TB_DIE_B_NUM_CHANNELS;
    die_b_tx_stb_item.stb_wd_sel     = ca_cfg.ca_die_b_tx_tb_in_cfg.tx_stb_wd_sel;
    die_b_tx_stb_item.stb_bit_sel    = ca_cfg.ca_die_b_tx_tb_in_cfg.tx_stb_bit_sel;
    die_b_tx_stb_item.stb_intv       = ca_cfg.ca_die_b_tx_tb_in_cfg.tx_stb_intv;
    die_b_tx_stb_item.stb_en         = ca_cfg.ca_die_b_tx_tb_out_cfg.tx_stb_en; 
    die_b_tx_stb_item.calc_stb_beat();
    die_b_tx_stb_item.dprint();

    die_a_rx_stb_item.is_tx          = 0;
    die_a_rx_stb_item.my_name        = "DIE_A";
    die_a_rx_stb_item.bus_bit_width  = `TB_DIE_B_BUS_BIT_WIDTH;
    die_a_rx_stb_item.num_channels   = `TB_DIE_B_NUM_CHANNELS;
    die_a_rx_stb_item.stb_wd_sel     = ca_cfg.ca_die_a_rx_tb_in_cfg.rx_stb_wd_sel;
    die_a_rx_stb_item.stb_bit_sel    = ca_cfg.ca_die_a_rx_tb_in_cfg.rx_stb_bit_sel;
    die_a_rx_stb_item.stb_intv       = ca_cfg.ca_die_a_rx_tb_in_cfg.rx_stb_intv;
    die_a_rx_stb_item.stb_en         = ca_cfg.ca_die_a_rx_tb_in_cfg.rx_stb_en;
    die_a_rx_stb_item.stb_rcvr_enb   = ca_cfg.ca_die_a_rx_tb_in_cfg.tx_stb_rcvr;   
    die_a_rx_stb_item.calc_stb_beat();
    die_a_rx_stb_item.dprint();

    die_b_rx_stb_item.is_tx          = 0;
    die_b_rx_stb_item.my_name        = "DIE_B";
    die_b_rx_stb_item.bus_bit_width  = `TB_DIE_B_BUS_BIT_WIDTH;
    die_b_rx_stb_item.num_channels   = `TB_DIE_B_NUM_CHANNELS;
    die_b_rx_stb_item.stb_wd_sel     = ca_cfg.ca_die_b_rx_tb_in_cfg.rx_stb_wd_sel;
    die_b_rx_stb_item.stb_bit_sel    = ca_cfg.ca_die_b_rx_tb_in_cfg.rx_stb_bit_sel;
    die_b_rx_stb_item.stb_intv       = ca_cfg.ca_die_b_rx_tb_in_cfg.rx_stb_intv;
    die_b_rx_stb_item.stb_en         = ca_cfg.ca_die_b_rx_tb_in_cfg.rx_stb_en;
    die_b_rx_stb_item.stb_rcvr_enb   = ca_cfg.ca_die_b_rx_tb_in_cfg.tx_stb_rcvr;   
    die_b_rx_stb_item.calc_stb_beat();
    die_b_rx_stb_item.dprint();
    
endfunction : generate_stb_beat

//------------------------------------------
function void ca_scoreboard_c::write_ca_tx_tb_out ( ca_data_pkg::ca_seq_item_c  tx_tb_out_item );
   
    if(tx_tb_out_item.my_name == "DIE_A") begin
       tx_xfer_cnt_a++;
    `uvm_info("write_ca_tx_tb_out",$sformatf("===> SB RX-ing %0d item from TB: %s --> RTL tx_din \n", tx_xfer_cnt_a, tx_tb_out_item.my_name), UVM_MEDIUM);
    end else begin
       tx_xfer_cnt_b++;
    `uvm_info("write_ca_tx_tb_out",$sformatf("===> SB RX-ing %0d item from TB: %s --> RTL tx_din \n", tx_xfer_cnt_b, tx_tb_out_item.my_name), UVM_MEDIUM);
    end
    tx_tb_out_item.dprint();
    case(tx_tb_out_item.my_name)
        "DIE_A": begin
                     if(tx_xfer_cnt_a <= (ca_cfg.ca_knobs.tx_xfer_cnt_die_a)) begin  
                        die_a_tx_din_q.push_back(tx_tb_out_item);
                     end
                 end
        "DIE_B": begin
                     if(tx_xfer_cnt_b <= (ca_cfg.ca_knobs.tx_xfer_cnt_die_b)) begin  
		        die_b_tx_din_q.push_back(tx_tb_out_item); 
                      end
                 end
        default: begin
            `uvm_fatal("write_tx_tb_out", "BAD case in my_name");
        end
    endcase

endfunction : write_ca_tx_tb_out

//------------------------------------------
function void ca_scoreboard_c::write_tx_tb_in( ca_data_pkg::ca_seq_item_c  tx_tb_in_item );

    int  beat_cnt = 0;
    
    if((tx_tb_in_item.stb_pos_err == 1) || (tx_tb_in_item.stb_pos_coding_err == 1)) begin
        proc_tx_tb_in_err(tx_tb_in_item);
    end
    else begin // non error taffic
        case(tx_tb_in_item.my_name)
            "DIE_A": beat_cnt = ++tx_out_cnt_die_a;
            "DIE_B": beat_cnt = ++tx_out_cnt_die_b;
            default: begin
                `uvm_fatal("write_tx_tb_in", "BAD case in my_name");
            end
        endcase
        `uvm_info("write_tx_tb_in",$sformatf("===> SB RX-ing %0d item from RTL %s tx_din --> TB tx_dout \n", beat_cnt, tx_tb_in_item.my_name), UVM_MEDIUM);
        tx_tb_in_item.dprint();
        verify_tx_dout(tx_tb_in_item);
    end

endfunction : write_tx_tb_in

//------------------------------------------
function void ca_scoreboard_c::write_rx_tb_in( ca_data_pkg::ca_seq_item_c  rx_tb_in_item );

    `uvm_info("write_rx_tb_in",$sformatf("===> SB RX-ing from RTL: %s --> TB rx_dout \n", rx_tb_in_item.my_name), UVM_MEDIUM);

    if((rx_tb_in_item.stb_pos_err == 1) || (rx_tb_in_item.stb_pos_coding_err == 1)) begin
        proc_rx_tb_in_err(rx_tb_in_item);
    end 
    else if(rx_tb_in_item.align_err == 1) begin
        proc_rx_tb_in_aln_err(rx_tb_in_item);
    end
    else begin // non error taffic
        case(rx_tb_in_item.my_name)
            "DIE_A": begin
                      `ifndef CA_ASYMMETRIC
                        beat_cnt = ++rx_out_cnt_die_a;
                      `else
                        beat_cnt_a += 1;
                        if(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_a == 0 ) begin 
                        rx_out_cnt_die_a = beat_cnt_a *  rx_tb_in_item.cnt_mul;
                        end
                      `endif
                        if(rx_out_cnt_die_a == (ca_cfg.ca_knobs.tx_xfer_cnt_die_b)) begin  
                             ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_a = 1; 
                             ca_cfg.ca_die_b_rx_tb_in_cfg.drv_tfr_complete_b = 1; 
                        end
                        if(ca_cfg.ca_die_a_tx_tb_in_cfg.ca_afly1_stb_incorrect_intv_test == 1)begin
                           if(ca_cfg.ca_die_a_tx_tb_out_cfg.req_cnt == (ca_cfg.ca_knobs.tx_xfer_cnt_die_a)) begin  //check if requested count of transfer done at Tx driver
                                ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_a = 1; 
                                ca_cfg.ca_die_b_rx_tb_in_cfg.drv_tfr_complete_b = 1; 
                           end
                        end
                     end
            "DIE_B": begin
                      `ifndef CA_ASYMMETRIC
                        beat_cnt = ++rx_out_cnt_die_b;
                      `else
                        beat_cnt_b += 1;
                        if(ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_b == 0 ) begin 
                           rx_out_cnt_die_b = beat_cnt_b *  rx_tb_in_item.cnt_mul;
                        end
                        //if(beat_cnt == rx_tb_in_item.last_tx_cnt_b) rx_out_cnt_die_b = beat_cnt * rx_tb_in_item.cnt_mul;
                      `endif
                        if(ca_cfg.ca_die_a_tx_tb_in_cfg.ca_afly1_stb_incorrect_intv_test == 0)begin
                           if(rx_out_cnt_die_b == (ca_cfg.ca_knobs.tx_xfer_cnt_die_a)) begin  
                                ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_b = 1; 
                                ca_cfg.ca_die_b_rx_tb_in_cfg.drv_tfr_complete_a = 1; 
                           end
                        end else begin 
                           if(ca_cfg.ca_die_b_tx_tb_out_cfg.req_cnt == (ca_cfg.ca_knobs.tx_xfer_cnt_die_b)) begin  
                                ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_b = 1; 
                                ca_cfg.ca_die_b_rx_tb_in_cfg.drv_tfr_complete_a = 1; 
                           end
                        end
                     end
            default: begin
                `uvm_fatal("write_rx_tb_in", "BAD case in my_name");
            end
        endcase
                    if((ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_a == 1 ) && (ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_b == 1)) begin
                       ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab = 1;
                       ca_cfg.ca_die_b_rx_tb_in_cfg.drv_tfr_complete_ab = 1;
                       ca_cfg.ca_die_a_tx_tb_in_cfg.drv_tfr_complete_ab = 1;
                       ca_cfg.ca_die_b_tx_tb_in_cfg.drv_tfr_complete_ab = 1;
                       $display("drv_tfr_complete_ab %0d",ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab);
                    end
                     // $display("RX:: drv_tfr_complete_ab %0d,%0d,%s",ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab,ca_cfg.ca_die_b_rx_tb_in_cfg.drv_tfr_complete_ab,rx_tb_in_item.my_name);
                     // $display("TX:: drv_tfr_complete_ab %0d,%0d,%s",ca_cfg.ca_die_a_tx_tb_in_cfg.drv_tfr_complete_ab,ca_cfg.ca_die_b_tx_tb_in_cfg.drv_tfr_complete_ab,rx_tb_in_item.my_name);
                     // $display("my_name %0s rx_cnt %0f,tx_cnt   %0d",rx_tb_in_item.my_name ,rx_out_cnt_die_a,ca_cfg.ca_knobs.tx_xfer_cnt_die_a);
                     // $display("my_name %0s rx_cnt %0f,tx_cnt   %0d",rx_tb_in_item.my_name ,rx_out_cnt_die_b,ca_cfg.ca_knobs.tx_xfer_cnt_die_b);

       `ifdef CA_ASYMMETRIC
        //$display("cnt_mul = %0f,beat %0f,rx_die_a %0f,rx_die_b %0f,last_tx_cnt_a %0d,last_tx_cnt_b %0d,my_name  %s",rx_tb_in_item.cnt_mul,(rx_tb_in_item.my_name=="DIE_A")?beat_cnt_a:beat_cnt_b,rx_out_cnt_die_a,rx_out_cnt_die_b,rx_tb_in_item.last_tx_cnt_a,rx_tb_in_item.last_tx_cnt_b,rx_tb_in_item.my_name);
        `uvm_info("write_rx_tb_in",$sformatf("===> SB RX-ing %0d item from RTL: %s --> TB rx_dout \n", (rx_tb_in_item.my_name=="DIE_A")?beat_cnt_a:beat_cnt_b, rx_tb_in_item.my_name), UVM_MEDIUM);
        `else
        `uvm_info("write_rx_tb_in",$sformatf("===> SB RX-ing %0d item from RTL: %s --> TB rx_dout \n", beat_cnt, rx_tb_in_item.my_name), UVM_MEDIUM);
        `endif
        rx_tb_in_item.dprint();
        verify_rx_dout(rx_tb_in_item);
    end

endfunction : write_rx_tb_in

//=========================================================================================
function void ca_scoreboard_c::proc_tx_tb_in_err( ca_data_pkg::ca_seq_item_c  tx_tb_in_item );
     if(ca_cfg.ca_die_a_tx_tb_in_cfg.stb_error_test == 0)  begin
       `uvm_error("proc_tx_tb_in", $sformatf("%s UNEXPECTED ERROR: tx_stb_pos_err: %0d  tx_stb_pos_coding_err: %0d",
            tx_tb_in_item.my_name, tx_tb_in_item.stb_pos_err, tx_tb_in_item.stb_pos_coding_err));
     end
endfunction : proc_tx_tb_in_err

//------------------------------------------
function void ca_scoreboard_c::proc_rx_tb_in_err( ca_data_pkg::ca_seq_item_c  rx_tb_in_item );

     if((ca_cfg.ca_die_a_tx_tb_in_cfg.stb_error_test == 0) && (ca_cfg.ca_die_a_tx_tb_in_cfg.ca_afly1_stb_incorrect_intv_test == 0))  begin
        `uvm_error("proc_rx_tb_in", $sformatf("%s UNEXPECTED ERROR: rx_stb_pos_err: %0d  rx_stb_pos_coding_err: %0d ",
            rx_tb_in_item.my_name, rx_tb_in_item.stb_pos_err, rx_tb_in_item.stb_pos_coding_err));
     end 
endfunction : proc_rx_tb_in_err

//------------------------------------------
function void ca_scoreboard_c::proc_rx_tb_in_aln_err( ca_data_pkg::ca_seq_item_c  rx_tb_in_item );

     if((ca_cfg.ca_die_a_tx_tb_in_cfg.align_error_afly0_test == 0) && (ca_cfg.ca_die_a_tx_tb_in_cfg.stb_error_test == 0) && (ca_cfg.ca_die_a_tx_tb_in_cfg.ca_afly1_stb_incorrect_intv_test == 0))  begin
        `uvm_error("proc_rx_tb_in_aln_err", $sformatf("%s UNEXPECTED ERROR: align_err: %0d",
            rx_tb_in_item.my_name, rx_tb_in_item.align_err));
     end 
endfunction : proc_rx_tb_in_aln_err

//=========================================================================================
function void ca_scoreboard_c::verify_tx_dout(ca_data_pkg::ca_seq_item_c  act_item);

    ca_data_pkg::ca_seq_item_c   src_item;
    int                          size_mul;

    // get expect pkt from tx_din
    case(act_item.my_name)
        "DIE_A": begin
            if(die_a_tx_din_q.size() == 0) begin
                do_compare = 0;
                    `uvm_error("verify_tx_dout", $sformatf("DIE_A NO expect src pkt: %0d from tx_din",tx_out_cnt_die_a));
            end  
            else begin
                xfer_cnt = tx_out_cnt_die_a;
                src_item = die_a_tx_din_q.pop_front();
            end
        end
        "DIE_B": begin
            if(die_b_tx_din_q.size() == 0) begin
                do_compare = 0;
                     `uvm_error("verify_tx_dout", $sformatf("DIE_B NO expect src pkt: %0d from tx_din",tx_out_cnt_die_b));
            end  
            else begin
                xfer_cnt = tx_out_cnt_die_b;
                src_item = die_b_tx_din_q.pop_front();

            end
        end
        default: begin
            `uvm_fatal("verify_tx_dout", $sformatf("BAD case in name: %s", act_item.my_name));
        end
    endcase

    // if is_stb, add the stb bits into the expect / src data
    if(act_item.add_stb == 1) begin
        `uvm_info("verify_tx_dout", $sformatf("%s is_stb detected, added stb bits into expect data...", act_item.my_name), UVM_MEDIUM);
        if(act_item.my_name == "DIE_A") begin
            if((die_a_rx_stb_item.stb_rcvr_enb == 0) && (die_a_tx_stb_item.stb_en == 1)) begin 
               src_item.add_stb_beat(die_a_tx_stb_item);
            end
        end
        else begin
            if((die_b_rx_stb_item.stb_rcvr_enb == 0) && (die_b_tx_stb_item.stb_en == 1)) begin
               src_item.add_stb_beat(die_b_tx_stb_item);
            end
        end // b
    end // stb
    else begin
        `uvm_info("verify_tx_dout", $sformatf("%s is_stb not detected, clear stb bits into expect data...", act_item.my_name), UVM_MEDIUM);
        if(act_item.my_name == "DIE_A") begin
            if((die_a_rx_stb_item.stb_rcvr_enb == 0 ) && (die_a_tx_stb_item.stb_en == 1)) begin 
               src_item.clr_stb_beat(die_a_tx_stb_item);
            end
        end
        else begin
            if((die_b_rx_stb_item.stb_rcvr_enb == 0) && (die_b_tx_stb_item.stb_en == 1)) begin
               src_item.clr_stb_beat(die_b_tx_stb_item);
            end
        end // b
    end

    if(do_compare == 1) begin
        if(src_item.compare_beat(act_item,1'b0) == 1) begin
        
             `uvm_info("verify_tx_dout", $sformatf("%s xfer_cnt: %0d tx_din --> tx_dout pass", act_item.my_name, xfer_cnt), UVM_MEDIUM);
             // store act_item for rx rtl out / rx tb in checking
              `ifdef CA_ASYMMETRIC 
                  if(act_item.tx_data_rdy == 1)begin
                      act_item.databytes = act_item.tx_data_fin;
              `endif
               `ifndef CA_ASYMMETRIC 
                 `ifdef GEN1
                       if((`TB_DIE_A_BUS_BIT_WIDTH == 80) && (`TB_DIE_B_BUS_BIT_WIDTH == 80)) begin //HALF RATE
                           act_item.databytes = act_item.tx_data_bkp;
                       end
                 `endif
               `endif
                    if(act_item.my_name == "DIE_A") begin 
                        `uvm_info("verify_tx_dout", $sformatf("%s xfer_cnt: %0d storing exp for DIE_B rx_dout", act_item.my_name, xfer_cnt), UVM_MEDIUM);
                        die_b_exp_rx_dout_q.push_back(act_item);    
                    end
                    else begin
                        `uvm_info("verify_tx_dout", $sformatf("%s xfer_cnt: %0d storing exp for DIE_A rx_dout", act_item.my_name, xfer_cnt), UVM_MEDIUM);
                        die_a_exp_rx_dout_q.push_back(act_item);    
                    end
           `ifdef CA_ASYMMETRIC
                end //of tx_data_rdy
           `endif
            
         end
         else begin
             `uvm_warning("verify_tx_dout", $sformatf("%s EXPECTED beat TX_DIN data:", act_item.my_name));
             src_item.dprint();
             `uvm_warning("verify_tx_dout", $sformatf("%s ACTUAL beat TX_DOUT data:", act_item.my_name));
             act_item.dprint();
             `uvm_warning("verify_tx_dout", $sformatf("%s stb mask:", act_item.my_name));
             if(act_item.my_name == "DIE_A") die_a_tx_stb_item.dprint();
             else die_b_tx_stb_item.dprint();
             `uvm_error("verify_tx_dout", $sformatf("%s xfer_cnt: %0d tx_din --> tx_dout MISMATCH see above for error",
                 act_item.my_name, xfer_cnt));
         end
    end

endfunction : verify_tx_dout

//------------------------------------------------------
function void ca_scoreboard_c::verify_rx_dout(ca_data_pkg::ca_seq_item_c  act_item);

    ca_data_pkg::ca_seq_item_c   src_item;
    int                          xfer_cnt = 0;

    // get expect pkt from tx_din
    case(act_item.my_name)
        "DIE_A": begin // came from die_B
            if(die_a_exp_rx_dout_q.size() == 0) begin
                do_compare = 0;
                this.do_compare_rx_dout = 1'b0;
                `uvm_error("verify_rx_dout", $sformatf("DIE_A NO expect src pkt: %0f from rx_dout",beat_cnt_a));
            end  
            else begin
                src_item = die_a_exp_rx_dout_q.pop_front();  
                `ifdef CA_ASYMMETRIC 
                   xfer_cnt = beat_cnt_a * act_item.cnt_mul;
                `else
                   xfer_cnt = beat_cnt;
                `endif
            end
        end
        "DIE_B": begin // came from die_A
            if(die_b_exp_rx_dout_q.size() == 0) begin
                do_compare = 0;
                this.do_compare_rx_dout = 1'b0;
                `uvm_error("verify_rx_dout", $sformatf("DIE_B NO expect src pkt: %0f from rx_dout",beat_cnt_b));
            end  
            else begin
                src_item = die_b_exp_rx_dout_q.pop_front();   
                `ifdef CA_ASYMMETRIC 
                   xfer_cnt = beat_cnt_b * act_item.cnt_mul;
                `else
                   xfer_cnt = beat_cnt;
                `endif
            end
        end
        default: begin
            `uvm_fatal("verify_rx_dout", $sformatf("BAD case in name: %s", act_item.my_name));
        end
    endcase
    
    if(do_compare == 1) begin
    //if (this.do_compare_rx_dout == 1'b1) begin

        if(src_item.compare_beat(act_item,1'b1) == 1) begin
            `uvm_info("verify_rx_dout", $sformatf("xfer_cnt: %0d %s tx_din -- > AIB --> %s rx_dout Pass",
            xfer_cnt, src_item.my_name, act_item.my_name), UVM_LOW);
        end
        else begin /// show error 
            `uvm_warning("verify_rx_dout", $sformatf("%s EXPECTED beat TX_DOUT data:", src_item.my_name));
            src_item.dprint();
            `uvm_warning("verify_rx_dout", $sformatf("%s ACTUAL beat RX_DOUT data:", act_item.my_name));
            act_item.dprint();

            `uvm_warning("verify_rx_dout", $sformatf("%s stb mask:", act_item.my_name));

            ////Configured STB
            if(act_item.my_name == "DIE_A") die_a_rx_stb_item.dprint();
            else die_b_rx_stb_item.dprint();

            `uvm_error("verify_tx_dout", $sformatf("xfer_cnt: %0d %s tx_din --> AIB --> %s rx_dout MISMATCH see above for error",
            xfer_cnt, src_item.my_name, act_item.my_name));
        end
    end
endfunction : verify_rx_dout

//------------------------------------------------------
function bit ca_scoreboard_c::check_queue(ca_data_pkg::ca_seq_item_c  q_item[$], string q_name);

    ca_data_pkg::ca_seq_item_c   item;
    
    check_queue = 1;
    
    if(q_item.size() > 0) begin
        check_queue = 0;
        `uvm_warning("check_queue", $sformatf("%s NOT empty: %0d first item:", q_name, q_item.size()));
        item = q_item.pop_front();
        item.dprint(); 
    end   
    else begin
        `uvm_info("check_phase", $sformatf("%s empty: ok", q_name), UVM_LOW);
    end

    return check_queue;

endfunction : check_queue

//=========================================================================================
function void ca_scoreboard_c::check_phase(uvm_phase phase);

    bit pass = 1;
    ca_data_pkg::ca_seq_item_c   item;

       if ((ca_cfg.ca_die_b_tx_tb_in_cfg.ca_afly1_stb_incorrect_intv_test == 0) && (ca_cfg.ca_die_a_tx_tb_in_cfg.ca_afly1_stb_incorrect_intv_test == 0)) begin
    super.check_phase(phase);
    `uvm_info("CHECK_PHASE", $sformatf("Starting scoreboard check_phase..."), UVM_LOW);
    
    if(check_queue(die_a_tx_din_q, "die_a_tx_din_q") == 0) pass = 0;
    if(check_queue(die_b_tx_din_q, "die_b_tx_din_q") == 0) pass = 0;
    if(check_queue(die_a_exp_rx_dout_q, "die_a_exp_rx_dout_q") == 0) pass = 0;   
    if(check_queue(die_b_exp_rx_dout_q, "die_b_exp_rx_dout_q") == 0) pass = 0;   
    
    if(pass == 1) begin
        `uvm_info("check_phase", "passed\n", UVM_NONE);  
    end
    else begin
        `uvm_error("check_phase", ">> FAIL <<  Please see above msg\n"); 
    end

    end

endfunction : check_phase 

//////////////////////////////////////////////////////////////////
`endif
