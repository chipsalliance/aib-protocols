
// Very simple AXI MM touch test.
// Uses unmodified version of ../script/cfg/axi_mm_a32_d256.cfg configuration.
// See config file for details. Changing the config file will likely break TB.
//
// Trigger a few simple transactions.
//
// Note, that config us Full Gen2, so m_wr_clk = 2GHz.
// This is logic link to logic link.
// AIB is not shown, but should be generally an opaque transfer of the PHY signals.

`timescale 1ns/1ps

module axi_st_d256_multichannel_tb ();

`define ENABLE_PHASE_01 1               // Simple, non overlapping minimum sized transfers
`define ENABLE_PHASE_02 1               // Overlapping minimum sized transfers
`define ENABLE_PHASE_03 1               // Simple, non overlapping medium sized transfers
`define ENABLE_PHASE_04 1               // Overlapping medium transfers
`define ENABLE_PHASE_05 1               // Simple, non overlapping large sized transfers
`define ENABLE_PHASE_06 1               // Overlapping large transfers
`define ENABLE_PHASE_07 1               // Random size, packets
`define ENABLE_PHASE_08 1               // Overlapping large transfers with no flowcontrol from downstream
`define ENABLE_PHASE_09 1               // FIFO Corner Case

`define DATA_DEBUG 1            // If 1, data is less random, more incrementing patterns.


parameter FULL          = 4'h1;
parameter HALF          = 4'h2;
parameter QUARTER       = 4'h4;

// Note, we use 1,2,4 to encode Full, Half, Quarter rate, respecitvely.
// Also we standardized on 4 bit wide for ... reasons.

parameter MASTER_RATE = FULL;
parameter SLAVE_RATE  = HALF;

// This needs to stay in sync with the confguration. The marker should be within a 80 bit per chunk
parameter CHAN_M2S_MARKER_LOC = 8'd39;
parameter CHAN_S2M_MARKER_LOC = 8'd39;

`define TX_INIT_CREDIT 8'd128

// This determines how long it takes for Word Markers to Align int he RX
localparam CHAN_0_M2S_DLL_TIME = 8'd10;
localparam CHAN_1_M2S_DLL_TIME = 8'd10;
localparam CHAN_2_M2S_DLL_TIME = 8'd10;
localparam CHAN_3_M2S_DLL_TIME = 8'd10;
localparam CHAN_4_M2S_DLL_TIME = 8'd10;
localparam CHAN_5_M2S_DLL_TIME = 8'd10;
localparam CHAN_6_M2S_DLL_TIME = 8'd10;

localparam CHAN_0_S2M_DLL_TIME = 8'd10;
localparam CHAN_1_S2M_DLL_TIME = 8'd10;
localparam CHAN_2_S2M_DLL_TIME = 8'd10;
localparam CHAN_3_S2M_DLL_TIME = 8'd10;
localparam CHAN_4_S2M_DLL_TIME = 8'd10;
localparam CHAN_5_S2M_DLL_TIME = 8'd10;
localparam CHAN_6_S2M_DLL_TIME = 8'd10;


localparam CHAN_0_M2S_LATENCY = 8'd01 ;
localparam CHAN_1_M2S_LATENCY = 8'd15 ;
localparam CHAN_2_M2S_LATENCY = 8'd02 ;
localparam CHAN_3_M2S_LATENCY = 8'd10 ;
localparam CHAN_4_M2S_LATENCY = 8'd03 ;
localparam CHAN_5_M2S_LATENCY = 8'd08 ;
localparam CHAN_6_M2S_LATENCY = 8'd01 ;

localparam CHAN_0_S2M_LATENCY = 8'd03 ;
localparam CHAN_1_S2M_LATENCY = 8'd04 ;
localparam CHAN_2_S2M_LATENCY = 8'd05 ;
localparam CHAN_3_S2M_LATENCY = 8'd06 ;
localparam CHAN_4_S2M_LATENCY = 8'd07 ;
localparam CHAN_5_S2M_LATENCY = 8'd08 ;
localparam CHAN_6_S2M_LATENCY = 8'd09 ;


localparam DELAY_X_VALUE_SLAVE  = 8'd10; // Should be greater than DLL_TIME. Indicates when RX CA is ready for Strobe
localparam DELAY_XZ_VALUE_SLAVE = 8'd18; // Should be greater than DELAY_X_VALUE. Indicates when TX CA should send 1shot strobe
localparam DELAY_Z_VALUE_SLAVE  = 8'd8;  // Should be greater than DELAY_X_VALUE. Indicates when TX LLINK to stop user strobe
localparam DELAY_YZ_VALUE_SLAVE = 8'd40; // Should be greater than DELAY_XZ_VALUE. Indicates when TX LLINK can use reuse strobes and send data.

localparam DELAY_X_VALUE_MASTER  = DELAY_X_VALUE_SLAVE  << 1 ; // Slave is Half, so Master Full side should wait 2x as long
localparam DELAY_XZ_VALUE_MASTER = DELAY_XZ_VALUE_SLAVE << 1 ;
localparam DELAY_Z_VALUE_MASTER  = DELAY_Z_VALUE_SLAVE  << 1 ;
localparam DELAY_YZ_VALUE_MASTER = DELAY_YZ_VALUE_SLAVE << 1 ;

//////////////////////////////////////////////////////////////////////
// Clock and reset
parameter CLKL_HALF_CYCLE = 0.50;
reg                     clk_phy;
reg                     clk_p_div2;
reg                     clk_p_div4;
reg                     rst_phy_n;

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
  rst_phy_n <= 1'b0;                           // RST is known (active)
  repeat (10) #(CLKL_HALF_CYCLE);
  clk_phy <= 1'b0;                             // CLK is known
end

logic                     m_wr_clk;
logic                     s_wr_clk;
logic                     m_wr_rst_n;
logic                     s_wr_rst_n;

