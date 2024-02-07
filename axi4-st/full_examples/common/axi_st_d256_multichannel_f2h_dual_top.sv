// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: AXIST Dual Leader-FOllower top module
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module axi_st_d256_multichannel_f2h_dual_top #(parameter LEADER_MODE = 1, parameter FOLLOWER_MODE = 1, parameter SYNC_FIFO = 0)(

	input                     	m_wr_clk_in,
	input                     	s_wr_clk_in,	
	input [6:0]			lane_clk_a,
	input [6:0]			lane_clk_b,
	input                     	axist_rstn_in,	
	input                     	por_in,	
	input                     	m_gen2_mode,	
	input				w_m_wr_rst_n,
	input				w_s_wr_rst_n,
	input				rst_phy_n,
	input				clk_phy,
	input				clk_p_div2,
	input				clk_p_div4,
	
	input [31:0]			i_delay_x_value,
	input [31:0]			i_delay_y_value,
	input [31:0]			i_delay_z_value,
	input 				usermode_en,
	
	input  logic [ 255:   0]   	user_m2s_m_tdata      ,
	output logic               	user_m2s_m_tready     ,
	input  logic               	user_m2s_m_tvalid     ,
		
	output logic [ 511:   0]   	user_m2s_s_tdata      ,
	input  logic               	user_m2s_s_tready     ,
	output logic               	user_m2s_s_tvalid     ,
	output logic [   1:   0]   	user_m2s_s_enable     ,
	
  // ST_S2M channel	
	output logic [ 255:   0]   	user_s2m_m_tdata      ,
	input  logic               	user_s2m_m_tready     ,
	output logic               	user_s2m_m_tvalid     ,
	output logic [   0:   0]   	user_s2m_m_enable     ,


  // ST_S2M channel
	input  logic [ 511:   0]   	user_s2m_s_tdata      ,
	output logic               	user_s2m_s_tready     ,
	input  logic               	user_s2m_s_tvalid     ,

  // Debug Status Outputs
		
	output 				o_master_align_err,
	output 				o_slave_align_err,
	output 			  	o_master_sl_tx_transfer_en,
	output 			  	o_master_ms_tx_transfer_en,
	output 			  	o_slave_sl_tx_transfer_en,
	output 			  	o_slave_ms_tx_transfer_en,
	output 			  	o_slave_align_done,
	output 			  	o_master_align_done,
	output 			  	o_w_m_wr_rst_n,
	output 			  	o_s_wr_rst_n,

	input [6:0]			master_sl_tx_transfer_en,// From p2p_lite_i0 of p2p_lite.v, ...
	input [6:0]			master_ms_tx_transfer_en,// From p2p_lite_i0 of p2p_lite.v, ...
	input [6:0]			slave_ms_tx_transfer_en,// From p2p_lite_i0 of p2p_lite.v, ...
    	input [6:0]			slave_sl_tx_transfer_en,// From p2p_lite_i0 of p2p_lite.v, ...
	
	output [319:0]         		master_ca2phy_0,
	output [319:0]         		master_ca2phy_1,
	output [319:0]         		master_ca2phy_2,
	output [319:0]         		master_ca2phy_3,
	output [319:0]         		master_ca2phy_4,
	output [319:0]         		master_ca2phy_5,
	output [319:0]         		master_ca2phy_6,
	
	input [319:0]			master_phy2ca_0,	// From p2p_lite_i0 of p2p_lite.v
	input [319:0]			master_phy2ca_1,	// From p2p_lite_i1 of p2p_lite.v
	input [319:0]			master_phy2ca_2,	// From p2p_lite_i2 of p2p_lite.v
	input [319:0]			master_phy2ca_3,	// From p2p_lite_i3 of p2p_lite.v
	input [319:0]			master_phy2ca_4,	// From p2p_lite_i4 of p2p_lite.v
	input [319:0]			master_phy2ca_5,	// From p2p_lite_i5 of p2p_lite.v
	input [319:0]			master_phy2ca_6,	// From p2p_lite_i6 of p2p_lite.v
	
	output [319:0]         		slave_ca2phy_0,
	output [319:0]         		slave_ca2phy_1,
	output [319:0]         		slave_ca2phy_2,
	output [319:0]         		slave_ca2phy_3,
	output [319:0]         		slave_ca2phy_4,
	output [319:0]         		slave_ca2phy_5,
	output [319:0]         		slave_ca2phy_6,
	
	input [319:0]			slave_phy2ca_0,		// From p2p_lite_i0 of p2p_lite.v
	input [319:0]			slave_phy2ca_1,		// From p2p_lite_i1 of p2p_lite.v
	input [319:0]			slave_phy2ca_2,		// From p2p_lite_i2 of p2p_lite.v
	input [319:0]			slave_phy2ca_3,		// From p2p_lite_i3 of p2p_lite.v
	input [319:0]			slave_phy2ca_4,		// From p2p_lite_i4 of p2p_lite.v
	input [319:0]			slave_phy2ca_5,		// From p2p_lite_i5 of p2p_lite.v
	input [319:0]			slave_phy2ca_6	// From p2p_lite_i6 of p2p_lite.v

);

