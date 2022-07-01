// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: LPIF AIB instantiation
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////


//LPIF_CONFIG_DEFINES
`define    AIB_NUM_CHANNELS_4
`define    GEN2
`define    HALF_RATE
`define    HALF_RATE_DIE_B
`define    GLOBAL_MAX_INTER_CH_SKEW    		7
`define    AIB_MVER                			2
`define    AIB_SVER                			2
`define    LPIF_CA_AD_WIDTH        			5
`define    HOST_A_DEVICE_B
`define    DIE_A_IO_STREAM_ID_2
`define    DIE_B_IO_STREAM_ID_2
`define    DIE_A_MEM_CACHE_STREAM_ID_1
`define    DIE_B_MEM_CACHE_STREAM_ID_1
`define    DIE_A_ARB_MUX_STREAM_ID_4
`define    DIE_B_ARB_MUX_STREAM_ID_4
`define    DIE_A_AIB_LANES_4
`define    DIE_B_AIB_LANES_4
`define    DIE_A_LPIF_PIPELINE_1
`define    DIE_B_LPIF_PIPELINE_1
`define    TB_DIE_A_SYNC_FIFO      			1
`define    TB_DIE_B_SYNC_FIFO      			1
`define    CACHE_MEM 
`define    TB_DIE_A_LPIF_PL_PROTOCOL    	4
`define    TB_DIE_A_LPIF_PL_PROTOCOL_4  	
`define    TB_DIE_B_LPIF_PL_PROTOCOL    	4
`define    TB_DIE_B_LPIF_PL_PROTOCOL_4	
`define    TB_DIE_A_PTM_RX_DELAY        	5
`define    TB_DIE_B_PTM_RX_DELAY        	5
`define    TB_DIE_A_AIB_CLOCK_RATE      	1000
`define    TB_DIE_B_AIB_CLOCK_RATE      	1000
`define    TB_DIE_A_AIB_CLOCK_RATE_NS   	1
`define    TB_DIE_A_LPIF_CLOCK_RATE     	1000
`define    TB_DIE_B_LPIF_CLOCK_RATE     	1000
`define    TB_DIE_A_AIB_BITS_PER_LANE   	160
`define    TB_DIE_B_AIB_BITS_PER_LANE   	160
`define    TB_DIE_A_LPIF_DATA_WIDTH     	64
`define    TB_DIE_B_LPIF_DATA_WIDTH     	64
`define    TB_DIE_A_PL_VALID            	1
`define    TB_DIE_B_PL_VALID            	1
`define    TB_DIE_A_PL_CRC              	16
`define    FWD_CYCLE                    	1000
`define    WR_CYCLE                     	1000
`define    RD_CYCLE                     	1000
`define    TB_DIE_A_AIB_VERSION				2
`define    TB_DIE_B_AIB_VERSION				2
`define    TB_DIE_A_AIB_LANES				4
`define    TB_DIE_A_AIB_GENERATION			2
`define    TB_DIE_B_AIB_LANES				4
`define    TB_DIE_B_AIB_GENERATION			2
`define    TB_DIE_A_LPIF_PIPELINE_STAGES	1
`define    TB_DIE_B_LPIF_PIPELINE_STAGES	1
`define    TB_DIE_B_MEM_CACHE_STREAM_ID		8'h01
`define    TB_DIE_A_MEM_CACHE_STREAM_ID		8'h01
`define    TB_DIE_A_IO_STREAM_ID			8'h02
`define    TB_DIE_B_IO_STREAM_ID			8'h02
`define    TB_DIE_A_IO_STREAM_ID			8'h02
`define    TB_DIE_A_ARB_MUX_STREAM_ID		8'h04
`define    TB_DIE_B_ARB_MUX_STREAM_ID		8'h04
`define    TB_DIE_A_LPIF_PLPROTOCOL			4
`define    TB_DIE_B_LPIF_PLPROTOCOL			4
`define    TB_DIE_A_NUM_CHANNELS			4
`define    TB_DIE_B_NUM_CHANNELS			4
`define    LL_MSR_GEN2_MODE					1'b1
`define    LL_SLV_GEN2_MODE					1'b1

