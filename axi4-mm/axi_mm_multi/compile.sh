#!/usr/bin/bash

xmverilog \
  -f ${PROJ_DIR}/axi4-mm/axi_mm_multi/axi_mm_master.f \
  -f ${PROJ_DIR}/axi4-mm/axi_mm_multi/axi_mm_slave.f

