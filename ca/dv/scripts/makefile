## ////////////////////////////////////////////////////////////////////////////////////////////////////
## //
## //        Copyright (C) 2021 Eximius Design
## //                All Rights Reserved
## //
## // This entire notice must be reproduced on all copies of this file
## // and copies of this file may only be made by a person if such person is
## // permitted to do so under the terms of a subsisting license agreement
## // from Eximius Design
## //
## // Licensed under the Apache License, Version 2.0 (the "License");
## // you may not use this file except in compliance with the License.
## // You may obtain a copy of the License at
## //
## //     http://www.apache.org/licenses/LICENSE-2.0
## //
## // Unless required by applicable law or agreed to in writing, software
## // distributed under the License is distributed on an "AS IS" BASIS,
## // WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## // See the License for the specific language governing permissions and
## // limitations under the License.
## //
## // Functional Descript: Makefile for Channel Alignment Test run
## //
## //
## //
## ////////////////////////////////////////////////////////////////////////////////////////////////////

default: help

#-----------------------------------------------------------------------------
# user specify Files
#-----------------------------------------------------------------------------
DESIGNWARE_HOME = <DW_HOME_PATH_HERE>
PROJ_DIR	= ../../..
xcelium_home	= CDNS-1.2

aib_inc_dir     = ${TESTBENCH_DIR}/{top,data,config,params/aib,macro,tests,aib_uvm/aib_test,aib_uvm/aib_master/aib_master_por,aib_uvm/aib_slave/aib_slave_por,aib_uvm/aib_env/,interface,aib2.0}
ca_tb_inc_dir   = ${CA_DV_HOME}/{tb,export_src,export_src/chan_delay_agent,../../common/dv/reset_agent}

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
SIM_DIR         = ${CURDIR}
tbench_dir      = $(SIM_DIR)

AIB2_PHY_HOME	= ${PROJ_DIR}/aib
DESIGN          = ${PROJ_DIR}
AIB2_RTL        = ${AIB2_PHY_HOME}/rtl
AIB2_DV         = ${AIB2_PHY_HOME}/dv
AIB2_EMIB       = ${AIB2_DV}/emib
AIB2_INTERFACE  = ${AIB2_DV}/interface

CA              = ${DESIGN}/ca
DV              = ${CA}/dv
CA_DV_HOME      = ${DV}

# Define RTL directory
LOG_DIR 	= ./logs
RTL_ROOT=${PROJ_DIR}
AIB_ROOT=${RTL_ROOT}/../aib-phy-hardware/

AIB_RTL_ROOT=${AIB_ROOT}
TESTBENCH_DIR=${PROJ_DIR}/aib/dv
AIB2_ROOT= ${AIB_RTL_ROOT}/v2.0/rev1/rtl/
V2COM_ROOT=${AIB_RTL_ROOT}/v1.0/rev2/rtl/v2_common
V1M_ROOT=${AIB_RTL_ROOT}/v1.0/rev2/rtl/v1_master
V1S_ROOT=${AIB_RTL_ROOT}/v1.0/rev2/rtl/v1_slave
V2M_ROOT=${AIB_RTL_ROOT}/v1.0/rev2/rtl/v2_master
V2S_ROOT=${AIB_RTL_ROOT}/v1.0/rev2/rtl/v2_slave

CA_FILELIST=${RTL_ROOT}/ca/rtl/ca_update.f
CA_DV_DIR = .

#-----------------------------------------------------------------------------
# AIB Include Required Files
#-----------------------------------------------------------------------------
# Include all required directories
INC_AIB_DIR 	 = ${TESTBENCH_DIR}/params/aib
INC_MACRO_DIR 	 = ${TESTBENCH_DIR}/macro
INC_DATA_DIR 	 = ${TESTBENCH_DIR}/data

AIB2_FILELIST = ${PROJ_DIR}/aib/filelist/AIB2.0.f
V1S_FILELIST =  ${PROJ_DIR}/aib/filelist/dut_v1s.f
V1M_FILELIST =  ${PROJ_DIR}/aib/filelist/dut_v1m.f
AIB_UVM_FILELIST = ${TESTBENCH_DIR}/filelist/aib_uvm.f
EMIB_FILELIST = ${PROJ_DIR}/aib/filelist/emib.f

