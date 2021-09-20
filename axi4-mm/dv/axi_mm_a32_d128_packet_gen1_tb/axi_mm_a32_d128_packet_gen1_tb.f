+access+rwc
axi_mm_a32_d128_packet_gen1_tb.sv
${PROJ_DIR}/common/dv/p2p_lite.sv
+libverbose
+libext+.v
+define+FOR_SIM_ONLY
-f ${PROJ_DIR}/axi4-mm/axi_mm_a32_d128_packet_gen1/axi_mm_a32_d128_packet_gen1_master.f
-f ${PROJ_DIR}/axi4-mm/axi_mm_a32_d128_packet_gen1/axi_mm_a32_d128_packet_gen1_slave.f
-f ${PROJ_DIR}/ca/rtl/ca.f
-y .
-l axi_mm_a32_d128_packet_gen1_tb.log
