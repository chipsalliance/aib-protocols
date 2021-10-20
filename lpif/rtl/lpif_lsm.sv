////////////////////////////////////////////////////////////
//
//        Copyright (C) 2021 Eximius Design
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
// Functional Descript: LPIF Adapter IP Link State Machine
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
   input logic        ctl_phy_err,
   output logic       lsm_state_active,

   output logic       pl_exit_cg_req,
   input logic        lp_exit_cg_ack,

   output logic       pl_stallreq,
   input logic        lp_stallack,

   input logic        lp_wake_req,
   output logic       pl_wake_ack,

   output logic       pl_phyinl1,
   output logic       pl_phyinl2,
   output logic       pl_phyinrecenter,

   output logic       pl_lnk_up,

   output logic [3:0] lsm_dstrm_state,
   output logic [2:0] lsm_lnk_cfg,
   output logic [2:0] lsm_speedmode
   );

  logic               d_pl_phyinl1;
  logic               d_pl_phyinl2;
  logic               d_pl_phyinrecenter;

  logic               d_pl_lnk_up;

  logic [3:0]         d_pl_state_sts;

  logic [3:0]         d_lsm_dstrm_state;
  logic [3:0]         lsm_return_state, d_lsm_return_state;
  logic [2:0]         d_lsm_lnk_cfg;
  logic [2:0]         d_lsm_speedmode;

  logic               lsm_cg_req;
  logic               lsm_stall_req;

  logic               coldstart, d_coldstart;
  logic               lsm_exit_lp, d_lsm_exit_lp;

  // sideband state encodings

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
                      sb_ustrm, sb_dstrm;

  assign sb_ustrm = ustrm_state;
  assign sb_dstrm = lsm_dstrm_state;

  /*AUTOASCIIENUM("sb_ustrm", "sb_ustrm_ascii", "")*/
  // Beginning of automatic ASCII enum decoding
  reg [151:0]           sb_ustrm_ascii;         // Decode of sb_ustrm
  always @(sb_ustrm) begin
    case ({sb_ustrm})
      SB_NULL:             sb_ustrm_ascii = "sb_null            ";
      SB_L1_REQ:           sb_ustrm_ascii = "sb_l1_req          ";
      SB_L1_STS:           sb_ustrm_ascii = "sb_l1_sts          ";
      SB_ACTIVE_REQ:       sb_ustrm_ascii = "sb_active_req      ";
      SB_ACTIVE_STS:       sb_ustrm_ascii = "sb_active_sts      ";
      SB_LINK_ERROR:       sb_ustrm_ascii = "sb_link_error      ";
      SB_L2_REQ:           sb_ustrm_ascii = "sb_l2_req          ";
      SB_L2_STS:           sb_ustrm_ascii = "sb_l2_sts          ";
      SB_LINK_RESET_REQ:   sb_ustrm_ascii = "sb_link_reset_req  ";
      SB_LINK_RESET_STS:   sb_ustrm_ascii = "sb_link_reset_sts  ";
      SB_LINK_RETRAIN_REQ: sb_ustrm_ascii = "sb_link_retrain_req";
      SB_LINK_RETRAIN_STS: sb_ustrm_ascii = "sb_link_retrain_sts";
      default:             sb_ustrm_ascii = "%Error             ";
    endcase
  end
  // End of automatics

  /*AUTOASCIIENUM("sb_dstrm", "sb_dstrm_ascii", "")*/
  // Beginning of automatic ASCII enum decoding
  reg [151:0]           sb_dstrm_ascii;         // Decode of sb_dstrm
  always @(sb_dstrm) begin
    case ({sb_dstrm})
      SB_NULL:             sb_dstrm_ascii = "sb_null            ";
      SB_L1_REQ:           sb_dstrm_ascii = "sb_l1_req          ";
      SB_L1_STS:           sb_dstrm_ascii = "sb_l1_sts          ";
      SB_ACTIVE_REQ:       sb_dstrm_ascii = "sb_active_req      ";
      SB_ACTIVE_STS:       sb_dstrm_ascii = "sb_active_sts      ";
      SB_LINK_ERROR:       sb_dstrm_ascii = "sb_link_error      ";
      SB_L2_REQ:           sb_dstrm_ascii = "sb_l2_req          ";
      SB_L2_STS:           sb_dstrm_ascii = "sb_l2_sts          ";
      SB_LINK_RESET_REQ:   sb_dstrm_ascii = "sb_link_reset_req  ";
      SB_LINK_RESET_STS:   sb_dstrm_ascii = "sb_link_reset_sts  ";
      SB_LINK_RETRAIN_REQ: sb_dstrm_ascii = "sb_link_retrain_req";
      SB_LINK_RETRAIN_STS: sb_dstrm_ascii = "sb_link_retrain_sts";
      default:             sb_dstrm_ascii = "%Error             ";
    endcase
  end
  // End of automatics

  // lp_state_req encodings

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
  logic [3:0]         state_req_del;
  logic               state_req_change, d_state_req_change;

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

  // pl_state_sts encodings

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

  // lp_state_req decodes

  wire                state_req_nop		= (lp_state_req == REQ_NOP);
  wire                state_req_active		= (lp_state_req == REQ_ACTIVE);
  wire                state_req_linkreset	= (lp_state_req == REQ_LinkReset);
  wire                state_req_disable		= (lp_state_req == REQ_DISABLE);
  wire                state_req_retrain		= (lp_state_req == REQ_RETRAIN);
  wire                state_req_idle_l1_1	= (lp_state_req == REQ_IDLE_L1_1);
  wire                state_req_sleep_l2	= (lp_state_req == REQ_SLEEP_L2);

  // sideband state decodes

  wire                sb_ustrm_null			= (sb_ustrm == SB_NULL);
  wire                sb_ustrm_l1_req			= (sb_ustrm == SB_L1_REQ);
  wire                sb_ustrm_l1_sts			= (sb_ustrm == SB_L1_STS);
  wire                sb_ustrm_active_req		= (sb_ustrm == SB_ACTIVE_REQ);
  wire                sb_ustrm_active_sts		= (sb_ustrm == SB_ACTIVE_STS);
  wire                sb_ustrm_link_error		= (sb_ustrm == SB_LINK_ERROR);
  wire                sb_ustrm_l2_req			= (sb_ustrm == SB_L2_REQ);
  wire                sb_ustrm_l2_sts			= (sb_ustrm == SB_L2_STS);
  wire                sb_ustrm_link_reset_req		= (sb_ustrm == SB_LINK_RESET_REQ);
  wire                sb_ustrm_link_reset_sts		= (sb_ustrm == SB_LINK_RESET_STS);
  wire                sb_ustrm_link_retrain_req		= (sb_ustrm == SB_LINK_RETRAIN_REQ);
  wire                sb_ustrm_link_retrain_sts		= (sb_ustrm == SB_LINK_RETRAIN_STS);

  wire                sb_dstrm_null			= (sb_dstrm == SB_NULL);
  wire                sb_dstrm_l1_req			= (sb_dstrm == SB_L1_REQ);
  wire                sb_dstrm_l1_sts			= (sb_dstrm == SB_L1_STS);
  wire                sb_dstrm_active_req		= (sb_dstrm == SB_ACTIVE_REQ);
  wire                sb_dstrm_active_sts		= (sb_dstrm == SB_ACTIVE_STS);
  wire                sb_dstrm_link_error		= (sb_dstrm == SB_LINK_ERROR);
  wire                sb_dstrm_l2_req			= (sb_dstrm == SB_L2_REQ);
  wire                sb_dstrm_l2_sts			= (sb_dstrm == SB_L2_STS);
  wire                sb_dstrm_link_reset_req		= (sb_dstrm == SB_LINK_RESET_REQ);
  wire                sb_dstrm_link_reset_sts		= (sb_dstrm == SB_LINK_RESET_STS);
  wire                sb_dstrm_link_retrain_req		= (sb_dstrm == SB_LINK_RETRAIN_REQ);
  wire                sb_dstrm_link_retrain_sts		= (sb_dstrm == SB_LINK_RETRAIN_STS);

  wire                sb_req = (sb_ustrm_l1_req | sb_ustrm_active_req | sb_ustrm_l2_req |
                                sb_ustrm_link_reset_req | sb_ustrm_link_retrain_req);

  wire                sb_l1_ack = (sb_ustrm_l1_sts & sb_dstrm_l1_req);
  wire                sb_active_ack = (sb_ustrm_active_sts & sb_dstrm_active_req);
  wire                sb_l2_ack = (sb_ustrm_l2_sts & sb_dstrm_l2_sts);
  wire                sb_link_reset_ack = (sb_ustrm_link_reset_sts & sb_dstrm_link_reset_req);
  wire                sb_link_retrain_ack = (sb_ustrm_link_retrain_sts & sb_dstrm_link_retrain_req);
  wire                sb_ack = sb_l1_ack | sb_active_ack | sb_l2_ack | sb_link_reset_ack |
                      sb_link_retrain_ack;

  wire                exit_active = (coldstart |
                                     sb_ustrm_l1_req | sb_ustrm_l2_req | sb_ustrm_link_reset_req |
                                     sb_ustrm_link_retrain_req | sb_ustrm_link_error |
                                     (state_req_change &
                                      (state_req_retrain | state_req_idle_l1_1| state_req_sleep_l2 |
                                       state_req_linkreset | state_req_disable)
                                      )
                                     );
  // pl_lnk_cfg encodings

  localparam [2:0]
    LNK_CFG_X1	= 3'b000,
    LNK_CFG_X16	= 3'b101;

  // pl_speedmode encoding

  localparam [2:0]
    SPEEDMODE_GEN1	= 3'b000,
    SPEEDMODE_GEN5	= 3'b100;

  // Link State Machine

  localparam [4:0] /* auto enum lsm_state_info */
    LSM_RESET		= 5'h0,
    LSM_RESET_a		= 5'h1,
    LSM_ACTIVE_a	= 5'h2,
    LSM_ACTIVE		= 5'h3,
    LSM_ACTIVE_b	= 5'h4,
    LSM_ACTIVE_L0S	= 5'h5,
    LSM_DAPM		= 5'h6,
    LSM_IDLE_L1_1	= 5'h7,
    LSM_IDLE_L1_2	= 5'h8,
    LSM_IDLE_L1_3	= 5'h9,
    LSM_IDLE_L1_4	= 5'hA,
    LSM_SLEEP_L2	= 5'hB,
    LSM_LinkReset_a	= 5'hC,
    LSM_LinkReset	= 5'hD,
    LSM_LinkError	= 5'hE,
    LSM_RETRAIN_a	= 5'hF,
    LSM_RETRAIN_b	= 5'h10,
    LSM_RETRAIN_c	= 5'h11,
    LSM_RETRAIN		= 5'h12,
    LSM_DISABLE		= 5'h13,
    LSM_SB_ACK		= 5'h14;

  logic [4:0]         /* auto enum lsm_state_info */
                      lsm_state, d_lsm_state;

  /*AUTOASCIIENUM("lsm_state", "lsm_state_ascii", "")*/
  // Beginning of automatic ASCII enum decoding
  reg [119:0]           lsm_state_ascii;        // Decode of lsm_state
  always @(lsm_state) begin
    case ({lsm_state})
      LSM_RESET:       lsm_state_ascii = "lsm_reset      ";
      LSM_RESET_a:     lsm_state_ascii = "lsm_reset_a    ";
      LSM_ACTIVE_a:    lsm_state_ascii = "lsm_active_a   ";
      LSM_ACTIVE:      lsm_state_ascii = "lsm_active     ";
      LSM_ACTIVE_b:    lsm_state_ascii = "lsm_active_b   ";
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
      LSM_RETRAIN_b:   lsm_state_ascii = "lsm_retrain_b  ";
      LSM_RETRAIN_c:   lsm_state_ascii = "lsm_retrain_c  ";
      LSM_RETRAIN:     lsm_state_ascii = "lsm_retrain    ";
      LSM_DISABLE:     lsm_state_ascii = "lsm_disable    ";
      LSM_SB_ACK:      lsm_state_ascii = "lsm_sb_ack     ";
      default:         lsm_state_ascii = "%Error         ";
    endcase
  end
  // End of automatics

  // lsm state decodes

  assign lsm_state_active = (pl_state_sts == STS_ACTIVE);

  always_ff @(posedge lclk or negedge rst_n)
    if (~rst_n)
      lsm_state <= LSM_RESET;
    else
      lsm_state <= d_lsm_state;

  always_comb
    begin : lsm_state_next
      d_lsm_state = lsm_state;
      d_pl_phyinl1 = 1'b0;
      d_pl_phyinl2 = 1'b0;
      d_pl_phyinrecenter = 1'b0;
      d_lsm_dstrm_state = lsm_dstrm_state;
      d_lsm_lnk_cfg = lsm_lnk_cfg;
      d_lsm_speedmode = lsm_speedmode;
      lsm_cg_req = 1'b0;
      lsm_stall_req = 1'b0;
      d_pl_lnk_up = pl_lnk_up;
      d_coldstart = coldstart;
      d_lsm_exit_lp = lsm_exit_lp;
      d_pl_state_sts = pl_state_sts;
      d_lsm_return_state = lsm_return_state;
      d_state_req_change = state_req_change ? 1'b1 : (state_req != state_req_del);
      if (ctl_phy_err)
        begin
          d_pl_state_sts = STS_LinkError;
          d_lsm_state = LSM_LinkError;
        end
      else
        case (lsm_state)
          LSM_RESET: begin
            d_pl_state_sts = STS_RESET;
            if (ctl_link_up)
              d_lsm_state = LSM_RESET_a;
          end
          LSM_RESET_a: begin
            begin
              d_pl_lnk_up = 1'b1;
              if (state_req_active | sb_ustrm_active_req)
                begin
                  lsm_cg_req = 1'b1;
                  d_lsm_state = LSM_ACTIVE_a;
                end
              else if (state_req_linkreset & state_req_change)
                begin
                  d_state_req_change = 1'b0;
                  d_lsm_state = LSM_LinkReset;
                end
              else if (state_req_disable & state_req_change)
                begin
                  d_state_req_change = 1'b0;
                  d_lsm_state = LSM_DISABLE;
                end
              else if (sb_ustrm_link_error)
                d_lsm_state = LSM_LinkError;
            end // UNMATCHED !!
          end
          LSM_ACTIVE_a: begin
            if (pl_exit_cg_req & lp_exit_cg_ack)
              begin
                d_pl_state_sts = STS_ACTIVE;
                d_lsm_dstrm_state = SB_ACTIVE_STS;
                d_lsm_state = LSM_ACTIVE;
              end
          end
          LSM_ACTIVE: begin
            if (exit_active)
              begin
                d_state_req_change = 1'b0;
                lsm_stall_req = 1'b1;
                d_lsm_state = LSM_ACTIVE_b;
              end
          end
          LSM_ACTIVE_b: begin
            if (pl_stallreq & lp_stallack)
              begin
                if (state_req_retrain | coldstart)
                  begin
                    d_pl_state_sts = STS_RETRAIN;
                    d_lsm_dstrm_state = SB_LINK_RETRAIN_STS;
                    d_lsm_state = LSM_RETRAIN_a;
                  end
                else if (state_req_idle_l1_1)
                  begin
                    d_lsm_dstrm_state = SB_L1_REQ;
                    d_lsm_return_state = LSM_IDLE_L1_1;
                    d_lsm_state = LSM_SB_ACK;
                  end
                else if (sb_ustrm_l1_req)
                  begin
                    d_pl_state_sts = STS_IDLE_L1_1;
                    d_lsm_state = LSM_IDLE_L1_1;
                  end
                else if (state_req_sleep_l2 | sb_ustrm_l2_req)
                  begin
                    d_pl_state_sts = STS_SLEEP_L2;
                    d_lsm_state = LSM_SLEEP_L2;
                  end
                else if (state_req_linkreset)
                  begin
                    d_lsm_dstrm_state = SB_LINK_RESET_REQ;
                    d_lsm_return_state = LSM_LinkReset_a;
                    d_lsm_state = LSM_SB_ACK;
                  end
                else if (sb_ustrm_link_reset_req)
                  d_lsm_state = LSM_LinkReset;
                else if (sb_ustrm_link_retrain_req)
                  d_lsm_state = LSM_RETRAIN;
                else if (state_req_disable)
                  d_lsm_state = LSM_DISABLE;
                else if (sb_ustrm_link_error)
                  d_lsm_state = LSM_LinkError;
              end
          end // case: LSM_ACTIVE_b
          LSM_IDLE_L1_1: begin
            d_pl_state_sts = STS_IDLE_L1_1;
            d_lsm_dstrm_state = SB_L1_STS;
            d_pl_phyinl1 = 1'b1;
            if (sb_ustrm_active_req)
              d_lsm_state = LSM_RETRAIN_a;
            else if ((state_req_active | state_req_retrain) & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_exit_lp = 1'b1;
                d_lsm_dstrm_state = SB_ACTIVE_REQ;
                d_lsm_return_state = LSM_RETRAIN_a;
                d_lsm_state = LSM_SB_ACK;
              end
            else if (state_req_linkreset & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_dstrm_state = SB_LINK_RESET_REQ;
                d_lsm_return_state = LSM_LinkReset_a;
                d_lsm_state = LSM_SB_ACK;
              end
            else if (sb_ustrm_link_reset_req)
              begin
                d_lsm_state = LSM_LinkReset_a;
              end
            else if (state_req_disable & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_state = LSM_DISABLE;
              end
            else if (sb_ustrm_link_error)
              d_lsm_state = LSM_LinkError;
          end
          LSM_IDLE_L1_2: begin
            d_pl_state_sts = STS_IDLE_L1_2;
            d_lsm_dstrm_state = SB_L1_STS;
            d_pl_phyinl1 = 1'b1;
            if (sb_ustrm_active_req)
              d_lsm_state = LSM_RETRAIN_a;
            else if ((state_req_active | state_req_retrain) & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_exit_lp = 1'b1;
                d_lsm_dstrm_state = SB_ACTIVE_REQ;
                d_lsm_return_state = LSM_RETRAIN_a;
                d_lsm_state = LSM_SB_ACK;
              end
            else if (state_req_linkreset & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_dstrm_state = SB_LINK_RESET_REQ;
                d_lsm_state = LSM_LinkReset_a;
              end
            else if (state_req_disable & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_state = LSM_DISABLE;
              end
            else if (sb_ustrm_link_error)
              d_lsm_state = LSM_LinkError;
          end
          LSM_IDLE_L1_3: begin
            d_pl_state_sts = STS_IDLE_L1_3;
            d_lsm_dstrm_state = SB_L1_STS;
            d_pl_phyinl1 = 1'b1;
            if (sb_ustrm_active_req)
              d_lsm_state = LSM_RETRAIN_a;
            else if ((state_req_active | state_req_retrain) & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_exit_lp = 1'b1;
                d_lsm_dstrm_state = SB_ACTIVE_REQ;
                d_lsm_return_state = LSM_RETRAIN_a;
                d_lsm_state = LSM_SB_ACK;
              end
            else if (state_req_linkreset & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_dstrm_state = SB_LINK_RESET_REQ;
                d_lsm_state = LSM_LinkReset_a;
              end
            else if (state_req_disable & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_state = LSM_DISABLE;
              end
            else if (sb_ustrm_link_error)
              d_lsm_state = LSM_LinkError;
          end
          LSM_IDLE_L1_4: begin
            d_pl_state_sts = STS_IDLE_L1_4;
            d_lsm_dstrm_state = SB_L1_STS;
            d_pl_phyinl1 = 1'b1;
            if (sb_ustrm_active_req)
              d_lsm_state = LSM_RETRAIN_a;
            else if ((state_req_active | state_req_retrain) & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_exit_lp = 1'b1;
                d_lsm_dstrm_state = SB_ACTIVE_REQ;
                d_lsm_return_state = LSM_RETRAIN_a;
                d_lsm_state = LSM_SB_ACK;
              end
            else if (state_req_linkreset & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_dstrm_state = SB_LINK_RESET_REQ;
                d_lsm_state = LSM_LinkReset_a;
              end
            else if (state_req_disable & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_state = LSM_DISABLE;
              end
            else if (sb_ustrm_link_error)
              d_lsm_state = LSM_LinkError;
          end
          LSM_SLEEP_L2: begin
            d_pl_state_sts = STS_SLEEP_L2;
            d_lsm_dstrm_state = SB_L2_STS;
            d_pl_phyinl2 = 1'b1;
            if ((state_req_active | state_req_retrain) & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_exit_lp = 1'b1;
                d_pl_state_sts = STS_RETRAIN;
                d_lsm_state = LSM_RETRAIN_a;
              end
            else if (state_req_linkreset & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_dstrm_state = SB_LINK_RESET_REQ;
                d_lsm_state = LSM_LinkReset_a;
              end
            else if (state_req_disable & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_state = LSM_DISABLE;
              end
            else if (sb_ustrm_link_error)
              d_lsm_state = LSM_LinkError;
          end
          LSM_LinkReset_a: begin
            if (sb_ustrm_link_reset_req | sb_ustrm_link_reset_sts)
              begin
                d_pl_state_sts = STS_LinkReset;
                d_lsm_state = LSM_LinkReset;
              end
          end
          LSM_LinkReset: begin
            // entered when software writes a register or when remote phy requests
            d_lsm_dstrm_state = SB_LINK_RESET_STS;
            if (sb_ustrm_active_req)
              d_lsm_state = LSM_RESET;
            else if ((state_req_active | state_req_disable) & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_dstrm_state = SB_ACTIVE_REQ;
                d_lsm_return_state = LSM_RESET;
                d_lsm_state = LSM_SB_ACK;
              end
            else if (state_req_disable & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_state = LSM_DISABLE;
              end
            else if (sb_ustrm_link_error)
              d_lsm_state = LSM_LinkError;
          end
          LSM_LinkError: begin
            d_lsm_dstrm_state = SB_LINK_ERROR;
          end
          LSM_RETRAIN_a: begin
            d_lsm_dstrm_state = SB_LINK_RETRAIN_STS;
            d_lsm_state = LSM_RETRAIN_b;
          end
          LSM_RETRAIN_b: begin
            d_lsm_state = LSM_RETRAIN_c;
          end
          LSM_RETRAIN_c: begin
            if ((sb_ustrm_active_req | coldstart | lsm_exit_lp | sb_ustrm_link_retrain_sts) & ~lp_exit_cg_ack)
              d_lsm_state = LSM_RETRAIN;
          end
          LSM_RETRAIN: begin
            d_lsm_lnk_cfg = LNK_CFG_X16;
            d_lsm_speedmode = SPEEDMODE_GEN5;
            lsm_cg_req = 1'b1;
            d_pl_phyinrecenter = 1'b1;
            d_lsm_dstrm_state = SB_LINK_RETRAIN_STS;
            if ((state_req_active  & state_req_change) | coldstart | lsm_exit_lp)
              begin
                d_state_req_change = 1'b0;
                d_coldstart = 1'b0;
                d_lsm_exit_lp = 1'b0;
                d_lsm_state = LSM_ACTIVE_a;
              end
            else if (sb_ustrm_active_req)
              begin
                d_lsm_dstrm_state = SB_ACTIVE_STS;
                d_lsm_state = LSM_ACTIVE;
              end
            else if (state_req_linkreset & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_dstrm_state = SB_LINK_RESET_REQ;
                d_lsm_state = LSM_LinkReset_a;
              end
            else if (state_req_disable & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_state = LSM_DISABLE;
              end
            else if (sb_ustrm_link_error)
              d_lsm_state = LSM_LinkError;
          end
          LSM_DISABLE: begin
            d_pl_state_sts = STS_DISABLE;
            if (sb_ustrm_link_error)
              d_lsm_state = LSM_LinkError;
            else if (state_req_active & state_req_change)
              begin
                d_state_req_change = 1'b0;
                d_lsm_state = LSM_RESET;
              end
          end
          LSM_SB_ACK: begin
            if (sb_ack)
              begin
                d_lsm_state = lsm_return_state;
              end
          end
          default: d_lsm_state = LSM_RESET;
        endcase // case (lsm_state)
    end // block: lsm_state_next

  // pl_state_sts

  always_ff @(posedge lclk or negedge rst_n)
    if (~rst_n)
      begin
        pl_phyinl1 <= 1'b0;
        pl_phyinl2 <= 1'b0;
        pl_phyinrecenter <= 1'b0;
        pl_state_sts <= 4'b0;
        lsm_dstrm_state <= 4'b0;
        lsm_lnk_cfg <= LNK_CFG_X1;
        lsm_speedmode <= 3'b0;
        pl_lnk_up <= 1'b0;
        coldstart <= 1'b1;
        lsm_exit_lp <= 1'b0;
        lsm_return_state <= 4'b0;
        state_req_del <= 4'b0;
        state_req_change <= 1'b0;
      end
    else
      begin
        pl_phyinl1 <= d_pl_phyinl1;
        pl_phyinl2 <= d_pl_phyinl2;
        pl_phyinrecenter <= d_pl_phyinrecenter;
        pl_state_sts <= d_pl_state_sts;
        lsm_dstrm_state <= d_lsm_dstrm_state;
        lsm_lnk_cfg <= d_lsm_lnk_cfg;
        lsm_speedmode <= d_lsm_speedmode;
        pl_lnk_up <= d_pl_lnk_up;
        coldstart <= d_coldstart;
        lsm_exit_lp <= d_lsm_exit_lp;
        lsm_return_state <= d_lsm_return_state;
        state_req_del <= state_req;
        state_req_change <= d_state_req_change;
      end

  // exit_cg req/ack

  logic lsm_cg_req_del;
  logic lp_exit_cg_ack_del;

  always_ff @(posedge lclk or negedge rst_n)
    if (~rst_n)
      begin
        pl_exit_cg_req <= 1'b0;
        lsm_cg_req_del <= 1'b0;
        lp_exit_cg_ack_del <= 1'b0;
      end
    else
      begin
        lsm_cg_req_del <= lsm_cg_req;
        lp_exit_cg_ack_del <= lp_exit_cg_ack;
        if (lsm_cg_req)
          pl_exit_cg_req <= 1'b1;
        else if (lp_exit_cg_ack_del)
          pl_exit_cg_req <= 1'b0;
      end

  // stallreq/ack

  logic lsm_stall_req_del;
  logic lp_stallack_del;

  always_ff @(posedge lclk or negedge rst_n)
    if (~rst_n)
      begin
        pl_stallreq <= 1'b0;
        lsm_stall_req_del <= 1'b0;
        lp_stallack_del <= 1'b0;
      end
    else
      begin
        lsm_stall_req_del <= lsm_stall_req;
        lp_stallack_del <= lp_stallack;
        if (lsm_stall_req)
          pl_stallreq <= 1'b1;
        else if (lp_stallack_del)
          pl_stallreq <= 1'b0;
      end

  logic lp_wake_req_sync;

  /* levelsync AUTO_TEMPLATE (
   .RESET_VALUE (1'b0),
   .clk_dest    (lclk),
   .rst_dest_n  (rst_n),
   .src_data    (lp_wake_req),
   .dest_data   (lp_wake_req_sync),
   ); */

  levelsync
    #(/*AUTOINSTPARAM*/
      // Parameters
      .RESET_VALUE                      (1'b0))                  // Templated
  level_sync_i
    (/*AUTOINST*/
     // Outputs
     .dest_data                         (lp_wake_req_sync),      // Templated
     // Inputs
     .rst_dest_n                        (rst_n),                 // Templated
     .clk_dest                          (lclk),                  // Templated
     .src_data                          (lp_wake_req));           // Templated

  // wake_req/ack

  always_ff @(posedge lclk or negedge rst_n)
    if (~rst_n)
      begin
        pl_wake_ack <= 1'b0;
      end
    else
      begin
        if (lp_wake_req_sync)
          pl_wake_ack <= 1'b1;
        else if (~lp_wake_req_sync)
          pl_wake_ack <= 1'b0;
      end

endmodule // lpif_lsm

// Local Variables:
// verilog-library-directories:("." "${PROJ_DIR}/common/rtl")
// verilog-auto-inst-param-value:t
// End:
