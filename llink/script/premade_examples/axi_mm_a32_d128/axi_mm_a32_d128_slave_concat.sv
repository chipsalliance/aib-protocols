////////////////////////////////////////////////////////////
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
////////////////////////////////////////////////////////////

module axi_mm_a32_d128_slave_concat  (

// Data from Logic Links
  output logic [  48:   0]   rx_ar_data          ,
  output logic               rx_ar_push_ovrd     ,
  output logic               rx_ar_pushbit       ,
  input  logic               tx_ar_credit        ,

  output logic [  48:   0]   rx_aw_data          ,
  output logic               rx_aw_push_ovrd     ,
  output logic               rx_aw_pushbit       ,
  input  logic               tx_aw_credit        ,

  output logic [ 148:   0]   rx_w_data           ,
  output logic               rx_w_push_ovrd      ,
  output logic               rx_w_pushbit        ,
  input  logic               tx_w_credit         ,

  input  logic [ 134:   0]   tx_r_data           ,
  output logic               tx_r_pop_ovrd       ,
  input  logic               tx_r_pushbit        ,
  output logic               rx_r_credit         ,

  input  logic [   5:   0]   tx_b_data           ,
  output logic               tx_b_pop_ovrd       ,
  input  logic               tx_b_pushbit        ,
  output logic               rx_b_credit         ,

// PHY Interconnect
  output logic [  79:   0]   tx_phy0             ,
  input  logic [  79:   0]   rx_phy0             ,
  output logic [  79:   0]   tx_phy1             ,
  input  logic [  79:   0]   rx_phy1             ,
  output logic [  79:   0]   tx_phy2             ,
  input  logic [  79:   0]   rx_phy2             ,
  output logic [  79:   0]   tx_phy3             ,
  input  logic [  79:   0]   rx_phy3             ,

  input  logic               clk_wr              ,
  input  logic               clk_rd              ,
  input  logic               rst_wr_n            ,
  input  logic               rst_rd_n            ,

  input  logic               m_gen2_mode         ,
  input  logic               tx_online           ,

  input  logic               tx_stb_userbit      ,
  input  logic [   0:   0]   tx_mrk_userbit      

);

// No TX Packetization, so tie off packetization signals
  assign tx_r_pop_ovrd                      = 1'b0                               ;
  assign tx_b_pop_ovrd                      = 1'b0                               ;

// No RX Packetization, so tie off packetization signals
  assign rx_ar_push_ovrd                    = 1'b0                               ;
  assign rx_aw_push_ovrd                    = 1'b0                               ;
  assign rx_w_push_ovrd                     = 1'b0                               ;

//////////////////////////////////////////////////////////////////
// TX Section

