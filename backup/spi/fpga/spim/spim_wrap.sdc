

create_clock -name sclk_in -period 8.000 -waveform { 0.000 4.000 } [get_ports sclk_in]

create_generated_clock -name spim_top.i_spim_intf.sclk_inv -source [get_ports {sclk_in}] -divide_by 1 -invert

create_clock -name m_avmm_clk -period 4.000 -waveform { 0.000 2.000 } [get_ports m_avmm_clk]


    set_false_path -from [get_clocks sclk_in] -to [get_clocks m_avmm_clk]
    set_false_path -from [get_clocks m_avmm_clk] -to [get_clocks sclk_in]