initial
begin
  clk_p_div2 = 1'bx;                              // Everything is X
  clk_p_div4 = 1'bx;                              // Everything is X
  clk_phy = 1'bx;                              // Everything is X
  rst_phy_n = 1'bx;
  m_wr_rst_n = 1'bx;
  s_wr_rst_n = 1'bx;
  repeat (10) #(CLKL_HALF_CYCLE);
  rst_phy_n = 1'b0;
  m_wr_rst_n <= 1'b0;                           // RST is known (active)
  s_wr_rst_n <= 1'b0;                           // RST is known (active)
  repeat (10) #(CLKL_HALF_CYCLE);
  clk_p_div4 <= 1'b0;                             // CLK is known
  clk_p_div2 <= 1'b0;                             // CLK is known
  repeat (500) @(posedge clk_phy);
  repeat (1) @(posedge m_wr_clk);
  m_wr_rst_n <= 1;                              // Everything is up and running
  repeat (1) @(posedge s_wr_clk);
  s_wr_rst_n <= 1;                              // Everything is up and running
  repeat (1) @(posedge clk_phy);
  rst_phy_n <= 1'b1;
  $display ("######## Exit Reset",,$time);
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
    $shm_probe( axi_st_d256_multichannel_tb, "AMCTF");
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
   logic		master_align_done;	// From ca_master_i of ca.v
   logic		master_align_err;	// From ca_master_i of ca.v
   logic [39:0]		master_ca2ll_0;		// From ca_master_i of ca.v
   logic [39:0]		master_ca2ll_1;		// From ca_master_i of ca.v
   logic [39:0]		master_ca2ll_2;		// From ca_master_i of ca.v
   logic [39:0]		master_ca2ll_3;		// From ca_master_i of ca.v
   logic [39:0]		master_ca2ll_4;		// From ca_master_i of ca.v
   logic [39:0]		master_ca2ll_5;		// From ca_master_i of ca.v
   logic [39:0]		master_ca2ll_6;		// From ca_master_i of ca.v
   logic [39:0]		master_ll2ca_0;		// From axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic [39:0]		master_ll2ca_1;		// From axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic [39:0]		master_ll2ca_2;		// From axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic [39:0]		master_ll2ca_3;		// From axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic [39:0]		master_ll2ca_4;		// From axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic [39:0]		master_ll2ca_5;		// From axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic [39:0]		master_ll2ca_6;		// From axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic [6:0]		master_ms_tx_transfer_en;// From phy_to_phy_lite_i0 of phy_to_phy_lite.v, ...
   logic [319:0]	master_phy2ca_0;	// From phy_to_phy_lite_i0 of phy_to_phy_lite.v
   logic [319:0]	master_phy2ca_1;	// From phy_to_phy_lite_i1 of phy_to_phy_lite.v
   logic [319:0]	master_phy2ca_2;	// From phy_to_phy_lite_i2 of phy_to_phy_lite.v
   logic [319:0]	master_phy2ca_3;	// From phy_to_phy_lite_i3 of phy_to_phy_lite.v
   logic [319:0]	master_phy2ca_4;	// From phy_to_phy_lite_i4 of phy_to_phy_lite.v
   logic [319:0]	master_phy2ca_5;	// From phy_to_phy_lite_i5 of phy_to_phy_lite.v
   logic [319:0]	master_phy2ca_6;	// From phy_to_phy_lite_i6 of phy_to_phy_lite.v
   logic		master_rx_stb_pos_coding_err;// From ca_master_i of ca.v
   logic		master_rx_stb_pos_err;	// From ca_master_i of ca.v
   logic [6:0]		master_sl_tx_transfer_en;// From phy_to_phy_lite_i0 of phy_to_phy_lite.v, ...
   logic		master_tx_stb_pos_coding_err;// From ca_master_i of ca.v
   logic		master_tx_stb_pos_err;	// From ca_master_i of ca.v
   logic [31:0]		rx_st_debug_status;	// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic		slave_align_done;	// From ca_slave_i of ca.v
   logic		slave_align_err;	// From ca_slave_i of ca.v
   logic [79:0]		slave_ca2ll_0;		// From ca_slave_i of ca.v
   logic [79:0]		slave_ca2ll_1;		// From ca_slave_i of ca.v
   logic [79:0]		slave_ca2ll_2;		// From ca_slave_i of ca.v
   logic [79:0]		slave_ca2ll_3;		// From ca_slave_i of ca.v
   logic [79:0]		slave_ca2ll_4;		// From ca_slave_i of ca.v
   logic [79:0]		slave_ca2ll_5;		// From ca_slave_i of ca.v
   logic [79:0]		slave_ca2ll_6;		// From ca_slave_i of ca.v
   logic [79:0]		slave_ll2ca_0;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic [79:0]		slave_ll2ca_1;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic [79:0]		slave_ll2ca_2;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic [79:0]		slave_ll2ca_3;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic [79:0]		slave_ll2ca_4;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic [79:0]		slave_ll2ca_5;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic [79:0]		slave_ll2ca_6;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic [6:0]		slave_ms_tx_transfer_en;// From phy_to_phy_lite_i0 of phy_to_phy_lite.v, ...
   logic [319:0]	slave_phy2ca_0;		// From phy_to_phy_lite_i0 of phy_to_phy_lite.v
   logic [319:0]	slave_phy2ca_1;		// From phy_to_phy_lite_i1 of phy_to_phy_lite.v
   logic [319:0]	slave_phy2ca_2;		// From phy_to_phy_lite_i2 of phy_to_phy_lite.v
   logic [319:0]	slave_phy2ca_3;		// From phy_to_phy_lite_i3 of phy_to_phy_lite.v
   logic [319:0]	slave_phy2ca_4;		// From phy_to_phy_lite_i4 of phy_to_phy_lite.v
   logic [319:0]	slave_phy2ca_5;		// From phy_to_phy_lite_i5 of phy_to_phy_lite.v
   logic [319:0]	slave_phy2ca_6;		// From phy_to_phy_lite_i6 of phy_to_phy_lite.v
   logic		slave_rx_stb_pos_coding_err;// From ca_slave_i of ca.v
   logic		slave_rx_stb_pos_err;	// From ca_slave_i of ca.v
   logic [6:0]		slave_sl_tx_transfer_en;// From phy_to_phy_lite_i0 of phy_to_phy_lite.v, ...
   logic		slave_tx_stb_pos_coding_err;// From ca_slave_i of ca.v
   logic		slave_tx_stb_pos_err;	// From ca_slave_i of ca.v
   logic [3:0]		tx_mrk_userbit_master;	// From marker_gen_im of marker_gen.v
   logic [3:0]		tx_mrk_userbit_slave;	// From marker_gen_is of marker_gen.v
   logic [31:0]		tx_st_debug_status;	// From axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic		user1_tready;		// From axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic [1:0]		user2_enable;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic [511:0]	user2_tdata;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic		user2_tvalid;		// From axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   // End of automatics

   //-----------------------
   //-- REG DECLARATIONS --
   //-----------------------
   /*AUTOREGINPUT*/
   // Beginning of automatic reg inputs (for undeclared instantiated-module inputs)
   logic		m_gen2_mode=0;		// To axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v, ...
   logic		tx_stb_userbit_master=0;	// To axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic		tx_stb_userbit_slave=0;	// To axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   logic [255:0]	user1_tdata=0;		// To axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic		user1_tvalid=0;		// To axi_st_master_top_i of axi_st_d256_multichannel_full_master_top.v
   logic		user2_tready=0;		// To axi_st_slave_top_i of axi_st_d256_multichannel_half_slave_top.v
   // End of automatics

   logic [319:0]         slave_ca2phy_0;
   logic [319:0]         slave_ca2phy_1;
   logic [319:0]         slave_ca2phy_2;
   logic [319:0]         slave_ca2phy_3;
   logic [319:0]         slave_ca2phy_4;
   logic [319:0]         slave_ca2phy_5;
   logic [319:0]         slave_ca2phy_6;
   logic [319:0]         master_ca2phy_0;
   logic [319:0]         master_ca2phy_1;
   logic [319:0]         master_ca2phy_2;
   logic [319:0]         master_ca2phy_3;
   logic [319:0]         master_ca2phy_4;
   logic [319:0]         master_ca2phy_5;
   logic [319:0]         master_ca2phy_6;

   logic [6:0] m2s_master_ca2phy_strobe;
   logic [6:0] m2s_slave_phy2ca_strobe;

   logic [6:0] s2m_slave_ca2phy_strobe;
   logic [6:0] s2m_master_phy2ca_strobe;

   logic [6:0] master_ca2phy_marker;
   logic [6:0] slave_ca2phy_marker;

   logic       m2s_master_ca2phy_pushbit;
   logic [1:0] m2s_slave_phy2ca_pushbit;

   logic [1:0] s2m_slave_ca2phy_credit;
   logic       s2m_master_phy2ca_credit;


   // TX M2S
   assign m2s_master_ca2phy_strobe = {master_ca2phy_6[1],
                                      master_ca2phy_5[1],
                                      master_ca2phy_4[1],
                                      master_ca2phy_3[1],
                                      master_ca2phy_2[1],
                                      master_ca2phy_1[1],
                                      master_ca2phy_0[1]};

   // RX M2S
   assign m2s_slave_phy2ca_strobe = {slave_phy2ca_6[1],
                                     slave_phy2ca_5[1],
                                     slave_phy2ca_4[1],
                                     slave_phy2ca_3[1],
                                     slave_phy2ca_2[1],
                                     slave_phy2ca_1[1],
                                     slave_phy2ca_0[1]};

   // TX S2M
   assign s2m_slave_ca2phy_strobe = {slave_ca2phy_6[1],
                                     slave_ca2phy_5[1],
                                     slave_ca2phy_4[1],
                                     slave_ca2phy_3[1],
                                     slave_ca2phy_2[1],
                                     slave_ca2phy_1[1],
                                     slave_ca2phy_0[1]};

   // RX S2M
   assign s2m_master_phy2ca_strobe = {master_phy2ca_6[1],
                                      master_phy2ca_5[1],
                                      master_phy2ca_4[1],
                                      master_phy2ca_3[1],
                                      master_phy2ca_2[1],
                                      master_phy2ca_1[1],
                                      master_phy2ca_0[1]};

   // TX M2S
   assign master_ca2phy_marker = {master_ca2phy_6[39],
                                  master_ca2phy_5[39],
                                  master_ca2phy_4[39],
                                  master_ca2phy_3[39],
                                  master_ca2phy_2[39],
                                  master_ca2phy_1[39],
                                  master_ca2phy_0[39]};

   // TX S2M
   assign slave_ca2phy_marker = {slave_ca2phy_6[39],
                                 slave_ca2phy_5[39],
                                 slave_ca2phy_4[39],
                                 slave_ca2phy_3[39],
                                 slave_ca2phy_2[39],
                                 slave_ca2phy_1[39],
                                 slave_ca2phy_0[39]};

   assign m2s_master_ca2phy_pushbit  = {master_ca2phy_0[0]};

   assign m2s_slave_phy2ca_pushbit = {slave_phy2ca_0[0+40],slave_phy2ca_0[0]};

   assign s2m_slave_ca2phy_credit  = {slave_ca2phy_0[0+40],slave_ca2phy_0[0]};

   assign s2m_master_phy2ca_credit   = {master_phy2ca_0[0]};




   initial m_gen2_mode = 0;

   /* marker_gen AUTO_TEMPLATE ".*_i\(.+\)" (
      .user_marker			(tx_mrk_userbit_master[]),
      .clk				(@_wr_clk),
      .rst_n				(@_wr_rst_n),
      .local_rate			(MASTER_RATE),
      .remote_rate			(SLAVE_RATE),
    );
    */

   marker_gen marker_gen_im
     (/*AUTOINST*/
      // Outputs
      .user_marker			(tx_mrk_userbit_master[3:0]), // Templated
      // Inputs
      .clk				(m_wr_clk),		 // Templated
      .rst_n				(m_wr_rst_n),		 // Templated
      .local_rate			(MASTER_RATE),		 // Templated
      .remote_rate			(SLAVE_RATE));		 // Templated


   /* marker_gen AUTO_TEMPLATE ".*_i\(.+\)" (
      .user_marker			(tx_mrk_userbit_slave[]),
      .clk				(@_wr_clk),
      .rst_n				(@_wr_rst_n),
      .local_rate			(SLAVE_RATE),
      .remote_rate			(MASTER_RATE),
    );
    */

   marker_gen marker_gen_is
     (/*AUTOINST*/
      // Outputs
      .user_marker			(tx_mrk_userbit_slave[3:0]), // Templated
      // Inputs
      .clk				(s_wr_clk),		 // Templated
      .rst_n				(s_wr_rst_n),		 // Templated
      .local_rate			(SLAVE_RATE),		 // Templated
      .remote_rate			(MASTER_RATE));		 // Templated

   // Tie strobes low to avoid confusion
   initial
   begin
     tx_stb_userbit_master = 1'b1;
     tx_stb_userbit_slave  = 1'b1;
   end

