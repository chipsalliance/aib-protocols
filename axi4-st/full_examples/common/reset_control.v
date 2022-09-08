// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: Reset control module
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////

module reset_control (
	input 					clk,	
	input 					rst_n,
	output	reg				reset_out,
	output	reg				reset_out_n
	);
	
	always@(posedge clk or negedge rst_n)
	begin
		if(rst_n == 1'b0)
		begin
			reset_out		<= 1'b1;
			reset_out_n		<= 1'b0;
		end
		else
		begin
			reset_out		<= 1'b0;
			reset_out_n		<= 1'b1;
		end
	end
	
endmodule
