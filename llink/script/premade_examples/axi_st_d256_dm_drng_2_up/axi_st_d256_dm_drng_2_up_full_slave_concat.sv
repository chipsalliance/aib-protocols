////////////////////////////////////////////////////////////
//
//        Copyright (C) 2021 Eximius Design
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

module axi_st_d256_dm_drng_2_up_full_slave_concat  (

// Data from Logic Links
  output logic [ 256:   0]   rx_st_data          ,
  output logic               rx_st_push_ovrd     ,
  output logic               rx_st_pushbit       ,
  input  logic [   3:   0]   tx_st_credit        ,

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

//   TX_CH_WIDTH           = 40; // Gen1Only running at Full Rate
//   TX_DATA_WIDTH         = 40; // Usable Data per Channel
//   TX_PERSISTENT_STROBE  = 1'b0;
//   TX_PERSISTENT_MARKER  = 1'b0;
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
  logic [  39:   0]                              tx_phy_preflop_recov_strobe_0 ;
  logic [  39:   0]                              tx_phy_preflop_recov_strobe_1 ;
  logic [  39:   0]                              tx_phy_preflop_recov_strobe_2 ;
  logic [  39:   0]                              tx_phy_preflop_recov_strobe_3 ;
  logic [  39:   0]                              tx_phy_preflop_recov_strobe_4 ;
  logic [  39:   0]                              tx_phy_preflop_recov_strobe_5 ;
  logic [  39:   0]                              tx_phy_preflop_recov_strobe_6 ;
  logic [  39:   0]                              tx_phy_preflop_recov_marker_0 ;
  logic [  39:   0]                              tx_phy_preflop_recov_marker_1 ;
  logic [  39:   0]                              tx_phy_preflop_recov_marker_2 ;
  logic [  39:   0]                              tx_phy_preflop_recov_marker_3 ;
  logic [  39:   0]                              tx_phy_preflop_recov_marker_4 ;
  logic [  39:   0]                              tx_phy_preflop_recov_marker_5 ;
  logic [  39:   0]                              tx_phy_preflop_recov_marker_6 ;
  logic [  39:   0]                              tx_phy_flop_0_reg             ;
  logic [  39:   0]                              tx_phy_flop_1_reg             ;
  logic [  39:   0]                              tx_phy_flop_2_reg             ;
  logic [  39:   0]                              tx_phy_flop_3_reg             ;
  logic [  39:   0]                              tx_phy_flop_4_reg             ;
  logic [  39:   0]                              tx_phy_flop_5_reg             ;
  logic [  39:   0]                              tx_phy_flop_6_reg             ;

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
  end
  else
  begin
    tx_phy_flop_0_reg                       <= tx_phy_preflop_recov_marker_0               ;
    tx_phy_flop_1_reg                       <= tx_phy_preflop_recov_marker_1               ;
    tx_phy_flop_2_reg                       <= tx_phy_preflop_recov_marker_2               ;
    tx_phy_flop_3_reg                       <= tx_phy_preflop_recov_marker_3               ;
    tx_phy_flop_4_reg                       <= tx_phy_preflop_recov_marker_4               ;
    tx_phy_flop_5_reg                       <= tx_phy_preflop_recov_marker_5               ;
    tx_phy_flop_6_reg                       <= tx_phy_preflop_recov_marker_6               ;
  end

  assign tx_phy0                            = TX_REG_PHY ? tx_phy_flop_0_reg : tx_phy_preflop_recov_marker_0               ;
  assign tx_phy1                            = TX_REG_PHY ? tx_phy_flop_1_reg : tx_phy_preflop_recov_marker_1               ;
  assign tx_phy2                            = TX_REG_PHY ? tx_phy_flop_2_reg : tx_phy_preflop_recov_marker_2               ;
  assign tx_phy3                            = TX_REG_PHY ? tx_phy_flop_3_reg : tx_phy_preflop_recov_marker_3               ;
  assign tx_phy4                            = TX_REG_PHY ? tx_phy_flop_4_reg : tx_phy_preflop_recov_marker_4               ;
  assign tx_phy5                            = TX_REG_PHY ? tx_phy_flop_5_reg : tx_phy_preflop_recov_marker_5               ;
  assign tx_phy6                            = TX_REG_PHY ? tx_phy_flop_6_reg : tx_phy_preflop_recov_marker_6               ;

  assign tx_phy_preflop_recov_strobe_0 [   0 +:   1] =                                 tx_phy_preflop_0 [   0 +:   1] ;
  assign tx_phy_preflop_recov_strobe_0 [   1 +:   1] = (~tx_online) ? tx_stb_userbit : tx_phy_preflop_0 [   1 +:   1] ;
  assign tx_phy_preflop_recov_strobe_0 [   2 +:  38] =                                 tx_phy_preflop_0 [   2 +:  38] ;
  assign tx_phy_preflop_recov_strobe_1 [   0 +:   1] =                                 tx_phy_preflop_1 [   0 +:   1] ;
  assign tx_phy_preflop_recov_strobe_1 [   1 +:   1] = (~tx_online) ? tx_stb_userbit : tx_phy_preflop_1 [   1 +:   1] ;
  assign tx_phy_preflop_recov_strobe_1 [   2 +:  38] =                                 tx_phy_preflop_1 [   2 +:  38] ;
  assign tx_phy_preflop_recov_strobe_2 [   0 +:   1] =                                 tx_phy_preflop_2 [   0 +:   1] ;
  assign tx_phy_preflop_recov_strobe_2 [   1 +:   1] = (~tx_online) ? tx_stb_userbit : tx_phy_preflop_2 [   1 +:   1] ;
  assign tx_phy_preflop_recov_strobe_2 [   2 +:  38] =                                 tx_phy_preflop_2 [   2 +:  38] ;
  assign tx_phy_preflop_recov_strobe_3 [   0 +:   1] =                                 tx_phy_preflop_3 [   0 +:   1] ;
  assign tx_phy_preflop_recov_strobe_3 [   1 +:   1] = (~tx_online) ? tx_stb_userbit : tx_phy_preflop_3 [   1 +:   1] ;
  assign tx_phy_preflop_recov_strobe_3 [   2 +:  38] =                                 tx_phy_preflop_3 [   2 +:  38] ;
  assign tx_phy_preflop_recov_strobe_4 [   0 +:   1] =                                 tx_phy_preflop_4 [   0 +:   1] ;
  assign tx_phy_preflop_recov_strobe_4 [   1 +:   1] = (~tx_online) ? tx_stb_userbit : tx_phy_preflop_4 [   1 +:   1] ;
  assign tx_phy_preflop_recov_strobe_4 [   2 +:  38] =                                 tx_phy_preflop_4 [   2 +:  38] ;
  assign tx_phy_preflop_recov_strobe_5 [   0 +:   1] =                                 tx_phy_preflop_5 [   0 +:   1] ;
  assign tx_phy_preflop_recov_strobe_5 [   1 +:   1] = (~tx_online) ? tx_stb_userbit : tx_phy_preflop_5 [   1 +:   1] ;
  assign tx_phy_preflop_recov_strobe_5 [   2 +:  38] =                                 tx_phy_preflop_5 [   2 +:  38] ;
  assign tx_phy_preflop_recov_strobe_6 [   0 +:   1] =                                 tx_phy_preflop_6 [   0 +:   1] ;
  assign tx_phy_preflop_recov_strobe_6 [   1 +:   1] = (~tx_online) ? tx_stb_userbit : tx_phy_preflop_6 [   1 +:   1] ;
  assign tx_phy_preflop_recov_strobe_6 [   2 +:  38] =                                 tx_phy_preflop_6 [   2 +:  38] ;

  assign tx_phy_preflop_recov_marker_0 [   0 +:  39] =                                    tx_phy_preflop_recov_strobe_0 [   0 +:  39] ;
  assign tx_phy_preflop_recov_marker_0 [  39 +:   1] = (~tx_online) ? tx_mrk_userbit[0] : tx_phy_preflop_recov_strobe_0 [  39 +:   1] ;
  assign tx_phy_preflop_recov_marker_1 [   0 +:  39] =                                    tx_phy_preflop_recov_strobe_1 [   0 +:  39] ;
  assign tx_phy_preflop_recov_marker_1 [  39 +:   1] = (~tx_online) ? tx_mrk_userbit[0] : tx_phy_preflop_recov_strobe_1 [  39 +:   1] ;
  assign tx_phy_preflop_recov_marker_2 [   0 +:  39] =                                    tx_phy_preflop_recov_strobe_2 [   0 +:  39] ;
  assign tx_phy_preflop_recov_marker_2 [  39 +:   1] = (~tx_online) ? tx_mrk_userbit[0] : tx_phy_preflop_recov_strobe_2 [  39 +:   1] ;
  assign tx_phy_preflop_recov_marker_3 [   0 +:  39] =                                    tx_phy_preflop_recov_strobe_3 [   0 +:  39] ;
  assign tx_phy_preflop_recov_marker_3 [  39 +:   1] = (~tx_online) ? tx_mrk_userbit[0] : tx_phy_preflop_recov_strobe_3 [  39 +:   1] ;
  assign tx_phy_preflop_recov_marker_4 [   0 +:  39] =                                    tx_phy_preflop_recov_strobe_4 [   0 +:  39] ;
  assign tx_phy_preflop_recov_marker_4 [  39 +:   1] = (~tx_online) ? tx_mrk_userbit[0] : tx_phy_preflop_recov_strobe_4 [  39 +:   1] ;
  assign tx_phy_preflop_recov_marker_5 [   0 +:  39] =                                    tx_phy_preflop_recov_strobe_5 [   0 +:  39] ;
  assign tx_phy_preflop_recov_marker_5 [  39 +:   1] = (~tx_online) ? tx_mrk_userbit[0] : tx_phy_preflop_recov_strobe_5 [  39 +:   1] ;
  assign tx_phy_preflop_recov_marker_6 [   0 +:  39] =                                    tx_phy_preflop_recov_strobe_6 [   0 +:  39] ;
  assign tx_phy_preflop_recov_marker_6 [  39 +:   1] = (~tx_online) ? tx_mrk_userbit[0] : tx_phy_preflop_recov_strobe_6 [  39 +:   1] ;

  logic                                          tx_st_credit_r0               ;
  logic                                          tx_st_credit_r1               ;
  logic                                          tx_st_credit_r2               ;
  logic                                          tx_st_credit_r3               ;

  // Asymmetric Credit Logic
  assign tx_st_credit_r0                    = tx_st_credit         [   0 +:   1] ;
  assign tx_st_credit_r1                    = 1'b0                               ;
  assign tx_st_credit_r2                    = 1'b0                               ;
  assign tx_st_credit_r3                    = 1'b0                               ;

  assign tx_phy_preflop_0 [   0] = tx_st_credit_r0            ;
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
  assign tx_phy_preflop_0 [  38] = 1'b0                       ;
  assign tx_phy_preflop_0 [  39] = 1'b0                       ;
  assign tx_phy_preflop_1 [   0] = 1'b0                       ;
  assign tx_phy_preflop_1 [   1] = 1'b0                       ;
  assign tx_phy_preflop_1 [   2] = 1'b0                       ;
  assign tx_phy_preflop_1 [   3] = 1'b0                       ;
  assign tx_phy_preflop_1 [   4] = 1'b0                       ;
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
  assign tx_phy_preflop_1 [  39] = 1'b0                       ;
  assign tx_phy_preflop_2 [   0] = 1'b0                       ;
  assign tx_phy_preflop_2 [   1] = 1'b0                       ;
  assign tx_phy_preflop_2 [   2] = 1'b0                       ;
  assign tx_phy_preflop_2 [   3] = 1'b0                       ;
  assign tx_phy_preflop_2 [   4] = 1'b0                       ;
  assign tx_phy_preflop_2 [   5] = 1'b0                       ;
  assign tx_phy_preflop_2 [   6] = 1'b0                       ;
  assign tx_phy_preflop_2 [   7] = 1'b0                       ;
  assign tx_phy_preflop_2 [   8] = 1'b0                       ;
  assign tx_phy_preflop_2 [   9] = 1'b0                       ;
  assign tx_phy_preflop_2 [  10] = 1'b0                       ;
  assign tx_phy_preflop_2 [  11] = 1'b0                       ;
  assign tx_phy_preflop_2 [  12] = 1'b0                       ;
  assign tx_phy_preflop_2 [  13] = 1'b0                       ;
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
  assign tx_phy_preflop_2 [  39] = 1'b0                       ;
  assign tx_phy_preflop_3 [   0] = 1'b0                       ;
  assign tx_phy_preflop_3 [   1] = 1'b0                       ;
  assign tx_phy_preflop_3 [   2] = 1'b0                       ;
  assign tx_phy_preflop_3 [   3] = 1'b0                       ;
  assign tx_phy_preflop_3 [   4] = 1'b0                       ;
  assign tx_phy_preflop_3 [   5] = 1'b0                       ;
  assign tx_phy_preflop_3 [   6] = 1'b0                       ;
  assign tx_phy_preflop_3 [   7] = 1'b0                       ;
  assign tx_phy_preflop_3 [   8] = 1'b0                       ;
  assign tx_phy_preflop_3 [   9] = 1'b0                       ;
  assign tx_phy_preflop_3 [  10] = 1'b0                       ;
  assign tx_phy_preflop_3 [  11] = 1'b0                       ;
  assign tx_phy_preflop_3 [  12] = 1'b0                       ;
  assign tx_phy_preflop_3 [  13] = 1'b0                       ;
  assign tx_phy_preflop_3 [  14] = 1'b0                       ;
  assign tx_phy_preflop_3 [  15] = 1'b0                       ;
  assign tx_phy_preflop_3 [  16] = 1'b0                       ;
  assign tx_phy_preflop_3 [  17] = 1'b0                       ;
  assign tx_phy_preflop_3 [  18] = 1'b0                       ;
  assign tx_phy_preflop_3 [  19] = 1'b0                       ;
  assign tx_phy_preflop_3 [  20] = 1'b0                       ;
  assign tx_phy_preflop_3 [  21] = 1'b0                       ;
  assign tx_phy_preflop_3 [  22] = 1'b0                       ;
  assign tx_phy_preflop_3 [  23] = 1'b0                       ;
  assign tx_phy_preflop_3 [  24] = 1'b0                       ;
  assign tx_phy_preflop_3 [  25] = 1'b0                       ;
  assign tx_phy_preflop_3 [  26] = 1'b0                       ;
  assign tx_phy_preflop_3 [  27] = 1'b0                       ;
  assign tx_phy_preflop_3 [  28] = 1'b0                       ;
  assign tx_phy_preflop_3 [  29] = 1'b0                       ;
  assign tx_phy_preflop_3 [  30] = 1'b0                       ;
  assign tx_phy_preflop_3 [  31] = 1'b0                       ;
  assign tx_phy_preflop_3 [  32] = 1'b0                       ;
  assign tx_phy_preflop_3 [  33] = 1'b0                       ;
  assign tx_phy_preflop_3 [  34] = 1'b0                       ;
  assign tx_phy_preflop_3 [  35] = 1'b0                       ;
  assign tx_phy_preflop_3 [  36] = 1'b0                       ;
  assign tx_phy_preflop_3 [  37] = 1'b0                       ;
  assign tx_phy_preflop_3 [  38] = 1'b0                       ;
  assign tx_phy_preflop_3 [  39] = 1'b0                       ;
  assign tx_phy_preflop_4 [   0] = 1'b0                       ;
  assign tx_phy_preflop_4 [   1] = 1'b0                       ;
  assign tx_phy_preflop_4 [   2] = 1'b0                       ;
  assign tx_phy_preflop_4 [   3] = 1'b0                       ;
  assign tx_phy_preflop_4 [   4] = 1'b0                       ;
  assign tx_phy_preflop_4 [   5] = 1'b0                       ;
  assign tx_phy_preflop_4 [   6] = 1'b0                       ;
  assign tx_phy_preflop_4 [   7] = 1'b0                       ;
  assign tx_phy_preflop_4 [   8] = 1'b0                       ;
  assign tx_phy_preflop_4 [   9] = 1'b0                       ;
  assign tx_phy_preflop_4 [  10] = 1'b0                       ;
  assign tx_phy_preflop_4 [  11] = 1'b0                       ;
  assign tx_phy_preflop_4 [  12] = 1'b0                       ;
  assign tx_phy_preflop_4 [  13] = 1'b0                       ;
  assign tx_phy_preflop_4 [  14] = 1'b0                       ;
  assign tx_phy_preflop_4 [  15] = 1'b0                       ;
  assign tx_phy_preflop_4 [  16] = 1'b0                       ;
  assign tx_phy_preflop_4 [  17] = 1'b0                       ;
  assign tx_phy_preflop_4 [  18] = 1'b0                       ;
  assign tx_phy_preflop_4 [  19] = 1'b0                       ;
  assign tx_phy_preflop_4 [  20] = 1'b0                       ;
  assign tx_phy_preflop_4 [  21] = 1'b0                       ;
  assign tx_phy_preflop_4 [  22] = 1'b0                       ;
  assign tx_phy_preflop_4 [  23] = 1'b0                       ;
  assign tx_phy_preflop_4 [  24] = 1'b0                       ;
  assign tx_phy_preflop_4 [  25] = 1'b0                       ;
  assign tx_phy_preflop_4 [  26] = 1'b0                       ;
  assign tx_phy_preflop_4 [  27] = 1'b0                       ;
  assign tx_phy_preflop_4 [  28] = 1'b0                       ;
  assign tx_phy_preflop_4 [  29] = 1'b0                       ;
  assign tx_phy_preflop_4 [  30] = 1'b0                       ;
  assign tx_phy_preflop_4 [  31] = 1'b0                       ;
  assign tx_phy_preflop_4 [  32] = 1'b0                       ;
  assign tx_phy_preflop_4 [  33] = 1'b0                       ;
  assign tx_phy_preflop_4 [  34] = 1'b0                       ;
  assign tx_phy_preflop_4 [  35] = 1'b0                       ;
  assign tx_phy_preflop_4 [  36] = 1'b0                       ;
  assign tx_phy_preflop_4 [  37] = 1'b0                       ;
  assign tx_phy_preflop_4 [  38] = 1'b0                       ;
  assign tx_phy_preflop_4 [  39] = 1'b0                       ;
  assign tx_phy_preflop_5 [   0] = 1'b0                       ;
  assign tx_phy_preflop_5 [   1] = 1'b0                       ;
  assign tx_phy_preflop_5 [   2] = 1'b0                       ;
  assign tx_phy_preflop_5 [   3] = 1'b0                       ;
  assign tx_phy_preflop_5 [   4] = 1'b0                       ;
  assign tx_phy_preflop_5 [   5] = 1'b0                       ;
  assign tx_phy_preflop_5 [   6] = 1'b0                       ;
  assign tx_phy_preflop_5 [   7] = 1'b0                       ;
  assign tx_phy_preflop_5 [   8] = 1'b0                       ;
  assign tx_phy_preflop_5 [   9] = 1'b0                       ;
  assign tx_phy_preflop_5 [  10] = 1'b0                       ;
  assign tx_phy_preflop_5 [  11] = 1'b0                       ;
  assign tx_phy_preflop_5 [  12] = 1'b0                       ;
  assign tx_phy_preflop_5 [  13] = 1'b0                       ;
  assign tx_phy_preflop_5 [  14] = 1'b0                       ;
  assign tx_phy_preflop_5 [  15] = 1'b0                       ;
  assign tx_phy_preflop_5 [  16] = 1'b0                       ;
  assign tx_phy_preflop_5 [  17] = 1'b0                       ;
  assign tx_phy_preflop_5 [  18] = 1'b0                       ;
  assign tx_phy_preflop_5 [  19] = 1'b0                       ;
  assign tx_phy_preflop_5 [  20] = 1'b0                       ;
  assign tx_phy_preflop_5 [  21] = 1'b0                       ;
  assign tx_phy_preflop_5 [  22] = 1'b0                       ;
  assign tx_phy_preflop_5 [  23] = 1'b0                       ;
  assign tx_phy_preflop_5 [  24] = 1'b0                       ;
  assign tx_phy_preflop_5 [  25] = 1'b0                       ;
  assign tx_phy_preflop_5 [  26] = 1'b0                       ;
  assign tx_phy_preflop_5 [  27] = 1'b0                       ;
  assign tx_phy_preflop_5 [  28] = 1'b0                       ;
  assign tx_phy_preflop_5 [  29] = 1'b0                       ;
  assign tx_phy_preflop_5 [  30] = 1'b0                       ;
  assign tx_phy_preflop_5 [  31] = 1'b0                       ;
  assign tx_phy_preflop_5 [  32] = 1'b0                       ;
  assign tx_phy_preflop_5 [  33] = 1'b0                       ;
  assign tx_phy_preflop_5 [  34] = 1'b0                       ;
  assign tx_phy_preflop_5 [  35] = 1'b0                       ;
  assign tx_phy_preflop_5 [  36] = 1'b0                       ;
  assign tx_phy_preflop_5 [  37] = 1'b0                       ;
  assign tx_phy_preflop_5 [  38] = 1'b0                       ;
  assign tx_phy_preflop_5 [  39] = 1'b0                       ;
  assign tx_phy_preflop_6 [   0] = 1'b0                       ;
  assign tx_phy_preflop_6 [   1] = 1'b0                       ;
  assign tx_phy_preflop_6 [   2] = 1'b0                       ;
  assign tx_phy_preflop_6 [   3] = 1'b0                       ;
  assign tx_phy_preflop_6 [   4] = 1'b0                       ;
  assign tx_phy_preflop_6 [   5] = 1'b0                       ;
  assign tx_phy_preflop_6 [   6] = 1'b0                       ;
  assign tx_phy_preflop_6 [   7] = 1'b0                       ;
  assign tx_phy_preflop_6 [   8] = 1'b0                       ;
  assign tx_phy_preflop_6 [   9] = 1'b0                       ;
  assign tx_phy_preflop_6 [  10] = 1'b0                       ;
  assign tx_phy_preflop_6 [  11] = 1'b0                       ;
  assign tx_phy_preflop_6 [  12] = 1'b0                       ;
  assign tx_phy_preflop_6 [  13] = 1'b0                       ;
  assign tx_phy_preflop_6 [  14] = 1'b0                       ;
  assign tx_phy_preflop_6 [  15] = 1'b0                       ;
  assign tx_phy_preflop_6 [  16] = 1'b0                       ;
  assign tx_phy_preflop_6 [  17] = 1'b0                       ;
  assign tx_phy_preflop_6 [  18] = 1'b0                       ;
  assign tx_phy_preflop_6 [  19] = 1'b0                       ;
  assign tx_phy_preflop_6 [  20] = 1'b0                       ;
  assign tx_phy_preflop_6 [  21] = 1'b0                       ;
  assign tx_phy_preflop_6 [  22] = 1'b0                       ;
  assign tx_phy_preflop_6 [  23] = 1'b0                       ;
  assign tx_phy_preflop_6 [  24] = 1'b0                       ;
  assign tx_phy_preflop_6 [  25] = 1'b0                       ;
  assign tx_phy_preflop_6 [  26] = 1'b0                       ;
  assign tx_phy_preflop_6 [  27] = 1'b0                       ;
  assign tx_phy_preflop_6 [  28] = 1'b0                       ;
  assign tx_phy_preflop_6 [  29] = 1'b0                       ;
  assign tx_phy_preflop_6 [  30] = 1'b0                       ;
  assign tx_phy_preflop_6 [  31] = 1'b0                       ;
  assign tx_phy_preflop_6 [  32] = 1'b0                       ;
  assign tx_phy_preflop_6 [  33] = 1'b0                       ;
  assign tx_phy_preflop_6 [  34] = 1'b0                       ;
  assign tx_phy_preflop_6 [  35] = 1'b0                       ;
  assign tx_phy_preflop_6 [  36] = 1'b0                       ;
  assign tx_phy_preflop_6 [  37] = 1'b0                       ;
  assign tx_phy_preflop_6 [  38] = 1'b0                       ;
  assign tx_phy_preflop_6 [  39] = 1'b0                       ;
// TX Section
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// RX Section

//   RX_CH_WIDTH           = 40; // Gen1Only running at Full Rate
//   RX_DATA_WIDTH         = 40; // Usable Data per Channel
//   RX_PERSISTENT_STROBE  = 1'b0;
//   RX_PERSISTENT_MARKER  = 1'b0;
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
  logic [  39:   0]                              rx_phy_flop_0_reg             ;
  logic [  39:   0]                              rx_phy_flop_1_reg             ;
  logic [  39:   0]                              rx_phy_flop_2_reg             ;
  logic [  39:   0]                              rx_phy_flop_3_reg             ;
  logic [  39:   0]                              rx_phy_flop_4_reg             ;
  logic [  39:   0]                              rx_phy_flop_5_reg             ;
  logic [  39:   0]                              rx_phy_flop_6_reg             ;

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

  logic                                          rx_st_pushbit_r0              ;

  assign rx_st_pushbit        = rx_st_pushbit_r0    ;

  assign rx_st_pushbit_r0           = rx_phy_postflop_0 [   0];
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
  assign rx_st_data          [  37] = rx_phy_postflop_0 [  38];
  assign rx_st_data          [  38] = rx_phy_postflop_0 [  39];
  assign rx_st_data          [  39] = rx_phy_postflop_1 [   0];
  assign rx_st_data          [  40] = rx_phy_postflop_1 [   1];
  assign rx_st_data          [  41] = rx_phy_postflop_1 [   2];
  assign rx_st_data          [  42] = rx_phy_postflop_1 [   3];
  assign rx_st_data          [  43] = rx_phy_postflop_1 [   4];
  assign rx_st_data          [  44] = rx_phy_postflop_1 [   5];
  assign rx_st_data          [  45] = rx_phy_postflop_1 [   6];
  assign rx_st_data          [  46] = rx_phy_postflop_1 [   7];
  assign rx_st_data          [  47] = rx_phy_postflop_1 [   8];
  assign rx_st_data          [  48] = rx_phy_postflop_1 [   9];
  assign rx_st_data          [  49] = rx_phy_postflop_1 [  10];
  assign rx_st_data          [  50] = rx_phy_postflop_1 [  11];
  assign rx_st_data          [  51] = rx_phy_postflop_1 [  12];
  assign rx_st_data          [  52] = rx_phy_postflop_1 [  13];
  assign rx_st_data          [  53] = rx_phy_postflop_1 [  14];
  assign rx_st_data          [  54] = rx_phy_postflop_1 [  15];
  assign rx_st_data          [  55] = rx_phy_postflop_1 [  16];
  assign rx_st_data          [  56] = rx_phy_postflop_1 [  17];
  assign rx_st_data          [  57] = rx_phy_postflop_1 [  18];
  assign rx_st_data          [  58] = rx_phy_postflop_1 [  19];
  assign rx_st_data          [  59] = rx_phy_postflop_1 [  20];
  assign rx_st_data          [  60] = rx_phy_postflop_1 [  21];
  assign rx_st_data          [  61] = rx_phy_postflop_1 [  22];
  assign rx_st_data          [  62] = rx_phy_postflop_1 [  23];
  assign rx_st_data          [  63] = rx_phy_postflop_1 [  24];
  assign rx_st_data          [  64] = rx_phy_postflop_1 [  25];
  assign rx_st_data          [  65] = rx_phy_postflop_1 [  26];
  assign rx_st_data          [  66] = rx_phy_postflop_1 [  27];
  assign rx_st_data          [  67] = rx_phy_postflop_1 [  28];
  assign rx_st_data          [  68] = rx_phy_postflop_1 [  29];
  assign rx_st_data          [  69] = rx_phy_postflop_1 [  30];
  assign rx_st_data          [  70] = rx_phy_postflop_1 [  31];
  assign rx_st_data          [  71] = rx_phy_postflop_1 [  32];
  assign rx_st_data          [  72] = rx_phy_postflop_1 [  33];
  assign rx_st_data          [  73] = rx_phy_postflop_1 [  34];
  assign rx_st_data          [  74] = rx_phy_postflop_1 [  35];
  assign rx_st_data          [  75] = rx_phy_postflop_1 [  36];
  assign rx_st_data          [  76] = rx_phy_postflop_1 [  37];
  assign rx_st_data          [  77] = rx_phy_postflop_1 [  38];
  assign rx_st_data          [  78] = rx_phy_postflop_1 [  39];
  assign rx_st_data          [  79] = rx_phy_postflop_2 [   0];
  assign rx_st_data          [  80] = rx_phy_postflop_2 [   1];
  assign rx_st_data          [  81] = rx_phy_postflop_2 [   2];
  assign rx_st_data          [  82] = rx_phy_postflop_2 [   3];
  assign rx_st_data          [  83] = rx_phy_postflop_2 [   4];
  assign rx_st_data          [  84] = rx_phy_postflop_2 [   5];
  assign rx_st_data          [  85] = rx_phy_postflop_2 [   6];
  assign rx_st_data          [  86] = rx_phy_postflop_2 [   7];
  assign rx_st_data          [  87] = rx_phy_postflop_2 [   8];
  assign rx_st_data          [  88] = rx_phy_postflop_2 [   9];
  assign rx_st_data          [  89] = rx_phy_postflop_2 [  10];
  assign rx_st_data          [  90] = rx_phy_postflop_2 [  11];
  assign rx_st_data          [  91] = rx_phy_postflop_2 [  12];
  assign rx_st_data          [  92] = rx_phy_postflop_2 [  13];
  assign rx_st_data          [  93] = rx_phy_postflop_2 [  14];
  assign rx_st_data          [  94] = rx_phy_postflop_2 [  15];
  assign rx_st_data          [  95] = rx_phy_postflop_2 [  16];
  assign rx_st_data          [  96] = rx_phy_postflop_2 [  17];
  assign rx_st_data          [  97] = rx_phy_postflop_2 [  18];
  assign rx_st_data          [  98] = rx_phy_postflop_2 [  19];
  assign rx_st_data          [  99] = rx_phy_postflop_2 [  20];
  assign rx_st_data          [ 100] = rx_phy_postflop_2 [  21];
  assign rx_st_data          [ 101] = rx_phy_postflop_2 [  22];
  assign rx_st_data          [ 102] = rx_phy_postflop_2 [  23];
  assign rx_st_data          [ 103] = rx_phy_postflop_2 [  24];
  assign rx_st_data          [ 104] = rx_phy_postflop_2 [  25];
  assign rx_st_data          [ 105] = rx_phy_postflop_2 [  26];
  assign rx_st_data          [ 106] = rx_phy_postflop_2 [  27];
  assign rx_st_data          [ 107] = rx_phy_postflop_2 [  28];
  assign rx_st_data          [ 108] = rx_phy_postflop_2 [  29];
  assign rx_st_data          [ 109] = rx_phy_postflop_2 [  30];
  assign rx_st_data          [ 110] = rx_phy_postflop_2 [  31];
  assign rx_st_data          [ 111] = rx_phy_postflop_2 [  32];
  assign rx_st_data          [ 112] = rx_phy_postflop_2 [  33];
  assign rx_st_data          [ 113] = rx_phy_postflop_2 [  34];
  assign rx_st_data          [ 114] = rx_phy_postflop_2 [  35];
  assign rx_st_data          [ 115] = rx_phy_postflop_2 [  36];
  assign rx_st_data          [ 116] = rx_phy_postflop_2 [  37];
  assign rx_st_data          [ 117] = rx_phy_postflop_2 [  38];
  assign rx_st_data          [ 118] = rx_phy_postflop_2 [  39];
  assign rx_st_data          [ 119] = rx_phy_postflop_3 [   0];
  assign rx_st_data          [ 120] = rx_phy_postflop_3 [   1];
  assign rx_st_data          [ 121] = rx_phy_postflop_3 [   2];
  assign rx_st_data          [ 122] = rx_phy_postflop_3 [   3];
  assign rx_st_data          [ 123] = rx_phy_postflop_3 [   4];
  assign rx_st_data          [ 124] = rx_phy_postflop_3 [   5];
  assign rx_st_data          [ 125] = rx_phy_postflop_3 [   6];
  assign rx_st_data          [ 126] = rx_phy_postflop_3 [   7];
  assign rx_st_data          [ 127] = rx_phy_postflop_3 [   8];
  assign rx_st_data          [ 128] = rx_phy_postflop_3 [   9];
  assign rx_st_data          [ 129] = rx_phy_postflop_3 [  10];
  assign rx_st_data          [ 130] = rx_phy_postflop_3 [  11];
  assign rx_st_data          [ 131] = rx_phy_postflop_3 [  12];
  assign rx_st_data          [ 132] = rx_phy_postflop_3 [  13];
  assign rx_st_data          [ 133] = rx_phy_postflop_3 [  14];
  assign rx_st_data          [ 134] = rx_phy_postflop_3 [  15];
  assign rx_st_data          [ 135] = rx_phy_postflop_3 [  16];
  assign rx_st_data          [ 136] = rx_phy_postflop_3 [  17];
  assign rx_st_data          [ 137] = rx_phy_postflop_3 [  18];
  assign rx_st_data          [ 138] = rx_phy_postflop_3 [  19];
  assign rx_st_data          [ 139] = rx_phy_postflop_3 [  20];
  assign rx_st_data          [ 140] = rx_phy_postflop_3 [  21];
  assign rx_st_data          [ 141] = rx_phy_postflop_3 [  22];
  assign rx_st_data          [ 142] = rx_phy_postflop_3 [  23];
  assign rx_st_data          [ 143] = rx_phy_postflop_3 [  24];
  assign rx_st_data          [ 144] = rx_phy_postflop_3 [  25];
  assign rx_st_data          [ 145] = rx_phy_postflop_3 [  26];
  assign rx_st_data          [ 146] = rx_phy_postflop_3 [  27];
  assign rx_st_data          [ 147] = rx_phy_postflop_3 [  28];
  assign rx_st_data          [ 148] = rx_phy_postflop_3 [  29];
  assign rx_st_data          [ 149] = rx_phy_postflop_3 [  30];
  assign rx_st_data          [ 150] = rx_phy_postflop_3 [  31];
  assign rx_st_data          [ 151] = rx_phy_postflop_3 [  32];
  assign rx_st_data          [ 152] = rx_phy_postflop_3 [  33];
  assign rx_st_data          [ 153] = rx_phy_postflop_3 [  34];
  assign rx_st_data          [ 154] = rx_phy_postflop_3 [  35];
  assign rx_st_data          [ 155] = rx_phy_postflop_3 [  36];
  assign rx_st_data          [ 156] = rx_phy_postflop_3 [  37];
  assign rx_st_data          [ 157] = rx_phy_postflop_3 [  38];
  assign rx_st_data          [ 158] = rx_phy_postflop_3 [  39];
  assign rx_st_data          [ 159] = rx_phy_postflop_4 [   0];
  assign rx_st_data          [ 160] = rx_phy_postflop_4 [   1];
  assign rx_st_data          [ 161] = rx_phy_postflop_4 [   2];
  assign rx_st_data          [ 162] = rx_phy_postflop_4 [   3];
  assign rx_st_data          [ 163] = rx_phy_postflop_4 [   4];
  assign rx_st_data          [ 164] = rx_phy_postflop_4 [   5];
  assign rx_st_data          [ 165] = rx_phy_postflop_4 [   6];
  assign rx_st_data          [ 166] = rx_phy_postflop_4 [   7];
  assign rx_st_data          [ 167] = rx_phy_postflop_4 [   8];
  assign rx_st_data          [ 168] = rx_phy_postflop_4 [   9];
  assign rx_st_data          [ 169] = rx_phy_postflop_4 [  10];
  assign rx_st_data          [ 170] = rx_phy_postflop_4 [  11];
  assign rx_st_data          [ 171] = rx_phy_postflop_4 [  12];
  assign rx_st_data          [ 172] = rx_phy_postflop_4 [  13];
  assign rx_st_data          [ 173] = rx_phy_postflop_4 [  14];
  assign rx_st_data          [ 174] = rx_phy_postflop_4 [  15];
  assign rx_st_data          [ 175] = rx_phy_postflop_4 [  16];
  assign rx_st_data          [ 176] = rx_phy_postflop_4 [  17];
  assign rx_st_data          [ 177] = rx_phy_postflop_4 [  18];
  assign rx_st_data          [ 178] = rx_phy_postflop_4 [  19];
  assign rx_st_data          [ 179] = rx_phy_postflop_4 [  20];
  assign rx_st_data          [ 180] = rx_phy_postflop_4 [  21];
  assign rx_st_data          [ 181] = rx_phy_postflop_4 [  22];
  assign rx_st_data          [ 182] = rx_phy_postflop_4 [  23];
  assign rx_st_data          [ 183] = rx_phy_postflop_4 [  24];
  assign rx_st_data          [ 184] = rx_phy_postflop_4 [  25];
  assign rx_st_data          [ 185] = rx_phy_postflop_4 [  26];
  assign rx_st_data          [ 186] = rx_phy_postflop_4 [  27];
  assign rx_st_data          [ 187] = rx_phy_postflop_4 [  28];
  assign rx_st_data          [ 188] = rx_phy_postflop_4 [  29];
  assign rx_st_data          [ 189] = rx_phy_postflop_4 [  30];
  assign rx_st_data          [ 190] = rx_phy_postflop_4 [  31];
  assign rx_st_data          [ 191] = rx_phy_postflop_4 [  32];
  assign rx_st_data          [ 192] = rx_phy_postflop_4 [  33];
  assign rx_st_data          [ 193] = rx_phy_postflop_4 [  34];
  assign rx_st_data          [ 194] = rx_phy_postflop_4 [  35];
  assign rx_st_data          [ 195] = rx_phy_postflop_4 [  36];
  assign rx_st_data          [ 196] = rx_phy_postflop_4 [  37];
  assign rx_st_data          [ 197] = rx_phy_postflop_4 [  38];
  assign rx_st_data          [ 198] = rx_phy_postflop_4 [  39];
  assign rx_st_data          [ 199] = rx_phy_postflop_5 [   0];
  assign rx_st_data          [ 200] = rx_phy_postflop_5 [   1];
  assign rx_st_data          [ 201] = rx_phy_postflop_5 [   2];
  assign rx_st_data          [ 202] = rx_phy_postflop_5 [   3];
  assign rx_st_data          [ 203] = rx_phy_postflop_5 [   4];
  assign rx_st_data          [ 204] = rx_phy_postflop_5 [   5];
  assign rx_st_data          [ 205] = rx_phy_postflop_5 [   6];
  assign rx_st_data          [ 206] = rx_phy_postflop_5 [   7];
  assign rx_st_data          [ 207] = rx_phy_postflop_5 [   8];
  assign rx_st_data          [ 208] = rx_phy_postflop_5 [   9];
  assign rx_st_data          [ 209] = rx_phy_postflop_5 [  10];
  assign rx_st_data          [ 210] = rx_phy_postflop_5 [  11];
  assign rx_st_data          [ 211] = rx_phy_postflop_5 [  12];
  assign rx_st_data          [ 212] = rx_phy_postflop_5 [  13];
  assign rx_st_data          [ 213] = rx_phy_postflop_5 [  14];
  assign rx_st_data          [ 214] = rx_phy_postflop_5 [  15];
  assign rx_st_data          [ 215] = rx_phy_postflop_5 [  16];
  assign rx_st_data          [ 216] = rx_phy_postflop_5 [  17];
  assign rx_st_data          [ 217] = rx_phy_postflop_5 [  18];
  assign rx_st_data          [ 218] = rx_phy_postflop_5 [  19];
  assign rx_st_data          [ 219] = rx_phy_postflop_5 [  20];
  assign rx_st_data          [ 220] = rx_phy_postflop_5 [  21];
  assign rx_st_data          [ 221] = rx_phy_postflop_5 [  22];
  assign rx_st_data          [ 222] = rx_phy_postflop_5 [  23];
  assign rx_st_data          [ 223] = rx_phy_postflop_5 [  24];
  assign rx_st_data          [ 224] = rx_phy_postflop_5 [  25];
  assign rx_st_data          [ 225] = rx_phy_postflop_5 [  26];
  assign rx_st_data          [ 226] = rx_phy_postflop_5 [  27];
  assign rx_st_data          [ 227] = rx_phy_postflop_5 [  28];
  assign rx_st_data          [ 228] = rx_phy_postflop_5 [  29];
  assign rx_st_data          [ 229] = rx_phy_postflop_5 [  30];
  assign rx_st_data          [ 230] = rx_phy_postflop_5 [  31];
  assign rx_st_data          [ 231] = rx_phy_postflop_5 [  32];
  assign rx_st_data          [ 232] = rx_phy_postflop_5 [  33];
  assign rx_st_data          [ 233] = rx_phy_postflop_5 [  34];
  assign rx_st_data          [ 234] = rx_phy_postflop_5 [  35];
  assign rx_st_data          [ 235] = rx_phy_postflop_5 [  36];
  assign rx_st_data          [ 236] = rx_phy_postflop_5 [  37];
  assign rx_st_data          [ 237] = rx_phy_postflop_5 [  38];
  assign rx_st_data          [ 238] = rx_phy_postflop_5 [  39];
  assign rx_st_data          [ 239] = rx_phy_postflop_6 [   0];
  assign rx_st_data          [ 240] = rx_phy_postflop_6 [   1];
  assign rx_st_data          [ 241] = rx_phy_postflop_6 [   2];
  assign rx_st_data          [ 242] = rx_phy_postflop_6 [   3];
  assign rx_st_data          [ 243] = rx_phy_postflop_6 [   4];
  assign rx_st_data          [ 244] = rx_phy_postflop_6 [   5];
  assign rx_st_data          [ 245] = rx_phy_postflop_6 [   6];
  assign rx_st_data          [ 246] = rx_phy_postflop_6 [   7];
  assign rx_st_data          [ 247] = rx_phy_postflop_6 [   8];
  assign rx_st_data          [ 248] = rx_phy_postflop_6 [   9];
  assign rx_st_data          [ 249] = rx_phy_postflop_6 [  10];
  assign rx_st_data          [ 250] = rx_phy_postflop_6 [  11];
  assign rx_st_data          [ 251] = rx_phy_postflop_6 [  12];
  assign rx_st_data          [ 252] = rx_phy_postflop_6 [  13];
  assign rx_st_data          [ 253] = rx_phy_postflop_6 [  14];
  assign rx_st_data          [ 254] = rx_phy_postflop_6 [  15];
  assign rx_st_data          [ 255] = rx_phy_postflop_6 [  16];
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
//       nc                         = rx_phy_postflop_6 [  39];
  assign rx_st_data          [ 256] = rx_st_pushbit_r0;

// RX Section
//////////////////////////////////////////////////////////////////


endmodule
