// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2019 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: SPI master IP top level RTL 
//
//
// Change log
// 08/09/2021
/////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ps / 1ps

module spi_master #(
    parameter BUF_SIZE = 512,
    parameter BUF_ADWIDTH = $clog2(BUF_SIZE),
    parameter SS_WIDTH = 4
)(
    //System interface
    input                 spi_clk_in, //Free running clock
    input                 rst_n,      //System reset
    //SPI interface
    output                sclk,       //Free running SPI clock out 
    output [SS_WIDTH-1:0] ss_n,
    output                mosi,
    input                 miso,
    //avalon interface
    input                 avmm_clk,   //Free running clock
    input [16:0]          avmm_addr,
    input [3:0]           avmm_byte_en, //Expect this to be 4'f since design is word based
    input                 avmm_write,
    input                 avmm_read,
    input [31:0]          avmm_wdata,
    output                avmm_rdatavld,
    output [31:0]         avmm_rdata,
    output                avmm_waitreq,
    //Optional Interrupt port. Can connect to GPIO if necessary
    output                spi_inta
);
wire rst_n_avmm, rst_n_sclk;
wire [31:0] writedata;
wire read;
wire write;
wire [3:0] byteenable;   //Not used
wire [31:0] readdata;
wire readdatavalid;
wire[12:0] address;

wire [31:0] cmd_reg;
wire [31:0] rx_buf_wdata;
wire rx_buf_we;
wire [BUF_ADWIDTH-1:0] rx_buf_waddr;
wire [BUF_ADWIDTH-1:0] tx_buf_raddr;
wire [31:0] tx_buf_rdata;

assign sclk = spi_clk_in;
spi_rstnsync sclk_rstnsync
  (
    .clk(sclk),              // Destination clock of reset to be synced
    .i_rst_n(rst_n),         // Asynchronous reset input
    .scan_mode(1'b0),         // Scan bypass for reset
    .sync_rst_n(rst_n_sclk)      // Synchronized reset output
   );

spi_rstnsync aclk_rstnsync
  (
    .clk(avmm_clk),          // Destination clock of reset to be synced
    .i_rst_n(rst_n),         // Asynchronous reset input
    .scan_mode(1'b0),         // Scan bypass for reset
    .sync_rst_n(rst_n_avmm)      // Synchronized reset output
   );

mspi_avmm_intf #(
      .AVMM_ADDR_WIDTH(17),
      .RDL_ADDR_WIDTH(13)
   ) mspi_avmm_intf (
   .avmm_clk(avmm_clk), 
   .avmm_rst_n(rst_n_avmm),
   .i_avmm_write(avmm_write),
   .i_avmm_read(avmm_read),
   .i_avmm_addr(avmm_addr),
   .i_avmm_wdata(avmm_wdata),
   .i_avmm_byte_en(avmm_byte_en),
   .o_avmm_rdata(avmm_rdata),
   .o_avmm_rdatavalid(avmm_rdatavld),
   .o_avmm_waitrequest(avmm_waitreq),
   .clk(), // RDL-generated memory map interface
   .reset(),
   .writedata(writedata),
   .read(read),
   .write(write),
   .byteenable(byteenable),
   .readdata(readdata),
   .readdatavalid(readdatavalid),
   .address(address)

);


mspi_avmm_csr 
#(
    .BUF_SIZE(BUF_SIZE)
) mspi_avmm_csr (

//To SPI interface
    .cmd_reg(cmd_reg),
    .sclk(sclk),
    .spi_active(spi_active),
    .rx_buf_wdata(rx_buf_wdata),
    .rx_buf_we(rx_buf_we),
    .rx_buf_waddr(rx_buf_waddr),
    .tx_buf_raddr(tx_buf_raddr),
    .tx_buf_rdata(tx_buf_rdata),
    .avmm_clk(avmm_clk),       
    .avmm_rst_n(rst_n_avmm),
    .writedata(writedata),
    .read(read),
    .write(write),
    .byteenable(byteenable), 
    .readdata(readdata),
    .readdatavalid(readdatavalid),
    .address(address),
    .spi_inta(spi_inta)
);

mspi_intf 
#(
    .BUF_SIZE(BUF_SIZE) 
) mspi_intf (

    .rx_buf_wdata(rx_buf_wdata),
    .rx_buf_we(rx_buf_we),
    .rx_buf_waddr(rx_buf_waddr),
    .tx_buf_raddr(tx_buf_raddr),
    .tx_buf_rdata(tx_buf_rdata),
    .spi_active(spi_active),
    .avmm_clk(avmm_clk),
    .rst_n_avmm(rst_n_avmm),
    .cmd_reg(cmd_reg),
    .rst_n_sclk(rst_n_sclk),
    .sclk(sclk),
    .ss_n(ss_n),
    .mosi(mosi),
    .miso(miso)
);

endmodule
