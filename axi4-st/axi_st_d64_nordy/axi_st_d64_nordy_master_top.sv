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

module axi_st_d64_nordy_master_top  (
  input  logic               clk_wr              ,
  input  logic               rst_wr_n            ,

  // Control signals
  input  logic               tx_online           ,
  input  logic               rx_online           ,

  input  logic [7:0]         init_st_credit      ,

  // PHY Interconnect
  output logic [  79:   0]   tx_phy0             ,
  input  logic [  79:   0]   rx_phy0             ,

  // st channel
  input  logic [   7:   0]   user_tkeep          ,
  input  logic [  63:   0]   user_tdata          ,
  input  logic               user_tlast          ,
  input  logic               user_tvalid         ,

  // Debug Status Outputs
  output logic [31:0]        tx_st_debug_status  ,

  // Configuration
  input  logic               m_gen2_mode         ,

  input  logic [   0:   0]   tx_mrk_userbit      ,
  input  logic               tx_stb_userbit      ,

  input  logic [15:0]        delay_x_value       ,
  input  logic [15:0]        delay_y_value       ,
  input  logic [15:0]        delay_z_value       

);

//////////////////////////////////////////////////////////////////
// Interconnect Wires
  logic [  73:   0]                              tx_st_data                    ;
  logic [  73:   0]                              txfifo_st_data                ;
  logic                                          tx_st_pop_ovrd                ;

  logic [   0:   0]                              tx_auto_mrk_userbit           ;
  logic                                          tx_auto_stb_userbit           ;
  logic                                          tx_online_delay               ;
  logic                                          rx_online_delay               ;
  logic                                          rx_online_holdoff             ;

// Interconnect Wires
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Auto Sync

  assign rx_online_holdoff                  = 1'b0                               ;

   ll_auto_sync #(.MARKER_WIDTH(1),
                  .PERSISTENT_MARKER(1'b0),
                  .PERSISTENT_STROBE(1'b0)) ll_auto_sync_i
     (// Outputs
      .tx_online_delay                  (tx_online_delay),
      .tx_auto_mrk_userbit              (tx_auto_mrk_userbit),
      .tx_auto_stb_userbit              (tx_auto_stb_userbit),
      .rx_online_delay                  (rx_online_delay),
      // Inputs
      .clk_wr                           (clk_wr),
      .rst_wr_n                         (rst_wr_n),
      .tx_online                        (tx_online),
      .delay_z_value                    (delay_z_value[15:0]),
      .delay_y_value                    (delay_y_value[15:0]),
      .tx_mrk_userbit                   (tx_mrk_userbit),
      .tx_stb_userbit                   (tx_stb_userbit),
      .rx_online                        (rx_online),
      .rx_online_holdoff                (rx_online_holdoff),
      .delay_x_value                    (delay_x_value[15:0]));

// Auto Sync
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Logic Link Instantiation

  // No AXI Valid or Ready, so bypassing main Logic Link FIFO and Credit logic.
  assign tx_st_data           [   0 +:  74] = txfifo_st_data       [   0 +:  74] ;
  assign tx_st_debug_status   [   0 +:  32] = {12'h0, tx_online_delay, rx_online_delay, 18'h0} ;               
// Logic Link Instantiation
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// User Interface

      axi_st_d64_nordy_master_name axi_st_d64_nordy_master_name
      (
         .user_tkeep                       (user_tkeep[   7:   0]),
         .user_tdata                       (user_tdata[  63:   0]),
         .user_tlast                       (user_tlast),
         .user_tvalid                      (user_tvalid),

         .txfifo_st_data                   (txfifo_st_data[  73:   0]),

         .rx_online                        (rx_online_delay),
         .m_gen2_mode                      (m_gen2_mode)

      );
// User Interface                                                 
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// PHY Interface

      axi_st_d64_nordy_master_concat axi_st_d64_nordy_master_concat
      (
         .tx_st_data                       (tx_st_data[   0 +:  74]),
         .tx_st_pop_ovrd                   (tx_st_pop_ovrd),

         .tx_phy0                          (tx_phy0[79:0]),
         .rx_phy0                          (rx_phy0[79:0]),

         .clk_wr                           (clk_wr),
         .clk_rd                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rst_rd_n                         (rst_wr_n),

         .m_gen2_mode                      (m_gen2_mode),
         .tx_online                        (tx_online_delay),

         .tx_stb_userbit                   (tx_auto_stb_userbit),
         .tx_mrk_userbit                   (tx_auto_mrk_userbit)

      );

// PHY Interface
//////////////////////////////////////////////////////////////////


endmodule
