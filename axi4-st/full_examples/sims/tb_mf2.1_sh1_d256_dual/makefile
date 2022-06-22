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
export SIM_DIR =${PROJ_DIR}/axi4-st/full_examples/sims
export tbench_dir = $(SIM_DIR)/tb_mf2.1_sh1_d256_dual

## Define RTL directory
export AIB_ROOT=${PROJ_DIR}/../aib-phy-hardware
export RTL_ROOT=${AIB_ROOT}/v2.0/rev1/rtl
GEN1_ROOT=${AIB_ROOT}/v1.0/rev2/rtl/
export AIB_DV_ROOT =${RTL_ROOT}/../dv
export V1S_ROOT=${GEN1_ROOT}/v1_slave

#-----------------------------------------------------------------------------
# Example VCS execution command.
#-----------------------------------------------------------------------------

WAVES_FORMAT ?= WAVES_VPD ## This option compiles in possibility to record VPD. But this can be disabled via plusarg +WAVES_OFF in runtime arguments.

VCS = ${VCS_HOME}/linux64/bin/vcs -full64 -sverilog -Mdir=csrc_debug +vcs+lic+wait -kdb -debug_access+all -lca -debug_region+cell+encrypt -override_timescale=1ps/1ps -cm line+cond+tgl+fsm+branch+assert +nospecify

COMPILE_OPTION ?=

VLOG_COMM = vlogan -sverilog -Mdir=csrc_debug +vcs+lic+wait +v2k -full64 -kdb -v2k_generate \
	-debug_acc+r+w+dmptf -debug_region+cell+encrypt -CFLAGS \
	+define+${WAVES_FORMAT} -timescale=1ns/1ps \
	+incdir+${SIM_DIR} ${COMPILE_OPTION}  +incdir+${AIB_DV_ROOT}/interface/ +incdir+${AIB_DV_ROOT}/test/data

compile:
	${VLOG_COMM} -sverilog +v2k -full64 -timescale=1ps/1ps -work WORK -ntb_opts uvm -f  ${AIB_DV_ROOT}/flist/ms.cf -l compile_ms1.log
	${VLOG_COMM} -sverilog +v2k -full64 -timescale=1ps/1ps +define+AXIST_DUAL -work WORK -ntb_opts uvm -f ${SIM_DIR}/../flist/axi_st_d256_multichannel_f2h_dual.f -l compile_ms1_axist.log

	${VLOG_COMM} -sverilog  +v2k -full64 -timescale=1ps/1ps +define+FOR_SIM_ONLY +define+TIMESCALE_EN+VCS+BEHAVIORAL+MAIB_PIN96+ALTR_HPS_INTEL_MACROS_OFF -work WORK -ntb_opts uvm -f  ${AIB_DV_ROOT}/flist/sl_v1.cf -l compile_s1.log

	${VLOG_COMM} -sverilog  +v2k -full64  -timescale=1ps/1ps +define+VCS+SL_AIB_GEN1 -work WORK -ntb_opts uvm -f ${SIM_DIR}/../flist/tb_dual_rtl.cf -l compile_tb.log
	${VCS} -debug_acc+all -full64 +lint=TFIPC-L +error+100 +lint=PCWM -top top_tb -l vcs.log

sim :

	./simv -l simulation.log

run : clean gen_cfg compile sim

gen_cfg :
	dos2unix ../../common/* *  2>/dev/null
	python ${PROJ_DIR}/llink/script/dual_axist_llink_gen.py --cfg axi_st_d256_dual_multichannel.cfg

#-----------------------------------------------------------------------------
# Help - display gmake option
#-----------------------------------------------------------------------------
help:
	@echo "========================================================="
	@echo "                     makefile options                    "
	@echo "========================================================="
	@echo "    	make compile		- Compiles DUT and TB files for simulation"
	@echo "  	make run    		- Clears, compiles and runs simulation"
	@echo "    	make sim    		- Simulation "
	@echo "    	make clean  		- Remove all generated files"
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
	rm -rf axi_st_d256_dual_multichannel
	rm -rf novas.conf verdiLog/ verdi_config_file novas.rc
	rm -rf .fsm.sch.verilog.xml
