////////////////////////////////////////////////////////////
//
//        (C) Copyright 2021 Eximius Design
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
////////////////////////////////////////////////////////////

module axi_st_d256_gen1_gen2_slave_concat  (

// Data from Logic Links
  output logic [ 288:   0]   rx_st_data          ,
  output logic               rx_st_push_ovrd     ,
  output logic               rx_st_pushbit       ,
  input  logic               tx_st_credit        ,

// PHY Interconnect
  output logic [ 159:   0]   tx_phy0             ,
  input  logic [ 159:   0]   rx_phy0             ,
  output logic [ 159:   0]   tx_phy1             ,
  input  logic [ 159:   0]   rx_phy1             ,

  input  logic               clk_wr              ,
  input  logic               clk_rd              ,
  input  logic               rst_wr_n            ,
  input  logic               rst_rd_n            ,

  input  logic               m_gen2_mode         ,
  input  logic               tx_online           ,

  input  logic               tx_stb_userbit      ,
  input  logic [   1:   0]   tx_mrk_userbit      

);

// No TX Packetization, so tie off packetization signals

// No RX Packetization, so tie off packetization signals
  assign rx_st_push_ovrd                    = 1'b0                               ;

//////////////////////////////////////////////////////////////////
// TX Section

//   TX_CH_WIDTH           = 160; // Gen2 running at Half Rate
//   TX_DATA_WIDTH         = 149; // Usable Data per Channel
//   TX_PERSISTENT_STROBE  = 1'b1;
//   TX_PERSISTENT_MARKER  = 1'b1;
//   TX_STROBE_GEN2_LOC    = 'd76;
//   TX_MARKER_GEN2_LOC    = 'd4;
//   TX_STROBE_GEN1_LOC    = 'd35;
//   TX_MARKER_GEN1_LOC    = 'd39;
//   TX_ENABLE_STROBE      = 1'b1;
//   TX_ENABLE_MARKER      = 1'b1;
//   TX_DBI_PRESENT        = 1'b1;
//   TX_REG_PHY            = 1'b0;

  localparam TX_REG_PHY    = 1'b0;  // If set, this enables boundary FF for timing reasons

  logic [ 159:   0]                              tx_phy_preflop_0              ;
  logic [ 159:   0]                              tx_phy_preflop_1              ;
  logic [ 159:   0]                              tx_phy_flop_0_reg             ;
  logic [ 159:   0]                              tx_phy_flop_1_reg             ;

  always_ff @(posedge clk_wr or negedge rst_wr_n)
  if (~rst_wr_n)
  begin
    tx_phy_flop_0_reg                       <= 160'b0                                  ;
    tx_phy_flop_1_reg                       <= 160'b0                                  ;
  end
  else
  begin
    tx_phy_flop_0_reg                       <= tx_phy_preflop_0                        ;
    tx_phy_flop_1_reg                       <= tx_phy_preflop_1                        ;
  end

  assign tx_phy0                            = TX_REG_PHY ? tx_phy_flop_0_reg : tx_phy_preflop_0               ;
  assign tx_phy1                            = TX_REG_PHY ? tx_phy_flop_1_reg : tx_phy_preflop_1               ;


  assign tx_phy_preflop_0 [   0] = m_gen2_mode ? tx_st_credit              : tx_st_credit              ;  // Gen2 ? tx_st_credit         : tx_st_credit        
  assign tx_phy_preflop_0 [   1] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [   2] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [   3] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [   4] = m_gen2_mode ? tx_mrk_userbit[0]         : 1'b0                      ;  // Gen2 ? MARKER               : SPARE               
  assign tx_phy_preflop_0 [   5] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [   6] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [   7] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [   8] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [   9] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  10] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  11] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  12] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  13] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  14] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  15] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  16] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  17] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  18] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  19] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  20] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  21] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  22] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  23] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  24] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  25] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  26] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  27] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  28] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  29] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  30] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  31] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  32] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  33] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  34] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  35] = m_gen2_mode ? 1'b0                      : tx_stb_userbit            ;  // Gen2 ? SPARE                : STROBE              
  assign tx_phy_preflop_0 [  36] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  37] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_0 [  38] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : SPARE               
  assign tx_phy_preflop_0 [  39] = m_gen2_mode ? 1'b0                      : tx_mrk_userbit[0]         ;  // Gen2 ? DBI                  : MARKER              
  assign tx_phy_preflop_0 [  40] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  41] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  42] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  43] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  44] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  45] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  46] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  47] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  48] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  49] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  50] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  51] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  52] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  53] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  54] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  55] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  56] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  57] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  58] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  59] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  60] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  61] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  62] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  63] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  64] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  65] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  66] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  67] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  68] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  69] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  70] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  71] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  72] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  73] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  74] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  75] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  76] = m_gen2_mode ? tx_stb_userbit            : 1'b0                      ;  // Gen2 ? STROBE               : UNUSED              
  assign tx_phy_preflop_0 [  77] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  78] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_0 [  79] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_0 [  80] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  81] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  82] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  83] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  84] = m_gen2_mode ? tx_mrk_userbit[1]         : 1'b0                      ;  // Gen2 ? MARKER               : UNUSED              
  assign tx_phy_preflop_0 [  85] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  86] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  87] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  88] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  89] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  90] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  91] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  92] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  93] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  94] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  95] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  96] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  97] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  98] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [  99] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 100] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 101] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 102] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 103] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 104] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 105] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 106] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 107] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 108] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 109] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 110] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 111] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 112] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 113] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 114] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 115] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 116] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 117] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 118] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_0 [ 119] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_0 [ 120] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 121] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 122] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 123] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 124] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 125] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 126] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 127] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 128] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 129] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 130] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 131] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 132] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 133] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 134] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 135] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 136] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 137] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 138] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 139] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 140] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 141] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 142] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 143] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 144] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 145] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 146] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 147] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 148] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 149] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 150] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 151] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 152] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 153] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 154] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 155] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 156] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 157] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_0 [ 158] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_0 [ 159] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_1 [   0] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [   1] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [   2] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [   3] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [   4] = m_gen2_mode ? tx_mrk_userbit[0]         : 1'b0                      ;  // Gen2 ? MARKER               : SPARE               
  assign tx_phy_preflop_1 [   5] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [   6] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [   7] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [   8] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [   9] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  10] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  11] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  12] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  13] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  14] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  15] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  16] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  17] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  18] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  19] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  20] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  21] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  22] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  23] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  24] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  25] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  26] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  27] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  28] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  29] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  30] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  31] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  32] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  33] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  34] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  35] = m_gen2_mode ? 1'b0                      : tx_stb_userbit            ;  // Gen2 ? SPARE                : STROBE              
  assign tx_phy_preflop_1 [  36] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  37] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : SPARE               
  assign tx_phy_preflop_1 [  38] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : SPARE               
  assign tx_phy_preflop_1 [  39] = m_gen2_mode ? 1'b0                      : tx_mrk_userbit[0]         ;  // Gen2 ? DBI                  : MARKER              
  assign tx_phy_preflop_1 [  40] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  41] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  42] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  43] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  44] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  45] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  46] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  47] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  48] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  49] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  50] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  51] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  52] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  53] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  54] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  55] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  56] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  57] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  58] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  59] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  60] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  61] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  62] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  63] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  64] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  65] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  66] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  67] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  68] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  69] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  70] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  71] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  72] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  73] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  74] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  75] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  76] = m_gen2_mode ? tx_stb_userbit            : 1'b0                      ;  // Gen2 ? STROBE               : UNUSED              
  assign tx_phy_preflop_1 [  77] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  78] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_1 [  79] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_1 [  80] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  81] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  82] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  83] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  84] = m_gen2_mode ? tx_mrk_userbit[1]         : 1'b0                      ;  // Gen2 ? MARKER               : UNUSED              
  assign tx_phy_preflop_1 [  85] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  86] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  87] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  88] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  89] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  90] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  91] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  92] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  93] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  94] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  95] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  96] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  97] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  98] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [  99] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 100] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 101] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 102] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 103] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 104] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 105] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 106] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 107] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 108] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 109] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 110] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 111] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 112] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 113] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 114] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 115] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 116] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 117] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 118] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_1 [ 119] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_1 [ 120] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 121] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 122] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 123] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 124] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 125] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 126] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 127] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 128] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 129] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 130] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 131] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 132] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 133] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 134] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 135] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 136] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 137] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 138] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 139] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 140] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 141] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 142] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 143] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 144] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 145] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 146] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 147] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 148] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 149] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 150] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 151] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 152] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 153] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 154] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 155] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 156] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 157] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 158] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_1 [ 159] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
