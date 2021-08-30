

create_clock -name sclk -period 8.000 -waveform { 0.000 4.000 } [get_ports {sclk}]
create_generated_clock -name spis_top.i_spis_intf.sclk_inv -source [get_ports {sclk}] -divide_by 1 -invert
create_clock -name s_avmm_clk -period 4.000 -waveform { 0.000 2.000 } [get_ports s_avmm_clk]


    set_false_path -from [get_clocks sclk] -to [get_clocks s_avmm_clk]
    set_false_path -from [get_clocks s_avmm_clk] -to [get_clocks sclk]


