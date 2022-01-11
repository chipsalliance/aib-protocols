`ifndef _COMMON_LL_AUTO_SYNC_SV
`define _COMMON_LL_AUTO_SYNC_SV
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
//Functional Descript:
//
// Logic Link Transmit Block
//
// Parameters refer to the WIDTH of the Logic Link Data (no valid/ready) and
// the DEPTH is the depth of the TX_FIFO (typically 1)
//
////////////////////////////////////////////////////////////

module ll_auto_sync #(parameter MARKER_WIDTH=1, PERSISTENT_MARKER=1'b1, PERSISTENT_STROBE=1'b1, NO_MARKER=1'b0) (
    // clk, reset
    input logic                                 clk_wr              ,
    input logic                                 rst_wr_n            ,

    // Transmit Control
    input logic                                 tx_online           ,
    input logic [15:0]                          delay_z_value      ,
    input logic [15:0]                          delay_y_value      ,
    output logic                                tx_online_delay     ,

    input  logic [MARKER_WIDTH-1:0]             tx_mrk_userbit      ,
    input  logic                                tx_stb_userbit      ,
    output logic [MARKER_WIDTH-1:0]             tx_auto_mrk_userbit ,
    output logic                                tx_auto_stb_userbit ,

    // Receive Control
    input logic                                 rx_online           ,
    input logic                                 rx_online_holdoff   ,
    input logic [15:0]                          delay_x_value       ,
    output logic                                rx_online_delay

  );

  parameter DISABLE_TX_AUTOSYNC = 1'b0;
  parameter DISABLE_RX_AUTOSYNC = 1'b0;

  logic tx_online_delay_z_w_strobe;
////////////////////////////////////////////////////////////
// Delay Online by Z
// This delays online by Z
// At this point we should stop sending the USER inserted marker
// We should also allow exactly one USER Strobe.
// For the latter, we gate off the USER Strobe for all but one word as defined
// by the USER Marker. This is needed for asymmetric gearboxing.

  logic                 tx_online_delay_z;

   level_delay level_delay_i_zvalue
     (/*AUTOINST*/
      // Outputs
      .delayed_en			(tx_online_delay_z),
      // Inputs
      .rst_core_n			(rst_wr_n),
      .clk_core				(clk_wr),
      .enable				(tx_online),
      .delay_value			(delay_z_value[15:0]));

// Delay Online by Z
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Further Delay Online by Y+Z
// This delays online from the Word Alignment until the Channel Alignment
// is complete. At this point we begin real transmisson.

  logic                 tx_online_delay_y;

   level_delay level_delay_i_yvalue
     (/*AUTOINST*/
      // Outputs
      .delayed_en			(tx_online_delay_y),
      // Inputs
      .rst_core_n			(rst_wr_n),
      .clk_core				(clk_wr),
      .enable				(tx_online_delay_z_w_strobe),
      .delay_value			(delay_y_value[15:0]));

// Further Delay Online by Y+Z
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Determine time when we are going to enable automatic
// synchronization USER strobe for a one shot Strobe.
// Also determines when to disable USER Marker.

  logic                 delay_z_1st_marker;
  logic                 delay_z_2nd_marker;
  logic                 delay_z_1st_strobe;

  always @(posedge clk_wr or negedge rst_wr_n)
  if (!rst_wr_n)
    delay_z_1st_marker <= 1'h0;
  else if (tx_online_delay_z == 1'b0)
    delay_z_1st_marker <= 1'h0;
  else if ((NO_MARKER == 1'b0) & (|tx_mrk_userbit))
    delay_z_1st_marker <= 1'b1;
  else if ((NO_MARKER == 1'b1) & (tx_stb_userbit))
    delay_z_1st_marker <= 1'b1;

  always @(posedge clk_wr or negedge rst_wr_n)
  if (!rst_wr_n)
    delay_z_1st_strobe <= 1'h0;
  else if (delay_z_1st_marker == 1'b0)
    delay_z_1st_strobe <= 1'h0;
  else if (tx_stb_userbit)
    delay_z_1st_strobe <= 1'b1;

  always @(posedge clk_wr or negedge rst_wr_n)
  if (!rst_wr_n)
    delay_z_2nd_marker <= 1'h0;
  else if (delay_z_1st_marker == 1'b0)
    delay_z_2nd_marker <= 1'h0;
  else if ((NO_MARKER == 1'b0) & delay_z_1st_strobe & (|tx_mrk_userbit))
    delay_z_2nd_marker <= 1'b1;
  else if ((NO_MARKER == 1'b1) & (tx_stb_userbit))
    delay_z_2nd_marker <= 1'b1;

  assign tx_online_delay_z_w_strobe = delay_z_2nd_marker & tx_online_delay_z;
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
  else if (delay_z_2nd_marker == 1'b0)
    marker_replay_reg <= {tx_mrk_userbit, marker_replay_reg[(4*MARKER_WIDTH)-1:MARKER_WIDTH]};
  else
    marker_replay_reg <= {marker_replay_reg[0], marker_replay_reg[3:1]};
// Sample incomming USER Marker
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Gate off signals

// Disable USER Marker after X+Z
  assign tx_auto_mrk_userbit = DISABLE_TX_AUTOSYNC ? tx_mrk_userbit : PERSISTENT_MARKER ? tx_mrk_userbit : (tx_mrk_userbit & {MARKER_WIDTH{(~delay_z_1st_marker)}}) ;

// Allow one Word of Strobe
  assign tx_auto_stb_userbit = DISABLE_TX_AUTOSYNC ? tx_stb_userbit : PERSISTENT_STROBE ? tx_stb_userbit : (tx_stb_userbit & delay_z_1st_marker & (~delay_z_2nd_marker)) ;

// Test rst of logic we're good to begin transmission
  assign tx_online_delay     = DISABLE_TX_AUTOSYNC ? tx_online      : tx_online_delay_y ;

// Gate off signals
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Generate delay of RX Online

  logic                 rxon_holdoff_hold_reg;
  logic                 rx_delayed_online;

   level_delay level_delay_i_xvalue
     (/*AUTOINST*/
      // Outputs
      .delayed_en			(rx_delayed_online),	 // Templated
      // Inputs
      .rst_core_n			(rst_wr_n),		 // Templated
      .clk_core				(clk_wr),		 // Templated
      .enable				(rx_online),		 // Templated
      .delay_value			(delay_x_value[15:0]));	 // Templated

  always @(posedge clk_wr or negedge rst_wr_n)
  if (!rst_wr_n)
    rxon_holdoff_hold_reg <= 1'b1;
  else if (~rx_delayed_online)
    rxon_holdoff_hold_reg <= rxon_holdoff_hold_reg;
  else if (~rx_online_holdoff)
    rxon_holdoff_hold_reg <= 1'b0;

// Test rst of logic we're good to begin transmission
  assign rx_online_delay     = DISABLE_RX_AUTOSYNC ? rx_online : (rxon_holdoff_hold_reg ? 1'b0 : rx_delayed_online) ;

// Generate delay of RX Online
////////////////////////////////////////////////////////////

endmodule
`endif




// Local Variables:
// verilog-library-directories:("../*" "../../*/rtl" )
// verilog-auto-inst-param-value:()
// End:
//