// TX Section
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// RX Section

//   RX_CH_WIDTH           = 160; // Gen2 running at Half Rate
//   RX_DATA_WIDTH         = 149; // Usable Data per Channel
//   RX_PERSISTENT_STROBE  = 1'b1;
//   RX_PERSISTENT_MARKER  = 1'b1;
//   RX_STROBE_GEN2_LOC    = 'd76;
//   RX_MARKER_GEN2_LOC    = 'd4;
//   RX_STROBE_GEN1_LOC    = 'd35;
//   RX_MARKER_GEN1_LOC    = 'd39;
//   RX_ENABLE_STROBE      = 1'b1;
//   RX_ENABLE_MARKER      = 1'b1;
//   RX_DBI_PRESENT        = 1'b1;
//   RX_REG_PHY            = 1'b0;

  localparam RX_REG_PHY    = 1'b0;  // If set, this enables boundary FF for timing reasons

  logic [ 159:   0]                              rx_phy_postflop_0             ;
  logic [ 159:   0]                              rx_phy_postflop_1             ;
  logic [ 159:   0]                              rx_phy_flop_0_reg             ;
  logic [ 159:   0]                              rx_phy_flop_1_reg             ;

  always_ff @(posedge clk_rd or negedge rst_rd_n)
  if (~rst_rd_n)
  begin
    rx_phy_flop_0_reg                       <= 160'b0                                  ;
    rx_phy_flop_1_reg                       <= 160'b0                                  ;
  end
  else
  begin
    rx_phy_flop_0_reg                       <= rx_phy0                                 ;
    rx_phy_flop_1_reg                       <= rx_phy1                                 ;
  end


  assign rx_phy_postflop_0                  = RX_REG_PHY ? rx_phy_flop_0_reg : rx_phy0               ;
  assign rx_phy_postflop_1                  = RX_REG_PHY ? rx_phy_flop_1_reg : rx_phy1               ;

  assign rx_st_pushbit             = m_gen2_mode ? rx_phy_postflop_0 [   0] : rx_phy_postflop_0 [   0] ;  // Gen2 ? tx_st_pushbit        : tx_st_pushbit       
  assign rx_st_data          [   0] = m_gen2_mode ? rx_phy_postflop_0 [   1] : rx_phy_postflop_0 [   1] ;  // Gen2 ? user_tkeep[0]        : user_tkeep[0]       
  assign rx_st_data          [   1] = m_gen2_mode ? rx_phy_postflop_0 [   2] : rx_phy_postflop_0 [   2] ;  // Gen2 ? user_tkeep[1]        : user_tkeep[1]       
  assign rx_st_data          [   2] = m_gen2_mode ? rx_phy_postflop_0 [   3] : rx_phy_postflop_0 [   3] ;  // Gen2 ? user_tkeep[2]        : user_tkeep[2]       
//       nc                        =               rx_phy_postflop_0 [   4]                           ;  // Gen2 ? MARKER               : GEN2ONLY            
  assign rx_st_data          [   3] = m_gen2_mode ? rx_phy_postflop_0 [   5] : rx_phy_postflop_0 [   4] ;  // Gen2 ? user_tkeep[3]        : user_tkeep[3]       
  assign rx_st_data          [   4] = m_gen2_mode ? rx_phy_postflop_0 [   6] : rx_phy_postflop_0 [   5] ;  // Gen2 ? user_tkeep[4]        : user_tkeep[4]       
  assign rx_st_data          [   5] = m_gen2_mode ? rx_phy_postflop_0 [   7] : rx_phy_postflop_0 [   6] ;  // Gen2 ? user_tkeep[5]        : user_tkeep[5]       
  assign rx_st_data          [   6] = m_gen2_mode ? rx_phy_postflop_0 [   8] : rx_phy_postflop_0 [   7] ;  // Gen2 ? user_tkeep[6]        : user_tkeep[6]       
  assign rx_st_data          [   7] = m_gen2_mode ? rx_phy_postflop_0 [   9] : rx_phy_postflop_0 [   8] ;  // Gen2 ? user_tkeep[7]        : user_tkeep[7]       
  assign rx_st_data          [   8] =               rx_phy_postflop_0 [  10]                           ;  // Gen2 ? user_tkeep[8]        : GEN2ONLY            
  assign rx_st_data          [   9] =               rx_phy_postflop_0 [  11]                           ;  // Gen2 ? user_tkeep[9]        : GEN2ONLY            
  assign rx_st_data          [  10] =               rx_phy_postflop_0 [  12]                           ;  // Gen2 ? user_tkeep[10]       : GEN2ONLY            
  assign rx_st_data          [  11] =               rx_phy_postflop_0 [  13]                           ;  // Gen2 ? user_tkeep[11]       : GEN2ONLY            
  assign rx_st_data          [  12] =               rx_phy_postflop_0 [  14]                           ;  // Gen2 ? user_tkeep[12]       : GEN2ONLY            
  assign rx_st_data          [  13] =               rx_phy_postflop_0 [  15]                           ;  // Gen2 ? user_tkeep[13]       : GEN2ONLY            
  assign rx_st_data          [  14] =               rx_phy_postflop_0 [  16]                           ;  // Gen2 ? user_tkeep[14]       : GEN2ONLY            
  assign rx_st_data          [  15] =               rx_phy_postflop_0 [  17]                           ;  // Gen2 ? user_tkeep[15]       : GEN2ONLY            
  assign rx_st_data          [  16] =               rx_phy_postflop_0 [  18]                           ;  // Gen2 ? user_tkeep[16]       : GEN2ONLY            
  assign rx_st_data          [  17] =               rx_phy_postflop_0 [  19]                           ;  // Gen2 ? user_tkeep[17]       : GEN2ONLY            
  assign rx_st_data          [  18] =               rx_phy_postflop_0 [  20]                           ;  // Gen2 ? user_tkeep[18]       : GEN2ONLY            
  assign rx_st_data          [  19] =               rx_phy_postflop_0 [  21]                           ;  // Gen2 ? user_tkeep[19]       : GEN2ONLY            
  assign rx_st_data          [  20] =               rx_phy_postflop_0 [  22]                           ;  // Gen2 ? user_tkeep[20]       : GEN2ONLY            
  assign rx_st_data          [  21] =               rx_phy_postflop_0 [  23]                           ;  // Gen2 ? user_tkeep[21]       : GEN2ONLY            
  assign rx_st_data          [  22] =               rx_phy_postflop_0 [  24]                           ;  // Gen2 ? user_tkeep[22]       : GEN2ONLY            
  assign rx_st_data          [  23] =               rx_phy_postflop_0 [  25]                           ;  // Gen2 ? user_tkeep[23]       : GEN2ONLY            
  assign rx_st_data          [  24] =               rx_phy_postflop_0 [  26]                           ;  // Gen2 ? user_tkeep[24]       : GEN2ONLY            
  assign rx_st_data          [  25] =               rx_phy_postflop_0 [  27]                           ;  // Gen2 ? user_tkeep[25]       : GEN2ONLY            
  assign rx_st_data          [  26] =               rx_phy_postflop_0 [  28]                           ;  // Gen2 ? user_tkeep[26]       : GEN2ONLY            
  assign rx_st_data          [  27] =               rx_phy_postflop_0 [  29]                           ;  // Gen2 ? user_tkeep[27]       : GEN2ONLY            
  assign rx_st_data          [  28] =               rx_phy_postflop_0 [  30]                           ;  // Gen2 ? user_tkeep[28]       : GEN2ONLY            
  assign rx_st_data          [  29] =               rx_phy_postflop_0 [  31]                           ;  // Gen2 ? user_tkeep[29]       : GEN2ONLY            
  assign rx_st_data          [  30] =               rx_phy_postflop_0 [  32]                           ;  // Gen2 ? user_tkeep[30]       : GEN2ONLY            
  assign rx_st_data          [  31] =               rx_phy_postflop_0 [  33]                           ;  // Gen2 ? user_tkeep[31]       : GEN2ONLY            
  assign rx_st_data          [  32] = m_gen2_mode ? rx_phy_postflop_0 [  34] : rx_phy_postflop_0 [   9] ;  // Gen2 ? user_tdata[0]        : user_tdata[0]       
  assign rx_st_data          [  33] = m_gen2_mode ? rx_phy_postflop_0 [  35] : rx_phy_postflop_0 [  10] ;  // Gen2 ? user_tdata[1]        : user_tdata[1]       
  assign rx_st_data          [  34] = m_gen2_mode ? rx_phy_postflop_0 [  36] : rx_phy_postflop_0 [  11] ;  // Gen2 ? user_tdata[2]        : user_tdata[2]       
  assign rx_st_data          [  35] = m_gen2_mode ? rx_phy_postflop_0 [  37] : rx_phy_postflop_0 [  12] ;  // Gen2 ? user_tdata[3]        : user_tdata[3]       
