////////////////////////////////////////////////////////////
//
//        Copyright (C) 2021 Eximius Design
//
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
////////////////////////////////////////////////////////////

// Very simple AXI MM touch test.
// Uses unmodified version of ../script/cfg/axi_mm_a32_d128.cfg configuration.
// See config file for details. Changing the config file will likely break TB.
//
// Trigger a few simple transactions.
//
// Note, that config us Full Gen2, so clk_wr = 2GHz.
// This is logic link to logic link.
// AIB is not shown, but should be generally an opaque transfer of the PHY signals.

`timescale 1ns/1ps

module axi_mm_a32_d128_tb ();

`define ENABLE_PHASE_01 1               // Simple, non overlapping minimum sized transfers
`define ENABLE_PHASE_02 1               // Overlapping minimum sized transfers
`define ENABLE_PHASE_03 1               // Simple, non overlapping medium sized transfers
`define ENABLE_PHASE_04 1               // Overlapping medium transfers
`define ENABLE_PHASE_05 1               // Simple, non overlapping large sized transfers
`define ENABLE_PHASE_06 1               // Overlapping large transfers
`define ENABLE_PHASE_07 1               // Random size, packets
`define ENABLE_PHASE_08 1               // Overlapping large transfers with no flowcontrol from downstream

//`define DATA_DEBUG 1

localparam GENERIC_DELAY_X_VALUE = 16'd12 ;  // Word Alignment Time
localparam GENERIC_DELAY_Y_VALUE = 16'd32 ;  // CA Alignment Time
localparam GENERIC_DELAY_Z_VALUE = 16'd8000 ;  // AIB Alignment Time

localparam MASTER_DELAY_X_VALUE = GENERIC_DELAY_X_VALUE / 4'h1;
localparam MASTER_DELAY_Y_VALUE = GENERIC_DELAY_Y_VALUE / 4'h1;
localparam MASTER_DELAY_Z_VALUE = GENERIC_DELAY_Z_VALUE / 4'h1;

localparam SLAVE_DELAY_X_VALUE = GENERIC_DELAY_X_VALUE / 4'h1;
localparam SLAVE_DELAY_Y_VALUE = GENERIC_DELAY_Y_VALUE / 4'h1;
localparam SLAVE_DELAY_Z_VALUE = GENERIC_DELAY_Z_VALUE / 4'h1;

//////////////////////////////////////////////////////////////////////
// Clock and reset
parameter CLK_HALF_CYCLE = 0.25;
reg                     clk_wr;
reg                     rst_wr_n;

initial
begin
  repeat (5) #(CLK_HALF_CYCLE);
  forever @(clk_wr)
  begin
    #(CLK_HALF_CYCLE);
    clk_wr <= ~clk_wr;
  end
end

initial
begin
  clk_wr = 1'bx;                              // Everything is X
  rst_wr_n = 1'bx;
  repeat (10) #(CLK_HALF_CYCLE);
  rst_wr_n <= 1'b0;                           // RST is known (active)
  repeat (10) #(CLK_HALF_CYCLE);
  clk_wr <= 1'b0;                             // CLK is known
  repeat (500) @(posedge clk_wr);
  $display ("######## Exit Reset",,$time);
  rst_wr_n <= 1;                              // Everything is up and running
end
// Clock and reset
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Counters
integer NUMBER_PASSED = 0;
integer NUMBER_FAILED = 0;
// Counters
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Waveform
initial
begin
//   $fsdbDumpfile("mpu_ep_tb.fsdb");
//   $fsdbDumpvars(0);
//   $fsdbDumpon;

