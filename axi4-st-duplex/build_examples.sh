#!/bin/sh -f

if [ -z "${PROJ_DIR}" ]; then
    export PROJ_DIR=`pwd`/..
fi


## Build DUT
python ${PROJ_DIR}/llink/script/dual_axist_llink_gen.py --cfg ${PROJ_DIR}/axi4-st-duplex/cfg/axi_dual_st_d256_multichannel.cfg
python ${PROJ_DIR}/llink/script/dual_axist_llink_gen.py --cfg ${PROJ_DIR}/axi4-st-duplex/cfg/axi_dual_st_d64.cfg

