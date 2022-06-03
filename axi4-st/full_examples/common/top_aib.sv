// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2021 Intel Corporation.
/////////////////////////////////////////////////////////////////////////////////////////
//--------------------------------------------------------------------------------------
// Description: AIB model instantiation
//
//
// Change log
// 
/////////////////////////////////////////////////////////////////////////////////////////

`timescale 1ps/1ps

module top_aib#(parameter DWIDTH = 40, parameter TOTAL_CHNL_NUM = 24)
	(
	input									avmm_clk,
	input                                   osc_clk,
	input	[TOTAL_CHNL_NUM*DWIDTH*8-1:0]	m1_data_in_f,
    output  [TOTAL_CHNL_NUM*DWIDTH*8-1:0]	m1_data_out_f,
    input	[TOTAL_CHNL_NUM*DWIDTH*2-1:0]   m1_data_in, //output data to pad
    output  [TOTAL_CHNL_NUM*DWIDTH*2-1:0]   m1_data_out,
	input	[TOTAL_CHNL_NUM-1:0]     		m1_m_ns_fwd_clk, //output data clock
    input	[TOTAL_CHNL_NUM-1:0]     		m1_m_ns_rcv_clk,
    output  [TOTAL_CHNL_NUM-1:0]     		m1_m_fs_rcv_clk,
    output  [TOTAL_CHNL_NUM-1:0]     		m1_m_fs_fwd_clk,
    input	[TOTAL_CHNL_NUM-1:0]     		m1_m_wr_clk,
    input	[TOTAL_CHNL_NUM-1:0]     		m1_m_rd_clk,
    output  [TOTAL_CHNL_NUM-1:0]     		m1_ms_tx_transfer_en,
    output  [TOTAL_CHNL_NUM-1:0]     		m1_ms_rx_transfer_en,
    output  [TOTAL_CHNL_NUM-1:0]     		m1_sl_tx_transfer_en,
    output  [TOTAL_CHNL_NUM-1:0]     		m1_sl_rx_transfer_en,
    input									m1_i_osc_clk,   //Only for master mode
	output 									m1_por_out,
	
	input  	[TOTAL_CHNL_NUM*80-1:0]   		s1_gen1_data_in_f,
    output  [TOTAL_CHNL_NUM*80-1:0]   		s1_gen1_data_out_f,   
	input  	[TOTAL_CHNL_NUM-1:0]   			s1_m_wr_clk,
    input  	[TOTAL_CHNL_NUM-1:0]   			s1_m_rd_clk,
	input  	[TOTAL_CHNL_NUM-1:0]   			s1_m_ns_fwd_clk,
	output  [TOTAL_CHNL_NUM-1:0]   			s1_m_fs_fwd_clk,
    output  [TOTAL_CHNL_NUM-1:0]    		s1_ms_rx_transfer_en,
    output  [TOTAL_CHNL_NUM-1:0]    		s1_ms_tx_transfer_en,
    output  [TOTAL_CHNL_NUM-1:0]    		s1_sl_rx_transfer_en,
    output  [TOTAL_CHNL_NUM-1:0]    		s1_sl_tx_transfer_en
    
);

    //------------------------------------------------------------------------------------------
parameter AVMM_CYCLE = 4000;
parameter OSC_CYCLE  = 1000;

`ifdef MS_AIB_GEN1
   parameter M_PAD_NUM  = 96;
`else
   parameter M_PAD_NUM  = 102;
`endif
`ifdef SL_AIB_GEN1
   parameter S_PAD_NUM  = 96;
`else
   parameter S_PAD_NUM  = 102;
