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

module axi_st_d128_asym_full_master_concat  (

// Data from Logic Links
  input  logic [ 144:   0]   tx_st_data          ,
  output logic               tx_st_pop_ovrd      ,
  input  logic               tx_st_pushbit       ,
  output logic [   3:   0]   rx_st_credit        ,

// PHY Interconnect
  output logic [  79:   0]   tx_phy0             ,
  input  logic [  79:   0]   rx_phy0             ,
  output logic [  79:   0]   tx_phy1             ,
  input  logic [  79:   0]   rx_phy1             ,

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
  assign tx_st_pop_ovrd                     = 1'b0                               ;

// No RX Packetization, so tie off packetization signals

//////////////////////////////////////////////////////////////////
// TX Section

//   TX_CH_WIDTH           = 80; // Gen2Only running at Full Rate
//   TX_DATA_WIDTH         = 74; // Usable Data per Channel
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

  logic [  79:   0]                              tx_phy_preflop_0              ;
  logic [  79:   0]                              tx_phy_preflop_1              ;
  logic [  79:   0]                              tx_phy_flop_0_reg             ;
  logic [  79:   0]                              tx_phy_flop_1_reg             ;

  always_ff @(posedge clk_wr or negedge rst_wr_n)
  if (~rst_wr_n)
  begin
    tx_phy_flop_0_reg                       <= 80'b0                                   ;
    tx_phy_flop_1_reg                       <= 80'b0                                   ;
  end
  else
  begin
    tx_phy_flop_0_reg                       <= tx_phy_preflop_0                        ;
    tx_phy_flop_1_reg                       <= tx_phy_preflop_1                        ;
  end

  assign tx_phy0                            = TX_REG_PHY ? tx_phy_flop_0_reg : tx_phy_preflop_0               ;
  assign tx_phy1                            = TX_REG_PHY ? tx_phy_flop_1_reg : tx_phy_preflop_1               ;

  logic                                          tx_st_pushbit_r0              ;

  assign tx_st_pushbit_r0                   = tx_st_pushbit                      ;

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
// TX Section
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// RX Section

//   RX_CH_WIDTH           = 80; // Gen2Only running at Full Rate
//   RX_DATA_WIDTH         = 74; // Usable Data per Channel
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

  logic [  79:   0]                              rx_phy_postflop_0             ;
  logic [  79:   0]                              rx_phy_postflop_1             ;
  logic [  79:   0]                              rx_phy_flop_0_reg             ;
  logic [  79:   0]                              rx_phy_flop_1_reg             ;

  always_ff @(posedge clk_rd or negedge rst_rd_n)
  if (~rst_rd_n)
  begin
    rx_phy_flop_0_reg                       <= 80'b0                                   ;
    rx_phy_flop_1_reg                       <= 80'b0                                   ;
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
  assign rx_st_credit         [   1 +:   1] = 1'b0                               ;
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

// RX Section
//////////////////////////////////////////////////////////////////


endmodule
