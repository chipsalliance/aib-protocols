// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2019 Intel Corporation.
//-----------------------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------------------//
`timescale 1ps / 1ps
module sspi_intf #(
    parameter BUF_SIZE = 256,
    parameter BUF_ADWIDTH = $clog2(BUF_SIZE)
  )(
    //CSR interface and Buffer interface
    output logic                   csr_sel,
    output logic                   csr_we,
    output logic                   csr_re,
    output logic [3:0]             csr_addr,
    output logic [31:0]            csr_wdata,
    input  logic [31:0]            csr_rdata,
    output logic                   auto_update,
    output logic [31:0]            auto_csr0_reg,
    input  logic [31:0]            csr0_reg,
    input  logic [31:0]            csr1_reg,
    input  logic [31:0]            csr2_reg,

    output logic [31:0]            rx_buf_wdata,
    output logic                   rx_buf_we,
    output logic [BUF_ADWIDTH-1:0] rx_buf_waddr,
    output logic [BUF_ADWIDTH-1:0] tx_buf_raddr,
    input  logic [31:0]            tx_buf_rdata,
    //SPI Bus interface
    input  logic                   rst_n_sclk,
    input                          sclk,       //Free running SPI clock out
    input                          ss_n,
    input                          mosi,
    output logic                   miso

);

localparam CMD_REG_READ         = 4'h0;
localparam CMD_REG_WRITE        = 4'h1;
localparam CMD_BUF_READ         = 4'h2;
localparam CMD_BUF_WRITE        = 4'h3;
localparam CMD_AUTO_READ        = 4'h6;
localparam CMD_AUTO_WRITE       = 4'h7;

///////////////////////////////////////////////////////////
// Convert mosi to receiver buffer
///////////////////////////////////////////////////////////
logic [31:0] rx_data, tx_data;
logic [BUF_ADWIDTH+4:0] full_counter;
logic  dword0,cmd_valid;
logic [3:0] cmd;
logic [16:0] csr_addr_dw;

wire [BUF_ADWIDTH-1:0] wd_count = full_counter[BUF_ADWIDTH+4:5];
wire [4:0] bit_count = full_counter[4:0];
logic [BUF_ADWIDTH-1:0]  burst_len;
wire        last_bit  = (&bit_count);
logic       csr_addr_valid;
logic       burst_len_valid;
logic       tx_buf_ren;
logic [2:0] rd_lat_cnt;
logic [1:0] rd_latency;

assign rx_buf_wdata = rx_data;
assign csr_wdata = rx_data;
assign reg_read =   (cmd == CMD_REG_READ);
assign reg_write =  (cmd == CMD_REG_WRITE); 
assign buf_read =   (cmd == CMD_BUF_READ);
assign buf_write =  (cmd == CMD_BUF_WRITE);
assign auto_read =  (cmd == CMD_AUTO_READ);
assign auto_write = (cmd == CMD_AUTO_WRITE);

always_ff @(posedge sclk or negedge rst_n_sclk)
 if (!rst_n_sclk) begin
       full_counter <= '0;
       rx_data <= '0;
       rx_buf_we  <= '0;
       rx_buf_waddr <= '0;
 end
 else begin

       if (~ss_n) full_counter <= full_counter + 1'b1;
       else       full_counter <= '0;

       if (~ss_n) rx_data[31:0] <= {rx_data[30:0], mosi};
       rx_buf_we <= last_bit & (buf_write | auto_write) & ~dword0;
       if (ss_n) rx_buf_waddr <= '0;
       else if (rx_buf_we) rx_buf_waddr <= rx_buf_waddr + 1'b1;
 end

assign auto_csr0_reg ={7'h0, burst_len, csr_addr_dw, 2'b00, ~cmd[0], 1'b1}; 
always_ff @(posedge sclk or negedge rst_n_sclk)
 if (!rst_n_sclk) begin
       dword0 <= '0;
       cmd_valid <= '0; 
       cmd <= '0;
       burst_len_valid <= '0;
       csr_addr_valid <= '0;
       csr_addr_dw <= '0;
       csr_addr <= '0;
       csr_sel <= '0;
       csr_we  <= '0;
       csr_re  <= '0;
       auto_update <= '0;
 end
 else begin
       dword0 <= (wd_count == '0);
       cmd_valid <= (wd_count == '0) & (bit_count == 5'h3);
       if (cmd_valid) cmd <= rx_data[3:0];
       else if (ss_n) cmd <= '0;
       
       burst_len_valid <= (wd_count == '0) & (bit_count == 5'd12);
       if (burst_len_valid) burst_len <= rx_data[BUF_ADWIDTH-1:0];

       csr_addr_valid <= (wd_count == '0) & (bit_count == 5'h1d);
       if (csr_addr_valid)       csr_addr_dw <= rx_data[16:0];
       if (csr_addr_valid)       csr_addr <= rx_data[3:0];
       else if (csr_we | csr_re) csr_addr <= csr_addr + 1'b1;
       else if (ss_n) csr_addr <= '0;

       csr_sel <= (reg_read | reg_write); 
       csr_we  <= reg_write & (bit_count == 5'h1f) & ~dword0;
       csr_re  <= csr_sel & reg_read & (bit_count == 5'h1f);
       if (auto_write) 
            auto_update <= last_bit & (wd_count == burst_len + 1'b1);
       else if (auto_read)
            auto_update <= last_bit & (wd_count == '0);
       else auto_update <= 1'b0;
          
 end


///////////////////////////////////////////////////////////
// Generate miso from tx buffer 
// The read latency for auto read is programmable
// In other case, it is one cycle.
///////////////////////////////////////////////////////////
wire hdr_sel = csr1_reg[22];
wire [31:0] default_dw = hdr_sel ? csr2_reg : csr0_reg;
assign rd_latency = csr1_reg[24:23];
assign rd_lat_cnt = auto_read ? (rd_latency + 2'h2) : 2'b1;

always_ff @(posedge sclk or negedge rst_n_sclk)
 if (!rst_n_sclk) begin
       tx_buf_raddr <= '0;
       tx_buf_ren   <= '0;
 end
 else begin
       if (ss_n) tx_buf_raddr <= '0;
       else if (tx_buf_ren) tx_buf_raddr <= tx_buf_raddr + 1'b1;
       if (~ss_n) begin
          if ((wd_count >= rd_lat_cnt) & (bit_count == '0) & ~reg_read) 
             tx_buf_ren <= 1'b1;
          else  tx_buf_ren <= 1'b0;
       end else tx_buf_ren <= 1'b0;
 end

always_ff @(negedge sclk or negedge rst_n_sclk)
 if (!rst_n_sclk) miso <= '0;
 else miso <= tx_data[31];

always_ff @(posedge sclk or negedge rst_n_sclk)
 if (!rst_n_sclk) begin
    tx_data <= '0;
 end
 else begin
    if (ss_n) tx_data <= default_dw;
    else if (last_bit & reg_read) tx_data <= csr_rdata; 
    else if (last_bit) tx_data <= tx_buf_rdata;
    else tx_data <= {tx_data[30:0], 1'b0};
 end


endmodule
