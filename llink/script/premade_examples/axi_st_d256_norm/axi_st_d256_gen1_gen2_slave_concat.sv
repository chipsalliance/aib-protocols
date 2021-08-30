module axi_st_d256_gen1_gen2_slave_concat  (

// Transmit data from Logic Links
  output logic [288:  0]    rx_st_data          ,
  output logic              rx_st_push_ovrd     ,
  output logic              rx_st_pushbit       ,
  input  logic              tx_st_credit        ,

// PHY Interconnect
  output logic [159:  0]    tx_phy0             ,
  input  logic [159:  0]    rx_phy0             ,
  output logic [159:  0]    tx_phy1             ,
  input  logic [159:  0]    rx_phy1             ,

  input  logic              clk_wr              ,
  input  logic              clk_rd              ,
  input  logic              rst_wr_n            ,
  input  logic              rst_rd_n            ,

  input  logic              m_gen2_mode         ,
  input  logic              tx_online           ,

  input  logic              tx_stb_userbit      ,
  input  logic [  1:  0]    tx_mrk_userbit      

);

// No TX Packetization, so tie off packetization signals

// No RX Packetization, so tie off packetization signals
  assign rx_st_push_ovrd                  = 1'b0                             ;

////////////////////////////////////////////////////////////
// TX Section

