// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.

////////////////////////////////////////////////////////////////////////////
// This test is modified from basic_spi_test.inc. 
// Demonstrate how to use multi-step configuration to achieve what one step 
// AUTO Read/AUTO Write.Although this scheme is not recommended, we add test 
// case here for user to follow Chiplet_SPI_User_guide_v1.0.pdf section 3.12
// Write to Target Sequence and section 3.13 Read from Target Sequence.
// only for debug purpose.
//      SPI REG Write
//      SPI Auto Write     -- Replaced with Non-Auto Write procedure
//      SPI Auto Read      -- Replaced with Non-Auto Read procedure
//      No traffic run in this test case
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
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("////////////////////////////////////////////////////////////////////////////\n");

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t: Performing master SPI programming", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI REG Write", $time);
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

     // @(posedge top_tb.dut_mspi.spi_inta);
      status = " SPI REG Write Polling ";
      master_polling ();
    //  avmm_if_mspi.cfg_read (17'h000, 4'hf, rdata_reg);
      status = " SPI REG Write Done";

      #500ns;

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t: Equivalent of  SPI  Auto Run Write Burst", $time);
/*    Eq avmm write of the following:
      avmm_if_m1.cfg_write({i_m1,11'h31c}, 4'hf, 32'haaaa_bbbb);
      avmm_if_m1.cfg_write({i_m1,11'h320}, 4'hf, 32'hcccc_dddd);
      avmm_if_m1.cfg_write({i_m1,11'h324}, 4'hf, 32'heeee_ffff);
      avmm_if_m1.cfg_write({i_m1,11'h328}, 4'hf, 32'h5555_6666);
*/
/*    $display("////////////////////////////////////////////////////////////////////////////\n");
      status = " Auto Write 4 burst for 24 channel ";
      avmm_if_mspi.cfg_write(17'h200, 4'hf, {4'h7, 9'h3, 19'h31c}); //{4'h7, 9'h3, 19'h31c}
      avmm_if_mspi.cfg_write(17'h204, 4'hf, 32'haaaa_bbbb); //Write spim wbuf
      avmm_if_mspi.cfg_write(17'h208, 4'hf, 32'hcccc_dddd); //Write spim wbuf
      avmm_if_mspi.cfg_write(17'h20c, 4'hf, 32'heeee_ffff); //Write spim wbuf
      avmm_if_mspi.cfg_write(17'h210, 4'hf, 32'h5555_6666); //Write spim wbuf

      avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h0000_0011); //burst_len is bit[15:2]
      master_polling ();              //Check if write command/data has been sent to slave
      slave_polling ();                //Make sure  Slave is idle.
*/
      
      status = " Write Buffer with data first ";
      avmm_if_mspi.cfg_write(17'h200, 4'hf, {4'h3, 9'h0, 19'h000}); //Here base address is don't care
      avmm_if_mspi.cfg_write(17'h204, 4'hf, 32'haaaa_bbbb);
      avmm_if_mspi.cfg_write(17'h208, 4'hf, 32'hcccc_dddd);
      avmm_if_mspi.cfg_write(17'h20c, 4'hf, 32'heeee_ffff);
      avmm_if_mspi.cfg_write(17'h210, 4'hf, 32'h5555_6666);

      avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h0000_0011); //spi master burst_len is bit[15:2]
      avmm_if_mspi.cfg_read (17'h000, 4'hf, rdata_reg);
      master_polling ();
      status = " Buffer Write Finished ";
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  Buffer Write Done ", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      #100ns;

      status = " Program Follower Command Register 0 ";
      avmm_if_mspi.cfg_write(17'h200, 4'hf, 32'h1000_0000);
      avmm_if_mspi.cfg_write(17'h204, 4'hf, {2'b0, 9'h3, 19'h31c, 2'b01});
      
      avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h0000_0005);
      avmm_if_mspi.cfg_read (17'h000, 4'hf, rdata_reg);
      master_polling ();
      slave_polling ();

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI AVMM Burst Write for 24 Channel Finished ", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      #1000ns;
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI Equilvalent of Auto Run Read For 24 channel", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      //Eq avmm_if_m1.cfg_read(17'h208, 4'hf, rdata_reg);
/*    Eq avmm read of the following:
      avmm_if_m1.cfg_write({i_m1,11'h31c}, 4'hf, 32'haaaa_bbbb);
      avmm_if_m1.cfg_write({i_m1,11'h320}, 4'hf, 32'hcccc_dddd);
      avmm_if_m1.cfg_write({i_m1,11'h324}, 4'hf, 32'heeee_ffff);
      avmm_if_m1.cfg_write({i_m1,11'h328}, 4'hf, 32'h5555_6666);

*/
      
      status = "Program Follower Command Register 0  ";

      avmm_if_mspi.cfg_write(17'h200, 4'hf, 32'h1000_0000);
      avmm_if_mspi.cfg_write(17'h204, 4'hf, {2'b0, 9'h3, 19'h31c, 2'b11});
      
      avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h0000_0005);
      avmm_if_mspi.cfg_read (17'h000, 4'hf, rdata_reg);
      master_polling ();
      slave_polling ();

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI AVMM Burst Read for 24 Channel Finished ", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");
      status = "Perform Buffer Read and fetch data to Leader Read Buffer";
 
      avmm_if_mspi.cfg_write(17'h200, 4'hf, {4'h2, 9'h0, 19'h0}); 
      avmm_if_mspi.cfg_write(17'h000, 4'hf, {16'h0, 14'h61, 2'h1}); //burst 4 x 24 channel + 2 dummy= h61 
      master_polling ();              //Check if write command/data has been sent to slave

      for (int i=1; i<97; i++) begin
        if      ((i % 4)==1) expect_value = 32'haaaabbbb;
        else if ((i % 4)==2) expect_value = 32'hccccdddd; 
        else if ((i % 4)==3) expect_value = 32'heeeeffff; 
        else                 expect_value = 32'h55556666; 

        avmm_if_mspi.cfg_read ((17'h1000 + i*4), 4'hf, rdata_reg);

        if (rdata_reg !== expect_value) begin
              err_count++;
              $display ("[%t] DATA COMPARE ERROR: received = %x | expected = %x\n", $time, rdata_reg, expect_value);
        end
      end


      status = " End of burst read for 24 channel ";
      Finish ();
    end
  end
