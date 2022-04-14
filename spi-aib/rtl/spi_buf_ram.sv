// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2019 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: SPI simple dual port synchronous ram
// This code will work with Quartus tool. For other vendor, different structure may required
// Change log
// 08/09/2021
/////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ps / 1ps
module spi_buf_ram
  #(
    parameter DWIDTH  = 32,            // buffer Input data width 
    parameter DEPTH = 256,              // buffer depth. change ADWIDTH & DEPTH at same time
    parameter ADWIDTH = $clog2(DEPTH)    // buffer address width
    )
(
    input  wire                wr_clk,     // Write Domain Clock
    input  wire                wr_en,      // Write Data Enable
    input  wire [ADWIDTH-1:0]  wr_addr,     // Write Pointer
    input  wire [DWIDTH-1:0]   wr_data,    // Write Data In
    input  wire                rd_clk,
    input  wire [ADWIDTH-1:0]  rd_addr,     // Read Pointer
    output reg  [DWIDTH-1:0]   rd_data   // Read Data

);

   //********************************************************************
   // Infer Memory or use Dual Port Memory from Quartus/ASIC Memory
   //********************************************************************
   reg [DWIDTH-1:0]   buf_mem [DEPTH-1:0] /* synthesis ramstyle = "M20K, no_rw_check" */;
   
   always @(posedge wr_clk) begin
         if (wr_en) begin
             buf_mem[wr_addr] <= wr_data;
         end   
   end

   
   always @(posedge rd_clk) begin 
         rd_data <= buf_mem[rd_addr];
   end 
      
   
endmodule
