// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: AXIMM Leader application 
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////
module aximm_leader_app #(		parameter AXI_CHNL_NUM = 1,
					parameter DWIDTH = 128, 
					parameter ADDRWIDTH = 32)
	(
	input					clk,
	input					rst_n,
	input  [7:0] 			  	axi_rw_length,
	input  [1:0] 			  	axi_rw_burst,
	input  [2:0] 			  	axi_rw_size,
	input  [ADDRWIDTH-1:0] 	  		axi_rw_addr,
	input 					axi_wr,
	input 					axi_rd,
	output			 		patgen_data_wr,
	output	[(AXI_CHNL_NUM*64)-1 :0] 	patgen_exp_dout,
	output	logic				write_complete,
	output  [(AXI_CHNL_NUM*64)-1 :0]	data_out_first,
	output  				data_out_first_valid,
	output  [(AXI_CHNL_NUM*64)-1 :0]	data_out_last,
	output  				data_out_last_valid,
							
	
	output   [   3:   0]   		 	user_arid           ,
	output   [   2:   0]   		 	user_arsize         ,
	output   [   7:   0]   		 	user_arlen          ,
	output   [   1:   0]   		 	user_arburst        ,
	output   [ADDRWIDTH-1: 0]   	 	user_araddr         ,
	output                 		 	user_arvalid        ,
	input                  		 	user_arready        ,

	// aw channel
	output  wire [   3:   0]   		user_awid           ,
	output   [   2:   0]   			user_awsize         ,
	output   [   7:   0]   		 	user_awlen          ,
	output   [   1:   0]   		 	user_awburst        ,
	output   [ADDRWIDTH-1: 0]   	 	user_awaddr         ,
	output                 		 	user_awvalid        ,
	input                  		 	user_awready        ,
	
	// w channel
	output   [   3:   0]   			user_wid            ,
	output   [ DWIDTH-1 :   0]   		user_wdata          ,
	output   [  15:   0]   			user_wstrb          ,
	output                 			user_wlast          ,
	output                 			user_wvalid         ,
	input                  			user_wready         ,
	
	// r channel
	input  [   3:   0]   			user_rid            ,
	input  [ DWIDTH-1:   0]   		user_rdata          ,
	input                			user_rlast          ,
	input  [   1:   0]   			user_rresp          ,
	input                			user_rvalid         ,
	output  reg               		user_rready         ,
	
	// b channel
	input  [   3:   0]   			user_bid            ,
	input  [   1:   0]   			user_bresp          ,
	input                			user_bvalid         ,
	output               			user_bready         


);

    
localparam 		bus_idle 		= 1;
localparam 		ch_wr_addr 		= 2;
localparam 		ch_wr_addr_done 	= 3;
localparam 		ch_wr_data 		= 4;
localparam 		ch_rd_addr   		= 5;
localparam 		ch_rd_data		= 6;
localparam 		ch_bus_resp		= 7;


reg [   3:   0]   				r_user_awid   ;         
reg [   2:   0]   				r_user_awsize ;        
reg [   7:   0]   				r_user_awlen  ;        
reg [   1:   0]   				r_user_awburst;        
reg [  ADDRWIDTH-1:0]   			r_user_awaddr ;
reg               				r_user_awvalid ;  
reg  [15:0]             			r_user_wstrb ;  
wire 						w_user_awready;     
wire 						w_user_arready;     
wire 						w_wdata_Done;     
reg [   3:   0]   				r_user_arid   ;         
reg [   2:   0]   				r_user_arsize ;        
reg [   7:   0]   				r_user_arlen  ;        
reg [   1:   0]   				r_user_arburst;        
reg [  ADDRWIDTH-1:0]   			r_user_araddr ;
reg               				r_user_arvalid ;
reg               				fifo_rd_en_r1 ;

                
reg [3:0]  					aximm_wr_rd_ctrl;
wire 						w_data_gen_en;
wire [(AXI_CHNL_NUM*64)-1 :0]			w_user_wdata;
wire 						w_data_valid;
wire 						aximm_wdata_ready;
reg 						r_user_wid;
reg 						r_user_bready;

