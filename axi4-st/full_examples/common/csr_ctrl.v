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
	input 					clk,	
	input 					rst_n,
	
	input 	[15:0]			wr_rd_addr,		
	input					wr_en,
	input					rd_en,
	input  [31:0]			wr_data,
	
	output 	reg [31:0]		rd_datain,
	output	reg				rd_dvalid,
	
	`ifdef AXIST_DUAL
	  input 	[1:0]			f2l_chkr_pass,
	  input 					f2l_align_error,	
	  output 					f2l_csr_patgen_en,
	  output 	[1:0]			f2l_csr_patgen_sel,
	  output 	[8:0]			f2l_csr_patgen_cnt,
	  output 					f2l_csr_cntuspatt_en,
	`endif
	
	output	[31:0]			o_delay_x_value,
	output	[31:0]			o_delay_y_value,
	output	[31:0]			o_delay_z_value,
	
	input 	[1:0]			chkr_pass,
	input					align_error,
	input 					ldr_tx_online,
	input 					ldr_rx_online,
	input 					fllr_tx_online,
	input 					fllr_rx_online,

	output 					axist_rstn_out,
	
	output 					csr_patgen_en,
	output 	[1:0]			csr_patgen_sel,
	output 	[8:0]			csr_patgen_cnt,
	output 					csr_cntuspatt_en	


);

localparam 		REG_TX_PKT_CTRL_ADDR 		= 16'h1000;
localparam 		REG_RX_CKR_STS_ADDR	 		= 16'h1004;
`ifdef AXIST_DUAL
localparam 		REG_F2L_TX_PKT_CTRL_ADDR	= 16'h1008;
localparam 		REG_F2L_RX_CKR_STS_ADDR		= 16'h100C;
localparam 		REG_LINKUP_STS_ADDR			= 16'h1010;
`else
localparam 		REG_LINKUP_STS_ADDR			= 16'h1008;
`endif
localparam 		REG_DELAY_X_VAL_ADDR		= 16'h2000;
localparam 		REG_DELAY_Y_VAL_ADDR		= 16'h2004;
localparam 		REG_DELAY_Z_VAL_ADDR		= 16'h2008;
localparam 		REG_AXI_CTRL_ADDR			= 16'h3000;


reg [31:0] 		delay_x_value;
reg [31:0] 		delay_y_value;
reg [31:0] 		delay_z_value;
reg [31:0] 		tx_pkt_ctrl;
reg [31:0] 		l2f_tx_pkt_ctrl;
reg [31:0]		rx_ckr_sts ;
reg [31:0]		linkup_sts ;
reg [31:0]		axist_ctrl ;
reg [1:0]		csr_patgen_en_r1;
reg [1:0]		f2l_csr_patgen_en_r1;
reg [1:0]		chkr_done_r1;
wire 			chkr_done_rs;
`ifdef AXIST_DUAL
reg [1:0]		f2l_chkr_done_r1;
wire 			f2l_chkr_done_rs;
reg [31:0]		f2l_rx_ckr_sts ;
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
		csr_patgen_en_r1		<= 'b0;
	end 
	else
	begin
		csr_patgen_en_r1		<= {csr_patgen_en_r1[0],tx_pkt_ctrl[0]};
	end
end

assign csr_patgen_en = (tx_pkt_ctrl[0] & ~csr_patgen_en_r1[0]) | (csr_patgen_en_r1[0] & ~ csr_patgen_en_r1[1]);

always@(posedge clk)
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
				// delay_x_value	<= 32'd12 ;
				// delay_y_value	<= 32'd32 ;
				// delay_z_value	<= 32'd8000;
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
				l2f_tx_pkt_ctrl	<= l2f_tx_pkt_ctrl;
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
			REG_TX_PKT_CTRL_ADDR:
			begin
				rd_datain		<= tx_pkt_ctrl;
				rd_dvalid		<= 1'b1;
			end
			REG_RX_CKR_STS_ADDR:
			begin
				rd_datain		<= rx_ckr_sts;
				rd_dvalid		<= 1'b1;
			end
			REG_LINKUP_STS_ADDR:
			begin
				rd_datain		<= linkup_sts;
				rd_dvalid		<= 1'b1;
			end
			`ifdef AXIST_DUAL
			  REG_F2L_RX_CKR_STS_ADDR:
			  begin
			  	rd_datain		<= f2l_rx_ckr_sts;
			  	rd_dvalid		<= 1'b1;
			  end
			  REG_F2L_TX_PKT_CTRL_ADDR:
			  begin
			  	rd_datain		<= l2f_tx_pkt_ctrl;
			  	rd_dvalid		<= 1'b1;
			  end
			`endif
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

	assign rx_ckr_sts 		= {12'h000,~align_error,1'b0,chkr_pass};
	assign linkup_sts		= {12'h000, fllr_rx_online, fllr_tx_online, ldr_rx_online, ldr_tx_online};
    assign csr_cntuspatt_en = tx_pkt_ctrl[14];                          
    `ifdef AXIST_DUAL
	  assign f2l_rx_ckr_sts 		= {12'h000,~f2l_align_error,1'b0,f2l_chkr_pass};
	  assign f2l_csr_cntuspatt_en 	=   l2f_tx_pkt_ctrl[14];                          
	`endif
endmodule                         
                                  