INC = +incdir+./+${INC_AIB_DIR}+$(INC_MACRO_DIR)+$(INC_DATA_DIR)+${AVM_BFM_DIR}

VCS_DEFINE  = +define+USE_REAL_TIMER+MAX_NUM_SCENARIO_ITEMS=50
AIB_VERSION = +define+AIB

EXTRA_RUN =  -LDFLAGS "-g -rdynamic" -lgcov

#-----------------------------------------------------------------------------
TOP_FILES = ${CA_DV_HOME}/tb/ca_tb_files.f

#-----------------------------------------------------------------------------
# Example VCS execution command.
#-----------------------------------------------------------------------------

VCS = ${VCS_HOME}/linux64/bin/vcs -full64 -sverilog -Mdir=csrc_debug +vcs+lic+wait -kdb -debug_access+all -lca -ntb_opts uvm -cm line+cond+tgl+fsm -debug_region+cell+encrypt -override_timescale=1ps/1ps

AST = -cm assert

VLOG_COMM = vlogan -sverilog -Mdir=csrc_debug +vcs+lic+wait +v2k -full64 -kdb -v2k_generate \
	-debug_acc+r+w+dmptf -debug_region+cell+encrypt -CFLAGS \
	+define+SYNOPSYS_SV +define+DESIGNWARE_INCDIR=${DESIGNWARE_HOME} \
	+define+UVM_PACKER_MAX_BYTES=1500000 +define+UVM_DISABLE_AUTO_ITEM_RECORDING \
	+define+WAVES -timescale=1ns/1ps +define+directed_test_sequence_length=10 \
	+incdir+${aib_inc_dir} +incdir+${ca_tb_inc_dir}

VLOG_COMM_DUT = vlogan -sverilog +v2k -full64 -kdb +define+VCS_TIMESCALE_EN

#-----------------------------------------------------------------------------
## Compile
#-----------------------------------------------------------------------------
comp_uvm: check_log_dir
	${VLOG_COMM}  -ntb_opts uvm -work WORK -l ./logs/compile_uvm.log
comp_aib_tb: comp_uvm
	${VLOG_COMM} -sverilog +v2k -full64 -timescale=1ps/1ps -work WORK -ntb_opts uvm -f ${AIB_UVM_FILELIST} -l ./logs/compile_aib.log
comp_ca :
	${VLOG_COMM} -sverilog +v2k -full64 -timescale=1ps/1ps -work WORK -ntb_opts uvm -f ${CA_FILELIST}  -l ./logs/compile_ca.log
comp_emib :
	${VLOG_COMM} -sverilog +v2k -full64 -timescale=1ps/1ps -work WORK -ntb_opts uvm -f ${EMIB_FILELIST}  -l ./logs/compile_emib.log
comp_aib2:
	${VLOG_COMM}  +define+AXI_EN -sverilog +v2k -full64 -timescale=1ps/1ps +define+VCS -work WORK -ntb_opts uvm -f ${AIB2_FILELIST} -l ./logs/compile_aib2.log

comp_dut_v1m:
	${VLOG_COMM_DUT} +define+BEHAVIORAL +define+AIB_TOP_PIN96 -sverilog +v2k -full64 -timescale=1ps/1ps -work WORK -ntb_opts uvm -f ${V1M_FILELIST}  -l ./logs/compile_v1m.log
comp_dut_v1s:
	${VLOG_COMM_DUT} +define+ALTR_HPS_INTEL_MACROS_OFF+MAIB_PIN96 -sverilog +v2k -full64 -timescale=1ps/1ps -work WORK -ntb_opts uvm -f ${V1S_FILELIST}  -l ./logs/compile_v1s.log

#-----------------------------------------------------------------------------
## Compile TOP Level
#-----------------------------------------------------------------------------
scripts_dir = ${CA_DV_HOME}/scripts

MODE := m2s2

GEN_ARG += ${MODE}

