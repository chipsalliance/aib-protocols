// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: AXIST dual full2half pattern checker
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ns/1ps
module axi_st_patchkr_top #(parameter PATGEN_MODE = 1, parameter PATCHKR_MODE = 1)
(

	input 						rdclk ,
	input 						wrclk ,
	input 						rst_n ,
	input 						patchkr_en ,
	input 	[8:0]					patgen_cnt ,
	input	[(PATGEN_MODE* 40)-1 :0] 		patgen_din,
	input						patgen_din_wr,
	input 						cntuspatt_en,
	output 						chkr_fifo_full,
	input						axist_valid,
	input 	[(PATCHKR_MODE* 256)-1  :0]		axist_rcv_data,
	input   [1:0]					axist_denable,
	output						axist_tready,
	output  reg [511:0]				data_in_first,
	output  					data_in_first_valid,
	output   reg [511:0]				data_in_last,
	output  					data_in_last_valid,
	
	
	output reg [1:0]				patchkr_out

);

	
	wire 						rx_fifo_empty;
	wire  						rx_fifo_rd_en;
	reg  						patchkr_start;
	wire  						patchkr_done;
	reg  						rx_fifo_empty_r2;
	reg  						rx_fifo_empty_r1;
	wire [511:0] 					fifo_rx_dout;
	wire [513:0]  					chkr_fifo_dout;
	wire 						chkr_fifo_empty;
	
	reg [8:0]					rd_cnt;
	reg [8:0]					patgen_cnt_r1;
	reg [8:0]					patgen_cnt_r2;
	reg [8:0]					err_count;
	reg						rx_fifo_rd_en_r1;
	wire						chkr_fifo_rd_en;
	reg						cntuspatt_en_r2;
	reg						cntuspatt_en_r1;
	wire						cntuspatt_en_fe;
	wire						cntuspatt_en_re;
	wire 						chkr_full;
	wire 						rcv_fifo_wrfull;
	
	reg  [513:0]					chkr_fifo_din;
	reg  [1:0]					chkr_fifo_din_wr;
	wire 						chkr_fifo_wr;
	wire [255:0]					patgen_data_in;
	wire 						ff_1, q_out;
	reg 						q, q1, q2, q3;
	reg  [1023:0]					rcvdata_shift;
	reg  [1023:0]					fifo_dinshift;
	reg  [511:0]					dinshift;
	reg  [3:0]					rcvdata_enable;
	reg  [3:0]					din_crdt;
	reg						data_error;
	reg  [1:0]					credit_update;
	reg						rcv_fifo_wr_en;
	wire [511:0]					rcv_fifo_wr_data;
	reg [3:0]					credit;
	reg						axist_first_dvld_r;
	wire						axist_first_dvld;
	reg						first_dvalid;
	reg						first_rcv_data;
	
	// assign 	rcv_fifo_wr_en		= (din_crdt>1) ? 1'b1 : 1'b0;
	assign  rcv_fifo_wr_data	= fifo_dinshift[511:0];
	assign axist_rcv_valid	= axist_valid & axist_tready;
	
	
	parameter AXIST_NUM_CHNL  = 7; 
	
	assign rx_fifo_rd_en = ~rx_fifo_empty;
	assign axist_tready  = ~rcv_fifo_wrfull & ~chkr_full & axist_valid ;
	
	assign chkr_fifo_full = chkr_full;
		
	asyncfifo #(.FIFO_WIDTH_WID(512),
				.FIFO_DEPTH_WID(512))		
	fifo_fllwr_rcv_data(/*AUTOARG*/
   // Outputs
   .rddata(fifo_rx_dout), 
   .rd_numfilled(), 
   .wr_numempty(), 
   .wr_full(rcv_fifo_wrfull), 
   .rd_empty(rx_fifo_empty),
   .wr_overflow_pulse(), 
   .rd_underflow_pulse(),
   // Inputs
   .clk_write(rdclk), 
   .rst_write_n(rst_n), 
   .clk_read(rdclk), 
   .rst_read_n(rst_n), 
   .wrdata(rcv_fifo_wr_data), 
   .write_push(rcv_fifo_wr_en),
   .read_pop(rx_fifo_rd_en), 
   .rd_soft_reset(1'b0), 
   .wr_soft_reset(1'b0)
   );
	
	always@(posedge rdclk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			rx_fifo_rd_en_r1	<= 2'b00;
		end 
		else
		begin
			rx_fifo_rd_en_r1	<= rx_fifo_rd_en;
		end 
	end 
	
		always@(posedge rdclk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			axist_first_dvld_r	= 1'b0;
		end
		else
		begin
			axist_first_dvld_r	= axist_rcv_valid;

		end
	end

	assign axist_first_dvld = ~axist_first_dvld_r &(axist_rcv_valid);
	assign data_in_first_valid = first_dvalid;
	assign data_in_last_valid = patchkr_done & patchkr_start;
	
		
//	always@(posedge rdclk or negedge rst_n)
//	begin
//		if(!rst_n)
//		begin
//			data_in_last_valid	= 'b0;
//		end
//		else
//		begin
//			data_in_last_valid	= w_data_in_last_valid;
//
//		end
//	end

	always@(posedge rdclk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			data_in_last	= 'b0;
		end
		else
		begin
			data_in_last	= fifo_rx_dout;

		end
	end

	
	always@(posedge rdclk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			data_in_first	= 'b0;
		end
		else if(axist_denable == 2'b01 || axist_denable == 2'b11)
		begin
			data_in_first	= {256'b0,axist_rcv_data[255:0]};
		end
		else if(axist_denable == 2'b10)
		begin
			data_in_first	= {256'b0,axist_rcv_data[511:256]};
		end
	end

	
	always@(posedge rdclk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			first_rcv_data	= 1'b0;
			first_dvalid	= 1'b0;
		end
		else if(axist_first_dvld && first_rcv_data == 1'b0)
		begin
			first_rcv_data	= 1'b1;
			first_dvalid	= 1'b1;
		end
		else if(patchkr_done) 
		begin
			first_rcv_data	= 1'b0;
		end 
		else
		begin
			first_dvalid	= 1'b0;
		end 
	end

	
	always@(posedge rdclk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			cntuspatt_en_r1		<= 	1'b0;
			cntuspatt_en_r2		<=	1'b0;
		end
		else
		begin
			cntuspatt_en_r1		<= cntuspatt_en;
			cntuspatt_en_r2		<= cntuspatt_en_r1;
		end
	end
	
	assign cntuspatt_en_fe 	= cntuspatt_en_r2 & ~cntuspatt_en_r1;
	assign cntuspatt_en_re 	= ~cntuspatt_en_r2 & cntuspatt_en_r1;
	
	assign ff_1 = (patchkr_en) ? ~q : q;
	
	always@(posedge rdclk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			q	<= 1'b0;
		end 
		else 
		begin
			q	<= ff_1;
		end
	end
	
	always@(posedge rdclk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			q1	<= 1'b0;
			q2	<= 1'b0;
			q3	<= 1'b0;
		end 
		else 
		begin
			q1	<= q;
			q2	<= q1;
			q3	<= q2;
		end
	end

	assign q_out = q3 ^ q2;
	
	always@(posedge rdclk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			rd_cnt		<= 'b0;
		end 
		else if(!chkr_fifo_empty && (axist_valid & axist_tready))
		begin
			rd_cnt		<= rd_cnt + 1;
		end
		else if(!chkr_fifo_empty)
		begin
			rd_cnt	<= rd_cnt;
		end
		else
		begin
			rd_cnt		<= 'b0;
		end
	end
	
	always@(posedge rdclk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			err_count	<= 'b0;
		end
		else if((chkr_fifo_dout[513:512] == 2'b11)&&(!chkr_fifo_empty && rx_fifo_rd_en_r1) && 
				 chkr_fifo_dout[255:0] != fifo_rx_dout[255:0] &&
				 chkr_fifo_dout[511:256] != fifo_rx_dout[511:256])
			begin
			if(err_count!=9'h1FF)
				err_count 	<= err_count + 1;
			else
				err_count	<= err_count;
		end
		else if((chkr_fifo_dout[513:512] == 2'b01)&&(!chkr_fifo_empty && rx_fifo_rd_en_r1) && chkr_fifo_dout[255:0] != fifo_rx_dout[255:0])
			begin
			if(err_count!=9'h1FF)
				err_count 	<= err_count + 1;
			else
				err_count	<= err_count;
		end
		else if(patchkr_start==1'b0)
		begin
			err_count	<= 'b0;
		end
	end 
	
	always@(posedge rdclk or negedge rst_n)
	begin
		if(!rst_n)	
		begin
			rcvdata_enable		<= 4'h0;
			rcvdata_shift		<= 'b0;
		end
		else
		begin
			rcvdata_enable		<= {axist_denable,rcvdata_enable[3:2]};
			rcvdata_shift		<= {axist_rcv_data,rcvdata_shift[1023:512]};
		end
	end
	
	always@(posedge rdclk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			data_error				<= 1'b0;
			dinshift			<= 'b0;
			credit_update			<= 'b0;
		end
		else if(axist_valid & axist_tready)
		begin
			if(axist_denable[1:0] == 2'b01)
			begin
				credit_update				<= 2'b01;
					dinshift[255:0]	<= 	axist_rcv_data[255:0];
			end
			else if(axist_denable[1:0] == 2'b10)
			begin
				credit_update				<=  2'b01;
				dinshift[255:0]				<= 	axist_rcv_data[511:256];
			end
			else if(axist_denable[1:0] == 2'b11)
			begin
				credit_update				<= 2'b11;
				dinshift[511:0]					<= axist_rcv_data[511:0];
			end
			else
			begin
				credit_update				<= 2'b00;	
			end 
		end
		else 
		begin
			credit_update				<= 2'b00;	
		end
	end
	
	
	
	always@(posedge rdclk or negedge rst_n)
	begin
		if(!rst_n)
		begin
					rcv_fifo_wr_en			<= 1'b0;
					fifo_dinshift			<= 'b0;
					credit					<= 'b0;
		end 
		else if(credit_update == 2'b01)
		begin
			case (credit)
				4'b0000 :
				begin
					fifo_dinshift[255:0]	<= dinshift[255:0] ;
					credit					<= 4'b0001;
				end
				4'b0001 :
				begin
					fifo_dinshift[511:256]	<= dinshift[255:0] ;
					credit					<= 4'b0000;
					rcv_fifo_wr_en			<= 1'b1;
				end
				4'b0011 :
				begin
					fifo_dinshift[767:512]	<= dinshift[255:0] ;
					credit					<= 4'b0100;
					rcv_fifo_wr_en			<= 1'b0;
				end
				4'b0100 :
				begin
					fifo_dinshift[511:0]	<= {dinshift[255:0],fifo_dinshift[767:512]} ;
					credit					<= 4'b0011;
					rcv_fifo_wr_en			<= 1'b1;
				end
				4'b1100 :
				begin
					fifo_dinshift[767:0]	<= {dinshift[255:0],fifo_dinshift[1023:512]};
					credit					<= 4'b0100;
					rcv_fifo_wr_en			<= 1'b1;
				end
			default
					rcv_fifo_wr_en			<= 1'b0;
			endcase
		end
		else if(credit_update == 2'b11)
		begin
			case (credit)
				4'b0000 :
				begin
					fifo_dinshift[511:0]	<= dinshift ;
					credit					<= 4'b0011;
					rcv_fifo_wr_en			<= 1'b1;
				end
				4'b0001 :
				begin
					fifo_dinshift[767:256]	<= dinshift;
					credit					<= 4'b0100;
					rcv_fifo_wr_en			<= 1'b1;
				end
				4'b0011 :
				begin
					fifo_dinshift[1023:512]	<= dinshift;
					credit					<= 4'b1100;
					rcv_fifo_wr_en			<= 1'b0;
				end
				4'b0100 :
				begin
					fifo_dinshift[767:0]	<= {dinshift,fifo_dinshift[767:512]} ;
					credit					<= 4'b0100;
					rcv_fifo_wr_en			<= 1'b1;
				end
				4'b1100 :
				begin
					fifo_dinshift			<= {dinshift,fifo_dinshift[1023:512]};
					credit					<= 4'b1100;
					rcv_fifo_wr_en			<= 1'b1;
				end
			default
					rcv_fifo_wr_en			<= 1'b0;
			endcase
		end
		else
		begin
			rcv_fifo_wr_en			<= 1'b0;
		
		end
	end
	
	always@(posedge rdclk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			patchkr_start	<= 1'b0;
		end 
		else if(q_out || cntuspatt_en_re)
		begin
			patchkr_start	<= 1'b1;
		end
		else if(patchkr_done)
		begin
			patchkr_start	<= 1'b0;
		end 
	end
	
	always@(posedge rdclk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			patchkr_out	<= 2'b00;
		end 
		else if((patchkr_done  && err_count == 8'h00 && patchkr_start == 1'b1))
		begin
			patchkr_out	<= 2'b11;
		end
		else if((patchkr_done && patchkr_start == 1'b1))
		begin
			patchkr_out	<= 2'b10;
		end 
		else if(q_out || cntuspatt_en_re)
		begin
			patchkr_out	<= 2'b00;
		end 
	end
	
	// always@(posedge rdclk)
	// begin
		// if(!rst_n)
		// begin
			// chkr_fifo_rd_en	<= 1'b0;
		// end 
		// // else if(rx_fifo_rd_en && rd_cnt<= patgen_cnt_r2)
		// else if(rx_fifo_rd_en && chkr_fifo_empty!=1'b1)
		// begin
			// chkr_fifo_rd_en	<= 1'b1;
		// end
		// else
		// begin
			// chkr_fifo_rd_en	<= 1'b0;
		// end 
	// end 
	
	assign chkr_fifo_rd_en	= rx_fifo_rd_en & ~chkr_fifo_empty ;
		
	always@(posedge rdclk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			patgen_cnt_r1	<= 1'b0;
			patgen_cnt_r2	<= 1'b0;
		end 
		else 
		begin
			patgen_cnt_r1	<= patgen_cnt;
			patgen_cnt_r2	<= patgen_cnt_r1;
		end

	end 
	
	always@(posedge rdclk or negedge rst_n)
	begin
		if(!rst_n)
		begin
			rx_fifo_empty_r1	<= 1'b0;
			rx_fifo_empty_r2	<= 1'b0;
		end 
		else 
		begin
			rx_fifo_empty_r1	<= rx_fifo_empty;
			rx_fifo_empty_r2	<= rx_fifo_empty_r1;
		end

	end 
	
	assign patchkr_done = ~rx_fifo_empty_r2 & rx_fifo_empty_r1 & chkr_fifo_empty & patchkr_start;
	
	// assign chkr_fifo_wr   = (chkr_fifo_din_wr == 2'b01 ) ? 1'b1 : 1'b0;
	assign chkr_fifo_wr   = (chkr_fifo_din_wr == 2'b10 ) ? 1'b1 : 1'b0;
	
	asyncfifo #(.FIFO_WIDTH_WID(514),
				.FIFO_DEPTH_WID(512))		
	fifo_chkr_data(/*AUTOARG*/
   // Outputs
   .rddata(chkr_fifo_dout), 
   .rd_numfilled(), 
   .wr_numempty(), 
   .wr_full(chkr_full), 
   .rd_empty(chkr_fifo_empty),
   .wr_overflow_pulse(), 
   .rd_underflow_pulse(),
   // Inputs
   .clk_write(wrclk), 
   .rst_write_n(rst_n), 
   .clk_read(rdclk), 
   .rst_read_n(rst_n), 
   .wrdata(chkr_fifo_din), 
   .write_push(chkr_fifo_wr ),
   .read_pop(chkr_fifo_rd_en), 
   .rd_soft_reset(1'b0), 
   .wr_soft_reset(1'b0)
   );
	
always @(posedge wrclk or negedge rst_n)
begin
	if(!rst_n)
	begin 
		chkr_fifo_din	<= 'b0;
	end
	else if(patgen_din_wr )
	begin
		chkr_fifo_din	<= {2'b11,patgen_data_in,chkr_fifo_din[511:256]};
		
	end
	else if(chkr_fifo_din_wr == 2'b10)
	begin
		chkr_fifo_din	<= {2'b01,patgen_data_in,chkr_fifo_din[511:256]};
	end
	
end	

genvar i;
	
	generate
		for(i=0;i<AXIST_NUM_CHNL - 1;i=i+1) begin 
			assign patgen_data_in[(40*i)+39 : 40*i] = patgen_din[39:0];
			assign patgen_data_in[255:240] = patgen_din[15:0];
		end
	endgenerate

always @(posedge wrclk or negedge rst_n)
begin
	if(!rst_n || patchkr_en )
	begin 
		chkr_fifo_din_wr	<= 2'b00;
	end
	else if(patgen_din_wr)
	begin
		if(chkr_fifo_din_wr > 2'b01)
			chkr_fifo_din_wr	<= 2'b01;
		else
			chkr_fifo_din_wr	<= chkr_fifo_din_wr + 1;
		
	end
	else if(!patgen_din_wr & chkr_fifo_din_wr == 2'b10)
	begin
		chkr_fifo_din_wr	<= 2'b01;
	end
	else if(!patgen_din_wr )
	begin
		chkr_fifo_din_wr	<= 2'b00;
	end
end	
	
endmodule
