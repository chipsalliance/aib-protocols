// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: Tstbench top module 
//
//
// Change log :
// 
/////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps
module top_tb();

parameter CLK_SCALING 		= 4;
parameter WR_CYCLE   		= 1000*CLK_SCALING;
parameter RD_CYCLE   		= 1000*CLK_SCALING;
parameter FWD_CYCLE  		= 1000*CLK_SCALING;
parameter AVMM_CYCLE 		= 4000;
parameter OSC_CYCLE  		= 1000*CLK_SCALING;
parameter TOTAL_CHNL_NUM 	= 24;
parameter DWIDTH 			= 40;
parameter DATAWIDTH 		= 40;
parameter FULL 				= 1;
parameter HALF 				= 2;
parameter CLKL_HALF_CYCLE 	= 500;

reg 				ms_wr_clk;
reg 				ms_rd_clk;
reg 				ms_fwd_clk;
				
reg 				sl_wr_clk;
reg 				sl_rd_clk;
reg 				sl_fwd_clk;
			
reg					avmm_clk;
reg  [5:0]			count;
reg  [255:0]		dout_last;
reg  [255:0]		dout;
reg  [511:0]		data_in;
reg  [255:0]		data_in_last;
reg  [511:0]		chkr_fifo_rcv_data_r1;
wire [255:0]		pat_gen_wr_data;
reg  [255:0]		pat_gen_wr_data_r1;
wire [511:0]		pat_chkr_rcv_data;
wire [511:0]		chkr_fifo_rcv_data;
wire		        pat_chkr_rcv_en  ;
wire		        chkr_fifo_empty  ;
wire		        pat_gen_wr_en  ;
					
reg 				osc_clk;
reg  [31:0]			tb_read_data;       		// width = 32,     
wire [31:0]			tb_master_readdata; 
wire 				tb_master_readdatavalid;	
wire 				pat_gen_wr_valid;
wire 				pat_gen_wr_ready;
wire 				pat_gen_high;

reg  [31:0] 		tb_wr_addr, tb_wrdata;
reg  [3:0] 			mask_reg;
reg 				tb_wren, tb_rden;

reg              	clk_phy;
reg              	clk_p_div2;
reg              	clk_p_div4;
reg              	rst_phy_n;
reg              	tb_w_m_wr_rst_n ;
reg              	tb_w_s_wr_rst_n ;
reg 				flag;

logic [255:0]     	queue_dout [$];

axist_aib_top #(.LEADER_MODE(FULL), 
				.FOLLOWER_MODE(HALF),
				.DATAWIDTH(DATAWIDTH), 
				.TOTAL_CHNL_NUM(TOTAL_CHNL_NUM)) 
axist_aib_dut(
.i_w_m_wr_rst_n(tb_w_m_wr_rst_n),
.i_w_s_wr_rst_n(tb_w_s_wr_rst_n),
.i_wr_addr(tb_wr_addr), 
.i_wrdata(tb_wrdata), 

.rst_phy_n(rst_phy_n),
.clk_phy(clk_phy),
.clk_p_div2(clk_p_div2),
.clk_p_div4(clk_p_div4),

.ms_wr_clk(ms_wr_clk),
.ms_rd_clk(ms_rd_clk),
.ms_fwd_clk(ms_fwd_clk),
            
.sl_wr_clk(sl_wr_clk),
.sl_rd_clk(sl_rd_clk),
.sl_fwd_clk(sl_fwd_clk),

.avmm_clk(avmm_clk), 
.osc_clk(osc_clk), 
.i_wren(tb_wren), 
.i_rden(tb_rden),

.o_tb_patdout(pat_gen_wr_data),
.o_tb_axist_valid(pat_gen_wr_valid),
.o_tb_axist_ready(pat_gen_wr_ready),
.o_master_readdatavalid(tb_master_readdatavalid),
.o_master_readdata(tb_master_readdata)			
);

initial
begin

	ms_wr_clk	= 1'b0;
	ms_rd_clk	= 1'b0;
	ms_fwd_clk	= 1'b0;
	sl_wr_clk	= 1'b0;
	sl_rd_clk	= 1'b0;
	sl_fwd_clk	= 1'b0;
	avmm_clk	= 1'b0;
	osc_clk		= 1'b0;
end

always #(WR_CYCLE/2)   ms_wr_clk   	= ~ms_wr_clk;
always #(RD_CYCLE/2)   ms_rd_clk   	= ~ms_rd_clk;
always #(FWD_CYCLE/2)  ms_fwd_clk  	= ~ms_fwd_clk;
	
