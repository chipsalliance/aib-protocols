// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: AIB model instantiation
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////

integer i_m1, i_s1;
parameter WR_CYCLE   = 1000;
parameter RD_CYCLE   = 1000;
parameter FWD_CYCLE  = 500;

always #(WR_CYCLE/2)   ms_wr_clk   = ~ms_wr_clk;
always #(RD_CYCLE/2)   ms_rd_clk   = ~ms_rd_clk;
always #(FWD_CYCLE/2)  ms_fwd_clk  = ~ms_fwd_clk;

always #(WR_CYCLE/2)   sl_wr_clk   = ~sl_wr_clk;
always #(RD_CYCLE/2)   sl_rd_clk   = ~sl_rd_clk;
always #(FWD_CYCLE/2)  sl_fwd_clk  = ~sl_fwd_clk;

  initial begin
    begin
      status = "Reset DUT";
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t: AIB : Get into Main initial", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");
      reset_duts ();
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t: AIB : Finish reset_duts", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("\n//                                                                       ///");
      $display("%0t: AIB :  set to 2xFIFO mode for ms -> sl and sl -> ms 24 channel testing", $time);
      $display("\n//                                                                       ///");
      $display("%0t: AIB : No dbi enabled", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      fork
 
        for (i_m1=0; i_m1<24; i_m1++) begin
            avmm_if_m1.cfg_write({i_m1,11'h208}, 4'hf, 32'h0600_0000);
            avmm_if_m1.cfg_write({i_m1,11'h210}, 4'hf, 32'h0000_0023);      
            avmm_if_m1.cfg_write({i_m1,11'h218}, 4'hf, 32'h60a4_0000);
/*
            avmm_if_m1.cfg_write({i_m1,11'h21c}, 4'hf, 32'h0000_0000);
            avmm_if_m1.cfg_write({i_m1,11'h31c}, 4'hf, 32'h0000_0000);
            avmm_if_m1.cfg_write({i_m1,11'h320}, 4'hf, 32'h0000_0000);
            avmm_if_m1.cfg_write({i_m1,11'h324}, 4'hf, 32'h0000_0000);
            avmm_if_m1.cfg_write({i_m1,11'h328}, 4'hf, 32'h0000_0000);
*/
        end
        for (i_s1=0; i_s1<24; i_s1++) begin
            avmm_if_s1.cfg_write({i_s1,11'h208}, 4'hf, 32'h0600_0000);
            avmm_if_s1.cfg_write({i_s1,11'h210}, 4'hf, 32'h0000_0023);
            avmm_if_s1.cfg_write({i_s1,11'h218}, 4'hf, 32'h60a4_0000);
/*
            avmm_if_s1.cfg_write({i_s1,11'h21c}, 4'hf, 32'h0000_0000);
            avmm_if_s1.cfg_write({i_s1,11'h31c}, 4'hf, 32'h0000_0000);
            avmm_if_s1.cfg_write({i_s1,11'h320}, 4'hf, 32'h0000_0000);
            avmm_if_s1.cfg_write({i_s1,11'h324}, 4'hf, 32'h0000_0000);
            avmm_if_s1.cfg_write({i_s1,11'h328}, 4'hf, 32'h0000_0000);
*/
        end

      join

      ms1_tx_fifo_mode = 2'b01;
      sl1_tx_fifo_mode = 2'b01;
      ms1_rx_fifo_mode = 2'b01;
      sl1_rx_fifo_mode = 2'b01;
      ms1_tx_markbit   = 5'b00100;
      sl1_tx_markbit   = 5'b00100;
      ms1_gen1 = 1'b0;
      sl1_gen1 = 1'b0;
      ms1_lpbk = 1'b0;
      sl1_lpbk = 1'b0;
      ms1_dbi_en = 1'b0;
      sl1_dbi_en = 1'b0;


      run_for_n_pkts_ms1 = 40;
      run_for_n_pkts_sl1 = 40;

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t: AIB: Performing duts_wakeup", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      duts_wakeup ();
      status = "Waiting for link up";

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t: AIB: Waiting for link up", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      link_up ();
    
    end
  end