`timescale 1ps/1ps
module lpif_aib_top(
	
	input					ms_wr_clk ,
	input					ms_rd_clk ,
	input					ms_fwd_clk,
	input					sl_wr_clk ,
	input					sl_rd_clk ,
	input					sl_fwd_clk,
	input					avmm_clk	,
	input					osc_clk		,
	input					clk_die_a ,
	input					clk_die_b ,
	input					reset_die_a ,
	input					reset_die_b ,

	input	[31:0]			master_address,       // width = 32,       master.address
    output	[31:0]			master_readdata,      // width = 32,             .readdata
    input					master_read,          //  width = 1,             .read
    input					master_write,         //  width = 1,             .write
    input	[31:0]			master_writedata,     // width = 32,             .writedata
    output					master_waitrequest,   //  width = 1,             .waitrequest
    output					master_readdatavalid, //  width = 1,             .readdatavalid
    output	[3:0]			master_byteenable,    //  width = 4,             .byteenable
	

    output   [7:0]          die_a_pl_stream,
	output                  die_a_pl_error,
	output                  die_a_pl_trainerror,
	output                  die_a_pl_cerror,
	output                  die_a_pl_stallreq,
    output                  die_a_pl_phyinl1,
	output                  die_a_pl_phyinl2,
	output   [3:0]          die_a_pl_state_sts,
    output                  die_a_pl_quiesce,
	output   [2:0]          die_a_pl_lnk_cfg,
	output                  die_a_pl_lnk_up,
	output                  die_a_pl_rxframe_errmask,
	output   [0:0]          die_a_pl_portmode,
	output                  die_a_pl_portmode_val,
	output   [2:0]          die_a_pl_speedmode,
	output   [2:0]          die_a_pl_clr_lnkeqreq,
	output   [2:0]          die_a_pl_set_lnkeqreq,
	output                  die_a_pl_inband_pres,
	output   [7:0]          die_a_pl_ptm_rx_delay,
	output                  die_a_pl_setlabs,
    output                  die_a_pl_surprise_lnk_down,
    output   [2:0]          die_a_pl_protocol,
    output                  die_a_pl_protocol_vld,
    output                  die_a_pl_err_pipestg,
    output                  die_a_pl_wake_ack,
    output                  die_a_pl_phyinrecenter,
    output   [7:0]          die_a_pl_cfg,
    output                  die_a_pl_cfg_vld,
	output                  die_a_pl_setlbms,
	output                  die_a_pl_clk_req,
	input                   die_a_lp_tmstmp,
    input   [7:0]           die_a_lp_tmstmp_stream,
    output                  die_a_pl_tmstmp,
    output   [7:0]          die_a_pl_tmstmp_stream,
    input   [7:0]           die_a_lp_stream,
    input                   die_a_lp_stallack,
    input                   die_a_lp_linkerror,
    input                   die_a_lp_flushed_all,
    input                   die_a_lp_rcvd_crc_err,
    input                   die_a_lp_wake_req,
    input                   die_a_lp_force_detect,
    input   [7:0]           die_a_lp_cfg,
    input                   die_a_lp_cfg_vld,
	input   [15:0]          die_a_lp_crc,
    input                   die_a_lp_crc_valid,
    input                   die_a_lp_device_present,
    input                   die_a_lp_clk_ack,
    input   [1:0]           die_a_lp_pri,
    input                   die_a_lpbk_en,
	
	output					die_a_rwd_valid	,
	output	[527:0]			die_a_rwd_data	,
	output	[527:0]			die_a_drs_data	,
	output                  die_a_drs_valid ,
	output   [7:0]          die_b_pl_stream,
	output                  die_b_pl_error,
	output                  die_b_pl_trainerror,
	output                  die_b_pl_cerror,
	output                  die_b_pl_stallreq,
    output                  die_b_pl_phyinl1,
	output                  die_b_pl_phyinl2,
	output   [3:0]          die_b_pl_state_sts,
    output                  die_b_pl_quiesce,
	output   [2:0]          die_b_pl_lnk_cfg,
	output                  die_b_pl_lnk_up,
	output                  die_b_pl_rxframe_errmask,
	output   [0:0]          die_b_pl_portmode,
	output                  die_b_pl_portmode_val,
	output   [2:0]          die_b_pl_speedmode,
	output   [2:0]          die_b_pl_clr_lnkeqreq,
	output   [2:0]          die_b_pl_set_lnkeqreq,
	output                  die_b_pl_inband_pres,
	output   [7:0]          die_b_pl_ptm_rx_delay,
	output                  die_b_pl_setlabs,
    output                  die_b_pl_surprise_lnk_down,
    output   [2:0]          die_b_pl_protocol,
    output                  die_b_pl_protocol_vld,
    output                  die_b_pl_err_pipestg,
    output                  die_b_pl_wake_ack,
    output                  die_b_pl_phyinrecenter,
    output   [7:0]          die_b_pl_cfg,
    output                  die_b_pl_cfg_vld,
	output                  die_b_pl_setlbms,
    output   [15:0]         die_b_pl_crc,
    output                  die_b_pl_crc_valid,
	output                  die_b_pl_clk_req,
	input                   die_b_lp_tmstmp,
    input   [7:0]           die_b_lp_tmstmp_stream,
    output                  die_b_pl_tmstmp,
    output   [7:0]          die_b_pl_tmstmp_stream,
    input   [7:0]           die_b_lp_stream,
    input                   die_b_lp_stallack,
    input                   die_b_lp_linkerror,
    input                   die_b_lp_flushed_all,
    input                   die_b_lp_rcvd_crc_err,
    input                   die_b_lp_wake_req,
    input                   die_b_lp_force_detect,
    input   [7:0]           die_b_lp_cfg,
    input                   die_b_lp_cfg_vld,
	input   [15:0]          die_b_lp_crc,
    input                   die_b_lp_crc_valid,
    input                   die_b_lp_device_present,
    input                   die_b_lp_clk_ack,
    input   [1:0]           die_b_lp_pri,
    input                   die_b_lpbk_en
	
);

localparam 			MASTER_RATE 	= 2;
localparam 			SLAVE_RATE 		= 2;
parameter 			TOTAL_CHNL_NUM 	= 24;
parameter 			DWIDTH 			= 40;
parameter 			DATAWIDTH 		= 40;
	
wire [0:0]									die_b_pl_valid;
wire [1:0]									remote_rate_die_a;
wire [1:0]									remote_rate_die_b;
wire [`TB_DIE_A_AIB_LANES-1 : 0]  			die_a_fifo_full  ;
wire [`TB_DIE_A_AIB_LANES-1 : 0]  			die_a_fifo_pfull ;
wire [`TB_DIE_A_AIB_LANES-1 : 0]  			die_a_fifo_empty ;
wire [`TB_DIE_A_AIB_LANES-1 : 0]  			die_a_fifo_pempty;
wire [`TB_DIE_B_AIB_LANES-1 : 0]  			die_b_fifo_full  ;
wire [`TB_DIE_B_AIB_LANES-1 : 0]  			die_b_fifo_pfull ;
wire [`TB_DIE_B_AIB_LANES-1 : 0]  			die_b_fifo_empty ;
wire [`TB_DIE_B_AIB_LANES-1 : 0]  			die_b_fifo_pempty;

wire [31:0]  								w_mem_wr_rd_addr;
wire [511:0] 								w_mem_wr_data;
wire [511:0] 								w_mem_rd_data;
wire 		 								w_mem_wr_en;

wire [159:0]								master_ll2ca_3;
wire [159:0]								master_ll2ca_2;
wire [159:0]								master_ll2ca_1;
wire [159:0]								master_ll2ca_0;
wire [159:0]								master_ca2ll_3;
wire [159:0]								master_ca2ll_2;
wire [159:0]								master_ca2ll_1;
wire [159:0]								master_ca2ll_0;
wire [159:0]								master_phy2ca_3;
wire [159:0]								master_phy2ca_2;
wire [159:0]								master_phy2ca_1;
wire [159:0]								master_phy2ca_0;
wire [159:0]								master_ca2phy_3;
wire [159:0]								master_ca2phy_2;
wire [159:0]								master_ca2phy_1;
wire [159:0]								master_ca2phy_0;

wire [159:0]								slave_ca2phy_3;
wire [159:0]								slave_ca2phy_2;
wire [159:0]								slave_ca2phy_1;
wire [159:0]								slave_ca2phy_0;
wire [159:0]								slave_phy2ca_3;
wire [159:0]								slave_phy2ca_2;
wire [159:0]								slave_phy2ca_1;
wire [159:0]								slave_phy2ca_0;
wire [159:0]								slave_ca2ll_3;
wire [159:0]								slave_ca2ll_2;
wire [159:0]								slave_ca2ll_1;
wire [159:0]								slave_ca2ll_0;
wire [159:0]								slave_ll2ca_3;
wire [159:0]								slave_ll2ca_2;
wire [159:0]								slave_ll2ca_1;
wire [159:0]								slave_ll2ca_0;
wire [639:0]								die_a_tx_din;
wire [639:0]								die_b_tx_din;
wire [639:0]								die_a_rx_dout;
wire [639:0]								die_b_rx_dout;
wire 										w_m0_align_fly;
wire [7:0] 									w_m0_tx_stb_wd_sel;
wire [39:0] 								w_m0_tx_stb_bit_sel;
wire [15:0] 								w_m0_tx_stb_intv;
wire [7:0] 									w_m0_rx_stb_wd_sel;
wire [39:0] 								w_m0_rx_stb_bit_sel;
wire [15:0] 								w_m0_rx_stb_intv;
wire [5:0] 									w_m0_fifo_full_val  ;
wire [5:0] 									w_m0_fifo_pfull_val ;
wire [2:0] 									w_m0_fifo_empty_val ;
wire [2:0] 									w_m0_fifo_pempty_val;
wire [2:0] 									w_m0_rden_dly;
wire 										w_m0_tx_online;
wire 										w_m0_rx_online;
wire 										w_s0_align_fly;
wire [7:0] 									w_s0_tx_stb_wd_sel;
wire [39:0] 								w_s0_tx_stb_bit_sel;
wire [15:0] 								w_s0_tx_stb_intv;
wire [7:0] 									w_s0_rx_stb_wd_sel;
wire [39:0] 								w_s0_rx_stb_bit_sel;
wire [15:0] 								w_s0_rx_stb_intv;
wire [5:0] 									w_s0_fifo_full_val  ;
wire [5:0] 									w_s0_fifo_pfull_val ;
wire [2:0] 									w_s0_fifo_empty_val ;
wire [2:0] 									w_s0_fifo_pempty_val;
wire [2:0] 									w_s0_rden_dly;
wire 										w_s0_tx_online;
wire 										w_s0_rx_online;
wire [23:0]									m1_ms_tx_transfer_en;
wire [23:0]									m1_ms_rx_transfer_en;
wire [23:0]									m1_sl_tx_transfer_en;
wire [23:0]									m1_sl_rx_transfer_en;
wire [23:0]									s1_ms_rx_transfer_en;
wire [23:0]									s1_ms_tx_transfer_en;
wire [23:0]									s1_sl_rx_transfer_en;
wire [23:0]									s1_sl_tx_transfer_en;
wire [7679:0]	  							data_in_f;
wire 										m0_ns_mac_rdy	;
wire [3:0]									m0_adapter_rstn;
wire 										s0_ns_mac_rdy	;
wire [3:0]									s0_adapter_rstn;
wire [0:0]              				 	die_a_pl_valid;
wire [`TB_DIE_A_LPIF_DATA_WIDTH*8-1:0]   	die_a_pl_data;
	
	
wire										die_b_pl_exit_cg_req;
wire										die_b_pl_trdy;
						