//       nc                        =               rx_phy_postflop_0 [  38]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  39]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
  assign rx_st_data          [  36] = m_gen2_mode ? rx_phy_postflop_0 [  40] : rx_phy_postflop_0 [  13] ;  // Gen2 ? user_tdata[4]        : user_tdata[4]       
  assign rx_st_data          [  37] = m_gen2_mode ? rx_phy_postflop_0 [  41] : rx_phy_postflop_0 [  14] ;  // Gen2 ? user_tdata[5]        : user_tdata[5]       
  assign rx_st_data          [  38] = m_gen2_mode ? rx_phy_postflop_0 [  42] : rx_phy_postflop_0 [  15] ;  // Gen2 ? user_tdata[6]        : user_tdata[6]       
  assign rx_st_data          [  39] = m_gen2_mode ? rx_phy_postflop_0 [  43] : rx_phy_postflop_0 [  16] ;  // Gen2 ? user_tdata[7]        : user_tdata[7]       
  assign rx_st_data          [  40] = m_gen2_mode ? rx_phy_postflop_0 [  44] : rx_phy_postflop_0 [  17] ;  // Gen2 ? user_tdata[8]        : user_tdata[8]       
  assign rx_st_data          [  41] = m_gen2_mode ? rx_phy_postflop_0 [  45] : rx_phy_postflop_0 [  18] ;  // Gen2 ? user_tdata[9]        : user_tdata[9]       
  assign rx_st_data          [  42] = m_gen2_mode ? rx_phy_postflop_0 [  46] : rx_phy_postflop_0 [  19] ;  // Gen2 ? user_tdata[10]       : user_tdata[10]      
  assign rx_st_data          [  43] = m_gen2_mode ? rx_phy_postflop_0 [  47] : rx_phy_postflop_0 [  20] ;  // Gen2 ? user_tdata[11]       : user_tdata[11]      
  assign rx_st_data          [  44] = m_gen2_mode ? rx_phy_postflop_0 [  48] : rx_phy_postflop_0 [  21] ;  // Gen2 ? user_tdata[12]       : user_tdata[12]      
  assign rx_st_data          [  45] = m_gen2_mode ? rx_phy_postflop_0 [  49] : rx_phy_postflop_0 [  22] ;  // Gen2 ? user_tdata[13]       : user_tdata[13]      
  assign rx_st_data          [  46] = m_gen2_mode ? rx_phy_postflop_0 [  50] : rx_phy_postflop_0 [  23] ;  // Gen2 ? user_tdata[14]       : user_tdata[14]      
  assign rx_st_data          [  47] = m_gen2_mode ? rx_phy_postflop_0 [  51] : rx_phy_postflop_0 [  24] ;  // Gen2 ? user_tdata[15]       : user_tdata[15]      
  assign rx_st_data          [  48] = m_gen2_mode ? rx_phy_postflop_0 [  52] : rx_phy_postflop_0 [  25] ;  // Gen2 ? user_tdata[16]       : user_tdata[16]      
  assign rx_st_data          [  49] = m_gen2_mode ? rx_phy_postflop_0 [  53] : rx_phy_postflop_0 [  26] ;  // Gen2 ? user_tdata[17]       : user_tdata[17]      
  assign rx_st_data          [  50] = m_gen2_mode ? rx_phy_postflop_0 [  54] : rx_phy_postflop_0 [  27] ;  // Gen2 ? user_tdata[18]       : user_tdata[18]      
  assign rx_st_data          [  51] = m_gen2_mode ? rx_phy_postflop_0 [  55] : rx_phy_postflop_0 [  28] ;  // Gen2 ? user_tdata[19]       : user_tdata[19]      
  assign rx_st_data          [  52] = m_gen2_mode ? rx_phy_postflop_0 [  56] : rx_phy_postflop_0 [  29] ;  // Gen2 ? user_tdata[20]       : user_tdata[20]      
  assign rx_st_data          [  53] = m_gen2_mode ? rx_phy_postflop_0 [  57] : rx_phy_postflop_0 [  30] ;  // Gen2 ? user_tdata[21]       : user_tdata[21]      
  assign rx_st_data          [  54] = m_gen2_mode ? rx_phy_postflop_0 [  58] : rx_phy_postflop_0 [  31] ;  // Gen2 ? user_tdata[22]       : user_tdata[22]      
  assign rx_st_data          [  55] = m_gen2_mode ? rx_phy_postflop_0 [  59] : rx_phy_postflop_0 [  32] ;  // Gen2 ? user_tdata[23]       : user_tdata[23]      
  assign rx_st_data          [  56] = m_gen2_mode ? rx_phy_postflop_0 [  60] : rx_phy_postflop_0 [  33] ;  // Gen2 ? user_tdata[24]       : user_tdata[24]      
  assign rx_st_data          [  57] = m_gen2_mode ? rx_phy_postflop_0 [  61] : rx_phy_postflop_0 [  34] ;  // Gen2 ? user_tdata[25]       : user_tdata[25]      
  assign rx_st_data          [  58] = m_gen2_mode ? rx_phy_postflop_0 [  62] : rx_phy_postflop_0 [  36] ;  // Gen2 ? user_tdata[26]       : user_tdata[26]      
  assign rx_st_data          [  59] = m_gen2_mode ? rx_phy_postflop_0 [  63] : rx_phy_postflop_0 [  37] ;  // Gen2 ? user_tdata[27]       : user_tdata[27]      
  assign rx_st_data          [  60] = m_gen2_mode ? rx_phy_postflop_0 [  64] : rx_phy_postflop_0 [  38] ;  // Gen2 ? user_tdata[28]       : user_tdata[28]      
  assign rx_st_data          [  61] = m_gen2_mode ? rx_phy_postflop_0 [  65] : rx_phy_postflop_1 [   0] ;  // Gen2 ? user_tdata[29]       : user_tdata[29]      
  assign rx_st_data          [  62] = m_gen2_mode ? rx_phy_postflop_0 [  66] : rx_phy_postflop_1 [   1] ;  // Gen2 ? user_tdata[30]       : user_tdata[30]      
  assign rx_st_data          [  63] = m_gen2_mode ? rx_phy_postflop_0 [  67] : rx_phy_postflop_1 [   2] ;  // Gen2 ? user_tdata[31]       : user_tdata[31]      
  assign rx_st_data          [  64] = m_gen2_mode ? rx_phy_postflop_0 [  68] : rx_phy_postflop_1 [   3] ;  // Gen2 ? user_tdata[32]       : user_tdata[32]      
  assign rx_st_data          [  65] = m_gen2_mode ? rx_phy_postflop_0 [  69] : rx_phy_postflop_1 [   4] ;  // Gen2 ? user_tdata[33]       : user_tdata[33]      
  assign rx_st_data          [  66] = m_gen2_mode ? rx_phy_postflop_0 [  70] : rx_phy_postflop_1 [   5] ;  // Gen2 ? user_tdata[34]       : user_tdata[34]      
  assign rx_st_data          [  67] = m_gen2_mode ? rx_phy_postflop_0 [  71] : rx_phy_postflop_1 [   6] ;  // Gen2 ? user_tdata[35]       : user_tdata[35]      
  assign rx_st_data          [  68] = m_gen2_mode ? rx_phy_postflop_0 [  72] : rx_phy_postflop_1 [   7] ;  // Gen2 ? user_tdata[36]       : user_tdata[36]      
  assign rx_st_data          [  69] = m_gen2_mode ? rx_phy_postflop_0 [  73] : rx_phy_postflop_1 [   8] ;  // Gen2 ? user_tdata[37]       : user_tdata[37]      
  assign rx_st_data          [  70] = m_gen2_mode ? rx_phy_postflop_0 [  74] : rx_phy_postflop_1 [   9] ;  // Gen2 ? user_tdata[38]       : user_tdata[38]      
  assign rx_st_data          [  71] = m_gen2_mode ? rx_phy_postflop_0 [  75] : rx_phy_postflop_1 [  10] ;  // Gen2 ? user_tdata[39]       : user_tdata[39]      