//   TX_CH_WIDTH           = 160; // Gen2 running at Half Rate
//   TX_DATA_WIDTH         = 149; // Usable Data per Channel
//   TX_PERSISTENT_STROBE  = 1'b1;
//   TX_PERSISTENT_MARKER  = 1'b1;
//   TX_STROBE_GEN2_LOC    = 'd76;
//   TX_MARKER_GEN2_LOC    = 'd4;
//   TX_STROBE_GEN1_LOC    = 'd35;
//   TX_MARKER_GEN1_LOC    = 'd39;
//   TX_ENABLE_STROBE      = 1'b1;
//   TX_ENABLE_MARKER      = 1'b1;
//   TX_DBI_PRESENT        = 1'b1;
//   TX_REG_PHY            = 1'b0;

  localparam TX_REG_PHY    = 1'b0;

  logic [159:  0]                                tx_phy_preflop_0              ;
  logic [159:  0]                                tx_phy_preflop_1              ;
  logic [159:  0]                                tx_phy_flop_0_reg             ;
  logic [159:  0]                                tx_phy_flop_1_reg             ;

  always_ff @(posedge clk_wr or negedge rst_wr_n)
  if (~rst_wr_n)
  begin
    tx_phy_flop_0_reg                     <= 160'b0                                ;
    tx_phy_flop_1_reg                     <= 160'b0                                ;
  end
  else
  begin
    tx_phy_flop_0_reg                     <= tx_phy_preflop_0                      ;
    tx_phy_flop_1_reg                     <= tx_phy_preflop_1                      ;
  end


  assign tx_phy0                          = TX_REG_PHY ? tx_phy_flop_0_reg : tx_phy_preflop_0             ;
  assign tx_phy1                          = TX_REG_PHY ? tx_phy_flop_1_reg : tx_phy_preflop_1             ;

  assign tx_phy_preflop_0 [  0] = tx_st_credit              ;
  assign tx_phy_preflop_0 [  1] = 1'b0                      ;
  assign tx_phy_preflop_0 [  2] = 1'b0                      ;
  assign tx_phy_preflop_0 [  3] = 1'b0                      ;
  assign tx_phy_preflop_0 [  4] = tx_mrk_userbit[0]         ; // MARKER
  assign tx_phy_preflop_0 [  5] = 1'b0                      ;
  assign tx_phy_preflop_0 [  6] = 1'b0                      ;
  assign tx_phy_preflop_0 [  7] = 1'b0                      ;
  assign tx_phy_preflop_0 [  8] = 1'b0                      ;
  assign tx_phy_preflop_0 [  9] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 10] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 11] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 12] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 13] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 14] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 15] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 16] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 17] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 18] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 19] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 20] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 21] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 22] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 23] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 24] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 25] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 26] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 27] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 28] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 29] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 30] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 31] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 32] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 33] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 34] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 35] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 36] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 37] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 38] = 1'b0                      ; // DBI
  assign tx_phy_preflop_0 [ 39] = 1'b0                      ; // DBI
  assign tx_phy_preflop_0 [ 40] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 41] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 42] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 43] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 44] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 45] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 46] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 47] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 48] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 49] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 50] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 51] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 52] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 53] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 54] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 55] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 56] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 57] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 58] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 59] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 60] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 61] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 62] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 63] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 64] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 65] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 66] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 67] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 68] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 69] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 70] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 71] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 72] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 73] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 74] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 75] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 76] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_0 [ 77] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 78] = 1'b0                      ; // DBI
  assign tx_phy_preflop_0 [ 79] = 1'b0                      ; // DBI
  assign tx_phy_preflop_0 [ 80] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 81] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 82] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 83] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 84] = tx_mrk_userbit[1]         ; // MARKER
  assign tx_phy_preflop_0 [ 85] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 86] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 87] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 88] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 89] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 90] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 91] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 92] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 93] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 94] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 95] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 96] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 97] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 98] = 1'b0                      ;
  assign tx_phy_preflop_0 [ 99] = 1'b0                      ;
  assign tx_phy_preflop_0 [100] = 1'b0                      ;
  assign tx_phy_preflop_0 [101] = 1'b0                      ;
  assign tx_phy_preflop_0 [102] = 1'b0                      ;
  assign tx_phy_preflop_0 [103] = 1'b0                      ;
  assign tx_phy_preflop_0 [104] = 1'b0                      ;
  assign tx_phy_preflop_0 [105] = 1'b0                      ;
  assign tx_phy_preflop_0 [106] = 1'b0                      ;
  assign tx_phy_preflop_0 [107] = 1'b0                      ;
  assign tx_phy_preflop_0 [108] = 1'b0                      ;
  assign tx_phy_preflop_0 [109] = 1'b0                      ;
  assign tx_phy_preflop_0 [110] = 1'b0                      ;
  assign tx_phy_preflop_0 [111] = 1'b0                      ;
  assign tx_phy_preflop_0 [112] = 1'b0                      ;
  assign tx_phy_preflop_0 [113] = 1'b0                      ;
  assign tx_phy_preflop_0 [114] = 1'b0                      ;
  assign tx_phy_preflop_0 [115] = 1'b0                      ;
  assign tx_phy_preflop_0 [116] = 1'b0                      ;
  assign tx_phy_preflop_0 [117] = 1'b0                      ;
  assign tx_phy_preflop_0 [118] = 1'b0                      ; // DBI
  assign tx_phy_preflop_0 [119] = 1'b0                      ; // DBI
  assign tx_phy_preflop_0 [120] = 1'b0                      ;
  assign tx_phy_preflop_0 [121] = 1'b0                      ;
  assign tx_phy_preflop_0 [122] = 1'b0                      ;
  assign tx_phy_preflop_0 [123] = 1'b0                      ;
  assign tx_phy_preflop_0 [124] = 1'b0                      ;
  assign tx_phy_preflop_0 [125] = 1'b0                      ;
  assign tx_phy_preflop_0 [126] = 1'b0                      ;
  assign tx_phy_preflop_0 [127] = 1'b0                      ;
  assign tx_phy_preflop_0 [128] = 1'b0                      ;
  assign tx_phy_preflop_0 [129] = 1'b0                      ;
  assign tx_phy_preflop_0 [130] = 1'b0                      ;
  assign tx_phy_preflop_0 [131] = 1'b0                      ;
  assign tx_phy_preflop_0 [132] = 1'b0                      ;
  assign tx_phy_preflop_0 [133] = 1'b0                      ;
  assign tx_phy_preflop_0 [134] = 1'b0                      ;
  assign tx_phy_preflop_0 [135] = 1'b0                      ;
  assign tx_phy_preflop_0 [136] = 1'b0                      ;
  assign tx_phy_preflop_0 [137] = 1'b0                      ;
  assign tx_phy_preflop_0 [138] = 1'b0                      ;
  assign tx_phy_preflop_0 [139] = 1'b0                      ;
  assign tx_phy_preflop_0 [140] = 1'b0                      ;
  assign tx_phy_preflop_0 [141] = 1'b0                      ;
  assign tx_phy_preflop_0 [142] = 1'b0                      ;
  assign tx_phy_preflop_0 [143] = 1'b0                      ;
  assign tx_phy_preflop_0 [144] = 1'b0                      ;
  assign tx_phy_preflop_0 [145] = 1'b0                      ;
  assign tx_phy_preflop_0 [146] = 1'b0                      ;
  assign tx_phy_preflop_0 [147] = 1'b0                      ;
  assign tx_phy_preflop_0 [148] = 1'b0                      ;
  assign tx_phy_preflop_0 [149] = 1'b0                      ;
  assign tx_phy_preflop_0 [150] = 1'b0                      ;
  assign tx_phy_preflop_0 [151] = 1'b0                      ;
  assign tx_phy_preflop_0 [152] = 1'b0                      ;
  assign tx_phy_preflop_0 [153] = 1'b0                      ;
  assign tx_phy_preflop_0 [154] = 1'b0                      ;
  assign tx_phy_preflop_0 [155] = 1'b0                      ;
  assign tx_phy_preflop_0 [156] = 1'b0                      ;
  assign tx_phy_preflop_0 [157] = 1'b0                      ;
  assign tx_phy_preflop_0 [158] = 1'b0                      ; // DBI
  assign tx_phy_preflop_0 [159] = 1'b0                      ; // DBI
  assign tx_phy_preflop_1 [  0] = 1'b0                      ;
  assign tx_phy_preflop_1 [  1] = 1'b0                      ;
  assign tx_phy_preflop_1 [  2] = 1'b0                      ;
  assign tx_phy_preflop_1 [  3] = 1'b0                      ;
  assign tx_phy_preflop_1 [  4] = tx_mrk_userbit[0]         ; // MARKER
  assign tx_phy_preflop_1 [  5] = 1'b0                      ;
  assign tx_phy_preflop_1 [  6] = 1'b0                      ;
  assign tx_phy_preflop_1 [  7] = 1'b0                      ;
  assign tx_phy_preflop_1 [  8] = 1'b0                      ;
  assign tx_phy_preflop_1 [  9] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 10] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 11] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 12] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 13] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 14] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 15] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 16] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 17] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 18] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 19] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 20] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 21] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 22] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 23] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 24] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 25] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 26] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 27] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 28] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 29] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 30] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 31] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 32] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 33] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 34] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 35] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 36] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 37] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 38] = 1'b0                      ; // DBI
  assign tx_phy_preflop_1 [ 39] = 1'b0                      ; // DBI
  assign tx_phy_preflop_1 [ 40] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 41] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 42] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 43] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 44] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 45] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 46] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 47] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 48] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 49] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 50] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 51] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 52] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 53] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 54] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 55] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 56] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 57] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 58] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 59] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 60] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 61] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 62] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 63] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 64] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 65] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 66] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 67] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 68] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 69] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 70] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 71] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 72] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 73] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 74] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 75] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 76] = tx_stb_userbit             ; // STROBE
  assign tx_phy_preflop_1 [ 77] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 78] = 1'b0                      ; // DBI
  assign tx_phy_preflop_1 [ 79] = 1'b0                      ; // DBI
  assign tx_phy_preflop_1 [ 80] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 81] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 82] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 83] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 84] = tx_mrk_userbit[1]         ; // MARKER
  assign tx_phy_preflop_1 [ 85] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 86] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 87] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 88] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 89] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 90] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 91] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 92] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 93] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 94] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 95] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 96] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 97] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 98] = 1'b0                      ;
  assign tx_phy_preflop_1 [ 99] = 1'b0                      ;
  assign tx_phy_preflop_1 [100] = 1'b0                      ;
  assign tx_phy_preflop_1 [101] = 1'b0                      ;
  assign tx_phy_preflop_1 [102] = 1'b0                      ;
  assign tx_phy_preflop_1 [103] = 1'b0                      ;
  assign tx_phy_preflop_1 [104] = 1'b0                      ;
  assign tx_phy_preflop_1 [105] = 1'b0                      ;
  assign tx_phy_preflop_1 [106] = 1'b0                      ;
  assign tx_phy_preflop_1 [107] = 1'b0                      ;
  assign tx_phy_preflop_1 [108] = 1'b0                      ;
  assign tx_phy_preflop_1 [109] = 1'b0                      ;
  assign tx_phy_preflop_1 [110] = 1'b0                      ;
  assign tx_phy_preflop_1 [111] = 1'b0                      ;
  assign tx_phy_preflop_1 [112] = 1'b0                      ;
  assign tx_phy_preflop_1 [113] = 1'b0                      ;
  assign tx_phy_preflop_1 [114] = 1'b0                      ;
  assign tx_phy_preflop_1 [115] = 1'b0                      ;
  assign tx_phy_preflop_1 [116] = 1'b0                      ;
  assign tx_phy_preflop_1 [117] = 1'b0                      ;
  assign tx_phy_preflop_1 [118] = 1'b0                      ; // DBI
  assign tx_phy_preflop_1 [119] = 1'b0                      ; // DBI
  assign tx_phy_preflop_1 [120] = 1'b0                      ;
  assign tx_phy_preflop_1 [121] = 1'b0                      ;
  assign tx_phy_preflop_1 [122] = 1'b0                      ;
  assign tx_phy_preflop_1 [123] = 1'b0                      ;
  assign tx_phy_preflop_1 [124] = 1'b0                      ;
  assign tx_phy_preflop_1 [125] = 1'b0                      ;
  assign tx_phy_preflop_1 [126] = 1'b0                      ;
  assign tx_phy_preflop_1 [127] = 1'b0                      ;
  assign tx_phy_preflop_1 [128] = 1'b0                      ;
  assign tx_phy_preflop_1 [129] = 1'b0                      ;
  assign tx_phy_preflop_1 [130] = 1'b0                      ;
  assign tx_phy_preflop_1 [131] = 1'b0                      ;
  assign tx_phy_preflop_1 [132] = 1'b0                      ;
  assign tx_phy_preflop_1 [133] = 1'b0                      ;
  assign tx_phy_preflop_1 [134] = 1'b0                      ;
  assign tx_phy_preflop_1 [135] = 1'b0                      ;
  assign tx_phy_preflop_1 [136] = 1'b0                      ;
  assign tx_phy_preflop_1 [137] = 1'b0                      ;
  assign tx_phy_preflop_1 [138] = 1'b0                      ;
  assign tx_phy_preflop_1 [139] = 1'b0                      ;
  assign tx_phy_preflop_1 [140] = 1'b0                      ;
  assign tx_phy_preflop_1 [141] = 1'b0                      ;
  assign tx_phy_preflop_1 [142] = 1'b0                      ;
  assign tx_phy_preflop_1 [143] = 1'b0                      ;
  assign tx_phy_preflop_1 [144] = 1'b0                      ;
  assign tx_phy_preflop_1 [145] = 1'b0                      ;
  assign tx_phy_preflop_1 [146] = 1'b0                      ;
  assign tx_phy_preflop_1 [147] = 1'b0                      ;
  assign tx_phy_preflop_1 [148] = 1'b0                      ;
  assign tx_phy_preflop_1 [149] = 1'b0                      ;
  assign tx_phy_preflop_1 [150] = 1'b0                      ;
  assign tx_phy_preflop_1 [151] = 1'b0                      ;
  assign tx_phy_preflop_1 [152] = 1'b0                      ;
  assign tx_phy_preflop_1 [153] = 1'b0                      ;
  assign tx_phy_preflop_1 [154] = 1'b0                      ;
  assign tx_phy_preflop_1 [155] = 1'b0                      ;
  assign tx_phy_preflop_1 [156] = 1'b0                      ;
  assign tx_phy_preflop_1 [157] = 1'b0                      ;
  assign tx_phy_preflop_1 [158] = 1'b0                      ; // DBI
  assign tx_phy_preflop_1 [159] = 1'b0                      ; // DBI
