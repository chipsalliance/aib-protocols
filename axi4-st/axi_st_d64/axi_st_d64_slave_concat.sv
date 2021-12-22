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

module axi_st_d64_slave_concat  (

// Data from Logic Links
  output logic [  72:   0]   rx_st_data          ,
  output logic               rx_st_push_ovrd     ,
  output logic               rx_st_pushbit       ,
  input  logic               tx_st_credit        ,

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

// No RX Packetization, so tie off packetization signals
  assign rx_st_push_ovrd                    = 1'b0                               ;

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

  assign tx_phy_preflop_0 [   0] = tx_st_credit               ;
  assign tx_phy_preflop_0 [   1] = 1'b0                       ;
  assign tx_phy_preflop_0 [   2] = 1'b0                       ;
  assign tx_phy_preflop_0 [   3] = 1'b0                       ;
  assign tx_phy_preflop_0 [   4] = 1'b0                       ;
  assign tx_phy_preflop_0 [   5] = 1'b0                       ;
  assign tx_phy_preflop_0 [   6] = 1'b0                       ;
  assign tx_phy_preflop_0 [   7] = 1'b0                       ;
  assign tx_phy_preflop_0 [   8] = 1'b0                       ;
  assign tx_phy_preflop_0 [   9] = 1'b0                       ;
  assign tx_phy_preflop_0 [  10] = 1'b0                       ;
  assign tx_phy_preflop_0 [  11] = 1'b0                       ;
  assign tx_phy_preflop_0 [  12] = 1'b0                       ;
  assign tx_phy_preflop_0 [  13] = 1'b0                       ;
  assign tx_phy_preflop_0 [  14] = 1'b0                       ;
  assign tx_phy_preflop_0 [  15] = 1'b0                       ;
  assign tx_phy_preflop_0 [  16] = 1'b0                       ;
  assign tx_phy_preflop_0 [  17] = 1'b0                       ;
  assign tx_phy_preflop_0 [  18] = 1'b0                       ;
  assign tx_phy_preflop_0 [  19] = 1'b0                       ;
  assign tx_phy_preflop_0 [  20] = 1'b0                       ;
  assign tx_phy_preflop_0 [  21] = 1'b0                       ;
  assign tx_phy_preflop_0 [  22] = 1'b0                       ;
  assign tx_phy_preflop_0 [  23] = 1'b0                       ;
  assign tx_phy_preflop_0 [  24] = 1'b0                       ;
  assign tx_phy_preflop_0 [  25] = 1'b0                       ;
  assign tx_phy_preflop_0 [  26] = 1'b0                       ;
  assign tx_phy_preflop_0 [  27] = 1'b0                       ;
  assign tx_phy_preflop_0 [  28] = 1'b0                       ;
  assign tx_phy_preflop_0 [  29] = 1'b0                       ;
  assign tx_phy_preflop_0 [  30] = 1'b0                       ;
  assign tx_phy_preflop_0 [  31] = 1'b0                       ;
  assign tx_phy_preflop_0 [  32] = 1'b0                       ;
  assign tx_phy_preflop_0 [  33] = 1'b0                       ;
  assign tx_phy_preflop_0 [  34] = 1'b0                       ;
  assign tx_phy_preflop_0 [  35] = 1'b0                       ;
  assign tx_phy_preflop_0 [  36] = 1'b0                       ;
  assign tx_phy_preflop_0 [  37] = 1'b0                       ;
  assign tx_phy_preflop_0 [  38] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [  39] = 1'b0                       ; // DBI
  assign tx_phy_preflop_0 [  40] = 1'b0                       ;
  assign tx_phy_preflop_0 [  41] = 1'b0                       ;
  assign tx_phy_preflop_0 [  42] = 1'b0                       ;
  assign tx_phy_preflop_0 [  43] = 1'b0                       ;
  assign tx_phy_preflop_0 [  44] = 1'b0                       ;
  assign tx_phy_preflop_0 [  45] = 1'b0                       ;
  assign tx_phy_preflop_0 [  46] = 1'b0                       ;
  assign tx_phy_preflop_0 [  47] = 1'b0                       ;
  assign tx_phy_preflop_0 [  48] = 1'b0                       ;
  assign tx_phy_preflop_0 [  49] = 1'b0                       ;
  assign tx_phy_preflop_0 [  50] = 1'b0                       ;
  assign tx_phy_preflop_0 [  51] = 1'b0                       ;
  assign tx_phy_preflop_0 [  52] = 1'b0                       ;
  assign tx_phy_preflop_0 [  53] = 1'b0                       ;
  assign tx_phy_preflop_0 [  54] = 1'b0                       ;
  assign tx_phy_preflop_0 [  55] = 1'b0                       ;
  assign tx_phy_preflop_0 [  56] = 1'b0                       ;
  assign tx_phy_preflop_0 [  57] = 1'b0                       ;
  assign tx_phy_preflop_0 [  58] = 1'b0                       ;
  assign tx_phy_preflop_0 [  59] = 1'b0                       ;
  assign tx_phy_preflop_0 [  60] = 1'b0                       ;
  assign tx_phy_preflop_0 [  61] = 1'b0                       ;
  assign tx_phy_preflop_0 [  62] = 1'b0                       ;
  assign tx_phy_preflop_0 [  63] = 1'b0                       ;
  assign tx_phy_preflop_0 [  64] = 1'b0                       ;
  assign tx_phy_preflop_0 [  65] = 1'b0                       ;
  assign tx_phy_preflop_0 [  66] = 1'b0                       ;
  assign tx_phy_preflop_0 [  67] = 1'b0                       ;
  assign tx_phy_preflop_0 [  68] = 1'b0                       ;
  assign tx_phy_preflop_0 [  69] = 1'b0                       ;
  assign tx_phy_preflop_0 [  70] = 1'b0                       ;
  assign tx_phy_preflop_0 [  71] = 1'b0                       ;
  assign tx_phy_preflop_0 [  72] = 1'b0                       ;
  assign tx_phy_preflop_0 [  73] = 1'b0                       ;
  assign tx_phy_preflop_0 [  74] = 1'b0                       ;
  assign tx_phy_preflop_0 [  75] = 1'b0                       ;
  assign tx_phy_preflop_0 [  76] = 1'b0                       ;
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

  assign rx_st_pushbit              = rx_phy_postflop_0 [   0];
  assign rx_st_data          [   0] = rx_phy_postflop_0 [   1];
  assign rx_st_data          [   1] = rx_phy_postflop_0 [   2];
  assign rx_st_data          [   2] = rx_phy_postflop_0 [   3];
  assign rx_st_data          [   3] = rx_phy_postflop_0 [   4];
  assign rx_st_data          [   4] = rx_phy_postflop_0 [   5];
  assign rx_st_data          [   5] = rx_phy_postflop_0 [   6];
  assign rx_st_data          [   6] = rx_phy_postflop_0 [   7];
  assign rx_st_data          [   7] = rx_phy_postflop_0 [   8];
  assign rx_st_data          [   8] = rx_phy_postflop_0 [   9];
  assign rx_st_data          [   9] = rx_phy_postflop_0 [  10];
  assign rx_st_data          [  10] = rx_phy_postflop_0 [  11];
  assign rx_st_data          [  11] = rx_phy_postflop_0 [  12];
  assign rx_st_data          [  12] = rx_phy_postflop_0 [  13];
  assign rx_st_data          [  13] = rx_phy_postflop_0 [  14];
  assign rx_st_data          [  14] = rx_phy_postflop_0 [  15];
  assign rx_st_data          [  15] = rx_phy_postflop_0 [  16];
  assign rx_st_data          [  16] = rx_phy_postflop_0 [  17];
  assign rx_st_data          [  17] = rx_phy_postflop_0 [  18];
  assign rx_st_data          [  18] = rx_phy_postflop_0 [  19];
  assign rx_st_data          [  19] = rx_phy_postflop_0 [  20];
  assign rx_st_data          [  20] = rx_phy_postflop_0 [  21];
  assign rx_st_data          [  21] = rx_phy_postflop_0 [  22];
  assign rx_st_data          [  22] = rx_phy_postflop_0 [  23];
  assign rx_st_data          [  23] = rx_phy_postflop_0 [  24];
  assign rx_st_data          [  24] = rx_phy_postflop_0 [  25];
  assign rx_st_data          [  25] = rx_phy_postflop_0 [  26];
  assign rx_st_data          [  26] = rx_phy_postflop_0 [  27];
  assign rx_st_data          [  27] = rx_phy_postflop_0 [  28];
  assign rx_st_data          [  28] = rx_phy_postflop_0 [  29];
  assign rx_st_data          [  29] = rx_phy_postflop_0 [  30];
  assign rx_st_data          [  30] = rx_phy_postflop_0 [  31];
  assign rx_st_data          [  31] = rx_phy_postflop_0 [  32];
  assign rx_st_data          [  32] = rx_phy_postflop_0 [  33];
  assign rx_st_data          [  33] = rx_phy_postflop_0 [  34];
  assign rx_st_data          [  34] = rx_phy_postflop_0 [  35];
  assign rx_st_data          [  35] = rx_phy_postflop_0 [  36];
  assign rx_st_data          [  36] = rx_phy_postflop_0 [  37];
//       DBI                        = rx_phy_postflop_0 [  38];
//       DBI                        = rx_phy_postflop_0 [  39];
  assign rx_st_data          [  37] = rx_phy_postflop_0 [  40];
  assign rx_st_data          [  38] = rx_phy_postflop_0 [  41];
  assign rx_st_data          [  39] = rx_phy_postflop_0 [  42];
  assign rx_st_data          [  40] = rx_phy_postflop_0 [  43];
  assign rx_st_data          [  41] = rx_phy_postflop_0 [  44];
  assign rx_st_data          [  42] = rx_phy_postflop_0 [  45];
  assign rx_st_data          [  43] = rx_phy_postflop_0 [  46];
  assign rx_st_data          [  44] = rx_phy_postflop_0 [  47];
  assign rx_st_data          [  45] = rx_phy_postflop_0 [  48];
  assign rx_st_data          [  46] = rx_phy_postflop_0 [  49];
  assign rx_st_data          [  47] = rx_phy_postflop_0 [  50];
  assign rx_st_data          [  48] = rx_phy_postflop_0 [  51];
  assign rx_st_data          [  49] = rx_phy_postflop_0 [  52];
  assign rx_st_data          [  50] = rx_phy_postflop_0 [  53];
  assign rx_st_data          [  51] = rx_phy_postflop_0 [  54];
  assign rx_st_data          [  52] = rx_phy_postflop_0 [  55];
  assign rx_st_data          [  53] = rx_phy_postflop_0 [  56];
  assign rx_st_data          [  54] = rx_phy_postflop_0 [  57];
  assign rx_st_data          [  55] = rx_phy_postflop_0 [  58];
  assign rx_st_data          [  56] = rx_phy_postflop_0 [  59];
  assign rx_st_data          [  57] = rx_phy_postflop_0 [  60];
  assign rx_st_data          [  58] = rx_phy_postflop_0 [  61];
  assign rx_st_data          [  59] = rx_phy_postflop_0 [  62];
  assign rx_st_data          [  60] = rx_phy_postflop_0 [  63];
  assign rx_st_data          [  61] = rx_phy_postflop_0 [  64];
  assign rx_st_data          [  62] = rx_phy_postflop_0 [  65];
  assign rx_st_data          [  63] = rx_phy_postflop_0 [  66];
  assign rx_st_data          [  64] = rx_phy_postflop_0 [  67];
  assign rx_st_data          [  65] = rx_phy_postflop_0 [  68];
  assign rx_st_data          [  66] = rx_phy_postflop_0 [  69];
  assign rx_st_data          [  67] = rx_phy_postflop_0 [  70];
  assign rx_st_data          [  68] = rx_phy_postflop_0 [  71];
  assign rx_st_data          [  69] = rx_phy_postflop_0 [  72];
  assign rx_st_data          [  70] = rx_phy_postflop_0 [  73];
  assign rx_st_data          [  71] = rx_phy_postflop_0 [  74];
  assign rx_st_data          [  72] = rx_phy_postflop_0 [  75];
//       nc                         = rx_phy_postflop_0 [  76];
//       nc                         = rx_phy_postflop_0 [  77];
//       DBI                        = rx_phy_postflop_0 [  78];
//       DBI                        = rx_phy_postflop_0 [  79];

// RX Section
//////////////////////////////////////////////////////////////////


endmodule
