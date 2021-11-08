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

module ca_DUT_wrapper
    #(
        parameter NUM_CHANNELS      = 2,
        parameter BITS_PER_CHANNEL  = 80,
        parameter AD_WIDTH          = 4,
        parameter SYNC_FIFO         = 1
    )
    (input [NUM_CHANNELS-1:0] clk_lane , input clk_com, input tb_reset_l,
     ca_if     ca_if
    );

    //--------------------------------------------------------------
    // Channel Alignment  : DUT instance
    //--------------------------------------------------------------
    ca #(.NUM_CHANNELS      (NUM_CHANNELS),
         .BITS_PER_CHANNEL  (BITS_PER_CHANNEL),
         .AD_WIDTH          (AD_WIDTH),
         .SYNC_FIFO         (SYNC_FIFO)
        ) ca_DUT (
             .lane_clk               (SYNC_FIFO ? {NUM_CHANNELS{clk_com}} : clk_lane[NUM_CHANNELS-1:0]),
             .com_clk                (clk_com),
             .rst_n                  (tb_reset_l),

             .tx_online              (ca_if.tx_online),
             .rx_online              (ca_if.rx_online),

             .tx_stb_en              (ca_if.tx_stb_en),
             .tx_stb_rcvr            (ca_if.tx_stb_rcvr),
             .align_fly              (ca_if.align_fly),
             .rden_dly               (ca_if.rden_dly),

             .delay_x_value          (ca_if.delay_x_value),
             .delay_z_value          (ca_if.delay_z_value),

             .tx_stb_wd_sel          (ca_if.tx_stb_wd_sel),
             .tx_stb_bit_sel         (ca_if.tx_stb_bit_sel),
             .tx_stb_intv            (ca_if.tx_stb_intv),
             .rx_stb_wd_sel          (ca_if.rx_stb_wd_sel),
             .rx_stb_bit_sel         (ca_if.rx_stb_bit_sel),
             .rx_stb_intv            (ca_if.rx_stb_intv),

             .tx_din                 (ca_if.tx_din),
             .tx_dout                (ca_if.tx_dout),
             .rx_din                 (ca_if.rx_din),
             .rx_dout                (ca_if.rx_dout),

             .align_done             (ca_if.align_done),
             .align_err              (ca_if.align_err),

             .tx_stb_pos_err         (ca_if.tx_stb_pos_err),
             .tx_stb_pos_coding_err  (ca_if.tx_stb_pos_coding_err),
             .rx_stb_pos_err         (ca_if.rx_stb_pos_err),
             .rx_stb_pos_coding_err  (ca_if.rx_stb_pos_coding_err),

             .fifo_full_val          (ca_if.fifo_full_val),
             .fifo_pfull_val         (ca_if.fifo_pfull_val),
             .fifo_empty_val         (ca_if.fifo_empty_val),
             .fifo_pempty_val        (ca_if.fifo_pempty_val),

             .fifo_full              (ca_if.fifo_full),
             .fifo_pfull             (ca_if.fifo_pfull),
             .fifo_empty             (ca_if.fifo_empty),
             .fifo_pempty            (ca_if.fifo_pempty)
         );
endmodule
