`timescale 1ps/1ps
module top_tb();

parameter CLK_SCALING 		= 4;
parameter WR_CYCLE   		= 2000*CLK_SCALING;
parameter RD_CYCLE   		= 2000*CLK_SCALING;
parameter FWD_CYCLE  		= 1000*CLK_SCALING;
parameter AVMM_CYCLE 		= 4000;
parameter OSC_CYCLE  		= 1000*CLK_SCALING;
parameter TOTAL_CHNL_NUM 	= 24;
parameter DWIDTH 		= 40;
parameter DATAWIDTH 		= 40;
parameter FULL 			= 1;
parameter HALF 			= 2;
parameter CLKL_HALF_CYCLE 	= 500;

localparam 			REG_MM_WR_CFG_ADDR		= 32'h50001000;
localparam 			REG_MM_WR_RD_ADDR	 	= 32'h50001004;
localparam 			REG_MM_BUS_STS_ADDR	 	= 32'h50001008;
localparam 			REG_LINKUP_STS_ADDR		= 32'h5000100C;
localparam 			REG_DOUT_FIRST1_ADDR		= 32'h50004000;
localparam 			REG_DOUT_LAST1_ADDR		= 32'h50004010;
localparam 			REG_DIN_FIRST1_ADDR		= 32'h50004020;
localparam 			REG_DIN_LAST1_ADDR		= 32'h50004030;
localparam 			REG_MM_RD_CFG_ADDR		= 32'h50001010;

reg 				ms_wr_clk;
reg 				ms_rd_clk;
reg 				ms_fwd_clk;
				
reg 				sl_wr_clk;
reg 				sl_rd_clk;
reg 				sl_fwd_clk;
			
reg				avmm_clk;
					
reg 				osc_clk;
reg  [31:0]			tb_read_data;       		// width = 32,     
wire [31:0]			tb_master_readdata;     	// width = 32,     
wire 				tb_master_readdatavalid;	//  width = 1,     

reg  [31:0] 			tb_wr_addr, tb_wrdata;
reg  [3:0] 			mask_reg;
reg 				tb_wren, tb_rden;

reg              		clk_phy;
reg              		clk_p_div2;
reg              		clk_p_div4;
reg              		rst_phy_n;
reg              		tb_w_m_wr_rst_n ;
reg              		tb_w_s_wr_rst_n ;
reg [127:0]			t_data_out_128b;
reg [127:0]			data_out_first;
reg [127:0]			data_out_last;
reg [127:0]			data_in_first;
reg [127:0]			data_in_last;
int 				i;
reg	[31:0]			tb_32b_rd_addr;

aximm_aib_top #(.AXI_CHNL_NUM(2),
		.LEADER_MODE(HALF), 
		.FOLLOWER_MODE(HALF),
		.DATAWIDTH(DATAWIDTH), 
		.TOTAL_CHNL_NUM(TOTAL_CHNL_NUM)) 
aximm_aib_dut(
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
.tx_online(),
.rx_online(),
.test_done(),
.o_master_waitrequest(),
            
.sl_wr_clk(sl_wr_clk),
.sl_rd_clk(sl_rd_clk),
.sl_fwd_clk(sl_fwd_clk),

.avmm_clk(avmm_clk), 
.osc_clk(osc_clk), 
.i_wren(tb_wren), 
.i_rden(tb_rden),

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
	
always #(WR_CYCLE/2)     sl_wr_clk   	= ~sl_wr_clk;
always #(RD_CYCLE/2)     sl_rd_clk   	= ~sl_rd_clk;
always #(FWD_CYCLE/2)  sl_fwd_clk  	= ~sl_fwd_clk;

always #(AVMM_CYCLE/2) avmm_clk 	= ~avmm_clk;
	
always #(OSC_CYCLE/2)  osc_clk  	= ~osc_clk;


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

initial
begin
	t_data_out_128b		= 0;
	mask_reg		= 0;
	tb_wren			= 0;
	data_out_first		= 0;
	data_out_last		= 0;
	data_in_first		= 0;
	tb_32b_rd_addr		= 0;
	tb_wrdata		= 0;
	data_in_last		= 0;
	tb_read_data		= 0;
	tb_rden			= 0;
	tb_wr_addr		= 0;
	
	$display("Wait for AXI MM online");
	wait (rst_phy_n == 1'b1);
	repeat (10) @(posedge avmm_clk);
	//Delay X,Y and Z values
	avmm_write(32'h50002000, 32'h0000000C); //Delay X value = 12
	avmm_write(32'h50002004, 32'h00000020); //Delay Y value = 32
	avmm_write(32'h50002008, 32'h00001770); //Delay Z value = 6000
	
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
		$display("AXI-MM TX and RX online is high");
		$display("///////////////////////////////////////////////////////\n");
	end
	else $display("AXI-MM TX/RX is offline\n");
	repeat (200) @(posedge ms_wr_clk);
	tb_read_data = 0;

	// Initiate AXIMM write with Random data pattern  
	avmm_write(REG_MM_WR_RD_ADDR, 32'h10000000);
	avmm_write(REG_MM_WR_CFG_ADDR, 32'h00041804);
	$display("///////////////////////////////////////////////////");
	$display("%0t AXI-MM Incremental pattern test for 128 burst packet ",$time);
	$display("//////////////////////////////////////////////////\n");
	repeat (10) @(posedge ms_wr_clk);
	
	//wait for AXI MM write complete
	avmm_read(REG_MM_BUS_STS_ADDR);
	while (tb_read_data[4] != 1'b1)
	begin
		avmm_read(REG_MM_BUS_STS_ADDR);
	end
	avmm_read(REG_MM_BUS_STS_ADDR);
	repeat(20) @(posedge ms_wr_clk);

	//read first data write
	read_aximm_128bit_data(REG_DOUT_FIRST1_ADDR);
	data_out_first = t_data_out_128b;
	$display("AXI-MM send pattern1 burst  1 : 0x%x", data_out_first);

   	repeat (5)
	begin
		repeat(20) @(posedge ms_wr_clk);
		$display(".");
	end

	//read last data write 
	read_aximm_128bit_data(REG_DOUT_LAST1_ADDR);
	data_out_last = t_data_out_128b;
	$display("AXI-MM send pattern1 burst 128 : 0x%x", data_out_last);
	
	//Initiate Read
	avmm_write(REG_MM_WR_RD_ADDR, 32'h10000000);
	avmm_write(REG_MM_RD_CFG_ADDR, 32'h00041804);
	
	//wait for AXI MM read complete
	avmm_read(REG_MM_BUS_STS_ADDR);
	while (tb_read_data[5] != 1'b1)
	begin
		avmm_read(REG_MM_BUS_STS_ADDR);
	end
	avmm_read(REG_MM_BUS_STS_ADDR);
	repeat (20) @(posedge ms_wr_clk);

	//read first data after read initiate
	read_aximm_128bit_data(REG_DIN_FIRST1_ADDR);
	data_in_first = t_data_out_128b;
	$display("AXI-MM Receive pattern1 burst  1 : 0x%x", data_in_first);
	
   	repeat (5)
	begin
		repeat(20) @(posedge ms_wr_clk);
		$display(".");
	end


	//read last data after read initiate 
	read_aximm_128bit_data(REG_DIN_LAST1_ADDR);
	data_in_last = t_data_out_128b;
	$display("AXI-MM Receive pattern1 burst 128 : 0x%x", data_in_last);
	$display("\n");

	//read test report
	repeat (20) @(posedge ms_wr_clk);
	aximm_test_report;
	
	$finish(0);

end

	task avmm_write (input [31:0] wr_addr, [31:0] wrdata) ;
	begin	
		tb_wr_addr 	= wr_addr;
		tb_wrdata  	= wrdata;
		tb_wren   	= 1'b0;
		repeat (3) @(posedge ms_wr_clk)
		begin
		tb_wren   	= 1'b1;
		end
		
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
	end 
	endtask
	
	task read_aximm_128bit_data (input [31:0] rd_staddr);
	begin
		tb_32b_rd_addr	= rd_staddr;
		for(i=0;i<4;i++)
		begin
			avmm_read(tb_32b_rd_addr);
			t_data_out_128b= {tb_read_data,t_data_out_128b[127:32]};
			tb_32b_rd_addr	= tb_32b_rd_addr + 4;
		end 
	end
	endtask
	
	task aximm_test_report ;
	begin
		avmm_read(REG_MM_BUS_STS_ADDR);
		mask_reg = {tb_read_data[3:0]}&4'hf;
		case(mask_reg)
			4'b0xxx : $display("AXI-MM Align error\n");
			4'bx0xx : $display("AXI-MM Align error\n");
			4'b1110 : $display("AXI-MM test Fail\n");
			4'b1111 : 
				begin
					$display("*******************");
					$display("* AXI-MM test Pass *");
					$display("*******************");
				end 
			4'b110x : $display("Test not complete\n");
			default	 : $display("Invalid test condition\n");
		endcase
		
	end 
	endtask
`ifdef VCS
   initial
   begin
     $vcdpluson;
   end
`endif
endmodule
