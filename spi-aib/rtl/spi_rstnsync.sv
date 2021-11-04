// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2019 Intel Corporation. 
//---------------------------------------------------------------------------------------
// Description: For rst_n, asynchronously assertion and sychronously de-assertion (AASD)
// Assumptions: i_rst_n is assumed to be bypassed with scan_clk during scan_mode
//---------------------------------------------------------------------------------------

module spi_rstnsync
  (
    input  logic clk,		// Destination clock of reset to be synced
    input  logic i_rst_n,        // Asynchronous reset input
    input  logic	scan_mode,	// Scan bypass for reset
    output logic sync_rst_n	// Synchronized reset output
   
   );

   logic   first_stg_rst_n;					     
   logic   prescan_sync_rst_n;
   
   always @(posedge clk or negedge i_rst_n)
     if (!i_rst_n)
       first_stg_rst_n <= 1'b0;
     else
       first_stg_rst_n <= 1'b1;

   spi_bitsync 
     #(.DWIDTH(1), .RESET_VAL(0)                      ) 
   i_sync_rst_n
     (
      .clk           (clk               ),
      .rst_n         (i_rst_n           ), 
      .data_in       (first_stg_rst_n   ),
      .data_out      (prescan_sync_rst_n) 
      );

    assign sync_rst_n = scan_mode ? i_rst_n : prescan_sync_rst_n;

      
   endmodule
   
