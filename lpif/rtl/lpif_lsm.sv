////////////////////////////////////////////////////////////
// Proprietary Information of Eximius Design
//
//        (C) Copyright 2021 Eximius Design
//                All Rights Reserved
//
// This entire notice must be reproduced on all copies of this file
// and copies of this file may only be made by a person if such person is
// permitted to do so under the terms of a subsisting license agreement
// from Eximius Design
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
//Functional Descript: LPIF Adapter IP Link State Machine
//
//
//
////////////////////////////////////////////////////////////

module lpif_lsm
  (
   input logic        lclk,
   input logic        rst_n,

   input logic [3:0]  lp_state_req,
   output logic [3:0] pl_state_sts,

   input logic [3:0]  ustrm_state,

   input logic        ctl_link_up,

   output logic       pl_phyinl1,
   output logic       pl_phyinl2,
   output logic       pl_phyinrecenter,
   output logic       pl_stallreq,

   output logic [3:0] lsm_dstrm_state,
   output logic [2:0] lsm_lnk_cfg,
   output logic [2:0] lsm_speedmode
   );

  logic               d_pl_phyinl1;
  logic               d_pl_phyinl2;
  logic               d_pl_phyinrecenter;
  logic               d_pl_stallreq;
  logic [3:0]         d_pl_state_sts;

  logic [3:0]         d_lsm_dstrm_state;
  logic [2:0]         d_lsm_lnk_cfg;
  logic [2:0]         d_lsm_speedmode;

  localparam [3:0] /* auto enum sb_info */
    SB_NULL		= 4'h0,
    SB_L1_REQ		= 4'h1,
    SB_L1_STS		= 4'h2,
    SB_ACTIVE_REQ	= 4'h3,
    SB_ACTIVE_STS	= 4'h4,
    SB_LINK_ERROR	= 4'h5,
    SB_L2_REQ		= 4'h6,
    SB_L2_STS		= 4'h7,
    SB_LINK_RESET_REQ	= 4'h8,
    SB_LINK_RESET_STS	= 4'h9,
    SB_LINK_RETRAIN_REQ	= 4'hA,
    SB_LINK_RETRAIN_STS	= 4'hB;

  logic [3:0]         /* auto enum sb_info */
                      sb;

  assign sb = ustrm_state;

  /*AUTOASCIIENUM("sb", "sb_ascii", "")*/
  // Beginning of automatic ASCII enum decoding
  reg [151:0]           sb_ascii;               // Decode of sb
  always @(sb) begin
    case ({sb})
      SB_NULL:             sb_ascii = "sb_null            ";
      SB_L1_REQ:           sb_ascii = "sb_l1_req          ";
      SB_L1_STS:           sb_ascii = "sb_l1_sts          ";
      SB_ACTIVE_REQ:       sb_ascii = "sb_active_req      ";
      SB_ACTIVE_STS:       sb_ascii = "sb_active_sts      ";
      SB_LINK_ERROR:       sb_ascii = "sb_link_error      ";
      SB_L2_REQ:           sb_ascii = "sb_l2_req          ";
      SB_L2_STS:           sb_ascii = "sb_l2_sts          ";
      SB_LINK_RESET_REQ:   sb_ascii = "sb_link_reset_req  ";
      SB_LINK_RESET_STS:   sb_ascii = "sb_link_reset_sts  ";
      SB_LINK_RETRAIN_REQ: sb_ascii = "sb_link_retrain_req";
      SB_LINK_RETRAIN_STS: sb_ascii = "sb_link_retrain_sts";
      default:             sb_ascii = "%Error             ";
    endcase
  end
  // End of automatics

  localparam [3:0] /* auto enum req_info */
    REQ_NOP		= 4'h0,
    REQ_ACTIVE		= 4'h1,
    REQ_ACTIVE_L0S	= 4'h2,
    REQ_DAPM		= 4'h3,
    REQ_IDLE_L1_1	= 4'h4,
    REQ_IDLE_L1_2	= 4'h5,
    REQ_IDLE_L1_3	= 4'h6,
    REQ_IDLE_L1_4	= 4'h7,
    REQ_SLEEP_L2	= 4'h8,
    REQ_LinkReset	= 4'h9,
    REQ_Reserved	= 4'hA,
    REQ_RETRAIN		= 4'hB,
    REQ_DISABLE		= 4'hC;

  logic [3:0]         /* auto enum req_info */
                      state_req;

  assign state_req = lp_state_req;

  /*AUTOASCIIENUM("state_req", "state_req_ascii", "")*/
  // Beginning of automatic ASCII enum decoding
  reg [111:0]           state_req_ascii;        // Decode of state_req
  always @(state_req) begin
    case ({state_req})
      REQ_NOP:        state_req_ascii = "req_nop       ";
      REQ_ACTIVE:     state_req_ascii = "req_active    ";
      REQ_ACTIVE_L0S: state_req_ascii = "req_active_l0s";
      REQ_DAPM:       state_req_ascii = "req_dapm      ";
      REQ_IDLE_L1_1:  state_req_ascii = "req_idle_l1_1 ";
      REQ_IDLE_L1_2:  state_req_ascii = "req_idle_l1_2 ";
      REQ_IDLE_L1_3:  state_req_ascii = "req_idle_l1_3 ";
      REQ_IDLE_L1_4:  state_req_ascii = "req_idle_l1_4 ";
      REQ_SLEEP_L2:   state_req_ascii = "req_sleep_l2  ";
      REQ_LinkReset:  state_req_ascii = "req_linkreset ";
      REQ_Reserved:   state_req_ascii = "req_reserved  ";
      REQ_RETRAIN:    state_req_ascii = "req_retrain   ";
      REQ_DISABLE:    state_req_ascii = "req_disable   ";
      default:        state_req_ascii = "%Error        ";
    endcase
  end
  // End of automatics

  localparam [3:0] /* auto enum sts_info */
    STS_RESET		= 4'h0,
    STS_ACTIVE		= 4'h1,
    STS_ACTIVE_L0S	= 4'h2,
    STS_Reserved	= 4'h3,
    STS_IDLE_L1_1	= 4'h4,
    STS_IDLE_L1_2	= 4'h5,
    STS_IDLE_L1_3	= 4'h6,
    STS_IDLE_L1_4	= 4'h7,
    STS_SLEEP_L2	= 4'h8,
    STS_LinkReset	= 4'h9,
    STS_LinkError	= 4'hA,
    STS_RETRAIN		= 4'hB,
    STS_DISABLE		= 4'hC;

  logic [3:0]         /* auto enum sts_info */
                      state_sts;
  assign state_sts = pl_state_sts;

  /*AUTOASCIIENUM("state_sts", "state_sts_ascii", "")*/
  // Beginning of automatic ASCII enum decoding
  reg [111:0]           state_sts_ascii;        // Decode of state_sts
  always @(state_sts) begin
    case ({state_sts})
      STS_RESET:      state_sts_ascii = "sts_reset     ";
      STS_ACTIVE:     state_sts_ascii = "sts_active    ";
      STS_ACTIVE_L0S: state_sts_ascii = "sts_active_l0s";
      STS_Reserved:   state_sts_ascii = "sts_reserved  ";
      STS_IDLE_L1_1:  state_sts_ascii = "sts_idle_l1_1 ";
      STS_IDLE_L1_2:  state_sts_ascii = "sts_idle_l1_2 ";
      STS_IDLE_L1_3:  state_sts_ascii = "sts_idle_l1_3 ";
      STS_IDLE_L1_4:  state_sts_ascii = "sts_idle_l1_4 ";
      STS_SLEEP_L2:   state_sts_ascii = "sts_sleep_l2  ";
      STS_LinkReset:  state_sts_ascii = "sts_linkreset ";
      STS_LinkError:  state_sts_ascii = "sts_linkerror ";
      STS_RETRAIN:    state_sts_ascii = "sts_retrain   ";
      STS_DISABLE:    state_sts_ascii = "sts_disable   ";
      default:        state_sts_ascii = "%Error        ";
    endcase
  end
  // End of automatics

  // lp_state_req

  wire                state_req_nop		= (lp_state_req == REQ_NOP);
  wire                state_req_active		= (lp_state_req == REQ_ACTIVE);
  wire                state_req_linkreset	= (lp_state_req == REQ_LinkReset);
  wire                state_req_disable		= (lp_state_req == REQ_DISABLE);
  wire                state_req_retrain		= (lp_state_req == REQ_RETRAIN);
  wire                state_req_idle_l1_1	= (lp_state_req == REQ_IDLE_L1_1);
  wire                state_req_sleep_l2	= (lp_state_req == REQ_SLEEP_L2);

  // sideband decodes

  wire                sb_null			= (sb == SB_NULL);
  wire                sb_l1_req			= (sb == SB_L1_REQ);
  wire                sb_l1_sts			= (sb == SB_L1_STS);
  wire                sb_active_req		= (sb == SB_ACTIVE_REQ);
  wire                sb_active_sts		= (sb == SB_ACTIVE_STS);
  wire                sb_link_error		= (sb == SB_LINK_ERROR);
  wire                sb_l2_req			= (sb == SB_L2_REQ);
  wire                sb_l2_sts			= (sb == SB_L2_STS);
  wire                sb_link_reset_req		= (sb == SB_LINK_RESET_REQ);
  wire                sb_link_reset_sts		= (sb == SB_LINK_RESET_STS);
  wire                sb_link_retrain_req	= (sb == SB_LINK_RETRAIN_REQ);
  wire                sb_link_retrain_sts	= (sb == SB_LINK_RETRAIN_STS);

  localparam [2:0]
    LNK_CFG_X1	= 3'b000,
    LNK_CFG_X16	= 3'b101;

  localparam [2:0]
    SPEEDMODE_GEN1	= 3'b000,
    SPEEDMODE_GEN5	= 3'b100;

  // Link State Machine

  localparam [3:0] /* auto enum lsm_state_info */
    LSM_RESET		= 4'h0,
    LSM_ACTIVE_a	= 4'h1,
    LSM_ACTIVE		= 4'h2,
    LSM_ACTIVE_L0S	= 4'h3,
    LSM_DAPM		= 4'h4,
    LSM_IDLE_L1_1	= 4'h5,
    LSM_IDLE_L1_2	= 4'h6,
    LSM_IDLE_L1_3	= 4'h7,
    LSM_IDLE_L1_4	= 4'h8,
    LSM_SLEEP_L2	= 4'h9,
    LSM_LinkReset_a	= 4'hA,
    LSM_LinkReset	= 4'hB,
    LSM_LinkError	= 4'hC,
    LSM_RETRAIN_a	= 4'hD,
    LSM_RETRAIN		= 4'hE,
    LSM_DISABLE		= 4'hF;

  logic [3:0]         /* auto enum lsm_state_info */
                      lsm_state, d_lsm_state;

  /*AUTOASCIIENUM("lsm_state", "lsm_state_ascii", "")*/
  // Beginning of automatic ASCII enum decoding
  reg [119:0]           lsm_state_ascii;        // Decode of lsm_state
  always @(lsm_state) begin
    case ({lsm_state})
      LSM_RESET:       lsm_state_ascii = "lsm_reset      ";
      LSM_ACTIVE_a:    lsm_state_ascii = "lsm_active_a   ";
      LSM_ACTIVE:      lsm_state_ascii = "lsm_active     ";
      LSM_ACTIVE_L0S:  lsm_state_ascii = "lsm_active_l0s ";
      LSM_DAPM:        lsm_state_ascii = "lsm_dapm       ";
      LSM_IDLE_L1_1:   lsm_state_ascii = "lsm_idle_l1_1  ";
      LSM_IDLE_L1_2:   lsm_state_ascii = "lsm_idle_l1_2  ";
      LSM_IDLE_L1_3:   lsm_state_ascii = "lsm_idle_l1_3  ";
      LSM_IDLE_L1_4:   lsm_state_ascii = "lsm_idle_l1_4  ";
      LSM_SLEEP_L2:    lsm_state_ascii = "lsm_sleep_l2   ";
      LSM_LinkReset_a: lsm_state_ascii = "lsm_linkreset_a";
      LSM_LinkReset:   lsm_state_ascii = "lsm_linkreset  ";
      LSM_LinkError:   lsm_state_ascii = "lsm_linkerror  ";
      LSM_RETRAIN_a:   lsm_state_ascii = "lsm_retrain_a  ";
      LSM_RETRAIN:     lsm_state_ascii = "lsm_retrain    ";
      LSM_DISABLE:     lsm_state_ascii = "lsm_disable    ";
      default:         lsm_state_ascii = "%Error         ";
    endcase
  end
  // End of automatics

  always_ff @(posedge lclk or negedge rst_n)
    if (~rst_n)
      lsm_state <= LSM_RESET;
    else
      lsm_state <= d_lsm_state;

  // TODO: PM Entry and Exit

  always_comb
    begin : lsm_state_next
      d_lsm_state = lsm_state;
      d_pl_phyinl1 = pl_phyinl1;
      d_pl_phyinl2 = pl_phyinl2;
      d_pl_phyinrecenter = pl_phyinrecenter;
      d_pl_stallreq = pl_stallreq;
      d_lsm_dstrm_state = lsm_dstrm_state;
      d_lsm_lnk_cfg = lsm_lnk_cfg;
      d_lsm_speedmode = lsm_speedmode;
      case (lsm_state)
        LSM_RESET: begin
          if (state_req_active | ctl_link_up)
            d_lsm_state = LSM_ACTIVE;
          else if (state_req_linkreset)
            d_lsm_state = LSM_LinkReset;
          else if (state_req_disable)
            d_lsm_state = LSM_DISABLE;
          else if (sb_link_error)
            d_lsm_state = LSM_LinkError;
        end
        LSM_ACTIVE_a: begin
          if (sb_active_sts)
            d_lsm_state = LSM_ACTIVE;
        end
        LSM_ACTIVE: begin
          d_lsm_dstrm_state = SB_ACTIVE_STS;
          if (state_req_retrain)
            begin
              d_lsm_dstrm_state = SB_LINK_RETRAIN_REQ;
              d_lsm_state = LSM_RETRAIN_a;
            end
          else if (state_req_idle_l1_1 | sb_l1_req)
            d_lsm_state = LSM_IDLE_L1_1;
          else if (state_req_sleep_l2 | sb_l2_req)
            d_lsm_state = LSM_SLEEP_L2;
          else if (state_req_linkreset)
            begin
              d_lsm_dstrm_state = SB_LINK_RESET_REQ;
              d_lsm_state = LSM_LinkReset_a;
            end
          else if (sb_link_reset_req)
            d_lsm_state = LSM_LinkReset;
          else if (sb_link_retrain_req)
            d_lsm_state = LSM_RETRAIN;
          else if (state_req_disable)
            d_lsm_state = LSM_DISABLE;
          else if (sb_link_error)
            d_lsm_state = LSM_LinkError;
        end
        LSM_IDLE_L1_1: begin
          d_lsm_dstrm_state = SB_L1_STS;
          d_pl_phyinl1 = 1'b1;
          if (state_req_linkreset)
            d_lsm_state = LSM_LinkReset;
          else if (state_req_disable)
            d_lsm_state = LSM_DISABLE;
          else if (sb_link_error)
            d_lsm_state = LSM_LinkError;
        end
        LSM_IDLE_L1_2: begin
          d_lsm_dstrm_state = SB_L1_STS;
          d_pl_phyinl1 = 1'b1;
          if (state_req_linkreset)
            d_lsm_state = LSM_LinkReset;
          else if (state_req_disable)
            d_lsm_state = LSM_DISABLE;
          else if (sb_link_error)
            d_lsm_state = LSM_LinkError;
        end
        LSM_IDLE_L1_3: begin
          d_lsm_dstrm_state = SB_L1_STS;
          d_pl_phyinl1 = 1'b1;
          if (state_req_linkreset)
            d_lsm_state = LSM_LinkReset;
          else if (state_req_disable)
            d_lsm_state = LSM_DISABLE;
          else if (sb_link_error)
            d_lsm_state = LSM_LinkError;
        end
        LSM_IDLE_L1_4: begin
          d_lsm_dstrm_state = SB_L1_STS;
          d_pl_phyinl1 = 1'b1;
          if (state_req_linkreset)
            d_lsm_state = LSM_LinkReset;
          else if (state_req_disable)
            d_lsm_state = LSM_DISABLE;
          else if (sb_link_error)
            d_lsm_state = LSM_LinkError;
        end
        LSM_SLEEP_L2: begin
          d_lsm_dstrm_state = SB_L2_STS;
          d_pl_phyinl2 = 1'b1;
          if (state_req_linkreset)
            d_lsm_state = LSM_LinkReset;
          else if (state_req_disable)
            d_lsm_state = LSM_DISABLE;
          else if (sb_link_error)
            d_lsm_state = LSM_LinkError;
        end
        LSM_LinkReset_a: begin
          if (sb_link_reset_sts)
            d_lsm_state = LSM_LinkReset;
        end
        LSM_LinkReset: begin
          // entered when software writes a register or when remote phy requests
          d_lsm_dstrm_state = SB_LINK_RESET_STS;
          if (state_req_active | state_req_disable) // TODO: also exit due to an internal request to move to RESET
            d_lsm_state = LSM_RESET;
          else if (state_req_disable) // TODO: also exit due to an internal request to move to DISABLE
            d_lsm_state = LSM_DISABLE;
          else if (sb_link_error)
            d_lsm_state = LSM_LinkError;
        end
        LSM_LinkError: begin
          d_lsm_dstrm_state = SB_LINK_ERROR;
        end
        LSM_RETRAIN_a: begin
          if (sb_link_retrain_sts)
            d_lsm_state = LSM_RETRAIN;
        end
        LSM_RETRAIN: begin
          d_lsm_lnk_cfg = LNK_CFG_X16;
          d_lsm_speedmode = SPEEDMODE_GEN5;
          d_pl_phyinrecenter = 1'b1;
          d_lsm_dstrm_state = SB_LINK_RETRAIN_STS;
          if (state_req_active)
            begin
              d_lsm_dstrm_state = SB_ACTIVE_REQ;
              d_lsm_state = LSM_ACTIVE_a;
            end
          else if (sb_active_req)
            begin
              d_lsm_dstrm_state = SB_ACTIVE_REQ;
              d_lsm_state = LSM_ACTIVE;
            end
          else if (state_req_linkreset)
            d_lsm_state = LSM_LinkReset;
          else if (state_req_disable)
            d_lsm_state = LSM_DISABLE;
          else if (sb_link_error)
            d_lsm_state = LSM_LinkError;
        end
        LSM_DISABLE: begin
          if (state_req_linkreset)
            d_lsm_state = LSM_LinkReset;
          else if (sb_link_error)
            d_lsm_state = LSM_LinkError;
        end
        default: d_lsm_state = LSM_RESET;
      endcase // case (lsm_state)
    end // block: lsm_state_next

  // pl_state_sts

  always_comb
    begin : pl_state_sts_info
      case (lsm_state)
        LSM_RESET:      d_pl_state_sts = STS_RESET;
        LSM_ACTIVE:     d_pl_state_sts = STS_ACTIVE;
        LSM_ACTIVE_L0S: d_pl_state_sts = STS_ACTIVE_L0S;
        LSM_DAPM:       d_pl_state_sts = STS_Reserved;
        LSM_IDLE_L1_1:  d_pl_state_sts = STS_IDLE_L1_1;
        LSM_IDLE_L1_2:  d_pl_state_sts = STS_IDLE_L1_2;
        LSM_IDLE_L1_3:  d_pl_state_sts = STS_IDLE_L1_3;
        LSM_IDLE_L1_4:  d_pl_state_sts = STS_IDLE_L1_4;
        LSM_SLEEP_L2:   d_pl_state_sts = STS_SLEEP_L2;
        LSM_LinkReset:  d_pl_state_sts = STS_LinkReset;
        LSM_LinkError:  d_pl_state_sts = STS_LinkError;
        LSM_RETRAIN:    d_pl_state_sts = STS_RETRAIN;
        LSM_DISABLE:    d_pl_state_sts = STS_DISABLE;
        default:        d_pl_state_sts = STS_RESET ;
      endcase // case (lsm_state)
    end

  always_ff @(posedge lclk or negedge rst_n)
    if (~rst_n)
      begin
        pl_phyinl1 <= 1'b0;
        pl_phyinl2 <= 1'b0;
        pl_phyinrecenter <= 1'b0;
        pl_stallreq <= 1'b0;
        pl_state_sts <= 4'b0;
        lsm_dstrm_state <= 4'b0;
        lsm_lnk_cfg <= 3'b0;
        lsm_speedmode <= 3'b0;
      end
    else
      begin
        pl_phyinl1 <= d_pl_phyinl1;
        pl_phyinl2 <= d_pl_phyinl2;
        pl_phyinrecenter <= d_pl_phyinrecenter;
        pl_stallreq <= d_pl_stallreq;
        pl_state_sts <= d_pl_state_sts;
        lsm_dstrm_state <= d_lsm_dstrm_state;
        lsm_lnk_cfg <= d_lsm_lnk_cfg;
        lsm_speedmode <= d_lsm_speedmode;
      end

endmodule // lpif_lsm

// Local Variables:
// verilog-library-directories:("." "${PROJ_DIR}/common/rtl")
// verilog-auto-inst-param-value:t
// End:
