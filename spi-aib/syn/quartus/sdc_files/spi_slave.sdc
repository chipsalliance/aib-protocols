#------------------------------------------------------------------------------
# User needs to modify clock, IO timing when using this module based on system
# requirement
#------------------------------------------------------------------------------

set_time_format -unit ns -decimal_places 3

#------------------------------------------------------------------------------
# Create Clock (core clock is 50 MHz. SPI I/O is 20 MHz
#------------------------------------------------------------------------------
create_clock -name avmm_clk -period 20.000 -waveform { 0.000 10.000 } [get_ports {avmm_clk}]
create_clock -name sclk -period 50.000 -waveform { 0.000 25.000 } [get_ports {sclk}]

#------------------------------------------------------------------------------
# Create virtual clock exist outside of the FPGA that used for IO timing of SPI
# For I/O, virtual clock will be the launch clock for input constrints and the latch
# clock for output constraints.
#-------------------------------------------------------------------------------

create_clock -name sclk_ext -period 50.000 

set_clock_groups -asynchronous \
  -group [get_clocks {avmm_clk}] \
  -group [get_clocks {sclk}]

#------------------------------------------------------------------------------
# ss_n is used to make miso tri-state when ss_n is high
# The gated logic should be handled in top level.
#------------------------------------------------------------------------------
set_false_path -from [get_keepers -no_duplicates {ss_n}] -to [get_keepers -no_duplicates {miso}]

#------------------------------------------------------------------------------
# The following set_input_delay/set_output_delay is for reference. User should
# modify it based on their own system requirement
#------------------------------------------------------------------------------
set SPI_INPUTS [get_ports [list ss_n mosi]]
set_input_delay  -add_delay -max -clock sclk_ext 25.0 $SPI_INPUTS
set_input_delay  -add_delay -min -clock sclk_ext  0.0 $SPI_INPUTS

set_output_delay -add_delay -max -clock sclk_ext 25.0 \
                  [get_ports miso]
set_output_delay -add_delay -min -clock sclk_ext  0.0 \
                  [get_ports miso]


