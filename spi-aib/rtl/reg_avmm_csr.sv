// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2019 Intel Corporation. 
//-----------------------------------------------------------------------------------------------//
//-----------------------------------------------------------------------------------------------//
`timescale 1ps / 1ps
module reg_avmm_csr 
#(
    parameter STAT_NUM= 16,   //Maximum 16
    parameter CTRL_NUM= 256,  //Maximum 256
    parameter STAT_ADWIDTH = $clog2(STAT_NUM),
    parameter CTRL_ADWIDTH = $clog2(CTRL_NUM)
)(

//To user interface
input	logic [STAT_NUM-1:0][31:0]    user_status,
output	logic [CTRL_NUM-1:0][31:0]    user_csr,


//avmm  Interface
input                   avmm_clk,       //This block is running in avmm clk
input                   avmm_rst_n,
input [31:0]            writedata,
input                   read,
input                   write,
input [3:0]             byteenable,   //Not used
output logic [31:0]     readdata,
output logic            readdatavalid,
input [12:0]            address
);

// Protocol management
// combinatorial read data signal declaration
logic  [31:0] rdata_comb;
logic  [2:0]  read_dly;
//  Protocol specific assignment to inside signals
//
wire        we = write;
wire        re = read;
wire [12:0] addr = address;
wire [31:0] din  = writedata [31:0];

wire        sel_user_csr = ((addr[12:0] >= 13'h200)  && (addr[12:0] < (13'h200  + 4*CTRL_NUM)));    //0x200-0x600
wire        sel_status   = ((addr[12:0] >= 13'h1000) && (addr[12:0] < (13'h1000 + 4*STAT_NUM)));   //0x1000-0x1040
wire        we_user_csr  = we & sel_user_csr;


// synchronous process for the read
always @(negedge avmm_rst_n ,posedge avmm_clk)  begin 
   if (!avmm_rst_n) begin
           readdata[31:0] <= 32'h0; 
           user_csr <= '{default:32'h00};
           read_dly <= 3'h0;
           readdatavalid <= 1'b0;
   end else   begin
           readdata[31:0] <= rdata_comb[31:0];
           if (we_user_csr) user_csr[addr[CTRL_ADWIDTH-1:2]] <= din;
           read_dly <= {read_dly[1:0], read};
           readdatavalid <= read_dly[0] & ~read_dly[1];
   end


end


////////////////////////////////////////////////////////////////
// read process
// Firmware needs to make sure addr is within range of parameter
////////////////////////////////////////////////////////////////
always @ (*)
begin
   
   if (sel_status) 
        rdata_comb[31:0] = user_status[addr[4:2]];
   else if (sel_user_csr) 
        rdata_comb[31:0] = user_csr[addr[7:2]];
   else 
        rdata_comb = 32'h0;
end

endmodule
