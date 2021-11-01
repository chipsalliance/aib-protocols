////////////////////////////////////////////////////////////
//
//        Copyright (C) 2021 Eximius Design
//                All Rights Reserved
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Eximius Design
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
//Functional Descript:
//
//
//
////////////////////////////////////////////////////////////

module spisreg_top 
#( 
parameter FIFO_WIDTH = 32,
parameter FIFO_DEPTH = 64
) 
(
input	logic		sclk,
input	logic		s_avmm_clk,
input	logic		rst_n,
input	logic		s_avmm_rst_n,
input	logic		ss_n,
// spi read/write
output 	logic	[31:0]	miso_data, // spi rdata, - read data from slave for master rd_buf
input	logic		ssn_off_pulse_sclk,
input	logic		spi_write, // from m_cmd - read data from write buf and send to slave
input	logic		spi_read,  // from m_cmd - receive read data from slave and write to read buf
input	logic	[15:0] 	spi_wr_addr,  // from spim intf 
input	logic	[15:0] 	spi_rd_addr,  // from spim intf 
input	logic	[31:0] 	mosi_data, //spi wdata, - write data from master to slave wr_buf
input   logic	[31:0]  dbg_bus0,
input   logic	[31:0]  dbg_bus1,

input 	logic 		cmd_is_read,
input	logic		bc_zero,
input   logic           single_read,
// avmm read/write
output 	logic	[31:0]	reg2avb_wdata, // write data from spis wr_buf for AVB channel
input	logic		avb2reg_write, // Write signal for AVB channel data write to s_rbuf
input	logic	[15:0] 	avb2reg_addr,  // Spis reg/buf address  for read wr_buf or write to rd_buf from AVB 
input	logic	[31:0] 	avb2reg_rdata, // AVB chnl rdata to spis rd_buf
input	logic		avb2reg_read_pulse,



// Outputs from m_cmd register
output	logic	[7:0] 	avmm_brstlen,
output	logic	[1:0]	avmm_sel,
output	logic	[16:0]	avmm_offset,
output	logic		avmm_rdnwr,

output	logic		avmm_transvld,
output	logic		avmm_active,
input 	logic		avmmtransvld_up

);

// Local 
localparam FIFO_DEPTH_WIDTH = $clog2(FIFO_DEPTH);
localparam FIFO_ADDR_WIDTH = FIFO_DEPTH_WIDTH + 1;


logic 	[(FIFO_WIDTH-1):0]	wbuf_fifo_rddata;
logic 	[(FIFO_WIDTH-1):0]	wbuf_fifo_wrdata;
logic 	[(FIFO_ADDR_WIDTH-1):0]	wbuf_rd_numfilled;
logic 	[(FIFO_ADDR_WIDTH-1):0]	wbuf_wr_numempty;

logic 	[(FIFO_WIDTH-1):0]	rbuf_fifo_rddata;
logic 	[(FIFO_WIDTH-1):0]	rbuf_fifo_wrdata;
logic 	[(FIFO_ADDR_WIDTH-1):0]	rbuf_rd_numfilled;
logic 	[(FIFO_ADDR_WIDTH-1):0]	rbuf_wr_numempty;

logic				wbuf_write_push;
logic				wbuf_read_pop;
logic				rbuf_write_push;
logic				rbuf_read_pop;


logic				wbuf_wr_overflow_pulse;
logic				wbuf_rd_underflow_pulse;
logic				rbuf_wr_overflow_pulse;
logic				rbuf_rd_underflow_pulse;

logic				wbuf_wr_overflow_sticky;
logic				wbuf_rd_underflow_sticky;
logic				rbuf_wr_overflow_sticky;
logic				rbuf_rd_underflow_sticky;

logic				wbuf_wr_soft_reset;
logic				wbuf_rd_soft_reset;
logic				rbuf_wr_soft_reset;
logic				rbuf_rd_soft_reset;

logic                           wbuf_wr_full;
logic                           wbuf_rd_empty;
logic                           rbuf_wr_full;
logic                           rbuf_rd_empty;

logic 	[31:0]	wdata_reg;
logic 	[31:0]	rdata_reg;
logic 	[15:0]	addr;
logic 	[15:0]	spi_addr;

logic 	[31:0] 	s_status_in;
logic 	[31:0] 	s_diag0_in;
logic 	[31:0] 	s_diag1_in;

logic 	[31:0] 	s_cmd;

logic 	[31:0] 	s_status;
logic 	[31:0] 	s_diag0;
logic 	[31:0] 	s_diag1;

