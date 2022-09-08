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

module csr_ctrl (
	input 				clk,	
	input 				rst_n,
	
	input 	[15:0]			wr_rd_addr,		
	input				wr_en,
	input				rd_en,
	input  [31:0]			wr_data,
	
	output 	reg [31:0]		rd_datain,
	output				rd_dvalid,
	
	`ifdef AXIST_DUAL
	  input 	[1:0]		f2l_chkr_pass,
	  input 			f2l_align_error,	
	  output 			f2l_csr_patgen_en,
	  output 	[1:0]		f2l_csr_patgen_sel,
	  output 	[8:0]		f2l_csr_patgen_cnt,
	  output 			f2l_csr_cntuspatt_en,
	  input  [255:0]		f2l_data_out_first,
	  input  			f2l_data_out_first_valid,
	  input  [255:0]		f2l_data_out_last,
	  input  			f2l_data_out_last_valid,
	  
	  input  [511:0]		f2l_data_in_first,
	  input  			f2l_data_in_first_valid,
	  input  [511:0]		f2l_data_in_last,
	  input  			f2l_data_in_last_valid,
	`endif
	
	output	[31:0]			o_delay_x_value,
	output	[31:0]			o_delay_y_value,
	output	[31:0]			o_delay_z_value,
	
	input 	[1:0]			chkr_pass,
	input				align_error,
	input 				ldr_tx_online,
	input 				ldr_rx_online,
	input 				fllr_tx_online,
	input 				fllr_rx_online,
	
	input  [255:0]			data_out_first,
	input  				data_out_first_valid,
	input  [255:0]			data_out_last,
	input  				data_out_last_valid,
	
	input  [511:0]			data_in_first,
	input  				data_in_first_valid,
	input  [511:0]			data_in_last,
	input  				data_in_last_valid,
	
	output 				axist_rstn_out,
	
	output 				csr_patgen_en,
	output 	[1:0]			csr_patgen_sel,
	output 	[8:0]			csr_patgen_cnt,
	output 				csr_cntuspatt_en	


);

localparam 		REG_TX_PKT_CTRL_ADDR 		= 16'h1000;
localparam 		REG_RX_CKR_STS_ADDR	 	= 16'h1004;
`ifdef AXIST_DUAL
  localparam 		REG_F2L_TX_PKT_CTRL_ADDR	= 16'h1008;
  localparam 		REG_F2L_RX_CKR_STS_ADDR		= 16'h100C;
  localparam 		REG_LINKUP_STS_ADDR		= 16'h1010;
  	
  localparam 		REG_FOLLR_DOUT_FIRST1_ADDR	= 16'h5000;
  localparam 		REG_FOLLR_DOUT_FIRST2_ADDR	= 16'h5004;
  localparam 		REG_FOLLR_DOUT_FIRST3_ADDR	= 16'h5008;
  localparam 		REG_FOLLR_DOUT_FIRST4_ADDR	= 16'h500C;
  localparam 		REG_FOLLR_DOUT_FIRST5_ADDR	= 16'h5010;
  localparam 		REG_FOLLR_DOUT_FIRST6_ADDR	= 16'h5014;
  localparam 		REG_FOLLR_DOUT_FIRST7_ADDR	= 16'h5018;
  localparam 		REG_FOLLR_DOUT_FIRST8_ADDR	= 16'h501C;
  	
  localparam 		REG_FOLLR_DOUT_LAST1_ADDR	= 16'h5100;
  localparam 		REG_FOLLR_DOUT_LAST2_ADDR	= 16'h5104;
  localparam 		REG_FOLLR_DOUT_LAST3_ADDR	= 16'h5108;
  localparam 		REG_FOLLR_DOUT_LAST4_ADDR	= 16'h510C;
  localparam 		REG_FOLLR_DOUT_LAST5_ADDR	= 16'h5110;
  localparam 		REG_FOLLR_DOUT_LAST6_ADDR	= 16'h5114;
  localparam 		REG_FOLLR_DOUT_LAST7_ADDR	= 16'h5118;
  localparam 		REG_FOLLR_DOUT_LAST8_ADDR	= 16'h511C;
  	
  localparam 		REG_FOLLR_DIN_FIRST1_ADDR	= 16'h5200;
  localparam 		REG_FOLLR_DIN_FIRST2_ADDR	= 16'h5204;
  localparam 		REG_FOLLR_DIN_FIRST3_ADDR	= 16'h5208;
  localparam 		REG_FOLLR_DIN_FIRST4_ADDR	= 16'h520C;
  localparam 		REG_FOLLR_DIN_FIRST5_ADDR	= 16'h5210;
  localparam 		REG_FOLLR_DIN_FIRST6_ADDR	= 16'h5214;
  localparam 		REG_FOLLR_DIN_FIRST7_ADDR	= 16'h5218;
  localparam 		REG_FOLLR_DIN_FIRST8_ADDR	= 16'h521C;
  	
  localparam 		REG_FOLLR_DIN_LAST1_ADDR	= 16'h5300;
  localparam 		REG_FOLLR_DIN_LAST2_ADDR	= 16'h5304;
  localparam 		REG_FOLLR_DIN_LAST3_ADDR	= 16'h5308;
  localparam 		REG_FOLLR_DIN_LAST4_ADDR	= 16'h530C;
  localparam 		REG_FOLLR_DIN_LAST5_ADDR	= 16'h5310;
  localparam 		REG_FOLLR_DIN_LAST6_ADDR	= 16'h5314;
  localparam 		REG_FOLLR_DIN_LAST7_ADDR	= 16'h5318;
  localparam 		REG_FOLLR_DIN_LAST8_ADDR	= 16'h531C;
`else
  localparam 		REG_LINKUP_STS_ADDR		= 16'h1008;
