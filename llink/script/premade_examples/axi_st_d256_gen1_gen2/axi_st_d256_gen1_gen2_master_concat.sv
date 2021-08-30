module axi_st_d256_gen1_gen2_master_concat  (

// Data from Logic Links
  input  logic [ 288:   0]   tx_st_data          ,
  output logic               tx_st_pop_ovrd      ,
  input  logic               tx_st_pushbit       ,
  output logic               rx_st_credit        ,

// PHY Interconnect
  output logic [ 159:   0]   tx_phy0             ,
  input  logic [ 159:   0]   rx_phy0             ,
  output logic [ 159:   0]   tx_phy1             ,
  input  logic [ 159:   0]   rx_phy1             ,

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
  assign tx_st_pop_ovrd                     = 1'b0                               ;

// No RX Packetization, so tie off packetization signals

//////////////////////////////////////////////////////////////////
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

  localparam TX_REG_PHY    = 1'b0;  // If set, this enables boundary FF for timing reasons

  logic [ 159:   0]                              tx_phy_preflop_0              ;
  logic [ 159:   0]                              tx_phy_preflop_1              ;
  logic [ 159:   0]                              tx_phy_flop_0_reg             ;
  logic [ 159:   0]                              tx_phy_flop_1_reg             ;

  always_ff @(posedge clk_wr or negedge rst_wr_n)
  if (~rst_wr_n)
  begin
    tx_phy_flop_0_reg                       <= 160'b0                                  ;
    tx_phy_flop_1_reg                       <= 160'b0                                  ;
  end
  else
  begin
    tx_phy_flop_0_reg                       <= tx_phy_preflop_0                        ;
    tx_phy_flop_1_reg                       <= tx_phy_preflop_1                        ;
  end

  assign tx_phy0                            = TX_REG_PHY ? tx_phy_flop_0_reg : tx_phy_preflop_0               ;
  assign tx_phy1                            = TX_REG_PHY ? tx_phy_flop_1_reg : tx_phy_preflop_1               ;

  assign tx_phy_preflop_0 [   0] = m_gen2_mode ? tx_st_pushbit             : tx_st_pushbit             ;  // Gen2 ? tx_st_pushbit        : tx_st_pushbit       
  assign tx_phy_preflop_0 [   1] = m_gen2_mode ? tx_st_data          [   0] : tx_st_data          [   0];  // Gen2 ? user_tkeep[0]        : user_tkeep[0]       
  assign tx_phy_preflop_0 [   2] = m_gen2_mode ? tx_st_data          [   1] : tx_st_data          [   1];  // Gen2 ? user_tkeep[1]        : user_tkeep[1]       
  assign tx_phy_preflop_0 [   3] = m_gen2_mode ? tx_st_data          [   2] : tx_st_data          [   2];  // Gen2 ? user_tkeep[2]        : user_tkeep[2]       
  assign tx_phy_preflop_0 [   4] = m_gen2_mode ? tx_mrk_userbit[0]         : tx_st_data          [   3];  // Gen2 ? MARKER               : user_tkeep[3]       
  assign tx_phy_preflop_0 [   5] = m_gen2_mode ? tx_st_data          [   3] : tx_st_data          [   4];  // Gen2 ? user_tkeep[3]        : user_tkeep[4]       
  assign tx_phy_preflop_0 [   6] = m_gen2_mode ? tx_st_data          [   4] : tx_st_data          [   5];  // Gen2 ? user_tkeep[4]        : user_tkeep[5]       
  assign tx_phy_preflop_0 [   7] = m_gen2_mode ? tx_st_data          [   5] : tx_st_data          [   6];  // Gen2 ? user_tkeep[5]        : user_tkeep[6]       
  assign tx_phy_preflop_0 [   8] = m_gen2_mode ? tx_st_data          [   6] : tx_st_data          [   7];  // Gen2 ? user_tkeep[6]        : user_tkeep[7]       
  assign tx_phy_preflop_0 [   9] = m_gen2_mode ? tx_st_data          [   7] : tx_st_data          [  32];  // Gen2 ? user_tkeep[7]        : user_tdata[0]       
  assign tx_phy_preflop_0 [  10] = m_gen2_mode ? tx_st_data          [   8] : tx_st_data          [  33];  // Gen2 ? user_tkeep[8]        : user_tdata[1]       
  assign tx_phy_preflop_0 [  11] = m_gen2_mode ? tx_st_data          [   9] : tx_st_data          [  34];  // Gen2 ? user_tkeep[9]        : user_tdata[2]       
  assign tx_phy_preflop_0 [  12] = m_gen2_mode ? tx_st_data          [  10] : tx_st_data          [  35];  // Gen2 ? user_tkeep[10]       : user_tdata[3]       
  assign tx_phy_preflop_0 [  13] = m_gen2_mode ? tx_st_data          [  11] : tx_st_data          [  36];  // Gen2 ? user_tkeep[11]       : user_tdata[4]       
  assign tx_phy_preflop_0 [  14] = m_gen2_mode ? tx_st_data          [  12] : tx_st_data          [  37];  // Gen2 ? user_tkeep[12]       : user_tdata[5]       
  assign tx_phy_preflop_0 [  15] = m_gen2_mode ? tx_st_data          [  13] : tx_st_data          [  38];  // Gen2 ? user_tkeep[13]       : user_tdata[6]       
  assign tx_phy_preflop_0 [  16] = m_gen2_mode ? tx_st_data          [  14] : tx_st_data          [  39];  // Gen2 ? user_tkeep[14]       : user_tdata[7]       
  assign tx_phy_preflop_0 [  17] = m_gen2_mode ? tx_st_data          [  15] : tx_st_data          [  40];  // Gen2 ? user_tkeep[15]       : user_tdata[8]       
  assign tx_phy_preflop_0 [  18] = m_gen2_mode ? tx_st_data          [  16] : tx_st_data          [  41];  // Gen2 ? user_tkeep[16]       : user_tdata[9]       
  assign tx_phy_preflop_0 [  19] = m_gen2_mode ? tx_st_data          [  17] : tx_st_data          [  42];  // Gen2 ? user_tkeep[17]       : user_tdata[10]      
  assign tx_phy_preflop_0 [  20] = m_gen2_mode ? tx_st_data          [  18] : tx_st_data          [  43];  // Gen2 ? user_tkeep[18]       : user_tdata[11]      
  assign tx_phy_preflop_0 [  21] = m_gen2_mode ? tx_st_data          [  19] : tx_st_data          [  44];  // Gen2 ? user_tkeep[19]       : user_tdata[12]      
  assign tx_phy_preflop_0 [  22] = m_gen2_mode ? tx_st_data          [  20] : tx_st_data          [  45];  // Gen2 ? user_tkeep[20]       : user_tdata[13]      
  assign tx_phy_preflop_0 [  23] = m_gen2_mode ? tx_st_data          [  21] : tx_st_data          [  46];  // Gen2 ? user_tkeep[21]       : user_tdata[14]      
  assign tx_phy_preflop_0 [  24] = m_gen2_mode ? tx_st_data          [  22] : tx_st_data          [  47];  // Gen2 ? user_tkeep[22]       : user_tdata[15]      
  assign tx_phy_preflop_0 [  25] = m_gen2_mode ? tx_st_data          [  23] : tx_st_data          [  48];  // Gen2 ? user_tkeep[23]       : user_tdata[16]      
  assign tx_phy_preflop_0 [  26] = m_gen2_mode ? tx_st_data          [  24] : tx_st_data          [  49];  // Gen2 ? user_tkeep[24]       : user_tdata[17]      
  assign tx_phy_preflop_0 [  27] = m_gen2_mode ? tx_st_data          [  25] : tx_st_data          [  50];  // Gen2 ? user_tkeep[25]       : user_tdata[18]      
  assign tx_phy_preflop_0 [  28] = m_gen2_mode ? tx_st_data          [  26] : tx_st_data          [  51];  // Gen2 ? user_tkeep[26]       : user_tdata[19]      
  assign tx_phy_preflop_0 [  29] = m_gen2_mode ? tx_st_data          [  27] : tx_st_data          [  52];  // Gen2 ? user_tkeep[27]       : user_tdata[20]      
  assign tx_phy_preflop_0 [  30] = m_gen2_mode ? tx_st_data          [  28] : tx_st_data          [  53];  // Gen2 ? user_tkeep[28]       : user_tdata[21]      
  assign tx_phy_preflop_0 [  31] = m_gen2_mode ? tx_st_data          [  29] : tx_st_data          [  54];  // Gen2 ? user_tkeep[29]       : user_tdata[22]      
  assign tx_phy_preflop_0 [  32] = m_gen2_mode ? tx_st_data          [  30] : tx_st_data          [  55];  // Gen2 ? user_tkeep[30]       : user_tdata[23]      
  assign tx_phy_preflop_0 [  33] = m_gen2_mode ? tx_st_data          [  31] : tx_st_data          [  56];  // Gen2 ? user_tkeep[31]       : user_tdata[24]      
  assign tx_phy_preflop_0 [  34] = m_gen2_mode ? tx_st_data          [  32] : tx_st_data          [  57];  // Gen2 ? user_tdata[0]        : user_tdata[25]      
  assign tx_phy_preflop_0 [  35] = m_gen2_mode ? tx_st_data          [  33] : tx_stb_userbit            ;  // Gen2 ? user_tdata[1]        : STROBE              
  assign tx_phy_preflop_0 [  36] = m_gen2_mode ? tx_st_data          [  34] : tx_st_data          [  58];  // Gen2 ? user_tdata[2]        : user_tdata[26]      
  assign tx_phy_preflop_0 [  37] = m_gen2_mode ? tx_st_data          [  35] : tx_st_data          [  59];  // Gen2 ? user_tdata[3]        : user_tdata[27]      
  assign tx_phy_preflop_0 [  38] = m_gen2_mode ? 1'b0                      : tx_st_data          [  60];  // Gen2 ? DBI                  : user_tdata[28]      
  assign tx_phy_preflop_0 [  39] = m_gen2_mode ? 1'b0                      : tx_mrk_userbit[0]         ;  // Gen2 ? DBI                  : MARKER              
  assign tx_phy_preflop_0 [  40] = m_gen2_mode ? tx_st_data          [  36] : 1'b0                      ;  // Gen2 ? user_tdata[4]        : UNUSED              
  assign tx_phy_preflop_0 [  41] = m_gen2_mode ? tx_st_data          [  37] : 1'b0                      ;  // Gen2 ? user_tdata[5]        : UNUSED              
  assign tx_phy_preflop_0 [  42] = m_gen2_mode ? tx_st_data          [  38] : 1'b0                      ;  // Gen2 ? user_tdata[6]        : UNUSED              
  assign tx_phy_preflop_0 [  43] = m_gen2_mode ? tx_st_data          [  39] : 1'b0                      ;  // Gen2 ? user_tdata[7]        : UNUSED              
  assign tx_phy_preflop_0 [  44] = m_gen2_mode ? tx_st_data          [  40] : 1'b0                      ;  // Gen2 ? user_tdata[8]        : UNUSED              
  assign tx_phy_preflop_0 [  45] = m_gen2_mode ? tx_st_data          [  41] : 1'b0                      ;  // Gen2 ? user_tdata[9]        : UNUSED              
  assign tx_phy_preflop_0 [  46] = m_gen2_mode ? tx_st_data          [  42] : 1'b0                      ;  // Gen2 ? user_tdata[10]       : UNUSED              
  assign tx_phy_preflop_0 [  47] = m_gen2_mode ? tx_st_data          [  43] : 1'b0                      ;  // Gen2 ? user_tdata[11]       : UNUSED              
  assign tx_phy_preflop_0 [  48] = m_gen2_mode ? tx_st_data          [  44] : 1'b0                      ;  // Gen2 ? user_tdata[12]       : UNUSED              
  assign tx_phy_preflop_0 [  49] = m_gen2_mode ? tx_st_data          [  45] : 1'b0                      ;  // Gen2 ? user_tdata[13]       : UNUSED              
  assign tx_phy_preflop_0 [  50] = m_gen2_mode ? tx_st_data          [  46] : 1'b0                      ;  // Gen2 ? user_tdata[14]       : UNUSED              
  assign tx_phy_preflop_0 [  51] = m_gen2_mode ? tx_st_data          [  47] : 1'b0                      ;  // Gen2 ? user_tdata[15]       : UNUSED              
  assign tx_phy_preflop_0 [  52] = m_gen2_mode ? tx_st_data          [  48] : 1'b0                      ;  // Gen2 ? user_tdata[16]       : UNUSED              
  assign tx_phy_preflop_0 [  53] = m_gen2_mode ? tx_st_data          [  49] : 1'b0                      ;  // Gen2 ? user_tdata[17]       : UNUSED              
  assign tx_phy_preflop_0 [  54] = m_gen2_mode ? tx_st_data          [  50] : 1'b0                      ;  // Gen2 ? user_tdata[18]       : UNUSED              
  assign tx_phy_preflop_0 [  55] = m_gen2_mode ? tx_st_data          [  51] : 1'b0                      ;  // Gen2 ? user_tdata[19]       : UNUSED              
  assign tx_phy_preflop_0 [  56] = m_gen2_mode ? tx_st_data          [  52] : 1'b0                      ;  // Gen2 ? user_tdata[20]       : UNUSED              
  assign tx_phy_preflop_0 [  57] = m_gen2_mode ? tx_st_data          [  53] : 1'b0                      ;  // Gen2 ? user_tdata[21]       : UNUSED              
  assign tx_phy_preflop_0 [  58] = m_gen2_mode ? tx_st_data          [  54] : 1'b0                      ;  // Gen2 ? user_tdata[22]       : UNUSED              
  assign tx_phy_preflop_0 [  59] = m_gen2_mode ? tx_st_data          [  55] : 1'b0                      ;  // Gen2 ? user_tdata[23]       : UNUSED              
  assign tx_phy_preflop_0 [  60] = m_gen2_mode ? tx_st_data          [  56] : 1'b0                      ;  // Gen2 ? user_tdata[24]       : UNUSED              
  assign tx_phy_preflop_0 [  61] = m_gen2_mode ? tx_st_data          [  57] : 1'b0                      ;  // Gen2 ? user_tdata[25]       : UNUSED              
  assign tx_phy_preflop_0 [  62] = m_gen2_mode ? tx_st_data          [  58] : 1'b0                      ;  // Gen2 ? user_tdata[26]       : UNUSED              
  assign tx_phy_preflop_0 [  63] = m_gen2_mode ? tx_st_data          [  59] : 1'b0                      ;  // Gen2 ? user_tdata[27]       : UNUSED              
  assign tx_phy_preflop_0 [  64] = m_gen2_mode ? tx_st_data          [  60] : 1'b0                      ;  // Gen2 ? user_tdata[28]       : UNUSED              
  assign tx_phy_preflop_0 [  65] = m_gen2_mode ? tx_st_data          [  61] : 1'b0                      ;  // Gen2 ? user_tdata[29]       : UNUSED              
  assign tx_phy_preflop_0 [  66] = m_gen2_mode ? tx_st_data          [  62] : 1'b0                      ;  // Gen2 ? user_tdata[30]       : UNUSED              
  assign tx_phy_preflop_0 [  67] = m_gen2_mode ? tx_st_data          [  63] : 1'b0                      ;  // Gen2 ? user_tdata[31]       : UNUSED              
  assign tx_phy_preflop_0 [  68] = m_gen2_mode ? tx_st_data          [  64] : 1'b0                      ;  // Gen2 ? user_tdata[32]       : UNUSED              
  assign tx_phy_preflop_0 [  69] = m_gen2_mode ? tx_st_data          [  65] : 1'b0                      ;  // Gen2 ? user_tdata[33]       : UNUSED              
  assign tx_phy_preflop_0 [  70] = m_gen2_mode ? tx_st_data          [  66] : 1'b0                      ;  // Gen2 ? user_tdata[34]       : UNUSED              
  assign tx_phy_preflop_0 [  71] = m_gen2_mode ? tx_st_data          [  67] : 1'b0                      ;  // Gen2 ? user_tdata[35]       : UNUSED              
  assign tx_phy_preflop_0 [  72] = m_gen2_mode ? tx_st_data          [  68] : 1'b0                      ;  // Gen2 ? user_tdata[36]       : UNUSED              
  assign tx_phy_preflop_0 [  73] = m_gen2_mode ? tx_st_data          [  69] : 1'b0                      ;  // Gen2 ? user_tdata[37]       : UNUSED              
  assign tx_phy_preflop_0 [  74] = m_gen2_mode ? tx_st_data          [  70] : 1'b0                      ;  // Gen2 ? user_tdata[38]       : UNUSED              
  assign tx_phy_preflop_0 [  75] = m_gen2_mode ? tx_st_data          [  71] : 1'b0                      ;  // Gen2 ? user_tdata[39]       : UNUSED              
  assign tx_phy_preflop_0 [  76] = m_gen2_mode ? tx_stb_userbit            : 1'b0                      ;  // Gen2 ? STROBE               : UNUSED              
  assign tx_phy_preflop_0 [  77] = m_gen2_mode ? tx_st_data          [  72] : 1'b0                      ;  // Gen2 ? user_tdata[40]       : UNUSED              
  assign tx_phy_preflop_0 [  78] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_0 [  79] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_0 [  80] = m_gen2_mode ? tx_st_data          [  73] : 1'b0                      ;  // Gen2 ? user_tdata[41]       : UNUSED              
  assign tx_phy_preflop_0 [  81] = m_gen2_mode ? tx_st_data          [  74] : 1'b0                      ;  // Gen2 ? user_tdata[42]       : UNUSED              
  assign tx_phy_preflop_0 [  82] = m_gen2_mode ? tx_st_data          [  75] : 1'b0                      ;  // Gen2 ? user_tdata[43]       : UNUSED              
  assign tx_phy_preflop_0 [  83] = m_gen2_mode ? tx_st_data          [  76] : 1'b0                      ;  // Gen2 ? user_tdata[44]       : UNUSED              
  assign tx_phy_preflop_0 [  84] = m_gen2_mode ? tx_mrk_userbit[1]         : 1'b0                      ;  // Gen2 ? MARKER               : UNUSED              
  assign tx_phy_preflop_0 [  85] = m_gen2_mode ? tx_st_data          [  77] : 1'b0                      ;  // Gen2 ? user_tdata[45]       : UNUSED              
  assign tx_phy_preflop_0 [  86] = m_gen2_mode ? tx_st_data          [  78] : 1'b0                      ;  // Gen2 ? user_tdata[46]       : UNUSED              
  assign tx_phy_preflop_0 [  87] = m_gen2_mode ? tx_st_data          [  79] : 1'b0                      ;  // Gen2 ? user_tdata[47]       : UNUSED              
  assign tx_phy_preflop_0 [  88] = m_gen2_mode ? tx_st_data          [  80] : 1'b0                      ;  // Gen2 ? user_tdata[48]       : UNUSED              
  assign tx_phy_preflop_0 [  89] = m_gen2_mode ? tx_st_data          [  81] : 1'b0                      ;  // Gen2 ? user_tdata[49]       : UNUSED              
  assign tx_phy_preflop_0 [  90] = m_gen2_mode ? tx_st_data          [  82] : 1'b0                      ;  // Gen2 ? user_tdata[50]       : UNUSED              
  assign tx_phy_preflop_0 [  91] = m_gen2_mode ? tx_st_data          [  83] : 1'b0                      ;  // Gen2 ? user_tdata[51]       : UNUSED              
  assign tx_phy_preflop_0 [  92] = m_gen2_mode ? tx_st_data          [  84] : 1'b0                      ;  // Gen2 ? user_tdata[52]       : UNUSED              
  assign tx_phy_preflop_0 [  93] = m_gen2_mode ? tx_st_data          [  85] : 1'b0                      ;  // Gen2 ? user_tdata[53]       : UNUSED              
  assign tx_phy_preflop_0 [  94] = m_gen2_mode ? tx_st_data          [  86] : 1'b0                      ;  // Gen2 ? user_tdata[54]       : UNUSED              
  assign tx_phy_preflop_0 [  95] = m_gen2_mode ? tx_st_data          [  87] : 1'b0                      ;  // Gen2 ? user_tdata[55]       : UNUSED              
  assign tx_phy_preflop_0 [  96] = m_gen2_mode ? tx_st_data          [  88] : 1'b0                      ;  // Gen2 ? user_tdata[56]       : UNUSED              
  assign tx_phy_preflop_0 [  97] = m_gen2_mode ? tx_st_data          [  89] : 1'b0                      ;  // Gen2 ? user_tdata[57]       : UNUSED              
  assign tx_phy_preflop_0 [  98] = m_gen2_mode ? tx_st_data          [  90] : 1'b0                      ;  // Gen2 ? user_tdata[58]       : UNUSED              
  assign tx_phy_preflop_0 [  99] = m_gen2_mode ? tx_st_data          [  91] : 1'b0                      ;  // Gen2 ? user_tdata[59]       : UNUSED              
  assign tx_phy_preflop_0 [ 100] = m_gen2_mode ? tx_st_data          [  92] : 1'b0                      ;  // Gen2 ? user_tdata[60]       : UNUSED              
  assign tx_phy_preflop_0 [ 101] = m_gen2_mode ? tx_st_data          [  93] : 1'b0                      ;  // Gen2 ? user_tdata[61]       : UNUSED              
  assign tx_phy_preflop_0 [ 102] = m_gen2_mode ? tx_st_data          [  94] : 1'b0                      ;  // Gen2 ? user_tdata[62]       : UNUSED              
  assign tx_phy_preflop_0 [ 103] = m_gen2_mode ? tx_st_data          [  95] : 1'b0                      ;  // Gen2 ? user_tdata[63]       : UNUSED              
  assign tx_phy_preflop_0 [ 104] = m_gen2_mode ? tx_st_data          [  96] : 1'b0                      ;  // Gen2 ? user_tdata[64]       : UNUSED              
  assign tx_phy_preflop_0 [ 105] = m_gen2_mode ? tx_st_data          [  97] : 1'b0                      ;  // Gen2 ? user_tdata[65]       : UNUSED              
  assign tx_phy_preflop_0 [ 106] = m_gen2_mode ? tx_st_data          [  98] : 1'b0                      ;  // Gen2 ? user_tdata[66]       : UNUSED              
  assign tx_phy_preflop_0 [ 107] = m_gen2_mode ? tx_st_data          [  99] : 1'b0                      ;  // Gen2 ? user_tdata[67]       : UNUSED              
  assign tx_phy_preflop_0 [ 108] = m_gen2_mode ? tx_st_data          [ 100] : 1'b0                      ;  // Gen2 ? user_tdata[68]       : UNUSED              
  assign tx_phy_preflop_0 [ 109] = m_gen2_mode ? tx_st_data          [ 101] : 1'b0                      ;  // Gen2 ? user_tdata[69]       : UNUSED              
  assign tx_phy_preflop_0 [ 110] = m_gen2_mode ? tx_st_data          [ 102] : 1'b0                      ;  // Gen2 ? user_tdata[70]       : UNUSED              
  assign tx_phy_preflop_0 [ 111] = m_gen2_mode ? tx_st_data          [ 103] : 1'b0                      ;  // Gen2 ? user_tdata[71]       : UNUSED              
  assign tx_phy_preflop_0 [ 112] = m_gen2_mode ? tx_st_data          [ 104] : 1'b0                      ;  // Gen2 ? user_tdata[72]       : UNUSED              
  assign tx_phy_preflop_0 [ 113] = m_gen2_mode ? tx_st_data          [ 105] : 1'b0                      ;  // Gen2 ? user_tdata[73]       : UNUSED              
  assign tx_phy_preflop_0 [ 114] = m_gen2_mode ? tx_st_data          [ 106] : 1'b0                      ;  // Gen2 ? user_tdata[74]       : UNUSED              
  assign tx_phy_preflop_0 [ 115] = m_gen2_mode ? tx_st_data          [ 107] : 1'b0                      ;  // Gen2 ? user_tdata[75]       : UNUSED              
  assign tx_phy_preflop_0 [ 116] = m_gen2_mode ? tx_st_data          [ 108] : 1'b0                      ;  // Gen2 ? user_tdata[76]       : UNUSED              
  assign tx_phy_preflop_0 [ 117] = m_gen2_mode ? tx_st_data          [ 109] : 1'b0                      ;  // Gen2 ? user_tdata[77]       : UNUSED              
  assign tx_phy_preflop_0 [ 118] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_0 [ 119] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_0 [ 120] = m_gen2_mode ? tx_st_data          [ 110] : 1'b0                      ;  // Gen2 ? user_tdata[78]       : UNUSED              
  assign tx_phy_preflop_0 [ 121] = m_gen2_mode ? tx_st_data          [ 111] : 1'b0                      ;  // Gen2 ? user_tdata[79]       : UNUSED              
  assign tx_phy_preflop_0 [ 122] = m_gen2_mode ? tx_st_data          [ 112] : 1'b0                      ;  // Gen2 ? user_tdata[80]       : UNUSED              
  assign tx_phy_preflop_0 [ 123] = m_gen2_mode ? tx_st_data          [ 113] : 1'b0                      ;  // Gen2 ? user_tdata[81]       : UNUSED              
  assign tx_phy_preflop_0 [ 124] = m_gen2_mode ? tx_st_data          [ 114] : 1'b0                      ;  // Gen2 ? user_tdata[82]       : UNUSED              
  assign tx_phy_preflop_0 [ 125] = m_gen2_mode ? tx_st_data          [ 115] : 1'b0                      ;  // Gen2 ? user_tdata[83]       : UNUSED              
  assign tx_phy_preflop_0 [ 126] = m_gen2_mode ? tx_st_data          [ 116] : 1'b0                      ;  // Gen2 ? user_tdata[84]       : UNUSED              
  assign tx_phy_preflop_0 [ 127] = m_gen2_mode ? tx_st_data          [ 117] : 1'b0                      ;  // Gen2 ? user_tdata[85]       : UNUSED              
  assign tx_phy_preflop_0 [ 128] = m_gen2_mode ? tx_st_data          [ 118] : 1'b0                      ;  // Gen2 ? user_tdata[86]       : UNUSED              
  assign tx_phy_preflop_0 [ 129] = m_gen2_mode ? tx_st_data          [ 119] : 1'b0                      ;  // Gen2 ? user_tdata[87]       : UNUSED              
  assign tx_phy_preflop_0 [ 130] = m_gen2_mode ? tx_st_data          [ 120] : 1'b0                      ;  // Gen2 ? user_tdata[88]       : UNUSED              
  assign tx_phy_preflop_0 [ 131] = m_gen2_mode ? tx_st_data          [ 121] : 1'b0                      ;  // Gen2 ? user_tdata[89]       : UNUSED              
  assign tx_phy_preflop_0 [ 132] = m_gen2_mode ? tx_st_data          [ 122] : 1'b0                      ;  // Gen2 ? user_tdata[90]       : UNUSED              
  assign tx_phy_preflop_0 [ 133] = m_gen2_mode ? tx_st_data          [ 123] : 1'b0                      ;  // Gen2 ? user_tdata[91]       : UNUSED              
  assign tx_phy_preflop_0 [ 134] = m_gen2_mode ? tx_st_data          [ 124] : 1'b0                      ;  // Gen2 ? user_tdata[92]       : UNUSED              
  assign tx_phy_preflop_0 [ 135] = m_gen2_mode ? tx_st_data          [ 125] : 1'b0                      ;  // Gen2 ? user_tdata[93]       : UNUSED              
  assign tx_phy_preflop_0 [ 136] = m_gen2_mode ? tx_st_data          [ 126] : 1'b0                      ;  // Gen2 ? user_tdata[94]       : UNUSED              
  assign tx_phy_preflop_0 [ 137] = m_gen2_mode ? tx_st_data          [ 127] : 1'b0                      ;  // Gen2 ? user_tdata[95]       : UNUSED              
  assign tx_phy_preflop_0 [ 138] = m_gen2_mode ? tx_st_data          [ 128] : 1'b0                      ;  // Gen2 ? user_tdata[96]       : UNUSED              
  assign tx_phy_preflop_0 [ 139] = m_gen2_mode ? tx_st_data          [ 129] : 1'b0                      ;  // Gen2 ? user_tdata[97]       : UNUSED              
  assign tx_phy_preflop_0 [ 140] = m_gen2_mode ? tx_st_data          [ 130] : 1'b0                      ;  // Gen2 ? user_tdata[98]       : UNUSED              
  assign tx_phy_preflop_0 [ 141] = m_gen2_mode ? tx_st_data          [ 131] : 1'b0                      ;  // Gen2 ? user_tdata[99]       : UNUSED              
  assign tx_phy_preflop_0 [ 142] = m_gen2_mode ? tx_st_data          [ 132] : 1'b0                      ;  // Gen2 ? user_tdata[100]      : UNUSED              
  assign tx_phy_preflop_0 [ 143] = m_gen2_mode ? tx_st_data          [ 133] : 1'b0                      ;  // Gen2 ? user_tdata[101]      : UNUSED              
  assign tx_phy_preflop_0 [ 144] = m_gen2_mode ? tx_st_data          [ 134] : 1'b0                      ;  // Gen2 ? user_tdata[102]      : UNUSED              
  assign tx_phy_preflop_0 [ 145] = m_gen2_mode ? tx_st_data          [ 135] : 1'b0                      ;  // Gen2 ? user_tdata[103]      : UNUSED              
  assign tx_phy_preflop_0 [ 146] = m_gen2_mode ? tx_st_data          [ 136] : 1'b0                      ;  // Gen2 ? user_tdata[104]      : UNUSED              
  assign tx_phy_preflop_0 [ 147] = m_gen2_mode ? tx_st_data          [ 137] : 1'b0                      ;  // Gen2 ? user_tdata[105]      : UNUSED              
  assign tx_phy_preflop_0 [ 148] = m_gen2_mode ? tx_st_data          [ 138] : 1'b0                      ;  // Gen2 ? user_tdata[106]      : UNUSED              
  assign tx_phy_preflop_0 [ 149] = m_gen2_mode ? tx_st_data          [ 139] : 1'b0                      ;  // Gen2 ? user_tdata[107]      : UNUSED              
  assign tx_phy_preflop_0 [ 150] = m_gen2_mode ? tx_st_data          [ 140] : 1'b0                      ;  // Gen2 ? user_tdata[108]      : UNUSED              
  assign tx_phy_preflop_0 [ 151] = m_gen2_mode ? tx_st_data          [ 141] : 1'b0                      ;  // Gen2 ? user_tdata[109]      : UNUSED              
  assign tx_phy_preflop_0 [ 152] = m_gen2_mode ? tx_st_data          [ 142] : 1'b0                      ;  // Gen2 ? user_tdata[110]      : UNUSED              
  assign tx_phy_preflop_0 [ 153] = m_gen2_mode ? tx_st_data          [ 143] : 1'b0                      ;  // Gen2 ? user_tdata[111]      : UNUSED              
  assign tx_phy_preflop_0 [ 154] = m_gen2_mode ? tx_st_data          [ 144] : 1'b0                      ;  // Gen2 ? user_tdata[112]      : UNUSED              
  assign tx_phy_preflop_0 [ 155] = m_gen2_mode ? tx_st_data          [ 145] : 1'b0                      ;  // Gen2 ? user_tdata[113]      : UNUSED              
  assign tx_phy_preflop_0 [ 156] = m_gen2_mode ? tx_st_data          [ 146] : 1'b0                      ;  // Gen2 ? user_tdata[114]      : UNUSED              
  assign tx_phy_preflop_0 [ 157] = m_gen2_mode ? tx_st_data          [ 147] : 1'b0                      ;  // Gen2 ? user_tdata[115]      : UNUSED              
  assign tx_phy_preflop_0 [ 158] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_0 [ 159] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_1 [   0] = m_gen2_mode ? tx_st_data          [ 148] : tx_st_data          [  61];  // Gen2 ? user_tdata[116]      : user_tdata[29]      
  assign tx_phy_preflop_1 [   1] = m_gen2_mode ? tx_st_data          [ 149] : tx_st_data          [  62];  // Gen2 ? user_tdata[117]      : user_tdata[30]      
  assign tx_phy_preflop_1 [   2] = m_gen2_mode ? tx_st_data          [ 150] : tx_st_data          [  63];  // Gen2 ? user_tdata[118]      : user_tdata[31]      
  assign tx_phy_preflop_1 [   3] = m_gen2_mode ? tx_st_data          [ 151] : tx_st_data          [  64];  // Gen2 ? user_tdata[119]      : user_tdata[32]      
  assign tx_phy_preflop_1 [   4] = m_gen2_mode ? tx_mrk_userbit[0]         : tx_st_data          [  65];  // Gen2 ? MARKER               : user_tdata[33]      
  assign tx_phy_preflop_1 [   5] = m_gen2_mode ? tx_st_data          [ 152] : tx_st_data          [  66];  // Gen2 ? user_tdata[120]      : user_tdata[34]      
  assign tx_phy_preflop_1 [   6] = m_gen2_mode ? tx_st_data          [ 153] : tx_st_data          [  67];  // Gen2 ? user_tdata[121]      : user_tdata[35]      
  assign tx_phy_preflop_1 [   7] = m_gen2_mode ? tx_st_data          [ 154] : tx_st_data          [  68];  // Gen2 ? user_tdata[122]      : user_tdata[36]      
  assign tx_phy_preflop_1 [   8] = m_gen2_mode ? tx_st_data          [ 155] : tx_st_data          [  69];  // Gen2 ? user_tdata[123]      : user_tdata[37]      
  assign tx_phy_preflop_1 [   9] = m_gen2_mode ? tx_st_data          [ 156] : tx_st_data          [  70];  // Gen2 ? user_tdata[124]      : user_tdata[38]      
  assign tx_phy_preflop_1 [  10] = m_gen2_mode ? tx_st_data          [ 157] : tx_st_data          [  71];  // Gen2 ? user_tdata[125]      : user_tdata[39]      
  assign tx_phy_preflop_1 [  11] = m_gen2_mode ? tx_st_data          [ 158] : tx_st_data          [  72];  // Gen2 ? user_tdata[126]      : user_tdata[40]      
  assign tx_phy_preflop_1 [  12] = m_gen2_mode ? tx_st_data          [ 159] : tx_st_data          [  73];  // Gen2 ? user_tdata[127]      : user_tdata[41]      
  assign tx_phy_preflop_1 [  13] = m_gen2_mode ? tx_st_data          [ 160] : tx_st_data          [  74];  // Gen2 ? user_tdata[128]      : user_tdata[42]      
  assign tx_phy_preflop_1 [  14] = m_gen2_mode ? tx_st_data          [ 161] : tx_st_data          [  75];  // Gen2 ? user_tdata[129]      : user_tdata[43]      
  assign tx_phy_preflop_1 [  15] = m_gen2_mode ? tx_st_data          [ 162] : tx_st_data          [  76];  // Gen2 ? user_tdata[130]      : user_tdata[44]      
  assign tx_phy_preflop_1 [  16] = m_gen2_mode ? tx_st_data          [ 163] : tx_st_data          [  77];  // Gen2 ? user_tdata[131]      : user_tdata[45]      
  assign tx_phy_preflop_1 [  17] = m_gen2_mode ? tx_st_data          [ 164] : tx_st_data          [  78];  // Gen2 ? user_tdata[132]      : user_tdata[46]      
  assign tx_phy_preflop_1 [  18] = m_gen2_mode ? tx_st_data          [ 165] : tx_st_data          [  79];  // Gen2 ? user_tdata[133]      : user_tdata[47]      
  assign tx_phy_preflop_1 [  19] = m_gen2_mode ? tx_st_data          [ 166] : tx_st_data          [  80];  // Gen2 ? user_tdata[134]      : user_tdata[48]      
  assign tx_phy_preflop_1 [  20] = m_gen2_mode ? tx_st_data          [ 167] : tx_st_data          [  81];  // Gen2 ? user_tdata[135]      : user_tdata[49]      
  assign tx_phy_preflop_1 [  21] = m_gen2_mode ? tx_st_data          [ 168] : tx_st_data          [  82];  // Gen2 ? user_tdata[136]      : user_tdata[50]      
  assign tx_phy_preflop_1 [  22] = m_gen2_mode ? tx_st_data          [ 169] : tx_st_data          [  83];  // Gen2 ? user_tdata[137]      : user_tdata[51]      
  assign tx_phy_preflop_1 [  23] = m_gen2_mode ? tx_st_data          [ 170] : tx_st_data          [  84];  // Gen2 ? user_tdata[138]      : user_tdata[52]      
  assign tx_phy_preflop_1 [  24] = m_gen2_mode ? tx_st_data          [ 171] : tx_st_data          [  85];  // Gen2 ? user_tdata[139]      : user_tdata[53]      
  assign tx_phy_preflop_1 [  25] = m_gen2_mode ? tx_st_data          [ 172] : tx_st_data          [  86];  // Gen2 ? user_tdata[140]      : user_tdata[54]      
  assign tx_phy_preflop_1 [  26] = m_gen2_mode ? tx_st_data          [ 173] : tx_st_data          [  87];  // Gen2 ? user_tdata[141]      : user_tdata[55]      
  assign tx_phy_preflop_1 [  27] = m_gen2_mode ? tx_st_data          [ 174] : tx_st_data          [  88];  // Gen2 ? user_tdata[142]      : user_tdata[56]      
  assign tx_phy_preflop_1 [  28] = m_gen2_mode ? tx_st_data          [ 175] : tx_st_data          [  89];  // Gen2 ? user_tdata[143]      : user_tdata[57]      
  assign tx_phy_preflop_1 [  29] = m_gen2_mode ? tx_st_data          [ 176] : tx_st_data          [  90];  // Gen2 ? user_tdata[144]      : user_tdata[58]      
  assign tx_phy_preflop_1 [  30] = m_gen2_mode ? tx_st_data          [ 177] : tx_st_data          [  91];  // Gen2 ? user_tdata[145]      : user_tdata[59]      
  assign tx_phy_preflop_1 [  31] = m_gen2_mode ? tx_st_data          [ 178] : tx_st_data          [  92];  // Gen2 ? user_tdata[146]      : user_tdata[60]      
  assign tx_phy_preflop_1 [  32] = m_gen2_mode ? tx_st_data          [ 179] : tx_st_data          [  93];  // Gen2 ? user_tdata[147]      : user_tdata[61]      
  assign tx_phy_preflop_1 [  33] = m_gen2_mode ? tx_st_data          [ 180] : tx_st_data          [  94];  // Gen2 ? user_tdata[148]      : user_tdata[62]      
  assign tx_phy_preflop_1 [  34] = m_gen2_mode ? tx_st_data          [ 181] : tx_st_data          [  95];  // Gen2 ? user_tdata[149]      : user_tdata[63]      
  assign tx_phy_preflop_1 [  35] = m_gen2_mode ? tx_st_data          [ 182] : tx_stb_userbit            ;  // Gen2 ? user_tdata[150]      : STROBE              
  assign tx_phy_preflop_1 [  36] = m_gen2_mode ? tx_st_data          [ 183] : 1'b0                      ;  // Gen2 ? user_tdata[151]      : SPARE               
  assign tx_phy_preflop_1 [  37] = m_gen2_mode ? tx_st_data          [ 184] : 1'b0                      ;  // Gen2 ? user_tdata[152]      : SPARE               
  assign tx_phy_preflop_1 [  38] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : SPARE               
  assign tx_phy_preflop_1 [  39] = m_gen2_mode ? 1'b0                      : tx_mrk_userbit[0]         ;  // Gen2 ? DBI                  : MARKER              
  assign tx_phy_preflop_1 [  40] = m_gen2_mode ? tx_st_data          [ 185] : 1'b0                      ;  // Gen2 ? user_tdata[153]      : UNUSED              
  assign tx_phy_preflop_1 [  41] = m_gen2_mode ? tx_st_data          [ 186] : 1'b0                      ;  // Gen2 ? user_tdata[154]      : UNUSED              
  assign tx_phy_preflop_1 [  42] = m_gen2_mode ? tx_st_data          [ 187] : 1'b0                      ;  // Gen2 ? user_tdata[155]      : UNUSED              
  assign tx_phy_preflop_1 [  43] = m_gen2_mode ? tx_st_data          [ 188] : 1'b0                      ;  // Gen2 ? user_tdata[156]      : UNUSED              
  assign tx_phy_preflop_1 [  44] = m_gen2_mode ? tx_st_data          [ 189] : 1'b0                      ;  // Gen2 ? user_tdata[157]      : UNUSED              
  assign tx_phy_preflop_1 [  45] = m_gen2_mode ? tx_st_data          [ 190] : 1'b0                      ;  // Gen2 ? user_tdata[158]      : UNUSED              
  assign tx_phy_preflop_1 [  46] = m_gen2_mode ? tx_st_data          [ 191] : 1'b0                      ;  // Gen2 ? user_tdata[159]      : UNUSED              
  assign tx_phy_preflop_1 [  47] = m_gen2_mode ? tx_st_data          [ 192] : 1'b0                      ;  // Gen2 ? user_tdata[160]      : UNUSED              
  assign tx_phy_preflop_1 [  48] = m_gen2_mode ? tx_st_data          [ 193] : 1'b0                      ;  // Gen2 ? user_tdata[161]      : UNUSED              
  assign tx_phy_preflop_1 [  49] = m_gen2_mode ? tx_st_data          [ 194] : 1'b0                      ;  // Gen2 ? user_tdata[162]      : UNUSED              
  assign tx_phy_preflop_1 [  50] = m_gen2_mode ? tx_st_data          [ 195] : 1'b0                      ;  // Gen2 ? user_tdata[163]      : UNUSED              
  assign tx_phy_preflop_1 [  51] = m_gen2_mode ? tx_st_data          [ 196] : 1'b0                      ;  // Gen2 ? user_tdata[164]      : UNUSED              
  assign tx_phy_preflop_1 [  52] = m_gen2_mode ? tx_st_data          [ 197] : 1'b0                      ;  // Gen2 ? user_tdata[165]      : UNUSED              
  assign tx_phy_preflop_1 [  53] = m_gen2_mode ? tx_st_data          [ 198] : 1'b0                      ;  // Gen2 ? user_tdata[166]      : UNUSED              
  assign tx_phy_preflop_1 [  54] = m_gen2_mode ? tx_st_data          [ 199] : 1'b0                      ;  // Gen2 ? user_tdata[167]      : UNUSED              
  assign tx_phy_preflop_1 [  55] = m_gen2_mode ? tx_st_data          [ 200] : 1'b0                      ;  // Gen2 ? user_tdata[168]      : UNUSED              
  assign tx_phy_preflop_1 [  56] = m_gen2_mode ? tx_st_data          [ 201] : 1'b0                      ;  // Gen2 ? user_tdata[169]      : UNUSED              
  assign tx_phy_preflop_1 [  57] = m_gen2_mode ? tx_st_data          [ 202] : 1'b0                      ;  // Gen2 ? user_tdata[170]      : UNUSED              
  assign tx_phy_preflop_1 [  58] = m_gen2_mode ? tx_st_data          [ 203] : 1'b0                      ;  // Gen2 ? user_tdata[171]      : UNUSED              
  assign tx_phy_preflop_1 [  59] = m_gen2_mode ? tx_st_data          [ 204] : 1'b0                      ;  // Gen2 ? user_tdata[172]      : UNUSED              
  assign tx_phy_preflop_1 [  60] = m_gen2_mode ? tx_st_data          [ 205] : 1'b0                      ;  // Gen2 ? user_tdata[173]      : UNUSED              
  assign tx_phy_preflop_1 [  61] = m_gen2_mode ? tx_st_data          [ 206] : 1'b0                      ;  // Gen2 ? user_tdata[174]      : UNUSED              
  assign tx_phy_preflop_1 [  62] = m_gen2_mode ? tx_st_data          [ 207] : 1'b0                      ;  // Gen2 ? user_tdata[175]      : UNUSED              
  assign tx_phy_preflop_1 [  63] = m_gen2_mode ? tx_st_data          [ 208] : 1'b0                      ;  // Gen2 ? user_tdata[176]      : UNUSED              
  assign tx_phy_preflop_1 [  64] = m_gen2_mode ? tx_st_data          [ 209] : 1'b0                      ;  // Gen2 ? user_tdata[177]      : UNUSED              
  assign tx_phy_preflop_1 [  65] = m_gen2_mode ? tx_st_data          [ 210] : 1'b0                      ;  // Gen2 ? user_tdata[178]      : UNUSED              
  assign tx_phy_preflop_1 [  66] = m_gen2_mode ? tx_st_data          [ 211] : 1'b0                      ;  // Gen2 ? user_tdata[179]      : UNUSED              
  assign tx_phy_preflop_1 [  67] = m_gen2_mode ? tx_st_data          [ 212] : 1'b0                      ;  // Gen2 ? user_tdata[180]      : UNUSED              
  assign tx_phy_preflop_1 [  68] = m_gen2_mode ? tx_st_data          [ 213] : 1'b0                      ;  // Gen2 ? user_tdata[181]      : UNUSED              
  assign tx_phy_preflop_1 [  69] = m_gen2_mode ? tx_st_data          [ 214] : 1'b0                      ;  // Gen2 ? user_tdata[182]      : UNUSED              
  assign tx_phy_preflop_1 [  70] = m_gen2_mode ? tx_st_data          [ 215] : 1'b0                      ;  // Gen2 ? user_tdata[183]      : UNUSED              
  assign tx_phy_preflop_1 [  71] = m_gen2_mode ? tx_st_data          [ 216] : 1'b0                      ;  // Gen2 ? user_tdata[184]      : UNUSED              
  assign tx_phy_preflop_1 [  72] = m_gen2_mode ? tx_st_data          [ 217] : 1'b0                      ;  // Gen2 ? user_tdata[185]      : UNUSED              
  assign tx_phy_preflop_1 [  73] = m_gen2_mode ? tx_st_data          [ 218] : 1'b0                      ;  // Gen2 ? user_tdata[186]      : UNUSED              
  assign tx_phy_preflop_1 [  74] = m_gen2_mode ? tx_st_data          [ 219] : 1'b0                      ;  // Gen2 ? user_tdata[187]      : UNUSED              
  assign tx_phy_preflop_1 [  75] = m_gen2_mode ? tx_st_data          [ 220] : 1'b0                      ;  // Gen2 ? user_tdata[188]      : UNUSED              
  assign tx_phy_preflop_1 [  76] = m_gen2_mode ? tx_stb_userbit            : 1'b0                      ;  // Gen2 ? STROBE               : UNUSED              
  assign tx_phy_preflop_1 [  77] = m_gen2_mode ? tx_st_data          [ 221] : 1'b0                      ;  // Gen2 ? user_tdata[189]      : UNUSED              
  assign tx_phy_preflop_1 [  78] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_1 [  79] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_1 [  80] = m_gen2_mode ? tx_st_data          [ 222] : 1'b0                      ;  // Gen2 ? user_tdata[190]      : UNUSED              
  assign tx_phy_preflop_1 [  81] = m_gen2_mode ? tx_st_data          [ 223] : 1'b0                      ;  // Gen2 ? user_tdata[191]      : UNUSED              
  assign tx_phy_preflop_1 [  82] = m_gen2_mode ? tx_st_data          [ 224] : 1'b0                      ;  // Gen2 ? user_tdata[192]      : UNUSED              
  assign tx_phy_preflop_1 [  83] = m_gen2_mode ? tx_st_data          [ 225] : 1'b0                      ;  // Gen2 ? user_tdata[193]      : UNUSED              
  assign tx_phy_preflop_1 [  84] = m_gen2_mode ? tx_mrk_userbit[1]         : 1'b0                      ;  // Gen2 ? MARKER               : UNUSED              
  assign tx_phy_preflop_1 [  85] = m_gen2_mode ? tx_st_data          [ 226] : 1'b0                      ;  // Gen2 ? user_tdata[194]      : UNUSED              
  assign tx_phy_preflop_1 [  86] = m_gen2_mode ? tx_st_data          [ 227] : 1'b0                      ;  // Gen2 ? user_tdata[195]      : UNUSED              
  assign tx_phy_preflop_1 [  87] = m_gen2_mode ? tx_st_data          [ 228] : 1'b0                      ;  // Gen2 ? user_tdata[196]      : UNUSED              
  assign tx_phy_preflop_1 [  88] = m_gen2_mode ? tx_st_data          [ 229] : 1'b0                      ;  // Gen2 ? user_tdata[197]      : UNUSED              
  assign tx_phy_preflop_1 [  89] = m_gen2_mode ? tx_st_data          [ 230] : 1'b0                      ;  // Gen2 ? user_tdata[198]      : UNUSED              
  assign tx_phy_preflop_1 [  90] = m_gen2_mode ? tx_st_data          [ 231] : 1'b0                      ;  // Gen2 ? user_tdata[199]      : UNUSED              
  assign tx_phy_preflop_1 [  91] = m_gen2_mode ? tx_st_data          [ 232] : 1'b0                      ;  // Gen2 ? user_tdata[200]      : UNUSED              
  assign tx_phy_preflop_1 [  92] = m_gen2_mode ? tx_st_data          [ 233] : 1'b0                      ;  // Gen2 ? user_tdata[201]      : UNUSED              
  assign tx_phy_preflop_1 [  93] = m_gen2_mode ? tx_st_data          [ 234] : 1'b0                      ;  // Gen2 ? user_tdata[202]      : UNUSED              
  assign tx_phy_preflop_1 [  94] = m_gen2_mode ? tx_st_data          [ 235] : 1'b0                      ;  // Gen2 ? user_tdata[203]      : UNUSED              
  assign tx_phy_preflop_1 [  95] = m_gen2_mode ? tx_st_data          [ 236] : 1'b0                      ;  // Gen2 ? user_tdata[204]      : UNUSED              
  assign tx_phy_preflop_1 [  96] = m_gen2_mode ? tx_st_data          [ 237] : 1'b0                      ;  // Gen2 ? user_tdata[205]      : UNUSED              
  assign tx_phy_preflop_1 [  97] = m_gen2_mode ? tx_st_data          [ 238] : 1'b0                      ;  // Gen2 ? user_tdata[206]      : UNUSED              
  assign tx_phy_preflop_1 [  98] = m_gen2_mode ? tx_st_data          [ 239] : 1'b0                      ;  // Gen2 ? user_tdata[207]      : UNUSED              
  assign tx_phy_preflop_1 [  99] = m_gen2_mode ? tx_st_data          [ 240] : 1'b0                      ;  // Gen2 ? user_tdata[208]      : UNUSED              
  assign tx_phy_preflop_1 [ 100] = m_gen2_mode ? tx_st_data          [ 241] : 1'b0                      ;  // Gen2 ? user_tdata[209]      : UNUSED              
  assign tx_phy_preflop_1 [ 101] = m_gen2_mode ? tx_st_data          [ 242] : 1'b0                      ;  // Gen2 ? user_tdata[210]      : UNUSED              
  assign tx_phy_preflop_1 [ 102] = m_gen2_mode ? tx_st_data          [ 243] : 1'b0                      ;  // Gen2 ? user_tdata[211]      : UNUSED              
  assign tx_phy_preflop_1 [ 103] = m_gen2_mode ? tx_st_data          [ 244] : 1'b0                      ;  // Gen2 ? user_tdata[212]      : UNUSED              
  assign tx_phy_preflop_1 [ 104] = m_gen2_mode ? tx_st_data          [ 245] : 1'b0                      ;  // Gen2 ? user_tdata[213]      : UNUSED              
  assign tx_phy_preflop_1 [ 105] = m_gen2_mode ? tx_st_data          [ 246] : 1'b0                      ;  // Gen2 ? user_tdata[214]      : UNUSED              
  assign tx_phy_preflop_1 [ 106] = m_gen2_mode ? tx_st_data          [ 247] : 1'b0                      ;  // Gen2 ? user_tdata[215]      : UNUSED              
  assign tx_phy_preflop_1 [ 107] = m_gen2_mode ? tx_st_data          [ 248] : 1'b0                      ;  // Gen2 ? user_tdata[216]      : UNUSED              
  assign tx_phy_preflop_1 [ 108] = m_gen2_mode ? tx_st_data          [ 249] : 1'b0                      ;  // Gen2 ? user_tdata[217]      : UNUSED              
  assign tx_phy_preflop_1 [ 109] = m_gen2_mode ? tx_st_data          [ 250] : 1'b0                      ;  // Gen2 ? user_tdata[218]      : UNUSED              
  assign tx_phy_preflop_1 [ 110] = m_gen2_mode ? tx_st_data          [ 251] : 1'b0                      ;  // Gen2 ? user_tdata[219]      : UNUSED              
  assign tx_phy_preflop_1 [ 111] = m_gen2_mode ? tx_st_data          [ 252] : 1'b0                      ;  // Gen2 ? user_tdata[220]      : UNUSED              
  assign tx_phy_preflop_1 [ 112] = m_gen2_mode ? tx_st_data          [ 253] : 1'b0                      ;  // Gen2 ? user_tdata[221]      : UNUSED              
  assign tx_phy_preflop_1 [ 113] = m_gen2_mode ? tx_st_data          [ 254] : 1'b0                      ;  // Gen2 ? user_tdata[222]      : UNUSED              
  assign tx_phy_preflop_1 [ 114] = m_gen2_mode ? tx_st_data          [ 255] : 1'b0                      ;  // Gen2 ? user_tdata[223]      : UNUSED              
  assign tx_phy_preflop_1 [ 115] = m_gen2_mode ? tx_st_data          [ 256] : 1'b0                      ;  // Gen2 ? user_tdata[224]      : UNUSED              
  assign tx_phy_preflop_1 [ 116] = m_gen2_mode ? tx_st_data          [ 257] : 1'b0                      ;  // Gen2 ? user_tdata[225]      : UNUSED              
  assign tx_phy_preflop_1 [ 117] = m_gen2_mode ? tx_st_data          [ 258] : 1'b0                      ;  // Gen2 ? user_tdata[226]      : UNUSED              
  assign tx_phy_preflop_1 [ 118] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_1 [ 119] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_1 [ 120] = m_gen2_mode ? tx_st_data          [ 259] : 1'b0                      ;  // Gen2 ? user_tdata[227]      : UNUSED              
  assign tx_phy_preflop_1 [ 121] = m_gen2_mode ? tx_st_data          [ 260] : 1'b0                      ;  // Gen2 ? user_tdata[228]      : UNUSED              
  assign tx_phy_preflop_1 [ 122] = m_gen2_mode ? tx_st_data          [ 261] : 1'b0                      ;  // Gen2 ? user_tdata[229]      : UNUSED              
  assign tx_phy_preflop_1 [ 123] = m_gen2_mode ? tx_st_data          [ 262] : 1'b0                      ;  // Gen2 ? user_tdata[230]      : UNUSED              
  assign tx_phy_preflop_1 [ 124] = m_gen2_mode ? tx_st_data          [ 263] : 1'b0                      ;  // Gen2 ? user_tdata[231]      : UNUSED              
  assign tx_phy_preflop_1 [ 125] = m_gen2_mode ? tx_st_data          [ 264] : 1'b0                      ;  // Gen2 ? user_tdata[232]      : UNUSED              
  assign tx_phy_preflop_1 [ 126] = m_gen2_mode ? tx_st_data          [ 265] : 1'b0                      ;  // Gen2 ? user_tdata[233]      : UNUSED              
  assign tx_phy_preflop_1 [ 127] = m_gen2_mode ? tx_st_data          [ 266] : 1'b0                      ;  // Gen2 ? user_tdata[234]      : UNUSED              
  assign tx_phy_preflop_1 [ 128] = m_gen2_mode ? tx_st_data          [ 267] : 1'b0                      ;  // Gen2 ? user_tdata[235]      : UNUSED              
  assign tx_phy_preflop_1 [ 129] = m_gen2_mode ? tx_st_data          [ 268] : 1'b0                      ;  // Gen2 ? user_tdata[236]      : UNUSED              
  assign tx_phy_preflop_1 [ 130] = m_gen2_mode ? tx_st_data          [ 269] : 1'b0                      ;  // Gen2 ? user_tdata[237]      : UNUSED              
  assign tx_phy_preflop_1 [ 131] = m_gen2_mode ? tx_st_data          [ 270] : 1'b0                      ;  // Gen2 ? user_tdata[238]      : UNUSED              
  assign tx_phy_preflop_1 [ 132] = m_gen2_mode ? tx_st_data          [ 271] : 1'b0                      ;  // Gen2 ? user_tdata[239]      : UNUSED              
  assign tx_phy_preflop_1 [ 133] = m_gen2_mode ? tx_st_data          [ 272] : 1'b0                      ;  // Gen2 ? user_tdata[240]      : UNUSED              
  assign tx_phy_preflop_1 [ 134] = m_gen2_mode ? tx_st_data          [ 273] : 1'b0                      ;  // Gen2 ? user_tdata[241]      : UNUSED              
  assign tx_phy_preflop_1 [ 135] = m_gen2_mode ? tx_st_data          [ 274] : 1'b0                      ;  // Gen2 ? user_tdata[242]      : UNUSED              
  assign tx_phy_preflop_1 [ 136] = m_gen2_mode ? tx_st_data          [ 275] : 1'b0                      ;  // Gen2 ? user_tdata[243]      : UNUSED              
  assign tx_phy_preflop_1 [ 137] = m_gen2_mode ? tx_st_data          [ 276] : 1'b0                      ;  // Gen2 ? user_tdata[244]      : UNUSED              
  assign tx_phy_preflop_1 [ 138] = m_gen2_mode ? tx_st_data          [ 277] : 1'b0                      ;  // Gen2 ? user_tdata[245]      : UNUSED              
  assign tx_phy_preflop_1 [ 139] = m_gen2_mode ? tx_st_data          [ 278] : 1'b0                      ;  // Gen2 ? user_tdata[246]      : UNUSED              
  assign tx_phy_preflop_1 [ 140] = m_gen2_mode ? tx_st_data          [ 279] : 1'b0                      ;  // Gen2 ? user_tdata[247]      : UNUSED              
  assign tx_phy_preflop_1 [ 141] = m_gen2_mode ? tx_st_data          [ 280] : 1'b0                      ;  // Gen2 ? user_tdata[248]      : UNUSED              
  assign tx_phy_preflop_1 [ 142] = m_gen2_mode ? tx_st_data          [ 281] : 1'b0                      ;  // Gen2 ? user_tdata[249]      : UNUSED              
  assign tx_phy_preflop_1 [ 143] = m_gen2_mode ? tx_st_data          [ 282] : 1'b0                      ;  // Gen2 ? user_tdata[250]      : UNUSED              
  assign tx_phy_preflop_1 [ 144] = m_gen2_mode ? tx_st_data          [ 283] : 1'b0                      ;  // Gen2 ? user_tdata[251]      : UNUSED              
  assign tx_phy_preflop_1 [ 145] = m_gen2_mode ? tx_st_data          [ 284] : 1'b0                      ;  // Gen2 ? user_tdata[252]      : UNUSED              
  assign tx_phy_preflop_1 [ 146] = m_gen2_mode ? tx_st_data          [ 285] : 1'b0                      ;  // Gen2 ? user_tdata[253]      : UNUSED              
  assign tx_phy_preflop_1 [ 147] = m_gen2_mode ? tx_st_data          [ 286] : 1'b0                      ;  // Gen2 ? user_tdata[254]      : UNUSED              
  assign tx_phy_preflop_1 [ 148] = m_gen2_mode ? tx_st_data          [ 287] : 1'b0                      ;  // Gen2 ? user_tdata[255]      : UNUSED              
  assign tx_phy_preflop_1 [ 149] = m_gen2_mode ? tx_st_data          [ 288] : 1'b0                      ;  // Gen2 ? user_tlast           : UNUSED              
  assign tx_phy_preflop_1 [ 150] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 151] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 152] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 153] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 154] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 155] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 156] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 157] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? SPARE                : UNUSED              
  assign tx_phy_preflop_1 [ 158] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
  assign tx_phy_preflop_1 [ 159] = m_gen2_mode ? 1'b0                      : 1'b0                      ;  // Gen2 ? DBI                  : UNUSED              
