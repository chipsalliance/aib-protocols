`ifndef _CA_TX_TRAFFIC_SEQ_
`define _CA_TX_TRAFFIC_SEQ_

//////////////////////////////////////////////////////////////////////
class ca_tx_traffic_seq_c extends uvm_sequence #(ca_seq_item_c);

    `uvm_object_utils(ca_tx_traffic_seq_c)
    
    ca_cfg_c               ca_cfg;
    string                 my_name = "";
    int                    xfer_cnt = 0;
    
    //------------------------------------------
    extern function new(string name = "ca_tx_traffic_seq");
    extern task body();
    extern task run_tx();

endclass : ca_tx_traffic_seq_c

////////////////////////////////////////////////////////////
function ca_tx_traffic_seq_c::new(string name = "ca_tx_traffic_seq");
    
    super.new(name);

endfunction : new

//------------------------------------------
task ca_tx_traffic_seq_c::body();

    super.body(); 
    
    `uvm_info("body", $sformatf("START %s tx_traffic seq...", my_name), UVM_LOW);

    fork
        run_tx();
    join
   
    
    `uvm_info("body", $sformatf("END %s tx_traffic seq...\n", my_name), UVM_LOW);

endtask : body
//------------------------------------------
task ca_tx_traffic_seq_c::run_tx();
    
    // vars
    ca_seq_item_c     xfer_item; 
    
    for(int i = 0; i < xfer_cnt; i++) begin
        xfer_item = ca_seq_item_c::type_id::create("xfer_item");
        if(!xfer_item.randomize()) `uvm_fatal("run_tx", $sformatf("%s randomization FAILED omg!!!", my_name));
        xfer_item.print();
        start_item(xfer_item);
        `uvm_info("run_tx", $sformatf("%s sending in xfer cnt: %0d", my_name, i+1), UVM_MEDIUM);
        finish_item(xfer_item);
    end // i
endtask : run_tx
////////////////////////////////////////////////////////////

`endif