//   TX_CH_WIDTH           = 80; // Gen2Only running at Full Rate
//   TX_DATA_WIDTH         = 74; // Usable Data per Channel
//   TX_PERSISTENT_STROBE  = 1'b1;
//   TX_PERSISTENT_MARKER  = 1'b1;
//   TX_STROBE_GEN2_LOC    = 'd76;
//   TX_MARKER_GEN2_LOC    = 'd4;
//   TX_STROBE_GEN1_LOC    = 'd38;
//   TX_MARKER_GEN1_LOC    = 'd39;
//   TX_ENABLE_STROBE      = 1'b1;
//   TX_ENABLE_MARKER      = 1'b1;
//   TX_DBI_PRESENT        = 1'b1;
//   TX_REG_PHY            = 1'b0;

  localparam TX_REG_PHY    = 1'b0;  // If set, this enables boundary FF for timing reasons

  logic [  79:   0]                              tx_phy_preflop_0              ;
  logic [  79:   0]                              tx_phy_preflop_1              ;
  logic [  79:   0]                              tx_phy_preflop_2              ;
  logic [  79:   0]                              tx_phy_preflop_3              ;
  logic [  79:   0]                              tx_phy_flop_0_reg             ;
  logic [  79:   0]                              tx_phy_flop_1_reg             ;
  logic [  79:   0]                              tx_phy_flop_2_reg             ;
  logic [  79:   0]                              tx_phy_flop_3_reg             ;

  always_ff @(posedge clk_wr or negedge rst_wr_n)
  if (~rst_wr_n)
  begin
    tx_phy_flop_0_reg                       <= 80'b0                                   ;
    tx_phy_flop_1_reg                       <= 80'b0                                   ;
    tx_phy_flop_2_reg                       <= 80'b0                                   ;
    tx_phy_flop_3_reg                       <= 80'b0                                   ;
  end
  else
  begin
    tx_phy_flop_0_reg                       <= tx_phy_preflop_0                        ;
    tx_phy_flop_1_reg                       <= tx_phy_preflop_1                        ;
    tx_phy_flop_2_reg                       <= tx_phy_preflop_2                        ;
    tx_phy_flop_3_reg                       <= tx_phy_preflop_3                        ;
  end

  assign tx_phy0                            = TX_REG_PHY ? tx_phy_flop_0_reg : tx_phy_preflop_0               ;
  assign tx_phy1                            = TX_REG_PHY ? tx_phy_flop_1_reg : tx_phy_preflop_1               ;
  assign tx_phy2                            = TX_REG_PHY ? tx_phy_flop_2_reg : tx_phy_preflop_2               ;
  assign tx_phy3                            = TX_REG_PHY ? tx_phy_flop_3_reg : tx_phy_preflop_3               ;

  assign tx_phy_preflop_0 [   0] = tx_ar_credit               ;
  assign tx_phy_preflop_0 [   1] = tx_aw_credit               ;
  assign tx_phy_preflop_0 [   2] = tx_w_credit                ;
  assign tx_phy_preflop_0 [   3] = tx_r_pushbit               ;
  assign tx_phy_preflop_0 [   4] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_0 [   5] = tx_r_data           [   0] ;
  assign tx_phy_preflop_0 [   6] = tx_r_data           [   1] ;
  assign tx_phy_preflop_0 [   7] = tx_r_data           [   2] ;
  assign tx_phy_preflop_0 [   8] = tx_r_data           [   3] ;
  assign tx_phy_preflop_0 [   9] = tx_r_data           [   4] ;
  assign tx_phy_preflop_0 [  10] = tx_r_data           [   5] ;
  assign tx_phy_preflop_0 [  11] = tx_r_data           [   6] ;
  assign tx_phy_preflop_0 [  12] = tx_r_data           [   7] ;
  assign tx_phy_preflop_0 [  13] = tx_r_data           [   8] ;
  assign tx_phy_preflop_0 [  14] = tx_r_data           [   9] ;
  assign tx_phy_preflop_0 [  15] = tx_r_data           [  10] ;
  assign tx_phy_preflop_0 [  16] = tx_r_data           [  11] ;
  assign tx_phy_preflop_0 [  17] = tx_r_data           [  12] ;
  assign tx_phy_preflop_0 [  18] = tx_r_data           [  13] ;
  assign tx_phy_preflop_0 [  19] = tx_r_data           [  14] ;
  assign tx_phy_preflop_0 [  20] = tx_r_data           [  15] ;
  assign tx_phy_preflop_0 [  21] = tx_r_data           [  16] ;
  assign tx_phy_preflop_0 [  22] = tx_r_data           [  17] ;
  assign tx_phy_preflop_0 [  23] = tx_r_data           [  18] ;
  assign tx_phy_preflop_0 [  24] = tx_r_data           [  19] ;
  assign tx_phy_preflop_0 [  25] = tx_r_data           [  20] ;
  assign tx_phy_preflop_0 [  26] = tx_r_data           [  21] ;
  assign tx_phy_preflop_0 [  27] = tx_r_data           [  22] ;
  assign tx_phy_preflop_0 [  28] = tx_r_data           [  23] ;
  assign tx_phy_preflop_0 [  29] = tx_r_data           [  24] ;
  assign tx_phy_preflop_0 [  30] = tx_r_data           [  25] ;
  assign tx_phy_preflop_0 [  31] = tx_r_data           [  26] ;
  assign tx_phy_preflop_0 [  32] = tx_r_data           [  27] ;
  assign tx_phy_preflop_0 [  33] = tx_r_data           [  28] ;
  assign tx_phy_preflop_0 [  34] = tx_r_data           [  29] ;
  assign tx_phy_preflop_0 [  35] = tx_r_data           [  30] ;
  assign tx_phy_preflop_0 [  36] = tx_r_data           [  31] ;
  assign tx_phy_preflop_0 [  37] = tx_r_data           [  32] ;
  assign tx_phy_preflop_0 [  38] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [  39] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [  40] = tx_r_data           [  33] ;
  assign tx_phy_preflop_0 [  41] = tx_r_data           [  34] ;
  assign tx_phy_preflop_0 [  42] = tx_r_data           [  35] ;
  assign tx_phy_preflop_0 [  43] = tx_r_data           [  36] ;
  assign tx_phy_preflop_0 [  44] = tx_r_data           [  37] ;
  assign tx_phy_preflop_0 [  45] = tx_r_data           [  38] ;
  assign tx_phy_preflop_0 [  46] = tx_r_data           [  39] ;
  assign tx_phy_preflop_0 [  47] = tx_r_data           [  40] ;
  assign tx_phy_preflop_0 [  48] = tx_r_data           [  41] ;
  assign tx_phy_preflop_0 [  49] = tx_r_data           [  42] ;
  assign tx_phy_preflop_0 [  50] = tx_r_data           [  43] ;
  assign tx_phy_preflop_0 [  51] = tx_r_data           [  44] ;
  assign tx_phy_preflop_0 [  52] = tx_r_data           [  45] ;
  assign tx_phy_preflop_0 [  53] = tx_r_data           [  46] ;
  assign tx_phy_preflop_0 [  54] = tx_r_data           [  47] ;
  assign tx_phy_preflop_0 [  55] = tx_r_data           [  48] ;
  assign tx_phy_preflop_0 [  56] = tx_r_data           [  49] ;
  assign tx_phy_preflop_0 [  57] = tx_r_data           [  50] ;
  assign tx_phy_preflop_0 [  58] = tx_r_data           [  51] ;
  assign tx_phy_preflop_0 [  59] = tx_r_data           [  52] ;
  assign tx_phy_preflop_0 [  60] = tx_r_data           [  53] ;
  assign tx_phy_preflop_0 [  61] = tx_r_data           [  54] ;
  assign tx_phy_preflop_0 [  62] = tx_r_data           [  55] ;
  assign tx_phy_preflop_0 [  63] = tx_r_data           [  56] ;
  assign tx_phy_preflop_0 [  64] = tx_r_data           [  57] ;
  assign tx_phy_preflop_0 [  65] = tx_r_data           [  58] ;
  assign tx_phy_preflop_0 [  66] = tx_r_data           [  59] ;
  assign tx_phy_preflop_0 [  67] = tx_r_data           [  60] ;
  assign tx_phy_preflop_0 [  68] = tx_r_data           [  61] ;
  assign tx_phy_preflop_0 [  69] = tx_r_data           [  62] ;
  assign tx_phy_preflop_0 [  70] = tx_r_data           [  63] ;
  assign tx_phy_preflop_0 [  71] = tx_r_data           [  64] ;
  assign tx_phy_preflop_0 [  72] = tx_r_data           [  65] ;
  assign tx_phy_preflop_0 [  73] = tx_r_data           [  66] ;
  assign tx_phy_preflop_0 [  74] = tx_r_data           [  67] ;
  assign tx_phy_preflop_0 [  75] = tx_r_data           [  68] ;
  assign tx_phy_preflop_0 [  76] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_0 [  77] = tx_r_data           [  69] ;
  assign tx_phy_preflop_0 [  78] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [  79] = 1'b0                       ; // DBI
  assign tx_phy_preflop_1 [   0] = tx_r_data           [  70] ;
  assign tx_phy_preflop_1 [   1] = tx_r_data           [  71] ;
  assign tx_phy_preflop_1 [   2] = tx_r_data           [  72] ;
  assign tx_phy_preflop_1 [   3] = tx_r_data           [  73] ;
  assign tx_phy_preflop_1 [   4] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_1 [   5] = tx_r_data           [  74] ;
  assign tx_phy_preflop_1 [   6] = tx_r_data           [  75] ;
  assign tx_phy_preflop_1 [   7] = tx_r_data           [  76] ;
  assign tx_phy_preflop_1 [   8] = tx_r_data           [  77] ;
  assign tx_phy_preflop_1 [   9] = tx_r_data           [  78] ;
  assign tx_phy_preflop_1 [  10] = tx_r_data           [  79] ;
  assign tx_phy_preflop_1 [  11] = tx_r_data           [  80] ;
  assign tx_phy_preflop_1 [  12] = tx_r_data           [  81] ;
  assign tx_phy_preflop_1 [  13] = tx_r_data           [  82] ;
  assign tx_phy_preflop_1 [  14] = tx_r_data           [  83] ;
  assign tx_phy_preflop_1 [  15] = tx_r_data           [  84] ;
  assign tx_phy_preflop_1 [  16] = tx_r_data           [  85] ;
  assign tx_phy_preflop_1 [  17] = tx_r_data           [  86] ;
  assign tx_phy_preflop_1 [  18] = tx_r_data           [  87] ;
  assign tx_phy_preflop_1 [  19] = tx_r_data           [  88] ;
  assign tx_phy_preflop_1 [  20] = tx_r_data           [  89] ;
  assign tx_phy_preflop_1 [  21] = tx_r_data           [  90] ;
  assign tx_phy_preflop_1 [  22] = tx_r_data           [  91] ;
  assign tx_phy_preflop_1 [  23] = tx_r_data           [  92] ;
  assign tx_phy_preflop_1 [  24] = tx_r_data           [  93] ;
  assign tx_phy_preflop_1 [  25] = tx_r_data           [  94] ;
  assign tx_phy_preflop_1 [  26] = tx_r_data           [  95] ;
  assign tx_phy_preflop_1 [  27] = tx_r_data           [  96] ;
  assign tx_phy_preflop_1 [  28] = tx_r_data           [  97] ;
  assign tx_phy_preflop_1 [  29] = tx_r_data           [  98] ;
  assign tx_phy_preflop_1 [  30] = tx_r_data           [  99] ;
  assign tx_phy_preflop_1 [  31] = tx_r_data           [ 100] ;
  assign tx_phy_preflop_1 [  32] = tx_r_data           [ 101] ;
  assign tx_phy_preflop_1 [  33] = tx_r_data           [ 102] ;
  assign tx_phy_preflop_1 [  34] = tx_r_data           [ 103] ;
  assign tx_phy_preflop_1 [  35] = tx_r_data           [ 104] ;
  assign tx_phy_preflop_1 [  36] = tx_r_data           [ 105] ;
  assign tx_phy_preflop_1 [  37] = tx_r_data           [ 106] ;
  assign tx_phy_preflop_1 [  38] = 1'b0                       ; // DBI
  assign tx_phy_preflop_1 [  39] = 1'b0                       ; // DBI
  assign tx_phy_preflop_1 [  40] = tx_r_data           [ 107] ;
  assign tx_phy_preflop_1 [  41] = tx_r_data           [ 108] ;
  assign tx_phy_preflop_1 [  42] = tx_r_data           [ 109] ;
  assign tx_phy_preflop_1 [  43] = tx_r_data           [ 110] ;
  assign tx_phy_preflop_1 [  44] = tx_r_data           [ 111] ;
  assign tx_phy_preflop_1 [  45] = tx_r_data           [ 112] ;
  assign tx_phy_preflop_1 [  46] = tx_r_data           [ 113] ;
  assign tx_phy_preflop_1 [  47] = tx_r_data           [ 114] ;
  assign tx_phy_preflop_1 [  48] = tx_r_data           [ 115] ;
  assign tx_phy_preflop_1 [  49] = tx_r_data           [ 116] ;
  assign tx_phy_preflop_1 [  50] = tx_r_data           [ 117] ;
  assign tx_phy_preflop_1 [  51] = tx_r_data           [ 118] ;
  assign tx_phy_preflop_1 [  52] = tx_r_data           [ 119] ;
  assign tx_phy_preflop_1 [  53] = tx_r_data           [ 120] ;
  assign tx_phy_preflop_1 [  54] = tx_r_data           [ 121] ;
  assign tx_phy_preflop_1 [  55] = tx_r_data           [ 122] ;
  assign tx_phy_preflop_1 [  56] = tx_r_data           [ 123] ;
  assign tx_phy_preflop_1 [  57] = tx_r_data           [ 124] ;
  assign tx_phy_preflop_1 [  58] = tx_r_data           [ 125] ;
  assign tx_phy_preflop_1 [  59] = tx_r_data           [ 126] ;
  assign tx_phy_preflop_1 [  60] = tx_r_data           [ 127] ;
  assign tx_phy_preflop_1 [  61] = tx_r_data           [ 128] ;
  assign tx_phy_preflop_1 [  62] = tx_r_data           [ 129] ;
  assign tx_phy_preflop_1 [  63] = tx_r_data           [ 130] ;
  assign tx_phy_preflop_1 [  64] = tx_r_data           [ 131] ;
  assign tx_phy_preflop_1 [  65] = tx_r_data           [ 132] ;
  assign tx_phy_preflop_1 [  66] = tx_r_data           [ 133] ;
  assign tx_phy_preflop_1 [  67] = tx_r_data           [ 134] ;
  assign tx_phy_preflop_1 [  68] = tx_b_pushbit               ;
  assign tx_phy_preflop_1 [  69] = tx_b_data           [   0] ;
  assign tx_phy_preflop_1 [  70] = tx_b_data           [   1] ;
  assign tx_phy_preflop_1 [  71] = tx_b_data           [   2] ;
  assign tx_phy_preflop_1 [  72] = tx_b_data           [   3] ;
  assign tx_phy_preflop_1 [  73] = tx_b_data           [   4] ;
  assign tx_phy_preflop_1 [  74] = tx_b_data           [   5] ;
  assign tx_phy_preflop_1 [  75] = 1'b0                       ;
  assign tx_phy_preflop_1 [  76] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_1 [  77] = 1'b0                       ;
  assign tx_phy_preflop_1 [  78] = 1'b0                       ; // DBI
  assign tx_phy_preflop_1 [  79] = 1'b0                       ; // DBI
  assign tx_phy_preflop_2 [   0] = 1'b0                       ;
  assign tx_phy_preflop_2 [   1] = 1'b0                       ;
  assign tx_phy_preflop_2 [   2] = 1'b0                       ;
  assign tx_phy_preflop_2 [   3] = 1'b0                       ;
  assign tx_phy_preflop_2 [   4] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_2 [   5] = 1'b0                       ;
  assign tx_phy_preflop_2 [   6] = 1'b0                       ;
  assign tx_phy_preflop_2 [   7] = 1'b0                       ;
  assign tx_phy_preflop_2 [   8] = 1'b0                       ;
  assign tx_phy_preflop_2 [   9] = 1'b0                       ;
  assign tx_phy_preflop_2 [  10] = 1'b0                       ;
  assign tx_phy_preflop_2 [  11] = 1'b0                       ;
  assign tx_phy_preflop_2 [  12] = 1'b0                       ;
  assign tx_phy_preflop_2 [  13] = 1'b0                       ;
  assign tx_phy_preflop_2 [  14] = 1'b0                       ;
  assign tx_phy_preflop_2 [  15] = 1'b0                       ;
  assign tx_phy_preflop_2 [  16] = 1'b0                       ;
  assign tx_phy_preflop_2 [  17] = 1'b0                       ;
  assign tx_phy_preflop_2 [  18] = 1'b0                       ;
  assign tx_phy_preflop_2 [  19] = 1'b0                       ;
  assign tx_phy_preflop_2 [  20] = 1'b0                       ;
  assign tx_phy_preflop_2 [  21] = 1'b0                       ;
  assign tx_phy_preflop_2 [  22] = 1'b0                       ;
  assign tx_phy_preflop_2 [  23] = 1'b0                       ;
  assign tx_phy_preflop_2 [  24] = 1'b0                       ;
  assign tx_phy_preflop_2 [  25] = 1'b0                       ;
  assign tx_phy_preflop_2 [  26] = 1'b0                       ;
  assign tx_phy_preflop_2 [  27] = 1'b0                       ;
  assign tx_phy_preflop_2 [  28] = 1'b0                       ;
  assign tx_phy_preflop_2 [  29] = 1'b0                       ;
  assign tx_phy_preflop_2 [  30] = 1'b0                       ;
  assign tx_phy_preflop_2 [  31] = 1'b0                       ;
  assign tx_phy_preflop_2 [  32] = 1'b0                       ;
  assign tx_phy_preflop_2 [  33] = 1'b0                       ;
  assign tx_phy_preflop_2 [  34] = 1'b0                       ;
  assign tx_phy_preflop_2 [  35] = 1'b0                       ;
  assign tx_phy_preflop_2 [  36] = 1'b0                       ;
  assign tx_phy_preflop_2 [  37] = 1'b0                       ;
  assign tx_phy_preflop_2 [  38] = 1'b0                       ; // DBI
  assign tx_phy_preflop_2 [  39] = 1'b0                       ; // DBI
  assign tx_phy_preflop_2 [  40] = 1'b0                       ;
  assign tx_phy_preflop_2 [  41] = 1'b0                       ;
  assign tx_phy_preflop_2 [  42] = 1'b0                       ;
  assign tx_phy_preflop_2 [  43] = 1'b0                       ;
  assign tx_phy_preflop_2 [  44] = 1'b0                       ;
  assign tx_phy_preflop_2 [  45] = 1'b0                       ;
  assign tx_phy_preflop_2 [  46] = 1'b0                       ;
  assign tx_phy_preflop_2 [  47] = 1'b0                       ;
  assign tx_phy_preflop_2 [  48] = 1'b0                       ;
  assign tx_phy_preflop_2 [  49] = 1'b0                       ;
  assign tx_phy_preflop_2 [  50] = 1'b0                       ;
  assign tx_phy_preflop_2 [  51] = 1'b0                       ;
  assign tx_phy_preflop_2 [  52] = 1'b0                       ;
  assign tx_phy_preflop_2 [  53] = 1'b0                       ;
  assign tx_phy_preflop_2 [  54] = 1'b0                       ;
  assign tx_phy_preflop_2 [  55] = 1'b0                       ;
  assign tx_phy_preflop_2 [  56] = 1'b0                       ;
  assign tx_phy_preflop_2 [  57] = 1'b0                       ;
  assign tx_phy_preflop_2 [  58] = 1'b0                       ;
  assign tx_phy_preflop_2 [  59] = 1'b0                       ;
  assign tx_phy_preflop_2 [  60] = 1'b0                       ;
  assign tx_phy_preflop_2 [  61] = 1'b0                       ;
  assign tx_phy_preflop_2 [  62] = 1'b0                       ;
  assign tx_phy_preflop_2 [  63] = 1'b0                       ;
  assign tx_phy_preflop_2 [  64] = 1'b0                       ;
  assign tx_phy_preflop_2 [  65] = 1'b0                       ;
  assign tx_phy_preflop_2 [  66] = 1'b0                       ;
  assign tx_phy_preflop_2 [  67] = 1'b0                       ;
  assign tx_phy_preflop_2 [  68] = 1'b0                       ;
  assign tx_phy_preflop_2 [  69] = 1'b0                       ;
  assign tx_phy_preflop_2 [  70] = 1'b0                       ;
  assign tx_phy_preflop_2 [  71] = 1'b0                       ;
  assign tx_phy_preflop_2 [  72] = 1'b0                       ;
  assign tx_phy_preflop_2 [  73] = 1'b0                       ;
  assign tx_phy_preflop_2 [  74] = 1'b0                       ;
  assign tx_phy_preflop_2 [  75] = 1'b0                       ;
  assign tx_phy_preflop_2 [  76] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_2 [  77] = 1'b0                       ;
  assign tx_phy_preflop_2 [  78] = 1'b0                       ; // DBI
  assign tx_phy_preflop_2 [  79] = 1'b0                       ; // DBI
  assign tx_phy_preflop_3 [   0] = 1'b0                       ;
  assign tx_phy_preflop_3 [   1] = 1'b0                       ;
  assign tx_phy_preflop_3 [   2] = 1'b0                       ;
  assign tx_phy_preflop_3 [   3] = 1'b0                       ;
  assign tx_phy_preflop_3 [   4] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_3 [   5] = 1'b0                       ;
  assign tx_phy_preflop_3 [   6] = 1'b0                       ;
  assign tx_phy_preflop_3 [   7] = 1'b0                       ;
  assign tx_phy_preflop_3 [   8] = 1'b0                       ;
  assign tx_phy_preflop_3 [   9] = 1'b0                       ;
  assign tx_phy_preflop_3 [  10] = 1'b0                       ;
  assign tx_phy_preflop_3 [  11] = 1'b0                       ;
  assign tx_phy_preflop_3 [  12] = 1'b0                       ;
  assign tx_phy_preflop_3 [  13] = 1'b0                       ;
  assign tx_phy_preflop_3 [  14] = 1'b0                       ;
  assign tx_phy_preflop_3 [  15] = 1'b0                       ;
  assign tx_phy_preflop_3 [  16] = 1'b0                       ;
  assign tx_phy_preflop_3 [  17] = 1'b0                       ;
  assign tx_phy_preflop_3 [  18] = 1'b0                       ;
  assign tx_phy_preflop_3 [  19] = 1'b0                       ;
  assign tx_phy_preflop_3 [  20] = 1'b0                       ;
  assign tx_phy_preflop_3 [  21] = 1'b0                       ;
  assign tx_phy_preflop_3 [  22] = 1'b0                       ;
  assign tx_phy_preflop_3 [  23] = 1'b0                       ;
  assign tx_phy_preflop_3 [  24] = 1'b0                       ;
  assign tx_phy_preflop_3 [  25] = 1'b0                       ;
  assign tx_phy_preflop_3 [  26] = 1'b0                       ;
  assign tx_phy_preflop_3 [  27] = 1'b0                       ;
  assign tx_phy_preflop_3 [  28] = 1'b0                       ;
  assign tx_phy_preflop_3 [  29] = 1'b0                       ;
  assign tx_phy_preflop_3 [  30] = 1'b0                       ;
  assign tx_phy_preflop_3 [  31] = 1'b0                       ;
  assign tx_phy_preflop_3 [  32] = 1'b0                       ;
  assign tx_phy_preflop_3 [  33] = 1'b0                       ;
  assign tx_phy_preflop_3 [  34] = 1'b0                       ;
  assign tx_phy_preflop_3 [  35] = 1'b0                       ;
  assign tx_phy_preflop_3 [  36] = 1'b0                       ;
  assign tx_phy_preflop_3 [  37] = 1'b0                       ;
  assign tx_phy_preflop_3 [  38] = 1'b0                       ; // DBI
  assign tx_phy_preflop_3 [  39] = 1'b0                       ; // DBI
  assign tx_phy_preflop_3 [  40] = 1'b0                       ;
  assign tx_phy_preflop_3 [  41] = 1'b0                       ;
  assign tx_phy_preflop_3 [  42] = 1'b0                       ;
  assign tx_phy_preflop_3 [  43] = 1'b0                       ;
  assign tx_phy_preflop_3 [  44] = 1'b0                       ;
  assign tx_phy_preflop_3 [  45] = 1'b0                       ;
  assign tx_phy_preflop_3 [  46] = 1'b0                       ;
  assign tx_phy_preflop_3 [  47] = 1'b0                       ;
  assign tx_phy_preflop_3 [  48] = 1'b0                       ;
  assign tx_phy_preflop_3 [  49] = 1'b0                       ;
  assign tx_phy_preflop_3 [  50] = 1'b0                       ;
  assign tx_phy_preflop_3 [  51] = 1'b0                       ;
  assign tx_phy_preflop_3 [  52] = 1'b0                       ;
  assign tx_phy_preflop_3 [  53] = 1'b0                       ;
  assign tx_phy_preflop_3 [  54] = 1'b0                       ;
  assign tx_phy_preflop_3 [  55] = 1'b0                       ;
  assign tx_phy_preflop_3 [  56] = 1'b0                       ;
  assign tx_phy_preflop_3 [  57] = 1'b0                       ;
  assign tx_phy_preflop_3 [  58] = 1'b0                       ;
  assign tx_phy_preflop_3 [  59] = 1'b0                       ;
  assign tx_phy_preflop_3 [  60] = 1'b0                       ;
  assign tx_phy_preflop_3 [  61] = 1'b0                       ;
  assign tx_phy_preflop_3 [  62] = 1'b0                       ;
  assign tx_phy_preflop_3 [  63] = 1'b0                       ;
  assign tx_phy_preflop_3 [  64] = 1'b0                       ;
  assign tx_phy_preflop_3 [  65] = 1'b0                       ;
  assign tx_phy_preflop_3 [  66] = 1'b0                       ;
  assign tx_phy_preflop_3 [  67] = 1'b0                       ;
  assign tx_phy_preflop_3 [  68] = 1'b0                       ;
  assign tx_phy_preflop_3 [  69] = 1'b0                       ;
  assign tx_phy_preflop_3 [  70] = 1'b0                       ;
  assign tx_phy_preflop_3 [  71] = 1'b0                       ;
  assign tx_phy_preflop_3 [  72] = 1'b0                       ;
  assign tx_phy_preflop_3 [  73] = 1'b0                       ;
  assign tx_phy_preflop_3 [  74] = 1'b0                       ;
  assign tx_phy_preflop_3 [  75] = 1'b0                       ;
  assign tx_phy_preflop_3 [  76] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_3 [  77] = 1'b0                       ;
  assign tx_phy_preflop_3 [  78] = 1'b0                       ; // DBI
  assign tx_phy_preflop_3 [  79] = 1'b0                       ; // DBI
