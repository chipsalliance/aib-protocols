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
            vif.tx_online  <=  1'b0;
            tx_online = 0;
        end // reset
        else begin
            if((vif.ld_ms_rx_transfer_en === 24'hff_ffff) &&
               (vif.ld_sl_rx_transfer_en === 24'hff_ffff) &&
               (vif.fl_ms_rx_transfer_en === 24'hff_ffff) && 
               (vif.fl_sl_rx_transfer_en === 24'hff_ffff)) begin
               vif.tx_online <=  cfg.tx_online;
               if(tx_online == 0) `uvm_info("drv_tx_online", $sformatf("===>>> %s tx_online == %0d <<<===", my_name, cfg.tx_online), UVM_NONE);
               tx_online = 1;
            end 
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
    ca_data_pkg::ca_seq_item_c     tx_item;      
    bit [7:0]	                   count = 0;
    bit                            calc_stb = 1;
    
    bit [((BUS_BIT_WIDTH*NUM_CHANNELS)-1):0]  tx_data = 0; 
    
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
            end
        
            if(got_tx == 1)  begin
                if(tx_item.inj_delay > 0) begin
                    tx_item.inj_delay--;
                    drv_tx_idle();
                end // delay
                else begin
                    // send data
                    tx_data = 0;
                    for(int i = 0; i < (BUS_BIT_WIDTH*NUM_CHANNELS)/8; i++) begin
                        tx_data = tx_data << 8;
                        tx_data[7:0] = tx_item.databytes[i];
                    end // for
                    tx_cnt++;
                    vif.tx_din <= tx_data;
                    `uvm_info("drv_tx", $sformatf("%s Driving transfer %0d TB ---> tx_din: 0x%h", my_name, tx_cnt, tx_data), UVM_MEDIUM);
                    got_tx = 0;
                end // no delay
            end // got pkt
            else begin
                drv_tx_idle();
            end

        end // non reset
    end // forever clk
endtask: drv_tx

//----------------------------------------------
function void ca_tx_tb_out_drv_c::drv_tx_idle();
        
    bit [((BUS_BIT_WIDTH*NUM_CHANNELS)-1):0]  idle_data = 0; 

    /*
    if(vif.align_done === 1'b0) begin;
        for(int i = 0; i < (BUS_BIT_WIDTH*NUM_CHANNELS)/8; i++) begin
            idle_data = idle_data << 8;
            idle_data[7:0] = $urandom();
        end
    end
    */
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
                
    if((got_tx == 1) || (tx_q.size() > 0)) begin
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