`endif

logic  			ms_fwd_clk = 1'b0; 
logic  			ms_wr_clk  = 1'b0; 
logic  			ms_rd_clk  = 1'b0;
logic  			sl_fwd_clk = 1'b0;
logic  			sl_wr_clk  = 1'b0;
logic  			sl_rd_clk  = 1'b0;
int 			run_for_n_pkts_ms1;
int 			run_for_n_pkts_sl1;
int 			run_for_n_wa_cycle;
int 			err_count;
wire 			por_out;

logic [(TOTAL_CHNL_NUM*40*8)-1:0]   axist_data_in_f;
logic [(TOTAL_CHNL_NUM*40*8)-1:0]   axist_data_out_f;
logic [(TOTAL_CHNL_NUM*40)-1:0]     axist_gen1_data_in;
logic [(TOTAL_CHNL_NUM*40)-1:0]     axist_gen1_data_out;
logic [(TOTAL_CHNL_NUM*40*2)-1:0]   axist_gen1_data_in_f;
logic [(TOTAL_CHNL_NUM*40*2)-1:0]   axist_gen1_data_out_f;

logic [40*24-1:0] 					ms1_rcv_40b_q [$];

logic [80*24-1:0] 					sl1_rcv_80b_q [$];
logic [80*24-1:0] 					ms1_rcv_80b_q [$];

logic [320*24-1:0] 					sl1_rcv_320b_q [$];
logic [320*24-1:0] 					ms1_rcv_320b_q [$];
bit [1023:0] 						status;

logic [(24*320)-1 : 0] 				datain_f_m;
logic [(24*320)-1 : 0] 				dataout_f_m;
logic [(24*80)-1 : 0] 				datain_m;
logic [(24*80)-1 : 0] 				dataout_m;
logic [(24*80)-1 : 0] 				tx_parallel_data_in;
logic [(24*80)-1 : 0] 				rx_parallel_data_out;

logic data_en_axist;

    //=================================================================================
    // Slave AIB IOs
    //=================================================================================
    wire [M_PAD_NUM-1:0] m1_iopad_ch0_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch0_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch1_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch1_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch2_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch2_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch3_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch3_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch4_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch4_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch5_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch5_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch6_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch6_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch7_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch7_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch8_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch8_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch9_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch9_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch10_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch10_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch11_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch11_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch12_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch12_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch13_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch13_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch14_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch14_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch15_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch15_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch16_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch16_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch17_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch17_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch18_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch18_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch19_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch19_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch20_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch20_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch21_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch21_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch22_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch22_aib;
    wire [M_PAD_NUM-1:0] m1_iopad_ch23_aib;
    wire [S_PAD_NUM-1:0] s1_iopad_ch23_aib;
    //=================================================================================
    // Register config for testbench 
    //=================================================================================
    reg  [1:0]  ms1_tx_fifo_mode;
    reg  [1:0]  sl1_tx_fifo_mode;
    reg  [1:0]  ms1_rx_fifo_mode;
    reg  [1:0]  sl1_rx_fifo_mode;
    reg  [4:0]  ms1_tx_markbit;
    reg  [4:0]  sl1_tx_markbit;
    reg         ms1_gen1;
    reg         sl1_gen1;
    reg         ms1_lpbk;
    reg         sl1_lpbk;
    reg         ms1_dbi_en;
    reg         sl1_dbi_en;

`include "../../common/agent.sv"
// `include "../../../../../aib-phy-hardware-master/v2.0/rev1/dv/test/task/agent.sv"

    //-----------------------------------------------------------------------------------------
    //Avalon MM Interface instantiation
    //-----------------------------------------------------------------------------------------
    avalon_mm_if #(.AVMM_WIDTH(32), .BYTE_WIDTH(4)) avmm_if_m1  (
     .clk    (avmm_clk)
    );
    avalon_mm_if #(.AVMM_WIDTH(32), .BYTE_WIDTH(4)) avmm_if_s1  (
     .clk    (avmm_clk)
    );
    //-----------------------------------------------------------------------------------------
    // Mac Interface instantiation

    //-----------------------------------------------------------------------------------------
    dut_if_mac #(.DWIDTH (40)) intf_m1 (.wr_clk(ms_wr_clk), .rd_clk(ms_rd_clk), .fwd_clk(ms_fwd_clk), .osc_clk(osc_clk));
    dut_if_mac #(.DWIDTH (40)) intf_s1 (.wr_clk(sl_wr_clk), .rd_clk(sl_rd_clk), .fwd_clk(sl_fwd_clk), .osc_clk(osc_clk));
    //-----------------------------------------------------------------------------------------
    // DUT instantiation
    //-----------------------------------------------------------------------------------------

    // One channel master uses aib model
    parameter DATAWIDTH      = 40;
`ifdef MS_AIB_GEN1
    aib_top_wrapper_v1m dut_master1 (
       `include "dut_ms_gen1.inc"
    );
