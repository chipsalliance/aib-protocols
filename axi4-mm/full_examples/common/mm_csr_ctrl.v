// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: AXIST Register module
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////

module mm_csr_ctrl #(parameter AXI_CHNL_NUM = 1) (
	input 				clk,	
	input 				rst_n,
	
	input 	[15:0]			wr_rd_addr,		
	input				wr_en,
	input				rd_en,
	input  [31:0]			wr_data,
	
	output 	reg [31:0]		rd_datain,
	output				rd_dvalid,
	
	output	[31:0]			o_delay_x_value,
	output	[31:0]			o_delay_y_value,
	output	[31:0]			o_delay_z_value,
	
	input 	[1:0]			chkr_pass,
	input				align_error,
	input				f2l_align_error,
	input 				ldr_tx_online,
	input 				ldr_rx_online,
	input 				fllr_tx_online,
	input 				fllr_rx_online,
	input 				read_complete,
	input 				write_complete,

	input  [(AXI_CHNL_NUM*64)-1:0]	data_out_first,
	input  				data_out_first_valid,
	input  [(AXI_CHNL_NUM*64)-1:0]	data_out_last,
	input  				data_out_last_valid,
	
	input  [(AXI_CHNL_NUM*64)-1:0]	data_in_first,
	input  				data_in_first_valid,
	input  [(AXI_CHNL_NUM*64)-1:0]	data_in_last,
	input  				data_in_last_valid,
	output 				axist_rstn_out,
	
	output 				aximm_wr,
	output 				aximm_rd,
	output 	[7:0]			aximm_rw_length,
	output 	[1:0]			aximm_rw_burst,
	output 	[2:0]			aximm_rw_size,
	output 	[31:0]			aximm_rw_addr	

);

localparam 			REG_MM_WR_CFG_ADDR		= 16'h1000;
localparam 			REG_MM_WR_RD_ADDR	 	= 16'h1004;
localparam 			REG_MM_BUS_STS_ADDR	 	= 16'h1008;
localparam 			REG_LINKUP_STS_ADDR		= 16'h100C;
localparam 			REG_MM_RD_CFG_ADDR		= 16'h1010;
	
localparam 			REG_DELAY_X_VAL_ADDR		= 16'h2000;
localparam 			REG_DELAY_Y_VAL_ADDR		= 16'h2004;
localparam 			REG_DELAY_Z_VAL_ADDR		= 16'h2008;
localparam 			REG_AXI_CTRL_ADDR		= 16'h3000;
	
localparam 			REG_DOUT_FIRST1_ADDR		= 16'h4000;
localparam 			REG_DOUT_FIRST2_ADDR		= 16'h4004;
localparam 			REG_DOUT_FIRST3_ADDR		= 16'h4008;
localparam 			REG_DOUT_FIRST4_ADDR		= 16'h400C;
	
localparam 			REG_DOUT_LAST1_ADDR		= 16'h4010;
localparam 			REG_DOUT_LAST2_ADDR		= 16'h4014;
localparam 			REG_DOUT_LAST3_ADDR		= 16'h4018;
localparam 			REG_DOUT_LAST4_ADDR		= 16'h401C;
localparam 			REG_DIN_FIRST1_ADDR		= 16'h4020;
localparam 			REG_DIN_FIRST2_ADDR		= 16'h4024;
localparam 			REG_DIN_FIRST3_ADDR		= 16'h4028;
localparam 			REG_DIN_FIRST4_ADDR		= 16'h402C;
localparam 			REG_DIN_LAST1_ADDR		= 16'h4030;
localparam 			REG_DIN_LAST2_ADDR		= 16'h4034;
localparam 			REG_DIN_LAST3_ADDR		= 16'h4038;
localparam 			REG_DIN_LAST4_ADDR		= 16'h403C;
	
reg [31:0] 			delay_x_value;
reg [31:0] 			delay_y_value;
reg [31:0] 			delay_z_value;
reg [31:0] 			mm_wr_cfg;
reg [31:0] 			mm_wr_rd_addr;
reg [31:0] 			mm_rd_cfg;
reg [31:0] 			aximm_bus_sts;
reg [31:0]			linkup_sts ;
reg [31:0]			axist_ctrl ;
reg [1:0]			mm_rd_en_r1;
reg [1:0]			mm_wr_en_r1;
reg [1:0]			chkr_done_r1;
wire 				chkr_done_rs;
reg [127:0]			r_data_out_last;
reg [127:0]			r_data_out_first;
reg [127:0]			r_data_in_last;
reg [127:0]			r_data_in_first;
reg [19:0] 			reg_rd_dvalid;
reg [31:0]			datain;
reg 				dvalid;

wire [127 : 0]			w_data_out_last;
wire [127:0]			w_data_out_first;
wire [127:0]			w_data_in_last;
wire [127:0]			w_data_in_first;

assign axist_rstn_out   	= ~axist_ctrl[0];
assign o_delay_x_value  	= delay_x_value;
assign o_delay_y_value  	= delay_y_value;
assign o_delay_z_value  	= delay_z_value;