wire 										die_b_lp_exit_cg_ack;
wire 										die_b_lp_irdy;
wire [0:0]									die_b_lp_valid;
wire [511:0]								die_b_lp_data;
wire [3:0]									die_b_lp_state_req;
wire [1:0]									test_done;

wire										die_a_pl_exit_cg_req;
wire										die_a_pl_trdy;

wire 										die_a_lp_exit_cg_ack;
wire 										die_a_lp_irdy;
wire [0:0]									die_a_lp_valid;
wire [511:0]								die_a_lp_data;
wire [3:0]									die_a_lp_state_req;
wire [511:0]								die_b_pl_data;
wire [31:0]        							w_delay_x_value;
wire [31:0]        							w_delay_y_value;
wire [31:0]        							w_delay_z_value;
wire [3:0]        							s0_ns_adapter_rstn;
wire [23:0]        							w_s1_m_fs_fwd_clk;
wire [23:0]        							w_m1_m_fs_fwd_clk;
wire [23:0]        							w_m1_m_fs_rcv_clk;
wire 										die_a_lp_cfg_valid;

wire [DATAWIDTH * TOTAL_CHNL_NUM * 8 -1 :0] die_a_data_in_f;
wire [DATAWIDTH * TOTAL_CHNL_NUM * 8 -1 :0] die_b_data_in_f;
wire [DATAWIDTH * TOTAL_CHNL_NUM * 2 -1 :0] data_in;
wire [DATAWIDTH * TOTAL_CHNL_NUM * 8 -1 :0] data_out_f;
wire [DATAWIDTH * TOTAL_CHNL_NUM * 2 -1 :0] data_out;
wire [DATAWIDTH * TOTAL_CHNL_NUM * 8 -1 :0] s_data_in_f;
wire [DATAWIDTH * TOTAL_CHNL_NUM * 2 -1 :0] s_data_in;
wire [DATAWIDTH * TOTAL_CHNL_NUM * 8 -1 :0] s_data_out_f;
wire [DATAWIDTH * TOTAL_CHNL_NUM * 2 -1 :0] s_data_out;

wire [15:0]									w_die_a_lp_crc_data ;
wire [15:0]									w_die_b_crc_data ;
wire 										w_die_a_lp_crc_valid;
wire 										w_die_b_crc_data_valid;
wire 										w_test_complete;
wire [15:0]                					die_a_pl_crc;
wire                                    	die_a_pl_crc_valid;
wire [1919:0]                           	gen1_data_out_f;
wire [1919:0]                           	gen1_data_in_f;
	


bit[15:0]  GENERIC_DELAY_X_VALUE = 16'd10 ;
bit[15:0]  GENERIC_DELAY_Y_VALUE = 16'd30 ;
bit[15:0]  GENERIC_DELAY_Z_VALUE = 16'd800 ; // real system value 16'd8000 ;

bit[15:0]  MASTER_DELAY_X_VALUE = w_delay_x_value[15:0] / MASTER_RATE;//`MSR_GEAR;
bit[15:0]  MASTER_DELAY_Y_VALUE = w_delay_y_value[15:0] / MASTER_RATE;//`MSR_GEAR;
bit[15:0]  MASTER_DELAY_Z_VALUE = w_delay_z_value[15:0] / MASTER_RATE;//`MSR_GEAR;

bit[15:0]  SLAVE_DELAY_X_VALUE = w_delay_x_value[15:0] / SLAVE_RATE;//`SLV_GEAR;
bit[15:0]  SLAVE_DELAY_Y_VALUE = w_delay_y_value[15:0] / SLAVE_RATE;//`SLV_GEAR;
bit[15:0]  SLAVE_DELAY_Z_VALUE = w_delay_z_value[15:0] / SLAVE_RATE;//`SLV_GEAR;



assign master_ll2ca_3 = die_a_data_in_f[639:480];
assign master_ll2ca_2 = die_a_data_in_f[476:320];
assign master_ll2ca_1 = die_a_data_in_f[316:160];
assign master_ll2ca_0 = die_a_data_in_f[159:0];


assign slave_ll2ca_3 = die_b_data_in_f[639:480];
assign slave_ll2ca_2 = die_b_data_in_f[476:320];
assign slave_ll2ca_1 = die_b_data_in_f[316:160];
assign slave_ll2ca_0 = die_b_data_in_f[159:0];

assign master_phy2ca_0 = data_out_f[159:0];
assign master_phy2ca_1 = data_out_f[479:320];
assign master_phy2ca_2 = data_out_f[799:640];
assign master_phy2ca_3 = data_out_f[1119:960];

assign data_in_f 	= {6560'd0,master_ca2phy_3,160'd0,master_ca2phy_2,160'd0,master_ca2phy_1,160'd0,master_ca2phy_0};
assign s_data_in_f 	= {6560'd0,slave_ca2phy_3,160'd0,slave_ca2phy_2,160'd0,slave_ca2phy_1,160'd0,slave_ca2phy_0};

assign slave_phy2ca_3 = s_data_out_f[1119:960];
assign slave_phy2ca_2 = s_data_out_f[799:640];
assign slave_phy2ca_1 = s_data_out_f[479:320];
assign slave_phy2ca_0 = s_data_out_f[159:0];

assign die_a_rx_dout  = {master_ca2ll_3,master_ca2ll_2,master_ca2ll_1,master_ca2ll_0};
assign die_b_rx_dout  = {slave_ca2ll_3,slave_ca2ll_2,slave_ca2ll_1,slave_ca2ll_0};

assign remote_rate_die_a = 2'b01;
assign remote_rate_die_b = 2'b01;

assign die_a_lp_cfg_valid = 1'b0;

