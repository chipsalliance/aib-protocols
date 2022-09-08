// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: AXIMM Folower application
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////
module aximm_follower_app #(		
					parameter AXI_CHNL_NUM = 1,
					parameter DWIDTH = 128, 
					parameter ADDRWIDTH = 32)
	(
	input					  	clk,
	input					  	rst_n,
	output						read_complete,
	output [7:0]					mem_wr_addr,
	output [(64*AXI_CHNL_NUM)-1:0]			mem_wr_data,
	output 						mem_wr_en,
	input  [(64*AXI_CHNL_NUM)-1:0]			mem_rd_data,
	output [7:0]					mem_rd_addr,
	
	output  [(64*AXI_CHNL_NUM)-1:0]			data_in_first,
	output  					data_in_first_valid,
	output  [(64*AXI_CHNL_NUM)-1:0]			data_in_last,
	output  					data_in_last_valid,
	
	input  logic [   3:   0]   			F_user_arid           ,
	input  logic [   2:   0]   			F_user_arsize         ,
	input  logic [   7:   0]   			F_user_arlen          ,
	input  logic [   1:   0]   			F_user_arburst        ,
	input  logic [  ADDRWIDTH-1:   0]   		F_user_araddr         ,
	input  logic               			F_user_arvalid        ,
	output logic               			F_user_arready        ,

	// aw channel
	input  logic [   3:   0]   			F_user_awid           ,
	input  logic [   2:   0]   			F_user_awsize         ,
	input  logic [   7:   0]   			F_user_awlen          ,
	input  logic [   1:   0]   			F_user_awburst        ,
	input  logic [  ADDRWIDTH-1:   0]   		F_user_awaddr         ,
	input  logic               			F_user_awvalid        ,
	output logic               			F_user_awready        ,
	
	// w channel
	input  logic [   3:   0]   			user_wid            ,
	input  logic [ DWIDTH-1 :   0]   		user_wdata          ,
	input  logic [  15:   0]   			user_wstrb          ,
	input  logic               			user_wlast          ,
	input  logic               			user_wvalid         ,
	output logic                 			user_wready         ,
	
	// r channel
	output logic [   3:   0]   			F_user_rid            ,
	output logic [ DWIDTH-1:   0]   		F_user_rdata          ,
	output logic               			F_user_rlast          ,
	output logic [   1:   0]   			F_user_rresp          ,
	output logic               			F_user_rvalid         ,
	input  logic               			F_user_rready         ,
	
	// b channel
	output logic [   3:   0]   			F_user_bid            ,
	output logic [   1:   0]   			F_user_bresp          ,
	output logic               			F_user_bvalid         ,
	input  logic               			F_user_bready         


);
	localparam 		aximem_acc_idle = 1;
	localparam 		aximem_wr_addr 	= 2;
	localparam		aximem_wr_wait  = 3;
	localparam 		aximem_wr_data 	= 4;
	localparam 		aximem_wr_resp 	= 5;
	localparam 		aximem_rd_addr 	= 6;
	localparam 		aximem_rd_wait 	= 7;
	localparam 		aximem_rd_data 	= 8;
	
	parameter 		ADDR_INCR	= 1;
	
	reg [3:0]				aximm_mem_ctrl;
	reg [   2:   0]   			r_user_arsize ;
	reg [   7:   0]   			r_user_arlen  ;
	reg [   1:   0]   			r_user_arburst;
	reg [  ADDRWIDTH-1:   0]   		r_user_araddr;
	
	reg	 [  ADDRWIDTH-1+4:   0]		r_user_awaddr 	;
	reg	 [7:0]				r_user_awlen	;
	reg	 [1:0] 				r_user_awburst	;
	reg	 [2:0]				r_user_awsize	;
	reg  [7:0]				rd_datacnt;
	reg  [7:0]				waddr;
	reg  [7:0]				raddr;
	reg 					mem_wr;
	reg 					r_read_complete;
	reg 					r_user_rid;
	reg 					r_user_rvalid;
	reg  [(64*AXI_CHNL_NUM)-1:0]		r_mem_wr_data;
	reg  [1:0]				r_user_rresp;
	
	
assign F_user_rdata 	= mem_rd_data;
assign F_user_rlast 	= (rd_datacnt==r_user_arlen) ? 1'b1 : 1'b0;
assign F_user_rresp 	= r_user_rresp;
assign F_user_rid	= r_user_rid;
assign read_complete 	= r_read_complete;

assign mem_wr_addr	= waddr;
assign mem_wr_data      = user_wdata;
assign mem_wr_en        = mem_wr;
assign mem_rd_addr	= raddr;

always@(posedge clk)
begin
	if(!rst_n)
	begin
		  r_read_complete <= 'b0; 
	end
	else if(F_user_rlast && r_user_rvalid && F_user_rready)
	begin
		  r_read_complete <= 'b1; 
	end
	else if(F_user_arvalid)
	begin
		  r_read_complete <= 'b0; 
	end
end


	assign F_user_rvalid = r_user_rvalid;

