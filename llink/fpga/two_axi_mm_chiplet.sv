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
//Functional Descript:
//
// This is a temporary module showing how the two sides (axi_mm_a32_d128_packet_master_top and axi_mm_a32_d128_packet_slave_top) would be in the system.
// This assumes the PHYs are transparent.
// Both sides use clk_wr and rst_wr_n
//
// Details of the design
// 32 bit addr
// 128 bit data
// Full Gen2 rate (no word markers).
// 3x AIB channels
// Persistent strobes on bit [1] of each channel.
// Uses DBI.
// All channels default to 1 credit only.
//
////////////////////////////////////////////////////////////

module two_axi_mm_chiplet (
    input  logic                                clk_wr        ,
    input  logic                                rst_wr_n      ,

    input  logic                                m_gen2_mode   ,

  // Master
    // AR channel
    input  logic  [3:0]                         user1_arid    ,
    input  logic  [2:0]                         user1_arsize  ,
    input  logic  [7:0]                         user1_arlen   ,
    input  logic  [1:0]                         user1_arburst ,
    input  logic  [31:0]                        user1_araddr  ,
    input  logic                                user1_arvalid ,
    output logic                                user1_arready ,

    // AW channel
    input  logic  [3:0]                         user1_awid    ,
    input  logic  [2:0]                         user1_awsize  ,
    input  logic  [7:0]                         user1_awlen   ,
    input  logic  [1:0]                         user1_awburst ,
    input  logic  [31:0]                        user1_awaddr  ,
    input  logic                                user1_awvalid ,
    output logic                                user1_awready ,

    // W channel
    input  logic  [3:0]                         user1_wid     ,
    input  logic  [127:0]                       user1_wdata   ,
    input  logic  [15:0]                        user1_wstrb   ,
    input  logic                                user1_wlast   ,
    input  logic                                user1_wvalid  ,
    output logic                                user1_wready  ,

    // R channel
    output logic   [3:0]                        user1_rid     ,
    output logic   [127:0]                      user1_rdata   ,
    output logic                                user1_rlast   ,
    output logic   [1:0]                        user1_rresp   ,
    output logic                                user1_rvalid  ,
    input  logic                                user1_rready  ,

    // B channel
    output logic   [3:0]                        user1_bid     ,
    output logic   [1:0]                        user1_bresp   ,
    output logic                                user1_bvalid  ,
    input  logic                                user1_bready  ,


  // SLAVE IF
    // AR channel
    output logic  [3:0]                         user2_arid    ,
    output logic  [2:0]                         user2_arsize  ,
    output logic  [7:0]                         user2_arlen   ,
    output logic  [1:0]                         user2_arburst ,
    output logic  [31:0]                        user2_araddr  ,
    output logic                                user2_arvalid ,
    input  logic                                user2_arready ,

    // AW channel
    output logic  [3:0]                         user2_awid    ,
    output logic  [2:0]                         user2_awsize  ,
    output logic  [7:0]                         user2_awlen   ,
    output logic  [1:0]                         user2_awburst ,
    output logic  [31:0]                        user2_awaddr  ,
    output logic                                user2_awvalid ,
    input  logic                                user2_awready ,

    // W channel
    output logic  [3:0]                         user2_wid     ,
    output logic  [127:0]                       user2_wdata   ,
    output logic  [15:0]                        user2_wstrb   ,
    output logic                                user2_wlast   ,
    output logic                                user2_wvalid  ,
    input  logic                                user2_wready  ,

    // R channel
    input  logic   [3:0]                        user2_rid     ,
    input  logic   [127:0]                      user2_rdata   ,
    input  logic                                user2_rlast   ,
    input  logic   [1:0]                        user2_rresp   ,
    input  logic                                user2_rvalid  ,
    output logic                                user2_rready  ,

    // B channel
    input  logic   [3:0]                        user2_bid     ,
    input  logic   [1:0]                        user2_bresp   ,
    input  logic                                user2_bvalid  ,
    output logic                                user2_bready  ,

    // All status have same format
    // debug_status [7:0] = current dpeth of FIFO
    // debug_status [15:8] = configured DEPTH of FIFO
    // debug_status [16] = overflow_sticky
    // debug_status [17] = underflow_sticky
    // debug_status [23:18] = 0
    // debug_status [31:24] = current transmit credits (on TX only)

    output logic [31:0]                         rx_ar_debug_status ,
    output logic [31:0]                         rx_aw_debug_status ,
    output logic [31:0]                         rx_b_debug_status ,
    output logic [31:0]                         rx_r_debug_status ,
    output logic [31:0]                         rx_w_debug_status ,
    output logic [31:0]                         tx_ar_debug_status ,
    output logic [31:0]                         tx_aw_debug_status ,
    output logic [31:0]                         tx_b_debug_status ,
    output logic [31:0]                         tx_r_debug_status ,
    output logic [31:0]                         tx_w_debug_status

   );


  //-----------------------
  //-- The below should be empty.  Debug for autos
  //-----------------------

  /*AUTOOUTPUT*/

  /*AUTOREG*/

  /*AUTOREGINPUT*/

  //-----------------------
  //-- The Above should be empty.  Debug for autos
  //-----------------------

  //-----------------------
  //-- WIRE DECLARATIONS --
  //-----------------------
  /*AUTOWIRE*/
  // Beginning of automatic wires (for undeclared instantiated-module outputs)
  logic [79:0]		rx_phy_master_0;	// From fake_phy of fake_phy.v
  logic [79:0]		rx_phy_slave_0;		// From fake_phy of fake_phy.v
  logic [79:0]		tx_phy_master_0;	// From axi_mm_a32_d128_packet_master_top of axi_mm_a32_d128_packet_master_top.v
  logic [79:0]		tx_phy_slave_0;		// From axi_mm_a32_d128_packet_slave_top of axi_mm_a32_d128_packet_slave_top.v
  // End of automatics


   /* axi_mm_a32_d128_packet_master_top AUTO_TEMPLATE ".*_i\(.+\)"  (
      .user_\(.*\)			(user1_\1[]),

      .rx_mrk_userbit			(),
      .rx_stb_userbit			(),
      .tx_mrk_userbit			(2'b0),  // No Markers
      .tx_stb_userbit			(1'b0),

      .init_ar_credit			(8'd8),
      .init_aw_credit			(8'd8),
      .init_w_credit			(8'd128),

      .disable_dbi			(1'b0),

      .rx_online			(1'b1), // Tied ONLINE high
      .tx_online			(1'b1), // Tied ONLINE high

      .delay_x_value                    (8'd20),        // Word Alignment Time or 0 in Multi-Channel case (tie RX_ONLINE to CA.ALIGN_DONE)
      .delay_xz_value                   (8'd24),        // Word Alignment Time + a little
      .delay_yz_value                   (8'd48),        // Channel Alignment Time + a little

      .tx_phy\(.\)                      (tx_phy_master_\1[]),
      .rx_phy\(.\)			(rx_phy_master_\1[]),
    );
    */
   axi_mm_a32_d128_packet_master_top  axi_mm_a32_d128_packet_master_top
     (/*AUTOINST*/
      // Outputs
      .tx_phy0				(tx_phy_master_0[79:0]), // Templated
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
      .tx_mrk_userbit			(2'b0),			 // Templated
      .tx_stb_userbit			(1'b0),			 // Templated
      .delay_x_value			(8'd20),		 // Templated
      .delay_xz_value			(8'd24),		 // Templated
      .delay_yz_value			(8'd48));		 // Templated



   /* axi_mm_a32_d128_packet_slave_top AUTO_TEMPLATE ".*_i\(.+\)"  (
      .user_\(.*\)			(user2_\1[]),

      .rx_mrk_userbit			(),
      .rx_stb_userbit			(),
      .tx_mrk_userbit			(2'b0),  // No Markers
      .tx_stb_userbit			(1'b0),

      .init_b_credit			(8'h8),
      .init_r_credit			(8'd128),

      .disable_dbi			(1'b0),

      .rx_online			(1'b1), // Tied ONLINE high
      .tx_online			(1'b1), // Tied ONLINE high

      .delay_x_value                    (8'd20),        // Word Alignment Time or 0 in Multi-Channel case (tie RX_ONLINE to CA.ALIGN_DONE)
      .delay_xz_value                   (8'd24),        // Word Alignment Time + a little
      .delay_yz_value                   (8'd48),        // Channel Alignment Time + a little

      .tx_phy\(.\)                      (tx_phy_slave_\1[]),
      .rx_phy\(.\)			(rx_phy_slave_\1[]),
    );
    */
   axi_mm_a32_d128_packet_slave_top  axi_mm_a32_d128_packet_slave_top
     (/*AUTOINST*/
      // Outputs
      .tx_phy0				(tx_phy_slave_0[79:0]),	 // Templated
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
      .init_b_credit			(8'h8),			 // Templated
      .rx_phy0				(rx_phy_slave_0[79:0]),	 // Templated
      .user_arready			(user2_arready),	 // Templated
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
      .tx_mrk_userbit			(2'b0),			 // Templated
      .tx_stb_userbit			(1'b0),			 // Templated
      .delay_x_value			(8'd20),		 // Templated
      .delay_xz_value			(8'd24),		 // Templated
      .delay_yz_value			(8'd48));		 // Templated

   /* fake_phy AUTO_TEMPLATE ".*_i\(.+\)"  (
      .rx_phy_slave_1			(),
      .rx_phy_slave_2			(),
      .rx_phy_slave_3			(),
      .rx_phy_master_1			(),
      .rx_phy_master_2			(),
      .rx_phy_master_3			(),
      // Inputs
      .tx_phy_master_1			(80'h0),
      .tx_phy_master_2			(80'h0),
      .tx_phy_master_3			(80'h0),
      .tx_phy_slave_1			(80'h0),
      .tx_phy_slave_2			(80'h0),
      .tx_phy_slave_3			(80'h0),
    );
    */
   fake_phy  fake_phy
     (/*AUTOINST*/
      // Outputs
      .rx_phy_slave_0			(rx_phy_slave_0[79:0]),
      .rx_phy_slave_1			(),			 // Templated
      .rx_phy_slave_2			(),			 // Templated
      .rx_phy_slave_3			(),			 // Templated
      .rx_phy_master_0			(rx_phy_master_0[79:0]),
      .rx_phy_master_1			(),			 // Templated
      .rx_phy_master_2			(),			 // Templated
      .rx_phy_master_3			(),			 // Templated
      // Inputs
      .clk_wr				(clk_wr),
      .tx_phy_master_0			(tx_phy_master_0[79:0]),
      .tx_phy_master_1			(80'h0),		 // Templated
      .tx_phy_master_2			(80'h0),		 // Templated
      .tx_phy_master_3			(80'h0),		 // Templated
      .tx_phy_slave_0			(tx_phy_slave_0[79:0]),
      .tx_phy_slave_1			(80'h0),		 // Templated
      .tx_phy_slave_2			(80'h0),		 // Templated
      .tx_phy_slave_3			(80'h0));		 // Templated


endmodule // two_axi_mm_chiplet //



// Local Variables:
// verilog-library-directories:("dut_rtl" ".")
// verilog-auto-inst-param-value:()
// End:
//
