// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.

////////////////////////////////////////////////////////////////////////////
// This test covers all SPI basic commands:
//      SPI REG Write
//      SPI REG Read
//      SPI BUFFER Write
//      SPI Auto Write
//      SPI Auto Read
//      SPI BUFFER Read
//      SPI REG Write to another SPI slave_1
//      SPI REG read to another SPI slave_1
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
      $display("\n//                                                                       ///");
      $display("%0t: set to 4xFIFO mode for ms -> sl and sl -> ms, 24 channel testing", $time);
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
      avmm_if_mspi.cfg_write(17'h208, 4'hf, 32'h0017_0800);   //hex 17 is decimal 23 (24-1)
      avmm_if_mspi.cfg_write(17'h20c, 4'hf, 32'hdead_beef);

      //Programm command register
      avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h0000_000d);
      avmm_if_mspi.cfg_read (17'h000, 4'hf, rdata_reg);

     // @(posedge top_tb.dut_mspi.spi_inta);
      status = " SPI test1 REG Write Polling ";
      master_polling ();
    //  avmm_if_mspi.cfg_read (17'h000, 4'hf, rdata_reg);
      status = " SPI test1 REG Write Done";

 
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI test2 REG Read", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");
      status = " SPI test2 REG Read ";
      //Programm write buffer first. Slave read command.
      avmm_if_mspi.cfg_write(17'h200, 4'hf, 32'h0000_0000);
      //Programm command register. The read/write bit does not matter.
      avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h0000_000d);
      master_polling ();
      status = " SPI master REG Read from read buffer";
      //Read back slave registers from read buffer
      for (int i=0; i<4; i++) begin
          if (i==0 | i==1) expect_value = 32'h00800200;
          else if (i==2)   expect_value = 32'h00170800;
          else             expect_value = 32'hdeadbeef;
          avmm_if_mspi.cfg_read ((17'h1000 + i*4), 4'hf, rdata_reg);
          if (rdata_reg !== expect_value) begin
              err_count++;
              $display ("[%t] DATA COMPARE ERROR: received = %x | expected = %x\n", $time, rdata_reg, expect_value);
          end
      end
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI test2 REG Read finished", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI test3 Buffer Write", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");
      status = " SPI test1 Buffer Write ";
      avmm_if_mspi.cfg_write(17'h200, 4'hf, {4'h3, 9'h0, 19'h000}); //Here base address is don't care
      avmm_if_mspi.cfg_write(17'h204, 4'hf, 32'haaaa_aaaa);
      avmm_if_mspi.cfg_write(17'h208, 4'hf, 32'hbbbb_bbbb);
      avmm_if_mspi.cfg_write(17'h20c, 4'hf, 32'hcccc_cccc);

      avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h0000_000d); //spi master burst_len is bit[15:2]
      avmm_if_mspi.cfg_read (17'h000, 4'hf, rdata_reg);
      master_polling ();
      status = " Buffer Write Finished ";

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI test4 Auto Run Write", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");
      status = " Auto Write 208 32'h0600_0000 for 24 channel ";
      //Eq avmm_if_m1.cfg_write(17'h208, 4'hf, 32'h0600_0000) 
      avmm_if_mspi.cfg_write(17'h200, 4'hf, 32'h7000_0208);
      avmm_if_mspi.cfg_write(17'h204, 4'hf, 32'h0600_0000); //Write spim wbuf

      avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h0000_0005); //burst_len is bit[15:2]
    //@(posedge top_tb.dut_mspi.spi_inta);
      master_polling ();              //Check if write command/data has been sent to slave
      slave_polling ();                //Make sure  Slave is idle.


      #500ns;

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI test5 Auto Run Write Burst", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");
      status = " Auto Write 4 burst for 24 channel ";
      avmm_if_mspi.cfg_write(17'h200, 4'hf, {4'h7, 9'h3, 19'h31c}); //{4'h7, 9'h3, 19'h31c}
      avmm_if_mspi.cfg_write(17'h204, 4'hf, 32'haaaa_bbbb); //Write spim wbuf
      avmm_if_mspi.cfg_write(17'h208, 4'hf, 32'hcccc_dddd); //Write spim wbuf
      avmm_if_mspi.cfg_write(17'h20c, 4'hf, 32'heeee_ffff); //Write spim wbuf
      avmm_if_mspi.cfg_write(17'h210, 4'hf, 32'h5555_6666); //Write spim wbuf

      avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h0000_0011); //burst_len is bit[15:2]
    //@(posedge top_tb.dut_mspi.spi_inta);
      master_polling ();              //Check if write command/data has been sent to slave
      slave_polling ();                //Make sure  Slave is idle.


/*    Eq avmm write of the following:
      avmm_if_m1.cfg_write({i_m1,11'h31c}, 4'hf, 32'haaaa_bbbb);
      avmm_if_m1.cfg_write({i_m1,11'h320}, 4'hf, 32'hcccc_dddd);
      avmm_if_m1.cfg_write({i_m1,11'h324}, 4'hf, 32'heeee_ffff);
      avmm_if_m1.cfg_write({i_m1,11'h328}, 4'hf, 32'h5555_6666);

*/

      #1000ns;
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI test6 Auto Run Read For 24 channel", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      //Eq avmm_if_m1.cfg_read(17'h208, 4'hf, rdata_reg);
/*    Eq avmm read of the following:
      avmm_if_m1.cfg_write({i_m1,11'h31c}, 4'hf, 32'haaaa_bbbb);
      avmm_if_m1.cfg_write({i_m1,11'h320}, 4'hf, 32'hcccc_dddd);
      avmm_if_m1.cfg_write({i_m1,11'h324}, 4'hf, 32'heeee_ffff);
      avmm_if_m1.cfg_write({i_m1,11'h328}, 4'hf, 32'h5555_6666);

*/
      status = " Auto burst read for 24 channel ";
      avmm_if_mspi.cfg_write(17'h200, 4'hf, {4'h6, 9'h3, 19'h31c}); 
      avmm_if_mspi.cfg_write(17'h000, 4'hf, {16'h0, 14'h61, 2'h1}); //burst 4 x 24 channel + 2 dummy= h61 
      master_polling ();              //Check if write command/data has been sent to slave
//    @(posedge top_tb.dut_mspi.spi_inta);
      for (int i=0; i<13; i++) begin
             avmm_if_mspi.cfg_read ((17'h1000 + i*4), 4'hf, rdata_reg);
      end
      status = " End of Auto burst read for 24 channel ";

      #1000ns;
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI test7 Buffer Read ", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      status = " Buffer Read Test ";
      avmm_if_mspi.cfg_write(17'h200, 4'hf, {4'h2, 9'h0, 19'h0});
      avmm_if_mspi.cfg_write(17'h000, 4'hf, {16'h0, 14'h61, 2'h1}); //Read all buffer content from Auto Read
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

      status = " End of Buffer Read ";

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI test8 REG Write to SPI slave_1", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");
      status = " SPI test8 REG Write to SPI slave_1 ";
      //Programm spi master write buffer first 
      avmm_if_mspi.cfg_write(17'h200, 4'hf, 32'h1000_0000);
      avmm_if_mspi.cfg_write(17'h204, 4'hf, 32'h0080_0200);  
      avmm_if_mspi.cfg_write(17'h208, 4'hf, 32'h0017_0800);   //hex 17 is decimal 23 (24-1)
      avmm_if_mspi.cfg_write(17'h20c, 4'hf, 32'hdead_beef);

      //Programm command register
      avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h4000_000d);   //Bit 31:30 = 2'b01. Slave 1 has been selected.
      avmm_if_mspi.cfg_read (17'h000, 4'hf, rdata_reg);

     // @(posedge top_tb.dut_mspi.spi_inta);
      status = " SPI test8 REG Write to SPI slave_1 Polling ";
      master_polling ();
    //  avmm_if_mspi.cfg_read (17'h000, 4'hf, rdata_reg);
      status = " SPI test8 REG Write to SPI slave_1 Done";

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI test9 REG Read from SPI slave_1", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");
      status = " SPI test9 REG Read ";
      //Programm write buffer first. Slave read command.
      avmm_if_mspi.cfg_write(17'h200, 4'hf, 32'h0000_0000);
      //Programm command register. The read/write bit does not matter.
      avmm_if_mspi.cfg_write(17'h000, 4'hf, 32'h4000_000d); //Bit 31:30 = 2'b01. Slave 1 has been selected.
      master_polling ();
      status = " SPI master REG Read from read buffer";
      //Read back slave registers from read buffer
      for (int i=0; i<4; i++) begin
          if (i==0 | i==1) expect_value = 32'h00800200;
          else if (i==2)   expect_value = 32'h00170800;
          else             expect_value = 32'hdeadbeef;
          avmm_if_mspi.cfg_read ((17'h1000 + i*4), 4'hf, rdata_reg);
          if (rdata_reg !== expect_value) begin
              err_count++;
              $display ("[%t] DATA COMPARE ERROR: received = %x | expected = %x\n", $time, rdata_reg, expect_value);
          end
      end
      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t:  SPI test9 REG Read finished", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");



      Finish ();
    end
  end