logic	write_reg;
logic	read_reg;


logic 	spi_write_aclk_pulse; // sync'd to aclk

logic 	rd_buf_access;
logic 	wr_buf_access;

logic 	ssn_off_pulse_aclk;
logic 	ssn_off_pulse_sclk_d1;
logic   single_read_d1;

logic 	wbuf_rd_empty_d1;
logic 	wbuf_rd_empty_pulse;
logic   spi_rbuf_access;
logic	avmm_rbuf_access;
logic	spi_wbuf_access;
logic	avmm_wbuf_access;

logic	wbuf_rd_rst;
logic	rbuf_rd_rst;
logic 	avmm_cmd_rd;
logic 	avmm_cmd_wr;
logic   load_dbg_bus0;
logic   load_dbg_bus1;

always_ff @ (posedge sclk or negedge rst_n)
        if (~rst_n) 
           ssn_off_pulse_sclk_d1 <= 1'b0;
        else
           ssn_off_pulse_sclk_d1 <= ssn_off_pulse_sclk;

always_ff @ (posedge sclk or negedge rst_n)
        if (~rst_n) 
           single_read_d1 <= 1'b0;
        else
           single_read_d1 <= single_read;




pulse_sync spiwrite_pulse_sync (
        .dest_pulse (spi_write_aclk_pulse),
        .clk_dest (s_avmm_clk),
        .rst_dest_n (s_avmm_rst_n),
        .clk_src (sclk),
        .rst_src_n (rst_n),
        .src_pulse (spi_write)
        );


pulse_sync ssnoff_pulse_sync (
        .dest_pulse (ssn_off_pulse_aclk),
        .clk_dest (s_avmm_clk),
        .rst_dest_n (s_avmm_rst_n),
        .clk_src (sclk),
        .rst_src_n (rst_n),
        .src_pulse (ssn_off_pulse_sclk_d1)
        );

assign avmm_active = avmm_transvld;



assign load_dbg_bus0 = ssn_off_pulse_aclk;
assign load_dbg_bus1 = avmmtransvld_up;  

always_ff @ (posedge s_avmm_clk or negedge s_avmm_rst_n)
        if (~s_avmm_rst_n) 
          wbuf_rd_empty_d1 <= 1'b0;	
	else 
         wbuf_rd_empty_d1 <= wbuf_rd_empty;


assign wbuf_rd_empty_pulse  = wbuf_rd_empty & ~wbuf_rd_empty_d1; 


assign spi_rbuf_access  = ((16'h1000 <= spi_rd_addr)  & (spi_rd_addr  <= 16'h17FF));
assign avmm_rbuf_access = ((16'h1000 <= avb2reg_addr) & (avb2reg_addr <= 16'h17FF));
assign spi_wbuf_access  = ((16'h0200 <= spi_wr_addr)  & (spi_wr_addr  <= 16'h09FF));
assign avmm_wbuf_access = ((16'h0200 <= avb2reg_addr) & (avb2reg_addr <= 16'h09FF));

assign rd_buf_access = (spi_rbuf_access | avmm_rbuf_access);
assign wr_buf_access = (spi_wbuf_access | avmm_wbuf_access);

assign spi_addr = spi_read ? spi_rd_addr : spi_wr_addr;
assign addr  = spi_addr; 

//SPI writes to registers for commands and for fifo controls
assign write_reg = spi_write_aclk_pulse; 
// avmm writes (nios) data read from avb  to read buffer 
// spi reads rd buffer for aib channel read data (miso data); 
// avmm slave reads wr buffer for aib channel write data 

//SPI reads registers during polling for command completion.
// Can also read for fifo status or debug data 
assign read_reg  = spi_read;


assign wdata_reg = mosi_data;   // SPI clock - Does not change for 32 spi clocks  
assign rbuf_fifo_wrdata = avb2reg_rdata;
assign wbuf_fifo_wrdata = mosi_data;


assign miso_data = (spi_read & spi_rbuf_access) ? rbuf_fifo_rddata : 
		   (spi_read & ~spi_rbuf_access) ? rdata_reg : 32'hdeadbeef;  


assign reg2avb_wdata = wbuf_read_pop ? wbuf_fifo_rddata : 32'b0; 


assign wbuf_write_push = ((spi_write & spi_wbuf_access) & ~avmm_cmd_rd);
assign wbuf_read_pop =   ((avb2reg_read_pulse & avmm_wbuf_access)) ;

