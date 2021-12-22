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

module lpif_txrx_x4_asym2_quarter_master_concat  (

// Data from Logic Links
  input  logic [ 307:   0]   tx_downstream_data  ,
  output logic               tx_downstream_pop_ovrd,

  output logic [ 307:   0]   rx_upstream_data    ,
  output logic               rx_upstream_push_ovrd,

// PHY Interconnect
  output logic [ 319:   0]   tx_phy0             ,
  input  logic [ 319:   0]   rx_phy0             ,

  input  logic               clk_wr              ,
  input  logic               clk_rd              ,
  input  logic               rst_wr_n            ,
  input  logic               rst_rd_n            ,

  input  logic               m_gen2_mode         ,
  input  logic               tx_online           ,

  input  logic               tx_stb_userbit      ,
  input  logic [   3:   0]   tx_mrk_userbit      

);

// No TX Packetization, so tie off packetization signals
  assign tx_downstream_pop_ovrd               = 1'b0                               ;

// No RX Packetization, so tie off packetization signals
  assign rx_upstream_push_ovrd               = 1'b0                               ;

//////////////////////////////////////////////////////////////////
// TX Section

//   TX_CH_WIDTH           = 320; // Gen2 running at Quarter Rate
//   TX_DATA_WIDTH         = 312; // Usable Data per Channel
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

  logic [ 319:   0]                              tx_phy_preflop_0              ;
  logic [ 319:   0]                              tx_phy_flop_0_reg             ;

  always_ff @(posedge clk_wr or negedge rst_wr_n)
  if (~rst_wr_n)
  begin
    tx_phy_flop_0_reg                       <= 320'b0                                  ;
  end
  else
  begin
    tx_phy_flop_0_reg                       <= tx_phy_preflop_0                        ;
  end

  assign tx_phy0                            = TX_REG_PHY ? tx_phy_flop_0_reg : tx_phy_preflop_0               ;

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
  assign tx_phy_preflop_0 [  79] = 1'b0                       ;
  assign tx_phy_preflop_0 [  80] = tx_downstream_data  [  77] ;
  assign tx_phy_preflop_0 [  81] = 1'b0                       ; // STROBE (unused)
  assign tx_phy_preflop_0 [  82] = tx_downstream_data  [  78] ;
  assign tx_phy_preflop_0 [  83] = tx_downstream_data  [  79] ;
  assign tx_phy_preflop_0 [  84] = tx_downstream_data  [  80] ;
  assign tx_phy_preflop_0 [  85] = tx_downstream_data  [  81] ;
  assign tx_phy_preflop_0 [  86] = tx_downstream_data  [  82] ;
  assign tx_phy_preflop_0 [  87] = tx_downstream_data  [  83] ;
  assign tx_phy_preflop_0 [  88] = tx_downstream_data  [  84] ;
  assign tx_phy_preflop_0 [  89] = tx_downstream_data  [  85] ;
  assign tx_phy_preflop_0 [  90] = tx_downstream_data  [  86] ;
  assign tx_phy_preflop_0 [  91] = tx_downstream_data  [  87] ;
  assign tx_phy_preflop_0 [  92] = tx_downstream_data  [  88] ;
  assign tx_phy_preflop_0 [  93] = tx_downstream_data  [  89] ;
  assign tx_phy_preflop_0 [  94] = tx_downstream_data  [  90] ;
  assign tx_phy_preflop_0 [  95] = tx_downstream_data  [  91] ;
  assign tx_phy_preflop_0 [  96] = tx_downstream_data  [  92] ;
  assign tx_phy_preflop_0 [  97] = tx_downstream_data  [  93] ;
  assign tx_phy_preflop_0 [  98] = tx_downstream_data  [  94] ;
  assign tx_phy_preflop_0 [  99] = tx_downstream_data  [  95] ;
  assign tx_phy_preflop_0 [ 100] = tx_downstream_data  [  96] ;
  assign tx_phy_preflop_0 [ 101] = tx_downstream_data  [  97] ;
  assign tx_phy_preflop_0 [ 102] = tx_downstream_data  [  98] ;
  assign tx_phy_preflop_0 [ 103] = tx_downstream_data  [  99] ;
  assign tx_phy_preflop_0 [ 104] = tx_downstream_data  [ 100] ;
  assign tx_phy_preflop_0 [ 105] = tx_downstream_data  [ 101] ;
  assign tx_phy_preflop_0 [ 106] = tx_downstream_data  [ 102] ;
  assign tx_phy_preflop_0 [ 107] = tx_downstream_data  [ 103] ;
  assign tx_phy_preflop_0 [ 108] = tx_downstream_data  [ 104] ;
  assign tx_phy_preflop_0 [ 109] = tx_downstream_data  [ 105] ;
  assign tx_phy_preflop_0 [ 110] = tx_downstream_data  [ 106] ;
  assign tx_phy_preflop_0 [ 111] = tx_downstream_data  [ 107] ;
  assign tx_phy_preflop_0 [ 112] = tx_downstream_data  [ 108] ;
  assign tx_phy_preflop_0 [ 113] = tx_downstream_data  [ 109] ;
  assign tx_phy_preflop_0 [ 114] = tx_downstream_data  [ 110] ;
  assign tx_phy_preflop_0 [ 115] = tx_downstream_data  [ 111] ;
  assign tx_phy_preflop_0 [ 116] = tx_downstream_data  [ 112] ;
  assign tx_phy_preflop_0 [ 117] = tx_downstream_data  [ 113] ;
  assign tx_phy_preflop_0 [ 118] = tx_downstream_data  [ 114] ;
  assign tx_phy_preflop_0 [ 119] = tx_downstream_data  [ 115] ;
  assign tx_phy_preflop_0 [ 120] = tx_downstream_data  [ 116] ;
  assign tx_phy_preflop_0 [ 121] = tx_downstream_data  [ 117] ;
  assign tx_phy_preflop_0 [ 122] = tx_downstream_data  [ 118] ;
  assign tx_phy_preflop_0 [ 123] = tx_downstream_data  [ 119] ;
  assign tx_phy_preflop_0 [ 124] = tx_downstream_data  [ 120] ;
  assign tx_phy_preflop_0 [ 125] = tx_downstream_data  [ 121] ;
  assign tx_phy_preflop_0 [ 126] = tx_downstream_data  [ 122] ;
  assign tx_phy_preflop_0 [ 127] = tx_downstream_data  [ 123] ;
  assign tx_phy_preflop_0 [ 128] = tx_downstream_data  [ 124] ;
  assign tx_phy_preflop_0 [ 129] = tx_downstream_data  [ 125] ;
  assign tx_phy_preflop_0 [ 130] = tx_downstream_data  [ 126] ;
  assign tx_phy_preflop_0 [ 131] = tx_downstream_data  [ 127] ;
  assign tx_phy_preflop_0 [ 132] = tx_downstream_data  [ 128] ;
  assign tx_phy_preflop_0 [ 133] = tx_downstream_data  [ 129] ;
  assign tx_phy_preflop_0 [ 134] = tx_downstream_data  [ 130] ;
  assign tx_phy_preflop_0 [ 135] = tx_downstream_data  [ 131] ;
  assign tx_phy_preflop_0 [ 136] = tx_downstream_data  [ 132] ;
  assign tx_phy_preflop_0 [ 137] = tx_downstream_data  [ 133] ;
  assign tx_phy_preflop_0 [ 138] = tx_downstream_data  [ 134] ;
  assign tx_phy_preflop_0 [ 139] = tx_downstream_data  [ 135] ;
  assign tx_phy_preflop_0 [ 140] = tx_downstream_data  [ 136] ;
  assign tx_phy_preflop_0 [ 141] = tx_downstream_data  [ 137] ;
  assign tx_phy_preflop_0 [ 142] = tx_downstream_data  [ 138] ;
  assign tx_phy_preflop_0 [ 143] = tx_downstream_data  [ 139] ;
  assign tx_phy_preflop_0 [ 144] = tx_downstream_data  [ 140] ;
  assign tx_phy_preflop_0 [ 145] = tx_downstream_data  [ 141] ;
  assign tx_phy_preflop_0 [ 146] = tx_downstream_data  [ 142] ;
  assign tx_phy_preflop_0 [ 147] = tx_downstream_data  [ 143] ;
  assign tx_phy_preflop_0 [ 148] = tx_downstream_data  [ 144] ;
  assign tx_phy_preflop_0 [ 149] = tx_downstream_data  [ 145] ;
  assign tx_phy_preflop_0 [ 150] = tx_downstream_data  [ 146] ;
  assign tx_phy_preflop_0 [ 151] = tx_downstream_data  [ 147] ;
  assign tx_phy_preflop_0 [ 152] = tx_downstream_data  [ 148] ;
  assign tx_phy_preflop_0 [ 153] = tx_downstream_data  [ 149] ;
  assign tx_phy_preflop_0 [ 154] = tx_downstream_data  [ 150] ;
  assign tx_phy_preflop_0 [ 155] = tx_downstream_data  [ 151] ;
  assign tx_phy_preflop_0 [ 156] = tx_downstream_data  [ 152] ;
  assign tx_phy_preflop_0 [ 157] = tx_mrk_userbit[1]          ; // MARKER
  assign tx_phy_preflop_0 [ 158] = tx_downstream_data  [ 153] ;
  assign tx_phy_preflop_0 [ 159] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 160] = tx_downstream_data  [ 154] ;
  assign tx_phy_preflop_0 [ 161] = 1'b0                       ; // STROBE (unused)
  assign tx_phy_preflop_0 [ 162] = tx_downstream_data  [ 155] ;
  assign tx_phy_preflop_0 [ 163] = tx_downstream_data  [ 156] ;
  assign tx_phy_preflop_0 [ 164] = tx_downstream_data  [ 157] ;
  assign tx_phy_preflop_0 [ 165] = tx_downstream_data  [ 158] ;
  assign tx_phy_preflop_0 [ 166] = tx_downstream_data  [ 159] ;
  assign tx_phy_preflop_0 [ 167] = tx_downstream_data  [ 160] ;
  assign tx_phy_preflop_0 [ 168] = tx_downstream_data  [ 161] ;
  assign tx_phy_preflop_0 [ 169] = tx_downstream_data  [ 162] ;
  assign tx_phy_preflop_0 [ 170] = tx_downstream_data  [ 163] ;
  assign tx_phy_preflop_0 [ 171] = tx_downstream_data  [ 164] ;
  assign tx_phy_preflop_0 [ 172] = tx_downstream_data  [ 165] ;
  assign tx_phy_preflop_0 [ 173] = tx_downstream_data  [ 166] ;
  assign tx_phy_preflop_0 [ 174] = tx_downstream_data  [ 167] ;
  assign tx_phy_preflop_0 [ 175] = tx_downstream_data  [ 168] ;
  assign tx_phy_preflop_0 [ 176] = tx_downstream_data  [ 169] ;
  assign tx_phy_preflop_0 [ 177] = tx_downstream_data  [ 170] ;
  assign tx_phy_preflop_0 [ 178] = tx_downstream_data  [ 171] ;
  assign tx_phy_preflop_0 [ 179] = tx_downstream_data  [ 172] ;
  assign tx_phy_preflop_0 [ 180] = tx_downstream_data  [ 173] ;
  assign tx_phy_preflop_0 [ 181] = tx_downstream_data  [ 174] ;
  assign tx_phy_preflop_0 [ 182] = tx_downstream_data  [ 175] ;
  assign tx_phy_preflop_0 [ 183] = tx_downstream_data  [ 176] ;
  assign tx_phy_preflop_0 [ 184] = tx_downstream_data  [ 177] ;
  assign tx_phy_preflop_0 [ 185] = tx_downstream_data  [ 178] ;
  assign tx_phy_preflop_0 [ 186] = tx_downstream_data  [ 179] ;
  assign tx_phy_preflop_0 [ 187] = tx_downstream_data  [ 180] ;
  assign tx_phy_preflop_0 [ 188] = tx_downstream_data  [ 181] ;
  assign tx_phy_preflop_0 [ 189] = tx_downstream_data  [ 182] ;
  assign tx_phy_preflop_0 [ 190] = tx_downstream_data  [ 183] ;
  assign tx_phy_preflop_0 [ 191] = tx_downstream_data  [ 184] ;
  assign tx_phy_preflop_0 [ 192] = tx_downstream_data  [ 185] ;
  assign tx_phy_preflop_0 [ 193] = tx_downstream_data  [ 186] ;
  assign tx_phy_preflop_0 [ 194] = tx_downstream_data  [ 187] ;
  assign tx_phy_preflop_0 [ 195] = tx_downstream_data  [ 188] ;
  assign tx_phy_preflop_0 [ 196] = tx_downstream_data  [ 189] ;
  assign tx_phy_preflop_0 [ 197] = tx_downstream_data  [ 190] ;
  assign tx_phy_preflop_0 [ 198] = tx_downstream_data  [ 191] ;
  assign tx_phy_preflop_0 [ 199] = tx_downstream_data  [ 192] ;
  assign tx_phy_preflop_0 [ 200] = tx_downstream_data  [ 193] ;
  assign tx_phy_preflop_0 [ 201] = tx_downstream_data  [ 194] ;
  assign tx_phy_preflop_0 [ 202] = tx_downstream_data  [ 195] ;
  assign tx_phy_preflop_0 [ 203] = tx_downstream_data  [ 196] ;
  assign tx_phy_preflop_0 [ 204] = tx_downstream_data  [ 197] ;
  assign tx_phy_preflop_0 [ 205] = tx_downstream_data  [ 198] ;
  assign tx_phy_preflop_0 [ 206] = tx_downstream_data  [ 199] ;
  assign tx_phy_preflop_0 [ 207] = tx_downstream_data  [ 200] ;
  assign tx_phy_preflop_0 [ 208] = tx_downstream_data  [ 201] ;
  assign tx_phy_preflop_0 [ 209] = tx_downstream_data  [ 202] ;
  assign tx_phy_preflop_0 [ 210] = tx_downstream_data  [ 203] ;
  assign tx_phy_preflop_0 [ 211] = tx_downstream_data  [ 204] ;
  assign tx_phy_preflop_0 [ 212] = tx_downstream_data  [ 205] ;
  assign tx_phy_preflop_0 [ 213] = tx_downstream_data  [ 206] ;
  assign tx_phy_preflop_0 [ 214] = tx_downstream_data  [ 207] ;
  assign tx_phy_preflop_0 [ 215] = tx_downstream_data  [ 208] ;
  assign tx_phy_preflop_0 [ 216] = tx_downstream_data  [ 209] ;
  assign tx_phy_preflop_0 [ 217] = tx_downstream_data  [ 210] ;
  assign tx_phy_preflop_0 [ 218] = tx_downstream_data  [ 211] ;
  assign tx_phy_preflop_0 [ 219] = tx_downstream_data  [ 212] ;
  assign tx_phy_preflop_0 [ 220] = tx_downstream_data  [ 213] ;
  assign tx_phy_preflop_0 [ 221] = tx_downstream_data  [ 214] ;
  assign tx_phy_preflop_0 [ 222] = tx_downstream_data  [ 215] ;
  assign tx_phy_preflop_0 [ 223] = tx_downstream_data  [ 216] ;
  assign tx_phy_preflop_0 [ 224] = tx_downstream_data  [ 217] ;
  assign tx_phy_preflop_0 [ 225] = tx_downstream_data  [ 218] ;
  assign tx_phy_preflop_0 [ 226] = tx_downstream_data  [ 219] ;
  assign tx_phy_preflop_0 [ 227] = tx_downstream_data  [ 220] ;
  assign tx_phy_preflop_0 [ 228] = tx_downstream_data  [ 221] ;
  assign tx_phy_preflop_0 [ 229] = tx_downstream_data  [ 222] ;
  assign tx_phy_preflop_0 [ 230] = tx_downstream_data  [ 223] ;
  assign tx_phy_preflop_0 [ 231] = tx_downstream_data  [ 224] ;
  assign tx_phy_preflop_0 [ 232] = tx_downstream_data  [ 225] ;
  assign tx_phy_preflop_0 [ 233] = tx_downstream_data  [ 226] ;
  assign tx_phy_preflop_0 [ 234] = tx_downstream_data  [ 227] ;
  assign tx_phy_preflop_0 [ 235] = tx_downstream_data  [ 228] ;
  assign tx_phy_preflop_0 [ 236] = tx_downstream_data  [ 229] ;
  assign tx_phy_preflop_0 [ 237] = tx_mrk_userbit[2]          ; // MARKER
  assign tx_phy_preflop_0 [ 238] = tx_downstream_data  [ 230] ;
  assign tx_phy_preflop_0 [ 239] = 1'b0                       ;
  assign tx_phy_preflop_0 [ 240] = tx_downstream_data  [ 231] ;
  assign tx_phy_preflop_0 [ 241] = 1'b0                       ; // STROBE (unused)
  assign tx_phy_preflop_0 [ 242] = tx_downstream_data  [ 232] ;
  assign tx_phy_preflop_0 [ 243] = tx_downstream_data  [ 233] ;
  assign tx_phy_preflop_0 [ 244] = tx_downstream_data  [ 234] ;
  assign tx_phy_preflop_0 [ 245] = tx_downstream_data  [ 235] ;
  assign tx_phy_preflop_0 [ 246] = tx_downstream_data  [ 236] ;
  assign tx_phy_preflop_0 [ 247] = tx_downstream_data  [ 237] ;
  assign tx_phy_preflop_0 [ 248] = tx_downstream_data  [ 238] ;
  assign tx_phy_preflop_0 [ 249] = tx_downstream_data  [ 239] ;
  assign tx_phy_preflop_0 [ 250] = tx_downstream_data  [ 240] ;
  assign tx_phy_preflop_0 [ 251] = tx_downstream_data  [ 241] ;
  assign tx_phy_preflop_0 [ 252] = tx_downstream_data  [ 242] ;
  assign tx_phy_preflop_0 [ 253] = tx_downstream_data  [ 243] ;
  assign tx_phy_preflop_0 [ 254] = tx_downstream_data  [ 244] ;
  assign tx_phy_preflop_0 [ 255] = tx_downstream_data  [ 245] ;
  assign tx_phy_preflop_0 [ 256] = tx_downstream_data  [ 246] ;
  assign tx_phy_preflop_0 [ 257] = tx_downstream_data  [ 247] ;
  assign tx_phy_preflop_0 [ 258] = tx_downstream_data  [ 248] ;
  assign tx_phy_preflop_0 [ 259] = tx_downstream_data  [ 249] ;
  assign tx_phy_preflop_0 [ 260] = tx_downstream_data  [ 250] ;
  assign tx_phy_preflop_0 [ 261] = tx_downstream_data  [ 251] ;
  assign tx_phy_preflop_0 [ 262] = tx_downstream_data  [ 252] ;
  assign tx_phy_preflop_0 [ 263] = tx_downstream_data  [ 253] ;
  assign tx_phy_preflop_0 [ 264] = tx_downstream_data  [ 254] ;
  assign tx_phy_preflop_0 [ 265] = tx_downstream_data  [ 255] ;
  assign tx_phy_preflop_0 [ 266] = tx_downstream_data  [ 256] ;
  assign tx_phy_preflop_0 [ 267] = tx_downstream_data  [ 257] ;
  assign tx_phy_preflop_0 [ 268] = tx_downstream_data  [ 258] ;
  assign tx_phy_preflop_0 [ 269] = tx_downstream_data  [ 259] ;
  assign tx_phy_preflop_0 [ 270] = tx_downstream_data  [ 260] ;
  assign tx_phy_preflop_0 [ 271] = tx_downstream_data  [ 261] ;
  assign tx_phy_preflop_0 [ 272] = tx_downstream_data  [ 262] ;
  assign tx_phy_preflop_0 [ 273] = tx_downstream_data  [ 263] ;
  assign tx_phy_preflop_0 [ 274] = tx_downstream_data  [ 264] ;
  assign tx_phy_preflop_0 [ 275] = tx_downstream_data  [ 265] ;
  assign tx_phy_preflop_0 [ 276] = tx_downstream_data  [ 266] ;
  assign tx_phy_preflop_0 [ 277] = tx_downstream_data  [ 267] ;
  assign tx_phy_preflop_0 [ 278] = tx_downstream_data  [ 268] ;
  assign tx_phy_preflop_0 [ 279] = tx_downstream_data  [ 269] ;
  assign tx_phy_preflop_0 [ 280] = tx_downstream_data  [ 270] ;
  assign tx_phy_preflop_0 [ 281] = tx_downstream_data  [ 271] ;
  assign tx_phy_preflop_0 [ 282] = tx_downstream_data  [ 272] ;
  assign tx_phy_preflop_0 [ 283] = tx_downstream_data  [ 273] ;
  assign tx_phy_preflop_0 [ 284] = tx_downstream_data  [ 274] ;
  assign tx_phy_preflop_0 [ 285] = tx_downstream_data  [ 275] ;
  assign tx_phy_preflop_0 [ 286] = tx_downstream_data  [ 276] ;
  assign tx_phy_preflop_0 [ 287] = tx_downstream_data  [ 277] ;
  assign tx_phy_preflop_0 [ 288] = tx_downstream_data  [ 278] ;
  assign tx_phy_preflop_0 [ 289] = tx_downstream_data  [ 279] ;
  assign tx_phy_preflop_0 [ 290] = tx_downstream_data  [ 280] ;
  assign tx_phy_preflop_0 [ 291] = tx_downstream_data  [ 281] ;
  assign tx_phy_preflop_0 [ 292] = tx_downstream_data  [ 282] ;
  assign tx_phy_preflop_0 [ 293] = tx_downstream_data  [ 283] ;
  assign tx_phy_preflop_0 [ 294] = tx_downstream_data  [ 284] ;
  assign tx_phy_preflop_0 [ 295] = tx_downstream_data  [ 285] ;
  assign tx_phy_preflop_0 [ 296] = tx_downstream_data  [ 286] ;
  assign tx_phy_preflop_0 [ 297] = tx_downstream_data  [ 287] ;
  assign tx_phy_preflop_0 [ 298] = tx_downstream_data  [ 288] ;
  assign tx_phy_preflop_0 [ 299] = tx_downstream_data  [ 289] ;
  assign tx_phy_preflop_0 [ 300] = tx_downstream_data  [ 290] ;
  assign tx_phy_preflop_0 [ 301] = tx_downstream_data  [ 291] ;
  assign tx_phy_preflop_0 [ 302] = tx_downstream_data  [ 292] ;
  assign tx_phy_preflop_0 [ 303] = tx_downstream_data  [ 293] ;
  assign tx_phy_preflop_0 [ 304] = tx_downstream_data  [ 294] ;
  assign tx_phy_preflop_0 [ 305] = tx_downstream_data  [ 295] ;
  assign tx_phy_preflop_0 [ 306] = tx_downstream_data  [ 296] ;
  assign tx_phy_preflop_0 [ 307] = tx_downstream_data  [ 297] ;
  assign tx_phy_preflop_0 [ 308] = tx_downstream_data  [ 298] ;
  assign tx_phy_preflop_0 [ 309] = tx_downstream_data  [ 299] ;
  assign tx_phy_preflop_0 [ 310] = tx_downstream_data  [ 300] ;
  assign tx_phy_preflop_0 [ 311] = tx_downstream_data  [ 301] ;
  assign tx_phy_preflop_0 [ 312] = tx_downstream_data  [ 302] ;
  assign tx_phy_preflop_0 [ 313] = tx_downstream_data  [ 303] ;
  assign tx_phy_preflop_0 [ 314] = tx_downstream_data  [ 304] ;
  assign tx_phy_preflop_0 [ 315] = tx_downstream_data  [ 305] ;
  assign tx_phy_preflop_0 [ 316] = tx_downstream_data  [ 306] ;
  assign tx_phy_preflop_0 [ 317] = tx_mrk_userbit[3]          ; // MARKER
  assign tx_phy_preflop_0 [ 318] = tx_downstream_data  [ 307] ;
  assign tx_phy_preflop_0 [ 319] = 1'b0                       ;
