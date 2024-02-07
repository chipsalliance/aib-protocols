// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: Testbench Top module
//
//
// Change log
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
parameter MGMT_CLK_PERIOD 	= 10000;
parameter DWIDTH 		= 40;
parameter DATAWIDTH 		= 40;
parameter FULL 			= 1;
parameter HALF 			= 2;
parameter CLKL_HALF_CYCLE 	= 500;
`ifdef ASYNC_FIFO
  parameter SYNC_FIFO		= 0;
`else
  parameter SYNC_FIFO		= 1;
`endif

localparam		NUM_CHANNELS		= 7;
localparam 		REG_AXI_CTRL_ADDR		= 32'h50003000;
localparam 		REG_TX_PKT_CTRL_ADDR 		= 32'h50001000;
localparam 		REG_RX_CKR_STS_ADDR	 	= 32'h50001004;
localparam 		REG_F2L_TX_PKT_CTRL_ADDR	= 32'h50001008;
localparam 		REG_F2L_RX_CKR_STS_ADDR		= 32'h5000100C;
localparam 		REG_LINKUP_STS_ADDR		= 32'h50001010;
localparam 		REG_DOUT_FIRST1_ADDR		= 32'h50004000;
localparam 		REG_DOUT_LAST1_ADDR		= 32'h50004100;
localparam 		REG_DIN_FIRST1_ADDR		= 32'h50004200;
localparam 		REG_DIN_LAST1_ADDR		= 32'h50004300;
localparam 		REG_FOLLR_DOUT_FIRST1_ADDR	= 32'h50005000;
localparam 		REG_FOLLR_DOUT_LAST1_ADDR	= 32'h50005100;
localparam 		REG_FOLLR_DIN_FIRST1_ADDR	= 32'h50005200;
localparam 		REG_FOLLR_DIN_LAST1_ADDR	= 32'h50005300;

reg 				ms_wr_clk;
reg 				ms_rd_clk;
reg 				ms_fwd_clk;
				
reg 				sl_wr_clk;
reg 				sl_rd_clk;
reg 				sl_fwd_clk;
reg [NUM_CHANNELS-1 : 0]	lane_clk_a;
reg [NUM_CHANNELS-1 : 0]	lane_clk_b;	
reg				avmm_clk;
reg  [5:0]			count;
reg  [255:0]			f2l_dout_last;
reg  [255:0]			dout_last;
reg  [255:0]			f2l_dout;
reg  [255:0]			dout;
reg  [511:0]			f2l_data_in;
reg  [511:0]			data_in;
reg  [255:0]			data_in_last;
reg  [255:0]			f2l_data_in_last;
wire [255:0]			pat_gen_wr_data;
wire [511:0]			f2l_pat_gen_wr_data;
reg  [255:0]			pat_gen_wr_data_r1;
wire		        	pat_gen_wr_en  ;
					
reg 				osc_clk;
reg  [31:0]			tb_read_data;       		// width = 32,     
wire [31:0]			tb_master_readdata;     	// width = 32,     
wire 				tb_master_readdatavalid;	//  width = 1,     
wire 				pat_gen_wr_valid;
wire 				pat_gen_wr_ready;
wire 				f2l_pat_gen_wr_valid;
wire 				f2l_pat_gen_wr_ready;

reg  [31:0] 			tb_wr_addr, tb_wrdata;
reg  [3:0] 			mask_reg;
reg 				tb_wren, tb_rden;

reg              		clk_phy;
reg              		clk_p_div2;
reg              		clk_p_div4;
reg              		rst_phy_n;
reg              		tb_w_m_wr_rst_n ;
reg              		tb_w_s_wr_rst_n ;
reg [1:0]			axist_dual_test;
wire				tb_master_waitreq;
reg [255:0]			t_data_out_256b;
reg [31:0]			tb_32b_rd_addr ;
int 				i;
reg 				flag;
reg 				flag1;
reg 				tb_mgmt_clk;
wire [NUM_CHANNELS-1 : 0]	lane_clk_a_in;
wire [NUM_CHANNELS-1 : 0]	lane_clk_b_in;


axist_aib_dual_top #(.LEADER_MODE(FULL), 
		     .FOLLOWER_MODE(HALF),
		     .DATAWIDTH(DATAWIDTH), 
		     .TOTAL_CHNL_NUM(TOTAL_CHNL_NUM),
		     .SYNC_FIFO(SYNC_FIFO)
	     ) 
axist_aib_dual_dut(
 .lane_clk_a(lane_clk_a_in),
 .lane_clk_b(lane_clk_b_in),
.i_w_m_wr_rst_n(tb_w_m_wr_rst_n),
.i_w_s_wr_rst_n(tb_w_s_wr_rst_n),
.mgmt_clk(tb_mgmt_clk),
.i_wr_addr(tb_wr_addr), 
.i_wrdata(tb_wrdata),
.tx_online(),
.rx_online(),
.test_done(),
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
.o_tb_f2l_patdout(f2l_pat_gen_wr_data),
.o_tb_f2l_axist_valid(f2l_pat_gen_wr_valid),
.o_tb_f2l_axist_ready(f2l_pat_gen_wr_ready),
.o_master_waitreq(tb_master_waitreq),
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
	tb_mgmt_clk	= 1'b0;
end

genvar j;
generate
	for(j = 0;j < NUM_CHANNELS;j = j+1)
	initial
	begin
		lane_clk_a	= {NUM_CHANNELS{1'b0}};
		#(50*$urandom_range(5,10)); 
		forever #(WR_CYCLE/2) lane_clk_a[j] = ~lane_clk_a[j];
	end
endgenerate

generate 
	for(j = 0;j < NUM_CHANNELS;j = j+1)
	initial
	begin
		lane_clk_b	= {NUM_CHANNELS{1'b0}};
		#(50*$urandom_range(1,10)); 
		forever #(WR_CYCLE) lane_clk_b[j] = ~lane_clk_b[j];
	end
endgenerate

assign lane_clk_a_in	= (SYNC_FIFO == 1'b1)? {NUM_CHANNELS{ms_wr_clk}} :  lane_clk_a;
assign lane_clk_b_in	= (SYNC_FIFO == 1'b1)? {NUM_CHANNELS{sl_wr_clk}} :  lane_clk_b;

always #(WR_CYCLE/2)   ms_wr_clk   	= ~ms_wr_clk;
always #(RD_CYCLE/2)   ms_rd_clk   	= ~ms_rd_clk;
always #(FWD_CYCLE/2)  ms_fwd_clk  	= ~ms_fwd_clk;
always #(MGMT_CLK_PERIOD/2) tb_mgmt_clk = ~tb_mgmt_clk;

always #(WR_CYCLE)     sl_wr_clk   	= ~sl_wr_clk;
always #(RD_CYCLE)     sl_rd_clk   	= ~sl_rd_clk;
always #(FWD_CYCLE/2)  sl_fwd_clk  	= ~sl_fwd_clk;

always #(AVMM_CYCLE/2) avmm_clk 	= ~avmm_clk;
	
always #(OSC_CYCLE/2)  osc_clk  	= ~osc_clk;

always @(posedge ms_wr_clk)
	if(!tb_w_m_wr_rst_n)
	begin
		pat_gen_wr_data_r1		<= 'b0;
	end
	else if(pat_gen_wr_en)
	begin
		pat_gen_wr_data_r1		<= pat_gen_wr_data ;
	end
	

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
  clk_phy 	  = 1'bx;                              // Everything is X
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

assign pat_gen_wr_en 		  = pat_gen_wr_ready & pat_gen_wr_valid;

initial
begin
	mask_reg 	 		= 0;
	count 	 	 		= 0;
	dout 		 		= 'b0;
	data_in 	 		= 'b0;
	dout_last 	 		= 'b0;
	data_in_last 			= 'b0;
	tb_wr_addr 	 		= 'b0;
	tb_rden    	 		= 'b0;
	tb_read_data 			= 'b0;
	tb_wr_addr 	 		= 'b0;
	tb_wrdata    			= 'b0;
	tb_wren      			= 'b0;
	axist_dual_test 		= 'b0;
	f2l_dout_last	 		= 'b0;
	tb_32b_rd_addr			= 'b0;
	f2l_dout		 	= 'b0;
	f2l_data_in		 	= 'b0;
	f2l_data_in_last 		= 'b0;
	flag				= 1'b0;
	flag1				= 1'b0;
	t_data_out_256b = 0;
	$display("Wait for AXI STREAM online");
	repeat (1000) @(posedge ms_wr_clk);
	wait (rst_phy_n == 1'b1);
	repeat (10) @(posedge avmm_clk);
	//Delay X,Y and Z values
	avmm_write(32'h50002000, 32'h0000000C); //Delay X value = 12
	avmm_write(32'h50002004, 32'h00000020); //Delay Y value = 32
	avmm_write(32'h50002008, 32'h00001770); //Delay Z value = 6000
	
	//reset axi interface
	avmm_write(REG_AXI_CTRL_ADDR, 32'h00000001);
	repeat(100) @(posedge avmm_clk);
	avmm_write(REG_AXI_CTRL_ADDR, 32'h00000000);
		
	//wait for AIB online
	avmm_read(REG_LINKUP_STS_ADDR);
	while (tb_read_data[3:0] != 4'hf)
	begin
		avmm_read(REG_LINKUP_STS_ADDR);
	end
	avmm_read(REG_LINKUP_STS_ADDR);
	
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
	
	// //Random pattern test 
	avmm_write(REG_TX_PKT_CTRL_ADDR, 32'h00000FF5);
	avmm_write(REG_F2L_TX_PKT_CTRL_ADDR, 32'h00000FF5);
	$display("///////////////////////////////////////////////////");
	$display("%0t Random pattern test for 256 data packet ",$time);
	$display("//////////////////////////////////////////////////\n");
	
	//Read first data transmitted and received
	l2f_first_data;
	f2l_first_data;
	count 	 = 0;
	$display("Send Pattern 1    (Leader)  = %x",dout);
	$display("receive Pattern 1 (Follower)= %x",data_in[255:0]);	
	$display("\n");
	$display("Send Pattern 1    (Follower)= %x",f2l_dout);
	$display("receive Pattern 1 (Leader)  = %x",f2l_data_in[255:0]);
	
	//wait for test to complete	
	repeat (5)
	begin
	repeat(20) @(posedge ms_wr_clk);
		$display(".");
	end
	
	//check for L2F test complete
	avmm_read(REG_RX_CKR_STS_ADDR);
	while(!tb_read_data[3] == 1'b1)
	begin
		avmm_read(REG_RX_CKR_STS_ADDR);
	end

	//L2F - Read last data transmitted and received
	read_axist_256bit_data(REG_DOUT_LAST1_ADDR);
	dout_last 		= t_data_out_256b;
	read_axist_256bit_data(REG_DIN_LAST1_ADDR);
	data_in_last  		= t_data_out_256b;
	flag1			= 1'b1;
	$display("Send Pattern 256    (Leader)  = %x",dout_last);
	$display("Receive Pattern 256 (Follower)= %x",data_in_last );
	$display("\n");
	
	//check for F2L test complete
	avmm_read(REG_F2L_RX_CKR_STS_ADDR);
	while(!tb_read_data[3] == 1'b1)
	begin
		avmm_read(REG_F2L_RX_CKR_STS_ADDR);
	end
	
	//F2L - Read last data transmitted and received
	read_axist_256bit_data(REG_FOLLR_DOUT_LAST1_ADDR);
	f2l_dout_last 		= t_data_out_256b;
	read_axist_256bit_data(REG_FOLLR_DIN_LAST1_ADDR);
	f2l_data_in_last  	= t_data_out_256b;
	flag			= 1'b1;	
	$display("Send Pattern 256    (Follower)= %x",f2l_dout_last);
	$display("Receive Pattern 256 (Leader)  = %x\n",f2l_data_in_last );
	
	//check for axist test results
	repeat (100) @(posedge ms_wr_clk);
	axist_test_report(REG_RX_CKR_STS_ADDR, "L2F");
	repeat (2) @(posedge sl_wr_clk);
	axist_test_report(REG_F2L_RX_CKR_STS_ADDR, "F2L");
	repeat (100) @(posedge ms_wr_clk);
	if(axist_dual_test == 2'b11)
		begin
			$display("************************");
			$display("* AXIST DUAL test pass *");
			$display("************************");
		end
	else
		begin
			$display("AXIST DUAL test fail ");
		end 
	
	$finish(0);
end 

	task avmm_write (input [31:0] wr_addr, [31:0] wrdata) ;
	begin	
		tb_wr_addr 	= wr_addr;
		tb_wrdata  	= wrdata;
		tb_wren   	= 1'b0;
		
		repeat (3) @(posedge tb_mgmt_clk)
		tb_wren 	= 1'b1;
		tb_wren		= 1'b0;
		repeat (3) @(posedge tb_mgmt_clk);

		tb_wren		= 1'b0;
	end
	endtask
	
       	task avmm_read (input [31:0] rd_addr) ;
	begin
		tb_wr_addr 	= rd_addr;
		tb_rden   	= 1'b0;
		repeat (3) @(posedge ms_wr_clk)
		begin
			tb_rden   = 1'b1;
		end
		
		tb_rden		= 1'b0;
		wait (tb_master_readdatavalid==1'b1)
		tb_read_data	= tb_master_readdata;
	
		repeat (20) @(posedge ms_wr_clk);
	end 
	endtask
	
	task axist_test_report (input [31:0] addr, string axist_type);
	begin
		avmm_read(addr);
		mask_reg = {tb_read_data[3],tb_read_data[1:0]}&3'h7;
		casex(mask_reg)
			3'b0xx : $display("AXIST %s Align error\n", axist_type);
			3'b110 : $display("AXIST %s test Fail\n", axist_type);
			3'b111 : 
				begin
					// $display("***********************");
					$display(" AXIST %s test Pass \n", axist_type);
					// $display("***********************");
					axist_dual_test	= {axist_dual_test[0], 1'b1};
				end 
			3'b10x : $display("Test not complete\n");
			default	 : $display("Invalid test condition\n");
		endcase
		
	end 
		mask_reg	= 'b0;
	endtask
	
	task l2f_first_data;
		wait ( pat_gen_wr_en == 1'b1);
		repeat (5) @(posedge ms_wr_clk)
		read_axist_256bit_data(REG_DOUT_FIRST1_ADDR);
		dout 	 = t_data_out_256b;
		read_axist_256bit_data(REG_DIN_FIRST1_ADDR);
		data_in  = t_data_out_256b;
	
	endtask
	
    task f2l_first_data;
		read_axist_256bit_data(REG_FOLLR_DOUT_FIRST1_ADDR);
		f2l_dout 	= t_data_out_256b;
		read_axist_256bit_data(REG_FOLLR_DIN_FIRST1_ADDR);
		f2l_data_in  	= t_data_out_256b;
	
	endtask
	
	task read_axist_256bit_data (input [31:0] rd_staddr);
	begin
		tb_32b_rd_addr	= rd_staddr;
		for(i=0;i<8;i++)
		begin
			avmm_read(tb_32b_rd_addr);
			t_data_out_256b = {tb_read_data,t_data_out_256b[255:32]};
			tb_32b_rd_addr	= tb_32b_rd_addr + 4;
		end 
	end
	endtask
	
   initial
   begin
     $vcdpluson;
   end

	
endmodule