// TX Section
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// RX Section

//   RX_CH_WIDTH           = 160; // Gen2 running at Half Rate
//   RX_DATA_WIDTH         = 149; // Usable Data per Channel
//   RX_PERSISTENT_STROBE  = 1'b1;
//   RX_PERSISTENT_MARKER  = 1'b1;
//   RX_STROBE_GEN2_LOC    = 'd76;
//   RX_MARKER_GEN2_LOC    = 'd4;
//   RX_STROBE_GEN1_LOC    = 'd35;
//   RX_MARKER_GEN1_LOC    = 'd39;
//   RX_ENABLE_STROBE      = 1'b1;
//   RX_ENABLE_MARKER      = 1'b1;
//   RX_DBI_PRESENT        = 1'b1;
//   RX_REG_PHY            = 1'b0;

  localparam RX_REG_PHY    = 1'b0;

  logic [159:  0]                                rx_phy_postflop_0             ;
  logic [159:  0]                                rx_phy_postflop_1             ;
  logic [159:  0]                                rx_phy_flop_0_reg             ;
  logic [159:  0]                                rx_phy_flop_1_reg             ;

  always_ff @(posedge clk_rd or negedge rst_rd_n)
  if (~rst_rd_n)
  begin
    rx_phy_flop_0_reg                     <= 160'b0                                ;
    rx_phy_flop_1_reg                     <= 160'b0                                ;
  end
  else
  begin
    rx_phy_flop_0_reg                     <= rx_phy0                               ;
    rx_phy_flop_1_reg                     <= rx_phy1                               ;
  end


  assign rx_phy_postflop_0                = RX_REG_PHY ? rx_phy_flop_0_reg : rx_phy0             ;
  assign rx_phy_postflop_1                = RX_REG_PHY ? rx_phy_flop_1_reg : rx_phy1             ;

  assign rx_st_pushbit             = rx_phy_postflop_0 [  0];
  assign rx_st_data          [  0] = rx_phy_postflop_0 [  1];
  assign rx_st_data          [  1] = rx_phy_postflop_0 [  2];
  assign rx_st_data          [  2] = rx_phy_postflop_0 [  3];
