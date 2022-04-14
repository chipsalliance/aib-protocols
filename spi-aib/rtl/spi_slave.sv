// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2019 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: SPI Slave IP top level RTL
// Only mode 0 is supported.
// Only free running sclk may supported. For gated clock, work around may required.
//
// Change log
// 08/09/2021
// 11/19/2021 Remove tristate buffer.
/////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ps / 1ps

module spi_slave #(
    parameter BUF_SIZE = 256,
    parameter BUF_ADWIDTH = $clog2(BUF_SIZE)
)(
    //System interface
    input                 rst_n,      //System reset
    //SPI interface
    input                 sclk,       //Free running SPI clock out 
    input                 ss_n,
    input                 mosi,
    output                miso,
    //avalon interface
    input                 avmm_clk,   //Free running clock

    //avalon interface 0
    output [16:0]         avmm0_addr,
    output [3:0]          avmm0_byte_en, //Expect this to be 4'f since design is word based
    output                avmm0_write,
    output                avmm0_read,
    output [31:0]         avmm0_wdata,
    input                 avmm0_rdatavld,
    input  [31:0]         avmm0_rdata,
    input                 avmm0_waitreq,

    //avalon interface 1
    output [16:0]         avmm1_addr,
    output [3:0]          avmm1_byte_en, //Expect this to be 4'f since design is word based
    output                avmm1_write,
    output                avmm1_read,
    output [31:0]         avmm1_wdata,
    input                 avmm1_rdatavld,
    input  [31:0]         avmm1_rdata,
    input                 avmm1_waitreq,
    //avalon interface 2
    output [16:0]         avmm2_addr,
    output [3:0]          avmm2_byte_en, //Expect this to be 4'f since design is word based
    output                avmm2_write,
    output                avmm2_read,
    output [31:0]         avmm2_wdata,
    input                 avmm2_rdatavld,
    input  [31:0]         avmm2_rdata,
    input                 avmm2_waitreq
    
    //Optional Interrupt port. Can connect to GPIO if necessary
//  output                spi_inta
);


logic rx_buf_we, tx_buf_we;
logic [BUF_ADWIDTH-1:0] rx_buf_waddr;
logic [BUF_ADWIDTH-1:0] rx_buf_raddr;
logic [BUF_ADWIDTH-1:0] tx_buf_waddr;
logic [BUF_ADWIDTH-1:0] tx_buf_raddr;
logic [31:0] tx_buf_wdata;
logic [31:0] tx_buf_rdata;
logic [31:0] rx_buf_wdata;
logic [31:0] rx_buf_rdata;
logic        csr_sel;
logic        csr_we;
logic        csr_re;
logic [3:0]  csr_addr;
logic [31:0] csr_wdata;
logic [31:0] csr_rdata;
logic        auto_update;
logic [31:0] auto_csr0_reg;
logic [31:0] csr0_reg;
logic [31:0] csr1_reg;
logic [31:0] csr2_reg;
logic rst_n_sclk, rst_n_avmm;
logic trans_done;


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

sspi_avmm_intf #(
      .AVMM_ADDR_WIDTH(17),
      .BUF_SIZE(BUF_SIZE) 
   ) sspi_avmm_intf (
   .avmm_clk(avmm_clk), 
   .avmm_rst_n(rst_n_avmm),
   //AVMM Slave interface0
   .o_avmm0_write(avmm0_write),
   .o_avmm0_read(avmm0_read),
   .o_avmm0_addr(avmm0_addr),
   .o_avmm0_wdata(avmm0_wdata),
   .o_avmm0_byte_en(avmm0_byte_en),
   .i_avmm0_rdata(avmm0_rdata),
   .i_avmm0_rdatavalid(avmm0_rdatavld),
   .i_avmm0_waitrequest(avmm0_waitreq),

   //AVMM Slave interface1
   .o_avmm1_write(avmm1_write),
   .o_avmm1_read(avmm1_read),
   .o_avmm1_addr(avmm1_addr),
   .o_avmm1_wdata(avmm1_wdata),
   .o_avmm1_byte_en(avmm1_byte_en),
   .i_avmm1_rdata(avmm1_rdata),
   .i_avmm1_rdatavalid(avmm1_rdatavld),
   .i_avmm1_waitrequest(avmm1_waitreq),

   //AVMM Slave interface2
   .o_avmm2_write(avmm2_write),
   .o_avmm2_read(avmm2_read),
   .o_avmm2_addr(avmm2_addr),
   .o_avmm2_wdata(avmm2_wdata),
   .o_avmm2_byte_en(avmm2_byte_en),
   .i_avmm2_rdata(avmm2_rdata),
   .i_avmm2_rdatavalid(avmm2_rdatavld),
   .i_avmm2_waitrequest(avmm2_waitreq),

   .csr0_reg(csr0_reg),
   .csr1_reg(csr1_reg),
   .rx_buf_rdata(rx_buf_rdata),
   .rx_buf_raddr(rx_buf_raddr),
   .tx_buf_wdata(tx_buf_wdata),
   .tx_buf_waddr(tx_buf_waddr),
   .tx_buf_we(tx_buf_we),
   .trans_done(trans_done)
);


sspi_avmm_csr 
#(
    .BUF_SIZE(BUF_SIZE)
) sspi_avmm_csr (

//To SPI interface
    .sclk(sclk),
    .rst_n_sclk(rst_n_sclk),
    .csr0_reg(csr0_reg),
    .csr1_reg(csr1_reg),
    .csr2_reg(csr2_reg),
    .rx_buf_rdata(rx_buf_rdata),
    .rx_buf_raddr(rx_buf_raddr),
    .tx_buf_wdata(tx_buf_wdata),
    .tx_buf_waddr(tx_buf_waddr),
    .tx_buf_we(tx_buf_we),
    .trans_done(trans_done),

    .csr_sel(csr_sel),
    .csr_we(csr_we),
    .csr_re(csr_re),
    .csr_addr(csr_addr),
    .csr_wdata(csr_wdata),
    .csr_rdata(csr_rdata),
    .auto_update(auto_update),
    .auto_csr0_reg(auto_csr0_reg),

    .avmm_clk(avmm_clk),
    .avmm_rst_n(rst_n_avmm),
    .rx_buf_wdata(rx_buf_wdata),
    .rx_buf_we(rx_buf_we),
    .rx_buf_waddr(rx_buf_waddr),
    .tx_buf_raddr(tx_buf_raddr),
    .tx_buf_rdata(tx_buf_rdata)
);

sspi_intf 
#(
    .BUF_SIZE(BUF_SIZE) 
) sspi_intf (

    .csr_sel(csr_sel),
    .csr_we(csr_we),
    .csr_re(csr_re),
    .csr_addr(csr_addr),
    .csr_wdata(csr_wdata),
    .csr_rdata(csr_rdata),
    .auto_update(auto_update),
    .auto_csr0_reg(auto_csr0_reg),
    .csr0_reg(csr0_reg),
    .csr1_reg(csr1_reg),
    .csr2_reg(csr2_reg),

    .rx_buf_wdata(rx_buf_wdata),
    .rx_buf_we(rx_buf_we),
    .rx_buf_waddr(rx_buf_waddr),
    .tx_buf_raddr(tx_buf_raddr),
    .tx_buf_rdata(tx_buf_rdata),

    .rst_n_sclk(rst_n_sclk),
    .sclk(sclk),
    .ss_n(ss_n),
    .mosi(mosi),
//  .miso(miso_int)
    .miso(miso)
);
//assign miso = (~ss_n) ? miso_int : 1'bz;
endmodule
