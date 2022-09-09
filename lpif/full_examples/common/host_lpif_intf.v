// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: LPIF host logic
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps
module host_lpif_intf(

input 					clk,
input					reset_n,
input 					die_a_tx_online,
input					die_a_rx_online,
input 					die_a_align_done,
input 					die_a_align_error,
	
input 					die_a_pl_exit_cg_req,
input 					die_a_pl_trdy,
input 					die_a_pl_valid,
input [511:0]				die_a_pl_data,
input [15:0]				die_a_pl_crc,
input 					die_a_pl_crc_valid,

output reg				die_a_lp_exit_cg_ack,
output reg				die_a_lp_irdy,
output reg				die_a_lp_valid,
output reg [511:0]			die_a_lp_data,

output     [15:0]			die_a_lp_crc_data,
output reg 				die_a_lp_crc_valid,

output					die_a_rwd_valid	,
output	   [527:0]			die_a_rwd_data	,
output	   [527:0]			die_a_drs_data	,
output                  		die_a_drs_valid ,

output 	reg [3:0]			die_a_lp_state_req,
output 	reg				write_done,
output 	reg				read_done,
output 	reg				test_complete,
output 	[1:0]				test_done,

input					flit_wr_en

);

`include "../../common/lpif_ed_defines.v"

reg  [527:0]  mem_rwd [15:0];
reg  [527:0]  mem_req [15:0];

initial 
begin
	mem_rwd[0] =  `M2S_RWD_FLIT_0 ;
	mem_rwd[1] =  `M2S_RWD_FLIT_1 ;
	mem_rwd[2] =  `M2S_RWD_FLIT_2 ;
	mem_rwd[3] =  `M2S_RWD_FLIT_3 ;
	mem_rwd[4] =  `M2S_RWD_FLIT_4 ;
	mem_rwd[5] =  `M2S_RWD_FLIT_5 ;
	mem_rwd[6] =  `M2S_RWD_FLIT_6 ;
	mem_rwd[7] =  `M2S_RWD_FLIT_7 ;
	mem_rwd[8] =  `M2S_RWD_FLIT_8 ;
	mem_rwd[9] =  `M2S_RWD_FLIT_9 ;
	mem_rwd[10] = `M2S_RWD_FLIT_10;
	mem_rwd[11] = `M2S_RWD_FLIT_11;
	mem_rwd[12] = `M2S_RWD_FLIT_12;
	mem_rwd[13] = `M2S_RWD_FLIT_13;
	mem_rwd[14] = `M2S_RWD_FLIT_14;
	mem_rwd[15] = `M2S_RWD_FLIT_15;

end

initial 
begin
	mem_req[0] =  `M2S_REQ_FLIT_0 ;
	mem_req[1] =  `M2S_REQ_FLIT_1 ;
	mem_req[2] =  `M2S_REQ_FLIT_2 ;
	mem_req[3] =  `M2S_REQ_FLIT_3 ;
	mem_req[4] =  `M2S_REQ_FLIT_4 ;
	mem_req[5] =  `M2S_REQ_FLIT_5 ;
	mem_req[6] =  `M2S_REQ_FLIT_6 ;
	mem_req[7] =  `M2S_REQ_FLIT_7 ;
	mem_req[8] =  `M2S_REQ_FLIT_8 ;
	mem_req[9] =  `M2S_REQ_FLIT_9 ;
	mem_req[10] = `M2S_REQ_FLIT_10;
	mem_req[11] = `M2S_REQ_FLIT_11;
	mem_req[12] = `M2S_REQ_FLIT_12;
	mem_req[13] = `M2S_REQ_FLIT_13;
	mem_req[14] = `M2S_REQ_FLIT_14;
	mem_req[15] = `M2S_REQ_FLIT_15;

end


localparam  reset_state  = 1;
localparam  active_state = 2;
localparam  write_rwd	 = 3;
localparam  write_ndr	 = 4;
localparam  read_req	 = 5;
localparam  read_drs	 = 6;

reg [2:0] 			host_state;
reg [4:0] 			flit_cnt;
wire 				phy_ready;
reg 				exit_reset;
wire 				ndr_rcv;
wire 				drs_rcv;
wire 				w_die_a_rwd_valid;
wire 				w_die_a_drs_valid;
reg [527:0]			w_die_a_lp_crc_data;

assign die_a_lp_crc_data  = w_die_a_lp_crc_data[527:512];
assign die_a_rwd_valid    = w_die_a_rwd_valid;
assign die_a_drs_valid    = w_die_a_drs_valid;
assign die_a_rwd_data	  = {w_die_a_lp_crc_data[527:512],mem_rwd[flit_cnt][511:0]};
assign die_a_drs_data	  = {die_a_pl_crc,die_a_pl_data};

assign phy_ready		  = die_a_align_done & die_a_tx_online & die_a_rx_online & ~die_a_align_error;
assign ndr_rcv      	  = die_a_pl_trdy & die_a_pl_valid & die_a_pl_data[60] & (host_state == write_ndr);
assign drs_rcv      	  = die_a_pl_trdy & die_a_pl_valid & die_a_pl_data[72] & (host_state == read_drs);

always@(posedge clk or negedge reset_n)
begin
	if(!reset_n )
	begin
		host_state			<= reset_state;
		die_a_lp_state_req		<= 4'h0;
		die_a_lp_exit_cg_ack		<= 1'b0;
		exit_reset			<= 1'b0;
		die_a_lp_irdy			<= 1'b0;
		die_a_lp_valid			<= 1'b0;
		die_a_lp_crc_valid		<= 1'b0;
		test_complete       		<= 1'b0;
		write_done	        	<= 1'b0;
		read_done	        	<= 1'b0;
		flit_cnt			<= 'b0;
		die_a_lp_data			<= 'b0;
		w_die_a_lp_crc_data		<= 'b0;
	end
	else
	begin
		case (host_state)
			reset_state :
			begin
				if(phy_ready)
				begin
					host_state	<= active_state;
				end
				else
				begin
					host_state	<= reset_state;
				end
			end
			active_state :
			begin
			flit_cnt			<= 5'd0;
			die_a_lp_state_req		<= 4'h1;
				if(die_a_pl_exit_cg_req)
				begin
					die_a_lp_exit_cg_ack	<= 1'b1;
					exit_reset		<= 1'b1;
				end
				else if(!die_a_pl_exit_cg_req)
				begin
					die_a_lp_exit_cg_ack	<= 1'b0;
					if(exit_reset == 1'b1 && flit_wr_en==1'b1)
					begin
						host_state		<= write_rwd;
						test_complete		<= 1'b0;
					end
				end
				 
			end
			write_rwd :	
			begin
				if(die_a_pl_trdy)
				begin
				die_a_lp_irdy			<= 1'b1;
				die_a_lp_valid			<= 1'b1;
				die_a_lp_data       		<= mem_rwd[flit_cnt];
				w_die_a_lp_crc_data		<=	mem_rwd[flit_cnt];
				die_a_lp_crc_valid		<= 1'b1	;
				host_state			<= write_ndr;
				end
				else
				begin
				die_a_lp_irdy			<= 1'b0;
				die_a_lp_valid			<= 1'b0;
				die_a_lp_crc_valid		<= 1'b0;
				die_a_lp_data       		<= 'b0;
				w_die_a_lp_crc_data     	<= 'b0;
				end
			end
		    write_ndr	:
			begin
				die_a_lp_irdy			<= 1'b0;
				die_a_lp_valid			<= 1'b0;
				die_a_lp_crc_valid		<= 1'b0;
				die_a_lp_data       		<= 'b0;
				w_die_a_lp_crc_data     	<= 'b0;
				if(ndr_rcv)
					host_state		<= read_req;
				else
					host_state		<= write_ndr;
				 
			end
		    read_req	:
			begin
				if(die_a_pl_trdy)
				begin
				die_a_lp_irdy			<= 1'b1;
				die_a_lp_valid			<= 1'b1;
				die_a_lp_crc_valid		<= 1'b1;
				die_a_lp_data       		<= mem_req[flit_cnt];
				w_die_a_lp_crc_data		<=	mem_req[flit_cnt];
				host_state			<= read_drs;
				end
				else
				begin
				die_a_lp_irdy			<= 1'b0;
				die_a_lp_valid			<= 1'b0;
				die_a_lp_crc_valid		<= 1'b0;
				die_a_lp_data       		<= 'b0;
				w_die_a_lp_crc_data     	<= 'b0;
				host_state			<= read_req;
				end
			end
		    read_drs	:
			begin
				die_a_lp_irdy			<= 1'b0;
				die_a_lp_valid			<= 1'b0;
				die_a_lp_crc_valid		<= 1'b0;
				die_a_lp_data			<= 'b0;
				w_die_a_lp_crc_data		<= 'b0;
				
				if(drs_rcv)
				begin
					
					if(flit_cnt < 5'd9)
					begin
						host_state		<= write_rwd;
						flit_cnt		<= flit_cnt + 1;
					end
					else 
					begin
						host_state		<= active_state;
						test_complete		<= 1'b1;
					end
				end
				else
				begin
					host_state			<= read_drs;
				end
			end
			default
			begin
				host_state				<= active_state;
			end
		endcase
	end

end

assign w_die_a_rwd_valid = ((host_state==write_ndr) & die_a_pl_trdy & die_a_lp_irdy & die_a_lp_valid);
assign w_die_a_drs_valid = (drs_rcv & (host_state==read_drs));
                                                                
data_checker checker(
.clk(clk),
.reset_n(reset_n),
.wr_rd_done(test_complete),
.die_a_rwd_valid(w_die_a_rwd_valid),
.die_a_rwd_data({w_die_a_lp_crc_data[527:512],mem_rwd[flit_cnt][511:0]}),
.die_a_drs_valid(w_die_a_drs_valid),
.die_a_drs_data({die_a_pl_crc,die_a_pl_data}),
.data_error(),
.test_done(test_done)

);

endmodule
