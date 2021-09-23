`ifndef _CA_TOP_TB_
`define _CA_TOP_TB_

//.........TIMESCALE.............
`timescale 1ps/1ps

//.........CONFIG.............
`include "ca_GENERATED_defines.svh"

////////////////////////////////////////////////////////////
module ca_top_tb;

    import uvm_pkg::*;
    import ca_pkg::*;
    //import aximm_aib_mon_pkg::*;

    //-----------------------------------
    parameter AVMM_CYCLE = 4000;
    parameter OSC_CYCLE  = 1000;
    //parameter FWD_CYCLE  = 2000;
    //parameter WR_CYCLE   = 2000;
    //parameter RD_CYCLE   = 2000;
    parameter FWD_CYCLE  = `TB_DIE_A_CLK; //PN_REVIEW
    parameter WR_CYCLE   = `TB_DIE_A_CLK;
    parameter RD_CYCLE   = `TB_DIE_A_CLK;

`ifdef MS_AIB_GEN1
    parameter M_PAD_NUM  = 96;
`else
    parameter M_PAD_NUM  = 102;
`endif
`ifdef SL_AIB_GEN1
    parameter S_PAD_NUM  = 96;
`else
    parameter S_PAD_NUM  = 102;
`endif

    // used to communicate w/ AIB network
    logic [(`TB_DIE_A_BUS_BIT_WIDTH*`MAX_NUM_CHANNELS)-1:0] die_a_tx_dout; 
    logic [(`TB_DIE_B_BUS_BIT_WIDTH*`MAX_NUM_CHANNELS)-1:0] die_b_tx_dout; 
    //
    logic [(`TB_DIE_A_BUS_BIT_WIDTH*`MAX_NUM_CHANNELS)-1:0] die_a_rx_din; 
    logic [(`TB_DIE_B_BUS_BIT_WIDTH*`MAX_NUM_CHANNELS)-1:0] die_b_rx_din; 

    logic [(`TB_DIE_A_BUS_BIT_WIDTH*`MAX_NUM_CHANNELS)-1:0] delay_rxdin_die_a;
    logic [(`TB_DIE_B_BUS_BIT_WIDTH*`MAX_NUM_CHANNELS)-1:0] delay_rxdin_die_b;

    logic [(`TB_DIE_A_BUS_BIT_WIDTH*`MAX_NUM_CHANNELS)-1:0] die_a_dout_delay; 
    logic [(`TB_DIE_B_BUS_BIT_WIDTH*`MAX_NUM_CHANNELS)-1:0] die_b_dout_delay; 

    //-----------------------------------
    `include "top_tb_declare.inc"  //AIB related
    //-----------------------------------
    reg    [`MAX_NUM_CHANNELS-1:0]   clk_lane_a;
    reg    [`MAX_NUM_CHANNELS-1:0]   clk_lane_b;

    reg    clk_die_a                 = 1'b0;
    reg    clk_die_b                 = 1'b0;

    // AIB clks
    reg    avmm_clk = 1'b0;
    reg    osc_clk  = 1'b0;
    reg    fwd_clk  = 1'b0;
    reg    rd_clk   = 1'b0;
    reg    wr_clk   = 1'b0;

    // wires
    //--------------------------------------------------------------
    wire   tb_reset_l;

    wire   die_a_align_done;
    wire   die_b_align_done;

`ifdef P2P_LITE
    logic [23:0]        master_sl_tx_transfer_en;     
    logic [23:0]        master_ms_tx_transfer_en;     
    logic [23:0]        slave_ms_tx_transfer_en;      
    logic [23:0]        slave_sl_tx_transfer_en;      
    logic               master_align_err;             
    logic               master_tx_stb_pos_coding_err; 
    logic               master_tx_stb_pos_err;        
    logic               master_rx_stb_pos_coding_err; 
    logic               master_rx_stb_pos_err;        

    parameter FULL                   = 4'h1;
    parameter HALF                   = 4'h2;
    parameter QUARTER                = 4'h4;

      localparam MASTER_RATE           =  FULL;
      localparam SLAVE_RATE            =  FULL;
    //localparam MASTER_RATE           =  HALF;
    //localparam SLAVE_RATE            =  HALF;
    //localparam MASTER_RATE           =  QUARTER;
    //localparam SLAVE_RATE            =  QUARTER;

    localparam CHAN_0_M2S_LATENCY    = 8'd2; // This number equates to how many s_wr_clk cycles it takes to go from the data (MAC) input of one PHY to the data (MAC) output of the other PHY.
    localparam CHAN_1_M2S_LATENCY    = 8'd1; // This number equates to how many s_wr_clk cycles it takes to go from the data (MAC) input of one PHY to the data (MAC) output of the other PHY.
    localparam CHAN_0_S2M_LATENCY    = 8'd7; // This number equates to how many m_wr_clk cycles it takes to go from the data (MAC) input of one PHY to the data (MAC) output of the other PHY.
    localparam CHAN_1_S2M_LATENCY    = 8'd5; // This number equates to how many m_wr_clk cycles it takes to go from the data (MAC) input of one PHY to the data (MAC) output of the other PHY.

     // This determines how long it takes for Word Markers to Align int he RX
    localparam CHAN_0_M2S_DLL_TIME   = 8'd5;
    localparam CHAN_1_M2S_DLL_TIME   = 8'd5;
    localparam CHAN_0_S2M_DLL_TIME   = 8'd5;
    localparam CHAN_1_S2M_DLL_TIME   = 8'd5;

    localparam DELAY_X_VALUE         = 8'd10; // Should be greater than DLL_TIME. Indicates when RX CA is ready for Strobe
    localparam DELAY_XZ_VALUE        = 8'd14; // Should be greater than DELAY_X_VALUE. Indicates when TX CA should send 1shot strobe
    localparam DELAY_Z_VALUE         = 8'd4;  // Should be greater than DELAY_X_VALUE. Indicates when TX LLINK to stop user strobe
    localparam DELAY_YZ_VALUE        = 8'd30; // Should be greater than DELAY_XZ_VALUE. Indicates when TX LLINK can use reuse strobes and send data.

    localparam CHAN_M2S_MARKER_LOC   = 8'd39;
    localparam CHAN_S2M_MARKER_LOC   = 8'd39;
`endif

