// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: AXIST pattern genertor 
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ns/1ps
module axi_st_patgen_top #(parameter LEADER_MODE = 1)(

	input 					wr_clk ,
	input 					rst_n ,
	input 					cntuspatt_en ,
	input 					patgen_en ,
	input	[1:0]				patgen_sel ,
	input 	[8:0]				patgen_cnt ,
	output  [255:0]				data_out_first,
	output  				data_out_first_valid,
	output  [255:0]				data_out_last,
	output  				data_out_last_valid,
	output	[(LEADER_MODE* 256)-1 :0] 	patgen_dout,
	output	[(LEADER_MODE* 256)-1 :0] 	patgen_exp_dout,
	output 					patgen_data_wr,
	input 					chkr_fifo_full,
	output					axist_valid,
	input 					axist_rdy

);

parameter AXIST_NUM_CHNL  = 7;  

wire 						rand_gen_en;
wire 						incr_gen_en;
wire [(LEADER_MODE*40)-1 : 0]			rand_data;
wire [(LEADER_MODE*40)-1 : 0]			incr_data;
wire [119 : 0]					rand_seed_in;
wire [119 : 0]					incr_seed_in;
wire 						cntr_en;
wire 						cntuspatt_wr_en;
wire [(AXIST_NUM_CHNL*40)-1 : 0] 		w_patgen_dout;
wire 						fifo_rd_req;
wire 						fifo_empty;

assign patgen_dout   =  w_patgen_dout[(LEADER_MODE* 256)-1 :0]; 

axist_rand_gen#(.LEADER_MODE(LEADER_MODE)) randomgen(

	.clk(wr_clk),
	.rst_n(rst_n),
	.ena_in(rand_gen_en),
	.seed_in(rand_seed_in[(LEADER_MODE*40)-1:0]),
	.rand_dout(rand_data) 

);


