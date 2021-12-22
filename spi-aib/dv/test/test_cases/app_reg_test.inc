// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.

////////////////////////////////////////////////////////////////////////////
// This test covers Application Register write read test:
//      No traffic run in this test case
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
      $display("%0t:  SPI test1 REG Write", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");
      status = " SPI test1 REG Write ";
      //Programm spi master write buffer first 
      avmm_if_mspi.cfg_write(17'h200, 4'hf, 32'h1000_0000);
      avmm_if_mspi.cfg_write(17'h204, 4'hf, 32'h0080_0200);
      avmm_if_mspi.cfg_write(17'h208, 4'hf, 32'h0000_0000);   //hex 17 is decimal 23 (24-1)
      avmm_if_mspi.cfg_write(17'h20c, 4'hf, 32'hdead_beef);

      //Programm command register
      avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h0000_000d);
      avmm_if_mspi.cfg_read (17'h000, 4'hf, rdata_reg);

     // @(posedge top_tb.dut_mspi.spi_inta);
      status = " SPI test1 REG Write Polling ";
      master_polling ();
    //  avmm_if_mspi.cfg_read (17'h000, 4'hf, rdata_reg);
      status = " SPI test1 REG Write Done";


      #500ns;

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI test2 Auto Run Write Burst", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");
      status = " Auto Write 4 burst for user control ";
      avmm_if_mspi.cfg_write(17'h200, 4'hf, {4'h7, 9'h3, 19'h200}); //{4'h7, 9'h3, 19'h31c}
      avmm_if_mspi.cfg_write(17'h204, 4'hf, 32'haaaa_bbbb); //Write spim wbuf
      avmm_if_mspi.cfg_write(17'h208, 4'hf, 32'hcccc_dddd); //Write spim wbuf
      avmm_if_mspi.cfg_write(17'h20c, 4'hf, 32'heeee_ffff); //Write spim wbuf
      avmm_if_mspi.cfg_write(17'h210, 4'hf, 32'h5555_6666); //Write spim wbuf

      avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h0000_0011); //burst_len is bit[15:2]
    //@(posedge top_tb.dut_mspi.spi_inta);
      master_polling ();              //Check if write command/data has been sent to slave
      slave_polling ();                //Make sure  Slave is idle.


/*    Eq avmm write of the following:
      avmm_if_m1.cfg_write({i_m1,11'h200}, 4'hf, 32'haaaa_bbbb);
      avmm_if_m1.cfg_write({i_m1,11'h204}, 4'hf, 32'hcccc_dddd);
      avmm_if_m1.cfg_write({i_m1,11'h208}, 4'hf, 32'heeee_ffff);
      avmm_if_m1.cfg_write({i_m1,11'h20c}, 4'hf, 32'h5555_6666);

*/
      #1000ns;
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI test6 Auto Run Read ", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      //Eq avmm_if_m1.cfg_read(17'h208, 4'hf, rdata_reg);
/*    Eq avmm read of the following:
      avmm_if_m1.cfg_read({i_m1,11'h200}, 4'hf, 32'haaaa_bbbb);
      avmm_if_m1.cfg_read({i_m1,11'h204}, 4'hf, 32'hcccc_dddd);
      avmm_if_m1.cfg_read({i_m1,11'h208}, 4'hf, 32'heeee_ffff);
      avmm_if_m1.cfg_read({i_m1,11'h20c}, 4'hf, 32'h5555_6666);

*/
      status = " Auto burst read ";
      avmm_if_mspi.cfg_write(17'h200, 4'hf, {4'h6, 9'h3, 19'h200});
      avmm_if_mspi.cfg_write(17'h000, 4'hf, {16'h0, 14'h6, 2'h1}); //burst 4  + 2 dummy= h6 
      master_polling ();              //Check if write command/data has been sent to slave
//    @(posedge top_tb.dut_mspi.spi_inta);
      for (int i=0; i<6; i++) begin
           avmm_if_mspi.cfg_read ((17'h1000 + i*4), 4'hf, rdata_reg);
           if      (i==2)   expect_value = 32'haaaa_bbbb;
           else if (i==3)   expect_value = 32'hcccc_dddd;
           else if (i==4)   expect_value = 32'heeee_ffff;
           else if (i==5)   expect_value = 32'h5555_6666;
          avmm_if_mspi.cfg_read ((17'h1000 + i*4), 4'hf, rdata_reg);
          if ((rdata_reg !== expect_value) && (i>1)) begin
              err_count++;
              $display ("[%t] DATA COMPARE ERROR: received = %x | expected = %x\n", $time, rdata_reg, expect_value);
          end

      end
      status = " End of Auto burst read ";


      #1000ns;
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI test6 Auto Run Read ", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      //Eq avmm_if_m1.cfg_read(17'h208, 4'hf, rdata_reg);
/*    Eq avmm read of the following:
      avmm_if_m1.cfg_write({i_m1,11'h1000}, 4'hf, 32'h0000_1111);
      avmm_if_m1.cfg_write({i_m1,11'h1004}, 4'hf, 32'h0000_2222);
      avmm_if_m1.cfg_write({i_m1,11'h1008}, 4'hf, 32'h0000_3333);
      avmm_if_m1.cfg_write({i_m1,11'h100c}, 4'hf, 32'h0000_4444);

*/
      status = " Auto burst read ";
      avmm_if_mspi.cfg_write(17'h200, 4'hf, {4'h6, 9'h3, 19'h1000}); 
      avmm_if_mspi.cfg_write(17'h000, 4'hf, {16'h0, 14'h6, 2'h1}); //burst 4  + 2 dummy= h6 
      master_polling ();              //Check if write command/data has been sent to slave
//    @(posedge top_tb.dut_mspi.spi_inta);
      for (int i=0; i<6; i++) begin
           avmm_if_mspi.cfg_read ((17'h1000 + i*4), 4'hf, rdata_reg);
           if      (i==2)   expect_value = 32'h0000_1111;
           else if (i==3)   expect_value = 32'h0000_2222;
           else if (i==4)   expect_value = 32'h0000_3333;
           else if (i==5)   expect_value = 32'h0000_4444;
          if ((rdata_reg !== expect_value) && (i>1)) begin
              err_count++;
              $display ("[%t] DATA COMPARE ERROR: received = %x | expected = %x\n", $time, rdata_reg, expect_value);
          end
 
      end
      status = " End of Auto burst read ";

      Finish ();
    end
  end
