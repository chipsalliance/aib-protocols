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
    import ca_reset_pkg::*;
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
    `include "../seqs/ca_traffic_seq.sv"

    // env 
    //--------------------------------------------------- 
    `include "../tb/ca_top_env.sv"
 
    // tests 
    //--------------------------------------------------- 
    `include "../tests/base_ca_test.sv"
    `include "../tests/ca_basic_test.sv"
    `include "../tests/ca_stb_intv_stb_pos_test.sv"
    `include "../tests/ca_stb_intv_walking_ones_test.sv"
    `include "../tests/ca_stb_wd_sel_test.sv"
    `include "../tests/ca_stb_wd_sel_Q2Q_test.sv"
    `include "../tests/ca_stb_wd_sel_bit_sel_test.sv"
    `include "../tests/ca_all_wd_sel_39th_bit_sel_test.sv"
    `include "../tests/ca_wd_bit_sel_ones_cover_test.sv"
    `include "../tests/ca_stb_all_bit_sel_test.sv"
    `include "../tests/ca_strobe_error_test.sv"
    `include "../tests/ca_tx_rx_online_test.sv"
    `include "../tests/ca_stb_enb_high_low_high_test.sv"
    `include "../tests/ca_stb_en0_aft_aln_done_test.sv"
    `include "../tests/ca_fifo_ptr_values_variations_test.sv"
    `include "../tests/ca_no_external_strobes_test.sv"
    `include "../tests/ca_with_external_strobes_test.sv"
    `include "../tests/ca_stb_rcvr_enb_test.sv"
    `include "../tests/ca_afly1_stb_incorrect_intv_test.sv"
    `include "../tests/ca_align_error_test.sv"
    `include "../tests/ca_aln_err_by_incorrect_stb_test.sv"
    `include "../tests/ca_aln_err_afly0_by_incorrect_stb_test.sv"
    `include "../tests/ca_afly1_stb_intv_variations_test.sv"
    `include "../tests/ca_afly_toggling_test.sv"
    `include "../tests/ca_stb_rcvr_aft_aln_done_test.sv"
    `include "../tests/ca_toggle_cover_test.sv"
    `include "../tests/ca_rden_dly_test.sv"
    `include "../tests/ca_delay_x_xz_values_test.sv"
    `include "../tests/ca_traffic_reset_traffic_test.sv"
    `include "../tests/ca_reset_during_traffic_test.sv"
    `include "../tests/ca_basic_afly1_test.sv"
    
////////////////////////////////////////////////////////////////////
endpackage : ca_pkg
`endif
