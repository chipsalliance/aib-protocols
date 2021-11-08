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

module axi_st_d256_gen1_gen2_tb ();

`define ENABLE_PHASE_01 1               // Simple, non overlapping minimum sized transfers
`define ENABLE_PHASE_02 1               // Overlapping minimum sized transfers
`define ENABLE_PHASE_03 1               // Simple, non overlapping medium sized transfers
`define ENABLE_PHASE_04 1               // Overlapping medium transfers
`define ENABLE_PHASE_05 1               // Simple, non overlapping large sized transfers
`define ENABLE_PHASE_06 1               // Overlapping large transfers
`define ENABLE_PHASE_07 1               // Random size, packets
`define ENABLE_PHASE_08 1               // Overlapping large transfers with no flowcontrol from downstream
`define ENABLE_PHASE_09 1               // Gen1 Simple, non overlapping minimum sized transfers
`define ENABLE_PHASE_10 1               // Gen1 Random size, packets
`define ENABLE_PHASE_11 1               // Gen1 Overlapping large transfers with no flowcontrol from downstream

`define DATA_DEBUG 0            // If 1, data is less random, more incrementing patterns.

`define PHY_LATENCY 0

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
parameter CLK_HALF_CYCLE = 0.25 * 2;
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
    $shm_probe( axi_st_d256_gen1_gen2_tb, "AMCTF");
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
   logic [31:0]		rx_st_debug_status;	// From axi_st_slave_top_i of axi_st_d256_gen1_gen2_slave_top.v
   logic [159:0]	tx_phy_master_0;	// From axi_st_master_top_i of axi_st_d256_gen1_gen2_master_top.v
   logic [159:0]	tx_phy_master_1;	// From axi_st_master_top_i of axi_st_d256_gen1_gen2_master_top.v
   logic [159:0]	tx_phy_slave_0;		// From axi_st_slave_top_i of axi_st_d256_gen1_gen2_slave_top.v
   logic [159:0]	tx_phy_slave_1;		// From axi_st_slave_top_i of axi_st_d256_gen1_gen2_slave_top.v
   logic [31:0]		tx_st_debug_status;	// From axi_st_master_top_i of axi_st_d256_gen1_gen2_master_top.v
   logic		user1_tready;		// From axi_st_master_top_i of axi_st_d256_gen1_gen2_master_top.v
   logic [255:0]	user2_tdata;		// From axi_st_slave_top_i of axi_st_d256_gen1_gen2_slave_top.v
   logic [31:0]		user2_tkeep;		// From axi_st_slave_top_i of axi_st_d256_gen1_gen2_slave_top.v
   logic		user2_tlast;		// From axi_st_slave_top_i of axi_st_d256_gen1_gen2_slave_top.v
   logic		user2_tvalid;		// From axi_st_slave_top_i of axi_st_d256_gen1_gen2_slave_top.v
   // End of automatics

   //-----------------------
   //-- REG DECLARATIONS --
   //-----------------------
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   logic		m_gen2_mode=0;		// To axi_st_master_top_i of axi_st_d256_gen1_gen2_master_top.v, ...
   logic [159:0]	rx_phy_master_0=0;	// To axi_st_master_top_i of axi_st_d256_gen1_gen2_master_top.v
   logic [159:0]	rx_phy_master_1=0;	// To axi_st_master_top_i of axi_st_d256_gen1_gen2_master_top.v
   logic [159:0]	rx_phy_slave_0=0;		// To axi_st_slave_top_i of axi_st_d256_gen1_gen2_slave_top.v
   logic [159:0]	rx_phy_slave_1=0;		// To axi_st_slave_top_i of axi_st_d256_gen1_gen2_slave_top.v
   logic [255:0]	user1_tdata=0;		// To axi_st_master_top_i of axi_st_d256_gen1_gen2_master_top.v
   logic [31:0]		user1_tkeep=0;		// To axi_st_master_top_i of axi_st_d256_gen1_gen2_master_top.v
   logic		user1_tlast=0;		// To axi_st_master_top_i of axi_st_d256_gen1_gen2_master_top.v
   logic		user1_tvalid=0;		// To axi_st_master_top_i of axi_st_d256_gen1_gen2_master_top.v
   logic		user2_tready=0;		// To axi_st_slave_top_i of axi_st_d256_gen1_gen2_slave_top.v
   // End of automatics

   initial m_gen2_mode = 1;

   /* axi_st_d256_gen1_gen2_master_top AUTO_TEMPLATE (
      .user_\(.*\)			(user1_\1[]),

      .init_st_credit			(8'd0),

      .rx_online			(1'b1), // Tied ONLINE high
      .tx_online			(1'b1), // Tied ONLINE high

      .delay_x_value                    (MASTER_DELAY_X_VALUE),
      .delay_y_value                    (MASTER_DELAY_Y_VALUE),
      .delay_z_value                    (MASTER_DELAY_Z_VALUE),

      .tx_phy\(.\)                      (tx_phy_master_\1[]),
      .rx_phy\(.\)			(rx_phy_master_\1[]),
    );
    */
   axi_st_d256_gen1_gen2_master_top axi_st_master_top_i
     (/*AUTOINST*/
      // Outputs
      .tx_phy0				(tx_phy_master_0[159:0]), // Templated
      .tx_phy1				(tx_phy_master_1[159:0]), // Templated
      .user_tready			(user1_tready),		 // Templated
      .tx_st_debug_status		(tx_st_debug_status[31:0]),
      // Inputs
      .clk_wr				(clk_wr),
      .rst_wr_n				(rst_wr_n),
      .tx_online			(1'b1),			 // Templated
      .rx_online			(1'b1),			 // Templated
      .init_st_credit			(8'd64),		 // Templated
      .rx_phy0				(rx_phy_master_0[159:0]), // Templated
      .rx_phy1				(rx_phy_master_1[159:0]), // Templated
      .user_tkeep			(user1_tkeep[31:0]),	 // Templated
      .user_tdata			(user1_tdata[255:0]),	 // Templated
      .user_tlast			(user1_tlast),		 // Templated
      .user_tvalid			(user1_tvalid),		 // Templated
      .m_gen2_mode			(m_gen2_mode),
      .delay_x_value                    (MASTER_DELAY_X_VALUE),
      .delay_y_value                    (MASTER_DELAY_Y_VALUE),
      .delay_z_value                    (MASTER_DELAY_Z_VALUE));


   /* axi_st_d256_gen1_gen2_slave_top AUTO_TEMPLATE (
      .user_\(.*\)			(user2_\1[]),

      .rx_online			(1'b1), // Tied ONLINE high
      .tx_online			(1'b1), // Tied ONLINE high

      .delay_x_value                    (SLAVE_DELAY_X_VALUE),
      .delay_y_value                    (SLAVE_DELAY_Y_VALUE),
      .delay_z_value                    (SLAVE_DELAY_Z_VALUE),

      .tx_phy\(.\)                      (tx_phy_slave_\1[]),
      .rx_phy\(.\)			(rx_phy_slave_\1[]),
    );
    */
   axi_st_d256_gen1_gen2_slave_top axi_st_slave_top_i
     (/*AUTOINST*/
      // Outputs
      .tx_phy0				(tx_phy_slave_0[159:0]), // Templated
      .tx_phy1				(tx_phy_slave_1[159:0]), // Templated
      .user_tkeep			(user2_tkeep[31:0]),	 // Templated
      .user_tdata			(user2_tdata[255:0]),	 // Templated
      .user_tlast			(user2_tlast),		 // Templated
      .user_tvalid			(user2_tvalid),		 // Templated
      .rx_st_debug_status		(rx_st_debug_status[31:0]),
      // Inputs
      .clk_wr				(clk_wr),
      .rst_wr_n				(rst_wr_n),
      .tx_online			(1'b1),			 // Templated
      .rx_online			(1'b1),			 // Templated
      .rx_phy0				(rx_phy_slave_0[159:0]), // Templated
      .rx_phy1				(rx_phy_slave_1[159:0]), // Templated
      .user_tready			(user2_tready),		 // Templated
      .m_gen2_mode			(m_gen2_mode),
      .delay_x_value                    (SLAVE_DELAY_X_VALUE),
      .delay_y_value                    (SLAVE_DELAY_Y_VALUE),
      .delay_z_value                    (SLAVE_DELAY_Z_VALUE));


localparam TX_PHY_LATENCY = `PHY_LATENCY; // This number equates to how many clk_wr cycles it takes to go from the data (MAC) input of one PHY to the data (MAC) output of the other PHY.
logic [159:0] tx_master_phy0_delay_array [$];
logic [159:0] tx_master_phy1_delay_array [$];
logic [159:0] tx_slave_phy0_delay_array  [$];
logic [159:0] tx_slave_phy1_delay_array  [$];

