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

module spis_intf (
// SPI Interface
input logic 		rst_n,
input logic		sclk,
input logic		mosi,
input logic		ss_n,

input logic	[31:0]	tx_rdata,


output logic		ssn_off_pulse,
output logic		cmd_is_read,
output logic		cmd_is_write,
output logic		bc_zero,
output logic		miso,
output logic		spi_write,  // to spisreg_top for spi write indication
output logic 		spi_read,   // to spisreg_top for spi read indication
output logic            single_read,
output logic	[15:0]	spi_wr_addr_2reg,   // to spisreg_top for spi read indication
output logic	[15:0]	spi_rd_addr,   // to spisreg_top for spi read indication
output logic	[31:0]  dbg_bus0,
output logic	[31:0]  rx_wdata
);

logic	[31:0]	rx_shift_reg;
logic   [31:0]	tx_shift_reg; 
logic   [4:0]	rx_count; 
logic   [4:0]	tx_count; 
logic   [31:0]	tx_rdata_reg; 
logic 		flag_word; 	// Indicates that first word is received. 
				// Word received after ss_n 1->0
logic	[7:0]	cmd_rw;
logic	[7:0]	cmd_brstlen;
logic	[15:0]	cmd_addr;
logic		cmd_recvd;

logic 	[15:0]	wrbuf_addr;
logic 	[15:0]	rdbuf_addr;

logic 		flag_word_q;    // delayed version of flag_word

logic		rx_load;
logic		tx_load;
logic		rx_data_update;

logic		read;
logic		write;
logic	[7:0]	burstlength;
logic	[15:0]	reg_addr;
logic		sclk_inv;
logic		ssn_neg;
logic		ssn_d1;
logic		ssn_d2;   
logic		ssn_int; 

logic 	[2:0]	cur_st;
logic	[2:0]	nxt_st;
logic	[7:0]	burstcount;

localparam	STATE_IDLE	= 3'h0;
localparam	STATE_CMD	= 3'h1;
localparam	STATE_RD	= 3'h2;
localparam	STATE_FRD	= 3'h3;
localparam	STATE_WR	= 3'h4;
localparam	STATE_FWR	= 3'h5;
localparam	STATE_END_WR	= 3'h6;
localparam	STATE_END_RD	= 3'h7;

// CPOL = 0, CPHA = 0
// Receive data (MISO) is captured on the clk rising (LE) edge
// Transmit data (MOSI) is launched on the clk falling (TE) edge 


