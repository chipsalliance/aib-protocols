#!/usr/bin/bash

/usr/bin/emacs -batch axi_mm_master_top.sv -f verilog-auto -f save-buffer
/usr/bin/emacs -batch axi_mm_slave_top.sv  -f verilog-auto -f save-buffer
