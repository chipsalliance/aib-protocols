// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: LPIF device logic
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ps/1ps
module device_lpif_intf(

input 					clk,
input					reset_n,
input 					die_b_tx_online,
input					die_b_rx_online,
input 					die_b_align_done,
input 					die_b_align_error,
	
input 					die_b_pl_exit_cg_req,
input 					die_b_pl_trdy,

input [511:0]				die_b_pl_data,
input					die_b_pl_valid,

output reg 				die_b_lp_exit_cg_ack,
output reg 				die_b_lp_irdy,
output reg 				die_b_lp_valid,
output reg  [511:0]			die_b_lp_data,

output 	    [15:0]			die_b_crc_data,
output 	reg 				die_b_crc_data_valid,

output  reg [31:0]			mem_addr,
output  reg [511:0]			mem_data,
output	reg 				mem_wr,
output	reg 				mem_rd,

input 	    [511:0]			mem_rdata,

output 	reg [3:0]			die_b_lp_state_req

);

localparam  reset_state  = 1;
localparam  active_state = 2;
localparam  write_dev	 = 3;
localparam  write_ndr	 = 4;
localparam  read_dev	 = 5;
localparam  read_drs	 = 6;

reg  [2:0] 				device_state;
wire 					phy_ready;
wire [31:0] 				addr;
wire [511:0] 				wr_data;
reg 					exit_reset;
wire 					rwd_flit;
wire 					req_flit;
reg  [4:0]				flit_rcv_cnt;
reg  [527:0]				w_die_b_lp_crc_data;