//       MARKER                    = rx_phy_postflop_0 [  4]
  assign rx_st_data          [  3] = rx_phy_postflop_0 [  5];
  assign rx_st_data          [  4] = rx_phy_postflop_0 [  6];
  assign rx_st_data          [  5] = rx_phy_postflop_0 [  7];
  assign rx_st_data          [  6] = rx_phy_postflop_0 [  8];
  assign rx_st_data          [  7] = rx_phy_postflop_0 [  9];
  assign rx_st_data          [  8] = rx_phy_postflop_0 [ 10];
  assign rx_st_data          [  9] = rx_phy_postflop_0 [ 11];
  assign rx_st_data          [ 10] = rx_phy_postflop_0 [ 12];
  assign rx_st_data          [ 11] = rx_phy_postflop_0 [ 13];
  assign rx_st_data          [ 12] = rx_phy_postflop_0 [ 14];
  assign rx_st_data          [ 13] = rx_phy_postflop_0 [ 15];
  assign rx_st_data          [ 14] = rx_phy_postflop_0 [ 16];
  assign rx_st_data          [ 15] = rx_phy_postflop_0 [ 17];
  assign rx_st_data          [ 16] = rx_phy_postflop_0 [ 18];
  assign rx_st_data          [ 17] = rx_phy_postflop_0 [ 19];
  assign rx_st_data          [ 18] = rx_phy_postflop_0 [ 20];
  assign rx_st_data          [ 19] = rx_phy_postflop_0 [ 21];
  assign rx_st_data          [ 20] = rx_phy_postflop_0 [ 22];
  assign rx_st_data          [ 21] = rx_phy_postflop_0 [ 23];
  assign rx_st_data          [ 22] = rx_phy_postflop_0 [ 24];
  assign rx_st_data          [ 23] = rx_phy_postflop_0 [ 25];
  assign rx_st_data          [ 24] = rx_phy_postflop_0 [ 26];
  assign rx_st_data          [ 25] = rx_phy_postflop_0 [ 27];
  assign rx_st_data          [ 26] = rx_phy_postflop_0 [ 28];
  assign rx_st_data          [ 27] = rx_phy_postflop_0 [ 29];
  assign rx_st_data          [ 28] = rx_phy_postflop_0 [ 30];
  assign rx_st_data          [ 29] = rx_phy_postflop_0 [ 31];
  assign rx_st_data          [ 30] = rx_phy_postflop_0 [ 32];
  assign rx_st_data          [ 31] = rx_phy_postflop_0 [ 33];
  assign rx_st_data          [ 32] = rx_phy_postflop_0 [ 34];
  assign rx_st_data          [ 33] = rx_phy_postflop_0 [ 35];
  assign rx_st_data          [ 34] = rx_phy_postflop_0 [ 36];
  assign rx_st_data          [ 35] = rx_phy_postflop_0 [ 37];
