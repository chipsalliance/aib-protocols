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

module lpif_txrx_x16_asym2_full_master_concat  (

// Data from Logic Links
  input  logic [ 280:   0]   tx_downstream_data  ,
  output logic               tx_downstream_pop_ovrd,

  output logic [ 280:   0]   rx_upstream_data    ,
  output logic               rx_upstream_push_ovrd,

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
  assign tx_downstream_pop_ovrd               = 1'b0                               ;

// No RX Packetization, so tie off packetization signals
  assign rx_upstream_push_ovrd               = 1'b0                               ;

//////////////////////////////////////////////////////////////////
// TX Section

//   TX_CH_WIDTH           = 80; // Gen2 running at Full Rate
//   TX_DATA_WIDTH         = 78; // Usable Data per Channel
//   TX_PERSISTENT_STROBE  = 1'b1;
//   TX_PERSISTENT_MARKER  = 1'b1;
//   TX_STROBE_GEN2_LOC    = 'd1;
//   TX_MARKER_GEN2_LOC    = 'd77;
//   TX_STROBE_GEN1_LOC    = 'd38;
//   TX_MARKER_GEN1_LOC    = 'd39;
//   TX_ENABLE_STROBE      = 1'b1;
//   TX_ENABLE_MARKER      = 1'b1;
//   TX_DBI_PRESENT        = 1'b0;
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

  assign tx_phy_preflop_0 [   0] = tx_downstream_data  [   0] ;
  assign tx_phy_preflop_0 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_0 [   2] = tx_downstream_data  [   1] ;
  assign tx_phy_preflop_0 [   3] = tx_downstream_data  [   2] ;
  assign tx_phy_preflop_0 [   4] = tx_downstream_data  [   3] ;
  assign tx_phy_preflop_0 [   5] = tx_downstream_data  [   4] ;
  assign tx_phy_preflop_0 [   6] = tx_downstream_data  [   5] ;
  assign tx_phy_preflop_0 [   7] = tx_downstream_data  [   6] ;
  assign tx_phy_preflop_0 [   8] = tx_downstream_data  [   7] ;
  assign tx_phy_preflop_0 [   9] = tx_downstream_data  [   8] ;
  assign tx_phy_preflop_0 [  10] = tx_downstream_data  [   9] ;
  assign tx_phy_preflop_0 [  11] = tx_downstream_data  [  10] ;
  assign tx_phy_preflop_0 [  12] = tx_downstream_data  [  11] ;
  assign tx_phy_preflop_0 [  13] = tx_downstream_data  [  12] ;
  assign tx_phy_preflop_0 [  14] = tx_downstream_data  [  13] ;
  assign tx_phy_preflop_0 [  15] = tx_downstream_data  [  14] ;
  assign tx_phy_preflop_0 [  16] = tx_downstream_data  [  15] ;
  assign tx_phy_preflop_0 [  17] = tx_downstream_data  [  16] ;
  assign tx_phy_preflop_0 [  18] = tx_downstream_data  [  17] ;
  assign tx_phy_preflop_0 [  19] = tx_downstream_data  [  18] ;
  assign tx_phy_preflop_0 [  20] = tx_downstream_data  [  19] ;
  assign tx_phy_preflop_0 [  21] = tx_downstream_data  [  20] ;
  assign tx_phy_preflop_0 [  22] = tx_downstream_data  [  21] ;
  assign tx_phy_preflop_0 [  23] = tx_downstream_data  [  22] ;
  assign tx_phy_preflop_0 [  24] = tx_downstream_data  [  23] ;
  assign tx_phy_preflop_0 [  25] = tx_downstream_data  [  24] ;
  assign tx_phy_preflop_0 [  26] = tx_downstream_data  [  25] ;
  assign tx_phy_preflop_0 [  27] = tx_downstream_data  [  26] ;
  assign tx_phy_preflop_0 [  28] = tx_downstream_data  [  27] ;
  assign tx_phy_preflop_0 [  29] = tx_downstream_data  [  28] ;
  assign tx_phy_preflop_0 [  30] = tx_downstream_data  [  29] ;
  assign tx_phy_preflop_0 [  31] = tx_downstream_data  [  30] ;
  assign tx_phy_preflop_0 [  32] = tx_downstream_data  [  31] ;
  assign tx_phy_preflop_0 [  33] = tx_downstream_data  [  32] ;
  assign tx_phy_preflop_0 [  34] = tx_downstream_data  [  33] ;
  assign tx_phy_preflop_0 [  35] = tx_downstream_data  [  34] ;
  assign tx_phy_preflop_0 [  36] = tx_downstream_data  [  35] ;
  assign tx_phy_preflop_0 [  37] = tx_downstream_data  [  36] ;
  assign tx_phy_preflop_0 [  38] = tx_downstream_data  [  37] ;
  assign tx_phy_preflop_0 [  39] = tx_downstream_data  [  38] ;
  assign tx_phy_preflop_0 [  40] = tx_downstream_data  [  39] ;
  assign tx_phy_preflop_0 [  41] = tx_downstream_data  [  40] ;
  assign tx_phy_preflop_0 [  42] = tx_downstream_data  [  41] ;
  assign tx_phy_preflop_0 [  43] = tx_downstream_data  [  42] ;
  assign tx_phy_preflop_0 [  44] = tx_downstream_data  [  43] ;
  assign tx_phy_preflop_0 [  45] = tx_downstream_data  [  44] ;
  assign tx_phy_preflop_0 [  46] = tx_downstream_data  [  45] ;
  assign tx_phy_preflop_0 [  47] = tx_downstream_data  [  46] ;
  assign tx_phy_preflop_0 [  48] = tx_downstream_data  [  47] ;
  assign tx_phy_preflop_0 [  49] = tx_downstream_data  [  48] ;
  assign tx_phy_preflop_0 [  50] = tx_downstream_data  [  49] ;
  assign tx_phy_preflop_0 [  51] = tx_downstream_data  [  50] ;
  assign tx_phy_preflop_0 [  52] = tx_downstream_data  [  51] ;
  assign tx_phy_preflop_0 [  53] = tx_downstream_data  [  52] ;
  assign tx_phy_preflop_0 [  54] = tx_downstream_data  [  53] ;
  assign tx_phy_preflop_0 [  55] = tx_downstream_data  [  54] ;
  assign tx_phy_preflop_0 [  56] = tx_downstream_data  [  55] ;
  assign tx_phy_preflop_0 [  57] = tx_downstream_data  [  56] ;
  assign tx_phy_preflop_0 [  58] = tx_downstream_data  [  57] ;
  assign tx_phy_preflop_0 [  59] = tx_downstream_data  [  58] ;
  assign tx_phy_preflop_0 [  60] = tx_downstream_data  [  59] ;
  assign tx_phy_preflop_0 [  61] = tx_downstream_data  [  60] ;
  assign tx_phy_preflop_0 [  62] = tx_downstream_data  [  61] ;
  assign tx_phy_preflop_0 [  63] = tx_downstream_data  [  62] ;
  assign tx_phy_preflop_0 [  64] = tx_downstream_data  [  63] ;
  assign tx_phy_preflop_0 [  65] = tx_downstream_data  [  64] ;
  assign tx_phy_preflop_0 [  66] = tx_downstream_data  [  65] ;
  assign tx_phy_preflop_0 [  67] = tx_downstream_data  [  66] ;
  assign tx_phy_preflop_0 [  68] = tx_downstream_data  [  67] ;
  assign tx_phy_preflop_0 [  69] = tx_downstream_data  [  68] ;
  assign tx_phy_preflop_0 [  70] = tx_downstream_data  [  69] ;
  assign tx_phy_preflop_0 [  71] = tx_downstream_data  [  70] ;
  assign tx_phy_preflop_0 [  72] = tx_downstream_data  [  71] ;
  assign tx_phy_preflop_0 [  73] = tx_downstream_data  [  72] ;
  assign tx_phy_preflop_0 [  74] = tx_downstream_data  [  73] ;
  assign tx_phy_preflop_0 [  75] = tx_downstream_data  [  74] ;
  assign tx_phy_preflop_0 [  76] = tx_downstream_data  [  75] ;
  assign tx_phy_preflop_0 [  77] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_0 [  78] = tx_downstream_data  [  76] ;
  assign tx_phy_preflop_0 [  79] = tx_downstream_data  [  77] ;
  assign tx_phy_preflop_1 [   0] = tx_downstream_data  [  78] ;
  assign tx_phy_preflop_1 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_1 [   2] = tx_downstream_data  [  79] ;
  assign tx_phy_preflop_1 [   3] = tx_downstream_data  [  80] ;
  assign tx_phy_preflop_1 [   4] = tx_downstream_data  [  81] ;
  assign tx_phy_preflop_1 [   5] = tx_downstream_data  [  82] ;
  assign tx_phy_preflop_1 [   6] = tx_downstream_data  [  83] ;
  assign tx_phy_preflop_1 [   7] = tx_downstream_data  [  84] ;
  assign tx_phy_preflop_1 [   8] = tx_downstream_data  [  85] ;
  assign tx_phy_preflop_1 [   9] = tx_downstream_data  [  86] ;
  assign tx_phy_preflop_1 [  10] = tx_downstream_data  [  87] ;
  assign tx_phy_preflop_1 [  11] = tx_downstream_data  [  88] ;
  assign tx_phy_preflop_1 [  12] = tx_downstream_data  [  89] ;
  assign tx_phy_preflop_1 [  13] = tx_downstream_data  [  90] ;
  assign tx_phy_preflop_1 [  14] = tx_downstream_data  [  91] ;
  assign tx_phy_preflop_1 [  15] = tx_downstream_data  [  92] ;
  assign tx_phy_preflop_1 [  16] = tx_downstream_data  [  93] ;
  assign tx_phy_preflop_1 [  17] = tx_downstream_data  [  94] ;
  assign tx_phy_preflop_1 [  18] = tx_downstream_data  [  95] ;
  assign tx_phy_preflop_1 [  19] = tx_downstream_data  [  96] ;
  assign tx_phy_preflop_1 [  20] = tx_downstream_data  [  97] ;
  assign tx_phy_preflop_1 [  21] = tx_downstream_data  [  98] ;
  assign tx_phy_preflop_1 [  22] = tx_downstream_data  [  99] ;
  assign tx_phy_preflop_1 [  23] = tx_downstream_data  [ 100] ;
  assign tx_phy_preflop_1 [  24] = tx_downstream_data  [ 101] ;
  assign tx_phy_preflop_1 [  25] = tx_downstream_data  [ 102] ;
  assign tx_phy_preflop_1 [  26] = tx_downstream_data  [ 103] ;
  assign tx_phy_preflop_1 [  27] = tx_downstream_data  [ 104] ;
  assign tx_phy_preflop_1 [  28] = tx_downstream_data  [ 105] ;
  assign tx_phy_preflop_1 [  29] = tx_downstream_data  [ 106] ;
  assign tx_phy_preflop_1 [  30] = tx_downstream_data  [ 107] ;
  assign tx_phy_preflop_1 [  31] = tx_downstream_data  [ 108] ;
  assign tx_phy_preflop_1 [  32] = tx_downstream_data  [ 109] ;
  assign tx_phy_preflop_1 [  33] = tx_downstream_data  [ 110] ;
  assign tx_phy_preflop_1 [  34] = tx_downstream_data  [ 111] ;
  assign tx_phy_preflop_1 [  35] = tx_downstream_data  [ 112] ;
  assign tx_phy_preflop_1 [  36] = tx_downstream_data  [ 113] ;
  assign tx_phy_preflop_1 [  37] = tx_downstream_data  [ 114] ;
  assign tx_phy_preflop_1 [  38] = tx_downstream_data  [ 115] ;
  assign tx_phy_preflop_1 [  39] = tx_downstream_data  [ 116] ;
  assign tx_phy_preflop_1 [  40] = tx_downstream_data  [ 117] ;
  assign tx_phy_preflop_1 [  41] = tx_downstream_data  [ 118] ;
  assign tx_phy_preflop_1 [  42] = tx_downstream_data  [ 119] ;
  assign tx_phy_preflop_1 [  43] = tx_downstream_data  [ 120] ;
  assign tx_phy_preflop_1 [  44] = tx_downstream_data  [ 121] ;
  assign tx_phy_preflop_1 [  45] = tx_downstream_data  [ 122] ;
  assign tx_phy_preflop_1 [  46] = tx_downstream_data  [ 123] ;
  assign tx_phy_preflop_1 [  47] = tx_downstream_data  [ 124] ;
  assign tx_phy_preflop_1 [  48] = tx_downstream_data  [ 125] ;
  assign tx_phy_preflop_1 [  49] = tx_downstream_data  [ 126] ;
  assign tx_phy_preflop_1 [  50] = tx_downstream_data  [ 127] ;
  assign tx_phy_preflop_1 [  51] = tx_downstream_data  [ 128] ;
  assign tx_phy_preflop_1 [  52] = tx_downstream_data  [ 129] ;
  assign tx_phy_preflop_1 [  53] = tx_downstream_data  [ 130] ;
  assign tx_phy_preflop_1 [  54] = tx_downstream_data  [ 131] ;
  assign tx_phy_preflop_1 [  55] = tx_downstream_data  [ 132] ;
  assign tx_phy_preflop_1 [  56] = tx_downstream_data  [ 133] ;
  assign tx_phy_preflop_1 [  57] = tx_downstream_data  [ 134] ;
  assign tx_phy_preflop_1 [  58] = tx_downstream_data  [ 135] ;
  assign tx_phy_preflop_1 [  59] = tx_downstream_data  [ 136] ;
  assign tx_phy_preflop_1 [  60] = tx_downstream_data  [ 137] ;
  assign tx_phy_preflop_1 [  61] = tx_downstream_data  [ 138] ;
  assign tx_phy_preflop_1 [  62] = tx_downstream_data  [ 139] ;
  assign tx_phy_preflop_1 [  63] = tx_downstream_data  [ 140] ;
  assign tx_phy_preflop_1 [  64] = tx_downstream_data  [ 141] ;
  assign tx_phy_preflop_1 [  65] = tx_downstream_data  [ 142] ;
  assign tx_phy_preflop_1 [  66] = tx_downstream_data  [ 143] ;
  assign tx_phy_preflop_1 [  67] = tx_downstream_data  [ 144] ;
  assign tx_phy_preflop_1 [  68] = tx_downstream_data  [ 145] ;
  assign tx_phy_preflop_1 [  69] = tx_downstream_data  [ 146] ;
  assign tx_phy_preflop_1 [  70] = tx_downstream_data  [ 147] ;
  assign tx_phy_preflop_1 [  71] = tx_downstream_data  [ 148] ;
  assign tx_phy_preflop_1 [  72] = tx_downstream_data  [ 149] ;
  assign tx_phy_preflop_1 [  73] = tx_downstream_data  [ 150] ;
  assign tx_phy_preflop_1 [  74] = tx_downstream_data  [ 151] ;
  assign tx_phy_preflop_1 [  75] = tx_downstream_data  [ 152] ;
  assign tx_phy_preflop_1 [  76] = tx_downstream_data  [ 153] ;
  assign tx_phy_preflop_1 [  77] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_1 [  78] = tx_downstream_data  [ 154] ;
  assign tx_phy_preflop_1 [  79] = tx_downstream_data  [ 155] ;
  assign tx_phy_preflop_2 [   0] = tx_downstream_data  [ 156] ;
  assign tx_phy_preflop_2 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_2 [   2] = tx_downstream_data  [ 157] ;
  assign tx_phy_preflop_2 [   3] = tx_downstream_data  [ 158] ;
  assign tx_phy_preflop_2 [   4] = tx_downstream_data  [ 159] ;
  assign tx_phy_preflop_2 [   5] = tx_downstream_data  [ 160] ;
  assign tx_phy_preflop_2 [   6] = tx_downstream_data  [ 161] ;
  assign tx_phy_preflop_2 [   7] = tx_downstream_data  [ 162] ;
  assign tx_phy_preflop_2 [   8] = tx_downstream_data  [ 163] ;
  assign tx_phy_preflop_2 [   9] = tx_downstream_data  [ 164] ;
  assign tx_phy_preflop_2 [  10] = tx_downstream_data  [ 165] ;
  assign tx_phy_preflop_2 [  11] = tx_downstream_data  [ 166] ;
  assign tx_phy_preflop_2 [  12] = tx_downstream_data  [ 167] ;
  assign tx_phy_preflop_2 [  13] = tx_downstream_data  [ 168] ;
  assign tx_phy_preflop_2 [  14] = tx_downstream_data  [ 169] ;
  assign tx_phy_preflop_2 [  15] = tx_downstream_data  [ 170] ;
  assign tx_phy_preflop_2 [  16] = tx_downstream_data  [ 171] ;
  assign tx_phy_preflop_2 [  17] = tx_downstream_data  [ 172] ;
  assign tx_phy_preflop_2 [  18] = tx_downstream_data  [ 173] ;
  assign tx_phy_preflop_2 [  19] = tx_downstream_data  [ 174] ;
  assign tx_phy_preflop_2 [  20] = tx_downstream_data  [ 175] ;
  assign tx_phy_preflop_2 [  21] = tx_downstream_data  [ 176] ;
  assign tx_phy_preflop_2 [  22] = tx_downstream_data  [ 177] ;
  assign tx_phy_preflop_2 [  23] = tx_downstream_data  [ 178] ;
  assign tx_phy_preflop_2 [  24] = tx_downstream_data  [ 179] ;
  assign tx_phy_preflop_2 [  25] = tx_downstream_data  [ 180] ;
  assign tx_phy_preflop_2 [  26] = tx_downstream_data  [ 181] ;
  assign tx_phy_preflop_2 [  27] = tx_downstream_data  [ 182] ;
  assign tx_phy_preflop_2 [  28] = tx_downstream_data  [ 183] ;
  assign tx_phy_preflop_2 [  29] = tx_downstream_data  [ 184] ;
  assign tx_phy_preflop_2 [  30] = tx_downstream_data  [ 185] ;
  assign tx_phy_preflop_2 [  31] = tx_downstream_data  [ 186] ;
  assign tx_phy_preflop_2 [  32] = tx_downstream_data  [ 187] ;
  assign tx_phy_preflop_2 [  33] = tx_downstream_data  [ 188] ;
  assign tx_phy_preflop_2 [  34] = tx_downstream_data  [ 189] ;
  assign tx_phy_preflop_2 [  35] = tx_downstream_data  [ 190] ;
  assign tx_phy_preflop_2 [  36] = tx_downstream_data  [ 191] ;
  assign tx_phy_preflop_2 [  37] = tx_downstream_data  [ 192] ;
  assign tx_phy_preflop_2 [  38] = tx_downstream_data  [ 193] ;
  assign tx_phy_preflop_2 [  39] = tx_downstream_data  [ 194] ;
  assign tx_phy_preflop_2 [  40] = tx_downstream_data  [ 195] ;
  assign tx_phy_preflop_2 [  41] = tx_downstream_data  [ 196] ;
  assign tx_phy_preflop_2 [  42] = tx_downstream_data  [ 197] ;
  assign tx_phy_preflop_2 [  43] = tx_downstream_data  [ 198] ;
  assign tx_phy_preflop_2 [  44] = tx_downstream_data  [ 199] ;
  assign tx_phy_preflop_2 [  45] = tx_downstream_data  [ 200] ;
  assign tx_phy_preflop_2 [  46] = tx_downstream_data  [ 201] ;
  assign tx_phy_preflop_2 [  47] = tx_downstream_data  [ 202] ;
  assign tx_phy_preflop_2 [  48] = tx_downstream_data  [ 203] ;
  assign tx_phy_preflop_2 [  49] = tx_downstream_data  [ 204] ;
  assign tx_phy_preflop_2 [  50] = tx_downstream_data  [ 205] ;
  assign tx_phy_preflop_2 [  51] = tx_downstream_data  [ 206] ;
  assign tx_phy_preflop_2 [  52] = tx_downstream_data  [ 207] ;
  assign tx_phy_preflop_2 [  53] = tx_downstream_data  [ 208] ;
  assign tx_phy_preflop_2 [  54] = tx_downstream_data  [ 209] ;
  assign tx_phy_preflop_2 [  55] = tx_downstream_data  [ 210] ;
  assign tx_phy_preflop_2 [  56] = tx_downstream_data  [ 211] ;
  assign tx_phy_preflop_2 [  57] = tx_downstream_data  [ 212] ;
  assign tx_phy_preflop_2 [  58] = tx_downstream_data  [ 213] ;
  assign tx_phy_preflop_2 [  59] = tx_downstream_data  [ 214] ;
  assign tx_phy_preflop_2 [  60] = tx_downstream_data  [ 215] ;
  assign tx_phy_preflop_2 [  61] = tx_downstream_data  [ 216] ;
  assign tx_phy_preflop_2 [  62] = tx_downstream_data  [ 217] ;
  assign tx_phy_preflop_2 [  63] = tx_downstream_data  [ 218] ;
  assign tx_phy_preflop_2 [  64] = tx_downstream_data  [ 219] ;
  assign tx_phy_preflop_2 [  65] = tx_downstream_data  [ 220] ;
  assign tx_phy_preflop_2 [  66] = tx_downstream_data  [ 221] ;
  assign tx_phy_preflop_2 [  67] = tx_downstream_data  [ 222] ;
  assign tx_phy_preflop_2 [  68] = tx_downstream_data  [ 223] ;
  assign tx_phy_preflop_2 [  69] = tx_downstream_data  [ 224] ;
  assign tx_phy_preflop_2 [  70] = tx_downstream_data  [ 225] ;
  assign tx_phy_preflop_2 [  71] = tx_downstream_data  [ 226] ;
  assign tx_phy_preflop_2 [  72] = tx_downstream_data  [ 227] ;
  assign tx_phy_preflop_2 [  73] = tx_downstream_data  [ 228] ;
  assign tx_phy_preflop_2 [  74] = tx_downstream_data  [ 229] ;
  assign tx_phy_preflop_2 [  75] = tx_downstream_data  [ 230] ;
  assign tx_phy_preflop_2 [  76] = tx_downstream_data  [ 231] ;
  assign tx_phy_preflop_2 [  77] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_2 [  78] = tx_downstream_data  [ 232] ;
  assign tx_phy_preflop_2 [  79] = tx_downstream_data  [ 233] ;
  assign tx_phy_preflop_3 [   0] = tx_downstream_data  [ 234] ;
  assign tx_phy_preflop_3 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_3 [   2] = tx_downstream_data  [ 235] ;
  assign tx_phy_preflop_3 [   3] = tx_downstream_data  [ 236] ;
  assign tx_phy_preflop_3 [   4] = tx_downstream_data  [ 237] ;
  assign tx_phy_preflop_3 [   5] = tx_downstream_data  [ 238] ;
  assign tx_phy_preflop_3 [   6] = tx_downstream_data  [ 239] ;
  assign tx_phy_preflop_3 [   7] = tx_downstream_data  [ 240] ;
  assign tx_phy_preflop_3 [   8] = tx_downstream_data  [ 241] ;
  assign tx_phy_preflop_3 [   9] = tx_downstream_data  [ 242] ;
  assign tx_phy_preflop_3 [  10] = tx_downstream_data  [ 243] ;
  assign tx_phy_preflop_3 [  11] = tx_downstream_data  [ 244] ;
  assign tx_phy_preflop_3 [  12] = tx_downstream_data  [ 245] ;
  assign tx_phy_preflop_3 [  13] = tx_downstream_data  [ 246] ;
  assign tx_phy_preflop_3 [  14] = tx_downstream_data  [ 247] ;
  assign tx_phy_preflop_3 [  15] = tx_downstream_data  [ 248] ;
  assign tx_phy_preflop_3 [  16] = tx_downstream_data  [ 249] ;
  assign tx_phy_preflop_3 [  17] = tx_downstream_data  [ 250] ;
  assign tx_phy_preflop_3 [  18] = tx_downstream_data  [ 251] ;
  assign tx_phy_preflop_3 [  19] = tx_downstream_data  [ 252] ;
  assign tx_phy_preflop_3 [  20] = tx_downstream_data  [ 253] ;
  assign tx_phy_preflop_3 [  21] = tx_downstream_data  [ 254] ;
  assign tx_phy_preflop_3 [  22] = tx_downstream_data  [ 255] ;
  assign tx_phy_preflop_3 [  23] = tx_downstream_data  [ 256] ;
  assign tx_phy_preflop_3 [  24] = tx_downstream_data  [ 257] ;
  assign tx_phy_preflop_3 [  25] = tx_downstream_data  [ 258] ;
  assign tx_phy_preflop_3 [  26] = tx_downstream_data  [ 259] ;
  assign tx_phy_preflop_3 [  27] = tx_downstream_data  [ 260] ;
  assign tx_phy_preflop_3 [  28] = tx_downstream_data  [ 261] ;
  assign tx_phy_preflop_3 [  29] = tx_downstream_data  [ 262] ;
  assign tx_phy_preflop_3 [  30] = tx_downstream_data  [ 263] ;
  assign tx_phy_preflop_3 [  31] = tx_downstream_data  [ 264] ;
  assign tx_phy_preflop_3 [  32] = tx_downstream_data  [ 265] ;
  assign tx_phy_preflop_3 [  33] = tx_downstream_data  [ 266] ;
  assign tx_phy_preflop_3 [  34] = tx_downstream_data  [ 267] ;
  assign tx_phy_preflop_3 [  35] = tx_downstream_data  [ 268] ;
  assign tx_phy_preflop_3 [  36] = tx_downstream_data  [ 269] ;
  assign tx_phy_preflop_3 [  37] = tx_downstream_data  [ 270] ;
  assign tx_phy_preflop_3 [  38] = tx_downstream_data  [ 271] ;
  assign tx_phy_preflop_3 [  39] = tx_downstream_data  [ 272] ;
  assign tx_phy_preflop_3 [  40] = tx_downstream_data  [ 273] ;
  assign tx_phy_preflop_3 [  41] = tx_downstream_data  [ 274] ;
  assign tx_phy_preflop_3 [  42] = tx_downstream_data  [ 275] ;
  assign tx_phy_preflop_3 [  43] = tx_downstream_data  [ 276] ;
  assign tx_phy_preflop_3 [  44] = tx_downstream_data  [ 277] ;
  assign tx_phy_preflop_3 [  45] = tx_downstream_data  [ 278] ;
  assign tx_phy_preflop_3 [  46] = tx_downstream_data  [ 279] ;
  assign tx_phy_preflop_3 [  47] = tx_downstream_data  [ 280] ;
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
  assign tx_phy_preflop_3 [  76] = 1'b0                       ;
  assign tx_phy_preflop_3 [  77] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_3 [  78] = 1'b0                       ;
  assign tx_phy_preflop_3 [  79] = 1'b0                       ;
// TX Section
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// RX Section

//   RX_CH_WIDTH           = 80; // Gen2 running at Full Rate
//   RX_DATA_WIDTH         = 78; // Usable Data per Channel
//   RX_PERSISTENT_STROBE  = 1'b1;
//   RX_PERSISTENT_MARKER  = 1'b1;
//   RX_STROBE_GEN2_LOC    = 'd1;
//   RX_MARKER_GEN2_LOC    = 'd77;
//   RX_STROBE_GEN1_LOC    = 'd38;
//   RX_MARKER_GEN1_LOC    = 'd39;
//   RX_ENABLE_STROBE      = 1'b1;
//   RX_ENABLE_MARKER      = 1'b1;
//   RX_DBI_PRESENT        = 1'b0;
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

  assign rx_upstream_data    [   0] = rx_phy_postflop_0 [   0];
//       STROBE                     = rx_phy_postflop_0 [   1]
  assign rx_upstream_data    [   1] = rx_phy_postflop_0 [   2];
  assign rx_upstream_data    [   2] = rx_phy_postflop_0 [   3];
  assign rx_upstream_data    [   3] = rx_phy_postflop_0 [   4];
  assign rx_upstream_data    [   4] = rx_phy_postflop_0 [   5];
  assign rx_upstream_data    [   5] = rx_phy_postflop_0 [   6];
  assign rx_upstream_data    [   6] = rx_phy_postflop_0 [   7];
  assign rx_upstream_data    [   7] = rx_phy_postflop_0 [   8];
  assign rx_upstream_data    [   8] = rx_phy_postflop_0 [   9];
  assign rx_upstream_data    [   9] = rx_phy_postflop_0 [  10];
  assign rx_upstream_data    [  10] = rx_phy_postflop_0 [  11];
  assign rx_upstream_data    [  11] = rx_phy_postflop_0 [  12];
  assign rx_upstream_data    [  12] = rx_phy_postflop_0 [  13];
  assign rx_upstream_data    [  13] = rx_phy_postflop_0 [  14];
  assign rx_upstream_data    [  14] = rx_phy_postflop_0 [  15];
  assign rx_upstream_data    [  15] = rx_phy_postflop_0 [  16];
  assign rx_upstream_data    [  16] = rx_phy_postflop_0 [  17];
  assign rx_upstream_data    [  17] = rx_phy_postflop_0 [  18];
  assign rx_upstream_data    [  18] = rx_phy_postflop_0 [  19];
  assign rx_upstream_data    [  19] = rx_phy_postflop_0 [  20];
  assign rx_upstream_data    [  20] = rx_phy_postflop_0 [  21];
  assign rx_upstream_data    [  21] = rx_phy_postflop_0 [  22];
  assign rx_upstream_data    [  22] = rx_phy_postflop_0 [  23];
  assign rx_upstream_data    [  23] = rx_phy_postflop_0 [  24];
  assign rx_upstream_data    [  24] = rx_phy_postflop_0 [  25];
  assign rx_upstream_data    [  25] = rx_phy_postflop_0 [  26];
  assign rx_upstream_data    [  26] = rx_phy_postflop_0 [  27];
  assign rx_upstream_data    [  27] = rx_phy_postflop_0 [  28];
  assign rx_upstream_data    [  28] = rx_phy_postflop_0 [  29];
  assign rx_upstream_data    [  29] = rx_phy_postflop_0 [  30];
  assign rx_upstream_data    [  30] = rx_phy_postflop_0 [  31];
  assign rx_upstream_data    [  31] = rx_phy_postflop_0 [  32];
  assign rx_upstream_data    [  32] = rx_phy_postflop_0 [  33];
  assign rx_upstream_data    [  33] = rx_phy_postflop_0 [  34];
  assign rx_upstream_data    [  34] = rx_phy_postflop_0 [  35];
  assign rx_upstream_data    [  35] = rx_phy_postflop_0 [  36];
  assign rx_upstream_data    [  36] = rx_phy_postflop_0 [  37];
  assign rx_upstream_data    [  37] = rx_phy_postflop_0 [  38];
  assign rx_upstream_data    [  38] = rx_phy_postflop_0 [  39];
  assign rx_upstream_data    [  39] = rx_phy_postflop_0 [  40];
  assign rx_upstream_data    [  40] = rx_phy_postflop_0 [  41];
  assign rx_upstream_data    [  41] = rx_phy_postflop_0 [  42];
  assign rx_upstream_data    [  42] = rx_phy_postflop_0 [  43];
  assign rx_upstream_data    [  43] = rx_phy_postflop_0 [  44];
  assign rx_upstream_data    [  44] = rx_phy_postflop_0 [  45];
  assign rx_upstream_data    [  45] = rx_phy_postflop_0 [  46];
  assign rx_upstream_data    [  46] = rx_phy_postflop_0 [  47];
  assign rx_upstream_data    [  47] = rx_phy_postflop_0 [  48];
  assign rx_upstream_data    [  48] = rx_phy_postflop_0 [  49];
  assign rx_upstream_data    [  49] = rx_phy_postflop_0 [  50];
  assign rx_upstream_data    [  50] = rx_phy_postflop_0 [  51];
  assign rx_upstream_data    [  51] = rx_phy_postflop_0 [  52];
  assign rx_upstream_data    [  52] = rx_phy_postflop_0 [  53];
  assign rx_upstream_data    [  53] = rx_phy_postflop_0 [  54];
  assign rx_upstream_data    [  54] = rx_phy_postflop_0 [  55];
  assign rx_upstream_data    [  55] = rx_phy_postflop_0 [  56];
  assign rx_upstream_data    [  56] = rx_phy_postflop_0 [  57];
  assign rx_upstream_data    [  57] = rx_phy_postflop_0 [  58];
  assign rx_upstream_data    [  58] = rx_phy_postflop_0 [  59];
  assign rx_upstream_data    [  59] = rx_phy_postflop_0 [  60];
  assign rx_upstream_data    [  60] = rx_phy_postflop_0 [  61];
  assign rx_upstream_data    [  61] = rx_phy_postflop_0 [  62];
  assign rx_upstream_data    [  62] = rx_phy_postflop_0 [  63];
  assign rx_upstream_data    [  63] = rx_phy_postflop_0 [  64];
  assign rx_upstream_data    [  64] = rx_phy_postflop_0 [  65];
  assign rx_upstream_data    [  65] = rx_phy_postflop_0 [  66];
  assign rx_upstream_data    [  66] = rx_phy_postflop_0 [  67];
  assign rx_upstream_data    [  67] = rx_phy_postflop_0 [  68];
  assign rx_upstream_data    [  68] = rx_phy_postflop_0 [  69];
  assign rx_upstream_data    [  69] = rx_phy_postflop_0 [  70];
  assign rx_upstream_data    [  70] = rx_phy_postflop_0 [  71];
  assign rx_upstream_data    [  71] = rx_phy_postflop_0 [  72];
  assign rx_upstream_data    [  72] = rx_phy_postflop_0 [  73];
  assign rx_upstream_data    [  73] = rx_phy_postflop_0 [  74];
  assign rx_upstream_data    [  74] = rx_phy_postflop_0 [  75];
  assign rx_upstream_data    [  75] = rx_phy_postflop_0 [  76];
//       MARKER                     = rx_phy_postflop_0 [  77]
  assign rx_upstream_data    [  76] = rx_phy_postflop_0 [  78];
  assign rx_upstream_data    [  77] = rx_phy_postflop_0 [  79];
  assign rx_upstream_data    [  78] = rx_phy_postflop_1 [   0];
//       STROBE                     = rx_phy_postflop_1 [   1]
  assign rx_upstream_data    [  79] = rx_phy_postflop_1 [   2];
  assign rx_upstream_data    [  80] = rx_phy_postflop_1 [   3];
  assign rx_upstream_data    [  81] = rx_phy_postflop_1 [   4];
  assign rx_upstream_data    [  82] = rx_phy_postflop_1 [   5];
  assign rx_upstream_data    [  83] = rx_phy_postflop_1 [   6];
  assign rx_upstream_data    [  84] = rx_phy_postflop_1 [   7];
  assign rx_upstream_data    [  85] = rx_phy_postflop_1 [   8];
  assign rx_upstream_data    [  86] = rx_phy_postflop_1 [   9];
  assign rx_upstream_data    [  87] = rx_phy_postflop_1 [  10];
  assign rx_upstream_data    [  88] = rx_phy_postflop_1 [  11];
  assign rx_upstream_data    [  89] = rx_phy_postflop_1 [  12];
  assign rx_upstream_data    [  90] = rx_phy_postflop_1 [  13];
  assign rx_upstream_data    [  91] = rx_phy_postflop_1 [  14];
  assign rx_upstream_data    [  92] = rx_phy_postflop_1 [  15];
  assign rx_upstream_data    [  93] = rx_phy_postflop_1 [  16];
  assign rx_upstream_data    [  94] = rx_phy_postflop_1 [  17];
  assign rx_upstream_data    [  95] = rx_phy_postflop_1 [  18];
  assign rx_upstream_data    [  96] = rx_phy_postflop_1 [  19];
  assign rx_upstream_data    [  97] = rx_phy_postflop_1 [  20];
  assign rx_upstream_data    [  98] = rx_phy_postflop_1 [  21];
  assign rx_upstream_data    [  99] = rx_phy_postflop_1 [  22];
  assign rx_upstream_data    [ 100] = rx_phy_postflop_1 [  23];
  assign rx_upstream_data    [ 101] = rx_phy_postflop_1 [  24];
  assign rx_upstream_data    [ 102] = rx_phy_postflop_1 [  25];
  assign rx_upstream_data    [ 103] = rx_phy_postflop_1 [  26];
  assign rx_upstream_data    [ 104] = rx_phy_postflop_1 [  27];
  assign rx_upstream_data    [ 105] = rx_phy_postflop_1 [  28];
  assign rx_upstream_data    [ 106] = rx_phy_postflop_1 [  29];
  assign rx_upstream_data    [ 107] = rx_phy_postflop_1 [  30];
  assign rx_upstream_data    [ 108] = rx_phy_postflop_1 [  31];
  assign rx_upstream_data    [ 109] = rx_phy_postflop_1 [  32];
  assign rx_upstream_data    [ 110] = rx_phy_postflop_1 [  33];
  assign rx_upstream_data    [ 111] = rx_phy_postflop_1 [  34];
  assign rx_upstream_data    [ 112] = rx_phy_postflop_1 [  35];
  assign rx_upstream_data    [ 113] = rx_phy_postflop_1 [  36];
  assign rx_upstream_data    [ 114] = rx_phy_postflop_1 [  37];
  assign rx_upstream_data    [ 115] = rx_phy_postflop_1 [  38];
  assign rx_upstream_data    [ 116] = rx_phy_postflop_1 [  39];
  assign rx_upstream_data    [ 117] = rx_phy_postflop_1 [  40];
  assign rx_upstream_data    [ 118] = rx_phy_postflop_1 [  41];
  assign rx_upstream_data    [ 119] = rx_phy_postflop_1 [  42];
  assign rx_upstream_data    [ 120] = rx_phy_postflop_1 [  43];
  assign rx_upstream_data    [ 121] = rx_phy_postflop_1 [  44];
  assign rx_upstream_data    [ 122] = rx_phy_postflop_1 [  45];
  assign rx_upstream_data    [ 123] = rx_phy_postflop_1 [  46];
  assign rx_upstream_data    [ 124] = rx_phy_postflop_1 [  47];
  assign rx_upstream_data    [ 125] = rx_phy_postflop_1 [  48];
  assign rx_upstream_data    [ 126] = rx_phy_postflop_1 [  49];
  assign rx_upstream_data    [ 127] = rx_phy_postflop_1 [  50];
  assign rx_upstream_data    [ 128] = rx_phy_postflop_1 [  51];
  assign rx_upstream_data    [ 129] = rx_phy_postflop_1 [  52];
  assign rx_upstream_data    [ 130] = rx_phy_postflop_1 [  53];
  assign rx_upstream_data    [ 131] = rx_phy_postflop_1 [  54];
  assign rx_upstream_data    [ 132] = rx_phy_postflop_1 [  55];
  assign rx_upstream_data    [ 133] = rx_phy_postflop_1 [  56];
  assign rx_upstream_data    [ 134] = rx_phy_postflop_1 [  57];
  assign rx_upstream_data    [ 135] = rx_phy_postflop_1 [  58];
  assign rx_upstream_data    [ 136] = rx_phy_postflop_1 [  59];
  assign rx_upstream_data    [ 137] = rx_phy_postflop_1 [  60];
  assign rx_upstream_data    [ 138] = rx_phy_postflop_1 [  61];
  assign rx_upstream_data    [ 139] = rx_phy_postflop_1 [  62];
  assign rx_upstream_data    [ 140] = rx_phy_postflop_1 [  63];
  assign rx_upstream_data    [ 141] = rx_phy_postflop_1 [  64];
  assign rx_upstream_data    [ 142] = rx_phy_postflop_1 [  65];
  assign rx_upstream_data    [ 143] = rx_phy_postflop_1 [  66];
  assign rx_upstream_data    [ 144] = rx_phy_postflop_1 [  67];
  assign rx_upstream_data    [ 145] = rx_phy_postflop_1 [  68];
  assign rx_upstream_data    [ 146] = rx_phy_postflop_1 [  69];
  assign rx_upstream_data    [ 147] = rx_phy_postflop_1 [  70];
  assign rx_upstream_data    [ 148] = rx_phy_postflop_1 [  71];
  assign rx_upstream_data    [ 149] = rx_phy_postflop_1 [  72];
  assign rx_upstream_data    [ 150] = rx_phy_postflop_1 [  73];
  assign rx_upstream_data    [ 151] = rx_phy_postflop_1 [  74];
  assign rx_upstream_data    [ 152] = rx_phy_postflop_1 [  75];
  assign rx_upstream_data    [ 153] = rx_phy_postflop_1 [  76];
//       MARKER                     = rx_phy_postflop_1 [  77]
  assign rx_upstream_data    [ 154] = rx_phy_postflop_1 [  78];
  assign rx_upstream_data    [ 155] = rx_phy_postflop_1 [  79];
  assign rx_upstream_data    [ 156] = rx_phy_postflop_2 [   0];
//       STROBE                     = rx_phy_postflop_2 [   1]
  assign rx_upstream_data    [ 157] = rx_phy_postflop_2 [   2];
  assign rx_upstream_data    [ 158] = rx_phy_postflop_2 [   3];
  assign rx_upstream_data    [ 159] = rx_phy_postflop_2 [   4];
  assign rx_upstream_data    [ 160] = rx_phy_postflop_2 [   5];
  assign rx_upstream_data    [ 161] = rx_phy_postflop_2 [   6];
  assign rx_upstream_data    [ 162] = rx_phy_postflop_2 [   7];
  assign rx_upstream_data    [ 163] = rx_phy_postflop_2 [   8];
  assign rx_upstream_data    [ 164] = rx_phy_postflop_2 [   9];
  assign rx_upstream_data    [ 165] = rx_phy_postflop_2 [  10];
  assign rx_upstream_data    [ 166] = rx_phy_postflop_2 [  11];
  assign rx_upstream_data    [ 167] = rx_phy_postflop_2 [  12];
  assign rx_upstream_data    [ 168] = rx_phy_postflop_2 [  13];
  assign rx_upstream_data    [ 169] = rx_phy_postflop_2 [  14];
  assign rx_upstream_data    [ 170] = rx_phy_postflop_2 [  15];
  assign rx_upstream_data    [ 171] = rx_phy_postflop_2 [  16];
  assign rx_upstream_data    [ 172] = rx_phy_postflop_2 [  17];
  assign rx_upstream_data    [ 173] = rx_phy_postflop_2 [  18];
  assign rx_upstream_data    [ 174] = rx_phy_postflop_2 [  19];
  assign rx_upstream_data    [ 175] = rx_phy_postflop_2 [  20];
  assign rx_upstream_data    [ 176] = rx_phy_postflop_2 [  21];
  assign rx_upstream_data    [ 177] = rx_phy_postflop_2 [  22];
  assign rx_upstream_data    [ 178] = rx_phy_postflop_2 [  23];
  assign rx_upstream_data    [ 179] = rx_phy_postflop_2 [  24];
  assign rx_upstream_data    [ 180] = rx_phy_postflop_2 [  25];
  assign rx_upstream_data    [ 181] = rx_phy_postflop_2 [  26];
  assign rx_upstream_data    [ 182] = rx_phy_postflop_2 [  27];
  assign rx_upstream_data    [ 183] = rx_phy_postflop_2 [  28];
  assign rx_upstream_data    [ 184] = rx_phy_postflop_2 [  29];
  assign rx_upstream_data    [ 185] = rx_phy_postflop_2 [  30];
  assign rx_upstream_data    [ 186] = rx_phy_postflop_2 [  31];
  assign rx_upstream_data    [ 187] = rx_phy_postflop_2 [  32];
  assign rx_upstream_data    [ 188] = rx_phy_postflop_2 [  33];
  assign rx_upstream_data    [ 189] = rx_phy_postflop_2 [  34];
  assign rx_upstream_data    [ 190] = rx_phy_postflop_2 [  35];
  assign rx_upstream_data    [ 191] = rx_phy_postflop_2 [  36];
  assign rx_upstream_data    [ 192] = rx_phy_postflop_2 [  37];
  assign rx_upstream_data    [ 193] = rx_phy_postflop_2 [  38];
  assign rx_upstream_data    [ 194] = rx_phy_postflop_2 [  39];
  assign rx_upstream_data    [ 195] = rx_phy_postflop_2 [  40];
  assign rx_upstream_data    [ 196] = rx_phy_postflop_2 [  41];
  assign rx_upstream_data    [ 197] = rx_phy_postflop_2 [  42];
  assign rx_upstream_data    [ 198] = rx_phy_postflop_2 [  43];
  assign rx_upstream_data    [ 199] = rx_phy_postflop_2 [  44];
  assign rx_upstream_data    [ 200] = rx_phy_postflop_2 [  45];
  assign rx_upstream_data    [ 201] = rx_phy_postflop_2 [  46];
  assign rx_upstream_data    [ 202] = rx_phy_postflop_2 [  47];
  assign rx_upstream_data    [ 203] = rx_phy_postflop_2 [  48];
  assign rx_upstream_data    [ 204] = rx_phy_postflop_2 [  49];
  assign rx_upstream_data    [ 205] = rx_phy_postflop_2 [  50];
  assign rx_upstream_data    [ 206] = rx_phy_postflop_2 [  51];
  assign rx_upstream_data    [ 207] = rx_phy_postflop_2 [  52];
  assign rx_upstream_data    [ 208] = rx_phy_postflop_2 [  53];
  assign rx_upstream_data    [ 209] = rx_phy_postflop_2 [  54];
  assign rx_upstream_data    [ 210] = rx_phy_postflop_2 [  55];
  assign rx_upstream_data    [ 211] = rx_phy_postflop_2 [  56];
  assign rx_upstream_data    [ 212] = rx_phy_postflop_2 [  57];
  assign rx_upstream_data    [ 213] = rx_phy_postflop_2 [  58];
  assign rx_upstream_data    [ 214] = rx_phy_postflop_2 [  59];
  assign rx_upstream_data    [ 215] = rx_phy_postflop_2 [  60];
  assign rx_upstream_data    [ 216] = rx_phy_postflop_2 [  61];
  assign rx_upstream_data    [ 217] = rx_phy_postflop_2 [  62];
  assign rx_upstream_data    [ 218] = rx_phy_postflop_2 [  63];
  assign rx_upstream_data    [ 219] = rx_phy_postflop_2 [  64];
  assign rx_upstream_data    [ 220] = rx_phy_postflop_2 [  65];
  assign rx_upstream_data    [ 221] = rx_phy_postflop_2 [  66];
  assign rx_upstream_data    [ 222] = rx_phy_postflop_2 [  67];
  assign rx_upstream_data    [ 223] = rx_phy_postflop_2 [  68];
  assign rx_upstream_data    [ 224] = rx_phy_postflop_2 [  69];
  assign rx_upstream_data    [ 225] = rx_phy_postflop_2 [  70];
  assign rx_upstream_data    [ 226] = rx_phy_postflop_2 [  71];
  assign rx_upstream_data    [ 227] = rx_phy_postflop_2 [  72];
  assign rx_upstream_data    [ 228] = rx_phy_postflop_2 [  73];
  assign rx_upstream_data    [ 229] = rx_phy_postflop_2 [  74];
  assign rx_upstream_data    [ 230] = rx_phy_postflop_2 [  75];
  assign rx_upstream_data    [ 231] = rx_phy_postflop_2 [  76];
//       MARKER                     = rx_phy_postflop_2 [  77]
  assign rx_upstream_data    [ 232] = rx_phy_postflop_2 [  78];
  assign rx_upstream_data    [ 233] = rx_phy_postflop_2 [  79];
  assign rx_upstream_data    [ 234] = rx_phy_postflop_3 [   0];
//       STROBE                     = rx_phy_postflop_3 [   1]
  assign rx_upstream_data    [ 235] = rx_phy_postflop_3 [   2];
  assign rx_upstream_data    [ 236] = rx_phy_postflop_3 [   3];
  assign rx_upstream_data    [ 237] = rx_phy_postflop_3 [   4];
  assign rx_upstream_data    [ 238] = rx_phy_postflop_3 [   5];
  assign rx_upstream_data    [ 239] = rx_phy_postflop_3 [   6];
  assign rx_upstream_data    [ 240] = rx_phy_postflop_3 [   7];
  assign rx_upstream_data    [ 241] = rx_phy_postflop_3 [   8];
  assign rx_upstream_data    [ 242] = rx_phy_postflop_3 [   9];
  assign rx_upstream_data    [ 243] = rx_phy_postflop_3 [  10];
  assign rx_upstream_data    [ 244] = rx_phy_postflop_3 [  11];
  assign rx_upstream_data    [ 245] = rx_phy_postflop_3 [  12];
  assign rx_upstream_data    [ 246] = rx_phy_postflop_3 [  13];
  assign rx_upstream_data    [ 247] = rx_phy_postflop_3 [  14];
  assign rx_upstream_data    [ 248] = rx_phy_postflop_3 [  15];
  assign rx_upstream_data    [ 249] = rx_phy_postflop_3 [  16];
  assign rx_upstream_data    [ 250] = rx_phy_postflop_3 [  17];
  assign rx_upstream_data    [ 251] = rx_phy_postflop_3 [  18];
  assign rx_upstream_data    [ 252] = rx_phy_postflop_3 [  19];
  assign rx_upstream_data    [ 253] = rx_phy_postflop_3 [  20];
  assign rx_upstream_data    [ 254] = rx_phy_postflop_3 [  21];
  assign rx_upstream_data    [ 255] = rx_phy_postflop_3 [  22];
  assign rx_upstream_data    [ 256] = rx_phy_postflop_3 [  23];
  assign rx_upstream_data    [ 257] = rx_phy_postflop_3 [  24];
  assign rx_upstream_data    [ 258] = rx_phy_postflop_3 [  25];
  assign rx_upstream_data    [ 259] = rx_phy_postflop_3 [  26];
  assign rx_upstream_data    [ 260] = rx_phy_postflop_3 [  27];
  assign rx_upstream_data    [ 261] = rx_phy_postflop_3 [  28];
  assign rx_upstream_data    [ 262] = rx_phy_postflop_3 [  29];
  assign rx_upstream_data    [ 263] = rx_phy_postflop_3 [  30];
  assign rx_upstream_data    [ 264] = rx_phy_postflop_3 [  31];
  assign rx_upstream_data    [ 265] = rx_phy_postflop_3 [  32];
  assign rx_upstream_data    [ 266] = rx_phy_postflop_3 [  33];
  assign rx_upstream_data    [ 267] = rx_phy_postflop_3 [  34];
  assign rx_upstream_data    [ 268] = rx_phy_postflop_3 [  35];
  assign rx_upstream_data    [ 269] = rx_phy_postflop_3 [  36];
  assign rx_upstream_data    [ 270] = rx_phy_postflop_3 [  37];
  assign rx_upstream_data    [ 271] = rx_phy_postflop_3 [  38];
  assign rx_upstream_data    [ 272] = rx_phy_postflop_3 [  39];
  assign rx_upstream_data    [ 273] = rx_phy_postflop_3 [  40];
  assign rx_upstream_data    [ 274] = rx_phy_postflop_3 [  41];
  assign rx_upstream_data    [ 275] = rx_phy_postflop_3 [  42];
  assign rx_upstream_data    [ 276] = rx_phy_postflop_3 [  43];
  assign rx_upstream_data    [ 277] = rx_phy_postflop_3 [  44];
  assign rx_upstream_data    [ 278] = rx_phy_postflop_3 [  45];
  assign rx_upstream_data    [ 279] = rx_phy_postflop_3 [  46];
  assign rx_upstream_data    [ 280] = rx_phy_postflop_3 [  47];
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
//       nc                         = rx_phy_postflop_3 [  76];
//       MARKER                     = rx_phy_postflop_3 [  77]
//       nc                         = rx_phy_postflop_3 [  78];
//       nc                         = rx_phy_postflop_3 [  79];

// RX Section
//////////////////////////////////////////////////////////////////


endmodule
