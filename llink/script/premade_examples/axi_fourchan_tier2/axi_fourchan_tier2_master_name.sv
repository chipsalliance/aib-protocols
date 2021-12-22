////////////////////////////////////////////////////////////
//
//        (C) Copyright 2021 Eximius Design
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
////////////////////////////////////////////////////////////

module axi_fourchan_tier2_master_name  (

  // tx channel
  input  logic [  73:   0]   ch0_tx_data         ,
  input  logic [  73:   0]   ch1_tx_data         ,
  input  logic [  73:   0]   ch2_tx_data         ,
  input  logic [  73:   0]   ch3_tx_data         ,

  // rx channel
  output logic [  73:   0]   ch0_rx_data         ,
  output logic [  73:   0]   ch1_rx_data         ,
  output logic [  73:   0]   ch2_rx_data         ,
  output logic [  73:   0]   ch3_rx_data         ,

  // Logic Link Interfaces
  output logic [ 295:   0]   txfifo_tx_data      ,

  input  logic [ 295:   0]   rxfifo_rx_data      ,

  input  logic               m_gen2_mode         

);

  // Connect Data

  assign user_tx_vld                        = 1'b1                               ; // user_tx_vld is unused
  assign txfifo_tx_data       [   0 +:  74] = ch0_tx_data          [   0 +:  74] ;
  assign txfifo_tx_data       [  74 +:  74] = ch1_tx_data          [   0 +:  74] ;
  assign txfifo_tx_data       [ 148 +:  74] = ch2_tx_data          [   0 +:  74] ;
  assign txfifo_tx_data       [ 222 +:  74] = ch3_tx_data          [   0 +:  74] ;

  // user_rx_vld is unused
  assign ch0_rx_data          [   0 +:  74] = rxfifo_rx_data       [   0 +:  74] ;
  assign ch1_rx_data          [   0 +:  74] = rxfifo_rx_data       [  74 +:  74] ;
  assign ch2_rx_data          [   0 +:  74] = rxfifo_rx_data       [ 148 +:  74] ;
  assign ch3_rx_data          [   0 +:  74] = rxfifo_rx_data       [ 222 +:  74] ;

endmodule
