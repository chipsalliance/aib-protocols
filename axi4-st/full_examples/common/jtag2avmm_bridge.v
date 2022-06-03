// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: JTAG to AVMM adress decode module
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
module jtag2avmm_bridge (

	input 					clk ,
	input 					rst_n ,
    
	input	[31:0]			master_address,       // width = 32,       master.address
    output	[31:0]			master_readdata,      // width = 32,             .readdata
    input					master_read,          //  width = 1,             .read
    input					master_write,         //  width = 1,             .write
    input	[31:0]			master_writedata,     // width = 32,             .writedata
    output					master_waitrequest,   //  width = 1,             .waitrequest
    output					master_readdatavalid, //  width = 1,             .readdatavalid
    output	[3:0]			master_byteenable,    //  width = 4,             .byteenable
	
	output 	[15:0]			wr_rd_addr,		
	output					wr_en,
	output					rd_en,
	output  [31:0]			wr_data,
	
	input 	[31:0]			rd_datain,
	input					rd_dvalid
	
);

	localparam REG_BASE_ADDR = 16'h5000;
	localparam ECHO_REG_ADDR = 16'h0030;

	reg [31:0]	echo_reg;      
	reg [31:0]	r_address;      
    reg 		r_read;         
    reg 		r_write;        
    reg [31:0]	r_writedata;       
	
	wire 		wr_valid;
	wire 		rd_valid;


always@(posedge clk)
begin
	if(!rst_n) 
	begin
		r_address  		<= 'b0;
		r_read   		<= 'b0;
		r_write    		<= 'b0;
		r_writedata		<= 'b0;
		
	end
	else
	begin
		r_address  		<= master_address;
		r_read   		<= master_read;
		r_write    		<= master_write;
		r_writedata		<= master_writedata;
		
	end
	
end
	assign 	wr_valid 	= (r_address[31:16] == REG_BASE_ADDR && r_write) ? 1'b1 : 1'b0;
	assign 	wr_rd_addr	= (wr_valid || rd_valid) ? r_address[15:0] : 16'h0000;
    assign 	wr_en		= (wr_valid && r_address[15:0] != ECHO_REG_ADDR) ? r_write : 1'b0 ;
    assign 	wr_data 	= r_writedata;
	assign  rd_valid 	= (r_address[31:16] == REG_BASE_ADDR && r_read) ? 1'b1 : 1'b0;
	
	assign 	rd_en					= (rd_valid && r_address[15:0] != ECHO_REG_ADDR) ? r_read : 1'b0;
	assign  master_readdata 		= (rd_valid) ? (r_address[15:0] == ECHO_REG_ADDR) ? echo_reg : rd_datain : 'b0; 
	assign 	master_readdatavalid 	= (rd_valid) ? (r_address[15:0] == ECHO_REG_ADDR) ? 1'b1 : rd_dvalid : 'b0;
	
always@(posedge clk)
begin
	if(!rst_n) 
	begin
		echo_reg	<= 'b0;
	end 
	else if(wr_valid && r_address[15:0] == ECHO_REG_ADDR)
	begin
		echo_reg	<= r_writedata;
	end 
end 


endmodule