`define DATA_DEBUG 1            // If 1, data is less random, more incrementing patterns.
`define CA_TX_STB_INTV	    16'd24
`define CA_RX_STB_INTV	    16'd24
`define TX_INIT_CREDIT      8'd128


	parameter FULL          = 4'h1;
	parameter HALF          = 4'h2;
	parameter QUARTER       = 4'h4;

// Note, we use 1,2,4 to encode Full, Half, Quarter rate, respecitvely.
// Also we standardized on 4 bit wide for ... reasons.

	parameter MASTER_RATE 	= FULL;
	parameter SLAVE_RATE  	= HALF;

// This needs to stay in sync with the confguration. The marker should be within a 80 bit per chunk
	parameter CHAN_M2S_MARKER_LOC = 8'd39;
	parameter CHAN_S2M_MARKER_LOC = 8'd39;

	reg [15:0] 			m_delay_x_value_reg1;
	reg [15:0] 			m_delay_x_value_reg2;
	reg [15:0] 			m_delay_y_value_reg1;
	reg [15:0] 			m_delay_y_value_reg2;
	reg [15:0] 			m_delay_z_value_reg1;
	reg [15:0] 			m_delay_z_value_reg2;
				
	reg [15:0] 			s_delay_x_value_reg1;
	reg [15:0] 			s_delay_x_value_reg2;
	reg [15:0] 			s_delay_y_value_reg1;
	reg [15:0] 			s_delay_y_value_reg2;
	reg [15:0] 			s_delay_z_value_reg1;
	reg [15:0] 			s_delay_z_value_reg2;
	
	
	wire [15:0]			MASTER_DELAY_X_VALUE;
	wire [15:0]			MASTER_DELAY_Y_VALUE;
	wire [15:0]			MASTER_DELAY_Z_VALUE;
	
	wire [15:0]			SLAVE_DELAY_X_VALUE;
	wire [15:0]			SLAVE_DELAY_Y_VALUE;
	wire [15:0]			SLAVE_DELAY_Z_VALUE;


// localparam GENERIC_DELAY_X_VALUE = 16'd12 ;  // Word Alignment Time
// localparam GENERIC_DELAY_Y_VALUE = 16'd32 ;  // CA Alignment Time
// localparam GENERIC_DELAY_Z_VALUE = 16'd8000 ;  // AIB Alignment Time

// localparam MASTER_DELAY_X_VALUE = GENERIC_DELAY_X_VALUE / MASTER_RATE;
// localparam MASTER_DELAY_Y_VALUE = GENERIC_DELAY_Y_VALUE / MASTER_RATE;
// localparam MASTER_DELAY_Z_VALUE = GENERIC_DELAY_Z_VALUE / MASTER_RATE;