axi_st_wr_ctrl axi_st_ctrl(
	
	.clk(wr_clk),
	.rst_n(rst_n),
	.fifo_empty(fifo_empty),
	.fifo_rden(fifo_rd_req),
	.axist_rdy(axist_rdy),
	.axist_valid(axist_valid)

);

 axist_incr_gen #(.LEADER_MODE(LEADER_MODE)) incr_generator(

	.clk(wr_clk),
	.rst_n(rst_n),
	.ena_in(incr_gen_en),
	.seed_in(incr_seed_in[(LEADER_MODE*40)-1:0]),
	.patgen_cnt(patgen_cnt),
	.cntuspatt_en(cntuspatt_en),
	.chkr_fifo_full(chkr_fifo_full),
	.cntuspatt_wr_en(cntuspatt_wr_en),
	.incr_dout(incr_data) 

);


	reg 				start_cnt;
	reg 				cntuspatt_wr_r1;
	reg [8:0] 			dcnr;
	wire 				fifo_wr_en;
	wire  [(LEADER_MODE*40)-1 : 0] 	fifo_wr_data;
	reg  [(LEADER_MODE*40)-1 : 0] 	fifo_out_data;
	wire [119:0] 			fixed_pattern=120'h111111222222223333333344444444;
	wire [511:0]			w_fifo_out_data;
	wire [511:0]			w_fifo_wr_data;
	reg  [255:0]			axist_fisrt_data;
	reg				axist_valid_r1;
	reg				axist_fisrt_data_valid;
	wire 				first_data;
	reg				axist_rdy_r;	
	reg 				fifo_rd_req_r;
	assign rand_gen_en 	= (patgen_sel == 2'b01 && patgen_en) ? 1'b1 : 1'b0;
	assign incr_gen_en 	= (patgen_sel == 2'b10 && patgen_en) ? 1'b1 : 1'b0;
	assign rand_seed_in 	= 120'hFF_AAAA_5555_3333_6666_1111_7777_9001;
	assign incr_seed_in 	= 120'h11_1111_2222_2222_3333_3333_4444_4444;
	
	assign cntr_en 		= (patgen_en && (patgen_sel!=2'b11)) ? 1'b1 : 1'b0;
	
	
	assign data_out_first 	= axist_fisrt_data;
	assign data_out_first_valid = axist_fisrt_data_valid;
	
	assign data_out_last  		= (axist_valid == 1'b1 && axist_rdy == 1'b1 && fifo_empty ==1'b1) ? patgen_dout : 'b0;
	assign data_out_last_valid  	= (axist_valid == 1'b1 && axist_rdy == 1'b1 && fifo_empty ==1'b1) ? 1'b1 : 'b0;
	
	always@(posedge wr_clk or negedge rst_n)
	begin
	if(!rst_n) 
		begin
			axist_fisrt_data	<= 'b0;
			axist_fisrt_data_valid	<= 1'b0;
		end 
	else if(axist_valid & first_data)
		begin
			axist_fisrt_data	<= patgen_dout;
			axist_fisrt_data_valid	<= 1'b1;
		end 
	else
		begin
			axist_fisrt_data_valid	<= 1'b0;
		end
	end
	
	always@(posedge wr_clk or negedge rst_n)
	begin
	if(!rst_n) 
		begin
			axist_valid_r1		<= 'b0;
		end 
	else 
		begin
			axist_valid_r1		<= axist_valid;
		end 
	end
	
	assign first_data = ~axist_valid_r1 & axist_valid ;
	
	always@(posedge wr_clk or negedge rst_n)
	begin
	if(!rst_n) 
		begin
			cntuspatt_wr_r1		<= 1'b0;
		end 
	else
		begin
			cntuspatt_wr_r1		<= cntuspatt_wr_en;
		end 
	end
	
always@(posedge wr_clk or negedge rst_n)
begin
	if(!rst_n) 
		begin
			dcnr		<= 'b0;
			start_cnt	<= 1'b0;
		end 
	else if(cntr_en)
		begin
			start_cnt	<= 1'b1;
		end 
	else if(dcnr == patgen_cnt)
		begin
			dcnr		<= 'b0;
			start_cnt	<= 1'b0;
		end 
	else if(start_cnt)
		begin
			dcnr 	<= dcnr + 1;
		end 
end 

	assign fifo_wr_en 	= (cntuspatt_en ) ? ((chkr_fifo_full)? 1'b0 : cntuspatt_wr_r1) : (dcnr > 0) ? 1'b1:1'b0;
	assign patgen_data_wr 	= fifo_wr_en;
	assign fifo_wr_data 	= (patgen_sel==2'b01) ? rand_data :
				  (patgen_sel==2'b10 || cntuspatt_en) ? incr_data : 
				  (patgen_sel==2'b00) ? fixed_pattern[39:0]:
				  'b0;
	assign patgen_exp_dout[39:0] =  fifo_wr_data;

	assign w_fifo_wr_data[39:0] = fifo_wr_data;
	
   	asyncfifo #(.FIFO_WIDTH_WID(512),
		    .FIFO_DEPTH_WID(512))		
	fifo_follower_data(/*AUTOARG*/
   // Outputs
   .rddata(w_fifo_out_data), 
   .rd_numfilled(), 
   .wr_numempty(), 
   .wr_full(), 
   .rd_empty(fifo_empty),
   .wr_overflow_pulse(), 
   .rd_underflow_pulse(),
   // Inputs
   .clk_write(wr_clk), 
   .rst_write_n(rst_n), 
   .clk_read(wr_clk), 
   .rst_read_n(rst_n), 
   .wrdata(w_fifo_wr_data), 
   .write_push(fifo_wr_en),
   .read_pop(fifo_rd_req), 
   .rd_soft_reset(1'b0), 
   .wr_soft_reset(1'b0)
   );
	
//assign fifo_out_data = w_fifo_out_data[(LEADER_MODE*40)-1 : 0]; 

	always@(posedge wr_clk or negedge rst_n)
	begin
	if(!rst_n) 
		begin
			fifo_out_data		<= 'b0;
		end 
	//else if(axist_valid & !axist_rdy)
	else if(fifo_rd_req_r)
		begin
			fifo_out_data		<= w_fifo_out_data[(LEADER_MODE*40)-1 : 0];
		end 
	end

	always@(posedge wr_clk or negedge rst_n)
	begin
	if(!rst_n) 
	begin
		axist_rdy_r		<= 'b0;
	end 
	else 
	begin
		axist_rdy_r		<= axist_rdy;
	end 
	end

	always@(posedge wr_clk or negedge rst_n)
	begin
	if(!rst_n) 
	begin
		fifo_rd_req_r		<= 'b0;
	end 
	else 
	begin
		fifo_rd_req_r		<= fifo_rd_req;
	end 
	end

	genvar i;
	
	generate
		for(i=0;i<7;i=i+1) begin 
			assign w_patgen_dout[((i*(LEADER_MODE*40))+((LEADER_MODE*40)-1)):(i*(LEADER_MODE*40))] = (axist_valid & !axist_rdy_r & axist_rdy)? fifo_out_data[(LEADER_MODE*40)-1 : 0] : w_fifo_out_data[(LEADER_MODE*40)-1 : 0];
		end
	endgenerate
	
endmodule