`ifdef P2P_LITE
    logic  tb_do_aib_reset = 0;
    logic  tb_do_aib_prog  = 0;
`else
    logic  tb_do_aib_reset = 1;
    logic  tb_do_aib_prog  = 1;
`endif
    logic               aib_ready    = 0;


   //// RESET
    assign tb_reset_l = reset_if_0.reset_l;


/////////// AIB related //////////////
    // Avalon MM Interface instantiation
    //-----------------------------------------------------------------------------------------
    avalon_mm_if avmm_if_m1  (
     .clk    (avmm_clk)
    );

    avalon_mm_if avmm_if_s1  (
     .clk    (avmm_clk)
    );

    // Mac Interface instantiation
    //-----------------------------------------------------------------------------------------
    dut_if_mac #(.DWIDTH (`MIN_BUS_BIT_WIDTH), .TOTAL_CHNL_NUM(`MAX_NUM_CHANNELS)) 
        intf_m1 (.wr_clk(wr_clk), .rd_clk(rd_clk), .fwd_clk(fwd_clk), .osc_clk(osc_clk));

    dut_if_mac #(.DWIDTH (`MIN_BUS_BIT_WIDTH), .TOTAL_CHNL_NUM(`MAX_NUM_CHANNELS)) 
        intf_s1 (.wr_clk(wr_clk), .rd_clk(rd_clk), .fwd_clk(fwd_clk), .osc_clk(osc_clk));

    // Mac Interface instantiation
    //-----------------------------------------------------------------------------------------
    aib_model_top  #(.DATAWIDTH(`MIN_BUS_BIT_WIDTH)) dut_master1 (
        `include "dut_ms1_port.inc"
    );
    aib_model_top #(.DATAWIDTH(`MIN_BUS_BIT_WIDTH)) dut_slave1 (
        `include "dut_sl1_port.inc"
    );

`ifdef MS_AIB_GEN1
    emib_m1s2 dut_emib (
        `include "dut_emib.inc"
       );
`elsif SL_AIB_GEN1
    emib_m2s1 dut_emib (
        `include "dut_emib.inc"
       );
`else
    emib_m2s2 dut_emib (
        `include "dut_emib.inc"
       );
`endif
/////////// AIB related //////////////


    //--------------------------------------------------------------
    // Channel Alignment DIE A : DUT instance
    //--------------------------------------------------------------
    ca #(.NUM_CHANNELS      (`TB_DIE_A_NUM_CHANNELS),
         .BITS_PER_CHANNEL  (`TB_DIE_A_BUS_BIT_WIDTH),
         .AD_WIDTH          (`TB_DIE_A_AD_WIDTH),
         .SYNC_FIFO         (`SYNC_FIFO)
        ) ca_die_a (
             .lane_clk               (clk_lane_a[`TB_DIE_A_NUM_CHANNELS-1:0]),
             .com_clk                (clk_die_a),
             .rst_n                  (tb_reset_l),
             .tx_online              (ca_die_a_tx_tb_out_if.tx_online),
             .rx_online              (ca_die_a_rx_tb_in_if.rx_online),
             .tx_stb_en              (ca_die_a_tx_tb_out_if.tx_stb_en),
             .tx_stb_rcvr            (ca_die_a_tx_tb_out_if.tx_stb_rcvr),
             .align_fly              (ca_die_a_rx_tb_in_if.align_fly),
             .rden_dly               (ca_die_a_rx_tb_in_if.rden_dly),
             .count_x                (8'h2), // FIXME
             .count_xz               (8'h2), // FIXME
             .tx_stb_wd_sel          (ca_die_a_tx_tb_out_if.tx_stb_wd_sel),
             .tx_stb_bit_sel         (ca_die_a_tx_tb_out_if.tx_stb_bit_sel),
             .tx_stb_intv            (ca_die_a_tx_tb_out_if.tx_stb_intv),
             .rx_stb_wd_sel          (ca_die_a_rx_tb_in_if.rx_stb_wd_sel),
             .rx_stb_bit_sel         (ca_die_a_rx_tb_in_if.rx_stb_bit_sel),
             .rx_stb_intv            (ca_die_a_rx_tb_in_if.rx_stb_intv),
             .tx_din                 (ca_die_a_tx_tb_out_if.tx_din),
             .tx_dout                (die_a_tx_dout[(`TB_DIE_A_BUS_BIT_WIDTH*`TB_DIE_A_NUM_CHANNELS)-1:0]),
          `ifdef CHAN_DELAY_ENB
             .rx_din                 (die_b_dout_delay[(`TB_DIE_A_BUS_BIT_WIDTH*`TB_DIE_A_NUM_CHANNELS)-1:0]),
          `else 
             .rx_din                 (die_a_rx_din[(`TB_DIE_A_BUS_BIT_WIDTH*`TB_DIE_A_NUM_CHANNELS)-1:0]),
          `endif
             .rx_dout                (ca_die_a_rx_tb_in_if.rx_dout),
             .align_done             (die_a_align_done),
             .align_err              (ca_die_a_rx_tb_in_if.align_err),
             .tx_stb_pos_err         (ca_die_a_tx_tb_in_if.tx_stb_pos_err),
             .tx_stb_pos_coding_err  (ca_die_a_tx_tb_in_if.tx_stb_pos_coding_err),
             .rx_stb_pos_err         (ca_die_a_rx_tb_in_if.rx_stb_pos_err),
             .rx_stb_pos_coding_err  (ca_die_a_rx_tb_in_if.rx_stb_pos_coding_err),
             .fifo_full_val          (ca_die_a_rx_tb_in_if.fifo_full_val),
             .fifo_pfull_val         (ca_die_a_rx_tb_in_if.fifo_pfull_val),
             .fifo_empty_val         (ca_die_a_rx_tb_in_if.fifo_empty_val),
             .fifo_pempty_val        (ca_die_a_rx_tb_in_if.fifo_pempty_val),
             .fifo_full              (ca_die_a_rx_tb_in_if.fifo_full),
             .fifo_pfull             (ca_die_a_rx_tb_in_if.fifo_pfull),
             .fifo_empty             (ca_die_a_rx_tb_in_if.fifo_empty),
             .fifo_pempty            (ca_die_a_rx_tb_in_if.fifo_pempty)
         );
    
    //--------------------------------------------------------------
    // Channel Alignment DIE B : DUT instance
    //--------------------------------------------------------------
    ca #(.NUM_CHANNELS      (`TB_DIE_B_NUM_CHANNELS),
         .BITS_PER_CHANNEL  (`TB_DIE_B_BUS_BIT_WIDTH),
         .AD_WIDTH          (`TB_DIE_B_AD_WIDTH),
         .SYNC_FIFO         (`SYNC_FIFO)
        ) ca_die_b (
             .lane_clk               (clk_lane_b[`TB_DIE_B_NUM_CHANNELS-1:0]),
             .com_clk                (clk_die_b),
             .rst_n                  (tb_reset_l),
             .tx_online              (ca_die_b_tx_tb_out_if.tx_online),
             .rx_online              (ca_die_b_rx_tb_in_if.rx_online),
             .tx_stb_en              (ca_die_b_tx_tb_out_if.tx_stb_en),
             .tx_stb_rcvr            (ca_die_b_tx_tb_out_if.tx_stb_rcvr),
             .align_fly              (ca_die_b_rx_tb_in_if.align_fly),
             .rden_dly               (ca_die_b_rx_tb_in_if.rden_dly),
             .count_x                (8'd2), // FIXME
             .count_xz               (8'd2), // FIXME
             .tx_stb_wd_sel          (ca_die_b_tx_tb_out_if.tx_stb_wd_sel),
             .tx_stb_bit_sel         (ca_die_b_tx_tb_out_if.tx_stb_bit_sel),
             .tx_stb_intv            (ca_die_b_tx_tb_out_if.tx_stb_intv),
             .rx_stb_wd_sel          (ca_die_b_rx_tb_in_if.rx_stb_wd_sel),
             .rx_stb_bit_sel         (ca_die_b_rx_tb_in_if.rx_stb_bit_sel),
             .rx_stb_intv            (ca_die_b_rx_tb_in_if.rx_stb_intv),
             .tx_din                 (ca_die_b_tx_tb_out_if.tx_din),
             .tx_dout                (die_b_tx_dout[(`TB_DIE_B_BUS_BIT_WIDTH*`TB_DIE_B_NUM_CHANNELS)-1:0]),
          `ifdef CHAN_DELAY_ENB
             .rx_din                 (die_a_dout_delay[(`TB_DIE_B_BUS_BIT_WIDTH*`TB_DIE_B_NUM_CHANNELS)-1:0]),
          `else 
             .rx_din                 (die_b_rx_din[(`TB_DIE_B_BUS_BIT_WIDTH*`TB_DIE_B_NUM_CHANNELS)-1:0]),
          `endif
             .rx_dout                (ca_die_b_rx_tb_in_if.rx_dout),
             .align_done             (die_b_align_done),
             .align_err              (ca_die_b_rx_tb_in_if.align_err),
             .tx_stb_pos_err         (ca_die_b_tx_tb_in_if.tx_stb_pos_err),
             .tx_stb_pos_coding_err  (ca_die_b_tx_tb_in_if.tx_stb_pos_coding_err),
             .rx_stb_pos_err         (ca_die_b_rx_tb_in_if.rx_stb_pos_err),
             .rx_stb_pos_coding_err  (ca_die_b_rx_tb_in_if.rx_stb_pos_coding_err),
             .fifo_full_val          (ca_die_b_rx_tb_in_if.fifo_full_val),
             .fifo_pfull_val         (ca_die_b_rx_tb_in_if.fifo_pfull_val),
             .fifo_empty_val         (ca_die_b_rx_tb_in_if.fifo_empty_val),
             .fifo_pempty_val        (ca_die_b_rx_tb_in_if.fifo_pempty_val),
             .fifo_full              (ca_die_b_rx_tb_in_if.fifo_full),
             .fifo_pfull             (ca_die_b_rx_tb_in_if.fifo_pfull),
             .fifo_empty             (ca_die_b_rx_tb_in_if.fifo_empty),
             .fifo_pempty            (ca_die_b_rx_tb_in_if.fifo_pempty)
         );

`ifdef P2P_LITE
genvar i;
generate 
 for(i=0;i<`MAX_NUM_CHANNELS;i+=1) begin : p2p_inst
    p2p_lite p2p_i(
       .master_sl_tx_transfer_en     (master_sl_tx_transfer_en[i]),
       .master_ms_tx_transfer_en     (master_ms_tx_transfer_en[i]),
       .slave_sl_tx_transfer_en      (slave_sl_tx_transfer_en[i]) , 
       .slave_ms_tx_transfer_en      (slave_ms_tx_transfer_en[i]) , 
       .s2m_data_out                 (die_a_rx_din[((i+1)*`TB_DIE_A_BUS_BIT_WIDTH-1):(i*`TB_DIE_A_BUS_BIT_WIDTH)]),
       .m2s_data_out                 (die_b_rx_din[((i+1)*`TB_DIE_B_BUS_BIT_WIDTH-1):(i*`TB_DIE_B_BUS_BIT_WIDTH)]),
       .fwd_clk                      (fwd_clk),
       .ns_adapter_rstn              (tb_reset_l),
       .m_wr_clk                     (wr_clk),
       .s_wr_clk                     (rd_clk),
       .m2s_data_in                  (die_a_tx_dout[((i+1)*`TB_DIE_A_BUS_BIT_WIDTH-1):(i*`TB_DIE_A_BUS_BIT_WIDTH)]),
       .s2m_data_in                  (die_b_tx_dout[((i+1)*`TB_DIE_B_BUS_BIT_WIDTH-1):(i*`TB_DIE_B_BUS_BIT_WIDTH)]),
       //`ifdef GEN1
        // .tb_m2s_marker_loc          (CHAN_M2S_MARKER_LOC), 
        // .tb_s2m_marker_loc          (CHAN_S2M_MARKER_LOC), 
       // `endif
       //`ifdef GEN2
       .tb_m2s_marker_loc            (8'd77),               
       .tb_s2m_marker_loc            (8'd77),               
       //`endif
       .tb_master_rate               (MASTER_RATE),         
       .tb_slave_rate                (SLAVE_RATE),          
       .m_gen2_mode                  (`MODE_GEN2),  /////0:gen1    1:gen2  in ca_GENERATED_defines
       .tb_m2s_latency               (CHAN_0_M2S_LATENCY),  
       .tb_s2m_latency               (CHAN_0_S2M_LATENCY),  
       .tb_master_rx_dll_time        (CHAN_0_M2S_DLL_TIME), 
       .tb_slave_rx_dll_time         (CHAN_0_M2S_DLL_TIME), 
       .tb_en_asymmetric             (1'b0));               
  end
endgenerate
`endif //P2P_LITE

    //--------------------------------------------------------------
    // agent hookups
    //--------------------------------------------------------------
    // ++++++
    // die a
    // ++++++
    ca_tx_tb_out_if #(.BUS_BIT_WIDTH (`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS)) ca_die_a_tx_tb_out_if (.clk(clk_die_a), .rst_n(tb_reset_l));
    ca_tx_tb_in_if  #(.BUS_BIT_WIDTH (`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS)) ca_die_a_tx_tb_in_if  (.clk(clk_die_a), .rst_n(tb_reset_l));
    ca_rx_tb_in_if  #(.BUS_BIT_WIDTH (`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS)) ca_die_a_rx_tb_in_if  (.clk(clk_die_a), .rst_n(tb_reset_l));

    assign ca_die_a_tx_tb_out_if.com_clk = clk_die_a;
    assign ca_die_a_tx_tb_in_if.tx_dout  = ca_die_a.tx_dout;

  `ifdef P2P_LITE
     assign ca_die_a_tx_tb_out_if.tx_online            = &{master_sl_tx_transfer_en[`TB_DIE_A_NUM_CHANNELS-1:0],master_ms_tx_transfer_en[`TB_DIE_A_NUM_CHANNELS-1:0]};
     assign ca_die_a_tx_tb_in_if.tx_online             = &{master_sl_tx_transfer_en[`TB_DIE_A_NUM_CHANNELS-1:0],master_ms_tx_transfer_en[`TB_DIE_A_NUM_CHANNELS-1:0]};
     assign ca_die_a_rx_tb_in_if.rx_online             = &{master_sl_tx_transfer_en[`TB_DIE_A_NUM_CHANNELS-1:0],master_ms_tx_transfer_en[`TB_DIE_A_NUM_CHANNELS-1:0]};
  `else
     assign ca_die_a_tx_tb_in_if.tx_online             = ca_die_a_tx_tb_out_if.tx_online;
     assign ca_die_a_tx_tb_out_if.ld_ms_rx_transfer_en = intf_m1.ms_tx_transfer_en;
     assign ca_die_a_tx_tb_out_if.ld_sl_rx_transfer_en = intf_m1.sl_tx_transfer_en; 
     assign ca_die_a_tx_tb_out_if.fl_ms_rx_transfer_en = intf_s1.ms_tx_transfer_en;
     assign ca_die_a_tx_tb_out_if.fl_sl_rx_transfer_en = intf_s1.sl_tx_transfer_en; 
     assign ca_die_a_rx_tb_in_if.rx_din                = intf_m1.data_out_f;
     assign ca_die_a_rx_tb_in_if.ld_ms_rx_transfer_en  = intf_m1.ms_tx_transfer_en;
     assign ca_die_a_rx_tb_in_if.ld_sl_rx_transfer_en  = intf_m1.sl_tx_transfer_en; 
     assign ca_die_a_rx_tb_in_if.fl_ms_rx_transfer_en  = intf_s1.ms_tx_transfer_en;
     assign ca_die_a_rx_tb_in_if.fl_sl_rx_transfer_en  = intf_s1.sl_tx_transfer_en; 
     assign ca_die_a_rx_tb_in_if.ld_rx_align_done      = intf_m1.m_rx_align_done; 
     assign ca_die_a_rx_tb_in_if.fl_rx_align_done      = intf_s1.m_rx_align_done; 
  `endif

     assign ca_die_a_tx_tb_out_if.align_done           = die_a_align_done & die_b_align_done;
     assign ca_die_a_tx_tb_in_if.align_done            = die_a_align_done & die_b_align_done;
     assign ca_die_a_rx_tb_in_if.align_done            = die_a_align_done & die_b_align_done;

    // ++++++
    // die b
    // ++++++
    ca_tx_tb_out_if #(.BUS_BIT_WIDTH (`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS)) ca_die_b_tx_tb_out_if (.clk(clk_die_b), .rst_n(tb_reset_l));
    ca_tx_tb_in_if  #(.BUS_BIT_WIDTH (`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS)) ca_die_b_tx_tb_in_if  (.clk(clk_die_b), .rst_n(tb_reset_l));
    ca_rx_tb_in_if  #(.BUS_BIT_WIDTH (`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS)) ca_die_b_rx_tb_in_if  (.clk(clk_die_b), .rst_n(tb_reset_l));

    assign ca_die_b_tx_tb_out_if.com_clk = clk_die_b;
    assign ca_die_b_tx_tb_in_if.tx_dout  = ca_die_b.tx_dout;

  `ifdef P2P_LITE
     assign ca_die_b_tx_tb_out_if.tx_online            = &{slave_sl_tx_transfer_en[`TB_DIE_B_NUM_CHANNELS-1:0],slave_ms_tx_transfer_en[`TB_DIE_B_NUM_CHANNELS-1:0]};
     assign ca_die_b_tx_tb_in_if.tx_online             = &{slave_sl_tx_transfer_en[`TB_DIE_B_NUM_CHANNELS-1:0],slave_ms_tx_transfer_en[`TB_DIE_B_NUM_CHANNELS-1:0]};
     assign ca_die_b_rx_tb_in_if.rx_online             = &{slave_sl_tx_transfer_en[`TB_DIE_B_NUM_CHANNELS-1:0],slave_ms_tx_transfer_en[`TB_DIE_B_NUM_CHANNELS-1:0]};
   `else    
     assign ca_die_b_tx_tb_in_if.tx_online             = ca_die_b_tx_tb_out_if.tx_online;
     assign ca_die_b_tx_tb_out_if.ld_ms_rx_transfer_en = intf_m1.ms_tx_transfer_en;
     assign ca_die_b_tx_tb_out_if.ld_sl_rx_transfer_en = intf_m1.sl_tx_transfer_en; 
     assign ca_die_b_tx_tb_out_if.fl_ms_rx_transfer_en = intf_s1.ms_tx_transfer_en;
     assign ca_die_b_tx_tb_out_if.fl_sl_rx_transfer_en = intf_s1.sl_tx_transfer_en; 
     assign ca_die_b_rx_tb_in_if.rx_din                = intf_s1.data_out_f;
     assign ca_die_b_rx_tb_in_if.ld_ms_rx_transfer_en  = intf_m1.ms_tx_transfer_en;
     assign ca_die_b_rx_tb_in_if.ld_sl_rx_transfer_en  = intf_m1.sl_tx_transfer_en; 
     assign ca_die_b_rx_tb_in_if.fl_ms_rx_transfer_en  = intf_s1.ms_tx_transfer_en;
     assign ca_die_b_rx_tb_in_if.fl_sl_rx_transfer_en  = intf_s1.sl_tx_transfer_en; 
     assign ca_die_b_rx_tb_in_if.ld_rx_align_done      = intf_m1.m_rx_align_done; 
     assign ca_die_b_rx_tb_in_if.fl_rx_align_done      = intf_s1.m_rx_align_done; 
    `endif

    assign ca_die_b_tx_tb_out_if.align_done            = die_a_align_done & die_b_align_done;
    assign ca_die_b_tx_tb_in_if.align_done             = die_a_align_done & die_b_align_done;
    assign ca_die_b_rx_tb_in_if.align_done             = die_a_align_done & die_b_align_done;

    chan_delay_if #(.BUS_BIT_WIDTH (`TB_DIE_A_BUS_BIT_WIDTH)) chan_delay_die_a_if (.clk(clk_die_a), .rst_n(tb_reset_l));
    chan_delay_if #(.BUS_BIT_WIDTH (`TB_DIE_B_BUS_BIT_WIDTH)) chan_delay_die_b_if (.clk(clk_die_b), .rst_n(tb_reset_l));
    reset_if   reset_if_0 (.clk(clk_die_a));
    ca_gen_if  gen_if(.clk(clk_die_a), .rst_n(tb_reset_l));
    assign gen_if.aib_ready = aib_ready;
    
    // UVM initial block:
    // Virtual interface wrapping & run_test()
    //--------------------------------------------------------------
    initial begin 
        /// display seed
        // die a
        $display("Test SEED: %0d", unsigned'($get_initial_random_seed));
        uvm_config_db #(virtual ca_tx_tb_out_if #(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS)))::set( null, "*.ca_die_a_tx_tb_out_agent.*", "ca_tx_tb_out_vif", ca_die_a_tx_tb_out_if);
        uvm_config_db #(virtual ca_tx_tb_in_if #(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS)))::set( null, "*.ca_die_a_tx_tb_in_agent.*", "ca_tx_tb_in_vif", ca_die_a_tx_tb_in_if);
        uvm_config_db #(virtual ca_rx_tb_in_if #(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS)))::set( null, "*.ca_die_a_rx_tb_in_agent.*", "ca_rx_tb_in_vif", ca_die_a_rx_tb_in_if);
        // die b
        uvm_config_db #(virtual ca_tx_tb_out_if #(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS)))::set( null, "*.ca_die_b_tx_tb_out_agent.*", "ca_tx_tb_out_vif", ca_die_b_tx_tb_out_if);
        uvm_config_db #(virtual ca_tx_tb_in_if #(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS)))::set( null, "*.ca_die_b_tx_tb_in_agent.*", "ca_tx_tb_in_vif", ca_die_b_tx_tb_in_if);
        uvm_config_db #(virtual ca_rx_tb_in_if #(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS)))::set( null, "*.ca_die_b_rx_tb_in_agent.*", "ca_rx_tb_in_vif", ca_die_b_rx_tb_in_if);
        // reset
        uvm_config_db #(virtual reset_if)::set( null, "*", "reset_vif", reset_if_0);
        uvm_config_db #(virtual ca_gen_if)::set( null, "*", "gen_vif", gen_if);

        for(int j = 0; j < `MAX_NUM_CHANNELS; j++) begin  
            uvm_config_db #(virtual chan_delay_if #(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH)))::set(uvm_root::get(), $sformatf("*.chan_delay_die_b_agent_%0d.*",j), "chan_delay_vif", chan_delay_die_b_if);
        end 
        for(int k = 0; k < `MAX_NUM_CHANNELS; k++) begin 
             uvm_config_db #(virtual chan_delay_if #(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH)))::set(uvm_root::get(), $sformatf("*.chan_delay_die_a_agent_%0d.*",k), "chan_delay_vif", chan_delay_die_a_if);
        end 

        run_test();
        end

    //
    // clocking...
    //
    initial begin //// CA :  com_clk
        clk_die_a = 1'b0;
        forever begin
            #(`TB_DIE_A_CLK/2) clk_die_a <= ~clk_die_a;
        end
    end

    initial begin //// CA : com_clk 
        clk_die_b = 1'b0;
        forever begin
            #(`TB_DIE_B_CLK/2) clk_die_b <= ~clk_die_b;
        end
    end
    
    //......................................................
    // clks for AIB
    //......................................................
    initial begin
        avmm_clk <= 1'b0;
        forever begin
            #(AVMM_CYCLE/2) avmm_clk <= ~avmm_clk;
        end
    end
    
    initial begin
        osc_clk <= 1'b0;
        forever begin
            #(OSC_CYCLE/2) osc_clk <= ~osc_clk;
        end
    end
    
    initial begin
        fwd_clk <= 1'b0;
        forever begin
            #(FWD_CYCLE/2) fwd_clk <= ~fwd_clk;
        end
    end
    
    initial begin
        rd_clk <= 1'b0;
        forever begin
            #(RD_CYCLE/2) rd_clk <= ~rd_clk;
        end
    end
    
    initial begin
        wr_clk <= 1'b0;
        forever begin
            #(WR_CYCLE/2) wr_clk <= ~wr_clk;
        end
    end

    //.......................................................
    genvar aclk;
    generate
        for(aclk = 0; aclk < `TB_DIE_A_NUM_CHANNELS; aclk = aclk + 1) begin
            initial begin
                clk_lane_a[aclk] <= 1'b0;
                if(`SYNC_FIFO == 0) #(($urandom_range(3,0)) * (250/2)); // random phase shit delays
                forever begin
                    #(`TB_DIE_A_CLK/2) clk_lane_a[aclk] = ~clk_lane_a[aclk];
                end
            end // int
        end // for
    endgenerate
`ifdef P2P_LITE
    genvar aclk_p2p;
    generate
        for (aclk_p2p = `TB_DIE_A_NUM_CHANNELS; aclk_p2p <`MAX_NUM_CHANNELS  ;aclk_p2p += 1) begin
            initial begin
                clk_lane_a[aclk_p2p] <= 1'b0;
            end // int
        end // for
    endgenerate
`endif
    
    genvar bclk;
    generate
        for(bclk = 0; bclk < `TB_DIE_B_NUM_CHANNELS; bclk = bclk + 1) begin
            initial begin
                clk_lane_b[bclk] <= 1'b0;
                if(`SYNC_FIFO == 0) #(($urandom_range(3,0)) * (250/2)); // random phase shit delays
                forever begin
                    #(`TB_DIE_B_CLK/2) clk_lane_b[bclk] = ~clk_lane_b[bclk];
                end
            end // int
        end // for
    endgenerate
`ifdef P2P_LITE
    genvar bclk_p2p;
    generate
        for (bclk_p2p = `TB_DIE_B_NUM_CHANNELS; bclk_p2p <`MAX_NUM_CHANNELS  ;bclk_p2p += 1) begin
            initial begin
                clk_lane_b[bclk_p2p] <= 1'b0;
            end // int
        end // for
    endgenerate
`endif
    
    // AIB bring up via avmm 
    //--------------------------------------------------------------
    always @(posedge avmm_clk) begin
        if(tb_reset_l === 1'b0) begin
             if(tb_do_aib_reset == 1) begin
                 $display("%0t CA_TOP_TB ===========> RESET AIB", $time);
                 tb_do_aib_reset = 0;
                 tb_do_aib_prog  = 1;
                 aib_ready <= 1'b0;
                 reset_dut(); 
             end
        end
        else if(tb_reset_l === 1'b1) begin
            if(tb_do_aib_prog == 1) begin
                tb_do_aib_prog = 0;
                $display("%0t CA_TOP_TB ===========> PROG AIB via avmm", $time);
                prog_aib_via_avm_1x();
                //prog_aib_via_avm_4x();
                wakeup_aib();
                wait_for_link_up();
                $display("%0t CA_TOP_TB ===========> AIB READY lets go...", $time);
                aib_ready <= 1'b1;
                tb_do_aib_reset = 1;
            end
        end 
    end



    // WAVES
    //--------------------------------------------------------------
    initial begin
        $shm_open( , 0, , ); $shm_probe( ca_die_a, "CA_DIE_A");
        $shm_open( , 0, , ); $shm_probe( ca_die_b, "CA_DIE_B");
    end
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
`include "aib_tb_tasks.svi"
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
   `ifndef P2P_LITE
    logic [`MAX_BUS_BIT_WIDTH-1:0] die_a_ca_chan[`MAX_NUM_CHANNELS];
    logic [`MAX_BUS_BIT_WIDTH-1:0] die_b_ca_chan[`MAX_NUM_CHANNELS];
    logic [`TB_DIE_A_BUS_BIT_WIDTH-1:0] die_a_aib_chan[`MAX_NUM_CHANNELS];
    logic [`TB_DIE_B_BUS_BIT_WIDTH-1:0] die_b_aib_chan[`MAX_NUM_CHANNELS];
    genvar chan;
    generate
        for(chan = 0; chan < `MAX_NUM_CHANNELS; chan++) begin
            assign die_a_ca_chan[chan] = { {`MAX_BUS_BIT_WIDTH-`TB_DIE_A_BUS_BIT_WIDTH{1'b0}}, die_a_tx_dout[(`TB_DIE_A_BUS_BIT_WIDTH*(chan+1))-1:(`TB_DIE_A_BUS_BIT_WIDTH*chan)] }; 
            assign die_b_ca_chan[chan] = { {`MAX_BUS_BIT_WIDTH-`TB_DIE_B_BUS_BIT_WIDTH{1'b0}}, die_b_tx_dout[(`TB_DIE_B_BUS_BIT_WIDTH*(chan+1))-1:(`TB_DIE_B_BUS_BIT_WIDTH*chan)] }; 
            assign die_a_aib_chan[chan] = intf_m1.data_out_f[(`TB_DIE_A_BUS_BIT_WIDTH+(`MAX_BUS_BIT_WIDTH*chan))-1:`MAX_BUS_BIT_WIDTH*chan]; 
            assign die_b_aib_chan[chan] = intf_s1.data_out_f[(`TB_DIE_B_BUS_BIT_WIDTH+(`MAX_BUS_BIT_WIDTH*chan))-1:`MAX_BUS_BIT_WIDTH*chan]; 
        end
    endgenerate 


    assign intf_m1.data_in_f = {
       {die_a_ca_chan[23]}, {die_a_ca_chan[22]}, {die_a_ca_chan[21]}, {die_a_ca_chan[20]}, {die_a_ca_chan[19]}, {die_a_ca_chan[18]},
       {die_a_ca_chan[17]}, {die_a_ca_chan[16]}, {die_a_ca_chan[15]}, {die_a_ca_chan[14]}, {die_a_ca_chan[13]}, {die_a_ca_chan[12]},
       {die_a_ca_chan[11]}, {die_a_ca_chan[10]}, {die_a_ca_chan[9]},  {die_a_ca_chan[8]},  {die_a_ca_chan[7]},  {die_a_ca_chan[6]},
       {die_a_ca_chan[5]},  {die_a_ca_chan[4]},  {die_a_ca_chan[3]},  {die_a_ca_chan[2]},  {die_a_ca_chan[1]},  {die_a_ca_chan[0]}
    }; // assign

    assign intf_s1.data_in_f = {
       {die_b_ca_chan[23]}, {die_b_ca_chan[22]}, {die_b_ca_chan[21]}, {die_b_ca_chan[20]}, {die_b_ca_chan[19]}, {die_b_ca_chan[18]},
       {die_b_ca_chan[17]}, {die_b_ca_chan[16]}, {die_b_ca_chan[15]}, {die_b_ca_chan[14]}, {die_b_ca_chan[13]}, {die_b_ca_chan[12]},
       {die_b_ca_chan[11]}, {die_b_ca_chan[10]}, {die_b_ca_chan[9]},  {die_b_ca_chan[8]},  {die_b_ca_chan[7]},  {die_b_ca_chan[6]},
       {die_b_ca_chan[5]},  {die_b_ca_chan[4]},  {die_b_ca_chan[3]},  {die_b_ca_chan[2]},  {die_b_ca_chan[1]},  {die_b_ca_chan[0]}
    }; // assign
    
    assign die_a_rx_din = {
       {die_a_aib_chan[23]}, {die_a_aib_chan[22]}, {die_a_aib_chan[21]}, {die_a_aib_chan[20]}, {die_a_aib_chan[19]}, {die_a_aib_chan[18]},
       {die_a_aib_chan[17]}, {die_a_aib_chan[16]}, {die_a_aib_chan[15]}, {die_a_aib_chan[14]}, {die_a_aib_chan[13]}, {die_a_aib_chan[12]},
       {die_a_aib_chan[11]}, {die_a_aib_chan[10]}, {die_a_aib_chan[9]},  {die_a_aib_chan[8]},  {die_a_aib_chan[7]},  {die_a_aib_chan[6]},
       {die_a_aib_chan[5]},  {die_a_aib_chan[4]},  {die_a_aib_chan[3]},  {die_a_aib_chan[2]},  {die_a_aib_chan[1]},  {die_a_aib_chan[0]}
    }; // assign

    assign die_b_rx_din = {
       {die_b_aib_chan[23]}, {die_b_aib_chan[22]}, {die_b_aib_chan[21]}, {die_b_aib_chan[20]}, {die_b_aib_chan[19]}, {die_b_aib_chan[18]},
       {die_b_aib_chan[17]}, {die_b_aib_chan[16]}, {die_b_aib_chan[15]}, {die_b_aib_chan[14]}, {die_b_aib_chan[13]}, {die_b_aib_chan[12]},
       {die_b_aib_chan[11]}, {die_b_aib_chan[10]}, {die_b_aib_chan[9]},  {die_b_aib_chan[8]},  {die_b_aib_chan[7]},  {die_b_aib_chan[6]},
       {die_b_aib_chan[5]},  {die_b_aib_chan[4]},  {die_b_aib_chan[3]},  {die_b_aib_chan[2]},  {die_b_aib_chan[1]},  {die_b_aib_chan[0]}
    };
   `endif

    genvar dout_a;
    for(dout_a = 0; dout_a < `MAX_NUM_CHANNELS; dout_a++) begin : dout_a_inst 
      assign die_a_dout_delay[(`TB_DIE_A_BUS_BIT_WIDTH+(`TB_DIE_A_BUS_BIT_WIDTH*dout_a))-1:`TB_DIE_A_BUS_BIT_WIDTH*dout_a]   = chan_delay_die_a_inst[dout_a].chan_delay_die_a_if.dout[(`TB_DIE_A_BUS_BIT_WIDTH-1):0];
    end

    genvar dout_b;
    for(dout_b = 0; dout_b < `MAX_NUM_CHANNELS; dout_b++) begin : dout_b_inst 
       assign die_b_dout_delay[(`TB_DIE_B_BUS_BIT_WIDTH+(`TB_DIE_B_BUS_BIT_WIDTH*dout_b))-1:`TB_DIE_B_BUS_BIT_WIDTH*dout_b]  = chan_delay_die_b_inst[dout_b].chan_delay_die_b_if.dout[(`TB_DIE_B_BUS_BIT_WIDTH-1):0];
    end

    genvar j;
    for(j = 0; j < `MAX_NUM_CHANNELS; j++) begin : chan_delay_die_b_inst
        chan_delay_if #(.BUS_BIT_WIDTH (`TB_DIE_B_BUS_BIT_WIDTH)) chan_delay_die_b_if (.clk(clk_die_b), .rst_n(tb_reset_l));
        `ifdef P2P_LITE
            assign chan_delay_die_b_if.din = p2p_inst[j].p2p_i.s2m_data_out[(`TB_DIE_B_BUS_BIT_WIDTH-1):0];
        `else 
           assign chan_delay_die_b_if.din = intf_m1.data_out_f[(`TB_DIE_B_BUS_BIT_WIDTH+(`MAX_BUS_BIT_WIDTH*j))-1:`MAX_BUS_BIT_WIDTH*j]; 
        `endif 
        initial uvm_config_db #(virtual chan_delay_if #(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH)))::set(uvm_root::get(), $sformatf("*.chan_delay_die_b_agent_%0d.*",j), "chan_delay_vif", chan_delay_die_b_if);
    end // genvar j

    genvar k;
    for(k = 0; k < `MAX_NUM_CHANNELS; k++) begin : chan_delay_die_a_inst
        chan_delay_if #(.BUS_BIT_WIDTH (`TB_DIE_A_BUS_BIT_WIDTH)) chan_delay_die_a_if (.clk(clk_die_a), .rst_n(tb_reset_l));
        `ifdef P2P_LITE
            assign chan_delay_die_a_if.din = p2p_inst[k].p2p_i.m2s_data_out[(`TB_DIE_A_BUS_BIT_WIDTH-1):0];
        `else 
           assign chan_delay_die_a_if.din = intf_s1.data_out_f[(`TB_DIE_A_BUS_BIT_WIDTH+(`MAX_BUS_BIT_WIDTH*k))-1:`MAX_BUS_BIT_WIDTH*k];
        `endif
        initial uvm_config_db #(virtual chan_delay_if #(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH)))::set(uvm_root::get(), $sformatf("*.chan_delay_die_a_agent_%0d.*",k), "chan_delay_vif", chan_delay_die_a_if);
    end // genvar k
//////////////////////////////////////////////////////////////////////////////////////////
endmodule: ca_top_tb
///////////////////////////////////////////////////////
`endif
