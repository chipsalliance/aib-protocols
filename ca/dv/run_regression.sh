#!/bin/bash

run_cmd="./run_sim   ca_basic_test_c   nowaves"
##Replace above line with line below to run regression with cov enable
#run_cmd="./run_sim  ca_basic_test_c   cov_nowaves"

MAX_PARALLEL_JOBS=10
SEC_BETWEEN_UPDATES=60

## Clean up previous runs
if [ -d regression.old ]; then
   rm -Rf regression.old;
   rm -Rf regression_results.txt.old;
fi
if [ -d regression ]; then
    mv regression regression.old;
    mv regression_results.txt regression_results.txt.old
fi
mkdir regression
touch regression_results.txt

if [ -e regression_grid_group.txt ]; then rm regression_grid_group.txt; fi

echo Building Regression Directories
cd cfg_list;
python3 ca_gen_cfg.py    ## Creating Multiple random sailrock cfg files
cd ~-;

for CONFIG in `ls cfg_list/sailrock_array/*sailrock_cfg.txt`; do
    DIR=${CONFIG/cfg_list\/sailrock_array/regression}
    DIR=${DIR/_sailrock_cfg.txt/}

    cd scripts;
    python3 run_all_sim.py copy -d $DIR -cfg $CONFIG >> ../regression_build.log;
    cd ~-;
    echo "cd $DIR; $run_cmd; rm -Rf simv.daidir work.lib++ csrc_debug AN.DB cm.log xcelium.d; cd ~-; " >> regression_grid_group.txt
done

date > regression_results.txt

./submit_group.pl max=$MAX_PARALLEL_JOBS sleep=$SEC_BETWEEN_UPDATES regression_grid_group.txt

echo Running Regressions

for CONFIG in `ls cfg_list/sailrock_array/*sailrock_cfg.txt`; do
    DIR=${CONFIG/cfg_list\/sailrock_array/regression}
    DIR=${DIR/_sailrock_cfg.txt/}

       testname_temp=`grep -ir "UVM_TESTNAME" ${DIR}/ca_tb.log`
       seed_value=`grep -r "svseed" ${DIR}/ca_tb.log`
       echo "$testname_temp" >temp.txt
       testname=$(cut --complement -d "=" -f 1 temp.txt )
       rm temp.txt
        if  [ ! -f ${DIR}/ca_tb.log ] ;  then
          echo ERROR: ${DIR}   $testname  with  ${seed_value}  did not run
          echo ERROR: ${DIR}   $testname  with  ${seed_value}  did not run. >> regression_results.txt
        elif `grep -qE "xmsim: \*E,ASRTST" ${DIR}/ca_tb.log`; then
          echo ERROR: ${DIR}   $testname  with  ${seed_value}   Assertion Failure
          echo ERROR: ${DIR}   $testname  with  ${seed_value}   Assertion Failure. >> regression_results.txt
        elif `grep -qE "errors with the code \*E" ${DIR}/ca_tb.log` || `grep -qE "\*E" ${DIR}/ca_tb.log` ; then
          echo ERROR: ${DIR}   $testname  with  ${seed_value}   compilation errors
          echo ERROR: ${DIR}   $testname  with  ${seed_value}   compilation errors. >> regression_results.txt
        elif `grep -qE "TRNULLID: NULL pointer dereference" ${DIR}/ca_tb.log` ; then
          echo ERROR: ${DIR}   $testname  with  ${seed_value}   NULL POINTER errors
          echo ERROR: ${DIR}   $testname  with  ${seed_value}   NULL POINTER errors. >> regression_results.txt
        elif ! `grep -qE "UVM_ERROR\s*:\s*0" ${DIR}/ca_tb.log` || ! `grep -qE "UVM_FATAL\s*:\s*0" ${DIR}/ca_tb.log`;  then
          echo ERROR: ${DIR}   $testname  with  ${seed_value}   did not finish
          echo ERROR: ${DIR}   $testname  with  ${seed_value}   did not finish. >> regression_results.txt
        else
          echo pass:  ${DIR}   $testname  with  ${seed_value}  completed successfully
          echo pass:  ${DIR}   $testname  with  ${seed_value}  completed successfully. >> regression_results.txt
        fi
done

date >> regression_results.txt
