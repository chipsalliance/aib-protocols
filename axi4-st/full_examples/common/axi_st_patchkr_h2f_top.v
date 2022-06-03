// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: AXIST Dual half2full pattern checker
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
module axi_st_patchkr_h2f_top #(parameter PATGEN_MODE = 1, parameter PATCHKR_MODE = 1)
(

	input 										rdclk ,
	input 										wrclk ,
	input 										rst_n ,
	input 										patchkr_en ,
	input 	[8:0]								patgen_cnt ,
	input	[(PATGEN_MODE* 40)-1 :0] 			patgen_din,
	input										patgen_din_wr,
	input 										cntuspatt_en,
	output 										chkr_fifo_full,
	input										axist_valid,
	input 	[(PATCHKR_MODE* 256)-1  :0]			axist_rcv_data,
	output										axist_tready,
	
	output reg [1:0]							patchkr_out

);

	parameter AXIST_NUM_CHNL  = 7; 
	
	wire 						  rx_fifo_empty;
	reg  						  rx_fifo_rd_en;
	reg  						  patchkr_start;
	reg  						  patchkr_done;
	reg  						  rx_fifo_empty_r2;
	reg  						  rx_fifo_empty_r1;
	wire [(PATGEN_MODE*256)-1:0]  fifo_rx_dout;
	wire [(PATGEN_MODE*256)-1:0]  chkr_fifo_dout;
	wire 						  chkr_fifo_empty;
	
	reg [8:0]					  rd_cnt;
	reg [8:0]					  patgen_cnt_r1;
	reg [8:0]					  patgen_cnt_r2;
	reg [8:0]					  err_count;
	reg							  rx_fifo_rd_en_r1;
	reg							  chkr_fifo_rd_en;
	reg							  cntuspatt_en_r2;
	reg							  cntuspatt_en_r1;
	wire						  cntuspatt_en_fe;
	wire						  cntuspatt_en_re;
	wire 						  chkr_full;
	wire 						  rcv_fifo_wrfull;
	
	wire [511:0]				  patgen_data_in;
	reg  [511:0]				  axist_rcv_fifo_din;
	reg  [1:0]					  axist_rx_fifo_din_wr;
	wire 						  axist_rx_fifo_wr;
		
	wire 						  ff_1, q_out;
	reg 						  q, q1, q2, q3;
	
	assign rx_fifo_rd_en = ~rx_fifo_empty;
	assign axist_tready  = ~rcv_fifo_wrfull & ~chkr_full & axist_valid ;
	
	assign chkr_fifo_full = chkr_full;
		
	asyncfifo #(.FIFO_WIDTH_WID(512),
				.FIFO_DEPTH_WID(512))		
	fifo_fllwr_rcv_data(/*AUTOARG*/
   // Outputs
   .rddata(fifo_rx_dout[(PATGEN_MODE*256)-1:0]), 
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
   .wrdata(axist_rcv_fifo_din), 
   .write_push(axist_rx_fifo_wr ),
   .read_pop(rx_fifo_rd_en), 
   .rd_soft_reset(1'b0), 
   .wr_soft_reset(1'b0)
   );
	
	always@(posedge rdclk)
	begin
		if(!rst_n)
		begin
			rx_fifo_rd_en_r1	<= 2'b00;
		end 
		else
		begin
			rx_fifo_rd_en_r1	<= rx_fifo_rd_en;
		end 
	end 
	
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
		else if(!chkr_fifo_empty && (axist_valid & axist_tready))
		begin
			rd_cnt		<= rd_cnt + 1;
		end
		else if(!chkr_fifo_empty)
		begin
			rd_cnt	<= rd_cnt;
		end
		else
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
		else if((!chkr_fifo_empty && rx_fifo_rd_en_r1) && chkr_fifo_dout[511:0] != fifo_rx_dout[511:0])
			begin
			if(err_count!=9'h1FF)
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
		else if((patchkr_done  && err_count == 8'h000 && patchkr_start == 1'b1))
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
		// // else if(rx_fifo_rd_en && rd_cnt<= patgen_cnt_r2)
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
	
	assign patchkr_done = ~rx_fifo_empty_r2 & rx_fifo_empty_r1 & chkr_fifo_empty;
	
	assign axist_rx_fifo_wr   = (axist_rx_fifo_din_wr == 2'b10) ? 1'b1 : 1'b0;
	
	
	asyncfifo #(.FIFO_WIDTH_WID(512),
				.FIFO_DEPTH_WID(512))		
	fifo_chkr_data(/*AUTOARG*/
   // Outputs
   .rddata(chkr_fifo_dout[(PATGEN_MODE*256)-1:0]), 
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
   .wrdata(patgen_data_in), 
   .write_push(patgen_din_wr),
   .read_pop(chkr_fifo_rd_en), 
   .rd_soft_reset(1'b0), 
   .wr_soft_reset(1'b0)
   );
	
	genvar i;
	
	generate
		for(i=0;i<AXIST_NUM_CHNL - 1;i=i+1) begin 
			assign patgen_data_in[(40*i)+39 : 40*i] = patgen_din[39:0];
			assign patgen_data_in[255:240] = patgen_din[15:0];
			assign patgen_data_in[((40*i)+39)+256 : (40*i)+256] = patgen_din[79:40];
			assign patgen_data_in[511:496] = patgen_din[55:40];
			
		end
	endgenerate

	
always @(posedge rdclk)
begin
	if(!rst_n)
	begin 
		axist_rcv_fifo_din	<= 'b0;
	end
	else if(axist_tready & axist_valid)
	begin
		axist_rcv_fifo_din	<= {axist_rcv_data,axist_rcv_fifo_din[511:256]};
		
	end
end	


always @(posedge rdclk)
begin
	if(!rst_n ||  patchkr_en)
	begin 
		axist_rx_fifo_din_wr	<= 2'b00;
	end
	else if(axist_tready & axist_valid)
	begin
		if(axist_rx_fifo_din_wr > 2'b01)
			axist_rx_fifo_din_wr	<= 2'b01;
		else
			axist_rx_fifo_din_wr	<= axist_rx_fifo_din_wr + 1;
		
	end
	else if(axist_rx_fifo_din_wr == 2'b10)
	begin
		axist_rx_fifo_din_wr	<= 2'b00;
	end
end	
	
endmodule