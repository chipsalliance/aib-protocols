set_time_format -unit ns -decimal_places 3

#------------------------------------------------------------------------------
# Create Clock (core clock is 50 MHz. SPI I/O is 20 MHz
# User needs to replace spi_clk_in with a spi clock that coming from PLL.
#------------------------------------------------------------------------------
create_clock -name avmm_clk -period 20.000 -waveform { 0.000 10.000 } [get_ports {avmm_clk}]
create_clock -name sclk -period 50.000 -waveform { 0.000 25.000 } [get_ports {spi_clk_in}]

#------------------------------------------------------------------------------
# Create virtual clock exist outside of the FPGA that used for IO timing of SP -max avmm_clock_period -value_multiplier 0.8I
# For I/O, virtual clock will be the launch clock for input constrints and the latch
# clock for output constraints.
#-------------------------------------------------------------------------------

create_clock -name sclk_ext -period 50.000 

#-------------------------------------------------------------------------------
#set_clock_groups -asynchronous \
  -group [get_clocks {avmm_clk}] \
  -group [get_clocks {sclk}]

#-------------------------------------------------------------------------------
#  Metastable delay. The design required the delay to Meastable flop less
#  than one cycle of either destination clock or source clock 
#-------------------------------------------------------------------------------

set_net_delay -from  *mspi_avmm_csr|cmd_reg*  -to *mspi_intf|bitsync2_cmd_reg|dff1* -max -get_value_from_clock_period  dst_clock_period -value_multiplier 0.8


#------------------------------------------------------------------------------
# The following set_input_delay/set_output_delay is for reference. User should
# modify it based on their own system requirement
#------------------------------------------------------------------------------
set_output_delay  -add_delay -max -clock sclk_ext 25.0 [get_ports {ss_n[*]}]
set_output_delay  -add_delay -min -clock sclk_ext  0.0 [get_ports {ss_n[*]}]

set_input_delay  -add_delay -max -clock sclk_ext 25.0 [get_ports {miso[*]}]
set_input_delay  -add_delay -min -clock sclk_ext  0.0 [get_ports {miso[*]}]

set_output_delay -add_delay -max -clock sclk_ext 25.0 [get_ports mosi] 
set_output_delay -add_delay -min -clock sclk_ext  0.0 [get_ports mosi] 