ifneq (,$(findstring m2s2,$(MODE)))
comp_define     = +define+TEST_1_AIB
master_cfg_file = ./master_0_config_aib.dat
slave_cfg_file  = ./slave_0_config_aib.dat
endif
ifneq (,$(findstring m2s1,$(MODE)))
comp_define     = +define+TEST_1_AIB+SL_AIB_GEN1
master_cfg_file = ./master_0_config_aib.dat
slave_cfg_file  = ${TESTBENCH_DIR}/data/dsp1_image/sl2_dsp1_fifo2x.dat
endif
ifneq (,$(findstring m1s2,$(MODE)))
comp_define     = +define+TEST_1_AIB+MS_AIB_GEN1
master_cfg_file = ${TESTBENCH_DIR}/data/dsp1_image/ms1_dsp1_reg.dat
slave_cfg_file  = ./slave_0_config_aib.dat
endif

comp_top:
	echo ${comp_define}
	${VLOG_COMM} -sverilog +v2k -full64  ${comp_define} -timescale=1ps/1ps -work WORK -ntb_opts uvm -f ${TOP_FILES}  -l ./logs/compile_${GEN_ARG}.log
	${VCS} ${EXTRA_RUN} -top ca_top_tb -l vcs.log

comp_aib : check_log_dir comp_aib_tb comp_dut_v1m comp_dut_v1s comp_aib2 comp_emib
comp_ex  : xcomp_m2s1
comp_all  : all_x
#comp_all  : all_p2p

#-----------------------------------------------------------------------------
## Generation Config
#-----------------------------------------------------------------------------
DEFAULT_CFG = sailrock_cfg.txt
FILE_EXISTS := $(or $(and $(wildcard $(cfg_exist)),1),0)
pre_gen_cfg :
	$(eval sailrock_cfg := sailrock_cfg.txt)
	$(eval aib_default_cfg := ${scripts_dir}/aib_cfg_default.txt)
	$(eval ca_default_cfg := ${scripts_dir}/ca_cfg_default.txt)
	$(eval aib_config_o := aib_config.txt)
	$(eval ca_config_o := ca_config_define.svi1)
	$(eval comp_cmd := comp_${GEN_ARG})
	@echo " Work on mode " ${GEN_ARG}
	@echo " ==== Generating config files from sailrock_cfg.txt ==== "
	python ${scripts_dir}/aib_gen_parser.py -f ${sailrock_cfg} -aib_cfg ${aib_default_cfg} -o ${aib_config_o}
	#python ${scripts_dir}/ca_gen_parser.py -f ${sailrock_cfg} -cfg ${ca_default_cfg} -o ${ca_config_o}
	@echo "python ${scripts_dir}/aib_gen_parser.py -f ${sailrock_cfg} -aib_cfg ${aib_default_cfg} -o ${aib_config_o}"
	@echo "python ${scripts_dir}/ca_gen_parser.py -f ${sailrock_cfg} -cfg ${ca_default_cfg} -o ${ca_config_o}"
	perl ${scripts_dir}/ca_gen_parser.pl -f ${sailrock_cfg}  ####generates ca_config_define.svi file in run_directory
	${scripts_dir}/aib_gen_config $(aib_config_o)
	@echo " ==== Done generate all config files ==== "

## Gen cfg always need to compile all
gen_cfg : pre_gen_cfg

#-----------------------------------------------------------------------------
## Simulation
#-----------------------------------------------------------------------------

SCENARIO=directed_test
gen_scenario += $(SCENARIO)

sim :
	./simv +UVM_TESTNAME=${gen_scenario} $(SEEDCMD) +UVM_VERBOSITY=UVM_LOW +AIB_IF_COUNT=1 +AIB_CONFIG_DIR=./ +AIB_MASTER_CONFIG_FILE=${master_cfg_file} +AIB_SLAVE_CONFIG_FILE=${slave_cfg_file} -l ./logs/sim_${GEN_ARG}$(UNIQID).log

.EXPORT_ALL_VARIABLES:

#-----------------------------------------------------------------------------
## Run all Steps
#-----------------------------------------------------------------------------
run_all : comp_all
#### For XCELIUM
run_allX : gen_cfg comp_allX comp_topX simX

# example command to generate coverage report in VCS
cov:
	urg -dir simv.vdb

verdi_conv:
	verdi -cov -covdir simv.vdb &

debug:
	./simv ${AST} -classdebug +UVM_CONFIG_DB_TRACE +vmm_log_default=DEBUG | tee sim.log

