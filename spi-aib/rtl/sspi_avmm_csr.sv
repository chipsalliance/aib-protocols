// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2019 Intel Corporation. 
//-----------------------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------------------//
`timescale 1ps / 1ps
module sspi_avmm_csr 
#(
    parameter BUF_SIZE = 256,
    parameter BUF_ADWIDTH = $clog2(BUF_SIZE) 
)(

//Buffer SPI interface 
input                    sclk,
input                    rst_n_sclk,

//avmm  Interface
input                    avmm_clk,       
input                    avmm_rst_n,

//csr1_reg and csr2_reg are static
//csr0_reg will be treated as static by cdc constrain
output  logic [31:0]     csr0_reg,
output  logic [31:0]     csr1_reg,
output  logic [31:0]     csr2_reg,

//From AVMM interface
input  [BUF_ADWIDTH-1:0] rx_buf_raddr,
output [31:0]            rx_buf_rdata,

input  [BUF_ADWIDTH-1:0] tx_buf_waddr,
input  [31:0]            tx_buf_wdata,
input                    tx_buf_we,
input                    trans_done,

//SPI CSR and Buffer interface
input                    csr_sel,
input                    csr_we,
input                    csr_re,
input  [3:0]             csr_addr,
input  [31:0]            csr_wdata,
output logic [31:0]      csr_rdata,
input                    auto_update,
input  [31:0]            auto_csr0_reg,

input  [BUF_ADWIDTH-1:0] rx_buf_waddr,
input                    rx_buf_we,
input  [31:0]            rx_buf_wdata,
input  [BUF_ADWIDTH-1:0] tx_buf_raddr,
output logic [31:0]      tx_buf_rdata
);

//
logic  [31:0] rdata_comb;
logic         trans_done_sclk; 
logic         auto_update_d1;
// A write byte enable for each register

wire           sel_csr0    = (csr_addr[3:0] == 4'h0) & csr_sel;
wire           sel_csr1    = (csr_addr[3:0] == 4'h1) & csr_sel;
wire           sel_csr2    = (csr_addr[3:0] == 4'h2) & csr_sel;
wire           sel_csr3    = (csr_addr[3:0] == 4'h3) & csr_sel;
wire	       we_csr0     = csr_we & sel_csr0;
wire	       we_csr1     = csr_we & sel_csr1;
wire	       we_csr2     = csr_we & sel_csr2;

wire           re_csr0     = sel_csr0; 
wire           re_csr1     = sel_csr1; 
wire           re_csr2     = sel_csr2; 
wire           re_csr3     = sel_csr3; 

///////////////////////////////////////////////////////////
// Take spi_acitve from sclk domain to avmm_clk domain
//////////////////////////////////////////////////////////
    spi_bitsync bitsync2_start_trans
       (
        .clk      (sclk),
        .rst_n    (rst_n_sclk),
        .data_in  (trans_done),
        .data_out (trans_done_sclk)
        );
// Write process
//During the auto_update, csr0_reg bit 0 will be the last
//to arrive to avmm to make sure the rest information are stabled to use
//SDC constrain will make sure the skew and delay can work for that purpose. 

always @( negedge  rst_n_sclk,  posedge sclk)
   if (!rst_n_sclk)  begin
      csr0_reg[31:0] <= 32'h00000000;
      auto_update_d1 <= 1'b0;
   end
   else begin
      if (we_csr0)
         csr0_reg[31:0] <=  csr_wdata[31:0];
      else if (auto_update)
         csr0_reg[31:1] <= auto_csr0_reg[31:1];
      else if (auto_update_d1)                  //Delay bit 0 one SCLK
         csr0_reg[0]    <= 1'b1;                //Bit 0 is the AVMM state machine enable
      else if (trans_done_sclk)
         csr0_reg[0] <= 1'b0;

      auto_update_d1 <= auto_update;
   end


//csr1_reg is static
always @( negedge  rst_n_sclk,  posedge sclk)
   if (!rst_n_sclk)  begin
      csr1_reg[31:0] <= 32'h00000000;
   end
   else begin
      if (we_csr1)
         csr1_reg[31:0] <=  csr_wdata[31:0];
   end

//csr2_reg is static
always @( negedge  rst_n_sclk,  posedge sclk)
   if (!rst_n_sclk)  begin
      csr2_reg[31:0] <= 32'h00000000;
   end 
   else begin
      if (we_csr2)
         csr2_reg[31:0] <=  csr_wdata[31:0];
   end

// read process
always @( negedge  rst_n_sclk,  posedge sclk)
   if (!rst_n_sclk)  
      csr_rdata[31:0] <= 32'h00000000;
   else 
      csr_rdata[31:0] <=  rdata_comb[31:0];

always @ (*)
  begin
     rdata_comb = 32'h0;
     if (re_csr0) rdata_comb [31:0] = csr0_reg[31:0];
     else if (re_csr1) rdata_comb [31:0] = csr1_reg[31:0];
     else if (re_csr2) rdata_comb [31:0] = csr2_reg[31:0];
  end

spi_buf_ram 
  #(
    .DWIDTH(32),          // buffer Input data width
    .DEPTH (BUF_SIZE)         // buffer Depth
    ) sspi_tx_buffer
(
    .wr_clk(avmm_clk),     
    .wr_en(tx_buf_we),    
    .wr_addr(tx_buf_waddr[BUF_ADWIDTH-1:0]), //addr is per word 
    .wr_data(tx_buf_wdata),
    .rd_clk(sclk),
    .rd_addr(tx_buf_raddr),        //addr is per word
    .rd_data(tx_buf_rdata)
);

spi_buf_ram 
  #(
    .DWIDTH(32),          // buffer Input data width
    .DEPTH (BUF_SIZE)   // buffer Depth
    ) sspi_rx_buffer
(
    .wr_clk(sclk),
    .wr_en(rx_buf_we),
    .wr_addr(rx_buf_waddr), //addr is per word
    .wr_data(rx_buf_wdata[31:0]),
    .rd_clk(avmm_clk),
    .rd_addr(rx_buf_raddr[BUF_ADWIDTH-1:0]),        //addr is per word
    .rd_data(rx_buf_rdata)
);
endmodule
