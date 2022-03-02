`ifndef _COMMON_LL_RECEIVE_SV
`define _COMMON_LL_RECEIVE_SV
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
// Logic Link Receive Block
//
// Parameters refer to the WIDTH of the Logic Link Data (no valid/ready) and
// the DEPTH is the depth of the RX_FIFO
//
////////////////////////////////////////////////////////////

module ll_receive #(parameter WIDTH=8, parameter DEPTH=8'h1) (
    // clk, reset
    input logic                                 clk_wr ,
    input logic                                 rst_wr_n ,

    // Control Logic
    input logic                                 rx_online ,
    input logic                                 tx_online ,
    input logic                                 rx_i_push_ovrd ,

    // From Upstream
    input  logic  [WIDTH-1:0]                   rx_i_data ,
    input  logic                                rx_i_pushbit ,

    // To downstream
    output logic  [WIDTH-1:0]                   rxfifo_i_data ,
    output logic                                user_i_valid ,
    input  logic                                user_i_ready ,

    // RX Credit
    output logic			        tx_i_credit ,

    // Debug / status
    output logic  [31:0]                        rx_i_debug_status

  );


////////////////////////////////////////////////////////////
//  Do Not Modify
localparam FIFO_COUNT_WID  = ((DEPTH+1) > 1024 )  ?  0 :  // Invalid
                             ((DEPTH+1) > 512  )  ? 10 :
                             ((DEPTH+1) > 256  )  ?  9 :
                             ((DEPTH+1) > 128  )  ?  8 :
                             ((DEPTH+1) >  64  )  ?  7 :
                             ((DEPTH+1) >  32  )  ?  6 :
                             ((DEPTH+1) >  16  )  ?  5 :
                             ((DEPTH+1) >   8  )  ?  4 :
                             ((DEPTH+1) >   4  )  ?  3 :
                             ((DEPTH+1) >   2  )  ?  2 : 1 ;
localparam FIFO_COUNT_MSB = FIFO_COUNT_WID  - 1 ;
//  Do Not Modify
////////////////////////////////////////////////////////////

  //-----------------------
  //-- The below should be empty.  Debug for autos
  //-----------------------

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
  wire [FIFO_COUNT_MSB:0] dbg_rxfifo_i_numfilled;// From syncfifo_ii of syncfifo_ram.v
  wire			rxfifo_i_empty;		// From syncfifo_ii of syncfifo_ram.v
  wire			rxfifo_i_overflow_pulse;// From syncfifo_ii of syncfifo_ram.v
  logic			rxfifo_i_pop;		// From ll_rx_ctrl_ii of ll_rx_ctrl.v
  logic			rxfifo_i_push;		// From ll_rx_push_ii of ll_rx_push.v
  wire			rxfifo_i_underflow_pulse;// From syncfifo_ii of syncfifo_ram.v
  // End of automatics

   /* ll_rx_push AUTO_TEMPLATE ".*_i\(.+\)"  (
      .\(.*\)_i_\(.*\)			(\1_@_\2[]),
    );
    */
   ll_rx_push ll_rx_push_ii
     (/*AUTOINST*/
      // Outputs
      .rxfifo_i_push			(rxfifo_i_push),	 // Templated
      // Inputs
      .rx_online			(rx_online),
      .rx_i_push_ovrd			(rx_i_push_ovrd),	 // Templated
      .rx_i_pushbit			(rx_i_pushbit));		 // Templated

   /* ll_rx_ctrl AUTO_TEMPLATE ".*_i\(.+\)"  (
      .\(.*\)_i_\(.*\)			(\1_@_\2[]),
    );
    */
   ll_rx_ctrl #(.FIFO_COUNT_MSB(FIFO_COUNT_MSB)) ll_rx_ctrl_ii
     (/*AUTOINST*/
      // Outputs
      .user_i_valid			(user_i_valid),		 // Templated
      .rxfifo_i_pop			(rxfifo_i_pop),		 // Templated
      .tx_i_credit			(tx_i_credit),		 // Templated
      // Inputs
      .clk_wr				(clk_wr),
      .rst_wr_n				(rst_wr_n),
      .tx_online			(tx_online),
      .user_i_ready			(user_i_ready),		 // Templated
      .rxfifo_i_empty			(rxfifo_i_empty),	 // Templated
      .dbg_rxfifo_i_numfilled		(dbg_rxfifo_i_numfilled[FIFO_COUNT_MSB:0]), // Templated
      .rxfifo_i_push			(rxfifo_i_push));	 // Templated

   /* syncfifo_ram AUTO_TEMPLATE ".*_i\(.+\)"  (
      .clk_core				(clk_wr),
      .rst_core_n			(rst_wr_n),
      .soft_reset			(1'b0),
      .write_push			(rxfifo_@_push),
      .rddata				(rxfifo_@_data[WIDTH-1:0]),
      .wrdata				(rx_@_data[WIDTH-1:0]),
      .numfilled			(dbg_rxfifo_@_numfilled[]),
      .numempty				(),
      .full				(),
      .empty				(rxfifo_@_empty),
      .overflow_pulse			(rxfifo_@_overflow_pulse),
      .underflow_pulse			(rxfifo_@_underflow_pulse),
      .read_pop				(rxfifo_@_pop),
    );
    */
   syncfifo_ram #(.FIFO_WIDTH_WID(WIDTH), .FIFO_DEPTH_WID(DEPTH)) syncfifo_ii
     (/*AUTOINST*/
      // Outputs
      .rddata				(rxfifo_i_data[WIDTH-1:0]), // Templated
      .numfilled			(dbg_rxfifo_i_numfilled[FIFO_COUNT_MSB:0]), // Templated
      .numempty				(),			 // Templated
      .full				(),			 // Templated
      .empty				(rxfifo_i_empty),	 // Templated
      .overflow_pulse			(rxfifo_i_overflow_pulse), // Templated
      .underflow_pulse			(rxfifo_i_underflow_pulse), // Templated
      // Inputs
      .clk_core				(clk_wr),		 // Templated
      .rst_core_n			(rst_wr_n),		 // Templated
      .soft_reset			(1'b0),		         // Templated
      .write_push			(rxfifo_i_push),	 // Templated
      .wrdata				(rx_i_data[WIDTH-1:0]),	 // Templated
      .read_pop				(rxfifo_i_pop));		 // Templated


reg rx_overflow_sticky;
reg rx_underflow_sticky;

assign rx_i_debug_status [7:0]   = '0 | dbg_rxfifo_i_numfilled ;
assign rx_i_debug_status [15:8]  = DEPTH ;
assign rx_i_debug_status [16]    = '0 | rx_overflow_sticky     ;
assign rx_i_debug_status [17]    = '0 | rx_underflow_sticky    ;
assign rx_i_debug_status [18]    = rx_online                   ;
assign rx_i_debug_status [19]    = tx_online                   ;
assign rx_i_debug_status [23:20] = '0                          ;
assign rx_i_debug_status [31:24] = '0                          ;

always_ff @(posedge clk_wr or negedge rst_wr_n)
if (!rst_wr_n)
  rx_overflow_sticky <= 1'b0;
else if (rxfifo_i_overflow_pulse)
  rx_overflow_sticky <= 1'b1;

always_ff @(posedge clk_wr or negedge rst_wr_n)
if (!rst_wr_n)
  rx_underflow_sticky <= 1'b0;
else if (rxfifo_i_underflow_pulse)
  rx_underflow_sticky <= 1'b1;


endmodule
`endif




// Local Variables:
// verilog-library-directories:("../*" "../../*/rtl" )
// verilog-auto-inst-param-value:()
// End:
//