// TX Section
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// RX Section

//   RX_CH_WIDTH           = 80; // Gen2Only running at Full Rate
//   RX_DATA_WIDTH         = 74; // Usable Data per Channel
//   RX_PERSISTENT_STROBE  = 1'b1;
//   RX_PERSISTENT_MARKER  = 1'b1;
//   RX_STROBE_GEN2_LOC    = 'd76;
//   RX_MARKER_GEN2_LOC    = 'd4;
//   RX_STROBE_GEN1_LOC    = 'd38;
//   RX_MARKER_GEN1_LOC    = 'd39;
//   RX_ENABLE_STROBE      = 1'b1;
//   RX_ENABLE_MARKER      = 1'b1;
//   RX_DBI_PRESENT        = 1'b1;
//   RX_REG_PHY            = 1'b0;

  localparam RX_REG_PHY    = 1'b0;  // If set, this enables boundary FF for timing reasons

  logic [  79:   0]                              rx_phy_postflop_0             ;
  logic [  79:   0]                              rx_phy_postflop_1             ;
  logic [  79:   0]                              rx_phy_postflop_2             ;
  logic [  79:   0]                              rx_phy_postflop_3             ;
  logic [  79:   0]                              rx_phy_flop_0_reg             ;
  logic [  79:   0]                              rx_phy_flop_1_reg             ;
  logic [  79:   0]                              rx_phy_flop_2_reg             ;
  logic [  79:   0]                              rx_phy_flop_3_reg             ;

  always_ff @(posedge clk_rd or negedge rst_rd_n)
  if (~rst_rd_n)
  begin
    rx_phy_flop_0_reg                       <= 80'b0                                   ;
    rx_phy_flop_1_reg                       <= 80'b0                                   ;
    rx_phy_flop_2_reg                       <= 80'b0                                   ;
    rx_phy_flop_3_reg                       <= 80'b0                                   ;
  end
  else
  begin
    rx_phy_flop_0_reg                       <= rx_phy0                                 ;
    rx_phy_flop_1_reg                       <= rx_phy1                                 ;
    rx_phy_flop_2_reg                       <= rx_phy2                                 ;
    rx_phy_flop_3_reg                       <= rx_phy3                                 ;
  end


  assign rx_phy_postflop_0                  = RX_REG_PHY ? rx_phy_flop_0_reg : rx_phy0               ;
  assign rx_phy_postflop_1                  = RX_REG_PHY ? rx_phy_flop_1_reg : rx_phy1               ;
  assign rx_phy_postflop_2                  = RX_REG_PHY ? rx_phy_flop_2_reg : rx_phy2               ;
  assign rx_phy_postflop_3                  = RX_REG_PHY ? rx_phy_flop_3_reg : rx_phy3               ;

  assign rx_ar_pushbit              = rx_phy_postflop_0 [   0];
  assign rx_ar_data          [   0] = rx_phy_postflop_0 [   1];
  assign rx_ar_data          [   1] = rx_phy_postflop_0 [   2];
  assign rx_ar_data          [   2] = rx_phy_postflop_0 [   3];
