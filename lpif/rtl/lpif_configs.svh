////////////////////////////////////////////////////////////////////////////////////////////////////
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
// Functional Descript: LPIF Configuration parameters
//
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////

localparam X16_Q2 = ((LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH == 128) && (AIB_VERSION == 2) &&  (AIB_GENERATION == 2) && (AIB_LANES ==  4) && (AIB_BITS_PER_LANE == 320));
localparam X16_H2 = ((LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  64) && (AIB_VERSION == 2) &&  (AIB_GENERATION == 2) && (AIB_LANES ==  4) && (AIB_BITS_PER_LANE == 160));
localparam X16_F2 = ((LPIF_CLOCK_RATE == 2000) && (LPIF_DATA_WIDTH ==  32) && (AIB_VERSION == 2) &&  (AIB_GENERATION == 2) && (AIB_LANES ==  4) && (AIB_BITS_PER_LANE ==  80));

localparam X8_Q2 =  ((LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH == 128) && (AIB_VERSION == 2) &&  (AIB_GENERATION == 2) && (AIB_LANES ==  2) && (AIB_BITS_PER_LANE == 320));
localparam X8_H2 =  ((LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  64) && (AIB_VERSION == 2) &&  (AIB_GENERATION == 2) && (AIB_LANES ==  2) && (AIB_BITS_PER_LANE == 160));
localparam X8_F2 =  ((LPIF_CLOCK_RATE == 2000) && (LPIF_DATA_WIDTH ==  32) && (AIB_VERSION == 2) &&  (AIB_GENERATION == 2) && (AIB_LANES ==  2) && (AIB_BITS_PER_LANE ==  80));

localparam X4_Q2 =  ((LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH == 128) && (AIB_VERSION == 2) &&  (AIB_GENERATION == 2) && (AIB_LANES ==  1) && (AIB_BITS_PER_LANE == 320));
localparam X4_H2 =  ((LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  64) && (AIB_VERSION == 2) &&  (AIB_GENERATION == 2) && (AIB_LANES ==  1) && (AIB_BITS_PER_LANE == 160));
localparam X4_F2 =  ((LPIF_CLOCK_RATE == 2000) && (LPIF_DATA_WIDTH ==  32) && (AIB_VERSION == 2) &&  (AIB_GENERATION == 2) && (AIB_LANES ==  1) && (AIB_BITS_PER_LANE ==  80));

localparam X16_H1 = ((LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH == 128) && (((AIB_VERSION == 2) && (AIB_GENERATION == 1)) || (AIB_VERSION == 1)) && (AIB_LANES == 16) && (AIB_BITS_PER_LANE == 80));
localparam X16_F1 = ((LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  64) && (((AIB_VERSION == 2) && (AIB_GENERATION == 1)) || (AIB_VERSION == 1)) && (AIB_LANES == 16) && (AIB_BITS_PER_LANE == 40));

localparam X8_H1 =  ((LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH == 128) && (((AIB_VERSION == 2) && (AIB_GENERATION == 1)) || (AIB_VERSION == 1)) && (AIB_LANES ==  8) && (AIB_BITS_PER_LANE == 80));
localparam X8_F1 =  ((LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  64) && (((AIB_VERSION == 2) && (AIB_GENERATION == 1)) || (AIB_VERSION == 1)) && (AIB_LANES ==  8) && (AIB_BITS_PER_LANE == 40));

localparam X4_H1 =  ((LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH == 128) && (((AIB_VERSION == 2) && (AIB_GENERATION == 1)) || (AIB_VERSION == 1)) && (AIB_LANES ==  4) && (AIB_BITS_PER_LANE == 80));
localparam X4_F1 =  ((LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  64) && (((AIB_VERSION == 2) && (AIB_GENERATION == 1)) || (AIB_VERSION == 1)) && (AIB_LANES ==  4) && (AIB_BITS_PER_LANE == 40));

localparam X2_H1 =  ((LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH == 128) && (((AIB_VERSION == 2) && (AIB_GENERATION == 1)) || (AIB_VERSION == 1)) && (AIB_LANES ==  2) && (AIB_BITS_PER_LANE == 80));
localparam X2_F1 =  ((LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  64) && (((AIB_VERSION == 2) && (AIB_GENERATION == 1)) || (AIB_VERSION == 1)) && (AIB_LANES ==  2) && (AIB_BITS_PER_LANE == 40));

// X1_H1 and X1_F1 are deprecated
/* -----\/----- EXCLUDED -----\/-----
localparam X1_H1 =  ((LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH == 128) && (((AIB_VERSION == 2) && (AIB_GENERATION == 1)) || (AIB_VERSION == 1)) && (AIB_LANES ==  2) && (AIB_BITS_PER_LANE == 80));
localparam X1_F1 =  ((LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  64) && (((AIB_VERSION == 2) && (AIB_GENERATION == 1)) || (AIB_VERSION == 1)) && (AIB_LANES ==  2) && (AIB_BITS_PER_LANE == 40));
 -----/\----- EXCLUDED -----/\----- */
localparam X1_H1 =  0;
localparam X1_F1 =  0;


localparam G2X16 = X16_Q2 | X16_H2 | X16_F2 ;
localparam G2X8  = X8_Q2  | X8_H2  | X8_F2  ;
localparam G2X4  = X4_Q2  | X4_H2  | X4_F2  ;

localparam G1X16 = X16_F1 | X16_H1 ;
localparam G1X8  = X8_F1  | X8_H1  ;
localparam G1X4  = X4_F1  | X4_H1  ;
localparam G1X2  = X2_F1  | X2_H1  ;

localparam G2F = X16_F2 | X8_F2 | X4_F2 ;
localparam G2H = X16_H2 | X8_H2 | X4_H2 ;
localparam G2Q = X16_Q2 | X8_Q2 | X4_Q2 ;

localparam G1F = X16_F1 | X8_F1 | X4_F1 | X2_F1 ;
localparam G1H = X16_H1 | X8_H1 | X4_H1 | X2_H1 ;




wire        x16_q2 = X16_Q2;
wire        x16_h2 = X16_H2;
wire        x16_f2 = X16_F2;

wire        x8_q2  = X8_Q2;
wire        x8_h2  = X8_H2;
wire        x8_f2  = X8_F2;

wire        x4_q2  = X4_Q2;
wire        x4_h2  = X4_H2;
wire        x4_f2  = X4_F2;

wire        x16_h1 = X16_H1;
wire        x16_f1 = X16_F1;

wire        x8_h1  = X8_H1;
wire        x8_f1  = X8_F1;

wire        x4_h1  = X4_H1;
wire        x4_f1  = X4_F1;

wire        x2_h1  = X2_H1;
wire        x2_f1  = X2_F1;

wire        x1_h1  = X1_H1;
wire        x1_f1  = X1_F1;

wire [15:0] lpif_clock_rate = LPIF_CLOCK_RATE;
wire [15:0] lpif_data_width = LPIF_DATA_WIDTH;
wire [15:0] aib_version = AIB_VERSION;
wire [15:0] aib_generation = AIB_GENERATION;
wire [15:0] aib_lanes = AIB_LANES;
wire [15:0] aib_bits_per_lane = AIB_BITS_PER_LANE;

wire [7:0]  mem_cache_stream_id = MEM_CACHE_STREAM_ID;
wire [7:0]  io_stream_id = IO_STREAM_ID;
wire [7:0]  arb_mux_stream_id = ARB_MUX_STREAM_ID;
