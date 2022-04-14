// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2019 Intel Corporation.
//-----------------------------------------------------------------------------------------------//
// This module handle SPI bus side interface:
// Receive command from AVMM domain register.
// Receive control info from AVMM domain register (skew/delay for this static info enforced by SDC)
// Generate counter to shifting out miso from tx buffer and shifting in mosi to rx buffer 
// Only SPI mode 0 is supported. SCLK is free running. 
//-----------------------------------------------------------------------------------------------//
`timescale 1ps / 1ps
module mspi_intf
#(
    parameter SS_WIDTH = 4,
    parameter BUF_SIZE = 256,
    parameter BUF_ADWIDTH = $clog2(BUF_SIZE)
)(

//To TX/RX Buffer
output reg [31:0]            rx_buf_wdata,
output reg                   rx_buf_we,
output reg [BUF_ADWIDTH-1:0] rx_buf_waddr,
output reg [BUF_ADWIDTH-1:0] tx_buf_raddr,
input  [31:0]                tx_buf_rdata,
output                       spi_active,

//Contro from CSR
input                        avmm_clk,
input                        rst_n_avmm,
input  [31:0]                cmd_reg,    //From avmm clock domain

//SPI interface signal
input                        rst_n_sclk,
input                        sclk,       //Free running SPI clock out
output reg [SS_WIDTH-1:0]    ss_n,
output reg                   mosi,
input      [SS_WIDTH-1:0]    miso
);
////////////////////////////////////////////////////////////////////////
//cmd_reg is from avmm_clk domain. because avmm_clk and spi clock is 
//totally async, need to make sure start_trans stretch enough both high
//and low not to miss the pulse to sclk when sclk is too slow compare to 
//avmm_clk
////////////////////////////////////////////////////////////////////////
localparam ST_ZERO      = 2'b00;
localparam ST_WT_4_ONE  = 2'b01;
localparam ST_ONE       = 2'b10;
localparam ST_WT_4_ZERO = 2'b11;

logic [31:0] cmd_reg_sync;
logic [1:0] cdc_st;
logic  start_trans, cdc_req;
logic cdc_req_aclk, cdc_ack_sclk;
logic mux_miso;

always_ff @(posedge sclk or negedge rst_n_sclk)
 if (!rst_n_sclk) begin
      start_trans <= '0;
      cdc_st <= ST_ZERO;
      cdc_req <= '0;
 end else begin
      case (cdc_st)
        ST_ZERO:      if (cmd_reg_sync[0] & ~cdc_ack_sclk) begin  
                           cdc_st <= ST_WT_4_ONE;
                           cdc_req <= 1'b1;
                           start_trans <= 1'b0;
                      end
        ST_WT_4_ONE:  if (cdc_ack_sclk) begin
                           cdc_st <= ST_ONE;
                           cdc_req <= 1'b0;
                           start_trans <= 1'b1;
                      end
        ST_ONE:       if (~cmd_reg_sync[0]  &  ~cdc_ack_sclk) begin
                           cdc_st <= ST_WT_4_ZERO;
                           cdc_req <= 1'b1; 
                           start_trans <= 1'b1;
                      end
        ST_WT_4_ZERO: if (cdc_ack_sclk == 1'b1) begin
                           cdc_st <= ST_ZERO;
                           cdc_req <= 1'b0;
                           start_trans <= 1'b0;
                      end
      endcase
 end 

//////////////////////////////////////////////////////////////////////////////////
//This multibit register go through syncronizer is static that constrained by SDC
//so that skew should not be worry about
/////////////////////////////////////////////////////////////////////////////////

    spi_bitsync #(.DWIDTH(32)) bitsync2_cmd_reg
       (
        .clk      (sclk),
        .rst_n    (rst_n_sclk),
        .data_in  (cmd_reg[31:0]),
        .data_out (cmd_reg_sync[31:0])
        );


    spi_bitsync sync_req_aclk 
       (
        .clk      (avmm_clk),
        .rst_n    (rst_n_avmm),
        .data_in  (cdc_req),
        .data_out (cdc_req_aclk)
        );
    spi_bitsync sync_req_sclk 
       (
        .clk      (sclk),
        .rst_n    (rst_n_sclk),
        .data_in  (cdc_req_aclk),
        .data_out (cdc_ack_sclk)
        );

/////////////////////////////////////////////////////////////////////////
wire start_trans_sync2, start_pulse;
reg  start_trans_d1, trans_enable, trans_enable_d;
reg [31:0] rx_data, tx_data;
reg [BUF_ADWIDTH+4:0] full_counter;

//Generate start pulse in sclk domain
always_ff @(posedge sclk or negedge rst_n_sclk)
 if (!rst_n_sclk) start_trans_d1 <= '0;
 else start_trans_d1 <= start_trans;

assign start_pulse = start_trans & !start_trans_d1;

wire [BUF_ADWIDTH-1:0] burst_len_wd = cmd_reg_sync[BUF_ADWIDTH+1:2];
wire [1:0] cs_sel = cmd_reg_sync[31:30];

///////////////////////////////////////////////////////////
// Generate mosi from transfer buffer
// User are responsible for the format.
//////////////////////////////////////////////////////////
wire [BUF_ADWIDTH-1:0] wd_count = full_counter[BUF_ADWIDTH+4:5];
wire [4:0] bit_count = full_counter[4:0];
wire [BUF_ADWIDTH-1:0] last_wd   = burst_len_wd;
wire       last_bit  = (&bit_count);

assign spi_active = trans_enable | trans_enable_d;

always_ff @(posedge sclk or negedge rst_n_sclk)
 if (!rst_n_sclk) begin
       trans_enable <= '0;
       trans_enable_d <= '0;
       full_counter <= '0;
       tx_buf_raddr <= '0;
       tx_data      <= '0;
 end
 else begin
 
       if (start_pulse) trans_enable <= 1'b1;
       else if ((wd_count == last_wd) && last_bit)  trans_enable <= '0;
       trans_enable_d <= trans_enable;

       if (trans_enable) full_counter <= full_counter + 1'b1;
       else full_counter <= '0;

       if (start_pulse) tx_buf_raddr <= tx_buf_raddr + 1'b1;
       else if (last_bit) tx_buf_raddr <= tx_buf_raddr + 1'b1; 
       else if (~spi_active) tx_buf_raddr <= '0;

       if (start_pulse) tx_data <= tx_buf_rdata;
       else if (&full_counter[4:0]) tx_data <= tx_buf_rdata;
       else tx_data <= {tx_data[30:0], 1'b0};
 end

//4:1 mux to select miso from multiple slave.
//If pin is limited, miso line can be shared with tristate in slave miso output buffer.
assign mux_miso = cs_sel[1]? (cs_sel[0]? miso[3] : miso[2]) : (cs_sel[0] ? miso[1] : miso[0]);

always_ff @(negedge sclk or negedge rst_n_sclk)
 if (!rst_n_sclk) begin
    mosi <= '0;
    ss_n <= 4'b1111;
 end
 else begin
    if (trans_enable) mosi <= tx_data[31];
    else              mosi <= 1'b0;
    case (cs_sel) 
      2'b00: ss_n <= {3'b111, ~trans_enable};
      2'b01: ss_n <= {2'b11, ~trans_enable, 1'b1};
      2'b10: ss_n <= {1'b1, ~trans_enable, 2'b11};
      2'b11: ss_n <= {~trans_enable, 3'b111};
    endcase
 end
///////////////////////////////////////////////////////////
// Convert miso to receiver buffer
///////////////////////////////////////////////////////////
assign rx_buf_wdata = rx_data;
always_ff @(posedge sclk or negedge rst_n_sclk)
 if (!rst_n_sclk) begin
    rx_data <= '0;
    rx_buf_we <= '0;
    rx_buf_waddr <= '0;
 end
 else begin
    if (&ss_n == 1'b0) rx_data[31:0] <= {rx_data[30:0], mux_miso};
    rx_buf_we <= &full_counter[4:0];
    rx_buf_waddr <= full_counter[BUF_ADWIDTH+4:5];
 end

endmodule
