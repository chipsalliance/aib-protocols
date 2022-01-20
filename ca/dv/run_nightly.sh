#!/bin/bash

cov_wave_opt=nowaves
##uncomment this to run with cov enable (no waves)
#cov_wave_opt=cov_nowaves

## Clean up previous runs
if [ -d nightly.old ]; then
   rm -Rf nightly.old;
   rm -Rf nightly_results.txt.old;
fi
if [ -d nightly ]; then
    mv nightly nightly.old;
    mv nightly_results.txt nightly_results.txt.old
fi
mkdir nightly
touch nightly_results.txt
 
if [ -e nightly_grid_group.txt ]; then rm nightly_grid_group.txt; fi


echo Building Nightly Test Directories
lp_cnt=0;
for CONFIG in `ls examples/*sailrock_cfg.txt`; do
    lp_cnt=$(($lp_cnt+1));
    sailrock_name=${CONFIG/examples\/};
    sailrock_name=${sailrock_name/_sailrock_cfg.txt};
    DIR=${CONFIG/examples/nightly}
    DIR=${DIR/_sailrock_cfg.txt/}
    #echo "DIR is $DIR"
    DIR1=test_${DIR}
    #echo "DIR 1is $DIR1"

case "$sailrock_name" in
    "M2S2_GEN2_F2F_align_error_fifo8") 
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR} -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_align_error_test_c ${cov_wave_opt}"
                                                           echo "cd $DIR; ${run_cmd}; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           ;;
    "M2S2_GEN2_F2F_align_error_fifo16") 
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d $DIR -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_align_error_test_c ${cov_wave_opt}"
                                                           echo "cd $DIR; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           ;;
    "M2S2_GEN2_F2F_align_error_fifo32") 
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d $DIR -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_align_error_test_c ${cov_wave_opt}"
                                                           echo "cd $DIR; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           ;;
    "M2S2_GEN2_F2F_no_ch_delay_async_fifo_afly_x_xz")
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_1 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim  ca_delay_x_xz_values_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_1; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_2 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_basic_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_2; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           ;;
    "M2S2_GEN2_F2F_no_ch_delay_sync_fifo_afly_x_xz")
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_1 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim  ca_delay_x_xz_values_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_1; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_2 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_basic_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_2; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           ;;
    "full_pfull")
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_1 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim  ca_fifo_ptr_values_variations_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_1; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_2 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_basic_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_2; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           ;;
                     
    "full_pfull_ch7")
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_1 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim  ca_fifo_ptr_values_variations_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_1; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_2 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_basic_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_2; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           ;;
    "M2S2_GEN2_F2F_ALIGN_FLY1")
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_1 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim  ca_afly1_stb_incorrect_intv_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_1; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           python3 run_all_sim.py copy -d ${DIR}_2 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_basic_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_2; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           ;;
    "M2S2_GEN2_Q2Q_CH24")
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_1 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim  ca_stb_wd_sel_Q2Q_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_1; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_2 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_basic_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_2; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           ;;
    "M2S2_GEN2_Q2Q")
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_1 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim  ca_stb_wd_sel_bit_sel_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_1; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_2 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_basic_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_2; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           ;;
    "M2S2_GEN2_Q2Q_MARKER_78")
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_1 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim  ca_all_wd_sel_39th_bit_sel_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_1; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_2 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_basic_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_2; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           ;;
    "sync_fifo0_afly1")
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_1 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim  ca_aln_err_by_incorrect_stb_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_1; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_2 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_basic_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_2; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           ;;
    "inter_ch_skew15_32")
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_1 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim  ca_traffic_reset_traffic_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_1; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_2 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_basic_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_2; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           ;; 
    "inter_ch_skew15_32_ch0")
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_1 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim  ca_traffic_reset_traffic_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_1; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_2 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_basic_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_2; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           ;;
    "M2S2_GEN2_F2F")
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_1 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_aln_err_by_incorrect_stb_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_1; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_2 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_traffic_reset_traffic_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_2; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_3 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_basic_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_3; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_4 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_afly1_stb_incorrect_intv_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_4; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_5 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_fifo_ptr_values_variations_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_5; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_6 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_tx_rx_online_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_6; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_7 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_no_external_strobes_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_7; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_8 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_stb_wd_sel_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_8; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_9 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_stb_intv_stb_pos_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_9; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_10 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_reset_during_traffic_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_10; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_11 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_strobe_error_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_11; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_12 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_stb_rcvr_enb_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_12; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_13 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_with_external_strobes_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_13; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_14 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_afly_toggling_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_14; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_15 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_stb_all_bit_sel_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_15; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_16 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_stb_enb_high_low_high_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_16; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_17 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_stb_intv_walking_ones_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_17; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_18 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_wd_bit_sel_ones_cover_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_18; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_19 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_afly1_stb_intv_variations_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_19; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_20 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_rden_dly_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_20; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_21 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_toggle_cover_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_21; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_22 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_aln_err_afly0_by_incorrect_stb_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_22; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_23 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim  ca_stb_en0_aft_aln_done_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_23; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt

                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR}_24 -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_stb_rcvr_aft_aln_done_test_c ${cov_wave_opt}"
                                                           echo "cd ${DIR}_24; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           ;;
    *)
                                                           cd scripts;
                                                           python3 run_all_sim.py copy -d ${DIR} -cfg $CONFIG;
                                                           cd -;
                                                           run_cmd="./run_sim ca_basic_test_c ${cov_wave_opt}"
                                                           echo "cd $DIR; $run_cmd ; rm -rf xcelium.d ; cd ~-;" >> nightly_grid_group.txt
                                                           ;;