initial
begin
  #1;
  repeat (TX_PHY_LATENCY)
  begin
    tx_master_phy0_delay_array.push_back ( 160'h0 ) ;
    tx_master_phy1_delay_array.push_back ( 160'h0 ) ;

    tx_slave_phy0_delay_array.push_back  ( 160'h0 ) ;
    tx_slave_phy1_delay_array.push_back  ( 160'h0 ) ;
  end
end


always @(posedge clk_wr)
begin
  if (m_gen2_mode)
  begin
    tx_master_phy0_delay_array.push_back ( tx_phy_master_0[159:0] ) ;
    tx_master_phy1_delay_array.push_back ( tx_phy_master_1[159:0] ) ;

    tx_slave_phy0_delay_array.push_back  ( tx_phy_slave_0[159:0]  ) ;
    tx_slave_phy1_delay_array.push_back  ( tx_phy_slave_1[159:0]  ) ;
  end
  else // Gen 1
  begin
    tx_master_phy0_delay_array.push_back ( tx_phy_master_0[39:0] ) ;
    tx_master_phy1_delay_array.push_back ( tx_phy_master_1[39:0] ) ;

    tx_slave_phy0_delay_array.push_back  ( tx_phy_slave_0[39:0]  ) ;
    tx_slave_phy1_delay_array.push_back  ( tx_phy_slave_1[39:0]  ) ;
  end

  rx_phy_slave_0[159:0]  <= tx_master_phy0_delay_array.pop_front()  ;
  rx_phy_slave_1[159:0]  <= tx_master_phy1_delay_array.pop_front()  ;

  rx_phy_master_0[159:0] <= tx_slave_phy0_delay_array.pop_front() ;
  rx_phy_master_1[159:0] <= tx_slave_phy1_delay_array.pop_front() ;
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
      // Send minimal sized write
      init_data(1);
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
      // Send minimal sized write
      init_data(1);
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
      // Send medium sized write
      init_data(10);
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
      // Send medium sized write
      init_data(10);
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
      // Send max sized write
      init_data(256);
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
      // Send max sized write
      init_data(256);
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
      init_data ( $urandom_range(1,256) );
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
      init_data  ( 256 );
      -> sub_phase_trig;
    end
    wait_until_empty();

    disable_us_performance_cap = 0;
    disable_ds_flowcontrol = 0;
    repeat (100) @(posedge clk_wr);

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge clk_wr);
  end

  if (`ENABLE_PHASE_09)
  begin
    TestPhase = 9 ;
    repeat (100) @(posedge clk_wr);
    m_gen2_mode = 0;
    repeat (100) @(posedge clk_wr);

    repeat (20)
    begin
      // Send minimal sized write
      init_data(1);
      wait_until_empty();
      repeat (100) @(posedge clk_wr);
      -> sub_phase_trig;
    end

    wait_until_empty();

    repeat (100) @(posedge clk_wr);
    m_gen2_mode = 1;
    repeat (100) @(posedge clk_wr);

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge clk_wr);
  end

  if (`ENABLE_PHASE_10)
  begin
    TestPhase = 10 ;
    repeat (100) @(posedge clk_wr);
    m_gen2_mode = 0;
    repeat (100) @(posedge clk_wr);

    disable_us_performance_cap = 1;
    repeat (100) @(posedge clk_wr);

    repeat (20)
    begin
      init_data ( $urandom_range(1,256) );
      -> sub_phase_trig;
    end

    // This takes a while (so long it triggers timeout)
    // So we'll add a longish wait.
    repeat (100_000) @(posedge clk_wr);
    wait_until_empty();

    disable_us_performance_cap = 0;
    repeat (100) @(posedge clk_wr);
    m_gen2_mode = 1;
    repeat (100) @(posedge clk_wr);


    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge clk_wr);
  end

  if (`ENABLE_PHASE_11)
  begin
    TestPhase = 11 ;
    repeat (100) @(posedge clk_wr);
    m_gen2_mode = 0;
    repeat (100) @(posedge clk_wr);

    disable_ds_flowcontrol = 1;
    disable_us_performance_cap = 1;
    repeat (100) @(posedge clk_wr);

    repeat (20)
    begin
      init_data  ( 256 );
      -> sub_phase_trig;
    end
    wait_until_empty();

    disable_us_performance_cap = 0;
    disable_ds_flowcontrol = 0;
    repeat (100) @(posedge clk_wr);
    m_gen2_mode = 1;
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

logic [63:0]         pseudo_rand_iteration = 0;

logic [255:0]         queue_master_act_tdata   [$] ;
logic [31:0]          queue_master_act_tkeep   [$] ;
logic                queue_master_act_tlast   [$] ;

logic [255:0]         queue_slave_exp_tdata   [$] ;
logic [31:0]          queue_slave_exp_tkeep   [$] ;
logic                queue_slave_exp_tlast   [$] ;

task init_data;
  input [31:0] burst_length;

  logic [255:0]        tx_mst_tdata   ;
  logic [31:0]         tx_mst_tkeep   ;
  logic               tx_mst_tlast   ;

  logic [7:0] remaining_burst_length;
  begin
    tx_mst_tdata = pseudo_rand_iteration  ;
    tx_mst_tkeep = pseudo_rand_iteration  ;
    tx_mst_tlast = pseudo_rand_iteration  ;
    pseudo_rand_iteration = pseudo_rand_iteration + 1;

    // Generate several beats of W
    remaining_burst_length = burst_length;
    repeat (burst_length)
    begin
      // Randomize Data Ever cycle

      if (`DATA_DEBUG)
      begin
        tx_mst_tdata = tx_mst_tdata + 1;
        tx_mst_tkeep = tx_mst_tkeep + 1;
        tx_mst_tlast = tx_mst_tlast + 1;
      end
      else
      begin
        assert(std::randomize( tx_mst_tdata ));
        assert(std::randomize( tx_mst_tkeep ));
        assert(std::randomize( tx_mst_tlast ));
      end

      queue_master_act_tdata.push_back  ( tx_mst_tdata ) ;
      queue_slave_exp_tdata.push_back   ( tx_mst_tdata ) ;
      queue_master_act_tkeep.push_back  ( tx_mst_tkeep ) ;
      queue_slave_exp_tkeep.push_back   ( tx_mst_tkeep ) ;

      // build cycle by cycle expected data
      if (remaining_burst_length == 1)
      begin
        queue_slave_exp_tlast.push_back  ( 1'b1 );
        queue_master_act_tlast.push_back ( 1'b1 );
      end
      else
      begin
        queue_slave_exp_tlast.push_back  ( 1'b0 );
        queue_master_act_tlast.push_back ( 1'b0 );
      end

      remaining_burst_length = remaining_burst_length - 1;
    end
  end
endtask

// Transaction Queueing
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Channel Initiators

// ST
always @(posedge clk_wr)
while (queue_master_act_tkeep.size())
begin
   user1_tdata  <= queue_master_act_tdata.pop_front();
   user1_tkeep  <= queue_master_act_tkeep.pop_front();
   user1_tlast  <= queue_master_act_tlast.pop_front();
   user1_tvalid <= 1'b1 ;

   @(negedge clk_wr);
   while (user1_tready == 1'b0) @(negedge clk_wr);
   @(posedge clk_wr);

   user1_tdata  <= '0;
   user1_tkeep  <= '0;
   user1_tlast  <= '0;
   user1_tvalid <= '0;
end

// Channel Initiators
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Randomize User Readys

logic [7:0] rand_percent_tready_delay;

logic [7:0] rand_tready_delay_value;


always @(posedge clk_wr)
begin
  rand_tready_delay_value = $urandom_range(1,100);
  rand_percent_tready_delay = $urandom_range(1,100);

  user2_tready <= disable_ds_flowcontrol ? 1'b1 : (rand_percent_tready_delay > 50);

  repeat (rand_tready_delay_value) @(posedge clk_wr);
end

// Randomize User Readys
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Channel Receivers

always @(posedge clk_wr)
if (user2_tvalid && user2_tready)
begin
   if (m_gen2_mode)
   begin
     if ( (user2_tdata !== queue_slave_exp_tdata[0]  ) ||
          (user2_tkeep !== queue_slave_exp_tkeep[0]  ) ||
          (user2_tlast !== queue_slave_exp_tlast[0]  ) )
     begin
       $display ("ERROR ST Receive at time %t", $time);
       $display ("   user2_tdata    act:%x  exp:%x", user2_tdata , queue_slave_exp_tdata[0]  );
       $display ("   user2_tkeep    act:%x  exp:%x", user2_tkeep , queue_slave_exp_tkeep[0]  );
       $display ("   user2_tlast    act:%x  exp:%x", user2_tlast , queue_slave_exp_tlast[0]  );
       NUMBER_FAILED = NUMBER_FAILED + 1;
       finish_simulation;
     end
     else
       NUMBER_PASSED = NUMBER_PASSED + 1;
   end
   else // Gen 1
   begin
     if ( (user2_tdata[63:0] !== queue_slave_exp_tdata[0][63:0]  ) ||
          (user2_tkeep[7:0]  !== queue_slave_exp_tkeep[0][7:0]   ) )
     begin
       $display ("ERROR ST Receive at time %t", $time);
       $display ("   user2_tdata    act:%x  exp:%x", user2_tdata[63:0] , queue_slave_exp_tdata[0][63:0]  );
       $display ("   user2_tkeep    act:%x  exp:%x", user2_tkeep[7:0] , queue_slave_exp_tkeep[0][7:0]  );
       NUMBER_FAILED = NUMBER_FAILED + 1;
       finish_simulation;
     end
     else
         NUMBER_PASSED = NUMBER_PASSED + 1;
   end


   void'(queue_slave_exp_tdata.pop_front()  );
   void'(queue_slave_exp_tkeep.pop_front()  );
   void'(queue_slave_exp_tlast.pop_front()  );
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
             (queue_master_act_tkeep.size  () == 0) &&
             (queue_slave_exp_tkeep.size   () == 0) );

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
    $display ("   queue_master_act_tkeep.size  () = %d", queue_master_act_tkeep.size  () );
    $display ("");
    $display ("// Receivers");
    $display ("   queue_slave_exp_tkeep.size   () = %d", queue_slave_exp_tkeep.size  () );
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