// TX Section
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// RX Section

//   RX_CH_WIDTH           = 320; // Gen2 running at Quarter Rate
//   RX_DATA_WIDTH         = 312; // Usable Data per Channel
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

  logic [ 319:   0]                              rx_phy_postflop_0             ;
  logic [ 319:   0]                              rx_phy_flop_0_reg             ;

  always_ff @(posedge clk_rd or negedge rst_rd_n)
  if (~rst_rd_n)
  begin
    rx_phy_flop_0_reg                       <= 320'b0                                  ;
  end
  else
  begin
    rx_phy_flop_0_reg                       <= rx_phy0                                 ;
  end


  assign rx_phy_postflop_0                  = RX_REG_PHY ? rx_phy_flop_0_reg : rx_phy0               ;

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
//       nc                         = rx_phy_postflop_0 [  79];
  assign rx_upstream_data    [  77] = rx_phy_postflop_0 [  80];
//       STROBE                     = rx_phy_postflop_0 [  81]
  assign rx_upstream_data    [  78] = rx_phy_postflop_0 [  82];
  assign rx_upstream_data    [  79] = rx_phy_postflop_0 [  83];
  assign rx_upstream_data    [  80] = rx_phy_postflop_0 [  84];
  assign rx_upstream_data    [  81] = rx_phy_postflop_0 [  85];
  assign rx_upstream_data    [  82] = rx_phy_postflop_0 [  86];
  assign rx_upstream_data    [  83] = rx_phy_postflop_0 [  87];
  assign rx_upstream_data    [  84] = rx_phy_postflop_0 [  88];
  assign rx_upstream_data    [  85] = rx_phy_postflop_0 [  89];
  assign rx_upstream_data    [  86] = rx_phy_postflop_0 [  90];
  assign rx_upstream_data    [  87] = rx_phy_postflop_0 [  91];
  assign rx_upstream_data    [  88] = rx_phy_postflop_0 [  92];
  assign rx_upstream_data    [  89] = rx_phy_postflop_0 [  93];
  assign rx_upstream_data    [  90] = rx_phy_postflop_0 [  94];
  assign rx_upstream_data    [  91] = rx_phy_postflop_0 [  95];
  assign rx_upstream_data    [  92] = rx_phy_postflop_0 [  96];
  assign rx_upstream_data    [  93] = rx_phy_postflop_0 [  97];
  assign rx_upstream_data    [  94] = rx_phy_postflop_0 [  98];
  assign rx_upstream_data    [  95] = rx_phy_postflop_0 [  99];
  assign rx_upstream_data    [  96] = rx_phy_postflop_0 [ 100];
  assign rx_upstream_data    [  97] = rx_phy_postflop_0 [ 101];
  assign rx_upstream_data    [  98] = rx_phy_postflop_0 [ 102];
  assign rx_upstream_data    [  99] = rx_phy_postflop_0 [ 103];
  assign rx_upstream_data    [ 100] = rx_phy_postflop_0 [ 104];
  assign rx_upstream_data    [ 101] = rx_phy_postflop_0 [ 105];
  assign rx_upstream_data    [ 102] = rx_phy_postflop_0 [ 106];
  assign rx_upstream_data    [ 103] = rx_phy_postflop_0 [ 107];
  assign rx_upstream_data    [ 104] = rx_phy_postflop_0 [ 108];
  assign rx_upstream_data    [ 105] = rx_phy_postflop_0 [ 109];
  assign rx_upstream_data    [ 106] = rx_phy_postflop_0 [ 110];
  assign rx_upstream_data    [ 107] = rx_phy_postflop_0 [ 111];
  assign rx_upstream_data    [ 108] = rx_phy_postflop_0 [ 112];
  assign rx_upstream_data    [ 109] = rx_phy_postflop_0 [ 113];
  assign rx_upstream_data    [ 110] = rx_phy_postflop_0 [ 114];
  assign rx_upstream_data    [ 111] = rx_phy_postflop_0 [ 115];
  assign rx_upstream_data    [ 112] = rx_phy_postflop_0 [ 116];
  assign rx_upstream_data    [ 113] = rx_phy_postflop_0 [ 117];
  assign rx_upstream_data    [ 114] = rx_phy_postflop_0 [ 118];
  assign rx_upstream_data    [ 115] = rx_phy_postflop_0 [ 119];
  assign rx_upstream_data    [ 116] = rx_phy_postflop_0 [ 120];
  assign rx_upstream_data    [ 117] = rx_phy_postflop_0 [ 121];
  assign rx_upstream_data    [ 118] = rx_phy_postflop_0 [ 122];
  assign rx_upstream_data    [ 119] = rx_phy_postflop_0 [ 123];
  assign rx_upstream_data    [ 120] = rx_phy_postflop_0 [ 124];
  assign rx_upstream_data    [ 121] = rx_phy_postflop_0 [ 125];
  assign rx_upstream_data    [ 122] = rx_phy_postflop_0 [ 126];
  assign rx_upstream_data    [ 123] = rx_phy_postflop_0 [ 127];
  assign rx_upstream_data    [ 124] = rx_phy_postflop_0 [ 128];
  assign rx_upstream_data    [ 125] = rx_phy_postflop_0 [ 129];
  assign rx_upstream_data    [ 126] = rx_phy_postflop_0 [ 130];
  assign rx_upstream_data    [ 127] = rx_phy_postflop_0 [ 131];
  assign rx_upstream_data    [ 128] = rx_phy_postflop_0 [ 132];
  assign rx_upstream_data    [ 129] = rx_phy_postflop_0 [ 133];
  assign rx_upstream_data    [ 130] = rx_phy_postflop_0 [ 134];
  assign rx_upstream_data    [ 131] = rx_phy_postflop_0 [ 135];
  assign rx_upstream_data    [ 132] = rx_phy_postflop_0 [ 136];
  assign rx_upstream_data    [ 133] = rx_phy_postflop_0 [ 137];
  assign rx_upstream_data    [ 134] = rx_phy_postflop_0 [ 138];
  assign rx_upstream_data    [ 135] = rx_phy_postflop_0 [ 139];
  assign rx_upstream_data    [ 136] = rx_phy_postflop_0 [ 140];
  assign rx_upstream_data    [ 137] = rx_phy_postflop_0 [ 141];
  assign rx_upstream_data    [ 138] = rx_phy_postflop_0 [ 142];
  assign rx_upstream_data    [ 139] = rx_phy_postflop_0 [ 143];
  assign rx_upstream_data    [ 140] = rx_phy_postflop_0 [ 144];
  assign rx_upstream_data    [ 141] = rx_phy_postflop_0 [ 145];
  assign rx_upstream_data    [ 142] = rx_phy_postflop_0 [ 146];
  assign rx_upstream_data    [ 143] = rx_phy_postflop_0 [ 147];
  assign rx_upstream_data    [ 144] = rx_phy_postflop_0 [ 148];
  assign rx_upstream_data    [ 145] = rx_phy_postflop_0 [ 149];
  assign rx_upstream_data    [ 146] = rx_phy_postflop_0 [ 150];
  assign rx_upstream_data    [ 147] = rx_phy_postflop_0 [ 151];
  assign rx_upstream_data    [ 148] = rx_phy_postflop_0 [ 152];
  assign rx_upstream_data    [ 149] = rx_phy_postflop_0 [ 153];
  assign rx_upstream_data    [ 150] = rx_phy_postflop_0 [ 154];
  assign rx_upstream_data    [ 151] = rx_phy_postflop_0 [ 155];
  assign rx_upstream_data    [ 152] = rx_phy_postflop_0 [ 156];
