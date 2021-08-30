////////////////////////////////////////////////////////////
// Proprietary Information of Eximius Design
//
//        (C) Copyright 2021 Eximius Design
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
//Functional Descript:
//
// Lower Level Block used to extract fields for one Channel.
//
////////////////////////////////////////////////////////////


module ll_rx_concat_onechan
  #(parameter CH_WIDTH=80,
    parameter DATA_WIDTH=79,
    parameter PERSISTENT_STROBE=1,
    parameter PERSISTENT_MARKER=1,
    parameter STROBE_GEN2_LOC=0,
    parameter MARKER_GEN2_LOC=0,
    parameter STROBE_GEN1_LOC=0,
    parameter MARKER_GEN1_LOC=0,
    parameter ENABLE_STROBE=0,
    parameter ENABLE_MARKER=0,
    parameter DBI_PRESENT=1,
    parameter REG_PHY=0 )
  (
    input  logic                                clk_rd         ,

    output logic  [DATA_WIDTH-1:0]              rx_data_input  ,
    input logic [CH_WIDTH-1:0]                  phy_i_rx       ,

    // Control signals
    output  logic                               rx_stb_userbit ,
    output  logic                               rx_mrk_userbit ,

    input  logic                                m_gen2_mode     // Needed when switching from Gen2 to Gen1 W DBI enabled.
);

// This parameter adjusts the strobe bit to accound for a marker bit removal.
// e.g. if MARKER_LOC=0 and STROBE_LOC=1, then once ll_rx_mux_imrk is done, the receive vector will be shifted by 1, so strobe is now at local 0.
parameter STROBE_GEN2_ADJ= (STROBE_GEN2_LOC > MARKER_GEN2_LOC) ? 1 : 0;
parameter STROBE_GEN1_ADJ= (STROBE_GEN1_LOC > MARKER_GEN1_LOC) ? 1 : 0;

logic [CH_WIDTH-1:0] post_stb         ;
logic [CH_WIDTH-1:0] post_mrk         ;
logic [319:0]        data_in_max_wid  ;
logic [319:0]        pre_dbi_max_wid  ;
logic [319:0]        post_dbi_max_wid ;
logic [CH_WIDTH-1:0] post_dbi         ;
logic [CH_WIDTH-1:0] pre_logic_reg    ;
logic [CH_WIDTH-1:0] phy_logic_nxt    ;

always @(posedge clk_rd)
  pre_logic_reg <= phy_i_rx;

assign phy_logic_nxt = (REG_PHY == 1'b1) ? pre_logic_reg : phy_i_rx;

  ll_rx_mux #(.PERSISTENT(PERSISTENT_MARKER), .CH_WIDTH(CH_WIDTH), .ENABLE(ENABLE_MARKER), .GEN2_LOC(MARKER_GEN2_LOC), .GEN1_LOC(MARKER_GEN1_LOC))  ll_rx_mux_imrk (
    .data_in                    (phy_logic_nxt  ),
    .data_out                   (post_mrk       ),
    .rx_userbit                 (rx_mrk_userbit ),
    .m_gen2_mode                (m_gen2_mode    ));

  ll_rx_mux #(.PERSISTENT(PERSISTENT_STROBE), .CH_WIDTH(CH_WIDTH), .ENABLE(ENABLE_STROBE), .GEN2_LOC(STROBE_GEN2_LOC - STROBE_GEN2_ADJ), .GEN1_LOC(STROBE_GEN1_LOC - STROBE_GEN1_ADJ))  ll_rx_mux_istb (
    .data_in                    (post_mrk       ),
    .data_out                   (post_stb       ),
    .rx_userbit                 (rx_stb_userbit ),
    .m_gen2_mode                (m_gen2_mode    ));


// This effectively adds zeros to top if needed.
assign data_in_max_wid = post_stb  | '0;

// Remove DBI
assign pre_dbi_max_wid[  0+:19] = data_in_max_wid[  0+:19];
assign pre_dbi_max_wid[ 19+:19] = data_in_max_wid[ 20+:19];
assign pre_dbi_max_wid[ 38+:19] = data_in_max_wid[ 40+:19];
assign pre_dbi_max_wid[ 57+:19] = data_in_max_wid[ 60+:19];
assign pre_dbi_max_wid[ 76+:19] = data_in_max_wid[ 80+:19];
assign pre_dbi_max_wid[ 95+:19] = data_in_max_wid[100+:19];
assign pre_dbi_max_wid[114+:19] = data_in_max_wid[120+:19];
assign pre_dbi_max_wid[133+:19] = data_in_max_wid[140+:19];
assign pre_dbi_max_wid[152+:19] = data_in_max_wid[160+:19];
assign pre_dbi_max_wid[171+:19] = data_in_max_wid[180+:19];
assign pre_dbi_max_wid[190+:19] = data_in_max_wid[200+:19];
assign pre_dbi_max_wid[209+:19] = data_in_max_wid[220+:19];
assign pre_dbi_max_wid[228+:19] = data_in_max_wid[240+:19];
assign pre_dbi_max_wid[247+:19] = data_in_max_wid[260+:19];
assign pre_dbi_max_wid[266+:19] = data_in_max_wid[280+:19];
assign pre_dbi_max_wid[285+:19] = data_in_max_wid[300+:19];
assign pre_dbi_max_wid[304+:16] = 0;

assign post_dbi_max_wid = ((m_gen2_mode == 0) || (DBI_PRESENT == 0)) ? data_in_max_wid : pre_dbi_max_wid ;
assign post_dbi         = post_dbi_max_wid [CH_WIDTH-1:0];

assign rx_data_input = post_dbi [DATA_WIDTH-1:0] ;


endmodule