//       DBI                       = rx_phy_postflop_0 [ 38];
//       DBI                       = rx_phy_postflop_0 [ 39];
  assign rx_st_data          [ 36] = rx_phy_postflop_0 [ 40];
  assign rx_st_data          [ 37] = rx_phy_postflop_0 [ 41];
  assign rx_st_data          [ 38] = rx_phy_postflop_0 [ 42];
  assign rx_st_data          [ 39] = rx_phy_postflop_0 [ 43];
  assign rx_st_data          [ 40] = rx_phy_postflop_0 [ 44];
  assign rx_st_data          [ 41] = rx_phy_postflop_0 [ 45];
  assign rx_st_data          [ 42] = rx_phy_postflop_0 [ 46];
  assign rx_st_data          [ 43] = rx_phy_postflop_0 [ 47];
  assign rx_st_data          [ 44] = rx_phy_postflop_0 [ 48];
  assign rx_st_data          [ 45] = rx_phy_postflop_0 [ 49];
  assign rx_st_data          [ 46] = rx_phy_postflop_0 [ 50];
  assign rx_st_data          [ 47] = rx_phy_postflop_0 [ 51];
  assign rx_st_data          [ 48] = rx_phy_postflop_0 [ 52];
  assign rx_st_data          [ 49] = rx_phy_postflop_0 [ 53];
  assign rx_st_data          [ 50] = rx_phy_postflop_0 [ 54];
  assign rx_st_data          [ 51] = rx_phy_postflop_0 [ 55];
  assign rx_st_data          [ 52] = rx_phy_postflop_0 [ 56];
  assign rx_st_data          [ 53] = rx_phy_postflop_0 [ 57];
  assign rx_st_data          [ 54] = rx_phy_postflop_0 [ 58];
  assign rx_st_data          [ 55] = rx_phy_postflop_0 [ 59];
  assign rx_st_data          [ 56] = rx_phy_postflop_0 [ 60];
  assign rx_st_data          [ 57] = rx_phy_postflop_0 [ 61];
  assign rx_st_data          [ 58] = rx_phy_postflop_0 [ 62];
  assign rx_st_data          [ 59] = rx_phy_postflop_0 [ 63];
  assign rx_st_data          [ 60] = rx_phy_postflop_0 [ 64];
  assign rx_st_data          [ 61] = rx_phy_postflop_0 [ 65];
  assign rx_st_data          [ 62] = rx_phy_postflop_0 [ 66];
  assign rx_st_data          [ 63] = rx_phy_postflop_0 [ 67];
  assign rx_st_data          [ 64] = rx_phy_postflop_0 [ 68];
  assign rx_st_data          [ 65] = rx_phy_postflop_0 [ 69];
  assign rx_st_data          [ 66] = rx_phy_postflop_0 [ 70];
  assign rx_st_data          [ 67] = rx_phy_postflop_0 [ 71];
  assign rx_st_data          [ 68] = rx_phy_postflop_0 [ 72];
  assign rx_st_data          [ 69] = rx_phy_postflop_0 [ 73];
  assign rx_st_data          [ 70] = rx_phy_postflop_0 [ 74];
  assign rx_st_data          [ 71] = rx_phy_postflop_0 [ 75];
//       STROBE                    = rx_phy_postflop_0 [ 76]
  assign rx_st_data          [ 72] = rx_phy_postflop_0 [ 77];
//       DBI                       = rx_phy_postflop_0 [ 78];
//       DBI                       = rx_phy_postflop_0 [ 79];
  assign rx_st_data          [ 73] = rx_phy_postflop_0 [ 80];
  assign rx_st_data          [ 74] = rx_phy_postflop_0 [ 81];
  assign rx_st_data          [ 75] = rx_phy_postflop_0 [ 82];
  assign rx_st_data          [ 76] = rx_phy_postflop_0 [ 83];
//       MARKER                    = rx_phy_postflop_0 [ 84]
  assign rx_st_data          [ 77] = rx_phy_postflop_0 [ 85];
  assign rx_st_data          [ 78] = rx_phy_postflop_0 [ 86];
  assign rx_st_data          [ 79] = rx_phy_postflop_0 [ 87];
  assign rx_st_data          [ 80] = rx_phy_postflop_0 [ 88];
  assign rx_st_data          [ 81] = rx_phy_postflop_0 [ 89];
  assign rx_st_data          [ 82] = rx_phy_postflop_0 [ 90];
  assign rx_st_data          [ 83] = rx_phy_postflop_0 [ 91];
  assign rx_st_data          [ 84] = rx_phy_postflop_0 [ 92];
  assign rx_st_data          [ 85] = rx_phy_postflop_0 [ 93];
  assign rx_st_data          [ 86] = rx_phy_postflop_0 [ 94];
  assign rx_st_data          [ 87] = rx_phy_postflop_0 [ 95];
  assign rx_st_data          [ 88] = rx_phy_postflop_0 [ 96];
  assign rx_st_data          [ 89] = rx_phy_postflop_0 [ 97];
  assign rx_st_data          [ 90] = rx_phy_postflop_0 [ 98];
  assign rx_st_data          [ 91] = rx_phy_postflop_0 [ 99];
  assign rx_st_data          [ 92] = rx_phy_postflop_0 [100];
  assign rx_st_data          [ 93] = rx_phy_postflop_0 [101];
  assign rx_st_data          [ 94] = rx_phy_postflop_0 [102];
  assign rx_st_data          [ 95] = rx_phy_postflop_0 [103];
  assign rx_st_data          [ 96] = rx_phy_postflop_0 [104];
  assign rx_st_data          [ 97] = rx_phy_postflop_0 [105];
  assign rx_st_data          [ 98] = rx_phy_postflop_0 [106];
  assign rx_st_data          [ 99] = rx_phy_postflop_0 [107];
  assign rx_st_data          [100] = rx_phy_postflop_0 [108];
  assign rx_st_data          [101] = rx_phy_postflop_0 [109];
  assign rx_st_data          [102] = rx_phy_postflop_0 [110];
  assign rx_st_data          [103] = rx_phy_postflop_0 [111];
  assign rx_st_data          [104] = rx_phy_postflop_0 [112];
  assign rx_st_data          [105] = rx_phy_postflop_0 [113];
  assign rx_st_data          [106] = rx_phy_postflop_0 [114];
  assign rx_st_data          [107] = rx_phy_postflop_0 [115];
  assign rx_st_data          [108] = rx_phy_postflop_0 [116];
  assign rx_st_data          [109] = rx_phy_postflop_0 [117];
