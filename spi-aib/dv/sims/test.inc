// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.

////////////////////////////////////////////////////////////////////////////
// This test covers:
//      SPI REG Write
//      SPI Auto Write dut_master1, dut_master2, dut_slave2 for 24 channel
//      After SPI configuration all dut (except FPGA which used macro config)
//      Passing traffic for both Pair 1 and Pair 2 AIB PHY and check the result
//      Pair 1: dut_slave1 (FPGA aka follower) and dut_master1 (AIB2.0 model in gen1 mode)
//      Pair 1: dut_slave2 (AIB2.0)  and dut_master2 (AIB2.0)
//      All above AIB PHY was programmed in FIFO2X mode.
////////////////////////////////////////////////////////////////////////////


integer i_m1, i_s1;
parameter WR_CYCLE   = 2000;
parameter RD_CYCLE   = 2000;
parameter FWD_CYCLE  = 1000;

always #(WR_CYCLE/2)   p1_wr_clk   = ~p1_wr_clk;
always #(RD_CYCLE/2)   p1_rd_clk   = ~p1_rd_clk;
always #(FWD_CYCLE/2)  p1_fwd_clk  = ~p1_fwd_clk;

always #(WR_CYCLE/4)   p2_wr_clk   = ~p2_wr_clk;
always #(RD_CYCLE/4)   p2_rd_clk   = ~p2_rd_clk;
always #(FWD_CYCLE/4)  p2_fwd_clk  = ~p2_fwd_clk;
  initial begin
    begin
      status = "Reset DUT";
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t: Get into Main initial", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");
      reset_duts ();
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t: Finish reset_duts", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("\n//                                                                       ///");
      $display("%0t: set pair2 AIB2.0 2xFIFO mode for ms2 <-> sl2  24 channel testing", $time);
      $display("%0t: set pair1 AIB1.0 2xFIFO mode for ms1 <-> sl1 (Gen1 FPGA)  24 channel testing", $time);
      $display("\n//                                                                       ///");
      $display("%0t: No dbi enabled", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");
      /***********************************************************************************
      *The following is what SPI master try to achieve.
      ************************************************************************************

      fork
 
        for (i_m2=0; i_m2<24; i_m2++) begin
            avmm_if_m2.cfg_write({i_m1,11'h208}, 4'hf, 32'h0600_0000);
            avmm_if_m2.cfg_write({i_m1,11'h210}, 4'hf, 32'h0000_0023);      
            avmm_if_m2.cfg_write({i_m1,11'h218}, 4'hf, 32'h60a4_0000);
            avmm_if_m2.cfg_write({i_m1,11'h21c}, 4'hf, 32'h0000_0000);
            avmm_if_m2.cfg_write({i_m1,11'h31c}, 4'hf, 32'h0000_0000);
            avmm_if_m2.cfg_write({i_m1,11'h320}, 4'hf, 32'h0000_0000);
            avmm_if_m2.cfg_write({i_m1,11'h324}, 4'hf, 32'h0000_0000);
            avmm_if_m2.cfg_write({i_m1,11'h328}, 4'hf, 32'h0000_0000);
        end
        for (i_s2=0; i_s2<24; i_s2++) begin
            avmm_if_s2.cfg_write({i_s1,11'h208}, 4'hf, 32'h0600_0000);
            avmm_if_s2.cfg_write({i_s1,11'h210}, 4'hf, 32'h0000_0023);
            avmm_if_s2.cfg_write({i_s1,11'h218}, 4'hf, 32'h60a4_0000);
            avmm_if_s2.cfg_write({i_s1,11'h21c}, 4'hf, 32'h0000_0000);
            avmm_if_s2.cfg_write({i_s1,11'h31c}, 4'hf, 32'h0000_0000);
            avmm_if_s2.cfg_write({i_s1,11'h320}, 4'hf, 32'h0000_0000);
            avmm_if_s2.cfg_write({i_s1,11'h324}, 4'hf, 32'h0000_0000);
            avmm_if_s2.cfg_write({i_s1,11'h328}, 4'hf, 32'h0000_0000);
        end
        for (i_m1=0; i_m1<24; i_m1++) begin
            avmm_if_m1.cfg_write({i_m1,11'h208}, 4'hf, 32'h0600_0000);
            avmm_if_m1.cfg_write({i_m1,11'h210}, 4'hf, 32'h0000_000b);
            avmm_if_m1.cfg_write({i_m1,11'h218}, 4'hf, 32'h60a1_0000);
            avmm_if_m1.cfg_write({i_m1,11'h21c}, 4'hf, 32'h0000_0000);
            avmm_if_m1.cfg_write({i_m1,11'h31c}, 4'hf, 32'h0000_0000);
            avmm_if_m1.cfg_write({i_m1,11'h320}, 4'hf, 32'h0000_0000);
            avmm_if_m1.cfg_write({i_m1,11'h324}, 4'hf, 32'h0000_0000);
            avmm_if_m1.cfg_write({i_m1,11'h328}, 4'hf, 32'h0000_0000);
      end
      join
      *************************************************************************************/

      /***********************************************************************************
      * Program MS1 with from SPI master 
      * Step 1: Program Slave Register cmd0 and cmd1.
      * Step 2: Auto write from 208 - 21c with single write (because they are not continuous.
      * Step 3: Auto write from 31c - 328 with burst write because they are continous.
      *         Becaise the program value is all zeros. Skip it.
      ************************************************************************************/
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI test1 REG Write", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");
      status = " SPI test1 REG Write ";
      //Programm spi master write buffer first 
      avmm_if_mspi.cfg_write(17'h200, 4'hf, 32'h1000_0000);
      avmm_if_mspi.cfg_write(17'h204, 4'hf, 32'h0080_0200);
      avmm_if_mspi.cfg_write(17'h208, 4'hf, 32'h0017_0800);   //hex 17 is decimal 23 (24-1)
      avmm_if_mspi.cfg_write(17'h20c, 4'hf, 32'hdead_beef);

      //Programm command register
      avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h0000_000d);
      avmm_if_mspi.cfg_read (17'h000, 4'hf, rdata_reg);

      status = " SPI test1 REG Write Polling ";
      master_polling ();
      status = " SPI test1 REG Write Done";
      //Program auto write avmm 208 
      status = "auto write avmm 208 for 24 channel";
      sl_single_auto_write(19'h208, 32'h0600_0000);
      status = "auto write avmm 210 for 24 channel";
      sl_single_auto_write(19'h210, 32'h0000_000b); 
      status = "auto write avmm 218 for 24 channel";
      sl_single_auto_write(19'h218, 32'h60a1_0000);

      /***********************************************************************************
      * Program SL2 with from SPI master 
      * Step 1: This step skipped because it has been done.
      * Step 2: Auto write from 208 - 21c with single write (because they are not continuous.
      * Step 3: Auto write from 31c - 328 with burst write because they are continous.
      *         Becaise the program value is all zeros. Skip it.
      ************************************************************************************/
      //Program auto write avmm 208 
      status = "auto write avmm 208 for 24 channel";
      sl_single_auto_write({2'b01,17'h208}, 32'h0600_0000);
      status = "auto write avmm 210 for 24 channel";
      sl_single_auto_write({2'b01,17'h210}, 32'h0000_0023);
      status = "auto write avmm 218 for 24 channel";
      sl_single_auto_write({2'b01,17'h218}, 32'h60a4_0000);

      /***********************************************************************************
      * Program MS2 with from SPI master 
      * Step 1: This step skipped because it has been done.
      * Step 2: Auto write from 208 - 21c with single write (because they are not continuous.
      * Step 3: Auto write from 31c - 328 with burst write because they are continous.
      *         Becaise the program value is all zeros. Skip it.
      ************************************************************************************/
      //Program auto write avmm 208 
      status = "auto write avmm 208 for 24 channel";
      sl_single_auto_write({2'b10,17'h208}, 32'h0600_0000);
      status = "auto write avmm 210 for 24 channel";
      sl_single_auto_write({2'b10,17'h210}, 32'h0000_0023);
      status = "auto write avmm 218 for 24 channel";
      sl_single_auto_write({2'b10,17'h218}, 32'h60a4_0000);

      
      /* Pair 1 setting                 */
      ms1_tx_fifo_mode = 2'b01;
      sl1_tx_fifo_mode = 2'b01;
      ms1_rx_fifo_mode = 2'b01;
      sl1_rx_fifo_mode = 2'b01;
      ms1_tx_markbit   = 5'b00001;
      sl1_tx_markbit   = 5'b00001;
      ms1_gen1 = 1'b0;
      sl1_gen1 = 1'b1;
      ms1_lpbk = 1'b0;
      sl1_lpbk = 1'b0;
      ms1_dbi_en = 1'b0;
      sl1_dbi_en = 1'b0;
      run_for_n_pkts_ms1 = 40;
      run_for_n_pkts_sl1 = 40;

      /* Pair 2 setting                 */
      ms2_tx_fifo_mode = 2'b01;
      sl2_tx_fifo_mode = 2'b01;
      ms2_rx_fifo_mode = 2'b01;
      sl2_rx_fifo_mode = 2'b01;
      ms2_tx_markbit   = 5'b00100;
      sl2_tx_markbit   = 5'b00100;
      ms2_gen1 = 1'b0;
      sl2_gen1 = 1'b0;
      ms2_lpbk = 1'b0;
      sl2_lpbk = 1'b0;
      ms2_dbi_en = 1'b0;
      sl2_dbi_en = 1'b0;
      run_for_n_pkts_ms2 = 40;
      run_for_n_pkts_sl2 = 40;

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t: Performing duts_wakeup", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      duts_wakeup ();
      status = "Waiting for link up";

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t: Waiting for link up", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      link_up ();
      status = "Starting data transmission";

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t: Starting data transmission", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");
      
      fork
      /* Pair 1 traffic running */
         ms1_gen1toaib1_f2f_xmit ();
         sl1_aib1togen1_f2f_xmit ();
         ms1_gen1_fifomod_rcv ();
         sl1_aib1_fifomod_rcv ();

      /* Pair 2 traffic running */
         ms2_aib2_f2f_s_xmit ();
         ms2_aib2_fifomod_rcv ();
         sl2_aib2_f2f_s_xmit ();
         sl2_aib2_fifomod_rcv ();
      join

      status = "Finishing data transmission";
      Finish ();
    end
  end
