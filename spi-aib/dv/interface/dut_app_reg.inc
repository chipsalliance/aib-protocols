   .user_status(user_status),
   .user_csr(user_csr),
   
   .avmm_rstn(avmm_rstn),
   .avmm_clk(avmm_if_sspi0.clk),
   .avmm_addr(avmm_if_sspi0.address),
   .avmm_byte_en(avmm_if_sspi0.byteenable),
   .avmm_read(avmm_if_sspi0.read),
   .avmm_write(avmm_if_sspi0.write),
   .avmm_wdata(avmm_if_sspi0.writedata),
   .avmm_rdatavld(avmm_if_sspi0.readdatavalid),
   .avmm_rdata(avmm_if_sspi0.readdata),
   .avmm_waitreq(avmm_if_sspi0.waitrequest)