`endif
localparam 		REG_DELAY_X_VAL_ADDR		= 16'h2000;
localparam 		REG_DELAY_Y_VAL_ADDR		= 16'h2004;
localparam 		REG_DELAY_Z_VAL_ADDR		= 16'h2008;
localparam 		REG_AXI_CTRL_ADDR		= 16'h3000;
	
localparam 			REG_DOUT_FIRST1_ADDR	= 16'h4000;
localparam 			REG_DOUT_FIRST2_ADDR	= 16'h4004;
localparam 			REG_DOUT_FIRST3_ADDR	= 16'h4008;
localparam 			REG_DOUT_FIRST4_ADDR	= 16'h400C;
localparam 			REG_DOUT_FIRST5_ADDR	= 16'h4010;
localparam 			REG_DOUT_FIRST6_ADDR	= 16'h4014;
localparam 			REG_DOUT_FIRST7_ADDR	= 16'h4018;
localparam 			REG_DOUT_FIRST8_ADDR	= 16'h401C;
	
localparam 			REG_DOUT_LAST1_ADDR	= 16'h4100;
localparam 			REG_DOUT_LAST2_ADDR	= 16'h4104;
localparam 			REG_DOUT_LAST3_ADDR	= 16'h4108;
localparam 			REG_DOUT_LAST4_ADDR	= 16'h410C;
localparam 			REG_DOUT_LAST5_ADDR	= 16'h4110;
localparam 			REG_DOUT_LAST6_ADDR	= 16'h4114;
localparam 			REG_DOUT_LAST7_ADDR	= 16'h4118;
localparam 			REG_DOUT_LAST8_ADDR	= 16'h411C;
	
localparam 			REG_DIN_FIRST1_ADDR	= 16'h4200;
localparam 			REG_DIN_FIRST2_ADDR	= 16'h4204;
localparam 			REG_DIN_FIRST3_ADDR	= 16'h4208;
localparam 			REG_DIN_FIRST4_ADDR	= 16'h420C;
localparam 			REG_DIN_FIRST5_ADDR	= 16'h4210;
localparam 			REG_DIN_FIRST6_ADDR	= 16'h4214;
localparam 			REG_DIN_FIRST7_ADDR	= 16'h4218;
localparam 			REG_DIN_FIRST8_ADDR	= 16'h421C;
	
localparam 			REG_DIN_LAST1_ADDR	= 16'h4300;
localparam 			REG_DIN_LAST2_ADDR	= 16'h4304;
localparam 			REG_DIN_LAST3_ADDR	= 16'h4308;
localparam 			REG_DIN_LAST4_ADDR	= 16'h430C;
localparam 			REG_DIN_LAST5_ADDR	= 16'h4310;
localparam 			REG_DIN_LAST6_ADDR	= 16'h4314;
localparam 			REG_DIN_LAST7_ADDR	= 16'h4318;
localparam 			REG_DIN_LAST8_ADDR	= 16'h431C;


reg  [31:0] 		delay_x_value;
reg  [31:0] 		delay_y_value;
reg  [31:0] 		delay_z_value;
reg  [31:0] 		tx_pkt_ctrl;
reg  [31:0] 		l2f_tx_pkt_ctrl;
wire [31:0]		rx_ckr_sts ;
wire [31:0]		linkup_sts ;
reg  [31:0]		axist_ctrl ;
reg  [1:0]		csr_patgen_en_r1;
reg  [1:0]		f2l_csr_patgen_en_r1;
reg  [1:0]		chkr_done_r1;
reg  [31:0]		datain;
reg 			dvalid;
wire 			chkr_done_rs;
reg  [19:0]		reg_rd_dvalid;
reg  [255:0]		r_data_out_last;
reg  [255:0]		r_data_out_first;
reg  [511:0]		r_data_in_last;
reg  [511:0]		r_data_in_first;
`ifdef AXIST_DUAL
	reg [1:0]		f2l_chkr_done_r1;
	wire 			f2l_chkr_done_rs;
	wire [31:0]		f2l_rx_ckr_sts ;
	reg [511:0]		r_f2l_data_out_last;
	reg [511:0]		r_f2l_data_out_first;
	reg [511:0]		r_f2l_data_in_last;
	reg [511:0]		r_f2l_data_in_first;