`else 
    aib_model_top  #(.DATAWIDTH(DATAWIDTH)) dut_master1 (
        // `include "dut_ms1_port.inc"
		    .iopad_ch0_aib(m1_iopad_ch0_aib), 
    .iopad_ch1_aib(m1_iopad_ch1_aib), 
    .iopad_ch2_aib(m1_iopad_ch2_aib), 
    .iopad_ch3_aib(m1_iopad_ch3_aib), 
    .iopad_ch4_aib(m1_iopad_ch4_aib), 
    .iopad_ch5_aib(m1_iopad_ch5_aib), 
    .iopad_ch6_aib(m1_iopad_ch6_aib), 
    .iopad_ch7_aib(m1_iopad_ch7_aib), 
    .iopad_ch8_aib(m1_iopad_ch8_aib), 
    .iopad_ch9_aib(m1_iopad_ch9_aib), 
    .iopad_ch10_aib(m1_iopad_ch10_aib),
    .iopad_ch11_aib(m1_iopad_ch11_aib),
    .iopad_ch12_aib(m1_iopad_ch12_aib),
    .iopad_ch13_aib(m1_iopad_ch13_aib),
    .iopad_ch14_aib(m1_iopad_ch14_aib),
    .iopad_ch15_aib(m1_iopad_ch15_aib),
    .iopad_ch16_aib(m1_iopad_ch16_aib),
    .iopad_ch17_aib(m1_iopad_ch17_aib),
    .iopad_ch18_aib(m1_iopad_ch18_aib),
    .iopad_ch19_aib(m1_iopad_ch19_aib),
    .iopad_ch20_aib(m1_iopad_ch20_aib),
    .iopad_ch21_aib(m1_iopad_ch21_aib),
    .iopad_ch22_aib(m1_iopad_ch22_aib),
    .iopad_ch23_aib(m1_iopad_ch23_aib),
   //IO pads, AUX channel
  
    .iopad_device_detect(device_detect),
    .iopad_power_on_reset(por),
  
    //Control/status from/to MAC 
    .data_in_f(m1_data_in_f),						
    .data_out_f(m1_data_out_f),                     
    .data_in(m1_data_in), //output data to pad      
    .data_out(m1_data_out),                         
			 
    .m_ns_fwd_clk(m1_m_ns_fwd_clk), //output data clock	 
    .m_ns_rcv_clk(m1_m_ns_rcv_clk),                         
    .m_fs_rcv_clk(m1_m_fs_rcv_clk),                         
    .m_fs_fwd_clk(m1_m_fs_fwd_clk),                         
                                                         
    .m_wr_clk(m1_m_wr_clk),                              
    .m_rd_clk(m1_m_rd_clk),
    .tclk_phy(),

    .ns_adapter_rstn(intf_m1.ns_adapter_rstn),	
    .ns_mac_rdy(intf_m1.ns_mac_rdy),             
    .fs_mac_rdy(intf_m1.fs_mac_rdy),             

    .i_conf_done(intf_m1.i_conf_done),
    .ms_rx_dcc_dll_lock_req(intf_m1.ms_rx_dcc_dll_lock_req),			
    .ms_tx_dcc_dll_lock_req(intf_m1.ms_tx_dcc_dll_lock_req),         
    .sl_rx_dcc_dll_lock_req({24{1'b1}}),                        
    .sl_tx_dcc_dll_lock_req({24{1'b1}}),                        
    .ms_tx_transfer_en(m1_ms_tx_transfer_en),                   
    .ms_rx_transfer_en(m1_ms_rx_transfer_en),                   
    .sl_tx_transfer_en(m1_sl_tx_transfer_en),
    .sl_rx_transfer_en(m1_sl_rx_transfer_en),
    .sr_ms_tomac(intf_m1.ms_sideband),			
    .sr_sl_tomac(intf_m1.sl_sideband),           
    .m_rx_align_done(intf_m1.m_rx_align_done),   
    .dual_mode_select(1'b1),
`ifdef SL_AIB_GEN1
    .m_gen2_mode(1'b0),
`else
    .m_gen2_mode(1'b1),
`endif
    .i_osc_clk(m1_i_osc_clk),   //Only for master mode			
                                                                
    //AVMM interface                                            
    .i_cfg_avmm_clk(avmm_if_m1.clk),
    .i_cfg_avmm_rst_n(avmm_if_m1.rst_n),
    .i_cfg_avmm_addr(avmm_if_m1.address),
    .i_cfg_avmm_byte_en(avmm_if_m1.byteenable),
    .i_cfg_avmm_read(avmm_if_m1.read),
    .i_cfg_avmm_write(avmm_if_m1.write),
    .i_cfg_avmm_wdata(avmm_if_m1.writedata),

    .o_cfg_avmm_rdatavld(avmm_if_m1.readdatavalid),
    .o_cfg_avmm_rdata(avmm_if_m1.readdata),
    .o_cfg_avmm_waitreq(avmm_if_m1.waitrequest),

    //Aux channel signals from MAC
    .m_por_ovrd(intf_m1.m_por_ovrd),
    .m_device_detect(intf_m1.m_device_detect),
    .m_device_detect_ovrd(1'b0),
    .i_m_power_on_reset(1'b0),
    // .o_m_power_on_reset(),
    .o_m_power_on_reset(m1_por_out),

    //JTAG ports
    .i_jtag_clkdr(1'b0),
    .i_jtag_clksel(1'b0),
    .o_jtag_tdo(),
    .i_jtag_intest(1'b0),
    .i_jtag_mode(1'b0),
    .i_jtag_rstb(1'b0),
    .i_jtag_rstb_en(1'b0),
    .i_jtag_weakpdn(1'b0),
    .i_jtag_weakpu(1'b0),
    .i_jtag_tx_scanen(1'b0),
    .i_jtag_tdi(1'b0),
   //ATPG
    .i_scan_clk(1'b0),
    .i_scan_clk_500m(1'b0),
    .i_scan_clk_1000m(1'b0),
    .i_scan_en(1'b0),
    .i_scan_mode(1'b0),
    .i_scan_din({24{200'b0}}),
    .i_scan_dout(),


    .sl_external_cntl_26_0({24{27'b0}}),
    .sl_external_cntl_30_28({24{3'b0}}),
    .sl_external_cntl_57_32({24{26'b0}}),

    .ms_external_cntl_4_0({24{5'b0}}),
    .ms_external_cntl_65_8({24{58'b0}})


     );
`endif

`ifdef SL_AIB_GEN1
    maib_top dut_slave1 (
        // `include "dut_sl_gen1.inc"
	.iopad_aib_ch0(s1_iopad_ch0_aib),
    .iopad_aib_ch1(s1_iopad_ch1_aib),
    .iopad_aib_ch2(s1_iopad_ch2_aib),
    .iopad_aib_ch3(s1_iopad_ch3_aib),
    .iopad_aib_ch4(s1_iopad_ch4_aib),
    .iopad_aib_ch5(s1_iopad_ch5_aib),
    .iopad_aib_ch6(s1_iopad_ch6_aib),
    .iopad_aib_ch7(s1_iopad_ch7_aib),
    .iopad_aib_ch8(s1_iopad_ch8_aib),
    .iopad_aib_ch9(s1_iopad_ch9_aib),
    .iopad_aib_ch10(s1_iopad_ch10_aib),
    .iopad_aib_ch11(s1_iopad_ch11_aib),
    .iopad_aib_ch12(s1_iopad_ch12_aib),
    .iopad_aib_ch13(s1_iopad_ch13_aib),
    .iopad_aib_ch14(s1_iopad_ch14_aib),
    .iopad_aib_ch15(s1_iopad_ch15_aib),
    .iopad_aib_ch16(s1_iopad_ch16_aib),
    .iopad_aib_ch17(s1_iopad_ch17_aib),
    .iopad_aib_ch18(s1_iopad_ch18_aib),
    .iopad_aib_ch19(s1_iopad_ch19_aib),
    .iopad_aib_ch20(s1_iopad_ch20_aib),
    .iopad_aib_ch21(s1_iopad_ch21_aib),
    .iopad_aib_ch22(s1_iopad_ch22_aib),
    .iopad_aib_ch23(s1_iopad_ch23_aib), 

    .tx_parallel_data(s1_gen1_data_in_f),	
    .rx_parallel_data(s1_gen1_data_out_f),    
	.tx_coreclkin(s1_m_wr_clk),			
    .tx_clkout(),                       
    .rx_coreclkin(s1_m_rd_clk),         
                                        
    .rx_clkout(),                         
    .m_ns_fwd_clk(s1_m_ns_fwd_clk),       
                                          
    .m_fs_fwd_clk(s1_m_fs_fwd_clk),

    .fs_mac_rdy(intf_s1.fs_mac_rdy),
    .ns_mac_rdy(intf_s1.ns_mac_rdy),
    .ns_adapter_rstn(intf_s1.ns_adapter_rstn),
    .config_done(intf_s1.i_conf_done),						
                                                        
    .sl_rx_dcc_dll_lock_req(intf_s1.sl_rx_dcc_dll_lock_req), 
    .sl_tx_dcc_dll_lock_req(intf_s1.sl_tx_dcc_dll_lock_req), 
                                                        
    .ms_osc_transfer_en(),                              
    .ms_rx_transfer_en(s1_ms_rx_transfer_en),           
    .ms_tx_transfer_en(s1_ms_tx_transfer_en),           
    .sl_osc_transfer_en(),                              
    .sl_rx_transfer_en(s1_sl_rx_transfer_en),
    .sl_tx_transfer_en(s1_sl_tx_transfer_en),

    .ms_sideband(intf_s1.ms_sideband),
    .sl_sideband(intf_s1.sl_sideband),
    .iopad_crdet(device_detect),
    .iopad_crdet_r(device_detect),
    .iopad_por(por),
    .iopad_por_r(),
    .m_power_on_reset(intf_s1.i_m_power_on_reset),		
    .m_device_detect_ovrd(intf_s1.m_device_detect_ovrd), 
    .m_device_detect(intf_s1.m_device_detect)            
       );
initial begin
@(posedge dut_slave1.config_done);
`include "maib_prog.inc"
end
    
`else
    aib_model_top #(.DATAWIDTH(DATAWIDTH)) dut_slave1 (
        // `include "dut_sl1_port.inc"
	.iopad_ch0_aib(s1_iopad_ch0_aib),
    .iopad_ch1_aib(s1_iopad_ch1_aib),
    .iopad_ch2_aib(s1_iopad_ch2_aib),
    .iopad_ch3_aib(s1_iopad_ch3_aib),
    .iopad_ch4_aib(s1_iopad_ch4_aib),
    .iopad_ch5_aib(s1_iopad_ch5_aib),
    .iopad_ch6_aib(s1_iopad_ch6_aib),
    .iopad_ch7_aib(s1_iopad_ch7_aib),
    .iopad_ch8_aib(s1_iopad_ch8_aib),
    .iopad_ch9_aib(s1_iopad_ch9_aib),
    .iopad_ch10_aib(s1_iopad_ch10_aib),
    .iopad_ch11_aib(s1_iopad_ch11_aib),
    .iopad_ch12_aib(s1_iopad_ch12_aib),
    .iopad_ch13_aib(s1_iopad_ch13_aib),
    .iopad_ch14_aib(s1_iopad_ch14_aib),
    .iopad_ch15_aib(s1_iopad_ch15_aib),
    .iopad_ch16_aib(s1_iopad_ch16_aib),
    .iopad_ch17_aib(s1_iopad_ch17_aib),
    .iopad_ch18_aib(s1_iopad_ch18_aib),
    .iopad_ch19_aib(s1_iopad_ch19_aib),
    .iopad_ch20_aib(s1_iopad_ch20_aib),
    .iopad_ch21_aib(s1_iopad_ch21_aib),
    .iopad_ch22_aib(s1_iopad_ch22_aib),
    .iopad_ch23_aib(s1_iopad_ch23_aib), 
   //IO pads, AUX channel
    .iopad_device_detect(device_detect),
    .iopad_power_on_reset(por),

    //Control/status from/to MAC 
    .data_in_f(intf_s1.data_in_f),
    .data_out_f(intf_s1.data_out_f),
    .data_in(intf_s1.data_in), //output data to pad
    .data_out(intf_s1.data_out),

    .m_ns_fwd_clk(intf_s1.m_ns_fwd_clk), //output data clock
    .m_ns_rcv_clk(intf_s1.m_ns_rcv_clk),
    .m_fs_rcv_clk(intf_s1.m_fs_rcv_clk),
    .m_fs_fwd_clk(intf_s1.m_fs_fwd_clk),

    .m_wr_clk(intf_s1.m_wr_clk),
    .m_rd_clk(intf_s1.m_rd_clk),
    .tclk_phy(),

    .ns_adapter_rstn(intf_s1.ns_adapter_rstn),
    .ns_mac_rdy(intf_s1.ns_mac_rdy),
    .fs_mac_rdy(intf_s1.fs_mac_rdy),

    .i_conf_done(intf_s1.i_conf_done),
    .ms_rx_dcc_dll_lock_req({24{1'b1}}),
    .ms_tx_dcc_dll_lock_req({24{1'b1}}),
    .sl_rx_dcc_dll_lock_req(intf_s1.sl_rx_dcc_dll_lock_req),
    .sl_tx_dcc_dll_lock_req(intf_s1.sl_tx_dcc_dll_lock_req),
    .ms_tx_transfer_en(intf_s1.ms_tx_transfer_en),
    .ms_rx_transfer_en(intf_s1.ms_rx_transfer_en),
    .sl_tx_transfer_en(intf_s1.sl_tx_transfer_en),
    .sl_rx_transfer_en(intf_s1.sl_rx_transfer_en),
    .sr_ms_tomac(intf_s1.ms_sideband),
    .sr_sl_tomac(intf_s1.sl_sideband),
    .m_rx_align_done(intf_s1.m_rx_align_done),
    .dual_mode_select(1'b0),
`ifdef MS_AIB_GEN1
    .m_gen2_mode(1'b0),
`else
    .m_gen2_mode(1'b1),
`endif
    .i_osc_clk(intf_s1.i_osc_clk),   //Only for master mode

    //AVMM interface
    .i_cfg_avmm_clk(avmm_if_s1.clk),
    .i_cfg_avmm_rst_n(avmm_if_s1.rst_n),
    .i_cfg_avmm_addr(avmm_if_s1.address),
    .i_cfg_avmm_byte_en(avmm_if_s1.byteenable),
    .i_cfg_avmm_read(avmm_if_s1.read),
    .i_cfg_avmm_write(avmm_if_s1.write),
    .i_cfg_avmm_wdata(avmm_if_s1.writedata),

    .o_cfg_avmm_rdatavld(avmm_if_s1.readdatavalid),
    .o_cfg_avmm_rdata(avmm_if_s1.readdata),
    .o_cfg_avmm_waitreq(avmm_if_s1.waitrequest),

    //Aux channel signals from MAC
    .m_por_ovrd(1'b0),
    .m_device_detect(intf_s1.m_device_detect),
    .m_device_detect_ovrd(intf_s1.m_device_detect_ovrd),
    .i_m_power_on_reset(intf_s1.i_m_power_on_reset),
    .o_m_power_on_reset(),

    //JTAG ports
    .i_jtag_clkdr(1'b0),
    .i_jtag_clksel(1'b0),
    .o_jtag_tdo(),
    .i_jtag_intest(1'b0),
    .i_jtag_mode(1'b0),
    .i_jtag_rstb(1'b0),
    .i_jtag_rstb_en(1'b0),
    .i_jtag_weakpdn(1'b0),
    .i_jtag_weakpu(1'b0),
    .i_jtag_tx_scanen(1'b0),
    .i_jtag_tdi(1'b0),
   //ATPG
    .i_scan_clk(1'b0),
    .i_scan_clk_500m(1'b0),
    .i_scan_clk_1000m(1'b0),
    .i_scan_en(1'b0),
    .i_scan_mode(1'b0),
    .i_scan_din({24{200'b0}}),
    .i_scan_dout(),

    .sl_external_cntl_26_0({24{27'b0}}),
    .sl_external_cntl_30_28({24{3'b0}}),
    .sl_external_cntl_57_32({24{26'b0}}),

    .ms_external_cntl_4_0({24{5'b0}}),
    .ms_external_cntl_65_8({24{58'b0}})

       );
`endif

    // 24 channel Embedded Multi-Die Interconnect Bridge (EMIB) For future use
`ifdef MS_AIB_GEN1
    emib_m1s2 dut_emib (
        `include "dut_emib.inc"
       );
`elsif SL_AIB_GEN1
    emib_m2s1 dut_emib (
        `include "dut_emib.inc"
       );
`else
    emib_m2s2 dut_emib (
        `include "dut_emib.inc"
       );
`endif

`include "../../common/test.inc"
   //---------------------------------------------------------------------------
   // DUMP
   //---------------------------------------------------------------------------
`ifdef VCS
   initial
   begin
     $vcdpluson;
   end
`endif

endmodule 
