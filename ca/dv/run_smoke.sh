#!/bin/bash

cd ../../
echo `pwd`
cd -

LOG=$PROJ_DIR/ca/dv/ca_tb.log
rm -f $LOG

if [ -d RUN_SMOKE_TEST ]; then
    rm -rf RUN_SMOKE_TEST
fi
cd ./scripts
python3 run_all_sim.py copy -d RUN_SMOKE_TEST -cfg sailrock_cfg.txt
cd ../RUN_SMOKE_TEST
./run_sim
cp ca_tb.log ../

####xrun -f ca_tb.args

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
