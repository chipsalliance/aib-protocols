// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: AXIST Simplex pattern checker
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
module axi_mm_patchkr_top #(parameter AXI_CHNL_NUM = 1 ,parameter LEADER_MODE = 1, parameter FOLLOWER_MODE = 1)
(

	input 						rdclk ,
	input 						wrclk ,
	input 						rst_n ,
	input 						patchkr_en ,
	input 	[7:0]					patgen_cnt ,
	input	[(AXI_CHNL_NUM* 64)-1 :0] 		patgen_din,
	input						patgen_din_wr,
	input 						cntuspatt_en,
	output 						chkr_fifo_full,
	input						axist_valid,
	input 	[(AXI_CHNL_NUM* 64)-1  :0]		axist_rcv_data,
	input						axist_tready,
	
	output reg [1:0]				patchkr_out

);

	
	wire 						rx_fifo_empty;
	reg  						rx_fifo_rd_en;
	reg  						patchkr_start;
	reg  						patchkr_done;
	reg  						rx_fifo_empty_r2;
	reg  						rx_fifo_empty_r1;
	wire [(64*AXI_CHNL_NUM)-1:0] 			fifo_rx_dout;
	wire [(64*AXI_CHNL_NUM)-1:0] 			chkr_fifo_dout;
	wire [(64*AXI_CHNL_NUM)-1:0]			fifo_rx_qout;
	wire 						chkr_fifo_empty;
	
	reg [8:0]					rd_cnt;
	reg [8:0]					patgen_cnt_r1;
	reg [8:0]					patgen_cnt_r2;
	reg [8:0]					err_count;
	reg						chkr_fifo_rd_en;
	reg						cntuspatt_en_r2;
	reg						cntuspatt_en_r1;
	wire						cntuspatt_en_fe;
	wire						cntuspatt_en_re;
	wire 						chkr_full;
	wire 						rcv_fifo_wrfull;
	wire [127:0]					patgen_din_fifo;
	wire [(64*AXI_CHNL_NUM)-1:0]			chkr_fifo_data;
	reg  [1:0]					chkr_fifo_din_wr;
	wire 						chkr_fifo_wr;
	wire 						chkr_fifo_wr_last;
	wire 						ff_1, q_out;
	reg 						q, q1, q2, q3;
	
	assign rx_fifo_rd_en 		  		= ~rx_fifo_empty;
	assign fifo_rx_dout[(64*AXI_CHNL_NUM)-1:0]    	= fifo_rx_qout[(64*AXI_CHNL_NUM)-1:0]; 
	assign chkr_fifo_full 		  		= chkr_full;

	asyncfifo #(.FIFO_WIDTH_WID(64*AXI_CHNL_NUM),
				.FIFO_DEPTH_WID(512))		
	fifo_fllwr_rcv_data(/*AUTOARG*/
   // Outputs
   .rddata(fifo_rx_qout), 
   .rd_numfilled(), 
   .wr_numempty(), 
   .wr_full(rcv_fifo_wrfull), 
   .rd_empty(rx_fifo_empty),
   .wr_overflow_pulse(), 
   .rd_underflow_pulse(),
   // Inputs
   .clk_write(rdclk), 
   .rst_write_n(rst_n), 
   .clk_read(rdclk), 
   .rst_read_n(rst_n), 
   .wrdata(axist_rcv_data), 
   .write_push(axist_valid & axist_tready),
   .read_pop(rx_fifo_rd_en), 
   .rd_soft_reset(1'b0), 
   .wr_soft_reset(1'b0)
   );

	always@(posedge rdclk)
	begin
		if(!rst_n)
		begin
			cntuspatt_en_r1		<= 	1'b0;
			cntuspatt_en_r2		<=	1'b0;
		end
		else
		begin
			cntuspatt_en_r1		<= cntuspatt_en;
			cntuspatt_en_r2		<= cntuspatt_en_r1;
		end
	end
	
	assign cntuspatt_en_fe 	= cntuspatt_en_r2 & ~cntuspatt_en_r1;
	assign cntuspatt_en_re 	= ~cntuspatt_en_r2 & cntuspatt_en_r1;
		
	assign ff_1 = (patchkr_en) ? ~q : q;
	
	always@(posedge rdclk)
	begin
		if(!rst_n)
		begin
			q	<= 1'b0;
		end 
		else 
		begin
			q	<= ff_1;
		end
	end
	
	always@(posedge rdclk)
	begin
		if(!rst_n)
		begin
			q1	<= 1'b0;
			q2	<= 1'b0;
			q3	<= 1'b0;
		end 
		else 
		begin
			q1	<= q;
			q2	<= q1;
			q3	<= q2;
		end
	end

	assign q_out = q3 ^ q2;
	
	always@(posedge rdclk)
	begin
		if(!rst_n)
		begin
			rd_cnt		<= 'b0;
		end 
		else if(!rx_fifo_empty)
		begin
			rd_cnt		<= rd_cnt + 1;
		end
		else if(chkr_fifo_empty)
		begin
			rd_cnt		<= 'b0;
		end
	end
	
	always@(posedge rdclk)
	begin
		if(!rst_n)
		begin
			err_count	<= 'b0;
		end
		else if (/*(rd_cnt > 0 )*/ rx_fifo_rd_en && (chkr_fifo_dout[(64*AXI_CHNL_NUM)-1:0] != fifo_rx_dout[(64*AXI_CHNL_NUM)-1:0] ))
		begin
			if(err_count!=9'h1FF /*&& (chkr_fifo_empty)*/)
				err_count 	<= err_count + 1;
			else
				err_count	<= err_count;
		end
		else if(patchkr_start==1'b0)
		begin
			err_count	<= 'b0;
		end
	end 
	
	always@(posedge rdclk)
	begin
		if(!rst_n)
		begin
			patchkr_start	<= 1'b0;
		end 
		else if(q_out || cntuspatt_en_re)
		begin
			patchkr_start	<= 1'b1;
		end
		else if(patchkr_done)
		begin
			patchkr_start	<= 1'b0;
		end 
	end
	
	always@(posedge rdclk)
	begin
		if(!rst_n)
		begin
			patchkr_out	<= 2'b00;
		end 
		else if((patchkr_done  && err_count == 9'h000 && patchkr_start == 1'b1))
		begin
			patchkr_out	<= 2'b11;
		end
		else if((patchkr_done && patchkr_start == 1'b1))
		begin
			patchkr_out	<= 2'b10;
		end 
		else if(q_out || cntuspatt_en_re)
		begin
			patchkr_out	<= 2'b00;
		end 
	end
	
	// always@(posedge rdclk)
	// begin
		// if(!rst_n)
		// begin
			// chkr_fifo_rd_en	<= 1'b0;
		// end 
// 		else if(rx_fifo_rd_en && rd_cnt<= patgen_cnt_r2)
		// else if(rx_fifo_rd_en && chkr_fifo_empty!=1'b1)
		// begin
			// chkr_fifo_rd_en	<= 1'b1;
		// end
		// else
		// begin
			// chkr_fifo_rd_en	<= 1'b0;
		// end 
	// end 
	
	 assign chkr_fifo_rd_en	= rx_fifo_rd_en & ~chkr_fifo_empty ;
		
	always@(posedge rdclk)
	begin
		if(!rst_n)
		begin
			patgen_cnt_r1	<= 1'b0;
			patgen_cnt_r2	<= 1'b0;
		end 
		else 
		begin
			patgen_cnt_r1	<= patgen_cnt;
			patgen_cnt_r2	<= patgen_cnt_r1;
		end

	end 
	
	always@(posedge rdclk)
	begin
		if(!rst_n)
		begin
			rx_fifo_empty_r1	<= 1'b0;
			rx_fifo_empty_r2	<= 1'b0;
		end 
		else 
		begin
			rx_fifo_empty_r1	<= rx_fifo_empty;
			rx_fifo_empty_r2	<= rx_fifo_empty_r1;
		end

	end 
	
	assign patchkr_done 	 = ~rx_fifo_empty_r2 & rx_fifo_empty_r1 & chkr_fifo_empty;
	assign patgen_din_fifo 	 = patgen_din;
	assign chkr_fifo_dout 	 = chkr_fifo_data;
	assign chkr_fifo_wr   	 = (chkr_fifo_din_wr == 2'b01) ? 1'b1 : 1'b0;
	assign chkr_fifo_wr_last = (chkr_fifo_din_wr == 2'b10 && patgen_din_wr == 1'b0) ? 1'b1 : 1'b0;
	
	asyncfifo #(.FIFO_WIDTH_WID(64*AXI_CHNL_NUM),
				.FIFO_DEPTH_WID(512))		
	fifo_chkr_data(/*AUTOARG*/
   // Outputs
   .rddata(chkr_fifo_data), 
   .rd_numfilled(), 
   .wr_numempty(), 
   .wr_full(chkr_full), 
   .rd_empty(chkr_fifo_empty),
   .wr_overflow_pulse(), 
   .rd_underflow_pulse(),
   // Inputs
   .clk_write(wrclk), 
   .rst_write_n(rst_n), 
   .clk_read(rdclk), 
   .rst_read_n(rst_n), 
   .wrdata(patgen_din), 
   .write_push(patgen_din_wr),
   .read_pop(chkr_fifo_rd_en), 
   .rd_soft_reset(1'b0), 
   .wr_soft_reset(1'b0)
   );

always @(posedge wrclk)
begin
	if(!rst_n || patchkr_en || chkr_fifo_wr_last)
	begin 
		chkr_fifo_din_wr	<= 2'b00;
	end
	else if(patgen_din_wr)
	begin
		if(chkr_fifo_din_wr > 2'b01)
			chkr_fifo_din_wr	<= 2'b01;
		else
			chkr_fifo_din_wr	<= chkr_fifo_din_wr + 1;
		
	end
end	
	
endmodule
