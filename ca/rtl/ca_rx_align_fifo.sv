////////////////////////////////////////////////////////////
//
//        Copyright (C) 2021 Eximius Design
//
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Functional Descript: Channel Alignment IP, RX channel alignment FIFO
//
//
//
////////////////////////////////////////////////////////////

module ca_rx_align_fifo
  #(
    parameter BITS_PER_CHANNEL = 80,
    parameter AD_WIDTH = 4,
    parameter SYNC_FIFO = 1
    )
  (
   input logic                         lane_clk,
   input logic                         rst_lane_n,
   input logic                         com_clk,
   input logic                         rst_com_n,

   input logic                         fifo_push,
   input logic                         fifo_pop,
   input logic                         soft_reset,

   input logic [BITS_PER_CHANNEL-1:0]  rx_din,
   output logic [BITS_PER_CHANNEL-1:0] rx_dout,

   output logic                        rd_empty,
   output logic                        wr_overflow_pulse,

   input logic [5:0]                   fifo_full_val,
   input logic [5:0]                   fifo_pfull_val,
   input logic [2:0]                   fifo_empty_val,
   input logic [2:0]                   fifo_pempty_val,

   output logic                        soft_reset_lane,
   output logic                        fifo_full,
   output logic                        fifo_pfull,
   output logic                        fifo_empty,
   output logic                        fifo_pempty
   );

  localparam FIFO_WIDTH_MSB = BITS_PER_CHANNEL-1;
  localparam FIFO_COUNT_MSB = AD_WIDTH;

  localparam FIFO_WIDTH_WID = BITS_PER_CHANNEL;
  localparam FIFO_DEPTH_WID = (1 << AD_WIDTH);
  localparam FIFO_ADDR_WID = AD_WIDTH+1;

  logic [FIFO_ADDR_WID-1:0]            rd_numfilled;
  logic [FIFO_ADDR_WID-1:0]            wr_numfilled;
  logic [FIFO_ADDR_WID-1:0]            wr_numempty;

  logic                                wr_full;
  logic                                reset_fifo_rd_empty;
  logic                                reset_fifo_rd_pop;
  logic                                rd_underflow_pulse;

  /* RX alignment FIFO */

  /* syncfifo AUTO_TEMPLATE (
   .clk_core        (com_clk),
   .rst_core_n      (rst_com_n),
   .soft_reset      (soft_reset),
   .rddata          (rx_dout[]),
   .numfilled       (rd_numfilled[]),
   .numempty        (wr_numempty[]),
   .wrdata          (rx_din[]),
   .write_push      (fifo_push),
   .read_pop        (fifo_pop),
   .full            (wr_full),
   .empty           (rd_empty),
   .overflow_pulse  (wr_overflow_pulse),
   .underflow_pulse (rd_underflow_pulse),
   ); */

  /* asyncfifo AUTO_TEMPLATE (
   .clk_write     (lane_clk),
   .rst_write_n   (rst_lane_n),
   .clk_read      (com_clk),
   .rst_read_n    (rst_com_n),
   .rddata        (rx_dout[]),
   .rd_numfilled  (rd_numfilled[]),
   .wr_numempty   (wr_numempty[]),
   .wrdata        (rx_din[]),
   .write_push    (fifo_push),
   .read_pop      (fifo_pop),
   .wr_soft_reset (soft_reset_lane),
   .rd_soft_reset (1'b0),
   ); */

  /* levelsync AUTO_TEMPLATE (
   .RESET_VALUE (1'b0),
   .clk_dest    (lane_clk),
   .rst_dest_n  (rst_lane_n),
   .src_data    (soft_reset),
   .dest_data   (soft_reset_lane),
   ); */

  generate
    if (SYNC_FIFO)
      begin
        assign soft_reset_lane = soft_reset;

        syncfifo
          #(/*AUTOINSTPARAM*/
            // Parameters
            .FIFO_WIDTH_WID             (FIFO_WIDTH_WID),
            .FIFO_DEPTH_WID             (FIFO_DEPTH_WID))
        syncfifo_i
          (/*AUTOINST*/
           // Outputs
           .rddata                      (rx_dout[FIFO_WIDTH_MSB:0]), // Templated
           .numfilled                   (rd_numfilled[FIFO_COUNT_MSB:0]), // Templated
           .numempty                    (wr_numempty[FIFO_COUNT_MSB:0]), // Templated
           .full                        (wr_full),               // Templated
           .empty                       (rd_empty),              // Templated
           .overflow_pulse              (wr_overflow_pulse),     // Templated
           .underflow_pulse             (rd_underflow_pulse),    // Templated
           // Inputs
           .clk_core                    (com_clk),               // Templated
           .rst_core_n                  (rst_com_n),             // Templated
           .soft_reset                  (soft_reset),            // Templated
           .write_push                  (fifo_push),             // Templated
           .wrdata                      (rx_din[FIFO_WIDTH_MSB:0]), // Templated
           .read_pop                    (fifo_pop));              // Templated
      end
    else
      begin
	
	asyncfifo
        #(/*AUTOINSTPARAM*/
          // Parameters
          .FIFO_WIDTH_WID             (1),
          .FIFO_DEPTH_WID             (8))
        asyncfifo_soft_reset
         (/*AUTOINST*/
          // Outputs
          .rddata                      (soft_reset_lane),// Templated
          .rd_numfilled                (), // Templated
          .wr_numempty                 (),// Templated
          .wr_full                     (),
          .rd_empty                    (reset_fifo_rd_empty),
          .wr_overflow_pulse           (),
          .rd_underflow_pulse          (),
          // Inputs
          .clk_write                   (com_clk),              // Templated
          .rst_write_n                 (rst_com_n),            // Templated
          .clk_read                    (lane_clk),               // Templated
          .rst_read_n                  (rst_lane_n),             // Templated
          .wrdata                      (soft_reset),// Templated
          .write_push                  (1'b1),             // Templated
          .read_pop                    (reset_fifo_rd_pop),              // Templated
          .rd_soft_reset               (1'b0),                  // Templated
          .wr_soft_reset               (1'b0));     // Templated

	assign reset_fifo_rd_pop =  (reset_fifo_rd_empty==1'b1) ? 1'b0 : 1'b1 ;

        asyncfifo
          #(/*AUTOINSTPARAM*/
            // Parameters
            .FIFO_WIDTH_WID             (FIFO_WIDTH_WID),
            .FIFO_DEPTH_WID             (FIFO_DEPTH_WID))
        asyncfifo_i
          (/*AUTOINST*/
           // Outputs
           .rddata                      (rx_dout[FIFO_WIDTH_WID-1:0]), // Templated
           .rd_numfilled                (rd_numfilled[FIFO_ADDR_WID-1:0]), // Templated
           .wr_numempty                 (wr_numempty[FIFO_ADDR_WID-1:0]), // Templated
           .wr_full                     (wr_full),
           .rd_empty                    (rd_empty),
           .wr_overflow_pulse           (wr_overflow_pulse),
           .rd_underflow_pulse          (rd_underflow_pulse),
           // Inputs
           .clk_write                   (lane_clk),              // Templated
           .rst_write_n                 (rst_lane_n),            // Templated
           .clk_read                    (com_clk),               // Templated
           .rst_read_n                  (rst_com_n),             // Templated
           .wrdata                      (rx_din[FIFO_WIDTH_WID-1:0]), // Templated
           .write_push                  (fifo_push),             // Templated
           .read_pop                    (fifo_pop),              // Templated
           .rd_soft_reset               (1'b0),                  // Templated
           .wr_soft_reset               (soft_reset_lane));     // Templated
      end // else: !if(SYNC_FIFO)
  endgenerate

  /* FIFO flags */

  assign wr_numfilled = FIFO_DEPTH_WID - wr_numempty;

  always_comb
    begin
      fifo_full = (rd_numfilled >= fifo_full_val);
      fifo_pfull = (rd_numfilled >= fifo_pfull_val);
      fifo_empty = (wr_numfilled == fifo_empty_val);
      fifo_pempty = (wr_numfilled <= fifo_pempty_val);
    end

endmodule // ca_rx_align_fifo

// Local Variables:
// verilog-library-directories:("." "${PROJ_DIR}/common/rtl")
// verilog-auto-inst-param-value:t
// End:

