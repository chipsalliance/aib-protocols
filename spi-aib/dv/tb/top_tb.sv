// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
`timescale 1ps/1ps

module top_tb;

    //------------------------------------------------------------------------------------------

parameter TOTAL_CHNL_NUM = 24;
parameter AVMM_CYCLE = 5000;
parameter SPI_CYCLE = 10000;
parameter OSC_CYCLE  = 1000;
//parameter FWD_CYCLE  = 500;

parameter PAD_NUM_LO  = 96;
parameter PAD_NUM_HI  = 102;

`include "top_tb_declare.inc"
`include "agent.sv"
`include "spi_task.sv"

//------------------------------------------------------------------------------------------
// Clock generation.
//------------------------------------------------------------------------------------------

    always #(AVMM_CYCLE/2) avmm_clk = ~avmm_clk;

    always #(SPI_CYCLE/2) spi_clk = ~spi_clk;

    always #(OSC_CYCLE/2)  osc_clk  = ~osc_clk;


    //-----------------------------------------------------------------------------------------
    // Mac Interface instantiation

    //-----------------------------------------------------------------------------------------
    dut_if_mac #(.DWIDTH (40)) intf_m1 (.wr_clk(p1_wr_clk), .rd_clk(p1_rd_clk), .fwd_clk(p1_fwd_clk), .osc_clk(osc_clk));
    dut_if_mac #(.DWIDTH (40)) intf_s1 (.wr_clk(p1_wr_clk), .rd_clk(p1_rd_clk), .fwd_clk(p1_fwd_clk), .osc_clk(osc_clk));
    dut_if_mac #(.DWIDTH (40)) intf_m2 (.wr_clk(p2_wr_clk), .rd_clk(p2_rd_clk), .fwd_clk(p2_fwd_clk), .osc_clk(osc_clk));
    dut_if_mac #(.DWIDTH (40)) intf_s2 (.wr_clk(p2_wr_clk), .rd_clk(p2_rd_clk), .fwd_clk(p2_fwd_clk), .osc_clk(osc_clk));

    //-----------------------------------------------------------------------------------------
    // SPI DUT Instantiation 
    //-----------------------------------------------------------------------------------------

    //-----------------------------------------------------------------------------------------
    // Test configuration is driven from avmm_if_mspi
    //-----------------------------------------------------------------------------------------
    avalon_mm_if #(.AVMM_WIDTH (32), .BYTE_WIDTH (4)) avmm_if_mspi  (
     .clk    (avmm_clk)
    );

    //-----------------------------------------------------------------------------------------
    // AVMM interface connect between slave SPI and AIB dut_master1 (aka AIB leader) 
    //-----------------------------------------------------------------------------------------
    avalon_mm_if #(.AVMM_WIDTH (32), .BYTE_WIDTH (4)) avmm_if_sspi0  (
     .clk    (avmm_clk)
    );

    //-----------------------------------------------------------------------------------------
    // AVMM interface connect between slave SPI and AIB dut_master2 (aka AIB leader)
    //-----------------------------------------------------------------------------------------

    avalon_mm_if #(.AVMM_WIDTH (32), .BYTE_WIDTH (4)) avmm_if_sspi1  (
     .clk    (avmm_clk)
    );

    //-----------------------------------------------------------------------------------------
    // AVMM interface connect between slave SPI and AIB dut_slave2 (aka AIB follower)
    //-----------------------------------------------------------------------------------------

    avalon_mm_if #(.AVMM_WIDTH (32), .BYTE_WIDTH (4)) avmm_if_sspi2  (
     .clk    (avmm_clk)
    );


    //-----------------------------------------------------------------------------------------
    // SPI interface connect between spi_master and spi_slave 
    // In addition, spi_master connects to second spi_slave dut_sspi_1.
    //-----------------------------------------------------------------------------------------
    spi_if  spi_if  (
    );

    spi_master dut_mspi (
        `include "dut_mspi_port_ch.inc"
    );

    spi_slave dut_sspi (
        `include "dut_sspi_port_ch.inc"
    );

    spi_slave dut_sspi_1 (
        `include "dut_sspi_1_port_ch.inc"
    );

    //-----------------------------------------------------------------------------------------
    // DUT instantiation
    // dut ms2 (leader) and dut sl2 (follower) pair togather
    //-----------------------------------------------------------------------------------------

    parameter DATAWIDTH      = 40;
    aib_model_top  #(.DATAWIDTH(DATAWIDTH)) dut_master2 (
        `include "dut_ms2_port.inc"
     );
    aib_model_top  #(.DATAWIDTH(DATAWIDTH)) dut_slave2 (
        `include "dut_sl2_port.inc"
     );
    //-----------------------------------------------------------------------------------------
    //  dut ms1 and dut sl1 pair togather
    //-----------------------------------------------------------------------------------------

    aib_model_top  #(.DATAWIDTH(DATAWIDTH)) dut_master1 (
        `include "dut_ms1_port.inc"
     );

    maib_top dut_slave1 (
        `include "dut_sl_gen1.inc"
       );
    //-----------------------------------------------------------------------------------------
    // FPGA MAIB configuration is through maib_prog.inc. All other three dut is through SPI to
    // avmm interface programming 
    //-----------------------------------------------------------------------------------------
    initial begin
    @(posedge dut_slave1.config_done);
    `include "../test/data/maib_prog.inc"
    end
    //----------------------------------------------------------------------------------------- 
    // 24 channel Embedded Multi-Die Interconnect Bridge (EMIB) For future use
    // p1: pair one is connect AIB bump between FPGA and dut_ms1 (emib_m2s1 means slave is MAIB, 
    //     master is AIB2.0
    // p2: pair two. connect AIB bump between AIB2.0 model.
    //-----------------------------------------------------------------------------------------

    emib_m2s1 dut_emib_p1 (
        `include "dut_emib1.inc"
       );
    emib_m2s2 dut_emib_p2 (
        `include "dut_emib2.inc"
       );

   //---------------------------------------------------------------------------
   // DUMP
   //---------------------------------------------------------------------------
`ifdef VCS
   initial
   begin
     $vcdpluson;
   end
`endif
   `include "test.inc"

endmodule 
