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

    int  tx_xfer_cnt  = 0; // number of xfers from TB into RTL on the TX side

    int  tx_out_cnt_die_a   = 0;
    int  tx_out_cnt_die_b   = 0;
    int  rx_out_cnt_die_a   = 0;
    int  rx_out_cnt_die_b   = 0;

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
    die_a_tx_stb_item.calc_stb_beat();
    die_a_tx_stb_item.dprint();
    
    die_b_tx_stb_item.is_tx          = 1;
    die_b_tx_stb_item.my_name        = "DIE_B";
    die_b_tx_stb_item.bus_bit_width  = `TB_DIE_B_BUS_BIT_WIDTH;
    die_b_tx_stb_item.num_channels   = `TB_DIE_B_NUM_CHANNELS;
    die_b_tx_stb_item.stb_wd_sel     = ca_cfg.ca_die_b_tx_tb_in_cfg.tx_stb_wd_sel;
    die_b_tx_stb_item.stb_bit_sel    = ca_cfg.ca_die_b_tx_tb_in_cfg.tx_stb_bit_sel;
    die_b_tx_stb_item.stb_intv       = ca_cfg.ca_die_b_tx_tb_in_cfg.tx_stb_intv;
    die_b_tx_stb_item.calc_stb_beat();
    die_b_tx_stb_item.dprint();

    die_a_rx_stb_item.is_tx          = 0;
    die_a_rx_stb_item.my_name        = "DIE_A";
    die_a_rx_stb_item.bus_bit_width  = `TB_DIE_B_BUS_BIT_WIDTH;
    die_a_rx_stb_item.num_channels   = `TB_DIE_B_NUM_CHANNELS;
    die_a_rx_stb_item.stb_wd_sel     = ca_cfg.ca_die_a_rx_tb_in_cfg.rx_stb_wd_sel;
    die_a_rx_stb_item.stb_bit_sel    = ca_cfg.ca_die_a_rx_tb_in_cfg.rx_stb_bit_sel;
    die_a_rx_stb_item.stb_intv       = ca_cfg.ca_die_a_rx_tb_in_cfg.rx_stb_intv;
    die_a_rx_stb_item.calc_stb_beat();
    die_a_rx_stb_item.dprint();

    die_b_rx_stb_item.is_tx          = 0;
    die_b_rx_stb_item.my_name        = "DIE_B";
    die_b_rx_stb_item.bus_bit_width  = `TB_DIE_B_BUS_BIT_WIDTH;
    die_b_rx_stb_item.num_channels   = `TB_DIE_B_NUM_CHANNELS;
    die_b_rx_stb_item.stb_wd_sel     = ca_cfg.ca_die_b_rx_tb_in_cfg.rx_stb_wd_sel;
    die_b_rx_stb_item.stb_bit_sel    = ca_cfg.ca_die_b_rx_tb_in_cfg.rx_stb_bit_sel;
    die_b_rx_stb_item.stb_intv       = ca_cfg.ca_die_b_rx_tb_in_cfg.rx_stb_intv;
    die_b_rx_stb_item.calc_stb_beat();
    die_b_rx_stb_item.dprint();
    
endfunction : generate_stb_beat

//------------------------------------------
function void ca_scoreboard_c::write_ca_tx_tb_out ( ca_data_pkg::ca_seq_item_c  tx_tb_out_item );

    tx_xfer_cnt++;
    `uvm_info("write_ca_tx_tb_out",$sformatf("===> SB RX-ing %0d item from TB: %s --> RTL tx_din \n", tx_xfer_cnt, tx_tb_out_item.my_name), UVM_MEDIUM);
    tx_tb_out_item.dprint();
    case(tx_tb_out_item.my_name)
        "DIE_A": die_a_tx_din_q.push_back(tx_tb_out_item);
        "DIE_B": die_b_tx_din_q.push_back(tx_tb_out_item); 
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

    int  beat_cnt = 0;
    `uvm_info("write_rx_tb_in",$sformatf("===> SB RX-ing from RTL: %s --> TB rx_dout \n", rx_tb_in_item.my_name), UVM_MEDIUM);

    if((rx_tb_in_item.stb_pos_err == 1) || (rx_tb_in_item.stb_pos_coding_err == 1) || (rx_tb_in_item.align_err == 1)) begin
        proc_rx_tb_in_err(rx_tb_in_item);
    end
    else begin // non error taffic
        case(rx_tb_in_item.my_name)
            "DIE_A": beat_cnt = ++rx_out_cnt_die_a;
            "DIE_B": beat_cnt = ++rx_out_cnt_die_b;
            default: begin
                `uvm_fatal("write_rx_tb_in", "BAD case in my_name");
            end
        endcase
        `uvm_info("write_rx_tb_in",$sformatf("===> SB RX-ing %0d item from RTL: %s --> TB rx_dout \n", beat_cnt, rx_tb_in_item.my_name), UVM_MEDIUM);
        rx_tb_in_item.dprint();
        verify_rx_dout(rx_tb_in_item);
    end

endfunction : write_rx_tb_in

