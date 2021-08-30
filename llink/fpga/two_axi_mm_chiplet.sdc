
create_clock -name clk_wr -period 2.000 -waveform { 0.000 1.000 } [get_ports {clk_wr}]
create_clock -name clk_wr_virt -period 2.000 -waveform { 0.000 1.000 }

