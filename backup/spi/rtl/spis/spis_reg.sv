////////////////////////////////////////////////////////////
//
//        Copyright (C) 2021 Eximius Design
//                All Rights Reserved
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Eximius Design
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
//Functional Descript:
//
//
//
////////////////////////////////////////////////////////////



module spis_reg 
(
input	logic		aclk,
input	logic		arst_n,

input	logic	[31:0]	wdata,
input	logic		write,
input	logic		read,
input	logic	[15:0] 	addr,
output	logic	[31:0] 	rdata,


input 	logic		avmmtransvld_up,
input 	logic	[31:0]	s_status_in,
input 	logic	[31:0]	s_diag0_in,
input 	logic	[31:0]	s_diag1_in,
input   logic           load_dbg_bus0,
input   logic           load_dbg_bus1,



input  logic   		wbuf_wr_overflow_sticky,
input  logic   		wbuf_rd_underflow_sticky,
input  logic   		rbuf_wr_overflow_sticky,
input  logic   		rbuf_rd_underflow_sticky,

output  logic   	wbuf_wr_soft_reset,
output  logic   	wbuf_rd_soft_reset,
output  logic   	rbuf_wr_soft_reset,
output  logic   	rbuf_rd_soft_reset,
output  logic           sft_rst_ctrl, 


output	logic	[31:0]	s_cmd,
output	logic	[31:0]	s_status,
output	logic	[31:0]	s_diag0,
output	logic	[31:0]	s_diag1

);

logic		[31:0]	buffer_fifo_status; 
//ES; 9/8 logic		[31:0]	buffer_fifo_ctrl; 
logic		[4:0]	buffer_fifo_ctrl; 
//ES; 9/8 logic		[31:0]	sft_rst_ctrl_reg; 


logic                    we_cmd;
logic                    we_buffer_fifo_ctrl;
logic                    we_buffer_fifo_ctrl_d1;

logic           [2:0] rsvd3;
logic          [26:0] rsvd27;
logic           [3:0] sft_reset_d1;
logic           [3:0] sft_reset_d2;
logic           [3:0] sft_reset_d3;
logic           [3:0] sft_reset_d4;
logic                 wrt_srst_ctrl_d1;

assign wbuf_wr_soft_reset = buffer_fifo_ctrl[0];
assign wbuf_rd_soft_reset = buffer_fifo_ctrl[1];
assign rbuf_wr_soft_reset = buffer_fifo_ctrl[2];
assign rbuf_rd_soft_reset = buffer_fifo_ctrl[3];
assign sft_rst_ctrl       = buffer_fifo_ctrl[4];

//
// write  
// generate write enables for the registers
assign we_cmd    = 	((addr == 16'h0000) & write) ? 1'b1 : 1'b0;


assign we_buffer_fifo_ctrl = 	((addr == 16'h0044) & write) ? 1'b1 : 1'b0;	

assign  rsvd3 = 3'b0;
assign  rsvd27 = 27'b0;

always_ff @(posedge aclk or negedge arst_n)
	if (~arst_n) 
	  	we_buffer_fifo_ctrl_d1 <= 'b0;
 	else 
		we_buffer_fifo_ctrl_d1 <= we_buffer_fifo_ctrl;
			
always_ff @(posedge aclk or negedge arst_n)
	if (~arst_n) 
	  	wrt_srst_ctrl_d1 <= 'b0;
 	else if (we_buffer_fifo_ctrl)
		wrt_srst_ctrl_d1  <= wdata[4];
			
always_ff @(posedge aclk or negedge arst_n)
	if (~arst_n) begin 
	  	sft_reset_d1 <= 4'b0;
	  	sft_reset_d2 <= 4'b0;
	  	sft_reset_d3 <= 4'b0;
	  	sft_reset_d4 <= 4'b0;
               end
 	else begin
		sft_reset_d1 <= {rbuf_rd_soft_reset,rbuf_wr_soft_reset, wbuf_rd_soft_reset,wbuf_wr_soft_reset};
		sft_reset_d2 <= sft_reset_d1;
		sft_reset_d3 <= sft_reset_d2;
		sft_reset_d4 <= sft_reset_d4;
               end
			

// s_status offset 0x0 
always_ff @(posedge aclk or negedge arst_n)
	if (~arst_n) 
	  	s_cmd <= 'b0;
 	else begin
	  if (avmmtransvld_up)
		s_cmd[0] <= 1'b0;
	  else if (we_cmd) 
		s_cmd <= wdata;
	end			
			
// s_status offset 0xC 
always_ff @(posedge aclk or negedge arst_n)
	if (~arst_n) 
	  	s_status <= 'b0;
 	else 
		s_status <= s_status_in;
			
// s_diag0 offset 0x10 
always_ff @(posedge aclk or negedge arst_n)
	if (~arst_n) 
	  	s_diag0 <= 'b0;
 	else if (load_dbg_bus0)
		s_diag0 <= s_diag0_in;
			
// s_diag1 offset 0x14 
always_ff @(posedge aclk or negedge arst_n)
	if (~arst_n) 
	  	s_diag1 <= 'b0;
 	else if (load_dbg_bus1)
		s_diag1 <= s_diag1_in;
			
// wbuf numfilled offset 0x40 
always_ff @(posedge aclk or negedge arst_n)
	if (~arst_n) 
	  	buffer_fifo_status <= 'b0;
 	else 
		buffer_fifo_status <= {28'b0,rbuf_rd_underflow_sticky,rbuf_wr_overflow_sticky,wbuf_rd_underflow_sticky,wbuf_wr_overflow_sticky};

// wbuf numfilled offset 0x44 
always_ff @(posedge aclk or negedge arst_n)
	if (~arst_n) 
	  	buffer_fifo_ctrl <= 5'b0;
 	else if (we_buffer_fifo_ctrl) 
		buffer_fifo_ctrl[3:0] <= wdata[3:0];
 	else if (we_buffer_fifo_ctrl_d1)
                buffer_fifo_ctrl[4]   <= wrt_srst_ctrl_d1; 
        else if (|sft_reset_d4)
                buffer_fifo_ctrl[3:0] <= 4'b0;


// Read
always_comb begin
  rdata = 32'b0;
    if (read) begin
     case (addr) 

       16'h0000  : rdata = {s_cmd[31:24],rsvd3,s_cmd[20:0]}; 
       16'h000c  : rdata = s_status;   // addr 0x4 to 0xC
       16'h0010  : rdata = s_diag0;    // addr 0x8 to 0x10
       16'h0014  : rdata = s_diag1;    // addr 0xC to 0x14


       16'h0040  : rdata = buffer_fifo_status; 
       16'h0044  : rdata = {rsvd27,buffer_fifo_ctrl[4:0]}; 
//       16'h0048  : rdata = sft_rst_ctrl_reg; 

      default   : rdata = 32'hdeadbeef; 
     endcase
    end // if
   end // always


endmodule

 