// localparam SLAVE_DELAY_X_VALUE = GENERIC_DELAY_X_VALUE / SLAVE_RATE;
// localparam SLAVE_DELAY_Y_VALUE = GENERIC_DELAY_Y_VALUE / SLAVE_RATE;
// localparam SLAVE_DELAY_Z_VALUE = GENERIC_DELAY_Z_VALUE / SLAVE_RATE;



	logic           m_wr_clk;
	logic           s_wr_clk;
	logic           m_wr_rst_n;
	logic           s_wr_rst_n;
	
	wire  		slave_align_err;
	logic		master_align_err;
	
	assign m_wr_rst_n 			= ~por_in & w_m_wr_rst_n & axist_rstn_in;
	assign s_wr_rst_n 			= ~por_in & w_s_wr_rst_n & axist_rstn_in;
	assign o_slave_align_err		= slave_align_err;
	assign o_master_align_err		= master_align_err;
	assign o_master_sl_tx_transfer_en 	= &(master_sl_tx_transfer_en[6:0]);
	assign o_master_ms_tx_transfer_en 	= &(master_ms_tx_transfer_en[6:0]);
	assign o_slave_sl_tx_transfer_en 	= &(slave_sl_tx_transfer_en[6:0]); 
	assign o_slave_ms_tx_transfer_en 	= &(slave_ms_tx_transfer_en[6:0]); 
	 
	
	assign o_w_m_wr_rst_n			= m_wr_rst_n;
	assign o_s_wr_rst_n			= s_wr_rst_n;


   //-----------------------
   //-- WIRE DECLARATIONS --
   //-----------------------
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   logic		master_align_done;	// From ca_master_i of ca.v
   logic [39:0]		master_ca2ll_0;		// From ca_master_i of ca.v
   logic [39:0]		master_ca2ll_1;		// From ca_master_i of ca.v
   logic [39:0]		master_ca2ll_2;		// From ca_master_i of ca.v
   logic [39:0]		master_ca2ll_3;		// From ca_master_i of ca.v
   logic [39:0]		master_ca2ll_4;		// From ca_master_i of ca.v
   logic [39:0]		master_ca2ll_5;		// From ca_master_i of ca.v
   logic [39:0]		master_ca2ll_6;		// From ca_master_i of ca.v
   logic [39:0]		master_ll2ca_0;		// From axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic [39:0]		master_ll2ca_1;		// From axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic [39:0]		master_ll2ca_2;		// From axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic [39:0]		master_ll2ca_3;		// From axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic [39:0]		master_ll2ca_4;		// From axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic [39:0]		master_ll2ca_5;		// From axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic [39:0]		master_ll2ca_6;		// From axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic		master_rx_stb_pos_coding_err;// From ca_master_i of ca.v
   logic		master_rx_stb_pos_err;	// From ca_master_i of ca.v
   logic		master_tx_stb_pos_coding_err;// From ca_master_i of ca.v
   logic		master_tx_stb_pos_err;	// From ca_master_i of ca.v
   logic		slave_align_done;	// From ca_slave_i of ca.v
   logic [79:0]		slave_ca2ll_0;		// From ca_slave_i of ca.v
   logic [79:0]		slave_ca2ll_1;		// From ca_slave_i of ca.v
   logic [79:0]		slave_ca2ll_2;		// From ca_slave_i of ca.v
   logic [79:0]		slave_ca2ll_3;		// From ca_slave_i of ca.v
   logic [79:0]		slave_ca2ll_4;		// From ca_slave_i of ca.v
   logic [79:0]		slave_ca2ll_5;		// From ca_slave_i of ca.v
   logic [79:0]		slave_ca2ll_6;		// From ca_slave_i of ca.v
   logic [79:0]		slave_ll2ca_0;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic [79:0]		slave_ll2ca_1;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic [79:0]		slave_ll2ca_2;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic [79:0]		slave_ll2ca_3;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic [79:0]		slave_ll2ca_4;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic [79:0]		slave_ll2ca_5;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic [79:0]		slave_ll2ca_6;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic		slave_rx_stb_pos_coding_err;// From ca_slave_i of ca.v
   logic		slave_rx_stb_pos_err;	// From ca_slave_i of ca.v
   logic		slave_tx_stb_pos_coding_err;// From ca_slave_i of ca.v
   logic		slave_tx_stb_pos_err;	// From ca_slave_i of ca.v
   logic [3:0]		tx_mrk_userbit_master;	// From marker_gen_im of marker_gen.v
   logic [3:0]		tx_mrk_userbit_slave;	// From marker_gen_is of marker_gen.v
   // End of automatics

   //-----------------------
   //-- REG DECLARATIONS --
   //-----------------------
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   logic		tx_stb_userbit_master;	// To axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic		tx_stb_userbit_slave;	// To axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   
   // End of automatics

   logic [39:0]     	w_master_ca2phy_0;
   logic [39:0]     	w_master_ca2phy_1;
   logic [39:0]     	w_master_ca2phy_2;
   logic [39:0]     	w_master_ca2phy_3;
   logic [39:0]     	w_master_ca2phy_4;
   logic [39:0]     	w_master_ca2phy_5;
   logic [39:0]     	w_master_ca2phy_6;
   
   
always@(posedge m_wr_clk)
	if(!m_wr_rst_n)
	begin
		m_delay_x_value_reg1	<= 'b0;
		m_delay_x_value_reg2	<= 'b0;
		m_delay_y_value_reg1	<= 'b0;
		m_delay_y_value_reg2	<= 'b0;
		m_delay_z_value_reg1	<= 'b0;
		m_delay_z_value_reg2	<= 'b0;
	end
	else
	begin
		m_delay_x_value_reg1	<= i_delay_x_value;
	    	m_delay_x_value_reg2    <= m_delay_x_value_reg1;
		
		m_delay_y_value_reg1	<= i_delay_y_value;
	    	m_delay_y_value_reg2    <= m_delay_y_value_reg1;
		
		m_delay_z_value_reg1	<= i_delay_z_value;
	    	m_delay_z_value_reg2    <= m_delay_z_value_reg1;
		
	end