assign dbg_bus0[31:0] = ({{13{1'b0}},cur_st,burstcount,cmd_brstlen}); 

assign sclk_inv = ~sclk;


// Receive logic 
assign rx_load = flag_word ^ flag_word_q;

logic sclk_rx;  
assign sclk_rx = ~sclk;

always_ff @ (posedge sclk_inv or negedge rst_n) 
	if (~rst_n) 
           ssn_neg <= 1'b0;
        else 
           ssn_neg <= ss_n;

always_ff @ (posedge sclk or negedge rst_n) 
	if (~rst_n) begin  
	   ssn_d1	<= 1'b0;
	   ssn_d2	<= 1'b0; 
         end
	else begin 
	   ssn_d1	<= ss_n;
	   ssn_d2	<= ssn_d1;  
         end


assign ssn_off_pulse = ssn_d1 & ~ssn_d2; 

logic ssn_on_pulse;     
assign ssn_on_pulse = ~ssn_d1 & ssn_d2;     

logic ss_on_valid;
always_ff @ (posedge sclk or negedge rst_n) 
	if (~rst_n) 
          ss_on_valid <= 1'b0;
        else if (ss_n) 
          ss_on_valid <= 1'b0;
        else if (ssn_on_pulse)
          ss_on_valid <= 1'b1;

assign ssn_int = ss_n; // Trying this quick change to check impact

logic rx_data_update_cmb; 
assign rx_data_update_cmb = cmd_recvd ? rx_load : 1'b0; 

always_ff @ (posedge sclk or negedge rst_n) 
	if (~rst_n) 
	   rx_data_update	<= 'b0;
	else 
	   rx_data_update	<= rx_data_update_cmb;

logic [15:0] spi_wr_addr; 		// to capture the wr address to register


 always_ff @ (posedge sclk or negedge rst_n)
 	if (~rst_n) begin
 	   rx_wdata	<= 'b0;
 	   spi_wr_addr_2reg <= 'b0;
          end
         else if (rx_load) begin 
  	   rx_wdata <= rx_shift_reg;	
  	   if (cmd_addr == 16'h0200)
 	    spi_wr_addr_2reg <= 16'h0200;
            else 
 	    spi_wr_addr_2reg <= spi_wr_addr;
          end

assign bc_zero = burstcount == 8'b0;

assign spi_read  = (~single_read & tx_count == 'd28 & burstcount != 'd0) ? 1'b1 :
                   (tx_count == 'd28 ) ? 1'b1 : 1'b0;
assign spi_write = rx_data_update;

assign spi_wr_addr = (cmd_is_write) ? reg_addr : wrbuf_addr;


assign spi_rd_addr = ((cmd_is_read) & (cmd_addr == 16'h1000)) ? 16'h1000 :
                     (single_read) ? reg_addr : 16'h0000; // to account for tthe firs read 



always_ff @ (posedge sclk or negedge rst_n) 
	if (~rst_n)
	 begin
	   flag_word    <= 'b0;
	   flag_word_q  <= 'b0;
           rx_shift_reg <= 'b0;
           rx_count	<= 5'b00000;
           
         end
	else if (ssn_int) 
	 begin
	   flag_word    <= 'b0;
	   flag_word_q  <= 'b0;
           rx_shift_reg <= 'b0;
           rx_count	<= 5'b00000;
           
         end
        else
         begin
	 if (ssn_int == 0) begin 
	   if (rx_count == 5'b11111) begin
            flag_word   <= ~flag_word;
            end
            flag_word_q <= flag_word;
 	   rx_shift_reg <= {rx_shift_reg[30:0],mosi};
           rx_count     <= rx_count + 1'b1;  
         end //ss_N
	end //else


always_ff @ (posedge sclk or negedge rst_n) 
	if (~rst_n)  begin
	   cmd_recvd	<= 'b0;
	end
	else if (ssn_int)  begin
	   cmd_recvd	<= 'b0;
	end
	else if (rx_load & flag_word) begin 
	   cmd_recvd	<= 'b1;
	end


always_ff @ (posedge sclk or negedge rst_n) 
	if (~rst_n)  begin
	   cmd_rw	<= 8'hFF; // Setting it to unsed value to prevent default command
	   cmd_brstlen	<= 'b0;
	   cmd_addr	<= 'b0;
	end
	else if (ssn_int)  begin
	   cmd_rw	<= 8'hFF; // Setting it to unsed value to prevent default command
	   cmd_brstlen	<= 'b0;
	   cmd_addr	<= 'b0;
	end
	else if (rx_load & ~cmd_recvd) begin
	   cmd_rw	<= rx_shift_reg[31:24];
	   cmd_brstlen	<= rx_shift_reg[23:16];
	   cmd_addr	<= rx_shift_reg[15:0];
	end

always_comb begin
	read 	= 1'b0;
	write 	= 1'b0;
	burstlength = 'b0;
	single_read = 1'b0;
	if (cmd_rw == 8'h0) begin
	  read 		= 1'b1;
	  burstlength 	= 8'b0000_0000; // To account for first read
          single_read   = 1'b1;
        end 
	else if (cmd_rw == 8'h1) begin
	  write 	= 1'b1;
	  burstlength 	= 8'b0000_0001;
	end
	else if (cmd_rw == 8'h20) begin
	  read 		= 1'b1;
 	  burstlength 	= cmd_brstlen; // To account for first read
	end
	else if (cmd_rw == 8'h21) begin
	  write 	= 1'b1;
	  burstlength 	= cmd_brstlen;
	end
end


// Transmit logic

always_ff @ (posedge sclk or negedge rst_n) 
	if (~rst_n)
	   tx_rdata_reg	<= 'b0;
	else if (ssn_int)
	   tx_rdata_reg	<= 'b0;
        else if (spi_read)
	   tx_rdata_reg <= tx_rdata;




always_ff @ (posedge sclk or negedge rst_n) 
	if (~rst_n)
	 begin
	   tx_count	<= 5'b00000;  
           tx_load	<= 'b0;
         end
	else if (ssn_int)
	 begin
	   tx_count	<= 5'b00000;  
           tx_load	<= 'b0;
         end
	else 
	 begin
	   tx_count 	<= tx_count + 1'b1;
 	  if (tx_count == 5'b11111) begin
           tx_load	<= 1'b1; 
	   end
	   else begin
	     tx_load      <= 1'b0;
           end
          end


always_ff @ (posedge sclk_inv or negedge rst_n)
	if (~rst_n)
	   tx_shift_reg <= 'b0;     
	else if (ssn_int)
	   tx_shift_reg <= 'b0;     
	else if (tx_load == 1'b1)
	   tx_shift_reg <= tx_rdata_reg;     
	else
	   tx_shift_reg <= {tx_shift_reg[30:0],1'b0};    

assign miso = tx_shift_reg[31];  

// SPIS S/M

always_ff @ (posedge sclk or negedge rst_n)
	if (~rst_n)
	 cur_st <= STATE_IDLE;
	else if (ssn_int)
	 cur_st <= STATE_IDLE;
	else
	 cur_st <= nxt_st;

       
always_ff @ (posedge sclk or negedge rst_n)
	if (~rst_n) begin
	 burstcount <= 'b0;           
	 reg_addr   <= 'b0;
	 wrbuf_addr <= 16'h0200;     
	 rdbuf_addr <= 16'h1000;    
	end
	else if (ssn_int) begin
	 burstcount <= 'b0;        
	 reg_addr   <= 'b0;
	 wrbuf_addr <= 16'h0200;     
	 rdbuf_addr <= 16'h1000;     
	end
	else if (cur_st == STATE_CMD) begin 
	 reg_addr   <= cmd_addr[15:0];
	 burstcount <= burstlength; 
        end
	else if (cmd_is_write  & (cur_st == STATE_WR) & rx_load ) begin 
          burstcount <= burstcount - 1'b1; 
        end
	else if (cmd_is_write  & (cur_st == STATE_FWR)) begin 
	  wrbuf_addr <= wrbuf_addr;
	  reg_addr <= reg_addr;
        end
	else if (cmd_is_read & (cur_st == STATE_RD) & tx_load) begin 
          burstcount <= burstcount - 1'b1; 
        end
	else if (cmd_is_read & (cur_st == STATE_FRD)) begin 
	  rdbuf_addr <= rdbuf_addr;
	  reg_addr <= reg_addr;
        end
       
always_comb begin
	cmd_is_read 	= 1'b0;
	cmd_is_write	= 1'b0;
	nxt_st 		= cur_st;
	case (cur_st)
	STATE_IDLE	: begin
			   nxt_st = (cmd_recvd) & ss_on_valid ? STATE_CMD : cur_st; 
			  end

	STATE_CMD	: begin
			   if (read) begin 
			    cmd_is_read = 1'b1;
			    nxt_st = STATE_RD;
                           end
			   else if (write) begin
			    cmd_is_write = 1'b1;
			    nxt_st = STATE_WR;
			   end
                           else
			    nxt_st = STATE_IDLE;
			  end
			

	STATE_WR     	: begin 
			   if (rx_load) begin 
			    nxt_st = STATE_FWR;
                           end
			    cmd_is_write = 1'b1;
                          end
			    
	STATE_FWR     	: begin 
			   if (~rx_data_update) begin  
 	                    if (~(burstcount == {8{1'b0}})) begin 
			     nxt_st = STATE_WR; 
                            end
                            else begin
                             nxt_st = STATE_END_WR;
                           end
			    cmd_is_write = 1'b1;
			  end
                         end
 
      	STATE_END_WR	: begin
                           nxt_st = STATE_IDLE;
 			  end	
			    
	STATE_RD     	: begin 
			   if (spi_read) begin 
                            nxt_st = STATE_FRD;
			   end
			    cmd_is_read = 1'b1;
			  end

	STATE_FRD	: begin
			   if (~tx_load) begin 
 	                    if (~(burstcount == {8{1'b0}})) begin 
			     nxt_st = STATE_RD; 
                            end
                            else begin
                             nxt_st = STATE_END_RD;
                           end
			    cmd_is_read = 1'b1;
			  end
			 end

      	STATE_END_RD	: begin
                           nxt_st = STATE_IDLE;
 			  end	

	default		: begin
			   nxt_st = STATE_IDLE;
			  end
		endcase
        end

endmodule