top_aib #(.DWIDTH(DATAWIDTH), .TOTAL_CHNL_NUM(TOTAL_CHNL_NUM)) aib_model_inst(
	.avmm_clk(avmm_clk),
	.osc_clk(osc_clk),
	.m1_data_in_f(data_in_f),
    .m1_data_out_f(data_out_f),
    .m1_data_in(data_in), //output data to pad
    .m1_data_out(data_out),
	
	.s1_data_in_f(s_data_in_f), 
	.s1_data_out_f(s_data_out_f),
	.s1_data_in(s_data_in), 
	.s1_data_out(s_data_out),
	.m0_ns_mac_rdy	(m0_ns_mac_rdy	),
	.m0_adapter_rstn({6{m0_adapter_rstn}}),
	.s0_ns_mac_rdy	(s0_ns_mac_rdy	),
	.s0_adapter_rstn({6{s0_adapter_rstn}}),
	
	.m1_m_ns_fwd_clk({TOTAL_CHNL_NUM{ms_fwd_clk}}), //output data clock
    .m1_m_ns_rcv_clk({TOTAL_CHNL_NUM{ms_fwd_clk}}),
    .m1_m_fs_rcv_clk(w_m1_m_fs_rcv_clk),
    .m1_m_fs_fwd_clk(w_m1_m_fs_fwd_clk),
	.s1_s_ns_fwd_clk({TOTAL_CHNL_NUM{sl_fwd_clk}}),
	.s1_s_ns_rcv_clk({TOTAL_CHNL_NUM{sl_fwd_clk}}),
	.s1_s_fs_rcv_clk(),
	.s1_s_fs_fwd_clk(),
    .m1_m_wr_clk({TOTAL_CHNL_NUM{ms_wr_clk}}),
    .m1_m_rd_clk({TOTAL_CHNL_NUM{ms_rd_clk}}),
	
	.s1_s_wr_clk({TOTAL_CHNL_NUM{sl_wr_clk}}),
    .s1_s_rd_clk({TOTAL_CHNL_NUM{sl_rd_clk}}),
	.o_m1_conf_done(),
	.o_s1_conf_done(),
	.o_m1_por(w_m0_por),
	.o_s1_por(w_s0_por),
	.m1_ms_tx_transfer_en(m1_ms_tx_transfer_en),
    .m1_ms_rx_transfer_en(m1_ms_rx_transfer_en),
    .m1_sl_tx_transfer_en(m1_sl_tx_transfer_en),
    .m1_sl_rx_transfer_en(m1_sl_rx_transfer_en),
	.m1_i_osc_clk(osc_clk),   //Only for master mode
	.s1_gen1_data_in_f(gen1_data_in_f),
    .s1_gen1_data_out_f(gen1_data_out_f),   
	.s1_m_wr_clk({TOTAL_CHNL_NUM{sl_wr_clk}}),
    .s1_m_rd_clk({TOTAL_CHNL_NUM{sl_rd_clk}}),
	.s1_m_ns_fwd_clk({TOTAL_CHNL_NUM{sl_fwd_clk}}),
	.s1_m_fs_fwd_clk(w_s1_m_fs_fwd_clk),
    .s1_ms_rx_transfer_en(s1_ms_rx_transfer_en),
    .s1_ms_tx_transfer_en(s1_ms_tx_transfer_en),
    .s1_sl_rx_transfer_en(s1_sl_rx_transfer_en),
    .s1_sl_tx_transfer_en(s1_sl_tx_transfer_en)

);

