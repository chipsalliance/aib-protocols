// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: Random data generator - LFSR
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps

module axist_rand_gen #(parameter LEADER_MODE = 1)(

	input 								clk,
	input 								rst_n,
	input 								ena_in,
	input	[(LEADER_MODE*40)-1:0] 		seed_in,
	output	[(LEADER_MODE*40)-1:0]		rand_dout 

);

parameter FULL 		= 4'h1;
parameter HALF 		= 4'h2;
parameter QUATER 	= 4'h3;


//LFSR implemetation for FULL, HALF mode
reg [119 : 0] r_randreg;
reg gen_en;
wire fdbk_reg;

always@(posedge clk)
begin
	if(!rst_n) 
		begin
			r_randreg	<= 'b1;	
			gen_en 		<= 1'b0;
		end
	else if(ena_in)
		begin
			gen_en 		<= 1'b1;
		end
	else if({r_randreg[(LEADER_MODE*40)-1:1],fdbk_reg}==seed_in && gen_en==1'b1)
		begin
			gen_en 		<= 1'b0;
			r_randreg	<= 'b0;
		end 
end


always@(posedge clk)
begin
	if(!rst_n) 
		begin
			r_randreg	<= 'b1;	
		end
	else if(ena_in)
		begin
			r_randreg[(LEADER_MODE*40)-1:0]	<= seed_in;
		end 
	else if(gen_en)
		begin
			r_randreg[(LEADER_MODE*40)-1:0]	<= {r_randreg[(LEADER_MODE*40)-2:0],fdbk_reg};
		end
end 

	assign fdbk_reg  = (LEADER_MODE==FULL)?r_randreg[39] ^ r_randreg[37] ^ r_randreg[20] ^ r_randreg[18] :
					   (LEADER_MODE==HALF)?r_randreg[79] ^ r_randreg[78] ^ r_randreg[42] ^ r_randreg[41] :
					   1'b0;
	assign rand_dout = r_randreg[(LEADER_MODE*40)-1:0];
endmodule