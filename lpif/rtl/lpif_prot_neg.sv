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
// Functional Descript: LPIF Adapter IP
//
//
//
////////////////////////////////////////////////////////////

module lpif_prot_neg
  #(
    parameter AIB_VERSION = 2,
    parameter AIB_GENERATION = 2,
    parameter AIB_LANES = 4,
    parameter AIB_BITS_PER_LANE = 80,
    parameter AIB_CLOCK_RATE = 2000,
    parameter LPIF_CLOCK_RATE = 2000,
    parameter LPIF_DATA_WIDTH = 32,
    parameter LPIF_PIPELINE_STAGES = 0,
    parameter MEM_CACHE_STREAM_ID = 8'h1,
    parameter IO_STREAM_ID = 8'h2,
    parameter ARB_MUX_STREAM_ID = 8'h3,
    parameter PTM_RX_DELAY = 4,
    parameter LPIF_PL_PROTOCOL = 3'h4,
    parameter LPIF_IS_HOST = 1'b0,
    localparam LPIF_VALID_WIDTH = ((LPIF_DATA_WIDTH == 128) ? 2 : 1),
    localparam LPIF_CRC_WIDTH = ((LPIF_DATA_WIDTH == 128) ? 32 : 16)
    )
  (
   // LPIF Interface
   input  logic                                      lclk,
   input  logic                                      reset,

   output logic                                      negotiation_link_up,
   input  logic                                      ctl_link_up,

   output logic [LPIF_DATA_WIDTH*8-1:0]              ctrl_ustrm_data,
   input  logic [LPIF_DATA_WIDTH*8-1:0]              txrx_ustrm_data,

   input  logic [LPIF_DATA_WIDTH*8-1:0]              ctrl_dstrm_data,
   output logic [LPIF_DATA_WIDTH*8-1:0]              txrx_dstrm_data,

   output logic [2:0]                                pl_protocol,
   output logic                                      pl_protocol_vld,
   input  logic                                      renegotiate_n,

   output logic                                      pl_inband_pres,
   output logic                                      pl_portmode,
   output logic                                      pl_portmode_val
   );

