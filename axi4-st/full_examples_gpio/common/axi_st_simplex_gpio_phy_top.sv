// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: AXIST Simplex Leader-Follower top
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module axi_st_simplex_gpio_phy_top #(parameter AXI_TDATA_FACTOR = 4, parameter LEADER_MODE = 1, parameter FOLLOWER_MODE = 1, parameter PHY_DWIDTH = 1 )
(

	input                     	m_wr_clk_in,
	input                     	s_wr_clk_in,	
	input                     	axist_rstn_in,	
	input                     	por_in,	
	input                     	m_gen2_mode,	
	input				usermode_en,
	input				w_m_wr_rst_n,
	input				w_s_wr_rst_n,
	
	input [(64*AXI_TDATA_FACTOR)-1:0]	m_tx_axist_tdata,
	input 				m_tx_axist_tvalid,
	output 				m_tx_axist_tready,
	
	output [(64*AXI_TDATA_FACTOR)-1:0]	s_rx_axist_tdata,
	output 				s_rx_axist_tvalid,
	input 				s_rx_axist_tready,
	
	output 				o_master_sl_tx_transfer_en,
	output 				o_master_ms_tx_transfer_en,
	output 				o_slave_sl_tx_transfer_en,
	output 				o_slave_ms_tx_transfer_en,
	output 				o_slave_align_done,
	output 				o_master_align_done,
	output 				o_w_m_wr_rst_n,
	output 				o_s_wr_rst_n,
	
	input [31:0]			i_delay_x_value,
	input [31:0]			i_delay_y_value,
	input [31:0]			i_delay_z_value,
	

	input [AXI_TDATA_FACTOR-1:0]	master_sl_tx_transfer_en,
	input [AXI_TDATA_FACTOR-1:0]	master_ms_tx_transfer_en,
	input [AXI_TDATA_FACTOR-1:0]	slave_ms_tx_transfer_en,
   	input [AXI_TDATA_FACTOR-1:0]	slave_sl_tx_transfer_en
	
);

parameter FULL          = 4'h1;
parameter HALF          = 4'h2;
parameter QUARTER       = 4'h4;


parameter MASTER_RATE 	= HALF;
parameter SLAVE_RATE  	= HALF;


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

logic               		m_wr_clk;
logic               		s_wr_clk;
logic               		m_wr_rst_n;
logic               		s_wr_rst_n;

wire [39 * PHY_DWIDTH :0]	tx_phy0_ldr;
wire [39 * PHY_DWIDTH :0]	rx_phy0_ldr;

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

assign m_wr_rst_n 					= ~por_in & w_m_wr_rst_n & axist_rstn_in ;
assign s_wr_rst_n 					= ~por_in & w_s_wr_rst_n & axist_rstn_in ;
assign o_master_sl_tx_transfer_en 	= &(master_sl_tx_transfer_en);
assign o_master_ms_tx_transfer_en 	= &(master_ms_tx_transfer_en);
assign o_slave_sl_tx_transfer_en 	= &(slave_sl_tx_transfer_en); 
assign o_slave_ms_tx_transfer_en 	= &(slave_ms_tx_transfer_en); 	

assign o_w_m_wr_rst_n				= m_wr_rst_n;
assign o_s_wr_rst_n				= s_wr_rst_n;


   //-----------------------
   //-- WIRE DECLARATIONS --
   //-----------------------
   
   logic					master_align_done;	// From ca_master_i of ca.v
   logic [31:0]					rx_st_debug_status;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic [31:0]					tx_st_debug_status;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic					slave_align_done;			// From ca_slave_i of ca.v

   //-----------------------
   //-- REG DECLARATIONS --
   //-----------------------
   
	assign o_slave_align_done  		= slave_align_done; 
	assign o_master_align_done 		= master_align_done; 

	assign axist_master_tx_online =&{master_sl_tx_transfer_en,master_ms_tx_transfer_en} ;
	assign axist_slave_tx_online = &{slave_sl_tx_transfer_en,slave_ms_tx_transfer_en};
	assign m_wr_clk = m_wr_clk_in;
	assign s_wr_clk = s_wr_clk_in;


   axi_st_master_top axi_st_master_top_i
     (
      .tx_phy0				(tx_phy0_ldr),	
      .user_tready			(m_tx_axist_tready),	
      .tx_st_debug_status		(tx_st_debug_status[31:0]),
      
      .clk_wr				(m_wr_clk),		 
      .rst_wr_n				(m_wr_rst_n),	

      .tx_online			(axist_master_tx_online), 
      .rx_online			(master_align_done),	 
      .init_st_credit			(8'h0),			 
      .rx_phy0				(rx_phy0_ldr),
      .user_tdata			(m_tx_axist_tdata[(64*AXI_TDATA_FACTOR)-1:0]),	
      .user_tvalid			(m_tx_axist_tvalid),
      .m_gen2_mode			(m_gen2_mode),
      .delay_x_value    		(MASTER_DELAY_X_VALUE),
      .delay_y_value    		(MASTER_DELAY_Y_VALUE),
      .delay_z_value    		(MASTER_DELAY_Z_VALUE)
	);

  
   axi_st_slave_top axi_st_slave_top_i
    (
     .tx_phy0				(rx_phy0_ldr),	
     .user_tdata			(s_rx_axist_tdata[(64*AXI_TDATA_FACTOR)-1:0]),	 
     .user_tvalid			(s_rx_axist_tvalid),	
     .rx_st_debug_status		(rx_st_debug_status[31:0]),
    
     .clk_wr				(s_wr_clk),		 
     .rst_wr_n				(s_wr_rst_n & usermode_en),
    
     .tx_online				(axist_slave_tx_online), 
     .rx_online				(slave_align_done),	 
     .rx_phy0				(tx_phy0_ldr),	
     .user_tready			(s_rx_axist_tready),		
     .m_gen2_mode			(m_gen2_mode),
     .delay_x_value     		(SLAVE_DELAY_X_VALUE),
     .delay_y_value     		(SLAVE_DELAY_Y_VALUE),
     .delay_z_value     		(SLAVE_DELAY_Z_VALUE)
	 );



	assign master_align_done 	= axist_master_tx_online ;
	assign slave_align_done 	= axist_slave_tx_online ;


endmodule

