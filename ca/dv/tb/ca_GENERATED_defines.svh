`ifndef _ca_GENERATED_defines_
`define _ca_GENERATED_defines_
///////////////////////////////////////////////////////////
// *** AUTO GENERATED FILE do not alter && check in ***
///////////////////////////////////////////////////////////
// 
// COMMON
`define MIN_BUS_BIT_WIDTH       40
`define MAX_BUS_BIT_WIDTH       320 
`define MAX_NUM_CHANNELS        24
`define SYNC_FIFO               1 
`define AIB_PROG_FIFO_MODE      1  

// DIE A
`define TB_DIE_A_AIB            2
`define TB_DIE_A_NUM_CHANNELS   2
`define TB_DIE_A_AD_WIDTH       4

// DIE B
`define TB_DIE_B_AIB            2
`define TB_DIE_B_NUM_CHANNELS   2
`define TB_DIE_B_AD_WIDTH       4

//GEN1 mode, bits_per_ch 40,1GHZ 
`define TB_DIE_A_BUS_BIT_WIDTH  40 
`define TB_DIE_A_CLK            1000 
`define TB_DIE_B_BUS_BIT_WIDTH  40 
`define TB_DIE_B_CLK            1000 

//GEN1 mode, bits_per_ch 80,500MHZ 
//`define TB_DIE_A_BUS_BIT_WIDTH  80 
//`define TB_DIE_A_CLK            2000 
//`define TB_DIE_B_BUS_BIT_WIDTH  80 
//`define TB_DIE_B_CLK            2000
// 
////GEN2 mode, bits_per_ch 80,2GHZ 
//`define TB_DIE_A_BUS_BIT_WIDTH  80 
//`define TB_DIE_A_CLK            500 
//`define TB_DIE_B_BUS_BIT_WIDTH  80 
//`define TB_DIE_B_CLK            500
// 
////GEN2 mode, bits_per_ch 160,1GHZ 
//`define TB_DIE_A_BUS_BIT_WIDTH  160 
//`define TB_DIE_A_CLK            1000 
//`define TB_DIE_B_BUS_BIT_WIDTH  160
//`define TB_DIE_B_CLK            1000
 
////GEN2 mode, bits_per_ch 320,500MHZ 
//`define TB_DIE_A_BUS_BIT_WIDTH  320 
//`define TB_DIE_A_CLK            2000 
//`define TB_DIE_B_BUS_BIT_WIDTH  320
//`define TB_DIE_B_CLK            2000 
///////////////////////////////////////////////////////////
`define MODE_GEN2                 1'b0
`endif
