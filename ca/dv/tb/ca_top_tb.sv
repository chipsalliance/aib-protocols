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
    parameter FWD_CYCLE  = 2000;
    parameter WR_CYCLE   = 2000;
    parameter RD_CYCLE   = 2000;

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

    //-----------------------------------

    `include "top_tb_declare.inc"

    reg    clk_die_a        = 1'b0;
    reg    clk_die_b        = 1'b0;

    reg    [`TB_DIE_A_NUM_CHANNELS-1:0]  clk_lane_a;
    reg    [`TB_DIE_B_NUM_CHANNELS-1:0]  clk_lane_b;

    // AIB clks
    reg    avmm_clk = 1'b0;
    reg    osc_clk  = 1'b0;
    reg    fwd_clk  = 1'b0;
    reg    rd_clk   = 1'b0;
    reg    wr_clk   = 1'b0;

    logic  tb_do_aib_reset = 1;
    logic  tb_do_aib_prog  = 1;

    logic  aib_ready = 0;
   reg  [39:0] die_b_rx_din_d1, die_b_rx_din_d2, die_b_rx_din_d;
   wire [39:0] die_b_rx_din_w;

    // wires
    //--------------------------------------------------------------
    wire   tb_reset_l;
    assign tb_reset_l = reset_if_0.reset_l;

    wire   die_a_align_done;
    wire   die_b_align_done;

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



    // Channel Alignment DIE A
    //--------------------------------------------------------------
    ca #(.NUM_CHANNELS      (`TB_DIE_A_NUM_CHANNELS),
         .BITS_PER_CHANNEL  (`TB_DIE_A_BUS_BIT_WIDTH),
         .AD_WIDTH          (`TB_DIE_A_AD_WIDTH)
        ) ca_die_a (
             .lane_clk         (clk_lane_a),
             .com_clk          (clk_die_a),
             .rst_n            (tb_reset_l),
             .tx_online        (ca_die_a_tx_tb_out_if.tx_online),
             .rx_online        (ca_die_a_rx_tb_in_if.rx_online),
             .tx_stb_en        (ca_die_a_tx_tb_out_if.tx_stb_en),
             .tx_stb_rcvr      (ca_die_a_tx_tb_out_if.tx_stb_rcvr),
             .align_fly        (ca_die_a_rx_tb_in_if.align_fly),
             .rden_dly         (ca_die_a_rx_tb_in_if.rden_dly),
             .count_x          (8'h2), // FIXME
             .count_xz         (8'h2), // FIXME
             .tx_stb_wd_sel    (ca_die_a_tx_tb_out_if.tx_stb_wd_sel),
             .tx_stb_bit_sel   (ca_die_a_tx_tb_out_if.tx_stb_bit_sel),
             .tx_stb_intv      (ca_die_a_tx_tb_out_if.tx_stb_intv),
             .rx_stb_wd_sel    (ca_die_a_rx_tb_in_if.rx_stb_wd_sel),
             .rx_stb_bit_sel   (ca_die_a_rx_tb_in_if.rx_stb_bit_sel),
             .rx_stb_intv      (ca_die_a_rx_tb_in_if.rx_stb_intv),
             .tx_din           (ca_die_a_tx_tb_out_if.tx_din),
             .tx_dout          (die_a_tx_dout),
             .rx_din           (die_a_rx_din), // channel delay dout
             .rx_dout          (ca_die_a_rx_tb_in_if.rx_dout),
             .align_done       (die_a_align_done),
             .align_err        (ca_die_a_rx_tb_in_if.align_err),
             .tx_stb_pos_err         (ca_die_a_tx_tb_in_if.tx_stb_pos_err),
             .tx_stb_pos_coding_err  (ca_die_a_tx_tb_in_if.tx_stb_pos_coding_err),
             .rx_stb_pos_err         (ca_die_a_rx_tb_in_if.rx_stb_pos_err),
             .rx_stb_pos_coding_err  (ca_die_a_rx_tb_in_if.rx_stb_pos_coding_err),
             .fifo_full_val          (ca_die_a_rx_tb_in_if.fifo_full_val),
             .fifo_pfull_val         (ca_die_a_rx_tb_in_if.fifo_pfull_val),
             .fifo_empty_val         (ca_die_a_rx_tb_in_if.fifo_empty_val),
             .fifo_pempty_val        (ca_die_a_rx_tb_in_if.fifo_pempty_val),
             .fifo_full        (ca_die_a_rx_tb_in_if.fifo_full),
             .fifo_pfull       (ca_die_a_rx_tb_in_if.fifo_pfull),
             .fifo_empty       (ca_die_a_rx_tb_in_if.fifo_empty),
             .fifo_pempty      (ca_die_a_rx_tb_in_if.fifo_pempty)
         );
    
    // Channel Alignment DIE B
    //--------------------------------------------------------------
    ca #(.NUM_CHANNELS      (`TB_DIE_B_NUM_CHANNELS),
         .BITS_PER_CHANNEL  (`TB_DIE_B_BUS_BIT_WIDTH),
         .AD_WIDTH          (`TB_DIE_B_AD_WIDTH)
        ) ca_die_b (
             .lane_clk         (clk_lane_b),
             .com_clk          (clk_die_b),
             .rst_n            (tb_reset_l),
             .tx_online        (ca_die_b_tx_tb_out_if.tx_online),
             .rx_online        (ca_die_b_rx_tb_in_if.rx_online),
             .tx_stb_en        (ca_die_b_tx_tb_out_if.tx_stb_en),
             .tx_stb_rcvr      (ca_die_b_tx_tb_out_if.tx_stb_rcvr),
             .align_fly        (ca_die_b_rx_tb_in_if.align_fly),
             .rden_dly         (ca_die_b_rx_tb_in_if.rden_dly),
             .count_x          (8'd2), // FIXME
             .count_xz         (8'd2), // FIXME
             .tx_stb_wd_sel    (ca_die_b_tx_tb_out_if.tx_stb_wd_sel),
             .tx_stb_bit_sel   (ca_die_b_tx_tb_out_if.tx_stb_bit_sel),
             .tx_stb_intv      (ca_die_b_tx_tb_out_if.tx_stb_intv),
             .rx_stb_wd_sel    (ca_die_b_rx_tb_in_if.rx_stb_wd_sel),
             .rx_stb_bit_sel   (ca_die_b_rx_tb_in_if.rx_stb_bit_sel),
             .rx_stb_intv      (ca_die_b_rx_tb_in_if.rx_stb_intv),
             .tx_din           (ca_die_b_tx_tb_out_if.tx_din),
             .tx_dout          (die_b_tx_dout),
`ifdef CH0_DELAY2 
             .rx_din           ({die_b_rx_din[159:39],die_b_rx_din_w[39:0]}), // channel delay here
`else
             .rx_din           (die_b_rx_din), // channel delay here
`endif
             .rx_dout          (ca_die_b_rx_tb_in_if.rx_dout),
             .align_done       (die_b_align_done),
             .align_err        (ca_die_b_rx_tb_in_if.align_err),
             .tx_stb_pos_err         (ca_die_b_tx_tb_in_if.tx_stb_pos_err),
             .tx_stb_pos_coding_err  (ca_die_b_tx_tb_in_if.tx_stb_pos_coding_err),
             .rx_stb_pos_err         (ca_die_b_rx_tb_in_if.rx_stb_pos_err),
             .rx_stb_pos_coding_err  (ca_die_b_rx_tb_in_if.rx_stb_pos_coding_err),
             .fifo_full_val          (ca_die_b_rx_tb_in_if.fifo_full_val),
             .fifo_pfull_val         (ca_die_b_rx_tb_in_if.fifo_pfull_val),
             .fifo_empty_val         (ca_die_b_rx_tb_in_if.fifo_empty_val),
             .fifo_pempty_val        (ca_die_b_rx_tb_in_if.fifo_pempty_val),
             .fifo_full        (ca_die_b_rx_tb_in_if.fifo_full),
             .fifo_pfull       (ca_die_b_rx_tb_in_if.fifo_pfull),
             .fifo_empty       (ca_die_b_rx_tb_in_if.fifo_empty),
             .fifo_pempty      (ca_die_b_rx_tb_in_if.fifo_pempty)
         );


    // agent hookups
    //--------------------------------------------------------------
    // die a
    // ......................................
    ca_tx_tb_out_if #(.BUS_BIT_WIDTH (`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS)) ca_die_a_tx_tb_out_if (.clk(clk_die_a), .rst_n(tb_reset_l));
    assign ca_die_a_tx_tb_out_if.com_clk = clk_die_a;
    assign ca_die_a_tx_tb_out_if.ld_ms_rx_transfer_en = intf_m1.ms_tx_transfer_en;
    assign ca_die_a_tx_tb_out_if.ld_sl_rx_transfer_en = intf_m1.sl_tx_transfer_en; 
    assign ca_die_a_tx_tb_out_if.fl_ms_rx_transfer_en = intf_s1.ms_tx_transfer_en;
    assign ca_die_a_tx_tb_out_if.fl_sl_rx_transfer_en = intf_s1.sl_tx_transfer_en; 
    assign ca_die_a_tx_tb_out_if.align_done = die_a_align_done & die_b_align_done;

    ca_tx_tb_in_if #(.BUS_BIT_WIDTH (`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS)) ca_die_a_tx_tb_in_if (.clk(clk_die_a), .rst_n(tb_reset_l));
    assign ca_die_a_tx_tb_in_if.tx_dout = ca_die_a.tx_dout;
    assign ca_die_a_tx_tb_in_if.tx_online = ca_die_a_tx_tb_out_if.tx_online;
    assign ca_die_a_tx_tb_in_if.align_done = die_a_align_done & die_b_align_done;

    ca_rx_tb_in_if #(.BUS_BIT_WIDTH (`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS)) ca_die_a_rx_tb_in_if (.clk(clk_die_a), .rst_n(tb_reset_l));
    assign ca_die_a_rx_tb_in_if.rx_din = intf_m1.data_out_f;
    assign ca_die_a_rx_tb_in_if.ld_ms_rx_transfer_en = intf_m1.ms_tx_transfer_en;
    assign ca_die_a_rx_tb_in_if.ld_sl_rx_transfer_en = intf_m1.sl_tx_transfer_en; 
    assign ca_die_a_rx_tb_in_if.fl_ms_rx_transfer_en = intf_s1.ms_tx_transfer_en;
    assign ca_die_a_rx_tb_in_if.fl_sl_rx_transfer_en = intf_s1.sl_tx_transfer_en; 
    assign ca_die_a_rx_tb_in_if.ld_rx_align_done = intf_m1.m_rx_align_done; 
    assign ca_die_a_rx_tb_in_if.fl_rx_align_done = intf_s1.m_rx_align_done; 
    assign ca_die_a_rx_tb_in_if.align_done = die_a_align_done & die_b_align_done;
    
    // die b
    // ......................................
    ca_tx_tb_out_if #(.BUS_BIT_WIDTH (`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS)) ca_die_b_tx_tb_out_if (.clk(clk_die_b), .rst_n(tb_reset_l));
    assign ca_die_b_tx_tb_out_if.com_clk = clk_die_b;
    assign ca_die_b_tx_tb_out_if.ld_ms_rx_transfer_en = intf_m1.ms_tx_transfer_en;
    assign ca_die_b_tx_tb_out_if.ld_sl_rx_transfer_en = intf_m1.sl_tx_transfer_en; 
    assign ca_die_b_tx_tb_out_if.fl_ms_rx_transfer_en = intf_s1.ms_tx_transfer_en;
    assign ca_die_b_tx_tb_out_if.fl_sl_rx_transfer_en = intf_s1.sl_tx_transfer_en; 
    assign ca_die_b_tx_tb_out_if.align_done = die_a_align_done & die_b_align_done;

    ca_tx_tb_in_if #(.BUS_BIT_WIDTH (`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS)) ca_die_b_tx_tb_in_if (.clk(clk_die_b), .rst_n(tb_reset_l));
    assign ca_die_b_tx_tb_in_if.tx_dout = ca_die_b.tx_dout;
    assign ca_die_b_tx_tb_in_if.tx_online = ca_die_b_tx_tb_out_if.tx_online;
    assign ca_die_b_tx_tb_in_if.align_done = die_a_align_done & die_b_align_done;

    ca_rx_tb_in_if #(.BUS_BIT_WIDTH (`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS)) ca_die_b_rx_tb_in_if (.clk(clk_die_b), .rst_n(tb_reset_l));
    assign ca_die_b_rx_tb_in_if.rx_din = intf_s1.data_out_f;
    assign ca_die_b_rx_tb_in_if.ld_ms_rx_transfer_en = intf_m1.ms_tx_transfer_en;
    assign ca_die_b_rx_tb_in_if.ld_sl_rx_transfer_en = intf_m1.sl_tx_transfer_en; 
    assign ca_die_b_rx_tb_in_if.fl_ms_rx_transfer_en = intf_s1.ms_tx_transfer_en;
    assign ca_die_b_rx_tb_in_if.fl_sl_rx_transfer_en = intf_s1.sl_tx_transfer_en; 
    assign ca_die_b_rx_tb_in_if.ld_rx_align_done = intf_m1.m_rx_align_done; 
    assign ca_die_b_rx_tb_in_if.fl_rx_align_done = intf_s1.m_rx_align_done; 
    assign ca_die_b_rx_tb_in_if.align_done = die_a_align_done & die_b_align_done;

    genvar j;
    for(j = 0; j < `MAX_NUM_CHANNELS; j++) begin : chan_delay_die_b_inst
        chan_delay_if #(.BUS_BIT_WIDTH (`TB_DIE_B_BUS_BIT_WIDTH)) chan_delay_die_b_if (.clk(clk_die_b), .rst_n(tb_reset_l));
        assign chan_delay_die_b_if.din = intf_s1.data_out_f[(`TB_DIE_B_BUS_BIT_WIDTH+(`MAX_BUS_BIT_WIDTH*j))-1:`MAX_BUS_BIT_WIDTH*j]; 
        initial uvm_config_db #(virtual chan_delay_if #(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH)))::set(uvm_root::get(), $sformatf("*.chan_delay_die_b_agent_%0d.*",j), "chan_delay_vif", chan_delay_die_b_if);
    end // genvar j

    genvar k;
    for(k = 0; k < `MAX_NUM_CHANNELS; k++) begin : chan_delay_die_a_inst
        chan_delay_if #(.BUS_BIT_WIDTH (`TB_DIE_A_BUS_BIT_WIDTH)) chan_delay_die_a_if (.clk(clk_die_a), .rst_n(tb_reset_l));
        assign chan_delay_die_a_if.din = intf_m1.data_out_f[(`TB_DIE_A_BUS_BIT_WIDTH+(`MAX_BUS_BIT_WIDTH*k))-1:`MAX_BUS_BIT_WIDTH*k];
        initial uvm_config_db #(virtual chan_delay_if #(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH)))::set(uvm_root::get(), $sformatf("*.chan_delay_die_a_agent_%0d.*",k), "chan_delay_vif", chan_delay_die_a_if);
    end // genvar k


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
        run_test();
        end

    //
    // clocking...
    //
    initial begin 
        clk_die_a = 1'b0;
        forever begin
            #(`TB_DIE_A_CLK/2) clk_die_a <= ~clk_die_a;
        end
    end

    initial begin 
        clk_die_b = 1'b0;
        forever begin
            #(`TB_DIE_B_CLK/2) clk_die_b <= ~clk_die_b;
        end
    end
    
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

   /////Delay arrangement for  CH#0
    always @(posedge clk_lane_b[0]) begin
      if(tb_reset_l === 1'b0) begin
          die_b_rx_din_d1[39:0] <=  'h0;
          die_b_rx_din_d2[39:0] <=  'h0;
          die_b_rx_din_d[39:0]  <=  'h0;
      end else begin
          die_b_rx_din_d1[39:0] <=  die_b_rx_din[39:0];
          die_b_rx_din_d2[39:0] <=  die_b_rx_din_d1[39:0]; 
          die_b_rx_din_d[39:0]  <=  die_b_rx_din_d2[39:0];
      end
    end
    assign die_b_rx_din_w[39:0] = die_b_rx_din_d[39:0];


    // WAVES
    //--------------------------------------------------------------
    initial begin
        $shm_open( , 0, , ); $shm_probe( ca_die_a, "CA_DIE_A");
        $shm_open( , 0, , ); $shm_probe( ca_die_b, "CA_DIE_B");
    end

    //**************************************************************
    // Intel tasks for AIB bring up 
    //--------------------------------------------------------------
    task reset_dut ();
        begin
         $display("\n////////////////////////////////////////////////////////////////////////////");
         $display("%0t: Into task reset_dut", $time);
         $display("////////////////////////////////////////////////////////////////////////////\n");

         avmm_if_m1.rst_n = 1'b0;
         avmm_if_m1.address = '0;
         avmm_if_m1.write = 1'b0;
         avmm_if_m1.read  = 1'b0;
         avmm_if_m1.writedata = '0;
         avmm_if_m1.byteenable = '0;
         avmm_if_s1.rst_n = 1'b0;
         avmm_if_s1.address = '0;
         avmm_if_s1.write = 1'b0;
         avmm_if_s1.read  = 1'b0;
         avmm_if_s1.writedata = '0;
         avmm_if_s1.byteenable = '0;

         intf_s1.i_conf_done     = 1'b0;
         intf_s1.ns_mac_rdy      = '0;
         intf_s1.ns_adapter_rstn = '0;
         intf_s1.sl_rx_dcc_dll_lock_req = '0;
         intf_s1.sl_tx_dcc_dll_lock_req = '0;

         intf_m1.i_conf_done = 1'b0;
         intf_m1.ns_mac_rdy      = '0;
         intf_m1.ns_adapter_rstn = '0;
         intf_m1.ms_rx_dcc_dll_lock_req = '0;
         intf_m1.ms_tx_dcc_dll_lock_req = '0;
         #100ns;

         intf_m1.m_por_ovrd = 1'b1;
         intf_s1.m_device_detect_ovrd = 1'b0;
         intf_s1.i_m_power_on_reset = 1'b0;
         //intf_m1.data_in = {`MAX_NUM_CHANNELS{80'b0}};
         //intf_s1.data_in = {`MAX_NUM_CHANNELS{80'b0}};

         //intf_m1.data_in_f = {`MAX_NUM_CHANNELS{320'b0}};
         //intf_s1.data_in_f = {`MAX_NUM_CHANNELS{320'b0}};

         //intf_m1.gen1_data_in = {`MAX_NUM_CHANNELS{40'b0}};

         //intf_m1.gen1_data_in_f = {`MAX_NUM_CHANNELS{320'b0}};
         //intf_s1.gen1_data_in_f = {`MAX_NUM_CHANNELS{80'b0}};

         #100ns;
         intf_s1.i_m_power_on_reset = 1'b1;
         $display("\n////////////////////////////////////////////////////////////////////////////");
         $display("%0t: Follower (Slave) power_on_reset asserted", $time);
         $display("////////////////////////////////////////////////////////////////////////////\n");

         #200ns;
         intf_s1.i_m_power_on_reset = 1'b0;
         $display("\n////////////////////////////////////////////////////////////////////////////");
         $display("%0t: Follower (Slave)  power_on_reset de-asserted", $time);
         $display("////////////////////////////////////////////////////////////////////////////\n");

         #200ns;
         avmm_if_m1.rst_n = 1'b1;
         avmm_if_s1.rst_n = 1'b1;

         #100ns;
         $display("%0t: %m: de-asserting configuration reset and start configuration setup", $time);
        end
    endtask : reset_dut

    //--------------------------------------------------------------
    task prog_aib_via_avm_1x ();
        begin
            $display("\n////////////////////////////////////////////////////////////////////////////");
            $display("\n////////////////////////////////////////////////////////////////////////////");
            $display("\n//                                                                       ///");
            $display("%0t: set to 1xFIFO mode for ms -> sl and sl -> ms 24 channel testing", $time);
            $display("\n//                                                                       ///");
            $display("%0t: No dbi enabled", $time);
            $display("////////////////////////////////////////////////////////////////////////////\n");

      fork

        for (int i_m1=0; i_m1<24; i_m1++) begin
            avmm_if_m1.cfg_write({i_m1,11'h208}, 2'h3, 16'h0000);
            avmm_if_m1.cfg_write({i_m1,11'h20a}, 2'h3, 16'h0200);
            avmm_if_m1.cfg_write({i_m1,11'h210}, 2'h3, 16'h0001);
            avmm_if_m1.cfg_write({i_m1,11'h212}, 2'h3, 16'h0000);
            avmm_if_m1.cfg_write({i_m1,11'h218}, 2'h3, 16'h0000);
            avmm_if_m1.cfg_write({i_m1,11'h21a}, 2'h3, 16'h2080);
            avmm_if_m1.cfg_write({i_m1,11'h21c}, 2'h3, 16'h0000);
            avmm_if_m1.cfg_write({i_m1,11'h21e}, 2'h3, 16'h0000);
            avmm_if_m1.cfg_write({i_m1,11'h31c}, 2'h3, 16'h0000);
            avmm_if_m1.cfg_write({i_m1,11'h31e}, 2'h3, 16'h0000);
            avmm_if_m1.cfg_write({i_m1,11'h320}, 2'h3, 16'h0000);
            avmm_if_m1.cfg_write({i_m1,11'h322}, 2'h3, 16'h0000);
            avmm_if_m1.cfg_write({i_m1,11'h324}, 2'h3, 16'h0000);
            avmm_if_m1.cfg_write({i_m1,11'h326}, 2'h3, 16'h0000);
            avmm_if_m1.cfg_write({i_m1,11'h328}, 2'h3, 16'h0000);
            avmm_if_m1.cfg_write({i_m1,11'h32a}, 2'h3, 16'h0000);
        end
        for (int i_s1=0; i_s1<24; i_s1++) begin
            avmm_if_s1.cfg_write({i_s1,11'h208}, 2'h3, 16'h0000);
            avmm_if_s1.cfg_write({i_s1,11'h20a}, 2'h3, 16'h0200);
            avmm_if_s1.cfg_write({i_s1,11'h210}, 2'h3, 16'h0001);
            avmm_if_s1.cfg_write({i_s1,11'h212}, 2'h3, 16'h0000);
            avmm_if_s1.cfg_write({i_s1,11'h218}, 2'h3, 16'h0000);
            avmm_if_s1.cfg_write({i_s1,11'h21a}, 2'h3, 16'h2080);
            avmm_if_s1.cfg_write({i_s1,11'h21c}, 2'h3, 16'h0000);
            avmm_if_s1.cfg_write({i_s1,11'h21e}, 2'h3, 16'h0000);
            avmm_if_s1.cfg_write({i_s1,11'h31c}, 2'h3, 16'h0000);
            avmm_if_s1.cfg_write({i_s1,11'h31e}, 2'h3, 16'h0000);
            avmm_if_s1.cfg_write({i_s1,11'h320}, 2'h3, 16'h0000);
            avmm_if_s1.cfg_write({i_s1,11'h322}, 2'h3, 16'h0000);
            avmm_if_s1.cfg_write({i_s1,11'h324}, 2'h3, 16'h0000);
            avmm_if_s1.cfg_write({i_s1,11'h326}, 2'h3, 16'h0000);
            avmm_if_s1.cfg_write({i_s1,11'h328}, 2'h3, 16'h0000);
            avmm_if_s1.cfg_write({i_s1,11'h32a}, 2'h3, 16'h0000);

        end
      join


            ms1_tx_fifo_mode = 2'b00;
            sl1_tx_fifo_mode = 2'b00;
            ms1_rx_fifo_mode = 2'b00;
            sl1_rx_fifo_mode = 2'b00;
            ms1_gen1 = 1'b0;
            sl1_gen1 = 1'b0;
            ms1_lpbk = 1'b0;
            sl1_lpbk = 1'b0;
            ms1_dbi_en = 1'b0;
            sl1_dbi_en = 1'b0;

        end
    endtask : prog_aib_via_avm_1x

    //--------------------------------------------------------------
    task prog_aib_via_avm_4x ();
        begin
            $display("////////////////////////////////////////////////////////////////////////////");
            $display("////////////////////////////////////////////////////////////////////////////");
            $display("//                                                                       ///");
            $display("%0t: set to 4xFIFO mode for ms -> sl and sl -> ms, 24 channel testing", $time);
            $display("//                                                                       ///");
            $display("%0t: No dbi enabled", $time);
            $display("////////////////////////////////////////////////////////////////////////////\n");
        end
    endtask : prog_aib_via_avm_4x
    
    //--------------------------------------------------------------
    task wakeup_aib ();
        begin
            $display("////////////////////////////////////////////////////////////////////////////");
            $display("%0t: wakeup_aib", $time);
            $display("////////////////////////////////////////////////////////////////////////////\n");
            intf_m1.i_conf_done = 1'b1;
            intf_s1.i_conf_done = 1'b1;

            intf_m1.ns_mac_rdy = {`MAX_NUM_CHANNELS{1'b1}};
            intf_s1.ns_mac_rdy = {`MAX_NUM_CHANNELS{1'b1}};

            #1000ns;
            intf_m1.ns_adapter_rstn = {`MAX_NUM_CHANNELS{1'b1}};
            intf_s1.ns_adapter_rstn = {`MAX_NUM_CHANNELS{1'b1}};
            #1000ns;
            intf_s1.sl_rx_dcc_dll_lock_req = {`MAX_NUM_CHANNELS{1'b1}};
            intf_s1.sl_tx_dcc_dll_lock_req = {`MAX_NUM_CHANNELS{1'b1}};

            intf_m1.ms_rx_dcc_dll_lock_req = {`MAX_NUM_CHANNELS{1'b1}};
            intf_m1.ms_tx_dcc_dll_lock_req = {`MAX_NUM_CHANNELS{1'b1}};

            intf_m1.data_in = {`MAX_NUM_CHANNELS{80'b0}};
            intf_s1.data_in = {`MAX_NUM_CHANNELS{80'b0}};

            intf_m1.data_in_f[319:0] = {`MAX_NUM_CHANNELS{320'b0}};
            intf_s1.data_in_f[319:0] = {`MAX_NUM_CHANNELS{320'b0}};

        end
    endtask : wakeup_aib

    //--------------------------------------------------------------
    task wait_for_link_up ();
        begin
            $display("////////////////////////////////////////////////////////////////////////////");
            $display("%0t: Waiting for link up", $time);
            $display("////////////////////////////////////////////////////////////////////////////\n");
            begin
                wait (intf_s1.ms_tx_transfer_en == {`MAX_NUM_CHANNELS{1'b1}});
                wait (intf_s1.sl_tx_transfer_en == {`MAX_NUM_CHANNELS{1'b1}});
            end
            #100ns;
        end
    endtask : wait_for_link_up 

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

//////////////////////////////////////////////////////////////////////////////////////////
endmodule: ca_top_tb
///////////////////////////////////////////////////////
`endif
