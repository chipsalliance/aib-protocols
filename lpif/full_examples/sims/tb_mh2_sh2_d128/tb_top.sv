// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: Testbench top module 
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////



`define    TB_DIE_A_LPIF_DATA_WIDTH       64
`define    TB_DIE_B_LPIF_DATA_WIDTH       64
`define    TB_DIE_A_AIB_CLOCK_RATE        1000
`define    TB_DIE_B_AIB_CLOCK_RATE        1000


module tb_top();

   
   parameter CLK_SCALING 		= 1;
   parameter WR_CYCLE   		= 1000*CLK_SCALING;
   parameter RD_CYCLE   		= 1000*CLK_SCALING;
   parameter FWD_CYCLE  		= 500*CLK_SCALING;
   parameter AVMM_CYCLE 		= 4000;
   parameter OSC_CYCLE  		= 1000*CLK_SCALING;
   parameter FULL 			= 1;
   parameter HALF 			= 2;
   parameter CLKL_HALF_CYCLE 		= 500;


   localparam 			REG_DIE_A_CTRL_ADDR 		=32'h50001000;
   localparam 			REG_LINKUP_STS_ADDR		=32'h50001008;
   localparam 			REG_DIE_A_STS_ADDR		=32'h50001004;

   wire   [7:0]                                w_die_a_lp_stream;
   wire                                        w_die_a_lp_stallack;
   wire                                        w_die_a_lp_linkerror;
   wire                                        w_die_a_lp_flushed_all;
   wire                                        w_die_a_lp_rcvd_crc_err;
   wire                                        w_die_a_lp_wake_req;
   wire                                        w_die_a_lp_force_detect;
   wire [7:0] 				       w_die_a_lp_cfg;
   wire                                        w_die_a_lp_cfg_vld;
   wire [15:0] 				       w_die_a_lp_crc;
   wire                                        w_die_a_lp_crc_valid;
   wire                                        w_die_a_lp_device_present;
   wire                                        w_die_a_lp_clk_ack;
   wire [1:0] 				       w_die_a_lp_pri;
   wire                                        w_die_a_lpbk_en;
   
   wire                                        w_die_b_lp_irdy;
   wire [`TB_DIE_A_LPIF_DATA_WIDTH*8-1:0]      w_die_b_lp_data;
   wire [0:0] 				       w_die_b_lp_valid;
   wire [7:0] 				       w_die_b_lp_stream;
   wire                                        w_die_b_lp_stallack;
   wire                                        w_die_b_lp_linkerror;
   wire                                        w_die_b_lp_flushed_all;
   wire                                        w_die_b_lp_rcvd_crc_err;
   wire                                        w_die_b_lp_wake_req;
   wire                                        w_die_b_lp_force_detect;
   wire [7:0] 				       w_die_b_lp_cfg;
   wire                                        w_die_b_lp_cfg_vld;
   wire [15:0] 				       w_die_b_lp_crc;
   wire                                        w_die_b_lp_crc_valid;
   wire                                        w_die_b_lp_device_present;
   wire                                        w_die_b_lp_clk_ack;
   wire [1:0] 				       w_die_b_lp_pri;
   wire                                        w_die_b_lpbk_en;
   wire [7:0] 				       w_die_b_lp_tmstmp_stream;
   
   reg 					       ms_wr_clk;
   reg 					       ms_rd_clk;
   reg 					       ms_fwd_clk;
   
   reg 					       sl_wr_clk;
   reg 					       sl_rd_clk;
   reg 					       sl_fwd_clk;
   reg 					       tb_flit_wr_en;
   
   reg 					       avmm_clk;
   reg 					       osc_clk;
   reg 					       clk_die_a;
   reg 					       clk_die_b;
   reg 					       reset_die_a;
   reg 					       reset_die_b;
   wire 				       w_die_a_rwd_valid;
   wire [527:0] 			       w_die_a_rwd_data	;
   wire [527:0] 			       w_die_a_drs_data	;
   wire 				       w_die_a_drs_valid ;

   assign w_die_a_lp_stream			= 'b0;
   assign w_die_a_lp_stallack			= 'b0;
   assign w_die_a_lp_linkerror			= 'b0;
   assign w_die_a_lp_flushed_all 		= 'b0;
   assign w_die_a_lp_rcvd_crc_err 		= 'b0;
   assign w_die_a_lp_wake_req 			= 'b0;
   assign w_die_a_lp_force_detect 		= 'b0;
   assign w_die_a_lp_cfg 			= 'b0;
   assign w_die_a_lp_cfg_vld 			= 'b0;
   assign w_die_a_lp_crc 			= 'b0;
   assign w_die_a_lp_crc_valid 			= 'b0;
   assign w_die_a_lp_device_present 		= 'b0;
   assign w_die_a_lp_clk_ack 			= 'b0;
   assign w_die_a_lp_pri 			= 2'h3;
   assign w_die_a_lpbk_en 			= 'b0;

   assign w_die_b_lp_irdy 			= 'b0;
   assign w_die_b_lp_tmstmp_stream 		= 8'h00;
   assign w_die_b_lp_data 			= 'b0;
   assign w_die_b_lp_valid			= 'b0;
   assign w_die_b_lp_stream			= 'b0;
   assign w_die_b_lp_stallack			= 'b0;
   assign w_die_b_lp_linkerror			= 'b0;
   assign w_die_b_lp_flushed_all 		= 'b0;
   assign w_die_b_lp_rcvd_crc_err 		= 'b0;
   assign w_die_b_lp_wake_req 			= 'b0;
   assign w_die_b_lp_force_detect 		= 'b0;
   assign w_die_b_lp_cfg 			= 'b0;
   assign w_die_b_lp_cfg_vld 			= 'b0;
   assign w_die_b_lp_crc 			= 'b0;
   assign w_die_b_lp_crc_valid 			= 'b0;
   assign w_die_b_lp_device_present 		= 'b0;
   assign w_die_b_lp_clk_ack 			= 'b0;
   assign w_die_b_lp_pri 			= 2'h3;
   assign w_die_b_lpbk_en 			= 'b0;
   reg [31:0] 				       tb_wr_addr, tb_wrdata;
   reg [3:0] 				       mask_reg;
   reg 					       tb_wren, tb_rden;
   reg [31:0] 				       tb_read_data;       		// width = 32,     
   wire [31:0] 				       tb_master_readdata; 
   wire 				       tb_master_readdatavalid;	
   wire [7:0] 				       die_b_lp_tmstmp_stream;	
   wire [7:0] 				       w_die_b_pl_tmstmp_stream;	
   wire [7:0] 				       w_die_a_lp_tmstmp_stream;	
   wire 				       w_die_b_lp_tmstmp;
   wire 				       w_die_a_lp_tmstmp;
   integer 				       i;

   logic [527:0] 			       wr_flit [$];
   logic [527:0] 			       rd_flit [$];
   logic [527:0]                               disp;
   
   assign die_b_lp_tmstmp_stream 	= 8'd0;
   assign w_die_b_lp_tmstmp	  	= 1'b0;
   assign w_die_a_lp_tmstmp	  	= 1'b0;

   initial
     begin

	ms_wr_clk	= 1'b1;
	ms_rd_clk	= 1'b1;
	ms_fwd_clk	= 1'b1;
	sl_wr_clk	= 1'b1;
	sl_rd_clk	= 1'b1;
	sl_fwd_clk	= 1'b1;
	avmm_clk	= 1'b0;
	osc_clk		= 1'b1;
	clk_die_a 	= 1'b0;
	clk_die_b 	= 1'b0;
	
     end

   initial 
     begin
	
	reset_die_a = 1'b0;
	repeat (400) @(posedge clk_die_a);
	reset_die_a = 1'b1;
     end

   initial 
     begin
	
	reset_die_b = 1'b0;
	repeat (400) @(posedge clk_die_b);
	reset_die_b = 1'b1;
     end

   initial 
     begin
	tb_flit_wr_en	= 1'b0;
	#10us;
	tb_flit_wr_en   = 1'b1;
	#5ns;
	tb_flit_wr_en   = 1'b0;
     end

   always #(WR_CYCLE/2)   ms_wr_clk   		= ~ms_wr_clk;
   always #(RD_CYCLE/2)   ms_rd_clk   		= ~ms_rd_clk;
   always #(FWD_CYCLE/2)  ms_fwd_clk  		= ~ms_fwd_clk;

   always #(`TB_DIE_A_AIB_CLOCK_RATE/2.0) clk_die_a <= ~clk_die_a;
   always #(`TB_DIE_B_AIB_CLOCK_RATE/2.0) clk_die_b <= ~clk_die_b;

   
   
   always #(WR_CYCLE/2)     sl_wr_clk   	= ~sl_wr_clk;
   always #(RD_CYCLE/2)     sl_rd_clk   	= ~sl_rd_clk;
   always #(FWD_CYCLE/2)  sl_fwd_clk  		= ~sl_fwd_clk;
   
   always #(AVMM_CYCLE/2) avmm_clk 		= ~avmm_clk;
   
   always #(OSC_CYCLE/2)  osc_clk  		= ~osc_clk;




   lpif_aib_top lpif_aib_inst(
			      .ms_wr_clk (ms_wr_clk ),
			      .ms_rd_clk (ms_rd_clk ),
			      .ms_fwd_clk(ms_fwd_clk),
			      .sl_wr_clk (sl_wr_clk ),
			      .die_a_rwd_valid(w_die_a_rwd_valid),
			      .die_a_rwd_data	(w_die_a_rwd_data),
			      .die_a_drs_data	(w_die_a_drs_data),
			      .die_a_drs_valid(w_die_a_drs_valid),
			      .sl_rd_clk (sl_rd_clk ),
			      .sl_fwd_clk(sl_fwd_clk),
			      .avmm_clk  (avmm_clk),	
			      .osc_clk   (osc_clk	),		
			      .clk_die_a (clk_die_a),
			      .clk_die_b (clk_die_b ),
			      .tx_online(),
			      .rx_online(), 
			      .i_w_m_wr_rst_n(1'b1),
			      .i_w_s_wr_rst_n(1'b1),
			      .mgmt_clk(1'b0),
			      .reset_die_a(reset_die_a),
			      .reset_die_b(reset_die_b),
			      .master_address(tb_wr_addr),      
			      .master_readdata(tb_master_readdata),     
			      .master_read(tb_rden),         
			      .master_write(tb_wren),        
			      .master_writedata(tb_wrdata),    
			      .master_waitrequest(tb_master_waitrequest),  
			      .master_readdatavalid(tb_master_readdatavalid),
			      .master_byteenable(),   
			      .die_a_pl_stream(),
			      .die_a_pl_error(),
			      .die_a_pl_trainerror(),
			      .die_a_pl_cerror(),
			      .die_a_pl_stallreq(),
			      .die_a_pl_phyinl1(),
			      .die_a_pl_phyinl2(),
			      .die_a_pl_state_sts(),
			      .die_a_pl_quiesce(),
			      .die_a_pl_lnk_cfg(),
			      .die_a_pl_lnk_up(),
			      .die_a_pl_rxframe_errmask(),
			      .die_a_pl_portmode(),
			      .die_a_pl_portmode_val(),
			      .die_a_pl_speedmode(),
			      .die_a_pl_clr_lnkeqreq(),
			      .die_a_pl_set_lnkeqreq(),
			      .die_a_pl_inband_pres(),
			      .die_a_pl_ptm_rx_delay(),
			      .die_a_pl_setlabs(),
			      .die_a_pl_surprise_lnk_down(),
			      .die_a_pl_protocol(),
			      .die_a_pl_protocol_vld(),
			      .die_a_pl_err_pipestg(),
			      .die_a_pl_wake_ack(),
			      .die_a_pl_phyinrecenter(),
			      .die_a_pl_cfg(),
			      .die_a_pl_cfg_vld(),
			      .die_a_pl_setlbms(),
			      .die_a_pl_clk_req(),
			      .die_a_lp_tmstmp(w_die_a_lp_tmstmp),
			      .die_a_lp_tmstmp_stream(w_die_a_lp_tmstmp_stream),
			      .die_a_pl_tmstmp(),
			      .die_a_pl_tmstmp_stream(),
			      .die_a_lp_stream(w_die_a_lp_stream),
			      .die_a_lp_stallack(w_die_a_lp_stallack),
			      .die_a_lp_linkerror(w_die_a_lp_linkerror),
			      .die_a_lp_flushed_all(w_die_a_lp_flushed_all),
			      .die_a_lp_rcvd_crc_err(w_die_a_lp_rcvd_crc_err),
			      .die_a_lp_wake_req(w_die_a_lp_wake_req),
			      .die_a_lp_force_detect(w_die_a_lp_force_detect),
			      .die_a_lp_cfg(w_die_a_lp_cfg),
			      .die_a_lp_cfg_vld(w_die_a_lp_cfg_vld),
			      .die_a_lp_crc(w_die_a_lp_crc),
			      .die_a_lp_crc_valid(w_die_a_lp_crc_valid),
			      .die_a_lp_device_present(w_die_a_lp_device_present),
			      .die_a_lp_clk_ack(w_die_a_lp_clk_ack),
			      .die_a_lp_pri(w_die_a_lp_pri),
			      .die_a_lpbk_en(w_die_a_lpbk_en),
      
			      .die_b_pl_stream(),
			      .die_b_pl_error(),
			      .die_b_pl_trainerror(),
			      .die_b_pl_cerror(),
			      .die_b_pl_stallreq(),
			      .die_b_pl_phyinl1(),
			      .die_b_pl_phyinl2(),
			      .die_b_pl_state_sts(),
			      .die_b_pl_quiesce(),
			      .die_b_pl_lnk_cfg(),
			      .die_b_pl_lnk_up(),
			      .die_b_pl_rxframe_errmask(),
			      .die_b_pl_portmode(),
			      .die_b_pl_portmode_val(),
			      .die_b_pl_speedmode(),
			      .die_b_pl_clr_lnkeqreq(),
			      .die_b_pl_set_lnkeqreq(),
			      .die_b_pl_inband_pres(),
			      .die_b_pl_ptm_rx_delay(),
			      .die_b_pl_setlabs(),
			      .die_b_pl_surprise_lnk_down(),
			      .die_b_pl_protocol(),
			      .die_b_pl_protocol_vld(),
			      .die_b_pl_err_pipestg(),
			      .die_b_pl_wake_ack(),
			      .die_b_pl_phyinrecenter(),
			      .die_b_pl_cfg(),
			      .die_b_pl_cfg_vld(),
			      .die_b_pl_setlbms(),
			      .die_b_pl_crc(),
			      .die_b_pl_crc_valid(),
			      .die_b_pl_clk_req(),
			      .die_b_pl_tmstmp		(w_die_b_pl_tmstmp		),
			      .die_b_pl_tmstmp_stream	(w_die_b_pl_tmstmp_stream	),
      
			      .die_b_lp_tmstmp		(w_die_b_lp_tmstmp		),
			      .die_b_lp_tmstmp_stream	(w_die_b_lp_tmstmp_stream	),
			      .die_b_lp_stream		(w_die_b_lp_stream		),
			      .die_b_lp_stallack		(w_die_b_lp_stallack		),
			      .die_b_lp_linkerror		(w_die_b_lp_linkerror		),
			      .die_b_lp_flushed_all	(w_die_b_lp_flushed_all	),
			      .die_b_lp_rcvd_crc_err	(w_die_b_lp_rcvd_crc_err	),
			      .die_b_lp_wake_req		(w_die_b_lp_wake_req		),
			      .die_b_lp_force_detect	(w_die_b_lp_force_detect	),
			      .die_b_lp_cfg			(w_die_b_lp_cfg			),
			      .die_b_lp_cfg_vld		(w_die_b_lp_cfg_vld		),
			      .die_b_lp_crc			(w_die_b_lp_crc			),
			      .die_b_lp_crc_valid		(w_die_b_lp_crc_valid		),
			      .die_b_lp_device_present(w_die_b_lp_device_present),
			      .die_b_lp_clk_ack		(w_die_b_lp_clk_ack		),
			      .die_b_lp_pri			(w_die_b_lp_pri			),
			      .die_b_lpbk_en			(w_die_b_lpbk_en			)

			      );


   always@(posedge clk_die_a or negedge reset_die_a)
     begin
	if(w_die_a_rwd_valid)
	  begin
	     wr_flit.push_front(w_die_a_rwd_data);
	  end
	
     end


   always@(posedge clk_die_a or negedge reset_die_a)
     begin
	if(w_die_a_drs_valid)
	  begin
	     rd_flit.push_front(w_die_a_drs_data);
	  end
	
     end


   initial
     begin
	tb_wrdata	 = 'b0;
	tb_wren		 = 'b0;
	tb_rden		 = 'b0;
	mask_reg 	 = 0;
	tb_wr_addr 	 = 0;
	tb_read_data 	 = 0;
	i		 = 0;
	disp             = 0;
	
	$display("Wait for LPIF Adapter online");
	wait (reset_die_a == 1'b1);
	repeat (10) @(posedge avmm_clk);
	
	//Delay X,Y and Z values
	avmm_write(32'h50002000, 32'h0000000C); //Delay X value = 12
	avmm_write(32'h50002004, 32'h00000020); //Delay Y value = 32
	avmm_write(32'h50002008, 32'h00001770); //Delay Z value = 6000
	
	//wait for LPIF online
	avmm_read(REG_LINKUP_STS_ADDR);
	while (tb_read_data[5:0] != 6'h3f)
	  begin
	     avmm_read(REG_LINKUP_STS_ADDR);
	  end
	avmm_read(REG_LINKUP_STS_ADDR);
	
	//check for LPIF online
	if(tb_read_data[5:0]== 6'h3F) 
	  begin
	     $display("\n");
	     $display("////////////////////////////////////////////////////////");
	     $display("LPIF adapter Host and Device online is high");
	     $display("///////////////////////////////////////////////////////\n");
	  end
	else $display("LPIF Adapter Host/Device is offline\n");
	repeat(200) @(posedge clk_die_a);
	
	//Host-device write will be automatically followed by read
	//Initiate write flits to device
	$display("////////////////////////////////////////////////////////");
	$display("Host-Device Write and Read for 10 flits");
	$display("///////////////////////////////////////////////////////\n");
	avmm_write(REG_DIE_A_CTRL_ADDR,32'h00000001);
	repeat(4) @(posedge clk_die_a);
	avmm_write(REG_DIE_A_CTRL_ADDR,32'h00000000);
	
	//wait for test to complete	
	repeat(20) @(posedge clk_die_a);
	avmm_read(REG_DIE_A_STS_ADDR);
	while (tb_read_data[2] != 1'b1)
	  begin
	     avmm_read(REG_DIE_A_STS_ADDR);
	  end
	$display("\n");

	//Display write flits in terminal
	$display("Data Write: Flits from Host to Device");
	for(i=0;i<10;i++)
	  begin
	     disp = wr_flit.pop_back;
	     $display("Write Flit %2d Data: %x | Header: %x", i, disp[511:128], disp[127:0]);
	  end
	$display("\n");

	//Display read flit in terminal. Read is auto followed after write.
	$display("Data Read Response: Flits from Device to Host");
	for(i=0;i<10;i++)
	  begin
	     disp = rd_flit.pop_back;
	     $display("Read Flit %2d Data: %x | Header: %x", i, disp[511:128], disp[127:0]);
	  end	
	repeat(200) @(posedge clk_die_a);
	
	//check for test result
	avmm_read(REG_DIE_A_STS_ADDR);
	if(tb_read_data[3:0] == 4'hf)
	  begin
	     $display("\n\n");
	     $display("//////////////////////");
	     $display("LPIF test pass");    
	     $display("/////////////////////\n");
	  end
	else
	  begin
	     $display("LPIF test fail");    
	  end
	
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


   initial begin
      $vcdpluson();
      $vcdplusmemon();
   end

   endmodule
