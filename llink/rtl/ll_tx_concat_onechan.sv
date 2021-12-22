////////////////////////////////////////////////////////////
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
//Functional Descript:
//
// Lower Level Block used to generate fields for one Channel.
//
////////////////////////////////////////////////////////////

module ll_tx_concat_onechan
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
    input logic                                 clk_wr         ,

    input logic  [DATA_WIDTH-1:0]               tx_data_input  ,
    output logic [CH_WIDTH-1:0]                 phy_i_tx       ,

    // Control signals
    input  logic                                tx_stb_userbit ,
    input  logic                                tx_mrk_userbit ,

    input  logic                                m_gen2_mode    ,
    input  logic                                tx_online
);

// This parameter adjusts the strobe bit to accound for a marker bit removal.
// e.g. if MARKER_LOC=0 and STROBE_LOC=1, then once ll_rx_mux_imrk is done, the receive vector will be shifted by 1, so strobe is now at local 0.
parameter STROBE_GEN2_ADJ= (STROBE_GEN2_LOC > MARKER_GEN2_LOC) ? 1 : 0;
parameter STROBE_GEN1_ADJ= (STROBE_GEN1_LOC > MARKER_GEN1_LOC) ? 1 : 0;

logic [319:0]        pre_dbi_max_wid  ;
logic [319:0]        mid_dbi_max_wid  ;
logic [319:0]        post_dbi_max_wid ;
logic [CH_WIDTH-1:0] post_dbi         ;
logic [CH_WIDTH-1:0] post_stb         ;
logic [CH_WIDTH-1:0] post_mrk         ;
logic [CH_WIDTH-1:0] pre_txphy_reg    ;
logic [CH_WIDTH-1:0] phy_i_tx_nxt     ;

assign pre_dbi_max_wid = tx_data_input | '0;

assign mid_dbi_max_wid[  0+:19] = pre_dbi_max_wid[  0+:19];
assign mid_dbi_max_wid[ 20+:19] = pre_dbi_max_wid[ 19+:19];
assign mid_dbi_max_wid[ 40+:19] = pre_dbi_max_wid[ 38+:19];
assign mid_dbi_max_wid[ 60+:19] = pre_dbi_max_wid[ 57+:19];
assign mid_dbi_max_wid[ 80+:19] = pre_dbi_max_wid[ 76+:19];
assign mid_dbi_max_wid[100+:19] = pre_dbi_max_wid[ 95+:19];
assign mid_dbi_max_wid[120+:19] = pre_dbi_max_wid[114+:19];
assign mid_dbi_max_wid[140+:19] = pre_dbi_max_wid[133+:19];
assign mid_dbi_max_wid[160+:19] = pre_dbi_max_wid[152+:19];
assign mid_dbi_max_wid[180+:19] = pre_dbi_max_wid[171+:19];
assign mid_dbi_max_wid[200+:19] = pre_dbi_max_wid[190+:19];
assign mid_dbi_max_wid[220+:19] = pre_dbi_max_wid[209+:19];
assign mid_dbi_max_wid[240+:19] = pre_dbi_max_wid[228+:19];
assign mid_dbi_max_wid[260+:19] = pre_dbi_max_wid[247+:19];
assign mid_dbi_max_wid[280+:19] = pre_dbi_max_wid[266+:19];
assign mid_dbi_max_wid[300+:19] = pre_dbi_max_wid[285+:19];

assign mid_dbi_max_wid[ 20-1] = 1'b0;
assign mid_dbi_max_wid[ 40-1] = 1'b0;
assign mid_dbi_max_wid[ 60-1] = 1'b0;
assign mid_dbi_max_wid[ 80-1] = 1'b0;
assign mid_dbi_max_wid[100-1] = 1'b0;
assign mid_dbi_max_wid[120-1] = 1'b0;
assign mid_dbi_max_wid[140-1] = 1'b0;
assign mid_dbi_max_wid[160-1] = 1'b0;
assign mid_dbi_max_wid[180-1] = 1'b0;
assign mid_dbi_max_wid[200-1] = 1'b0;
assign mid_dbi_max_wid[220-1] = 1'b0;
assign mid_dbi_max_wid[240-1] = 1'b0;
assign mid_dbi_max_wid[260-1] = 1'b0;
assign mid_dbi_max_wid[280-1] = 1'b0;
assign mid_dbi_max_wid[300-1] = 1'b0;
assign mid_dbi_max_wid[320-1] = 1'b0;

assign post_dbi_max_wid = ((m_gen2_mode == 0) || (DBI_PRESENT == 0)) ? pre_dbi_max_wid : mid_dbi_max_wid ;

assign post_dbi = post_dbi_max_wid [CH_WIDTH-1:0] ;

  ll_tx_mux #(.PERSISTENT(PERSISTENT_STROBE), .CH_WIDTH(CH_WIDTH), .ENABLE(ENABLE_STROBE), .GEN2_LOC(STROBE_GEN2_LOC - STROBE_GEN2_ADJ), .GEN1_LOC(STROBE_GEN1_LOC - STROBE_GEN1_ADJ)) ll_tx_mux_istb (
    .data_in                    (post_dbi       ),
    .data_out                   (post_stb       ),
    .tx_userbit                 (tx_stb_userbit ),
    .m_gen2_mode                (m_gen2_mode    ),
    .online                     (tx_online      ));

  ll_tx_mux #(.PERSISTENT(PERSISTENT_MARKER), .CH_WIDTH(CH_WIDTH), .ENABLE(ENABLE_MARKER), .GEN2_LOC(MARKER_GEN2_LOC), .GEN1_LOC(MARKER_GEN1_LOC)) ll_tx_mux_imrk (
    .data_in                    (post_stb       ),
    .data_out                   (post_mrk       ),
    .tx_userbit                 (tx_mrk_userbit ),
    .m_gen2_mode                (m_gen2_mode    ),
    .online                     (tx_online      ));


assign phy_i_tx_nxt = post_mrk [CH_WIDTH-1:0] ;


always @(posedge clk_wr)
  pre_txphy_reg <= phy_i_tx_nxt;

assign phy_i_tx = (REG_PHY == 1'b1) ? pre_txphy_reg : phy_i_tx_nxt;

endmodule
