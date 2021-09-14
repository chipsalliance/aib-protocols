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
////////////////////////////////////////////////////////////

module axi_st_d128_asym_half_master_concat  (

// Data from Logic Links
  input  logic [ 289:   0]   tx_st_data          ,
  output logic               tx_st_pop_ovrd      ,
  input  logic               tx_st_pushbit       ,
  output logic [   3:   0]   rx_st_credit        ,

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
  assign tx_st_pop_ovrd                     = 1'b0                               ;

// No RX Packetization, so tie off packetization signals

//////////////////////////////////////////////////////////////////
// TX Section

//   TX_CH_WIDTH           = 160; // Gen2Only running at Half Rate
//   TX_DATA_WIDTH         = 148; // Usable Data per Channel
//   TX_PERSISTENT_STROBE  = 1'b1;
//   TX_PERSISTENT_MARKER  = 1'b1;
//   TX_STROBE_GEN2_LOC    = 'd1;
//   TX_MARKER_GEN2_LOC    = 'd0;
//   TX_STROBE_GEN1_LOC    = 'd1;
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

  logic                                          tx_st_pushbit_r0              ;
  logic                                          tx_st_pushbit_r1              ;

  assign tx_st_pushbit_r0                   = tx_st_pushbit                      ;
  assign tx_st_pushbit_r1                   = tx_st_pushbit                      ;

  assign tx_phy_preflop_0 [   0] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_0 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_0 [   2] = tx_st_pushbit_r0           ;
  assign tx_phy_preflop_0 [   3] = tx_st_data          [   0] ;
  assign tx_phy_preflop_0 [   4] = tx_st_data          [   1] ;
  assign tx_phy_preflop_0 [   5] = tx_st_data          [   2] ;
  assign tx_phy_preflop_0 [   6] = tx_st_data          [   3] ;
  assign tx_phy_preflop_0 [   7] = tx_st_data          [   4] ;
  assign tx_phy_preflop_0 [   8] = tx_st_data          [   5] ;
  assign tx_phy_preflop_0 [   9] = tx_st_data          [   6] ;
  assign tx_phy_preflop_0 [  10] = tx_st_data          [   7] ;
  assign tx_phy_preflop_0 [  11] = tx_st_data          [   8] ;
  assign tx_phy_preflop_0 [  12] = tx_st_data          [   9] ;
  assign tx_phy_preflop_0 [  13] = tx_st_data          [  10] ;
  assign tx_phy_preflop_0 [  14] = tx_st_data          [  11] ;
  assign tx_phy_preflop_0 [  15] = tx_st_data          [  12] ;
  assign tx_phy_preflop_0 [  16] = tx_st_data          [  13] ;
  assign tx_phy_preflop_0 [  17] = tx_st_data          [  14] ;
  assign tx_phy_preflop_0 [  18] = tx_st_data          [  15] ;
  assign tx_phy_preflop_0 [  19] = tx_st_data          [  16] ;
  assign tx_phy_preflop_0 [  20] = tx_st_data          [  17] ;
  assign tx_phy_preflop_0 [  21] = tx_st_data          [  18] ;
  assign tx_phy_preflop_0 [  22] = tx_st_data          [  19] ;
  assign tx_phy_preflop_0 [  23] = tx_st_data          [  20] ;
  assign tx_phy_preflop_0 [  24] = tx_st_data          [  21] ;
  assign tx_phy_preflop_0 [  25] = tx_st_data          [  22] ;
  assign tx_phy_preflop_0 [  26] = tx_st_data          [  23] ;
  assign tx_phy_preflop_0 [  27] = tx_st_data          [  24] ;
  assign tx_phy_preflop_0 [  28] = tx_st_data          [  25] ;
  assign tx_phy_preflop_0 [  29] = tx_st_data          [  26] ;
  assign tx_phy_preflop_0 [  30] = tx_st_data          [  27] ;
  assign tx_phy_preflop_0 [  31] = tx_st_data          [  28] ;
  assign tx_phy_preflop_0 [  32] = tx_st_data          [  29] ;
  assign tx_phy_preflop_0 [  33] = tx_st_data          [  30] ;
  assign tx_phy_preflop_0 [  34] = tx_st_data          [  31] ;
  assign tx_phy_preflop_0 [  35] = tx_st_data          [  32] ;
  assign tx_phy_preflop_0 [  36] = tx_st_data          [  33] ;
  assign tx_phy_preflop_0 [  37] = tx_st_data          [  34] ;
  assign tx_phy_preflop_0 [  38] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [  39] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [  40] = tx_st_data          [  35] ;
  assign tx_phy_preflop_0 [  41] = tx_st_data          [  36] ;
  assign tx_phy_preflop_0 [  42] = tx_st_data          [  37] ;
  assign tx_phy_preflop_0 [  43] = tx_st_data          [  38] ;
  assign tx_phy_preflop_0 [  44] = tx_st_data          [  39] ;
  assign tx_phy_preflop_0 [  45] = tx_st_data          [  40] ;
  assign tx_phy_preflop_0 [  46] = tx_st_data          [  41] ;
  assign tx_phy_preflop_0 [  47] = tx_st_data          [  42] ;
  assign tx_phy_preflop_0 [  48] = tx_st_data          [  43] ;
  assign tx_phy_preflop_0 [  49] = tx_st_data          [  44] ;
  assign tx_phy_preflop_0 [  50] = tx_st_data          [  45] ;
  assign tx_phy_preflop_0 [  51] = tx_st_data          [  46] ;
  assign tx_phy_preflop_0 [  52] = tx_st_data          [  47] ;
  assign tx_phy_preflop_0 [  53] = tx_st_data          [  48] ;
  assign tx_phy_preflop_0 [  54] = tx_st_data          [  49] ;
  assign tx_phy_preflop_0 [  55] = tx_st_data          [  50] ;
  assign tx_phy_preflop_0 [  56] = tx_st_data          [  51] ;
  assign tx_phy_preflop_0 [  57] = tx_st_data          [  52] ;
  assign tx_phy_preflop_0 [  58] = tx_st_data          [  53] ;
  assign tx_phy_preflop_0 [  59] = tx_st_data          [  54] ;
  assign tx_phy_preflop_0 [  60] = tx_st_data          [  55] ;
  assign tx_phy_preflop_0 [  61] = tx_st_data          [  56] ;
  assign tx_phy_preflop_0 [  62] = tx_st_data          [  57] ;
  assign tx_phy_preflop_0 [  63] = tx_st_data          [  58] ;
  assign tx_phy_preflop_0 [  64] = tx_st_data          [  59] ;
  assign tx_phy_preflop_0 [  65] = tx_st_data          [  60] ;
  assign tx_phy_preflop_0 [  66] = tx_st_data          [  61] ;
  assign tx_phy_preflop_0 [  67] = tx_st_data          [  62] ;
  assign tx_phy_preflop_0 [  68] = tx_st_data          [  63] ;
  assign tx_phy_preflop_0 [  69] = tx_st_data          [  64] ;
  assign tx_phy_preflop_0 [  70] = tx_st_data          [  65] ;
  assign tx_phy_preflop_0 [  71] = tx_st_data          [  66] ;
  assign tx_phy_preflop_0 [  72] = tx_st_data          [  67] ;
  assign tx_phy_preflop_0 [  73] = tx_st_data          [  68] ;
  assign tx_phy_preflop_0 [  74] = tx_st_data          [  69] ;
  assign tx_phy_preflop_0 [  75] = tx_st_data          [  70] ;
  assign tx_phy_preflop_0 [  76] = tx_st_data          [  71] ;
  assign tx_phy_preflop_0 [  77] = tx_st_data          [  72] ;
  assign tx_phy_preflop_0 [  78] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [  79] = 1'b0                       ; // DBI
  assign tx_phy_preflop_1 [   0] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_1 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_1 [   2] = tx_st_data          [  73] ;
  assign tx_phy_preflop_1 [   3] = tx_st_data          [  74] ;
  assign tx_phy_preflop_1 [   4] = tx_st_data          [  75] ;
  assign tx_phy_preflop_1 [   5] = tx_st_data          [  76] ;
  assign tx_phy_preflop_1 [   6] = tx_st_data          [  77] ;
  assign tx_phy_preflop_1 [   7] = tx_st_data          [  78] ;
  assign tx_phy_preflop_1 [   8] = tx_st_data          [  79] ;
  assign tx_phy_preflop_1 [   9] = tx_st_data          [  80] ;
  assign tx_phy_preflop_1 [  10] = tx_st_data          [  81] ;
  assign tx_phy_preflop_1 [  11] = tx_st_data          [  82] ;
  assign tx_phy_preflop_1 [  12] = tx_st_data          [  83] ;
  assign tx_phy_preflop_1 [  13] = tx_st_data          [  84] ;
  assign tx_phy_preflop_1 [  14] = tx_st_data          [  85] ;
  assign tx_phy_preflop_1 [  15] = tx_st_data          [  86] ;
  assign tx_phy_preflop_1 [  16] = tx_st_data          [  87] ;
  assign tx_phy_preflop_1 [  17] = tx_st_data          [  88] ;
  assign tx_phy_preflop_1 [  18] = tx_st_data          [  89] ;
  assign tx_phy_preflop_1 [  19] = tx_st_data          [  90] ;
  assign tx_phy_preflop_1 [  20] = tx_st_data          [  91] ;
  assign tx_phy_preflop_1 [  21] = tx_st_data          [  92] ;
  assign tx_phy_preflop_1 [  22] = tx_st_data          [  93] ;
  assign tx_phy_preflop_1 [  23] = tx_st_data          [  94] ;
  assign tx_phy_preflop_1 [  24] = tx_st_data          [  95] ;
  assign tx_phy_preflop_1 [  25] = tx_st_data          [  96] ;
  assign tx_phy_preflop_1 [  26] = tx_st_data          [  97] ;
  assign tx_phy_preflop_1 [  27] = tx_st_data          [  98] ;
  assign tx_phy_preflop_1 [  28] = tx_st_data          [  99] ;
  assign tx_phy_preflop_1 [  29] = tx_st_data          [ 100] ;
  assign tx_phy_preflop_1 [  30] = tx_st_data          [ 101] ;
  assign tx_phy_preflop_1 [  31] = tx_st_data          [ 102] ;
  assign tx_phy_preflop_1 [  32] = tx_st_data          [ 103] ;
  assign tx_phy_preflop_1 [  33] = tx_st_data          [ 104] ;
  assign tx_phy_preflop_1 [  34] = tx_st_data          [ 105] ;
  assign tx_phy_preflop_1 [  35] = tx_st_data          [ 106] ;
  assign tx_phy_preflop_1 [  36] = tx_st_data          [ 107] ;
  assign tx_phy_preflop_1 [  37] = tx_st_data          [ 108] ;
  assign tx_phy_preflop_1 [  38] = 1'b0                       ; // DBI
  assign tx_phy_preflop_1 [  39] = 1'b0                       ; // DBI
  assign tx_phy_preflop_1 [  40] = tx_st_data          [ 109] ;
  assign tx_phy_preflop_1 [  41] = tx_st_data          [ 110] ;
  assign tx_phy_preflop_1 [  42] = tx_st_data          [ 111] ;
  assign tx_phy_preflop_1 [  43] = tx_st_data          [ 112] ;
  assign tx_phy_preflop_1 [  44] = tx_st_data          [ 113] ;
  assign tx_phy_preflop_1 [  45] = tx_st_data          [ 114] ;
  assign tx_phy_preflop_1 [  46] = tx_st_data          [ 115] ;
  assign tx_phy_preflop_1 [  47] = tx_st_data          [ 116] ;
  assign tx_phy_preflop_1 [  48] = tx_st_data          [ 117] ;
  assign tx_phy_preflop_1 [  49] = tx_st_data          [ 118] ;
  assign tx_phy_preflop_1 [  50] = tx_st_data          [ 119] ;
  assign tx_phy_preflop_1 [  51] = tx_st_data          [ 120] ;
  assign tx_phy_preflop_1 [  52] = tx_st_data          [ 121] ;
  assign tx_phy_preflop_1 [  53] = tx_st_data          [ 122] ;
  assign tx_phy_preflop_1 [  54] = tx_st_data          [ 123] ;
  assign tx_phy_preflop_1 [  55] = tx_st_data          [ 124] ;
  assign tx_phy_preflop_1 [  56] = tx_st_data          [ 125] ;
  assign tx_phy_preflop_1 [  57] = tx_st_data          [ 126] ;
  assign tx_phy_preflop_1 [  58] = tx_st_data          [ 127] ;
  assign tx_phy_preflop_1 [  59] = tx_st_data          [ 128] ;
  assign tx_phy_preflop_1 [  60] = tx_st_data          [ 129] ;
  assign tx_phy_preflop_1 [  61] = tx_st_data          [ 130] ;
  assign tx_phy_preflop_1 [  62] = tx_st_data          [ 131] ;
  assign tx_phy_preflop_1 [  63] = tx_st_data          [ 132] ;
  assign tx_phy_preflop_1 [  64] = tx_st_data          [ 133] ;
  assign tx_phy_preflop_1 [  65] = tx_st_data          [ 134] ;
  assign tx_phy_preflop_1 [  66] = tx_st_data          [ 135] ;
  assign tx_phy_preflop_1 [  67] = tx_st_data          [ 136] ;
  assign tx_phy_preflop_1 [  68] = tx_st_data          [ 137] ;
  assign tx_phy_preflop_1 [  69] = tx_st_data          [ 138] ;
  assign tx_phy_preflop_1 [  70] = tx_st_data          [ 139] ;
  assign tx_phy_preflop_1 [  71] = tx_st_data          [ 140] ;
  assign tx_phy_preflop_1 [  72] = tx_st_data          [ 141] ;
  assign tx_phy_preflop_1 [  73] = tx_st_data          [ 142] ;
  assign tx_phy_preflop_1 [  74] = tx_st_data          [ 143] ;
  assign tx_phy_preflop_1 [  75] = tx_st_data          [ 144] ;
  assign tx_phy_preflop_1 [  76] = 1'b0                       ;
  assign tx_phy_preflop_1 [  77] = 1'b0                       ;
  assign tx_phy_preflop_1 [  78] = 1'b0                       ; // DBI
  assign tx_phy_preflop_1 [  79] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [  80] = tx_mrk_userbit[1]          ; // MARKER
  assign tx_phy_preflop_0 [  81] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_0 [  82] = tx_st_pushbit_r1           ;
  assign tx_phy_preflop_0 [  83] = tx_st_data          [ 145] ;
  assign tx_phy_preflop_0 [  84] = tx_st_data          [ 146] ;
  assign tx_phy_preflop_0 [  85] = tx_st_data          [ 147] ;
  assign tx_phy_preflop_0 [  86] = tx_st_data          [ 148] ;
  assign tx_phy_preflop_0 [  87] = tx_st_data          [ 149] ;
  assign tx_phy_preflop_0 [  88] = tx_st_data          [ 150] ;
  assign tx_phy_preflop_0 [  89] = tx_st_data          [ 151] ;
  assign tx_phy_preflop_0 [  90] = tx_st_data          [ 152] ;
  assign tx_phy_preflop_0 [  91] = tx_st_data          [ 153] ;
  assign tx_phy_preflop_0 [  92] = tx_st_data          [ 154] ;
  assign tx_phy_preflop_0 [  93] = tx_st_data          [ 155] ;
  assign tx_phy_preflop_0 [  94] = tx_st_data          [ 156] ;
  assign tx_phy_preflop_0 [  95] = tx_st_data          [ 157] ;
  assign tx_phy_preflop_0 [  96] = tx_st_data          [ 158] ;
  assign tx_phy_preflop_0 [  97] = tx_st_data          [ 159] ;
  assign tx_phy_preflop_0 [  98] = tx_st_data          [ 160] ;
  assign tx_phy_preflop_0 [  99] = tx_st_data          [ 161] ;
  assign tx_phy_preflop_0 [ 100] = tx_st_data          [ 162] ;
  assign tx_phy_preflop_0 [ 101] = tx_st_data          [ 163] ;
  assign tx_phy_preflop_0 [ 102] = tx_st_data          [ 164] ;
  assign tx_phy_preflop_0 [ 103] = tx_st_data          [ 165] ;
  assign tx_phy_preflop_0 [ 104] = tx_st_data          [ 166] ;
  assign tx_phy_preflop_0 [ 105] = tx_st_data          [ 167] ;
  assign tx_phy_preflop_0 [ 106] = tx_st_data          [ 168] ;
  assign tx_phy_preflop_0 [ 107] = tx_st_data          [ 169] ;
  assign tx_phy_preflop_0 [ 108] = tx_st_data          [ 170] ;
  assign tx_phy_preflop_0 [ 109] = tx_st_data          [ 171] ;
  assign tx_phy_preflop_0 [ 110] = tx_st_data          [ 172] ;
  assign tx_phy_preflop_0 [ 111] = tx_st_data          [ 173] ;
  assign tx_phy_preflop_0 [ 112] = tx_st_data          [ 174] ;
  assign tx_phy_preflop_0 [ 113] = tx_st_data          [ 175] ;
  assign tx_phy_preflop_0 [ 114] = tx_st_data          [ 176] ;
  assign tx_phy_preflop_0 [ 115] = tx_st_data          [ 177] ;
  assign tx_phy_preflop_0 [ 116] = tx_st_data          [ 178] ;
  assign tx_phy_preflop_0 [ 117] = tx_st_data          [ 179] ;
  assign tx_phy_preflop_0 [ 118] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [ 119] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [ 120] = tx_st_data          [ 180] ;
  assign tx_phy_preflop_0 [ 121] = tx_st_data          [ 181] ;
  assign tx_phy_preflop_0 [ 122] = tx_st_data          [ 182] ;
  assign tx_phy_preflop_0 [ 123] = tx_st_data          [ 183] ;
  assign tx_phy_preflop_0 [ 124] = tx_st_data          [ 184] ;
  assign tx_phy_preflop_0 [ 125] = tx_st_data          [ 185] ;
  assign tx_phy_preflop_0 [ 126] = tx_st_data          [ 186] ;
  assign tx_phy_preflop_0 [ 127] = tx_st_data          [ 187] ;
  assign tx_phy_preflop_0 [ 128] = tx_st_data          [ 188] ;
  assign tx_phy_preflop_0 [ 129] = tx_st_data          [ 189] ;
  assign tx_phy_preflop_0 [ 130] = tx_st_data          [ 190] ;
  assign tx_phy_preflop_0 [ 131] = tx_st_data          [ 191] ;
  assign tx_phy_preflop_0 [ 132] = tx_st_data          [ 192] ;
  assign tx_phy_preflop_0 [ 133] = tx_st_data          [ 193] ;
  assign tx_phy_preflop_0 [ 134] = tx_st_data          [ 194] ;
  assign tx_phy_preflop_0 [ 135] = tx_st_data          [ 195] ;
  assign tx_phy_preflop_0 [ 136] = tx_st_data          [ 196] ;
  assign tx_phy_preflop_0 [ 137] = tx_st_data          [ 197] ;
  assign tx_phy_preflop_0 [ 138] = tx_st_data          [ 198] ;
  assign tx_phy_preflop_0 [ 139] = tx_st_data          [ 199] ;
  assign tx_phy_preflop_0 [ 140] = tx_st_data          [ 200] ;
  assign tx_phy_preflop_0 [ 141] = tx_st_data          [ 201] ;
  assign tx_phy_preflop_0 [ 142] = tx_st_data          [ 202] ;
  assign tx_phy_preflop_0 [ 143] = tx_st_data          [ 203] ;
  assign tx_phy_preflop_0 [ 144] = tx_st_data          [ 204] ;
  assign tx_phy_preflop_0 [ 145] = tx_st_data          [ 205] ;
  assign tx_phy_preflop_0 [ 146] = tx_st_data          [ 206] ;
  assign tx_phy_preflop_0 [ 147] = tx_st_data          [ 207] ;
  assign tx_phy_preflop_0 [ 148] = tx_st_data          [ 208] ;
  assign tx_phy_preflop_0 [ 149] = tx_st_data          [ 209] ;
  assign tx_phy_preflop_0 [ 150] = tx_st_data          [ 210] ;
  assign tx_phy_preflop_0 [ 151] = tx_st_data          [ 211] ;
  assign tx_phy_preflop_0 [ 152] = tx_st_data          [ 212] ;
  assign tx_phy_preflop_0 [ 153] = tx_st_data          [ 213] ;
  assign tx_phy_preflop_0 [ 154] = tx_st_data          [ 214] ;
  assign tx_phy_preflop_0 [ 155] = tx_st_data          [ 215] ;
  assign tx_phy_preflop_0 [ 156] = tx_st_data          [ 216] ;
  assign tx_phy_preflop_0 [ 157] = tx_st_data          [ 217] ;
  assign tx_phy_preflop_0 [ 158] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [ 159] = 1'b0                       ; // DBI
  assign tx_phy_preflop_1 [  80] = tx_mrk_userbit[1]          ; // MARKER
  assign tx_phy_preflop_1 [  81] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_1 [  82] = tx_st_data          [ 218] ;
  assign tx_phy_preflop_1 [  83] = tx_st_data          [ 219] ;
  assign tx_phy_preflop_1 [  84] = tx_st_data          [ 220] ;
  assign tx_phy_preflop_1 [  85] = tx_st_data          [ 221] ;
  assign tx_phy_preflop_1 [  86] = tx_st_data          [ 222] ;
  assign tx_phy_preflop_1 [  87] = tx_st_data          [ 223] ;
  assign tx_phy_preflop_1 [  88] = tx_st_data          [ 224] ;
  assign tx_phy_preflop_1 [  89] = tx_st_data          [ 225] ;
  assign tx_phy_preflop_1 [  90] = tx_st_data          [ 226] ;
  assign tx_phy_preflop_1 [  91] = tx_st_data          [ 227] ;
  assign tx_phy_preflop_1 [  92] = tx_st_data          [ 228] ;
  assign tx_phy_preflop_1 [  93] = tx_st_data          [ 229] ;
  assign tx_phy_preflop_1 [  94] = tx_st_data          [ 230] ;
  assign tx_phy_preflop_1 [  95] = tx_st_data          [ 231] ;
  assign tx_phy_preflop_1 [  96] = tx_st_data          [ 232] ;
  assign tx_phy_preflop_1 [  97] = tx_st_data          [ 233] ;
  assign tx_phy_preflop_1 [  98] = tx_st_data          [ 234] ;
  assign tx_phy_preflop_1 [  99] = tx_st_data          [ 235] ;
  assign tx_phy_preflop_1 [ 100] = tx_st_data          [ 236] ;
  assign tx_phy_preflop_1 [ 101] = tx_st_data          [ 237] ;
  assign tx_phy_preflop_1 [ 102] = tx_st_data          [ 238] ;
  assign tx_phy_preflop_1 [ 103] = tx_st_data          [ 239] ;
  assign tx_phy_preflop_1 [ 104] = tx_st_data          [ 240] ;
  assign tx_phy_preflop_1 [ 105] = tx_st_data          [ 241] ;
  assign tx_phy_preflop_1 [ 106] = tx_st_data          [ 242] ;
  assign tx_phy_preflop_1 [ 107] = tx_st_data          [ 243] ;
  assign tx_phy_preflop_1 [ 108] = tx_st_data          [ 244] ;
  assign tx_phy_preflop_1 [ 109] = tx_st_data          [ 245] ;
  assign tx_phy_preflop_1 [ 110] = tx_st_data          [ 246] ;
  assign tx_phy_preflop_1 [ 111] = tx_st_data          [ 247] ;
  assign tx_phy_preflop_1 [ 112] = tx_st_data          [ 248] ;
  assign tx_phy_preflop_1 [ 113] = tx_st_data          [ 249] ;
  assign tx_phy_preflop_1 [ 114] = tx_st_data          [ 250] ;
  assign tx_phy_preflop_1 [ 115] = tx_st_data          [ 251] ;
  assign tx_phy_preflop_1 [ 116] = tx_st_data          [ 252] ;
  assign tx_phy_preflop_1 [ 117] = tx_st_data          [ 253] ;
  assign tx_phy_preflop_1 [ 118] = 1'b0                       ; // DBI
  assign tx_phy_preflop_1 [ 119] = 1'b0                       ; // DBI
  assign tx_phy_preflop_1 [ 120] = tx_st_data          [ 254] ;
  assign tx_phy_preflop_1 [ 121] = tx_st_data          [ 255] ;
  assign tx_phy_preflop_1 [ 122] = tx_st_data          [ 256] ;
  assign tx_phy_preflop_1 [ 123] = tx_st_data          [ 257] ;
  assign tx_phy_preflop_1 [ 124] = tx_st_data          [ 258] ;
  assign tx_phy_preflop_1 [ 125] = tx_st_data          [ 259] ;
  assign tx_phy_preflop_1 [ 126] = tx_st_data          [ 260] ;
  assign tx_phy_preflop_1 [ 127] = tx_st_data          [ 261] ;
  assign tx_phy_preflop_1 [ 128] = tx_st_data          [ 262] ;
  assign tx_phy_preflop_1 [ 129] = tx_st_data          [ 263] ;
  assign tx_phy_preflop_1 [ 130] = tx_st_data          [ 264] ;
  assign tx_phy_preflop_1 [ 131] = tx_st_data          [ 265] ;
  assign tx_phy_preflop_1 [ 132] = tx_st_data          [ 266] ;
  assign tx_phy_preflop_1 [ 133] = tx_st_data          [ 267] ;
  assign tx_phy_preflop_1 [ 134] = tx_st_data          [ 268] ;
  assign tx_phy_preflop_1 [ 135] = tx_st_data          [ 269] ;
  assign tx_phy_preflop_1 [ 136] = tx_st_data          [ 270] ;
  assign tx_phy_preflop_1 [ 137] = tx_st_data          [ 271] ;
  assign tx_phy_preflop_1 [ 138] = tx_st_data          [ 272] ;
  assign tx_phy_preflop_1 [ 139] = tx_st_data          [ 273] ;
  assign tx_phy_preflop_1 [ 140] = tx_st_data          [ 274] ;
  assign tx_phy_preflop_1 [ 141] = tx_st_data          [ 275] ;
  assign tx_phy_preflop_1 [ 142] = tx_st_data          [ 276] ;
  assign tx_phy_preflop_1 [ 143] = tx_st_data          [ 277] ;
  assign tx_phy_preflop_1 [ 144] = tx_st_data          [ 278] ;
  assign tx_phy_preflop_1 [ 145] = tx_st_data          [ 279] ;
  assign tx_phy_preflop_1 [ 146] = tx_st_data          [ 280] ;
  assign tx_phy_preflop_1 [ 147] = tx_st_data          [ 281] ;
  assign tx_phy_preflop_1 [ 148] = tx_st_data          [ 282] ;
  assign tx_phy_preflop_1 [ 149] = tx_st_data          [ 283] ;
  assign tx_phy_preflop_1 [ 150] = tx_st_data          [ 284] ;
  assign tx_phy_preflop_1 [ 151] = tx_st_data          [ 285] ;
  assign tx_phy_preflop_1 [ 152] = tx_st_data          [ 286] ;
  assign tx_phy_preflop_1 [ 153] = tx_st_data          [ 287] ;
  assign tx_phy_preflop_1 [ 154] = tx_st_data          [ 288] ;
  assign tx_phy_preflop_1 [ 155] = tx_st_data          [ 289] ;
  assign tx_phy_preflop_1 [ 156] = 1'b0                       ;
  assign tx_phy_preflop_1 [ 157] = 1'b0                       ;
  assign tx_phy_preflop_1 [ 158] = 1'b0                       ; // DBI
  assign tx_phy_preflop_1 [ 159] = 1'b0                       ; // DBI
// TX Section
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// RX Section

//   RX_CH_WIDTH           = 160; // Gen2Only running at Half Rate
//   RX_DATA_WIDTH         = 148; // Usable Data per Channel
//   RX_PERSISTENT_STROBE  = 1'b1;
//   RX_PERSISTENT_MARKER  = 1'b1;
//   RX_STROBE_GEN2_LOC    = 'd1;
//   RX_MARKER_GEN2_LOC    = 'd0;
//   RX_STROBE_GEN1_LOC    = 'd1;
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

  logic                                          rx_st_credit_r0               ;
  logic                                          rx_st_credit_r1               ;
  logic                                          rx_st_credit_r2               ;
  logic                                          rx_st_credit_r3               ;

  // Asymmetric Credit Logic
  assign rx_st_credit         [   0 +:   1] = rx_st_credit_r0                    ;
  assign rx_st_credit         [   1 +:   1] = rx_st_credit_r1                    ;
  assign rx_st_credit         [   2 +:   1] = 1'b0                               ;
  assign rx_st_credit         [   3 +:   1] = 1'b0                               ;

//       MARKER                     = rx_phy_postflop_0 [   0]
//       STROBE                     = rx_phy_postflop_0 [   1]
  assign rx_st_credit_r0            = rx_phy_postflop_0 [   2];
//       nc                         = rx_phy_postflop_0 [   3];
//       nc                         = rx_phy_postflop_0 [   4];
//       nc                         = rx_phy_postflop_0 [   5];
//       nc                         = rx_phy_postflop_0 [   6];
//       nc                         = rx_phy_postflop_0 [   7];
//       nc                         = rx_phy_postflop_0 [   8];
//       nc                         = rx_phy_postflop_0 [   9];
//       nc                         = rx_phy_postflop_0 [  10];
//       nc                         = rx_phy_postflop_0 [  11];
//       nc                         = rx_phy_postflop_0 [  12];
//       nc                         = rx_phy_postflop_0 [  13];
//       nc                         = rx_phy_postflop_0 [  14];
//       nc                         = rx_phy_postflop_0 [  15];
//       nc                         = rx_phy_postflop_0 [  16];
//       nc                         = rx_phy_postflop_0 [  17];
//       nc                         = rx_phy_postflop_0 [  18];
//       nc                         = rx_phy_postflop_0 [  19];
//       nc                         = rx_phy_postflop_0 [  20];
//       nc                         = rx_phy_postflop_0 [  21];
//       nc                         = rx_phy_postflop_0 [  22];
//       nc                         = rx_phy_postflop_0 [  23];
//       nc                         = rx_phy_postflop_0 [  24];
//       nc                         = rx_phy_postflop_0 [  25];
//       nc                         = rx_phy_postflop_0 [  26];
//       nc                         = rx_phy_postflop_0 [  27];
//       nc                         = rx_phy_postflop_0 [  28];
//       nc                         = rx_phy_postflop_0 [  29];
//       nc                         = rx_phy_postflop_0 [  30];
//       nc                         = rx_phy_postflop_0 [  31];
//       nc                         = rx_phy_postflop_0 [  32];
//       nc                         = rx_phy_postflop_0 [  33];
//       nc                         = rx_phy_postflop_0 [  34];
//       nc                         = rx_phy_postflop_0 [  35];
//       nc                         = rx_phy_postflop_0 [  36];
//       nc                         = rx_phy_postflop_0 [  37];
//       DBI                        = rx_phy_postflop_0 [  38];
//       DBI                        = rx_phy_postflop_0 [  39];
//       nc                         = rx_phy_postflop_0 [  40];
//       nc                         = rx_phy_postflop_0 [  41];
//       nc                         = rx_phy_postflop_0 [  42];
//       nc                         = rx_phy_postflop_0 [  43];
//       nc                         = rx_phy_postflop_0 [  44];
//       nc                         = rx_phy_postflop_0 [  45];
//       nc                         = rx_phy_postflop_0 [  46];
//       nc                         = rx_phy_postflop_0 [  47];
//       nc                         = rx_phy_postflop_0 [  48];
//       nc                         = rx_phy_postflop_0 [  49];
//       nc                         = rx_phy_postflop_0 [  50];
//       nc                         = rx_phy_postflop_0 [  51];
//       nc                         = rx_phy_postflop_0 [  52];
//       nc                         = rx_phy_postflop_0 [  53];
//       nc                         = rx_phy_postflop_0 [  54];
//       nc                         = rx_phy_postflop_0 [  55];
//       nc                         = rx_phy_postflop_0 [  56];
//       nc                         = rx_phy_postflop_0 [  57];
//       nc                         = rx_phy_postflop_0 [  58];
//       nc                         = rx_phy_postflop_0 [  59];
//       nc                         = rx_phy_postflop_0 [  60];
//       nc                         = rx_phy_postflop_0 [  61];
//       nc                         = rx_phy_postflop_0 [  62];
//       nc                         = rx_phy_postflop_0 [  63];
//       nc                         = rx_phy_postflop_0 [  64];
//       nc                         = rx_phy_postflop_0 [  65];
//       nc                         = rx_phy_postflop_0 [  66];
//       nc                         = rx_phy_postflop_0 [  67];
//       nc                         = rx_phy_postflop_0 [  68];
//       nc                         = rx_phy_postflop_0 [  69];
//       nc                         = rx_phy_postflop_0 [  70];
//       nc                         = rx_phy_postflop_0 [  71];
//       nc                         = rx_phy_postflop_0 [  72];
//       nc                         = rx_phy_postflop_0 [  73];
//       nc                         = rx_phy_postflop_0 [  74];
//       nc                         = rx_phy_postflop_0 [  75];
//       nc                         = rx_phy_postflop_0 [  76];
//       nc                         = rx_phy_postflop_0 [  77];
//       DBI                        = rx_phy_postflop_0 [  78];
//       DBI                        = rx_phy_postflop_0 [  79];
//       MARKER                     = rx_phy_postflop_1 [   0]
//       STROBE                     = rx_phy_postflop_1 [   1]
//       nc                         = rx_phy_postflop_1 [   2];
//       nc                         = rx_phy_postflop_1 [   3];
//       nc                         = rx_phy_postflop_1 [   4];
//       nc                         = rx_phy_postflop_1 [   5];
//       nc                         = rx_phy_postflop_1 [   6];
//       nc                         = rx_phy_postflop_1 [   7];
//       nc                         = rx_phy_postflop_1 [   8];
//       nc                         = rx_phy_postflop_1 [   9];
//       nc                         = rx_phy_postflop_1 [  10];
//       nc                         = rx_phy_postflop_1 [  11];
//       nc                         = rx_phy_postflop_1 [  12];
//       nc                         = rx_phy_postflop_1 [  13];
//       nc                         = rx_phy_postflop_1 [  14];
//       nc                         = rx_phy_postflop_1 [  15];
//       nc                         = rx_phy_postflop_1 [  16];
//       nc                         = rx_phy_postflop_1 [  17];
//       nc                         = rx_phy_postflop_1 [  18];
//       nc                         = rx_phy_postflop_1 [  19];
//       nc                         = rx_phy_postflop_1 [  20];
//       nc                         = rx_phy_postflop_1 [  21];
//       nc                         = rx_phy_postflop_1 [  22];
//       nc                         = rx_phy_postflop_1 [  23];
//       nc                         = rx_phy_postflop_1 [  24];
//       nc                         = rx_phy_postflop_1 [  25];
//       nc                         = rx_phy_postflop_1 [  26];
//       nc                         = rx_phy_postflop_1 [  27];
//       nc                         = rx_phy_postflop_1 [  28];
//       nc                         = rx_phy_postflop_1 [  29];
//       nc                         = rx_phy_postflop_1 [  30];
//       nc                         = rx_phy_postflop_1 [  31];
//       nc                         = rx_phy_postflop_1 [  32];
//       nc                         = rx_phy_postflop_1 [  33];
//       nc                         = rx_phy_postflop_1 [  34];
//       nc                         = rx_phy_postflop_1 [  35];
//       nc                         = rx_phy_postflop_1 [  36];
//       nc                         = rx_phy_postflop_1 [  37];
//       DBI                        = rx_phy_postflop_1 [  38];
//       DBI                        = rx_phy_postflop_1 [  39];
//       nc                         = rx_phy_postflop_1 [  40];
//       nc                         = rx_phy_postflop_1 [  41];
//       nc                         = rx_phy_postflop_1 [  42];
//       nc                         = rx_phy_postflop_1 [  43];
//       nc                         = rx_phy_postflop_1 [  44];
//       nc                         = rx_phy_postflop_1 [  45];
//       nc                         = rx_phy_postflop_1 [  46];
//       nc                         = rx_phy_postflop_1 [  47];
//       nc                         = rx_phy_postflop_1 [  48];
//       nc                         = rx_phy_postflop_1 [  49];
//       nc                         = rx_phy_postflop_1 [  50];
//       nc                         = rx_phy_postflop_1 [  51];
//       nc                         = rx_phy_postflop_1 [  52];
//       nc                         = rx_phy_postflop_1 [  53];
//       nc                         = rx_phy_postflop_1 [  54];
//       nc                         = rx_phy_postflop_1 [  55];
//       nc                         = rx_phy_postflop_1 [  56];
//       nc                         = rx_phy_postflop_1 [  57];
//       nc                         = rx_phy_postflop_1 [  58];
//       nc                         = rx_phy_postflop_1 [  59];
//       nc                         = rx_phy_postflop_1 [  60];
//       nc                         = rx_phy_postflop_1 [  61];
//       nc                         = rx_phy_postflop_1 [  62];
//       nc                         = rx_phy_postflop_1 [  63];
//       nc                         = rx_phy_postflop_1 [  64];
//       nc                         = rx_phy_postflop_1 [  65];
//       nc                         = rx_phy_postflop_1 [  66];
//       nc                         = rx_phy_postflop_1 [  67];
//       nc                         = rx_phy_postflop_1 [  68];
//       nc                         = rx_phy_postflop_1 [  69];
//       nc                         = rx_phy_postflop_1 [  70];
//       nc                         = rx_phy_postflop_1 [  71];
//       nc                         = rx_phy_postflop_1 [  72];
//       nc                         = rx_phy_postflop_1 [  73];
//       nc                         = rx_phy_postflop_1 [  74];
//       nc                         = rx_phy_postflop_1 [  75];
//       nc                         = rx_phy_postflop_1 [  76];
//       nc                         = rx_phy_postflop_1 [  77];
//       DBI                        = rx_phy_postflop_1 [  78];
//       DBI                        = rx_phy_postflop_1 [  79];
//       MARKER                     = rx_phy_postflop_0 [  80]
//       STROBE                     = rx_phy_postflop_0 [  81]
  assign rx_st_credit_r1            = rx_phy_postflop_0 [  82];
//       nc                         = rx_phy_postflop_0 [  83];
//       nc                         = rx_phy_postflop_0 [  84];
//       nc                         = rx_phy_postflop_0 [  85];
//       nc                         = rx_phy_postflop_0 [  86];
//       nc                         = rx_phy_postflop_0 [  87];
//       nc                         = rx_phy_postflop_0 [  88];
//       nc                         = rx_phy_postflop_0 [  89];
//       nc                         = rx_phy_postflop_0 [  90];
//       nc                         = rx_phy_postflop_0 [  91];
//       nc                         = rx_phy_postflop_0 [  92];
//       nc                         = rx_phy_postflop_0 [  93];
//       nc                         = rx_phy_postflop_0 [  94];
//       nc                         = rx_phy_postflop_0 [  95];
//       nc                         = rx_phy_postflop_0 [  96];
//       nc                         = rx_phy_postflop_0 [  97];
//       nc                         = rx_phy_postflop_0 [  98];
//       nc                         = rx_phy_postflop_0 [  99];
//       nc                         = rx_phy_postflop_0 [ 100];
//       nc                         = rx_phy_postflop_0 [ 101];
//       nc                         = rx_phy_postflop_0 [ 102];
//       nc                         = rx_phy_postflop_0 [ 103];
//       nc                         = rx_phy_postflop_0 [ 104];
//       nc                         = rx_phy_postflop_0 [ 105];
//       nc                         = rx_phy_postflop_0 [ 106];
//       nc                         = rx_phy_postflop_0 [ 107];
//       nc                         = rx_phy_postflop_0 [ 108];
//       nc                         = rx_phy_postflop_0 [ 109];
//       nc                         = rx_phy_postflop_0 [ 110];
//       nc                         = rx_phy_postflop_0 [ 111];
//       nc                         = rx_phy_postflop_0 [ 112];
//       nc                         = rx_phy_postflop_0 [ 113];
//       nc                         = rx_phy_postflop_0 [ 114];
//       nc                         = rx_phy_postflop_0 [ 115];
//       nc                         = rx_phy_postflop_0 [ 116];
//       nc                         = rx_phy_postflop_0 [ 117];
//       DBI                        = rx_phy_postflop_0 [ 118];
//       DBI                        = rx_phy_postflop_0 [ 119];
//       nc                         = rx_phy_postflop_0 [ 120];
//       nc                         = rx_phy_postflop_0 [ 121];
//       nc                         = rx_phy_postflop_0 [ 122];
//       nc                         = rx_phy_postflop_0 [ 123];
//       nc                         = rx_phy_postflop_0 [ 124];
//       nc                         = rx_phy_postflop_0 [ 125];
//       nc                         = rx_phy_postflop_0 [ 126];
//       nc                         = rx_phy_postflop_0 [ 127];
//       nc                         = rx_phy_postflop_0 [ 128];
//       nc                         = rx_phy_postflop_0 [ 129];
//       nc                         = rx_phy_postflop_0 [ 130];
//       nc                         = rx_phy_postflop_0 [ 131];
//       nc                         = rx_phy_postflop_0 [ 132];
//       nc                         = rx_phy_postflop_0 [ 133];
//       nc                         = rx_phy_postflop_0 [ 134];
//       nc                         = rx_phy_postflop_0 [ 135];
//       nc                         = rx_phy_postflop_0 [ 136];
//       nc                         = rx_phy_postflop_0 [ 137];
//       nc                         = rx_phy_postflop_0 [ 138];
//       nc                         = rx_phy_postflop_0 [ 139];
//       nc                         = rx_phy_postflop_0 [ 140];
//       nc                         = rx_phy_postflop_0 [ 141];
//       nc                         = rx_phy_postflop_0 [ 142];
//       nc                         = rx_phy_postflop_0 [ 143];
//       nc                         = rx_phy_postflop_0 [ 144];
//       nc                         = rx_phy_postflop_0 [ 145];
//       nc                         = rx_phy_postflop_0 [ 146];
//       nc                         = rx_phy_postflop_0 [ 147];
//       nc                         = rx_phy_postflop_0 [ 148];
//       nc                         = rx_phy_postflop_0 [ 149];
//       nc                         = rx_phy_postflop_0 [ 150];
//       nc                         = rx_phy_postflop_0 [ 151];
//       nc                         = rx_phy_postflop_0 [ 152];
//       nc                         = rx_phy_postflop_0 [ 153];
//       nc                         = rx_phy_postflop_0 [ 154];
//       nc                         = rx_phy_postflop_0 [ 155];
//       nc                         = rx_phy_postflop_0 [ 156];
//       nc                         = rx_phy_postflop_0 [ 157];
//       DBI                        = rx_phy_postflop_0 [ 158];
//       DBI                        = rx_phy_postflop_0 [ 159];
//       MARKER                     = rx_phy_postflop_1 [  80]
//       STROBE                     = rx_phy_postflop_1 [  81]
//       nc                         = rx_phy_postflop_1 [  82];
//       nc                         = rx_phy_postflop_1 [  83];
//       nc                         = rx_phy_postflop_1 [  84];
//       nc                         = rx_phy_postflop_1 [  85];
//       nc                         = rx_phy_postflop_1 [  86];
//       nc                         = rx_phy_postflop_1 [  87];
//       nc                         = rx_phy_postflop_1 [  88];
//       nc                         = rx_phy_postflop_1 [  89];
//       nc                         = rx_phy_postflop_1 [  90];
//       nc                         = rx_phy_postflop_1 [  91];
//       nc                         = rx_phy_postflop_1 [  92];
//       nc                         = rx_phy_postflop_1 [  93];
//       nc                         = rx_phy_postflop_1 [  94];
//       nc                         = rx_phy_postflop_1 [  95];
//       nc                         = rx_phy_postflop_1 [  96];
//       nc                         = rx_phy_postflop_1 [  97];
//       nc                         = rx_phy_postflop_1 [  98];
//       nc                         = rx_phy_postflop_1 [  99];
//       nc                         = rx_phy_postflop_1 [ 100];
//       nc                         = rx_phy_postflop_1 [ 101];
//       nc                         = rx_phy_postflop_1 [ 102];
//       nc                         = rx_phy_postflop_1 [ 103];
//       nc                         = rx_phy_postflop_1 [ 104];
//       nc                         = rx_phy_postflop_1 [ 105];
//       nc                         = rx_phy_postflop_1 [ 106];
//       nc                         = rx_phy_postflop_1 [ 107];
//       nc                         = rx_phy_postflop_1 [ 108];
//       nc                         = rx_phy_postflop_1 [ 109];
//       nc                         = rx_phy_postflop_1 [ 110];
//       nc                         = rx_phy_postflop_1 [ 111];
//       nc                         = rx_phy_postflop_1 [ 112];
//       nc                         = rx_phy_postflop_1 [ 113];
//       nc                         = rx_phy_postflop_1 [ 114];
//       nc                         = rx_phy_postflop_1 [ 115];
//       nc                         = rx_phy_postflop_1 [ 116];
//       nc                         = rx_phy_postflop_1 [ 117];
//       DBI                        = rx_phy_postflop_1 [ 118];
//       DBI                        = rx_phy_postflop_1 [ 119];
//       nc                         = rx_phy_postflop_1 [ 120];
//       nc                         = rx_phy_postflop_1 [ 121];
//       nc                         = rx_phy_postflop_1 [ 122];
//       nc                         = rx_phy_postflop_1 [ 123];
//       nc                         = rx_phy_postflop_1 [ 124];
//       nc                         = rx_phy_postflop_1 [ 125];
//       nc                         = rx_phy_postflop_1 [ 126];
//       nc                         = rx_phy_postflop_1 [ 127];
//       nc                         = rx_phy_postflop_1 [ 128];
//       nc                         = rx_phy_postflop_1 [ 129];
//       nc                         = rx_phy_postflop_1 [ 130];
//       nc                         = rx_phy_postflop_1 [ 131];
//       nc                         = rx_phy_postflop_1 [ 132];
//       nc                         = rx_phy_postflop_1 [ 133];
//       nc                         = rx_phy_postflop_1 [ 134];
//       nc                         = rx_phy_postflop_1 [ 135];
//       nc                         = rx_phy_postflop_1 [ 136];
//       nc                         = rx_phy_postflop_1 [ 137];
//       nc                         = rx_phy_postflop_1 [ 138];
//       nc                         = rx_phy_postflop_1 [ 139];
//       nc                         = rx_phy_postflop_1 [ 140];
//       nc                         = rx_phy_postflop_1 [ 141];
//       nc                         = rx_phy_postflop_1 [ 142];
//       nc                         = rx_phy_postflop_1 [ 143];
//       nc                         = rx_phy_postflop_1 [ 144];
//       nc                         = rx_phy_postflop_1 [ 145];
//       nc                         = rx_phy_postflop_1 [ 146];
//       nc                         = rx_phy_postflop_1 [ 147];
//       nc                         = rx_phy_postflop_1 [ 148];
//       nc                         = rx_phy_postflop_1 [ 149];
//       nc                         = rx_phy_postflop_1 [ 150];
//       nc                         = rx_phy_postflop_1 [ 151];
//       nc                         = rx_phy_postflop_1 [ 152];
//       nc                         = rx_phy_postflop_1 [ 153];
//       nc                         = rx_phy_postflop_1 [ 154];
//       nc                         = rx_phy_postflop_1 [ 155];
//       nc                         = rx_phy_postflop_1 [ 156];
//       nc                         = rx_phy_postflop_1 [ 157];
//       DBI                        = rx_phy_postflop_1 [ 158];
//       DBI                        = rx_phy_postflop_1 [ 159];

// RX Section
//////////////////////////////////////////////////////////////////


endmodule