//       DBI                       = rx_phy_postflop_0 [118];
//       DBI                       = rx_phy_postflop_0 [119];
  assign rx_st_data          [110] = rx_phy_postflop_0 [120];
  assign rx_st_data          [111] = rx_phy_postflop_0 [121];
  assign rx_st_data          [112] = rx_phy_postflop_0 [122];
  assign rx_st_data          [113] = rx_phy_postflop_0 [123];
  assign rx_st_data          [114] = rx_phy_postflop_0 [124];
  assign rx_st_data          [115] = rx_phy_postflop_0 [125];
  assign rx_st_data          [116] = rx_phy_postflop_0 [126];
  assign rx_st_data          [117] = rx_phy_postflop_0 [127];
  assign rx_st_data          [118] = rx_phy_postflop_0 [128];
  assign rx_st_data          [119] = rx_phy_postflop_0 [129];
  assign rx_st_data          [120] = rx_phy_postflop_0 [130];
  assign rx_st_data          [121] = rx_phy_postflop_0 [131];
  assign rx_st_data          [122] = rx_phy_postflop_0 [132];
  assign rx_st_data          [123] = rx_phy_postflop_0 [133];
  assign rx_st_data          [124] = rx_phy_postflop_0 [134];
  assign rx_st_data          [125] = rx_phy_postflop_0 [135];
  assign rx_st_data          [126] = rx_phy_postflop_0 [136];
  assign rx_st_data          [127] = rx_phy_postflop_0 [137];
  assign rx_st_data          [128] = rx_phy_postflop_0 [138];
  assign rx_st_data          [129] = rx_phy_postflop_0 [139];
  assign rx_st_data          [130] = rx_phy_postflop_0 [140];
  assign rx_st_data          [131] = rx_phy_postflop_0 [141];
  assign rx_st_data          [132] = rx_phy_postflop_0 [142];
  assign rx_st_data          [133] = rx_phy_postflop_0 [143];
  assign rx_st_data          [134] = rx_phy_postflop_0 [144];
  assign rx_st_data          [135] = rx_phy_postflop_0 [145];
  assign rx_st_data          [136] = rx_phy_postflop_0 [146];
  assign rx_st_data          [137] = rx_phy_postflop_0 [147];
  assign rx_st_data          [138] = rx_phy_postflop_0 [148];
  assign rx_st_data          [139] = rx_phy_postflop_0 [149];
  assign rx_st_data          [140] = rx_phy_postflop_0 [150];
  assign rx_st_data          [141] = rx_phy_postflop_0 [151];
  assign rx_st_data          [142] = rx_phy_postflop_0 [152];
  assign rx_st_data          [143] = rx_phy_postflop_0 [153];
  assign rx_st_data          [144] = rx_phy_postflop_0 [154];
  assign rx_st_data          [145] = rx_phy_postflop_0 [155];
  assign rx_st_data          [146] = rx_phy_postflop_0 [156];
  assign rx_st_data          [147] = rx_phy_postflop_0 [157];
//       DBI                       = rx_phy_postflop_0 [158];
//       DBI                       = rx_phy_postflop_0 [159];
  assign rx_st_data          [148] = rx_phy_postflop_1 [  0];
  assign rx_st_data          [149] = rx_phy_postflop_1 [  1];
  assign rx_st_data          [150] = rx_phy_postflop_1 [  2];
  assign rx_st_data          [151] = rx_phy_postflop_1 [  3];