generate
begin
	if(AXI_CHNL_NUM == 1)
		begin
			assign w_data_out_last 	= {64'd0,data_out_last};
			assign w_data_out_first = {64'd0,data_out_first};
			assign w_data_in_first 	= {64'd0,data_in_first};
			assign w_data_in_last 	= {64'd0,data_in_last};
		end
	else if(AXI_CHNL_NUM == 2)
		begin
			assign w_data_out_last 	= data_out_last;
			assign w_data_out_first = data_out_first;
			assign w_data_in_first 	= data_in_first;
			assign w_data_in_last 	= data_in_last;
		end
end
endgenerate

always@(posedge clk)
begin
	if(!rst_n)
	begin
		r_data_out_first 	<= 'b0;
	end 
	else if(data_out_first_valid)
	begin
		r_data_out_first	<= w_data_out_first;
	end
end

always@(posedge clk)
begin
	if(!rst_n)
	begin
		r_data_out_last 	<= 'b0;
	end 
	else if(data_out_last_valid)
	begin
		r_data_out_last		<= w_data_out_last;
	end
end

always@(posedge clk)
begin
	if(!rst_n)
	begin
		r_data_in_first 	<= 'b0;
	end 
	else if(data_in_first_valid)
	begin
		r_data_in_first		<= w_data_in_first;
	end
end

always@(posedge clk)
begin
	if(!rst_n)
	begin
		r_data_in_last 	<= 'b0;
	end 
	else if(data_in_last_valid)
	begin
		r_data_in_last	<= w_data_in_last;
	end
end

always@(posedge clk)
begin
	if(!rst_n)
	begin
		mm_wr_en_r1		<= 'b0;
	end 
	else
	begin
		mm_wr_en_r1		<= {mm_wr_en_r1[0],mm_wr_cfg[18]};
	end
end

assign aximm_wr = (mm_wr_cfg[18] & ~mm_wr_en_r1[0]) | (mm_wr_en_r1[0] & ~ mm_wr_en_r1[1]);

always@(posedge clk)
begin
	if(!rst_n)
	begin
		mm_rd_en_r1		<= 'b0;
	end 
	else
	begin
		mm_rd_en_r1		<= {mm_rd_en_r1[0],mm_rd_cfg[18]};
	end
end

assign aximm_rd 	= (mm_rd_cfg[18] & ~mm_rd_en_r1[0]) | (mm_rd_en_r1[0] & ~ mm_rd_en_r1[1]);

assign aximm_rw_length	= (aximm_wr) ?  mm_wr_cfg[11:4] : (aximm_rd) ? mm_rd_cfg[11:4]: 'b0;
assign aximm_rw_burst   = (aximm_wr) ?  mm_wr_cfg[13:12]: (aximm_rd) ? mm_rd_cfg[13:12]: 'b0;
assign aximm_rw_size    = (aximm_wr) ?  mm_wr_cfg[2:0]  : (aximm_rd) ? mm_rd_cfg[2:0]: 'b0;
assign aximm_rw_addr	= (aximm_wr | aximm_rd) ?  mm_wr_rd_addr : 'b0;



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

`ifdef AXIST_DUAL
always@(posedge clk)
begin
	if(!rst_n)
	begin
		f2l_chkr_done_r1	<= 'b0;
	end
	else
	begin
		f2l_chkr_done_r1	<= {f2l_chkr_done_r1[0],f2l_chkr_pass[1]};
	end
	
end

assign f2l_chkr_done_rs	= ~f2l_chkr_done_r1[1] & f2l_chkr_done_r1[0] ;
`endif

always@(posedge clk)
begin
	if(!rst_n)
	begin
		mm_wr_cfg				<= 'b0;
		mm_wr_rd_addr				<= 'b0;
		mm_rd_cfg				<= 'b0;
		axist_ctrl				<= 'b0;
	end 
	else if(wr_en)
	begin
		case(wr_rd_addr)
			REG_MM_WR_CFG_ADDR:
			begin
				mm_wr_cfg		<= wr_data;
				
			end
			REG_MM_WR_RD_ADDR:
			begin
				mm_wr_rd_addr		<= wr_data;
				
			end
			REG_MM_RD_CFG_ADDR:
			begin
				mm_rd_cfg		<= wr_data;
				
			end
			REG_DELAY_X_VAL_ADDR : 
				delay_x_value		<= wr_data;
			REG_DELAY_Y_VAL_ADDR : 
				delay_y_value		<= wr_data;
			REG_DELAY_Z_VAL_ADDR : 
				delay_z_value		<= wr_data;			
			REG_AXI_CTRL_ADDR : 
				axist_ctrl		<= wr_data;
			default:
			begin
				mm_wr_cfg		<= mm_wr_cfg;
			end
		endcase
	
	end
	else if(chkr_done_rs)
	begin
		mm_wr_cfg		<= 'b0;
	end	
end 

always@(posedge clk)
begin
	if(!rst_n)
	begin
		datain		<= 'b0;
		dvalid		<= 1'b0;
		
	end 
	else if(rd_en)
	begin
		case(wr_rd_addr)
			REG_MM_WR_CFG_ADDR:					
			begin                               	
				datain		<= mm_wr_cfg;   	
				dvalid		<= 1'b1;        	
			end                                 	
			REG_MM_WR_RD_ADDR:
			begin
				datain		<= mm_wr_rd_addr;
				dvalid		<= 1'b1;
			end
			REG_MM_BUS_STS_ADDR:
			begin
				datain		<= aximm_bus_sts;
				dvalid		<= 1'b1;
			end			
			REG_LINKUP_STS_ADDR:
			begin
				datain		<= linkup_sts;
				dvalid		<= 1'b1;
			end
			REG_MM_RD_CFG_ADDR:
			begin
				datain		<= mm_rd_cfg;
				dvalid		<= 1'b1;
			end
			REG_DELAY_X_VAL_ADDR :
			begin
				datain		<= delay_x_value;
				dvalid		<= 1'b1;
			end
			REG_DELAY_Y_VAL_ADDR :
			begin
				datain		<= delay_y_value;
				dvalid		<= 1'b1;
			end
			REG_DELAY_Z_VAL_ADDR :
			begin
				datain		<= delay_z_value;
				dvalid		<= 1'b1;
			end
			
			REG_DOUT_FIRST1_ADDR	:
			begin
				datain		<= r_data_out_first[31:0];
				dvalid		<= 1'b1;
			end
			REG_DOUT_FIRST2_ADDR	:
			begin
				datain		<= r_data_out_first[63:32];
				dvalid		<= 1'b1;
			end
			REG_DOUT_FIRST3_ADDR	:
			begin
				datain		<= r_data_out_first[95:64];
				dvalid		<= 1'b1;
			end
			REG_DOUT_FIRST4_ADDR	:
			begin
				datain		<= r_data_out_first[127:96];
				dvalid		<= 1'b1;
			end
			
			REG_DOUT_LAST1_ADDR		:
			begin
				datain		<= r_data_out_last[31:0];
				dvalid		<= 1'b1;
			end
			REG_DOUT_LAST2_ADDR		:
			begin
				datain		<= r_data_out_last[63:32];
				dvalid		<= 1'b1;
			end
			REG_DOUT_LAST3_ADDR		:
			begin
				datain		<= r_data_out_last[95:64];
				dvalid		<= 1'b1;
			end
			REG_DOUT_LAST4_ADDR		:
			begin
				datain		<= r_data_out_last[127:96];
				dvalid		<= 1'b1;
			end
			
			REG_DIN_FIRST1_ADDR		:
			begin
				datain		<= r_data_in_first[31:0];
				dvalid		<= 1'b1;
			end                    
			REG_DIN_FIRST2_ADDR		:
			begin                  
				datain		<= r_data_in_first[63:32];
				dvalid		<= 1'b1;
			end                    
			REG_DIN_FIRST3_ADDR		:
			begin                  
				datain		<= r_data_in_first[95:64];
				dvalid		<= 1'b1;
			end                    
			REG_DIN_FIRST4_ADDR		:
			begin                  
				datain		<= r_data_in_first[127:96];
				dvalid		<= 1'b1;
			end
			
			REG_DIN_LAST1_ADDR		:
			begin
				datain		<= r_data_in_last[31:0];
				dvalid		<= 1'b1;
			end                    
			REG_DIN_LAST2_ADDR		:
			begin                  
				datain		<= r_data_in_last[63:32];
				dvalid		<= 1'b1;
			end                    
			REG_DIN_LAST3_ADDR		:
			begin                  
				datain		<= r_data_in_last[95:64];
				dvalid		<= 1'b1;
			end                    
			REG_DIN_LAST4_ADDR		:
			begin                  
				datain		<= r_data_in_last[127:96];
				dvalid		<= 1'b1;
			end
			
			default:
			begin
				datain		<= 'b0;
				dvalid		<= 1'b0;
			end
		endcase
	
	end
	else
	begin
		datain		<= 'b0;
		dvalid		<= 1'b0;
	end 
end 

always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			reg_rd_dvalid	<= 'b0;
		end
		else
		begin
			reg_rd_dvalid	<= {reg_rd_dvalid[18:0],dvalid};
		end 
	end 
	
	assign rd_dvalid	= |reg_rd_dvalid;
	
	
	always@(posedge clk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			rd_datain	<= 'b0;
		end
		else if(dvalid)
		begin
			rd_datain	<= datain;
		end 
	end 


	assign aximm_bus_sts	= {10'h000,read_complete,write_complete,~align_error,~f2l_align_error,chkr_pass};
	assign linkup_sts	= {12'h000, fllr_rx_online, fllr_tx_online, ldr_rx_online, ldr_tx_online};
    
endmodule                         
                                  
