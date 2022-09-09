// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: Flits data checker 
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ps/1ps
module data_checker(
	input 					clk,
	input					reset_n,

	input 					wr_rd_done,
	input 					die_a_rwd_valid,
	input [527:0]				die_a_rwd_data,

	input 					die_a_drs_valid,
	input [527:0]				die_a_drs_data,

	output reg				data_error,
	output reg [1:0]			test_done

);

wire 						drs_fifo_rd_en;
wire 						rwd_fifo_rd_en;
wire 						rwd_fifo_empty;
wire 						drs_fifo_empty;
wire	[511:0] 				rwd_fifo_rdata;
wire	[511:0] 				drs_fifo_rdata;
	
reg 						rwd_fifo_rd_en_r;
reg 						drs_fifo_rd_en_r;

assign rwd_fifo_rd_en 	= ~rwd_fifo_empty & wr_rd_done;
assign drs_fifo_rd_en 	= ~drs_fifo_empty & wr_rd_done;


asyncfifo #(.FIFO_WIDTH_WID(512),
				.FIFO_DEPTH_WID(64))		
	rwd_fifo(/*AUTOARG*/
   // Outputs
   .rddata(rwd_fifo_rdata), 
   .rd_numfilled(), 
   .wr_numempty(), 
   .wr_full(), 
   .rd_empty(rwd_fifo_empty),
   .wr_overflow_pulse(), 
   .rd_underflow_pulse(),
   // Inputs
   .clk_write(clk), 
   .rst_write_n(reset_n), 
   .clk_read(clk), 
   .rst_read_n(reset_n), 
   .wrdata(die_a_rwd_data[511:0]), 
   .write_push(die_a_rwd_valid),
   .read_pop(rwd_fifo_rd_en), 
   .rd_soft_reset(1'b0), 
   .wr_soft_reset(1'b0)
   );

asyncfifo #(.FIFO_WIDTH_WID(512),
				.FIFO_DEPTH_WID(64))		
	drs_fifo(/*AUTOARG*/
   // Outputs
   .rddata(drs_fifo_rdata), 
   .rd_numfilled(), 
   .wr_numempty(), 
   .wr_full(), 
   .rd_empty(drs_fifo_empty),
   .wr_overflow_pulse(), 
   .rd_underflow_pulse(),
   // Inputs
   .clk_write(clk), 
   .rst_write_n(reset_n), 
   .clk_read(clk), 
   .rst_read_n(reset_n), 
   .wrdata(die_a_drs_data[511:0]), 
   .write_push(die_a_drs_valid),   
   .read_pop(drs_fifo_rd_en), 
   .rd_soft_reset(1'b0), 
   .wr_soft_reset(1'b0)
   );

	always@(posedge clk or negedge reset_n)
	begin
		if(!reset_n)
		begin
			data_error		<= 1'b0;
		end
		else if(rwd_fifo_rd_en_r & drs_fifo_rd_en_r) 
		begin
			if(drs_fifo_rdata[255:128] != rwd_fifo_rdata[255:128])
			begin
				data_error	<= 1'b1;
			end
		end
	end
	
	always@(posedge clk or negedge reset_n)
	begin
		if(!reset_n)
		begin
			test_done		<= 2'b0;
		end
		else if(wr_rd_done & rwd_fifo_empty & drs_fifo_empty) 
		begin
			if(data_error == 1'b0)
			begin
				test_done	<= 2'b11;
			end
			else
			begin
				test_done	<= 2'b10;
			end
		end
	end

	always@(posedge clk or negedge reset_n)
	begin
		if(!reset_n)
		begin
			rwd_fifo_rd_en_r 	<= 1'b0;
			drs_fifo_rd_en_r 	<= 1'b0;
		end
		else 
		begin
			rwd_fifo_rd_en_r 	<= rwd_fifo_rd_en;
			drs_fifo_rd_en_r 	<= drs_fifo_rd_en;
		end
	end


endmodule