//       MARKER                    = rx_phy_postflop_1 [  4]
  assign rx_st_data          [152] = rx_phy_postflop_1 [  5];
  assign rx_st_data          [153] = rx_phy_postflop_1 [  6];
  assign rx_st_data          [154] = rx_phy_postflop_1 [  7];
  assign rx_st_data          [155] = rx_phy_postflop_1 [  8];
  assign rx_st_data          [156] = rx_phy_postflop_1 [  9];
  assign rx_st_data          [157] = rx_phy_postflop_1 [ 10];
  assign rx_st_data          [158] = rx_phy_postflop_1 [ 11];
  assign rx_st_data          [159] = rx_phy_postflop_1 [ 12];
  assign rx_st_data          [160] = rx_phy_postflop_1 [ 13];
  assign rx_st_data          [161] = rx_phy_postflop_1 [ 14];
  assign rx_st_data          [162] = rx_phy_postflop_1 [ 15];
  assign rx_st_data          [163] = rx_phy_postflop_1 [ 16];
  assign rx_st_data          [164] = rx_phy_postflop_1 [ 17];
  assign rx_st_data          [165] = rx_phy_postflop_1 [ 18];
  assign rx_st_data          [166] = rx_phy_postflop_1 [ 19];
  assign rx_st_data          [167] = rx_phy_postflop_1 [ 20];
  assign rx_st_data          [168] = rx_phy_postflop_1 [ 21];
  assign rx_st_data          [169] = rx_phy_postflop_1 [ 22];
  assign rx_st_data          [170] = rx_phy_postflop_1 [ 23];
  assign rx_st_data          [171] = rx_phy_postflop_1 [ 24];
  assign rx_st_data          [172] = rx_phy_postflop_1 [ 25];
  assign rx_st_data          [173] = rx_phy_postflop_1 [ 26];
  assign rx_st_data          [174] = rx_phy_postflop_1 [ 27];
  assign rx_st_data          [175] = rx_phy_postflop_1 [ 28];
  assign rx_st_data          [176] = rx_phy_postflop_1 [ 29];
  assign rx_st_data          [177] = rx_phy_postflop_1 [ 30];
  assign rx_st_data          [178] = rx_phy_postflop_1 [ 31];
  assign rx_st_data          [179] = rx_phy_postflop_1 [ 32];
  assign rx_st_data          [180] = rx_phy_postflop_1 [ 33];
  assign rx_st_data          [181] = rx_phy_postflop_1 [ 34];
  assign rx_st_data          [182] = rx_phy_postflop_1 [ 35];
  assign rx_st_data          [183] = rx_phy_postflop_1 [ 36];
  assign rx_st_data          [184] = rx_phy_postflop_1 [ 37];
//       DBI                       = rx_phy_postflop_1 [ 38];
//       DBI                       = rx_phy_postflop_1 [ 39];
  assign rx_st_data          [185] = rx_phy_postflop_1 [ 40];
  assign rx_st_data          [186] = rx_phy_postflop_1 [ 41];
  assign rx_st_data          [187] = rx_phy_postflop_1 [ 42];
  assign rx_st_data          [188] = rx_phy_postflop_1 [ 43];
  assign rx_st_data          [189] = rx_phy_postflop_1 [ 44];
  assign rx_st_data          [190] = rx_phy_postflop_1 [ 45];
  assign rx_st_data          [191] = rx_phy_postflop_1 [ 46];
  assign rx_st_data          [192] = rx_phy_postflop_1 [ 47];
  assign rx_st_data          [193] = rx_phy_postflop_1 [ 48];
  assign rx_st_data          [194] = rx_phy_postflop_1 [ 49];
  assign rx_st_data          [195] = rx_phy_postflop_1 [ 50];
  assign rx_st_data          [196] = rx_phy_postflop_1 [ 51];
  assign rx_st_data          [197] = rx_phy_postflop_1 [ 52];
  assign rx_st_data          [198] = rx_phy_postflop_1 [ 53];
  assign rx_st_data          [199] = rx_phy_postflop_1 [ 54];
  assign rx_st_data          [200] = rx_phy_postflop_1 [ 55];
  assign rx_st_data          [201] = rx_phy_postflop_1 [ 56];
  assign rx_st_data          [202] = rx_phy_postflop_1 [ 57];
  assign rx_st_data          [203] = rx_phy_postflop_1 [ 58];
  assign rx_st_data          [204] = rx_phy_postflop_1 [ 59];
  assign rx_st_data          [205] = rx_phy_postflop_1 [ 60];
  assign rx_st_data          [206] = rx_phy_postflop_1 [ 61];
  assign rx_st_data          [207] = rx_phy_postflop_1 [ 62];
  assign rx_st_data          [208] = rx_phy_postflop_1 [ 63];
  assign rx_st_data          [209] = rx_phy_postflop_1 [ 64];
  assign rx_st_data          [210] = rx_phy_postflop_1 [ 65];
  assign rx_st_data          [211] = rx_phy_postflop_1 [ 66];
  assign rx_st_data          [212] = rx_phy_postflop_1 [ 67];
  assign rx_st_data          [213] = rx_phy_postflop_1 [ 68];
  assign rx_st_data          [214] = rx_phy_postflop_1 [ 69];
  assign rx_st_data          [215] = rx_phy_postflop_1 [ 70];
  assign rx_st_data          [216] = rx_phy_postflop_1 [ 71];
  assign rx_st_data          [217] = rx_phy_postflop_1 [ 72];
  assign rx_st_data          [218] = rx_phy_postflop_1 [ 73];
  assign rx_st_data          [219] = rx_phy_postflop_1 [ 74];
  assign rx_st_data          [220] = rx_phy_postflop_1 [ 75];
//       STROBE                    = rx_phy_postflop_1 [ 76]
  assign rx_st_data          [221] = rx_phy_postflop_1 [ 77];
//       DBI                       = rx_phy_postflop_1 [ 78];
//       DBI                       = rx_phy_postflop_1 [ 79];
  assign rx_st_data          [222] = rx_phy_postflop_1 [ 80];
  assign rx_st_data          [223] = rx_phy_postflop_1 [ 81];
  assign rx_st_data          [224] = rx_phy_postflop_1 [ 82];
  assign rx_st_data          [225] = rx_phy_postflop_1 [ 83];