//       MARKER                     = rx_phy_postflop_0 [ 157]
  assign rx_upstream_data    [ 153] = rx_phy_postflop_0 [ 158];
//       nc                         = rx_phy_postflop_0 [ 159];
  assign rx_upstream_data    [ 154] = rx_phy_postflop_0 [ 160];
//       STROBE                     = rx_phy_postflop_0 [ 161]
  assign rx_upstream_data    [ 155] = rx_phy_postflop_0 [ 162];
  assign rx_upstream_data    [ 156] = rx_phy_postflop_0 [ 163];
  assign rx_upstream_data    [ 157] = rx_phy_postflop_0 [ 164];
  assign rx_upstream_data    [ 158] = rx_phy_postflop_0 [ 165];
  assign rx_upstream_data    [ 159] = rx_phy_postflop_0 [ 166];
  assign rx_upstream_data    [ 160] = rx_phy_postflop_0 [ 167];
  assign rx_upstream_data    [ 161] = rx_phy_postflop_0 [ 168];
  assign rx_upstream_data    [ 162] = rx_phy_postflop_0 [ 169];
  assign rx_upstream_data    [ 163] = rx_phy_postflop_0 [ 170];
  assign rx_upstream_data    [ 164] = rx_phy_postflop_0 [ 171];
  assign rx_upstream_data    [ 165] = rx_phy_postflop_0 [ 172];
  assign rx_upstream_data    [ 166] = rx_phy_postflop_0 [ 173];
  assign rx_upstream_data    [ 167] = rx_phy_postflop_0 [ 174];
  assign rx_upstream_data    [ 168] = rx_phy_postflop_0 [ 175];
  assign rx_upstream_data    [ 169] = rx_phy_postflop_0 [ 176];
  assign rx_upstream_data    [ 170] = rx_phy_postflop_0 [ 177];
  assign rx_upstream_data    [ 171] = rx_phy_postflop_0 [ 178];
  assign rx_upstream_data    [ 172] = rx_phy_postflop_0 [ 179];
  assign rx_upstream_data    [ 173] = rx_phy_postflop_0 [ 180];
  assign rx_upstream_data    [ 174] = rx_phy_postflop_0 [ 181];
  assign rx_upstream_data    [ 175] = rx_phy_postflop_0 [ 182];
  assign rx_upstream_data    [ 176] = rx_phy_postflop_0 [ 183];
  assign rx_upstream_data    [ 177] = rx_phy_postflop_0 [ 184];
  assign rx_upstream_data    [ 178] = rx_phy_postflop_0 [ 185];
  assign rx_upstream_data    [ 179] = rx_phy_postflop_0 [ 186];
  assign rx_upstream_data    [ 180] = rx_phy_postflop_0 [ 187];
  assign rx_upstream_data    [ 181] = rx_phy_postflop_0 [ 188];
  assign rx_upstream_data    [ 182] = rx_phy_postflop_0 [ 189];
  assign rx_upstream_data    [ 183] = rx_phy_postflop_0 [ 190];
  assign rx_upstream_data    [ 184] = rx_phy_postflop_0 [ 191];
  assign rx_upstream_data    [ 185] = rx_phy_postflop_0 [ 192];
  assign rx_upstream_data    [ 186] = rx_phy_postflop_0 [ 193];
  assign rx_upstream_data    [ 187] = rx_phy_postflop_0 [ 194];
  assign rx_upstream_data    [ 188] = rx_phy_postflop_0 [ 195];
  assign rx_upstream_data    [ 189] = rx_phy_postflop_0 [ 196];
  assign rx_upstream_data    [ 190] = rx_phy_postflop_0 [ 197];
  assign rx_upstream_data    [ 191] = rx_phy_postflop_0 [ 198];
  assign rx_upstream_data    [ 192] = rx_phy_postflop_0 [ 199];
  assign rx_upstream_data    [ 193] = rx_phy_postflop_0 [ 200];
  assign rx_upstream_data    [ 194] = rx_phy_postflop_0 [ 201];
  assign rx_upstream_data    [ 195] = rx_phy_postflop_0 [ 202];
  assign rx_upstream_data    [ 196] = rx_phy_postflop_0 [ 203];
  assign rx_upstream_data    [ 197] = rx_phy_postflop_0 [ 204];
  assign rx_upstream_data    [ 198] = rx_phy_postflop_0 [ 205];
  assign rx_upstream_data    [ 199] = rx_phy_postflop_0 [ 206];
  assign rx_upstream_data    [ 200] = rx_phy_postflop_0 [ 207];
  assign rx_upstream_data    [ 201] = rx_phy_postflop_0 [ 208];
  assign rx_upstream_data    [ 202] = rx_phy_postflop_0 [ 209];
  assign rx_upstream_data    [ 203] = rx_phy_postflop_0 [ 210];
  assign rx_upstream_data    [ 204] = rx_phy_postflop_0 [ 211];
  assign rx_upstream_data    [ 205] = rx_phy_postflop_0 [ 212];
  assign rx_upstream_data    [ 206] = rx_phy_postflop_0 [ 213];
  assign rx_upstream_data    [ 207] = rx_phy_postflop_0 [ 214];
  assign rx_upstream_data    [ 208] = rx_phy_postflop_0 [ 215];
  assign rx_upstream_data    [ 209] = rx_phy_postflop_0 [ 216];
  assign rx_upstream_data    [ 210] = rx_phy_postflop_0 [ 217];
  assign rx_upstream_data    [ 211] = rx_phy_postflop_0 [ 218];
  assign rx_upstream_data    [ 212] = rx_phy_postflop_0 [ 219];
  assign rx_upstream_data    [ 213] = rx_phy_postflop_0 [ 220];
  assign rx_upstream_data    [ 214] = rx_phy_postflop_0 [ 221];
  assign rx_upstream_data    [ 215] = rx_phy_postflop_0 [ 222];
  assign rx_upstream_data    [ 216] = rx_phy_postflop_0 [ 223];
  assign rx_upstream_data    [ 217] = rx_phy_postflop_0 [ 224];
  assign rx_upstream_data    [ 218] = rx_phy_postflop_0 [ 225];
  assign rx_upstream_data    [ 219] = rx_phy_postflop_0 [ 226];
  assign rx_upstream_data    [ 220] = rx_phy_postflop_0 [ 227];
  assign rx_upstream_data    [ 221] = rx_phy_postflop_0 [ 228];
  assign rx_upstream_data    [ 222] = rx_phy_postflop_0 [ 229];
  assign rx_upstream_data    [ 223] = rx_phy_postflop_0 [ 230];
  assign rx_upstream_data    [ 224] = rx_phy_postflop_0 [ 231];
  assign rx_upstream_data    [ 225] = rx_phy_postflop_0 [ 232];
  assign rx_upstream_data    [ 226] = rx_phy_postflop_0 [ 233];
  assign rx_upstream_data    [ 227] = rx_phy_postflop_0 [ 234];
  assign rx_upstream_data    [ 228] = rx_phy_postflop_0 [ 235];
  assign rx_upstream_data    [ 229] = rx_phy_postflop_0 [ 236];