check_log_dir:
	if [ ! -d "$(LOG_DIR)" ]; then mkdir -p $(LOG_DIR); fi

verdi:
	verdi -ssf test_top.fsdb &


#-----------------------------------------------------------------------------
# Help - display gmake option
#-----------------------------------------------------------------------------
help:
	@echo "========================================================="
	@echo "                     makefile options                    "
	@echo "========================================================="
	@echo "    make gen_cfg                         - Generate  all configure file base on sailrock_cfg.txt"
	@echo "    make comp_all,comp_aib,comp_ex       - Compile All , All Eximius codes"
	@echo "    make sim                             - Simulation "
	@echo "    make run_all                         - Generate cfg, Compile and run Simulate"
	@echo "    make cov                             - Generate the coverage report"
	@echo "    make clean                           - Remove all generated files"
	@echo " "

#-----------------------------------------------------------------------------
# Clean up
#-----------------------------------------------------------------------------

clean:
	rm -rf *.vro simv* csrc* *.vshell depchk*vr */*~
	rm -rf .__snps* *.db* *.vpd* *.log *~ obj scs* work DVEfiles
	rm -rf *.fcov *.html .vhdl.assert* .vlog.assert* vc_hdrs.h urgReport
	rm -rf pioneer_shell.v pioneer.vdb pioneer.config transcript virsim.cfg
	rm -f */*.bak *.sav *.bak *.key .restartSimSession.tcl.old
	rm -rf 64 AN.DB work.lib* logs *.log

arcs:
	arc shell cadence_xcelium,cadence_xcelium-lic,synopsys_vip_common/vip_R-2020.12G, synopsys_verdi/R-2020.12, vcs/R-2020.12-SP1, python/3.8.10


#-----------------------------------------------------------------------------
# Cadence/Xcelium Support
#-----------------------------------------------------------------------------
XRUN_UVM = -uvmhome ${xcelium_home} -uvm -access rwc -sv +xm64bit -licqueue

XRUN_COMP_ARGS = -define CADENCE  -define UVM_PACKER_MAX_BYTES=1500000 +xmtimescale+1ns/1ps +define+BEHAVIORAL +define+AIB_TOP_PIN96 +define+ALTR_HPS_INTEL_MACROS_OFF+MAIB_PIN96
XRUN_COMP_FILES = -f ${V1M_FILELIST} -f ${V1S_FILELIST} -f ${AIB2_FILELIST} -f ${AIB_UVM_FILELIST} -f ${CA_FILELIST} -f ${TOP_FILES}
XRUN_COMP_TOP_FILES = -f ${TOP_FILES}
#XRUN_COMP_AIB_FILES = -f ${V1M_FILELIST} -f ${V1S_FILELIST} -f ${AIB2_FILELIST} -f ${AIB_UVM_FILELIST} -f ${EMIB_FILELIST}
XRUN_COMP_AIB_FILES = -f ${V1M_FILELIST} -f ${V1S_FILELIST}  -f ${AIB2_FILELIST} ${TESTBENCH_DIR}/top/abstract_class_pkg.sv ${TESTBENCH_DIR}/config/test_aib_cfg_pkg.sv -f ${AIB_UVM_FILELIST} -f ${EMIB_FILELIST}
XRUN_SIM_ARGS_DEBUG = +UVM_CONFIG_DB_TRACE +UVM_VERBOSITY=UVM_LOW +AIB_IF_COUNT=1 +AIB_TRANS_COUNT=120 +AIB_CONFIG_DIR=./ +MASTER_CONFIG_FILE=./
XRUN_SIM_ARGS = +UVM_VERBOSITY=UVM_LOW +AIB_IF_COUNT=1 +AIB_TRANS_COUNT=120 +AIB_CONFIG_DIR=./ +AIB_MASTER_CONFIG_FILE=${master_cfg_file} +AIB_SLAVE_CONFIG_FILE=${slave_cfg_file} ${comp_define}

