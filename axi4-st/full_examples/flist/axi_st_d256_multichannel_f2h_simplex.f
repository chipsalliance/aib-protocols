+access+rwc
${SIM_DIR}/../common/axi_st_d256_multichannel_f2h_simplex_top.sv
#${PROJ_DIR}/common/dv/p2p_lite.sv
${PROJ_DIR}/common/dv/marker_gen.sv
${PROJ_DIR}/common/dv/strobe_gen.sv
${SIM_DIR}/../common/axist_rand_gen.v
${SIM_DIR}/../common/axi_st_patgen_top.v
${SIM_DIR}/../common/axi_st_wr_ctrl.v
${SIM_DIR}/../common/axi_st_patchkr_top.v
${SIM_DIR}/../common/axist_incr_gen.v
${SIM_DIR}/../common/axi_st_csr.v
${SIM_DIR}/../common/csr_ctrl.v
${SIM_DIR}/../common/jtag2avmm_bridge.v
${PROJ_DIR}/common/rtl/asyncfifo.sv
${PROJ_DIR}/common/rtl/syncfifo_mem1r1w.sv
+libverbose
+libext+.v
+define+FOR_SIM_ONLY
-f ${tbench_dir}/axi_st_d256_multichannel/axi_st_d256_multichannel_full_master.f
-f ${tbench_dir}/axi_st_d256_multichannel/axi_st_d256_multichannel_half_slave.f
-f ${PROJ_DIR}/ca/rtl/ca.f
-y .
-l axi_st_d256_multichannel_f2h_simplex.log