always #(WR_CYCLE)     sl_wr_clk   	= ~sl_wr_clk;
always #(RD_CYCLE)     sl_rd_clk   	= ~sl_rd_clk;
always #(FWD_CYCLE/2)  sl_fwd_clk  	= ~sl_fwd_clk;

always #(AVMM_CYCLE/2) avmm_clk 	= ~avmm_clk;
	
always #(OSC_CYCLE/2)  osc_clk  	= ~osc_clk;

always @(posedge ms_wr_clk)
	pat_gen_wr_data_r1		<= pat_gen_wr_data ;
	
always @(posedge sl_rd_clk)
	chkr_fifo_rcv_data_r1	<= chkr_fifo_rcv_data ;

initial
begin
  repeat (5) #(CLKL_HALF_CYCLE);
  forever @(clk_phy)
  begin
    #(CLKL_HALF_CYCLE); clk_phy <= ~clk_phy; clk_p_div2 <= ~clk_p_div2; clk_p_div4 <= ~clk_p_div4;
    #(CLKL_HALF_CYCLE); clk_phy <= ~clk_phy;
    #(CLKL_HALF_CYCLE); clk_phy <= ~clk_phy; clk_p_div2 <= ~clk_p_div2;
    #(CLKL_HALF_CYCLE); clk_phy <= ~clk_phy;
    #(CLKL_HALF_CYCLE); clk_phy <= ~clk_phy; clk_p_div2 <= ~clk_p_div2; clk_p_div4 <= ~clk_p_div4;
    #(CLKL_HALF_CYCLE); clk_phy <= ~clk_phy;
    #(CLKL_HALF_CYCLE); clk_phy <= ~clk_phy; clk_p_div2 <= ~clk_p_div2;
    #(CLKL_HALF_CYCLE); clk_phy <= ~clk_phy;
  end
end

initial
begin
  repeat (10) #(CLKL_HALF_CYCLE);
  rst_phy_n <= 1'b0;                           	// RST is known (active)
  repeat (10) #(CLKL_HALF_CYCLE);
  clk_phy 	<= 1'b0;                             // CLK is known
end


initial
begin
  clk_p_div2 	  = 1'bx;                              // Everything is X
  clk_p_div4 	  = 1'bx;                              // Everything is X
  clk_phy 	 	  = 1'bx;                              // Everything is X
  rst_phy_n  	  = 1'bx;
  tb_w_m_wr_rst_n = 1'bx;
  tb_w_s_wr_rst_n = 1'bx;
  repeat (10) #(CLKL_HALF_CYCLE);
  rst_phy_n 		 = 1'b0;
  tb_w_m_wr_rst_n 	<= 1'b0;                           // RST is known (active)
  tb_w_s_wr_rst_n 	<= 1'b0;                           // RST is known (active)
  repeat (10) #(CLKL_HALF_CYCLE);
  clk_p_div4 		<= 1'b0;                             // CLK is known
  clk_p_div2 		<= 1'b0;                             // CLK is known
  repeat (500) @(posedge clk_phy);
  repeat (1) @(posedge ms_wr_clk);
  tb_w_m_wr_rst_n 	<= 1;                              // Everything is up and running
  repeat (1) @(posedge sl_wr_clk);
  tb_w_s_wr_rst_n 	<= 1;                              // Everything is up and running
  repeat (1) @(posedge clk_phy);
  rst_phy_n 		<= 1'b1;
  $display ("######## Exit Reset",,$time);
end

integer random_seed;
initial
begin
  if (!$value$plusargs("VERILOG_RANDOM_SEED=%h",random_seed))
    if (!$value$plusargs("SEED=%h",random_seed))
      random_seed = 0;

  $display ("Using Random Seed (random_seed) = %0x",random_seed);
  $display ("To reproduce, add:  +VERILOG_RANDOM_SEED=%0x",random_seed);
end

assign pat_gen_wr_en 	  = pat_gen_wr_ready & pat_gen_wr_valid;
assign pat_chkr_rcv_data  = axist_aib_dut.pattern_checker.axist_rcv_data;
assign pat_chkr_rcv_en    = axist_aib_dut.pattern_checker.axist_valid & axist_aib_dut.pattern_checker.axist_tready;
assign pat_gen_high 	  = axist_aib_dut.pat_gen.start_cnt;
assign chkr_fifo_rcv_data = axist_aib_dut.pattern_checker.fifo_fllwr_rcv_data.rddata[511:256];
assign chkr_fifo_empty    = axist_aib_dut.pattern_checker.rx_fifo_empty;
 