//       MARKER                     = rx_phy_postflop_0 [   4]
  assign rx_ar_data          [   3] = rx_phy_postflop_0 [   5];
  assign rx_ar_data          [   4] = rx_phy_postflop_0 [   6];
  assign rx_ar_data          [   5] = rx_phy_postflop_0 [   7];
  assign rx_ar_data          [   6] = rx_phy_postflop_0 [   8];
  assign rx_ar_data          [   7] = rx_phy_postflop_0 [   9];
  assign rx_ar_data          [   8] = rx_phy_postflop_0 [  10];
  assign rx_ar_data          [   9] = rx_phy_postflop_0 [  11];
  assign rx_ar_data          [  10] = rx_phy_postflop_0 [  12];
  assign rx_ar_data          [  11] = rx_phy_postflop_0 [  13];
  assign rx_ar_data          [  12] = rx_phy_postflop_0 [  14];
  assign rx_ar_data          [  13] = rx_phy_postflop_0 [  15];
  assign rx_ar_data          [  14] = rx_phy_postflop_0 [  16];
  assign rx_ar_data          [  15] = rx_phy_postflop_0 [  17];
  assign rx_ar_data          [  16] = rx_phy_postflop_0 [  18];
  assign rx_ar_data          [  17] = rx_phy_postflop_0 [  19];
  assign rx_ar_data          [  18] = rx_phy_postflop_0 [  20];
  assign rx_ar_data          [  19] = rx_phy_postflop_0 [  21];
  assign rx_ar_data          [  20] = rx_phy_postflop_0 [  22];
  assign rx_ar_data          [  21] = rx_phy_postflop_0 [  23];
  assign rx_ar_data          [  22] = rx_phy_postflop_0 [  24];
  assign rx_ar_data          [  23] = rx_phy_postflop_0 [  25];
  assign rx_ar_data          [  24] = rx_phy_postflop_0 [  26];
  assign rx_ar_data          [  25] = rx_phy_postflop_0 [  27];
  assign rx_ar_data          [  26] = rx_phy_postflop_0 [  28];
  assign rx_ar_data          [  27] = rx_phy_postflop_0 [  29];
  assign rx_ar_data          [  28] = rx_phy_postflop_0 [  30];
  assign rx_ar_data          [  29] = rx_phy_postflop_0 [  31];
  assign rx_ar_data          [  30] = rx_phy_postflop_0 [  32];
  assign rx_ar_data          [  31] = rx_phy_postflop_0 [  33];
  assign rx_ar_data          [  32] = rx_phy_postflop_0 [  34];
  assign rx_ar_data          [  33] = rx_phy_postflop_0 [  35];
  assign rx_ar_data          [  34] = rx_phy_postflop_0 [  36];
  assign rx_ar_data          [  35] = rx_phy_postflop_0 [  37];