my_xlm1 = +incdir+${aib_inc_dir} ${TESTBENCH_DIR}/top/abstract_class_pkg.sv ${TESTBENCH_DIR}/params/aib/aib_param_pkg.sv  ${TESTBENCH_DIR}/macro/macro_intf_inst.svh ${TESTBENCH_DIR}/macro/macro_tb_dut_inst.svh ${TESTBENCH_DIR}/macro/macro_intf_to_uvm.svh ${TESTBENCH_DIR}/interface/ca_if.sv ${TESTBENCH_DIR}/interface/vclock_if.sv  ${TESTBENCH_DIR}/interface/aib_mac_if.sv  ${TESTBENCH_DIR}/interface/avalon_mm_if.sv  ${TESTBENCH_DIR}/interface/dut_bump_if.sv  ${TESTBENCH_DIR}/interface/tb_nios_if.sv ${TESTBENCH_DIR}/interface/dut_if_mac.sv ${TESTBENCH_DIR}/aib2.0/tb_aib2_dut_wrapper_m0.sv ${TESTBENCH_DIR}/aib2.0/tb_aib2_dut_wrapper_s0.sv ${TESTBENCH_DIR}/aib2.0/tb_emib.sv ${TESTBENCH_DIR}/top/delay_unit.v ${TESTBENCH_DIR}/aib_uvm/aib_test/aib_test_macros.svh ${TESTBENCH_DIR}/top/tb_dut_wrapper_m0.sv ${TESTBENCH_DIR}/top/tb_dut_wrapper_s0.sv ${TESTBENCH_DIR}/aib_uvm/aib_master/aib_master_por/aib_master_por_pkg.sv ${TESTBENCH_DIR}/aib_uvm/aib_slave/aib_slave_por/aib_slave_por_pkg.sv ${TESTBENCH_DIR}/aib_uvm/aib_env/aib_env_pkg.sv ${TESTBENCH_DIR}/aib_uvm/aib_master/aib_master_common/aib_master_common_pkg.sv ${TESTBENCH_DIR}/aib_uvm/aib_slave/aib_slave_common/aib_slave_common_pkg.sv ${TESTBENCH_DIR}/top/clk_gen.sv ${TESTBENCH_DIR}/macro/macro_clk_gen.svh              ${CA_DV_HOME}/tb/ca_GENERATED_defines.svh -f ${CA_DV_HOME}/../rtl/ca_update.f  ${PROJ_DIR}/common/dv/p2p_lite.sv  +incdir+${CA_DV_HOME}/tb/ +incdir+${PROJ_DIR}/common/dv/reset_agent/  +incdir+${CA_DV_HOME}/export_src/chan_delay_agent/ ${PROJ_DIR}/common/dv/reset_agent/reset_pkg.svh ${PROJ_DIR}/common/dv/reset_agent/reset_if.sv ${CA_DV_HOME}/export_src/chan_delay_agent/chan_delay_pkg.svh ${CA_DV_HOME}/export_src/chan_delay_agent/chan_delay_if.sv +incdir+${CA_DV_HOME}/export_src/ ${CA_DV_HOME}/local_src/ca_gen_if.sv ${CA_DV_HOME}/export_src/ca_data_pkg.svh ${CA_DV_HOME}/export_src/ca_tx_tb_out_if.sv ${CA_DV_HOME}/export_src/ca_tx_tb_out_pkg.svh ${CA_DV_HOME}/export_src/ca_tx_tb_in_if.sv ${CA_DV_HOME}/export_src/ca_tx_tb_in_pkg.svh ${CA_DV_HOME}/export_src/ca_rx_tb_in_if.sv ${CA_DV_HOME}/export_src/ca_rx_tb_in_pkg.svh ${CA_DV_HOME}/ca_pkg.svh ${CA_DV_HOME}/tb/ca_DUT_wrapper.sv ${CA_DV_HOME}/tb/ca_top_tb.sv -top ca_top_tb +UVM_TESTNAME=${gen_scenario} -input ../ca_shm.tcl -l ca_tb.log
my_x = ${TESTBENCH_DIR}/params/aib/aib_param_pkg.sv ${TESTBENCH_DIR}/macro/macro_intf_inst.svh ${TESTBENCH_DIR}/macro/macro_tb_dut_inst.svh ${TESTBENCH_DIR}/macro/macro_intf_to_uvm.svh ${TESTBENCH_DIR}/interface/ca_if.sv ${TESTBENCH_DIR}/interface/vclock_if.sv  ${TESTBENCH_DIR}/interface/aib_mac_if.sv  ${TESTBENCH_DIR}/interface/avalon_mm_if.sv  ${TESTBENCH_DIR}/interface/dut_bump_if.sv  ${TESTBENCH_DIR}/interface/tb_nios_if.sv ${TESTBENCH_DIR}/interface/dut_if_mac.sv ${TESTBENCH_DIR}/aib2.0/tb_aib2_dut_wrapper_m0.sv ${TESTBENCH_DIR}/aib2.0/tb_aib2_dut_wrapper_s0.sv ${TESTBENCH_DIR}/aib2.0/tb_emib.sv ${TESTBENCH_DIR}/top/delay_unit.v ${TESTBENCH_DIR}/aib_uvm/aib_test/aib_test_macros.svh ${TESTBENCH_DIR}/top/tb_dut_wrapper_m0.sv ${TESTBENCH_DIR}/top/tb_dut_wrapper_s0.sv ${TESTBENCH_DIR}/aib_uvm/aib_master/aib_master_por/aib_master_por_pkg.sv ${TESTBENCH_DIR}/aib_uvm/aib_slave/aib_slave_por/aib_slave_por_pkg.sv ${TESTBENCH_DIR}/aib_uvm/aib_env/aib_env_pkg.sv ${TESTBENCH_DIR}/aib_uvm/aib_master/aib_master_common/aib_master_common_pkg.sv ${TESTBENCH_DIR}/aib_uvm/aib_slave/aib_slave_common/aib_slave_common_pkg.sv ${TESTBENCH_DIR}/top/clk_gen.sv ${TESTBENCH_DIR}/macro/macro_clk_gen.svh              ${CA_DV_HOME}/tb/ca_GENERATED_defines.svh -f ${CA_DV_HOME}/../rtl/ca_update.f  ${PROJ_DIR}/common/dv/p2p_lite.sv  +incdir+${CA_DV_HOME}/tb/ +incdir+${PROJ_DIR}/common/dv/reset_agent/  +incdir+${CA_DV_HOME}/export_src/chan_delay_agent/ ${PROJ_DIR}/common/dv/reset_agent/reset_pkg.svh ${PROJ_DIR}/common/dv/reset_agent/reset_if.sv ${CA_DV_HOME}/export_src/chan_delay_agent/chan_delay_pkg.svh ${CA_DV_HOME}/export_src/chan_delay_agent/chan_delay_if.sv +incdir+${CA_DV_HOME}/export_src/ ${CA_DV_HOME}/local_src/ca_gen_if.sv ${CA_DV_HOME}/export_src/ca_data_pkg.svh ${CA_DV_HOME}/export_src/ca_tx_tb_out_if.sv ${CA_DV_HOME}/export_src/ca_tx_tb_out_pkg.svh ${CA_DV_HOME}/export_src/ca_tx_tb_in_if.sv ${CA_DV_HOME}/export_src/ca_tx_tb_in_pkg.svh ${CA_DV_HOME}/export_src/ca_rx_tb_in_if.sv ${CA_DV_HOME}/export_src/ca_rx_tb_in_pkg.svh ${CA_DV_HOME}/ca_pkg.svh ${CA_DV_HOME}/tb/ca_DUT_wrapper.sv ${CA_DV_HOME}/tb/ca_top_tb.sv -top ca_top_tb +UVM_TESTNAME=${gen_scenario} -input ../ca_shm.tcl -l ca_tb.log