assign rbuf_write_push = ((avb2reg_write & avmm_rbuf_access));
assign rbuf_read_pop   = (avmm_brstlen == 8'b000_0001) ?  (spi_read & spi_rbuf_access & ~rbuf_rd_empty) : 
                                                          ((~bc_zero & spi_read & spi_rbuf_access));

// assign s_cmd outputs
assign avmm_brstlen 	= s_cmd[31:24];
assign avmm_sel		= s_cmd[20:19];
assign avmm_offset	= s_cmd[18:2];
assign avmm_rdnwr	= s_cmd[1];
assign avmm_transvld	= s_cmd[0];

assign s_status_in	= 'b0;
assign s_diag0_in	= dbg_bus0;
assign s_diag1_in	= dbg_bus1;

//Use s_cmd[1] and avmm_transvld_up to determine fifo rsts 
always_ff @ (posedge s_avmm_clk or negedge s_avmm_rst_n)
        if (~s_avmm_rst_n) 
          avmm_cmd_wr <= 1'b0;	
	else if (~avmm_rdnwr & avmm_transvld)
          avmm_cmd_wr <= 1'b1;
        else if (avmmtransvld_up)
          avmm_cmd_wr <= 1'b0;	

always_ff @ (posedge sclk or negedge rst_n)
        if (~rst_n) 
          avmm_cmd_rd <= 1'b0;	
	else if (cmd_is_read & ~ss_n)
          avmm_cmd_rd <= 1'b1;
        else if (ssn_off_pulse_sclk_d1)
          avmm_cmd_rd <= 1'b0;	

//FIFO Reset logic in Slave SPI
// 
logic sft_rst_ctrl;
logic wbuf_rd_rst_cmb;
logic rbuf_rd_rst_cmb;
logic rbuf_rdsfrst_sclk;
logic wbuf_wrsfrst_sclk;


assign wbuf_rd_rst = (avmm_cmd_wr) ? wbuf_rd_empty_pulse  : 1'b0;              // read by aclk

assign rbuf_rd_rst = (avmm_cmd_rd & ~single_read_d1 ) ? ssn_off_pulse_sclk : 1'b0;


assign wbuf_rd_rst_cmb = sft_rst_ctrl ? wbuf_rd_soft_reset : wbuf_rd_rst;
assign rbuf_rd_rst_cmb = sft_rst_ctrl ? rbuf_rdsfrst_sclk : rbuf_rd_rst;
           

asyncfifo 
 #( // Paramenters
	.FIFO_WIDTH_WID		(FIFO_WIDTH), 	// Data width of the FIFO
	.FIFO_DEPTH_WID		(FIFO_DEPTH)) 	// Depth of the FIFO
i_spis_wrbuf_fifo (
   // Outputs
	.rddata			(wbuf_fifo_rddata), 
	.rd_numfilled		(wbuf_rd_numfilled), // to CSR 
	.wr_numempty		(wbuf_wr_numempty),  // to CSR
	.wr_full		(wbuf_wr_full), 	// to CSR & to spim output
	.rd_empty		(wbuf_rd_empty),	// to CSR & to spim output
	.wr_overflow_pulse	(wbuf_wr_overflow_pulse),   // sclk 
	.rd_underflow_pulse	(wbuf_rd_underflow_pulse),   // aclk
   
  // Inputs
	.clk_write		(sclk), 
	.rst_write_n		(rst_n), 
	.clk_read		(s_avmm_clk), 	
	.rst_read_n		(s_avmm_rst_n), 
	.wrdata			(wbuf_fifo_wrdata), 
	.write_push		(wbuf_write_push),
	.read_pop		(wbuf_read_pop), 
	.rd_soft_reset		(wbuf_rd_rst_cmb),  // from CSR 
	.wr_soft_reset		(1'b0) 
   );

levelsync sync_rbuf_rdsrst (
   	.dest_data (rbuf_rdsfrst_sclk),
   	.clk_dest (sclk), 
   	.rst_dest_n (rst_n), 
   	.src_data (rbuf_rd_soft_reset)
   );

levelsync sync_wbuf_rdsrst (
   	.dest_data (wbuf_wrsfrst_sclk),
   	.clk_dest (sclk), 
   	.rst_dest_n (rst_n), 
   	.src_data (wbuf_wr_soft_reset)
   );

always_ff @(posedge sclk or negedge rst_n)
       if (~rst_n)
          wbuf_wr_overflow_sticky <= 1'b0;
       else if (wbuf_wr_overflow_pulse)
          wbuf_wr_overflow_sticky <= 1'b1;              // write clk (spi)
       else if (wbuf_wrsfrst_sclk)                   
          wbuf_wr_overflow_sticky <= 1'b0;          

always_ff @(posedge s_avmm_clk or negedge s_avmm_rst_n)
       if (~s_avmm_rst_n)
          wbuf_rd_underflow_sticky <= 1'b0;
       else if (wbuf_rd_underflow_pulse)
          wbuf_rd_underflow_sticky <= 1'b1;              // Read clk (avmm)
       else if (wbuf_rd_soft_reset)                
          wbuf_rd_underflow_sticky <= 1'b0;       


// Rdbuf is read with spi clk and written with avmm clk 
asyncfifo 
 #( // Paramenters
	.FIFO_WIDTH_WID		(FIFO_WIDTH), 	// Data width of the FIFO
	.FIFO_DEPTH_WID		(FIFO_DEPTH)) 	// Depth of the FIFO