//       DBI                        = rx_phy_postflop_0 [  38];
//       DBI                        = rx_phy_postflop_0 [  39];
  assign rx_ar_data          [  36] = rx_phy_postflop_0 [  40];
  assign rx_ar_data          [  37] = rx_phy_postflop_0 [  41];
  assign rx_ar_data          [  38] = rx_phy_postflop_0 [  42];
  assign rx_ar_data          [  39] = rx_phy_postflop_0 [  43];
  assign rx_ar_data          [  40] = rx_phy_postflop_0 [  44];
  assign rx_ar_data          [  41] = rx_phy_postflop_0 [  45];
  assign rx_ar_data          [  42] = rx_phy_postflop_0 [  46];
  assign rx_ar_data          [  43] = rx_phy_postflop_0 [  47];
  assign rx_ar_data          [  44] = rx_phy_postflop_0 [  48];
  assign rx_ar_data          [  45] = rx_phy_postflop_0 [  49];
  assign rx_ar_data          [  46] = rx_phy_postflop_0 [  50];
  assign rx_ar_data          [  47] = rx_phy_postflop_0 [  51];
  assign rx_ar_data          [  48] = rx_phy_postflop_0 [  52];
  assign rx_aw_pushbit              = rx_phy_postflop_0 [  53];
  assign rx_aw_data          [   0] = rx_phy_postflop_0 [  54];
  assign rx_aw_data          [   1] = rx_phy_postflop_0 [  55];
  assign rx_aw_data          [   2] = rx_phy_postflop_0 [  56];
  assign rx_aw_data          [   3] = rx_phy_postflop_0 [  57];
  assign rx_aw_data          [   4] = rx_phy_postflop_0 [  58];
  assign rx_aw_data          [   5] = rx_phy_postflop_0 [  59];
  assign rx_aw_data          [   6] = rx_phy_postflop_0 [  60];
  assign rx_aw_data          [   7] = rx_phy_postflop_0 [  61];
  assign rx_aw_data          [   8] = rx_phy_postflop_0 [  62];
  assign rx_aw_data          [   9] = rx_phy_postflop_0 [  63];
  assign rx_aw_data          [  10] = rx_phy_postflop_0 [  64];
  assign rx_aw_data          [  11] = rx_phy_postflop_0 [  65];
  assign rx_aw_data          [  12] = rx_phy_postflop_0 [  66];
  assign rx_aw_data          [  13] = rx_phy_postflop_0 [  67];
  assign rx_aw_data          [  14] = rx_phy_postflop_0 [  68];
  assign rx_aw_data          [  15] = rx_phy_postflop_0 [  69];
  assign rx_aw_data          [  16] = rx_phy_postflop_0 [  70];
  assign rx_aw_data          [  17] = rx_phy_postflop_0 [  71];
  assign rx_aw_data          [  18] = rx_phy_postflop_0 [  72];
  assign rx_aw_data          [  19] = rx_phy_postflop_0 [  73];
  assign rx_aw_data          [  20] = rx_phy_postflop_0 [  74];
  assign rx_aw_data          [  21] = rx_phy_postflop_0 [  75];
