// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: AXIST valid control
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module axi_st_wr_ctrl (
	
	input 		clk,
	input 		rst_n,
	input 		fifo_empty,
	output wire	fifo_rden,
	input 		axist_rdy,
	output reg	axist_valid

);

	reg  [3:0]		fifo_ctrl_r1;
	reg  [3:0]		fifo_ctrl_r2;
	reg  [3:0]		fifo_ctrl_r3;
	reg 			fifo_empty_r1;
	reg 			fifo_empty_r2;
	wire 			fifo_empty_fedge;
	wire 			rd_nxt_data;
	
	always@(posedge clk)
	begin
		if(!rst_n) 
		begin
			fifo_empty_r1	<= 1'b0;
			fifo_empty_r2   <= 1'b0;
		end
		else
		begin
			fifo_empty_r1	<= fifo_empty;
		    fifo_empty_r2   <= fifo_empty_r1;
		end	
	end 
		assign fifo_empty_fedge = fifo_empty_r2 & ~fifo_empty_r1;
	
	always@(posedge clk)
	begin
		if(!rst_n) 
		begin
			fifo_ctrl_r1 <= 'b0;
		end
		else
		begin
			// fifo_ctrl_r1 <= {1'b0,~fifo_empty,(fifo_empty_fedge||axist_rdy),1'b0};
			fifo_ctrl_r1 <= {1'b0,~fifo_empty,(fifo_empty_fedge),1'b0};
			// fifo_ctrl_r1 <= {1'b0,~fifo_empty,(fifo_empty_fedge||rd_nxt_data),1'b0};
		end	
	end 

	always@(posedge clk)
	begin
		if(!rst_n) 
		begin
			fifo_ctrl_r2 <= 'b0;
		end
		else
		begin
			fifo_ctrl_r2 <= {1'b0,rd_nxt_data,fifo_ctrl_r1[2:1]};
		end	
	end 
	
	always@(posedge clk)
	begin
		if(!rst_n) 
		begin
			fifo_ctrl_r3 <= 'b0;
		end
		else
		begin
			// fifo_ctrl_r3 <= {1'b0,fifo_ctrl_r2[3:1]};
			fifo_ctrl_r3 <= {1'b0,fifo_ctrl_r2[2:0]};
		end	
	end 

	
	always@(posedge clk)
	begin
		if(!rst_n) 
		begin
			axist_valid <= 'b0;
		end 
		else if(axist_valid == 1'b1 && axist_rdy == 1'b0)
        begin
            axist_valid     <= axist_valid;
        end
		else
			axist_valid	<= fifo_rden;
	end
	
	// always@(posedge clk)
	// begin
		// if(!rst_n) 
		// begin
			// axist_valid <= 'b0;
		// end
		// // else if(fifo_ctrl_r3[1:0]==2'b11)
		// else if(fifo_rden)
		// begin
			// axist_valid <= 1'b1;
		// end
		// else if(axist_rdy && fifo_empty)
		// begin
			// axist_valid <= 1'b0;
		// end
	// end 

	// assign axist_valid	= (fifo_ctrl_r3[1:0]==2'b11 || fifo_ctrl_r3[2:1]==2'b11) & ~fifo_empty_r1 & ~fifo_empty_r2;

	// assign axist_valid = (fifo_ctrl_r3[1:0] == 2'b11) ? 1'b1 : (axist_rdy==1'b1) ? 1'b0: axist_valid ;
	
	assign rd_nxt_data = axist_valid & axist_rdy;

	assign fifo_rden = ((fifo_ctrl_r2[1:0]==2'b11 || (fifo_ctrl_r2[1] & rd_nxt_data))&& fifo_empty==1'b0) ? 1'b1:1'b0;

	// fifo_ctrl_r1 <= {fifo_empty_fedge,~fifo_empty,2'b0};

endmodule