i_spis_rdbuf_fifo (
   // Outputs
	.rddata			(rbuf_fifo_rddata), 
	.rd_numfilled		(rbuf_rd_numfilled), // to CSR 
	.wr_numempty		(rbuf_wr_numempty),  // to CSR
	.wr_full		(rbuf_wr_full), 	// to CSR & to spim output
	.rd_empty		(rbuf_rd_empty),	// to CSR & to spim output
	.wr_overflow_pulse	(rbuf_wr_overflow_pulse),  //aclk
	.rd_underflow_pulse	(rbuf_rd_underflow_pulse), // sclk
   
   // Inputs
	.clk_write		(s_avmm_clk), 
	.rst_write_n		(s_avmm_rst_n), 
	.clk_read		(sclk),
	.rst_read_n		(rst_n), 
	.wrdata			(rbuf_fifo_wrdata), 
	.write_push		(rbuf_write_push),
	.read_pop		(rbuf_read_pop), 
	.rd_soft_reset		(rbuf_rd_rst_cmb),  // from CSR 
	.wr_soft_reset		(1'b0)
   );

always_ff @(posedge s_avmm_clk or negedge s_avmm_rst_n)
       if (~s_avmm_rst_n)
          rbuf_wr_overflow_sticky <= 1'b0;
       else if (rbuf_wr_overflow_pulse)
          rbuf_wr_overflow_sticky <= 1'b1;              // Write clk (avmm)
       else if (rbuf_wr_soft_reset)                  
          rbuf_wr_overflow_sticky <= 1'b0;          

always_ff @(posedge sclk or negedge rst_n)
       if (~rst_n)
          rbuf_rd_underflow_sticky <= 1'b0;
       else if (rbuf_rd_underflow_pulse)
          rbuf_rd_underflow_sticky <= 1'b1;              // Read clk (spi)
       else if (rbuf_rdsfrst_sclk)                 
          rbuf_rd_underflow_sticky <= 1'b0;       

//instanstiation of spis_reg 
spis_reg 
  i_spis_reg (
	.aclk (s_avmm_clk),
	.arst_n (s_avmm_rst_n),
	.wdata (wdata_reg),
	.write (write_reg),
	.read (read_reg),
	.addr (addr),
	.rdata (rdata_reg),
	.avmmtransvld_up (avmmtransvld_up), 
	.s_status_in (s_status_in),         
	.s_diag0_in (s_diag0_in),         
	.s_diag1_in (s_diag1_in),         
	.load_dbg_bus0 (load_dbg_bus0),
	.load_dbg_bus1 (load_dbg_bus1),
	.wbuf_wr_overflow_sticky (wbuf_wr_overflow_sticky),
	.wbuf_rd_underflow_sticky (wbuf_rd_underflow_sticky),
	.rbuf_wr_overflow_sticky (rbuf_wr_overflow_sticky),
	.rbuf_rd_underflow_sticky (rbuf_rd_underflow_sticky),
        
	.wbuf_wr_soft_reset (wbuf_wr_soft_reset),       //spi
	.wbuf_rd_soft_reset (wbuf_rd_soft_reset),       //avmm
	.rbuf_wr_soft_reset (rbuf_wr_soft_reset),       //avmm
	.rbuf_rd_soft_reset (rbuf_rd_soft_reset),       //spi
        .sft_rst_ctrl (sft_rst_ctrl),

	.s_cmd (s_cmd),
	.s_status (s_status),
	.s_diag0 (s_diag0),
	.s_diag1 (s_diag1)
);


endmodule