// A - record all signals
// T - record all tasks
// F - record all functions
// M - record memory (big)
// C - repeat recursively below

  `ifdef SHM_OVERRIDE_OFF
    $display ("INFORMATION:  SHM Override in effect.  No Waveform.");
  `else
    $shm_open( , 0, , );
    $shm_probe( axi_mm_a32_d128_tb, "AMCTF");
  `endif
end
// Waveform
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Randomization
integer random_seed;
initial
begin
  if (!$value$plusargs("VERILOG_RANDOM_SEED=%h",random_seed))
    if (!$value$plusargs("SEED=%h",random_seed))
      random_seed = 0;

  $display ("Using Random Seed (random_seed) = %0x",random_seed);
  $display ("To reproduce, add:  +VERILOG_RANDOM_SEED=%0x",random_seed);
end

// Randomization
//////////////////////////////////////////////////////////////////////


   //-----------------------
   //-- WIRE DECLARATIONS --
   //-----------------------
   /*AUTOWIRE*/
   // Beginning of automatic wires (for undeclared instantiated-module outputs)
   logic [31:0]		rx_ar_debug_status;	// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [31:0]		rx_aw_debug_status;	// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [31:0]		rx_b_debug_status;	// From axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [31:0]		rx_r_debug_status;	// From axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [31:0]		rx_w_debug_status;	// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [31:0]		tx_ar_debug_status;	// From axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [31:0]		tx_aw_debug_status;	// From axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [31:0]		tx_b_debug_status;	// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [31:0]		tx_r_debug_status;	// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [31:0]		tx_w_debug_status;	// From axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic		user1_arready;		// From axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic		user1_awready;		// From axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [3:0]		user1_bid;		// From axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [1:0]		user1_bresp;		// From axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic		user1_bvalid;		// From axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [127:0]	user1_rdata;		// From axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [3:0]		user1_rid;		// From axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic		user1_rlast;		// From axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [1:0]		user1_rresp;		// From axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic		user1_rvalid;		// From axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic		user1_wready;		// From axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [31:0]		user2_araddr;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [1:0]		user2_arburst;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [3:0]		user2_arid;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [7:0]		user2_arlen;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [2:0]		user2_arsize;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic		user2_arvalid;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [31:0]		user2_awaddr;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [1:0]		user2_awburst;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [3:0]		user2_awid;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [7:0]		user2_awlen;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [2:0]		user2_awsize;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic		user2_awvalid;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic		user2_bready;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic		user2_rready;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [127:0]	user2_wdata;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [3:0]		user2_wid;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic		user2_wlast;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [15:0]		user2_wstrb;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic		user2_wvalid;		// From axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   // End of automatics

   //-----------------------
   //-- REG DECLARATIONS --
   //-----------------------
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   logic		m_gen2_mode=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v, ...
   logic [31:0]		user1_araddr=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [1:0]		user1_arburst=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [3:0]		user1_arid=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [7:0]		user1_arlen=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [2:0]		user1_arsize=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic		user1_arvalid=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [31:0]		user1_awaddr=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [1:0]		user1_awburst=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [3:0]		user1_awid=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [7:0]		user1_awlen=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [2:0]		user1_awsize=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic		user1_awvalid=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic		user1_bready=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic		user1_rready=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [127:0]	user1_wdata=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [3:0]		user1_wid=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic		user1_wlast=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic [15:0]		user1_wstrb=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic		user1_wvalid=0;		// To axi_mm_master_top_i of axi_mm_a32_d128_master_top.v
   logic		user2_arready=0;		// To axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic		user2_awready=0;		// To axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [3:0]		user2_bid=0;		// To axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [1:0]		user2_bresp=0;		// To axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic		user2_bvalid=0;		// To axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [127:0]	user2_rdata=0;		// To axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [3:0]		user2_rid=0;		// To axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic		user2_rlast=0;		// To axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic [1:0]		user2_rresp=0;		// To axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic		user2_rvalid=0;		// To axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   logic		user2_wready=0;		// To axi_mm_slave_top_i of axi_mm_a32_d128_slave_top.v
   // End of automatics
   logic [159:0]	tx_phy_master_0;
   logic [159:0]	tx_phy_master_1;
   logic [159:0]	tx_phy_master_2;
   logic [159:0]	tx_phy_master_3;
   logic [159:0]	tx_phy_master_4;
   logic [159:0]	tx_phy_master_5;
   logic [159:0]	tx_phy_master_6;
   logic [159:0]	tx_phy_master_7;
   logic [159:0]	tx_phy_slave_0;
   logic [159:0]	tx_phy_slave_1;
   logic [159:0]	tx_phy_slave_2;
   logic [159:0]	tx_phy_slave_3;
   logic [159:0]	tx_phy_slave_4;
   logic [159:0]	tx_phy_slave_5;
   logic [159:0]	tx_phy_slave_6;
   logic [159:0]	tx_phy_slave_7;
   logic [159:0]	rx_phy_master_0=0;
   logic [159:0]	rx_phy_master_1=0;
   logic [159:0]	rx_phy_master_2=0;
   logic [159:0]	rx_phy_master_3=0;
   logic [159:0]	rx_phy_master_4=0;
   logic [159:0]	rx_phy_master_5=0;
   logic [159:0]	rx_phy_master_6=0;
   logic [159:0]	rx_phy_master_7=0;
   logic [159:0]	rx_phy_slave_0=0;
   logic [159:0]	rx_phy_slave_1=0;
   logic [159:0]	rx_phy_slave_2=0;
   logic [159:0]	rx_phy_slave_3=0;
   logic [159:0]	rx_phy_slave_4=0;
   logic [159:0]	rx_phy_slave_5=0;
   logic [159:0]	rx_phy_slave_6=0;
   logic [159:0]	rx_phy_slave_7=0;

   initial m_gen2_mode = 1;


   /* axi_mm_a32_d128_master_top AUTO_TEMPLATE (
      .user_\(.*\)			(user1_\1[]),

      .init_ar_credit			(8'd8),
      .init_aw_credit			(8'd8),
      .init_w_credit			(8'd128),

      .rx_online			(1'b1), // Tied ONLINE high
      .tx_online			(1'b1), // Tied ONLINE high

      .delay_x_value                    (MASTER_DELAY_X_VALUE),
      .delay_y_value                    (MASTER_DELAY_Y_VALUE),
      .delay_z_value                    (MASTER_DELAY_Z_VALUE),

      .tx_phy\(.\)                      (tx_phy_master_\1[]),
      .rx_phy\(.\)			(rx_phy_master_\1[]),
    );
    */
   axi_mm_a32_d128_master_top axi_mm_master_top_i
     (/*AUTOINST*/
      // Outputs
      .tx_phy0				(tx_phy_master_0[79:0]), // Templated
      .tx_phy1				(tx_phy_master_1[79:0]), // Templated
      .tx_phy2				(tx_phy_master_2[79:0]), // Templated
      .tx_phy3				(tx_phy_master_3[79:0]), // Templated
      .user_arready			(user1_arready),	 // Templated
      .user_awready			(user1_awready),	 // Templated
      .user_wready			(user1_wready),		 // Templated
      .user_rid				(user1_rid[3:0]),	 // Templated
      .user_rdata			(user1_rdata[127:0]),	 // Templated
      .user_rlast			(user1_rlast),		 // Templated
      .user_rresp			(user1_rresp[1:0]),	 // Templated
      .user_rvalid			(user1_rvalid),		 // Templated
      .user_bid				(user1_bid[3:0]),	 // Templated
      .user_bresp			(user1_bresp[1:0]),	 // Templated
      .user_bvalid			(user1_bvalid),		 // Templated
      .tx_ar_debug_status		(tx_ar_debug_status[31:0]),
      .tx_aw_debug_status		(tx_aw_debug_status[31:0]),
      .tx_w_debug_status		(tx_w_debug_status[31:0]),
      .rx_r_debug_status		(rx_r_debug_status[31:0]),
      .rx_b_debug_status		(rx_b_debug_status[31:0]),
      // Inputs
      .clk_wr				(clk_wr),
      .rst_wr_n				(rst_wr_n),
      .tx_online			(1'b1),			 // Templated
      .rx_online			(1'b1),			 // Templated
      .init_ar_credit			(8'd8),			 // Templated
      .init_aw_credit			(8'd8),			 // Templated
      .init_w_credit			(8'd128),		 // Templated
      .rx_phy0				(rx_phy_master_0[79:0]), // Templated
      .rx_phy1				(rx_phy_master_1[79:0]), // Templated
      .rx_phy2				(rx_phy_master_2[79:0]), // Templated
      .rx_phy3				(rx_phy_master_3[79:0]), // Templated
      .user_arid			(user1_arid[3:0]),	 // Templated
      .user_arsize			(user1_arsize[2:0]),	 // Templated
      .user_arlen			(user1_arlen[7:0]),	 // Templated
      .user_arburst			(user1_arburst[1:0]),	 // Templated
      .user_araddr			(user1_araddr[31:0]),	 // Templated
      .user_arvalid			(user1_arvalid),	 // Templated
      .user_awid			(user1_awid[3:0]),	 // Templated
      .user_awsize			(user1_awsize[2:0]),	 // Templated
      .user_awlen			(user1_awlen[7:0]),	 // Templated
      .user_awburst			(user1_awburst[1:0]),	 // Templated
      .user_awaddr			(user1_awaddr[31:0]),	 // Templated
      .user_awvalid			(user1_awvalid),	 // Templated
      .user_wid				(user1_wid[3:0]),	 // Templated
      .user_wdata			(user1_wdata[127:0]),	 // Templated
      .user_wstrb			(user1_wstrb[15:0]),	 // Templated
      .user_wlast			(user1_wlast),		 // Templated
      .user_wvalid			(user1_wvalid),		 // Templated
      .user_rready			(user1_rready),		 // Templated
      .user_bready			(user1_bready),		 // Templated
      .m_gen2_mode			(m_gen2_mode),
      .delay_x_value                    (MASTER_DELAY_X_VALUE),
      .delay_y_value                    (MASTER_DELAY_Y_VALUE),
      .delay_z_value                    (MASTER_DELAY_Z_VALUE));

   /* axi_mm_a32_d128_slave_top AUTO_TEMPLATE (
      .user_\(.*\)			(user2_\1[]),

      .init_b_credit			(8'd8),
      .init_r_credit			(8'd128),

      .rx_online			(1'b1), // Tied ONLINE high
      .tx_online			(1'b1), // Tied ONLINE high

      .delay_x_value                    (slave_DELAY_X_VALUE),
      .delay_y_value                    (slave_DELAY_Y_VALUE),
      .delay_z_value                    (slave_DELAY_Z_VALUE),

      .tx_phy\(.\)                      (tx_phy_slave_\1[]),
      .rx_phy\(.\)			(rx_phy_slave_\1[]),
    );
    */
   axi_mm_a32_d128_slave_top axi_mm_slave_top_i
     (/*AUTOINST*/
      // Outputs
      .tx_phy0				(tx_phy_slave_0[79:0]),         // Templated
      .tx_phy1				(tx_phy_slave_1[79:0]),         // Templated
      .tx_phy2				(tx_phy_slave_2[79:0]),         // Templated
      .tx_phy3				(tx_phy_slave_3[79:0]),         // Templated
      .user_arid			(user2_arid[3:0]),	 // Templated
      .user_arsize			(user2_arsize[2:0]),	 // Templated
      .user_arlen			(user2_arlen[7:0]),	 // Templated
      .user_arburst			(user2_arburst[1:0]),	 // Templated
      .user_araddr			(user2_araddr[31:0]),	 // Templated
      .user_arvalid			(user2_arvalid),	 // Templated
      .user_awid			(user2_awid[3:0]),	 // Templated
      .user_awsize			(user2_awsize[2:0]),	 // Templated
      .user_awlen			(user2_awlen[7:0]),	 // Templated
      .user_awburst			(user2_awburst[1:0]),	 // Templated
      .user_awaddr			(user2_awaddr[31:0]),	 // Templated
      .user_awvalid			(user2_awvalid),	 // Templated
      .user_wid				(user2_wid[3:0]),	 // Templated
      .user_wdata			(user2_wdata[127:0]),	 // Templated
      .user_wstrb			(user2_wstrb[15:0]),	 // Templated
      .user_wlast			(user2_wlast),		 // Templated
      .user_wvalid			(user2_wvalid),		 // Templated
      .user_rready			(user2_rready),		 // Templated
      .user_bready			(user2_bready),		 // Templated
      .rx_ar_debug_status		(rx_ar_debug_status[31:0]),
      .rx_aw_debug_status		(rx_aw_debug_status[31:0]),
      .rx_w_debug_status		(rx_w_debug_status[31:0]),
      .tx_r_debug_status		(tx_r_debug_status[31:0]),
      .tx_b_debug_status		(tx_b_debug_status[31:0]),
      // Inputs
      .clk_wr				(clk_wr),
      .rst_wr_n				(rst_wr_n),
      .tx_online			(1'b1),			 // Templated
      .rx_online			(1'b1),			 // Templated
      .init_r_credit			(8'd128),		 // Templated
      .init_b_credit			(8'd8),			 // Templated
      .rx_phy0				(rx_phy_slave_0[79:0]),         // Templated
      .rx_phy1				(rx_phy_slave_1[79:0]),         // Templated
      .rx_phy2				(rx_phy_slave_2[79:0]),         // Templated
      .rx_phy3				(rx_phy_slave_3[79:0]),         // Templated
      .user_arready			(user2_arready),         // Templated
      .user_awready			(user2_awready),	 // Templated
      .user_wready			(user2_wready),		 // Templated
      .user_rid				(user2_rid[3:0]),	 // Templated
      .user_rdata			(user2_rdata[127:0]),	 // Templated
      .user_rlast			(user2_rlast),		 // Templated
      .user_rresp			(user2_rresp[1:0]),	 // Templated
      .user_rvalid			(user2_rvalid),		 // Templated
      .user_bid				(user2_bid[3:0]),	 // Templated
      .user_bresp			(user2_bresp[1:0]),	 // Templated
      .user_bvalid			(user2_bvalid),		 // Templated
      .m_gen2_mode			(m_gen2_mode),
      .delay_x_value                    (MASTER_DELAY_X_VALUE),
      .delay_y_value                    (MASTER_DELAY_Y_VALUE),
      .delay_z_value                    (MASTER_DELAY_Z_VALUE));


localparam TX_PHY_LATENCY = 30; // This number equates to how many clk_wr cycles it takes to go from the data (MAC) input of one PHY to the data (MAC) output of the other PHY.
logic [319:0] tx_master_phy0_delay_array [$];
logic [319:0] tx_master_phy1_delay_array [$];
logic [319:0] tx_master_phy2_delay_array [$];
logic [319:0] tx_master_phy3_delay_array [$];
logic [319:0] tx_master_phy4_delay_array [$];
logic [319:0] tx_master_phy5_delay_array [$];
logic [319:0] tx_master_phy6_delay_array [$];
logic [319:0] tx_master_phy7_delay_array [$];
logic [319:0] tx_slave_phy0_delay_array  [$];
logic [319:0] tx_slave_phy1_delay_array  [$];
logic [319:0] tx_slave_phy2_delay_array  [$];
logic [319:0] tx_slave_phy3_delay_array  [$];
logic [319:0] tx_slave_phy4_delay_array  [$];
logic [319:0] tx_slave_phy5_delay_array  [$];
logic [319:0] tx_slave_phy6_delay_array  [$];
logic [319:0] tx_slave_phy7_delay_array  [$];

initial
begin
  #1;
  repeat (TX_PHY_LATENCY)
  begin
    tx_master_phy0_delay_array.push_back ( 320'h0 ) ;
    tx_master_phy1_delay_array.push_back ( 320'h0 ) ;
    tx_master_phy2_delay_array.push_back ( 320'h0 ) ;
    tx_master_phy3_delay_array.push_back ( 320'h0 ) ;
    tx_master_phy4_delay_array.push_back ( 320'h0 ) ;
    tx_master_phy5_delay_array.push_back ( 320'h0 ) ;
    tx_master_phy6_delay_array.push_back ( 320'h0 ) ;
    tx_master_phy7_delay_array.push_back ( 320'h0 ) ;

    tx_slave_phy0_delay_array.push_back  ( 320'h0 ) ;
    tx_slave_phy1_delay_array.push_back  ( 320'h0 ) ;
    tx_slave_phy2_delay_array.push_back  ( 320'h0 ) ;
    tx_slave_phy3_delay_array.push_back  ( 320'h0 ) ;
    tx_slave_phy4_delay_array.push_back  ( 320'h0 ) ;
    tx_slave_phy5_delay_array.push_back  ( 320'h0 ) ;
    tx_slave_phy6_delay_array.push_back  ( 320'h0 ) ;
    tx_slave_phy7_delay_array.push_back  ( 320'h0 ) ;

  end
end


always @(posedge clk_wr)
begin
  tx_master_phy0_delay_array.push_back ( tx_phy_master_0 | 320'h0) ;
  tx_master_phy1_delay_array.push_back ( tx_phy_master_1 | 320'h0) ;
  tx_master_phy2_delay_array.push_back ( tx_phy_master_2 | 320'h0) ;
  tx_master_phy3_delay_array.push_back ( tx_phy_master_3 | 320'h0) ;
  tx_master_phy4_delay_array.push_back ( tx_phy_master_4 | 320'h0) ;
  tx_master_phy5_delay_array.push_back ( tx_phy_master_5 | 320'h0) ;
  tx_master_phy6_delay_array.push_back ( tx_phy_master_6 | 320'h0) ;
  tx_master_phy7_delay_array.push_back ( tx_phy_master_7 | 320'h0) ;

  tx_slave_phy0_delay_array.push_back  ( tx_phy_slave_0  | 320'h0 ) ;
  tx_slave_phy1_delay_array.push_back  ( tx_phy_slave_1  | 320'h0 ) ;
  tx_slave_phy2_delay_array.push_back  ( tx_phy_slave_2  | 320'h0 ) ;
  tx_slave_phy3_delay_array.push_back  ( tx_phy_slave_3  | 320'h0 ) ;
  tx_slave_phy4_delay_array.push_back  ( tx_phy_slave_4  | 320'h0 ) ;
  tx_slave_phy5_delay_array.push_back  ( tx_phy_slave_5  | 320'h0 ) ;
  tx_slave_phy6_delay_array.push_back  ( tx_phy_slave_6  | 320'h0 ) ;
  tx_slave_phy7_delay_array.push_back  ( tx_phy_slave_7  | 320'h0 ) ;

  rx_phy_slave_0 <= tx_master_phy0_delay_array.pop_front()  ;
  rx_phy_slave_1 <= tx_master_phy1_delay_array.pop_front()  ;
  rx_phy_slave_2 <= tx_master_phy2_delay_array.pop_front()  ;
  rx_phy_slave_3 <= tx_master_phy3_delay_array.pop_front()  ;
  rx_phy_slave_4 <= tx_master_phy4_delay_array.pop_front()  ;
  rx_phy_slave_5 <= tx_master_phy5_delay_array.pop_front()  ;
  rx_phy_slave_6 <= tx_master_phy6_delay_array.pop_front()  ;
  rx_phy_slave_7 <= tx_master_phy7_delay_array.pop_front()  ;

  rx_phy_master_0 <= tx_slave_phy0_delay_array.pop_front() ;
  rx_phy_master_1 <= tx_slave_phy1_delay_array.pop_front() ;
  rx_phy_master_2 <= tx_slave_phy2_delay_array.pop_front() ;
  rx_phy_master_3 <= tx_slave_phy3_delay_array.pop_front() ;
  rx_phy_master_4 <= tx_slave_phy4_delay_array.pop_front() ;
  rx_phy_master_5 <= tx_slave_phy5_delay_array.pop_front() ;
  rx_phy_master_6 <= tx_slave_phy6_delay_array.pop_front() ;
  rx_phy_master_7 <= tx_slave_phy7_delay_array.pop_front() ;

end

// DUT
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Actual Test

integer TestPhase=0;
event sub_phase_trig;
logic disable_ds_flowcontrol=0;
logic disable_us_performance_cap=0;

initial
begin
  wait (rst_wr_n === 1'b1);
  repeat (10) @(posedge clk_wr);

  if (`ENABLE_PHASE_01)
  begin
    TestPhase = 1 ;
    repeat (100) @(posedge clk_wr);

    repeat (20)
    begin
      // Send minimal sized read
      init_read(1);
      wait_until_empty();
      repeat (100) @(posedge clk_wr);

      // Send minimal sized write
      init_write(1);
      wait_until_empty();
      repeat (100) @(posedge clk_wr);
      -> sub_phase_trig;
    end

    wait_until_empty();

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge clk_wr);
  end

  if (`ENABLE_PHASE_02)
  begin
    TestPhase = 2 ;
    repeat (100) @(posedge clk_wr);

    repeat (20)
    begin
      // Send minimal sized read
      init_read(1);
      // Send minimal sized write
      init_write(1);
      wait_until_empty();
      repeat (100) @(posedge clk_wr);
      -> sub_phase_trig;
    end

    wait_until_empty();

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge clk_wr);
  end


  if (`ENABLE_PHASE_03)
  begin
    TestPhase = 3 ;
    repeat (100) @(posedge clk_wr);

    repeat (20)
    begin
      // Send medium sized read
      init_read(10);
      wait_until_empty();
      repeat (100) @(posedge clk_wr);

      // Send medium sized write
      init_write(10);
      wait_until_empty();
      repeat (100) @(posedge clk_wr);
      -> sub_phase_trig;
    end

    wait_until_empty();

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge clk_wr);
  end

  if (`ENABLE_PHASE_04)
  begin
    TestPhase = 4 ;
    repeat (100) @(posedge clk_wr);

    repeat (20)
    begin
      // Send medium sized read
      init_read(10);
      // Send medium sized write
      init_write(10);
      wait_until_empty();
      repeat (100) @(posedge clk_wr);
      -> sub_phase_trig;
    end

    wait_until_empty();

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge clk_wr);
  end

  if (`ENABLE_PHASE_05)
  begin
    TestPhase = 5 ;
    repeat (100) @(posedge clk_wr);

    repeat (20)
    begin
      // Send max sized read
      init_read(256);
      wait_until_empty();
      repeat (100) @(posedge clk_wr);

      // Send max sized write
      init_write(256);
      wait_until_empty();
      repeat (100) @(posedge clk_wr);
      -> sub_phase_trig;
    end

    wait_until_empty();

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge clk_wr);
  end

  if (`ENABLE_PHASE_06)
  begin
    TestPhase = 6 ;
    repeat (100) @(posedge clk_wr);

    repeat (20)
    begin
      // Send max sized read
      init_read(256);
      // Send max sized write
      init_write(256);
      wait_until_empty();
      repeat (100) @(posedge clk_wr);
      -> sub_phase_trig;
    end

    wait_until_empty();

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge clk_wr);
  end

  if (`ENABLE_PHASE_07)
  begin
    TestPhase = 7 ;
    repeat (100) @(posedge clk_wr);

    disable_us_performance_cap = 1;
    repeat (100) @(posedge clk_wr);

    repeat (20)
    begin
      init_read  ( $urandom_range(1,256) );
      init_write ( $urandom_range(1,256) );
      -> sub_phase_trig;
    end

    // This takes a while (so long it triggers timeout)
    // So we'll add a longish wait.
    repeat (100_000) @(posedge clk_wr);
    wait_until_empty();

    disable_us_performance_cap = 0;
    repeat (100) @(posedge clk_wr);

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge clk_wr);
  end

  if (`ENABLE_PHASE_08)
  begin
    TestPhase = 8 ;
    repeat (100) @(posedge clk_wr);

    disable_ds_flowcontrol = 1;
    disable_us_performance_cap = 1;
    repeat (100) @(posedge clk_wr);

    repeat (20)
    begin
      init_read  ( 256 );
      -> sub_phase_trig;
    end
    wait_until_empty();

    repeat (20)
    begin
      init_write  ( 256 );
      -> sub_phase_trig;
    end
    wait_until_empty();

    disable_us_performance_cap = 0;
    disable_ds_flowcontrol = 0;
    repeat (100) @(posedge clk_wr);

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge clk_wr);
  end



  repeat (100) @(posedge clk_wr);
  finish_simulation;
end

task finish_simulation;
begin
  $display ("NUMBER_PASSED            %32d",NUMBER_PASSED);
  $display ("Number That Did not Pass %32d",NUMBER_FAILED);
  $display ("");
  $display ("SIM COMPLETE");
  $display ("Finishing simulation via finish_simulation task");

  @(posedge clk_wr);
  $finish(0);
end
endtask

// Actual Test
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Transaction Queueing

logic [31:0]         queue_master_act_araddr  [$] ;
logic [1:0]          queue_master_act_arburst [$] ;
logic [3:0]          queue_master_act_arid    [$] ;
logic [7:0]          queue_master_act_arlen   [$] ;
logic [2:0]          queue_master_act_arsize  [$] ;

logic [127:0]        queue_slave_act_rdata    [$] ;
logic [3:0]          queue_slave_act_rid      [$] ;
logic                queue_slave_act_rlast    [$] ;
logic [1:0]          queue_slave_act_rresp    [$] ;

logic [31:0]         queue_master_act_awaddr  [$] ;
logic [1:0]          queue_master_act_awburst [$] ;
logic [3:0]          queue_master_act_awid    [$] ;
logic [7:0]          queue_master_act_awlen   [$] ;
logic [2:0]          queue_master_act_awsize  [$] ;

logic [127:0]        queue_master_act_wdata   [$] ;
logic [3:0]          queue_master_act_wid     [$] ;
logic                queue_master_act_wlast   [$] ;
logic [15:0]         queue_master_act_wstrb   [$] ;

logic [3:0]          queue_slave_act_bid      [$] ;
logic [1:0]          queue_slave_act_bresp    [$] ;


logic [31:0]         queue_slave_exp_araddr   [$] ;
logic [1:0]          queue_slave_exp_arburst  [$] ;
logic [3:0]          queue_slave_exp_arid     [$] ;
logic [7:0]          queue_slave_exp_arlen    [$] ;
logic [2:0]          queue_slave_exp_arsize   [$] ;

logic [127:0]        queue_master_exp_rdata   [$] ;
logic [3:0]          queue_master_exp_rid     [$] ;
logic                queue_master_exp_rlast   [$] ;
logic [1:0]          queue_master_exp_rresp   [$] ;

logic [31:0]         queue_slave_exp_awaddr   [$] ;
logic [1:0]          queue_slave_exp_awburst  [$] ;
logic [3:0]          queue_slave_exp_awid     [$] ;
logic [7:0]          queue_slave_exp_awlen    [$] ;
logic [2:0]          queue_slave_exp_awsize   [$] ;

logic [127:0]        queue_slave_exp_wdata    [$] ;
logic [3:0]          queue_slave_exp_wid      [$] ;
logic                queue_slave_exp_wlast    [$] ;
logic [15:0]         queue_slave_exp_wstrb    [$] ;

logic [3:0]          queue_master_exp_bid     [$] ;
logic [1:0]          queue_master_exp_bresp   [$] ;

// These two are part of the logical progression (i.e. read req before read data)
logic [3:0]          queue_slave_rx_arid      [$] ;
logic [3:0]          queue_slave_rx_awid      [$] ;
logic [3:0]          queue_slave_rx_wid       [$] ;

task init_read;
  input [31:0] burst_length;
  logic [31:0]         tx_mst_araddr  ;
  logic [1:0]          tx_mst_arburst ;
  logic [3:0]          tx_mst_arid    ;
  logic [7:0]          tx_mst_arlen   ;
  logic [2:0]          tx_mst_arsize  ;
  logic                tx_mst_arvalid ;
  logic                tx_mst_rready  ;

  logic [127:0]        tx_slv_rdata   ;
  logic [3:0]          tx_slv_rid     ;
  logic                tx_slv_rlast   ;
  logic [1:0]          tx_slv_rresp   ;
  logic                tx_slv_rvalid  ;
  logic [7:0] remaining_burst_length;
  begin

    // Randomize these once per transaction
    assert(std::randomize(tx_mst_araddr  ));
    assert(std::randomize(tx_mst_arid    ));

    // Assign these to sane values
    tx_mst_arburst = 0             ; // Always Incr
    tx_mst_arlen   = burst_length-1        ;
    tx_mst_arsize  = 3'b100        ; // 128 bit size

    tx_slv_rid     = tx_mst_arid ;
    tx_slv_rresp   = 0             ; // Everythig is OK


    // Generate 1 beat of AR
    queue_slave_exp_araddr.push_back   ( tx_mst_araddr  ) ;
    queue_master_act_araddr.push_back  ( tx_mst_araddr  ) ;
    queue_slave_exp_arburst.push_back  ( tx_mst_arburst ) ;
    queue_master_act_arburst.push_back ( tx_mst_arburst ) ;
    queue_slave_exp_arid.push_back     ( tx_mst_arid    ) ;
    queue_master_act_arid.push_back    ( tx_mst_arid    ) ;
    queue_slave_exp_arlen.push_back    ( tx_mst_arlen   ) ;
    queue_master_act_arlen.push_back   ( tx_mst_arlen   ) ;
    queue_slave_exp_arsize.push_back   ( tx_mst_arsize  ) ;
    queue_master_act_arsize.push_back  ( tx_mst_arsize  ) ;

    // Generate several beats of R
    remaining_burst_length = burst_length;
    repeat (burst_length)
    begin
      // Randomize Data Ever cycle
      assert(std::randomize(tx_slv_rdata   ));

      queue_master_exp_rid.push_back   ( tx_slv_rid   ) ;
      queue_slave_act_rid.push_back    ( tx_slv_rid   ) ;
      queue_master_exp_rresp.push_back ( tx_slv_rresp ) ;
      queue_slave_act_rresp.push_back  ( tx_slv_rresp ) ;
      queue_master_exp_rdata.push_back ( tx_slv_rdata ) ;
      queue_slave_act_rdata.push_back  ( tx_slv_rdata ) ;

      // build cycle by cycle expected data
      if (remaining_burst_length == 1)
      begin
        queue_master_exp_rlast.push_back ( 1'b1 );
        queue_slave_act_rlast.push_back  ( 1'b1 );
      end
      else
      begin
        queue_master_exp_rlast.push_back ( 1'b0 );
        queue_slave_act_rlast.push_back  ( 1'b0 );
      end

      remaining_burst_length = remaining_burst_length - 1;
    end
  end
endtask

task init_write;
  input [31:0] burst_length;

  logic [31:0]         tx_mst_awaddr  ;
  logic [1:0]          tx_mst_awburst ;
  logic [3:0]          tx_mst_awid    ;
  logic [7:0]          tx_mst_awlen   ;
  logic [2:0]          tx_mst_awsize  ;

  logic [127:0]        tx_mst_wdata   ;
  logic [3:0]          tx_mst_wid     ;
  logic                tx_mst_wlast   ;
  logic [15:0]         tx_mst_wstrb   ;

  logic                tx_slv_arready ;
  logic                tx_slv_awready ;
  logic [3:0]          tx_slv_bid     ;
  logic [1:0]          tx_slv_bresp   ;
  logic                tx_slv_bvalid  ;
  logic                tx_slv_wready  ;

  logic [7:0] remaining_burst_length;
  begin

   // Randomize these once per transaction
   assert(std::randomize(tx_mst_awaddr  ));
   assert(std::randomize(tx_mst_awid    ));
   tx_mst_awburst = 0             ; // Always Incr
   tx_mst_awlen   = burst_length -1        ;
   tx_mst_awsize  = 3'b100        ; // 128 bit size

   tx_mst_wid     =  tx_mst_awid  ; // Same ID as AW

   tx_slv_bid     =  tx_mst_awid  ; // Same ID as AW
   tx_slv_bresp   = 0             ; // Everythig is OK


   // Generate 1 beat of AW
   queue_slave_exp_awaddr.push_back   ( tx_mst_awaddr  ) ;
   queue_master_act_awaddr.push_back  ( tx_mst_awaddr  ) ;
   queue_slave_exp_awburst.push_back  ( tx_mst_awburst ) ;
   queue_master_act_awburst.push_back ( tx_mst_awburst ) ;
   queue_slave_exp_awid.push_back     ( tx_mst_awid    ) ;
   queue_master_act_awid.push_back    ( tx_mst_awid    ) ;
   queue_slave_exp_awlen.push_back    ( tx_mst_awlen   ) ;
   queue_master_act_awlen.push_back   ( tx_mst_awlen   ) ;
   queue_slave_exp_awsize.push_back   ( tx_mst_awsize  ) ;
   queue_master_act_awsize.push_back  ( tx_mst_awsize  ) ;

   // Generate 1 beat of B
   queue_master_exp_bid.push_back     ( tx_slv_bid     ) ;
   queue_slave_act_bid.push_back      ( tx_slv_bid     ) ;
   queue_master_exp_bresp.push_back   ( tx_slv_bresp   ) ;
   queue_slave_act_bresp.push_back    ( tx_slv_bresp   ) ;

    // Generate several beats of W
    remaining_burst_length = burst_length;
    repeat (burst_length)
    begin
      // Randomize Data Ever cycle

      assert(std::randomize( tx_mst_wdata ));
      assert(std::randomize( tx_mst_wstrb ));

      queue_slave_exp_wdata.push_back  ( tx_mst_wdata ) ;
      queue_master_act_wdata.push_back ( tx_mst_wdata ) ;
      queue_slave_exp_wid.push_back    ( tx_mst_wid   ) ;
      queue_master_act_wid.push_back   ( tx_mst_wid   ) ;
      queue_slave_exp_wstrb.push_back  ( tx_mst_wstrb ) ;
      queue_master_act_wstrb.push_back ( tx_mst_wstrb ) ;

      // build cycle by cycle expected data
      if (remaining_burst_length == 1)
      begin
        queue_slave_exp_wlast.push_back  ( 1'b1 );
        queue_master_act_wlast.push_back ( 1'b1 );
      end
      else
      begin
        queue_slave_exp_wlast.push_back  ( 1'b0 );
        queue_master_act_wlast.push_back ( 1'b0 );
      end

      remaining_burst_length = remaining_burst_length - 1;
    end
  end
endtask

// Transaction Queueing
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Channel Initiators

// AR
always @(posedge clk_wr)
while (queue_master_act_arid.size())
begin
   user1_araddr  <= queue_master_act_araddr.pop_front();
   user1_arburst <= queue_master_act_arburst.pop_front();
   user1_arid    <= queue_master_act_arid.pop_front();
   user1_arlen   <= queue_master_act_arlen.pop_front();
   user1_arsize  <= queue_master_act_arsize.pop_front();
   user1_arvalid <= 1'b1 ;

   @(negedge clk_wr);
   while (user1_arready == 1'b0) @(negedge clk_wr);
   @(posedge clk_wr);

   user1_araddr  <= '0;
   user1_arburst <= '0;
   user1_arid    <= '0;
   user1_arlen   <= '0;
   user1_arsize  <= '0;
   user1_arvalid <= '0;

end

// AW
always @(posedge clk_wr)
while (queue_master_act_awid.size())
begin
   user1_awaddr  <= queue_master_act_awaddr.pop_front();
   user1_awburst <= queue_master_act_awburst.pop_front();
   user1_awid    <= queue_master_act_awid.pop_front();
   user1_awlen   <= queue_master_act_awlen.pop_front();
   user1_awsize  <= queue_master_act_awsize.pop_front();
   user1_awvalid <= 1'b1 ;

   @(negedge clk_wr);
   while (user1_awready == 1'b0) @(negedge clk_wr);
   @(posedge clk_wr);

   user1_awaddr  <= '0;
   user1_awburst <= '0;
   user1_awid    <= '0;
   user1_awlen   <= '0;
   user1_awsize  <= '0;
   user1_awvalid <= '0;
end

// W
always @(posedge clk_wr)
while (queue_master_act_wid.size())
begin
   user1_wdata  <= queue_master_act_wdata.pop_front();
   user1_wid    <= queue_master_act_wid.pop_front();
   user1_wlast  <= queue_master_act_wlast.pop_front();
   user1_wvalid <= 1'b1 ;

   @(negedge clk_wr);
   while (user1_wready == 1'b0) @(negedge clk_wr);
   @(posedge clk_wr);

   user1_wdata  <= '0;
   user1_wid    <= '0;
   user1_wlast  <= '0;
   user1_wvalid <= '0;
end

// R
always @(posedge clk_wr)
while (queue_slave_act_rid.size() && queue_slave_rx_arid.size())
begin
   void'(queue_slave_rx_arid.pop_front());
   user2_rdata  <= queue_slave_act_rdata.pop_front();
   user2_rid    <= queue_slave_act_rid.pop_front();
   user2_rlast  <= queue_slave_act_rlast.pop_front();
   user2_rresp  <= queue_slave_act_rresp.pop_front();
   user2_rvalid <= 1'b1 ;

   @(negedge clk_wr);
   while (user2_rready == 1'b0) @(negedge clk_wr);
   @(posedge clk_wr);

   user2_rdata  <= '0;
   user2_rid    <= '0;
   user2_rlast  <= '0;
   user2_rresp  <= '0;
   user2_rvalid <= '0;
end

// B
always @(posedge clk_wr)
while (queue_slave_act_bid.size() && queue_slave_rx_awid.size() && queue_slave_rx_wid.size())
begin
   void'(queue_slave_rx_awid.pop_front());
   void'(queue_slave_rx_wid.pop_front());
   user2_bresp  <= queue_slave_act_bresp.pop_front();
   user2_bid    <= queue_slave_act_bid.pop_front();
   user2_bvalid <= 1'b1 ;

   @(negedge clk_wr);
   while (user2_bready == 1'b0) @(negedge clk_wr);
   @(posedge clk_wr);

   user2_bresp  <= '0;
   user2_bid    <= '0;
   user2_bvalid <= '0;
end

// Channel Initiators
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Randomize User Readys

logic [7:0] rand_percent_arready_delay;
logic [7:0] rand_percent_awready_delay;
logic [7:0] rand_percent_wready_delay;
logic [7:0] rand_percent_rready_delay;
logic [7:0] rand_percent_bready_delay;

logic [7:0] rand_arready_delay_value;
logic [7:0] rand_awready_delay_value;
logic [7:0] rand_wready_delay_value;
logic [7:0] rand_rready_delay_value;
logic [7:0] rand_bready_delay_value;


always @(posedge clk_wr)
begin
  rand_arready_delay_value = $urandom_range(1,100);
  rand_percent_arready_delay = $urandom_range(1,100);

  user2_arready <= disable_ds_flowcontrol ? 1'b1 : (rand_percent_arready_delay > 50);

  repeat (rand_arready_delay_value) @(posedge clk_wr);
end

always @(posedge clk_wr)
begin
  rand_awready_delay_value = $urandom_range(1,100);
  rand_percent_awready_delay = $urandom_range(1,100);

  user2_awready <= disable_ds_flowcontrol ? 1'b1 : (rand_percent_awready_delay > 50);

  repeat (rand_awready_delay_value) @(posedge clk_wr);
end

always @(posedge clk_wr)
begin
  rand_wready_delay_value = $urandom_range(1,100);
  rand_percent_wready_delay = $urandom_range(1,100);

  user2_wready <= disable_ds_flowcontrol ? 1'b1 : (rand_percent_wready_delay > 50);

  repeat (rand_wready_delay_value) @(posedge clk_wr);
end

always @(posedge clk_wr)
begin
  rand_rready_delay_value = $urandom_range(1,100);
  rand_percent_rready_delay = $urandom_range(1,100);

  user1_rready <= disable_ds_flowcontrol ? 1'b1 : (rand_percent_rready_delay > 50);

  repeat (rand_rready_delay_value) @(posedge clk_wr);
end

always @(posedge clk_wr)
begin
  rand_bready_delay_value = $urandom_range(1,100);
  rand_percent_bready_delay = $urandom_range(1,100);

  user1_bready <= disable_ds_flowcontrol ? 1'b1 : (rand_percent_bready_delay > 50);

  repeat (rand_bready_delay_value) @(posedge clk_wr);
end

// Randomize User Readys
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Channel Receivers

// AR
always @(posedge clk_wr)
if (user2_arvalid && user2_arready)
begin
   if ( (user2_araddr  !== queue_slave_exp_araddr[0]  ) ||
        (user2_arburst !== queue_slave_exp_arburst[0] ) ||
        (user2_arid    !== queue_slave_exp_arid[0]    ) ||
        (user2_arlen   !== queue_slave_exp_arlen[0]   ) ||
        (user2_arsize  !== queue_slave_exp_arsize[0]  ) )
   begin
     $display ("ERROR In AR Receive at time %t", $time);
     $display ("   user2_araddr    act:%x  exp:%x", user2_araddr , queue_slave_exp_araddr[0]  );
     $display ("   user2_arburst   act:%x  exp:%x", user2_arburst, queue_slave_exp_arburst[0] );
     $display ("   user2_arid      act:%x  exp:%x", user2_arid   , queue_slave_exp_arid[0]    );
     $display ("   user2_arlen     act:%x  exp:%x", user2_arlen  , queue_slave_exp_arlen[0]   );
     $display ("   user2_arsize    act:%x  exp:%x", user2_arsize , queue_slave_exp_arsize[0]  );
     NUMBER_FAILED = NUMBER_FAILED + 1;
     finish_simulation;
   end
   else
     NUMBER_PASSED = NUMBER_PASSED + 1;

   // Tell TB we received the AR and we should send a arlen beats of data
   repeat (user2_arlen + 1)
     queue_slave_rx_arid.push_back(user2_arid);

   void'(queue_slave_exp_araddr.pop_front()  );
   void'(queue_slave_exp_arburst.pop_front() );
   void'(queue_slave_exp_arid.pop_front()    );
   void'(queue_slave_exp_arlen.pop_front()   );
   void'(queue_slave_exp_arsize.pop_front()  );
end

// AW
always @(posedge clk_wr)
if (user2_awvalid && user2_awready)
begin
   if ( (user2_awaddr  !== queue_slave_exp_awaddr[0]  ) ||
        (user2_awburst !== queue_slave_exp_awburst[0] ) ||
        (user2_awid    !== queue_slave_exp_awid[0]    ) ||
        (user2_awlen   !== queue_slave_exp_awlen[0]   ) ||
        (user2_awsize  !== queue_slave_exp_awsize[0]  ) )
   begin
     $display ("ERROR In aw Receive at time %t", $time);
     $display ("   user2_awaddr    act:%x  exp:%x", user2_awaddr , queue_slave_exp_awaddr[0]  );
     $display ("   user2_awburst   act:%x  exp:%x", user2_awburst, queue_slave_exp_awburst[0] );
     $display ("   user2_awid      act:%x  exp:%x", user2_awid   , queue_slave_exp_awid[0]    );
     $display ("   user2_awlen     act:%x  exp:%x", user2_awlen  , queue_slave_exp_awlen[0]   );
     $display ("   user2_awsize    act:%x  exp:%x", user2_awsize , queue_slave_exp_awsize[0]  );
     NUMBER_FAILED = NUMBER_FAILED + 1;
     finish_simulation;
   end
   else
     NUMBER_PASSED = NUMBER_PASSED + 1;

   // Tell TB we received the aw
   queue_slave_rx_awid.push_back(queue_slave_exp_awid[0]);

   void'(queue_slave_exp_awaddr.pop_front()  );
   void'(queue_slave_exp_awburst.pop_front() );
   void'(queue_slave_exp_awid.pop_front()    );
   void'(queue_slave_exp_awlen.pop_front()   );
   void'(queue_slave_exp_awsize.pop_front()  );
end

// W
always @(posedge clk_wr)
if (user2_wvalid && user2_wready)
begin
   if ( (user2_wdata !== queue_slave_exp_wdata[0]  ) ||
        (user2_wid   !== queue_slave_exp_wid[0]    ) ||
        (user2_wlast !== queue_slave_exp_wlast[0]  ) )
   begin
     $display ("ERROR In w Receive at time %t", $time);
     $display ("   user2_wdata    act:%x  exp:%x", user2_wdata , queue_slave_exp_wdata[0]  );
     $display ("   user2_wid      act:%x  exp:%x", user2_wid   , queue_slave_exp_wid[0]    );
     $display ("   user2_wlast    act:%x  exp:%x", user2_wlast , queue_slave_exp_wlast[0]  );
     NUMBER_FAILED = NUMBER_FAILED + 1;
     finish_simulation;
   end
   else
     NUMBER_PASSED = NUMBER_PASSED + 1;

   // Tell TB we received the wlast so we can send B
   if (user2_wlast)
     queue_slave_rx_wid.push_back(queue_slave_exp_wid[0]);

   void'(queue_slave_exp_wdata.pop_front()  );
   void'(queue_slave_exp_wid.pop_front()    );
   void'(queue_slave_exp_wlast.pop_front()  );
end

// R
always @(posedge clk_wr)
if (user1_rvalid && user1_rready)
begin
   if ( (user1_rdata  !== queue_master_exp_rdata [0] ) ||
        (user1_rid    !== queue_master_exp_rid   [0] ) ||
        (user1_rlast  !== queue_master_exp_rlast [0] ) ||
        (user1_rresp  !== queue_master_exp_rresp [0] ) )
   begin
     $display ("ERROR In r Receive at time %t", $time);
     $display ("   user1_rdata   act:%x  exp:%x", user1_rdata, queue_master_exp_rdata [0]  );
     $display ("   user1_rid     act:%x  exp:%x", user1_rid  , queue_master_exp_rid   [0]  );
     $display ("   user1_rlast   act:%x  exp:%x", user1_rlast, queue_master_exp_rlast [0]  );
     $display ("   user1_rresp   act:%x  exp:%x", user1_rresp, queue_master_exp_rresp [0]  );
     NUMBER_FAILED = NUMBER_FAILED + 1;
     finish_simulation;
   end
   else
     NUMBER_PASSED = NUMBER_PASSED + 1;

   void'(queue_master_exp_rdata.pop_front()  );
   void'(queue_master_exp_rid.pop_front() );
   void'(queue_master_exp_rlast.pop_front()    );
   void'(queue_master_exp_rresp.pop_front()  );
end

// B
always @(posedge clk_wr)
if (user1_bvalid && user1_bready)
begin
   if ( (user1_bresp !== queue_master_exp_bresp [0] ) ||
        (user1_bid   !== queue_master_exp_bid   [0] ) )
   begin
     $display ("ERROR In b Receive at time %t", $time);
     $display ("   user1_bresp   act:%x  exp:%x", user1_bresp, queue_master_exp_bresp [0] );
     $display ("   user1_bid     act:%x  exp:%x", user1_bid  , queue_master_exp_bid   [0] );
     NUMBER_FAILED = NUMBER_FAILED + 1;
     finish_simulation;
   end
   else
     NUMBER_PASSED = NUMBER_PASSED + 1;

   void'(queue_master_exp_bresp.pop_front()  );
   void'(queue_master_exp_bid.pop_front() );
end


// Channel Receivers
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// General functions

task wait_until_empty;

integer wait_timeout;

begin
  wait_timeout = 1_000_000;

  fork
    begin
      wait (
             // Initiators
             (queue_master_act_arid.size () == 0) &&
             (queue_master_act_awid.size () == 0) &&
             (queue_master_act_wid.size  () == 0) &&

             (queue_slave_act_bid.size   () == 0) &&
             (queue_slave_act_rid.size   () == 0) &&
             (queue_slave_act_bid.size   () == 0) &&

             // Receivers
             (queue_slave_exp_arid.size  () == 0) &&
             (queue_slave_exp_awid.size  () == 0) &&
             (queue_slave_exp_wid.size   () == 0) &&

             (queue_master_exp_bid.size  () == 0) &&
             (queue_master_exp_rid.size  () == 0) &&

             // AXI sequencer (shouldn't return read data until read req recieved)
             (queue_slave_rx_arid.size   () == 0) &&
             (queue_slave_rx_awid.size   () == 0) &&
             (queue_slave_rx_wid.size    () == 0) );

    end

    begin
      @(posedge clk_wr);
      while (wait_timeout > 0)
      begin
        wait_timeout = wait_timeout - 1;
        @(posedge clk_wr);
      end
    end
  join_any

  if (wait_timeout <= 0)
  begin
    $display ("ERROR Timeout waiting for quiescence at time %t", $time);
    $display ("// Initiators");
    $display ("   queue_master_act_arid.size () = %d", queue_master_act_arid.size () );
    $display ("   queue_master_act_awid.size () = %d", queue_master_act_awid.size () );
    $display ("   queue_master_act_wid.size  () = %d", queue_master_act_wid.size  () );
    $display ("");
    $display ("   queue_slave_act_bid.size   () = %d", queue_slave_act_bid.size () );
    $display ("   queue_slave_act_rid.size   () = %d", queue_slave_act_rid.size () );
    $display ("   queue_slave_act_bid.size   () = %d", queue_slave_act_bid.size () );
    $display ("");
    $display ("// Receivers");
    $display ("   queue_slave_exp_arid.size  () = %d", queue_slave_exp_arid.size () );
    $display ("   queue_slave_exp_awid.size  () = %d", queue_slave_exp_awid.size () );
    $display ("   queue_slave_exp_wid.size   () = %d", queue_slave_exp_wid.size  () );
    $display ("");
    $display ("   queue_master_exp_bid.size  () = %d", queue_master_exp_bid.size () );
    $display ("   queue_master_exp_rid.size  () = %d", queue_master_exp_rid.size () );
    $display ("");
    $display ("// AXI sequence");
    $display ("   queue_slave_rx_arid.size   () = %d", queue_slave_rx_arid.size   () );
    $display ("   queue_slave_rx_awid.size   () = %d", queue_slave_rx_awid.size   () );
    $display ("   queue_slave_rx_wid.size    () = %d", queue_slave_rx_wid.size    () );
    NUMBER_FAILED = NUMBER_FAILED + 1;
    finish_simulation;
  end
  else
    NUMBER_PASSED = NUMBER_PASSED + 1;

end
endtask



















//`include "useful_functions.vh"

// Local Variables:
// verilog-library-directories:("../*" "../../*" "../script/premade_examples/*/")
// End:
//


endmodule

