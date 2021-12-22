////////////////////////////////////////////////////////////////////////////////////////////////////
//
//        Copyright (C) 2021 Eximius Design
//
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//     http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//
// Functional Descript: Channel Alignment Testbench File
//
//
//
////////////////////////////////////////////////////////////////////////////////////////////////////

`ifndef _CHAN_DELAY_PKG_
`define _CHAN_DELAY_PKG_
////////////////////////////////////////////////////////////////////
package chan_delay_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"
    
    `include "./chan_delay_seq_item.sv"
    `include "./chan_delay_cfg.sv"
    `include "./chan_delay_drv.sv"
    `include "./chan_delay_mon.sv"
    `include "./chan_delay_seqr.sv"
    //`include "./chan_delay_fcov_mon.sv"
    `include "./chan_delay_agent.sv"

////////////////////////////////////////////////////////////////////
endpackage : chan_delay_pkg
`endif