// TX Section
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
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

  localparam RX_REG_PHY    = 1'b0;  // If set, this enables boundary FF for timing reasons

  logic [ 159:   0]                              rx_phy_postflop_0             ;
  logic [ 159:   0]                              rx_phy_postflop_1             ;
  logic [ 159:   0]                              rx_phy_flop_0_reg             ;
  logic [ 159:   0]                              rx_phy_flop_1_reg             ;

  always_ff @(posedge clk_rd or negedge rst_rd_n)
  if (~rst_rd_n)
  begin
    rx_phy_flop_0_reg                       <= 160'b0                                  ;
    rx_phy_flop_1_reg                       <= 160'b0                                  ;
  end
  else
  begin
    rx_phy_flop_0_reg                       <= rx_phy0                                 ;
    rx_phy_flop_1_reg                       <= rx_phy1                                 ;
  end


  assign rx_phy_postflop_0                  = RX_REG_PHY ? rx_phy_flop_0_reg : rx_phy0               ;
  assign rx_phy_postflop_1                  = RX_REG_PHY ? rx_phy_flop_1_reg : rx_phy1               ;

  assign rx_st_credit              = m_gen2_mode ? rx_phy_postflop_0 [   0] : rx_phy_postflop_0 [   0] ;  // Gen2 ? tx_st_credit         : tx_st_credit        