`endif
assign axist_rstn_out   	= ~axist_ctrl[0];
assign o_delay_x_value  	= delay_x_value;
assign o_delay_y_value  	= delay_y_value;
assign o_delay_z_value  	= delay_z_value;
assign csr_patgen_sel		= tx_pkt_ctrl[3:2];
assign csr_patgen_cnt   	= tx_pkt_ctrl[12:4];
assign f2l_csr_patgen_sel   = l2f_tx_pkt_ctrl[3:2];
assign f2l_csr_patgen_cnt   = l2f_tx_pkt_ctrl[12:4];


always@(posedge clk)
begin
	if(!rst_n)
	begin
		r_data_out_first 	<= 'b0;
	end 
	else if(data_out_first_valid)
	begin
		r_data_out_first	<= data_out_first;
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
		r_data_out_last		<= data_out_last;
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
		r_data_in_first		<= data_in_first;
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
		r_data_in_last	<= data_in_last;
	end
end

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		csr_patgen_en_r1		<= 'b0;
	end 
	else
	begin
		csr_patgen_en_r1		<= {csr_patgen_en_r1[0],tx_pkt_ctrl[0]};
	end
end

assign csr_patgen_en = (tx_pkt_ctrl[0] & ~csr_patgen_en_r1[0]) | (csr_patgen_en_r1[0] & ~ csr_patgen_en_r1[1]);

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		f2l_csr_patgen_en_r1		<= 'b0;
	end 
	else
	begin
		f2l_csr_patgen_en_r1		<= {f2l_csr_patgen_en_r1[0],l2f_tx_pkt_ctrl[0]};
	end
end

assign f2l_csr_patgen_en = (l2f_tx_pkt_ctrl[0] & ~f2l_csr_patgen_en_r1[0]) | (f2l_csr_patgen_en_r1[0] & ~ f2l_csr_patgen_en_r1[1]);

always@(posedge clk or negedge rst_n)
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
always@(posedge clk or negedge rst_n)
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

always@(posedge clk or negedge rst_n)		
begin                                       
	if(!rst_n)
	begin
		r_f2l_data_out_first	<= 'b0;
	end
	else if(f2l_data_out_first_valid)
	begin
		r_f2l_data_out_first	<= f2l_data_out_first;
	end
	
end


always@(posedge clk or negedge rst_n)		
begin                                       
	if(!rst_n)
	begin
		r_f2l_data_out_last	<= 'b0;
	end
	else if(f2l_data_out_last_valid)
	begin
		r_f2l_data_out_last	<= f2l_data_out_last;
	end
	
end

always@(posedge clk or negedge rst_n)		
begin                                       
	if(!rst_n)
	begin
		r_f2l_data_in_first	<= 'b0;
	end
	else if(f2l_data_in_first_valid)
	begin
		r_f2l_data_in_first	<= f2l_data_in_first;
	end
	
end


always@(posedge clk or negedge rst_n)		
begin                                       
	if(!rst_n)
	begin
		r_f2l_data_in_last	<= 'b0;
	end
	else if(f2l_data_in_last_valid)
	begin
		r_f2l_data_in_last	<= f2l_data_in_last;
	end
	
end



`endif

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		tx_pkt_ctrl				<= 'b0;
		l2f_tx_pkt_ctrl			<= 'b0;
		axist_ctrl				<= 'b0;
	end 
	else if(wr_en)
	begin
		case(wr_rd_addr)
			REG_TX_PKT_CTRL_ADDR:
			begin
				tx_pkt_ctrl		<= wr_data;
			end
			`ifdef AXIST_DUAL
			  REG_F2L_TX_PKT_CTRL_ADDR :
			  begin
			  	l2f_tx_pkt_ctrl	<= wr_data;
			  end
			`endif
			REG_DELAY_X_VAL_ADDR : 
				delay_x_value	<= wr_data;
			REG_DELAY_Y_VAL_ADDR : 
				delay_y_value	<= wr_data;
			REG_DELAY_Z_VAL_ADDR : 
				delay_z_value	<= wr_data;			
			REG_AXI_CTRL_ADDR : 
				axist_ctrl	<= wr_data;
			default:
			begin
				tx_pkt_ctrl		<= tx_pkt_ctrl;
				l2f_tx_pkt_ctrl		<= l2f_tx_pkt_ctrl;
			end
		endcase
	
	end
	else if(chkr_done_rs)
	begin
		tx_pkt_ctrl		<= 'b0;
	end	
	`ifdef AXIST_DUAL
	  else if(f2l_chkr_done_rs)
	  begin
	  	l2f_tx_pkt_ctrl		<= 'b0;
	  end
	`endif