always@(posedge clk)
begin
	if(!rst_n)
	begin
		aximm_mem_ctrl	<= aximem_acc_idle;
		r_user_awaddr 	<= 'b0;
	    r_user_awlen	<= 'b0;
	    r_user_awburst	<= 'b0;
	    r_user_awsize	<= 'b0;
		F_user_awready	<= 1'b0;
		waddr		<= 'b0;
		r_mem_wr_data	<= 'b0;
		mem_wr		<= 'b0;
		F_user_bid   	<= 'b0;
		F_user_bresp    <= 'b0;
		F_user_bvalid   <= 'b0;
		r_user_araddr   <= 'b0;
		r_user_arburst  <= 'b0;
		r_user_arsize   <= 'b0;
		r_user_arlen   	<= 'b0;
		F_user_arready  <= 'b0;
		r_user_rvalid   <= 'b0;
		rd_datacnt   	<= 'b0;
		raddr		<= 'b0;
		user_wready	<= 1'b0;
	end
	else
	begin
		case(aximm_mem_ctrl) 
			aximem_acc_idle :
			begin
			F_user_arready   <= 'b0;
				if(F_user_awvalid==1'b1)
				begin
					aximm_mem_ctrl	<= aximem_wr_addr;
				end
				else if(F_user_arvalid ==1'b1)
				begin
					aximm_mem_ctrl	<= aximem_rd_addr;
				end
			end
			aximem_wr_addr 	:
			begin
				r_user_awaddr 	<= {F_user_awid,F_user_awaddr};
				r_user_awlen	<= F_user_awlen;
				r_user_awburst	<= F_user_awburst;
				r_user_awsize	<= F_user_awsize;
				F_user_awready	<= 1'b1;
				aximm_mem_ctrl	<= aximem_wr_wait;
			end
			aximem_wr_wait	:
			begin
				waddr			<= r_user_awaddr[7:0];
				if(user_wvalid)
				begin
					aximm_mem_ctrl		<= aximem_wr_data;
					user_wready		<= 1'b1;
					mem_wr			<= 1'b1;
					r_mem_wr_data		<= user_wdata;
				end
				else
				begin
					user_wready		<= 1'b0;
					aximm_mem_ctrl		<= aximem_wr_wait;
				end
			end
			aximem_wr_data 	:
			begin
				F_user_awready	<= 1'b0;
					if(user_wvalid && user_wlast)
					begin
						waddr		<= waddr + ADDR_INCR;
						user_wready   	<= 'b1; 
						aximm_mem_ctrl	<= aximem_wr_resp;
						r_mem_wr_data	<= user_wdata;
						F_user_bid   	<= 'h1;
						F_user_bresp    <= 'b0;
						F_user_bvalid   <= 'b1;
					end
					else if(user_wvalid )
					begin
						waddr		<= waddr + ADDR_INCR;
						user_wready   	<= 'b1; 
						aximm_mem_ctrl	<= aximem_wr_data;
						r_mem_wr_data	<= user_wdata;
					end
			end	
			aximem_wr_resp 	:
			begin
				if(F_user_bready)
				begin
					F_user_bvalid   <= 'b0;
					aximm_mem_ctrl	<= aximem_acc_idle;
				end
				else
				begin
					aximm_mem_ctrl	<= aximem_wr_resp;
				end
			end
			aximem_rd_addr 	:
			begin
				r_user_araddr 	<= {F_user_arid,F_user_araddr};
				r_user_arlen	<= F_user_arlen;
				r_user_arburst	<= F_user_arburst;
				r_user_arsize	<= F_user_arsize;
				F_user_arready	<= 1'b1;
				aximm_mem_ctrl	<= aximem_rd_wait;
			end
			aximem_rd_wait :
			begin
				raddr			<= r_user_araddr[7:0];
				aximm_mem_ctrl		<= aximem_rd_data;
				rd_datacnt		<= 'b0;
			end
			aximem_rd_data 	:
			begin
				r_user_rvalid		<= 1'b1;
				r_user_rresp		<= 'b0;
				r_user_rid		<= 'b0;
				if(F_user_rready)
				begin
					raddr		<= raddr + 1;
					rd_datacnt	<= rd_datacnt + 1;
						if(rd_datacnt > r_user_arlen-1)
						begin
							aximm_mem_ctrl	<= aximem_acc_idle;
							r_user_rvalid	<= 1'b0;
						end
				end
			end
		default
		begin
			r_user_rresp		<= 'b0;
			r_user_rid		<= 'b0;
				
		end
		endcase
	end
end 

assign data_in_first 		= (F_user_rready && r_user_rvalid && rd_datacnt == 8'h01) ? mem_rd_data : 'b0;
assign data_in_last  		= (F_user_rready && r_user_rvalid && F_user_rlast ) ? mem_rd_data : 'b0 ;

assign data_in_last_valid  	= (F_user_rready && r_user_rvalid && F_user_rlast ) ? 1'b1 : 1'b0 ;
assign data_in_first_valid 	= (F_user_rready && r_user_rvalid && rd_datacnt == 8'h01 ) ? 1'b1 : 1'b0 ;


endmodule
