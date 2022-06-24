Script code has been tested with standard Python v2.7.5 and Python v3.7.5

Example invocations:
python ../llink/script/dual_axist_llink_gen.py --cfg cfg/axi_dual_st_d64.cfg
python ../llink/script/dual_axist_llink_gen.py --cfg cfg/axi_dual_st_d256_multichannel.cfg

--cfg   points to a configuration file. This can be customized but the cfg
        directory has examples

--odir  generated files are placed in the odir directory.
        (Optional, if not present default is "./<MODULE_NAME>")


This will generated several files in the odir. The names depend on the module <NAME> field in the
cfg file. They will be:
<MODULE_NAME>_info.txt - Text based info file.

<MODULE_NAME>_master.f - list files. File paths are prepended ${PROJ_DIR}/llink/script/odir
<MODULE_NAME>_master_top.sv - top level master module
<MODULE_NAME>_master_name.sv - user interface module
<MODULE_NAME>_master_concat.sv - phy interface module

<MODULE_NAME>_slave.f - list files. File paths are prepended ${PROJ_DIR}/llink/script/odir
<MODULE_NAME>_slave_top.sv - top level slave module
<MODULE_NAME>_slave_name.sv - user interface module
<MODULE_NAME>_slave_concat.sv - phy interface module

The configuration file has many options. Note that everything is coded from the Master's
perspective so that the Master's TX is necessarily the Slave's RX and the Master's RX is
necessarily the Slave's TX.


List of CFG:

 axi_dual_st_d64.cfg                - Basic, simple AXI ST with 64 bit data. 1 Full AIB2.0 Channel.
 axi_dual_st_d256_multichannel.cfg  - Basic, simple AXI ST with 256 bit data bits running on two channel AIB2.0 Gen2 Half Rate.