end 

always@(posedge clk or negedge rst_n)
begin
	if(!rst_n)
	begin
		datain		<= 'b0;
		dvalid		<= 1'b0;
		
	end 
	else if(rd_en)
	begin
		case(wr_rd_addr)
			REG_TX_PKT_CTRL_ADDR:
			begin
				datain		<= tx_pkt_ctrl;
				dvalid		<= 1'b1;
			end
			REG_RX_CKR_STS_ADDR:
			begin
				datain		<= rx_ckr_sts;
				dvalid		<= 1'b1;
			end
			REG_LINKUP_STS_ADDR:
			begin
				datain		<= linkup_sts;
				dvalid		<= 1'b1;
			end
			`ifdef AXIST_DUAL
			  REG_F2L_RX_CKR_STS_ADDR:
			  begin
			  	datain		<= f2l_rx_ckr_sts;
			  	dvalid		<= 1'b1;
			  end
			  REG_F2L_TX_PKT_CTRL_ADDR:
			  begin
			  	datain		<= l2f_tx_pkt_ctrl;
			  	dvalid		<= 1'b1;
			  end
			  
			  REG_FOLLR_DOUT_FIRST1_ADDR	:
			  begin
			  	datain		<= r_data_out_first[31:0];
			  	dvalid		<= 1'b1;
			  end
			  REG_FOLLR_DOUT_FIRST2_ADDR	:
			  begin
			  	datain		<= r_data_out_first[63:32];
			  	dvalid		<= 1'b1;
			  end
			  REG_FOLLR_DOUT_FIRST3_ADDR	:
			  begin
			  	datain		<= r_data_out_first[95:64];
			  	dvalid		<= 1'b1;
			  end
			  REG_FOLLR_DOUT_FIRST4_ADDR	:
			  begin
			  	datain		<= r_data_out_first[127:96];
			  	dvalid		<= 1'b1;
			  end
			   REG_FOLLR_DOUT_FIRST5_ADDR	:
			  begin
			  	datain		<= r_data_out_first[159:128];
			  	dvalid		<= 1'b1;
			  end
			  REG_FOLLR_DOUT_FIRST6_ADDR	:
			  begin
			  	datain		<= r_data_out_first[191:160];
			  	dvalid		<= 1'b1;
			  end
			  REG_FOLLR_DOUT_FIRST7_ADDR	:
			  begin
			  	datain		<= r_data_out_first[223:192];
			  	dvalid		<= 1'b1;
			  end
			  REG_FOLLR_DOUT_FIRST8_ADDR	:
			  begin
			  	datain		<= r_data_out_first[255:224];
			  	dvalid		<= 1'b1;
			  end	  
			  
			  REG_FOLLR_DOUT_LAST1_ADDR		:
			  begin
			  	datain		<= r_f2l_data_out_last[31:0];
			  	dvalid		<= 1'b1;
			  end
			  REG_FOLLR_DOUT_LAST2_ADDR		:
			  begin
			  	datain		<= r_f2l_data_out_last[63:32];
			  	dvalid		<= 1'b1;
			  end
			  REG_FOLLR_DOUT_LAST3_ADDR		:
			  begin
			  	datain		<= r_f2l_data_out_last[95:64];
			  	dvalid		<= 1'b1;
			  end
			  REG_FOLLR_DOUT_LAST4_ADDR		:
			  begin
			  	datain		<= r_f2l_data_out_last[127:96];
			  	dvalid		<= 1'b1;
			  end
			  REG_FOLLR_DOUT_LAST5_ADDR		:
			  begin
			  	datain		<= r_f2l_data_out_last[159:128];
			  	dvalid		<= 1'b1;               
			  end                                  
			  REG_FOLLR_DOUT_LAST6_ADDR		:      
			  begin                                
			  	datain		<= r_f2l_data_out_last[191:160];
			  	dvalid		<= 1'b1;               
			  end                                  
			  REG_FOLLR_DOUT_LAST7_ADDR		:      
			  begin                                
			  	datain		<= r_f2l_data_out_last[223:192];
			  	dvalid		<= 1'b1;               
			  end                                  
			  REG_FOLLR_DOUT_LAST8_ADDR		:      
			  begin                                
			  	datain		<= r_f2l_data_out_last[255:224];
			  	dvalid		<= 1'b1;
			  end
			  
			  REG_FOLLR_DIN_FIRST1_ADDR		:
			  begin
			  	datain		<= r_f2l_data_in_first[31:0];
			  	dvalid		<= 1'b1;
			  end                    
			  REG_FOLLR_DIN_FIRST2_ADDR		:
			  begin                  
			  	datain		<= r_f2l_data_in_first[63:32];
			  	dvalid		<= 1'b1;
			  end                    
			  REG_FOLLR_DIN_FIRST3_ADDR		:
			  begin                  
			  	datain		<= r_f2l_data_in_first[95:64];
			  	dvalid		<= 1'b1;
			  end                    
			  REG_FOLLR_DIN_FIRST4_ADDR		:
			  begin                  
			  	datain		<= r_f2l_data_in_first[127:96];
			  	dvalid		<= 1'b1;
			  end
			  REG_FOLLR_DIN_FIRST5_ADDR		:
			  begin
			  	datain		<= r_f2l_data_in_first[159:128];
			  	dvalid		<= 1'b1;               
			  end                                  
			  REG_FOLLR_DIN_FIRST6_ADDR		:      
			  begin                                
			  	datain		<= r_f2l_data_in_first[191:160];
			  	dvalid		<= 1'b1;               
			  end                                  
			  REG_FOLLR_DIN_FIRST7_ADDR		:      
			  begin                                
			  	datain		<= r_f2l_data_in_first[223:192];
			  	dvalid		<= 1'b1;               
			  end                                  
			  REG_FOLLR_DIN_FIRST8_ADDR		:      
			  begin                                
			  	datain		<= r_f2l_data_in_first[255:224];
			  	dvalid		<= 1'b1;
			  end

			  REG_FOLLR_DIN_LAST1_ADDR		:
			  begin
			  	datain		<= r_f2l_data_in_last[31:0];
			  	dvalid		<= 1'b1;
			  end                    
			  REG_FOLLR_DIN_LAST2_ADDR		:
			  begin                  
			  	datain		<= r_f2l_data_in_last[63:32];
			  	dvalid		<= 1'b1;
			  end                    
			  REG_FOLLR_DIN_LAST3_ADDR		:
			  begin                  
			  	datain		<= r_f2l_data_in_last[95:64];
			  	dvalid		<= 1'b1;
			  end                    
			  REG_FOLLR_DIN_LAST4_ADDR		:
			  begin                  
			  	datain		<= r_f2l_data_in_last[127:96];
			  	dvalid		<= 1'b1;
			  end
			  REG_FOLLR_DIN_LAST5_ADDR		:
			  begin
			  	datain		<= r_f2l_data_in_last[159:128];
			  	dvalid		<= 1'b1;              
			  end                                 
			  REG_FOLLR_DIN_LAST6_ADDR		:     
			  begin                               
			  	datain		<= r_f2l_data_in_last[191:160];
			  	dvalid		<= 1'b1;              
			  end                                 
			  REG_FOLLR_DIN_LAST7_ADDR		:     
			  begin                               
			  	datain		<= r_f2l_data_in_last[223:192];
			  	dvalid		<= 1'b1;              
			  end                                 
			  REG_FOLLR_DIN_LAST8_ADDR		:     
			  begin                               
			  	datain		<= r_f2l_data_in_last[255:224];
			  	dvalid		<= 1'b1;
			  end
			`endif
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
			REG_DOUT_FIRST5_ADDR	:
			begin
				datain		<= r_data_out_first[159:128];
				dvalid		<= 1'b1;
			end
			REG_DOUT_FIRST6_ADDR	:
			begin
				datain		<= r_data_out_first[191:160];
				dvalid		<= 1'b1;
			end
			REG_DOUT_FIRST7_ADDR	:
			begin
				datain		<= r_data_out_first[223:192];
				dvalid		<= 1'b1;
			end
			REG_DOUT_FIRST8_ADDR	:
			begin
				datain		<= r_data_out_first[255:224];
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
			REG_DOUT_LAST5_ADDR		:
			begin
				datain		<= r_data_out_last[159:128];
				dvalid		<= 1'b1;
			end
			REG_DOUT_LAST6_ADDR		:
			begin
				datain		<= r_data_out_last[191:160];
				dvalid		<= 1'b1;
			end
			REG_DOUT_LAST7_ADDR		:
			begin
				datain		<= r_data_out_last[223:192];
				dvalid		<= 1'b1;
			end
			REG_DOUT_LAST8_ADDR		:
			begin
				datain		<= r_data_out_last[255:224];
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
			REG_DIN_FIRST5_ADDR		:
			begin
				datain		<= r_data_in_first[159:128];
				dvalid		<= 1'b1;
			end                    
			REG_DIN_FIRST6_ADDR		:
			begin                  
				datain		<= r_data_in_first[191:160];
				dvalid		<= 1'b1;
			end                    
			REG_DIN_FIRST7_ADDR		:
			begin                  
				datain		<= r_data_in_first[223:192];
				dvalid		<= 1'b1;
			end                    
			REG_DIN_FIRST8_ADDR		:
			begin                  
				datain		<= r_data_in_first[255:224];
				dvalid		<= 1'b1;
			end
			REG_DIN_LAST1_ADDR		:
			begin
				datain		<= r_data_in_last[287:256];
				dvalid		<= 1'b1;
			end                    
			REG_DIN_LAST2_ADDR		:
			begin                  
				datain		<= r_data_in_last[319:288];
				dvalid		<= 1'b1;
			end                    
			REG_DIN_LAST3_ADDR		:
			begin                  
				datain		<= r_data_in_last[351:320];
				dvalid		<= 1'b1;
			end                    
			REG_DIN_LAST4_ADDR		:
			begin                  
				datain		<= r_data_in_last[383:352];
				dvalid		<= 1'b1;
			end
			REG_DIN_LAST5_ADDR		:
			begin
				datain		<= r_data_in_last[415:384];
				dvalid		<= 1'b1;
			end                    
			REG_DIN_LAST6_ADDR		:
			begin                  
				datain		<= r_data_in_last[447:416];
				dvalid		<= 1'b1;
			end                    
			REG_DIN_LAST7_ADDR		:
			begin                  
				datain		<= r_data_in_last[479:448];
				dvalid		<= 1'b1;
			end                    
			REG_DIN_LAST8_ADDR		:
			begin                  
				datain		<= r_data_in_last[511:480];
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


	assign rx_ckr_sts 		= {12'h000,~align_error,1'b0,chkr_pass};
	assign linkup_sts		= {12'h000, fllr_rx_online, fllr_tx_online, ldr_rx_online, ldr_tx_online};
    assign csr_cntuspatt_en 		=   tx_pkt_ctrl[14];                          
   `ifdef AXIST_DUAL
	  assign f2l_rx_ckr_sts 	= {12'h000,~f2l_align_error,1'b0,f2l_chkr_pass};
	  assign f2l_csr_cntuspatt_en 	=   l2f_tx_pkt_ctrl[14];                          
	`endif
endmodule                         
                                  