always@(posedge s_wr_clk)
	if(!s_wr_rst_n)
	begin
		s_delay_x_value_reg1	<= 'b0;
		s_delay_x_value_reg2	<= 'b0;
		s_delay_y_value_reg1	<= 'b0;
		s_delay_y_value_reg2	<= 'b0;
		s_delay_z_value_reg1	<= 'b0;
		s_delay_z_value_reg2	<= 'b0;
	end
	else
	begin
		s_delay_x_value_reg1	<= i_delay_x_value;
	    s_delay_x_value_reg2    <= s_delay_x_value_reg1;
		
		s_delay_y_value_reg1	<= i_delay_y_value;
	    s_delay_y_value_reg2    <= s_delay_y_value_reg1;
		
		s_delay_z_value_reg1	<= i_delay_z_value;
	    s_delay_z_value_reg2    <= s_delay_z_value_reg1;
		
	end

	assign MASTER_DELAY_X_VALUE = m_delay_x_value_reg2 / MASTER_RATE;
	assign MASTER_DELAY_Y_VALUE = m_delay_y_value_reg2 / MASTER_RATE;
	assign MASTER_DELAY_Z_VALUE = m_delay_z_value_reg2 / MASTER_RATE;
	
	assign SLAVE_DELAY_X_VALUE = s_delay_x_value_reg2 / SLAVE_RATE;
	assign SLAVE_DELAY_Y_VALUE = s_delay_y_value_reg2 / SLAVE_RATE;
	assign SLAVE_DELAY_Z_VALUE = s_delay_z_value_reg2 / SLAVE_RATE;

   
   	assign master_ca2phy_0  = {280'd0,w_master_ca2phy_0};
   	assign master_ca2phy_1  = {280'd0,w_master_ca2phy_1};
   	assign master_ca2phy_2  = {280'd0,w_master_ca2phy_2};
   	assign master_ca2phy_3  = {280'd0,w_master_ca2phy_3};
   	assign master_ca2phy_4  = {280'd0,w_master_ca2phy_4};
   	assign master_ca2phy_5  = {280'd0,w_master_ca2phy_5};
   	assign master_ca2phy_6  = {280'd0,w_master_ca2phy_6};
   	
   	assign slave_ca2phy_0[319:80]	= 'b0 ;
   	assign slave_ca2phy_1[319:80]	= 'b0 ;
   	assign slave_ca2phy_2[319:80]	= 'b0 ;
   	assign slave_ca2phy_3[319:80]	= 'b0 ;
   	assign slave_ca2phy_4[319:80]	= 'b0 ;
   	assign slave_ca2phy_5[319:80]	= 'b0 ;
   	assign slave_ca2phy_6[319:80]	= 'b0 ;

	logic [15:0] 	strobe_gen_m_interval;
	logic [15:0] 	strobe_gen_s_interval;

	logic [6:0] 	m2s_master_ca2phy_strobe;
	logic [6:0] 	m2s_slave_phy2ca_strobe;
		
	logic [6:0] 	s2m_slave_ca2phy_strobe;
	logic [6:0] 	s2m_master_phy2ca_strobe;
		
	logic [6:0] 	master_ca2phy_marker;
	logic [6:0] 	slave_ca2phy_marker;
		
	logic       	m2s_master_ca2phy_pushbit;
	logic [1:0] 	m2s_slave_phy2ca_pushbit;
		
	logic [1:0] 	s2m_slave_ca2phy_credit;
	logic       	s2m_master_phy2ca_credit;


   // TX M2S
   assign m2s_master_ca2phy_strobe = {master_ca2phy_6[1],
                                      master_ca2phy_5[1],
                                      master_ca2phy_4[1],
                                      master_ca2phy_3[1],
                                      master_ca2phy_2[1],
                                      master_ca2phy_1[1],
                                      master_ca2phy_0[1]};

   // RX M2S
   assign m2s_slave_phy2ca_strobe = {slave_phy2ca_6[1],
                                     slave_phy2ca_5[1],
                                     slave_phy2ca_4[1],
                                     slave_phy2ca_3[1],
                                     slave_phy2ca_2[1],
                                     slave_phy2ca_1[1],
                                     slave_phy2ca_0[1]};

   // TX S2M
   assign s2m_slave_ca2phy_strobe = {slave_ca2phy_6[1],
                                     slave_ca2phy_5[1],
                                     slave_ca2phy_4[1],
                                     slave_ca2phy_3[1],
                                     slave_ca2phy_2[1],
                                     slave_ca2phy_1[1],
                                     slave_ca2phy_0[1]};

   // RX S2M
   assign s2m_master_phy2ca_strobe = {master_phy2ca_6[1],
                                      master_phy2ca_5[1],
                                      master_phy2ca_4[1],
                                      master_phy2ca_3[1],
                                      master_phy2ca_2[1],
                                      master_phy2ca_1[1],
                                      master_phy2ca_0[1]};

   // TX M2S
   assign master_ca2phy_marker = {master_ca2phy_6[39],
                                  master_ca2phy_5[39],
                                  master_ca2phy_4[39],
                                  master_ca2phy_3[39],
                                  master_ca2phy_2[39],
                                  master_ca2phy_1[39],
                                  master_ca2phy_0[39]};

   // TX S2M
   assign slave_ca2phy_marker = {slave_ca2phy_6[39],
                                 slave_ca2phy_5[39],
                                 slave_ca2phy_4[39],
                                 slave_ca2phy_3[39],
                                 slave_ca2phy_2[39],
                                 slave_ca2phy_1[39],
                                 slave_ca2phy_0[39]};

   assign m2s_master_ca2phy_pushbit 	= {master_ca2phy_0[0]};

   assign m2s_slave_phy2ca_pushbit	= {slave_phy2ca_0[0+40],slave_phy2ca_0[0]};

   assign s2m_slave_ca2phy_credit   	= {slave_ca2phy_0[0+40],slave_ca2phy_0[0]};

   assign s2m_master_phy2ca_credit  	= {master_phy2ca_0[0]};

   assign strobe_gen_m_interval    	= (`CA_TX_STB_INTV * SLAVE_RATE)/MASTER_RATE;
									   
   assign strobe_gen_s_interval		= (`CA_RX_STB_INTV * MASTER_RATE)/SLAVE_RATE;
	
   assign o_slave_align_done  		= slave_align_done; 
   assign o_master_align_done 		= master_align_done; 

    /* marker_gen AUTO_TEMPLATE ".*_i\(.+\)" (
      .user_marker			(tx_mrk_userbit_master[]),
      .clk				(@_wr_clk),
      .rst_n				(@_wr_rst_n),
      .local_rate			(MASTER_RATE),
      .remote_rate			(SLAVE_RATE),
    );
    */

   marker_gen marker_gen_im
     (/*AUTOINST*/
      // Outputs
      .user_marker			(tx_mrk_userbit_master[3:0]), // Templated
      // Inputs
      .clk					(m_wr_clk),		 // Templated
      .rst_n				(m_wr_rst_n),		 // Templated
      .local_rate			(MASTER_RATE),		 // Templated
      .remote_rate			(SLAVE_RATE));		 // Templated


   /* marker_gen AUTO_TEMPLATE ".*_i\(.+\)" (
      .user_marker			(tx_mrk_userbit_slave[]),
      .clk				(@_wr_clk),
      .rst_n				(@_wr_rst_n),
      .local_rate			(SLAVE_RATE),
      .remote_rate			(MASTER_RATE),
    );
    */

   marker_gen marker_gen_is
     (/*AUTOINST*/
      // Outputs
      .user_marker			(tx_mrk_userbit_slave[3:0]), // Templated
      // Inputs
      .clk					(s_wr_clk),		 // Templated
      .rst_n				(s_wr_rst_n),		 // Templated
      .local_rate			(SLAVE_RATE),		 // Templated
      .remote_rate			(MASTER_RATE));		 // Templated


	strobe_gen strobe_gen_im(

  .clk(m_wr_clk),
  .rst_n(m_wr_rst_n),
  
  .interval(strobe_gen_m_interval),          // Set to 0 for back to back strobes. Otherwise, interval is the time between strobes (so if you want a strobe every 10 cycles, set to 9)
  .user_marker(|tx_mrk_userbit_master),       // Effectiely the OR reduction of all user_marker bits. We only increment strobe count when we send a remote side word
  .online(1'b1),            // Set to 1 to begin strobe generation (0 to stop)
  
  .user_strobe(tx_stb_userbit_master)

);
	
	strobe_gen strobe_gen_is(

  .clk(s_wr_clk),
  .rst_n(s_wr_rst_n),
  
  .interval(strobe_gen_s_interval),          // Set to 0 for back to back strobes. Otherwise, interval is the time between strobes (so if you want a strobe every 10 cycles, set to 9)
  .user_marker(|tx_mrk_userbit_slave),       // Effectiely the OR reduction of all user_marker bits. We only increment strobe count when we send a remote side word
  .online(1'b1),            // Set to 1 to begin strobe generation (0 to stop)
  
  .user_strobe(tx_stb_userbit_slave)

);
				  
	assign m_wr_clk = m_wr_clk_in;
	assign s_wr_clk = s_wr_clk_in;


   /* axi_st_d256_multichannel_full_master_top AUTO_TEMPLATE (
      .user_\(.*\)			(user1_\1[]),

      .tx_stb_userbit     		(1'b1),
      .tx_mrk_userbit			(tx_mrk_userbit_master[]),
      .tx_stb_userbit			(tx_stb_userbit_master[]),

      .init_st_credit			(8'h0),

      .rx_online			(master_align_done),
      .tx_online			(&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}),

      .delay_x_value                    (MASTER_DELAY_X_VALUE),
      .delay_y_value                    (MASTER_DELAY_Y_VALUE),
      .delay_z_value                    (MASTER_DELAY_Z_VALUE),

      .tx_phy\(.\)                      (master_ll2ca_\1[]),
      .rx_phy\(.\)		        (master_ca2ll_\1[]),

      .clk_wr				(m_wr_clk),
      .rst_wr_n				(m_wr_rst_n),
    );
    */
   axi_st_d256_dual_multichannel_full_master_top axi_st_master_top_i
     (/*AUTOINST*/
      // Outputs
	.tx_phy0(master_ll2ca_0[39:0]),	 // Templated
	.tx_phy1(master_ll2ca_1[39:0]),	 // Templated
     	.tx_phy2(master_ll2ca_2[39:0]),	 // Templated
     	.tx_phy3(master_ll2ca_3[39:0]),	 // Templated
     	.tx_phy4(master_ll2ca_4[39:0]),	 // Templated
	.tx_phy5(master_ll2ca_5[39:0]),	 // Templated
	.tx_phy6(master_ll2ca_6[39:0]),	 // Templated
	.user_m2s_tdata(user_m2s_m_tdata),   
	.user_m2s_tready(user_m2s_m_tready),  
	.user_m2s_tvalid(user_m2s_m_tvalid),  
	    
	  .user_s2m_tdata(user_s2m_m_tdata),   
	  .user_s2m_tready(user_s2m_m_tready),  
	  .user_s2m_tvalid(user_s2m_m_tvalid),  
	  .user_s2m_enable(user_s2m_m_enable),  
	  .tx_ST_M2S_debug_status(),
	  .rx_ST_S2M_debug_status(),
	  
      // Inputs
      .clk_wr				(m_wr_clk),		 // Templated
      .rst_wr_n				(m_wr_rst_n),		 // Templated
      .tx_online			(&{master_sl_tx_transfer_en[6:0],master_ms_tx_transfer_en[6:0]}), // Templated
      .rx_online			(master_align_done),	 // Templated
      .init_ST_M2S_credit		(8'h0),			 // Templated
      .rx_phy0				(master_ca2ll_0[39:0]),	 // Templated	
      .rx_phy1				(master_ca2ll_1[39:0]),	 // Templated   
      .rx_phy2				(master_ca2ll_2[39:0]),	 // Templated   
      .rx_phy3				(master_ca2ll_3[39:0]),	 // Templated   
      .rx_phy4				(master_ca2ll_4[39:0]),	 // Templated   
      .rx_phy5				(master_ca2ll_5[39:0]),	 // Templated   
      .rx_phy6				(master_ca2ll_6[39:0]),	 // Templated   
      .m_gen2_mode			(m_gen2_mode),
      .tx_mrk_userbit			(tx_mrk_userbit_master[0:0]), // Templated
      .tx_stb_userbit			(tx_stb_userbit_master), // Templated
      .delay_x_value        		(MASTER_DELAY_X_VALUE),
      .delay_y_value        		(MASTER_DELAY_Y_VALUE),
      .delay_z_value        		(MASTER_DELAY_Z_VALUE));

   /* axi_st_d256_multichannel_half_slave_top AUTO_TEMPLATE (
      .user_\(.*\)			(user2_\1[]),

      .tx_mrk_userbit			(tx_mrk_userbit_slave[]),
      .tx_stb_userbit			(tx_stb_userbit_slave[]),

      .rx_online			(slave_align_done),
      .tx_online			(&{slave_sl_tx_transfer_en,slave_ms_tx_transfer_en}),

      .delay_x_value                    (SLAVE_DELAY_X_VALUE),
      .delay_y_value                    (SLAVE_DELAY_Y_VALUE),
      .delay_z_value                    (SLAVE_DELAY_Z_VALUE),

      .tx_phy\(.\)                      (slave_ll2ca_\1[]),
      .rx_phy\(.\)			(slave_ca2ll_\1[]),

      .clk_wr				(s_wr_clk),
      .rst_wr_n				(s_wr_rst_n),
    );
    */
   axi_st_d256_dual_multichannel_half_slave_top axi_st_slave_top_i
    (/*AUTOINST*/
     // Outputs
	.tx_phy0			(slave_ll2ca_0[79:0]),	 // Templated
     	.tx_phy1			(slave_ll2ca_1[79:0]),	 // Templated
     	.tx_phy2			(slave_ll2ca_2[79:0]),	 // Templated
     	.tx_phy3			(slave_ll2ca_3[79:0]),	 // Templated
     	.tx_phy4			(slave_ll2ca_4[79:0]),	 // Templated
     	.tx_phy5			(slave_ll2ca_5[79:0]),	 // Templated
     	.tx_phy6			(slave_ll2ca_6[79:0]),	 // Templated
     	.user_m2s_tdata        		(user_m2s_s_tdata ),
	.user_m2s_tready       		(user_m2s_s_tready),
	.user_m2s_tvalid       		(user_m2s_s_tvalid),
	.user_m2s_enable       		(user_m2s_s_enable),
	.rx_ST_M2S_debug_status		(),
	.tx_ST_S2M_debug_status		(),
	.init_ST_S2M_credit		(8'h00),
	 
	.user_s2m_tdata        		(user_s2m_s_tdata ),
	.user_s2m_tready       		(user_s2m_s_tready),
	.user_s2m_tvalid       		(user_s2m_s_tvalid),
	 
     // Inputs
     	.clk_wr				(s_wr_clk),		 // Templated
     	.rst_wr_n			(s_wr_rst_n & usermode_en),		 // Templated
     	.tx_online			(&{slave_sl_tx_transfer_en[6:0],slave_ms_tx_transfer_en[6:0]}), // Templated
     	.rx_online			(slave_align_done),	 // Templated
     	.rx_phy0			(slave_ca2ll_0[79:0]),	 // Templated
     	.rx_phy1			(slave_ca2ll_1[79:0]),	 // Templated
     	.rx_phy2			(slave_ca2ll_2[79:0]),	 // Templated
     	.rx_phy3			(slave_ca2ll_3[79:0]),	 // Templated
     	.rx_phy4			(slave_ca2ll_4[79:0]),	 // Templated
     	.rx_phy5			(slave_ca2ll_5[79:0]),	 // Templated
     	.rx_phy6			(slave_ca2ll_6[79:0]),	 // Templated
     	.m_gen2_mode			(m_gen2_mode),
     	.tx_mrk_userbit			(tx_mrk_userbit_slave[1:0]), // Templated
     	.tx_stb_userbit			(tx_stb_userbit_slave),	 // Templated
     	.delay_x_value         		(SLAVE_DELAY_X_VALUE),
     	.delay_y_value         		(SLAVE_DELAY_Y_VALUE),
     	.delay_z_value         		(SLAVE_DELAY_Z_VALUE));


   /* ca AUTO_TEMPLATE (
      .lane_clk				({7{m_wr_clk}}),
      .com_clk				(m_wr_clk),
      .rst_n				(m_wr_rst_n),

      .align_done			(master_align_done),
      .align_err			(master_align_err),
      .tx_stb_pos_err			(master_tx_stb_pos_err),
      .tx_stb_pos_coding_err		(master_tx_stb_pos_coding_err),
      .rx_stb_pos_err			(master_rx_stb_pos_err),
      .rx_stb_pos_coding_err		(master_rx_stb_pos_coding_err),

      .tx_online			(&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}),
      .rx_online			(&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}),

      .tx_stb_en			(1'b0),   // No CA Strobe in Asymmetric
      .tx_stb_rcvr			(1'b1),                 // recover strobes
      .align_fly			('0),                   // Only look for strobe once
      .rden_dly				('0),                   // No delay before outputting data
      .delay_x_value                    (MASTER_DELAY_X_VALUE),
      .delay_z_value                    (MASTER_DELAY_Z_VALUE),
      .tx_stb_wd_sel                    (8'h01),                 // Strobe is at LOC [1]
      .tx_stb_bit_sel                   (40'h0000000002),
      .tx_stb_intv                      (16'd20),                 // Strobe repeats every 20 cycles
      .rx_stb_wd_sel			(8'h01),                 // Strobe is at LOC [1]
      .rx_stb_bit_sel			(40'h0000000002),
      .rx_stb_intv			(16'd20),                 // Strobe repeats every 20 cycles

      .tx_din				 ({master_ll2ca_6[39:0]  , master_ll2ca_5[39:0]  , master_ll2ca_4[39:0]  , master_ll2ca_3[39:0]  , master_ll2ca_2[39:0]  , master_ll2ca_1[39:0]  , master_ll2ca_0[39:0]})  ,
      .rx_din				 ({master_phy2ca_6[39:0] , master_phy2ca_5[39:0] , master_phy2ca_4[39:0] , master_phy2ca_3[39:0] , master_phy2ca_2[39:0] , master_phy2ca_1[39:0] , master_phy2ca_0[39:0]})  ,
      .tx_dout				 ({master_ca2phy_6[39:0] , master_ca2phy_5[39:0] , master_ca2phy_4[39:0] , master_ca2phy_3[39:0] , master_ca2phy_2[39:0] , master_ca2phy_1[39:0] , master_ca2phy_0[39:0]}) ,
      .rx_dout				 ({master_ca2ll_6[39:0]  , master_ca2ll_5[39:0]  , master_ca2ll_4[39:0]  , master_ca2ll_3[39:0]  , master_ca2ll_2[39:0]  , master_ca2ll_1[39:0]  , master_ca2ll_0[39:0]})  ,

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
   ca #(.NUM_CHANNELS      (7),           // 2 Channels
        .BITS_PER_CHANNEL  (40),          // Half Rate Gen1 is 80 bits
        .AD_WIDTH          (4),           // Allows 16 deep FIFO
        .SYNC_FIFO         (SYNC_FIFO))        // Synchronous FIFO
   ca_master_i
     (/*AUTOINST*/
      // Outputs
      .tx_dout				({w_master_ca2phy_6[39:0] , w_master_ca2phy_5[39:0] , w_master_ca2phy_4[39:0] , w_master_ca2phy_3[39:0] , w_master_ca2phy_2[39:0] , w_master_ca2phy_1[39:0] , w_master_ca2phy_0[39:0]}), // Templated
      .rx_dout				({master_ca2ll_6[39:0]  , master_ca2ll_5[39:0]  , master_ca2ll_4[39:0]  , master_ca2ll_3[39:0]  , master_ca2ll_2[39:0]  , master_ca2ll_1[39:0]  , master_ca2ll_0[39:0]}), // Templated
      .align_done			(master_align_done),	 // Templated
      .align_err			(master_align_err),	 // Templated
      .tx_stb_pos_err			(master_tx_stb_pos_err), // Templated
      .tx_stb_pos_coding_err		(master_tx_stb_pos_coding_err), // Templated
      .rx_stb_pos_err			(master_rx_stb_pos_err), // Templated
      .rx_stb_pos_coding_err		(master_rx_stb_pos_coding_err), // Templated
      .fifo_full			(),			 // Templated
      .fifo_pfull			(),			 // Templated
      .fifo_empty			(),			 // Templated
      .fifo_pempty			(),			 // Templated
      // Inputs
      .lane_clk				(lane_clk_a),	 // Templated
      .com_clk				(m_wr_clk),		 // Templated
      .rst_n				(m_wr_rst_n),		 // Templated
      .tx_online			(&{master_sl_tx_transfer_en[6:0],master_ms_tx_transfer_en[6:0]}), // Templated
      .rx_online			(&{master_sl_tx_transfer_en[6:0],master_ms_tx_transfer_en[6:0]}), // Templated
      .tx_stb_en			(1'b0),			 // Templated
      .tx_stb_rcvr			(1'b1),			 // Templated
      .align_fly			(1'b1),			 // Templated
      .rden_dly				(3'd0),			 // Templated
      .delay_x_value        (MASTER_DELAY_X_VALUE),
      .delay_z_value        (MASTER_DELAY_Z_VALUE),
      .tx_stb_wd_sel		(8'h01),		 // Templated
      .tx_stb_bit_sel		(40'h0000000002),	 // Templated
      // .tx_stb_intv			(16'd20),		 // Templated
      .tx_stb_intv			((`CA_TX_STB_INTV*SLAVE_RATE)/MASTER_RATE),		 // Templated
      .rx_stb_wd_sel			(8'h01),		 // Templated
      .rx_stb_bit_sel			(40'h0000000002),	 // Templated
      .rx_stb_intv			(`CA_RX_STB_INTV),		 // Templated
      .tx_din				({master_ll2ca_6[39:0]  , master_ll2ca_5[39:0]  , master_ll2ca_4[39:0]  , master_ll2ca_3[39:0]  , master_ll2ca_2[39:0]  , master_ll2ca_1[39:0]  , master_ll2ca_0[39:0]}), // Templated
      .rx_din				({master_phy2ca_6[39:0] , master_phy2ca_5[39:0] , master_phy2ca_4[39:0] , master_phy2ca_3[39:0] , master_phy2ca_2[39:0] , master_phy2ca_1[39:0] , master_phy2ca_0[39:0]}), // Templated
      .fifo_full_val			(6'd16),		 // Templated
      .fifo_pfull_val			(6'd12),		 // Templated
      .fifo_empty_val			(3'd0),			 // Templated
      .fifo_pempty_val			(3'd4));			 // Templated

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
   ca #(.NUM_CHANNELS      (7),           // 2 Channels
        .BITS_PER_CHANNEL  (80),          // Half Rate Gen1 is 80 bits
        .AD_WIDTH          (4),           // Allows 16 deep FIFO
        .SYNC_FIFO         (SYNC_FIFO))        // Synchronous FIFO
   ca_slave_i
     (/*AUTOINST*/
      // Outputs
      .tx_dout				({slave_ca2phy_6[79:0] , slave_ca2phy_5[79:0] , slave_ca2phy_4[79:0] , slave_ca2phy_3[79:0] , slave_ca2phy_2[79:0] , slave_ca2phy_1[79:0] , slave_ca2phy_0[79:0]}), // Templated
      .rx_dout				({slave_ca2ll_6[79:0]  , slave_ca2ll_5[79:0]  , slave_ca2ll_4[79:0]  , slave_ca2ll_3[79:0]  , slave_ca2ll_2[79:0]  , slave_ca2ll_1[79:0]  , slave_ca2ll_0[79:0]}), // Templated
      .align_done			(slave_align_done),	 // Templated
      .align_err			(slave_align_err),	 // Templated
      .tx_stb_pos_err		(slave_tx_stb_pos_err),	 // Templated
      .tx_stb_pos_coding_err(slave_tx_stb_pos_coding_err), // Templated
      .rx_stb_pos_err		(slave_rx_stb_pos_err),	 // Templated
      .rx_stb_pos_coding_err(slave_rx_stb_pos_coding_err), // Templated
      .fifo_full			(),			 // Templated
      .fifo_pfull			(),			 // Templated
      .fifo_empty			(),			 // Templated
      .fifo_pempty			(),			 // Templated
      // Inputs
      .lane_clk				(lane_clk_b),	 // Templated
      .com_clk				(s_wr_clk),		 // Templated
      .rst_n				(s_wr_rst_n & usermode_en),		 // Templated
      .tx_online			(&{slave_sl_tx_transfer_en[6:0],slave_ms_tx_transfer_en[6:0]}), // Templated
      .rx_online			(&{slave_sl_tx_transfer_en[6:0],slave_ms_tx_transfer_en[6:0]}), // Templated
      .tx_stb_en			(1'b0),			 // Templated
      .tx_stb_rcvr			(1'b1),			 // Templated
      .align_fly			(1'b1),			 // Templated
      .rden_dly				(3'd0),			 // Templated
      .delay_x_value        (SLAVE_DELAY_X_VALUE),
      .delay_z_value        (SLAVE_DELAY_Z_VALUE),
      .tx_stb_wd_sel		(8'h01),		 // Templated
      .tx_stb_bit_sel		(40'h0000000002),	 // Templated
      .tx_stb_intv			((`CA_RX_STB_INTV*MASTER_RATE)/SLAVE_RATE),		 // Templated
      .rx_stb_wd_sel		(8'h01),		 // Templated
      .rx_stb_bit_sel		(40'h0000000002),	 // Templated
      .rx_stb_intv			(`CA_TX_STB_INTV),		 // Templated
      .tx_din				({slave_ll2ca_6[79:0]  , slave_ll2ca_5[79:0]  , slave_ll2ca_4[79:0]  , slave_ll2ca_3[79:0]  , slave_ll2ca_2[79:0]  , slave_ll2ca_1[79:0]  , slave_ll2ca_0[79:0]}), // Templated
      .rx_din				({slave_phy2ca_6[79:0] , slave_phy2ca_5[79:0] , slave_phy2ca_4[79:0] , slave_phy2ca_3[79:0] , slave_phy2ca_2[79:0] , slave_phy2ca_1[79:0] , slave_phy2ca_0[79:0]}), // Templated
      .fifo_full_val		(6'd16),		 // Templated
      .fifo_pfull_val		(6'd12),		 // Templated
      .fifo_empty_val		(3'd0),			 // Templated
      .fifo_pempty_val		(3'd4));			 // Templated

	
endmodule
