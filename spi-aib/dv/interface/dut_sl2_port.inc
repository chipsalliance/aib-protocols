    .iopad_ch0_aib(s2_iopad_ch0_aib), 
    .iopad_ch1_aib(s2_iopad_ch1_aib), 
    .iopad_ch2_aib(s2_iopad_ch2_aib), 
    .iopad_ch3_aib(s2_iopad_ch3_aib), 
    .iopad_ch4_aib(s2_iopad_ch4_aib), 
    .iopad_ch5_aib(s2_iopad_ch5_aib), 
    .iopad_ch6_aib(s2_iopad_ch6_aib), 
    .iopad_ch7_aib(s2_iopad_ch7_aib), 
    .iopad_ch8_aib(s2_iopad_ch8_aib), 
    .iopad_ch9_aib(s2_iopad_ch9_aib), 
    .iopad_ch10_aib(s2_iopad_ch10_aib),
    .iopad_ch11_aib(s2_iopad_ch11_aib),
    .iopad_ch12_aib(s2_iopad_ch12_aib),
    .iopad_ch13_aib(s2_iopad_ch13_aib),
    .iopad_ch14_aib(s2_iopad_ch14_aib),
    .iopad_ch15_aib(s2_iopad_ch15_aib),
    .iopad_ch16_aib(s2_iopad_ch16_aib),
    .iopad_ch17_aib(s2_iopad_ch17_aib),
    .iopad_ch18_aib(s2_iopad_ch18_aib),
    .iopad_ch19_aib(s2_iopad_ch19_aib),
    .iopad_ch20_aib(s2_iopad_ch20_aib),
    .iopad_ch21_aib(s2_iopad_ch21_aib),
    .iopad_ch22_aib(s2_iopad_ch22_aib),
    .iopad_ch23_aib(s2_iopad_ch23_aib),
   //IO pads, AUX channel
  
    .iopad_device_detect(device_detect),
    .iopad_power_on_reset(por),
  
    //Control/status from/to MAC 
    .data_in_f(intf_s2.data_in_f),
    .data_out_f(intf_s2.data_out_f),
    .data_in(intf_s2.data_in), //output data to pad
    .data_out(intf_s2.data_out),

    .m_ns_fwd_clk(intf_s2.m_ns_fwd_clk), //output data clock
    .m_ns_rcv_clk(intf_s2.m_ns_rcv_clk),
    .m_fs_rcv_clk(intf_s2.m_fs_rcv_clk),
    .m_fs_fwd_clk(intf_s2.m_fs_fwd_clk),

    .m_wr_clk(intf_s2.m_wr_clk),
    .m_rd_clk(intf_s2.m_rd_clk),
    .tclk_phy(),

    .ns_adapter_rstn(intf_s2.ns_adapter_rstn),
    .ns_mac_rdy(intf_s2.ns_mac_rdy),
    .fs_mac_rdy(intf_s2.fs_mac_rdy),

    .i_conf_done(intf_s2.i_conf_done),
    .ms_rx_dcc_dll_lock_req(intf_s2.ms_rx_dcc_dll_lock_req),
    .ms_tx_dcc_dll_lock_req(intf_s2.ms_tx_dcc_dll_lock_req),
    .sl_rx_dcc_dll_lock_req({24{1'b1}}),
    .sl_tx_dcc_dll_lock_req({24{1'b1}}),
    .ms_tx_transfer_en(intf_s2.ms_tx_transfer_en),
    .ms_rx_transfer_en(intf_s2.ms_rx_transfer_en),
    .sl_tx_transfer_en(intf_s2.sl_tx_transfer_en),
    .sl_rx_transfer_en(intf_s2.sl_rx_transfer_en),
    .sr_ms_tomac(intf_s2.ms_sideband),
    .sr_sl_tomac(intf_s2.sl_sideband),
    .m_rx_align_done(intf_s2.m_rx_align_done),
    .dual_mode_select(1'b0),         //slave
    .m_gen2_mode(1'b1),              //Use for AIB ver 2.0
    .i_osc_clk(intf_s2.i_osc_clk),   //Only for master mode

    //AVMM interface
    .i_cfg_avmm_clk(avmm_clk),
    .i_cfg_avmm_rst_n(avmm_rstn),
    .i_cfg_avmm_addr(avmm_if_sspi1.address),
    .i_cfg_avmm_byte_en(avmm_if_sspi1.byteenable),
    .i_cfg_avmm_read(avmm_if_sspi1.read),
    .i_cfg_avmm_write(avmm_if_sspi1.write),
    .i_cfg_avmm_wdata(avmm_if_sspi1.writedata),

    .o_cfg_avmm_rdatavld(avmm_if_sspi1.readdatavalid),
    .o_cfg_avmm_rdata(avmm_if_sspi1.readdata),
    .o_cfg_avmm_waitreq(avmm_if_sspi1.waitrequest),

    //Aux channel signals from MAC
    .m_por_ovrd(intf_s2.m_por_ovrd),
    .m_device_detect(intf_s2.m_device_detect),
    .m_device_detect_ovrd(1'b0),
    .i_m_power_on_reset(1'b0),
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

