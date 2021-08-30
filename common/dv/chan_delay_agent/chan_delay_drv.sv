`ifndef _CHAN_DELAY_DRV_
`define _CHAN_DELAY_DRV_

///////////////////////////////////////////////////////////
class chan_delay_drv_c #(int BUS_BIT_WIDTH=80) extends uvm_driver #(chan_delay_seq_item_c, chan_delay_seq_item_c);

    // UVM Factory Registration Macro
    `uvm_component_param_utils(chan_delay_drv_c #(BUS_BIT_WIDTH))
    
    //------------------------------------------
    // Data Members
    //------------------------------------------
    virtual chan_delay_if     #(.BUS_BIT_WIDTH(BUS_BIT_WIDTH)) vif;
    chan_delay_cfg_c          cfg;
    int                       max_tb_inj_depth = 50;
    int                       chan_num = -1;
    int                       clk_multiplier = 1;

    // queues for holding seq items for injection into RTL
    chan_delay_seq_item_c     tx_q[$];
    chan_delay_seq_item_c     delay_q[$];
    bit                       got_tx = 0;

    //------------------------------------------
    // Standard UVM Methods:
    //------------------------------------------
    extern function new(string name = "chan_delay_drv", uvm_component parent = null);
    extern function void build_phase(uvm_phase phase);
    extern task run_phase(uvm_phase phase);
    extern task get_item_from_seq();
    extern virtual function void check_phase(uvm_phase phase);
    
    //------------------------------------------
    // Custom UVM Methods:
    //------------------------------------------
    extern task drv_capture();
    extern task drv_inject();

endclass: chan_delay_drv_c

////////////////////////////////////////////////////////////
//----------------------------------------------
function chan_delay_drv_c::new(string name = "chan_delay_drv", uvm_component parent = null);
    
    super.new(name, parent);
    
        `uvm_info("chan_delay_drv_c::new", $sformatf("chan: %0d BUS_BIT_WIDTH == %0d", chan_num, BUS_BIT_WIDTH), UVM_LOW);

   endfunction : new

//----------------------------------------------
function void chan_delay_drv_c::build_phase(uvm_phase phase);

    // get the interface
    if( !uvm_config_db #( virtual chan_delay_if #(BUS_BIT_WIDTH) )::get(this, "" , "chan_delay_vif", vif) ) 
    `uvm_fatal("build_phase", "unable to get chan_delay vif")

endfunction : build_phase

//----------------------------------------------
task chan_delay_drv_c::run_phase(uvm_phase phase);
    
   fork
        get_item_from_seq();
        drv_capture();
        drv_inject();
    join
endtask : run_phase

//---------------------------------------------
task chan_delay_drv_c::get_item_from_seq();
    
    chan_delay_seq_item_c         req_item;
    int                           req_cnt = 0;
    
    forever begin @(posedge vif.clk)
        while(tx_q.size() < max_tb_inj_depth) begin
            seq_item_port.get_next_item(req_item);
            req_cnt++;
            `uvm_info("get_item_from_seq", $sformatf("chan: %0d rx-ing %0d pkt from seq tx_q: %0d/%0d", 
                chan_num, req_cnt, tx_q.size(), max_tb_inj_depth), UVM_MEDIUM);
            tx_q.push_back(req_item);
            seq_item_port.item_done();
        end // while
    end // forever

endtask : get_item_from_seq 

//----------------------------------------------
task chan_delay_drv_c::drv_capture();
    
    chan_delay_seq_item_c          capture_item;      
    int                            xfer = 0;
    
    forever begin @(posedge vif.clk)
        if(vif.rst_n === 1'b0) begin // reset state
            while(tx_q.size() > 0) capture_item = tx_q.pop_front(); 
            while(delay_q.size() > 0) capture_item = delay_q.pop_front(); 
        end // reset
        else begin // non reset state
            if((|vif.din !== 1'b0) && ((^vif.din) !== 1'bx)) begin 
                capture_item = chan_delay_seq_item_c::type_id::create("capture_item");
                capture_item.data = 0;
                capture_item.data[BUS_BIT_WIDTH-1:0] = vif.din;
                // add delay here
                capture_item.chan_delay_clk = cfg.chan_delay_clk; 
                delay_q.push_back(capture_item);
            end // if
        end // non reset
    end // forever clk
endtask: drv_capture

//----------------------------------------------
task chan_delay_drv_c::drv_inject();
    
    chan_delay_seq_item_c          inject_item;      
    bit                            got_item = 0;                    
    int                            xfer = 0;
    bit [BUS_BIT_WIDTH-1:0]        dout = 0;
    
    forever begin @(posedge vif.clk)
        if(vif.rst_n === 1'b0) begin // reset state
            got_item = 0;
            vif.dout <= 'h0;
        end // reset
        else begin // non reset state
            //
            if((delay_q.size() > 0) && (got_item == 0)) begin
                got_item = 1; 
                inject_item = delay_q.pop_front();
            end

            if(got_item == 1) begin
                if(inject_item.chan_delay_clk > 0) begin
                    inject_item.chan_delay_clk--; 
                    vif.dout <= 'h0;
                end
                else begin
                    vif.dout <= inject_item.data[BUS_BIT_WIDTH-1:0];
                    got_item = 0;
                end
            end
            else begin
                vif.dout <= 'h0;
            end

        end // non reset
    end // forever clk
endtask: drv_inject

//----------------------------------------------
function void chan_delay_drv_c::check_phase(uvm_phase phase);

    bit  pass = 1;

    `uvm_info("check_phase", $sformatf("Starting chan_delay_drv check_phase..."), UVM_LOW);
                
    if((got_tx == 1) || (tx_q.size() > 0)) begin
        `uvm_warning("check_phase", $sformatf("chan: %0d chan_delay thread active: in transcation: %s queued : %0d", 
            chan_num, got_tx ? "T":"F", tx_q.size()));
         pass = 0;
        end

    if(pass == 1) begin
        `uvm_info("check_phase", $sformatf("chan: %0d chan_delay_drv check_phase ok", chan_num), UVM_LOW);
    end
    else begin
        `uvm_error("check_phase", $sformatf("chan: %0d chan_delay_drv check_phase FAIL - work still pending!", chan_num));
    end

endfunction : check_phase

//////////////////////////////////////////////////////////////////////////////
`endif
