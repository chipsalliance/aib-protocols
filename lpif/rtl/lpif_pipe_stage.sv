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
// Functional Descript: Single Pipeline Buffer
//
//
//
////////////////////////////////////////////////////////////

module lpif_pipe_stage
   (/*AUTOARG*/
   //Outputs
   empty, rddata,
   //Inputs
   lclk, pop, reset, wrdata, push
   );

////////////////////////////////////////////////////////////
//  User modifiable parts
parameter DATA_WIDTH = 32;
parameter RESET_VECTOR = {DATA_WIDTH{1'b0}};
//  User modifiable parts
////////////////////////////////////////////////////////////

input                           lclk;
input                           reset;

input                           push;           // Push data from previous stage
input [DATA_WIDTH-1:0]          wrdata;         // Data from previous stage
input                           pop;            // Pop data to next stage
output [DATA_WIDTH-1:0]         rddata;         // Data to next stage

output                          empty;          // empty signal

////////////////////////////////////////////////////////////
//empty status
reg empty_reg;

always_ff @(posedge lclk or negedge reset)
if (~reset)
  empty_reg <= 1'b1 ;
else if (pop & push)  // Push/Pop at same time. Keep current state.
  empty_reg <= empty_reg ;
else if (pop       )  // Read out data, so we are empty.
  empty_reg <= 1'b1 ;
else if (      push)  // Push in data, so we are not empty
  empty_reg <= 1'b0 ;

assign empty = empty_reg;

// empty status
////////////////////////////////////////////////////////////

  reg [DATA_WIDTH-1:0] memory;

  always_ff @(posedge lclk or negedge reset)
  if (!reset)
      memory <= RESET_VECTOR;
  else if (push)
    memory <= wrdata;

  assign rddata = memory;


endmodule // lpif_pipe_stage //

////////////////////////////////////////////////////////////
//Module:	lpif_pipe_stage
//$Id$
////////////////////////////////////////////////////////////

