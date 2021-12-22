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

module axi_lite_a32_d32_master_concat  (

// Data from Logic Links
  input  logic [  31:   0]   tx_ar_lite_data     ,
  output logic               tx_ar_lite_pop_ovrd ,
  input  logic               tx_ar_lite_pushbit  ,
  output logic               rx_ar_lite_credit   ,

  input  logic [  31:   0]   tx_aw_lite_data     ,
  output logic               tx_aw_lite_pop_ovrd ,
  input  logic               tx_aw_lite_pushbit  ,
  output logic               rx_aw_lite_credit   ,

  input  logic [  35:   0]   tx_w_lite_data      ,
  output logic               tx_w_lite_pop_ovrd  ,
  input  logic               tx_w_lite_pushbit   ,
  output logic               rx_w_lite_credit    ,

  output logic [  33:   0]   rx_r_lite_data      ,
  output logic               rx_r_lite_push_ovrd ,
  output logic               rx_r_lite_pushbit   ,
  input  logic               tx_r_lite_credit    ,

  output logic [   1:   0]   rx_b_lite_data      ,
  output logic               rx_b_lite_push_ovrd ,
  output logic               rx_b_lite_pushbit   ,
  input  logic               tx_b_lite_credit    ,

// PHY Interconnect
  output logic [ 159:   0]   tx_phy0             ,
  input  logic [ 159:   0]   rx_phy0             ,

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
  assign tx_ar_lite_pop_ovrd                = 1'b0                               ;
  assign tx_aw_lite_pop_ovrd                = 1'b0                               ;
  assign tx_w_lite_pop_ovrd                 = 1'b0                               ;

// No RX Packetization, so tie off packetization signals
  assign rx_r_lite_push_ovrd                = 1'b0                               ;
  assign rx_b_lite_push_ovrd                = 1'b0                               ;

//////////////////////////////////////////////////////////////////
// TX Section

//   TX_CH_WIDTH           = 160; // Gen2Only running at Half Rate
//   TX_DATA_WIDTH         = 149; // Usable Data per Channel
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

  logic [ 159:   0]                              tx_phy_preflop_0              ;
  logic [ 159:   0]                              tx_phy_flop_0_reg             ;

  always_ff @(posedge clk_wr or negedge rst_wr_n)
  if (~rst_wr_n)
  begin
    tx_phy_flop_0_reg                       <= 160'b0                                  ;
  end
  else
  begin
    tx_phy_flop_0_reg                       <= tx_phy_preflop_0                        ;
  end

  assign tx_phy0                            = TX_REG_PHY ? tx_phy_flop_0_reg : tx_phy_preflop_0               ;

  assign tx_phy_preflop_0 [   0] = tx_ar_lite_pushbit         ;
  assign tx_phy_preflop_0 [   1] = tx_ar_lite_data     [   0] ;
  assign tx_phy_preflop_0 [   2] = tx_ar_lite_data     [   1] ;
  assign tx_phy_preflop_0 [   3] = tx_ar_lite_data     [   2] ;
  assign tx_phy_preflop_0 [   4] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_0 [   5] = tx_ar_lite_data     [   3] ;
  assign tx_phy_preflop_0 [   6] = tx_ar_lite_data     [   4] ;
  assign tx_phy_preflop_0 [   7] = tx_ar_lite_data     [   5] ;
  assign tx_phy_preflop_0 [   8] = tx_ar_lite_data     [   6] ;
  assign tx_phy_preflop_0 [   9] = tx_ar_lite_data     [   7] ;
  assign tx_phy_preflop_0 [  10] = tx_ar_lite_data     [   8] ;
  assign tx_phy_preflop_0 [  11] = tx_ar_lite_data     [   9] ;
  assign tx_phy_preflop_0 [  12] = tx_ar_lite_data     [  10] ;
  assign tx_phy_preflop_0 [  13] = tx_ar_lite_data     [  11] ;
  assign tx_phy_preflop_0 [  14] = tx_ar_lite_data     [  12] ;
  assign tx_phy_preflop_0 [  15] = tx_ar_lite_data     [  13] ;
  assign tx_phy_preflop_0 [  16] = tx_ar_lite_data     [  14] ;
  assign tx_phy_preflop_0 [  17] = tx_ar_lite_data     [  15] ;
  assign tx_phy_preflop_0 [  18] = tx_ar_lite_data     [  16] ;
  assign tx_phy_preflop_0 [  19] = tx_ar_lite_data     [  17] ;
  assign tx_phy_preflop_0 [  20] = tx_ar_lite_data     [  18] ;
  assign tx_phy_preflop_0 [  21] = tx_ar_lite_data     [  19] ;
  assign tx_phy_preflop_0 [  22] = tx_ar_lite_data     [  20] ;
  assign tx_phy_preflop_0 [  23] = tx_ar_lite_data     [  21] ;
  assign tx_phy_preflop_0 [  24] = tx_ar_lite_data     [  22] ;
  assign tx_phy_preflop_0 [  25] = tx_ar_lite_data     [  23] ;
  assign tx_phy_preflop_0 [  26] = tx_ar_lite_data     [  24] ;
  assign tx_phy_preflop_0 [  27] = tx_ar_lite_data     [  25] ;
  assign tx_phy_preflop_0 [  28] = tx_ar_lite_data     [  26] ;
  assign tx_phy_preflop_0 [  29] = tx_ar_lite_data     [  27] ;
  assign tx_phy_preflop_0 [  30] = tx_ar_lite_data     [  28] ;
  assign tx_phy_preflop_0 [  31] = tx_ar_lite_data     [  29] ;
  assign tx_phy_preflop_0 [  32] = tx_ar_lite_data     [  30] ;
  assign tx_phy_preflop_0 [  33] = tx_ar_lite_data     [  31] ;
  assign tx_phy_preflop_0 [  34] = tx_aw_lite_pushbit         ;
  assign tx_phy_preflop_0 [  35] = tx_aw_lite_data     [   0] ;
  assign tx_phy_preflop_0 [  36] = tx_aw_lite_data     [   1] ;
  assign tx_phy_preflop_0 [  37] = tx_aw_lite_data     [   2] ;
  assign tx_phy_preflop_0 [  38] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [  39] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [  40] = tx_aw_lite_data     [   3] ;
  assign tx_phy_preflop_0 [  41] = tx_aw_lite_data     [   4] ;
  assign tx_phy_preflop_0 [  42] = tx_aw_lite_data     [   5] ;
  assign tx_phy_preflop_0 [  43] = tx_aw_lite_data     [   6] ;
  assign tx_phy_preflop_0 [  44] = tx_aw_lite_data     [   7] ;
  assign tx_phy_preflop_0 [  45] = tx_aw_lite_data     [   8] ;
  assign tx_phy_preflop_0 [  46] = tx_aw_lite_data     [   9] ;
  assign tx_phy_preflop_0 [  47] = tx_aw_lite_data     [  10] ;
  assign tx_phy_preflop_0 [  48] = tx_aw_lite_data     [  11] ;
  assign tx_phy_preflop_0 [  49] = tx_aw_lite_data     [  12] ;
  assign tx_phy_preflop_0 [  50] = tx_aw_lite_data     [  13] ;
  assign tx_phy_preflop_0 [  51] = tx_aw_lite_data     [  14] ;
  assign tx_phy_preflop_0 [  52] = tx_aw_lite_data     [  15] ;
  assign tx_phy_preflop_0 [  53] = tx_aw_lite_data     [  16] ;
  assign tx_phy_preflop_0 [  54] = tx_aw_lite_data     [  17] ;
  assign tx_phy_preflop_0 [  55] = tx_aw_lite_data     [  18] ;
  assign tx_phy_preflop_0 [  56] = tx_aw_lite_data     [  19] ;
  assign tx_phy_preflop_0 [  57] = tx_aw_lite_data     [  20] ;
  assign tx_phy_preflop_0 [  58] = tx_aw_lite_data     [  21] ;
  assign tx_phy_preflop_0 [  59] = tx_aw_lite_data     [  22] ;
  assign tx_phy_preflop_0 [  60] = tx_aw_lite_data     [  23] ;
  assign tx_phy_preflop_0 [  61] = tx_aw_lite_data     [  24] ;
  assign tx_phy_preflop_0 [  62] = tx_aw_lite_data     [  25] ;
  assign tx_phy_preflop_0 [  63] = tx_aw_lite_data     [  26] ;
  assign tx_phy_preflop_0 [  64] = tx_aw_lite_data     [  27] ;
  assign tx_phy_preflop_0 [  65] = tx_aw_lite_data     [  28] ;
  assign tx_phy_preflop_0 [  66] = tx_aw_lite_data     [  29] ;
  assign tx_phy_preflop_0 [  67] = tx_aw_lite_data     [  30] ;
  assign tx_phy_preflop_0 [  68] = tx_aw_lite_data     [  31] ;
  assign tx_phy_preflop_0 [  69] = tx_w_lite_pushbit          ;
  assign tx_phy_preflop_0 [  70] = tx_w_lite_data      [   0] ;
  assign tx_phy_preflop_0 [  71] = tx_w_lite_data      [   1] ;
  assign tx_phy_preflop_0 [  72] = tx_w_lite_data      [   2] ;
  assign tx_phy_preflop_0 [  73] = tx_w_lite_data      [   3] ;
  assign tx_phy_preflop_0 [  74] = tx_w_lite_data      [   4] ;
  assign tx_phy_preflop_0 [  75] = tx_w_lite_data      [   5] ;
  assign tx_phy_preflop_0 [  76] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_0 [  77] = tx_w_lite_data      [   6] ;
  assign tx_phy_preflop_0 [  78] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [  79] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [  80] = tx_w_lite_data      [   7] ;
  assign tx_phy_preflop_0 [  81] = tx_w_lite_data      [   8] ;
  assign tx_phy_preflop_0 [  82] = tx_w_lite_data      [   9] ;
  assign tx_phy_preflop_0 [  83] = tx_w_lite_data      [  10] ;
  assign tx_phy_preflop_0 [  84] = tx_mrk_userbit[1]          ; // MARKER
  assign tx_phy_preflop_0 [  85] = tx_w_lite_data      [  11] ;
  assign tx_phy_preflop_0 [  86] = tx_w_lite_data      [  12] ;
  assign tx_phy_preflop_0 [  87] = tx_w_lite_data      [  13] ;
  assign tx_phy_preflop_0 [  88] = tx_w_lite_data      [  14] ;
  assign tx_phy_preflop_0 [  89] = tx_w_lite_data      [  15] ;
  assign tx_phy_preflop_0 [  90] = tx_w_lite_data      [  16] ;
  assign tx_phy_preflop_0 [  91] = tx_w_lite_data      [  17] ;
  assign tx_phy_preflop_0 [  92] = tx_w_lite_data      [  18] ;
  assign tx_phy_preflop_0 [  93] = tx_w_lite_data      [  19] ;
  assign tx_phy_preflop_0 [  94] = tx_w_lite_data      [  20] ;
  assign tx_phy_preflop_0 [  95] = tx_w_lite_data      [  21] ;
  assign tx_phy_preflop_0 [  96] = tx_w_lite_data      [  22] ;
  assign tx_phy_preflop_0 [  97] = tx_w_lite_data      [  23] ;
  assign tx_phy_preflop_0 [  98] = tx_w_lite_data      [  24] ;
  assign tx_phy_preflop_0 [  99] = tx_w_lite_data      [  25] ;
  assign tx_phy_preflop_0 [ 100] = tx_w_lite_data      [  26] ;
  assign tx_phy_preflop_0 [ 101] = tx_w_lite_data      [  27] ;
  assign tx_phy_preflop_0 [ 102] = tx_w_lite_data      [  28] ;
  assign tx_phy_preflop_0 [ 103] = tx_w_lite_data      [  29] ;
  assign tx_phy_preflop_0 [ 104] = tx_w_lite_data      [  30] ;
  assign tx_phy_preflop_0 [ 105] = tx_w_lite_data      [  31] ;
  assign tx_phy_preflop_0 [ 106] = tx_w_lite_data      [  32] ;
  assign tx_phy_preflop_0 [ 107] = tx_w_lite_data      [  33] ;
  assign tx_phy_preflop_0 [ 108] = tx_w_lite_data      [  34] ;
  assign tx_phy_preflop_0 [ 109] = tx_w_lite_data      [  35] ;
  assign tx_phy_preflop_0 [ 110] = tx_r_lite_credit           ;
  assign tx_phy_preflop_0 [ 111] = tx_b_lite_credit           ;
  assign tx_phy_preflop_0 [ 112] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 113] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 114] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 115] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 116] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 117] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 118] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [ 119] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [ 120] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 121] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 122] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 123] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 124] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 125] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 126] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 127] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 128] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 129] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 130] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 131] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 132] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 133] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 134] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 135] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 136] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 137] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 138] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 139] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 140] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 141] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 142] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 143] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 144] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 145] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 146] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 147] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 148] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 149] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 150] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 151] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 152] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 153] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 154] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 155] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 156] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 157] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 158] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [ 159] = 1'b0                       ; // DBI