//       nc                        =               rx_phy_postflop_0 [  76]                           ;  // Gen2 ? STROBE               : GEN2ONLY            
  assign rx_st_data          [  72] = m_gen2_mode ? rx_phy_postflop_0 [  77] : rx_phy_postflop_1 [  11] ;  // Gen2 ? user_tdata[40]       : user_tdata[40]      
//       nc                        =               rx_phy_postflop_0 [  78]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  79]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
  assign rx_st_data          [  73] = m_gen2_mode ? rx_phy_postflop_0 [  80] : rx_phy_postflop_1 [  12] ;  // Gen2 ? user_tdata[41]       : user_tdata[41]      
  assign rx_st_data          [  74] = m_gen2_mode ? rx_phy_postflop_0 [  81] : rx_phy_postflop_1 [  13] ;  // Gen2 ? user_tdata[42]       : user_tdata[42]      
  assign rx_st_data          [  75] = m_gen2_mode ? rx_phy_postflop_0 [  82] : rx_phy_postflop_1 [  14] ;  // Gen2 ? user_tdata[43]       : user_tdata[43]      
  assign rx_st_data          [  76] = m_gen2_mode ? rx_phy_postflop_0 [  83] : rx_phy_postflop_1 [  15] ;  // Gen2 ? user_tdata[44]       : user_tdata[44]      
