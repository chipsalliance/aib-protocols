    .spi_clk_in(spi_clk),
    .sclk(spi_if.sclk),
    .ss_n(spi_if.ss_n),
    .mosi(spi_if.mosi),
    .miso(spi_if.miso),
    .rst_n(avmm_rstn),  //Make sure drive this signal for init.
    //AVMM interface
    .avmm_clk(avmm_if_mspi.clk),
//  .avmm_rst_n(avmm_if_mspi.rst_n),
    .avmm_addr(avmm_if_mspi.address),
    .avmm_byte_en(avmm_if_mspi.byteenable),
    .avmm_read(avmm_if_mspi.read),
    .avmm_write(avmm_if_mspi.write),
    .avmm_wdata(avmm_if_mspi.writedata),

    .avmm_rdatavld(avmm_if_mspi.readdatavalid),
    .avmm_rdata(avmm_if_mspi.readdata),
    .avmm_waitreq(avmm_if_mspi.waitrequest),
    .spi_inta(mspi_inta)