initial
begin
	dout 		 = 'b0;
	data_in 	 = 'b0;
	dout_last 	 = 'b0;
	data_in_last = 'b0;
	flag 		 = 'b0;
	tb_wrdata	 = 'b0;
	tb_wren		 = 'b0;
	tb_rden		 = 'b0;
	count 	 	 = 0;
	mask_reg 	 = 0;
	tb_wr_addr 	 = 0;
	tb_read_data = 0;
	
	$display("Wait for AXI STREAM online");
	wait (rst_phy_n == 1'b1);
	repeat (10) @(posedge avmm_clk);
	//Delay X,Y and Z values
	avmm_write(32'h50002000, 32'h0000000C); //Delay X value = 12
	avmm_write(32'h50002004, 32'h00000020); //Delay Y value = 32
	avmm_write(32'h50002008, 32'h00001770); //Delay Z value = 6000
	
	//wait for AIB online
	avmm_read(32'h50001008);
	while (tb_read_data[3:0] != 4'hf)
	begin
		avmm_read(32'h50001008);
	end
	avmm_read(32'h50001008);
	
	//check for AIB online
	if(tb_read_data[3:0]== 4'hF) 
	begin
		$display("\n");
		$display("////////////////////////////////////////////////////////");
		$display("AXI-Stream TX and RX online is high");
		$display("///////////////////////////////////////////////////////\n");
	end
	else $display("AXI-Stream TX/RX is offline\n");
	
	repeat (200) @(posedge ms_wr_clk);
	
	//Random pattern test 
	avmm_write(32'h50001000, 32'h00001005);

	$display("///////////////////////////////////////////////////");
	$display("%0t Random pattern test for 256 data packet ",$time);
	$display("//////////////////////////////////////////////////\n");
	wait ( pat_gen_wr_en == 1'b1);
	@(negedge ms_wr_clk);
	dout 	 = pat_gen_wr_data;
	wait (pat_chkr_rcv_en == 1'b1);
	@(negedge sl_rd_clk);
	data_in  = pat_chkr_rcv_data;
	count 	 = 0;
	$display("Send AXI Stream Packet 1    = %x",dout);
	$display("receive AXI Stream Packet 1 = %x",data_in[255:0]);
	
	//wait for test to complete
	while ( pat_gen_wr_en != 1'b0 | pat_gen_high !=1'b0)
		begin
		@(posedge ms_wr_clk);
		count = count + 1;
		if(count == 40)
			begin
			$display(".");
			count = 0;
			end
		end
		
	dout_last 	 = pat_gen_wr_data_r1;
	wait (chkr_fifo_empty == 1'b1)
	data_in_last = chkr_fifo_rcv_data;
	$display("Send AXI Stream Packet 256    = %x",dout_last);
	$display("Receive AXI Stream Packet 256 = %x",data_in_last );
	$display("\n");
	repeat (20) @(posedge ms_wr_clk);
	
	//check for AXIST test completion
	axist_test_report;
	
	$finish(0);
end 

	task avmm_write (input [31:0] wr_addr, [31:0] wrdata) ;
	begin	
		tb_wr_addr 	= wr_addr;
		tb_wrdata  	= wrdata;
		tb_wren   	= 1'b0;
		
		repeat (3) @(posedge avmm_clk)
		begin
			tb_wren   = 1'b1;
		end
		
		tb_wren		= 1'b0;
	end
	endtask
	
	task avmm_read (input [31:0] rd_addr) ;
	begin
		tb_wr_addr 	= rd_addr;
		tb_rden   	= 1'b0;
		repeat (3) @(posedge avmm_clk)
		begin
			tb_rden   = 1'b1;
		end
		
		tb_rden		= 1'b0;
		wait (tb_master_readdatavalid==1'b1)
		tb_read_data	= tb_master_readdata;
	
	end 
	endtask
	
	task axist_test_report ;
	begin
		avmm_read(32'h50001004);
		mask_reg = {tb_read_data[3],tb_read_data[1:0]}&3'h7;
		case(mask_reg)
			3'b0xx : $display("AXIST Align error\n");
			3'b110 : $display("AXIST test Fail\n");
			3'b111 : 
				begin
					$display("*******************");
					$display("* AXIST test Pass *");
					$display("*******************");
				end 
			3'b10x : $display("Test not complete\n");
			default	 : $display("Invalid test condition\n");
		endcase
		
	end 
	endtask

endmodule
