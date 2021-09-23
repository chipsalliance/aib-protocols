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
    bit [7:0]                      databytes[];

    `uvm_object_utils_begin(ca_seq_item_c)
        `uvm_field_int(fbyte, UVM_DEFAULT);
        `uvm_field_int(inj_delay, UVM_DEFAULT);
    `uvm_object_utils_end

    //------------------------------------------
    // constraints 
    //------------------------------------------
    constraint c_inj_delay { inj_delay >= 0 ; inj_delay <= 2; }
   
    // Standard UVM Methods:
    extern function new(string name = "ca_seq_item");
    extern function void init_xfer(int size);
    extern function void dprint(int bytes_per_line = 5);
    extern function void build_tx_beat(ca_seq_item_c  stb_beat);
    extern function bit [1:0] is_stb_beat(ca_seq_item_c  stb_beat);
    extern function void calc_stb_beat();
    extern function void add_stb_beat(ca_seq_item_c  stb_beat);
    extern function void clr_stb_beat(ca_seq_item_c  stb_beat);
    extern function void check_input();
    extern function bit  compare_beat(ca_seq_item_c  act_beat);

endclass : ca_seq_item_c

////////////////////////////////////////////////////////////
//--------------------------------------------------
function ca_seq_item_c::new (string name = "ca_seq_item");

    super.new(name);

endfunction : new

//--------------------------------------------------
function void ca_seq_item_c::init_xfer(int size);

    databytes = new[size];
    bcnt = size;

endfunction : init_xfer

//--------------------------------------------------
function void ca_seq_item_c::dprint(int bytes_per_line = 5);

    int     i = 0;
    string  sout = "";
    string  sbyte = "";

    if(bcnt == 0) `uvm_warning("dprint", "bcnt == 0  NOTHING to print!")
    else `uvm_info("dprint", $sformatf("displaying bytes: %0d", bcnt), UVM_MEDIUM);

    for(i = 0; i < bcnt ; i++) begin

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
            if(databytes[i] & (stb_beat.databytes[i] ^ 8'hff) != 'h0) begin
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
        databytes[i] = databytes[i] & (stb_beat.databytes[i] ^ 8'hff);
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
            `uvm_info("calc_stb_beat", $sformatf("%s %s exp i: %0d stb_wd: 0x%h", my_name, is_tx ? "TX":"RX", i, stb_wd), UVM_NONE);

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
function bit  ca_seq_item_c::compare_beat(ca_seq_item_c  act_beat);

    bit [7:0] dbyte = 0; 

    compare_beat = 1;

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
