#!/bin/bash

## Functions
function get_sim_results {
  local module=$1
  local logfile=$2
  local num_fatal;
  local num_error;

  if [ -f "$logfile" ]; then
    num_fatal=$(grep "UVM_FATAL :" $logfile | sed 's/[^0-9]*//g')
    num_error=$(grep "UVM_ERROR :" $logfile | sed 's/[^0-9]*//g')

    if [ $(($num_fatal + $num_error)) -ne 0 ]; then
      echo "$module: FAILED" >> $RESULTS
    else
      echo "$module: PASSED" >> $RESULTS
    fi
  else
    echo "$module: NOT RUN" >> $RESULTS
  fi
}

## Check simulation environment.
if ! command -v xrun &> /dev/null
then
  printf "\nERROR: Cadence Xcelium not found!\n\n"
  exit
fi

PROJ_DIR=`pwd`
printf "\nSetting PROJ_DIR to %s\n\n" "$PROJ_DIR"

## Run the smoke test for each module.
TIMESTAMP=$(date)
RESULTS="$PROJ_DIR/smoke_test.log"

echo -e "Smoke Test Results ($TIMESTAMP)\n" > $RESULTS

## axi4-mm
cd $PROJ_DIR/llink/dv/aximm
LOG=tb_mh2.1_sh1/smoke.txt
rm $LOG
sh run_smoke.sh
get_sim_results "AXI4-MM" $LOG
cd $PROJ_DIR

## axi4-st
cd $PROJ_DIR/llink/dv/axist
LOG=tb_mf2.1_sh1_d256/smoke.txt
rm $LOG
sh run_smoke.sh
get_sim_results "AXI4-ST" $LOG
cd $PROJ_DIR

## ca
cd $PROJ_DIR/ca/dv
LOG=ca_tb.log
rm $LOG
sh ca_smoke_test.sh
get_sim_results "CA" $LOG
cd $PROJ_DIR

## lpif
cd $PROJ_DIR/lpif/dv
LOG=lpif_tb.log
sh lpif_smoke_test.sh
get_sim_results "LPIF" $LOG
cd $PROJ_DIR

## spi
cd $PROJ_DIR/spi
LOG=dv/tb/tb_spi_master_slave_2/smoke.txt
rm $LOG
sh run_smoke.sh
get_sim_results "SPI" $LOG
cd $PROJ_DIR

## Print results.
cat $RESULTS

