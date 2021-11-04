set_time_format -unit ns -decimal_places 3

#------------------------------------------------------------------------------
# Create Clock (core clock is 50 MHz. SPI I/O is 20 MHz
# User needs to replace spi_clk_in with a spi clock that coming from PLL.
#------------------------------------------------------------------------------
create_clock -name avmm_clk -period 20.000 -waveform { 0.000 10.000 } [get_ports {avmm_clk}]
create_clock -name sclk -period 50.000 -waveform { 0.000 25.000 } [get_ports {spi_clk_in}]
#-------------------------------------------------------------------------------
set_clock_groups -asynchronous \
  -group [get_clocks {avmm_clk}] \
  -group [get_clocks {sclk}]

#------------------------------------------------------------------------------
# The following set_input_delay/set_output_delay is for reference. User should
# modify it based on their own system requirement
#------------------------------------------------------------------------------
set SPI_OUTPUTS [get_ports [list ss_n mosi]]
set_input_delay  -add_delay -max -clock [get_clocks {sclk}] 25.0 \
                  [get_ports miso]
set_input_delay  -add_delay -min -clock [get_clocks {sclk}]  0.0 \
                  [get_ports miso]
set_output_delay -add_delay -max -clock [get_clocks {sclk}] 25.0 \
                  $SPI_OUTPUTS
set_output_delay -add_delay -min -clock [get_clocks {sclk}]  0.0 \
                  $SPI_OUTPUTS