//=========================================================================================
function void ca_scoreboard_c::proc_tx_tb_in_err( ca_data_pkg::ca_seq_item_c  tx_tb_in_item );

    `uvm_error("proc_tx_tb_in", $sformatf("%s UNEXPECTED ERROR: tx_stb_pos_err: %0d  tx_stb_pos_coding_err: %0d",
        tx_tb_in_item.my_name, tx_tb_in_item.stb_pos_err, tx_tb_in_item.stb_pos_coding_err));

endfunction : proc_tx_tb_in_err

//------------------------------------------
function void ca_scoreboard_c::proc_rx_tb_in_err( ca_data_pkg::ca_seq_item_c  rx_tb_in_item );

    `uvm_error("proc_rx_tb_in", $sformatf("%s UNEXPECTED ERROR: rx_stb_pos_err: %0d  rx_stb_pos_coding_err: %0d align_err: %0d",
        rx_tb_in_item.my_name, rx_tb_in_item.stb_pos_err, rx_tb_in_item.stb_pos_coding_err, rx_tb_in_item.align_err));

endfunction : proc_rx_tb_in_err

//=========================================================================================
function void ca_scoreboard_c::verify_tx_dout(ca_data_pkg::ca_seq_item_c  act_item);

    ca_data_pkg::ca_seq_item_c   src_item;
    bit                          do_compare = 1;
    int                          xfer_cnt = 0;

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
        `uvm_info("verify_tx_dout", $sformatf("%s is_stb detected, added stb bits into expect data...", act_item.my_name), UVM_LOW);
        if(act_item.my_name == "DIE_A") begin
            src_item.add_stb_beat(die_a_tx_stb_item);
        end
        else begin
            src_item.add_stb_beat(die_b_tx_stb_item);
        end // b
    end // stb
    else begin
        `uvm_info("verify_tx_dout", $sformatf("%s is_stb not detected, clear stb bits into expect data...", act_item.my_name), UVM_LOW);
        if(act_item.my_name == "DIE_A") begin
            src_item.clr_stb_beat(die_a_tx_stb_item);
        end
        else begin
            src_item.clr_stb_beat(die_b_tx_stb_item);
        end // b
    end

    if(do_compare == 1) begin
        if(src_item.compare_beat(act_item) == 1) begin
            `uvm_info("verify_tx_dout", $sformatf("%s xfer_cnt: %0d tx_din --> tx_dout pass",
                act_item.my_name, xfer_cnt), UVM_LOW);
            // store act_item for rx rtl out / rx tb in checking
            if(act_item.my_name == "DIE_A") begin
                `uvm_info("verify_tx_dout", $sformatf("%s xfer_cnt: %0d storing exp for DIE_B rx_dout",
                    act_item.my_name, xfer_cnt), UVM_MEDIUM);
                die_b_exp_rx_dout_q.push_back(act_item);    
            end
            else begin
                `uvm_info("verify_tx_dout", $sformatf("%s xfer_cnt: %0d storing exp for DIE_A rx_dout",
                    act_item.my_name, xfer_cnt), UVM_MEDIUM);
                die_a_exp_rx_dout_q.push_back(act_item);    
            end
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
    bit                          do_compare = 1;
    int                          xfer_cnt = 0;

    // get expect pkt from tx_din
    case(act_item.my_name)
        "DIE_A": begin // came from die_B
            if(die_a_exp_rx_dout_q.size() == 0) begin
                do_compare = 0;
                `uvm_error("verify_rx_dout", $sformatf("DIE_A NO expect src pkt: %0d from rx_dout",rx_out_cnt_die_a));
            end  
            else begin
                src_item = die_a_exp_rx_dout_q.pop_front();   
                xfer_cnt = rx_out_cnt_die_a;
            end
        end
        "DIE_B": begin // came from die_A
            if(die_b_exp_rx_dout_q.size() == 0) begin
                do_compare = 0;
                `uvm_error("verify_rx_dout", $sformatf("DIE_B NO expect src pkt: %0d from rx_dout",rx_out_cnt_die_b));
            end  
            else begin
                src_item = die_b_exp_rx_dout_q.pop_front();   
                xfer_cnt = rx_out_cnt_die_b;
            end
        end
        default: begin
            `uvm_fatal("verify_rx_dout", $sformatf("BAD case in name: %s", act_item.my_name));
        end
    endcase
    
    if(do_compare == 1) begin
        if(src_item.compare_beat(act_item) == 1) begin
            `uvm_info("verify_rx_dout", $sformatf("xfer_cnt: %0d %s tx_din -- > AIB --> %s rx_dout Pass",
                xfer_cnt, src_item.my_name, act_item.my_name), UVM_LOW);
        end
        else begin
            `uvm_warning("verify_rx_dout", $sformatf("%s EXPECTED beat TX_DOUT data:", act_item.my_name));
            src_item.dprint();
            `uvm_warning("verify_rx_dout", $sformatf("%s ACTUAL beat RX_DOUT data:", act_item.my_name));
            act_item.dprint();
            `uvm_warning("verify_rx_dout", $sformatf("%s stb mask:", act_item.my_name));
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

endfunction : check_phase 

//////////////////////////////////////////////////////////////////
`endif