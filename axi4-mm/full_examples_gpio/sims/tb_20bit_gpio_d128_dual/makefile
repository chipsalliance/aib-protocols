#-------------------------------------------------------------------------
# Description: makefile
#-----------------------------------------------------------------------------

default: help

#-----------------------------------------------------------------------------
# user specify Files
#-----------------------------------------------------------------------------
export PROJ_DIR = ../../../../

#-----------------------------------------------------------------
# SEED defaults to random
# To use a seed with value N, specify "SEED=N" on the make command line
#-----------------------------------------------------------------
ifeq ($(SEED), )
  rseedprocid := $(shell echo $$$$)
  rseed := `expr $(shell date +"%S%M%H%d") + $(rseedprocid)`
else
  rseed := $(SEED)
endif
SEEDCMD = +ntb_random_seed=$(rseed)

ifeq ($(UNIQ), ON)
    UNIQID = _$(rseed)
else
    UNIQID =
endif

#-----------------------------------------------------------------------------
# Include Required Files
#-----------------------------------------------------------------------------
export SIM_DIR =${PROJ_DIR}axi4-mm/full_examples_gpio/sims
export tbench_dir = ${shell pwd}

#-----------------------------------------------------------------------------
# Example VCS execution command.
#-----------------------------------------------------------------------------

WAVES_FORMAT ?= WAVES_VPD ## This option compiles in possibility to record VPD. But this can be disabled via plusarg +WAVES_OFF in runtime arguments.

VCS = ${VCS_HOME}/linux64/bin/vcs -full64 -sverilog -Mdir=csrc_debug +vcs+lic+wait -kdb -debug_access+all -lca -debug_region+cell+encrypt -override_timescale=1ps/1ps -cm line+cond+tgl+fsm+branch+assert +nospecify

COMPILE_OPTION ?=

VLOG_COMM = vlogan -sverilog -Mdir=csrc_debug +vcs+lic+wait +v2k -full64 -kdb -v2k_generate \
	-debug_acc+r+w+dmptf -debug_region+cell+encrypt -CFLAGS \
	+define+${WAVES_FORMAT} -timescale=1ns/1ps \
	+incdir+${SIM_DIR} ${COMPILE_OPTION} 

compile:
	 
	 ${VLOG_COMM} -sverilog +v2k -full64 -timescale=1ps/1ps +define+SIM_DIR=${SIM_DIR} +define+AXIMM_DUPLEX -work WORK -ntb_opts uvm -f ${SIM_DIR}/../flist/axi_mm_d128_gpio_dual.f -l compile_aximm.log
	 ${VLOG_COMM} -sverilog  +v2k -full64  -timescale=1ps/1ps -work WORK -f ${SIM_DIR}/../flist/tb_gpio_rtl.cf -l compile_tb.log
	 ${VCS} -debug_acc+all -full64 +lint=TFIPC-L +error+100 +lint=PCWM -top top_tb -l vcs.log

sim :
	./simv -l simulation.log

run : clean gen_cfg compile sim


run_aibrtl : clean gen_cfg compile_aibrtl sim

gen_cfg :
	python ${PROJ_DIR}/llink/script/gpio_llink_gen.py --cfg aximm_ll.cfg --odir aximm_ll_dut_new


#-----------------------------------------------------------------------------
# Help - display gmake option
#-----------------------------------------------------------------------------
help:
	@echo "=========================================================================================="
	@echo "                                       makefile options                                   "
	@echo "=========================================================================================="
	@echo "    	make compile		- Compiles DUT and TB files for simulation"
	@echo "  	  make run    		- Clears, compiles and runs simulation "
	@echo "    	make sim    		- Simulates the design "
	@echo "    	make clean  		- Remove all generated files"
	@echo "    	make gen_cfg  		- Generates Leader and Follower files"
	@echo " "

#-----------------------------------------------------------------------------
# Clean up
#-----------------------------------------------------------------------------

clean:
	rm -rf *.log
	rm -rf *.vpd
	rm -rf simv*
	rm -rf csrc_debug/
	rm -rf DVEfiles/
	rm -rf AN.DB/
	rm -rf work.lib++/
	rm -rf ucli.key
	rm -rf novas.conf verdiLog/ verdi_config_file novas.rc
	rm -rf .fsm.sch.verilog.xml
	rm -rf *.fsdb
	rm -rf aximm_ll_dut_new