`include "lpif_configs.svh"

////////////////////////////////////////////////////////////
// Break Into Useful Bits of Info
  localparam REQ_LOC  = 0;
  localparam ACK_LOC  = 1;
  localparam PROT_LOC = 2;

  logic [0:0] rmote_req ;
  logic [0:0] rmote_ack ;
  logic [2:0] rmote_prot ;

  logic [0:0] local_req ;
  logic [0:0] local_ack ;
  logic [2:0] local_prot ;

  logic       in_negotiation ;

  // For receive, we can reasonably always look at lsbits.
  assign rmote_req  = txrx_ustrm_data  [REQ_LOC +: 1];
  assign rmote_ack  = txrx_ustrm_data  [ACK_LOC +: 1];
  assign rmote_prot = txrx_ustrm_data  [PROT_LOC +: 3];

  // We always pass the upstream data directly to CTRL. We use the link_up to qualify this data.
  assign ctrl_ustrm_data = txrx_ustrm_data ;

  assign in_negotiation = ~negotiation_link_up;

  localparam TXRX_DATA_WIDTH =  X16_Q2 ? (1024 / 1) :
                                X16_H2 ? (512  / 1) :
                                X16_F2 ? (256  / 1) :
                                X8_Q2  ? (1024 / 2) :
                                X8_H2  ? (512  / 2) :
                                X8_F2  ? (256  / 2) :
                                X4_Q2  ? (1024 / 4) :
                                X4_H2  ? (512  / 4) :
                                X4_F2  ? (256  / 4) :
                                X16_H1 ? (1024 / 1) :
                                X16_F1 ? (512  / 1) :
                                X8_H1  ? (1024 / 2) :
                                X8_F1  ? (512  / 2) :
                                X4_H1  ? (1024 / 4) :
                                X4_F1  ? (512  / 4) :
                                X2_H1  ? (1024 / 8) :
                                X2_F1  ? (512  / 8) :
                                X1_H1  ? (1024 / 16) :
                                X1_F1  ? (512  / 16) : (512  / 16);

  // We always pass the upper bits of downstream data directly to TXRX.
  // For transmit, we need to transmit on each replicated struct.
  // So we tie the lower 5 bits to the local_req/ack/prot signals in each replicated struct.
  // The remote side can chose any alignment and get good data
  generate
    if ((AIB_GENERATION == 2) && (LPIF_CLOCK_RATE ==  2000)) // Gen2 F
    begin :gen_block_gen2f
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/1)*0) + REQ_LOC  +:                       1] = in_negotiation ? local_req  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/1)*0) + REQ_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/1)*0) + ACK_LOC  +:                       1] = in_negotiation ? local_ack  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/1)*0) + ACK_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/1)*0) + PROT_LOC +:                       3] = in_negotiation ? local_prot : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/1)*0) + PROT_LOC +:                       3] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/1)*0) + 5        +: ((TXRX_DATA_WIDTH)/1)-5] =                               ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/1)*0) + 5        +: ((TXRX_DATA_WIDTH)/1)-5] ;
    end

    if ((AIB_GENERATION == 2) && (LPIF_CLOCK_RATE ==  1000)) // Gen2 H
    begin :gen_block_gen2h
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*0) + REQ_LOC  +:                       1] = in_negotiation ? local_req  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*0) + REQ_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*0) + ACK_LOC  +:                       1] = in_negotiation ? local_ack  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*0) + ACK_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*0) + PROT_LOC +:                       3] = in_negotiation ? local_prot : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*0) + PROT_LOC +:                       3] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*0) + 5        +: ((TXRX_DATA_WIDTH)/2)-5] =                               ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*0) + 5        +: ((TXRX_DATA_WIDTH)/2)-5] ;

     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*1) + REQ_LOC  +:                       1] = in_negotiation ? local_req  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*1) + REQ_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*1) + ACK_LOC  +:                       1] = in_negotiation ? local_ack  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*1) + ACK_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*1) + PROT_LOC +:                       3] = in_negotiation ? local_prot : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*1) + PROT_LOC +:                       3] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*1) + 5        +: ((TXRX_DATA_WIDTH)/2)-5] =                               ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*1) + 5        +: ((TXRX_DATA_WIDTH)/2)-5] ;
    end

    if ((AIB_GENERATION == 2) && (LPIF_CLOCK_RATE ==  500)) // Gen2 Q
    begin :gen_block_gen2q
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*0) + REQ_LOC  +:                       1] = in_negotiation ? local_req  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*0) + REQ_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*0) + ACK_LOC  +:                       1] = in_negotiation ? local_ack  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*0) + ACK_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*0) + PROT_LOC +:                       3] = in_negotiation ? local_prot : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*0) + PROT_LOC +:                       3] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*0) + 5        +: ((TXRX_DATA_WIDTH)/4)-5] =                               ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*0) + 5        +: ((TXRX_DATA_WIDTH)/4)-5] ;

     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*1) + REQ_LOC  +:                       1] = in_negotiation ? local_req  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*1) + REQ_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*1) + ACK_LOC  +:                       1] = in_negotiation ? local_ack  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*1) + ACK_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*1) + PROT_LOC +:                       3] = in_negotiation ? local_prot : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*1) + PROT_LOC +:                       3] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*1) + 5        +: ((TXRX_DATA_WIDTH)/4)-5] =                               ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*1) + 5        +: ((TXRX_DATA_WIDTH)/4)-5] ;

     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*2) + REQ_LOC  +:                       1] = in_negotiation ? local_req  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*2) + REQ_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*2) + ACK_LOC  +:                       1] = in_negotiation ? local_ack  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*2) + ACK_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*2) + PROT_LOC +:                       3] = in_negotiation ? local_prot : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*2) + PROT_LOC +:                       3] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*2) + 5        +: ((TXRX_DATA_WIDTH)/4)-5] =                               ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*2) + 5        +: ((TXRX_DATA_WIDTH)/4)-5] ;

     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*3) + REQ_LOC  +:                       1] = in_negotiation ? local_req  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*3) + REQ_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*3) + ACK_LOC  +:                       1] = in_negotiation ? local_ack  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*3) + ACK_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*3) + PROT_LOC +:                       3] = in_negotiation ? local_prot : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*3) + PROT_LOC +:                       3] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*3) + 5        +: ((TXRX_DATA_WIDTH)/4)-5] =                               ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/4)*3) + 5        +: ((TXRX_DATA_WIDTH)/4)-5] ;
    end
  
    if ((AIB_GENERATION == 1) && (LPIF_CLOCK_RATE ==  1000)) // Gen1 F
    begin :gen_block_gen1f
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/1)*0) + REQ_LOC  +:                       1] = in_negotiation ? local_req  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/1)*0) + REQ_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/1)*0) + ACK_LOC  +:                       1] = in_negotiation ? local_ack  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/1)*0) + ACK_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/1)*0) + PROT_LOC +:                       3] = in_negotiation ? local_prot : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/1)*0) + PROT_LOC +:                       3] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/1)*0) + 5        +: ((TXRX_DATA_WIDTH)/1)-5] =                               ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/1)*0) + 5        +: ((TXRX_DATA_WIDTH)/1)-5] ;
    end

    if ((AIB_GENERATION == 1) && (LPIF_CLOCK_RATE ==  500)) // Gen1 H
    begin :gen_block_gen1h
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*0) + REQ_LOC  +:                       1] = in_negotiation ? local_req  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*0) + REQ_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*0) + ACK_LOC  +:                       1] = in_negotiation ? local_ack  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*0) + ACK_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*0) + PROT_LOC +:                       3] = in_negotiation ? local_prot : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*0) + PROT_LOC +:                       3] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*0) + 5        +: ((TXRX_DATA_WIDTH)/2)-5] =                               ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*0) + 5        +: ((TXRX_DATA_WIDTH)/2)-5] ;

     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*1) + REQ_LOC  +:                       1] = in_negotiation ? local_req  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*1) + REQ_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*1) + ACK_LOC  +:                       1] = in_negotiation ? local_ack  : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*1) + ACK_LOC  +:                       1] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*1) + PROT_LOC +:                       3] = in_negotiation ? local_prot : ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*1) + PROT_LOC +:                       3] ;
     assign txrx_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*1) + 5        +: ((TXRX_DATA_WIDTH)/2)-5] =                               ctrl_dstrm_data [ (((TXRX_DATA_WIDTH)/2)*1) + 5        +: ((TXRX_DATA_WIDTH)/2)-5] ;
    end
  endgenerate

// State Machine
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// State Machine
  localparam STATE_IDLE   = 3'h0;  // Idle State
  localparam STATE_W4ACK  = 3'h1;  // Waiting for Remote side to acknowledge our REQ and waiting for its REQ.
  localparam STATE_NEG    = 3'h2;  // Perform negotiation
  localparam STATE_W4NACK = 3'h3;  // Waiting for Remote side to acknowledge our !REQ and waiting for its !REQ.
  localparam STATE_NOMAN1 = 3'h4;  // Idle time to ensure remote side sees ACK being low
  localparam STATE_NOMAN2 = 3'h5;  // Idle time to ensure remote side sees ACK being low
  localparam STATE_DONE   = 3'h6;  // Done. Return *stm_data to normal logic flow.

  logic [2:0] state_reg;
  logic [2:0] state_nxt;

  always @(posedge lclk or negedge reset)
  if (~reset)
    state_reg <= STATE_IDLE;
  else
    state_reg <= state_nxt;

  always_comb
    case (state_reg)
        STATE_IDLE   : state_nxt = (ctl_link_up & renegotiate_n) ? STATE_W4ACK  : state_reg;
        STATE_W4ACK  : state_nxt = (( rmote_ack) & ( rmote_req)) ? STATE_NEG    : state_reg;
        STATE_NEG    : state_nxt = STATE_W4NACK;
        STATE_W4NACK : state_nxt = ((!rmote_ack) & (!rmote_req)) ? STATE_NOMAN1 : state_reg;
        STATE_NOMAN1 : state_nxt = STATE_NOMAN2;
        STATE_NOMAN2 : state_nxt = STATE_DONE;
        STATE_DONE   : state_nxt = (!renegotiate_n) ? STATE_IDLE : state_reg;
        default      : state_nxt = (!renegotiate_n) ? STATE_IDLE : state_reg;
    endcase

// State Machine
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Drive signals

  assign local_req           = (state_reg == STATE_W4ACK) | (state_reg == STATE_NEG) ;
  assign local_ack           = ((state_reg == STATE_W4ACK) | (state_reg == STATE_NEG) | (state_reg == STATE_W4NACK) | (state_reg == STATE_NOMAN1) | (state_reg == STATE_NOMAN2)) ? rmote_req : 1'b0;
  assign local_prot          = LPIF_PL_PROTOCOL;

  assign negotiation_link_up = (state_reg == STATE_DONE);

// Drive signals
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Negotiate Results
//
// Host Support                 Encoding   Device Support             Encoding     Negotiated Result            Encoding
// CXL 1.1 - Single                3       CXL 1.1 - Single                3       CXL 1.1 - Single                3
//                                 3       CXL 1.1 - Multi Type 1,2,3      4       CXL 1.1 - Single                3
//                                 3       CXL 2.0 - Multi Type 1,2        5       CXL 1.1 - Single                3
//                                 3       CXL 2.0 - Multi Type 3          6       CXL 1.1 - Single                3
//                                 3       CXL 2.0 - Single                7       CXL 1.1 - Single                3
//                                         
// CXL 1.1 - Multi Type 1,2,3      4       CXL 1.1 - Single                3       CXL 1.1 - Single                3
//                                 4       CXL 1.1 - Multi Type 1,2,3      4       CXL 1.1 - Multi Type 1,2,3      4
//                                 4       CXL 2.0 - Multi Type 1,2        5       CXL 1.1 - Multi Type 1,2,3      4
//                                 4       CXL 2.0 - Multi Type 3          6       CXL 1.1 - Multi Type 1,2,3      4
//                                 4       CXL 2.0 - Single                7       CXL 1.1 - Single                3
//                                         
// CXL 2.0 - Multi Type 1,2        5       CXL 1.1 - Single                3       CXL 1.1 - Single                3
//                                 5       CXL 1.1 - Multi Type 1,2,3      4       CXL 1.1 - Multi Type 1,2,3      4
//                                 5       CXL 2.0 - Multi Type 1,2        5       CXL 2.0 - Multi Type 1,2        5
//                                 5       CXL 2.0 - Multi Type 3          6       CXL 2.0 - Multi Type 3          6
//                                 5       CXL 2.0 - Single                7       CXL 2.0 - Single                7
//                                         
// CXL 2.0 - Multi Type 3          6       CXL 1.1 - Single                3       CXL 1.1 - Single                3
//                                 6       CXL 1.1 - Multi Type 1,2,3      4       CXL 1.1 - Multi Type 1,2,3      4
//                                 6       CXL 2.0 - Multi Type 1,2        5       CXL 2.0 - Multi Type 1,2        5  
//                                 6       CXL 2.0 - Multi Type 3          6       CXL 2.0 - Multi Type 3          6
//                                 6       CXL 2.0 - Single                7       CXL 2.0 - Single                7
//                                         
// CXL 2.0 - Single                7       CXL 1.1 - Single                3       CXL 1.1 - Single                3
//                                 7       CXL 1.1 - Multi Type 1,2,3      4       CXL 1.1 - Single                3
//                                 7       CXL 2.0 - Multi Type 1,2        5       CXL 2.0 - Single                7
//                                 7       CXL 2.0 - Multi Type 3          6       CXL 2.0 - Single                7
//                                 7       CXL 2.0 - Single                7       CXL 2.0 - Single                7
 
  logic [2:0] pl_prot_next;
  logic       pl_prt_vld_next;

  logic [2:0] host_prot;
  logic [2:0] device_prot;
  
  assign host_prot   = LPIF_IS_HOST ? local_prot : rmote_prot ;
  assign device_prot = LPIF_IS_HOST ? rmote_prot : local_prot ;
  
  always_comb
  case ({host_prot , device_prot })
        {     3'h3 ,        3'h3 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h3;  end 
        {     3'h3 ,        3'h4 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h3;  end 
        {     3'h3 ,        3'h5 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h3;  end 
        {     3'h3 ,        3'h6 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h3;  end 
        {     3'h3 ,        3'h7 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h3;  end 

        {     3'h4 ,        3'h3 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h3;  end 
        {     3'h4 ,        3'h4 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h4;  end 
        {     3'h4 ,        3'h5 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h4;  end 
        {     3'h4 ,        3'h6 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h4;  end 
        {     3'h4 ,        3'h7 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h3;  end 

        {     3'h5 ,        3'h3 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h3;  end 
        {     3'h5 ,        3'h4 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h4;  end 
        {     3'h5 ,        3'h5 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h5;  end 
        {     3'h5 ,        3'h6 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h6;  end 
        {     3'h5 ,        3'h7 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h7;  end 

        {     3'h6 ,        3'h3 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h3;  end 
        {     3'h6 ,        3'h4 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h4;  end 
        {     3'h6 ,        3'h5 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h5;  end 
        {     3'h6 ,        3'h6 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h6;  end 
        {     3'h6 ,        3'h7 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h7;  end 

        {     3'h7 ,        3'h3 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h3;  end 
        {     3'h7 ,        3'h4 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h3;  end 
        {     3'h7 ,        3'h5 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h7;  end 
        {     3'h7 ,        3'h6 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h7;  end 
        {     3'h7 ,        3'h7 } : begin  pl_prt_vld_next=1'b1;   pl_prot_next=3'h7;  end 

        default                    : begin  pl_prt_vld_next=1'b0;   pl_prot_next=3'h3;  end
  endcase


  always @(posedge lclk or negedge reset)
  if (~reset)
  begin
    pl_protocol_vld <= 1'h0;
    pl_protocol     <= 3'h0;
  end
  else if (state_reg == STATE_IDLE)
  begin
    pl_protocol_vld <= 1'h0;
    pl_protocol     <= 3'h0;
  end
  else if (state_reg == STATE_NEG)
  begin
    pl_protocol_vld <= pl_prt_vld_next;
    pl_protocol     <= pl_prot_next;
  end

// Drive signals
////////////////////////////////////////////////////////////

////////////////////////////////////////////////////////////
// Related Signals

  always @(posedge lclk or negedge reset)
  if (~reset)
  begin
    pl_inband_pres  <= 1'h0;
    pl_portmode_val <= 1'h0;
    pl_portmode     <= 1'h0;
  end
  else if (~renegotiate_n)
  begin
    pl_inband_pres  <= 1'h0;
    pl_portmode_val <= 1'h0;
    pl_portmode     <= 1'h0;
  end
  else if (ctl_link_up & renegotiate_n)
  begin
    pl_inband_pres  <= 1'h1;
    pl_portmode_val <= 1'h1;
    pl_portmode     <= 1'h1;
  end

// Related Signals
////////////////////////////////////////////////////////////

endmodule



