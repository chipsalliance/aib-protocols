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
////////////////////////////////////////////////////////////
module marker_gen (

  input logic clk,
  input logic rst_n,

  input logic  [3:0] local_rate,
  input logic  [3:0] remote_rate,

  output logic [3:0] user_marker

);

// Note, we'll drive all 4 bits of marker, but if local is Full or Half,
// we'll only use bit 0 or bits 1:0, respectively.

logic [1:0] state_reg;

always @(posedge clk or negedge rst_n)
if (!rst_n)
  state_reg <= 2'h0;
else
  state_reg <= state_reg + 2'h1;


parameter FULL          = 4'h1;
parameter HALF          = 4'h2;
parameter QUARTER       = 4'h4;

always @(posedge clk or negedge rst_n)
if (!rst_n)
begin
  user_marker <= 4'h0;
end
else
begin
  case ({local_rate, remote_rate, state_reg})
      {FULL    , FULL    , 2'h0} : user_marker <= 4'b1    ;
      {FULL    , FULL    , 2'h1} : user_marker <= 4'b1    ;
      {FULL    , FULL    , 2'h2} : user_marker <= 4'b1    ;
      {FULL    , FULL    , 2'h3} : user_marker <= 4'b1    ;

      {FULL    , HALF    , 2'h0} : user_marker <= 4'b0    ;
      {FULL    , HALF    , 2'h1} : user_marker <= 4'b1    ;
      {FULL    , HALF    , 2'h2} : user_marker <= 4'b0    ;
      {FULL    , HALF    , 2'h3} : user_marker <= 4'b1    ;

      {FULL    , QUARTER , 2'h0} : user_marker <= 4'b0    ;
      {FULL    , QUARTER , 2'h1} : user_marker <= 4'b0    ;
      {FULL    , QUARTER , 2'h2} : user_marker <= 4'b0    ;
      {FULL    , QUARTER , 2'h3} : user_marker <= 4'b1    ;


      {HALF    , FULL    , 2'h0} : user_marker <= 4'b11   ;
      {HALF    , FULL    , 2'h1} : user_marker <= 4'b11   ;
      {HALF    , FULL    , 2'h2} : user_marker <= 4'b11   ;
      {HALF    , FULL    , 2'h3} : user_marker <= 4'b11   ;

      {HALF    , HALF    , 2'h0} : user_marker <= 4'b10   ;
      {HALF    , HALF    , 2'h1} : user_marker <= 4'b10   ;
      {HALF    , HALF    , 2'h2} : user_marker <= 4'b10   ;
      {HALF    , HALF    , 2'h3} : user_marker <= 4'b10   ;

      {HALF    , QUARTER , 2'h0} : user_marker <= 4'b00   ;
      {HALF    , QUARTER , 2'h1} : user_marker <= 4'b10   ;
      {HALF    , QUARTER , 2'h2} : user_marker <= 4'b00   ;
      {HALF    , QUARTER , 2'h3} : user_marker <= 4'b10   ;


      {QUARTER , FULL    , 2'h0} : user_marker <= 4'b1111 ;
      {QUARTER , FULL    , 2'h1} : user_marker <= 4'b1111 ;
      {QUARTER , FULL    , 2'h2} : user_marker <= 4'b1111 ;
      {QUARTER , FULL    , 2'h3} : user_marker <= 4'b1111 ;

      {QUARTER , HALF    , 2'h0} : user_marker <= 4'b1010 ;
      {QUARTER , HALF    , 2'h1} : user_marker <= 4'b1010 ;
      {QUARTER , HALF    , 2'h2} : user_marker <= 4'b1010 ;
      {QUARTER , HALF    , 2'h3} : user_marker <= 4'b1010 ;

      {QUARTER , QUARTER , 2'h0} : user_marker <= 4'b1000 ;
      {QUARTER , QUARTER , 2'h1} : user_marker <= 4'b1000 ;
      {QUARTER , QUARTER , 2'h2} : user_marker <= 4'b1000 ;
      {QUARTER , QUARTER , 2'h3} : user_marker <= 4'b1000 ;

      default                    : user_marker <= 4'b0000 ;
  endcase
end


endmodule
