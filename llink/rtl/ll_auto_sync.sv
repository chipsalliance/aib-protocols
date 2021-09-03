////////////////////////////////////////////////////////////
// Proprietary Information of Eximius Design
//
//        (C) Copyright 2021 Eximius Design
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
// Logic Link Transmit Block
//
// Parameters refer to the WIDTH of the Logic Link Data (no valid/ready) and
// the DEPTH is the depth of the TX_FIFO (typically 1)
//
////////////////////////////////////////////////////////////

module ll_auto_sync #(parameter MARKER_WIDTH=1, PERSISTENT_MARKER=1'b1, PERSISTENT_STROBE=1'b1) (
    // clk, reset
    input logic                                 clk_wr              ,
    input logic                                 rst_wr_n            ,

    // Transmit Control
    input logic                                 tx_online           ,
    input logic [7:0]                           delay_xz_value      ,
    input logic [7:0]                           delay_yz_value      ,
    output logic                                tx_online_delay     ,

    input  logic [MARKER_WIDTH-1:0]             tx_mrk_userbit      ,
    input  logic                                tx_stb_userbit      ,
    output logic [MARKER_WIDTH-1:0]             tx_auto_mrk_userbit ,
    output logic                                tx_auto_stb_userbit ,

    // Receive Control
    input logic                                 rx_online           ,
    input logic [7:0]                           delay_x_value       ,
    output logic                                rx_online_delay

  );

  parameter DISABLE_TX_AUTOSYNC = 1'b0;
  parameter DISABLE_RX_AUTOSYNC = 1'b0;

////////////////////////////////////////////////////////////
// Delay Online by X+Z
// This delays online by X (time for Word Marker to Sync) plus a little (Z)
// At this point we should stop sending the USER inserted marker
// We should also allow exactly one USER Strobe.
// For the latter, we gate off the USER Strobe for all but one word as defined
// by the USER Marker. This is needed for asymmetric gearboxing.

  logic                 tx_online_delayxz;

   level_delay level_delay_ixzvalue
     (/*AUTOINST*/
      // Outputs
      .delayed_en			(tx_online_delayxz),
      // Inputs
      .rst_core_n			(rst_wr_n),
      .clk_core				(clk_wr),
      .enable				(tx_online),
      .delay_value			(delay_xz_value[7:0]));

// Delay Online by X+Z
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Further Delay Online by Y+Z
// This delays online from the Word Alignment until the Channel Alignment
// is complete. At this point we begin real transmisson.

  logic                 tx_delayed_online;

   level_delay level_delay_iyzvalue
     (/*AUTOINST*/
      // Outputs
      .delayed_en			(tx_delayed_online),
      // Inputs
      .rst_core_n			(rst_wr_n),
      .clk_core				(clk_wr),
      .enable				(tx_online_delayxz),
      .delay_value			(delay_yz_value[7:0]));

// Further Delay Online by Y+Z
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Determine time when we are going to enable automatic
// synchronization USER strobe for a one shot Strobe.
// Also determines when to disable USER Marker.

  logic                 delayxz_1st_marker;
  logic                 delayxz_2nd_marker;

  always @(posedge clk_wr or negedge rst_wr_n)
  if (!rst_wr_n)
    delayxz_1st_marker <= 1'h0;
  else if (tx_online_delayxz == 1'b0)
    delayxz_1st_marker <= 1'h0;
  else if (|tx_mrk_userbit)
    delayxz_1st_marker <= 1'b1;

  always @(posedge clk_wr or negedge rst_wr_n)
  if (!rst_wr_n)
    delayxz_2nd_marker <= 1'h0;
  else if (delayxz_1st_marker == 1'b0)
    delayxz_2nd_marker <= 1'h0;
  else if (|tx_mrk_userbit)
    delayxz_2nd_marker <= 1'b1;

// Sample incomming USER Marker
////////////////////////////////////////////////////////////


////////////////////////////////////////////////////////////
// Sample incomming USER Marker
// Here we sample the incomming USER marker and reocrd it for
// later use. This is for asymetric gearboxing flow control.

  logic [(4*MARKER_WIDTH)-1:0]           marker_replay_reg;

  always @(posedge clk_wr or negedge rst_wr_n)
  if (!rst_wr_n)
    marker_replay_reg <= {(4*MARKER_WIDTH){1'b1}};
  else if (delayxz_2nd_marker == 1'b0)
    marker_replay_reg <= {tx_mrk_userbit, marker_replay_reg[(4*MARKER_WIDTH)-1:MARKER_WIDTH]};
  else
    marker_replay_reg <= {marker_replay_reg[0], marker_replay_reg[3:1]};
// Sample incomming USER Marker
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Gate off signals

// Disable USER Marker after X+Z
  assign tx_auto_mrk_userbit = DISABLE_TX_AUTOSYNC ? tx_mrk_userbit : PERSISTENT_MARKER ? tx_mrk_userbit : (tx_mrk_userbit & {MARKER_WIDTH{(~delayxz_1st_marker)}}) ;

// Allow one Word of Strobe
  assign tx_auto_stb_userbit = DISABLE_TX_AUTOSYNC ? tx_stb_userbit : PERSISTENT_STROBE ? tx_stb_userbit : (tx_stb_userbit & delayxz_1st_marker & (~delayxz_2nd_marker)) ;

// Test rst of logic we're good to begin transmission
  assign tx_online_delay     = DISABLE_TX_AUTOSYNC ? tx_online      : tx_delayed_online ;

// Gate off signals
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Generate delay of RX Online

  logic                 rx_delayed_online;

   level_delay level_delay_ixvalue
     (/*AUTOINST*/
      // Outputs
      .delayed_en			(rx_delayed_online),	 // Templated
      // Inputs
      .rst_core_n			(rst_wr_n),		 // Templated
      .clk_core				(clk_wr),		 // Templated
      .enable				(rx_online),		 // Templated
      .delay_value			(delay_x_value[7:0]));	 // Templated

// Test rst of logic we're good to begin transmission
  assign rx_online_delay     = DISABLE_RX_AUTOSYNC ? rx_online : rx_delayed_online ;

// Generate delay of RX Online
////////////////////////////////////////////////////////////

endmodule




// Local Variables:
// verilog-library-directories:("../*" "../../*/rtl" )
// verilog-auto-inst-param-value:()
// End:
//