my_xlm2 = ${CA_DV_HOME}/tb/ca_GENERATED_defines.svh -f ${CA_DV_HOME}/../rtl/ca_update.f  ${PROJ_DIR}/common/dv/p2p_lite.sv  +incdir+${CA_DV_HOME}/tb/ +incdir+${PROJ_DIR}/common/dv/reset_agent/  +incdir+${CA_DV_HOME}/export_src/chan_delay_agent/ ${PROJ_DIR}/common/dv/reset_agent/reset_pkg.svh ${PROJ_DIR}/common/dv/reset_agent/reset_if.sv ${CA_DV_HOME}/export_src/chan_delay_agent/chan_delay_pkg.svh ${CA_DV_HOME}/export_src/chan_delay_agent/chan_delay_if.sv +incdir+${CA_DV_HOME}/export_src/ ${CA_DV_HOME}/local_src/ca_gen_if.sv ${CA_DV_HOME}/export_src/ca_data_pkg.svh ${CA_DV_HOME}/export_src/ca_tx_tb_out_if.sv ${CA_DV_HOME}/export_src/ca_tx_tb_out_pkg.svh ${CA_DV_HOME}/export_src/ca_tx_tb_in_if.sv ${CA_DV_HOME}/export_src/ca_tx_tb_in_pkg.svh ${CA_DV_HOME}/export_src/ca_rx_tb_in_if.sv ${CA_DV_HOME}/export_src/ca_rx_tb_in_pkg.svh ${CA_DV_HOME}/ca_pkg.svh ${CA_DV_HOME}/tb/ca_DUT_wrapper.sv ${CA_DV_HOME}/tb/ca_top_tb.sv -top ca_top_tb +UVM_TESTNAME=${gen_scenario} -input ../ca_shm.tcl -l ca_tb.log +UVM_VERBOSITY=UVM_LOW

