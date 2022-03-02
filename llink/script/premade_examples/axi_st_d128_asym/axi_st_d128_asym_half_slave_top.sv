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

module axi_st_d128_asym_half_slave_top  (
  input  logic               clk_wr              ,
  input  logic               rst_wr_n            ,

  // Control signals
  input  logic               tx_online           ,
  input  logic               rx_online           ,


  // PHY Interconnect
  output logic [ 159:   0]   tx_phy0             ,
  input  logic [ 159:   0]   rx_phy0             ,
  output logic [ 159:   0]   tx_phy1             ,
  input  logic [ 159:   0]   rx_phy1             ,

  // st channel
  output logic [  31:   0]   user_tkeep          ,
  output logic [ 255:   0]   user_tdata          ,
  output logic [   1:   0]   user_tuser          ,
  output logic               user_tvalid         ,
  input  logic               user_tready         ,
  output logic [   1:   0]   user_enable         ,

  // Debug Status Outputs
  output logic [31:0]        rx_st_debug_status  ,

  // Configuration
  input  logic               m_gen2_mode         ,

  input  logic [   1:   0]   tx_mrk_userbit      ,
  input  logic               tx_stb_userbit      ,

  input  logic [15:0]        delay_x_value       ,
  input  logic [15:0]        delay_y_value       ,
  input  logic [15:0]        delay_z_value       

);

//////////////////////////////////////////////////////////////////
// Interconnect Wires
  logic                                          rx_st_pushbit                 ;
  logic                                          user_st_vld                   ;
  logic [ 291:   0]                              rx_st_data                    ;
  logic [ 291:   0]                              rxfifo_st_data                ;
  logic                                          tx_st_credit                  ;
  logic                                          user_st_ready                 ;
  logic                                          rx_st_push_ovrd               ;

  logic [   1:   0]                              tx_auto_mrk_userbit           ;
  logic                                          tx_auto_stb_userbit           ;
  logic                                          tx_online_delay               ;
  logic                                          rx_online_delay               ;
  logic                                          rx_online_holdoff             ;

// Interconnect Wires
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Auto Sync

  assign rx_online_holdoff                  = 1'b0                               ;

   ll_auto_sync #(.MARKER_WIDTH(2),
                  .PERSISTENT_MARKER(1'b1),
                  .PERSISTENT_STROBE(1'b1)) ll_auto_sync_i
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

      ll_receive #(.WIDTH(292), .DEPTH(8'd32)) ll_receive_ist
        (// Outputs
         .rxfifo_i_data                    (rxfifo_st_data[291:0]),
         .user_i_valid                     (user_st_vld),
         .tx_i_credit                      (tx_st_credit),
         .rx_i_debug_status                (rx_st_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .tx_online                        (tx_online_delay),
         .rx_i_push_ovrd                   (rx_st_push_ovrd),
         .rx_i_data                        (rx_st_data[291:0]),
         .rx_i_pushbit                     (rx_st_pushbit),
         .user_i_ready                     (user_st_ready));

// Logic Link Instantiation
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// User Interface

      axi_st_d128_asym_half_slave_name axi_st_d128_asym_half_slave_name
      (
         .user_tkeep                       (user_tkeep[  31:   0]),
         .user_tdata                       (user_tdata[ 255:   0]),
         .user_tuser                       (user_tuser[   1:   0]),
         .user_tvalid                      (user_tvalid),
         .user_tready                      (user_tready),
         .user_enable                      (user_enable[   1:   0]),

         .user_st_vld                      (user_st_vld),
         .rxfifo_st_data                   (rxfifo_st_data[ 291:   0]),
         .user_st_ready                    (user_st_ready),

         .m_gen2_mode                      (m_gen2_mode)

      );
// User Interface                                                 
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// PHY Interface

      axi_st_d128_asym_half_slave_concat axi_st_d128_asym_half_slave_concat
      (
         .rx_st_data                       (rx_st_data[   0 +: 292]),
         .rx_st_push_ovrd                  (rx_st_push_ovrd),
         .rx_st_pushbit                    (rx_st_pushbit),
         .tx_st_credit                     (tx_st_credit ? 4'h3 : 4'h0),

         .tx_phy0                          (tx_phy0[159:0]),
         .rx_phy0                          (rx_phy0[159:0]),
         .tx_phy1                          (tx_phy1[159:0]),
         .rx_phy1                          (rx_phy1[159:0]),

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
