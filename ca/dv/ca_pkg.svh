////////////////////////////////////////////////////////////////////////////////////////////////////
//
//        Copyright (C) 2021 Eximius Design
//                All Rights Reserved
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Eximius Design
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

`ifndef _CA_PKG_
`define _CA_PKG_
////////////////////////////////////////////////////////////////////
package ca_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"

    // TB generated defines
    //--------------------------------------------------- 
    
    // TB knobs 
    //--------------------------------------------------- 
    `include "../tests/ca_knobs.sv"
    
    // seq items and data structs 
    //--------------------------------------------------- 
    import ca_data_pkg::*;
    
    // agent pkgs 
    //--------------------------------------------------- 
    import reset_pkg::*;
    import chan_delay_pkg::*;
    import ca_tx_tb_out_pkg::*;
    import ca_tx_tb_in_pkg::*;
    import ca_rx_tb_in_pkg::*;

    // cfg class 
    //--------------------------------------------------- 
    `include "../tests/ca_cfg.sv"

    // scoreboard 
    //--------------------------------------------------- 
    `include "../export_src/ca_coverage.sv"
    `include "../export_src/ca_scoreboard.sv"
    
    // seqs classes
    //--------------------------------------------------- 
    `include "../seqs/virt_seqr.sv"
    `include "../seqs/ca_tx_traffic_seq.sv"
    `include "../seqs/ca_seq_lib.sv"

    // env 
    //--------------------------------------------------- 
    `include "../tb/ca_top_env.sv"
 
    // tests 
    //--------------------------------------------------- 
    `include "../tests/base_ca_test.sv"
    `include "../tests/ca_basic_test.sv"
    
////////////////////////////////////////////////////////////////////
endpackage : ca_pkg
`endif
