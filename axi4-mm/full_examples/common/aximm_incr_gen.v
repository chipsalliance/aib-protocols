// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: Increment generator for AXIST
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////

module aximm_incr_gen #(parameter LEADER_MODE = 1)(

	input 								clk,
	input 								rst_n,
	input 								ena_in,
	input	[(LEADER_MODE*40)-1:0] 		seed_in,
	input 	[7:0]						patgen_cnt,
	input 								cntuspatt_en,
	input 								chkr_fifo_full,
	output 								cntuspatt_wr_en,
	output	[(LEADER_MODE*40)-1:0]		incr_dout 

);
	
	
parameter FULL 		= 4'h1;
parameter HALF 		= 4'h2;
parameter QUATER 	= 4'h3;

reg 				cntuspatt_en_r1;
reg 				gen_en;
wire 				cntspatt_rs;
wire 				cntuspatt_fs;
reg [7:0] 			incr_cnt;
reg [119 : 0] 		r_incrreg;

always@(posedge clk)
begin
	if(!rst_n) 
	begin
		cntuspatt_en_r1		<= 1'b0;
	end 
	else
	begin
		cntuspatt_en_r1 	<= cntuspatt_en;
	end
end 

	assign cntuspatt_fs = cntuspatt_en_r1 & ~cntuspatt_en;
	assign cntspatt_rs  = ~cntuspatt_en_r1 & cntuspatt_en;
	
always@(posedge clk)
begin
	if(!rst_n) 
		begin
			gen_en 		<= 1'b0;
		end
	else if((ena_in || cntuspatt_en_r1))
		begin
			gen_en 		<= 1'b1;
		end
	else if(incr_cnt==patgen_cnt || cntuspatt_fs )
		begin
			gen_en 		<= 1'b0;
		end
end 

always@(posedge clk)
begin
	if(!rst_n) 
		begin
			incr_cnt 		<= 'b0;
		end
	else if(gen_en && !cntuspatt_en)
		begin
			incr_cnt 		<= incr_cnt + 1;
		end
	else if(!gen_en)
		begin
			incr_cnt		<= 'b0;
		end
end 

always@(posedge clk)
begin
	if(!rst_n) 
		begin
			r_incrreg	<= 'b1;	
		end
	else if(ena_in || cntspatt_rs)
		begin
			r_incrreg[(LEADER_MODE*40)-1:0]	<= seed_in;
		end 
	else if(gen_en & !chkr_fifo_full)
		begin
			r_incrreg[(LEADER_MODE*40)-1:0]	<= r_incrreg[(LEADER_MODE*40)-1:0] + 1;
		end
end 

assign incr_dout[(LEADER_MODE*40)-1:0] = r_incrreg[(LEADER_MODE*40)-1:0] ; 

assign cntuspatt_wr_en = (cntuspatt_en ) ? gen_en : 1'b0;
	
endmodule
