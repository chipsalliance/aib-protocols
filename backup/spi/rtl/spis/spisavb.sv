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


module spisavb (

// AVMM Interface
input	logic   	s_avmm_rst_n,
input	logic   	s_avmm_clk,

output	logic  	[16:0]	s_avmm0_addr,   	// AVB Channel
output	logic 	[3:0]	s_avmm0_byte_en, // AVB Channel
output	logic		s_avmm0_write,   // AVB Channel
output	logic		s_avmm0_read,   	// AVB Channel
output	logic 	[31:0]	s_avmm0_wdata,   // AVB Channel

input	logic	[31:0]	s_avmm0_rdata,   // AVB Channel
input	logic		s_avmm0_rdatavld,// AVB Channel
input	logic		s_avmm0_waitreq, // AVB Channel

output	logic  	[16:0]	s_avmm1_addr,   	// AVB Channel
output	logic 	[3:0]	s_avmm1_byte_en, // AVB Channel
output	logic		s_avmm1_write,   // AVB Channel
output	logic		s_avmm1_read,   	// AVB Channel
output	logic 	[31:0]	s_avmm1_wdata,   // AVB Channel

input	logic	[31:0]	s_avmm1_rdata,   // AVB Channel
input	logic		s_avmm1_rdatavld,// AVB Channel
input	logic		s_avmm1_waitreq, // AVB Channel

output	logic  	[16:0]	s_avmm2_addr,   	// AVB Channel
output	logic 	[3:0]	s_avmm2_byte_en, // AVB Channel
output	logic		s_avmm2_write,   // AVB Channel
output	logic		s_avmm2_read,   	// AVB Channel
output	logic 	[31:0]	s_avmm2_wdata,   // AVB Channel

input	logic	[31:0]	s_avmm2_rdata,   // AVB Channel
input	logic		s_avmm2_rdatavld,// AVB Channel
input	logic		s_avmm2_waitreq, // AVB Channel

output 	logic 	[31:0]	avb2reg_rdata_q,   // to spis rd_buf
output 	logic 	[31:0]	dbg_bus1,   

input	logic	[31:0]	reg2avb_wdata,   // from spis wr_buf for AVB channel
output	logic   [15:0]	avb2reg_addr, 	// To spis reg to read wr_buf or write to rd_buf from AVB 

// inputs from s_cmd register
input	logic	[7:0] 	avmm_brstlen,  	// Burstlength in DWords
input	logic	[1:0]	avmm_sel,
input	logic	[16:0]	avmm_offset,	// starting offset
input	logic		avmm_transvld,
input	logic		avmm_rdnwr,

output	logic		avmmtransvld_up,
output  logic		avb2reg_read_pulse,

output  logic		avb2reg_write 	// to spis reg
);



localparam STATE_IDLE			= 4'h0;
localparam STATE_CMD			= 4'h1;
localparam STATE_WR_RDSPIREG		= 4'h2;
localparam STATE_WR_WAITREQ		= 4'h3;
localparam STATE_WR_SETNEXT		= 4'h4;
localparam STATE_WR_ENDWR		= 4'h5;
localparam STATE_RD_WAITRDVLD		= 4'h6;
localparam STATE_RD_WAITRDVLD1		= 4'h7;   
localparam STATE_RD_SETNEXT		= 4'h8;
localparam STATE_RD_ENDRD		= 4'h9;


logic  	[16:0]	s_avmm_addr;   	
logic 	[3:0]	s_avmm_byte_en; 
logic		s_avmm_write;   
logic		s_avmm_read;   	
logic 	[31:0]	s_avmm_wdata;   
logic	[31:0]	s_avmm_rdata;   
logic		s_avmm_rdatavld;
logic		s_avmm_waitreq; 

logic [3:0]	cur_st;
logic [3:0]	nxt_st;

logic [7:0]	burstcount;
logic [15:0]	wrbuf_addr;
logic [15:0]	rdbuf_addr;
logic 		avmm_read;
logic		avmm_write;
logic [31:0]	avmm_wdata;


logic [16:0]	avmm_addr;
logic [16:0]	avmm_addr_d1;

logic		avmmtransvld_up_int;

//Generate a avmm_transvld pulse to start the state machine
logic		avmm_transvld_d1;
logic		avmm_transvld_pulse;
logic           avb2reg_read;