`include "../../common/lpif_ed_defines.v"

reg  [527:0]  		mem_ndr [15:0];
reg  [527:0]  		mem_drs [15:0];

initial 
begin
	mem_ndr[0] =  `S2M_NDR_FLIT_0 ;
	mem_ndr[1] =  `S2M_NDR_FLIT_1 ;
	mem_ndr[2] =  `S2M_NDR_FLIT_2 ;
	mem_ndr[3] =  `S2M_NDR_FLIT_3 ;
	mem_ndr[4] =  `S2M_NDR_FLIT_4 ;
	mem_ndr[5] =  `S2M_NDR_FLIT_5 ;
	mem_ndr[6] =  `S2M_NDR_FLIT_6 ;
	mem_ndr[7] =  `S2M_NDR_FLIT_7 ;
	mem_ndr[8] =  `S2M_NDR_FLIT_8 ;
	mem_ndr[9] =  `S2M_NDR_FLIT_9 ;
	mem_ndr[10] = `S2M_NDR_FLIT_10;
	mem_ndr[11] = `S2M_NDR_FLIT_11;
	mem_ndr[12] = `S2M_NDR_FLIT_12;
	mem_ndr[13] = `S2M_NDR_FLIT_13;
	mem_ndr[14] = `S2M_NDR_FLIT_14;
	mem_ndr[15] = `S2M_NDR_FLIT_15;

end

initial 
begin
	mem_drs[0] =  `S2M_DRS_FLIT_0 ;
	mem_drs[1] =  `S2M_DRS_FLIT_1 ;
	mem_drs[2] =  `S2M_DRS_FLIT_2 ;
	mem_drs[3] =  `S2M_DRS_FLIT_3 ;
	mem_drs[4] =  `S2M_DRS_FLIT_4 ;
	mem_drs[5] =  `S2M_DRS_FLIT_5 ;
	mem_drs[6] =  `S2M_DRS_FLIT_6 ;
	mem_drs[7] =  `S2M_DRS_FLIT_7 ;
	mem_drs[8] =  `S2M_DRS_FLIT_8 ;
	mem_drs[9] =  `S2M_DRS_FLIT_9 ;
	mem_drs[10] = `S2M_DRS_FLIT_10;
	mem_drs[11] = `S2M_DRS_FLIT_11;
	mem_drs[12] = `S2M_DRS_FLIT_12;
	mem_drs[13] = `S2M_DRS_FLIT_13;
	mem_drs[14] = `S2M_DRS_FLIT_14;
	mem_drs[15] = `S2M_DRS_FLIT_15;

end


assign die_b_crc_data  		= w_die_b_lp_crc_data[527:512];
assign phy_ready		= die_b_align_done & die_b_tx_online & die_b_rx_online & ~die_b_align_error;
assign rwd_flit 		= die_b_pl_trdy & die_b_pl_valid & (device_state == active_state);
assign req_flit 		= die_b_pl_trdy & die_b_pl_valid & (device_state == read_dev);

always@(posedge clk or negedge reset_n)
begin
	if(!reset_n )
	begin
		mem_addr	<= 'b0;
		mem_data	<= 'b0;

	end
	else if(rwd_flit || req_flit)
	begin
		mem_addr	<= die_b_pl_data[91:60];
		mem_data	<= die_b_pl_data[255:128];
	end
end 

always@(posedge clk or negedge reset_n)
begin
	if(!reset_n )
	begin
		device_state			<= reset_state;
		die_b_lp_state_req		<= 4'h0;
		die_b_lp_exit_cg_ack		<= 1'b0;
		exit_reset			<= 1'b0;
		die_b_lp_irdy			<= 1'b0;
		die_b_crc_data_valid		<= 1'b0;
		die_b_lp_valid			<= 1'b0;
		die_b_lp_data       		<= 'b0;
		w_die_b_lp_crc_data    		<= 'b0;
		flit_rcv_cnt	       		<= 'b0;
		mem_rd			       	<= 'b0;
		mem_wr			       	<= 'b0;
	end
	else
	begin
		case (device_state)
			reset_state :
			begin
				if(phy_ready)
				begin
					device_state	<= active_state;
				end
				else
				begin
					device_state	<= reset_state;
				end
			end
			active_state :
			begin
			die_b_lp_state_req		<= 4'h1;
			die_b_lp_irdy			<= 1'b0;
			die_b_lp_valid			<= 1'b0;
			die_b_crc_data_valid		<= 1'b0;
			die_b_lp_data			<= 'b0;
			w_die_b_lp_crc_data		<= 'b0;
				if(die_b_pl_exit_cg_req)
				begin
					die_b_lp_exit_cg_ack	<= 1'b1;
					exit_reset		<= 1'b1;
				end
				else if(!die_b_pl_exit_cg_req)
				begin
					die_b_lp_exit_cg_ack	<= 1'b0;
					if(exit_reset == 1'b1 && rwd_flit == 1'b1)
					begin
						device_state	<= write_dev;
					end
				end
				else
				begin
					die_b_lp_irdy		<= 1'b0;
					die_b_crc_data_valid	<= 1'b0;
					die_b_lp_valid		<= 1'b0;
				end
				 
			end
			write_dev	:
			begin
				mem_wr				<= 1'b1;
				device_state			<= write_ndr;
			end
		    write_ndr	:
			begin
				mem_wr				<= 1'b0;
				if(die_b_pl_trdy)
				begin
					die_b_lp_irdy		<= 1'b1;
					die_b_lp_valid		<= 1'b1;
					die_b_crc_data_valid	<= 1'b1;
					die_b_lp_data       	<= mem_ndr[flit_rcv_cnt];
					w_die_b_lp_crc_data     <= mem_ndr[flit_rcv_cnt];
					device_state		<= read_dev;
				end
				else
				begin
					die_b_lp_irdy		<= 1'b0;
					die_b_lp_valid		<= 1'b0;
					die_b_crc_data_valid	<= 1'b0;
					die_b_lp_data       	<= 'b0;
					w_die_b_lp_crc_data     <= 'b0;
				end
			end
		    read_dev	:
			begin
				if(req_flit)
				begin
					device_state		<= read_drs;
					mem_rd	            	<= 1'b1;
				end
				else
				begin
				die_b_lp_irdy			<= 1'b0;
				die_b_lp_valid			<= 1'b0;
				die_b_crc_data_valid		<= 1'b0;
				die_b_lp_data       		<= 'b0;
				w_die_b_lp_crc_data     	<= 'b0;
				end
			end
		    read_drs	:
			begin
				mem_rd	            		<= 1'b0;
				if(die_b_pl_trdy)
				begin
					die_b_lp_irdy			<= 1'b1;
					die_b_lp_valid			<= 1'b1;
					die_b_crc_data_valid		<= 1'b1;
					die_b_lp_data       		<= {mem_rdata,mem_drs[flit_rcv_cnt][127:0]};
					w_die_b_lp_crc_data     	<= mem_drs[flit_rcv_cnt];
					device_state			<= active_state;
					if(flit_rcv_cnt<5'd15)
						flit_rcv_cnt		<= flit_rcv_cnt + 1;
					else
						flit_rcv_cnt		<= 'b0;
				end
				else
				begin
					die_b_lp_irdy			<= 1'b0;
					die_b_lp_valid			<= 1'b0;
					die_b_crc_data_valid		<= 1'b0;
					die_b_lp_data       		<= 'b0;
					w_die_b_lp_crc_data 		<= 'b0;
				end
				
			end
			default
			begin
				device_state			<= active_state;
			end
		endcase
	end

end

endmodule
