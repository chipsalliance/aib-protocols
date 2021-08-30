module axi_st_d256_dm_drng_2_up_full_slave_top  (
  input  logic               clk_wr              ,
  input  logic               rst_wr_n            ,

  // Control signals
  input  logic               tx_online           ,
  input  logic               rx_online           ,


  // PHY Interconnect
  output logic [  39:   0]   tx_phy0             ,
  input  logic [  39:   0]   rx_phy0             ,
  output logic [  39:   0]   tx_phy1             ,
  input  logic [  39:   0]   rx_phy1             ,
  output logic [  39:   0]   tx_phy2             ,
  input  logic [  39:   0]   rx_phy2             ,
  output logic [  39:   0]   tx_phy3             ,
  input  logic [  39:   0]   rx_phy3             ,
  output logic [  39:   0]   tx_phy4             ,
  input  logic [  39:   0]   rx_phy4             ,
  output logic [  39:   0]   tx_phy5             ,
  input  logic [  39:   0]   rx_phy5             ,
  output logic [  39:   0]   tx_phy6             ,
  input  logic [  39:   0]   rx_phy6             ,

  // st channel
  output logic [ 255:   0]   user_tdata          ,
  output logic               user_tvalid         ,
  input  logic               user_tready         ,
  output logic [   0:   0]   user_enable         ,

  // Debug Status Outputs
  output logic [31:0]        rx_st_debug_status  ,

  // Configuration
  input  logic               m_gen2_mode         ,

  input  logic [   0:   0]   tx_mrk_userbit      ,
  input  logic               tx_stb_userbit      ,

  input  logic [7:0]         delay_x_value       , // In single channel, no CA, this is Word Alignment Time. In multie-channel, this is 0 and RX_ONLINE tied to channel_alignment_done
  input  logic [7:0]         delay_xz_value      ,
  input  logic [7:0]         delay_yz_value      

);

//////////////////////////////////////////////////////////////////
// Interconnect Wires
  logic                                          rx_st_pushbit                 ;
  logic                                          user_st_valid                 ;
  logic [ 256:   0]                              rx_st_data                    ;
  logic [ 256:   0]                              rxfifo_st_data                ;
  logic                                          tx_st_credit                  ;
  logic                                          user_st_ready                 ;
  logic                                          rx_st_push_ovrd               ;

  logic [   0:   0]                              tx_auto_mrk_userbit           ;
  logic                                          tx_auto_stb_userbit           ;
  logic                                          tx_online_delay               ;
  logic                                          rx_online_delay               ;

// Interconnect Wires
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Auto Sync

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
      .delay_xz_value                   (delay_xz_value[7:0]),
      .delay_yz_value                   (delay_yz_value[7:0]),
      .tx_mrk_userbit                   (tx_mrk_userbit),
      .tx_stb_userbit                   (tx_stb_userbit),
      .rx_online                        (rx_online),
      .delay_x_value                    (delay_x_value[7:0]));

// Auto Sync
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// Logic Link Instantiation

      ll_receive #(.WIDTH(257), .DEPTH(8'd128)) ll_receive_ist
        (// Outputs
         .rxfifo_i_data                    (rxfifo_st_data[256:0]),
         .user_i_valid                     (user_st_valid),
         .tx_i_credit                      (tx_st_credit),
         .rx_i_debug_status                (rx_st_debug_status[31:0]),
         // Inputs
         .clk_wr                           (clk_wr),
         .rst_wr_n                         (rst_wr_n),
         .rx_online                        (rx_online_delay),
         .rx_i_push_ovrd                   (rx_st_push_ovrd),
         .rx_i_data                        (rx_st_data[256:0]),
         .rx_i_pushbit                     (rx_st_pushbit),
         .user_i_ready                     (user_st_ready));

// Logic Link Instantiation
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// User Interface

      axi_st_d256_dm_drng_2_up_full_slave_name axi_st_d256_dm_drng_2_up_full_slave_name
      (
         .user_tdata                       (user_tdata[ 255:   0]),
         .user_tvalid                      (user_tvalid),
         .user_tready                      (user_tready),
         .user_enable                      (user_enable[   0:   0]),

         .user_st_valid                    (user_st_valid),
         .rxfifo_st_data                   (rxfifo_st_data[ 256:   0]),
         .user_st_ready                    (user_st_ready),

         .m_gen2_mode                      (m_gen2_mode)

      );
// User Interface                                                 
//////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////
// PHY Interface

      axi_st_d256_dm_drng_2_up_full_slave_concat axi_st_d256_dm_drng_2_up_full_slave_concat
      (
         .rx_st_data                       (rx_st_data[   0 +: 257]),
         .rx_st_push_ovrd                  (rx_st_push_ovrd),
         .rx_st_pushbit                    (rx_st_pushbit),
         .tx_st_credit                     (tx_st_credit ? 4'h1 : 4'h0),

         .tx_phy0                          (tx_phy0[39:0]),
         .rx_phy0                          (rx_phy0[39:0]),
         .tx_phy1                          (tx_phy1[39:0]),
         .rx_phy1                          (rx_phy1[39:0]),
         .tx_phy2                          (tx_phy2[39:0]),
         .rx_phy2                          (rx_phy2[39:0]),
         .tx_phy3                          (tx_phy3[39:0]),
         .rx_phy3                          (rx_phy3[39:0]),
         .tx_phy4                          (tx_phy4[39:0]),
         .rx_phy4                          (rx_phy4[39:0]),
         .tx_phy5                          (tx_phy5[39:0]),
         .rx_phy5                          (rx_phy5[39:0]),
         .tx_phy6                          (tx_phy6[39:0]),
         .rx_phy6                          (rx_phy6[39:0]),

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
