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

module axi_dual_st_d64_slave_concat  (

// Data from Logic Links
  output logic [  72:   0]   rx_ST_M2S_data      ,
  output logic               rx_ST_M2S_push_ovrd ,
  output logic               rx_ST_M2S_pushbit   ,
  input  logic               tx_ST_M2S_credit    ,

  input  logic [  72:   0]   tx_ST_S2M_data      ,
  output logic               tx_ST_S2M_pop_ovrd  ,
  input  logic               tx_ST_S2M_pushbit   ,
  output logic               rx_ST_S2M_credit    ,

// PHY Interconnect
  output logic [  79:   0]   tx_phy0             ,
  input  logic [  79:   0]   rx_phy0             ,

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
  assign tx_ST_S2M_pop_ovrd                 = 1'b0                               ;

// No RX Packetization, so tie off packetization signals
  assign rx_ST_M2S_push_ovrd                = 1'b0                               ;

//////////////////////////////////////////////////////////////////
// TX Section

//   TX_CH_WIDTH           = 80; // Gen2Only running at Full Rate
//   TX_DATA_WIDTH         = 76; // Usable Data per Channel
//   TX_PERSISTENT_STROBE  = 1'b0;
//   TX_PERSISTENT_MARKER  = 1'b0;
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
  logic [  79:   0]                              tx_phy_preflop_recov_strobe_0 ;
  logic [  79:   0]                              tx_phy_preflop_recov_marker_0 ;
  logic [  79:   0]                              tx_phy_flop_0_reg             ;

  always_ff @(posedge clk_wr or negedge rst_wr_n)
  if (~rst_wr_n)
  begin
    tx_phy_flop_0_reg                       <= 80'b0                                   ;
  end
  else
  begin
    tx_phy_flop_0_reg                       <= tx_phy_preflop_recov_marker_0               ;
  end

  assign tx_phy0                            = TX_REG_PHY ? tx_phy_flop_0_reg : tx_phy_preflop_recov_marker_0               ;

  assign tx_phy_preflop_recov_strobe_0 [   0 +:  76] =                                 tx_phy_preflop_0 [   0 +:  76] ;
  assign tx_phy_preflop_recov_strobe_0 [  76 +:   1] = (~tx_online) ? tx_stb_userbit : tx_phy_preflop_0 [  76 +:   1] ;
  assign tx_phy_preflop_recov_strobe_0 [  77 +:   3] =                                 tx_phy_preflop_0 [  77 +:   3] ;

  assign tx_phy_preflop_recov_marker_0 [   0 +:   4] =                                    tx_phy_preflop_recov_strobe_0 [   0 +:   4] ;
  assign tx_phy_preflop_recov_marker_0 [   4 +:   1] = (~tx_online) ? tx_mrk_userbit[0] : tx_phy_preflop_recov_strobe_0 [   4 +:   1] ;
  assign tx_phy_preflop_recov_marker_0 [   5 +:  75] =                                    tx_phy_preflop_recov_strobe_0 [   5 +:  75] ;

  assign tx_phy_preflop_0 [   0] = tx_ST_M2S_credit           ;
  assign tx_phy_preflop_0 [   1] = tx_ST_S2M_pushbit          ;
  assign tx_phy_preflop_0 [   2] = tx_ST_S2M_data      [   0] ;
  assign tx_phy_preflop_0 [   3] = tx_ST_S2M_data      [   1] ;
  assign tx_phy_preflop_0 [   4] = tx_ST_S2M_data      [   2] ;
  assign tx_phy_preflop_0 [   5] = tx_ST_S2M_data      [   3] ;
  assign tx_phy_preflop_0 [   6] = tx_ST_S2M_data      [   4] ;
  assign tx_phy_preflop_0 [   7] = tx_ST_S2M_data      [   5] ;
  assign tx_phy_preflop_0 [   8] = tx_ST_S2M_data      [   6] ;
  assign tx_phy_preflop_0 [   9] = tx_ST_S2M_data      [   7] ;
  assign tx_phy_preflop_0 [  10] = tx_ST_S2M_data      [   8] ;
  assign tx_phy_preflop_0 [  11] = tx_ST_S2M_data      [   9] ;
  assign tx_phy_preflop_0 [  12] = tx_ST_S2M_data      [  10] ;
  assign tx_phy_preflop_0 [  13] = tx_ST_S2M_data      [  11] ;
  assign tx_phy_preflop_0 [  14] = tx_ST_S2M_data      [  12] ;
  assign tx_phy_preflop_0 [  15] = tx_ST_S2M_data      [  13] ;
  assign tx_phy_preflop_0 [  16] = tx_ST_S2M_data      [  14] ;
  assign tx_phy_preflop_0 [  17] = tx_ST_S2M_data      [  15] ;
  assign tx_phy_preflop_0 [  18] = tx_ST_S2M_data      [  16] ;
  assign tx_phy_preflop_0 [  19] = tx_ST_S2M_data      [  17] ;
  assign tx_phy_preflop_0 [  20] = tx_ST_S2M_data      [  18] ;
  assign tx_phy_preflop_0 [  21] = tx_ST_S2M_data      [  19] ;
  assign tx_phy_preflop_0 [  22] = tx_ST_S2M_data      [  20] ;
  assign tx_phy_preflop_0 [  23] = tx_ST_S2M_data      [  21] ;
  assign tx_phy_preflop_0 [  24] = tx_ST_S2M_data      [  22] ;
  assign tx_phy_preflop_0 [  25] = tx_ST_S2M_data      [  23] ;
  assign tx_phy_preflop_0 [  26] = tx_ST_S2M_data      [  24] ;
  assign tx_phy_preflop_0 [  27] = tx_ST_S2M_data      [  25] ;
  assign tx_phy_preflop_0 [  28] = tx_ST_S2M_data      [  26] ;
  assign tx_phy_preflop_0 [  29] = tx_ST_S2M_data      [  27] ;
  assign tx_phy_preflop_0 [  30] = tx_ST_S2M_data      [  28] ;
  assign tx_phy_preflop_0 [  31] = tx_ST_S2M_data      [  29] ;
  assign tx_phy_preflop_0 [  32] = tx_ST_S2M_data      [  30] ;
  assign tx_phy_preflop_0 [  33] = tx_ST_S2M_data      [  31] ;
  assign tx_phy_preflop_0 [  34] = tx_ST_S2M_data      [  32] ;
  assign tx_phy_preflop_0 [  35] = tx_ST_S2M_data      [  33] ;
  assign tx_phy_preflop_0 [  36] = tx_ST_S2M_data      [  34] ;
  assign tx_phy_preflop_0 [  37] = tx_ST_S2M_data      [  35] ;
  assign tx_phy_preflop_0 [  38] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [  39] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [  40] = tx_ST_S2M_data      [  36] ;
  assign tx_phy_preflop_0 [  41] = tx_ST_S2M_data      [  37] ;
  assign tx_phy_preflop_0 [  42] = tx_ST_S2M_data      [  38] ;
  assign tx_phy_preflop_0 [  43] = tx_ST_S2M_data      [  39] ;
  assign tx_phy_preflop_0 [  44] = tx_ST_S2M_data      [  40] ;
  assign tx_phy_preflop_0 [  45] = tx_ST_S2M_data      [  41] ;
  assign tx_phy_preflop_0 [  46] = tx_ST_S2M_data      [  42] ;
  assign tx_phy_preflop_0 [  47] = tx_ST_S2M_data      [  43] ;
  assign tx_phy_preflop_0 [  48] = tx_ST_S2M_data      [  44] ;
  assign tx_phy_preflop_0 [  49] = tx_ST_S2M_data      [  45] ;
  assign tx_phy_preflop_0 [  50] = tx_ST_S2M_data      [  46] ;
  assign tx_phy_preflop_0 [  51] = tx_ST_S2M_data      [  47] ;
  assign tx_phy_preflop_0 [  52] = tx_ST_S2M_data      [  48] ;
  assign tx_phy_preflop_0 [  53] = tx_ST_S2M_data      [  49] ;
  assign tx_phy_preflop_0 [  54] = tx_ST_S2M_data      [  50] ;
  assign tx_phy_preflop_0 [  55] = tx_ST_S2M_data      [  51] ;
  assign tx_phy_preflop_0 [  56] = tx_ST_S2M_data      [  52] ;
  assign tx_phy_preflop_0 [  57] = tx_ST_S2M_data      [  53] ;
  assign tx_phy_preflop_0 [  58] = tx_ST_S2M_data      [  54] ;
  assign tx_phy_preflop_0 [  59] = tx_ST_S2M_data      [  55] ;
  assign tx_phy_preflop_0 [  60] = tx_ST_S2M_data      [  56] ;
  assign tx_phy_preflop_0 [  61] = tx_ST_S2M_data      [  57] ;
  assign tx_phy_preflop_0 [  62] = tx_ST_S2M_data      [  58] ;
  assign tx_phy_preflop_0 [  63] = tx_ST_S2M_data      [  59] ;
  assign tx_phy_preflop_0 [  64] = tx_ST_S2M_data      [  60] ;
  assign tx_phy_preflop_0 [  65] = tx_ST_S2M_data      [  61] ;
  assign tx_phy_preflop_0 [  66] = tx_ST_S2M_data      [  62] ;
  assign tx_phy_preflop_0 [  67] = tx_ST_S2M_data      [  63] ;
  assign tx_phy_preflop_0 [  68] = tx_ST_S2M_data      [  64] ;
  assign tx_phy_preflop_0 [  69] = tx_ST_S2M_data      [  65] ;
  assign tx_phy_preflop_0 [  70] = tx_ST_S2M_data      [  66] ;
  assign tx_phy_preflop_0 [  71] = tx_ST_S2M_data      [  67] ;
  assign tx_phy_preflop_0 [  72] = tx_ST_S2M_data      [  68] ;
  assign tx_phy_preflop_0 [  73] = tx_ST_S2M_data      [  69] ;
  assign tx_phy_preflop_0 [  74] = tx_ST_S2M_data      [  70] ;
  assign tx_phy_preflop_0 [  75] = tx_ST_S2M_data      [  71] ;
  assign tx_phy_preflop_0 [  76] = tx_ST_S2M_data      [  72] ;
  assign tx_phy_preflop_0 [  77] = 1'b0                       ;
  assign tx_phy_preflop_0 [  78] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [  79] = 1'b0                       ; // DBI
// TX Section
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// RX Section

//   RX_CH_WIDTH           = 80; // Gen2Only running at Full Rate
//   RX_DATA_WIDTH         = 76; // Usable Data per Channel
//   RX_PERSISTENT_STROBE  = 1'b0;
//   RX_PERSISTENT_MARKER  = 1'b0;
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
  logic [  79:   0]                              rx_phy_flop_0_reg             ;

  always_ff @(posedge clk_rd or negedge rst_rd_n)
  if (~rst_rd_n)
  begin
    rx_phy_flop_0_reg                       <= 80'b0                                   ;
  end
  else
  begin
    rx_phy_flop_0_reg                       <= rx_phy0                                 ;
  end


  assign rx_phy_postflop_0                  = RX_REG_PHY ? rx_phy_flop_0_reg : rx_phy0               ;

  assign rx_ST_M2S_pushbit          = rx_phy_postflop_0 [   0];
  assign rx_ST_M2S_data      [   0] = rx_phy_postflop_0 [   1];
  assign rx_ST_M2S_data      [   1] = rx_phy_postflop_0 [   2];
  assign rx_ST_M2S_data      [   2] = rx_phy_postflop_0 [   3];
  assign rx_ST_M2S_data      [   3] = rx_phy_postflop_0 [   4];
  assign rx_ST_M2S_data      [   4] = rx_phy_postflop_0 [   5];
  assign rx_ST_M2S_data      [   5] = rx_phy_postflop_0 [   6];
  assign rx_ST_M2S_data      [   6] = rx_phy_postflop_0 [   7];
  assign rx_ST_M2S_data      [   7] = rx_phy_postflop_0 [   8];
  assign rx_ST_M2S_data      [   8] = rx_phy_postflop_0 [   9];
  assign rx_ST_M2S_data      [   9] = rx_phy_postflop_0 [  10];
  assign rx_ST_M2S_data      [  10] = rx_phy_postflop_0 [  11];
  assign rx_ST_M2S_data      [  11] = rx_phy_postflop_0 [  12];
  assign rx_ST_M2S_data      [  12] = rx_phy_postflop_0 [  13];
  assign rx_ST_M2S_data      [  13] = rx_phy_postflop_0 [  14];
  assign rx_ST_M2S_data      [  14] = rx_phy_postflop_0 [  15];
  assign rx_ST_M2S_data      [  15] = rx_phy_postflop_0 [  16];
  assign rx_ST_M2S_data      [  16] = rx_phy_postflop_0 [  17];
  assign rx_ST_M2S_data      [  17] = rx_phy_postflop_0 [  18];
  assign rx_ST_M2S_data      [  18] = rx_phy_postflop_0 [  19];
  assign rx_ST_M2S_data      [  19] = rx_phy_postflop_0 [  20];
  assign rx_ST_M2S_data      [  20] = rx_phy_postflop_0 [  21];
  assign rx_ST_M2S_data      [  21] = rx_phy_postflop_0 [  22];
  assign rx_ST_M2S_data      [  22] = rx_phy_postflop_0 [  23];
  assign rx_ST_M2S_data      [  23] = rx_phy_postflop_0 [  24];
  assign rx_ST_M2S_data      [  24] = rx_phy_postflop_0 [  25];
  assign rx_ST_M2S_data      [  25] = rx_phy_postflop_0 [  26];
  assign rx_ST_M2S_data      [  26] = rx_phy_postflop_0 [  27];
  assign rx_ST_M2S_data      [  27] = rx_phy_postflop_0 [  28];
  assign rx_ST_M2S_data      [  28] = rx_phy_postflop_0 [  29];
  assign rx_ST_M2S_data      [  29] = rx_phy_postflop_0 [  30];
  assign rx_ST_M2S_data      [  30] = rx_phy_postflop_0 [  31];
  assign rx_ST_M2S_data      [  31] = rx_phy_postflop_0 [  32];
  assign rx_ST_M2S_data      [  32] = rx_phy_postflop_0 [  33];
  assign rx_ST_M2S_data      [  33] = rx_phy_postflop_0 [  34];
  assign rx_ST_M2S_data      [  34] = rx_phy_postflop_0 [  35];
  assign rx_ST_M2S_data      [  35] = rx_phy_postflop_0 [  36];
  assign rx_ST_M2S_data      [  36] = rx_phy_postflop_0 [  37];
//       DBI                        = rx_phy_postflop_0 [  38];
//       DBI                        = rx_phy_postflop_0 [  39];
  assign rx_ST_M2S_data      [  37] = rx_phy_postflop_0 [  40];
  assign rx_ST_M2S_data      [  38] = rx_phy_postflop_0 [  41];
  assign rx_ST_M2S_data      [  39] = rx_phy_postflop_0 [  42];
  assign rx_ST_M2S_data      [  40] = rx_phy_postflop_0 [  43];
  assign rx_ST_M2S_data      [  41] = rx_phy_postflop_0 [  44];
  assign rx_ST_M2S_data      [  42] = rx_phy_postflop_0 [  45];
  assign rx_ST_M2S_data      [  43] = rx_phy_postflop_0 [  46];
  assign rx_ST_M2S_data      [  44] = rx_phy_postflop_0 [  47];
  assign rx_ST_M2S_data      [  45] = rx_phy_postflop_0 [  48];
  assign rx_ST_M2S_data      [  46] = rx_phy_postflop_0 [  49];
  assign rx_ST_M2S_data      [  47] = rx_phy_postflop_0 [  50];
  assign rx_ST_M2S_data      [  48] = rx_phy_postflop_0 [  51];
  assign rx_ST_M2S_data      [  49] = rx_phy_postflop_0 [  52];
  assign rx_ST_M2S_data      [  50] = rx_phy_postflop_0 [  53];
  assign rx_ST_M2S_data      [  51] = rx_phy_postflop_0 [  54];
  assign rx_ST_M2S_data      [  52] = rx_phy_postflop_0 [  55];
  assign rx_ST_M2S_data      [  53] = rx_phy_postflop_0 [  56];
  assign rx_ST_M2S_data      [  54] = rx_phy_postflop_0 [  57];
  assign rx_ST_M2S_data      [  55] = rx_phy_postflop_0 [  58];
  assign rx_ST_M2S_data      [  56] = rx_phy_postflop_0 [  59];
  assign rx_ST_M2S_data      [  57] = rx_phy_postflop_0 [  60];
  assign rx_ST_M2S_data      [  58] = rx_phy_postflop_0 [  61];
  assign rx_ST_M2S_data      [  59] = rx_phy_postflop_0 [  62];
  assign rx_ST_M2S_data      [  60] = rx_phy_postflop_0 [  63];
  assign rx_ST_M2S_data      [  61] = rx_phy_postflop_0 [  64];
  assign rx_ST_M2S_data      [  62] = rx_phy_postflop_0 [  65];
  assign rx_ST_M2S_data      [  63] = rx_phy_postflop_0 [  66];
  assign rx_ST_M2S_data      [  64] = rx_phy_postflop_0 [  67];
  assign rx_ST_M2S_data      [  65] = rx_phy_postflop_0 [  68];
  assign rx_ST_M2S_data      [  66] = rx_phy_postflop_0 [  69];
  assign rx_ST_M2S_data      [  67] = rx_phy_postflop_0 [  70];
  assign rx_ST_M2S_data      [  68] = rx_phy_postflop_0 [  71];
  assign rx_ST_M2S_data      [  69] = rx_phy_postflop_0 [  72];
  assign rx_ST_M2S_data      [  70] = rx_phy_postflop_0 [  73];
  assign rx_ST_M2S_data      [  71] = rx_phy_postflop_0 [  74];
  assign rx_ST_M2S_data      [  72] = rx_phy_postflop_0 [  75];
  assign rx_ST_S2M_credit           = rx_phy_postflop_0 [  76];
//       nc                         = rx_phy_postflop_0 [  77];
//       DBI                        = rx_phy_postflop_0 [  78];
//       DBI                        = rx_phy_postflop_0 [  79];

// RX Section
//////////////////////////////////////////////////////////////////


endmodule
