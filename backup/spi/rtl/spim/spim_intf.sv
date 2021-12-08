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

module spim_intf (
// SPI Interface
input logic 		rst_n,
input logic		sclk_in,
input logic		miso,

input logic	[31:0]	tx_rdata,

input logic	[13:0]	spim_brstlen,
input logic		s_transvld,
input logic		spim_rdnwr,
input logic	[1:0]	spim_sselect,

output	logic   	ss_n_0,  	// slave select 0
output	logic   	ss_n_1, 	// slave select 1
output	logic   	ss_n_2,  	// slave select 2
output	logic   	ss_n_3, 	// slave select 3
output	logic 		ssn_off_pulse,
output	logic 		ssn_on_pulse,
output logic		sclk,
output logic		mosi,
output logic		spi_write,
output logic 		spi_read,
output logic		cmd_is_read,
output logic		cmd_is_write,
output logic	[15:0]	spi_wr_addr_2reg,
output logic	[15:0]	spi_rd_addr,
output logic		stransvld_up,
output logic    [31:0]  dbg_bus0,
output logic	[31:0]  rx_wdata
);

logic	[31:0]	rx_shift_reg;
logic   [31:0]	tx_shift_rega; 
logic   [31:0]	tx_shift_regb; 
logic   [4:0]	rx_count; 
logic   [4:0]	tx_count; 
logic 		flag_word; 	// Indicates that first word is received. 

logic 		flag_word_q;    // delayed version of flag_word
logic 		flag_word_q1;    // delayed version of flag_word

logic		rx_load;
logic		tx_load;
logic		inc_spi_addr;
logic		rx_data_update;
logic		s_transvld_q;
logic		s_transvld_detect;

logic 		ss_n; 	
logic 		ss_n_int; 
logic 		ss_n_dlyn;
logic 		ss_n_dly1;
logic 		ss_n_early;
logic 		ss_n_early_cmb;
logic		sclk_inv;



logic 	[2:0]	cur_st;
logic	[2:0]	nxt_st;
logic	[13:0]	burstcount;
logic	[31:0]  rx_data;
logic	[31:0]  tx_rdata_reg;

logic           mosi_int;  
logic           ss_n_0_int; 
logic           ss_n_1_int; 
logic           ss_n_2_int; 
logic           ss_n_3_int; 
logic           ss_n_cmb; 

localparam	ST_IDLE		= 3'h0;
localparam	ST_INI_CMD	= 3'h1;
localparam	ST_INI_RD	= 3'h2;
localparam	ST_INI_FRD	= 3'h3;
localparam	ST_INI_WR	= 3'h4;
localparam	ST_INI_FWR	= 3'h5;
localparam	ST_INI_END_RD	= 3'h6;


// CPOL = 0, CPHA = 0
// Receive data (MISO) is captured on the clk rising (LE) edge
// Transmit data (MOSI) is launched on the clk falling (TE) edge 


//assign slave select based on spim_sselect. 

always_comb begin
	ss_n_0_int = 1'b1;
	ss_n_1_int = 1'b1;
	ss_n_2_int = 1'b1;
	ss_n_3_int = 1'b1;
	case (spim_sselect) 
	2'b00: ss_n_0_int = ss_n;
	2'b01: ss_n_1_int = ss_n;
	2'b10: ss_n_2_int = ss_n;
	2'b11: ss_n_3_int = ss_n;
       endcase
      end
	 

// assign sclk_in to sclkg
assign sclk = sclk_in;
assign sclk_inv = ~sclk_in;

always_ff @ (posedge sclk_inv or negedge rst_n)
        if (~rst_n) begin
	   ss_n_0 <= 1'b1;
	   ss_n_1 <= 1'b1;
	   ss_n_2 <= 1'b1;
	   ss_n_3 <= 1'b1;
        end
        else begin
	   ss_n_0 <= ss_n_0_int;
	   ss_n_1 <= ss_n_1_int;
	   ss_n_2 <= ss_n_2_int;
	   ss_n_3 <= ss_n_3_int;
        end

assign ss_n_cmb = (ss_n_0_int & ss_n_1_int & ss_n_2_int & ss_n_3_int);

// Receive logic 
assign rx_load = flag_word_q ^ flag_word_q1;

	                                          
assign spi_read = (cur_st == ST_IDLE) & (s_transvld_detect == 1) ? 1'b1 :  
                  ((tx_count == 'd28) & (burstcount != 'd0)) ? 1'b1 : 1'b0;
	                                          
	                                          
	                                          
// adjust spim burstlength from m_cmd register based on
// read or write. Specifically, increase spim burst length by 1
// in case of read

assign spi_write = rx_data_update;


assign spi_rd_addr = spi_read  ? 16'h0200 : 16'h0000; //wrbuf_addr; 
assign spi_wr_addr_2reg = (spi_write)  ? 16'h1000 : 16'h0000; //rdbuf_addr;


always_ff @ (posedge sclk_inv or negedge rst_n)
        if (~rst_n) begin
	 ss_n_dlyn <= 1'b1;
         end
	else begin 
	 ss_n_dlyn <= ss_n_int;
         end

