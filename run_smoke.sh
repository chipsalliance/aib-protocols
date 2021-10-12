#!/bin/bash

## Functions
function run_test {
  local mod_name=$1
  local test_dir=$2
  local test_script=$3
  local test_log=$4
  local num_fatal
  local num_error

  echo "Running $mod_name smoke test" >> $RESULTS
  echo "    DIR    : $test_dir" >> $RESULTS
  echo "    SCRIPT : $test_script" >> $RESULTS
  echo "    LOG    : $test_log" >> $RESULTS

  cd $test_dir
  rm -f $test_log
  sh $test_script

  if [ -f "$test_log" ]; then
    # Note the specific "UVM_<message> :" format; this should only appear
    # once in the log file underneath the "--- UVM Report Summary ---" line.
    num_fatal=$(grep "UVM_FATAL :" $test_log | sed 's/[^0-9]*//g')
    num_error=$(grep "UVM_ERROR :" $test_log | sed 's/[^0-9]*//g')

    if [ $(($num_fatal + $num_error)) -ne 0 ]; then
      echo -e "    RESULT : FAILED\n" >> $RESULTS
    else
      echo -e "    RESULT : PASSED\n" >> $RESULTS
    fi
  else
    echo -e "    RESULT : NOT RUN\n" >> $RESULTS
  fi

  cd $PROJ_DIR
}

## Check simulation environment.
## Note: We might need to implement options for other simulators (e.g. VCS).
if ! command -v xrun &> /dev/null
then
  printf "\nERROR: Cadence Xcelium not found!\n\n"
  exit
fi

PROJ_DIR=`pwd`
printf "\nSetting PROJ_DIR to %s\n\n" "$PROJ_DIR"

## Run the smoke test for each module.
RESULTS="$PROJ_DIR/smoke_test.log"

echo -e "Smoke Test Started: $(date)\n" > $RESULTS

for MODULE in AXI4-MM AXI4-ST CA LPIF SPI; do

  # Note: SCRIPT and LOG are relative to DIR.
  case $MODULE in
    AXI4-MM)
      DIR=$PROJ_DIR/llink/dv/aximm
      SCRIPT=run_smoke.sh
      LOG=tb_mh2.1_sh1_128/smoke.txt
      ;;

    AXI4-ST)
      DIR=$PROJ_DIR/llink/dv/axist
      SCRIPT=run_smoke.sh
      LOG=tb_mf2.1_sh1_d256/smoke.txt
      ;;

    CA)
      DIR=$PROJ_DIR/ca/dv
      SCRIPT=ca_smoke_test.sh
      LOG=ca_tb.log
      ;;

    LPIF)
      DIR=$PROJ_DIR/lpif/dv
      SCRIPT=lpif_smoke_test.sh
      LOG=lpif_tb.log
      ;;

    SPI)
      DIR=$PROJ_DIR/spi
      SCRIPT=run_smoke.sh
      LOG=dv/tb/tb_spi_master_slave_2/smoke.txt
      ;;

    *)
      printf "\nERROR: Unknown MODULE %s\n\n" "$MODULE"
      exit
      ;;
  esac

  run_test $MODULE $DIR $SCRIPT $LOG

done

## Print results.
echo -e "Smoke Test Finished: $(date)\n" >> $RESULTS
cat $RESULTS