// DIE A
    //--------------------------------------------------------------
    lpif  #(
        .AIB_VERSION           (`TB_DIE_A_AIB_VERSION),
        .AIB_GENERATION        (`TB_DIE_A_AIB_GENERATION),
        .AIB_LANES             (`TB_DIE_A_AIB_LANES),
        .AIB_BITS_PER_LANE     (`TB_DIE_A_AIB_BITS_PER_LANE),
        .AIB_CLOCK_RATE        (`TB_DIE_A_AIB_CLOCK_RATE),
        .LPIF_CLOCK_RATE       (`TB_DIE_A_LPIF_CLOCK_RATE),
        .LPIF_DATA_WIDTH       (`TB_DIE_A_LPIF_DATA_WIDTH),
        .LPIF_PIPELINE_STAGES  (`TB_DIE_A_LPIF_PIPELINE_STAGES),
        .MEM_CACHE_STREAM_ID   (`TB_DIE_A_MEM_CACHE_STREAM_ID),
        .IO_STREAM_ID          (`TB_DIE_A_IO_STREAM_ID),
        .ARB_MUX_STREAM_ID     (`TB_DIE_A_ARB_MUX_STREAM_ID),
	.LPIF_PL_PROTOCOL      (`TB_DIE_A_LPIF_PLPROTOCOL),
     `ifdef DEVICE_A_HOST_B
	.LPIF_IS_HOST          ( 1'b0                     ),
     `else
	.LPIF_IS_HOST          ( 1'b1                     ),
     `endif
	.PTM_RX_DELAY          (`TB_DIE_A_PTM_RX_DELAY     )
    ) 
	lpif_die_a (
    // LPIF Interface
    .lclk                   (clk_die_a                ),
    .reset                  (reset_die_a              ),
    .remote_rate            (remote_rate_die_a                             ),
    //OUTPUT
    .pl_trdy                  (die_a_pl_trdy),
    .pl_data                  (die_a_pl_data),
    .pl_valid                 (die_a_pl_valid[`TB_DIE_A_PL_VALID-1:0]),
    .pl_stream                (die_a_pl_stream            ),
    .pl_error                 (die_a_pl_error             ),
    .pl_trainerror            (die_a_pl_trainerror        ),
    .pl_cerror                (die_a_pl_cerror            ),
    .pl_stallreq              (die_a_pl_stallreq          ),
    .pl_phyinl1               (die_a_pl_phyinl1           ),
    .pl_phyinl2               (die_a_pl_phyinl2           ),
    .pl_state_sts             (die_a_pl_state_sts         ),
    .pl_quiesce               (die_a_pl_quiesce           ),
    .pl_lnk_cfg               (die_a_pl_lnk_cfg           ),
    .pl_lnk_up                (die_a_pl_lnk_up            ),
    .pl_rxframe_errmask       (die_a_pl_rxframe_errmask   ),
    .pl_portmode              (die_a_pl_portmode[0]       ),
    .pl_portmode_val          (die_a_pl_portmode_val      ),
    .pl_speedmode             (die_a_pl_speedmode         ),
    .pl_clr_lnkeqreq          (die_a_pl_clr_lnkeqreq      ),
    .pl_set_lnkeqreq          (die_a_pl_set_lnkeqreq      ),
    .pl_inband_pres           (die_a_pl_inband_pres       ),
    .pl_ptm_rx_delay          (die_a_pl_ptm_rx_delay      ),
    .pl_setlabs               (die_a_pl_setlabs           ),
    .pl_surprise_lnk_down     (die_a_pl_surprise_lnk_down ),
    .pl_protocol              (die_a_pl_protocol          ),
    .pl_protocol_vld          (die_a_pl_protocol_vld      ),
    .pl_err_pipestg           (die_a_pl_err_pipestg       ),
    .pl_wake_ack              (die_a_pl_wake_ack          ),
    .pl_phyinrecenter         (die_a_pl_phyinrecenter     ),
    .pl_exit_cg_req           (die_a_pl_exit_cg_req       ),
    .pl_cfg                   (die_a_pl_cfg               ),
    .pl_cfg_vld               (die_a_pl_cfg_vld           ),
    .pl_setlbms               (die_a_pl_setlbms           ),
    .pl_crc                   (die_a_pl_crc),
    .pl_crc_valid             (die_a_pl_crc_valid         ),
    .pl_clk_req               (die_a_pl_clk_req           ),
    
    .pl_tmstmp                (die_a_pl_tmstmp            ),
    .pl_tmstmp_stream         (die_a_pl_tmstmp_stream     ),
    //INPUT
    .lp_irdy                  (die_a_lp_irdy              ),
    .lp_data                  (die_a_lp_data),
    // .lp_data                  ('d0),
    .lp_valid                 (die_a_lp_valid[`TB_DIE_A_PL_VALID-1:0]),
    .lp_stream                (die_a_lp_stream            ),
    .lp_stallack              (die_a_lp_stallack          ),
    .lp_state_req             (die_a_lp_state_req         ),
    .lp_tmstmp                (die_a_lp_tmstmp            ),
    .lp_tmstmp_stream         (die_a_lp_tmstmp_stream     ),
    .lp_linkerror             (die_a_lp_linkerror         ),
    .lp_flushed_all           (die_a_lp_flushed_all       ),
    .lp_rcvd_crc_err          (die_a_lp_rcvd_crc_err      ),
    .lp_wake_req              (die_a_lp_wake_req          ),
    .lp_force_detect          (die_a_lp_force_detect      ),
    .lp_exit_cg_ack           (die_a_lp_exit_cg_ack       ),
    .lp_cfg                   (die_a_lp_cfg               ),
    .lp_cfg_vld               (die_a_lp_cfg_valid         ),
    .lp_crc                   (w_die_a_lp_crc_data),
    .lp_crc_valid             (w_die_a_lp_crc_valid       ),
    .lp_device_present        (die_a_lp_device_present    ),
    .lp_clk_ack               (die_a_lp_clk_ack           ),
    .lp_pri                   (die_a_lp_pri               ),
    .lpbk_en                  (die_a_lpbk_en),

     //OUTPUT
    `ifndef LPIF_ONE_CHANNEL
       .data_in_f           (die_a_data_in_f [639:0]),
    `else
       .data_in_f           (die_a_tx_din),
    `endif
    .ns_mac_rdy             (m0_ns_mac_rdy),
    //INPUT                  
    .fs_mac_rdy             (top_aib.intf_m1.fs_mac_rdy[0]),
    .ns_adapter_rstn        (m0_adapter_rstn ), //4bits
    .sl_rx_transfer_en      (s1_sl_rx_transfer_en[3:0]), //4bits 
   `ifdef MS_AIB_GEN1
    .ms_tx_transfer_en      (master_ver1_tx_transfer_en[`TB_DIE_A_NUM_CHANNELS-1:0]),
    .ms_rx_transfer_en      (master_ver1_rx_transfer_en[`TB_DIE_A_NUM_CHANNELS-1:0]),
   `else
    .ms_tx_transfer_en      (m1_ms_tx_transfer_en[3:0]           ),				
    .ms_rx_transfer_en      (m1_ms_rx_transfer_en[3:0]           ),               
   `endif                                                                   
    .sl_tx_transfer_en      (s1_sl_tx_transfer_en[3:0]           ),             
    .m_rxfifo_align_done    ({`TB_DIE_A_NUM_CHANNELS{master_align_done}}),
    .wa_error               (4'h0     ),
    .wa_error_cnt           (4'h0     ),
    .dual_mode_select       (1'b1                          ),
    .m_gen2_mode            (`LL_MSR_GEN2_MODE             ),
    .i_conf_done            (top_aib.intf_m1.i_conf_done   ),
    .power_on_reset         ({`TB_DIE_A_NUM_CHANNELS{w_m0_por}}),
  
      .align_done             (master_align_done   ),
      .dout                   (die_a_rx_dout     ),
      .align_err              (master_align_err    ),
      .fifo_full              (die_a_fifo_full    ),
      .fifo_pfull             (die_a_fifo_pfull   ),
      .fifo_empty             (die_a_fifo_empty   ),
      .fifo_pempty            (die_a_fifo_pempty  ),
      .delay_x_value          (MASTER_DELAY_X_VALUE          ),
      .delay_y_value          (MASTER_DELAY_Y_VALUE          ),
      .delay_z_value          (MASTER_DELAY_Z_VALUE          ),
    
    //OUTPUT
    .align_fly              (w_m0_align_fly       ),
    .tx_stb_wd_sel          (w_m0_tx_stb_wd_sel   ),
    .tx_stb_bit_sel         (w_m0_tx_stb_bit_sel  ),
    .tx_stb_intv            (w_m0_tx_stb_intv     ),
    .rx_stb_wd_sel          (w_m0_rx_stb_wd_sel   ),
    .rx_stb_bit_sel         (w_m0_rx_stb_bit_sel  ),
    .rx_stb_intv            (w_m0_rx_stb_intv     ),
    .fifo_full_val          (w_m0_fifo_full_val   ),
    .fifo_pfull_val         (w_m0_fifo_pfull_val  ),
    .fifo_empty_val         (w_m0_fifo_empty_val  ),
    .fifo_pempty_val        (w_m0_fifo_pempty_val ),
    .tx_online              (w_m0_tx_online       ),
    .rx_online              (w_m0_rx_online       ),
    
    .rden_dly               (w_m0_rden_dly        )
     );

   //--------------------------------------------------------------
   // DIE B
   //--------------------------------------------------------------
    lpif  #(
        .AIB_VERSION           (`TB_DIE_B_AIB_VERSION),
        .AIB_GENERATION        (`TB_DIE_B_AIB_GENERATION),
        .AIB_LANES             (`TB_DIE_B_AIB_LANES),
        .AIB_BITS_PER_LANE     (`TB_DIE_B_AIB_BITS_PER_LANE),
        .AIB_CLOCK_RATE        (`TB_DIE_B_AIB_CLOCK_RATE),
        .LPIF_CLOCK_RATE       (`TB_DIE_B_LPIF_CLOCK_RATE),
        .LPIF_DATA_WIDTH       (`TB_DIE_B_LPIF_DATA_WIDTH),
        .LPIF_PIPELINE_STAGES  (`TB_DIE_B_LPIF_PIPELINE_STAGES),
        .MEM_CACHE_STREAM_ID   (`TB_DIE_B_MEM_CACHE_STREAM_ID),
        .IO_STREAM_ID          (`TB_DIE_B_IO_STREAM_ID),
        .ARB_MUX_STREAM_ID     (`TB_DIE_B_ARB_MUX_STREAM_ID),
	.LPIF_PL_PROTOCOL      (`TB_DIE_B_LPIF_PLPROTOCOL),
     `ifdef DEVICE_A_HOST_B
	.LPIF_IS_HOST          ( 1'b1                     ),
     `else
	.LPIF_IS_HOST          ( 1'b0                     ),
     `endif
	.PTM_RX_DELAY          (`TB_DIE_B_PTM_RX_DELAY     )

    ) lpif_die_b (
    // LPIF Interface
    .lclk                      (clk_die_b                                    ),
    .reset                     (reset_die_b              ),
    .remote_rate               (remote_rate_die_b                            ),
    //OUTPUT
 
    .pl_trdy                  (die_b_pl_trdy              ),
    .pl_data                  (die_b_pl_data),
    .pl_valid                 (die_b_pl_valid[`TB_DIE_B_PL_VALID-1:0]            ),
    .pl_stream                (die_b_pl_stream            ),
    .pl_error                 (die_b_pl_error             ),
    .pl_trainerror            (die_b_pl_trainerror        ),
    .pl_cerror                (die_b_pl_cerror            ),
    .pl_stallreq              (die_b_pl_stallreq          ),
    .pl_phyinl1               (die_b_pl_phyinl1           ),
    .pl_phyinl2               (die_b_pl_phyinl2           ),
    .pl_state_sts             (die_b_pl_state_sts         ),
    .pl_quiesce               (die_b_pl_quiesce           ),
    .pl_lnk_cfg               (die_b_pl_lnk_cfg           ),
    .pl_lnk_up                (die_b_pl_lnk_up            ),
    .pl_rxframe_errmask       (die_b_pl_rxframe_errmask   ),
    .pl_portmode              (die_b_pl_portmode[0]       ),
    .pl_portmode_val          (die_b_pl_portmode_val      ),
    .pl_speedmode             (die_b_pl_speedmode         ),
    .pl_clr_lnkeqreq          (die_b_pl_clr_lnkeqreq      ),
    .pl_set_lnkeqreq          (die_b_pl_set_lnkeqreq      ),
    .pl_inband_pres           (die_b_pl_inband_pres       ),
    .pl_ptm_rx_delay          (die_b_pl_ptm_rx_delay      ),
    .pl_setlabs               (die_b_pl_setlabs           ),
    .pl_surprise_lnk_down     (die_b_pl_surprise_lnk_down ),
    .pl_protocol              (die_b_pl_protocol          ),
    .pl_protocol_vld          (die_b_pl_protocol_vld      ),
    .pl_err_pipestg           (die_b_pl_err_pipestg       ),
    .pl_wake_ack              (die_b_pl_wake_ack          ),
    .pl_phyinrecenter         (die_b_pl_phyinrecenter     ),
    .pl_exit_cg_req           (die_b_pl_exit_cg_req       ),
    .pl_cfg                   (die_b_pl_cfg               ),
    .pl_cfg_vld               (die_b_pl_cfg_vld           ),
    .pl_setlbms               (die_b_pl_setlbms           ),
    .pl_crc                   (die_b_pl_crc),
    .pl_crc_valid             (die_b_pl_crc_valid         ),
    .pl_clk_req               (die_b_pl_clk_req           ),

    .pl_tmstmp                (die_b_pl_tmstmp                             ),
    .pl_tmstmp_stream         (die_b_pl_tmstmp_stream                      ),
    //INPUT
    .lp_irdy                  (die_b_lp_irdy              ),
    .lp_data                  (die_b_lp_data),
    .lp_valid                 (die_b_lp_valid[`TB_DIE_B_PL_VALID-1:0]),
    .lp_stream                (die_b_lp_stream            ),
    .lp_stallack              (die_b_lp_stallack          ),
    .lp_state_req             (die_b_lp_state_req         ),
    .lp_tmstmp                (die_b_lp_tmstmp                               ),
    .lp_tmstmp_stream         (die_b_lp_tmstmp_stream                        ),
    .lp_linkerror             (die_b_lp_linkerror         ),
    .lp_flushed_all           (die_b_lp_flushed_all       ),
    .lp_rcvd_crc_err          (die_b_lp_rcvd_crc_err      ),
    .lp_wake_req              (die_b_lp_wake_req          ),
    .lp_force_detect          (die_b_lp_force_detect      ),
    .lp_exit_cg_ack           (die_b_lp_exit_cg_ack       ),
    .lp_cfg                   (die_b_lp_cfg               ),
    .lp_cfg_vld               (die_b_lp_cfg_vld           ),
    .lp_crc                   (w_die_b_crc_data),
    .lp_crc_valid             (w_die_b_crc_data_valid         ),
    .lp_device_present        (die_b_lp_device_present    ),
    .lp_clk_ack               (die_b_lp_clk_ack           ),
    .lp_pri                   (die_b_lp_pri               ),
    .lpbk_en                  (die_b_lpbk_en),

     //OUTPUT
    `ifndef LPIF_ONE_CHANNEL
       .data_in_f              ( die_b_data_in_f[639:0]     ),
    `else
       .data_in_f              ( die_b_tx_din),
    `endif
    .ns_mac_rdy                (s0_ns_mac_rdy),
    //INPUT                    
    .fs_mac_rdy                (top_aib.intf_s1.fs_mac_rdy[0]),
    // .ns_adapter_rstn           (s0_ns_adapter_rstn),
    .ns_adapter_rstn           (s0_adapter_rstn),
    .sl_rx_transfer_en         (s1_sl_rx_transfer_en[3:0]               ), //connect to AIB
   `ifdef MS_AIB_GEN1
    .ms_tx_transfer_en         (master_ver1_tx_transfer_en[`TB_DIE_B_NUM_CHANNELS-1:0]),
    .ms_rx_transfer_en         (master_ver1_rx_transfer_en[`TB_DIE_B_NUM_CHANNELS-1:0]),
   `else
    .ms_tx_transfer_en         (m1_ms_tx_transfer_en[3:0]         ), //connect to AIB
    .ms_rx_transfer_en         (m1_ms_rx_transfer_en[3:0]         ), //connect to AIB
   `endif
    .sl_tx_transfer_en         (s1_sl_tx_transfer_en[3:0]              ), // connect to AIB
    .m_rxfifo_align_done       ({`TB_DIE_B_NUM_CHANNELS{slave_align_done}}), 
    .wa_error                  (4'h0                     ),
    .wa_error_cnt              (4'h0                 ),
    .dual_mode_select          (1'b1                             ),
    .m_gen2_mode               (`LL_MSR_GEN2_MODE                ),
    .i_conf_done               (top_aib.intf_s1.i_conf_done              ), //connec to AIB
    .power_on_reset            ({`TB_DIE_B_NUM_CHANNELS{w_s0_por}}), //connec to AIB

      .align_done                (slave_align_done                ),   
      .align_err                 (slave_align_err                ),     
      .fifo_full                 (die_b_fifo_full                 ), 
      .fifo_pfull                (die_b_fifo_pfull                ), 
      .fifo_empty                (die_b_fifo_empty                ), 
      .fifo_pempty               (die_b_fifo_pempty               ), 
      .delay_x_value             (SLAVE_DELAY_X_VALUE                        ), 
      .delay_y_value             (SLAVE_DELAY_Y_VALUE                        ),
      .delay_z_value             (SLAVE_DELAY_Z_VALUE                        ), 
      .dout                      (die_b_rx_dout                   ),

    //OUTPUT
    .align_fly                 (w_s0_align_fly       ),
    .tx_stb_wd_sel             (w_s0_tx_stb_wd_sel   ),
    .tx_stb_bit_sel            (w_s0_tx_stb_bit_sel  ),
    .tx_stb_intv               (w_s0_tx_stb_intv     ),
    .rx_stb_wd_sel             (w_s0_rx_stb_wd_sel   ),
    .rx_stb_bit_sel            (w_s0_rx_stb_bit_sel  ),
    .rx_stb_intv               (w_s0_rx_stb_intv     ),
    .fifo_full_val             (w_s0_fifo_full_val   ),
    .fifo_pfull_val            (w_s0_fifo_pfull_val  ),
    .fifo_empty_val            (w_s0_fifo_empty_val  ),
    .fifo_pempty_val           (w_s0_fifo_pempty_val ),
    .tx_online                 (w_s0_tx_online       ),
    .rx_online                 (w_s0_rx_online       ),
                                
	.rden_dly                  (w_s0_rden_dly        )
   ) ;

//CHANNEL ALIGNMENT HOST
//
ca #(.NUM_CHANNELS      (4),           // 2 Channels
        .BITS_PER_CHANNEL  (160),          // Half Rate Gen1 is 80 bits
        .AD_WIDTH          (5),           // Allows 16 deep FIFO
        .SYNC_FIFO         (1'b1))        // Synchronous FIFO
   ca_master_i
     (/*AUTOINST*/
      // Outputs
      .tx_dout				({master_ca2phy_3[159:0] , master_ca2phy_2[159:0] , master_ca2phy_1[159:0] , master_ca2phy_0[159:0]}), // Templated // to AIB master
      .rx_dout				({master_ca2ll_3[159:0]  , master_ca2ll_2[159:0]  , master_ca2ll_1[159:0]  , master_ca2ll_0[159:0]}), // Templated // To LPIF die A
      .align_done			(master_align_done),	 // Templated
      .align_err			(master_align_err),	 // Templated
      .tx_stb_pos_err		(master_tx_stb_pos_err), // Templated									      
      .tx_stb_pos_coding_err(master_tx_stb_pos_coding_err), // Templated                              
      .rx_stb_pos_err		(master_rx_stb_pos_err), // Templated                                    
      .rx_stb_pos_coding_err(master_rx_stb_pos_coding_err), // Templated                                
      .fifo_full			(die_a_fifo_full  ),			 // Templated                             
      .fifo_pfull			(die_a_fifo_pfull ),			 // Templated                            
      .fifo_empty			(die_a_fifo_empty ),			 // Templated                               
      .fifo_pempty			(die_a_fifo_pempty),			 // Templated                             
      // Inputs                                                                                      
      .lane_clk				({4{clk_die_a}}),	 // Templated                                        
      .com_clk				(clk_die_a),		 // Templated                                           
      .rst_n				(reset_die_a),		 // Templated                                       w_m0_tx_online      
      .tx_online			(w_m0_tx_online), // Templated    w_m0_rx_online      
      .rx_online			(w_m0_rx_online), // Templated    
      .tx_stb_en			(1'b0),			 // Templated                                                  
      .tx_stb_rcvr			(1'b0),			 // Templated
      .align_fly			(w_m0_align_fly),			 // Templated
      .rden_dly				(w_m0_rden_dly),			 // Templated
      .delay_x_value        (MASTER_DELAY_X_VALUE),
      .delay_z_value        (MASTER_DELAY_Z_VALUE),
      .tx_stb_wd_sel		(w_m0_tx_stb_wd_sel),		 // Templated
      .tx_stb_bit_sel		(w_m0_tx_stb_bit_sel),	 // Templated
      .tx_stb_intv			(w_m0_tx_stb_intv),		 // Templated
      .rx_stb_wd_sel		(w_m0_rx_stb_wd_sel),		 // Templated
      .rx_stb_bit_sel		(w_m0_rx_stb_bit_sel),	 // Templated
      .rx_stb_intv			(w_m0_rx_stb_intv),		 // Templated
      .tx_din				({master_ll2ca_3[159:0]  , master_ll2ca_2[159:0]  , master_ll2ca_1[159:0]  , master_ll2ca_0[159:0]}), // Templated //from lpif die A
      .rx_din				({master_phy2ca_3[159:0] , master_phy2ca_2[159:0] , master_phy2ca_1[159:0] , master_phy2ca_0[159:0]}), // Templated // from AIB master
      .fifo_full_val		(w_m0_fifo_full_val),		 // Templated
      .fifo_pfull_val		(w_m0_fifo_pfull_val),		 // Templated
      .fifo_empty_val		(w_m0_fifo_empty_val),			 // Templated
      .fifo_pempty_val		(w_m0_fifo_pempty_val));			 // Templated

   /* ca AUTO_TEMPLATE (
      .lane_clk				({7{s_wr_clk}}),
      .com_clk				(s_wr_clk),
      .rst_n				(s_wr_rst_n),

      .align_done			(slave_align_done),
      .align_err			(slave_align_err),
      .tx_stb_pos_err			(slave_tx_stb_pos_err),
      .tx_stb_pos_coding_err		(slave_tx_stb_pos_coding_err),
      .rx_stb_pos_err			(slave_rx_stb_pos_err),
      .rx_stb_pos_coding_err		(slave_rx_stb_pos_coding_err),

      .tx_online			(&{slave_sl_tx_transfer_en,slave_ms_tx_transfer_en}),
      .rx_online			(&{slave_sl_tx_transfer_en,slave_ms_tx_transfer_en}),

      .tx_stb_en			(1'b1),
      .tx_stb_rcvr			(1'b1),                 // recover strobes
      .align_fly			('0),                   // Only look for strobe once
      .rden_dly				('0),                   // No delay before outputting data
      .delay_x_value                    (SLAVE_DELAY_X_VALUE),
      .delay_z_value                    (SLAVE_DELAY_Z_VALUE),
      .tx_stb_wd_sel			(8'h01),                // Strobe is at LOC [1]
      .tx_stb_bit_sel			(40'h0000000002),
      .tx_stb_intv			(16'd20),                 // Strobe repeats every 20 cycles
      .rx_stb_wd_sel			(8'h01),                // Strobe is at LOC [1]
      .rx_stb_bit_sel			(40'h0000000002),
      .rx_stb_intv			(16'd20),                 // Strobe repeats every 20 cycles

      .tx_din			        ({slave_ll2ca_6[79:0]  , slave_ll2ca_5[79:0]  , slave_ll2ca_4[79:0]  , slave_ll2ca_3[79:0]  , slave_ll2ca_2[79:0]  , slave_ll2ca_1[79:0]  , slave_ll2ca_0[79:0]})  ,
      .rx_din			        ({slave_phy2ca_6[79:0] , slave_phy2ca_5[79:0] , slave_phy2ca_4[79:0] , slave_phy2ca_3[79:0] , slave_phy2ca_2[79:0] , slave_phy2ca_1[79:0] , slave_phy2ca_0[79:0]})  ,
      .tx_dout			        ({slave_ca2phy_6[79:0] , slave_ca2phy_5[79:0] , slave_ca2phy_4[79:0] , slave_ca2phy_3[79:0] , slave_ca2phy_2[79:0] , slave_ca2phy_1[79:0] , slave_ca2phy_0[79:0]}) ,
      .rx_dout			        ({slave_ca2ll_6[79:0]  , slave_ca2ll_5[79:0]  , slave_ca2ll_4[79:0]  , slave_ca2ll_3[79:0]  , slave_ca2ll_2[79:0]  , slave_ca2ll_1[79:0]  , slave_ca2ll_0[79:0]})  ,

      .fifo_full_val			(6'd16),      // Status
      .fifo_pfull_val			(6'd12),      // Status
      .fifo_empty_val			(3'd0),       // Status
      .fifo_pempty_val			(3'd4),       // Status
      .fifo_full			(),          // Status
      .fifo_pfull			(),          // Status
      .fifo_empty			(),          // Status
      .fifo_pempty			(),          // Status

    );

*/

//CHANNEL ALIGNMENT DEVICE 
//

ca #(.NUM_CHANNELS      (4),           // 2 Channels
        .BITS_PER_CHANNEL  (160),          // Half Rate Gen1 is 80 bits
        .AD_WIDTH          (5),           // Allows 16 deep FIFO
        .SYNC_FIFO         (1'b1))        // Synchronous FIFO
   ca_slave_i
     (/*AUTOINST*/
      // Outputs
      .tx_dout				({slave_ca2phy_3[159:0] , slave_ca2phy_2[159:0] , slave_ca2phy_1[159:0] , slave_ca2phy_0[159:0]}), // Templated
      .rx_dout				({slave_ca2ll_3[159:0]  , slave_ca2ll_2[159:0]  , slave_ca2ll_1[159:0]  , slave_ca2ll_0[159:0]}), // Templated
      .align_done			(slave_align_done),	 // Templated
      .align_err			(slave_align_err),	 // Templated
      .tx_stb_pos_err		(slave_tx_stb_pos_err),	 // Templated
      .tx_stb_pos_coding_err(slave_tx_stb_pos_coding_err), // Templated
      .rx_stb_pos_err		(slave_rx_stb_pos_err),	 // Templated
      .rx_stb_pos_coding_err(slave_rx_stb_pos_coding_err), // Templated
      .fifo_full			(die_b_fifo_full    ),			 // Templated
      .fifo_pfull			(die_b_fifo_pfull   ),			 // Templated
      .fifo_empty			(die_b_fifo_empty   ),			 // Templated
      .fifo_pempty			(die_b_fifo_pempty  ),			 // Templated
      // Inputs
      .lane_clk				({4{clk_die_b}}),	 // Templated
      .com_clk				(clk_die_b),		 // Templated
      .rst_n				(reset_die_b),		 // Templated
	  
	  .tx_online			(w_s0_tx_online), // Templated
      .rx_online			(w_s0_rx_online), // Templated
      .tx_stb_en			(1'b0),			 // Templated
      .tx_stb_rcvr			(1'b0),			 // Templated
      .align_fly			(w_s0_align_fly),		
      .rden_dly				(w_s0_rden_dly),		
      .delay_x_value        (SLAVE_DELAY_X_VALUE),
      .delay_z_value        (SLAVE_DELAY_Z_VALUE),
      .tx_stb_wd_sel		(w_s0_tx_stb_wd_sel),	
      .tx_stb_bit_sel		(w_s0_tx_stb_bit_sel),	
      .tx_stb_intv			(w_s0_tx_stb_intv),		 // Templated
      .rx_stb_wd_sel		(w_s0_rx_stb_wd_sel),	// Templated
      .rx_stb_bit_sel		(w_s0_rx_stb_bit_sel),		 // Templated
      .rx_stb_intv			(w_s0_rx_stb_intv),		 // Templated
      .tx_din				({slave_ll2ca_3[159:0]  , slave_ll2ca_2[159:0]  , slave_ll2ca_1[159:0]  , slave_ll2ca_0[159:0]}), // Templated
      .rx_din				({slave_phy2ca_3[159:0] , slave_phy2ca_2[159:0] , slave_phy2ca_1[159:0] , slave_phy2ca_0[159:0]}), // Templated
      .fifo_full_val		(w_s0_fifo_full_val),	 // Templated
      .fifo_pfull_val		(w_s0_fifo_pfull_val),	 // Templated
      .fifo_empty_val		(w_s0_fifo_empty_val),	 // Templated
      .fifo_pempty_val		(w_s0_fifo_pempty_val)	);	 // Templated


device_lpif_intf device_lpif(

	.clk(clk_die_b),
	.reset_n(reset_die_b),
	.die_b_tx_online(w_s0_tx_online),
	.die_b_rx_online(w_s0_rx_online),
	.die_b_align_done (slave_align_done),
	.die_b_align_error(slave_align_err),
	
	.die_b_pl_exit_cg_req(die_b_pl_exit_cg_req),
	.die_b_pl_trdy(die_b_pl_trdy),
	
	.die_b_pl_data (die_b_pl_data ),
	.die_b_pl_valid(die_b_pl_valid[0]),
	.die_b_lp_exit_cg_ack(die_b_lp_exit_cg_ack),
	.die_b_lp_irdy(die_b_lp_irdy),
	.die_b_lp_valid(die_b_lp_valid[0]),
	.die_b_lp_data(die_b_lp_data),
	
	.die_b_crc_data(w_die_b_crc_data),
	.die_b_crc_data_valid(w_die_b_crc_data_valid),
	.mem_addr(w_mem_wr_rd_addr),
	.mem_data(w_mem_wr_data),
	.mem_wr(w_mem_wr_en),
	.mem_rd(),

	.mem_rdata(w_mem_rd_data),
	.die_b_lp_state_req(die_b_lp_state_req)

);


host_lpif_intf host_lpif(

.clk(clk_die_a),
.reset_n(reset_die_a),
.die_a_tx_online(w_m0_tx_online),
.die_a_rx_online(w_m0_rx_online),
.die_a_align_done (master_align_done),
.die_a_align_error(master_align_err),

.die_a_pl_exit_cg_req(die_a_pl_exit_cg_req),
.die_a_pl_trdy(die_a_pl_trdy),
.die_a_pl_valid(die_a_pl_valid),
.die_a_pl_data(die_a_pl_data),
.die_a_pl_crc(die_a_pl_crc),
.die_a_pl_crc_valid(die_a_pl_crc_valid),
.write_done(),
.read_done (),
.test_complete(w_test_complete),
.die_a_rwd_valid(die_a_rwd_valid),
.die_a_rwd_data	(die_a_rwd_data	),
.die_a_drs_data	(die_a_drs_data	),
.die_a_drs_valid(die_a_drs_valid),

.die_a_lp_exit_cg_ack(die_a_lp_exit_cg_ack),
.die_a_lp_irdy(die_a_lp_irdy),
.die_a_lp_valid(die_a_lp_valid[0]),
.die_a_lp_data(die_a_lp_data),

.die_a_lp_crc_data (w_die_a_lp_crc_data ),
.die_a_lp_crc_valid(w_die_a_lp_crc_valid),

.die_a_lp_state_req(die_a_lp_state_req),
.test_done(test_done),

.flit_wr_en(flit_wr_en)

);


syncfifo_mem1r1w
   ram_mem(/*AUTOARG*/
   //Outputs
   .rddata(w_mem_rd_data),
   //Inputs
   .clk_write(clk_die_b), 
   .clk_read(clk_die_b), 
   .rst_write_n(reset_die_b), 
   .rst_read_n(reset_die_b), 
   .rdaddr(w_mem_wr_rd_addr[7:0]), 
   .wraddr(w_mem_wr_rd_addr[7:0]), 
   .wrdata(w_mem_wr_data), 
   .wrstrobe(w_mem_wr_en)
   );
   
   defparam ram_mem.FIFO_WIDTH_WID = 512;
   defparam ram_mem.FIFO_DEPTH_WID = 256;
   
lpif_csr_intf lpif_csr(
	.clk(clk_die_a),	
	.rst_n(reset_die_a),
	
	.master_address  (master_address  ),       // width = 32,       master.address
    .master_readdata (master_readdata ),      // width = 32,             .readdata
    .master_read	 (master_read	 ),          //  width = 1,             .read
    .master_write	 (master_write	 ),         //  width = 1,             .write
    .master_writedata(master_writedata),     // width = 32,             .writedata
    .master_waitrequest(master_waitrequest),   //  width = 1,             .waitrequest
    .master_readdatavalid(master_readdatavalid), //  width = 1,             .readdatavalid
    .master_byteenable(master_byteenable),    //  width = 4,             .byteenable
	
	.chkr_pass(test_done),
	.test_complete(w_test_complete),
	.align_error(master_align_err & slave_align_err),
	.align_done(master_align_done & slave_align_done),
	.die_a_tx_online(w_m0_tx_online),
	.die_a_rx_online(w_m0_rx_online),
	.die_b_tx_online(w_s0_tx_online),
	.die_b_rx_online(w_s0_rx_online),
	.o_delay_x_value(w_delay_x_value),
	.o_delay_y_value(w_delay_y_value),
	.o_delay_z_value(w_delay_z_value),
	
	.flit_wr_en(flit_wr_en)

	
	);
   
endmodule