reg [7:0] 					data_wr_cnt   ;
reg 						r_write_complete;
wire 						w_user_wlast;


assign user_wvalid 		= (aximm_wr_rd_ctrl==ch_wr_data)? w_data_valid:1'b0;
assign 	w_user_awready 		= user_awready;            
assign 	w_user_arready 		= user_arready;            

	assign user_awid      = r_user_awid ;               
	assign user_awsize    = r_user_awsize;              
	assign user_awlen     = r_user_awlen ;              
	assign user_awburst   = r_user_awburst;             
	assign user_awaddr    = r_user_awaddr;
	assign user_awvalid   = r_user_awvalid;             

	assign user_arid      = r_user_arid ;               
	assign user_arsize    = r_user_arsize;              
	assign user_arlen     = r_user_arlen ;              
	assign user_arburst   = r_user_arburst;             
	assign user_araddr    = r_user_araddr;
	assign user_arvalid   = r_user_arvalid;             

	assign user_wid         = r_user_wid    ;
	assign 	user_wdata       = w_user_wdata  ;
	//assign user_wstrb       = r_user_wstrb[7:0]  ;
	assign user_wstrb       = r_user_wstrb  ;
	assign user_wlast       = w_user_wlast  ;
	assign write_complete   = r_write_complete;

	assign user_bready        = r_user_bready   ;

always@(posedge clk)
begin
	if(!rst_n)
	begin
		r_write_complete	<= 1'b0;
	end
	else if(w_user_wlast && user_wvalid && user_wready)
	begin
		r_write_complete	<= 1'b1;
	end
	else if(axi_wr)
	begin
		r_write_complete	<= 1'b0;
	end
end

assign aximm_wdata_ready	= user_wready;
				

