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

`ifndef _CA_RX_TRAFFIC_SEQ_
`define _CA_RX_TRAFFIC_SEQ_

//////////////////////////////////////////////////////////////////////
class ca_rx_traffic_seq_c extends uvm_sequence #(ca_seq_item_c);

    `uvm_object_utils(ca_rx_traffic_seq_c);
    `uvm_declare_p_sequencer(virt_seqr_c);
    
    //------------------------------------------
    extern function new(string name = "ca_rx_traffic_seq");
    extern task body();
    extern task run_rx();

endclass : ca_rx_traffic_seq_c

////////////////////////////////////////////////////////////
function ca_rx_traffic_seq_c::new(string name = "ca_rx_traffic_seq");
    
    super.new(name);

endfunction : new

//------------------------------------------
task ca_rx_traffic_seq_c::body();

    //super.body(); 
    
    `uvm_info("body", "START basic seq...", UVM_LOW);

    fork
        run_rx();
    join
   
    
    `uvm_info("body", "END basic seq...\n", UVM_LOW);

endtask : body
//------------------------------------------
task ca_rx_traffic_seq_c::run_rx();
    
    // vars
    ca_seq_item_c     pkt; 
    
    //for(int i = 0; i < ca_knobs.rx_cnt; i++) begin
    //    
    //    start_item(pkt);
    //    
    //    finish_item(pkt);
    //end // i
endtask : run_rx
////////////////////////////////////////////////////////////

`endif
