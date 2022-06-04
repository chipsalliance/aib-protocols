integer i_m1, i_s1;

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
      $display("%0t: AIB : set to 2xFIFO mode for ms -> sl and sl -> ms 24 channel testing", $time);
      $display("%0t: AIB : Master is 2.0 AIB model in Gen1 mode", $time);
      $display("%0t: AIB : Slave is 1.0 FPGA", $time);
      $display("\n//                                                                       ///");
      $display("%0t: No dbi enabled", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

 
      for (i_m1=0; i_m1<2; i_m1++) begin
          avmm_if_m1.cfg_write({i_m1,11'h208}, 4'hf, 32'h0600_0000);
          avmm_if_m1.cfg_write({i_m1,11'h210}, 4'hf, 32'h0000_000b);      
          avmm_if_m1.cfg_write({i_m1,11'h218}, 4'hf, 32'h60a1_0000);
          avmm_if_m1.cfg_write({i_m1,11'h21c}, 4'hf, 32'h0000_0000);
          avmm_if_m1.cfg_write({i_m1,11'h31c}, 4'hf, 32'h0000_0000);
          avmm_if_m1.cfg_write({i_m1,11'h320}, 4'hf, 32'h0000_0000);
          avmm_if_m1.cfg_write({i_m1,11'h324}, 4'hf, 32'h0000_0000);
          avmm_if_m1.cfg_write({i_m1,11'h328}, 4'hf, 32'h0000_0000);
      end

      ms1_tx_fifo_mode = 2'b01;
      sl1_tx_fifo_mode = 2'b01;
      ms1_rx_fifo_mode = 2'b01;
      sl1_rx_fifo_mode = 2'b01;
      ms1_tx_markbit   = 5'b00001;
      sl1_tx_markbit   = 5'b00001;
      ms1_gen1         = 1'b0;
      sl1_gen1         = 1'b1;

      run_for_n_pkts_ms1 = 40;
      run_for_n_pkts_sl1 = 40;

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t: AIB : Performing duts_wakeup", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      duts_wakeup ();
      status = "Waiting for link up";

      $display("\n////////////////////////////////////////////////////////////////////////////");
      $display("%0t: AIB : Waiting for link up", $time);
      $display("////////////////////////////////////////////////////////////////////////////\n");

      link_up ();
       status = "Starting data transmission"; 

       $display("\n////////////////////////////////////////////////////////////////////////////"); 
       $display("%0t: AIB : Starting data transmission", $time); 
       $display("////////////////////////////////////////////////////////////////////////////\n"); 
      

      status = "Finishing data transmission";
    end
  end