esac  ###sailrock_name
done ####for
echo " "
echo "Starting Nightly Regression with ${lp_cnt} TESTS ... "
echo " "

mv nightly_results.txt nightly_results.txt.old
date > nightly_results.txt
./submit_group.pl nightly_grid_group.txt

echo " "
echo "+++++++++++++++++++++++++++++++++++++++++ "
echo "Running Nightly done.... checking results"
echo "+++++++++++++++++++++++++++++++++++++++++ "
echo " "
cd nightly;
test_err=0;
test_pass=0;
for CONFIG in `ls .`; do
       echo "CONFIG NAME   $CONFIG"
       testname_temp=`grep -ir "UVM_TESTNAME" ${CONFIG}/ca_tb.log`
       echo "$testname_temp" >temp.txt
       testname=$(cut --complement -d "=" -f 1 temp.txt )
       rm temp.txt
       if  [ ! -f ${CONFIG}/ca_tb.log ] ;  then
         echo ERROR: $CONFIG $testname did not run
         echo ERROR: $CONFIG $testname did not run. >> ../nightly_results.txt
         test_err=$(($test_err+1));
         echo " "
       elif `grep -qE "xmsim: \*E,ASRTST" ${CONFIG}/ca_tb.log`; then
         echo ERROR: ${CONFIG} $testname Assertion Failure
         echo ERROR: ${CONFIG} $testname Assertion Failure. >> ../nightly_results.txt
         test_err=$(($test_err+1));
         echo " "
       elif `grep -qE "errors with the code \*E" ${CONFIG}/ca_tb.log` || `grep -qE "\*E" ${CONFIG}/ca_tb.log` ; then
         echo ERROR: ${CONFIG} $testname compilation errors
         echo ERROR: ${CONFIG} $testname compilation errors. >> ../nightly_results.txt
         test_err=$(($test_err+1));
         echo " "
       elif `grep -qE "TRNULLID: NULL pointer dereference" ${CONFIG}/ca_tb.log` ; then
         echo ERROR: ${CONFIG} $testname NULL POINTER errors
         echo ERROR: ${CONFIG} $testname NULL POINTER errors. >> ../nightly_results.txt
         test_err=$(($test_err+1));
         echo " "
       elif ! `grep -qE "UVM_ERROR\s*:\s*0" ${CONFIG}/ca_tb.log` || ! `grep -qE "UVM_FATAL\s*:\s*0" ${CONFIG}/ca_tb.log`;  then
         echo ERROR: $CONFIG $testname did not finish
         echo ERROR: $CONFIG $testname did not finish. >> ../nightly_results.txt
         test_err=$(($test_err+1));
         echo " "
       else
         echo pass:  ${CONFIG} $testname completed successfully
         echo pass:  ${CONFIG} $testname completed successfully. >> ../nightly_results.txt
         test_pass=$(($test_pass+1));
         echo " "
       fi
       mv ${CONFIG}  test_${CONFIG}  ###### all run directories' names are given same prefix (test_) for ease of coverage report merge
done  #for
echo "+++++++++++++++++++++++++++++++++++++++++ "
date >> ../nightly_results.txt
echo Summary:  $test_pass : TESTS PASSED...                $test_err : TESTS FAILED for various reasons
echo Summary:  $test_pass : TESTS PASSED...                $test_err : TESTS FAILED for various reasons >> ../nightly_results.txt
