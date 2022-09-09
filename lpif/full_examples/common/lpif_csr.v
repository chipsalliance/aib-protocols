// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: LPIF Adapter Register module
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////

module lpif_csr (
	input 					clk,	
	input 					rst_n,
	
	input 	[15:0]				wr_rd_addr,		
	input					wr_en,
	input					rd_en,
	input  [31:0]				wr_data,
	
	output 	reg [31:0]			rd_datain,
	output	reg				rd_dvalid,
	
	output	[31:0]				o_delay_x_value,
	output	[31:0]				o_delay_y_value,
	output	[31:0]				o_delay_z_value,
	
	input 	[1:0]				chkr_pass,
	input					align_error,
	input 					die_a_tx_online,
	input 					die_a_rx_online,
	input 					die_b_tx_online,
	input 					die_b_rx_online,
	input 					align_done,
	input 					test_complete,

	output 					flit_wr_en
	

);

localparam 		REG_DIE_A_CTRL_ADDR 		= 16'h1000;
localparam 		REG_DIE_A_STS_ADDR		= 16'h1004;
localparam 		REG_LINKUP_STS_ADDR		= 16'h1008;

localparam 		REG_DELAY_X_VAL_ADDR		= 16'h2000;
localparam 		REG_DELAY_Y_VAL_ADDR		= 16'h2004;
localparam 		REG_DELAY_Z_VAL_ADDR		= 16'h2008;

reg [31:0] 			delay_x_value;
reg [31:0] 			delay_y_value;
reg [31:0] 			delay_z_value;
reg [31:0] 			die_a_ctrl;
reg [31:0] 			die_a_sts;
reg [31:0]			linkup_sts ;

reg [1:0]			chkr_done_r1;
wire 				chkr_done_rs;

assign o_delay_x_value  	= delay_x_value;
assign o_delay_y_value  	= delay_y_value;
assign o_delay_z_value  	= delay_z_value;
assign flit_wr_en		= die_a_ctrl[0];

always@(posedge clk)
begin
	if(!rst_n)
	begin
		chkr_done_r1	<= 'b0;
	end
	else
	begin
		chkr_done_r1	<= {chkr_done_r1[0],chkr_pass[1]};
	end
	
end

assign chkr_done_rs	= ~chkr_done_r1[1] & chkr_done_r1[0] ;

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		die_a_ctrl				<= 'b0;
	end 
	else if(wr_en)
	begin
		case(wr_rd_addr)
			REG_DIE_A_CTRL_ADDR:
			begin
				die_a_ctrl		<= wr_data;
			end
			REG_DELAY_X_VAL_ADDR : 
				delay_x_value		<= wr_data;
			REG_DELAY_Y_VAL_ADDR : 
				delay_y_value		<= wr_data;
			REG_DELAY_Z_VAL_ADDR : 
				delay_z_value		<= wr_data;			
			default:
			begin
				die_a_ctrl		<= die_a_ctrl;
			end
		endcase
	
	end
	else if(chkr_done_rs)
	begin
		die_a_ctrl		<= 'b0;
	end	
	
end 

always@(posedge clk)
begin
	if(!rst_n)
	begin
		rd_datain		<= 'b0;
		rd_dvalid		<= 1'b0;
		
	end 
	else if(rd_en)
	begin
		case(wr_rd_addr)
			REG_DIE_A_CTRL_ADDR:
			begin
				rd_datain		<= die_a_ctrl;
				rd_dvalid		<= 1'b1;
			end
			REG_DIE_A_STS_ADDR:
			begin
				rd_datain		<= die_a_sts;
				rd_dvalid		<= 1'b1;
			end
			REG_LINKUP_STS_ADDR:
			begin
				rd_datain		<= linkup_sts;
				rd_dvalid		<= 1'b1;
			end
			REG_DELAY_X_VAL_ADDR :
			begin
				rd_datain		<= delay_x_value;
				rd_dvalid		<= 1'b1;
			end
			REG_DELAY_Y_VAL_ADDR :
			begin
				rd_datain		<= delay_y_value;
				rd_dvalid		<= 1'b1;
			end
			REG_DELAY_Z_VAL_ADDR :
			begin
				rd_datain		<= delay_z_value;
				rd_dvalid		<= 1'b1;
			end
			default:
			begin
				rd_datain		<= 'b0;
				rd_dvalid		<= 1'b0;
			end
		endcase
	
	end
	else
	begin
		rd_datain		<= 'b0;
		rd_dvalid		<= 1'b0;
	end 
end 

	assign die_a_sts 		= {12'h000,~align_error,test_complete,chkr_pass};
	assign linkup_sts		= {10'h000, ~align_error,align_done,die_b_rx_online, die_b_tx_online, die_a_rx_online, die_a_tx_online};
			
endmodule                         
                                  
            
