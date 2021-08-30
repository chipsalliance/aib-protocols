# this is for SYNC_FIFO = 1 mode

create_clock -name com_clk -period 2.000 -waveform { 0.000 1.000 } [get_ports com_clk]

# use these for SYNC_FIFO = 0 mode

#create_clock -name lane_clk[0] -period 2.000 -waveform { 0.000 1.000 } [get_ports lane_clk[0]]
#create_clock -name lane_clk[1] -period 2.000 -waveform { 0.000 1.000 } [get_ports lane_clk[1]]
#create_clock -name lane_clk[2] -period 2.000 -waveform { 0.000 1.000 } [get_ports lane_clk[2]]
#create_clock -name lane_clk[3] -period 2.000 -waveform { 0.000 1.000 } [get_ports lane_clk[3]]

# These are pseudo-static signals

set_false_path -from [get_keepers -no_duplicates {align_fly}]
set_false_path -from [get_keepers -no_duplicates {tx_stb_en}]
set_false_path -from [get_keepers -no_duplicates {tx_stb_rcvr}]
set_false_path -from [get_keepers -no_duplicates {rden_dly*}]

set_false_path -from [get_keepers -no_duplicates {count_x[*]}]
set_false_path -from [get_keepers -no_duplicates {count_xz[*]}]

set_false_path -from [get_keepers -no_duplicates {fifo_empty_val*}]
set_false_path -from [get_keepers -no_duplicates {fifo_pempty_val*}]
set_false_path -from [get_keepers -no_duplicates {fifo_full_val*}]
set_false_path -from [get_keepers -no_duplicates {fifo_pfull_val*}]

set_false_path -from [get_keepers -no_duplicates {rx_stb_bit_sel[*]}]
set_false_path -from [get_keepers -no_duplicates {rx_stb_intv[*]}]
set_false_path -from [get_keepers -no_duplicates {rx_stb_wd_sel[*]}]

set_false_path -from [get_keepers -no_duplicates {tx_stb_bit_sel[*]}]
set_false_path -from [get_keepers -no_duplicates {tx_stb_intv[*]}]
set_false_path -from [get_keepers -no_duplicates {tx_stb_wd_sel[*]}]
