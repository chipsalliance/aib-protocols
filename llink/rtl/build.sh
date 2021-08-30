/usr/bin/emacs -batch ll_transmit.sv          -f verilog-auto -f save-buffer
/usr/bin/emacs -batch ll_receive.sv           -f verilog-auto -f save-buffer
/usr/bin/emacs -batch axi_mm_master_concat.sv -f verilog-auto -f save-buffer
/usr/bin/emacs -batch axi_mm_master_top.sv    -f verilog-auto -f save-buffer
/usr/bin/emacs -batch axi_mm_slave_concat.sv  -f verilog-auto -f save-buffer
/usr/bin/emacs -batch axi_mm_slave_top.sv     -f verilog-auto -f save-buffer
/usr/bin/emacs -batch two_axi_mm_chiplet.sv   -f verilog-auto -f save-buffer


/usr/bin/emacs -batch axi_st_master_concat.sv -f verilog-auto -f save-buffer
/usr/bin/emacs -batch axi_st_master_top.sv    -f verilog-auto -f save-buffer
/usr/bin/emacs -batch axi_st_slave_concat.sv  -f verilog-auto -f save-buffer
/usr/bin/emacs -batch axi_st_slave_top.sv     -f verilog-auto -f save-buffer
/usr/bin/emacs -batch two_axi_st_chiplet.sv   -f verilog-auto -f save-buffer
