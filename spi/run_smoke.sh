#!/bin/bash

SIMDIR=$PROJ_DIR/spi/dv/tb/tb_spi_master_slave_2
cd $SIMDIR
rm -f $SIMDIR/logs/sim*log
./run spi_m_s_directed_loopback_test

grep -e "UVM_ERROR :" -e "UVM_FATAL :" $SIMDIR/logs/sim*log > smoke_log.txt

if `grep -qE "UVM_ERROR\s*:\s*0\s*$" $SIMDIR/logs/sim*log`  && `grep -qE "UVM_FATAL\s*:\s*0\s*$" $SIMDIR/logs/sim*log`;  then
     echo " "
     echo --------------------------------------------------------------------------------------------------------
     echo ----------------------------------------- SPI smoke test PASSED -----------------------------------------
     echo --------------------------------------------------------------------------------------------------------
     echo " "
 else
     echo " "
     echo --------------------------------------------------------------------------------------------------------
     echo ----------------------------------------- SPI smoke test FAILED -----------------------------------------
     echo --------------------------------------------------------------------------------------------------------
     grep -E "UVM_ERROR" $SIMDIR/logs/sim*log
     grep -E "UVM_FATAL" $SIMDIR/logs/sim*log
 fi