always@(posedge clk)
begin
	if(!rst_n)
	begin
		aximm_wr_rd_ctrl 	<= bus_idle;
		r_user_awid   		<= 'b0;
		r_user_awsize       	<= 'b0;
		r_user_awlen        	<= 'b0;
		r_user_awburst      	<= 'b0;
		r_user_awaddr       	<= 'b0;
		r_user_awvalid		<= 'b0;
		r_user_wstrb	    	<= 'b0;
		r_user_wid		<= 'b0;
		r_user_bready	    	<= 'b0;
		user_rready		<= 'b0;
		r_user_arvalid		<= 1'b0;
		r_user_arsize       	<= 'b0;  
		r_user_arlen        	<= 'b0;
		r_user_arburst      	<= 'b0;
		r_user_araddr       	<= 'b0;
		r_user_arid   		<= 4'b0;
		
	end
	else
	begin
		case(aximm_wr_rd_ctrl)
			bus_idle:
			begin
			r_user_bready			<= 1'b0;
			r_user_arvalid			<= 1'b0;
			user_rready			<= 1'b0;
				if(axi_wr)
				begin
					aximm_wr_rd_ctrl	<= ch_wr_addr;
					r_user_awid   		<= 4'b0;
					r_user_awsize       	<= 3'd4;  //04 - 16 bytes
					r_user_awlen        	<= axi_rw_length;
					r_user_awburst      	<= 2'b01; //01 - INCR
					r_user_awaddr       	<= axi_rw_addr;
					r_user_awvalid		<= 1'b1;
				end
				else if(axi_rd)
				begin
					aximm_wr_rd_ctrl	<= ch_rd_addr;
					r_user_arid   		<= 4'b0;
					r_user_arsize       	<= 8'h07;  //07 - 128 bytes
					r_user_arlen        	<= axi_rw_length;
					r_user_arburst      	<= 2'b01;
					r_user_araddr       	<= axi_rw_addr;
					r_user_arvalid		<= 1'b1;
				end
				else
				begin
				
				end
			end
			ch_wr_addr:
			begin
				r_user_awvalid		<= 1'b1;
				if(w_user_awready)
				begin
					aximm_wr_rd_ctrl	<= ch_wr_addr_done ;
				end
			end
			ch_wr_addr_done:
			begin
				r_user_awvalid		<= 1'b0;
				r_user_wstrb		<= 16'hFFFF;
				r_user_wid		<= 'b0;
				aximm_wr_rd_ctrl	<= ch_wr_data ;
			end
			ch_wr_data:
			begin
				if(w_wdata_Done)
				begin	
					aximm_wr_rd_ctrl	<= ch_bus_resp ;
					
				end
				else
				begin
					aximm_wr_rd_ctrl	<= ch_wr_data ;
				end
				end
			ch_rd_addr:
			begin
				if(w_user_arready)
				begin
					aximm_wr_rd_ctrl	<= ch_rd_data ;
					r_user_arvalid		<= 1'b0;
				end
			end	
			ch_rd_data:
			begin
				if(user_rvalid==1'b1 && user_rlast)
				begin
					user_rready		<= 1'b0;
					aximm_wr_rd_ctrl	<= bus_idle ;
				end
				else if(user_rvalid==1'b1)
				begin
					user_rready		<= 1'b1;
				end
			end			
			ch_bus_resp:
			begin
				if(user_bvalid==1'b1 && user_bresp ==2'b00)
				begin
					aximm_wr_rd_ctrl	<= bus_idle ;
					r_user_bready		<= 1'b1;
				end 
			end
		default
			begin
			
			end
		endcase
	end
end

always@(posedge clk)
begin
if(!rst_n)
begin
	data_wr_cnt		<= 'b0;
end
else
begin
if(aximm_wr_rd_ctrl==ch_wr_data)
begin
	if(w_data_valid & user_wready) 
	begin
		data_wr_cnt		<= data_wr_cnt + 1;
	end
	else if(aximm_wr_rd_ctrl == bus_idle)
	begin
		data_wr_cnt		<= 'b0;
	end

end
end
end 

assign w_data_gen_en 	= (aximm_wr_rd_ctrl==ch_wr_addr || aximm_wr_rd_ctrl==ch_wr_addr_done)? 1'b1 : 1'b0;
assign w_user_wlast 	= (data_wr_cnt == (r_user_awlen-1)) ? 1'b1:1'b0;
assign w_wdata_Done 	=  (w_user_wlast && user_wvalid && user_wready);

axi_mm_patgen_top #(.LEADER_MODE( 1), .AXI_CHNL_NUM(AXI_CHNL_NUM))aximm_inc_data(

	.wr_clk(clk) ,
	.rst_n (rst_n),
	.cntuspatt_en (1'b0),
	.patgen_en (w_data_gen_en),
	.patgen_sel (2'b10),
	.patgen_cnt (r_user_awlen),
	.patgen_dout(w_user_wdata),
	.patgen_exp_dout(patgen_exp_dout),
	.patgen_data_wr(patgen_data_wr),
	.chkr_fifo_full(1'b0),
	.axist_valid(w_data_valid),
	.axist_rdy(aximm_wdata_ready)

);

assign data_out_first 		= (aximm_wdata_ready && w_data_valid && data_wr_cnt == 'b0) ? w_user_wdata : 'b0;
assign data_out_last  		= (aximm_wdata_ready && w_data_valid && w_user_wlast ) ? w_user_wdata : 'b0 ;

assign data_out_last_valid 	= (aximm_wdata_ready && w_data_valid && w_user_wlast ) ? 1'b1 : 1'b0 ;
assign data_out_first_valid 	= (aximm_wdata_ready && w_data_valid && data_wr_cnt == 'b0 ) ? 1'b1 : 1'b0 ;

endmodule
