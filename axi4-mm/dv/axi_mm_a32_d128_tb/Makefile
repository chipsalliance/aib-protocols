ifndef PROJ_DIR
    PWD = $(shell pwd)
    export PROJ_DIR=${PWD}/../..
endif

TOP  = $(shell basename $(CURDIR))
SVTB = -f ${TOP}.f
SEED = 1
default: test_xcellium

vcs:	        compile_verdi run_verdi
test_verdi:	compile_verdi run_verdi

compile_verdi:
	echo Running VCS for TB $(TOP)
	vcs +lint=TFIPC-L -sverilog -l vcs.log -kdb -debug_access+all +v2k -full64 +vcs+vcdpluson -timescale=1ps/1ps +define+SHM_OVERRIDE_OFF +define+VCS+BEHAVIORAL+TIMESCALE_EN $(SVTB) -top ${TOP}

run_verdi:
	./simv -l sim.log -verdi +ntb_random_seed=$(SEED)

test_xcellium:
	echo Running Xcellium for TB $(TOP)
	xmverilog $(SVTB) +xmtop+${TOP}

clean:
	@rm -Rf xcelium.d/
	@rm -Rf axi_mm_a32_d128_tb.history axi_mm_a32_d128_tb.log
	@rm -Rf vcs.log