//       STROBE                     = rx_phy_postflop_0 [  76]
  assign rx_aw_data          [  22] = rx_phy_postflop_0 [  77];
//       DBI                        = rx_phy_postflop_0 [  78];
//       DBI                        = rx_phy_postflop_0 [  79];
  assign rx_aw_data          [  23] = rx_phy_postflop_1 [   0];
  assign rx_aw_data          [  24] = rx_phy_postflop_1 [   1];
  assign rx_aw_data          [  25] = rx_phy_postflop_1 [   2];
  assign rx_aw_data          [  26] = rx_phy_postflop_1 [   3];
//       MARKER                     = rx_phy_postflop_1 [   4]
  assign rx_aw_data          [  27] = rx_phy_postflop_1 [   5];
  assign rx_aw_data          [  28] = rx_phy_postflop_1 [   6];
  assign rx_aw_data          [  29] = rx_phy_postflop_1 [   7];
  assign rx_aw_data          [  30] = rx_phy_postflop_1 [   8];
  assign rx_aw_data          [  31] = rx_phy_postflop_1 [   9];
  assign rx_aw_data          [  32] = rx_phy_postflop_1 [  10];
  assign rx_aw_data          [  33] = rx_phy_postflop_1 [  11];
  assign rx_aw_data          [  34] = rx_phy_postflop_1 [  12];
  assign rx_aw_data          [  35] = rx_phy_postflop_1 [  13];
  assign rx_aw_data          [  36] = rx_phy_postflop_1 [  14];
  assign rx_aw_data          [  37] = rx_phy_postflop_1 [  15];
  assign rx_aw_data          [  38] = rx_phy_postflop_1 [  16];
  assign rx_aw_data          [  39] = rx_phy_postflop_1 [  17];
  assign rx_aw_data          [  40] = rx_phy_postflop_1 [  18];
  assign rx_aw_data          [  41] = rx_phy_postflop_1 [  19];
  assign rx_aw_data          [  42] = rx_phy_postflop_1 [  20];
  assign rx_aw_data          [  43] = rx_phy_postflop_1 [  21];
  assign rx_aw_data          [  44] = rx_phy_postflop_1 [  22];
  assign rx_aw_data          [  45] = rx_phy_postflop_1 [  23];
  assign rx_aw_data          [  46] = rx_phy_postflop_1 [  24];
  assign rx_aw_data          [  47] = rx_phy_postflop_1 [  25];
  assign rx_aw_data          [  48] = rx_phy_postflop_1 [  26];
  assign rx_w_pushbit               = rx_phy_postflop_1 [  27];
  assign rx_w_data           [   0] = rx_phy_postflop_1 [  28];
  assign rx_w_data           [   1] = rx_phy_postflop_1 [  29];
  assign rx_w_data           [   2] = rx_phy_postflop_1 [  30];
  assign rx_w_data           [   3] = rx_phy_postflop_1 [  31];
  assign rx_w_data           [   4] = rx_phy_postflop_1 [  32];
  assign rx_w_data           [   5] = rx_phy_postflop_1 [  33];
  assign rx_w_data           [   6] = rx_phy_postflop_1 [  34];
  assign rx_w_data           [   7] = rx_phy_postflop_1 [  35];
  assign rx_w_data           [   8] = rx_phy_postflop_1 [  36];
  assign rx_w_data           [   9] = rx_phy_postflop_1 [  37];
