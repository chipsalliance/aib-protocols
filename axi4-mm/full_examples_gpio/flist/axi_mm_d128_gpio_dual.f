${SIM_DIR}/../common/aximm_gpiophy_dual_top.v
${SIM_DIR}/../common/aximm_d128_gpiophy_dual_wrapper_top.v
${SIM_DIR}/../common/aximm_rand_gen.v
${SIM_DIR}/../common/axi_mm_patgen_top.v
${SIM_DIR}/../common/axi_mm_patchkr_top.v
${SIM_DIR}/../common/aximm_wr_ctrl.v
${SIM_DIR}/../common/aximm_incr_gen.v
${SIM_DIR}/../common/mm_csr_ctrl.v
${SIM_DIR}/../common/axi_mm_csr.v
${SIM_DIR}/../common/jtag2avmm_bridge.v
${SIM_DIR}/../common/aximm_follower_app.v
${SIM_DIR}/../common/aximm_leader_app.v
${PROJ_DIR}/common/rtl/syncfifo_mem1r1w.sv
+libverbose
+libext+.v
-f ${tbench_dir}/aximm_ll_dut_new/axi_mm_slave.f
-f ${tbench_dir}/aximm_ll_dut_new/axi_mm_master.f
-f ${PROJ_DIR}/ca/rtl/ca.f
