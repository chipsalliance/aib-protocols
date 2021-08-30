
## Build DUT
python ${PROJ_DIR}/llink/script/llink_gen.py --cfg ${PROJ_DIR}/axi4-st/cfg/axi_st_d64.cfg
python ${PROJ_DIR}/llink/script/llink_gen.py --cfg ${PROJ_DIR}/axi4-st/cfg/axi_st_d256_gen1_gen2.cfg
python ${PROJ_DIR}/llink/script/llink_gen.py --cfg ${PROJ_DIR}/axi4-st/cfg/axi_st_d128_asym.cfg
python ${PROJ_DIR}/llink/script/llink_gen.py --cfg ${PROJ_DIR}/axi4-st/cfg/axi_st_d256_multichannel.cfg
python ${PROJ_DIR}/llink/script/llink_gen.py --cfg ${PROJ_DIR}/axi4-st/cfg/axi_st_d256_norm.cfg
python ${PROJ_DIR}/llink/script/llink_gen.py --cfg ${PROJ_DIR}/axi4-st/cfg/axi_st_d256_gen1_gen2.cfg
