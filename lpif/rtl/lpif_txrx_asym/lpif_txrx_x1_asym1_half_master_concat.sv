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

module lpif_txrx_x1_asym1_half_master_concat  (

// Data from Logic Links
  input  logic [  83:   0]   tx_downstream_data  ,
  output logic               tx_downstream_pop_ovrd,

  output logic [  83:   0]   rx_upstream_data    ,
  output logic               rx_upstream_push_ovrd,

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
  input  logic [   1:   0]   tx_mrk_userbit      

);

// No TX Packetization, so tie off packetization signals
  assign tx_downstream_pop_ovrd               = 1'b0                               ;

// No RX Packetization, so tie off packetization signals
  assign rx_upstream_push_ovrd               = 1'b0                               ;

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
  assign tx_phy_preflop_1 [   5] = 1'b0                       ;
  assign tx_phy_preflop_1 [   6] = 1'b0                       ;
  assign tx_phy_preflop_1 [   7] = 1'b0                       ;
  assign tx_phy_preflop_1 [   8] = 1'b0                       ;
  assign tx_phy_preflop_1 [   9] = 1'b0                       ;
  assign tx_phy_preflop_1 [  10] = 1'b0                       ;
  assign tx_phy_preflop_1 [  11] = 1'b0                       ;
  assign tx_phy_preflop_1 [  12] = 1'b0                       ;
  assign tx_phy_preflop_1 [  13] = 1'b0                       ;
  assign tx_phy_preflop_1 [  14] = 1'b0                       ;
  assign tx_phy_preflop_1 [  15] = 1'b0                       ;
  assign tx_phy_preflop_1 [  16] = 1'b0                       ;
  assign tx_phy_preflop_1 [  17] = 1'b0                       ;
  assign tx_phy_preflop_1 [  18] = 1'b0                       ;
  assign tx_phy_preflop_1 [  19] = 1'b0                       ;
  assign tx_phy_preflop_1 [  20] = 1'b0                       ;
  assign tx_phy_preflop_1 [  21] = 1'b0                       ;
  assign tx_phy_preflop_1 [  22] = 1'b0                       ;
  assign tx_phy_preflop_1 [  23] = 1'b0                       ;
  assign tx_phy_preflop_1 [  24] = 1'b0                       ;
  assign tx_phy_preflop_1 [  25] = 1'b0                       ;
  assign tx_phy_preflop_1 [  26] = 1'b0                       ;
  assign tx_phy_preflop_1 [  27] = 1'b0                       ;
  assign tx_phy_preflop_1 [  28] = 1'b0                       ;
  assign tx_phy_preflop_1 [  29] = 1'b0                       ;
  assign tx_phy_preflop_1 [  30] = 1'b0                       ;
  assign tx_phy_preflop_1 [  31] = 1'b0                       ;
  assign tx_phy_preflop_1 [  32] = 1'b0                       ;
  assign tx_phy_preflop_1 [  33] = 1'b0                       ;
  assign tx_phy_preflop_1 [  34] = 1'b0                       ;
  assign tx_phy_preflop_1 [  35] = 1'b0                       ;
  assign tx_phy_preflop_1 [  36] = 1'b0                       ;
  assign tx_phy_preflop_1 [  37] = 1'b0                       ;
  assign tx_phy_preflop_1 [  38] = 1'b0                       ;
  assign tx_phy_preflop_1 [  39] = tx_mrk_userbit[0]          ; // MARKER
  assign tx_phy_preflop_0 [  40] = tx_downstream_data  [  42] ;
  assign tx_phy_preflop_0 [  41] = 1'b0                       ; // STROBE (unused)
  assign tx_phy_preflop_0 [  42] = tx_downstream_data  [  43] ;
  assign tx_phy_preflop_0 [  43] = tx_downstream_data  [  44] ;
  assign tx_phy_preflop_0 [  44] = tx_downstream_data  [  45] ;
  assign tx_phy_preflop_0 [  45] = tx_downstream_data  [  46] ;
  assign tx_phy_preflop_0 [  46] = tx_downstream_data  [  47] ;
  assign tx_phy_preflop_0 [  47] = tx_downstream_data  [  48] ;
  assign tx_phy_preflop_0 [  48] = tx_downstream_data  [  49] ;
  assign tx_phy_preflop_0 [  49] = tx_downstream_data  [  50] ;
  assign tx_phy_preflop_0 [  50] = tx_downstream_data  [  51] ;
  assign tx_phy_preflop_0 [  51] = tx_downstream_data  [  52] ;
  assign tx_phy_preflop_0 [  52] = tx_downstream_data  [  53] ;
  assign tx_phy_preflop_0 [  53] = tx_downstream_data  [  54] ;
  assign tx_phy_preflop_0 [  54] = tx_downstream_data  [  55] ;
  assign tx_phy_preflop_0 [  55] = tx_downstream_data  [  56] ;
  assign tx_phy_preflop_0 [  56] = tx_downstream_data  [  57] ;
  assign tx_phy_preflop_0 [  57] = tx_downstream_data  [  58] ;
  assign tx_phy_preflop_0 [  58] = tx_downstream_data  [  59] ;
  assign tx_phy_preflop_0 [  59] = tx_downstream_data  [  60] ;
  assign tx_phy_preflop_0 [  60] = tx_downstream_data  [  61] ;
  assign tx_phy_preflop_0 [  61] = tx_downstream_data  [  62] ;
  assign tx_phy_preflop_0 [  62] = tx_downstream_data  [  63] ;
  assign tx_phy_preflop_0 [  63] = tx_downstream_data  [  64] ;
  assign tx_phy_preflop_0 [  64] = tx_downstream_data  [  65] ;
  assign tx_phy_preflop_0 [  65] = tx_downstream_data  [  66] ;
  assign tx_phy_preflop_0 [  66] = tx_downstream_data  [  67] ;
  assign tx_phy_preflop_0 [  67] = tx_downstream_data  [  68] ;
  assign tx_phy_preflop_0 [  68] = tx_downstream_data  [  69] ;
  assign tx_phy_preflop_0 [  69] = tx_downstream_data  [  70] ;
  assign tx_phy_preflop_0 [  70] = tx_downstream_data  [  71] ;
  assign tx_phy_preflop_0 [  71] = tx_downstream_data  [  72] ;
  assign tx_phy_preflop_0 [  72] = tx_downstream_data  [  73] ;
  assign tx_phy_preflop_0 [  73] = tx_downstream_data  [  74] ;
  assign tx_phy_preflop_0 [  74] = tx_downstream_data  [  75] ;
  assign tx_phy_preflop_0 [  75] = tx_downstream_data  [  76] ;
  assign tx_phy_preflop_0 [  76] = tx_downstream_data  [  77] ;
  assign tx_phy_preflop_0 [  77] = tx_downstream_data  [  78] ;
  assign tx_phy_preflop_0 [  78] = tx_downstream_data  [  79] ;
  assign tx_phy_preflop_0 [  79] = tx_mrk_userbit[1]          ; // MARKER
  assign tx_phy_preflop_1 [  40] = tx_downstream_data  [  80] ;
  assign tx_phy_preflop_1 [  41] = 1'b0                       ; // STROBE (unused)
  assign tx_phy_preflop_1 [  42] = tx_downstream_data  [  81] ;
  assign tx_phy_preflop_1 [  43] = tx_downstream_data  [  82] ;
  assign tx_phy_preflop_1 [  44] = tx_downstream_data  [  83] ;
  assign tx_phy_preflop_1 [  45] = 1'b0                       ;
  assign tx_phy_preflop_1 [  46] = 1'b0                       ;
  assign tx_phy_preflop_1 [  47] = 1'b0                       ;
  assign tx_phy_preflop_1 [  48] = 1'b0                       ;
  assign tx_phy_preflop_1 [  49] = 1'b0                       ;
  assign tx_phy_preflop_1 [  50] = 1'b0                       ;
  assign tx_phy_preflop_1 [  51] = 1'b0                       ;
  assign tx_phy_preflop_1 [  52] = 1'b0                       ;
  assign tx_phy_preflop_1 [  53] = 1'b0                       ;
  assign tx_phy_preflop_1 [  54] = 1'b0                       ;
  assign tx_phy_preflop_1 [  55] = 1'b0                       ;
  assign tx_phy_preflop_1 [  56] = 1'b0                       ;
  assign tx_phy_preflop_1 [  57] = 1'b0                       ;
  assign tx_phy_preflop_1 [  58] = 1'b0                       ;
  assign tx_phy_preflop_1 [  59] = 1'b0                       ;
  assign tx_phy_preflop_1 [  60] = 1'b0                       ;
  assign tx_phy_preflop_1 [  61] = 1'b0                       ;
  assign tx_phy_preflop_1 [  62] = 1'b0                       ;
  assign tx_phy_preflop_1 [  63] = 1'b0                       ;
  assign tx_phy_preflop_1 [  64] = 1'b0                       ;
  assign tx_phy_preflop_1 [  65] = 1'b0                       ;
  assign tx_phy_preflop_1 [  66] = 1'b0                       ;
  assign tx_phy_preflop_1 [  67] = 1'b0                       ;
  assign tx_phy_preflop_1 [  68] = 1'b0                       ;
  assign tx_phy_preflop_1 [  69] = 1'b0                       ;
  assign tx_phy_preflop_1 [  70] = 1'b0                       ;
  assign tx_phy_preflop_1 [  71] = 1'b0                       ;
  assign tx_phy_preflop_1 [  72] = 1'b0                       ;
  assign tx_phy_preflop_1 [  73] = 1'b0                       ;
  assign tx_phy_preflop_1 [  74] = 1'b0                       ;
  assign tx_phy_preflop_1 [  75] = 1'b0                       ;
  assign tx_phy_preflop_1 [  76] = 1'b0                       ;
  assign tx_phy_preflop_1 [  77] = 1'b0                       ;
  assign tx_phy_preflop_1 [  78] = 1'b0                       ;
  assign tx_phy_preflop_1 [  79] = tx_mrk_userbit[1]          ; // MARKER
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
  assign rx_upstream_data    [  42] = rx_phy_postflop_0 [  40];
