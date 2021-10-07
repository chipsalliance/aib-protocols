#!/bin/bash
cd $PROJ_DIR/spi/dv/tb/tb_spi_master_slave_2
./run  spi_m_s_directed_loopback_test
grep  "UVM_ERROR " $PROJ_DIR/spi/dv/tb/tb_spi_master_slave_2/logs/sim*log  > smoke.txt 
grep  "UVM_FATAL " $PROJ_DIR/spi/dv/tb/tb_spi_master_slave_2/logs/sim*log  >> smoke.txt 