//       nc                        =               rx_phy_postflop_0 [  84]                           ;  // Gen2 ? MARKER               : GEN2ONLY            
  assign rx_st_data          [  77] = m_gen2_mode ? rx_phy_postflop_0 [  85] : rx_phy_postflop_1 [  16] ;  // Gen2 ? user_tdata[45]       : user_tdata[45]      
  assign rx_st_data          [  78] = m_gen2_mode ? rx_phy_postflop_0 [  86] : rx_phy_postflop_1 [  17] ;  // Gen2 ? user_tdata[46]       : user_tdata[46]      
  assign rx_st_data          [  79] = m_gen2_mode ? rx_phy_postflop_0 [  87] : rx_phy_postflop_1 [  18] ;  // Gen2 ? user_tdata[47]       : user_tdata[47]      
  assign rx_st_data          [  80] = m_gen2_mode ? rx_phy_postflop_0 [  88] : rx_phy_postflop_1 [  19] ;  // Gen2 ? user_tdata[48]       : user_tdata[48]      
  assign rx_st_data          [  81] = m_gen2_mode ? rx_phy_postflop_0 [  89] : rx_phy_postflop_1 [  20] ;  // Gen2 ? user_tdata[49]       : user_tdata[49]      
  assign rx_st_data          [  82] = m_gen2_mode ? rx_phy_postflop_0 [  90] : rx_phy_postflop_1 [  21] ;  // Gen2 ? user_tdata[50]       : user_tdata[50]      
  assign rx_st_data          [  83] = m_gen2_mode ? rx_phy_postflop_0 [  91] : rx_phy_postflop_1 [  22] ;  // Gen2 ? user_tdata[51]       : user_tdata[51]      
  assign rx_st_data          [  84] = m_gen2_mode ? rx_phy_postflop_0 [  92] : rx_phy_postflop_1 [  23] ;  // Gen2 ? user_tdata[52]       : user_tdata[52]      
  assign rx_st_data          [  85] = m_gen2_mode ? rx_phy_postflop_0 [  93] : rx_phy_postflop_1 [  24] ;  // Gen2 ? user_tdata[53]       : user_tdata[53]      
  assign rx_st_data          [  86] = m_gen2_mode ? rx_phy_postflop_0 [  94] : rx_phy_postflop_1 [  25] ;  // Gen2 ? user_tdata[54]       : user_tdata[54]      
  assign rx_st_data          [  87] = m_gen2_mode ? rx_phy_postflop_0 [  95] : rx_phy_postflop_1 [  26] ;  // Gen2 ? user_tdata[55]       : user_tdata[55]      
  assign rx_st_data          [  88] = m_gen2_mode ? rx_phy_postflop_0 [  96] : rx_phy_postflop_1 [  27] ;  // Gen2 ? user_tdata[56]       : user_tdata[56]      
  assign rx_st_data          [  89] = m_gen2_mode ? rx_phy_postflop_0 [  97] : rx_phy_postflop_1 [  28] ;  // Gen2 ? user_tdata[57]       : user_tdata[57]      
  assign rx_st_data          [  90] = m_gen2_mode ? rx_phy_postflop_0 [  98] : rx_phy_postflop_1 [  29] ;  // Gen2 ? user_tdata[58]       : user_tdata[58]      
  assign rx_st_data          [  91] = m_gen2_mode ? rx_phy_postflop_0 [  99] : rx_phy_postflop_1 [  30] ;  // Gen2 ? user_tdata[59]       : user_tdata[59]      
  assign rx_st_data          [  92] = m_gen2_mode ? rx_phy_postflop_0 [ 100] : rx_phy_postflop_1 [  31] ;  // Gen2 ? user_tdata[60]       : user_tdata[60]      
  assign rx_st_data          [  93] = m_gen2_mode ? rx_phy_postflop_0 [ 101] : rx_phy_postflop_1 [  32] ;  // Gen2 ? user_tdata[61]       : user_tdata[61]      
  assign rx_st_data          [  94] = m_gen2_mode ? rx_phy_postflop_0 [ 102] : rx_phy_postflop_1 [  33] ;  // Gen2 ? user_tdata[62]       : user_tdata[62]      
  assign rx_st_data          [  95] = m_gen2_mode ? rx_phy_postflop_0 [ 103] : rx_phy_postflop_1 [  34] ;  // Gen2 ? user_tdata[63]       : user_tdata[63]      
  assign rx_st_data          [  96] =               rx_phy_postflop_0 [ 104]                           ;  // Gen2 ? user_tdata[64]       : GEN2ONLY            
  assign rx_st_data          [  97] =               rx_phy_postflop_0 [ 105]                           ;  // Gen2 ? user_tdata[65]       : GEN2ONLY            
  assign rx_st_data          [  98] =               rx_phy_postflop_0 [ 106]                           ;  // Gen2 ? user_tdata[66]       : GEN2ONLY            
  assign rx_st_data          [  99] =               rx_phy_postflop_0 [ 107]                           ;  // Gen2 ? user_tdata[67]       : GEN2ONLY            
  assign rx_st_data          [ 100] =               rx_phy_postflop_0 [ 108]                           ;  // Gen2 ? user_tdata[68]       : GEN2ONLY            
  assign rx_st_data          [ 101] =               rx_phy_postflop_0 [ 109]                           ;  // Gen2 ? user_tdata[69]       : GEN2ONLY            
  assign rx_st_data          [ 102] =               rx_phy_postflop_0 [ 110]                           ;  // Gen2 ? user_tdata[70]       : GEN2ONLY            
  assign rx_st_data          [ 103] =               rx_phy_postflop_0 [ 111]                           ;  // Gen2 ? user_tdata[71]       : GEN2ONLY            
  assign rx_st_data          [ 104] =               rx_phy_postflop_0 [ 112]                           ;  // Gen2 ? user_tdata[72]       : GEN2ONLY            
  assign rx_st_data          [ 105] =               rx_phy_postflop_0 [ 113]                           ;  // Gen2 ? user_tdata[73]       : GEN2ONLY            
  assign rx_st_data          [ 106] =               rx_phy_postflop_0 [ 114]                           ;  // Gen2 ? user_tdata[74]       : GEN2ONLY            
  assign rx_st_data          [ 107] =               rx_phy_postflop_0 [ 115]                           ;  // Gen2 ? user_tdata[75]       : GEN2ONLY            
  assign rx_st_data          [ 108] =               rx_phy_postflop_0 [ 116]                           ;  // Gen2 ? user_tdata[76]       : GEN2ONLY            
  assign rx_st_data          [ 109] =               rx_phy_postflop_0 [ 117]                           ;  // Gen2 ? user_tdata[77]       : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 118]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 119]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
  assign rx_st_data          [ 110] =               rx_phy_postflop_0 [ 120]                           ;  // Gen2 ? user_tdata[78]       : GEN2ONLY            
  assign rx_st_data          [ 111] =               rx_phy_postflop_0 [ 121]                           ;  // Gen2 ? user_tdata[79]       : GEN2ONLY            
  assign rx_st_data          [ 112] =               rx_phy_postflop_0 [ 122]                           ;  // Gen2 ? user_tdata[80]       : GEN2ONLY            
  assign rx_st_data          [ 113] =               rx_phy_postflop_0 [ 123]                           ;  // Gen2 ? user_tdata[81]       : GEN2ONLY            
  assign rx_st_data          [ 114] =               rx_phy_postflop_0 [ 124]                           ;  // Gen2 ? user_tdata[82]       : GEN2ONLY            
  assign rx_st_data          [ 115] =               rx_phy_postflop_0 [ 125]                           ;  // Gen2 ? user_tdata[83]       : GEN2ONLY            
  assign rx_st_data          [ 116] =               rx_phy_postflop_0 [ 126]                           ;  // Gen2 ? user_tdata[84]       : GEN2ONLY            
  assign rx_st_data          [ 117] =               rx_phy_postflop_0 [ 127]                           ;  // Gen2 ? user_tdata[85]       : GEN2ONLY            
  assign rx_st_data          [ 118] =               rx_phy_postflop_0 [ 128]                           ;  // Gen2 ? user_tdata[86]       : GEN2ONLY            
  assign rx_st_data          [ 119] =               rx_phy_postflop_0 [ 129]                           ;  // Gen2 ? user_tdata[87]       : GEN2ONLY            
  assign rx_st_data          [ 120] =               rx_phy_postflop_0 [ 130]                           ;  // Gen2 ? user_tdata[88]       : GEN2ONLY            
  assign rx_st_data          [ 121] =               rx_phy_postflop_0 [ 131]                           ;  // Gen2 ? user_tdata[89]       : GEN2ONLY            
  assign rx_st_data          [ 122] =               rx_phy_postflop_0 [ 132]                           ;  // Gen2 ? user_tdata[90]       : GEN2ONLY            
  assign rx_st_data          [ 123] =               rx_phy_postflop_0 [ 133]                           ;  // Gen2 ? user_tdata[91]       : GEN2ONLY            
  assign rx_st_data          [ 124] =               rx_phy_postflop_0 [ 134]                           ;  // Gen2 ? user_tdata[92]       : GEN2ONLY            
  assign rx_st_data          [ 125] =               rx_phy_postflop_0 [ 135]                           ;  // Gen2 ? user_tdata[93]       : GEN2ONLY            
  assign rx_st_data          [ 126] =               rx_phy_postflop_0 [ 136]                           ;  // Gen2 ? user_tdata[94]       : GEN2ONLY            
  assign rx_st_data          [ 127] =               rx_phy_postflop_0 [ 137]                           ;  // Gen2 ? user_tdata[95]       : GEN2ONLY            
  assign rx_st_data          [ 128] =               rx_phy_postflop_0 [ 138]                           ;  // Gen2 ? user_tdata[96]       : GEN2ONLY            
  assign rx_st_data          [ 129] =               rx_phy_postflop_0 [ 139]                           ;  // Gen2 ? user_tdata[97]       : GEN2ONLY            
  assign rx_st_data          [ 130] =               rx_phy_postflop_0 [ 140]                           ;  // Gen2 ? user_tdata[98]       : GEN2ONLY            
  assign rx_st_data          [ 131] =               rx_phy_postflop_0 [ 141]                           ;  // Gen2 ? user_tdata[99]       : GEN2ONLY            
  assign rx_st_data          [ 132] =               rx_phy_postflop_0 [ 142]                           ;  // Gen2 ? user_tdata[100]      : GEN2ONLY            
  assign rx_st_data          [ 133] =               rx_phy_postflop_0 [ 143]                           ;  // Gen2 ? user_tdata[101]      : GEN2ONLY            
  assign rx_st_data          [ 134] =               rx_phy_postflop_0 [ 144]                           ;  // Gen2 ? user_tdata[102]      : GEN2ONLY            
  assign rx_st_data          [ 135] =               rx_phy_postflop_0 [ 145]                           ;  // Gen2 ? user_tdata[103]      : GEN2ONLY            
  assign rx_st_data          [ 136] =               rx_phy_postflop_0 [ 146]                           ;  // Gen2 ? user_tdata[104]      : GEN2ONLY            
  assign rx_st_data          [ 137] =               rx_phy_postflop_0 [ 147]                           ;  // Gen2 ? user_tdata[105]      : GEN2ONLY            
  assign rx_st_data          [ 138] =               rx_phy_postflop_0 [ 148]                           ;  // Gen2 ? user_tdata[106]      : GEN2ONLY            
  assign rx_st_data          [ 139] =               rx_phy_postflop_0 [ 149]                           ;  // Gen2 ? user_tdata[107]      : GEN2ONLY            
  assign rx_st_data          [ 140] =               rx_phy_postflop_0 [ 150]                           ;  // Gen2 ? user_tdata[108]      : GEN2ONLY            
  assign rx_st_data          [ 141] =               rx_phy_postflop_0 [ 151]                           ;  // Gen2 ? user_tdata[109]      : GEN2ONLY            
  assign rx_st_data          [ 142] =               rx_phy_postflop_0 [ 152]                           ;  // Gen2 ? user_tdata[110]      : GEN2ONLY            
  assign rx_st_data          [ 143] =               rx_phy_postflop_0 [ 153]                           ;  // Gen2 ? user_tdata[111]      : GEN2ONLY            
  assign rx_st_data          [ 144] =               rx_phy_postflop_0 [ 154]                           ;  // Gen2 ? user_tdata[112]      : GEN2ONLY            
  assign rx_st_data          [ 145] =               rx_phy_postflop_0 [ 155]                           ;  // Gen2 ? user_tdata[113]      : GEN2ONLY            
  assign rx_st_data          [ 146] =               rx_phy_postflop_0 [ 156]                           ;  // Gen2 ? user_tdata[114]      : GEN2ONLY            
  assign rx_st_data          [ 147] =               rx_phy_postflop_0 [ 157]                           ;  // Gen2 ? user_tdata[115]      : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 158]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 159]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
  assign rx_st_data          [ 148] =               rx_phy_postflop_1 [   0]                           ;  // Gen2 ? user_tdata[116]      : GEN2ONLY            
  assign rx_st_data          [ 149] =               rx_phy_postflop_1 [   1]                           ;  // Gen2 ? user_tdata[117]      : GEN2ONLY            
  assign rx_st_data          [ 150] =               rx_phy_postflop_1 [   2]                           ;  // Gen2 ? user_tdata[118]      : GEN2ONLY            
  assign rx_st_data          [ 151] =               rx_phy_postflop_1 [   3]                           ;  // Gen2 ? user_tdata[119]      : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [   4]                           ;  // Gen2 ? MARKER               : GEN2ONLY            
  assign rx_st_data          [ 152] =               rx_phy_postflop_1 [   5]                           ;  // Gen2 ? user_tdata[120]      : GEN2ONLY            
  assign rx_st_data          [ 153] =               rx_phy_postflop_1 [   6]                           ;  // Gen2 ? user_tdata[121]      : GEN2ONLY            
  assign rx_st_data          [ 154] =               rx_phy_postflop_1 [   7]                           ;  // Gen2 ? user_tdata[122]      : GEN2ONLY            
  assign rx_st_data          [ 155] =               rx_phy_postflop_1 [   8]                           ;  // Gen2 ? user_tdata[123]      : GEN2ONLY            
  assign rx_st_data          [ 156] =               rx_phy_postflop_1 [   9]                           ;  // Gen2 ? user_tdata[124]      : GEN2ONLY            
  assign rx_st_data          [ 157] =               rx_phy_postflop_1 [  10]                           ;  // Gen2 ? user_tdata[125]      : GEN2ONLY            
  assign rx_st_data          [ 158] =               rx_phy_postflop_1 [  11]                           ;  // Gen2 ? user_tdata[126]      : GEN2ONLY            
  assign rx_st_data          [ 159] =               rx_phy_postflop_1 [  12]                           ;  // Gen2 ? user_tdata[127]      : GEN2ONLY            
  assign rx_st_data          [ 160] =               rx_phy_postflop_1 [  13]                           ;  // Gen2 ? user_tdata[128]      : GEN2ONLY            
  assign rx_st_data          [ 161] =               rx_phy_postflop_1 [  14]                           ;  // Gen2 ? user_tdata[129]      : GEN2ONLY            
  assign rx_st_data          [ 162] =               rx_phy_postflop_1 [  15]                           ;  // Gen2 ? user_tdata[130]      : GEN2ONLY            
  assign rx_st_data          [ 163] =               rx_phy_postflop_1 [  16]                           ;  // Gen2 ? user_tdata[131]      : GEN2ONLY            
  assign rx_st_data          [ 164] =               rx_phy_postflop_1 [  17]                           ;  // Gen2 ? user_tdata[132]      : GEN2ONLY            
  assign rx_st_data          [ 165] =               rx_phy_postflop_1 [  18]                           ;  // Gen2 ? user_tdata[133]      : GEN2ONLY            
  assign rx_st_data          [ 166] =               rx_phy_postflop_1 [  19]                           ;  // Gen2 ? user_tdata[134]      : GEN2ONLY            
  assign rx_st_data          [ 167] =               rx_phy_postflop_1 [  20]                           ;  // Gen2 ? user_tdata[135]      : GEN2ONLY            
  assign rx_st_data          [ 168] =               rx_phy_postflop_1 [  21]                           ;  // Gen2 ? user_tdata[136]      : GEN2ONLY            
  assign rx_st_data          [ 169] =               rx_phy_postflop_1 [  22]                           ;  // Gen2 ? user_tdata[137]      : GEN2ONLY            
  assign rx_st_data          [ 170] =               rx_phy_postflop_1 [  23]                           ;  // Gen2 ? user_tdata[138]      : GEN2ONLY            
  assign rx_st_data          [ 171] =               rx_phy_postflop_1 [  24]                           ;  // Gen2 ? user_tdata[139]      : GEN2ONLY            
  assign rx_st_data          [ 172] =               rx_phy_postflop_1 [  25]                           ;  // Gen2 ? user_tdata[140]      : GEN2ONLY            
  assign rx_st_data          [ 173] =               rx_phy_postflop_1 [  26]                           ;  // Gen2 ? user_tdata[141]      : GEN2ONLY            
  assign rx_st_data          [ 174] =               rx_phy_postflop_1 [  27]                           ;  // Gen2 ? user_tdata[142]      : GEN2ONLY            
  assign rx_st_data          [ 175] =               rx_phy_postflop_1 [  28]                           ;  // Gen2 ? user_tdata[143]      : GEN2ONLY            
  assign rx_st_data          [ 176] =               rx_phy_postflop_1 [  29]                           ;  // Gen2 ? user_tdata[144]      : GEN2ONLY            
  assign rx_st_data          [ 177] =               rx_phy_postflop_1 [  30]                           ;  // Gen2 ? user_tdata[145]      : GEN2ONLY            
  assign rx_st_data          [ 178] =               rx_phy_postflop_1 [  31]                           ;  // Gen2 ? user_tdata[146]      : GEN2ONLY            
  assign rx_st_data          [ 179] =               rx_phy_postflop_1 [  32]                           ;  // Gen2 ? user_tdata[147]      : GEN2ONLY            
  assign rx_st_data          [ 180] =               rx_phy_postflop_1 [  33]                           ;  // Gen2 ? user_tdata[148]      : GEN2ONLY            
  assign rx_st_data          [ 181] =               rx_phy_postflop_1 [  34]                           ;  // Gen2 ? user_tdata[149]      : GEN2ONLY            
  assign rx_st_data          [ 182] =               rx_phy_postflop_1 [  35]                           ;  // Gen2 ? user_tdata[150]      : GEN2ONLY            
  assign rx_st_data          [ 183] =               rx_phy_postflop_1 [  36]                           ;  // Gen2 ? user_tdata[151]      : GEN2ONLY            
  assign rx_st_data          [ 184] =               rx_phy_postflop_1 [  37]                           ;  // Gen2 ? user_tdata[152]      : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  38]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  39]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
  assign rx_st_data          [ 185] =               rx_phy_postflop_1 [  40]                           ;  // Gen2 ? user_tdata[153]      : GEN2ONLY            
  assign rx_st_data          [ 186] =               rx_phy_postflop_1 [  41]                           ;  // Gen2 ? user_tdata[154]      : GEN2ONLY            
  assign rx_st_data          [ 187] =               rx_phy_postflop_1 [  42]                           ;  // Gen2 ? user_tdata[155]      : GEN2ONLY            
  assign rx_st_data          [ 188] =               rx_phy_postflop_1 [  43]                           ;  // Gen2 ? user_tdata[156]      : GEN2ONLY            
  assign rx_st_data          [ 189] =               rx_phy_postflop_1 [  44]                           ;  // Gen2 ? user_tdata[157]      : GEN2ONLY            
  assign rx_st_data          [ 190] =               rx_phy_postflop_1 [  45]                           ;  // Gen2 ? user_tdata[158]      : GEN2ONLY            
  assign rx_st_data          [ 191] =               rx_phy_postflop_1 [  46]                           ;  // Gen2 ? user_tdata[159]      : GEN2ONLY            
  assign rx_st_data          [ 192] =               rx_phy_postflop_1 [  47]                           ;  // Gen2 ? user_tdata[160]      : GEN2ONLY            
  assign rx_st_data          [ 193] =               rx_phy_postflop_1 [  48]                           ;  // Gen2 ? user_tdata[161]      : GEN2ONLY            
  assign rx_st_data          [ 194] =               rx_phy_postflop_1 [  49]                           ;  // Gen2 ? user_tdata[162]      : GEN2ONLY            
  assign rx_st_data          [ 195] =               rx_phy_postflop_1 [  50]                           ;  // Gen2 ? user_tdata[163]      : GEN2ONLY            
  assign rx_st_data          [ 196] =               rx_phy_postflop_1 [  51]                           ;  // Gen2 ? user_tdata[164]      : GEN2ONLY            
  assign rx_st_data          [ 197] =               rx_phy_postflop_1 [  52]                           ;  // Gen2 ? user_tdata[165]      : GEN2ONLY            
  assign rx_st_data          [ 198] =               rx_phy_postflop_1 [  53]                           ;  // Gen2 ? user_tdata[166]      : GEN2ONLY            
  assign rx_st_data          [ 199] =               rx_phy_postflop_1 [  54]                           ;  // Gen2 ? user_tdata[167]      : GEN2ONLY            
  assign rx_st_data          [ 200] =               rx_phy_postflop_1 [  55]                           ;  // Gen2 ? user_tdata[168]      : GEN2ONLY            
  assign rx_st_data          [ 201] =               rx_phy_postflop_1 [  56]                           ;  // Gen2 ? user_tdata[169]      : GEN2ONLY            
  assign rx_st_data          [ 202] =               rx_phy_postflop_1 [  57]                           ;  // Gen2 ? user_tdata[170]      : GEN2ONLY            
  assign rx_st_data          [ 203] =               rx_phy_postflop_1 [  58]                           ;  // Gen2 ? user_tdata[171]      : GEN2ONLY            
  assign rx_st_data          [ 204] =               rx_phy_postflop_1 [  59]                           ;  // Gen2 ? user_tdata[172]      : GEN2ONLY            
  assign rx_st_data          [ 205] =               rx_phy_postflop_1 [  60]                           ;  // Gen2 ? user_tdata[173]      : GEN2ONLY            
  assign rx_st_data          [ 206] =               rx_phy_postflop_1 [  61]                           ;  // Gen2 ? user_tdata[174]      : GEN2ONLY            
  assign rx_st_data          [ 207] =               rx_phy_postflop_1 [  62]                           ;  // Gen2 ? user_tdata[175]      : GEN2ONLY            
  assign rx_st_data          [ 208] =               rx_phy_postflop_1 [  63]                           ;  // Gen2 ? user_tdata[176]      : GEN2ONLY            
  assign rx_st_data          [ 209] =               rx_phy_postflop_1 [  64]                           ;  // Gen2 ? user_tdata[177]      : GEN2ONLY            
  assign rx_st_data          [ 210] =               rx_phy_postflop_1 [  65]                           ;  // Gen2 ? user_tdata[178]      : GEN2ONLY            
  assign rx_st_data          [ 211] =               rx_phy_postflop_1 [  66]                           ;  // Gen2 ? user_tdata[179]      : GEN2ONLY            
  assign rx_st_data          [ 212] =               rx_phy_postflop_1 [  67]                           ;  // Gen2 ? user_tdata[180]      : GEN2ONLY            
  assign rx_st_data          [ 213] =               rx_phy_postflop_1 [  68]                           ;  // Gen2 ? user_tdata[181]      : GEN2ONLY            
  assign rx_st_data          [ 214] =               rx_phy_postflop_1 [  69]                           ;  // Gen2 ? user_tdata[182]      : GEN2ONLY            
  assign rx_st_data          [ 215] =               rx_phy_postflop_1 [  70]                           ;  // Gen2 ? user_tdata[183]      : GEN2ONLY            
  assign rx_st_data          [ 216] =               rx_phy_postflop_1 [  71]                           ;  // Gen2 ? user_tdata[184]      : GEN2ONLY            
  assign rx_st_data          [ 217] =               rx_phy_postflop_1 [  72]                           ;  // Gen2 ? user_tdata[185]      : GEN2ONLY            
  assign rx_st_data          [ 218] =               rx_phy_postflop_1 [  73]                           ;  // Gen2 ? user_tdata[186]      : GEN2ONLY            
  assign rx_st_data          [ 219] =               rx_phy_postflop_1 [  74]                           ;  // Gen2 ? user_tdata[187]      : GEN2ONLY            
  assign rx_st_data          [ 220] =               rx_phy_postflop_1 [  75]                           ;  // Gen2 ? user_tdata[188]      : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  76]                           ;  // Gen2 ? STROBE               : GEN2ONLY            
  assign rx_st_data          [ 221] =               rx_phy_postflop_1 [  77]                           ;  // Gen2 ? user_tdata[189]      : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  78]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  79]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
  assign rx_st_data          [ 222] =               rx_phy_postflop_1 [  80]                           ;  // Gen2 ? user_tdata[190]      : GEN2ONLY            
  assign rx_st_data          [ 223] =               rx_phy_postflop_1 [  81]                           ;  // Gen2 ? user_tdata[191]      : GEN2ONLY            
  assign rx_st_data          [ 224] =               rx_phy_postflop_1 [  82]                           ;  // Gen2 ? user_tdata[192]      : GEN2ONLY            
  assign rx_st_data          [ 225] =               rx_phy_postflop_1 [  83]                           ;  // Gen2 ? user_tdata[193]      : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  84]                           ;  // Gen2 ? MARKER               : GEN2ONLY            
  assign rx_st_data          [ 226] =               rx_phy_postflop_1 [  85]                           ;  // Gen2 ? user_tdata[194]      : GEN2ONLY            
  assign rx_st_data          [ 227] =               rx_phy_postflop_1 [  86]                           ;  // Gen2 ? user_tdata[195]      : GEN2ONLY            
  assign rx_st_data          [ 228] =               rx_phy_postflop_1 [  87]                           ;  // Gen2 ? user_tdata[196]      : GEN2ONLY            
  assign rx_st_data          [ 229] =               rx_phy_postflop_1 [  88]                           ;  // Gen2 ? user_tdata[197]      : GEN2ONLY            
  assign rx_st_data          [ 230] =               rx_phy_postflop_1 [  89]                           ;  // Gen2 ? user_tdata[198]      : GEN2ONLY            
  assign rx_st_data          [ 231] =               rx_phy_postflop_1 [  90]                           ;  // Gen2 ? user_tdata[199]      : GEN2ONLY            
  assign rx_st_data          [ 232] =               rx_phy_postflop_1 [  91]                           ;  // Gen2 ? user_tdata[200]      : GEN2ONLY            
  assign rx_st_data          [ 233] =               rx_phy_postflop_1 [  92]                           ;  // Gen2 ? user_tdata[201]      : GEN2ONLY            
  assign rx_st_data          [ 234] =               rx_phy_postflop_1 [  93]                           ;  // Gen2 ? user_tdata[202]      : GEN2ONLY            
  assign rx_st_data          [ 235] =               rx_phy_postflop_1 [  94]                           ;  // Gen2 ? user_tdata[203]      : GEN2ONLY            
  assign rx_st_data          [ 236] =               rx_phy_postflop_1 [  95]                           ;  // Gen2 ? user_tdata[204]      : GEN2ONLY            
  assign rx_st_data          [ 237] =               rx_phy_postflop_1 [  96]                           ;  // Gen2 ? user_tdata[205]      : GEN2ONLY            
  assign rx_st_data          [ 238] =               rx_phy_postflop_1 [  97]                           ;  // Gen2 ? user_tdata[206]      : GEN2ONLY            
  assign rx_st_data          [ 239] =               rx_phy_postflop_1 [  98]                           ;  // Gen2 ? user_tdata[207]      : GEN2ONLY            
  assign rx_st_data          [ 240] =               rx_phy_postflop_1 [  99]                           ;  // Gen2 ? user_tdata[208]      : GEN2ONLY            
  assign rx_st_data          [ 241] =               rx_phy_postflop_1 [ 100]                           ;  // Gen2 ? user_tdata[209]      : GEN2ONLY            
  assign rx_st_data          [ 242] =               rx_phy_postflop_1 [ 101]                           ;  // Gen2 ? user_tdata[210]      : GEN2ONLY            
  assign rx_st_data          [ 243] =               rx_phy_postflop_1 [ 102]                           ;  // Gen2 ? user_tdata[211]      : GEN2ONLY            
  assign rx_st_data          [ 244] =               rx_phy_postflop_1 [ 103]                           ;  // Gen2 ? user_tdata[212]      : GEN2ONLY            
  assign rx_st_data          [ 245] =               rx_phy_postflop_1 [ 104]                           ;  // Gen2 ? user_tdata[213]      : GEN2ONLY            
  assign rx_st_data          [ 246] =               rx_phy_postflop_1 [ 105]                           ;  // Gen2 ? user_tdata[214]      : GEN2ONLY            
  assign rx_st_data          [ 247] =               rx_phy_postflop_1 [ 106]                           ;  // Gen2 ? user_tdata[215]      : GEN2ONLY            
  assign rx_st_data          [ 248] =               rx_phy_postflop_1 [ 107]                           ;  // Gen2 ? user_tdata[216]      : GEN2ONLY            
  assign rx_st_data          [ 249] =               rx_phy_postflop_1 [ 108]                           ;  // Gen2 ? user_tdata[217]      : GEN2ONLY            
  assign rx_st_data          [ 250] =               rx_phy_postflop_1 [ 109]                           ;  // Gen2 ? user_tdata[218]      : GEN2ONLY            
  assign rx_st_data          [ 251] =               rx_phy_postflop_1 [ 110]                           ;  // Gen2 ? user_tdata[219]      : GEN2ONLY            
  assign rx_st_data          [ 252] =               rx_phy_postflop_1 [ 111]                           ;  // Gen2 ? user_tdata[220]      : GEN2ONLY            
  assign rx_st_data          [ 253] =               rx_phy_postflop_1 [ 112]                           ;  // Gen2 ? user_tdata[221]      : GEN2ONLY            
  assign rx_st_data          [ 254] =               rx_phy_postflop_1 [ 113]                           ;  // Gen2 ? user_tdata[222]      : GEN2ONLY            
  assign rx_st_data          [ 255] =               rx_phy_postflop_1 [ 114]                           ;  // Gen2 ? user_tdata[223]      : GEN2ONLY            
  assign rx_st_data          [ 256] =               rx_phy_postflop_1 [ 115]                           ;  // Gen2 ? user_tdata[224]      : GEN2ONLY            
  assign rx_st_data          [ 257] =               rx_phy_postflop_1 [ 116]                           ;  // Gen2 ? user_tdata[225]      : GEN2ONLY            
  assign rx_st_data          [ 258] =               rx_phy_postflop_1 [ 117]                           ;  // Gen2 ? user_tdata[226]      : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 118]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 119]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
  assign rx_st_data          [ 259] =               rx_phy_postflop_1 [ 120]                           ;  // Gen2 ? user_tdata[227]      : GEN2ONLY            
  assign rx_st_data          [ 260] =               rx_phy_postflop_1 [ 121]                           ;  // Gen2 ? user_tdata[228]      : GEN2ONLY            
  assign rx_st_data          [ 261] =               rx_phy_postflop_1 [ 122]                           ;  // Gen2 ? user_tdata[229]      : GEN2ONLY            
  assign rx_st_data          [ 262] =               rx_phy_postflop_1 [ 123]                           ;  // Gen2 ? user_tdata[230]      : GEN2ONLY            
  assign rx_st_data          [ 263] =               rx_phy_postflop_1 [ 124]                           ;  // Gen2 ? user_tdata[231]      : GEN2ONLY            
  assign rx_st_data          [ 264] =               rx_phy_postflop_1 [ 125]                           ;  // Gen2 ? user_tdata[232]      : GEN2ONLY            
  assign rx_st_data          [ 265] =               rx_phy_postflop_1 [ 126]                           ;  // Gen2 ? user_tdata[233]      : GEN2ONLY            
  assign rx_st_data          [ 266] =               rx_phy_postflop_1 [ 127]                           ;  // Gen2 ? user_tdata[234]      : GEN2ONLY            
  assign rx_st_data          [ 267] =               rx_phy_postflop_1 [ 128]                           ;  // Gen2 ? user_tdata[235]      : GEN2ONLY            
  assign rx_st_data          [ 268] =               rx_phy_postflop_1 [ 129]                           ;  // Gen2 ? user_tdata[236]      : GEN2ONLY            
  assign rx_st_data          [ 269] =               rx_phy_postflop_1 [ 130]                           ;  // Gen2 ? user_tdata[237]      : GEN2ONLY            
  assign rx_st_data          [ 270] =               rx_phy_postflop_1 [ 131]                           ;  // Gen2 ? user_tdata[238]      : GEN2ONLY            
  assign rx_st_data          [ 271] =               rx_phy_postflop_1 [ 132]                           ;  // Gen2 ? user_tdata[239]      : GEN2ONLY            
  assign rx_st_data          [ 272] =               rx_phy_postflop_1 [ 133]                           ;  // Gen2 ? user_tdata[240]      : GEN2ONLY            
  assign rx_st_data          [ 273] =               rx_phy_postflop_1 [ 134]                           ;  // Gen2 ? user_tdata[241]      : GEN2ONLY            
  assign rx_st_data          [ 274] =               rx_phy_postflop_1 [ 135]                           ;  // Gen2 ? user_tdata[242]      : GEN2ONLY            
  assign rx_st_data          [ 275] =               rx_phy_postflop_1 [ 136]                           ;  // Gen2 ? user_tdata[243]      : GEN2ONLY            
  assign rx_st_data          [ 276] =               rx_phy_postflop_1 [ 137]                           ;  // Gen2 ? user_tdata[244]      : GEN2ONLY            
  assign rx_st_data          [ 277] =               rx_phy_postflop_1 [ 138]                           ;  // Gen2 ? user_tdata[245]      : GEN2ONLY            
  assign rx_st_data          [ 278] =               rx_phy_postflop_1 [ 139]                           ;  // Gen2 ? user_tdata[246]      : GEN2ONLY            
  assign rx_st_data          [ 279] =               rx_phy_postflop_1 [ 140]                           ;  // Gen2 ? user_tdata[247]      : GEN2ONLY            
  assign rx_st_data          [ 280] =               rx_phy_postflop_1 [ 141]                           ;  // Gen2 ? user_tdata[248]      : GEN2ONLY            
  assign rx_st_data          [ 281] =               rx_phy_postflop_1 [ 142]                           ;  // Gen2 ? user_tdata[249]      : GEN2ONLY            
  assign rx_st_data          [ 282] =               rx_phy_postflop_1 [ 143]                           ;  // Gen2 ? user_tdata[250]      : GEN2ONLY            
  assign rx_st_data          [ 283] =               rx_phy_postflop_1 [ 144]                           ;  // Gen2 ? user_tdata[251]      : GEN2ONLY            
  assign rx_st_data          [ 284] =               rx_phy_postflop_1 [ 145]                           ;  // Gen2 ? user_tdata[252]      : GEN2ONLY            
  assign rx_st_data          [ 285] =               rx_phy_postflop_1 [ 146]                           ;  // Gen2 ? user_tdata[253]      : GEN2ONLY            
  assign rx_st_data          [ 286] =               rx_phy_postflop_1 [ 147]                           ;  // Gen2 ? user_tdata[254]      : GEN2ONLY            
  assign rx_st_data          [ 287] =               rx_phy_postflop_1 [ 148]                           ;  // Gen2 ? user_tdata[255]      : GEN2ONLY            
  assign rx_st_data          [ 288] =               rx_phy_postflop_1 [ 149]                           ;  // Gen2 ? user_tlast           : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 150]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 151]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 152]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 153]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 154]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 155]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 156]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 157]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 158]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 159]                           ;  // Gen2 ? DBI                  : GEN2ONLY            

// RX Section
//////////////////////////////////////////////////////////////////


endmodule
