`ifndef _CA_RX_TB_IN_DRV_
`define _CA_RX_TB_IN_DRV_

///////////////////////////////////////////////////////////
class ca_rx_tb_in_drv_c #(int BUS_BIT_WIDTH=80, int NUM_CHANNELS=2) extends uvm_driver #(ca_data_pkg::ca_seq_item_c, ca_data_pkg::ca_seq_item_c);

    // UVM Factory Registration Macro
    `uvm_component_param_utils(ca_rx_tb_in_drv_c #(BUS_BIT_WIDTH, NUM_CHANNELS))
    
    //------------------------------------------
    // Data Members
    //------------------------------------------
    virtual ca_rx_tb_in_if     #(.BUS_BIT_WIDTH(BUS_BIT_WIDTH), .NUM_CHANNELS(NUM_CHANNELS)) vif;
    ca_rx_tb_in_cfg_c          cfg;
    int                         max_tb_inj_depth = 50;
    string                      my_name = "";

    // queues for holding seq items for injection into RTL
    ca_data_pkg::ca_seq_item_c  rx_q[$];
    bit                         got_rx = 0;
    bit                         rx_online = 0;

    //------------------------------------------
    // Standard UVM Methods:
    //------------------------------------------
    extern function new(string name = "ca_rx_tb_in_drv", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task get_item_from_seq();
    extern virtual function void check_phase(uvm_phase phase);
    
    //------------------------------------------
    // Custom UVM Methods:
    //------------------------------------------
    extern task drv_rx();
    extern task drv_rx_online();
    extern function void drv_rx_idle();

endclass: ca_rx_tb_in_drv_c

////////////////////////////////////////////////////////////
//----------------------------------------------
function ca_rx_tb_in_drv_c::new(string name = "ca_rx_tb_in_drv", uvm_component parent = null);
    
    super.new(name, parent);
    
        `uvm_info("ca_rx_tb_in_drv_c::new", $sformatf("%s BUS_BIT_WIDTH == %0d", my_name, BUS_BIT_WIDTH), UVM_LOW);
        `uvm_info("ca_rx_tb_in_drv_c::new", $sformatf("%s NUM_CHANNELS  == %0d", my_name, NUM_CHANNELS), UVM_LOW);

   endfunction : new

//----------------------------------------------
function void ca_rx_tb_in_drv_c::build_phase(uvm_phase phase);

    // get the interface
    if( !uvm_config_db #( virtual ca_rx_tb_in_if #(BUS_BIT_WIDTH, NUM_CHANNELS) )::get(this, "" , "ca_rx_tb_in_vif", vif) ) 
    `uvm_fatal("build_phase", "unable to get ca_rx_tb_in vif")

endfunction : build_phase

//----------------------------------------------
task ca_rx_tb_in_drv_c::run_phase(uvm_phase phase);
    
   fork
        get_item_from_seq();
        drv_rx();
        drv_rx_online();
    join
endtask : run_phase

//---------------------------------------------
task ca_rx_tb_in_drv_c::get_item_from_seq();
    
    ca_data_pkg::ca_seq_item_c    req_item;
    int                           req_cnt = 0;
    
    forever begin @(posedge vif.clk)
        while(rx_q.size() < max_tb_inj_depth) begin
            seq_item_port.get_next_item(req_item);
            req_cnt++;
            `uvm_info("get_item_from_seq", $sformatf("%s rx-ing %0d pkt from seq rx_q: %0d/%0d", 
                my_name, req_cnt, rx_q.size(), max_tb_inj_depth), UVM_MEDIUM);
            rx_q.push_back(req_item);
            seq_item_port.item_done();
        end // while
    end // forever

endtask : get_item_from_seq 

//----------------------------------------------
task ca_rx_tb_in_drv_c::drv_rx_online();
    
    forever begin @(posedge vif.clk)
        if(vif.rst_n === 1'b0) begin // reset state
            vif.rx_online  <=  1'b0;
            rx_online = 0;
        end // reset
        else begin // non reset state
            if((vif.ld_ms_rx_transfer_en === 24'hff_ffff) &&
               (vif.ld_sl_rx_transfer_en === 24'hff_ffff) &&
               (vif.fl_ms_rx_transfer_en === 24'hff_ffff) && 
               (vif.fl_sl_rx_transfer_en === 24'hff_ffff)) begin  // FIXME added m_rx_align_done
               vif.rx_online <=  cfg.rx_online;
               if(rx_online == 0) `uvm_info("drv_rx_online", $sformatf("===>>> %s rx_online == %0d <<<===", my_name, cfg.rx_online), UVM_NONE);
               rx_online = 1;
            end
        end // non reset
    end // forever clk

endtask : drv_rx_online

//----------------------------------------------
task ca_rx_tb_in_drv_c::drv_rx();
    
    ca_data_pkg::ca_seq_item_c     rx_item;      
    int                            rx_xfer = 0;
    bit [7:0]	                   count = 0;
    
    bit [((BUS_BIT_WIDTH*NUM_CHANNELS)-1):0]  rx_data = 0; 
    
    forever begin @(posedge vif.clk)
        if(vif.rst_n === 1'b0) begin // reset state
            drv_rx_idle();
            while(rx_q.size() > 0) rx_item = rx_q.pop_front(); 
        end // reset
        else begin // non reset state
            //
        end // non reset
    end // forever clk
endtask: drv_rx

//----------------------------------------------
function void ca_rx_tb_in_drv_c::drv_rx_idle();
        
    vif.rx_din           <= 'h0;
    vif.rx_stb_wd_sel    <=  cfg.rx_stb_wd_sel;
    vif.rx_stb_bit_sel   <=  cfg.rx_stb_bit_sel;
    vif.rx_stb_intv      <=  cfg.rx_stb_intv;
    vif.align_fly        <=  cfg.align_fly;
    vif.rden_dly         <=  cfg.rden_dly;
    vif.fifo_full_val    <=  cfg.fifo_full_val;
    vif.fifo_pfull_val   <=  cfg.fifo_pfull_val;
    vif.fifo_empty_val   <=  cfg.fifo_empty_val;
    vif.fifo_pempty_val  <=  cfg.fifo_pempty_val;

endfunction : drv_rx_idle

//----------------------------------------------
function void ca_rx_tb_in_drv_c::check_phase(uvm_phase phase);

    bit  pass = 1;

    `uvm_info("check_phase", $sformatf("Starting ca_rx_tb_in_drv check_phase..."), UVM_LOW);
                
    if((got_rx == 1) || (rx_q.size() > 0)) begin
        `uvm_warning("check_phase", $sformatf("%s ca_rx_tb_in thread active: in transcation: %s queued : %0d", 
            my_name, got_rx ? "T":"F", rx_q.size()));
         pass = 0;
        end

    if(pass == 1) begin
        `uvm_info("check_phase", $sformatf("%s ca_rx_tb_in_drv check_phase ok", my_name), UVM_LOW);
    end
    else begin
        `uvm_error("check_phase", $sformatf("%s ca_rx_tb_in_drv check_phase FAIL - work still pending!", my_name));
    end

endfunction : check_phase

//////////////////////////////////////////////////////////////////////////////
`endif
