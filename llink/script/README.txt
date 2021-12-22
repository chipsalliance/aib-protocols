Code has been tested with standard Python v2.7.5 and Python v3.7.5

Example invocations:
python llink_gen.py --cfg cfg/axi_mm_a32_d128.cfg        --odir premade_examples/axi_mm_a32_d128
python llink_gen.py --cfg cfg/axi_lite_a32_d32.cfg       --odir premade_examples/axi_lite_a32_d32
python llink_gen.py --cfg cfg/axi_mm_a48_d512_packet.cfg --odir premade_examples/axi_mm_a48_d512_packet
python llink_gen.py --cfg cfg/axi_st_d64.cfg             --odir premade_examples/axi_st_d64
python llink_gen.py --cfg cfg/axi_st_d256_gen1_gen2.cfg  --odir premade_examples/axi_st_d256_gen1_gen2

--cfg   points to a configuration file. This can be customized but the cfg
        directory has examples

--odir  generated files are placed in the odir directory.
        (Optional, if not present default is "./<MODULE_NAME>")


This will generated several files in the odir. The names depend on the module <NAME> field in the
cfg file. They will be:
<MODULE_NAME>_info.txt - Text based info file

<MODULE_NAME>_master.f - list files. File paths are prepended ${PROJ_DIR}/llink/script/odir
<MODULE_NAME>_master_top.sv - top level module module
<MODULE_NAME>_master_name.sv - user interface module
<MODULE_NAME>_master_name.sv - phy interface module

<MODULE_NAME>_slave.f - list files. File paths are prepended ${PROJ_DIR}/llink/script/odir
<MODULE_NAME>_slave_top.sv - top level slave module
<MODULE_NAME>_slave_name.sv - user interface module
<MODULE_NAME>_slave_name.sv - phy interface module

The configuration file has many options. Note that everything is coded from the Master's
perspective so that the Master's TX is necessarily the Slave's RX. So for traditional
AXI-MM, the AW bus would generally be an output.



List of CFG:

 axi_st_d64.cfg                         - Basic, simple AXI ST with 64 bit data. 1 Full AIB2 Channel
 axi_mm_a32_d128.cfg                    - Basic, fixed allocation AXI MM with 32 bit address, 128 bit data. 4 Full AIB2 Channel
 axi_mm_a32_d128_packet.cfg             - Basic, packetized version of axi_mm_a32_d128. 1 Full AIB2 Channel
 axi_mm_a48_d512_packet.cfg             - Large packetized AXI-MM with 48 bit address and 512 bit data. 2 Quarter AIB 2 Channel
 axi_mm_a48_d512_packet_variant1.cfg    - Variant of axi_mm_a48_d512_packet with no packet packing (AXI Channelss are not combined into AIB packets
 axi_mm_a48_d512_packet_variant2.cfg    - Variant of axi_mm_a48_d512_packet where packet size is artificailly shrunk to create more packets.
 axi_mm_a48_d512_packet_variant3.cfg    - Variant of axi_mm_a48_d512_packet where packet size is artificailly shrunk further to create more packets.
 axi_fourchan_a32_d32.cfg
 axi_lite_a32_d32.cfg                   - AXI Lite example
 axi_st_d256_gen1_gen2.cfg              - Example of "dynamic" (while in reset) switch from Gen2 to Gen1
 axi_st_d26_norm.cfg                    - Non-switching Gen2 Only for comparison to gen1/gen2 version
 axi_st_d128_asym.cfg                   - Example of asymmetric mode. Generates 3x master and 3x slavep; Full, Half and Quarter Each.
