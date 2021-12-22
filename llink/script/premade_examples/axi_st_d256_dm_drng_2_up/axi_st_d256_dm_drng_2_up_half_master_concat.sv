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

module axi_st_d256_dm_drng_2_up_half_master_concat  (

// Data from Logic Links
  input  logic [ 511:   0]   tx_st_data          ,
  output logic               tx_st_pop_ovrd      ,
  input  logic               tx_st_pushbit       ,
  output logic [   3:   0]   rx_st_credit        ,

// PHY Interconnect
  output logic [  79:   0]   tx_phy0             ,
  input  logic [  79:   0]   rx_phy0             ,
  output logic [  79:   0]   tx_phy1             ,
  input  logic [  79:   0]   rx_phy1             ,
  output logic [  79:   0]   tx_phy2             ,
  input  logic [  79:   0]   rx_phy2             ,
  output logic [  79:   0]   tx_phy3             ,
  input  logic [  79:   0]   rx_phy3             ,
  output logic [  79:   0]   tx_phy4             ,
  input  logic [  79:   0]   rx_phy4             ,
  output logic [  79:   0]   tx_phy5             ,
  input  logic [  79:   0]   rx_phy5             ,
  output logic [  79:   0]   tx_phy6             ,
  input  logic [  79:   0]   rx_phy6             ,

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

//   TX_CH_WIDTH           = 80; // Gen1Only running at Half Rate
//   TX_DATA_WIDTH         = 76; // Usable Data per Channel
//   TX_PERSISTENT_STROBE  = 1'b1;
//   TX_PERSISTENT_MARKER  = 1'b1;
//   TX_STROBE_GEN2_LOC    = 'd1;
//   TX_MARKER_GEN2_LOC    = 'd39;
//   TX_STROBE_GEN1_LOC    = 'd1;
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
  logic [  79:   0]                              tx_phy_preflop_4              ;
  logic [  79:   0]                              tx_phy_preflop_5              ;
  logic [  79:   0]                              tx_phy_preflop_6              ;
  logic [  79:   0]                              tx_phy_flop_0_reg             ;
  logic [  79:   0]                              tx_phy_flop_1_reg             ;
  logic [  79:   0]                              tx_phy_flop_2_reg             ;
  logic [  79:   0]                              tx_phy_flop_3_reg             ;
  logic [  79:   0]                              tx_phy_flop_4_reg             ;
  logic [  79:   0]                              tx_phy_flop_5_reg             ;
  logic [  79:   0]                              tx_phy_flop_6_reg             ;

  always_ff @(posedge clk_wr or negedge rst_wr_n)
  if (~rst_wr_n)
  begin
    tx_phy_flop_0_reg                       <= 80'b0                                   ;
    tx_phy_flop_1_reg                       <= 80'b0                                   ;
    tx_phy_flop_2_reg                       <= 80'b0                                   ;
    tx_phy_flop_3_reg                       <= 80'b0                                   ;
    tx_phy_flop_4_reg                       <= 80'b0                                   ;
    tx_phy_flop_5_reg                       <= 80'b0                                   ;
    tx_phy_flop_6_reg                       <= 80'b0                                   ;
  end
  else
  begin
    tx_phy_flop_0_reg                       <= tx_phy_preflop_0                        ;
    tx_phy_flop_1_reg                       <= tx_phy_preflop_1                        ;
    tx_phy_flop_2_reg                       <= tx_phy_preflop_2                        ;
    tx_phy_flop_3_reg                       <= tx_phy_preflop_3                        ;
    tx_phy_flop_4_reg                       <= tx_phy_preflop_4                        ;
    tx_phy_flop_5_reg                       <= tx_phy_preflop_5                        ;
    tx_phy_flop_6_reg                       <= tx_phy_preflop_6                        ;
  end

  assign tx_phy0                            = TX_REG_PHY ? tx_phy_flop_0_reg : tx_phy_preflop_0               ;
  assign tx_phy1                            = TX_REG_PHY ? tx_phy_flop_1_reg : tx_phy_preflop_1               ;
  assign tx_phy2                            = TX_REG_PHY ? tx_phy_flop_2_reg : tx_phy_preflop_2               ;
  assign tx_phy3                            = TX_REG_PHY ? tx_phy_flop_3_reg : tx_phy_preflop_3               ;
  assign tx_phy4                            = TX_REG_PHY ? tx_phy_flop_4_reg : tx_phy_preflop_4               ;
  assign tx_phy5                            = TX_REG_PHY ? tx_phy_flop_5_reg : tx_phy_preflop_5               ;
  assign tx_phy6                            = TX_REG_PHY ? tx_phy_flop_6_reg : tx_phy_preflop_6               ;

  logic                                          tx_st_pushbit_r0              ;
  logic                                          tx_st_pushbit_r1              ;

  assign tx_st_pushbit_r0                   = tx_st_pushbit                      ;
  assign tx_st_pushbit_r1                   = tx_st_pushbit                      ;

  assign tx_phy_preflop_0 [   0] = tx_st_pushbit_r0           ;
  assign tx_phy_preflop_0 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_0 [   2] = tx_st_data          [   0] ;
  assign tx_phy_preflop_0 [   3] = tx_st_data          [   1] ;
  assign tx_phy_preflop_0 [   4] = tx_st_data          [   2] ;
  assign tx_phy_preflop_0 [   5] = tx_st_data          [   3] ;
  assign tx_phy_preflop_0 [   6] = tx_st_data          [   4] ;
  assign tx_phy_preflop_0 [   7] = tx_st_data          [   5] ;
  assign tx_phy_preflop_0 [   8] = tx_st_data          [   6] ;
  assign tx_phy_preflop_0 [   9] = tx_st_data          [   7] ;
  assign tx_phy_preflop_0 [  10] = tx_st_data          [   8] ;
  assign tx_phy_preflop_0 [  11] = tx_st_data          [   9] ;
  assign tx_phy_preflop_0 [  12] = tx_st_data          [  10] ;
  assign tx_phy_preflop_0 [  13] = tx_st_data          [  11] ;
  assign tx_phy_preflop_0 [  14] = tx_st_data          [  12] ;
  assign tx_phy_preflop_0 [  15] = tx_st_data          [  13] ;
  assign tx_phy_preflop_0 [  16] = tx_st_data          [  14] ;
  assign tx_phy_preflop_0 [  17] = tx_st_data          [  15] ;
  assign tx_phy_preflop_0 [  18] = tx_st_data          [  16] ;
  assign tx_phy_preflop_0 [  19] = tx_st_data          [  17] ;
  assign tx_phy_preflop_0 [  20] = tx_st_data          [  18] ;
  assign tx_phy_preflop_0 [  21] = tx_st_data          [  19] ;
  assign tx_phy_preflop_0 [  22] = tx_st_data          [  20] ;
  assign tx_phy_preflop_0 [  23] = tx_st_data          [  21] ;
  assign tx_phy_preflop_0 [  24] = tx_st_data          [  22] ;
  assign tx_phy_preflop_0 [  25] = tx_st_data          [  23] ;
  assign tx_phy_preflop_0 [  26] = tx_st_data          [  24] ;
  assign tx_phy_preflop_0 [  27] = tx_st_data          [  25] ;
  assign tx_phy_preflop_0 [  28] = tx_st_data          [  26] ;
  assign tx_phy_preflop_0 [  29] = tx_st_data          [  27] ;
  assign tx_phy_preflop_0 [  30] = tx_st_data          [  28] ;
  assign tx_phy_preflop_0 [  31] = tx_st_data          [  29] ;
  assign tx_phy_preflop_0 [  32] = tx_st_data          [  30] ;
  assign tx_phy_preflop_0 [  33] = tx_st_data          [  31] ;
  assign tx_phy_preflop_0 [  34] = tx_st_data          [  32] ;
  assign tx_phy_preflop_0 [  35] = tx_st_data          [  33] ;
  assign tx_phy_preflop_0 [  36] = tx_st_data          [  34] ;
  assign tx_phy_preflop_0 [  37] = tx_st_data          [  35] ;
  assign tx_phy_preflop_0 [  38] = tx_st_data          [  36] ;
  assign tx_phy_preflop_0 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_1 [   0] = tx_st_data          [  37] ;
  assign tx_phy_preflop_1 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_1 [   2] = tx_st_data          [  38] ;
  assign tx_phy_preflop_1 [   3] = tx_st_data          [  39] ;
  assign tx_phy_preflop_1 [   4] = tx_st_data          [  40] ;
  assign tx_phy_preflop_1 [   5] = tx_st_data          [  41] ;
  assign tx_phy_preflop_1 [   6] = tx_st_data          [  42] ;
  assign tx_phy_preflop_1 [   7] = tx_st_data          [  43] ;
  assign tx_phy_preflop_1 [   8] = tx_st_data          [  44] ;
  assign tx_phy_preflop_1 [   9] = tx_st_data          [  45] ;
  assign tx_phy_preflop_1 [  10] = tx_st_data          [  46] ;
  assign tx_phy_preflop_1 [  11] = tx_st_data          [  47] ;
  assign tx_phy_preflop_1 [  12] = tx_st_data          [  48] ;
  assign tx_phy_preflop_1 [  13] = tx_st_data          [  49] ;
  assign tx_phy_preflop_1 [  14] = tx_st_data          [  50] ;
  assign tx_phy_preflop_1 [  15] = tx_st_data          [  51] ;
  assign tx_phy_preflop_1 [  16] = tx_st_data          [  52] ;
  assign tx_phy_preflop_1 [  17] = tx_st_data          [  53] ;
  assign tx_phy_preflop_1 [  18] = tx_st_data          [  54] ;
  assign tx_phy_preflop_1 [  19] = tx_st_data          [  55] ;
  assign tx_phy_preflop_1 [  20] = tx_st_data          [  56] ;
  assign tx_phy_preflop_1 [  21] = tx_st_data          [  57] ;
  assign tx_phy_preflop_1 [  22] = tx_st_data          [  58] ;
  assign tx_phy_preflop_1 [  23] = tx_st_data          [  59] ;
  assign tx_phy_preflop_1 [  24] = tx_st_data          [  60] ;
  assign tx_phy_preflop_1 [  25] = tx_st_data          [  61] ;
  assign tx_phy_preflop_1 [  26] = tx_st_data          [  62] ;
  assign tx_phy_preflop_1 [  27] = tx_st_data          [  63] ;
  assign tx_phy_preflop_1 [  28] = tx_st_data          [  64] ;
  assign tx_phy_preflop_1 [  29] = tx_st_data          [  65] ;
  assign tx_phy_preflop_1 [  30] = tx_st_data          [  66] ;
  assign tx_phy_preflop_1 [  31] = tx_st_data          [  67] ;
  assign tx_phy_preflop_1 [  32] = tx_st_data          [  68] ;
  assign tx_phy_preflop_1 [  33] = tx_st_data          [  69] ;
  assign tx_phy_preflop_1 [  34] = tx_st_data          [  70] ;
  assign tx_phy_preflop_1 [  35] = tx_st_data          [  71] ;
  assign tx_phy_preflop_1 [  36] = tx_st_data          [  72] ;
  assign tx_phy_preflop_1 [  37] = tx_st_data          [  73] ;
  assign tx_phy_preflop_1 [  38] = tx_st_data          [  74] ;
  assign tx_phy_preflop_1 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_2 [   0] = tx_st_data          [  75] ;
  assign tx_phy_preflop_2 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_2 [   2] = tx_st_data          [  76] ;
  assign tx_phy_preflop_2 [   3] = tx_st_data          [  77] ;
  assign tx_phy_preflop_2 [   4] = tx_st_data          [  78] ;
  assign tx_phy_preflop_2 [   5] = tx_st_data          [  79] ;
  assign tx_phy_preflop_2 [   6] = tx_st_data          [  80] ;
  assign tx_phy_preflop_2 [   7] = tx_st_data          [  81] ;
  assign tx_phy_preflop_2 [   8] = tx_st_data          [  82] ;
  assign tx_phy_preflop_2 [   9] = tx_st_data          [  83] ;
  assign tx_phy_preflop_2 [  10] = tx_st_data          [  84] ;
  assign tx_phy_preflop_2 [  11] = tx_st_data          [  85] ;
  assign tx_phy_preflop_2 [  12] = tx_st_data          [  86] ;
  assign tx_phy_preflop_2 [  13] = tx_st_data          [  87] ;
  assign tx_phy_preflop_2 [  14] = tx_st_data          [  88] ;
  assign tx_phy_preflop_2 [  15] = tx_st_data          [  89] ;
  assign tx_phy_preflop_2 [  16] = tx_st_data          [  90] ;
  assign tx_phy_preflop_2 [  17] = tx_st_data          [  91] ;
  assign tx_phy_preflop_2 [  18] = tx_st_data          [  92] ;
  assign tx_phy_preflop_2 [  19] = tx_st_data          [  93] ;
  assign tx_phy_preflop_2 [  20] = tx_st_data          [  94] ;
  assign tx_phy_preflop_2 [  21] = tx_st_data          [  95] ;
  assign tx_phy_preflop_2 [  22] = tx_st_data          [  96] ;
  assign tx_phy_preflop_2 [  23] = tx_st_data          [  97] ;
  assign tx_phy_preflop_2 [  24] = tx_st_data          [  98] ;
  assign tx_phy_preflop_2 [  25] = tx_st_data          [  99] ;
  assign tx_phy_preflop_2 [  26] = tx_st_data          [ 100] ;
  assign tx_phy_preflop_2 [  27] = tx_st_data          [ 101] ;
  assign tx_phy_preflop_2 [  28] = tx_st_data          [ 102] ;
  assign tx_phy_preflop_2 [  29] = tx_st_data          [ 103] ;
  assign tx_phy_preflop_2 [  30] = tx_st_data          [ 104] ;
  assign tx_phy_preflop_2 [  31] = tx_st_data          [ 105] ;
  assign tx_phy_preflop_2 [  32] = tx_st_data          [ 106] ;
  assign tx_phy_preflop_2 [  33] = tx_st_data          [ 107] ;
  assign tx_phy_preflop_2 [  34] = tx_st_data          [ 108] ;
  assign tx_phy_preflop_2 [  35] = tx_st_data          [ 109] ;
  assign tx_phy_preflop_2 [  36] = tx_st_data          [ 110] ;
  assign tx_phy_preflop_2 [  37] = tx_st_data          [ 111] ;
  assign tx_phy_preflop_2 [  38] = tx_st_data          [ 112] ;
  assign tx_phy_preflop_2 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_3 [   0] = tx_st_data          [ 113] ;
  assign tx_phy_preflop_3 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_3 [   2] = tx_st_data          [ 114] ;
  assign tx_phy_preflop_3 [   3] = tx_st_data          [ 115] ;
  assign tx_phy_preflop_3 [   4] = tx_st_data          [ 116] ;
  assign tx_phy_preflop_3 [   5] = tx_st_data          [ 117] ;
  assign tx_phy_preflop_3 [   6] = tx_st_data          [ 118] ;
  assign tx_phy_preflop_3 [   7] = tx_st_data          [ 119] ;
  assign tx_phy_preflop_3 [   8] = tx_st_data          [ 120] ;
  assign tx_phy_preflop_3 [   9] = tx_st_data          [ 121] ;
  assign tx_phy_preflop_3 [  10] = tx_st_data          [ 122] ;
  assign tx_phy_preflop_3 [  11] = tx_st_data          [ 123] ;
  assign tx_phy_preflop_3 [  12] = tx_st_data          [ 124] ;
  assign tx_phy_preflop_3 [  13] = tx_st_data          [ 125] ;
  assign tx_phy_preflop_3 [  14] = tx_st_data          [ 126] ;
  assign tx_phy_preflop_3 [  15] = tx_st_data          [ 127] ;
  assign tx_phy_preflop_3 [  16] = tx_st_data          [ 128] ;
  assign tx_phy_preflop_3 [  17] = tx_st_data          [ 129] ;
  assign tx_phy_preflop_3 [  18] = tx_st_data          [ 130] ;
  assign tx_phy_preflop_3 [  19] = tx_st_data          [ 131] ;
  assign tx_phy_preflop_3 [  20] = tx_st_data          [ 132] ;
  assign tx_phy_preflop_3 [  21] = tx_st_data          [ 133] ;
  assign tx_phy_preflop_3 [  22] = tx_st_data          [ 134] ;
  assign tx_phy_preflop_3 [  23] = tx_st_data          [ 135] ;
  assign tx_phy_preflop_3 [  24] = tx_st_data          [ 136] ;
  assign tx_phy_preflop_3 [  25] = tx_st_data          [ 137] ;
  assign tx_phy_preflop_3 [  26] = tx_st_data          [ 138] ;
  assign tx_phy_preflop_3 [  27] = tx_st_data          [ 139] ;
  assign tx_phy_preflop_3 [  28] = tx_st_data          [ 140] ;
  assign tx_phy_preflop_3 [  29] = tx_st_data          [ 141] ;
  assign tx_phy_preflop_3 [  30] = tx_st_data          [ 142] ;
  assign tx_phy_preflop_3 [  31] = tx_st_data          [ 143] ;
  assign tx_phy_preflop_3 [  32] = tx_st_data          [ 144] ;
  assign tx_phy_preflop_3 [  33] = tx_st_data          [ 145] ;
  assign tx_phy_preflop_3 [  34] = tx_st_data          [ 146] ;
  assign tx_phy_preflop_3 [  35] = tx_st_data          [ 147] ;
  assign tx_phy_preflop_3 [  36] = tx_st_data          [ 148] ;
  assign tx_phy_preflop_3 [  37] = tx_st_data          [ 149] ;
  assign tx_phy_preflop_3 [  38] = tx_st_data          [ 150] ;
  assign tx_phy_preflop_3 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_4 [   0] = tx_st_data          [ 151] ;
  assign tx_phy_preflop_4 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_4 [   2] = tx_st_data          [ 152] ;
  assign tx_phy_preflop_4 [   3] = tx_st_data          [ 153] ;
  assign tx_phy_preflop_4 [   4] = tx_st_data          [ 154] ;
  assign tx_phy_preflop_4 [   5] = tx_st_data          [ 155] ;
  assign tx_phy_preflop_4 [   6] = tx_st_data          [ 156] ;
  assign tx_phy_preflop_4 [   7] = tx_st_data          [ 157] ;
  assign tx_phy_preflop_4 [   8] = tx_st_data          [ 158] ;
  assign tx_phy_preflop_4 [   9] = tx_st_data          [ 159] ;
  assign tx_phy_preflop_4 [  10] = tx_st_data          [ 160] ;
  assign tx_phy_preflop_4 [  11] = tx_st_data          [ 161] ;
  assign tx_phy_preflop_4 [  12] = tx_st_data          [ 162] ;
  assign tx_phy_preflop_4 [  13] = tx_st_data          [ 163] ;
  assign tx_phy_preflop_4 [  14] = tx_st_data          [ 164] ;
  assign tx_phy_preflop_4 [  15] = tx_st_data          [ 165] ;
  assign tx_phy_preflop_4 [  16] = tx_st_data          [ 166] ;
  assign tx_phy_preflop_4 [  17] = tx_st_data          [ 167] ;
  assign tx_phy_preflop_4 [  18] = tx_st_data          [ 168] ;
  assign tx_phy_preflop_4 [  19] = tx_st_data          [ 169] ;
  assign tx_phy_preflop_4 [  20] = tx_st_data          [ 170] ;
  assign tx_phy_preflop_4 [  21] = tx_st_data          [ 171] ;
  assign tx_phy_preflop_4 [  22] = tx_st_data          [ 172] ;
  assign tx_phy_preflop_4 [  23] = tx_st_data          [ 173] ;
  assign tx_phy_preflop_4 [  24] = tx_st_data          [ 174] ;
  assign tx_phy_preflop_4 [  25] = tx_st_data          [ 175] ;
  assign tx_phy_preflop_4 [  26] = tx_st_data          [ 176] ;
  assign tx_phy_preflop_4 [  27] = tx_st_data          [ 177] ;
  assign tx_phy_preflop_4 [  28] = tx_st_data          [ 178] ;
  assign tx_phy_preflop_4 [  29] = tx_st_data          [ 179] ;
  assign tx_phy_preflop_4 [  30] = tx_st_data          [ 180] ;
  assign tx_phy_preflop_4 [  31] = tx_st_data          [ 181] ;
  assign tx_phy_preflop_4 [  32] = tx_st_data          [ 182] ;
  assign tx_phy_preflop_4 [  33] = tx_st_data          [ 183] ;
  assign tx_phy_preflop_4 [  34] = tx_st_data          [ 184] ;
  assign tx_phy_preflop_4 [  35] = tx_st_data          [ 185] ;
  assign tx_phy_preflop_4 [  36] = tx_st_data          [ 186] ;
  assign tx_phy_preflop_4 [  37] = tx_st_data          [ 187] ;
  assign tx_phy_preflop_4 [  38] = tx_st_data          [ 188] ;
  assign tx_phy_preflop_4 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_5 [   0] = tx_st_data          [ 189] ;
  assign tx_phy_preflop_5 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_5 [   2] = tx_st_data          [ 190] ;
  assign tx_phy_preflop_5 [   3] = tx_st_data          [ 191] ;
  assign tx_phy_preflop_5 [   4] = tx_st_data          [ 192] ;
  assign tx_phy_preflop_5 [   5] = tx_st_data          [ 193] ;
  assign tx_phy_preflop_5 [   6] = tx_st_data          [ 194] ;
  assign tx_phy_preflop_5 [   7] = tx_st_data          [ 195] ;
  assign tx_phy_preflop_5 [   8] = tx_st_data          [ 196] ;
  assign tx_phy_preflop_5 [   9] = tx_st_data          [ 197] ;
  assign tx_phy_preflop_5 [  10] = tx_st_data          [ 198] ;
  assign tx_phy_preflop_5 [  11] = tx_st_data          [ 199] ;
  assign tx_phy_preflop_5 [  12] = tx_st_data          [ 200] ;
  assign tx_phy_preflop_5 [  13] = tx_st_data          [ 201] ;
  assign tx_phy_preflop_5 [  14] = tx_st_data          [ 202] ;
  assign tx_phy_preflop_5 [  15] = tx_st_data          [ 203] ;
  assign tx_phy_preflop_5 [  16] = tx_st_data          [ 204] ;
  assign tx_phy_preflop_5 [  17] = tx_st_data          [ 205] ;
  assign tx_phy_preflop_5 [  18] = tx_st_data          [ 206] ;
  assign tx_phy_preflop_5 [  19] = tx_st_data          [ 207] ;
  assign tx_phy_preflop_5 [  20] = tx_st_data          [ 208] ;
  assign tx_phy_preflop_5 [  21] = tx_st_data          [ 209] ;
  assign tx_phy_preflop_5 [  22] = tx_st_data          [ 210] ;
  assign tx_phy_preflop_5 [  23] = tx_st_data          [ 211] ;
  assign tx_phy_preflop_5 [  24] = tx_st_data          [ 212] ;
  assign tx_phy_preflop_5 [  25] = tx_st_data          [ 213] ;
  assign tx_phy_preflop_5 [  26] = tx_st_data          [ 214] ;
  assign tx_phy_preflop_5 [  27] = tx_st_data          [ 215] ;
  assign tx_phy_preflop_5 [  28] = tx_st_data          [ 216] ;
  assign tx_phy_preflop_5 [  29] = tx_st_data          [ 217] ;
  assign tx_phy_preflop_5 [  30] = tx_st_data          [ 218] ;
  assign tx_phy_preflop_5 [  31] = tx_st_data          [ 219] ;
  assign tx_phy_preflop_5 [  32] = tx_st_data          [ 220] ;
  assign tx_phy_preflop_5 [  33] = tx_st_data          [ 221] ;
  assign tx_phy_preflop_5 [  34] = tx_st_data          [ 222] ;
  assign tx_phy_preflop_5 [  35] = tx_st_data          [ 223] ;
  assign tx_phy_preflop_5 [  36] = tx_st_data          [ 224] ;
  assign tx_phy_preflop_5 [  37] = tx_st_data          [ 225] ;
  assign tx_phy_preflop_5 [  38] = tx_st_data          [ 226] ;
  assign tx_phy_preflop_5 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_6 [   0] = tx_st_data          [ 227] ;
  assign tx_phy_preflop_6 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_6 [   2] = tx_st_data          [ 228] ;
  assign tx_phy_preflop_6 [   3] = tx_st_data          [ 229] ;
  assign tx_phy_preflop_6 [   4] = tx_st_data          [ 230] ;
  assign tx_phy_preflop_6 [   5] = tx_st_data          [ 231] ;
  assign tx_phy_preflop_6 [   6] = tx_st_data          [ 232] ;
  assign tx_phy_preflop_6 [   7] = tx_st_data          [ 233] ;
  assign tx_phy_preflop_6 [   8] = tx_st_data          [ 234] ;
  assign tx_phy_preflop_6 [   9] = tx_st_data          [ 235] ;
  assign tx_phy_preflop_6 [  10] = tx_st_data          [ 236] ;
  assign tx_phy_preflop_6 [  11] = tx_st_data          [ 237] ;
  assign tx_phy_preflop_6 [  12] = tx_st_data          [ 238] ;
  assign tx_phy_preflop_6 [  13] = tx_st_data          [ 239] ;
  assign tx_phy_preflop_6 [  14] = tx_st_data          [ 240] ;
  assign tx_phy_preflop_6 [  15] = tx_st_data          [ 241] ;
  assign tx_phy_preflop_6 [  16] = tx_st_data          [ 242] ;
  assign tx_phy_preflop_6 [  17] = tx_st_data          [ 243] ;
  assign tx_phy_preflop_6 [  18] = tx_st_data          [ 244] ;
  assign tx_phy_preflop_6 [  19] = tx_st_data          [ 245] ;
  assign tx_phy_preflop_6 [  20] = tx_st_data          [ 246] ;
  assign tx_phy_preflop_6 [  21] = tx_st_data          [ 247] ;
  assign tx_phy_preflop_6 [  22] = tx_st_data          [ 248] ;
  assign tx_phy_preflop_6 [  23] = tx_st_data          [ 249] ;
  assign tx_phy_preflop_6 [  24] = tx_st_data          [ 250] ;
  assign tx_phy_preflop_6 [  25] = tx_st_data          [ 251] ;
  assign tx_phy_preflop_6 [  26] = tx_st_data          [ 252] ;
  assign tx_phy_preflop_6 [  27] = tx_st_data          [ 253] ;
  assign tx_phy_preflop_6 [  28] = tx_st_data          [ 254] ;
  assign tx_phy_preflop_6 [  29] = tx_st_data          [ 255] ;
  assign tx_phy_preflop_6 [  30] = 1'b0                       ;
  assign tx_phy_preflop_6 [  31] = 1'b0                       ;
  assign tx_phy_preflop_6 [  32] = 1'b0                       ;
  assign tx_phy_preflop_6 [  33] = 1'b0                       ;
  assign tx_phy_preflop_6 [  34] = 1'b0                       ;
  assign tx_phy_preflop_6 [  35] = 1'b0                       ;
  assign tx_phy_preflop_6 [  36] = 1'b0                       ;
  assign tx_phy_preflop_6 [  37] = 1'b0                       ;
  assign tx_phy_preflop_6 [  38] = 1'b0                       ;
  assign tx_phy_preflop_6 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_0 [  40] = tx_st_pushbit_r1           ;
  assign tx_phy_preflop_0 [  41] = 1'b0                       ; // STROBE (unused)
  assign tx_phy_preflop_0 [  42] = tx_st_data          [ 256] ;
  assign tx_phy_preflop_0 [  43] = tx_st_data          [ 257] ;
  assign tx_phy_preflop_0 [  44] = tx_st_data          [ 258] ;
  assign tx_phy_preflop_0 [  45] = tx_st_data          [ 259] ;
  assign tx_phy_preflop_0 [  46] = tx_st_data          [ 260] ;
  assign tx_phy_preflop_0 [  47] = tx_st_data          [ 261] ;
  assign tx_phy_preflop_0 [  48] = tx_st_data          [ 262] ;
  assign tx_phy_preflop_0 [  49] = tx_st_data          [ 263] ;
  assign tx_phy_preflop_0 [  50] = tx_st_data          [ 264] ;
  assign tx_phy_preflop_0 [  51] = tx_st_data          [ 265] ;
  assign tx_phy_preflop_0 [  52] = tx_st_data          [ 266] ;
  assign tx_phy_preflop_0 [  53] = tx_st_data          [ 267] ;
  assign tx_phy_preflop_0 [  54] = tx_st_data          [ 268] ;
  assign tx_phy_preflop_0 [  55] = tx_st_data          [ 269] ;
  assign tx_phy_preflop_0 [  56] = tx_st_data          [ 270] ;
  assign tx_phy_preflop_0 [  57] = tx_st_data          [ 271] ;
  assign tx_phy_preflop_0 [  58] = tx_st_data          [ 272] ;
  assign tx_phy_preflop_0 [  59] = tx_st_data          [ 273] ;
  assign tx_phy_preflop_0 [  60] = tx_st_data          [ 274] ;
  assign tx_phy_preflop_0 [  61] = tx_st_data          [ 275] ;
  assign tx_phy_preflop_0 [  62] = tx_st_data          [ 276] ;
  assign tx_phy_preflop_0 [  63] = tx_st_data          [ 277] ;
  assign tx_phy_preflop_0 [  64] = tx_st_data          [ 278] ;
  assign tx_phy_preflop_0 [  65] = tx_st_data          [ 279] ;
  assign tx_phy_preflop_0 [  66] = tx_st_data          [ 280] ;
  assign tx_phy_preflop_0 [  67] = tx_st_data          [ 281] ;
  assign tx_phy_preflop_0 [  68] = tx_st_data          [ 282] ;
  assign tx_phy_preflop_0 [  69] = tx_st_data          [ 283] ;
  assign tx_phy_preflop_0 [  70] = tx_st_data          [ 284] ;
  assign tx_phy_preflop_0 [  71] = tx_st_data          [ 285] ;
  assign tx_phy_preflop_0 [  72] = tx_st_data          [ 286] ;
  assign tx_phy_preflop_0 [  73] = tx_st_data          [ 287] ;
  assign tx_phy_preflop_0 [  74] = tx_st_data          [ 288] ;
  assign tx_phy_preflop_0 [  75] = tx_st_data          [ 289] ;
  assign tx_phy_preflop_0 [  76] = tx_st_data          [ 290] ;
  assign tx_phy_preflop_0 [  77] = tx_st_data          [ 291] ;
  assign tx_phy_preflop_0 [  78] = tx_st_data          [ 292] ;
  assign tx_phy_preflop_0 [  79] = tx_mrk_userbit[1]          ; // MARKER
  assign tx_phy_preflop_1 [  40] = tx_st_data          [ 293] ;
  assign tx_phy_preflop_1 [  41] = 1'b0                       ; // STROBE (unused)
  assign tx_phy_preflop_1 [  42] = tx_st_data          [ 294] ;
  assign tx_phy_preflop_1 [  43] = tx_st_data          [ 295] ;
  assign tx_phy_preflop_1 [  44] = tx_st_data          [ 296] ;
  assign tx_phy_preflop_1 [  45] = tx_st_data          [ 297] ;
  assign tx_phy_preflop_1 [  46] = tx_st_data          [ 298] ;
  assign tx_phy_preflop_1 [  47] = tx_st_data          [ 299] ;
  assign tx_phy_preflop_1 [  48] = tx_st_data          [ 300] ;
  assign tx_phy_preflop_1 [  49] = tx_st_data          [ 301] ;
  assign tx_phy_preflop_1 [  50] = tx_st_data          [ 302] ;
  assign tx_phy_preflop_1 [  51] = tx_st_data          [ 303] ;
  assign tx_phy_preflop_1 [  52] = tx_st_data          [ 304] ;
  assign tx_phy_preflop_1 [  53] = tx_st_data          [ 305] ;
  assign tx_phy_preflop_1 [  54] = tx_st_data          [ 306] ;
  assign tx_phy_preflop_1 [  55] = tx_st_data          [ 307] ;
  assign tx_phy_preflop_1 [  56] = tx_st_data          [ 308] ;
  assign tx_phy_preflop_1 [  57] = tx_st_data          [ 309] ;
  assign tx_phy_preflop_1 [  58] = tx_st_data          [ 310] ;
  assign tx_phy_preflop_1 [  59] = tx_st_data          [ 311] ;
  assign tx_phy_preflop_1 [  60] = tx_st_data          [ 312] ;
  assign tx_phy_preflop_1 [  61] = tx_st_data          [ 313] ;
  assign tx_phy_preflop_1 [  62] = tx_st_data          [ 314] ;
  assign tx_phy_preflop_1 [  63] = tx_st_data          [ 315] ;
  assign tx_phy_preflop_1 [  64] = tx_st_data          [ 316] ;
  assign tx_phy_preflop_1 [  65] = tx_st_data          [ 317] ;
  assign tx_phy_preflop_1 [  66] = tx_st_data          [ 318] ;
  assign tx_phy_preflop_1 [  67] = tx_st_data          [ 319] ;
  assign tx_phy_preflop_1 [  68] = tx_st_data          [ 320] ;
  assign tx_phy_preflop_1 [  69] = tx_st_data          [ 321] ;
  assign tx_phy_preflop_1 [  70] = tx_st_data          [ 322] ;
  assign tx_phy_preflop_1 [  71] = tx_st_data          [ 323] ;
  assign tx_phy_preflop_1 [  72] = tx_st_data          [ 324] ;
  assign tx_phy_preflop_1 [  73] = tx_st_data          [ 325] ;
  assign tx_phy_preflop_1 [  74] = tx_st_data          [ 326] ;
  assign tx_phy_preflop_1 [  75] = tx_st_data          [ 327] ;
  assign tx_phy_preflop_1 [  76] = tx_st_data          [ 328] ;
  assign tx_phy_preflop_1 [  77] = tx_st_data          [ 329] ;
  assign tx_phy_preflop_1 [  78] = tx_st_data          [ 330] ;
  assign tx_phy_preflop_1 [  79] = tx_mrk_userbit[1]          ; // MARKER
  assign tx_phy_preflop_2 [  40] = tx_st_data          [ 331] ;
  assign tx_phy_preflop_2 [  41] = 1'b0                       ; // STROBE (unused)
  assign tx_phy_preflop_2 [  42] = tx_st_data          [ 332] ;
  assign tx_phy_preflop_2 [  43] = tx_st_data          [ 333] ;
  assign tx_phy_preflop_2 [  44] = tx_st_data          [ 334] ;
  assign tx_phy_preflop_2 [  45] = tx_st_data          [ 335] ;
  assign tx_phy_preflop_2 [  46] = tx_st_data          [ 336] ;
  assign tx_phy_preflop_2 [  47] = tx_st_data          [ 337] ;
  assign tx_phy_preflop_2 [  48] = tx_st_data          [ 338] ;
  assign tx_phy_preflop_2 [  49] = tx_st_data          [ 339] ;
  assign tx_phy_preflop_2 [  50] = tx_st_data          [ 340] ;
  assign tx_phy_preflop_2 [  51] = tx_st_data          [ 341] ;
  assign tx_phy_preflop_2 [  52] = tx_st_data          [ 342] ;
  assign tx_phy_preflop_2 [  53] = tx_st_data          [ 343] ;
  assign tx_phy_preflop_2 [  54] = tx_st_data          [ 344] ;
  assign tx_phy_preflop_2 [  55] = tx_st_data          [ 345] ;
  assign tx_phy_preflop_2 [  56] = tx_st_data          [ 346] ;
  assign tx_phy_preflop_2 [  57] = tx_st_data          [ 347] ;
  assign tx_phy_preflop_2 [  58] = tx_st_data          [ 348] ;
  assign tx_phy_preflop_2 [  59] = tx_st_data          [ 349] ;
  assign tx_phy_preflop_2 [  60] = tx_st_data          [ 350] ;
  assign tx_phy_preflop_2 [  61] = tx_st_data          [ 351] ;
  assign tx_phy_preflop_2 [  62] = tx_st_data          [ 352] ;
  assign tx_phy_preflop_2 [  63] = tx_st_data          [ 353] ;
  assign tx_phy_preflop_2 [  64] = tx_st_data          [ 354] ;
  assign tx_phy_preflop_2 [  65] = tx_st_data          [ 355] ;
  assign tx_phy_preflop_2 [  66] = tx_st_data          [ 356] ;
  assign tx_phy_preflop_2 [  67] = tx_st_data          [ 357] ;
  assign tx_phy_preflop_2 [  68] = tx_st_data          [ 358] ;
  assign tx_phy_preflop_2 [  69] = tx_st_data          [ 359] ;
  assign tx_phy_preflop_2 [  70] = tx_st_data          [ 360] ;
  assign tx_phy_preflop_2 [  71] = tx_st_data          [ 361] ;
  assign tx_phy_preflop_2 [  72] = tx_st_data          [ 362] ;
  assign tx_phy_preflop_2 [  73] = tx_st_data          [ 363] ;
  assign tx_phy_preflop_2 [  74] = tx_st_data          [ 364] ;
  assign tx_phy_preflop_2 [  75] = tx_st_data          [ 365] ;
  assign tx_phy_preflop_2 [  76] = tx_st_data          [ 366] ;
  assign tx_phy_preflop_2 [  77] = tx_st_data          [ 367] ;
  assign tx_phy_preflop_2 [  78] = tx_st_data          [ 368] ;
  assign tx_phy_preflop_2 [  79] = tx_mrk_userbit[1]          ; // MARKER
  assign tx_phy_preflop_3 [  40] = tx_st_data          [ 369] ;
  assign tx_phy_preflop_3 [  41] = 1'b0                       ; // STROBE (unused)
  assign tx_phy_preflop_3 [  42] = tx_st_data          [ 370] ;
  assign tx_phy_preflop_3 [  43] = tx_st_data          [ 371] ;
  assign tx_phy_preflop_3 [  44] = tx_st_data          [ 372] ;
  assign tx_phy_preflop_3 [  45] = tx_st_data          [ 373] ;
  assign tx_phy_preflop_3 [  46] = tx_st_data          [ 374] ;
  assign tx_phy_preflop_3 [  47] = tx_st_data          [ 375] ;
  assign tx_phy_preflop_3 [  48] = tx_st_data          [ 376] ;
  assign tx_phy_preflop_3 [  49] = tx_st_data          [ 377] ;
  assign tx_phy_preflop_3 [  50] = tx_st_data          [ 378] ;
  assign tx_phy_preflop_3 [  51] = tx_st_data          [ 379] ;
  assign tx_phy_preflop_3 [  52] = tx_st_data          [ 380] ;
  assign tx_phy_preflop_3 [  53] = tx_st_data          [ 381] ;
  assign tx_phy_preflop_3 [  54] = tx_st_data          [ 382] ;
  assign tx_phy_preflop_3 [  55] = tx_st_data          [ 383] ;
  assign tx_phy_preflop_3 [  56] = tx_st_data          [ 384] ;
  assign tx_phy_preflop_3 [  57] = tx_st_data          [ 385] ;
  assign tx_phy_preflop_3 [  58] = tx_st_data          [ 386] ;
  assign tx_phy_preflop_3 [  59] = tx_st_data          [ 387] ;
  assign tx_phy_preflop_3 [  60] = tx_st_data          [ 388] ;
  assign tx_phy_preflop_3 [  61] = tx_st_data          [ 389] ;
  assign tx_phy_preflop_3 [  62] = tx_st_data          [ 390] ;
  assign tx_phy_preflop_3 [  63] = tx_st_data          [ 391] ;
  assign tx_phy_preflop_3 [  64] = tx_st_data          [ 392] ;
  assign tx_phy_preflop_3 [  65] = tx_st_data          [ 393] ;
  assign tx_phy_preflop_3 [  66] = tx_st_data          [ 394] ;
  assign tx_phy_preflop_3 [  67] = tx_st_data          [ 395] ;
  assign tx_phy_preflop_3 [  68] = tx_st_data          [ 396] ;
  assign tx_phy_preflop_3 [  69] = tx_st_data          [ 397] ;
  assign tx_phy_preflop_3 [  70] = tx_st_data          [ 398] ;
  assign tx_phy_preflop_3 [  71] = tx_st_data          [ 399] ;
  assign tx_phy_preflop_3 [  72] = tx_st_data          [ 400] ;
  assign tx_phy_preflop_3 [  73] = tx_st_data          [ 401] ;
  assign tx_phy_preflop_3 [  74] = tx_st_data          [ 402] ;
  assign tx_phy_preflop_3 [  75] = tx_st_data          [ 403] ;
  assign tx_phy_preflop_3 [  76] = tx_st_data          [ 404] ;
  assign tx_phy_preflop_3 [  77] = tx_st_data          [ 405] ;
  assign tx_phy_preflop_3 [  78] = tx_st_data          [ 406] ;
  assign tx_phy_preflop_3 [  79] = tx_mrk_userbit[1]          ; // MARKER
  assign tx_phy_preflop_4 [  40] = tx_st_data          [ 407] ;
  assign tx_phy_preflop_4 [  41] = 1'b0                       ; // STROBE (unused)
  assign tx_phy_preflop_4 [  42] = tx_st_data          [ 408] ;
  assign tx_phy_preflop_4 [  43] = tx_st_data          [ 409] ;
  assign tx_phy_preflop_4 [  44] = tx_st_data          [ 410] ;
  assign tx_phy_preflop_4 [  45] = tx_st_data          [ 411] ;
  assign tx_phy_preflop_4 [  46] = tx_st_data          [ 412] ;
  assign tx_phy_preflop_4 [  47] = tx_st_data          [ 413] ;
  assign tx_phy_preflop_4 [  48] = tx_st_data          [ 414] ;
  assign tx_phy_preflop_4 [  49] = tx_st_data          [ 415] ;
  assign tx_phy_preflop_4 [  50] = tx_st_data          [ 416] ;
  assign tx_phy_preflop_4 [  51] = tx_st_data          [ 417] ;
  assign tx_phy_preflop_4 [  52] = tx_st_data          [ 418] ;
  assign tx_phy_preflop_4 [  53] = tx_st_data          [ 419] ;
  assign tx_phy_preflop_4 [  54] = tx_st_data          [ 420] ;
  assign tx_phy_preflop_4 [  55] = tx_st_data          [ 421] ;
  assign tx_phy_preflop_4 [  56] = tx_st_data          [ 422] ;
  assign tx_phy_preflop_4 [  57] = tx_st_data          [ 423] ;
  assign tx_phy_preflop_4 [  58] = tx_st_data          [ 424] ;
  assign tx_phy_preflop_4 [  59] = tx_st_data          [ 425] ;
  assign tx_phy_preflop_4 [  60] = tx_st_data          [ 426] ;
  assign tx_phy_preflop_4 [  61] = tx_st_data          [ 427] ;
  assign tx_phy_preflop_4 [  62] = tx_st_data          [ 428] ;
  assign tx_phy_preflop_4 [  63] = tx_st_data          [ 429] ;
  assign tx_phy_preflop_4 [  64] = tx_st_data          [ 430] ;
  assign tx_phy_preflop_4 [  65] = tx_st_data          [ 431] ;
  assign tx_phy_preflop_4 [  66] = tx_st_data          [ 432] ;
  assign tx_phy_preflop_4 [  67] = tx_st_data          [ 433] ;
  assign tx_phy_preflop_4 [  68] = tx_st_data          [ 434] ;
  assign tx_phy_preflop_4 [  69] = tx_st_data          [ 435] ;
  assign tx_phy_preflop_4 [  70] = tx_st_data          [ 436] ;
  assign tx_phy_preflop_4 [  71] = tx_st_data          [ 437] ;
  assign tx_phy_preflop_4 [  72] = tx_st_data          [ 438] ;
  assign tx_phy_preflop_4 [  73] = tx_st_data          [ 439] ;
  assign tx_phy_preflop_4 [  74] = tx_st_data          [ 440] ;
  assign tx_phy_preflop_4 [  75] = tx_st_data          [ 441] ;
  assign tx_phy_preflop_4 [  76] = tx_st_data          [ 442] ;
  assign tx_phy_preflop_4 [  77] = tx_st_data          [ 443] ;
  assign tx_phy_preflop_4 [  78] = tx_st_data          [ 444] ;
  assign tx_phy_preflop_4 [  79] = tx_mrk_userbit[1]          ; // MARKER
  assign tx_phy_preflop_5 [  40] = tx_st_data          [ 445] ;
  assign tx_phy_preflop_5 [  41] = 1'b0                       ; // STROBE (unused)
  assign tx_phy_preflop_5 [  42] = tx_st_data          [ 446] ;
  assign tx_phy_preflop_5 [  43] = tx_st_data          [ 447] ;
  assign tx_phy_preflop_5 [  44] = tx_st_data          [ 448] ;
  assign tx_phy_preflop_5 [  45] = tx_st_data          [ 449] ;
  assign tx_phy_preflop_5 [  46] = tx_st_data          [ 450] ;
  assign tx_phy_preflop_5 [  47] = tx_st_data          [ 451] ;
  assign tx_phy_preflop_5 [  48] = tx_st_data          [ 452] ;
  assign tx_phy_preflop_5 [  49] = tx_st_data          [ 453] ;
  assign tx_phy_preflop_5 [  50] = tx_st_data          [ 454] ;
  assign tx_phy_preflop_5 [  51] = tx_st_data          [ 455] ;
  assign tx_phy_preflop_5 [  52] = tx_st_data          [ 456] ;
  assign tx_phy_preflop_5 [  53] = tx_st_data          [ 457] ;
  assign tx_phy_preflop_5 [  54] = tx_st_data          [ 458] ;
  assign tx_phy_preflop_5 [  55] = tx_st_data          [ 459] ;
  assign tx_phy_preflop_5 [  56] = tx_st_data          [ 460] ;
  assign tx_phy_preflop_5 [  57] = tx_st_data          [ 461] ;
  assign tx_phy_preflop_5 [  58] = tx_st_data          [ 462] ;
  assign tx_phy_preflop_5 [  59] = tx_st_data          [ 463] ;
  assign tx_phy_preflop_5 [  60] = tx_st_data          [ 464] ;
  assign tx_phy_preflop_5 [  61] = tx_st_data          [ 465] ;
  assign tx_phy_preflop_5 [  62] = tx_st_data          [ 466] ;
  assign tx_phy_preflop_5 [  63] = tx_st_data          [ 467] ;
  assign tx_phy_preflop_5 [  64] = tx_st_data          [ 468] ;
  assign tx_phy_preflop_5 [  65] = tx_st_data          [ 469] ;
  assign tx_phy_preflop_5 [  66] = tx_st_data          [ 470] ;
  assign tx_phy_preflop_5 [  67] = tx_st_data          [ 471] ;
  assign tx_phy_preflop_5 [  68] = tx_st_data          [ 472] ;
  assign tx_phy_preflop_5 [  69] = tx_st_data          [ 473] ;
  assign tx_phy_preflop_5 [  70] = tx_st_data          [ 474] ;
  assign tx_phy_preflop_5 [  71] = tx_st_data          [ 475] ;
  assign tx_phy_preflop_5 [  72] = tx_st_data          [ 476] ;
  assign tx_phy_preflop_5 [  73] = tx_st_data          [ 477] ;
  assign tx_phy_preflop_5 [  74] = tx_st_data          [ 478] ;
  assign tx_phy_preflop_5 [  75] = tx_st_data          [ 479] ;
  assign tx_phy_preflop_5 [  76] = tx_st_data          [ 480] ;
  assign tx_phy_preflop_5 [  77] = tx_st_data          [ 481] ;
  assign tx_phy_preflop_5 [  78] = tx_st_data          [ 482] ;
  assign tx_phy_preflop_5 [  79] = tx_mrk_userbit[1]          ; // MARKER
  assign tx_phy_preflop_6 [  40] = tx_st_data          [ 483] ;
  assign tx_phy_preflop_6 [  41] = 1'b0                       ; // STROBE (unused)
  assign tx_phy_preflop_6 [  42] = tx_st_data          [ 484] ;
  assign tx_phy_preflop_6 [  43] = tx_st_data          [ 485] ;
  assign tx_phy_preflop_6 [  44] = tx_st_data          [ 486] ;
  assign tx_phy_preflop_6 [  45] = tx_st_data          [ 487] ;
  assign tx_phy_preflop_6 [  46] = tx_st_data          [ 488] ;
  assign tx_phy_preflop_6 [  47] = tx_st_data          [ 489] ;
  assign tx_phy_preflop_6 [  48] = tx_st_data          [ 490] ;
  assign tx_phy_preflop_6 [  49] = tx_st_data          [ 491] ;
  assign tx_phy_preflop_6 [  50] = tx_st_data          [ 492] ;
  assign tx_phy_preflop_6 [  51] = tx_st_data          [ 493] ;
  assign tx_phy_preflop_6 [  52] = tx_st_data          [ 494] ;
  assign tx_phy_preflop_6 [  53] = tx_st_data          [ 495] ;
  assign tx_phy_preflop_6 [  54] = tx_st_data          [ 496] ;
  assign tx_phy_preflop_6 [  55] = tx_st_data          [ 497] ;
  assign tx_phy_preflop_6 [  56] = tx_st_data          [ 498] ;
  assign tx_phy_preflop_6 [  57] = tx_st_data          [ 499] ;
  assign tx_phy_preflop_6 [  58] = tx_st_data          [ 500] ;
  assign tx_phy_preflop_6 [  59] = tx_st_data          [ 501] ;
  assign tx_phy_preflop_6 [  60] = tx_st_data          [ 502] ;
  assign tx_phy_preflop_6 [  61] = tx_st_data          [ 503] ;
  assign tx_phy_preflop_6 [  62] = tx_st_data          [ 504] ;
  assign tx_phy_preflop_6 [  63] = tx_st_data          [ 505] ;
  assign tx_phy_preflop_6 [  64] = tx_st_data          [ 506] ;
  assign tx_phy_preflop_6 [  65] = tx_st_data          [ 507] ;
  assign tx_phy_preflop_6 [  66] = tx_st_data          [ 508] ;
  assign tx_phy_preflop_6 [  67] = tx_st_data          [ 509] ;
  assign tx_phy_preflop_6 [  68] = tx_st_data          [ 510] ;
  assign tx_phy_preflop_6 [  69] = tx_st_data          [ 511] ;
  assign tx_phy_preflop_6 [  70] = 1'b0                       ;
  assign tx_phy_preflop_6 [  71] = 1'b0                       ;
  assign tx_phy_preflop_6 [  72] = 1'b0                       ;
  assign tx_phy_preflop_6 [  73] = 1'b0                       ;
  assign tx_phy_preflop_6 [  74] = 1'b0                       ;
  assign tx_phy_preflop_6 [  75] = 1'b0                       ;
  assign tx_phy_preflop_6 [  76] = 1'b0                       ;
  assign tx_phy_preflop_6 [  77] = 1'b0                       ;
  assign tx_phy_preflop_6 [  78] = 1'b0                       ;
  assign tx_phy_preflop_6 [  79] = tx_mrk_userbit[1]          ; // MARKER
// TX Section
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// RX Section

//   RX_CH_WIDTH           = 80; // Gen1Only running at Half Rate
//   RX_DATA_WIDTH         = 76; // Usable Data per Channel
//   RX_PERSISTENT_STROBE  = 1'b1;
//   RX_PERSISTENT_MARKER  = 1'b1;
//   RX_STROBE_GEN2_LOC    = 'd1;
//   RX_MARKER_GEN2_LOC    = 'd39;
//   RX_STROBE_GEN1_LOC    = 'd1;
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
  logic [  79:   0]                              rx_phy_postflop_4             ;
  logic [  79:   0]                              rx_phy_postflop_5             ;
  logic [  79:   0]                              rx_phy_postflop_6             ;
  logic [  79:   0]                              rx_phy_flop_0_reg             ;
  logic [  79:   0]                              rx_phy_flop_1_reg             ;
  logic [  79:   0]                              rx_phy_flop_2_reg             ;
  logic [  79:   0]                              rx_phy_flop_3_reg             ;
  logic [  79:   0]                              rx_phy_flop_4_reg             ;
  logic [  79:   0]                              rx_phy_flop_5_reg             ;
  logic [  79:   0]                              rx_phy_flop_6_reg             ;

  always_ff @(posedge clk_rd or negedge rst_rd_n)
  if (~rst_rd_n)
  begin
    rx_phy_flop_0_reg                       <= 80'b0                                   ;
    rx_phy_flop_1_reg                       <= 80'b0                                   ;
    rx_phy_flop_2_reg                       <= 80'b0                                   ;
    rx_phy_flop_3_reg                       <= 80'b0                                   ;
    rx_phy_flop_4_reg                       <= 80'b0                                   ;
    rx_phy_flop_5_reg                       <= 80'b0                                   ;
    rx_phy_flop_6_reg                       <= 80'b0                                   ;
  end
  else
  begin
    rx_phy_flop_0_reg                       <= rx_phy0                                 ;
    rx_phy_flop_1_reg                       <= rx_phy1                                 ;
    rx_phy_flop_2_reg                       <= rx_phy2                                 ;
    rx_phy_flop_3_reg                       <= rx_phy3                                 ;
    rx_phy_flop_4_reg                       <= rx_phy4                                 ;
    rx_phy_flop_5_reg                       <= rx_phy5                                 ;
    rx_phy_flop_6_reg                       <= rx_phy6                                 ;
  end


  assign rx_phy_postflop_0                  = RX_REG_PHY ? rx_phy_flop_0_reg : rx_phy0               ;
  assign rx_phy_postflop_1                  = RX_REG_PHY ? rx_phy_flop_1_reg : rx_phy1               ;
  assign rx_phy_postflop_2                  = RX_REG_PHY ? rx_phy_flop_2_reg : rx_phy2               ;
  assign rx_phy_postflop_3                  = RX_REG_PHY ? rx_phy_flop_3_reg : rx_phy3               ;
  assign rx_phy_postflop_4                  = RX_REG_PHY ? rx_phy_flop_4_reg : rx_phy4               ;
  assign rx_phy_postflop_5                  = RX_REG_PHY ? rx_phy_flop_5_reg : rx_phy5               ;
  assign rx_phy_postflop_6                  = RX_REG_PHY ? rx_phy_flop_6_reg : rx_phy6               ;

  logic                                          rx_st_credit_r0               ;
  logic                                          rx_st_credit_r1               ;
  logic                                          rx_st_credit_r2               ;
  logic                                          rx_st_credit_r3               ;

  // Asymmetric Credit Logic
  assign rx_st_credit         [   0 +:   1] = rx_st_credit_r0                    ;
  assign rx_st_credit         [   1 +:   1] = rx_st_credit_r1                    ;
  assign rx_st_credit         [   2 +:   1] = 1'b0                               ;
  assign rx_st_credit         [   3 +:   1] = 1'b0                               ;

  assign rx_st_credit_r0            = rx_phy_postflop_0 [   0];
//       STROBE                     = rx_phy_postflop_0 [   1]
//       nc                         = rx_phy_postflop_0 [   2];
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
//       nc                         = rx_phy_postflop_0 [  38];
//       MARKER                     = rx_phy_postflop_0 [  39]
//       nc                         = rx_phy_postflop_1 [   0];
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
//       nc                         = rx_phy_postflop_1 [  38];
//       MARKER                     = rx_phy_postflop_1 [  39]
//       nc                         = rx_phy_postflop_2 [   0];
//       STROBE                     = rx_phy_postflop_2 [   1]
//       nc                         = rx_phy_postflop_2 [   2];
//       nc                         = rx_phy_postflop_2 [   3];
//       nc                         = rx_phy_postflop_2 [   4];
//       nc                         = rx_phy_postflop_2 [   5];
//       nc                         = rx_phy_postflop_2 [   6];
//       nc                         = rx_phy_postflop_2 [   7];
//       nc                         = rx_phy_postflop_2 [   8];
//       nc                         = rx_phy_postflop_2 [   9];
//       nc                         = rx_phy_postflop_2 [  10];
//       nc                         = rx_phy_postflop_2 [  11];
//       nc                         = rx_phy_postflop_2 [  12];
//       nc                         = rx_phy_postflop_2 [  13];
//       nc                         = rx_phy_postflop_2 [  14];
//       nc                         = rx_phy_postflop_2 [  15];
//       nc                         = rx_phy_postflop_2 [  16];
//       nc                         = rx_phy_postflop_2 [  17];
//       nc                         = rx_phy_postflop_2 [  18];
//       nc                         = rx_phy_postflop_2 [  19];
//       nc                         = rx_phy_postflop_2 [  20];
//       nc                         = rx_phy_postflop_2 [  21];
//       nc                         = rx_phy_postflop_2 [  22];
//       nc                         = rx_phy_postflop_2 [  23];
//       nc                         = rx_phy_postflop_2 [  24];
//       nc                         = rx_phy_postflop_2 [  25];
//       nc                         = rx_phy_postflop_2 [  26];
//       nc                         = rx_phy_postflop_2 [  27];
//       nc                         = rx_phy_postflop_2 [  28];
//       nc                         = rx_phy_postflop_2 [  29];
//       nc                         = rx_phy_postflop_2 [  30];
//       nc                         = rx_phy_postflop_2 [  31];
//       nc                         = rx_phy_postflop_2 [  32];
//       nc                         = rx_phy_postflop_2 [  33];
//       nc                         = rx_phy_postflop_2 [  34];
//       nc                         = rx_phy_postflop_2 [  35];
//       nc                         = rx_phy_postflop_2 [  36];
//       nc                         = rx_phy_postflop_2 [  37];
//       nc                         = rx_phy_postflop_2 [  38];
//       MARKER                     = rx_phy_postflop_2 [  39]
//       nc                         = rx_phy_postflop_3 [   0];
//       STROBE                     = rx_phy_postflop_3 [   1]
//       nc                         = rx_phy_postflop_3 [   2];
//       nc                         = rx_phy_postflop_3 [   3];
//       nc                         = rx_phy_postflop_3 [   4];
//       nc                         = rx_phy_postflop_3 [   5];
//       nc                         = rx_phy_postflop_3 [   6];
//       nc                         = rx_phy_postflop_3 [   7];
//       nc                         = rx_phy_postflop_3 [   8];
//       nc                         = rx_phy_postflop_3 [   9];
//       nc                         = rx_phy_postflop_3 [  10];
//       nc                         = rx_phy_postflop_3 [  11];
//       nc                         = rx_phy_postflop_3 [  12];
//       nc                         = rx_phy_postflop_3 [  13];
//       nc                         = rx_phy_postflop_3 [  14];
//       nc                         = rx_phy_postflop_3 [  15];
//       nc                         = rx_phy_postflop_3 [  16];
//       nc                         = rx_phy_postflop_3 [  17];
//       nc                         = rx_phy_postflop_3 [  18];
//       nc                         = rx_phy_postflop_3 [  19];
//       nc                         = rx_phy_postflop_3 [  20];
//       nc                         = rx_phy_postflop_3 [  21];
//       nc                         = rx_phy_postflop_3 [  22];
//       nc                         = rx_phy_postflop_3 [  23];
//       nc                         = rx_phy_postflop_3 [  24];
//       nc                         = rx_phy_postflop_3 [  25];
//       nc                         = rx_phy_postflop_3 [  26];
//       nc                         = rx_phy_postflop_3 [  27];
//       nc                         = rx_phy_postflop_3 [  28];
//       nc                         = rx_phy_postflop_3 [  29];
//       nc                         = rx_phy_postflop_3 [  30];
//       nc                         = rx_phy_postflop_3 [  31];
//       nc                         = rx_phy_postflop_3 [  32];
//       nc                         = rx_phy_postflop_3 [  33];
//       nc                         = rx_phy_postflop_3 [  34];
//       nc                         = rx_phy_postflop_3 [  35];
//       nc                         = rx_phy_postflop_3 [  36];
//       nc                         = rx_phy_postflop_3 [  37];
//       nc                         = rx_phy_postflop_3 [  38];
//       MARKER                     = rx_phy_postflop_3 [  39]
//       nc                         = rx_phy_postflop_4 [   0];
//       STROBE                     = rx_phy_postflop_4 [   1]
//       nc                         = rx_phy_postflop_4 [   2];
//       nc                         = rx_phy_postflop_4 [   3];
//       nc                         = rx_phy_postflop_4 [   4];
//       nc                         = rx_phy_postflop_4 [   5];
//       nc                         = rx_phy_postflop_4 [   6];
//       nc                         = rx_phy_postflop_4 [   7];
//       nc                         = rx_phy_postflop_4 [   8];
//       nc                         = rx_phy_postflop_4 [   9];
//       nc                         = rx_phy_postflop_4 [  10];
//       nc                         = rx_phy_postflop_4 [  11];
//       nc                         = rx_phy_postflop_4 [  12];
//       nc                         = rx_phy_postflop_4 [  13];
//       nc                         = rx_phy_postflop_4 [  14];
//       nc                         = rx_phy_postflop_4 [  15];
//       nc                         = rx_phy_postflop_4 [  16];
//       nc                         = rx_phy_postflop_4 [  17];
//       nc                         = rx_phy_postflop_4 [  18];
//       nc                         = rx_phy_postflop_4 [  19];
//       nc                         = rx_phy_postflop_4 [  20];
//       nc                         = rx_phy_postflop_4 [  21];
//       nc                         = rx_phy_postflop_4 [  22];
//       nc                         = rx_phy_postflop_4 [  23];
//       nc                         = rx_phy_postflop_4 [  24];
//       nc                         = rx_phy_postflop_4 [  25];
//       nc                         = rx_phy_postflop_4 [  26];
//       nc                         = rx_phy_postflop_4 [  27];
//       nc                         = rx_phy_postflop_4 [  28];
//       nc                         = rx_phy_postflop_4 [  29];
//       nc                         = rx_phy_postflop_4 [  30];
//       nc                         = rx_phy_postflop_4 [  31];
//       nc                         = rx_phy_postflop_4 [  32];
//       nc                         = rx_phy_postflop_4 [  33];
//       nc                         = rx_phy_postflop_4 [  34];
//       nc                         = rx_phy_postflop_4 [  35];
//       nc                         = rx_phy_postflop_4 [  36];
//       nc                         = rx_phy_postflop_4 [  37];
//       nc                         = rx_phy_postflop_4 [  38];
//       MARKER                     = rx_phy_postflop_4 [  39]
//       nc                         = rx_phy_postflop_5 [   0];
//       STROBE                     = rx_phy_postflop_5 [   1]
//       nc                         = rx_phy_postflop_5 [   2];
//       nc                         = rx_phy_postflop_5 [   3];
//       nc                         = rx_phy_postflop_5 [   4];
//       nc                         = rx_phy_postflop_5 [   5];
//       nc                         = rx_phy_postflop_5 [   6];
//       nc                         = rx_phy_postflop_5 [   7];
//       nc                         = rx_phy_postflop_5 [   8];
//       nc                         = rx_phy_postflop_5 [   9];
//       nc                         = rx_phy_postflop_5 [  10];
//       nc                         = rx_phy_postflop_5 [  11];
//       nc                         = rx_phy_postflop_5 [  12];
//       nc                         = rx_phy_postflop_5 [  13];
//       nc                         = rx_phy_postflop_5 [  14];
//       nc                         = rx_phy_postflop_5 [  15];
//       nc                         = rx_phy_postflop_5 [  16];
//       nc                         = rx_phy_postflop_5 [  17];
//       nc                         = rx_phy_postflop_5 [  18];
//       nc                         = rx_phy_postflop_5 [  19];
//       nc                         = rx_phy_postflop_5 [  20];
//       nc                         = rx_phy_postflop_5 [  21];
//       nc                         = rx_phy_postflop_5 [  22];
//       nc                         = rx_phy_postflop_5 [  23];
//       nc                         = rx_phy_postflop_5 [  24];
//       nc                         = rx_phy_postflop_5 [  25];
//       nc                         = rx_phy_postflop_5 [  26];
//       nc                         = rx_phy_postflop_5 [  27];
//       nc                         = rx_phy_postflop_5 [  28];
//       nc                         = rx_phy_postflop_5 [  29];
//       nc                         = rx_phy_postflop_5 [  30];
//       nc                         = rx_phy_postflop_5 [  31];
//       nc                         = rx_phy_postflop_5 [  32];
//       nc                         = rx_phy_postflop_5 [  33];
//       nc                         = rx_phy_postflop_5 [  34];
//       nc                         = rx_phy_postflop_5 [  35];
//       nc                         = rx_phy_postflop_5 [  36];
//       nc                         = rx_phy_postflop_5 [  37];
//       nc                         = rx_phy_postflop_5 [  38];
//       MARKER                     = rx_phy_postflop_5 [  39]
//       nc                         = rx_phy_postflop_6 [   0];
//       STROBE                     = rx_phy_postflop_6 [   1]
//       nc                         = rx_phy_postflop_6 [   2];
//       nc                         = rx_phy_postflop_6 [   3];
//       nc                         = rx_phy_postflop_6 [   4];
//       nc                         = rx_phy_postflop_6 [   5];
//       nc                         = rx_phy_postflop_6 [   6];
//       nc                         = rx_phy_postflop_6 [   7];
//       nc                         = rx_phy_postflop_6 [   8];
//       nc                         = rx_phy_postflop_6 [   9];
//       nc                         = rx_phy_postflop_6 [  10];
//       nc                         = rx_phy_postflop_6 [  11];
//       nc                         = rx_phy_postflop_6 [  12];
//       nc                         = rx_phy_postflop_6 [  13];
//       nc                         = rx_phy_postflop_6 [  14];
//       nc                         = rx_phy_postflop_6 [  15];
//       nc                         = rx_phy_postflop_6 [  16];
//       nc                         = rx_phy_postflop_6 [  17];
//       nc                         = rx_phy_postflop_6 [  18];
//       nc                         = rx_phy_postflop_6 [  19];
//       nc                         = rx_phy_postflop_6 [  20];
//       nc                         = rx_phy_postflop_6 [  21];
//       nc                         = rx_phy_postflop_6 [  22];
//       nc                         = rx_phy_postflop_6 [  23];
//       nc                         = rx_phy_postflop_6 [  24];
//       nc                         = rx_phy_postflop_6 [  25];
//       nc                         = rx_phy_postflop_6 [  26];
//       nc                         = rx_phy_postflop_6 [  27];
//       nc                         = rx_phy_postflop_6 [  28];
//       nc                         = rx_phy_postflop_6 [  29];
//       nc                         = rx_phy_postflop_6 [  30];
//       nc                         = rx_phy_postflop_6 [  31];
//       nc                         = rx_phy_postflop_6 [  32];
//       nc                         = rx_phy_postflop_6 [  33];
//       nc                         = rx_phy_postflop_6 [  34];
//       nc                         = rx_phy_postflop_6 [  35];
//       nc                         = rx_phy_postflop_6 [  36];
//       nc                         = rx_phy_postflop_6 [  37];
//       nc                         = rx_phy_postflop_6 [  38];
//       MARKER                     = rx_phy_postflop_6 [  39]
  assign rx_st_credit_r1            = rx_phy_postflop_0 [  40];
//       STROBE                     = rx_phy_postflop_0 [  41]
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
//       nc                         = rx_phy_postflop_0 [  78];
//       MARKER                     = rx_phy_postflop_0 [  79]
//       nc                         = rx_phy_postflop_1 [  40];
//       STROBE                     = rx_phy_postflop_1 [  41]
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
//       nc                         = rx_phy_postflop_1 [  78];
//       MARKER                     = rx_phy_postflop_1 [  79]
//       nc                         = rx_phy_postflop_2 [  40];
//       STROBE                     = rx_phy_postflop_2 [  41]
//       nc                         = rx_phy_postflop_2 [  42];
//       nc                         = rx_phy_postflop_2 [  43];
//       nc                         = rx_phy_postflop_2 [  44];
//       nc                         = rx_phy_postflop_2 [  45];
//       nc                         = rx_phy_postflop_2 [  46];
//       nc                         = rx_phy_postflop_2 [  47];
//       nc                         = rx_phy_postflop_2 [  48];
//       nc                         = rx_phy_postflop_2 [  49];
//       nc                         = rx_phy_postflop_2 [  50];
//       nc                         = rx_phy_postflop_2 [  51];
//       nc                         = rx_phy_postflop_2 [  52];
//       nc                         = rx_phy_postflop_2 [  53];
//       nc                         = rx_phy_postflop_2 [  54];
//       nc                         = rx_phy_postflop_2 [  55];
//       nc                         = rx_phy_postflop_2 [  56];
//       nc                         = rx_phy_postflop_2 [  57];
//       nc                         = rx_phy_postflop_2 [  58];
//       nc                         = rx_phy_postflop_2 [  59];
//       nc                         = rx_phy_postflop_2 [  60];
//       nc                         = rx_phy_postflop_2 [  61];
//       nc                         = rx_phy_postflop_2 [  62];
//       nc                         = rx_phy_postflop_2 [  63];
//       nc                         = rx_phy_postflop_2 [  64];
//       nc                         = rx_phy_postflop_2 [  65];
//       nc                         = rx_phy_postflop_2 [  66];
//       nc                         = rx_phy_postflop_2 [  67];
//       nc                         = rx_phy_postflop_2 [  68];
//       nc                         = rx_phy_postflop_2 [  69];
//       nc                         = rx_phy_postflop_2 [  70];
//       nc                         = rx_phy_postflop_2 [  71];
//       nc                         = rx_phy_postflop_2 [  72];
//       nc                         = rx_phy_postflop_2 [  73];
//       nc                         = rx_phy_postflop_2 [  74];
//       nc                         = rx_phy_postflop_2 [  75];
//       nc                         = rx_phy_postflop_2 [  76];
//       nc                         = rx_phy_postflop_2 [  77];
//       nc                         = rx_phy_postflop_2 [  78];
//       MARKER                     = rx_phy_postflop_2 [  79]
//       nc                         = rx_phy_postflop_3 [  40];
//       STROBE                     = rx_phy_postflop_3 [  41]
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
//       nc                         = rx_phy_postflop_3 [  76];
//       nc                         = rx_phy_postflop_3 [  77];
//       nc                         = rx_phy_postflop_3 [  78];
//       MARKER                     = rx_phy_postflop_3 [  79]
//       nc                         = rx_phy_postflop_4 [  40];
//       STROBE                     = rx_phy_postflop_4 [  41]
//       nc                         = rx_phy_postflop_4 [  42];
//       nc                         = rx_phy_postflop_4 [  43];
//       nc                         = rx_phy_postflop_4 [  44];
//       nc                         = rx_phy_postflop_4 [  45];
//       nc                         = rx_phy_postflop_4 [  46];
//       nc                         = rx_phy_postflop_4 [  47];
//       nc                         = rx_phy_postflop_4 [  48];
//       nc                         = rx_phy_postflop_4 [  49];
//       nc                         = rx_phy_postflop_4 [  50];
//       nc                         = rx_phy_postflop_4 [  51];
//       nc                         = rx_phy_postflop_4 [  52];
//       nc                         = rx_phy_postflop_4 [  53];
//       nc                         = rx_phy_postflop_4 [  54];
//       nc                         = rx_phy_postflop_4 [  55];
//       nc                         = rx_phy_postflop_4 [  56];
//       nc                         = rx_phy_postflop_4 [  57];
//       nc                         = rx_phy_postflop_4 [  58];
//       nc                         = rx_phy_postflop_4 [  59];
//       nc                         = rx_phy_postflop_4 [  60];
//       nc                         = rx_phy_postflop_4 [  61];
//       nc                         = rx_phy_postflop_4 [  62];
//       nc                         = rx_phy_postflop_4 [  63];
//       nc                         = rx_phy_postflop_4 [  64];
//       nc                         = rx_phy_postflop_4 [  65];
//       nc                         = rx_phy_postflop_4 [  66];
//       nc                         = rx_phy_postflop_4 [  67];
//       nc                         = rx_phy_postflop_4 [  68];
//       nc                         = rx_phy_postflop_4 [  69];
//       nc                         = rx_phy_postflop_4 [  70];
//       nc                         = rx_phy_postflop_4 [  71];
//       nc                         = rx_phy_postflop_4 [  72];
//       nc                         = rx_phy_postflop_4 [  73];
//       nc                         = rx_phy_postflop_4 [  74];
//       nc                         = rx_phy_postflop_4 [  75];
//       nc                         = rx_phy_postflop_4 [  76];
//       nc                         = rx_phy_postflop_4 [  77];
//       nc                         = rx_phy_postflop_4 [  78];
//       MARKER                     = rx_phy_postflop_4 [  79]
//       nc                         = rx_phy_postflop_5 [  40];
//       STROBE                     = rx_phy_postflop_5 [  41]
//       nc                         = rx_phy_postflop_5 [  42];
//       nc                         = rx_phy_postflop_5 [  43];
//       nc                         = rx_phy_postflop_5 [  44];
//       nc                         = rx_phy_postflop_5 [  45];
//       nc                         = rx_phy_postflop_5 [  46];
//       nc                         = rx_phy_postflop_5 [  47];
//       nc                         = rx_phy_postflop_5 [  48];
//       nc                         = rx_phy_postflop_5 [  49];
//       nc                         = rx_phy_postflop_5 [  50];
//       nc                         = rx_phy_postflop_5 [  51];
//       nc                         = rx_phy_postflop_5 [  52];
//       nc                         = rx_phy_postflop_5 [  53];
//       nc                         = rx_phy_postflop_5 [  54];
//       nc                         = rx_phy_postflop_5 [  55];
//       nc                         = rx_phy_postflop_5 [  56];
//       nc                         = rx_phy_postflop_5 [  57];
//       nc                         = rx_phy_postflop_5 [  58];
//       nc                         = rx_phy_postflop_5 [  59];
//       nc                         = rx_phy_postflop_5 [  60];
//       nc                         = rx_phy_postflop_5 [  61];
//       nc                         = rx_phy_postflop_5 [  62];
//       nc                         = rx_phy_postflop_5 [  63];
//       nc                         = rx_phy_postflop_5 [  64];
//       nc                         = rx_phy_postflop_5 [  65];
//       nc                         = rx_phy_postflop_5 [  66];
//       nc                         = rx_phy_postflop_5 [  67];
//       nc                         = rx_phy_postflop_5 [  68];
//       nc                         = rx_phy_postflop_5 [  69];
//       nc                         = rx_phy_postflop_5 [  70];
//       nc                         = rx_phy_postflop_5 [  71];
//       nc                         = rx_phy_postflop_5 [  72];
//       nc                         = rx_phy_postflop_5 [  73];
//       nc                         = rx_phy_postflop_5 [  74];
//       nc                         = rx_phy_postflop_5 [  75];
//       nc                         = rx_phy_postflop_5 [  76];
//       nc                         = rx_phy_postflop_5 [  77];
//       nc                         = rx_phy_postflop_5 [  78];
//       MARKER                     = rx_phy_postflop_5 [  79]
//       nc                         = rx_phy_postflop_6 [  40];
//       STROBE                     = rx_phy_postflop_6 [  41]
//       nc                         = rx_phy_postflop_6 [  42];
//       nc                         = rx_phy_postflop_6 [  43];
//       nc                         = rx_phy_postflop_6 [  44];
//       nc                         = rx_phy_postflop_6 [  45];
//       nc                         = rx_phy_postflop_6 [  46];
//       nc                         = rx_phy_postflop_6 [  47];
//       nc                         = rx_phy_postflop_6 [  48];
//       nc                         = rx_phy_postflop_6 [  49];
//       nc                         = rx_phy_postflop_6 [  50];
//       nc                         = rx_phy_postflop_6 [  51];
//       nc                         = rx_phy_postflop_6 [  52];
//       nc                         = rx_phy_postflop_6 [  53];
//       nc                         = rx_phy_postflop_6 [  54];
//       nc                         = rx_phy_postflop_6 [  55];
//       nc                         = rx_phy_postflop_6 [  56];
//       nc                         = rx_phy_postflop_6 [  57];
//       nc                         = rx_phy_postflop_6 [  58];
//       nc                         = rx_phy_postflop_6 [  59];
//       nc                         = rx_phy_postflop_6 [  60];
//       nc                         = rx_phy_postflop_6 [  61];
//       nc                         = rx_phy_postflop_6 [  62];
//       nc                         = rx_phy_postflop_6 [  63];
//       nc                         = rx_phy_postflop_6 [  64];
//       nc                         = rx_phy_postflop_6 [  65];
//       nc                         = rx_phy_postflop_6 [  66];
//       nc                         = rx_phy_postflop_6 [  67];
//       nc                         = rx_phy_postflop_6 [  68];
//       nc                         = rx_phy_postflop_6 [  69];
//       nc                         = rx_phy_postflop_6 [  70];
//       nc                         = rx_phy_postflop_6 [  71];
//       nc                         = rx_phy_postflop_6 [  72];
//       nc                         = rx_phy_postflop_6 [  73];
//       nc                         = rx_phy_postflop_6 [  74];
//       nc                         = rx_phy_postflop_6 [  75];
//       nc                         = rx_phy_postflop_6 [  76];
//       nc                         = rx_phy_postflop_6 [  77];
//       nc                         = rx_phy_postflop_6 [  78];
//       MARKER                     = rx_phy_postflop_6 [  79]

// RX Section
//////////////////////////////////////////////////////////////////


endmodule