//       MARKER                     = rx_phy_postflop_0 [ 237]
  assign rx_upstream_data    [ 230] = rx_phy_postflop_0 [ 238];
//       nc                         = rx_phy_postflop_0 [ 239];
  assign rx_upstream_data    [ 231] = rx_phy_postflop_0 [ 240];
//       STROBE                     = rx_phy_postflop_0 [ 241]
  assign rx_upstream_data    [ 232] = rx_phy_postflop_0 [ 242];
  assign rx_upstream_data    [ 233] = rx_phy_postflop_0 [ 243];
  assign rx_upstream_data    [ 234] = rx_phy_postflop_0 [ 244];
  assign rx_upstream_data    [ 235] = rx_phy_postflop_0 [ 245];
  assign rx_upstream_data    [ 236] = rx_phy_postflop_0 [ 246];
  assign rx_upstream_data    [ 237] = rx_phy_postflop_0 [ 247];
  assign rx_upstream_data    [ 238] = rx_phy_postflop_0 [ 248];
  assign rx_upstream_data    [ 239] = rx_phy_postflop_0 [ 249];
  assign rx_upstream_data    [ 240] = rx_phy_postflop_0 [ 250];
  assign rx_upstream_data    [ 241] = rx_phy_postflop_0 [ 251];
  assign rx_upstream_data    [ 242] = rx_phy_postflop_0 [ 252];
  assign rx_upstream_data    [ 243] = rx_phy_postflop_0 [ 253];
  assign rx_upstream_data    [ 244] = rx_phy_postflop_0 [ 254];
  assign rx_upstream_data    [ 245] = rx_phy_postflop_0 [ 255];
  assign rx_upstream_data    [ 246] = rx_phy_postflop_0 [ 256];
  assign rx_upstream_data    [ 247] = rx_phy_postflop_0 [ 257];
  assign rx_upstream_data    [ 248] = rx_phy_postflop_0 [ 258];
  assign rx_upstream_data    [ 249] = rx_phy_postflop_0 [ 259];
  assign rx_upstream_data    [ 250] = rx_phy_postflop_0 [ 260];
  assign rx_upstream_data    [ 251] = rx_phy_postflop_0 [ 261];
  assign rx_upstream_data    [ 252] = rx_phy_postflop_0 [ 262];
  assign rx_upstream_data    [ 253] = rx_phy_postflop_0 [ 263];
  assign rx_upstream_data    [ 254] = rx_phy_postflop_0 [ 264];
  assign rx_upstream_data    [ 255] = rx_phy_postflop_0 [ 265];
  assign rx_upstream_data    [ 256] = rx_phy_postflop_0 [ 266];
  assign rx_upstream_data    [ 257] = rx_phy_postflop_0 [ 267];
  assign rx_upstream_data    [ 258] = rx_phy_postflop_0 [ 268];
  assign rx_upstream_data    [ 259] = rx_phy_postflop_0 [ 269];
  assign rx_upstream_data    [ 260] = rx_phy_postflop_0 [ 270];
  assign rx_upstream_data    [ 261] = rx_phy_postflop_0 [ 271];
  assign rx_upstream_data    [ 262] = rx_phy_postflop_0 [ 272];
  assign rx_upstream_data    [ 263] = rx_phy_postflop_0 [ 273];
  assign rx_upstream_data    [ 264] = rx_phy_postflop_0 [ 274];
  assign rx_upstream_data    [ 265] = rx_phy_postflop_0 [ 275];
  assign rx_upstream_data    [ 266] = rx_phy_postflop_0 [ 276];
  assign rx_upstream_data    [ 267] = rx_phy_postflop_0 [ 277];
  assign rx_upstream_data    [ 268] = rx_phy_postflop_0 [ 278];
  assign rx_upstream_data    [ 269] = rx_phy_postflop_0 [ 279];
  assign rx_upstream_data    [ 270] = rx_phy_postflop_0 [ 280];
  assign rx_upstream_data    [ 271] = rx_phy_postflop_0 [ 281];
  assign rx_upstream_data    [ 272] = rx_phy_postflop_0 [ 282];
  assign rx_upstream_data    [ 273] = rx_phy_postflop_0 [ 283];
  assign rx_upstream_data    [ 274] = rx_phy_postflop_0 [ 284];
  assign rx_upstream_data    [ 275] = rx_phy_postflop_0 [ 285];
  assign rx_upstream_data    [ 276] = rx_phy_postflop_0 [ 286];
  assign rx_upstream_data    [ 277] = rx_phy_postflop_0 [ 287];
  assign rx_upstream_data    [ 278] = rx_phy_postflop_0 [ 288];
  assign rx_upstream_data    [ 279] = rx_phy_postflop_0 [ 289];
  assign rx_upstream_data    [ 280] = rx_phy_postflop_0 [ 290];
  assign rx_upstream_data    [ 281] = rx_phy_postflop_0 [ 291];
  assign rx_upstream_data    [ 282] = rx_phy_postflop_0 [ 292];
  assign rx_upstream_data    [ 283] = rx_phy_postflop_0 [ 293];
  assign rx_upstream_data    [ 284] = rx_phy_postflop_0 [ 294];
  assign rx_upstream_data    [ 285] = rx_phy_postflop_0 [ 295];
  assign rx_upstream_data    [ 286] = rx_phy_postflop_0 [ 296];
  assign rx_upstream_data    [ 287] = rx_phy_postflop_0 [ 297];
  assign rx_upstream_data    [ 288] = rx_phy_postflop_0 [ 298];
  assign rx_upstream_data    [ 289] = rx_phy_postflop_0 [ 299];
  assign rx_upstream_data    [ 290] = rx_phy_postflop_0 [ 300];
  assign rx_upstream_data    [ 291] = rx_phy_postflop_0 [ 301];
  assign rx_upstream_data    [ 292] = rx_phy_postflop_0 [ 302];
  assign rx_upstream_data    [ 293] = rx_phy_postflop_0 [ 303];
  assign rx_upstream_data    [ 294] = rx_phy_postflop_0 [ 304];
  assign rx_upstream_data    [ 295] = rx_phy_postflop_0 [ 305];
  assign rx_upstream_data    [ 296] = rx_phy_postflop_0 [ 306];
  assign rx_upstream_data    [ 297] = rx_phy_postflop_0 [ 307];
  assign rx_upstream_data    [ 298] = rx_phy_postflop_0 [ 308];
  assign rx_upstream_data    [ 299] = rx_phy_postflop_0 [ 309];
  assign rx_upstream_data    [ 300] = rx_phy_postflop_0 [ 310];
  assign rx_upstream_data    [ 301] = rx_phy_postflop_0 [ 311];
  assign rx_upstream_data    [ 302] = rx_phy_postflop_0 [ 312];
  assign rx_upstream_data    [ 303] = rx_phy_postflop_0 [ 313];
  assign rx_upstream_data    [ 304] = rx_phy_postflop_0 [ 314];
  assign rx_upstream_data    [ 305] = rx_phy_postflop_0 [ 315];
  assign rx_upstream_data    [ 306] = rx_phy_postflop_0 [ 316];
//       MARKER                     = rx_phy_postflop_0 [ 317]
  assign rx_upstream_data    [ 307] = rx_phy_postflop_0 [ 318];
//       nc                         = rx_phy_postflop_0 [ 319];

// RX Section
//////////////////////////////////////////////////////////////////


endmodule