assign dbg_bus1[31:0] = ({{12{1'b0}},cur_st,burstcount,avmm_brstlen}); 

always_ff @(posedge s_avmm_clk or negedge s_avmm_rst_n) 
	if (~s_avmm_rst_n)
           avmm_transvld_d1 <= 1'b0;
	else 
	   avmm_transvld_d1 <= avmm_transvld;

assign avmm_transvld_pulse = avmm_transvld & ~avmm_transvld_d1;


//Generate a read pulse which will be used to pop the wbuf_fifo for read
logic		avb2reg_read_d1;
always_ff @(posedge s_avmm_clk or negedge s_avmm_rst_n) 
	if (~s_avmm_rst_n)
           avb2reg_read_d1 <= 1'b0;
	else 
	   avb2reg_read_d1 <= avb2reg_read;

assign avb2reg_read_pulse = avb2reg_read & ~avb2reg_read_d1;



assign avb2reg_write 	= (((cur_st == STATE_RD_WAITRDVLD1) | (cur_st == STATE_RD_WAITRDVLD)) &
                            (s_avmm_rdatavld == 1'b1)) ? 1'b1 : 1'b0; //m_avmm_write to rd_buf;

assign avb2reg_rdata_q	= s_avmm_rdata;

assign avb2reg_read	= ((cur_st == STATE_WR_RDSPIREG) | 
                           (cur_st == STATE_WR_WAITREQ)) ? 1'b1 : 1'b0; //m_avmm_read from wr_buf;

assign avmm_write	= ((cur_st == STATE_WR_WAITREQ)) ? 1'b1 : 1'b0; //m_avmm_read from wr_buf;
assign avmm_read 	= ((cur_st == STATE_RD_WAITRDVLD)) ? 1'b1 : 1'b0; //m_avmm_read from wr_buf;

always_ff @(posedge s_avmm_clk or negedge s_avmm_rst_n) begin
	if (~s_avmm_rst_n) begin           
	   avmm_addr_d1  <= 17'b0;
	end
 	else begin
 	   avmm_addr_d1  <= avmm_addr;
  	end
 end
	
assign s_avmm_addr	= (avmm_write | avmm_read) ? avmm_addr : 17'b0;

assign s_avmm_wdata	= avmm_wdata;
assign s_avmm_byte_en	= 4'b1111;
assign s_avmm_write	= avmm_write; 
assign s_avmm_read	= avmm_read;



//select avmm interface based on avmm_sel

always_comb begin
s_avmm0_addr 	= 'b0;
s_avmm0_byte_en	= 'b0;
s_avmm0_write 	= 1'b0;
s_avmm0_read 	= 1'b0;
s_avmm0_wdata 	= 'b0;
s_avmm1_addr 	= 'b0;
s_avmm1_byte_en	= 'b0;
s_avmm1_write 	= 1'b0;
s_avmm1_read 	= 1'b0;
s_avmm1_wdata 	= 'b0;
s_avmm2_addr 	= 'b0;
s_avmm2_byte_en	= 'b0;
s_avmm2_write 	= 1'b0;
s_avmm2_read 	= 1'b0;
s_avmm2_wdata   = 'b0;
case(avmm_sel)
 2'b00: begin
	s_avmm0_addr 	= s_avmm_addr;
	s_avmm0_byte_en	= s_avmm_byte_en;
	s_avmm0_write 	= s_avmm_write;
	s_avmm0_read 	= s_avmm_read;
	s_avmm0_wdata 	= s_avmm_wdata;
 end

 2'b01: begin
	s_avmm1_addr 	= s_avmm_addr;
	s_avmm1_byte_en	= s_avmm_byte_en;
	s_avmm1_write 	= s_avmm_write;
	s_avmm1_read 	= s_avmm_read;
	s_avmm1_wdata 	= s_avmm_wdata;
 end
	
 2'b10: begin
	s_avmm2_addr 	= s_avmm_addr;
	s_avmm2_byte_en	= s_avmm_byte_en;
	s_avmm2_write 	= s_avmm_write;
	s_avmm2_read 	= s_avmm_read;
	s_avmm2_wdata 	= s_avmm_wdata;
 end

 default: begin
	s_avmm0_addr 	= s_avmm_addr;
	s_avmm0_byte_en	= s_avmm_byte_en;
	s_avmm0_write 	= s_avmm_write;
	s_avmm0_read 	= s_avmm_read;
	s_avmm0_wdata 	= s_avmm_wdata;
 end
endcase
end


//select avmm interface based on avmm_sel
always_comb begin
s_avmm_rdata 	= 32'b0;
s_avmm_rdatavld =  1'b0;
s_avmm_waitreq 	=  1'b1;
case(avmm_sel)
 2'b00: begin
	s_avmm_rdata 	= s_avmm0_rdata;
	s_avmm_rdatavld = s_avmm0_rdatavld;
	s_avmm_waitreq 	= s_avmm0_waitreq;
 end

 2'b01: begin
	s_avmm_rdata 	= s_avmm1_rdata;
	s_avmm_rdatavld = s_avmm1_rdatavld;
	s_avmm_waitreq 	= s_avmm1_waitreq;
 end
	
 2'b10: begin
	s_avmm_rdata 	= s_avmm2_rdata;
	s_avmm_rdatavld = s_avmm2_rdatavld;
	s_avmm_waitreq 	= s_avmm2_waitreq;
 end

 default: begin
	s_avmm_rdata 	= 32'b0;
	s_avmm_rdatavld =  1'b0;
	s_avmm_waitreq 	=  1'b0;
 end
endcase
end

always_ff @(posedge s_avmm_clk or negedge s_avmm_rst_n) begin
	if (~s_avmm_rst_n)           
	   cur_st		<= STATE_IDLE;
	else 
	   cur_st		<= nxt_st;
 	end
	
	
always_ff @(posedge s_avmm_clk or negedge s_avmm_rst_n) begin
	if (~s_avmm_rst_n)  begin
	   burstcount		<= 'b0;
	   wrbuf_addr		<= 16'h0200; 	// starting address
	   rdbuf_addr		<= 16'h1000; 	// starting address
	   avmm_addr		<= 'b0;
	   avb2reg_addr		<= 'b0;
	   avmm_wdata		<= 'b0;
	end
	else if (cur_st == STATE_CMD) begin
	   avmm_addr		<= avmm_offset;
	    if (avmm_rdnwr == 1'b0) begin
		avb2reg_addr 	<= wrbuf_addr;  // AVB Chnl write, read wbuf for write data
 	        burstcount 	<= (avmm_brstlen - 1);
            end
	    else begin 
	        avb2reg_addr	<= rdbuf_addr;	// AVB Chnl Read, write read data to rbuf
 	        burstcount 	<= (avmm_brstlen);
            end
	end
	else if (cur_st == STATE_WR_RDSPIREG) begin
	   avmm_wdata		<= reg2avb_wdata;
	end
	else if ((cur_st == STATE_WR_SETNEXT)  & 
                (burstcount != 8'b0)) begin 
	   burstcount		<= burstcount - 1'b1;
	   avmm_addr		<= (avmm_addr + 4'b0100);
	end
	else if (((cur_st == STATE_RD_WAITRDVLD1) | (cur_st == STATE_RD_WAITRDVLD))  & 
                (burstcount != 8'b0) & s_avmm_rdatavld) begin 
	   burstcount		<= burstcount - 1'b1;
	   avmm_addr		<= (avmm_addr + 4'b0100);
	end
	else if (cur_st == STATE_IDLE) begin 
	   burstcount		<= 'b0;
	   wrbuf_addr		<= 16'h0200; 	// starting address
	   rdbuf_addr		<= 16'h1000; 	// starting address
	   avmm_addr		<= 'b0;
	   avb2reg_addr		<= 'b0;
	   avmm_wdata		<= 'b0;
	end
end   

assign avmmtransvld_up_int = (avmm_transvld & ((cur_st == STATE_WR_ENDWR) | (cur_st == STATE_RD_ENDRD))) 
                         ?  1'b1 : 1'b0;

assign avmmtransvld_up = avmmtransvld_up_int;
	
       
	

always_comb begin
	case (cur_st)
	STATE_IDLE	: nxt_st = (avmm_transvld_pulse) ?  STATE_CMD : STATE_IDLE ; 

	STATE_CMD	: nxt_st = (avmm_rdnwr == 1'b0) ? STATE_WR_RDSPIREG : 
				   (avmm_rdnwr == 1'b1) ? STATE_RD_WAITRDVLD  :
							  STATE_IDLE ;

	STATE_WR_RDSPIREG	: nxt_st = STATE_WR_WAITREQ; 



	STATE_WR_WAITREQ	: nxt_st = (s_avmm_waitreq == 1'b1) ? STATE_WR_WAITREQ : 
					                      STATE_WR_SETNEXT;

	STATE_WR_SETNEXT	: nxt_st = (burstcount == 8'b0) ? STATE_WR_ENDWR : 
				                                  STATE_WR_RDSPIREG;
										
	STATE_WR_ENDWR	: nxt_st = STATE_IDLE;


	STATE_RD_WAITRDVLD	: nxt_st =  (s_avmm_waitreq == 1'b1) ? STATE_RD_WAITRDVLD :
                                            (s_avmm_rdatavld == 1'b1) ? STATE_RD_SETNEXT  :
									STATE_RD_WAITRDVLD1 ;


	STATE_RD_WAITRDVLD1	: nxt_st =  (s_avmm_rdatavld == 1'b0) ? STATE_RD_WAITRDVLD1 :
									STATE_RD_SETNEXT   ;

	STATE_RD_SETNEXT	: nxt_st =  (burstcount == 8'h0) ? STATE_RD_ENDRD :
 								   STATE_RD_WAITRDVLD ;

	STATE_RD_ENDRD	: nxt_st = STATE_IDLE;


	default	: nxt_st = STATE_IDLE;

	endcase
end

endmodule
			    		

	