assign m_wr_clk = (MASTER_RATE == FULL)    ? clk_phy    :
                  (MASTER_RATE == HALF)    ? clk_p_div2 :
                  (MASTER_RATE == QUARTER) ? clk_p_div4 : 1'bx;

assign s_wr_clk = (SLAVE_RATE == FULL)    ? clk_phy    :
                  (SLAVE_RATE == HALF)    ? clk_p_div2 :
                  (SLAVE_RATE == QUARTER) ? clk_p_div4 : 1'bx;


   /* axi_st_d256_multichannel_full_master_top AUTO_TEMPLATE (
      .user_\(.*\)			(user1_\1[]),

      .tx_stb_userbit     		(1'b1),
      .tx_mrk_userbit			(tx_mrk_userbit_master[]),
      .tx_stb_userbit			(tx_stb_userbit_master[]),

      .init_st_credit			(8'h0),

      .rx_online			(master_align_done),
      .tx_online			(&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}),

      .delay_x_value                    (8'h0), // Because CA Is here, we set these to 0.
      .delay_xz_value                   (DELAY_Z_VALUE_MASTER ),
      .delay_yz_value                   (DELAY_YZ_VALUE_MASTER),

      .tx_phy\(.\)                      (master_ll2ca_\1[]),
      .rx_phy\(.\)		        (master_ca2ll_\1[]),

      .clk_wr				(m_wr_clk),
      .rst_wr_n				(m_wr_rst_n),
    );
    */
   axi_st_d256_multichannel_full_master_top axi_st_master_top_i
     (/*AUTOINST*/
      // Outputs
      .tx_phy0				(master_ll2ca_0[39:0]),	 // Templated
      .tx_phy1				(master_ll2ca_1[39:0]),	 // Templated
      .tx_phy2				(master_ll2ca_2[39:0]),	 // Templated
      .tx_phy3				(master_ll2ca_3[39:0]),	 // Templated
      .tx_phy4				(master_ll2ca_4[39:0]),	 // Templated
      .tx_phy5				(master_ll2ca_5[39:0]),	 // Templated
      .tx_phy6				(master_ll2ca_6[39:0]),	 // Templated
      .user_tready			(user1_tready),		 // Templated
      .tx_st_debug_status		(tx_st_debug_status[31:0]),
      // Inputs
      .clk_wr				(m_wr_clk),		 // Templated
      .rst_wr_n				(m_wr_rst_n),		 // Templated
      .tx_online			(&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}), // Templated
      .rx_online			(master_align_done),	 // Templated
      .init_st_credit			(8'h0),			 // Templated
      .rx_phy0				(master_ca2ll_0[39:0]),	 // Templated
      .rx_phy1				(master_ca2ll_1[39:0]),	 // Templated
      .rx_phy2				(master_ca2ll_2[39:0]),	 // Templated
      .rx_phy3				(master_ca2ll_3[39:0]),	 // Templated
      .rx_phy4				(master_ca2ll_4[39:0]),	 // Templated
      .rx_phy5				(master_ca2ll_5[39:0]),	 // Templated
      .rx_phy6				(master_ca2ll_6[39:0]),	 // Templated
      .user_tdata			(user1_tdata[255:0]),	 // Templated
      .user_tvalid			(user1_tvalid),		 // Templated
      .m_gen2_mode			(m_gen2_mode),
      .tx_mrk_userbit			(tx_mrk_userbit_master[0:0]), // Templated
      .tx_stb_userbit			(tx_stb_userbit_master), // Templated
      .delay_x_value			(8'h0),			 // Templated
      .delay_xz_value			(DELAY_Z_VALUE_MASTER ), // Templated
      .delay_yz_value			(DELAY_YZ_VALUE_MASTER)); // Templated

   /* axi_st_d256_multichannel_half_slave_top AUTO_TEMPLATE (
      .user_\(.*\)			(user2_\1[]),

      .tx_mrk_userbit			(tx_mrk_userbit_slave[]),
      .tx_stb_userbit			(tx_stb_userbit_slave[]),

      .rx_online			(slave_align_done),
      .tx_online			(&{slave_sl_tx_transfer_en,slave_ms_tx_transfer_en}),

      .delay_x_value                    (8'h0), // Because CA Is here, we set these to 0.
      .delay_xz_value                   (DELAY_Z_VALUE_SLAVE),
      .delay_yz_value                   (DELAY_YZ_VALUE_SLAVE),

      .tx_phy\(.\)                      (slave_ll2ca_\1[]),
      .rx_phy\(.\)			(slave_ca2ll_\1[]),

      .clk_wr				(s_wr_clk),
      .rst_wr_n				(s_wr_rst_n),
    );
    */
   axi_st_d256_multichannel_half_slave_top axi_st_slave_top_i
    (/*AUTOINST*/
     // Outputs
     .tx_phy0				(slave_ll2ca_0[79:0]),	 // Templated
     .tx_phy1				(slave_ll2ca_1[79:0]),	 // Templated
     .tx_phy2				(slave_ll2ca_2[79:0]),	 // Templated
     .tx_phy3				(slave_ll2ca_3[79:0]),	 // Templated
     .tx_phy4				(slave_ll2ca_4[79:0]),	 // Templated
     .tx_phy5				(slave_ll2ca_5[79:0]),	 // Templated
     .tx_phy6				(slave_ll2ca_6[79:0]),	 // Templated
     .user_tdata			(user2_tdata[511:0]),	 // Templated
     .user_tvalid			(user2_tvalid),		 // Templated
     .user_enable			(user2_enable[1:0]),	 // Templated
     .rx_st_debug_status		(rx_st_debug_status[31:0]),
     // Inputs
     .clk_wr				(s_wr_clk),		 // Templated
     .rst_wr_n				(s_wr_rst_n),		 // Templated
     .tx_online				(&{slave_sl_tx_transfer_en,slave_ms_tx_transfer_en}), // Templated
     .rx_online				(slave_align_done),	 // Templated
     .rx_phy0				(slave_ca2ll_0[79:0]),	 // Templated
     .rx_phy1				(slave_ca2ll_1[79:0]),	 // Templated
     .rx_phy2				(slave_ca2ll_2[79:0]),	 // Templated
     .rx_phy3				(slave_ca2ll_3[79:0]),	 // Templated
     .rx_phy4				(slave_ca2ll_4[79:0]),	 // Templated
     .rx_phy5				(slave_ca2ll_5[79:0]),	 // Templated
     .rx_phy6				(slave_ca2ll_6[79:0]),	 // Templated
     .user_tready			(user2_tready),		 // Templated
     .m_gen2_mode			(m_gen2_mode),
     .tx_mrk_userbit			(tx_mrk_userbit_slave[1:0]), // Templated
     .tx_stb_userbit			(tx_stb_userbit_slave),	 // Templated
     .delay_x_value			(8'h0),			 // Templated
     .delay_xz_value			(DELAY_Z_VALUE_SLAVE),	 // Templated
     .delay_yz_value			(DELAY_YZ_VALUE_SLAVE));	 // Templated




   /* ca AUTO_TEMPLATE (
      .lane_clk				({7{m_wr_clk}}),
      .com_clk				(m_wr_clk),
      .rst_n				(m_wr_rst_n),

      .align_done			(master_align_done),
      .align_err			(master_align_err),
      .tx_stb_pos_err			(master_tx_stb_pos_err),
      .tx_stb_pos_coding_err		(master_tx_stb_pos_coding_err),
      .rx_stb_pos_err			(master_rx_stb_pos_err),
      .rx_stb_pos_coding_err		(master_rx_stb_pos_coding_err),

      .tx_online			(&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}),
      .rx_online			(&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}),

      .tx_stb_en			(1'b0),   // No CA Strobe in Asymmetric
      .tx_stb_rcvr			(1'b1),                 // recover strobes
      .align_fly			('0),                   // Only look for strobe once
      .rden_dly				('0),                   // No delay before outputting data
      .count_x				(DELAY_X_VALUE_MASTER),
      .count_xz				(DELAY_XZ_VALUE_MASTER),
//      .tx_stb_wd_sel                    (8'h00),                // Strobe is at LOC 1
//      .tx_stb_bit_sel                   (40'h0000000000),
//      .tx_stb_intv                      (8'h0),                 // Strobe repeats every 4 cycles
       .tx_stb_wd_sel                    (8'h01),                // Strobe is at LOC 1       FIXME_ART
       .tx_stb_bit_sel                   (40'h0000000002),
       .tx_stb_intv                      (8'h4),                 // Strobe repeats every 4 cycles
      .rx_stb_wd_sel			(8'h01),                // Strobe is at LOC 1
      .rx_stb_bit_sel			(40'h0000000002),
      .rx_stb_intv			(8'h4),                 // Strobe repeats every 4 cycles

      .tx_din				 ({master_ll2ca_6[39:0]  , master_ll2ca_5[39:0]  , master_ll2ca_4[39:0]  , master_ll2ca_3[39:0]  , master_ll2ca_2[39:0]  , master_ll2ca_1[39:0]  , master_ll2ca_0[39:0]})  ,
      .rx_din				 ({master_phy2ca_6[39:0] , master_phy2ca_5[39:0] , master_phy2ca_4[39:0] , master_phy2ca_3[39:0] , master_phy2ca_2[39:0] , master_phy2ca_1[39:0] , master_phy2ca_0[39:0]})  ,
      .tx_dout				 ({master_ca2phy_6[39:0] , master_ca2phy_5[39:0] , master_ca2phy_4[39:0] , master_ca2phy_3[39:0] , master_ca2phy_2[39:0] , master_ca2phy_1[39:0] , master_ca2phy_0[39:0]}) ,
      .rx_dout				 ({master_ca2ll_6[39:0]  , master_ca2ll_5[39:0]  , master_ca2ll_4[39:0]  , master_ca2ll_3[39:0]  , master_ca2ll_2[39:0]  , master_ca2ll_1[39:0]  , master_ca2ll_0[39:0]})  ,

      .fifo_full_val			(5'd16),      // Status
      .fifo_pfull_val			(5'd12),      // Status
      .fifo_empty_val			(3'd0),       // Status
      .fifo_pempty_val			(3'd4),       // Status
      .fifo_full			(),          // Status
      .fifo_pfull			(),          // Status
      .fifo_empty			(),          // Status
      .fifo_pempty			(),          // Status

    );
    */
   ca #(.NUM_CHANNELS      (7),           // 2 Channels
        .BITS_PER_CHANNEL  (40),          // Half Rate Gen1 is 80 bits
        .AD_WIDTH          (4),           // Allows 16 deep FIFO
        .SYNC_FIFO         (1'b1))        // Synchronous FIFO
   ca_master_i
     (/*AUTOINST*/
      // Outputs
      .tx_dout				({master_ca2phy_6[39:0] , master_ca2phy_5[39:0] , master_ca2phy_4[39:0] , master_ca2phy_3[39:0] , master_ca2phy_2[39:0] , master_ca2phy_1[39:0] , master_ca2phy_0[39:0]}), // Templated
      .rx_dout				({master_ca2ll_6[39:0]  , master_ca2ll_5[39:0]  , master_ca2ll_4[39:0]  , master_ca2ll_3[39:0]  , master_ca2ll_2[39:0]  , master_ca2ll_1[39:0]  , master_ca2ll_0[39:0]}), // Templated
      .align_done			(master_align_done),	 // Templated
      .align_err			(master_align_err),	 // Templated
      .tx_stb_pos_err			(master_tx_stb_pos_err), // Templated
      .tx_stb_pos_coding_err		(master_tx_stb_pos_coding_err), // Templated
      .rx_stb_pos_err			(master_rx_stb_pos_err), // Templated
      .rx_stb_pos_coding_err		(master_rx_stb_pos_coding_err), // Templated
      .fifo_full			(),			 // Templated
      .fifo_pfull			(),			 // Templated
      .fifo_empty			(),			 // Templated
      .fifo_pempty			(),			 // Templated
      // Inputs
      .lane_clk				({7{m_wr_clk}}),	 // Templated
      .com_clk				(m_wr_clk),		 // Templated
      .rst_n				(m_wr_rst_n),		 // Templated
      .tx_online			(&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}), // Templated
      .rx_online			(&{master_sl_tx_transfer_en,master_ms_tx_transfer_en}), // Templated
      .tx_stb_en			(1'b0),			 // Templated
      .tx_stb_rcvr			(1'b1),			 // Templated
      .align_fly			('0),			 // Templated
      .rden_dly				('0),			 // Templated
      .count_x				(DELAY_X_VALUE_MASTER),	 // Templated
      .count_xz				(DELAY_XZ_VALUE_MASTER), // Templated
      .tx_stb_wd_sel			(8'h01),		 // Templated
      .tx_stb_bit_sel			(40'h0000000002),	 // Templated
      .tx_stb_intv			(8'h4),			 // Templated
      .rx_stb_wd_sel			(8'h01),		 // Templated
      .rx_stb_bit_sel			(40'h0000000002),	 // Templated
      .rx_stb_intv			(8'h4),			 // Templated
      .tx_din				({master_ll2ca_6[39:0]  , master_ll2ca_5[39:0]  , master_ll2ca_4[39:0]  , master_ll2ca_3[39:0]  , master_ll2ca_2[39:0]  , master_ll2ca_1[39:0]  , master_ll2ca_0[39:0]}), // Templated
      .rx_din				({master_phy2ca_6[39:0] , master_phy2ca_5[39:0] , master_phy2ca_4[39:0] , master_phy2ca_3[39:0] , master_phy2ca_2[39:0] , master_phy2ca_1[39:0] , master_phy2ca_0[39:0]}), // Templated
      .fifo_full_val			(5'd16),		 // Templated
      .fifo_pfull_val			(5'd12),		 // Templated
      .fifo_empty_val			(3'd0),			 // Templated
      .fifo_pempty_val			(3'd4));			 // Templated

   /* ca AUTO_TEMPLATE (
      .lane_clk				({7{s_wr_clk}}),
      .com_clk				(s_wr_clk),
      .rst_n				(s_wr_rst_n),

      .align_done			(slave_align_done),
      .align_err			(slave_align_err),
      .tx_stb_pos_err			(slave_tx_stb_pos_err),
      .tx_stb_pos_coding_err		(slave_tx_stb_pos_coding_err),
      .rx_stb_pos_err			(slave_rx_stb_pos_err),
      .rx_stb_pos_coding_err		(slave_rx_stb_pos_coding_err),

      .tx_online			(&{slave_sl_tx_transfer_en,slave_ms_tx_transfer_en}),
      .rx_online			(&{slave_sl_tx_transfer_en,slave_ms_tx_transfer_en}),

      .tx_stb_en			(1'b1),
      .tx_stb_rcvr			(1'b1),                 // recover strobes
      .align_fly			('0),                   // Only look for strobe once
      .rden_dly				('0),                   // No delay before outputting data
      .count_x				(DELAY_X_VALUE_SLAVE),
      .count_xz				(DELAY_XZ_VALUE_SLAVE),
      .tx_stb_wd_sel			(8'h01),                // Strobe is at LOC 1
      .tx_stb_bit_sel			(40'h0000000002),
      .tx_stb_intv			(8'h4),                 // Strobe repeats every 4 cycles
      .rx_stb_wd_sel			(8'h01),                // Strobe is at LOC 1
      .rx_stb_bit_sel			(40'h0000000002),
      .rx_stb_intv			(8'h4),                 // Strobe repeats every 4 cycles

      .tx_din			        ({slave_ll2ca_6[79:0]  , slave_ll2ca_5[79:0]  , slave_ll2ca_4[79:0]  , slave_ll2ca_3[79:0]  , slave_ll2ca_2[79:0]  , slave_ll2ca_1[79:0]  , slave_ll2ca_0[79:0]})  ,
      .rx_din			        ({slave_phy2ca_6[79:0] , slave_phy2ca_5[79:0] , slave_phy2ca_4[79:0] , slave_phy2ca_3[79:0] , slave_phy2ca_2[79:0] , slave_phy2ca_1[79:0] , slave_phy2ca_0[79:0]})  ,
      .tx_dout			        ({slave_ca2phy_6[79:0] , slave_ca2phy_5[79:0] , slave_ca2phy_4[79:0] , slave_ca2phy_3[79:0] , slave_ca2phy_2[79:0] , slave_ca2phy_1[79:0] , slave_ca2phy_0[79:0]}) ,
      .rx_dout			        ({slave_ca2ll_6[79:0]  , slave_ca2ll_5[79:0]  , slave_ca2ll_4[79:0]  , slave_ca2ll_3[79:0]  , slave_ca2ll_2[79:0]  , slave_ca2ll_1[79:0]  , slave_ca2ll_0[79:0]})  ,

      .fifo_full_val			(5'd16),      // Status
      .fifo_pfull_val			(5'd12),      // Status
      .fifo_empty_val			(3'd0),       // Status
      .fifo_pempty_val			(3'd4),       // Status
      .fifo_full			(),          // Status
      .fifo_pfull			(),          // Status
      .fifo_empty			(),          // Status
      .fifo_pempty			(),          // Status

    );
    */
   ca #(.NUM_CHANNELS      (7),           // 2 Channels
        .BITS_PER_CHANNEL  (80),          // Half Rate Gen1 is 80 bits
        .AD_WIDTH          (4),           // Allows 16 deep FIFO
        .SYNC_FIFO         (1'b1))        // Synchronous FIFO
   ca_slave_i
     (/*AUTOINST*/
      // Outputs
      .tx_dout				({slave_ca2phy_6[79:0] , slave_ca2phy_5[79:0] , slave_ca2phy_4[79:0] , slave_ca2phy_3[79:0] , slave_ca2phy_2[79:0] , slave_ca2phy_1[79:0] , slave_ca2phy_0[79:0]}), // Templated
      .rx_dout				({slave_ca2ll_6[79:0]  , slave_ca2ll_5[79:0]  , slave_ca2ll_4[79:0]  , slave_ca2ll_3[79:0]  , slave_ca2ll_2[79:0]  , slave_ca2ll_1[79:0]  , slave_ca2ll_0[79:0]}), // Templated
      .align_done			(slave_align_done),	 // Templated
      .align_err			(slave_align_err),	 // Templated
      .tx_stb_pos_err			(slave_tx_stb_pos_err),	 // Templated
      .tx_stb_pos_coding_err		(slave_tx_stb_pos_coding_err), // Templated
      .rx_stb_pos_err			(slave_rx_stb_pos_err),	 // Templated
      .rx_stb_pos_coding_err		(slave_rx_stb_pos_coding_err), // Templated
      .fifo_full			(),			 // Templated
      .fifo_pfull			(),			 // Templated
      .fifo_empty			(),			 // Templated
      .fifo_pempty			(),			 // Templated
      // Inputs
      .lane_clk				({7{s_wr_clk}}),	 // Templated
      .com_clk				(s_wr_clk),		 // Templated
      .rst_n				(s_wr_rst_n),		 // Templated
      .tx_online			(&{slave_sl_tx_transfer_en,slave_ms_tx_transfer_en}), // Templated
      .rx_online			(&{slave_sl_tx_transfer_en,slave_ms_tx_transfer_en}), // Templated
      .tx_stb_en			(1'b1),			 // Templated
      .tx_stb_rcvr			(1'b1),			 // Templated
      .align_fly			('0),			 // Templated
      .rden_dly				('0),			 // Templated
      .count_x				(DELAY_X_VALUE_SLAVE),	 // Templated
      .count_xz				(DELAY_XZ_VALUE_SLAVE),	 // Templated
      .tx_stb_wd_sel			(8'h01),		 // Templated
      .tx_stb_bit_sel			(40'h0000000002),	 // Templated
      .tx_stb_intv			(8'h4),			 // Templated
      .rx_stb_wd_sel			(8'h01),		 // Templated
      .rx_stb_bit_sel			(40'h0000000002),	 // Templated
      .rx_stb_intv			(8'h4),			 // Templated
      .tx_din				({slave_ll2ca_6[79:0]  , slave_ll2ca_5[79:0]  , slave_ll2ca_4[79:0]  , slave_ll2ca_3[79:0]  , slave_ll2ca_2[79:0]  , slave_ll2ca_1[79:0]  , slave_ll2ca_0[79:0]}), // Templated
      .rx_din				({slave_phy2ca_6[79:0] , slave_phy2ca_5[79:0] , slave_phy2ca_4[79:0] , slave_phy2ca_3[79:0] , slave_phy2ca_2[79:0] , slave_phy2ca_1[79:0] , slave_phy2ca_0[79:0]}), // Templated
      .fifo_full_val			(5'd16),		 // Templated
      .fifo_pfull_val			(5'd12),		 // Templated
      .fifo_empty_val			(3'd0),			 // Templated
      .fifo_pempty_val			(3'd4));			 // Templated





   /* phy_to_phy_lite AUTO_TEMPLATE ".*_i\(.+\)" (
      .master_sl_tx_transfer_en		(master_sl_tx_transfer_en[@]),
      .master_ms_tx_transfer_en		(master_ms_tx_transfer_en[@]),
      .slave_sl_tx_transfer_en		(slave_sl_tx_transfer_en[@]),
      .slave_ms_tx_transfer_en		(slave_ms_tx_transfer_en[@]),

      .tb_master_rx_dll_time               (CHAN_@_M2S_DLL_TIME),
      .tb_slave_rx_dll_time                (CHAN_@_M2S_DLL_TIME),
      .tb_m2s_latency                      (CHAN_@_M2S_LATENCY),
      .tb_s2m_latency                      (CHAN_@_S2M_LATENCY),

      .s2m_data_out			(master_phy2ca_@[]),
      .m2s_data_out			(slave_phy2ca_@[]),
      .m2s_data_in			(master_ca2phy_@[]),
      .s2m_data_in			(slave_ca2phy_@[]),

      .tb_master_rate			(MASTER_RATE),
      .tb_slave_rate			(SLAVE_RATE),

      .tb_m2s_marker_loc			(CHAN_M2S_MARKER_LOC),
      .tb_s2m_marker_loc			(CHAN_S2M_MARKER_LOC),
      .tb_en_asymmetric			(1'b1),

      .fwd_clk				(clk_phy),
      .ns_adapter_rstn		        (rst_phy_n),
    );
    */
   phy_to_phy_lite phy_to_phy_lite_i0
     (/*AUTOINST*/
      // Outputs
      .master_sl_tx_transfer_en		(master_sl_tx_transfer_en[0]), // Templated
      .master_ms_tx_transfer_en		(master_ms_tx_transfer_en[0]), // Templated
      .slave_sl_tx_transfer_en		(slave_sl_tx_transfer_en[0]), // Templated
      .slave_ms_tx_transfer_en		(slave_ms_tx_transfer_en[0]), // Templated
      .s2m_data_out			(master_phy2ca_0[319:0]), // Templated
      .m2s_data_out			(slave_phy2ca_0[319:0]), // Templated
      // Inputs
      .fwd_clk				(clk_phy),		 // Templated
      .ns_adapter_rstn			(rst_phy_n),		 // Templated
      .m_wr_clk				(m_wr_clk),
      .s_wr_clk				(s_wr_clk),
      .m2s_data_in			(master_ca2phy_0[319:0]), // Templated
      .s2m_data_in			(slave_ca2phy_0[319:0]), // Templated
      .tb_m2s_marker_loc		(CHAN_M2S_MARKER_LOC),	 // Templated
      .tb_s2m_marker_loc		(CHAN_S2M_MARKER_LOC),	 // Templated
      .tb_master_rate			(MASTER_RATE),		 // Templated
      .tb_slave_rate			(SLAVE_RATE),		 // Templated
      .m_gen2_mode			(m_gen2_mode),
      .tb_m2s_latency			(CHAN_0_M2S_LATENCY),	 // Templated
      .tb_s2m_latency			(CHAN_0_S2M_LATENCY),	 // Templated
      .tb_master_rx_dll_time		(CHAN_0_M2S_DLL_TIME),	 // Templated
      .tb_slave_rx_dll_time		(CHAN_0_M2S_DLL_TIME),	 // Templated
      .tb_en_asymmetric			(1'b1));			 // Templated

   phy_to_phy_lite phy_to_phy_lite_i1
     (/*AUTOINST*/
      // Outputs
      .master_sl_tx_transfer_en		(master_sl_tx_transfer_en[1]), // Templated
      .master_ms_tx_transfer_en		(master_ms_tx_transfer_en[1]), // Templated
      .slave_sl_tx_transfer_en		(slave_sl_tx_transfer_en[1]), // Templated
      .slave_ms_tx_transfer_en		(slave_ms_tx_transfer_en[1]), // Templated
      .s2m_data_out			(master_phy2ca_1[319:0]), // Templated
      .m2s_data_out			(slave_phy2ca_1[319:0]), // Templated
      // Inputs
      .fwd_clk				(clk_phy),		 // Templated
      .ns_adapter_rstn			(rst_phy_n),		 // Templated
      .m_wr_clk				(m_wr_clk),
      .s_wr_clk				(s_wr_clk),
      .m2s_data_in			(master_ca2phy_1[319:0]), // Templated
      .s2m_data_in			(slave_ca2phy_1[319:0]), // Templated
      .tb_m2s_marker_loc		(CHAN_M2S_MARKER_LOC),	 // Templated
      .tb_s2m_marker_loc		(CHAN_S2M_MARKER_LOC),	 // Templated
      .tb_master_rate			(MASTER_RATE),		 // Templated
      .tb_slave_rate			(SLAVE_RATE),		 // Templated
      .m_gen2_mode			(m_gen2_mode),
      .tb_m2s_latency			(CHAN_1_M2S_LATENCY),	 // Templated
      .tb_s2m_latency			(CHAN_1_S2M_LATENCY),	 // Templated
      .tb_master_rx_dll_time		(CHAN_1_M2S_DLL_TIME),	 // Templated
      .tb_slave_rx_dll_time		(CHAN_1_M2S_DLL_TIME),	 // Templated
      .tb_en_asymmetric			(1'b1));			 // Templated

   phy_to_phy_lite phy_to_phy_lite_i2
     (/*AUTOINST*/
      // Outputs
      .master_sl_tx_transfer_en		(master_sl_tx_transfer_en[2]), // Templated
      .master_ms_tx_transfer_en		(master_ms_tx_transfer_en[2]), // Templated
      .slave_sl_tx_transfer_en		(slave_sl_tx_transfer_en[2]), // Templated
      .slave_ms_tx_transfer_en		(slave_ms_tx_transfer_en[2]), // Templated
      .s2m_data_out			(master_phy2ca_2[319:0]), // Templated
      .m2s_data_out			(slave_phy2ca_2[319:0]), // Templated
      // Inputs
      .fwd_clk				(clk_phy),		 // Templated
      .ns_adapter_rstn			(rst_phy_n),		 // Templated
      .m_wr_clk				(m_wr_clk),
      .s_wr_clk				(s_wr_clk),
      .m2s_data_in			(master_ca2phy_2[319:0]), // Templated
      .s2m_data_in			(slave_ca2phy_2[319:0]), // Templated
      .tb_m2s_marker_loc		(CHAN_M2S_MARKER_LOC),	 // Templated
      .tb_s2m_marker_loc		(CHAN_S2M_MARKER_LOC),	 // Templated
      .tb_master_rate			(MASTER_RATE),		 // Templated
      .tb_slave_rate			(SLAVE_RATE),		 // Templated
      .m_gen2_mode			(m_gen2_mode),
      .tb_m2s_latency			(CHAN_2_M2S_LATENCY),	 // Templated
      .tb_s2m_latency			(CHAN_2_S2M_LATENCY),	 // Templated
      .tb_master_rx_dll_time		(CHAN_2_M2S_DLL_TIME),	 // Templated
      .tb_slave_rx_dll_time		(CHAN_2_M2S_DLL_TIME),	 // Templated
      .tb_en_asymmetric			(1'b1));			 // Templated

   phy_to_phy_lite phy_to_phy_lite_i3
     (/*AUTOINST*/
      // Outputs
      .master_sl_tx_transfer_en		(master_sl_tx_transfer_en[3]), // Templated
      .master_ms_tx_transfer_en		(master_ms_tx_transfer_en[3]), // Templated
      .slave_sl_tx_transfer_en		(slave_sl_tx_transfer_en[3]), // Templated
      .slave_ms_tx_transfer_en		(slave_ms_tx_transfer_en[3]), // Templated
      .s2m_data_out			(master_phy2ca_3[319:0]), // Templated
      .m2s_data_out			(slave_phy2ca_3[319:0]), // Templated
      // Inputs
      .fwd_clk				(clk_phy),		 // Templated
      .ns_adapter_rstn			(rst_phy_n),		 // Templated
      .m_wr_clk				(m_wr_clk),
      .s_wr_clk				(s_wr_clk),
      .m2s_data_in			(master_ca2phy_3[319:0]), // Templated
      .s2m_data_in			(slave_ca2phy_3[319:0]), // Templated
      .tb_m2s_marker_loc		(CHAN_M2S_MARKER_LOC),	 // Templated
      .tb_s2m_marker_loc		(CHAN_S2M_MARKER_LOC),	 // Templated
      .tb_master_rate			(MASTER_RATE),		 // Templated
      .tb_slave_rate			(SLAVE_RATE),		 // Templated
      .m_gen2_mode			(m_gen2_mode),
      .tb_m2s_latency			(CHAN_3_M2S_LATENCY),	 // Templated
      .tb_s2m_latency			(CHAN_3_S2M_LATENCY),	 // Templated
      .tb_master_rx_dll_time		(CHAN_3_M2S_DLL_TIME),	 // Templated
      .tb_slave_rx_dll_time		(CHAN_3_M2S_DLL_TIME),	 // Templated
      .tb_en_asymmetric			(1'b1));			 // Templated

   phy_to_phy_lite phy_to_phy_lite_i4
     (/*AUTOINST*/
      // Outputs
      .master_sl_tx_transfer_en		(master_sl_tx_transfer_en[4]), // Templated
      .master_ms_tx_transfer_en		(master_ms_tx_transfer_en[4]), // Templated
      .slave_sl_tx_transfer_en		(slave_sl_tx_transfer_en[4]), // Templated
      .slave_ms_tx_transfer_en		(slave_ms_tx_transfer_en[4]), // Templated
      .s2m_data_out			(master_phy2ca_4[319:0]), // Templated
      .m2s_data_out			(slave_phy2ca_4[319:0]), // Templated
      // Inputs
      .fwd_clk				(clk_phy),		 // Templated
      .ns_adapter_rstn			(rst_phy_n),		 // Templated
      .m_wr_clk				(m_wr_clk),
      .s_wr_clk				(s_wr_clk),
      .m2s_data_in			(master_ca2phy_4[319:0]), // Templated
      .s2m_data_in			(slave_ca2phy_4[319:0]), // Templated
      .tb_m2s_marker_loc		(CHAN_M2S_MARKER_LOC),	 // Templated
      .tb_s2m_marker_loc		(CHAN_S2M_MARKER_LOC),	 // Templated
      .tb_master_rate			(MASTER_RATE),		 // Templated
      .tb_slave_rate			(SLAVE_RATE),		 // Templated
      .m_gen2_mode			(m_gen2_mode),
      .tb_m2s_latency			(CHAN_4_M2S_LATENCY),	 // Templated
      .tb_s2m_latency			(CHAN_4_S2M_LATENCY),	 // Templated
      .tb_master_rx_dll_time		(CHAN_4_M2S_DLL_TIME),	 // Templated
      .tb_slave_rx_dll_time		(CHAN_4_M2S_DLL_TIME),	 // Templated
      .tb_en_asymmetric			(1'b1));			 // Templated

   phy_to_phy_lite phy_to_phy_lite_i5
     (/*AUTOINST*/
      // Outputs
      .master_sl_tx_transfer_en		(master_sl_tx_transfer_en[5]), // Templated
      .master_ms_tx_transfer_en		(master_ms_tx_transfer_en[5]), // Templated
      .slave_sl_tx_transfer_en		(slave_sl_tx_transfer_en[5]), // Templated
      .slave_ms_tx_transfer_en		(slave_ms_tx_transfer_en[5]), // Templated
      .s2m_data_out			(master_phy2ca_5[319:0]), // Templated
      .m2s_data_out			(slave_phy2ca_5[319:0]), // Templated
      // Inputs
      .fwd_clk				(clk_phy),		 // Templated
      .ns_adapter_rstn			(rst_phy_n),		 // Templated
      .m_wr_clk				(m_wr_clk),
      .s_wr_clk				(s_wr_clk),
      .m2s_data_in			(master_ca2phy_5[319:0]), // Templated
      .s2m_data_in			(slave_ca2phy_5[319:0]), // Templated
      .tb_m2s_marker_loc		(CHAN_M2S_MARKER_LOC),	 // Templated
      .tb_s2m_marker_loc		(CHAN_S2M_MARKER_LOC),	 // Templated
      .tb_master_rate			(MASTER_RATE),		 // Templated
      .tb_slave_rate			(SLAVE_RATE),		 // Templated
      .m_gen2_mode			(m_gen2_mode),
      .tb_m2s_latency			(CHAN_5_M2S_LATENCY),	 // Templated
      .tb_s2m_latency			(CHAN_5_S2M_LATENCY),	 // Templated
      .tb_master_rx_dll_time		(CHAN_5_M2S_DLL_TIME),	 // Templated
      .tb_slave_rx_dll_time		(CHAN_5_M2S_DLL_TIME),	 // Templated
      .tb_en_asymmetric			(1'b1));			 // Templated

   phy_to_phy_lite phy_to_phy_lite_i6
     (/*AUTOINST*/
      // Outputs
      .master_sl_tx_transfer_en		(master_sl_tx_transfer_en[6]), // Templated
      .master_ms_tx_transfer_en		(master_ms_tx_transfer_en[6]), // Templated
      .slave_sl_tx_transfer_en		(slave_sl_tx_transfer_en[6]), // Templated
      .slave_ms_tx_transfer_en		(slave_ms_tx_transfer_en[6]), // Templated
      .s2m_data_out			(master_phy2ca_6[319:0]), // Templated
      .m2s_data_out			(slave_phy2ca_6[319:0]), // Templated
      // Inputs
      .fwd_clk				(clk_phy),		 // Templated
      .ns_adapter_rstn			(rst_phy_n),		 // Templated
      .m_wr_clk				(m_wr_clk),
      .s_wr_clk				(s_wr_clk),
      .m2s_data_in			(master_ca2phy_6[319:0]), // Templated
      .s2m_data_in			(slave_ca2phy_6[319:0]), // Templated
      .tb_m2s_marker_loc		(CHAN_M2S_MARKER_LOC),	 // Templated
      .tb_s2m_marker_loc		(CHAN_S2M_MARKER_LOC),	 // Templated
      .tb_master_rate			(MASTER_RATE),		 // Templated
      .tb_slave_rate			(SLAVE_RATE),		 // Templated
      .m_gen2_mode			(m_gen2_mode),
      .tb_m2s_latency			(CHAN_6_M2S_LATENCY),	 // Templated
      .tb_s2m_latency			(CHAN_6_S2M_LATENCY),	 // Templated
      .tb_master_rx_dll_time		(CHAN_6_M2S_DLL_TIME),	 // Templated
      .tb_slave_rx_dll_time		(CHAN_6_M2S_DLL_TIME),	 // Templated
      .tb_en_asymmetric			(1'b1));			 // Templated

// DUT
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Actual Test

integer TestPhase=0;
event sub_phase_trig; // this is for display purposes only
logic let_phase_control_flowcontrol=0;
logic disable_ds_flowcontrol=0;
logic disable_us_performance_cap=0;
logic [31:0] tempdata0=0;

initial
begin
  wait (m_wr_rst_n === 1'b1);
  wait (s_wr_rst_n === 1'b1);
  repeat (10) @(posedge m_wr_clk);
  repeat (10) @(posedge s_wr_clk);

  if (`ENABLE_PHASE_01)
  begin
    TestPhase = 1 ;
    repeat (100) @(posedge m_wr_clk);

    repeat (20)
    begin
      // Send minimal sized write
      init_data(1);
      wait_until_empty();
      -> sub_phase_trig;
      repeat (100 + ($random & 4'hf)) @(posedge m_wr_clk); // the random causes the beat of data to be in different positions on the quarter side
      -> sub_phase_trig;
    end

    wait_until_empty();

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge m_wr_clk);
  end

  if (`ENABLE_PHASE_02)
  begin
    TestPhase = 2 ;
    repeat (100) @(posedge m_wr_clk);

    repeat (20)
    begin
      // Send minimal sized write
      init_data(1);
      wait_until_empty();
      repeat (100) @(posedge m_wr_clk);
      -> sub_phase_trig;
    end

    wait_until_empty();

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge m_wr_clk);
  end


  if (`ENABLE_PHASE_03)
  begin
    TestPhase = 3 ;
    repeat (100) @(posedge m_wr_clk);

    repeat (20)
    begin
      // Send medium sized write
      init_data(10);
      wait_until_empty();
      repeat (100) @(posedge m_wr_clk);
      -> sub_phase_trig;
    end

    wait_until_empty();

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge m_wr_clk);
  end

  if (`ENABLE_PHASE_04)
  begin
    TestPhase = 4 ;
    repeat (100) @(posedge m_wr_clk);

    repeat (20)
    begin
      // Send medium sized write
      init_data(10);
      wait_until_empty();
      repeat (100) @(posedge m_wr_clk);
      -> sub_phase_trig;
    end

    wait_until_empty();

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge m_wr_clk);
  end

  if (`ENABLE_PHASE_05)
  begin
    TestPhase = 5 ;
    repeat (100) @(posedge m_wr_clk);

    repeat (20)
    begin
      // Send max sized write
      init_data(256);
      wait_until_empty();
      repeat (100) @(posedge m_wr_clk);
      -> sub_phase_trig;
    end

    wait_until_empty();

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge m_wr_clk);
  end

  if (`ENABLE_PHASE_06)
  begin
    TestPhase = 6 ;
    repeat (100) @(posedge m_wr_clk);

    repeat (20)
    begin
      // Send max sized write
      init_data(256);
      wait_until_empty();
      repeat (100) @(posedge m_wr_clk);
      -> sub_phase_trig;
    end

    wait_until_empty();

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge m_wr_clk);
  end

  if (`ENABLE_PHASE_07)
  begin
    TestPhase = 7 ;
    repeat (100) @(posedge m_wr_clk);

    disable_us_performance_cap = 1;
    repeat (100) @(posedge m_wr_clk);

    repeat (20)
    begin
      init_data ( $urandom_range(1,256) );
      -> sub_phase_trig;
    end

    // This takes a while (so long it triggers timeout)
    // So we'll add a longish wait.
    repeat (100_000) @(posedge m_wr_clk);
    wait_until_empty();

    disable_us_performance_cap = 0;
    repeat (100) @(posedge m_wr_clk);

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge m_wr_clk);
  end

  if (`ENABLE_PHASE_08)
  begin
    TestPhase = 8 ;
    repeat (100) @(posedge m_wr_clk);

    disable_ds_flowcontrol = 1;
    disable_us_performance_cap = 1;
    repeat (100) @(posedge m_wr_clk);

    repeat (20)
    begin
      init_data  ( 256 );
      -> sub_phase_trig;
    end
    wait_until_empty();

    disable_us_performance_cap = 0;
    disable_ds_flowcontrol = 0;
    repeat (100) @(posedge m_wr_clk);

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge m_wr_clk);
  end

  if (`ENABLE_PHASE_09)
  begin
    TestPhase = 9 ;
    repeat (100) @(posedge m_wr_clk);

    let_phase_control_flowcontrol = 1;
    disable_ds_flowcontrol = 1;
    disable_us_performance_cap = 1;
    repeat (100) @(posedge m_wr_clk);

    // Assert Flow Control
    @(posedge  s_wr_clk);
    user2_tready <= 1'b0;
    @(posedge  m_wr_clk);

    for (tempdata0 = 0; tempdata0 < 20; tempdata0 = tempdata0 + 1)
    begin
      init_data  ( 10 );
      -> sub_phase_trig;

      repeat (5) @(posedge  s_wr_clk);
      repeat (10)
      begin
        repeat (tempdata0) @(posedge  s_wr_clk);
        user2_tready <= 1'b1; @(posedge  s_wr_clk); user2_tready <= 1'b0; @(posedge  s_wr_clk);
      end

      user2_tready <= 1'b1;

      wait_until_empty();
    end

    disable_us_performance_cap = 0;
    disable_ds_flowcontrol = 0;
    let_phase_control_flowcontrol = 0;
    repeat (100) @(posedge m_wr_clk);

    $display ("Finished Phase %0d at time %0d", TestPhase, $time);
    repeat (100) @(posedge m_wr_clk);
  end

  repeat (100) @(posedge m_wr_clk);
  repeat (100) @(posedge s_wr_clk);
  finish_simulation;
end

// Actual Test
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Transaction Queueing

logic [256-1:0]                                pseudo_rand_iteration = 256'h55555555_66666666_77777777_88888888_11111111_22222222_33333333_44444444;

logic [(256 * 1)-1:0]         queue_master_act_tdata   [$] ;

logic [(256 * 1)-1:0]         queue_slave_exp_tdata    [$] ;

task init_data;
  input [31:0] burst_length;

  logic [(256 * 1)-1:0] tx_mst_tdata   ;

  logic [7:0] remaining_burst_length;
  begin
    tx_mst_tdata = pseudo_rand_iteration  ;
    pseudo_rand_iteration = pseudo_rand_iteration + 1;

    // Generate several beats of W
    remaining_burst_length = burst_length;
    repeat (burst_length * MASTER_RATE)
    begin
      // Randomize Data Ever cycle

      if (`DATA_DEBUG)
      begin
        tx_mst_tdata = tx_mst_tdata + 256'h11111111_11111111_11111111_11111111_11111111_11111111_11111111_11111111;
      end
      else
      begin
        assert(std::randomize( tx_mst_tdata ));
      end

      queue_master_act_tdata.push_back  ( tx_mst_tdata ) ;
      queue_slave_exp_tdata.push_back   ( tx_mst_tdata ) ;

      remaining_burst_length = remaining_burst_length - 1;
    end
  end
endtask

// Transaction Queueing
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Channel Initiators

// ST
   logic [(256 * MASTER_RATE)-1:0] user1_1beat_tdata;

   integer user1_1beat;
always @(posedge m_wr_clk)
while (queue_master_act_tdata.size())
begin


   for (user1_1beat=0; user1_1beat < MASTER_RATE; user1_1beat = user1_1beat + 1)
   begin
     user1_1beat_tdata [256*user1_1beat+:256] = queue_master_act_tdata.pop_front();
   end

   user1_tdata  <= user1_1beat_tdata;
   user1_tvalid <= 1'b1 ;

   @(negedge m_wr_clk);
   while (user1_tready == 1'b0) @(negedge m_wr_clk);
   @(posedge m_wr_clk);

   user1_tdata  <= '0;
   user1_tvalid <= '0;
end

// Channel Initiators
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Randomize User Readys

logic [7:0] rand_percent_tready_delay;

logic [7:0] rand_tready_delay_value;


always @(posedge s_wr_clk)
begin
  if (let_phase_control_flowcontrol == 1'b0)
  begin
    rand_tready_delay_value = $urandom_range(1,100);
    rand_percent_tready_delay = $urandom_range(1,100);

    user2_tready <= disable_ds_flowcontrol ? 1'b1 : (rand_percent_tready_delay > 50);

    repeat (rand_tready_delay_value) @(posedge s_wr_clk);
  end
end

// Randomize User Readys
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Channel Receivers

   logic [256-1:0]	user2_1beat_tdata;
   logic          	user2_had_1beat;

   integer user2_1beat;
always @(posedge s_wr_clk)
if (user2_tvalid && user2_tready)
begin

   user2_had_1beat = 0;

   for (user2_1beat=0; user2_1beat < SLAVE_RATE; user2_1beat = user2_1beat + 1)
   begin
       if ( (user2_enable[user2_1beat] != 0) )
       begin
         user2_had_1beat = 1;

         user2_1beat_tdata = user2_tdata[256*user2_1beat+:256];

         if ( (user2_1beat_tdata !== queue_slave_exp_tdata[0]  ) )
         begin
           $display ("ERROR ST Receive at time %t", $time);
           $display ("   user2_tdata    act:%x  exp:%x", user2_1beat_tdata, queue_slave_exp_tdata[0]  );

           $display ("   full user2_1beat        %x", user2_1beat );
           $display ("   full user2_tdata    act:%x", user2_tdata );
           $display ("   full user2_enable   act:%x", user2_enable );
           NUMBER_FAILED = NUMBER_FAILED + 1;
           finish_simulation;
         end
         else
           NUMBER_PASSED = NUMBER_PASSED + 1;

         void'(queue_slave_exp_tdata.pop_front()  );
       end
   end

   if (user2_had_1beat == 0)
   begin
     $display ("ERROR Received completely empty AXI-ST time %t", $time);
     $display ("   user2_tdata    act:%x", user2_tdata );
     $display ("   user2_enable   act:%x", user2_enable );

     user2_1beat = 0;
     $display ("");
     $display ("   beat %x", user2_1beat);
     $display ("   user2_tdata    act:%x", user2_tdata [256*user2_1beat+:256]);
     $display ("   user2_enable   act:%x", user2_enable[user2_1beat] );

     user2_1beat = 1;
     $display ("");
     $display ("   beat %x", user2_1beat);
     $display ("   user2_tdata    act:%x", user2_tdata [256*user2_1beat+:256]);
     $display ("   user2_enable   act:%x", user2_enable[user2_1beat] );

     user2_1beat = 2;
     $display ("");
     $display ("   beat %x", user2_1beat);
     $display ("   user2_tdata    act:%x", user2_tdata [256*user2_1beat+:256]);
     $display ("   user2_enable   act:%x", user2_enable[user2_1beat] );

     user2_1beat = 3;
     $display ("");
     $display ("   beat %x", user2_1beat);
     $display ("   user2_tdata    act:%x", user2_tdata [256*user2_1beat+:256]);
     $display ("   user2_enable   act:%x", user2_enable[user2_1beat] );
     NUMBER_FAILED = NUMBER_FAILED + 1;
     finish_simulation;
   end
   else
     NUMBER_PASSED = NUMBER_PASSED + 1;
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
             (queue_master_act_tdata.size  () == 0) &&
             (queue_slave_exp_tdata.size   () == 0) &&
             (tx_st_debug_status[31:24]       == `TX_INIT_CREDIT) );

    end

    begin
      @(posedge m_wr_clk);
      while (wait_timeout > 0)
      begin
        wait_timeout = wait_timeout - 1;
        @(posedge m_wr_clk);
      end
    end
  join_any

  if (wait_timeout <= 0)
  begin
    $display ("ERROR Timeout waiting for quiescence at time %t", $time);
    $display ("// Initiators");
    $display ("   queue_master_act_tdata.size  () = %d", queue_master_act_tdata.size  () );
    $display ("");
    $display ("// Receivers");
    $display ("   queue_slave_exp_tdata.size   () = %d", queue_slave_exp_tdata.size  () );
    $display ("");
    $display ("// Credit");
    $display ("   tx_st_debug_status[31:24]       = %d (should be %d)", tx_st_debug_status[31:24], `TX_INIT_CREDIT );
    NUMBER_FAILED = NUMBER_FAILED + 1;
    finish_simulation;
  end
  else
    NUMBER_PASSED = NUMBER_PASSED + 1;

end
endtask

// General functions
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// Check FIFO Usage

reg [7:0] max_rx_fifo_useage  ;
reg       tx_credit_nonzero  ;
reg [7:0] min_tx_credit  ;
reg [7:0] max_tx_credit  ;

always @(posedge m_wr_clk or negedge m_wr_rst_n)
if (!m_wr_rst_n)
  max_rx_fifo_useage <= 0;
else if (rx_st_debug_status[7:0] > max_rx_fifo_useage)
  max_rx_fifo_useage <= rx_st_debug_status[7:0];

always @(posedge m_wr_clk or negedge m_wr_rst_n)
if (!m_wr_rst_n)
  tx_credit_nonzero <= 1'h0;
else if (|tx_st_debug_status[31:24])
  tx_credit_nonzero <= 1'h1;

always @(posedge m_wr_clk or negedge m_wr_rst_n)
if (!m_wr_rst_n)
  min_tx_credit <= 8'hff;
else if ((tx_st_debug_status[31:24] < min_tx_credit) & tx_credit_nonzero)
  min_tx_credit <= tx_st_debug_status[31:24];

always @(posedge m_wr_clk or negedge m_wr_rst_n)
if (!m_wr_rst_n)
  max_tx_credit <= 8'h00;
else if ((tx_st_debug_status[31:24] > max_tx_credit) & tx_credit_nonzero)
  max_tx_credit <= tx_st_debug_status[31:24];

// Check FIFO Usage
//////////////////////////////////////////////////////////////////////

task finish_simulation;
begin

  $display ("  Max RX FIFO Usage:  %d and configured for %d", max_rx_fifo_useage, rx_st_debug_status[15:8]);
  $display ("  Max/Min TX Credit:  %d / %d", `TX_INIT_CREDIT, min_tx_credit);

  if ((max_rx_fifo_useage != rx_st_debug_status[15:8]) || (max_rx_fifo_useage != `TX_INIT_CREDIT / SLAVE_RATE) || (min_tx_credit != 0))
  begin
    $display ("ERROR Did not make use of full FIFO/Credit");
    $display ("ERROR RX FIFO Depth configured for %d (should be %d) ", rx_st_debug_status[15:8], `TX_INIT_CREDIT / SLAVE_RATE);
    $display ("ERROR RX FIFO usaed should be      %d", max_rx_fifo_useage );
    $display ("ERROR Min TX Credit should be 0 and was %d", min_tx_credit );
    NUMBER_FAILED = NUMBER_FAILED + 1;
  end
  else
  begin
    $display ("  Good, made full use of credits/data");
    NUMBER_PASSED = NUMBER_PASSED + 1;
  end

  $display ("NUMBER_PASSED            %32d",NUMBER_PASSED);
  $display ("Number That Did not Pass %32d",NUMBER_FAILED);
  $display ("");
  $display ("SIM COMPLETE");
  $display ("Finishing simulation via finish_simulation task");

  @(posedge m_wr_clk);
  $finish(0);
end
endtask











//`include "useful_functions.vh"

// Local Variables:
// verilog-library-directories:("../*" "../../*"  "../../ca/*" "../script/premade_examples/*/")
// End:
//


endmodule