assign ss_n_early_cmb = (((nxt_st == ST_INI_FWR) | ((nxt_st == ST_INI_FRD) & (rx_count == 5'b00000))) & (burstcount == {14{1'b0}})); 
always_ff @ (posedge sclk_inv or negedge rst_n)
        if (~rst_n) begin
	 ss_n_early <= 1'b0;
         end
	else begin 
	 ss_n_early <= ss_n_early_cmb;
         end

assign ss_n =  (ss_n_int | ss_n_dlyn | ss_n_early_cmb | ss_n_early);



always_ff @ (posedge sclk_in or negedge rst_n)
        if (~rst_n) begin
	 ss_n_dly1 <= 1'b1;
         end
	else begin 
	 ss_n_dly1 <= ss_n_int;
         end

assign ssn_off_pulse = ss_n_int & ~ss_n_dly1;
assign ssn_on_pulse = ~ss_n_int & ss_n_dly1;


assign dbg_bus0 = ({1'b0,cur_st,burstcount,spim_brstlen});


always_ff @ (posedge sclk_in or negedge rst_n) 
	if (~rst_n)
	 begin
	   flag_word    <= 'b0;
           rx_shift_reg <= 'b0;
	   rx_count	<= 'b0;
           
         end
	else if (ss_n_dly1)
	 begin
	   flag_word    <= 'b0;
           rx_shift_reg <= 'b0;
           rx_count	<= 'b0;
           
         end
        else
         begin 
	  if (ss_n_cmb == 0) begin
	   if (rx_count == 5'b11111) begin
            flag_word   <= ~flag_word;
            end
//MSB is received first on miso           
 	   rx_shift_reg <= {rx_shift_reg[30:0],miso};
           rx_count     <= rx_count + 1'b1;  
         end //ss_N
	end // else

always_ff @ (posedge sclk_in or negedge rst_n) 
	if (~rst_n)
	 begin
	   flag_word_q   <= 'b0;
	   flag_word_q1  <= 'b0;
         end
	else if (ss_n_dly1)	    
	 begin	                   
	   flag_word_q    <= 'b0;  
	   flag_word_q1   <= 'b0;  
         end
	else 
	 begin
	   flag_word_q  <= flag_word;
	   flag_word_q1  <= flag_word_q;
         end


always_ff @ (posedge sclk_in or negedge rst_n) 
	if (~rst_n) begin
    	   rx_data_update <= 1'b0;
   	end
	else if (rx_load) begin
    	   rx_data_update <= 1'b1;
	end 
	else begin
	   rx_data_update <= 1'b0;
        end


always_ff @ (posedge sclk_in or negedge rst_n) 
	if (~rst_n) begin
	   rx_data	<= 'b0;
         end
        else if (rx_count == 5'b0) begin 
 	   rx_data <= rx_shift_reg;	
         end




logic load_sereg;
// Transmit logic - inverted clock
always_ff @ (posedge sclk_inv or negedge rst_n) 
	if (~rst_n)
	   tx_rdata_reg	<= 'b0;
        else if (spi_read)
	   tx_rdata_reg <= tx_rdata;



always_ff @ (posedge sclk_in or negedge rst_n)
	if (~rst_n)
	 begin 
	   tx_count	<= 5'b11111;
	   load_sereg   <= 1'b0;
           tx_load	<= 1'b0;
         end 
	else if (ss_n_int)
	 begin 
	   tx_count	<= 5'b11111;
	   load_sereg   <= 1'b0;
           tx_load	<= 1'b0;
         end 
	else if (ss_n_int == 0) begin  
	   tx_count 	<= tx_count + 1'b1;
  	       if (tx_count == 5'b11111)  begin
                tx_load	<= 1'b1;
	        load_sereg   <= ~load_sereg;
	      end
	       else begin
                tx_load	<= 1'b0;
	       end
             end

logic start_tx_shift;

always_ff @ (posedge sclk_inv or negedge rst_n)
	if (~rst_n) begin
	   tx_shift_rega <= 'b0;
	   tx_shift_regb <= 'b0;
	   start_tx_shift <= 'b0;
         end
	else if (ss_n_int) begin
	   tx_shift_rega <= 'b0;
	   tx_shift_regb <= 'b0;
	   start_tx_shift <= 'b0;
         end
	else if ((tx_count == 5'b11111) & ~load_sereg & (ss_n_int == 1'b0)) begin 
	   tx_shift_rega <= tx_rdata_reg;
           start_tx_shift <= 1'b1;
        end
	else if ((tx_count == 5'b11111) & load_sereg & (ss_n_int == 1'b0)) begin 
	   tx_shift_regb <= tx_rdata_reg;
           start_tx_shift <= 1'b0;
        end
	else begin
	   tx_shift_rega <= {tx_shift_rega[30:0],1'b0};
	   tx_shift_regb <= {tx_shift_regb[30:0],1'b0};
          end

assign mosi_int = (start_tx_shift & (ss_n_int == 1'b0)) ? tx_shift_rega[31] : tx_shift_regb[31];  

always_ff @ (posedge sclk_inv or negedge rst_n)  
	if (~rst_n) begin
           mosi <= 1'b0;
        end
        else begin
           mosi <= mosi_int;
        end

// SPIM S/M
always_ff @ (posedge sclk_in or negedge rst_n) 
	if (~rst_n)
	 cur_st <= ST_IDLE;
	else
	 cur_st <= nxt_st;

always_ff @ (posedge sclk_in or negedge rst_n) 
	if (~rst_n)
	 s_transvld_q <= 1'b0;
	else
	 s_transvld_q <= s_transvld;
assign s_transvld_detect = s_transvld & ~s_transvld_q;

always_ff @ (posedge sclk_in or negedge rst_n) 
	if (~rst_n) begin
	 burstcount <= 14'b00_0000_0000_0000;     
        end
        else if (ss_n_int == 1) 
        burstcount <= 14'b00_0000_0000_0000;
	else if (cur_st == ST_INI_CMD) 
	 burstcount <= (cmd_is_read) ? (spim_brstlen - 1'b1) : spim_brstlen; // Burstlen is # of DWORDS on SPI
				             // Count tracks from N to 0 
	else if ((cmd_is_write  & (cur_st == ST_INI_FWR)) & inc_spi_addr)   begin 
          burstcount <= (burstcount - 1'b1); 
        end
	else if ((cmd_is_read & (cur_st == ST_INI_FRD)) & inc_spi_addr) begin 
          burstcount <= (burstcount - 1'b1); 
        end
       

//from m_cmd Nios write - read data from m_write buf and send to slave s_write_buf
// from m_cmd Niso read - receive read data from slave s_rdbuf and write to m_read buf
always_comb begin
	cmd_is_read 	= 1'b0; 	
	cmd_is_write	= 1'b0;
	stransvld_up    = 1'b0;
	inc_spi_addr 	= 1'b0;
        ss_n_int	= 1'b1;
        rx_wdata	= rx_data;
	nxt_st  	= cur_st; 
	case (cur_st)
	ST_IDLE	: begin
			   if (s_transvld_detect) begin
			    nxt_st = ST_INI_CMD;
                           end 
		           else begin
			    nxt_st = cur_st;
                           end
 	                   ss_n_int	= 1'b1;
			   end

	ST_INI_CMD	: begin
			   if (spim_rdnwr) begin 
			    cmd_is_read = 1'b1;        // Initiator read from AVB Channnel
			    nxt_st = ST_INI_RD;
                           end
			   else begin
			    cmd_is_write = 1'b1;        // Initiator write to AVB Channnel
			    nxt_st = ST_INI_WR;
			   end
		            ss_n_int = 1'b0;
			  end
			

	ST_INI_WR     	: begin 
			   if (tx_load) begin  // tx count = 31
			    rx_wdata = rx_data;
			    nxt_st = ST_INI_FWR;
                           end
		           ss_n_int = 1'b0;
			   cmd_is_write = 1'b1;
                          end
			    
	ST_INI_FWR     	: begin 
			   if (~tx_load) begin 
 	                    if (~(burstcount == {14{1'b0}})) begin
	                     inc_spi_addr = 1'b1;
			     nxt_st = ST_INI_WR; 
                            end
                            else begin  // burst count not 0
                               inc_spi_addr = 1'b0; 
                               nxt_st = ST_IDLE;
		               ss_n_int = 1'b1; 
			       cmd_is_write = 1'b0; 
			       stransvld_up = 1'b1; 
                           end
		           ss_n_int = 1'b0;   // tx load is true
			   cmd_is_write = 1'b1;
			  end
			 end
 
			    
	ST_INI_RD     	: begin 
// changed this from spi read to tx count so spi incr happens earlier 
			   if (tx_count == 5'b11001 ) begin  // 'd25
                           nxt_st = ST_INI_FRD;
	                    end
                           if (rx_data_update) begin
			    rx_wdata = rx_data;
			   end
		           ss_n_int = 1'b0;
			   cmd_is_read = 1'b1;
			  end

	ST_INI_FRD	: begin
			   if (~tx_load) begin 
 	                      if (~(burstcount == {14{1'b0}})) begin
	                         inc_spi_addr = 1'b1;
			         nxt_st = ST_INI_RD; 
		                 ss_n_int = 1'b0;     
                              end
                              else  // bc = 0 tx_load=0
                               if (rx_load) begin
	                              inc_spi_addr = 1'b0;  //last write increase - matters for spi write
                                      nxt_st = ST_INI_END_RD;
		                      ss_n_int = 1'b0;
			              cmd_is_read = 1'b1;
			              stransvld_up = 1'b0; 
                               end 
			  end
		           ss_n_int = 1'b0;                            
			   cmd_is_read = 1'b1;                        
                         end



      	ST_INI_END_RD	: begin
			   stransvld_up = 1'b1; 
		           ss_n_int = 1'b1;
                           nxt_st = ST_IDLE;
			     rx_wdata = rx_data;
 			  end	

	default		: begin
			   nxt_st = ST_IDLE;
		           ss_n_int = 1'b1;
			  end
		endcase
        end

endmodule