//       nc                        =               rx_phy_postflop_0 [   1]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [   2]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [   3]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [   4]                           ;  // Gen2 ? MARKER               : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [   5]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [   6]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [   7]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [   8]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [   9]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  10]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  11]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  12]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  13]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  14]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  15]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  16]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  17]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  18]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  19]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  20]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  21]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  22]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  23]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  24]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  25]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  26]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  27]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  28]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  29]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  30]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  31]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  32]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  33]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  34]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  35]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  36]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  37]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  38]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  39]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  40]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  41]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  42]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  43]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  44]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  45]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  46]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  47]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  48]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  49]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  50]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  51]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  52]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  53]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  54]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  55]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  56]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  57]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  58]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  59]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  60]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  61]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  62]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  63]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  64]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  65]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  66]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  67]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  68]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  69]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  70]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  71]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  72]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  73]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  74]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  75]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  76]                           ;  // Gen2 ? STROBE               : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  77]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  78]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  79]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  80]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  81]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  82]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  83]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  84]                           ;  // Gen2 ? MARKER               : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  85]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  86]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  87]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  88]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  89]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  90]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  91]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  92]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  93]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  94]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  95]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  96]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  97]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  98]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [  99]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 100]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 101]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 102]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 103]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 104]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 105]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 106]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 107]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 108]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 109]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 110]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 111]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 112]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 113]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 114]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 115]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 116]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 117]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 118]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 119]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 120]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 121]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 122]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 123]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 124]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 125]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 126]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 127]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 128]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 129]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 130]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 131]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 132]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 133]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 134]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 135]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 136]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 137]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 138]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 139]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 140]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 141]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 142]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 143]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 144]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 145]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 146]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 147]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 148]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 149]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 150]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 151]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 152]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 153]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 154]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 155]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 156]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 157]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 158]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_0 [ 159]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [   0]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [   1]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [   2]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [   3]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [   4]                           ;  // Gen2 ? MARKER               : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [   5]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [   6]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [   7]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [   8]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [   9]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  10]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  11]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  12]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  13]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  14]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  15]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  16]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  17]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  18]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  19]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  20]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  21]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  22]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  23]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  24]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  25]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  26]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  27]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  28]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  29]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  30]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  31]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  32]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  33]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  34]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  35]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  36]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  37]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  38]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  39]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  40]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  41]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  42]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  43]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  44]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  45]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  46]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  47]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  48]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  49]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  50]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  51]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  52]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  53]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  54]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  55]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  56]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  57]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  58]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  59]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  60]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  61]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  62]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  63]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  64]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  65]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  66]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  67]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  68]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  69]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  70]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  71]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  72]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  73]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  74]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  75]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  76]                           ;  // Gen2 ? STROBE               : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  77]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  78]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  79]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  80]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  81]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  82]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  83]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  84]                           ;  // Gen2 ? MARKER               : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  85]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  86]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  87]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  88]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  89]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  90]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  91]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  92]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  93]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  94]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  95]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  96]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  97]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  98]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [  99]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 100]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 101]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 102]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 103]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 104]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 105]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 106]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 107]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 108]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 109]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 110]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 111]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 112]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 113]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 114]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 115]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 116]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 117]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 118]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 119]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 120]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 121]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 122]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 123]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 124]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 125]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 126]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 127]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 128]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 129]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 130]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 131]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 132]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 133]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 134]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 135]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 136]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 137]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 138]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 139]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 140]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 141]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 142]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 143]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 144]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 145]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 146]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 147]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 148]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 149]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 150]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 151]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 152]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 153]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 154]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 155]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 156]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 157]                           ;  // Gen2 ? SPARE                : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 158]                           ;  // Gen2 ? DBI                  : GEN2ONLY            
//       nc                        =               rx_phy_postflop_1 [ 159]                           ;  // Gen2 ? DBI                  : GEN2ONLY            

// RX Section
//////////////////////////////////////////////////////////////////


endmodule