my_cmd_p2p_defines   = +define+P2P_LITE +define+P2P_LITE_CH_DELAY_ENB
my_cmd_aib_defines   = +define+CA_YELLOW_OVAL +define+AIB_DATA_DELAY

############################# TARGETS #################################
all_x :	gen_cfg
	xrun  ${XRUN_UVM} ${XRUN_COMP_ARGS}  +incdir+${aib_inc_dir} ${XRUN_SIM_ARGS} ${XRUN_COMP_AIB_FILES} ${my_cmd_aib_defines} ${my_x}

all_p2p : gen_cfg
	  xrun  ${XRUN_UVM} ${XRUN_COMP_ARGS} ${my_xlm2} ${my_cmd_p2p_defines}

xcomp_aib : check_log_dir
	xrun -elaborate +define+INCA ${XRUN_UVM} ${XRUN_COMP_ARGS} ${XRUN_COMP_AIB_FILES} -l ./logs/xcompile_aib.log | tee ./logs/xcompile_all.log

xcomp_security:
	 xrun -elaborate +define+INCA ${XRUN_UVM} ${XRUN_COMP_ARGS} ${XRUN_COMP_SECURITY_FILES}  -l ./logs/xcompile_security.log | tee ./logs/xcompile_all.log


xcomp_m2s2: check_log_dir
	xrun -elaborate +define+INCA ${XRUN_UVM} ${XRUN_COMP_ARGS} ${XRUN_COMP_TOP_FILES} -l ./logs/xcompile_m2s2.log | tee ./logs/xcompile_all_m2s2.log
xsim_m2s2:
	xrun -R +xm64bit -licqueue +UVM_TESTNAME=base_test ${XRUN_SIM_ARGS} -top ca_top_tb -input ../ca_shm.tcl -l .logs/xsim_m2s2.log

xcomp_m2s1 : check_log_dir
	xrun -elaborate +define+INCA +define+SL_AIB_GEN1 ${XRUN_UVM}  ${XRUN_COMP_ARGS} ${XRUN_COMP_FILES} -l ./logs/xcompile_m2s1.log
xsim_m2s1:
	xrun -R +xm64bit -licqueue +UVM_TESTNAME=m2s1_test ${XRUN_SIM_ARGS} -l .logs/xsim_m2s1.log | tee ./logs/xsim_all_m2s1.log

xcomp_m1s2 : check_log_dir gen_m1s2
	xrun -elaborate +define+INCA +define+MS_AIB_GEN1 ${XRUN_UVM}  ${XRUN_COMP_ARGS} ${XRUN_COMP_FILES} -l ./logs/xcompile_m1s2.log
xsim_m1s2:
	xrun -R +xm64bit -licqueue +UVM_TESTNAME=m1s2_test ${XRUN_SIM_ARGS} -top ca_top_tb -input ../ca_shm.tcl -l .logs/xsim_m1s2.log | tee ./logs/xsim_all_m1s2.log

xwave :
	simvision waves.shm &
xclean:
	rm -rf xcelium.d compile.* test.log dump.* .simvision
############################# TARGETS #################################