// TX Section
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// RX Section

//   RX_CH_WIDTH           = 160; // Gen2Only running at Half Rate
//   RX_DATA_WIDTH         = 149; // Usable Data per Channel
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

  logic [ 159:   0]                              rx_phy_postflop_0             ;
  logic [ 159:   0]                              rx_phy_flop_0_reg             ;

  always_ff @(posedge clk_rd or negedge rst_rd_n)
  if (~rst_rd_n)
  begin
    rx_phy_flop_0_reg                       <= 160'b0                                  ;
  end
  else
  begin
    rx_phy_flop_0_reg                       <= rx_phy0                                 ;
  end


  assign rx_phy_postflop_0                  = RX_REG_PHY ? rx_phy_flop_0_reg : rx_phy0               ;

  assign rx_ar_lite_credit          = rx_phy_postflop_0 [   0];
  assign rx_aw_lite_credit          = rx_phy_postflop_0 [   1];
  assign rx_w_lite_credit           = rx_phy_postflop_0 [   2];
  assign rx_r_lite_pushbit          = rx_phy_postflop_0 [   3];
//       MARKER                     = rx_phy_postflop_0 [   4]
  assign rx_r_lite_data      [   0] = rx_phy_postflop_0 [   5];
  assign rx_r_lite_data      [   1] = rx_phy_postflop_0 [   6];
  assign rx_r_lite_data      [   2] = rx_phy_postflop_0 [   7];
  assign rx_r_lite_data      [   3] = rx_phy_postflop_0 [   8];
  assign rx_r_lite_data      [   4] = rx_phy_postflop_0 [   9];
  assign rx_r_lite_data      [   5] = rx_phy_postflop_0 [  10];
  assign rx_r_lite_data      [   6] = rx_phy_postflop_0 [  11];
  assign rx_r_lite_data      [   7] = rx_phy_postflop_0 [  12];
  assign rx_r_lite_data      [   8] = rx_phy_postflop_0 [  13];
  assign rx_r_lite_data      [   9] = rx_phy_postflop_0 [  14];
  assign rx_r_lite_data      [  10] = rx_phy_postflop_0 [  15];
  assign rx_r_lite_data      [  11] = rx_phy_postflop_0 [  16];
  assign rx_r_lite_data      [  12] = rx_phy_postflop_0 [  17];
  assign rx_r_lite_data      [  13] = rx_phy_postflop_0 [  18];
  assign rx_r_lite_data      [  14] = rx_phy_postflop_0 [  19];
  assign rx_r_lite_data      [  15] = rx_phy_postflop_0 [  20];
  assign rx_r_lite_data      [  16] = rx_phy_postflop_0 [  21];
  assign rx_r_lite_data      [  17] = rx_phy_postflop_0 [  22];
  assign rx_r_lite_data      [  18] = rx_phy_postflop_0 [  23];
  assign rx_r_lite_data      [  19] = rx_phy_postflop_0 [  24];
  assign rx_r_lite_data      [  20] = rx_phy_postflop_0 [  25];
  assign rx_r_lite_data      [  21] = rx_phy_postflop_0 [  26];
  assign rx_r_lite_data      [  22] = rx_phy_postflop_0 [  27];
  assign rx_r_lite_data      [  23] = rx_phy_postflop_0 [  28];
  assign rx_r_lite_data      [  24] = rx_phy_postflop_0 [  29];
  assign rx_r_lite_data      [  25] = rx_phy_postflop_0 [  30];
  assign rx_r_lite_data      [  26] = rx_phy_postflop_0 [  31];
  assign rx_r_lite_data      [  27] = rx_phy_postflop_0 [  32];
  assign rx_r_lite_data      [  28] = rx_phy_postflop_0 [  33];
  assign rx_r_lite_data      [  29] = rx_phy_postflop_0 [  34];
  assign rx_r_lite_data      [  30] = rx_phy_postflop_0 [  35];
  assign rx_r_lite_data      [  31] = rx_phy_postflop_0 [  36];
  assign rx_r_lite_data      [  32] = rx_phy_postflop_0 [  37];
//       DBI                        = rx_phy_postflop_0 [  38];
//       DBI                        = rx_phy_postflop_0 [  39];
  assign rx_r_lite_data      [  33] = rx_phy_postflop_0 [  40];
  assign rx_b_lite_pushbit          = rx_phy_postflop_0 [  41];
  assign rx_b_lite_data      [   0] = rx_phy_postflop_0 [  42];
  assign rx_b_lite_data      [   1] = rx_phy_postflop_0 [  43];
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
//       STROBE                     = rx_phy_postflop_0 [  76]
//       nc                         = rx_phy_postflop_0 [  77];
//       DBI                        = rx_phy_postflop_0 [  78];
//       DBI                        = rx_phy_postflop_0 [  79];
//       nc                         = rx_phy_postflop_0 [  80];
//       nc                         = rx_phy_postflop_0 [  81];
//       nc                         = rx_phy_postflop_0 [  82];
//       nc                         = rx_phy_postflop_0 [  83];
//       MARKER                     = rx_phy_postflop_0 [  84]
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

// RX Section
//////////////////////////////////////////////////////////////////


endmodule
