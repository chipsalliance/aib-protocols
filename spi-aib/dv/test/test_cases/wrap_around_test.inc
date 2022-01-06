// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.

////////////////////////////////////////////////////////////////////////////
// This test covers Application Register write read test:
// Auto write 256 entry and Auto Read back 256 test.
// Test overflow condition
////////////////////////////////////////////////////////////////////////////
`define APP_REG 1

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
logic [31:0] expect_value;

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
      $display("\n//                                                                       ///");
      $display("\n//                                                                       ///");
      $display("%0t: No dbi enabled", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t: Performing master SPI programming", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI test REG Write", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");
      status = " SPI test REG Write ";
      //Programm spi master write buffer first 
      avmm_if_mspi.cfg_write(17'h200, 4'hf, 32'h1000_0000);
      avmm_if_mspi.cfg_write(17'h204, 4'hf, 32'h0080_0200);
      avmm_if_mspi.cfg_write(17'h208, 4'hf, 32'h0000_0000);   //hex 17 is decimal 23 (24-1)
      avmm_if_mspi.cfg_write(17'h20c, 4'hf, 32'hdead_beef);

      //Programm command register
      avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h0000_000d);
      avmm_if_mspi.cfg_read (17'h000, 4'hf, rdata_reg);

     // @(posedge top_tb.dut_mspi.spi_inta);
      status = " SPI test REG Write Polling ";
      master_polling ();
    //  avmm_if_mspi.cfg_read (17'h000, 4'hf, rdata_reg);
      status = " SPI test REG Write Done";


      #500ns;

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI test Auto Run Write Burst", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");
      status = " Auto Write 256 burst for user control ";
      avmm_if_mspi.cfg_write(17'h200, 4'hf, {4'h7, 9'hff, 19'h200}); //{4'h7, 9'h3, 19'h31c}
      for (int i=0; i<256; i++) begin
        avmm_if_mspi.cfg_write((17'h204 + i*4), 4'hf, i);   
      end

      avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h0000_0401); //burst_len is bit[15:2]
    //@(posedge top_tb.dut_mspi.spi_inta);
      master_polling ();              //Check if write command/data has been sent to slave
      slave_polling ();                //Make sure  Slave is idle.


      #1000ns;
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI test Auto Run Read ", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      //Eq avmm_if_m1.cfg_read(17'h208, 4'hf, rdata_reg);
      status = " Auto burst read ";
      avmm_if_mspi.cfg_write(17'h200, 4'hf, {4'h6, 9'hff, 19'h200});
      avmm_if_mspi.cfg_write(17'h000, 4'hf, {16'h0, 14'h102, 2'h1}); //burst 256  + 2 dummy= h6 
      master_polling ();              //Check if write command/data has been sent to slave
//    @(posedge top_tb.dut_mspi.spi_inta);
      for (int i=0; i<256; i++) begin
           avmm_if_mspi.cfg_read ((17'h1008 + i*4), 4'hf, rdata_reg);
           expect_value = i;
          if ((rdata_reg !== expect_value)) begin
              err_count++;
              $display ("[%t] DATA COMPARE ERROR: received = %x | expected = %x\n", $time, rdata_reg, expect_value);
          end

      end
      status = " End of Auto burst read ";

      Finish ();
    end
  end