//       STROBE                     = rx_phy_postflop_0 [  41]
  assign rx_upstream_data    [  43] = rx_phy_postflop_0 [  42];
  assign rx_upstream_data    [  44] = rx_phy_postflop_0 [  43];
  assign rx_upstream_data    [  45] = rx_phy_postflop_0 [  44];
  assign rx_upstream_data    [  46] = rx_phy_postflop_0 [  45];
  assign rx_upstream_data    [  47] = rx_phy_postflop_0 [  46];
  assign rx_upstream_data    [  48] = rx_phy_postflop_0 [  47];
  assign rx_upstream_data    [  49] = rx_phy_postflop_0 [  48];
  assign rx_upstream_data    [  50] = rx_phy_postflop_0 [  49];
  assign rx_upstream_data    [  51] = rx_phy_postflop_0 [  50];
  assign rx_upstream_data    [  52] = rx_phy_postflop_0 [  51];
  assign rx_upstream_data    [  53] = rx_phy_postflop_0 [  52];
  assign rx_upstream_data    [  54] = rx_phy_postflop_0 [  53];
  assign rx_upstream_data    [  55] = rx_phy_postflop_0 [  54];
  assign rx_upstream_data    [  56] = rx_phy_postflop_0 [  55];
  assign rx_upstream_data    [  57] = rx_phy_postflop_0 [  56];
  assign rx_upstream_data    [  58] = rx_phy_postflop_0 [  57];
  assign rx_upstream_data    [  59] = rx_phy_postflop_0 [  58];
  assign rx_upstream_data    [  60] = rx_phy_postflop_0 [  59];
  assign rx_upstream_data    [  61] = rx_phy_postflop_0 [  60];
  assign rx_upstream_data    [  62] = rx_phy_postflop_0 [  61];
  assign rx_upstream_data    [  63] = rx_phy_postflop_0 [  62];
  assign rx_upstream_data    [  64] = rx_phy_postflop_0 [  63];
  assign rx_upstream_data    [  65] = rx_phy_postflop_0 [  64];
  assign rx_upstream_data    [  66] = rx_phy_postflop_0 [  65];
  assign rx_upstream_data    [  67] = rx_phy_postflop_0 [  66];
  assign rx_upstream_data    [  68] = rx_phy_postflop_0 [  67];
  assign rx_upstream_data    [  69] = rx_phy_postflop_0 [  68];
  assign rx_upstream_data    [  70] = rx_phy_postflop_0 [  69];
  assign rx_upstream_data    [  71] = rx_phy_postflop_0 [  70];
  assign rx_upstream_data    [  72] = rx_phy_postflop_0 [  71];
  assign rx_upstream_data    [  73] = rx_phy_postflop_0 [  72];
  assign rx_upstream_data    [  74] = rx_phy_postflop_0 [  73];
  assign rx_upstream_data    [  75] = rx_phy_postflop_0 [  74];
  assign rx_upstream_data    [  76] = rx_phy_postflop_0 [  75];
  assign rx_upstream_data    [  77] = rx_phy_postflop_0 [  76];
  assign rx_upstream_data    [  78] = rx_phy_postflop_0 [  77];
  assign rx_upstream_data    [  79] = rx_phy_postflop_0 [  78];
//       MARKER                     = rx_phy_postflop_0 [  79]
  assign rx_upstream_data    [  80] = rx_phy_postflop_1 [  40];
//       STROBE                     = rx_phy_postflop_1 [  41]
  assign rx_upstream_data    [  81] = rx_phy_postflop_1 [  42];
  assign rx_upstream_data    [  82] = rx_phy_postflop_1 [  43];
  assign rx_upstream_data    [  83] = rx_phy_postflop_1 [  44];
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

// RX Section
//////////////////////////////////////////////////////////////////


endmodule
