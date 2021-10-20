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

module lpif_txrx_x2_f1_master_concat  (

// Data from Logic Links
  input  logic [  88:   0]   tx_downstream_data  ,
  output logic               tx_downstream_pop_ovrd,

  output logic [  88:   0]   rx_upstream_data    ,
  output logic               rx_upstream_push_ovrd,

// PHY Interconnect
  output logic [  39:   0]   tx_phy0             ,
  input  logic [  39:   0]   rx_phy0             ,
  output logic [  39:   0]   tx_phy1             ,
  input  logic [  39:   0]   rx_phy1             ,
  output logic [  39:   0]   tx_phy2             ,
  input  logic [  39:   0]   rx_phy2             ,

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
  logic [  39:   0]                              tx_phy_flop_0_reg             ;
  logic [  39:   0]                              tx_phy_flop_1_reg             ;
  logic [  39:   0]                              tx_phy_flop_2_reg             ;

  always_ff @(posedge clk_wr or negedge rst_wr_n)
  if (~rst_wr_n)
  begin
    tx_phy_flop_0_reg                       <= 40'b0                                   ;
    tx_phy_flop_1_reg                       <= 40'b0                                   ;
    tx_phy_flop_2_reg                       <= 40'b0                                   ;
  end
  else
  begin
    tx_phy_flop_0_reg                       <= tx_phy_preflop_0                        ;
    tx_phy_flop_1_reg                       <= tx_phy_preflop_1                        ;
    tx_phy_flop_2_reg                       <= tx_phy_preflop_2                        ;
  end

  assign tx_phy0                            = TX_REG_PHY ? tx_phy_flop_0_reg : tx_phy_preflop_0               ;
  assign tx_phy1                            = TX_REG_PHY ? tx_phy_flop_1_reg : tx_phy_preflop_1               ;
  assign tx_phy2                            = TX_REG_PHY ? tx_phy_flop_2_reg : tx_phy_preflop_2               ;

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
  assign tx_phy_preflop_2 [  38] = 1'b0                       ;
  assign tx_phy_preflop_2 [  39] = tx_mrk_userbit[0]          ; // MARKER
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
  logic [  39:   0]                              rx_phy_flop_0_reg             ;
  logic [  39:   0]                              rx_phy_flop_1_reg             ;
  logic [  39:   0]                              rx_phy_flop_2_reg             ;

  always_ff @(posedge clk_rd or negedge rst_rd_n)
  if (~rst_rd_n)
  begin
    rx_phy_flop_0_reg                       <= 40'b0                                   ;
    rx_phy_flop_1_reg                       <= 40'b0                                   ;
    rx_phy_flop_2_reg                       <= 40'b0                                   ;
  end
  else
  begin
    rx_phy_flop_0_reg                       <= rx_phy0                                 ;
    rx_phy_flop_1_reg                       <= rx_phy1                                 ;
    rx_phy_flop_2_reg                       <= rx_phy2                                 ;
  end


  assign rx_phy_postflop_0                  = RX_REG_PHY ? rx_phy_flop_0_reg : rx_phy0               ;
  assign rx_phy_postflop_1                  = RX_REG_PHY ? rx_phy_flop_1_reg : rx_phy1               ;
  assign rx_phy_postflop_2                  = RX_REG_PHY ? rx_phy_flop_2_reg : rx_phy2               ;

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

// RX Section
//////////////////////////////////////////////////////////////////


endmodule
