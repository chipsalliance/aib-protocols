// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: Application CSR interface 
//
//
// Change log
// 12/19/2021 This is an example application register component
//            It includes AVMM slave interface and a parameterized CSR 
//            Generally, this block should sit in User appliation side 
//            that connects with one of the AVMM port of spi follower (slave)
/////////////////////////////////////////////////////////////////////////////////////////


`timescale 1ps / 1ps

module app_avmm_csr #(
    parameter STAT_NUM= 16,   //Maximum 16
    parameter CTRL_NUM= 256  //Maximum 256
)(
    //To user interface
    input  [STAT_NUM-1:0][31:0]    user_status,
    output [CTRL_NUM-1:0][31:0]    user_csr,
    //avalon interface
    input                 avmm_rstn,
    input                 avmm_clk,   //Free running clock
    input [16:0]          avmm_addr,
    input [3:0]           avmm_byte_en, //Expect this to be 4'f since design is word based
    input                 avmm_write,
    input                 avmm_read,
    input [31:0]          avmm_wdata,
    output                avmm_rdatavld,
    output [31:0]         avmm_rdata,
    output                avmm_waitreq
);

wire [31:0] writedata;
wire read;
wire write;
wire [3:0] byteenable;   //Not used
wire [31:0] readdata;
wire readdatavalid;
wire[12:0] address;

mspi_avmm_intf #(
      .AVMM_ADDR_WIDTH(17),
      .RDL_ADDR_WIDTH(13)
   ) mspi_avmm_intf (
   .avmm_clk(avmm_clk),
   .avmm_rst_n(avmm_rstn),
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

reg_avmm_csr
#(
    .STAT_NUM(STAT_NUM),
    .CTRL_NUM(CTRL_NUM)
) reg_avmm_csr (
    .user_status(user_status),
    .user_csr(user_csr),
    .avmm_clk(avmm_clk),
    .avmm_rst_n(avmm_rstn),
    .writedata(writedata),
    .read(read),
    .write(write),
    .byteenable(byteenable),
    .readdata(readdata),
    .readdatavalid(readdatavalid),
    .address(address)
);

endmodule

