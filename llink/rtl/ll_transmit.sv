`ifndef _COMMON_LL_TRANSMIT_SV
`define _COMMON_LL_TRANSMIT_SV
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

module ll_transmit #(parameter WIDTH=8, parameter DEPTH=8'h1, parameter TX_CRED_SIZE=3'h1, parameter ASYMMETRIC_CREDIT=1'h0, parameter DEFAULT_TX_CRED=8'd1) (
    // clk, reset
    input logic                                 clk_wr ,
    input logic                                 rst_wr_n ,

    // Control Logic
    input logic                                 tx_online ,
    input logic                                 rx_online ,
    input logic [7:0]                           init_i_credit ,
    input logic                                 tx_i_pop_ovrd ,
    input logic                                 end_of_txcred_coal ,

    // From Upstream
    input  logic  [WIDTH-1:0]                   txfifo_i_data ,
    input  logic                                user_i_valid ,
    output logic                                user_i_ready ,

    // To downstream
    output  logic  [WIDTH-1:0]                  tx_i_data ,
    output  logic                               tx_i_pushbit ,

    // RX Credit
    input logic	[3:0]		                rx_i_credit ,

    // Debug / status
    output logic [31:0]                         tx_i_debug_status

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
  logic [7:0]		dbg_curr_i_credit;	// From ll_tx_cred_ii of ll_tx_cred.v
  wire [FIFO_COUNT_MSB:0] dbg_txfifo_i_numfilled;// From syncfifo_ii of syncfifo_reg.v
  wire			txfifo_i_empty;		// From syncfifo_ii of syncfifo_reg.v
  wire			txfifo_i_full;		// From syncfifo_ii of syncfifo_reg.v
  wire			txfifo_i_overflow_pulse;// From syncfifo_ii of syncfifo_reg.v
  logic			txfifo_i_pop;		// From ll_tx_cred_ii of ll_tx_cred.v
  logic			txfifo_i_push;		// From ll_tx_ctrl_ii of ll_tx_ctrl.v
  wire			txfifo_i_underflow_pulse;// From syncfifo_ii of syncfifo_reg.v
  // End of automatics

   /* ll_tx_ctrl AUTO_TEMPLATE ".*_i\(.+\)" (
      .\(.*\)_i_\(.*\)			(\1_@_\2[]),
    );
    */
   ll_tx_ctrl ll_tx_ctrl_ii
     (/*AUTOINST*/
      // Outputs
      .txfifo_i_push			(txfifo_i_push),	 // Templated
      .user_i_ready			(user_i_ready),		 // Templated
      // Inputs
      .txfifo_i_full			(txfifo_i_full),	 // Templated
      .txfifo_i_pop			(txfifo_i_pop),		 // Templated
      .user_i_valid			(user_i_valid),		 // Templated
      .tx_online			(tx_online));

   /* ll_tx_cred AUTO_TEMPLATE ".*_i\(.+\)" (
      .\(.*\)_i_\(.*\)			(\1_@_\2[]),
    );
    */
   ll_tx_cred #(.TX_CRED_SIZE(TX_CRED_SIZE), .ASYMMETRIC_CREDIT(ASYMMETRIC_CREDIT), .DEFAULT_TX_CRED(DEFAULT_TX_CRED))  ll_tx_cred_ii
     (/*AUTOINST*/
      // Outputs
      .txfifo_i_pop			(txfifo_i_pop),		 // Templated
      .tx_i_pushbit			(tx_i_pushbit),		 // Templated
      .dbg_curr_i_credit		(dbg_curr_i_credit[7:0]), // Templated
      // Inputs
      .clk_wr				(clk_wr),
      .rst_wr_n				(rst_wr_n),
      .txfifo_i_empty			(txfifo_i_empty),	 // Templated
      .tx_online			(tx_online),
      .init_i_credit			(init_i_credit[7:0]),	 // Templated
      .end_of_txcred_coal		(end_of_txcred_coal),	 // Templated
      .rx_i_credit			(rx_i_credit[3:0]),	 // Templated
      .tx_i_pop_ovrd			(tx_i_pop_ovrd));	 // Templated

   /* syncfifo_reg AUTO_TEMPLATE ".*_i\(.+\)"  (
      .clk_core				(clk_wr),
      .rst_core_n			(rst_wr_n),
      .soft_reset			(1'b0),
      .write_push			(txfifo_@_push),
      .rddata				(tx_@_data[WIDTH-1:0]),
      .wrdata				(txfifo_@_data[WIDTH-1:0]),
      .numfilled			(dbg_txfifo_@_numfilled[FIFO_COUNT_MSB:0]),
      .numempty				(),
      .full				(txfifo_@_full),
      .empty				(txfifo_@_empty),
      .overflow_pulse			(txfifo_@_overflow_pulse),
      .underflow_pulse			(txfifo_@_underflow_pulse),
      .read_pop				(txfifo_@_pop),
    );
    */
   syncfifo_reg #(.FIFO_WIDTH_WID(WIDTH), .FIFO_DEPTH_WID(DEPTH)) syncfifo_ii
     (/*AUTOINST*/
      // Outputs
      .rddata				(tx_i_data[WIDTH-1:0]),	 // Templated
      .numfilled			(dbg_txfifo_i_numfilled[FIFO_COUNT_MSB:0]), // Templated
      .numempty				(),			 // Templated
      .full				(txfifo_i_full),	 // Templated
      .empty				(txfifo_i_empty),	 // Templated
      .overflow_pulse			(txfifo_i_overflow_pulse), // Templated
      .underflow_pulse			(txfifo_i_underflow_pulse), // Templated
      // Inputs
      .clk_core				(clk_wr),		 // Templated
      .rst_core_n			(rst_wr_n),		 // Templated
      .soft_reset			(1'b0),	                 // Templated
      .write_push			(txfifo_i_push),	 // Templated
      .wrdata				(txfifo_i_data[WIDTH-1:0]), // Templated
      .read_pop				(txfifo_i_pop));		 // Templated


reg tx_overflow_sticky;
reg tx_underflow_sticky;

assign tx_i_debug_status [7:0]   = '0 | dbg_txfifo_i_numfilled ;
assign tx_i_debug_status [15:8]  = DEPTH ;
assign tx_i_debug_status [16]    = '0 | tx_overflow_sticky     ;
assign tx_i_debug_status [17]    = '0 | tx_underflow_sticky    ;
assign tx_i_debug_status [18]    = rx_online                   ;
assign tx_i_debug_status [19]    = tx_online                   ;
assign tx_i_debug_status [23:20] = '0                          ;
assign tx_i_debug_status [31:24] = '0 | dbg_curr_i_credit      ;

always @(posedge clk_wr or negedge rst_wr_n)
if (!rst_wr_n)
  tx_overflow_sticky <= 1'b0;
else if (txfifo_i_overflow_pulse)
  tx_overflow_sticky <= 1'b1;

always @(posedge clk_wr or negedge rst_wr_n)
if (!rst_wr_n)
  tx_underflow_sticky <= 1'b0;
else if (txfifo_i_underflow_pulse)
  tx_underflow_sticky <= 1'b1;


endmodule
`endif




// Local Variables:
// verilog-library-directories:("../*" "../../*/rtl" )
// verilog-auto-inst-param-value:()
// End:
//
