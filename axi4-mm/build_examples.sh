
## Build DUT
python ${PROJ_DIR}/llink/script/llink_gen.py --cfg ${PROJ_DIR}/axi4-mm/cfg/axi_lite_a32_d32.cfg
python ${PROJ_DIR}/llink/script/llink_gen.py --cfg ${PROJ_DIR}/axi4-mm/cfg/axi_mm_a32_d128.cfg
python ${PROJ_DIR}/llink/script/llink_gen.py --cfg ${PROJ_DIR}/axi4-mm/cfg/axi_mm_a32_d128_packet.cfg
python ${PROJ_DIR}/llink/script/llink_gen.py --cfg ${PROJ_DIR}/axi4-mm/cfg/axi_mm_a32_d128_packet_gen1.cfg

python ${PROJ_DIR}/llink/script/llink_gen.py --cfg ${PROJ_DIR}/axi4-mm/cfg/aximm_ll_multi_tier1.cfg --odir ${PROJ_DIR}/axi4-mm/axi_mm_multi/aximm_ll_multi_tier1
python ${PROJ_DIR}/llink/script/llink_gen.py --cfg ${PROJ_DIR}/axi4-mm/cfg/aximm_ll_multi_tier2.cfg --odir ${PROJ_DIR}/axi4-mm/axi_mm_multi/aximm_ll_multi_tier2
cd ${PROJ_DIR}/axi4-mm/axi_mm_multi; ./build.sh; cd ~-
