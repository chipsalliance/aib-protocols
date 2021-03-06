// SPDX-License-Identifier: Apache-2.0
// Copyright (C) 2019 Intel Corporation. All rights reserved

`timescale 1ps/1ps
interface spi_if;

    logic                        sclk;
    logic [3:0]                  ss_n;
    logic                        mosi;
    wire  [3:0]                  miso;  //Sepearte miso pin, get rid of tristate.

endinterface : spi_if
