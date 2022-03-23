// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
//-----------------------------------------------------------------------------------------------//
// 07/16/21
// This module handles AVMM side read/write to AIB PHY CSR. Then read/write to buffer
//-----------------------------------------------------------------------------------------------//

`timescale 1ps / 1ps
module sspi_avmm_intf #(
      parameter AVMM_ADDR_WIDTH=16,
      parameter BUF_SIZE = 256,
      parameter BUF_ADWIDTH = $clog2(BUF_SIZE)
   ) (
   input   logic                         avmm_clk, // AVMM Slave interface
   input   logic                         avmm_rst_n,
   //AVMM interface 0
   output  logic                         o_avmm0_write,
   output  logic                         o_avmm0_read,
   output  logic  [AVMM_ADDR_WIDTH-1:0]  o_avmm0_addr,
   output  logic  [31:0]                 o_avmm0_wdata,
   output  logic  [3:0]                  o_avmm0_byte_en,
   input   logic  [31:0]                 i_avmm0_rdata,
   input   logic                         i_avmm0_rdatavalid,
   input   logic                         i_avmm0_waitrequest,

   //AVMM interface 1
   output  logic                         o_avmm1_write,
   output  logic                         o_avmm1_read,
   output  logic  [AVMM_ADDR_WIDTH-1:0]  o_avmm1_addr,
   output  logic  [31:0]                 o_avmm1_wdata,
   output  logic  [3:0]                  o_avmm1_byte_en,
   input   logic  [31:0]                 i_avmm1_rdata,
   input   logic                         i_avmm1_rdatavalid,
   input   logic                         i_avmm1_waitrequest,

   //AVMM interface 2

   output  logic                         o_avmm2_write,
   output  logic                         o_avmm2_read,
   output  logic  [AVMM_ADDR_WIDTH-1:0]  o_avmm2_addr,
   output  logic  [31:0]                 o_avmm2_wdata,
   output  logic  [3:0]                  o_avmm2_byte_en,
   input   logic  [31:0]                 i_avmm2_rdata,
   input   logic                         i_avmm2_rdatavalid,
   input   logic                         i_avmm2_waitrequest,

   input   logic [31:0]                  csr0_reg,
   input   logic [31:0]                  csr1_reg,
   input   logic [31:0]                  rx_buf_rdata,
   output  logic [BUF_ADWIDTH-1:0]       rx_buf_raddr, 
   output  logic [31:0]                  tx_buf_wdata,
   output  logic [BUF_ADWIDTH-1:0]       tx_buf_waddr,
   output  logic                         tx_buf_we,
   output  logic                         trans_done
);

localparam SM_IDLE              = 3'h0;
localparam SM_WRD               = 3'h1;
localparam SM_WAIT              = 3'h2;
localparam SM_CHNL_INC          = 3'h3;
localparam SM_DONE              = 3'h4;

logic [2:0] sm_base;
logic [8:0] burst_cnt;
wire  [8:0] burst_len = csr0_reg[29:21];
wire  [2:0] slave_sel = {(csr0_reg[20:19] == 2'b10),(csr0_reg[20:19] == 2'b01),(csr0_reg[20:19] == 2'b00)};   
wire  [16:0] start_addr= csr0_reg[18:2];
wire  rdnwr = csr0_reg[1];
logic trans_valid;
wire  [5:0] auto_chan_num = csr1_reg[21:16];
wire  [15:0] auto_offset_addr = csr1_reg[15:0];
logic [15:0] chanxoffset;
logic [16:0] avmm_addr;
logic avmm_rdatavalid, avmm_waitrequest;
logic [31:0] avmm_rdata;
logic [2:0] avmm_write, avmm_read;
logic [5:0] chan_cnt;

    spi_bitsync bitsync2_start_trans
       (
        .clk      (avmm_clk),
        .rst_n    (avmm_rst_n),
        .data_in  (csr0_reg[0]),
        .data_out (trans_valid)
        );


assign {o_avmm2_write,o_avmm1_write,o_avmm0_write} = avmm_write;
assign {o_avmm2_read, o_avmm1_read, o_avmm0_read} = avmm_read;
assign {o_avmm2_wdata,o_avmm1_wdata,o_avmm0_wdata} = {3{rx_buf_rdata}}; 
assign {o_avmm2_byte_en,o_avmm1_byte_en,o_avmm0_byte_en} = {3{4'hf}};
assign {o_avmm2_addr,o_avmm1_addr,o_avmm0_addr} = {3{avmm_addr}};
assign tx_buf_wdata = avmm_rdata;
assign tx_buf_we = avmm_rdatavalid;

always @* begin
   case(csr0_reg[20:19])
      2'b00: begin
               avmm_rdatavalid  = i_avmm0_rdatavalid;
               avmm_waitrequest = i_avmm0_waitrequest;
               avmm_rdata       = i_avmm0_rdata;
             end
      2'b01: begin
               avmm_rdatavalid  = i_avmm1_rdatavalid;
               avmm_waitrequest = i_avmm1_waitrequest;
               avmm_rdata       = i_avmm1_rdata;
             end
      2'b10: begin
               avmm_rdatavalid  = i_avmm2_rdatavalid;
               avmm_waitrequest = i_avmm2_waitrequest;
               avmm_rdata       = i_avmm2_rdata;
             end
      2'b11: begin
               avmm_rdatavalid  = 1'b0;
               avmm_waitrequest = 1'b1;
               avmm_rdata       = '0;
             end
      endcase
end

always @(posedge avmm_clk or negedge avmm_rst_n) begin : avmm_fsm
   if (avmm_rst_n==1'b0) begin
      avmm_write      <= '0;
      avmm_read       <= '0; 
      avmm_addr       <= '0;
      rx_buf_raddr    <= '0;
      tx_buf_waddr    <= '0;
      burst_cnt       <= '0;
      chan_cnt        <= '0;
      chanxoffset     <= '0;
      trans_done      <= '0;
      sm_base         <= SM_IDLE; 
   end
   else begin
      
      case(sm_base)
         SM_IDLE : begin
                     if (trans_valid) begin
                        sm_base <= SM_WRD;
                        avmm_write[2:0]   <= {3{~rdnwr}} & slave_sel[2:0];
                        avmm_read[2:0]    <= {3{rdnwr}} & slave_sel[2:0];
                        avmm_addr         <=  start_addr[16:0];
                        chan_cnt          <=  '0;
                        burst_cnt         <=  '0;
                        chanxoffset       <= '0;
                     end else begin
                        sm_base <= SM_IDLE;
                     end
                   end 
         SM_WRD : begin
                      tx_buf_waddr <= tx_buf_waddr + avmm_rdatavalid;
                      if (~avmm_waitrequest) begin
                        avmm_write      <= 3'b0;            //release control when slave is ready 
                        avmm_read       <= 3'b0;
                        if (burst_cnt == burst_len)
                           rx_buf_raddr <= '0;
                        else
                           rx_buf_raddr <= rx_buf_raddr + 1'b1;

                        if (~rdnwr) begin
                              sm_base <= SM_WAIT;          //Write
                        end else begin
                              if (avmm_rdatavalid) begin  //For case has rdvlid and ~avmm_waitrequest
                                    sm_base <= SM_WAIT;   //happen at the same time. Not for our case.
                              end else begin 
                                   sm_base <= SM_WRD;
                              end
                         end  // Read   
                      end else if (avmm_rdatavalid) begin
                        sm_base <= SM_WAIT;
                      end
                  end
         SM_WAIT  : begin
                      if (burst_cnt == burst_len) begin
                         sm_base <= SM_CHNL_INC;
                         burst_cnt <= '0; 
                         chanxoffset <= chanxoffset + auto_offset_addr;
                      end else begin
                         burst_cnt <= burst_cnt + 1'b1;
                         avmm_addr <= avmm_addr + 3'h4;
                         sm_base <= SM_WRD; 
                         avmm_write[2:0]   <= {3{~rdnwr}} & slave_sel[2:0];
                         avmm_read[2:0]    <= {3{rdnwr}} & slave_sel[2:0];
                      end
                    end
         SM_CHNL_INC : begin
                         if (chan_cnt == auto_chan_num) begin
                           sm_base <= SM_DONE;
                           trans_done <= 1'b1;
                         end else begin
                           sm_base <= SM_WRD;
                           avmm_write[2:0] <= {3{~rdnwr}} & slave_sel[2:0];
                           avmm_read[2:0]  <= {3{rdnwr}} & slave_sel[2:0];
                           avmm_addr       <=  start_addr[16:0] + chanxoffset;
                           chan_cnt        <=  chan_cnt + 1'b1;
                         end
                         rx_buf_raddr    <=  '0;
                         burst_cnt       <=  '0;
                       end
         SM_DONE : begin
                     avmm_write[2:0] <= 3'h0;
                     avmm_read[2:0]  <= 3'h0;
                     tx_buf_waddr    <= '0;
                     if (trans_valid) begin
                           sm_base <= SM_DONE;
                           trans_done <= 1'b1;
                     end  else begin            
                           sm_base <= SM_IDLE;
                           trans_done <= 1'b0;
                     end
                   end
         default  : sm_base <= SM_IDLE;
      endcase
   end
end : avmm_fsm

endmodule 
