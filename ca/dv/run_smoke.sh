#!/bin/bash

cd ../../
echo `pwd`
cd -

LOG=$PROJ_DIR/ca/dv/RUN_SMOKE_TEST/ca_tb.log

d_cfg=./scripts/sailrock_cfg.txt

if [ -d RUN_SMOKE_TEST ]; then
    rm -rf RUN_SMOKE_TEST
fi

cd ./scripts
python3 run_all_sim.py copy -d RUN_SMOKE_TEST -cfg $d_cfg

cd ../RUN_SMOKE_TEST

./run_sim             ####alternatively      ./run_sim   [ca_basic_test_c]  [nowaves/cov_nowaves/cov_waves]

# Move log file into a fixed location
if [ -d logs ]; then
    cp logs/ca_tb.log ./ca_tb.log
fi

grep -e "UVM_ERROR :" -e "UVM_FATAL :" $LOG > smoke_log.txt

if `grep -qE "UVM_ERROR\s*:\s*0\s*$" $LOG`  && `grep -qE "UVM_FATAL\s*:\s*0\s*$" $LOG`;  then
     echo " "
     echo --------------------------------------------------------------------------------------------------------
     echo ----------------------------------------- CA smoke test PASSED -----------------------------------------
     echo --------------------------------------------------------------------------------------------------------
     echo " "
else
     echo " "
     echo --------------------------------------------------------------------------------------------------------
     echo ----------------------------------------- CA smoke test FAILED -----------------------------------------
     echo --------------------------------------------------------------------------------------------------------
     grep -E "UVM_ERROR" $LOG
     grep -E "UVM_FATAL" $LOG
fi
