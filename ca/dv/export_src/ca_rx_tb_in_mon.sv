`ifndef _CA_RX_TB_IN_MON_
`define _CA_RX_TB_IN_MON_
///////////////////////////////////////////////////////////////////
class ca_rx_tb_in_mon_c #(int BUS_BIT_WIDTH=80, int NUM_CHANNELS=2) extends uvm_monitor ;
    
    // register w/ the factory
    //------------------------------------------
    `uvm_component_param_utils(ca_rx_tb_in_mon_c #(BUS_BIT_WIDTH, NUM_CHANNELS))

    // Virtual Interface
    //------------------------------------------
    ca_rx_tb_in_cfg_c             cfg;
    ca_data_pkg::ca_seq_item_c    stb_item;
    virtual ca_rx_tb_in_if        #(.BUS_BIT_WIDTH(BUS_BIT_WIDTH), .NUM_CHANNELS(NUM_CHANNELS)) vif;  

    //------------------------------------------
    // Data Members
    //------------------------------------------
    bit                      rx_active = 0;
    string                   my_name = "";
    int                      rx_cnt = 0;
    int                      stb_cnt = 0;
    int                      stb_beat_cnt = 0;
    bit                      stb_sync = 0;
    
    bit [((BUS_BIT_WIDTH*NUM_CHANNELS)-1):0]  exp_stb_data = 0; 

    //------------------------------------------
    // Component Members
    //------------------------------------------
    uvm_analysis_port #(ca_data_pkg::ca_seq_item_c) aport;

    //------------------------------------------
    // Standard UVM Methods:
    //------------------------------------------
    extern function new(string name = "ca_rx_tb_in_mon", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    
    extern function void verify_rx_stb();
    extern function void gen_stb_beat();
    extern function void set_item(ca_data_pkg::ca_seq_item_c  item);
    
    extern task mon_rx(); 
    extern task mon_err_sig();
    
    extern virtual function void check_phase(uvm_phase phase);

endclass : ca_rx_tb_in_mon_c

/////////////////////////////////////////////////

//----------------------------------------------
function ca_rx_tb_in_mon_c::new(string name = "ca_rx_tb_in_mon", uvm_component parent = null);
    
    super.new(name, parent);
    `uvm_info("ca_rx_tb_in_mon_c::new", $sformatf("BUS_BIT_WIDTH == %0d", BUS_BIT_WIDTH), UVM_LOW);
    `uvm_info("ca_rx_tb_in_mon_c::new", $sformatf("NUM_CHANNELS  == %0d", NUM_CHANNELS), UVM_LOW);

endfunction : new

//----------------------------------------------
function void ca_rx_tb_in_mon_c::build_phase(uvm_phase phase);
    
    aport = new("aport", this);

    // get the interface
    if( !uvm_config_db #( virtual ca_rx_tb_in_if #(BUS_BIT_WIDTH, NUM_CHANNELS) )::get(this, "" , "ca_rx_tb_in_vif", vif) )  
        `uvm_fatal("build_phase", "unable to get ca_rx_tb_in vif")

endfunction: build_phase

//----------------------------------------------
task ca_rx_tb_in_mon_c::run_phase(uvm_phase phase);
    
    fork
        mon_rx();
        mon_err_sig();
    join 

endtask : run_phase

//----------------------------------------------
function void ca_rx_tb_in_mon_c::set_item(ca_data_pkg::ca_seq_item_c  item);

    item.is_tx          = 0;
    item.my_name        = my_name;
    item.bus_bit_width  = BUS_BIT_WIDTH;
    item.num_channels   = NUM_CHANNELS;
    item.stb_wd_sel     = cfg.rx_stb_wd_sel;
    item.stb_bit_sel    = cfg.rx_stb_bit_sel;
    item.stb_intv       = cfg.rx_stb_intv;

endfunction : set_item

