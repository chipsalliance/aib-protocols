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

`ifndef _CA_TX_TB_IN_SEQR_
`define _CA_TX_TB_IN_SEQR_

////////////////////////////////////////////////////////////

class ca_tx_tb_in_seqr_c extends uvm_sequencer #(ca_data_pkg::ca_seq_item_c, ca_data_pkg::ca_seq_item_c);

    // UVM Factory Registration Macro
    `uvm_component_utils(ca_tx_tb_in_seqr_c)

    // Standard UVM Methods:
    extern function new(string name="ca_tx_tb_in_seqr", uvm_component parent = null);

endclass: ca_tx_tb_in_seqr_c
////////////////////////////////////////////////////////////
//---------------------------------------
function ca_tx_tb_in_seqr_c::new(string name="ca_tx_tb_in_seqr", uvm_component parent = null);
    super.new(name, parent);
endfunction : new

////////////////////////////////////////////////////////////
`endif
