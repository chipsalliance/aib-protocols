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

module lpif_txrx_x16_asym1_full_master_concat  (

// Data from Logic Links
  input  logic [ 536:   0]   tx_downstream_data  ,
  output logic               tx_downstream_pop_ovrd,

  output logic [ 536:   0]   rx_upstream_data    ,
  output logic               rx_upstream_push_ovrd,

// PHY Interconnect
  output logic [  39:   0]   tx_phy0             ,
  input  logic [  39:   0]   rx_phy0             ,
  output logic [  39:   0]   tx_phy1             ,
  input  logic [  39:   0]   rx_phy1             ,
  output logic [  39:   0]   tx_phy2             ,
  input  logic [  39:   0]   rx_phy2             ,
  output logic [  39:   0]   tx_phy3             ,
  input  logic [  39:   0]   rx_phy3             ,
  output logic [  39:   0]   tx_phy4             ,
  input  logic [  39:   0]   rx_phy4             ,
  output logic [  39:   0]   tx_phy5             ,
  input  logic [  39:   0]   rx_phy5             ,
  output logic [  39:   0]   tx_phy6             ,
  input  logic [  39:   0]   rx_phy6             ,
  output logic [  39:   0]   tx_phy7             ,
  input  logic [  39:   0]   rx_phy7             ,
  output logic [  39:   0]   tx_phy8             ,
  input  logic [  39:   0]   rx_phy8             ,
  output logic [  39:   0]   tx_phy9             ,
  input  logic [  39:   0]   rx_phy9             ,
  output logic [  39:   0]   tx_phy10            ,
  input  logic [  39:   0]   rx_phy10            ,
  output logic [  39:   0]   tx_phy11            ,
  input  logic [  39:   0]   rx_phy11            ,
  output logic [  39:   0]   tx_phy12            ,
  input  logic [  39:   0]   rx_phy12            ,
  output logic [  39:   0]   tx_phy13            ,
  input  logic [  39:   0]   rx_phy13            ,
  output logic [  39:   0]   tx_phy14            ,
  input  logic [  39:   0]   rx_phy14            ,
  output logic [  39:   0]   tx_phy15            ,
  input  logic [  39:   0]   rx_phy15            ,

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

//   TX_CH_WIDTH           = 40; // Gen1Only running at Full Rate
//   TX_DATA_WIDTH         = 38; // Usable Data per Channel
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

  logic [  39:   0]                              tx_phy_preflop_0              ;
  logic [  39:   0]                              tx_phy_preflop_1              ;
  logic [  39:   0]                              tx_phy_preflop_2              ;
  logic [  39:   0]                              tx_phy_preflop_3              ;
  logic [  39:   0]                              tx_phy_preflop_4              ;
  logic [  39:   0]                              tx_phy_preflop_5              ;
  logic [  39:   0]                              tx_phy_preflop_6              ;
  logic [  39:   0]                              tx_phy_preflop_7              ;
  logic [  39:   0]                              tx_phy_preflop_8              ;
  logic [  39:   0]                              tx_phy_preflop_9              ;
  logic [  39:   0]                              tx_phy_preflop_10             ;
  logic [  39:   0]                              tx_phy_preflop_11             ;
  logic [  39:   0]                              tx_phy_preflop_12             ;
  logic [  39:   0]                              tx_phy_preflop_13             ;
  logic [  39:   0]                              tx_phy_preflop_14             ;
  logic [  39:   0]                              tx_phy_preflop_15             ;
  logic [  39:   0]                              tx_phy_flop_0_reg             ;
  logic [  39:   0]                              tx_phy_flop_1_reg             ;
  logic [  39:   0]                              tx_phy_flop_2_reg             ;
  logic [  39:   0]                              tx_phy_flop_3_reg             ;
  logic [  39:   0]                              tx_phy_flop_4_reg             ;
  logic [  39:   0]                              tx_phy_flop_5_reg             ;
  logic [  39:   0]                              tx_phy_flop_6_reg             ;
  logic [  39:   0]                              tx_phy_flop_7_reg             ;
  logic [  39:   0]                              tx_phy_flop_8_reg             ;
  logic [  39:   0]                              tx_phy_flop_9_reg             ;
  logic [  39:   0]                              tx_phy_flop_10_reg            ;
  logic [  39:   0]                              tx_phy_flop_11_reg            ;
  logic [  39:   0]                              tx_phy_flop_12_reg            ;
  logic [  39:   0]                              tx_phy_flop_13_reg            ;
  logic [  39:   0]                              tx_phy_flop_14_reg            ;
  logic [  39:   0]                              tx_phy_flop_15_reg            ;

  always_ff @(posedge clk_wr or negedge rst_wr_n)
  if (~rst_wr_n)
  begin
    tx_phy_flop_0_reg                       <= 40'b0                                   ;
    tx_phy_flop_1_reg                       <= 40'b0                                   ;
    tx_phy_flop_2_reg                       <= 40'b0                                   ;
    tx_phy_flop_3_reg                       <= 40'b0                                   ;
    tx_phy_flop_4_reg                       <= 40'b0                                   ;
    tx_phy_flop_5_reg                       <= 40'b0                                   ;
    tx_phy_flop_6_reg                       <= 40'b0                                   ;
    tx_phy_flop_7_reg                       <= 40'b0                                   ;
    tx_phy_flop_8_reg                       <= 40'b0                                   ;
    tx_phy_flop_9_reg                       <= 40'b0                                   ;
    tx_phy_flop_10_reg                      <= 40'b0                                   ;
    tx_phy_flop_11_reg                      <= 40'b0                                   ;
    tx_phy_flop_12_reg                      <= 40'b0                                   ;
    tx_phy_flop_13_reg                      <= 40'b0                                   ;
    tx_phy_flop_14_reg                      <= 40'b0                                   ;
    tx_phy_flop_15_reg                      <= 40'b0                                   ;
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
    tx_phy_flop_7_reg                       <= tx_phy_preflop_7                        ;
    tx_phy_flop_8_reg                       <= tx_phy_preflop_8                        ;
    tx_phy_flop_9_reg                       <= tx_phy_preflop_9                        ;
    tx_phy_flop_10_reg                      <= tx_phy_preflop_10                       ;
    tx_phy_flop_11_reg                      <= tx_phy_preflop_11                       ;
    tx_phy_flop_12_reg                      <= tx_phy_preflop_12                       ;
    tx_phy_flop_13_reg                      <= tx_phy_preflop_13                       ;
    tx_phy_flop_14_reg                      <= tx_phy_preflop_14                       ;
    tx_phy_flop_15_reg                      <= tx_phy_preflop_15                       ;
  end

  assign tx_phy0                            = TX_REG_PHY ? tx_phy_flop_0_reg : tx_phy_preflop_0               ;
  assign tx_phy1                            = TX_REG_PHY ? tx_phy_flop_1_reg : tx_phy_preflop_1               ;
  assign tx_phy2                            = TX_REG_PHY ? tx_phy_flop_2_reg : tx_phy_preflop_2               ;
  assign tx_phy3                            = TX_REG_PHY ? tx_phy_flop_3_reg : tx_phy_preflop_3               ;
  assign tx_phy4                            = TX_REG_PHY ? tx_phy_flop_4_reg : tx_phy_preflop_4               ;
  assign tx_phy5                            = TX_REG_PHY ? tx_phy_flop_5_reg : tx_phy_preflop_5               ;
  assign tx_phy6                            = TX_REG_PHY ? tx_phy_flop_6_reg : tx_phy_preflop_6               ;
  assign tx_phy7                            = TX_REG_PHY ? tx_phy_flop_7_reg : tx_phy_preflop_7               ;
  assign tx_phy8                            = TX_REG_PHY ? tx_phy_flop_8_reg : tx_phy_preflop_8               ;
  assign tx_phy9                            = TX_REG_PHY ? tx_phy_flop_9_reg : tx_phy_preflop_9               ;
  assign tx_phy10                           = TX_REG_PHY ? tx_phy_flop_10_reg : tx_phy_preflop_10               ;
  assign tx_phy11                           = TX_REG_PHY ? tx_phy_flop_11_reg : tx_phy_preflop_11               ;
  assign tx_phy12                           = TX_REG_PHY ? tx_phy_flop_12_reg : tx_phy_preflop_12               ;
  assign tx_phy13                           = TX_REG_PHY ? tx_phy_flop_13_reg : tx_phy_preflop_13               ;
  assign tx_phy14                           = TX_REG_PHY ? tx_phy_flop_14_reg : tx_phy_preflop_14               ;
  assign tx_phy15                           = TX_REG_PHY ? tx_phy_flop_15_reg : tx_phy_preflop_15               ;

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
  assign tx_phy_preflop_0 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_1 [   0] = tx_downstream_data  [  38] ;
  assign tx_phy_preflop_1 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_1 [   2] = tx_downstream_data  [  39] ;
  assign tx_phy_preflop_1 [   3] = tx_downstream_data  [  40] ;
  assign tx_phy_preflop_1 [   4] = tx_downstream_data  [  41] ;
  assign tx_phy_preflop_1 [   5] = tx_downstream_data  [  42] ;
  assign tx_phy_preflop_1 [   6] = tx_downstream_data  [  43] ;
  assign tx_phy_preflop_1 [   7] = tx_downstream_data  [  44] ;
  assign tx_phy_preflop_1 [   8] = tx_downstream_data  [  45] ;
  assign tx_phy_preflop_1 [   9] = tx_downstream_data  [  46] ;
  assign tx_phy_preflop_1 [  10] = tx_downstream_data  [  47] ;
  assign tx_phy_preflop_1 [  11] = tx_downstream_data  [  48] ;
  assign tx_phy_preflop_1 [  12] = tx_downstream_data  [  49] ;
  assign tx_phy_preflop_1 [  13] = tx_downstream_data  [  50] ;
  assign tx_phy_preflop_1 [  14] = tx_downstream_data  [  51] ;
  assign tx_phy_preflop_1 [  15] = tx_downstream_data  [  52] ;
  assign tx_phy_preflop_1 [  16] = tx_downstream_data  [  53] ;
  assign tx_phy_preflop_1 [  17] = tx_downstream_data  [  54] ;
  assign tx_phy_preflop_1 [  18] = tx_downstream_data  [  55] ;
  assign tx_phy_preflop_1 [  19] = tx_downstream_data  [  56] ;
  assign tx_phy_preflop_1 [  20] = tx_downstream_data  [  57] ;
  assign tx_phy_preflop_1 [  21] = tx_downstream_data  [  58] ;
  assign tx_phy_preflop_1 [  22] = tx_downstream_data  [  59] ;
  assign tx_phy_preflop_1 [  23] = tx_downstream_data  [  60] ;
  assign tx_phy_preflop_1 [  24] = tx_downstream_data  [  61] ;
  assign tx_phy_preflop_1 [  25] = tx_downstream_data  [  62] ;
  assign tx_phy_preflop_1 [  26] = tx_downstream_data  [  63] ;
  assign tx_phy_preflop_1 [  27] = tx_downstream_data  [  64] ;
  assign tx_phy_preflop_1 [  28] = tx_downstream_data  [  65] ;
  assign tx_phy_preflop_1 [  29] = tx_downstream_data  [  66] ;
  assign tx_phy_preflop_1 [  30] = tx_downstream_data  [  67] ;
  assign tx_phy_preflop_1 [  31] = tx_downstream_data  [  68] ;
  assign tx_phy_preflop_1 [  32] = tx_downstream_data  [  69] ;
  assign tx_phy_preflop_1 [  33] = tx_downstream_data  [  70] ;
  assign tx_phy_preflop_1 [  34] = tx_downstream_data  [  71] ;
  assign tx_phy_preflop_1 [  35] = tx_downstream_data  [  72] ;
  assign tx_phy_preflop_1 [  36] = tx_downstream_data  [  73] ;
  assign tx_phy_preflop_1 [  37] = tx_downstream_data  [  74] ;
  assign tx_phy_preflop_1 [  38] = tx_downstream_data  [  75] ;
  assign tx_phy_preflop_1 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_2 [   0] = tx_downstream_data  [  76] ;
  assign tx_phy_preflop_2 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_2 [   2] = tx_downstream_data  [  77] ;
  assign tx_phy_preflop_2 [   3] = tx_downstream_data  [  78] ;
  assign tx_phy_preflop_2 [   4] = tx_downstream_data  [  79] ;
  assign tx_phy_preflop_2 [   5] = tx_downstream_data  [  80] ;
  assign tx_phy_preflop_2 [   6] = tx_downstream_data  [  81] ;
  assign tx_phy_preflop_2 [   7] = tx_downstream_data  [  82] ;
  assign tx_phy_preflop_2 [   8] = tx_downstream_data  [  83] ;
  assign tx_phy_preflop_2 [   9] = tx_downstream_data  [  84] ;
  assign tx_phy_preflop_2 [  10] = tx_downstream_data  [  85] ;
  assign tx_phy_preflop_2 [  11] = tx_downstream_data  [  86] ;
  assign tx_phy_preflop_2 [  12] = tx_downstream_data  [  87] ;
  assign tx_phy_preflop_2 [  13] = tx_downstream_data  [  88] ;
  assign tx_phy_preflop_2 [  14] = tx_downstream_data  [  89] ;
  assign tx_phy_preflop_2 [  15] = tx_downstream_data  [  90] ;
  assign tx_phy_preflop_2 [  16] = tx_downstream_data  [  91] ;
  assign tx_phy_preflop_2 [  17] = tx_downstream_data  [  92] ;
  assign tx_phy_preflop_2 [  18] = tx_downstream_data  [  93] ;
  assign tx_phy_preflop_2 [  19] = tx_downstream_data  [  94] ;
  assign tx_phy_preflop_2 [  20] = tx_downstream_data  [  95] ;
  assign tx_phy_preflop_2 [  21] = tx_downstream_data  [  96] ;
  assign tx_phy_preflop_2 [  22] = tx_downstream_data  [  97] ;
  assign tx_phy_preflop_2 [  23] = tx_downstream_data  [  98] ;
  assign tx_phy_preflop_2 [  24] = tx_downstream_data  [  99] ;
  assign tx_phy_preflop_2 [  25] = tx_downstream_data  [ 100] ;
  assign tx_phy_preflop_2 [  26] = tx_downstream_data  [ 101] ;
  assign tx_phy_preflop_2 [  27] = tx_downstream_data  [ 102] ;
  assign tx_phy_preflop_2 [  28] = tx_downstream_data  [ 103] ;
  assign tx_phy_preflop_2 [  29] = tx_downstream_data  [ 104] ;
  assign tx_phy_preflop_2 [  30] = tx_downstream_data  [ 105] ;
  assign tx_phy_preflop_2 [  31] = tx_downstream_data  [ 106] ;
  assign tx_phy_preflop_2 [  32] = tx_downstream_data  [ 107] ;
  assign tx_phy_preflop_2 [  33] = tx_downstream_data  [ 108] ;
  assign tx_phy_preflop_2 [  34] = tx_downstream_data  [ 109] ;
  assign tx_phy_preflop_2 [  35] = tx_downstream_data  [ 110] ;
  assign tx_phy_preflop_2 [  36] = tx_downstream_data  [ 111] ;
  assign tx_phy_preflop_2 [  37] = tx_downstream_data  [ 112] ;
  assign tx_phy_preflop_2 [  38] = tx_downstream_data  [ 113] ;
  assign tx_phy_preflop_2 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_3 [   0] = tx_downstream_data  [ 114] ;
  assign tx_phy_preflop_3 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_3 [   2] = tx_downstream_data  [ 115] ;
  assign tx_phy_preflop_3 [   3] = tx_downstream_data  [ 116] ;
  assign tx_phy_preflop_3 [   4] = tx_downstream_data  [ 117] ;
  assign tx_phy_preflop_3 [   5] = tx_downstream_data  [ 118] ;
  assign tx_phy_preflop_3 [   6] = tx_downstream_data  [ 119] ;
  assign tx_phy_preflop_3 [   7] = tx_downstream_data  [ 120] ;
  assign tx_phy_preflop_3 [   8] = tx_downstream_data  [ 121] ;
  assign tx_phy_preflop_3 [   9] = tx_downstream_data  [ 122] ;
  assign tx_phy_preflop_3 [  10] = tx_downstream_data  [ 123] ;
  assign tx_phy_preflop_3 [  11] = tx_downstream_data  [ 124] ;
  assign tx_phy_preflop_3 [  12] = tx_downstream_data  [ 125] ;
  assign tx_phy_preflop_3 [  13] = tx_downstream_data  [ 126] ;
  assign tx_phy_preflop_3 [  14] = tx_downstream_data  [ 127] ;
  assign tx_phy_preflop_3 [  15] = tx_downstream_data  [ 128] ;
  assign tx_phy_preflop_3 [  16] = tx_downstream_data  [ 129] ;
  assign tx_phy_preflop_3 [  17] = tx_downstream_data  [ 130] ;
  assign tx_phy_preflop_3 [  18] = tx_downstream_data  [ 131] ;
  assign tx_phy_preflop_3 [  19] = tx_downstream_data  [ 132] ;
  assign tx_phy_preflop_3 [  20] = tx_downstream_data  [ 133] ;
  assign tx_phy_preflop_3 [  21] = tx_downstream_data  [ 134] ;
  assign tx_phy_preflop_3 [  22] = tx_downstream_data  [ 135] ;
  assign tx_phy_preflop_3 [  23] = tx_downstream_data  [ 136] ;
  assign tx_phy_preflop_3 [  24] = tx_downstream_data  [ 137] ;
  assign tx_phy_preflop_3 [  25] = tx_downstream_data  [ 138] ;
  assign tx_phy_preflop_3 [  26] = tx_downstream_data  [ 139] ;
  assign tx_phy_preflop_3 [  27] = tx_downstream_data  [ 140] ;
  assign tx_phy_preflop_3 [  28] = tx_downstream_data  [ 141] ;
  assign tx_phy_preflop_3 [  29] = tx_downstream_data  [ 142] ;
  assign tx_phy_preflop_3 [  30] = tx_downstream_data  [ 143] ;
  assign tx_phy_preflop_3 [  31] = tx_downstream_data  [ 144] ;
  assign tx_phy_preflop_3 [  32] = tx_downstream_data  [ 145] ;
  assign tx_phy_preflop_3 [  33] = tx_downstream_data  [ 146] ;
  assign tx_phy_preflop_3 [  34] = tx_downstream_data  [ 147] ;
  assign tx_phy_preflop_3 [  35] = tx_downstream_data  [ 148] ;
  assign tx_phy_preflop_3 [  36] = tx_downstream_data  [ 149] ;
  assign tx_phy_preflop_3 [  37] = tx_downstream_data  [ 150] ;
  assign tx_phy_preflop_3 [  38] = tx_downstream_data  [ 151] ;
  assign tx_phy_preflop_3 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_4 [   0] = tx_downstream_data  [ 152] ;
  assign tx_phy_preflop_4 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_4 [   2] = tx_downstream_data  [ 153] ;
  assign tx_phy_preflop_4 [   3] = tx_downstream_data  [ 154] ;
  assign tx_phy_preflop_4 [   4] = tx_downstream_data  [ 155] ;
  assign tx_phy_preflop_4 [   5] = tx_downstream_data  [ 156] ;
  assign tx_phy_preflop_4 [   6] = tx_downstream_data  [ 157] ;
  assign tx_phy_preflop_4 [   7] = tx_downstream_data  [ 158] ;
  assign tx_phy_preflop_4 [   8] = tx_downstream_data  [ 159] ;
  assign tx_phy_preflop_4 [   9] = tx_downstream_data  [ 160] ;
  assign tx_phy_preflop_4 [  10] = tx_downstream_data  [ 161] ;
  assign tx_phy_preflop_4 [  11] = tx_downstream_data  [ 162] ;
  assign tx_phy_preflop_4 [  12] = tx_downstream_data  [ 163] ;
  assign tx_phy_preflop_4 [  13] = tx_downstream_data  [ 164] ;
  assign tx_phy_preflop_4 [  14] = tx_downstream_data  [ 165] ;
  assign tx_phy_preflop_4 [  15] = tx_downstream_data  [ 166] ;
  assign tx_phy_preflop_4 [  16] = tx_downstream_data  [ 167] ;
  assign tx_phy_preflop_4 [  17] = tx_downstream_data  [ 168] ;
  assign tx_phy_preflop_4 [  18] = tx_downstream_data  [ 169] ;
  assign tx_phy_preflop_4 [  19] = tx_downstream_data  [ 170] ;
  assign tx_phy_preflop_4 [  20] = tx_downstream_data  [ 171] ;
  assign tx_phy_preflop_4 [  21] = tx_downstream_data  [ 172] ;
  assign tx_phy_preflop_4 [  22] = tx_downstream_data  [ 173] ;
  assign tx_phy_preflop_4 [  23] = tx_downstream_data  [ 174] ;
  assign tx_phy_preflop_4 [  24] = tx_downstream_data  [ 175] ;
  assign tx_phy_preflop_4 [  25] = tx_downstream_data  [ 176] ;
  assign tx_phy_preflop_4 [  26] = tx_downstream_data  [ 177] ;
  assign tx_phy_preflop_4 [  27] = tx_downstream_data  [ 178] ;
  assign tx_phy_preflop_4 [  28] = tx_downstream_data  [ 179] ;
  assign tx_phy_preflop_4 [  29] = tx_downstream_data  [ 180] ;
  assign tx_phy_preflop_4 [  30] = tx_downstream_data  [ 181] ;
  assign tx_phy_preflop_4 [  31] = tx_downstream_data  [ 182] ;
  assign tx_phy_preflop_4 [  32] = tx_downstream_data  [ 183] ;
  assign tx_phy_preflop_4 [  33] = tx_downstream_data  [ 184] ;
  assign tx_phy_preflop_4 [  34] = tx_downstream_data  [ 185] ;
  assign tx_phy_preflop_4 [  35] = tx_downstream_data  [ 186] ;
  assign tx_phy_preflop_4 [  36] = tx_downstream_data  [ 187] ;
  assign tx_phy_preflop_4 [  37] = tx_downstream_data  [ 188] ;
  assign tx_phy_preflop_4 [  38] = tx_downstream_data  [ 189] ;
  assign tx_phy_preflop_4 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_5 [   0] = tx_downstream_data  [ 190] ;
  assign tx_phy_preflop_5 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_5 [   2] = tx_downstream_data  [ 191] ;
  assign tx_phy_preflop_5 [   3] = tx_downstream_data  [ 192] ;
  assign tx_phy_preflop_5 [   4] = tx_downstream_data  [ 193] ;
  assign tx_phy_preflop_5 [   5] = tx_downstream_data  [ 194] ;
  assign tx_phy_preflop_5 [   6] = tx_downstream_data  [ 195] ;
  assign tx_phy_preflop_5 [   7] = tx_downstream_data  [ 196] ;
  assign tx_phy_preflop_5 [   8] = tx_downstream_data  [ 197] ;
  assign tx_phy_preflop_5 [   9] = tx_downstream_data  [ 198] ;
  assign tx_phy_preflop_5 [  10] = tx_downstream_data  [ 199] ;
  assign tx_phy_preflop_5 [  11] = tx_downstream_data  [ 200] ;
  assign tx_phy_preflop_5 [  12] = tx_downstream_data  [ 201] ;
  assign tx_phy_preflop_5 [  13] = tx_downstream_data  [ 202] ;
  assign tx_phy_preflop_5 [  14] = tx_downstream_data  [ 203] ;
  assign tx_phy_preflop_5 [  15] = tx_downstream_data  [ 204] ;
  assign tx_phy_preflop_5 [  16] = tx_downstream_data  [ 205] ;
  assign tx_phy_preflop_5 [  17] = tx_downstream_data  [ 206] ;
  assign tx_phy_preflop_5 [  18] = tx_downstream_data  [ 207] ;
  assign tx_phy_preflop_5 [  19] = tx_downstream_data  [ 208] ;
  assign tx_phy_preflop_5 [  20] = tx_downstream_data  [ 209] ;
  assign tx_phy_preflop_5 [  21] = tx_downstream_data  [ 210] ;
  assign tx_phy_preflop_5 [  22] = tx_downstream_data  [ 211] ;
  assign tx_phy_preflop_5 [  23] = tx_downstream_data  [ 212] ;
  assign tx_phy_preflop_5 [  24] = tx_downstream_data  [ 213] ;
  assign tx_phy_preflop_5 [  25] = tx_downstream_data  [ 214] ;
  assign tx_phy_preflop_5 [  26] = tx_downstream_data  [ 215] ;
  assign tx_phy_preflop_5 [  27] = tx_downstream_data  [ 216] ;
  assign tx_phy_preflop_5 [  28] = tx_downstream_data  [ 217] ;
  assign tx_phy_preflop_5 [  29] = tx_downstream_data  [ 218] ;
  assign tx_phy_preflop_5 [  30] = tx_downstream_data  [ 219] ;
  assign tx_phy_preflop_5 [  31] = tx_downstream_data  [ 220] ;
  assign tx_phy_preflop_5 [  32] = tx_downstream_data  [ 221] ;
  assign tx_phy_preflop_5 [  33] = tx_downstream_data  [ 222] ;
  assign tx_phy_preflop_5 [  34] = tx_downstream_data  [ 223] ;
  assign tx_phy_preflop_5 [  35] = tx_downstream_data  [ 224] ;
  assign tx_phy_preflop_5 [  36] = tx_downstream_data  [ 225] ;
  assign tx_phy_preflop_5 [  37] = tx_downstream_data  [ 226] ;
  assign tx_phy_preflop_5 [  38] = tx_downstream_data  [ 227] ;
  assign tx_phy_preflop_5 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_6 [   0] = tx_downstream_data  [ 228] ;
  assign tx_phy_preflop_6 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_6 [   2] = tx_downstream_data  [ 229] ;
  assign tx_phy_preflop_6 [   3] = tx_downstream_data  [ 230] ;
  assign tx_phy_preflop_6 [   4] = tx_downstream_data  [ 231] ;
  assign tx_phy_preflop_6 [   5] = tx_downstream_data  [ 232] ;
  assign tx_phy_preflop_6 [   6] = tx_downstream_data  [ 233] ;
  assign tx_phy_preflop_6 [   7] = tx_downstream_data  [ 234] ;
  assign tx_phy_preflop_6 [   8] = tx_downstream_data  [ 235] ;
  assign tx_phy_preflop_6 [   9] = tx_downstream_data  [ 236] ;
  assign tx_phy_preflop_6 [  10] = tx_downstream_data  [ 237] ;
  assign tx_phy_preflop_6 [  11] = tx_downstream_data  [ 238] ;
  assign tx_phy_preflop_6 [  12] = tx_downstream_data  [ 239] ;
  assign tx_phy_preflop_6 [  13] = tx_downstream_data  [ 240] ;
  assign tx_phy_preflop_6 [  14] = tx_downstream_data  [ 241] ;
  assign tx_phy_preflop_6 [  15] = tx_downstream_data  [ 242] ;
  assign tx_phy_preflop_6 [  16] = tx_downstream_data  [ 243] ;
  assign tx_phy_preflop_6 [  17] = tx_downstream_data  [ 244] ;
  assign tx_phy_preflop_6 [  18] = tx_downstream_data  [ 245] ;
  assign tx_phy_preflop_6 [  19] = tx_downstream_data  [ 246] ;
  assign tx_phy_preflop_6 [  20] = tx_downstream_data  [ 247] ;
  assign tx_phy_preflop_6 [  21] = tx_downstream_data  [ 248] ;
  assign tx_phy_preflop_6 [  22] = tx_downstream_data  [ 249] ;
  assign tx_phy_preflop_6 [  23] = tx_downstream_data  [ 250] ;
  assign tx_phy_preflop_6 [  24] = tx_downstream_data  [ 251] ;
  assign tx_phy_preflop_6 [  25] = tx_downstream_data  [ 252] ;
  assign tx_phy_preflop_6 [  26] = tx_downstream_data  [ 253] ;
  assign tx_phy_preflop_6 [  27] = tx_downstream_data  [ 254] ;
  assign tx_phy_preflop_6 [  28] = tx_downstream_data  [ 255] ;
  assign tx_phy_preflop_6 [  29] = tx_downstream_data  [ 256] ;
  assign tx_phy_preflop_6 [  30] = tx_downstream_data  [ 257] ;
  assign tx_phy_preflop_6 [  31] = tx_downstream_data  [ 258] ;
  assign tx_phy_preflop_6 [  32] = tx_downstream_data  [ 259] ;
  assign tx_phy_preflop_6 [  33] = tx_downstream_data  [ 260] ;
  assign tx_phy_preflop_6 [  34] = tx_downstream_data  [ 261] ;
  assign tx_phy_preflop_6 [  35] = tx_downstream_data  [ 262] ;
  assign tx_phy_preflop_6 [  36] = tx_downstream_data  [ 263] ;
  assign tx_phy_preflop_6 [  37] = tx_downstream_data  [ 264] ;
  assign tx_phy_preflop_6 [  38] = tx_downstream_data  [ 265] ;
  assign tx_phy_preflop_6 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_7 [   0] = tx_downstream_data  [ 266] ;
  assign tx_phy_preflop_7 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_7 [   2] = tx_downstream_data  [ 267] ;
  assign tx_phy_preflop_7 [   3] = tx_downstream_data  [ 268] ;
  assign tx_phy_preflop_7 [   4] = tx_downstream_data  [ 269] ;
  assign tx_phy_preflop_7 [   5] = tx_downstream_data  [ 270] ;
  assign tx_phy_preflop_7 [   6] = tx_downstream_data  [ 271] ;
  assign tx_phy_preflop_7 [   7] = tx_downstream_data  [ 272] ;
  assign tx_phy_preflop_7 [   8] = tx_downstream_data  [ 273] ;
  assign tx_phy_preflop_7 [   9] = tx_downstream_data  [ 274] ;
  assign tx_phy_preflop_7 [  10] = tx_downstream_data  [ 275] ;
  assign tx_phy_preflop_7 [  11] = tx_downstream_data  [ 276] ;
  assign tx_phy_preflop_7 [  12] = tx_downstream_data  [ 277] ;
  assign tx_phy_preflop_7 [  13] = tx_downstream_data  [ 278] ;
  assign tx_phy_preflop_7 [  14] = tx_downstream_data  [ 279] ;
  assign tx_phy_preflop_7 [  15] = tx_downstream_data  [ 280] ;
  assign tx_phy_preflop_7 [  16] = tx_downstream_data  [ 281] ;
  assign tx_phy_preflop_7 [  17] = tx_downstream_data  [ 282] ;
  assign tx_phy_preflop_7 [  18] = tx_downstream_data  [ 283] ;
  assign tx_phy_preflop_7 [  19] = tx_downstream_data  [ 284] ;
  assign tx_phy_preflop_7 [  20] = tx_downstream_data  [ 285] ;
  assign tx_phy_preflop_7 [  21] = tx_downstream_data  [ 286] ;
  assign tx_phy_preflop_7 [  22] = tx_downstream_data  [ 287] ;
  assign tx_phy_preflop_7 [  23] = tx_downstream_data  [ 288] ;
  assign tx_phy_preflop_7 [  24] = tx_downstream_data  [ 289] ;
  assign tx_phy_preflop_7 [  25] = tx_downstream_data  [ 290] ;
  assign tx_phy_preflop_7 [  26] = tx_downstream_data  [ 291] ;
  assign tx_phy_preflop_7 [  27] = tx_downstream_data  [ 292] ;
  assign tx_phy_preflop_7 [  28] = tx_downstream_data  [ 293] ;
  assign tx_phy_preflop_7 [  29] = tx_downstream_data  [ 294] ;
  assign tx_phy_preflop_7 [  30] = tx_downstream_data  [ 295] ;
  assign tx_phy_preflop_7 [  31] = tx_downstream_data  [ 296] ;
  assign tx_phy_preflop_7 [  32] = tx_downstream_data  [ 297] ;
  assign tx_phy_preflop_7 [  33] = tx_downstream_data  [ 298] ;
  assign tx_phy_preflop_7 [  34] = tx_downstream_data  [ 299] ;
  assign tx_phy_preflop_7 [  35] = tx_downstream_data  [ 300] ;
  assign tx_phy_preflop_7 [  36] = tx_downstream_data  [ 301] ;
  assign tx_phy_preflop_7 [  37] = tx_downstream_data  [ 302] ;
  assign tx_phy_preflop_7 [  38] = tx_downstream_data  [ 303] ;
  assign tx_phy_preflop_7 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_8 [   0] = tx_downstream_data  [ 304] ;
  assign tx_phy_preflop_8 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_8 [   2] = tx_downstream_data  [ 305] ;
  assign tx_phy_preflop_8 [   3] = tx_downstream_data  [ 306] ;
  assign tx_phy_preflop_8 [   4] = tx_downstream_data  [ 307] ;
  assign tx_phy_preflop_8 [   5] = tx_downstream_data  [ 308] ;
  assign tx_phy_preflop_8 [   6] = tx_downstream_data  [ 309] ;
  assign tx_phy_preflop_8 [   7] = tx_downstream_data  [ 310] ;
  assign tx_phy_preflop_8 [   8] = tx_downstream_data  [ 311] ;
  assign tx_phy_preflop_8 [   9] = tx_downstream_data  [ 312] ;
  assign tx_phy_preflop_8 [  10] = tx_downstream_data  [ 313] ;
  assign tx_phy_preflop_8 [  11] = tx_downstream_data  [ 314] ;
  assign tx_phy_preflop_8 [  12] = tx_downstream_data  [ 315] ;
  assign tx_phy_preflop_8 [  13] = tx_downstream_data  [ 316] ;
  assign tx_phy_preflop_8 [  14] = tx_downstream_data  [ 317] ;
  assign tx_phy_preflop_8 [  15] = tx_downstream_data  [ 318] ;
  assign tx_phy_preflop_8 [  16] = tx_downstream_data  [ 319] ;
  assign tx_phy_preflop_8 [  17] = tx_downstream_data  [ 320] ;
  assign tx_phy_preflop_8 [  18] = tx_downstream_data  [ 321] ;
  assign tx_phy_preflop_8 [  19] = tx_downstream_data  [ 322] ;
  assign tx_phy_preflop_8 [  20] = tx_downstream_data  [ 323] ;
  assign tx_phy_preflop_8 [  21] = tx_downstream_data  [ 324] ;
  assign tx_phy_preflop_8 [  22] = tx_downstream_data  [ 325] ;
  assign tx_phy_preflop_8 [  23] = tx_downstream_data  [ 326] ;
  assign tx_phy_preflop_8 [  24] = tx_downstream_data  [ 327] ;
  assign tx_phy_preflop_8 [  25] = tx_downstream_data  [ 328] ;
  assign tx_phy_preflop_8 [  26] = tx_downstream_data  [ 329] ;
  assign tx_phy_preflop_8 [  27] = tx_downstream_data  [ 330] ;
  assign tx_phy_preflop_8 [  28] = tx_downstream_data  [ 331] ;
  assign tx_phy_preflop_8 [  29] = tx_downstream_data  [ 332] ;
  assign tx_phy_preflop_8 [  30] = tx_downstream_data  [ 333] ;
  assign tx_phy_preflop_8 [  31] = tx_downstream_data  [ 334] ;
  assign tx_phy_preflop_8 [  32] = tx_downstream_data  [ 335] ;
  assign tx_phy_preflop_8 [  33] = tx_downstream_data  [ 336] ;
  assign tx_phy_preflop_8 [  34] = tx_downstream_data  [ 337] ;
  assign tx_phy_preflop_8 [  35] = tx_downstream_data  [ 338] ;
  assign tx_phy_preflop_8 [  36] = tx_downstream_data  [ 339] ;
  assign tx_phy_preflop_8 [  37] = tx_downstream_data  [ 340] ;
  assign tx_phy_preflop_8 [  38] = tx_downstream_data  [ 341] ;
  assign tx_phy_preflop_8 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_9 [   0] = tx_downstream_data  [ 342] ;
  assign tx_phy_preflop_9 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_9 [   2] = tx_downstream_data  [ 343] ;
  assign tx_phy_preflop_9 [   3] = tx_downstream_data  [ 344] ;
  assign tx_phy_preflop_9 [   4] = tx_downstream_data  [ 345] ;
  assign tx_phy_preflop_9 [   5] = tx_downstream_data  [ 346] ;
  assign tx_phy_preflop_9 [   6] = tx_downstream_data  [ 347] ;
  assign tx_phy_preflop_9 [   7] = tx_downstream_data  [ 348] ;
  assign tx_phy_preflop_9 [   8] = tx_downstream_data  [ 349] ;
  assign tx_phy_preflop_9 [   9] = tx_downstream_data  [ 350] ;
  assign tx_phy_preflop_9 [  10] = tx_downstream_data  [ 351] ;
  assign tx_phy_preflop_9 [  11] = tx_downstream_data  [ 352] ;
  assign tx_phy_preflop_9 [  12] = tx_downstream_data  [ 353] ;
  assign tx_phy_preflop_9 [  13] = tx_downstream_data  [ 354] ;
  assign tx_phy_preflop_9 [  14] = tx_downstream_data  [ 355] ;
  assign tx_phy_preflop_9 [  15] = tx_downstream_data  [ 356] ;
  assign tx_phy_preflop_9 [  16] = tx_downstream_data  [ 357] ;
  assign tx_phy_preflop_9 [  17] = tx_downstream_data  [ 358] ;
  assign tx_phy_preflop_9 [  18] = tx_downstream_data  [ 359] ;
  assign tx_phy_preflop_9 [  19] = tx_downstream_data  [ 360] ;
  assign tx_phy_preflop_9 [  20] = tx_downstream_data  [ 361] ;
  assign tx_phy_preflop_9 [  21] = tx_downstream_data  [ 362] ;
  assign tx_phy_preflop_9 [  22] = tx_downstream_data  [ 363] ;
  assign tx_phy_preflop_9 [  23] = tx_downstream_data  [ 364] ;
  assign tx_phy_preflop_9 [  24] = tx_downstream_data  [ 365] ;
  assign tx_phy_preflop_9 [  25] = tx_downstream_data  [ 366] ;
  assign tx_phy_preflop_9 [  26] = tx_downstream_data  [ 367] ;
  assign tx_phy_preflop_9 [  27] = tx_downstream_data  [ 368] ;
  assign tx_phy_preflop_9 [  28] = tx_downstream_data  [ 369] ;
  assign tx_phy_preflop_9 [  29] = tx_downstream_data  [ 370] ;
  assign tx_phy_preflop_9 [  30] = tx_downstream_data  [ 371] ;
  assign tx_phy_preflop_9 [  31] = tx_downstream_data  [ 372] ;
  assign tx_phy_preflop_9 [  32] = tx_downstream_data  [ 373] ;
  assign tx_phy_preflop_9 [  33] = tx_downstream_data  [ 374] ;
  assign tx_phy_preflop_9 [  34] = tx_downstream_data  [ 375] ;
  assign tx_phy_preflop_9 [  35] = tx_downstream_data  [ 376] ;
  assign tx_phy_preflop_9 [  36] = tx_downstream_data  [ 377] ;
  assign tx_phy_preflop_9 [  37] = tx_downstream_data  [ 378] ;
  assign tx_phy_preflop_9 [  38] = tx_downstream_data  [ 379] ;
  assign tx_phy_preflop_9 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_10 [   0] = tx_downstream_data  [ 380] ;
  assign tx_phy_preflop_10 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_10 [   2] = tx_downstream_data  [ 381] ;
  assign tx_phy_preflop_10 [   3] = tx_downstream_data  [ 382] ;
  assign tx_phy_preflop_10 [   4] = tx_downstream_data  [ 383] ;
  assign tx_phy_preflop_10 [   5] = tx_downstream_data  [ 384] ;
  assign tx_phy_preflop_10 [   6] = tx_downstream_data  [ 385] ;
  assign tx_phy_preflop_10 [   7] = tx_downstream_data  [ 386] ;
  assign tx_phy_preflop_10 [   8] = tx_downstream_data  [ 387] ;
  assign tx_phy_preflop_10 [   9] = tx_downstream_data  [ 388] ;
  assign tx_phy_preflop_10 [  10] = tx_downstream_data  [ 389] ;
  assign tx_phy_preflop_10 [  11] = tx_downstream_data  [ 390] ;
  assign tx_phy_preflop_10 [  12] = tx_downstream_data  [ 391] ;
  assign tx_phy_preflop_10 [  13] = tx_downstream_data  [ 392] ;
  assign tx_phy_preflop_10 [  14] = tx_downstream_data  [ 393] ;
  assign tx_phy_preflop_10 [  15] = tx_downstream_data  [ 394] ;
  assign tx_phy_preflop_10 [  16] = tx_downstream_data  [ 395] ;
  assign tx_phy_preflop_10 [  17] = tx_downstream_data  [ 396] ;
  assign tx_phy_preflop_10 [  18] = tx_downstream_data  [ 397] ;
  assign tx_phy_preflop_10 [  19] = tx_downstream_data  [ 398] ;
  assign tx_phy_preflop_10 [  20] = tx_downstream_data  [ 399] ;
  assign tx_phy_preflop_10 [  21] = tx_downstream_data  [ 400] ;
  assign tx_phy_preflop_10 [  22] = tx_downstream_data  [ 401] ;
  assign tx_phy_preflop_10 [  23] = tx_downstream_data  [ 402] ;
  assign tx_phy_preflop_10 [  24] = tx_downstream_data  [ 403] ;
  assign tx_phy_preflop_10 [  25] = tx_downstream_data  [ 404] ;
  assign tx_phy_preflop_10 [  26] = tx_downstream_data  [ 405] ;
  assign tx_phy_preflop_10 [  27] = tx_downstream_data  [ 406] ;
  assign tx_phy_preflop_10 [  28] = tx_downstream_data  [ 407] ;
  assign tx_phy_preflop_10 [  29] = tx_downstream_data  [ 408] ;
  assign tx_phy_preflop_10 [  30] = tx_downstream_data  [ 409] ;
  assign tx_phy_preflop_10 [  31] = tx_downstream_data  [ 410] ;
  assign tx_phy_preflop_10 [  32] = tx_downstream_data  [ 411] ;
  assign tx_phy_preflop_10 [  33] = tx_downstream_data  [ 412] ;
  assign tx_phy_preflop_10 [  34] = tx_downstream_data  [ 413] ;
  assign tx_phy_preflop_10 [  35] = tx_downstream_data  [ 414] ;
  assign tx_phy_preflop_10 [  36] = tx_downstream_data  [ 415] ;
  assign tx_phy_preflop_10 [  37] = tx_downstream_data  [ 416] ;
  assign tx_phy_preflop_10 [  38] = tx_downstream_data  [ 417] ;
  assign tx_phy_preflop_10 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_11 [   0] = tx_downstream_data  [ 418] ;
  assign tx_phy_preflop_11 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_11 [   2] = tx_downstream_data  [ 419] ;
  assign tx_phy_preflop_11 [   3] = tx_downstream_data  [ 420] ;
  assign tx_phy_preflop_11 [   4] = tx_downstream_data  [ 421] ;
  assign tx_phy_preflop_11 [   5] = tx_downstream_data  [ 422] ;
  assign tx_phy_preflop_11 [   6] = tx_downstream_data  [ 423] ;
  assign tx_phy_preflop_11 [   7] = tx_downstream_data  [ 424] ;
  assign tx_phy_preflop_11 [   8] = tx_downstream_data  [ 425] ;
  assign tx_phy_preflop_11 [   9] = tx_downstream_data  [ 426] ;
  assign tx_phy_preflop_11 [  10] = tx_downstream_data  [ 427] ;
  assign tx_phy_preflop_11 [  11] = tx_downstream_data  [ 428] ;
  assign tx_phy_preflop_11 [  12] = tx_downstream_data  [ 429] ;
  assign tx_phy_preflop_11 [  13] = tx_downstream_data  [ 430] ;
  assign tx_phy_preflop_11 [  14] = tx_downstream_data  [ 431] ;
  assign tx_phy_preflop_11 [  15] = tx_downstream_data  [ 432] ;
  assign tx_phy_preflop_11 [  16] = tx_downstream_data  [ 433] ;
  assign tx_phy_preflop_11 [  17] = tx_downstream_data  [ 434] ;
  assign tx_phy_preflop_11 [  18] = tx_downstream_data  [ 435] ;
  assign tx_phy_preflop_11 [  19] = tx_downstream_data  [ 436] ;
  assign tx_phy_preflop_11 [  20] = tx_downstream_data  [ 437] ;
  assign tx_phy_preflop_11 [  21] = tx_downstream_data  [ 438] ;
  assign tx_phy_preflop_11 [  22] = tx_downstream_data  [ 439] ;
  assign tx_phy_preflop_11 [  23] = tx_downstream_data  [ 440] ;
  assign tx_phy_preflop_11 [  24] = tx_downstream_data  [ 441] ;
  assign tx_phy_preflop_11 [  25] = tx_downstream_data  [ 442] ;
  assign tx_phy_preflop_11 [  26] = tx_downstream_data  [ 443] ;
  assign tx_phy_preflop_11 [  27] = tx_downstream_data  [ 444] ;
  assign tx_phy_preflop_11 [  28] = tx_downstream_data  [ 445] ;
  assign tx_phy_preflop_11 [  29] = tx_downstream_data  [ 446] ;
  assign tx_phy_preflop_11 [  30] = tx_downstream_data  [ 447] ;
  assign tx_phy_preflop_11 [  31] = tx_downstream_data  [ 448] ;
  assign tx_phy_preflop_11 [  32] = tx_downstream_data  [ 449] ;
  assign tx_phy_preflop_11 [  33] = tx_downstream_data  [ 450] ;
  assign tx_phy_preflop_11 [  34] = tx_downstream_data  [ 451] ;
  assign tx_phy_preflop_11 [  35] = tx_downstream_data  [ 452] ;
  assign tx_phy_preflop_11 [  36] = tx_downstream_data  [ 453] ;
  assign tx_phy_preflop_11 [  37] = tx_downstream_data  [ 454] ;
  assign tx_phy_preflop_11 [  38] = tx_downstream_data  [ 455] ;
  assign tx_phy_preflop_11 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_12 [   0] = tx_downstream_data  [ 456] ;
  assign tx_phy_preflop_12 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_12 [   2] = tx_downstream_data  [ 457] ;
  assign tx_phy_preflop_12 [   3] = tx_downstream_data  [ 458] ;
  assign tx_phy_preflop_12 [   4] = tx_downstream_data  [ 459] ;
  assign tx_phy_preflop_12 [   5] = tx_downstream_data  [ 460] ;
  assign tx_phy_preflop_12 [   6] = tx_downstream_data  [ 461] ;
  assign tx_phy_preflop_12 [   7] = tx_downstream_data  [ 462] ;
  assign tx_phy_preflop_12 [   8] = tx_downstream_data  [ 463] ;
  assign tx_phy_preflop_12 [   9] = tx_downstream_data  [ 464] ;
  assign tx_phy_preflop_12 [  10] = tx_downstream_data  [ 465] ;
  assign tx_phy_preflop_12 [  11] = tx_downstream_data  [ 466] ;
  assign tx_phy_preflop_12 [  12] = tx_downstream_data  [ 467] ;
  assign tx_phy_preflop_12 [  13] = tx_downstream_data  [ 468] ;
  assign tx_phy_preflop_12 [  14] = tx_downstream_data  [ 469] ;
  assign tx_phy_preflop_12 [  15] = tx_downstream_data  [ 470] ;
  assign tx_phy_preflop_12 [  16] = tx_downstream_data  [ 471] ;
  assign tx_phy_preflop_12 [  17] = tx_downstream_data  [ 472] ;
  assign tx_phy_preflop_12 [  18] = tx_downstream_data  [ 473] ;
  assign tx_phy_preflop_12 [  19] = tx_downstream_data  [ 474] ;
  assign tx_phy_preflop_12 [  20] = tx_downstream_data  [ 475] ;
  assign tx_phy_preflop_12 [  21] = tx_downstream_data  [ 476] ;
  assign tx_phy_preflop_12 [  22] = tx_downstream_data  [ 477] ;
  assign tx_phy_preflop_12 [  23] = tx_downstream_data  [ 478] ;
  assign tx_phy_preflop_12 [  24] = tx_downstream_data  [ 479] ;
  assign tx_phy_preflop_12 [  25] = tx_downstream_data  [ 480] ;
  assign tx_phy_preflop_12 [  26] = tx_downstream_data  [ 481] ;
  assign tx_phy_preflop_12 [  27] = tx_downstream_data  [ 482] ;
  assign tx_phy_preflop_12 [  28] = tx_downstream_data  [ 483] ;
  assign tx_phy_preflop_12 [  29] = tx_downstream_data  [ 484] ;
  assign tx_phy_preflop_12 [  30] = tx_downstream_data  [ 485] ;
  assign tx_phy_preflop_12 [  31] = tx_downstream_data  [ 486] ;
  assign tx_phy_preflop_12 [  32] = tx_downstream_data  [ 487] ;
  assign tx_phy_preflop_12 [  33] = tx_downstream_data  [ 488] ;
  assign tx_phy_preflop_12 [  34] = tx_downstream_data  [ 489] ;
  assign tx_phy_preflop_12 [  35] = tx_downstream_data  [ 490] ;
  assign tx_phy_preflop_12 [  36] = tx_downstream_data  [ 491] ;
  assign tx_phy_preflop_12 [  37] = tx_downstream_data  [ 492] ;
  assign tx_phy_preflop_12 [  38] = tx_downstream_data  [ 493] ;
  assign tx_phy_preflop_12 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_13 [   0] = tx_downstream_data  [ 494] ;
  assign tx_phy_preflop_13 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_13 [   2] = tx_downstream_data  [ 495] ;
  assign tx_phy_preflop_13 [   3] = tx_downstream_data  [ 496] ;
  assign tx_phy_preflop_13 [   4] = tx_downstream_data  [ 497] ;
  assign tx_phy_preflop_13 [   5] = tx_downstream_data  [ 498] ;
  assign tx_phy_preflop_13 [   6] = tx_downstream_data  [ 499] ;
  assign tx_phy_preflop_13 [   7] = tx_downstream_data  [ 500] ;
  assign tx_phy_preflop_13 [   8] = tx_downstream_data  [ 501] ;
  assign tx_phy_preflop_13 [   9] = tx_downstream_data  [ 502] ;
  assign tx_phy_preflop_13 [  10] = tx_downstream_data  [ 503] ;
  assign tx_phy_preflop_13 [  11] = tx_downstream_data  [ 504] ;
  assign tx_phy_preflop_13 [  12] = tx_downstream_data  [ 505] ;
  assign tx_phy_preflop_13 [  13] = tx_downstream_data  [ 506] ;
  assign tx_phy_preflop_13 [  14] = tx_downstream_data  [ 507] ;
  assign tx_phy_preflop_13 [  15] = tx_downstream_data  [ 508] ;
  assign tx_phy_preflop_13 [  16] = tx_downstream_data  [ 509] ;
  assign tx_phy_preflop_13 [  17] = tx_downstream_data  [ 510] ;
  assign tx_phy_preflop_13 [  18] = tx_downstream_data  [ 511] ;
  assign tx_phy_preflop_13 [  19] = tx_downstream_data  [ 512] ;
  assign tx_phy_preflop_13 [  20] = tx_downstream_data  [ 513] ;
  assign tx_phy_preflop_13 [  21] = tx_downstream_data  [ 514] ;
  assign tx_phy_preflop_13 [  22] = tx_downstream_data  [ 515] ;
  assign tx_phy_preflop_13 [  23] = tx_downstream_data  [ 516] ;
  assign tx_phy_preflop_13 [  24] = tx_downstream_data  [ 517] ;
  assign tx_phy_preflop_13 [  25] = tx_downstream_data  [ 518] ;
  assign tx_phy_preflop_13 [  26] = tx_downstream_data  [ 519] ;
  assign tx_phy_preflop_13 [  27] = tx_downstream_data  [ 520] ;
  assign tx_phy_preflop_13 [  28] = tx_downstream_data  [ 521] ;
  assign tx_phy_preflop_13 [  29] = tx_downstream_data  [ 522] ;
  assign tx_phy_preflop_13 [  30] = tx_downstream_data  [ 523] ;
  assign tx_phy_preflop_13 [  31] = tx_downstream_data  [ 524] ;
  assign tx_phy_preflop_13 [  32] = tx_downstream_data  [ 525] ;
  assign tx_phy_preflop_13 [  33] = tx_downstream_data  [ 526] ;
  assign tx_phy_preflop_13 [  34] = tx_downstream_data  [ 527] ;
  assign tx_phy_preflop_13 [  35] = tx_downstream_data  [ 528] ;
  assign tx_phy_preflop_13 [  36] = tx_downstream_data  [ 529] ;
  assign tx_phy_preflop_13 [  37] = tx_downstream_data  [ 530] ;
  assign tx_phy_preflop_13 [  38] = tx_downstream_data  [ 531] ;
  assign tx_phy_preflop_13 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_14 [   0] = tx_downstream_data  [ 532] ;
  assign tx_phy_preflop_14 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_14 [   2] = tx_downstream_data  [ 533] ;
  assign tx_phy_preflop_14 [   3] = tx_downstream_data  [ 534] ;
  assign tx_phy_preflop_14 [   4] = tx_downstream_data  [ 535] ;
  assign tx_phy_preflop_14 [   5] = tx_downstream_data  [ 536] ;
  assign tx_phy_preflop_14 [   6] = 1'b0                       ;
  assign tx_phy_preflop_14 [   7] = 1'b0                       ;
  assign tx_phy_preflop_14 [   8] = 1'b0                       ;
  assign tx_phy_preflop_14 [   9] = 1'b0                       ;
  assign tx_phy_preflop_14 [  10] = 1'b0                       ;
  assign tx_phy_preflop_14 [  11] = 1'b0                       ;
  assign tx_phy_preflop_14 [  12] = 1'b0                       ;
  assign tx_phy_preflop_14 [  13] = 1'b0                       ;
  assign tx_phy_preflop_14 [  14] = 1'b0                       ;
  assign tx_phy_preflop_14 [  15] = 1'b0                       ;
  assign tx_phy_preflop_14 [  16] = 1'b0                       ;
  assign tx_phy_preflop_14 [  17] = 1'b0                       ;
  assign tx_phy_preflop_14 [  18] = 1'b0                       ;
  assign tx_phy_preflop_14 [  19] = 1'b0                       ;
  assign tx_phy_preflop_14 [  20] = 1'b0                       ;
  assign tx_phy_preflop_14 [  21] = 1'b0                       ;
  assign tx_phy_preflop_14 [  22] = 1'b0                       ;
  assign tx_phy_preflop_14 [  23] = 1'b0                       ;
  assign tx_phy_preflop_14 [  24] = 1'b0                       ;
  assign tx_phy_preflop_14 [  25] = 1'b0                       ;
  assign tx_phy_preflop_14 [  26] = 1'b0                       ;
  assign tx_phy_preflop_14 [  27] = 1'b0                       ;
  assign tx_phy_preflop_14 [  28] = 1'b0                       ;
  assign tx_phy_preflop_14 [  29] = 1'b0                       ;
  assign tx_phy_preflop_14 [  30] = 1'b0                       ;
  assign tx_phy_preflop_14 [  31] = 1'b0                       ;
  assign tx_phy_preflop_14 [  32] = 1'b0                       ;
  assign tx_phy_preflop_14 [  33] = 1'b0                       ;
  assign tx_phy_preflop_14 [  34] = 1'b0                       ;
  assign tx_phy_preflop_14 [  35] = 1'b0                       ;
  assign tx_phy_preflop_14 [  36] = 1'b0                       ;
  assign tx_phy_preflop_14 [  37] = 1'b0                       ;
  assign tx_phy_preflop_14 [  38] = 1'b0                       ;
  assign tx_phy_preflop_14 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_15 [   0] = 1'b0                       ;
  assign tx_phy_preflop_15 [   1] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_15 [   2] = 1'b0                       ;
  assign tx_phy_preflop_15 [   3] = 1'b0                       ;
  assign tx_phy_preflop_15 [   4] = 1'b0                       ;
  assign tx_phy_preflop_15 [   5] = 1'b0                       ;
  assign tx_phy_preflop_15 [   6] = 1'b0                       ;
  assign tx_phy_preflop_15 [   7] = 1'b0                       ;
  assign tx_phy_preflop_15 [   8] = 1'b0                       ;
  assign tx_phy_preflop_15 [   9] = 1'b0                       ;
  assign tx_phy_preflop_15 [  10] = 1'b0                       ;
  assign tx_phy_preflop_15 [  11] = 1'b0                       ;
  assign tx_phy_preflop_15 [  12] = 1'b0                       ;
  assign tx_phy_preflop_15 [  13] = 1'b0                       ;
  assign tx_phy_preflop_15 [  14] = 1'b0                       ;
  assign tx_phy_preflop_15 [  15] = 1'b0                       ;
  assign tx_phy_preflop_15 [  16] = 1'b0                       ;
  assign tx_phy_preflop_15 [  17] = 1'b0                       ;
  assign tx_phy_preflop_15 [  18] = 1'b0                       ;
  assign tx_phy_preflop_15 [  19] = 1'b0                       ;
  assign tx_phy_preflop_15 [  20] = 1'b0                       ;
  assign tx_phy_preflop_15 [  21] = 1'b0                       ;
  assign tx_phy_preflop_15 [  22] = 1'b0                       ;
  assign tx_phy_preflop_15 [  23] = 1'b0                       ;
  assign tx_phy_preflop_15 [  24] = 1'b0                       ;
  assign tx_phy_preflop_15 [  25] = 1'b0                       ;
  assign tx_phy_preflop_15 [  26] = 1'b0                       ;
  assign tx_phy_preflop_15 [  27] = 1'b0                       ;
  assign tx_phy_preflop_15 [  28] = 1'b0                       ;
  assign tx_phy_preflop_15 [  29] = 1'b0                       ;
  assign tx_phy_preflop_15 [  30] = 1'b0                       ;
  assign tx_phy_preflop_15 [  31] = 1'b0                       ;
  assign tx_phy_preflop_15 [  32] = 1'b0                       ;
  assign tx_phy_preflop_15 [  33] = 1'b0                       ;
  assign tx_phy_preflop_15 [  34] = 1'b0                       ;
  assign tx_phy_preflop_15 [  35] = 1'b0                       ;
  assign tx_phy_preflop_15 [  36] = 1'b0                       ;
  assign tx_phy_preflop_15 [  37] = 1'b0                       ;
  assign tx_phy_preflop_15 [  38] = 1'b0                       ;
  assign tx_phy_preflop_15 [  39] = tx_mrk_userbit[0]          ; // MARKER
// TX Section
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// RX Section

//   RX_CH_WIDTH           = 40; // Gen1Only running at Full Rate
//   RX_DATA_WIDTH         = 38; // Usable Data per Channel
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

  logic [  39:   0]                              rx_phy_postflop_0             ;
  logic [  39:   0]                              rx_phy_postflop_1             ;
  logic [  39:   0]                              rx_phy_postflop_2             ;
  logic [  39:   0]                              rx_phy_postflop_3             ;
  logic [  39:   0]                              rx_phy_postflop_4             ;
  logic [  39:   0]                              rx_phy_postflop_5             ;
  logic [  39:   0]                              rx_phy_postflop_6             ;
  logic [  39:   0]                              rx_phy_postflop_7             ;
  logic [  39:   0]                              rx_phy_postflop_8             ;
  logic [  39:   0]                              rx_phy_postflop_9             ;
  logic [  39:   0]                              rx_phy_postflop_10            ;
  logic [  39:   0]                              rx_phy_postflop_11            ;
  logic [  39:   0]                              rx_phy_postflop_12            ;
  logic [  39:   0]                              rx_phy_postflop_13            ;
  logic [  39:   0]                              rx_phy_postflop_14            ;
  logic [  39:   0]                              rx_phy_postflop_15            ;
  logic [  39:   0]                              rx_phy_flop_0_reg             ;
  logic [  39:   0]                              rx_phy_flop_1_reg             ;
  logic [  39:   0]                              rx_phy_flop_2_reg             ;
  logic [  39:   0]                              rx_phy_flop_3_reg             ;
  logic [  39:   0]                              rx_phy_flop_4_reg             ;
  logic [  39:   0]                              rx_phy_flop_5_reg             ;
  logic [  39:   0]                              rx_phy_flop_6_reg             ;
  logic [  39:   0]                              rx_phy_flop_7_reg             ;
  logic [  39:   0]                              rx_phy_flop_8_reg             ;
  logic [  39:   0]                              rx_phy_flop_9_reg             ;
  logic [  39:   0]                              rx_phy_flop_10_reg            ;
  logic [  39:   0]                              rx_phy_flop_11_reg            ;
  logic [  39:   0]                              rx_phy_flop_12_reg            ;
  logic [  39:   0]                              rx_phy_flop_13_reg            ;
  logic [  39:   0]                              rx_phy_flop_14_reg            ;
  logic [  39:   0]                              rx_phy_flop_15_reg            ;

  always_ff @(posedge clk_rd or negedge rst_rd_n)
  if (~rst_rd_n)
  begin
    rx_phy_flop_0_reg                       <= 40'b0                                   ;
    rx_phy_flop_1_reg                       <= 40'b0                                   ;
    rx_phy_flop_2_reg                       <= 40'b0                                   ;
    rx_phy_flop_3_reg                       <= 40'b0                                   ;
    rx_phy_flop_4_reg                       <= 40'b0                                   ;
    rx_phy_flop_5_reg                       <= 40'b0                                   ;
    rx_phy_flop_6_reg                       <= 40'b0                                   ;
    rx_phy_flop_7_reg                       <= 40'b0                                   ;
    rx_phy_flop_8_reg                       <= 40'b0                                   ;
    rx_phy_flop_9_reg                       <= 40'b0                                   ;
    rx_phy_flop_10_reg                      <= 40'b0                                   ;
    rx_phy_flop_11_reg                      <= 40'b0                                   ;
    rx_phy_flop_12_reg                      <= 40'b0                                   ;
    rx_phy_flop_13_reg                      <= 40'b0                                   ;
    rx_phy_flop_14_reg                      <= 40'b0                                   ;
    rx_phy_flop_15_reg                      <= 40'b0                                   ;
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
    rx_phy_flop_7_reg                       <= rx_phy7                                 ;
    rx_phy_flop_8_reg                       <= rx_phy8                                 ;
    rx_phy_flop_9_reg                       <= rx_phy9                                 ;
    rx_phy_flop_10_reg                      <= rx_phy10                                ;
    rx_phy_flop_11_reg                      <= rx_phy11                                ;
    rx_phy_flop_12_reg                      <= rx_phy12                                ;
    rx_phy_flop_13_reg                      <= rx_phy13                                ;
    rx_phy_flop_14_reg                      <= rx_phy14                                ;
    rx_phy_flop_15_reg                      <= rx_phy15                                ;
  end


  assign rx_phy_postflop_0                  = RX_REG_PHY ? rx_phy_flop_0_reg : rx_phy0               ;
  assign rx_phy_postflop_1                  = RX_REG_PHY ? rx_phy_flop_1_reg : rx_phy1               ;
  assign rx_phy_postflop_2                  = RX_REG_PHY ? rx_phy_flop_2_reg : rx_phy2               ;
  assign rx_phy_postflop_3                  = RX_REG_PHY ? rx_phy_flop_3_reg : rx_phy3               ;
  assign rx_phy_postflop_4                  = RX_REG_PHY ? rx_phy_flop_4_reg : rx_phy4               ;
  assign rx_phy_postflop_5                  = RX_REG_PHY ? rx_phy_flop_5_reg : rx_phy5               ;
  assign rx_phy_postflop_6                  = RX_REG_PHY ? rx_phy_flop_6_reg : rx_phy6               ;
  assign rx_phy_postflop_7                  = RX_REG_PHY ? rx_phy_flop_7_reg : rx_phy7               ;
  assign rx_phy_postflop_8                  = RX_REG_PHY ? rx_phy_flop_8_reg : rx_phy8               ;
  assign rx_phy_postflop_9                  = RX_REG_PHY ? rx_phy_flop_9_reg : rx_phy9               ;
  assign rx_phy_postflop_10                 = RX_REG_PHY ? rx_phy_flop_10_reg : rx_phy10               ;
  assign rx_phy_postflop_11                 = RX_REG_PHY ? rx_phy_flop_11_reg : rx_phy11               ;
  assign rx_phy_postflop_12                 = RX_REG_PHY ? rx_phy_flop_12_reg : rx_phy12               ;
  assign rx_phy_postflop_13                 = RX_REG_PHY ? rx_phy_flop_13_reg : rx_phy13               ;
  assign rx_phy_postflop_14                 = RX_REG_PHY ? rx_phy_flop_14_reg : rx_phy14               ;
  assign rx_phy_postflop_15                 = RX_REG_PHY ? rx_phy_flop_15_reg : rx_phy15               ;

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
//       MARKER                     = rx_phy_postflop_0 [  39]
  assign rx_upstream_data    [  38] = rx_phy_postflop_1 [   0];
//       STROBE                     = rx_phy_postflop_1 [   1]
  assign rx_upstream_data    [  39] = rx_phy_postflop_1 [   2];
  assign rx_upstream_data    [  40] = rx_phy_postflop_1 [   3];
  assign rx_upstream_data    [  41] = rx_phy_postflop_1 [   4];
  assign rx_upstream_data    [  42] = rx_phy_postflop_1 [   5];
  assign rx_upstream_data    [  43] = rx_phy_postflop_1 [   6];
  assign rx_upstream_data    [  44] = rx_phy_postflop_1 [   7];
  assign rx_upstream_data    [  45] = rx_phy_postflop_1 [   8];
  assign rx_upstream_data    [  46] = rx_phy_postflop_1 [   9];
  assign rx_upstream_data    [  47] = rx_phy_postflop_1 [  10];
  assign rx_upstream_data    [  48] = rx_phy_postflop_1 [  11];
  assign rx_upstream_data    [  49] = rx_phy_postflop_1 [  12];
  assign rx_upstream_data    [  50] = rx_phy_postflop_1 [  13];
  assign rx_upstream_data    [  51] = rx_phy_postflop_1 [  14];
  assign rx_upstream_data    [  52] = rx_phy_postflop_1 [  15];
  assign rx_upstream_data    [  53] = rx_phy_postflop_1 [  16];
  assign rx_upstream_data    [  54] = rx_phy_postflop_1 [  17];
  assign rx_upstream_data    [  55] = rx_phy_postflop_1 [  18];
  assign rx_upstream_data    [  56] = rx_phy_postflop_1 [  19];
  assign rx_upstream_data    [  57] = rx_phy_postflop_1 [  20];
  assign rx_upstream_data    [  58] = rx_phy_postflop_1 [  21];
  assign rx_upstream_data    [  59] = rx_phy_postflop_1 [  22];
  assign rx_upstream_data    [  60] = rx_phy_postflop_1 [  23];
  assign rx_upstream_data    [  61] = rx_phy_postflop_1 [  24];
  assign rx_upstream_data    [  62] = rx_phy_postflop_1 [  25];
  assign rx_upstream_data    [  63] = rx_phy_postflop_1 [  26];
  assign rx_upstream_data    [  64] = rx_phy_postflop_1 [  27];
  assign rx_upstream_data    [  65] = rx_phy_postflop_1 [  28];
  assign rx_upstream_data    [  66] = rx_phy_postflop_1 [  29];
  assign rx_upstream_data    [  67] = rx_phy_postflop_1 [  30];
  assign rx_upstream_data    [  68] = rx_phy_postflop_1 [  31];
  assign rx_upstream_data    [  69] = rx_phy_postflop_1 [  32];
  assign rx_upstream_data    [  70] = rx_phy_postflop_1 [  33];
  assign rx_upstream_data    [  71] = rx_phy_postflop_1 [  34];
  assign rx_upstream_data    [  72] = rx_phy_postflop_1 [  35];
  assign rx_upstream_data    [  73] = rx_phy_postflop_1 [  36];
  assign rx_upstream_data    [  74] = rx_phy_postflop_1 [  37];
  assign rx_upstream_data    [  75] = rx_phy_postflop_1 [  38];
//       MARKER                     = rx_phy_postflop_1 [  39]
  assign rx_upstream_data    [  76] = rx_phy_postflop_2 [   0];
//       STROBE                     = rx_phy_postflop_2 [   1]
  assign rx_upstream_data    [  77] = rx_phy_postflop_2 [   2];
  assign rx_upstream_data    [  78] = rx_phy_postflop_2 [   3];
  assign rx_upstream_data    [  79] = rx_phy_postflop_2 [   4];
  assign rx_upstream_data    [  80] = rx_phy_postflop_2 [   5];
  assign rx_upstream_data    [  81] = rx_phy_postflop_2 [   6];
  assign rx_upstream_data    [  82] = rx_phy_postflop_2 [   7];
  assign rx_upstream_data    [  83] = rx_phy_postflop_2 [   8];
  assign rx_upstream_data    [  84] = rx_phy_postflop_2 [   9];
  assign rx_upstream_data    [  85] = rx_phy_postflop_2 [  10];
  assign rx_upstream_data    [  86] = rx_phy_postflop_2 [  11];
  assign rx_upstream_data    [  87] = rx_phy_postflop_2 [  12];
  assign rx_upstream_data    [  88] = rx_phy_postflop_2 [  13];
  assign rx_upstream_data    [  89] = rx_phy_postflop_2 [  14];
  assign rx_upstream_data    [  90] = rx_phy_postflop_2 [  15];
  assign rx_upstream_data    [  91] = rx_phy_postflop_2 [  16];
  assign rx_upstream_data    [  92] = rx_phy_postflop_2 [  17];
  assign rx_upstream_data    [  93] = rx_phy_postflop_2 [  18];
  assign rx_upstream_data    [  94] = rx_phy_postflop_2 [  19];
  assign rx_upstream_data    [  95] = rx_phy_postflop_2 [  20];
  assign rx_upstream_data    [  96] = rx_phy_postflop_2 [  21];
  assign rx_upstream_data    [  97] = rx_phy_postflop_2 [  22];
  assign rx_upstream_data    [  98] = rx_phy_postflop_2 [  23];
  assign rx_upstream_data    [  99] = rx_phy_postflop_2 [  24];
  assign rx_upstream_data    [ 100] = rx_phy_postflop_2 [  25];
  assign rx_upstream_data    [ 101] = rx_phy_postflop_2 [  26];
  assign rx_upstream_data    [ 102] = rx_phy_postflop_2 [  27];
  assign rx_upstream_data    [ 103] = rx_phy_postflop_2 [  28];
  assign rx_upstream_data    [ 104] = rx_phy_postflop_2 [  29];
  assign rx_upstream_data    [ 105] = rx_phy_postflop_2 [  30];
  assign rx_upstream_data    [ 106] = rx_phy_postflop_2 [  31];
  assign rx_upstream_data    [ 107] = rx_phy_postflop_2 [  32];
  assign rx_upstream_data    [ 108] = rx_phy_postflop_2 [  33];
  assign rx_upstream_data    [ 109] = rx_phy_postflop_2 [  34];
  assign rx_upstream_data    [ 110] = rx_phy_postflop_2 [  35];
  assign rx_upstream_data    [ 111] = rx_phy_postflop_2 [  36];
  assign rx_upstream_data    [ 112] = rx_phy_postflop_2 [  37];
  assign rx_upstream_data    [ 113] = rx_phy_postflop_2 [  38];
//       MARKER                     = rx_phy_postflop_2 [  39]
  assign rx_upstream_data    [ 114] = rx_phy_postflop_3 [   0];
//       STROBE                     = rx_phy_postflop_3 [   1]
  assign rx_upstream_data    [ 115] = rx_phy_postflop_3 [   2];
  assign rx_upstream_data    [ 116] = rx_phy_postflop_3 [   3];
  assign rx_upstream_data    [ 117] = rx_phy_postflop_3 [   4];
  assign rx_upstream_data    [ 118] = rx_phy_postflop_3 [   5];
  assign rx_upstream_data    [ 119] = rx_phy_postflop_3 [   6];
  assign rx_upstream_data    [ 120] = rx_phy_postflop_3 [   7];
  assign rx_upstream_data    [ 121] = rx_phy_postflop_3 [   8];
  assign rx_upstream_data    [ 122] = rx_phy_postflop_3 [   9];
  assign rx_upstream_data    [ 123] = rx_phy_postflop_3 [  10];
  assign rx_upstream_data    [ 124] = rx_phy_postflop_3 [  11];
  assign rx_upstream_data    [ 125] = rx_phy_postflop_3 [  12];
  assign rx_upstream_data    [ 126] = rx_phy_postflop_3 [  13];
  assign rx_upstream_data    [ 127] = rx_phy_postflop_3 [  14];
  assign rx_upstream_data    [ 128] = rx_phy_postflop_3 [  15];
  assign rx_upstream_data    [ 129] = rx_phy_postflop_3 [  16];
  assign rx_upstream_data    [ 130] = rx_phy_postflop_3 [  17];
  assign rx_upstream_data    [ 131] = rx_phy_postflop_3 [  18];
  assign rx_upstream_data    [ 132] = rx_phy_postflop_3 [  19];
  assign rx_upstream_data    [ 133] = rx_phy_postflop_3 [  20];
  assign rx_upstream_data    [ 134] = rx_phy_postflop_3 [  21];
  assign rx_upstream_data    [ 135] = rx_phy_postflop_3 [  22];
  assign rx_upstream_data    [ 136] = rx_phy_postflop_3 [  23];
  assign rx_upstream_data    [ 137] = rx_phy_postflop_3 [  24];
  assign rx_upstream_data    [ 138] = rx_phy_postflop_3 [  25];
  assign rx_upstream_data    [ 139] = rx_phy_postflop_3 [  26];
  assign rx_upstream_data    [ 140] = rx_phy_postflop_3 [  27];
  assign rx_upstream_data    [ 141] = rx_phy_postflop_3 [  28];
  assign rx_upstream_data    [ 142] = rx_phy_postflop_3 [  29];
  assign rx_upstream_data    [ 143] = rx_phy_postflop_3 [  30];
  assign rx_upstream_data    [ 144] = rx_phy_postflop_3 [  31];
  assign rx_upstream_data    [ 145] = rx_phy_postflop_3 [  32];
  assign rx_upstream_data    [ 146] = rx_phy_postflop_3 [  33];
  assign rx_upstream_data    [ 147] = rx_phy_postflop_3 [  34];
  assign rx_upstream_data    [ 148] = rx_phy_postflop_3 [  35];
  assign rx_upstream_data    [ 149] = rx_phy_postflop_3 [  36];
  assign rx_upstream_data    [ 150] = rx_phy_postflop_3 [  37];
  assign rx_upstream_data    [ 151] = rx_phy_postflop_3 [  38];
//       MARKER                     = rx_phy_postflop_3 [  39]
  assign rx_upstream_data    [ 152] = rx_phy_postflop_4 [   0];
//       STROBE                     = rx_phy_postflop_4 [   1]
  assign rx_upstream_data    [ 153] = rx_phy_postflop_4 [   2];
  assign rx_upstream_data    [ 154] = rx_phy_postflop_4 [   3];
  assign rx_upstream_data    [ 155] = rx_phy_postflop_4 [   4];
  assign rx_upstream_data    [ 156] = rx_phy_postflop_4 [   5];
  assign rx_upstream_data    [ 157] = rx_phy_postflop_4 [   6];
  assign rx_upstream_data    [ 158] = rx_phy_postflop_4 [   7];
  assign rx_upstream_data    [ 159] = rx_phy_postflop_4 [   8];
  assign rx_upstream_data    [ 160] = rx_phy_postflop_4 [   9];
  assign rx_upstream_data    [ 161] = rx_phy_postflop_4 [  10];
  assign rx_upstream_data    [ 162] = rx_phy_postflop_4 [  11];
  assign rx_upstream_data    [ 163] = rx_phy_postflop_4 [  12];
  assign rx_upstream_data    [ 164] = rx_phy_postflop_4 [  13];
  assign rx_upstream_data    [ 165] = rx_phy_postflop_4 [  14];
  assign rx_upstream_data    [ 166] = rx_phy_postflop_4 [  15];
  assign rx_upstream_data    [ 167] = rx_phy_postflop_4 [  16];
  assign rx_upstream_data    [ 168] = rx_phy_postflop_4 [  17];
  assign rx_upstream_data    [ 169] = rx_phy_postflop_4 [  18];
  assign rx_upstream_data    [ 170] = rx_phy_postflop_4 [  19];
  assign rx_upstream_data    [ 171] = rx_phy_postflop_4 [  20];
  assign rx_upstream_data    [ 172] = rx_phy_postflop_4 [  21];
  assign rx_upstream_data    [ 173] = rx_phy_postflop_4 [  22];
  assign rx_upstream_data    [ 174] = rx_phy_postflop_4 [  23];
  assign rx_upstream_data    [ 175] = rx_phy_postflop_4 [  24];
  assign rx_upstream_data    [ 176] = rx_phy_postflop_4 [  25];
  assign rx_upstream_data    [ 177] = rx_phy_postflop_4 [  26];
  assign rx_upstream_data    [ 178] = rx_phy_postflop_4 [  27];
  assign rx_upstream_data    [ 179] = rx_phy_postflop_4 [  28];
  assign rx_upstream_data    [ 180] = rx_phy_postflop_4 [  29];
  assign rx_upstream_data    [ 181] = rx_phy_postflop_4 [  30];
  assign rx_upstream_data    [ 182] = rx_phy_postflop_4 [  31];
  assign rx_upstream_data    [ 183] = rx_phy_postflop_4 [  32];
  assign rx_upstream_data    [ 184] = rx_phy_postflop_4 [  33];
  assign rx_upstream_data    [ 185] = rx_phy_postflop_4 [  34];
  assign rx_upstream_data    [ 186] = rx_phy_postflop_4 [  35];
  assign rx_upstream_data    [ 187] = rx_phy_postflop_4 [  36];
  assign rx_upstream_data    [ 188] = rx_phy_postflop_4 [  37];
  assign rx_upstream_data    [ 189] = rx_phy_postflop_4 [  38];
//       MARKER                     = rx_phy_postflop_4 [  39]
  assign rx_upstream_data    [ 190] = rx_phy_postflop_5 [   0];
//       STROBE                     = rx_phy_postflop_5 [   1]
  assign rx_upstream_data    [ 191] = rx_phy_postflop_5 [   2];
  assign rx_upstream_data    [ 192] = rx_phy_postflop_5 [   3];
  assign rx_upstream_data    [ 193] = rx_phy_postflop_5 [   4];
  assign rx_upstream_data    [ 194] = rx_phy_postflop_5 [   5];
  assign rx_upstream_data    [ 195] = rx_phy_postflop_5 [   6];
  assign rx_upstream_data    [ 196] = rx_phy_postflop_5 [   7];
  assign rx_upstream_data    [ 197] = rx_phy_postflop_5 [   8];
  assign rx_upstream_data    [ 198] = rx_phy_postflop_5 [   9];
  assign rx_upstream_data    [ 199] = rx_phy_postflop_5 [  10];
  assign rx_upstream_data    [ 200] = rx_phy_postflop_5 [  11];
  assign rx_upstream_data    [ 201] = rx_phy_postflop_5 [  12];
  assign rx_upstream_data    [ 202] = rx_phy_postflop_5 [  13];
  assign rx_upstream_data    [ 203] = rx_phy_postflop_5 [  14];
  assign rx_upstream_data    [ 204] = rx_phy_postflop_5 [  15];
  assign rx_upstream_data    [ 205] = rx_phy_postflop_5 [  16];
  assign rx_upstream_data    [ 206] = rx_phy_postflop_5 [  17];
  assign rx_upstream_data    [ 207] = rx_phy_postflop_5 [  18];
  assign rx_upstream_data    [ 208] = rx_phy_postflop_5 [  19];
  assign rx_upstream_data    [ 209] = rx_phy_postflop_5 [  20];
  assign rx_upstream_data    [ 210] = rx_phy_postflop_5 [  21];
  assign rx_upstream_data    [ 211] = rx_phy_postflop_5 [  22];
  assign rx_upstream_data    [ 212] = rx_phy_postflop_5 [  23];
  assign rx_upstream_data    [ 213] = rx_phy_postflop_5 [  24];
  assign rx_upstream_data    [ 214] = rx_phy_postflop_5 [  25];
  assign rx_upstream_data    [ 215] = rx_phy_postflop_5 [  26];
  assign rx_upstream_data    [ 216] = rx_phy_postflop_5 [  27];
  assign rx_upstream_data    [ 217] = rx_phy_postflop_5 [  28];
  assign rx_upstream_data    [ 218] = rx_phy_postflop_5 [  29];
  assign rx_upstream_data    [ 219] = rx_phy_postflop_5 [  30];
  assign rx_upstream_data    [ 220] = rx_phy_postflop_5 [  31];
  assign rx_upstream_data    [ 221] = rx_phy_postflop_5 [  32];
  assign rx_upstream_data    [ 222] = rx_phy_postflop_5 [  33];
  assign rx_upstream_data    [ 223] = rx_phy_postflop_5 [  34];
  assign rx_upstream_data    [ 224] = rx_phy_postflop_5 [  35];
  assign rx_upstream_data    [ 225] = rx_phy_postflop_5 [  36];
  assign rx_upstream_data    [ 226] = rx_phy_postflop_5 [  37];
  assign rx_upstream_data    [ 227] = rx_phy_postflop_5 [  38];
//       MARKER                     = rx_phy_postflop_5 [  39]
  assign rx_upstream_data    [ 228] = rx_phy_postflop_6 [   0];
//       STROBE                     = rx_phy_postflop_6 [   1]
  assign rx_upstream_data    [ 229] = rx_phy_postflop_6 [   2];
  assign rx_upstream_data    [ 230] = rx_phy_postflop_6 [   3];
  assign rx_upstream_data    [ 231] = rx_phy_postflop_6 [   4];
  assign rx_upstream_data    [ 232] = rx_phy_postflop_6 [   5];
  assign rx_upstream_data    [ 233] = rx_phy_postflop_6 [   6];
  assign rx_upstream_data    [ 234] = rx_phy_postflop_6 [   7];
  assign rx_upstream_data    [ 235] = rx_phy_postflop_6 [   8];
  assign rx_upstream_data    [ 236] = rx_phy_postflop_6 [   9];
  assign rx_upstream_data    [ 237] = rx_phy_postflop_6 [  10];
  assign rx_upstream_data    [ 238] = rx_phy_postflop_6 [  11];
  assign rx_upstream_data    [ 239] = rx_phy_postflop_6 [  12];
  assign rx_upstream_data    [ 240] = rx_phy_postflop_6 [  13];
  assign rx_upstream_data    [ 241] = rx_phy_postflop_6 [  14];
  assign rx_upstream_data    [ 242] = rx_phy_postflop_6 [  15];
  assign rx_upstream_data    [ 243] = rx_phy_postflop_6 [  16];
  assign rx_upstream_data    [ 244] = rx_phy_postflop_6 [  17];
  assign rx_upstream_data    [ 245] = rx_phy_postflop_6 [  18];
  assign rx_upstream_data    [ 246] = rx_phy_postflop_6 [  19];
  assign rx_upstream_data    [ 247] = rx_phy_postflop_6 [  20];
  assign rx_upstream_data    [ 248] = rx_phy_postflop_6 [  21];
  assign rx_upstream_data    [ 249] = rx_phy_postflop_6 [  22];
  assign rx_upstream_data    [ 250] = rx_phy_postflop_6 [  23];
  assign rx_upstream_data    [ 251] = rx_phy_postflop_6 [  24];
  assign rx_upstream_data    [ 252] = rx_phy_postflop_6 [  25];
  assign rx_upstream_data    [ 253] = rx_phy_postflop_6 [  26];
  assign rx_upstream_data    [ 254] = rx_phy_postflop_6 [  27];
  assign rx_upstream_data    [ 255] = rx_phy_postflop_6 [  28];
  assign rx_upstream_data    [ 256] = rx_phy_postflop_6 [  29];
  assign rx_upstream_data    [ 257] = rx_phy_postflop_6 [  30];
  assign rx_upstream_data    [ 258] = rx_phy_postflop_6 [  31];
  assign rx_upstream_data    [ 259] = rx_phy_postflop_6 [  32];
  assign rx_upstream_data    [ 260] = rx_phy_postflop_6 [  33];
  assign rx_upstream_data    [ 261] = rx_phy_postflop_6 [  34];
  assign rx_upstream_data    [ 262] = rx_phy_postflop_6 [  35];
  assign rx_upstream_data    [ 263] = rx_phy_postflop_6 [  36];
  assign rx_upstream_data    [ 264] = rx_phy_postflop_6 [  37];
  assign rx_upstream_data    [ 265] = rx_phy_postflop_6 [  38];
//       MARKER                     = rx_phy_postflop_6 [  39]
  assign rx_upstream_data    [ 266] = rx_phy_postflop_7 [   0];
//       STROBE                     = rx_phy_postflop_7 [   1]
  assign rx_upstream_data    [ 267] = rx_phy_postflop_7 [   2];
  assign rx_upstream_data    [ 268] = rx_phy_postflop_7 [   3];
  assign rx_upstream_data    [ 269] = rx_phy_postflop_7 [   4];
  assign rx_upstream_data    [ 270] = rx_phy_postflop_7 [   5];
  assign rx_upstream_data    [ 271] = rx_phy_postflop_7 [   6];
  assign rx_upstream_data    [ 272] = rx_phy_postflop_7 [   7];
  assign rx_upstream_data    [ 273] = rx_phy_postflop_7 [   8];
  assign rx_upstream_data    [ 274] = rx_phy_postflop_7 [   9];
  assign rx_upstream_data    [ 275] = rx_phy_postflop_7 [  10];
  assign rx_upstream_data    [ 276] = rx_phy_postflop_7 [  11];
  assign rx_upstream_data    [ 277] = rx_phy_postflop_7 [  12];
  assign rx_upstream_data    [ 278] = rx_phy_postflop_7 [  13];
  assign rx_upstream_data    [ 279] = rx_phy_postflop_7 [  14];
  assign rx_upstream_data    [ 280] = rx_phy_postflop_7 [  15];
  assign rx_upstream_data    [ 281] = rx_phy_postflop_7 [  16];
  assign rx_upstream_data    [ 282] = rx_phy_postflop_7 [  17];
  assign rx_upstream_data    [ 283] = rx_phy_postflop_7 [  18];
  assign rx_upstream_data    [ 284] = rx_phy_postflop_7 [  19];
  assign rx_upstream_data    [ 285] = rx_phy_postflop_7 [  20];
  assign rx_upstream_data    [ 286] = rx_phy_postflop_7 [  21];
  assign rx_upstream_data    [ 287] = rx_phy_postflop_7 [  22];
  assign rx_upstream_data    [ 288] = rx_phy_postflop_7 [  23];
  assign rx_upstream_data    [ 289] = rx_phy_postflop_7 [  24];
  assign rx_upstream_data    [ 290] = rx_phy_postflop_7 [  25];
  assign rx_upstream_data    [ 291] = rx_phy_postflop_7 [  26];
  assign rx_upstream_data    [ 292] = rx_phy_postflop_7 [  27];
  assign rx_upstream_data    [ 293] = rx_phy_postflop_7 [  28];
  assign rx_upstream_data    [ 294] = rx_phy_postflop_7 [  29];
  assign rx_upstream_data    [ 295] = rx_phy_postflop_7 [  30];
  assign rx_upstream_data    [ 296] = rx_phy_postflop_7 [  31];
  assign rx_upstream_data    [ 297] = rx_phy_postflop_7 [  32];
  assign rx_upstream_data    [ 298] = rx_phy_postflop_7 [  33];
  assign rx_upstream_data    [ 299] = rx_phy_postflop_7 [  34];
  assign rx_upstream_data    [ 300] = rx_phy_postflop_7 [  35];
  assign rx_upstream_data    [ 301] = rx_phy_postflop_7 [  36];
  assign rx_upstream_data    [ 302] = rx_phy_postflop_7 [  37];
  assign rx_upstream_data    [ 303] = rx_phy_postflop_7 [  38];
//       MARKER                     = rx_phy_postflop_7 [  39]
  assign rx_upstream_data    [ 304] = rx_phy_postflop_8 [   0];
//       STROBE                     = rx_phy_postflop_8 [   1]
  assign rx_upstream_data    [ 305] = rx_phy_postflop_8 [   2];
  assign rx_upstream_data    [ 306] = rx_phy_postflop_8 [   3];
  assign rx_upstream_data    [ 307] = rx_phy_postflop_8 [   4];
  assign rx_upstream_data    [ 308] = rx_phy_postflop_8 [   5];
  assign rx_upstream_data    [ 309] = rx_phy_postflop_8 [   6];
  assign rx_upstream_data    [ 310] = rx_phy_postflop_8 [   7];
  assign rx_upstream_data    [ 311] = rx_phy_postflop_8 [   8];
  assign rx_upstream_data    [ 312] = rx_phy_postflop_8 [   9];
  assign rx_upstream_data    [ 313] = rx_phy_postflop_8 [  10];
  assign rx_upstream_data    [ 314] = rx_phy_postflop_8 [  11];
  assign rx_upstream_data    [ 315] = rx_phy_postflop_8 [  12];
  assign rx_upstream_data    [ 316] = rx_phy_postflop_8 [  13];
  assign rx_upstream_data    [ 317] = rx_phy_postflop_8 [  14];
  assign rx_upstream_data    [ 318] = rx_phy_postflop_8 [  15];
  assign rx_upstream_data    [ 319] = rx_phy_postflop_8 [  16];
  assign rx_upstream_data    [ 320] = rx_phy_postflop_8 [  17];
  assign rx_upstream_data    [ 321] = rx_phy_postflop_8 [  18];
  assign rx_upstream_data    [ 322] = rx_phy_postflop_8 [  19];
  assign rx_upstream_data    [ 323] = rx_phy_postflop_8 [  20];
  assign rx_upstream_data    [ 324] = rx_phy_postflop_8 [  21];
  assign rx_upstream_data    [ 325] = rx_phy_postflop_8 [  22];
  assign rx_upstream_data    [ 326] = rx_phy_postflop_8 [  23];
  assign rx_upstream_data    [ 327] = rx_phy_postflop_8 [  24];
  assign rx_upstream_data    [ 328] = rx_phy_postflop_8 [  25];
  assign rx_upstream_data    [ 329] = rx_phy_postflop_8 [  26];
  assign rx_upstream_data    [ 330] = rx_phy_postflop_8 [  27];
  assign rx_upstream_data    [ 331] = rx_phy_postflop_8 [  28];
  assign rx_upstream_data    [ 332] = rx_phy_postflop_8 [  29];
  assign rx_upstream_data    [ 333] = rx_phy_postflop_8 [  30];
  assign rx_upstream_data    [ 334] = rx_phy_postflop_8 [  31];
  assign rx_upstream_data    [ 335] = rx_phy_postflop_8 [  32];
  assign rx_upstream_data    [ 336] = rx_phy_postflop_8 [  33];
  assign rx_upstream_data    [ 337] = rx_phy_postflop_8 [  34];
  assign rx_upstream_data    [ 338] = rx_phy_postflop_8 [  35];
  assign rx_upstream_data    [ 339] = rx_phy_postflop_8 [  36];
  assign rx_upstream_data    [ 340] = rx_phy_postflop_8 [  37];
  assign rx_upstream_data    [ 341] = rx_phy_postflop_8 [  38];
//       MARKER                     = rx_phy_postflop_8 [  39]
  assign rx_upstream_data    [ 342] = rx_phy_postflop_9 [   0];
//       STROBE                     = rx_phy_postflop_9 [   1]
  assign rx_upstream_data    [ 343] = rx_phy_postflop_9 [   2];
  assign rx_upstream_data    [ 344] = rx_phy_postflop_9 [   3];
  assign rx_upstream_data    [ 345] = rx_phy_postflop_9 [   4];
  assign rx_upstream_data    [ 346] = rx_phy_postflop_9 [   5];
  assign rx_upstream_data    [ 347] = rx_phy_postflop_9 [   6];
  assign rx_upstream_data    [ 348] = rx_phy_postflop_9 [   7];
  assign rx_upstream_data    [ 349] = rx_phy_postflop_9 [   8];
  assign rx_upstream_data    [ 350] = rx_phy_postflop_9 [   9];
  assign rx_upstream_data    [ 351] = rx_phy_postflop_9 [  10];
  assign rx_upstream_data    [ 352] = rx_phy_postflop_9 [  11];
  assign rx_upstream_data    [ 353] = rx_phy_postflop_9 [  12];
  assign rx_upstream_data    [ 354] = rx_phy_postflop_9 [  13];
  assign rx_upstream_data    [ 355] = rx_phy_postflop_9 [  14];
  assign rx_upstream_data    [ 356] = rx_phy_postflop_9 [  15];
  assign rx_upstream_data    [ 357] = rx_phy_postflop_9 [  16];
  assign rx_upstream_data    [ 358] = rx_phy_postflop_9 [  17];
  assign rx_upstream_data    [ 359] = rx_phy_postflop_9 [  18];
  assign rx_upstream_data    [ 360] = rx_phy_postflop_9 [  19];
  assign rx_upstream_data    [ 361] = rx_phy_postflop_9 [  20];
  assign rx_upstream_data    [ 362] = rx_phy_postflop_9 [  21];
  assign rx_upstream_data    [ 363] = rx_phy_postflop_9 [  22];
  assign rx_upstream_data    [ 364] = rx_phy_postflop_9 [  23];
  assign rx_upstream_data    [ 365] = rx_phy_postflop_9 [  24];
  assign rx_upstream_data    [ 366] = rx_phy_postflop_9 [  25];
  assign rx_upstream_data    [ 367] = rx_phy_postflop_9 [  26];
  assign rx_upstream_data    [ 368] = rx_phy_postflop_9 [  27];
  assign rx_upstream_data    [ 369] = rx_phy_postflop_9 [  28];
  assign rx_upstream_data    [ 370] = rx_phy_postflop_9 [  29];
  assign rx_upstream_data    [ 371] = rx_phy_postflop_9 [  30];
  assign rx_upstream_data    [ 372] = rx_phy_postflop_9 [  31];
  assign rx_upstream_data    [ 373] = rx_phy_postflop_9 [  32];
  assign rx_upstream_data    [ 374] = rx_phy_postflop_9 [  33];
  assign rx_upstream_data    [ 375] = rx_phy_postflop_9 [  34];
  assign rx_upstream_data    [ 376] = rx_phy_postflop_9 [  35];
  assign rx_upstream_data    [ 377] = rx_phy_postflop_9 [  36];
  assign rx_upstream_data    [ 378] = rx_phy_postflop_9 [  37];
  assign rx_upstream_data    [ 379] = rx_phy_postflop_9 [  38];
//       MARKER                     = rx_phy_postflop_9 [  39]
  assign rx_upstream_data    [ 380] = rx_phy_postflop_10 [   0];
//       STROBE                     = rx_phy_postflop_10 [   1]
  assign rx_upstream_data    [ 381] = rx_phy_postflop_10 [   2];
  assign rx_upstream_data    [ 382] = rx_phy_postflop_10 [   3];
  assign rx_upstream_data    [ 383] = rx_phy_postflop_10 [   4];
  assign rx_upstream_data    [ 384] = rx_phy_postflop_10 [   5];
  assign rx_upstream_data    [ 385] = rx_phy_postflop_10 [   6];
  assign rx_upstream_data    [ 386] = rx_phy_postflop_10 [   7];
  assign rx_upstream_data    [ 387] = rx_phy_postflop_10 [   8];
  assign rx_upstream_data    [ 388] = rx_phy_postflop_10 [   9];
  assign rx_upstream_data    [ 389] = rx_phy_postflop_10 [  10];
  assign rx_upstream_data    [ 390] = rx_phy_postflop_10 [  11];
  assign rx_upstream_data    [ 391] = rx_phy_postflop_10 [  12];
  assign rx_upstream_data    [ 392] = rx_phy_postflop_10 [  13];
  assign rx_upstream_data    [ 393] = rx_phy_postflop_10 [  14];
  assign rx_upstream_data    [ 394] = rx_phy_postflop_10 [  15];
  assign rx_upstream_data    [ 395] = rx_phy_postflop_10 [  16];
  assign rx_upstream_data    [ 396] = rx_phy_postflop_10 [  17];
  assign rx_upstream_data    [ 397] = rx_phy_postflop_10 [  18];
  assign rx_upstream_data    [ 398] = rx_phy_postflop_10 [  19];
  assign rx_upstream_data    [ 399] = rx_phy_postflop_10 [  20];
  assign rx_upstream_data    [ 400] = rx_phy_postflop_10 [  21];
  assign rx_upstream_data    [ 401] = rx_phy_postflop_10 [  22];
  assign rx_upstream_data    [ 402] = rx_phy_postflop_10 [  23];
  assign rx_upstream_data    [ 403] = rx_phy_postflop_10 [  24];
  assign rx_upstream_data    [ 404] = rx_phy_postflop_10 [  25];
  assign rx_upstream_data    [ 405] = rx_phy_postflop_10 [  26];
  assign rx_upstream_data    [ 406] = rx_phy_postflop_10 [  27];
  assign rx_upstream_data    [ 407] = rx_phy_postflop_10 [  28];
  assign rx_upstream_data    [ 408] = rx_phy_postflop_10 [  29];
  assign rx_upstream_data    [ 409] = rx_phy_postflop_10 [  30];
  assign rx_upstream_data    [ 410] = rx_phy_postflop_10 [  31];
  assign rx_upstream_data    [ 411] = rx_phy_postflop_10 [  32];
  assign rx_upstream_data    [ 412] = rx_phy_postflop_10 [  33];
  assign rx_upstream_data    [ 413] = rx_phy_postflop_10 [  34];
  assign rx_upstream_data    [ 414] = rx_phy_postflop_10 [  35];
  assign rx_upstream_data    [ 415] = rx_phy_postflop_10 [  36];
  assign rx_upstream_data    [ 416] = rx_phy_postflop_10 [  37];
  assign rx_upstream_data    [ 417] = rx_phy_postflop_10 [  38];
//       MARKER                     = rx_phy_postflop_10 [  39]
  assign rx_upstream_data    [ 418] = rx_phy_postflop_11 [   0];
//       STROBE                     = rx_phy_postflop_11 [   1]
  assign rx_upstream_data    [ 419] = rx_phy_postflop_11 [   2];
  assign rx_upstream_data    [ 420] = rx_phy_postflop_11 [   3];
  assign rx_upstream_data    [ 421] = rx_phy_postflop_11 [   4];
  assign rx_upstream_data    [ 422] = rx_phy_postflop_11 [   5];
  assign rx_upstream_data    [ 423] = rx_phy_postflop_11 [   6];
  assign rx_upstream_data    [ 424] = rx_phy_postflop_11 [   7];
  assign rx_upstream_data    [ 425] = rx_phy_postflop_11 [   8];
  assign rx_upstream_data    [ 426] = rx_phy_postflop_11 [   9];
  assign rx_upstream_data    [ 427] = rx_phy_postflop_11 [  10];
  assign rx_upstream_data    [ 428] = rx_phy_postflop_11 [  11];
  assign rx_upstream_data    [ 429] = rx_phy_postflop_11 [  12];
  assign rx_upstream_data    [ 430] = rx_phy_postflop_11 [  13];
  assign rx_upstream_data    [ 431] = rx_phy_postflop_11 [  14];
  assign rx_upstream_data    [ 432] = rx_phy_postflop_11 [  15];
  assign rx_upstream_data    [ 433] = rx_phy_postflop_11 [  16];
  assign rx_upstream_data    [ 434] = rx_phy_postflop_11 [  17];
  assign rx_upstream_data    [ 435] = rx_phy_postflop_11 [  18];
  assign rx_upstream_data    [ 436] = rx_phy_postflop_11 [  19];
  assign rx_upstream_data    [ 437] = rx_phy_postflop_11 [  20];
  assign rx_upstream_data    [ 438] = rx_phy_postflop_11 [  21];
  assign rx_upstream_data    [ 439] = rx_phy_postflop_11 [  22];
  assign rx_upstream_data    [ 440] = rx_phy_postflop_11 [  23];
  assign rx_upstream_data    [ 441] = rx_phy_postflop_11 [  24];
  assign rx_upstream_data    [ 442] = rx_phy_postflop_11 [  25];
  assign rx_upstream_data    [ 443] = rx_phy_postflop_11 [  26];
  assign rx_upstream_data    [ 444] = rx_phy_postflop_11 [  27];
  assign rx_upstream_data    [ 445] = rx_phy_postflop_11 [  28];
  assign rx_upstream_data    [ 446] = rx_phy_postflop_11 [  29];
  assign rx_upstream_data    [ 447] = rx_phy_postflop_11 [  30];
  assign rx_upstream_data    [ 448] = rx_phy_postflop_11 [  31];
  assign rx_upstream_data    [ 449] = rx_phy_postflop_11 [  32];
  assign rx_upstream_data    [ 450] = rx_phy_postflop_11 [  33];
  assign rx_upstream_data    [ 451] = rx_phy_postflop_11 [  34];
  assign rx_upstream_data    [ 452] = rx_phy_postflop_11 [  35];
  assign rx_upstream_data    [ 453] = rx_phy_postflop_11 [  36];
  assign rx_upstream_data    [ 454] = rx_phy_postflop_11 [  37];
  assign rx_upstream_data    [ 455] = rx_phy_postflop_11 [  38];
//       MARKER                     = rx_phy_postflop_11 [  39]
  assign rx_upstream_data    [ 456] = rx_phy_postflop_12 [   0];
//       STROBE                     = rx_phy_postflop_12 [   1]
  assign rx_upstream_data    [ 457] = rx_phy_postflop_12 [   2];
  assign rx_upstream_data    [ 458] = rx_phy_postflop_12 [   3];
  assign rx_upstream_data    [ 459] = rx_phy_postflop_12 [   4];
  assign rx_upstream_data    [ 460] = rx_phy_postflop_12 [   5];
  assign rx_upstream_data    [ 461] = rx_phy_postflop_12 [   6];
  assign rx_upstream_data    [ 462] = rx_phy_postflop_12 [   7];
  assign rx_upstream_data    [ 463] = rx_phy_postflop_12 [   8];
  assign rx_upstream_data    [ 464] = rx_phy_postflop_12 [   9];
  assign rx_upstream_data    [ 465] = rx_phy_postflop_12 [  10];
  assign rx_upstream_data    [ 466] = rx_phy_postflop_12 [  11];
  assign rx_upstream_data    [ 467] = rx_phy_postflop_12 [  12];
  assign rx_upstream_data    [ 468] = rx_phy_postflop_12 [  13];
  assign rx_upstream_data    [ 469] = rx_phy_postflop_12 [  14];
  assign rx_upstream_data    [ 470] = rx_phy_postflop_12 [  15];
  assign rx_upstream_data    [ 471] = rx_phy_postflop_12 [  16];
  assign rx_upstream_data    [ 472] = rx_phy_postflop_12 [  17];
  assign rx_upstream_data    [ 473] = rx_phy_postflop_12 [  18];
  assign rx_upstream_data    [ 474] = rx_phy_postflop_12 [  19];
  assign rx_upstream_data    [ 475] = rx_phy_postflop_12 [  20];
  assign rx_upstream_data    [ 476] = rx_phy_postflop_12 [  21];
  assign rx_upstream_data    [ 477] = rx_phy_postflop_12 [  22];
  assign rx_upstream_data    [ 478] = rx_phy_postflop_12 [  23];
  assign rx_upstream_data    [ 479] = rx_phy_postflop_12 [  24];
  assign rx_upstream_data    [ 480] = rx_phy_postflop_12 [  25];
  assign rx_upstream_data    [ 481] = rx_phy_postflop_12 [  26];
  assign rx_upstream_data    [ 482] = rx_phy_postflop_12 [  27];
  assign rx_upstream_data    [ 483] = rx_phy_postflop_12 [  28];
  assign rx_upstream_data    [ 484] = rx_phy_postflop_12 [  29];
  assign rx_upstream_data    [ 485] = rx_phy_postflop_12 [  30];
  assign rx_upstream_data    [ 486] = rx_phy_postflop_12 [  31];
  assign rx_upstream_data    [ 487] = rx_phy_postflop_12 [  32];
  assign rx_upstream_data    [ 488] = rx_phy_postflop_12 [  33];
  assign rx_upstream_data    [ 489] = rx_phy_postflop_12 [  34];
  assign rx_upstream_data    [ 490] = rx_phy_postflop_12 [  35];
  assign rx_upstream_data    [ 491] = rx_phy_postflop_12 [  36];
  assign rx_upstream_data    [ 492] = rx_phy_postflop_12 [  37];
  assign rx_upstream_data    [ 493] = rx_phy_postflop_12 [  38];
//       MARKER                     = rx_phy_postflop_12 [  39]
  assign rx_upstream_data    [ 494] = rx_phy_postflop_13 [   0];
//       STROBE                     = rx_phy_postflop_13 [   1]
  assign rx_upstream_data    [ 495] = rx_phy_postflop_13 [   2];
  assign rx_upstream_data    [ 496] = rx_phy_postflop_13 [   3];
  assign rx_upstream_data    [ 497] = rx_phy_postflop_13 [   4];
  assign rx_upstream_data    [ 498] = rx_phy_postflop_13 [   5];
  assign rx_upstream_data    [ 499] = rx_phy_postflop_13 [   6];
  assign rx_upstream_data    [ 500] = rx_phy_postflop_13 [   7];
  assign rx_upstream_data    [ 501] = rx_phy_postflop_13 [   8];
  assign rx_upstream_data    [ 502] = rx_phy_postflop_13 [   9];
  assign rx_upstream_data    [ 503] = rx_phy_postflop_13 [  10];
  assign rx_upstream_data    [ 504] = rx_phy_postflop_13 [  11];
  assign rx_upstream_data    [ 505] = rx_phy_postflop_13 [  12];
  assign rx_upstream_data    [ 506] = rx_phy_postflop_13 [  13];
  assign rx_upstream_data    [ 507] = rx_phy_postflop_13 [  14];
  assign rx_upstream_data    [ 508] = rx_phy_postflop_13 [  15];
  assign rx_upstream_data    [ 509] = rx_phy_postflop_13 [  16];
  assign rx_upstream_data    [ 510] = rx_phy_postflop_13 [  17];
  assign rx_upstream_data    [ 511] = rx_phy_postflop_13 [  18];
  assign rx_upstream_data    [ 512] = rx_phy_postflop_13 [  19];
  assign rx_upstream_data    [ 513] = rx_phy_postflop_13 [  20];
  assign rx_upstream_data    [ 514] = rx_phy_postflop_13 [  21];
  assign rx_upstream_data    [ 515] = rx_phy_postflop_13 [  22];
  assign rx_upstream_data    [ 516] = rx_phy_postflop_13 [  23];
  assign rx_upstream_data    [ 517] = rx_phy_postflop_13 [  24];
  assign rx_upstream_data    [ 518] = rx_phy_postflop_13 [  25];
  assign rx_upstream_data    [ 519] = rx_phy_postflop_13 [  26];
  assign rx_upstream_data    [ 520] = rx_phy_postflop_13 [  27];
  assign rx_upstream_data    [ 521] = rx_phy_postflop_13 [  28];
  assign rx_upstream_data    [ 522] = rx_phy_postflop_13 [  29];
  assign rx_upstream_data    [ 523] = rx_phy_postflop_13 [  30];
  assign rx_upstream_data    [ 524] = rx_phy_postflop_13 [  31];
  assign rx_upstream_data    [ 525] = rx_phy_postflop_13 [  32];
  assign rx_upstream_data    [ 526] = rx_phy_postflop_13 [  33];
  assign rx_upstream_data    [ 527] = rx_phy_postflop_13 [  34];
  assign rx_upstream_data    [ 528] = rx_phy_postflop_13 [  35];
  assign rx_upstream_data    [ 529] = rx_phy_postflop_13 [  36];
  assign rx_upstream_data    [ 530] = rx_phy_postflop_13 [  37];
  assign rx_upstream_data    [ 531] = rx_phy_postflop_13 [  38];
//       MARKER                     = rx_phy_postflop_13 [  39]
  assign rx_upstream_data    [ 532] = rx_phy_postflop_14 [   0];
//       STROBE                     = rx_phy_postflop_14 [   1]
  assign rx_upstream_data    [ 533] = rx_phy_postflop_14 [   2];
  assign rx_upstream_data    [ 534] = rx_phy_postflop_14 [   3];
  assign rx_upstream_data    [ 535] = rx_phy_postflop_14 [   4];
  assign rx_upstream_data    [ 536] = rx_phy_postflop_14 [   5];
//       nc                         = rx_phy_postflop_14 [   6];
//       nc                         = rx_phy_postflop_14 [   7];
//       nc                         = rx_phy_postflop_14 [   8];
//       nc                         = rx_phy_postflop_14 [   9];
//       nc                         = rx_phy_postflop_14 [  10];
//       nc                         = rx_phy_postflop_14 [  11];
//       nc                         = rx_phy_postflop_14 [  12];
//       nc                         = rx_phy_postflop_14 [  13];
//       nc                         = rx_phy_postflop_14 [  14];
//       nc                         = rx_phy_postflop_14 [  15];
//       nc                         = rx_phy_postflop_14 [  16];
//       nc                         = rx_phy_postflop_14 [  17];
//       nc                         = rx_phy_postflop_14 [  18];
//       nc                         = rx_phy_postflop_14 [  19];
//       nc                         = rx_phy_postflop_14 [  20];
//       nc                         = rx_phy_postflop_14 [  21];
//       nc                         = rx_phy_postflop_14 [  22];
//       nc                         = rx_phy_postflop_14 [  23];
//       nc                         = rx_phy_postflop_14 [  24];
//       nc                         = rx_phy_postflop_14 [  25];
//       nc                         = rx_phy_postflop_14 [  26];
//       nc                         = rx_phy_postflop_14 [  27];
//       nc                         = rx_phy_postflop_14 [  28];
//       nc                         = rx_phy_postflop_14 [  29];
//       nc                         = rx_phy_postflop_14 [  30];
//       nc                         = rx_phy_postflop_14 [  31];
//       nc                         = rx_phy_postflop_14 [  32];
//       nc                         = rx_phy_postflop_14 [  33];
//       nc                         = rx_phy_postflop_14 [  34];
//       nc                         = rx_phy_postflop_14 [  35];
//       nc                         = rx_phy_postflop_14 [  36];
//       nc                         = rx_phy_postflop_14 [  37];
//       nc                         = rx_phy_postflop_14 [  38];
//       MARKER                     = rx_phy_postflop_14 [  39]
//       nc                         = rx_phy_postflop_15 [   0];
//       STROBE                     = rx_phy_postflop_15 [   1]
//       nc                         = rx_phy_postflop_15 [   2];
//       nc                         = rx_phy_postflop_15 [   3];
//       nc                         = rx_phy_postflop_15 [   4];
//       nc                         = rx_phy_postflop_15 [   5];
//       nc                         = rx_phy_postflop_15 [   6];
//       nc                         = rx_phy_postflop_15 [   7];
//       nc                         = rx_phy_postflop_15 [   8];
//       nc                         = rx_phy_postflop_15 [   9];
//       nc                         = rx_phy_postflop_15 [  10];
//       nc                         = rx_phy_postflop_15 [  11];
//       nc                         = rx_phy_postflop_15 [  12];
//       nc                         = rx_phy_postflop_15 [  13];
//       nc                         = rx_phy_postflop_15 [  14];
//       nc                         = rx_phy_postflop_15 [  15];
//       nc                         = rx_phy_postflop_15 [  16];
//       nc                         = rx_phy_postflop_15 [  17];
//       nc                         = rx_phy_postflop_15 [  18];
//       nc                         = rx_phy_postflop_15 [  19];
//       nc                         = rx_phy_postflop_15 [  20];
//       nc                         = rx_phy_postflop_15 [  21];
//       nc                         = rx_phy_postflop_15 [  22];
//       nc                         = rx_phy_postflop_15 [  23];
//       nc                         = rx_phy_postflop_15 [  24];
//       nc                         = rx_phy_postflop_15 [  25];
//       nc                         = rx_phy_postflop_15 [  26];
//       nc                         = rx_phy_postflop_15 [  27];
//       nc                         = rx_phy_postflop_15 [  28];
//       nc                         = rx_phy_postflop_15 [  29];
//       nc                         = rx_phy_postflop_15 [  30];
//       nc                         = rx_phy_postflop_15 [  31];
//       nc                         = rx_phy_postflop_15 [  32];
//       nc                         = rx_phy_postflop_15 [  33];
//       nc                         = rx_phy_postflop_15 [  34];
//       nc                         = rx_phy_postflop_15 [  35];
//       nc                         = rx_phy_postflop_15 [  36];
//       nc                         = rx_phy_postflop_15 [  37];
//       nc                         = rx_phy_postflop_15 [  38];
//       MARKER                     = rx_phy_postflop_15 [  39]

// RX Section
//////////////////////////////////////////////////////////////////


endmodule