//       MARKER                    = rx_phy_postflop_1 [ 84]
  assign rx_st_data          [226] = rx_phy_postflop_1 [ 85];
  assign rx_st_data          [227] = rx_phy_postflop_1 [ 86];
  assign rx_st_data          [228] = rx_phy_postflop_1 [ 87];
  assign rx_st_data          [229] = rx_phy_postflop_1 [ 88];
  assign rx_st_data          [230] = rx_phy_postflop_1 [ 89];
  assign rx_st_data          [231] = rx_phy_postflop_1 [ 90];
  assign rx_st_data          [232] = rx_phy_postflop_1 [ 91];
  assign rx_st_data          [233] = rx_phy_postflop_1 [ 92];
  assign rx_st_data          [234] = rx_phy_postflop_1 [ 93];
  assign rx_st_data          [235] = rx_phy_postflop_1 [ 94];
  assign rx_st_data          [236] = rx_phy_postflop_1 [ 95];
  assign rx_st_data          [237] = rx_phy_postflop_1 [ 96];
  assign rx_st_data          [238] = rx_phy_postflop_1 [ 97];
  assign rx_st_data          [239] = rx_phy_postflop_1 [ 98];
  assign rx_st_data          [240] = rx_phy_postflop_1 [ 99];
  assign rx_st_data          [241] = rx_phy_postflop_1 [100];
  assign rx_st_data          [242] = rx_phy_postflop_1 [101];
  assign rx_st_data          [243] = rx_phy_postflop_1 [102];
  assign rx_st_data          [244] = rx_phy_postflop_1 [103];
  assign rx_st_data          [245] = rx_phy_postflop_1 [104];
  assign rx_st_data          [246] = rx_phy_postflop_1 [105];
  assign rx_st_data          [247] = rx_phy_postflop_1 [106];
  assign rx_st_data          [248] = rx_phy_postflop_1 [107];
  assign rx_st_data          [249] = rx_phy_postflop_1 [108];
  assign rx_st_data          [250] = rx_phy_postflop_1 [109];
  assign rx_st_data          [251] = rx_phy_postflop_1 [110];
  assign rx_st_data          [252] = rx_phy_postflop_1 [111];
  assign rx_st_data          [253] = rx_phy_postflop_1 [112];
  assign rx_st_data          [254] = rx_phy_postflop_1 [113];
  assign rx_st_data          [255] = rx_phy_postflop_1 [114];
  assign rx_st_data          [256] = rx_phy_postflop_1 [115];
  assign rx_st_data          [257] = rx_phy_postflop_1 [116];
  assign rx_st_data          [258] = rx_phy_postflop_1 [117];
//       DBI                       = rx_phy_postflop_1 [118];
//       DBI                       = rx_phy_postflop_1 [119];
  assign rx_st_data          [259] = rx_phy_postflop_1 [120];
  assign rx_st_data          [260] = rx_phy_postflop_1 [121];
  assign rx_st_data          [261] = rx_phy_postflop_1 [122];
  assign rx_st_data          [262] = rx_phy_postflop_1 [123];
  assign rx_st_data          [263] = rx_phy_postflop_1 [124];
  assign rx_st_data          [264] = rx_phy_postflop_1 [125];
  assign rx_st_data          [265] = rx_phy_postflop_1 [126];
  assign rx_st_data          [266] = rx_phy_postflop_1 [127];
  assign rx_st_data          [267] = rx_phy_postflop_1 [128];
  assign rx_st_data          [268] = rx_phy_postflop_1 [129];
  assign rx_st_data          [269] = rx_phy_postflop_1 [130];
  assign rx_st_data          [270] = rx_phy_postflop_1 [131];
  assign rx_st_data          [271] = rx_phy_postflop_1 [132];
  assign rx_st_data          [272] = rx_phy_postflop_1 [133];
  assign rx_st_data          [273] = rx_phy_postflop_1 [134];
  assign rx_st_data          [274] = rx_phy_postflop_1 [135];
  assign rx_st_data          [275] = rx_phy_postflop_1 [136];
  assign rx_st_data          [276] = rx_phy_postflop_1 [137];
  assign rx_st_data          [277] = rx_phy_postflop_1 [138];
  assign rx_st_data          [278] = rx_phy_postflop_1 [139];
  assign rx_st_data          [279] = rx_phy_postflop_1 [140];
  assign rx_st_data          [280] = rx_phy_postflop_1 [141];
  assign rx_st_data          [281] = rx_phy_postflop_1 [142];
  assign rx_st_data          [282] = rx_phy_postflop_1 [143];
  assign rx_st_data          [283] = rx_phy_postflop_1 [144];
  assign rx_st_data          [284] = rx_phy_postflop_1 [145];
  assign rx_st_data          [285] = rx_phy_postflop_1 [146];
  assign rx_st_data          [286] = rx_phy_postflop_1 [147];
  assign rx_st_data          [287] = rx_phy_postflop_1 [148];
  assign rx_st_data          [288] = rx_phy_postflop_1 [149];
//       nc                        = rx_phy_postflop_1 [150];
//       nc                        = rx_phy_postflop_1 [151];
//       nc                        = rx_phy_postflop_1 [152];
//       nc                        = rx_phy_postflop_1 [153];
//       nc                        = rx_phy_postflop_1 [154];
//       nc                        = rx_phy_postflop_1 [155];
//       nc                        = rx_phy_postflop_1 [156];
//       nc                        = rx_phy_postflop_1 [157];
//       DBI                       = rx_phy_postflop_1 [158];
//       DBI                       = rx_phy_postflop_1 [159];

// RX Section
////////////////////////////////////////////////////////////


endmodule