//----------------------------------------------
function void ca_rx_tb_in_mon_c::gen_stb_beat();

    `uvm_info("gen_stb_beat", $sformatf("RX TB_out:"), UVM_LOW);
    stb_item = ca_data_pkg::ca_seq_item_c::type_id::create("stb_item") ;
    set_item(stb_item);
    stb_item.calc_stb_beat();

endfunction : gen_stb_beat

//----------------------------------------------
task ca_rx_tb_in_mon_c::mon_rx(); 

    logic [((BUS_BIT_WIDTH*NUM_CHANNELS)-1):0]  rx_data = 0; 
    ca_data_pkg::ca_seq_item_c                  ca_item;
    bit                                         calc_stb = 1;

    forever begin @(posedge vif.clk)
        
        if(vif.rst_n === 1'b0) begin 
            // reset state
            rx_active = 0;
            rx_cnt = 0;
            stb_cnt = 0;
            stb_sync = 0;
            if(calc_stb == 1) begin
                calc_stb = 0;
                gen_stb_beat();
            end
        end
        else if((vif.rx_online === 1'b1) && (vif.align_done === 1'b1)) begin // non reset state
            
            calc_stb = 1; 

            stb_cnt++; 
            rx_data = vif.rx_dout;
            if((|rx_data !== 1'b0) && ((^rx_data) !== 1'bx)) begin 
                rx_cnt++;
                ca_item = ca_data_pkg::ca_seq_item_c::type_id::create("ca_item");
                set_item(ca_item);
                ca_item.init_xfer((BUS_BIT_WIDTH*NUM_CHANNELS) / 8);
                `uvm_info("mon_rx_tb_in", $sformatf("%s rx-ing rxRTL --> TB xfer: %0d rx_din: 0x%h", my_name, rx_cnt, rx_data), UVM_MEDIUM);
                for(int i = 0; i < (BUS_BIT_WIDTH*NUM_CHANNELS) / 8; i++) begin
                    ca_item.databytes[i] = rx_data[7:0];
                    rx_data = rx_data >> 8;
                 end // for
                 case(ca_item.is_stb_beat(stb_item))
                     2'b01: begin
                         ca_item.add_stb = 0;
                         aport.write(ca_item); // data only
                     end
                     2'b10: begin
                         verify_rx_stb();  // stb only
                     end
                     3'b11: begin // both data and stb
                         verify_rx_stb();  
                         ca_item.add_stb = 1;
                         aport.write(ca_item);
                     end
                     default: begin
                         ca_item.dprint();
                         `uvm_fatal("mon_rx_tb_in", $sformatf("BAD case in is_stb_beat for above beat"));
                     end
                 endcase
            end // if        
        end // non reset 
    end // clk

endtask : mon_rx

//---------------------------------------------
function void ca_rx_tb_in_mon_c::verify_rx_stb();


    if(cfg.rx_stb_en == 0) begin
        `uvm_error("verify_rx_stb", $sformatf("%s rx stb rx-ed with rx_stb_en: %0d", my_name, cfg.rx_stb_en));
    end

    stb_beat_cnt++;
    if(stb_sync == 0) begin
        stb_sync = 1;
        if(stb_cnt >= 2 * cfg.rx_stb_intv) begin
            `uvm_error("verify_rx_stb", $sformatf("INIT: %s did NOT rx stb rx_dout beat within rx_stb_intv: %0d | act: %0d",
                my_name, cfg.rx_stb_intv, stb_cnt));
        end
    end
    else begin // sync

        if(stb_cnt != cfg.rx_stb_intv) begin
            `uvm_error("verify_rx_stb", $sformatf("%s did NOT rx stb_cnt: %0d rx_dout beat within rx_stb_intv: %0d | act: %0d",
                my_name, stb_beat_cnt, cfg.rx_stb_intv, stb_cnt));
        end
        else begin
            `uvm_info("verify_rx_stb", $sformatf("%s rx stb_cnt: %0d rx_dout beat within rx_stb_intv: %0d | act: %0d",
                my_name, stb_beat_cnt, cfg.rx_stb_intv, stb_cnt), UVM_MEDIUM);
        end
        //
    end
    stb_cnt = 0;

endfunction : verify_rx_stb

    
//---------------------------------------------
task ca_rx_tb_in_mon_c::mon_err_sig(); 

    ca_data_pkg::ca_seq_item_c                ca_item;

    forever begin @(posedge vif.clk)
        
        if(vif.rst_n === 1'b0) begin 
            // reset state
            end
        else if(vif.rx_online === 1'b1) begin // non reset state
    
            if((vif.rx_stb_pos_err !== 1'b0 ) || (vif.rx_stb_pos_coding_err !== 1'b0) || vif.align_err !== 1'b0) begin 
                ca_item = ca_data_pkg::ca_seq_item_c::type_id::create("ca_item");
                set_item(ca_item);
                `uvm_warning("mon_err_sig", $sformatf("%s rx-ing error: rx_stb_pos_err: %h  rx_stb_pos_coding_err: %h align_err: %h",
                    my_name, vif.rx_stb_pos_err, vif.rx_stb_pos_coding_err, vif.align_err));
                ca_item.stb_pos_err        = vif.rx_stb_pos_err;
                ca_item.stb_pos_coding_err = vif.rx_stb_pos_coding_err;
                ca_item.align_err          = vif.align_err;
                aport.write(ca_item); 
            end // non error 
    
        end // non reset 
    end // clk

endtask : mon_err_sig    

//---------------------------------------------
function void ca_rx_tb_in_mon_c::check_phase(uvm_phase phase);

    if(rx_active == 1) `uvm_error("check_phase", $sformatf("TX pkt rx_active still active at EOT!"));
    
    if(vif.align_done !== 1'b1) begin
       `uvm_error("check_phase", $sformatf("%s align_done NEVER asserted! act: %0h", my_name, vif.align_done));
    end

endfunction : check_phase

////////////////////////////////////////////////////////////
`endif