//       DBI                        = rx_phy_postflop_1 [  38];
//       DBI                        = rx_phy_postflop_1 [  39];
  assign rx_w_data           [  10] = rx_phy_postflop_1 [  40];
  assign rx_w_data           [  11] = rx_phy_postflop_1 [  41];
  assign rx_w_data           [  12] = rx_phy_postflop_1 [  42];
  assign rx_w_data           [  13] = rx_phy_postflop_1 [  43];
  assign rx_w_data           [  14] = rx_phy_postflop_1 [  44];
  assign rx_w_data           [  15] = rx_phy_postflop_1 [  45];
  assign rx_w_data           [  16] = rx_phy_postflop_1 [  46];
  assign rx_w_data           [  17] = rx_phy_postflop_1 [  47];
  assign rx_w_data           [  18] = rx_phy_postflop_1 [  48];
  assign rx_w_data           [  19] = rx_phy_postflop_1 [  49];
  assign rx_w_data           [  20] = rx_phy_postflop_1 [  50];
  assign rx_w_data           [  21] = rx_phy_postflop_1 [  51];
  assign rx_w_data           [  22] = rx_phy_postflop_1 [  52];
  assign rx_w_data           [  23] = rx_phy_postflop_1 [  53];
  assign rx_w_data           [  24] = rx_phy_postflop_1 [  54];
  assign rx_w_data           [  25] = rx_phy_postflop_1 [  55];
  assign rx_w_data           [  26] = rx_phy_postflop_1 [  56];
  assign rx_w_data           [  27] = rx_phy_postflop_1 [  57];
  assign rx_w_data           [  28] = rx_phy_postflop_1 [  58];
  assign rx_w_data           [  29] = rx_phy_postflop_1 [  59];
  assign rx_w_data           [  30] = rx_phy_postflop_1 [  60];
  assign rx_w_data           [  31] = rx_phy_postflop_1 [  61];
  assign rx_w_data           [  32] = rx_phy_postflop_1 [  62];
  assign rx_w_data           [  33] = rx_phy_postflop_1 [  63];
  assign rx_w_data           [  34] = rx_phy_postflop_1 [  64];
  assign rx_w_data           [  35] = rx_phy_postflop_1 [  65];
  assign rx_w_data           [  36] = rx_phy_postflop_1 [  66];
  assign rx_w_data           [  37] = rx_phy_postflop_1 [  67];
  assign rx_w_data           [  38] = rx_phy_postflop_1 [  68];
  assign rx_w_data           [  39] = rx_phy_postflop_1 [  69];
  assign rx_w_data           [  40] = rx_phy_postflop_1 [  70];
  assign rx_w_data           [  41] = rx_phy_postflop_1 [  71];
  assign rx_w_data           [  42] = rx_phy_postflop_1 [  72];
  assign rx_w_data           [  43] = rx_phy_postflop_1 [  73];
  assign rx_w_data           [  44] = rx_phy_postflop_1 [  74];
  assign rx_w_data           [  45] = rx_phy_postflop_1 [  75];
//       STROBE                     = rx_phy_postflop_1 [  76]
  assign rx_w_data           [  46] = rx_phy_postflop_1 [  77];
//       DBI                        = rx_phy_postflop_1 [  78];
//       DBI                        = rx_phy_postflop_1 [  79];
  assign rx_w_data           [  47] = rx_phy_postflop_2 [   0];
  assign rx_w_data           [  48] = rx_phy_postflop_2 [   1];
  assign rx_w_data           [  49] = rx_phy_postflop_2 [   2];
  assign rx_w_data           [  50] = rx_phy_postflop_2 [   3];
//       MARKER                     = rx_phy_postflop_2 [   4]
  assign rx_w_data           [  51] = rx_phy_postflop_2 [   5];
  assign rx_w_data           [  52] = rx_phy_postflop_2 [   6];
  assign rx_w_data           [  53] = rx_phy_postflop_2 [   7];
  assign rx_w_data           [  54] = rx_phy_postflop_2 [   8];
  assign rx_w_data           [  55] = rx_phy_postflop_2 [   9];
  assign rx_w_data           [  56] = rx_phy_postflop_2 [  10];
  assign rx_w_data           [  57] = rx_phy_postflop_2 [  11];
  assign rx_w_data           [  58] = rx_phy_postflop_2 [  12];
  assign rx_w_data           [  59] = rx_phy_postflop_2 [  13];
  assign rx_w_data           [  60] = rx_phy_postflop_2 [  14];
  assign rx_w_data           [  61] = rx_phy_postflop_2 [  15];
  assign rx_w_data           [  62] = rx_phy_postflop_2 [  16];
  assign rx_w_data           [  63] = rx_phy_postflop_2 [  17];
  assign rx_w_data           [  64] = rx_phy_postflop_2 [  18];
  assign rx_w_data           [  65] = rx_phy_postflop_2 [  19];
  assign rx_w_data           [  66] = rx_phy_postflop_2 [  20];
  assign rx_w_data           [  67] = rx_phy_postflop_2 [  21];
  assign rx_w_data           [  68] = rx_phy_postflop_2 [  22];
  assign rx_w_data           [  69] = rx_phy_postflop_2 [  23];
  assign rx_w_data           [  70] = rx_phy_postflop_2 [  24];
  assign rx_w_data           [  71] = rx_phy_postflop_2 [  25];
  assign rx_w_data           [  72] = rx_phy_postflop_2 [  26];
  assign rx_w_data           [  73] = rx_phy_postflop_2 [  27];
  assign rx_w_data           [  74] = rx_phy_postflop_2 [  28];
  assign rx_w_data           [  75] = rx_phy_postflop_2 [  29];
  assign rx_w_data           [  76] = rx_phy_postflop_2 [  30];
  assign rx_w_data           [  77] = rx_phy_postflop_2 [  31];
  assign rx_w_data           [  78] = rx_phy_postflop_2 [  32];
  assign rx_w_data           [  79] = rx_phy_postflop_2 [  33];
  assign rx_w_data           [  80] = rx_phy_postflop_2 [  34];
  assign rx_w_data           [  81] = rx_phy_postflop_2 [  35];
  assign rx_w_data           [  82] = rx_phy_postflop_2 [  36];
  assign rx_w_data           [  83] = rx_phy_postflop_2 [  37];
//       DBI                        = rx_phy_postflop_2 [  38];
//       DBI                        = rx_phy_postflop_2 [  39];
  assign rx_w_data           [  84] = rx_phy_postflop_2 [  40];
  assign rx_w_data           [  85] = rx_phy_postflop_2 [  41];
  assign rx_w_data           [  86] = rx_phy_postflop_2 [  42];
  assign rx_w_data           [  87] = rx_phy_postflop_2 [  43];
  assign rx_w_data           [  88] = rx_phy_postflop_2 [  44];
  assign rx_w_data           [  89] = rx_phy_postflop_2 [  45];
  assign rx_w_data           [  90] = rx_phy_postflop_2 [  46];
  assign rx_w_data           [  91] = rx_phy_postflop_2 [  47];
  assign rx_w_data           [  92] = rx_phy_postflop_2 [  48];
  assign rx_w_data           [  93] = rx_phy_postflop_2 [  49];
  assign rx_w_data           [  94] = rx_phy_postflop_2 [  50];
  assign rx_w_data           [  95] = rx_phy_postflop_2 [  51];
  assign rx_w_data           [  96] = rx_phy_postflop_2 [  52];
  assign rx_w_data           [  97] = rx_phy_postflop_2 [  53];
  assign rx_w_data           [  98] = rx_phy_postflop_2 [  54];
  assign rx_w_data           [  99] = rx_phy_postflop_2 [  55];
  assign rx_w_data           [ 100] = rx_phy_postflop_2 [  56];
  assign rx_w_data           [ 101] = rx_phy_postflop_2 [  57];
  assign rx_w_data           [ 102] = rx_phy_postflop_2 [  58];
  assign rx_w_data           [ 103] = rx_phy_postflop_2 [  59];
  assign rx_w_data           [ 104] = rx_phy_postflop_2 [  60];
  assign rx_w_data           [ 105] = rx_phy_postflop_2 [  61];
  assign rx_w_data           [ 106] = rx_phy_postflop_2 [  62];
  assign rx_w_data           [ 107] = rx_phy_postflop_2 [  63];
  assign rx_w_data           [ 108] = rx_phy_postflop_2 [  64];
  assign rx_w_data           [ 109] = rx_phy_postflop_2 [  65];
  assign rx_w_data           [ 110] = rx_phy_postflop_2 [  66];
  assign rx_w_data           [ 111] = rx_phy_postflop_2 [  67];
  assign rx_w_data           [ 112] = rx_phy_postflop_2 [  68];
  assign rx_w_data           [ 113] = rx_phy_postflop_2 [  69];
  assign rx_w_data           [ 114] = rx_phy_postflop_2 [  70];
  assign rx_w_data           [ 115] = rx_phy_postflop_2 [  71];
  assign rx_w_data           [ 116] = rx_phy_postflop_2 [  72];
  assign rx_w_data           [ 117] = rx_phy_postflop_2 [  73];
  assign rx_w_data           [ 118] = rx_phy_postflop_2 [  74];
  assign rx_w_data           [ 119] = rx_phy_postflop_2 [  75];
