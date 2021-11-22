////////////////////////////////////////////////////////////////////////////////////////////////////
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
// Functional Descript: LPIF Configuration parameters
//
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////

localparam X16_Q2 = ((LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH == 128) && (AIB_VERSION == 2) && (AIB_GENERATION == 2) && (AIB_LANES ==  4));
localparam X16_H2 = ((LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  64) && (AIB_VERSION == 2) && (AIB_GENERATION == 2) && (AIB_LANES ==  4));
localparam X16_F2 = ((LPIF_CLOCK_RATE == 2000) && (LPIF_DATA_WIDTH ==  32) && (AIB_VERSION == 2) && (AIB_GENERATION == 2) && (AIB_LANES ==  4));

localparam X8_Q2 =  ((LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH == 128) && (AIB_VERSION == 2) && (AIB_GENERATION == 2) && (AIB_LANES ==  2));
localparam X8_H2 =  ((LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  64) && (AIB_VERSION == 2) && (AIB_GENERATION == 2) && (AIB_LANES ==  2));
localparam X8_F2 =  ((LPIF_CLOCK_RATE == 2000) && (LPIF_DATA_WIDTH ==  32) && (AIB_VERSION == 2) && (AIB_GENERATION == 2) && (AIB_LANES ==  2));

localparam X4_Q2 =  ((LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH == 128) && (AIB_VERSION == 2) && (AIB_GENERATION == 2) && (AIB_LANES ==  1));
localparam X4_H2 =  ((LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  64) && (AIB_VERSION == 2) && (AIB_GENERATION == 2) && (AIB_LANES ==  1));
localparam X4_F2 =  ((LPIF_CLOCK_RATE == 2000) && (LPIF_DATA_WIDTH ==  32) && (AIB_VERSION == 2) && (AIB_GENERATION == 2) && (AIB_LANES ==  1));

localparam X16_H1 = ((LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH == 128) && (AIB_VERSION == 2) && (AIB_GENERATION == 1) && (AIB_LANES == 16));
localparam X16_F1 = ((LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  64) && (AIB_VERSION == 2) && (AIB_GENERATION == 1) && (AIB_LANES == 16));

localparam X8_H1 =  ((LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH == 128) && (AIB_VERSION == 2) && (AIB_GENERATION == 1) && (AIB_LANES ==  8));
localparam X8_F1 =  ((LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  64) && (AIB_VERSION == 2) && (AIB_GENERATION == 1) && (AIB_LANES ==  8));

localparam X4_H1 =  ((LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH == 128) && (AIB_VERSION == 2) && (AIB_GENERATION == 1) && (AIB_LANES ==  4));
localparam X4_F1 =  ((LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  64) && (AIB_VERSION == 2) && (AIB_GENERATION == 1) && (AIB_LANES ==  4));

localparam X2_H1 =  ((LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH == 128) && (AIB_VERSION == 2) && (AIB_GENERATION == 1) && (AIB_LANES ==  2));
localparam X2_F1 =  ((LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  64) && (AIB_VERSION == 2) && (AIB_GENERATION == 1) && (AIB_LANES ==  2));

localparam X1_H1 =  ((LPIF_CLOCK_RATE ==  500) && (LPIF_DATA_WIDTH == 128) && (AIB_VERSION == 2) && (AIB_GENERATION == 1) && (AIB_LANES ==  1));
localparam X1_F1 =  ((LPIF_CLOCK_RATE == 1000) && (LPIF_DATA_WIDTH ==  64) && (AIB_VERSION == 2) && (AIB_GENERATION == 1) && (AIB_LANES ==  1));
