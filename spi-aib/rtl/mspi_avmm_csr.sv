// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2019 Intel Corporation. 
//-----------------------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------------------//
`timescale 1ps / 1ps
module mspi_avmm_csr 
#(
    parameter BUF_SIZE = 256,
    parameter BUF_ADWIDTH = $clog2(BUF_SIZE) 
)(

//To SPI interface
output	logic [31:0]    cmd_reg,

//Buffer SPI interface 
input                   sclk,
input                   spi_active,
input [31:0]            rx_buf_wdata,
input                   rx_buf_we,
input [BUF_ADWIDTH-1:0] rx_buf_waddr,
input [BUF_ADWIDTH-1:0] tx_buf_raddr,
output logic [31:0]     tx_buf_rdata,

//avmm  Interface
input                   avmm_clk,       //This block is running in avmm clk
input                   avmm_rst_n,
input [31:0]            writedata,
input                   read,
input                   write,
input [3:0]             byteenable,   //Not used
output logic [31:0]     readdata,
output logic            readdatavalid,
input [12:0]            address,
output logic            spi_inta
);

wire        spi_active_aclk;
wire [31:0] rx_buf_rdata;
wire [31:0] status_reg = 32'h0;
// Protocol management
// combinatorial read data signal declaration
reg [31:0] rdata_comb;
reg        spi_active_aclk_d1;
reg [2:0]  read_dly;

// synchronous process for the read
always @(negedge avmm_rst_n ,posedge avmm_clk)  
   if (!avmm_rst_n) readdata[31:0] <= 32'h0; else readdata[31:0] <= rdata_comb[31:0];

//  Protocol specific assignment to inside signals
//
wire        we = write;
wire        re = read;
wire [12:0]  addr = address;
wire [31:0] din  = writedata [31:0];
reg  [12:0] tx_buf_waddr, rx_buf_raddr;
reg  [31:0] tx_buf_wdata;
reg         tx_buf_we;

// A write byte enable for each register

wire           sel_cmd    = (addr[12:0] == 13'h00);
wire           sel_status = (addr[12:0] == 13'h0c);
wire           sel_tx_buf = (~addr[12]  & |addr[11:9]);  //address range 13'h200 ~13'hfff
wire           sel_rx_buf = ( addr[12]  & ~addr[11]);    //address range 13'h1000 ~13'h17ff
wire	       we_cmd    = we & sel_cmd;


///////////////////////////////////////////////////////////
// Take spi_acitve from sclk domain to avmm_clk domain
//////////////////////////////////////////////////////////
    spi_bitsync bitsync2_start_trans
       (
        .clk      (avmm_clk),
        .rst_n    (avmm_rst_n),
        .data_in  (spi_active),
        .data_out (spi_active_aclk)
        );
//Generate start pulse in sclk domain

always @( negedge  avmm_rst_n,  posedge avmm_clk)
   if (!avmm_rst_n)  begin
      cmd_reg[31:0] <= 32'h00000000;
      spi_active_aclk_d1 <= 1'b0;
      read_dly <= 3'h0;
      readdatavalid <= 1'b0;
      spi_inta <= 1'b0;
   end
   else begin
      if (we_cmd) 
         cmd_reg[31:0] <=  din[31:0];
      else if (~spi_active_aclk & spi_active_aclk_d1) begin
         cmd_reg[0] <= 1'b0;
      end
      if (~spi_active_aclk & spi_active_aclk_d1) spi_inta <= 1'b1;
      else if (spi_active_aclk & ~spi_active_aclk_d1) spi_inta <= 1'b0;

      spi_active_aclk_d1 <= spi_active_aclk;

      read_dly <= {read_dly[1:0], read};
      readdatavalid <= read_dly[0] & ~read_dly[1];
   end

assign rx_buf_raddr = addr;   //RX buffer base address is at 1000. can ignore 1 here.
always @( negedge  avmm_rst_n,  posedge avmm_clk)
   if (!avmm_rst_n)  begin
      tx_buf_we    <= '0;
      tx_buf_waddr <= '0;
      tx_buf_wdata  <= '0; 
   end
   else begin
         tx_buf_we    <= we & sel_tx_buf;
         tx_buf_waddr <=  addr - 12'h200;
         tx_buf_wdata  <= writedata;
   end

// read process
always @ (*)
begin
rdata_comb = 32'h0;
   if (sel_cmd) rdata_comb [31:0] = cmd_reg[31:0];
   else if (sel_status) rdata_comb [31:0] = status_reg[31:0];
   else if (sel_rx_buf) rdata_comb [31:0] = rx_buf_rdata[31:0];
end

spi_buf_ram 
  #(
    .DWIDTH(32),          // buffer Input data width
    .DEPTH (BUF_SIZE)         // buffer Depth
    ) mspi_tx_buffer
(
    .wr_clk(avmm_clk),     
    .wr_en(tx_buf_we),    
    .wr_addr(tx_buf_waddr[BUF_ADWIDTH+1:2]), //addr is per word 
    .wr_data(tx_buf_wdata),
    .rd_clk(sclk),
    .rd_addr(tx_buf_raddr),        //addr is per word
    .rd_data(tx_buf_rdata)
);

spi_buf_ram 
  #(
    .DWIDTH(32),          // buffer Input data width
    .DEPTH (BUF_SIZE)   // buffer Depth
    ) mspi_rx_buffer
(
    .wr_clk(sclk),
    .wr_en(rx_buf_we),
    .wr_addr(rx_buf_waddr), //addr is per word
    .wr_data(rx_buf_wdata[31:0]),
    .rd_clk(avmm_clk),
    .rd_addr(rx_buf_raddr[BUF_ADWIDTH+1:2]),        //addr is per word
    .rd_data(rx_buf_rdata)
);
endmodule