//       STROBE                     = rx_phy_postflop_2 [  76]
  assign rx_w_data           [ 120] = rx_phy_postflop_2 [  77];
//       DBI                        = rx_phy_postflop_2 [  78];
//       DBI                        = rx_phy_postflop_2 [  79];
  assign rx_w_data           [ 121] = rx_phy_postflop_3 [   0];
  assign rx_w_data           [ 122] = rx_phy_postflop_3 [   1];
  assign rx_w_data           [ 123] = rx_phy_postflop_3 [   2];
  assign rx_w_data           [ 124] = rx_phy_postflop_3 [   3];
//       MARKER                     = rx_phy_postflop_3 [   4]
  assign rx_w_data           [ 125] = rx_phy_postflop_3 [   5];
  assign rx_w_data           [ 126] = rx_phy_postflop_3 [   6];
  assign rx_w_data           [ 127] = rx_phy_postflop_3 [   7];
  assign rx_w_data           [ 128] = rx_phy_postflop_3 [   8];
  assign rx_w_data           [ 129] = rx_phy_postflop_3 [   9];
  assign rx_w_data           [ 130] = rx_phy_postflop_3 [  10];
  assign rx_w_data           [ 131] = rx_phy_postflop_3 [  11];
  assign rx_w_data           [ 132] = rx_phy_postflop_3 [  12];
  assign rx_w_data           [ 133] = rx_phy_postflop_3 [  13];
  assign rx_w_data           [ 134] = rx_phy_postflop_3 [  14];
  assign rx_w_data           [ 135] = rx_phy_postflop_3 [  15];
  assign rx_w_data           [ 136] = rx_phy_postflop_3 [  16];
  assign rx_w_data           [ 137] = rx_phy_postflop_3 [  17];
  assign rx_w_data           [ 138] = rx_phy_postflop_3 [  18];
  assign rx_w_data           [ 139] = rx_phy_postflop_3 [  19];
  assign rx_w_data           [ 140] = rx_phy_postflop_3 [  20];
  assign rx_w_data           [ 141] = rx_phy_postflop_3 [  21];
  assign rx_w_data           [ 142] = rx_phy_postflop_3 [  22];
  assign rx_w_data           [ 143] = rx_phy_postflop_3 [  23];
  assign rx_w_data           [ 144] = rx_phy_postflop_3 [  24];
  assign rx_w_data           [ 145] = rx_phy_postflop_3 [  25];
  assign rx_w_data           [ 146] = rx_phy_postflop_3 [  26];
  assign rx_w_data           [ 147] = rx_phy_postflop_3 [  27];
  assign rx_w_data           [ 148] = rx_phy_postflop_3 [  28];
  assign rx_r_credit                = rx_phy_postflop_3 [  29];
  assign rx_b_credit                = rx_phy_postflop_3 [  30];
//       nc                         = rx_phy_postflop_3 [  31];
//       nc                         = rx_phy_postflop_3 [  32];
//       nc                         = rx_phy_postflop_3 [  33];
//       nc                         = rx_phy_postflop_3 [  34];
//       nc                         = rx_phy_postflop_3 [  35];
//       nc                         = rx_phy_postflop_3 [  36];
//       nc                         = rx_phy_postflop_3 [  37];
//       DBI                        = rx_phy_postflop_3 [  38];
//       DBI                        = rx_phy_postflop_3 [  39];
//       nc                         = rx_phy_postflop_3 [  40];
//       nc                         = rx_phy_postflop_3 [  41];
//       nc                         = rx_phy_postflop_3 [  42];
//       nc                         = rx_phy_postflop_3 [  43];
//       nc                         = rx_phy_postflop_3 [  44];
//       nc                         = rx_phy_postflop_3 [  45];
//       nc                         = rx_phy_postflop_3 [  46];
//       nc                         = rx_phy_postflop_3 [  47];
//       nc                         = rx_phy_postflop_3 [  48];
//       nc                         = rx_phy_postflop_3 [  49];
//       nc                         = rx_phy_postflop_3 [  50];
//       nc                         = rx_phy_postflop_3 [  51];
//       nc                         = rx_phy_postflop_3 [  52];
//       nc                         = rx_phy_postflop_3 [  53];
//       nc                         = rx_phy_postflop_3 [  54];
//       nc                         = rx_phy_postflop_3 [  55];
//       nc                         = rx_phy_postflop_3 [  56];
//       nc                         = rx_phy_postflop_3 [  57];
//       nc                         = rx_phy_postflop_3 [  58];
//       nc                         = rx_phy_postflop_3 [  59];
//       nc                         = rx_phy_postflop_3 [  60];
//       nc                         = rx_phy_postflop_3 [  61];
//       nc                         = rx_phy_postflop_3 [  62];
//       nc                         = rx_phy_postflop_3 [  63];
//       nc                         = rx_phy_postflop_3 [  64];
//       nc                         = rx_phy_postflop_3 [  65];
//       nc                         = rx_phy_postflop_3 [  66];
//       nc                         = rx_phy_postflop_3 [  67];
//       nc                         = rx_phy_postflop_3 [  68];
//       nc                         = rx_phy_postflop_3 [  69];
//       nc                         = rx_phy_postflop_3 [  70];
//       nc                         = rx_phy_postflop_3 [  71];
//       nc                         = rx_phy_postflop_3 [  72];
//       nc                         = rx_phy_postflop_3 [  73];
//       nc                         = rx_phy_postflop_3 [  74];
//       nc                         = rx_phy_postflop_3 [  75];
//       STROBE                     = rx_phy_postflop_3 [  76]
//       nc                         = rx_phy_postflop_3 [  77];
//       DBI                        = rx_phy_postflop_3 [  78];
//       DBI                        = rx_phy_postflop_3 [  79];

// RX Section
//////////////////////////////////////////////////////////////////


endmodule
