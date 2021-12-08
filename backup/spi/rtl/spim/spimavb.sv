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


module spimavb (

// AVMM Interface
input	logic   	m_avmm_rst_n,
input	logic   	m_avmm_clk,
input	logic  	[16:0]	m_avmm_addr,
input	logic 	[3:0]	m_avmm_byte_en,
input	logic		m_avmm_write,
input	logic		m_avmm_read,
input	logic 	[31:0]	m_avmm_wdata,
output	logic	[31:0]	m_avmm_rdata,
output	logic		m_avmm_rdatavld,
output	logic		m_avmm_waitreq,

input 	logic 	[31:0]	avbreg_rdata,
input 	logic 		avbreg_waitreq,  
input 	logic 		avbreg_rdatavld,
output	logic	[31:0]	avbreg_wdata,
output	logic   [15:0]	avbreg_addr, 	// Only 16 bits required to address m_cmd, wrt_buf, rd_buf
output  logic	[3:0]	avbbyte_en,
output	logic	[31:0]	dbg_bus1,
output  logic		avbreg_write,
output  logic		avbreg_read 
);


localparam STATE_IDLE			= 3'h0;
localparam STATE_WR			= 3'h1;
localparam STATE_WRC			= 3'h2;
localparam STATE_RD			= 3'h3;
localparam STATE_REG_RDVAL		= 3'h4;

logic [2:0]	cur_st;
logic [2:0]	nxt_st;

logic [31:0] 	reg_rdata_w_vld;
logic 		avmm_waitreq;
logic		avmm_rdatavld;

logic  	[16:0]	m_avmm_addr_d1;
logic 	[3:0]	m_avmm_byte_en_d1;
logic 	[31:0]	m_avmm_wdata_d1;

assign dbg_bus1 = ({{29{1'b0}},cur_st});

assign avbreg_write 	= (cur_st == STATE_WR) ? 1'b1 : 1'b0; //m_avmm_write;
assign avbreg_read	= (cur_st == STATE_RD) ? 1'b1 : 1'b0; //m_avmm_read;


always_ff @(posedge m_avmm_clk or negedge m_avmm_rst_n) begin
	if (~m_avmm_rst_n)  begin
           m_avmm_addr_d1     <= 17'b0;
           m_avmm_byte_en_d1  <= 4'b0;
           m_avmm_wdata_d1    <= 32'b0;
           end 
        else begin
           m_avmm_addr_d1     <= m_avmm_addr;
           m_avmm_byte_en_d1  <= m_avmm_byte_en;
           m_avmm_wdata_d1    <= m_avmm_wdata;
           end
end


assign avbreg_wdata	= m_avmm_wdata_d1;
assign avbbyte_en	= m_avmm_byte_en_d1;
assign avbreg_addr	= m_avmm_addr_d1[15:0];	

//These outputs are not registered   
assign m_avmm_waitreq 	= avmm_waitreq;
assign m_avmm_rdatavld 	= avmm_rdatavld;
assign m_avmm_rdata	= reg_rdata_w_vld; // Read data when valid is received (S/M State)


always_ff @(posedge m_avmm_clk or negedge m_avmm_rst_n) begin
	if (~m_avmm_rst_n)  begin
	   cur_st		<= STATE_IDLE;   
	   reg_rdata_w_vld	<= 'b0;
	   avmm_waitreq		<= 1'b1;
	   avmm_rdatavld	<= 1'b0;
	end
	else begin
	   cur_st 		<= nxt_st;
	   avmm_rdatavld	<= (nxt_st == STATE_REG_RDVAL) ? 1'b1 : 1'b0;
	   reg_rdata_w_vld	<= (nxt_st == STATE_REG_RDVAL) ? avbreg_rdata : 32'hdead_beef;
	   avmm_waitreq		<= (nxt_st == STATE_WRC) ? 1'b0 : 
                                   (nxt_st == STATE_RD)  ? 1'b0 : 1'b1; 
	end
end   

always_comb begin
	case (cur_st)

	STATE_IDLE	: nxt_st = (m_avmm_write == 1'b1) ? STATE_WR : 
				   (m_avmm_read) == 1'b1  ? STATE_RD  :
				                    STATE_IDLE  ;

	STATE_WR	: nxt_st = (avbreg_waitreq == 1'b0) ? STATE_WRC : STATE_WR;

	STATE_WRC	: nxt_st = STATE_IDLE;

	STATE_RD	: nxt_st = (avbreg_waitreq == 1'b0) ? STATE_REG_RDVAL : STATE_RD;

	STATE_REG_RDVAL	: nxt_st = (avbreg_rdatavld == 1'b1) ? STATE_IDLE : STATE_REG_RDVAL;

	default : nxt_st = STATE_IDLE;

	endcase
end

endmodule
			    		

	










