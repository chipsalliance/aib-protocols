////////////////////////////////////////////////////////////
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
// Functional Descript: LPIF Pipeline Buffer
//
//
//
////////////////////////////////////////////////////////////

module lpif_pipeline
  #(
    parameter AIB_VERSION = 2,
    parameter AIB_GENERATION = 2,
    parameter AIB_LANES = 4,
    parameter AIB_BITS_PER_LANE = 80,
    parameter AIB_CLOCK_RATE = 2000,
    parameter LPIF_CLOCK_RATE = 2000,
    parameter LPIF_DATA_WIDTH = 32,
    parameter LPIF_PIPELINE_STAGES = 1,
    parameter MEM_CACHE_STREAM_ID = 8'h1,
    parameter IO_STREAM_ID = 8'h2,
    parameter ARB_MUX_STREAM_ID = 8'h3,
    localparam LPIF_VALID_WIDTH = ((LPIF_DATA_WIDTH == 128) ? 2 : 1),
    localparam LPIF_CRC_WIDTH = ((LPIF_DATA_WIDTH == 128) ? 32 : 16)
    )
  (
   // LPIF Interface
   input logic                                      lclk,
   input logic                                      reset,

   input  logic [LPIF_VALID_WIDTH-1:0]              lp_valid,
   input  logic                                     lp_irdy,
   input  logic [1:0]                               lp_pri,
   input  logic [3:0]                               lp_state_req,
   input  logic [7:0]                               lp_cfg,
   input  logic [7:0]                               lp_stream,
   input  logic                                     lp_cfg_vld,
   input  logic                                     lp_clk_ack,
   input  logic                                     lp_device_present,
   input  logic                                     lp_exit_cg_ack,
   input  logic                                     lp_flushed_all,
   input  logic                                     lp_force_detect,
   input  logic [LPIF_CRC_WIDTH-1:0]                lp_crc,
   input  logic [LPIF_DATA_WIDTH*8-1:0]             lp_data,
   input  logic                                     lp_crc_valid,
   input  logic                                     lp_linkerror,
   input  logic                                     lp_rcvd_crc_err,
   input  logic                                     lp_stallack,
   input  logic                                     lp_wake_req,

   output logic                                     lp_prime_trans_valid, // Indicates valid transaction with at least one valid.
   output logic [LPIF_VALID_WIDTH-1:0]              lp_prime_valid,
   output logic                                     lp_prime_irdy,
   output logic [1:0]                               lp_prime_pri,
   output logic [3:0]                               lp_prime_state_req,
   output logic [7:0]                               lp_prime_cfg,
   output logic [7:0]                               lp_prime_stream,
   output logic                                     lp_prime_cfg_vld,
   output logic                                     lp_prime_clk_ack,
   output logic                                     lp_prime_device_present,
   output logic                                     lp_prime_exit_cg_ack,
   output logic                                     lp_prime_flushed_all,
   output logic                                     lp_prime_force_detect,
   output logic [LPIF_CRC_WIDTH-1:0]                lp_prime_crc,
   output logic [LPIF_DATA_WIDTH*8-1:0]             lp_prime_data,
   output logic                                     lp_prime_crc_valid,
   output logic                                     lp_prime_linkerror,
   output logic                                     lp_prime_rcvd_crc_err,
   output logic                                     lp_prime_stallack,
   output logic                                     lp_prime_wake_req,

   output logic [LPIF_VALID_WIDTH-1:0]              pl_valid,
   output logic                                     pl_trdy,
   output logic [2:0]                               pl_clr_lnkeqreq,
   output logic [2:0]                               pl_lnk_cfg,
   output logic [2:0]                               pl_protocol,
   output logic [2:0]                               pl_set_lnkeqreq,
   output logic [2:0]                               pl_speedmode,
   output logic [3:0]                               pl_state_sts,
   output logic [7:0]                               pl_cfg,
   output logic [7:0]                               pl_stream,
   output logic [LPIF_CRC_WIDTH-1:0]                pl_crc,
   output logic [LPIF_DATA_WIDTH*8-1:0]             pl_data,
   output logic                                     pl_crc_valid,
   output logic                                     pl_cerror,
   output logic                                     pl_cfg_vld,
   output logic                                     pl_clk_req,
   output logic                                     pl_error,
   output logic                                     pl_err_pipestg,
   output logic                                     pl_exit_cg_req,
   output logic                                     pl_inband_pres,
   output logic                                     pl_lnk_up,
   output logic                                     pl_phyinl1,
   output logic                                     pl_phyinl2,
   output logic                                     pl_phyinrecenter,
   output logic                                     pl_portmode,
   output logic                                     pl_portmode_val,
   output logic                                     pl_protocol_vld,
   output logic                                     pl_quiesce,
   output logic                                     pl_rxframe_errmask,
   output logic                                     pl_setlabs,
   output logic                                     pl_setlbms,
   output logic                                     pl_stallreq,
   output logic                                     pl_surprise_lnk_down,
   output logic                                     pl_trainerror,
   output logic                                     pl_wake_ack,

   input  logic [LPIF_VALID_WIDTH-1:0]              pl_prime_valid,
   input  logic                                     pl_prime_trdy,
   input  logic [2:0]                               pl_prime_clr_lnkeqreq,
   input  logic [2:0]                               pl_prime_lnk_cfg,
   input  logic [2:0]                               pl_prime_protocol,
   input  logic [2:0]                               pl_prime_set_lnkeqreq,
   input  logic [2:0]                               pl_prime_speedmode,
   input  logic [3:0]                               pl_prime_state_sts,
   input  logic [7:0]                               pl_prime_cfg,
   input  logic [7:0]                               pl_prime_stream,
   input  logic [LPIF_CRC_WIDTH-1:0]                pl_prime_crc,
   input  logic [LPIF_DATA_WIDTH*8-1:0]             pl_prime_data,
   input  logic                                     pl_prime_crc_valid,
   input  logic                                     pl_prime_cerror,
   input  logic                                     pl_prime_cfg_vld,
   input  logic                                     pl_prime_clk_req,
   input  logic                                     pl_prime_error,
   input  logic                                     pl_prime_err_pipestg,
   input  logic                                     pl_prime_exit_cg_req,
   input  logic                                     pl_prime_inband_pres,
   input  logic                                     pl_prime_lnk_up,
   input  logic                                     pl_prime_phyinl1,
   input  logic                                     pl_prime_phyinl2,
   input  logic                                     pl_prime_phyinrecenter,
   input  logic                                     pl_prime_portmode,
   input  logic                                     pl_prime_portmode_val,
   input  logic                                     pl_prime_protocol_vld,
   input  logic                                     pl_prime_quiesce,
   input  logic                                     pl_prime_rxframe_errmask,
   input  logic                                     pl_prime_setlabs,
   input  logic                                     pl_prime_setlbms,
   input  logic                                     pl_prime_stallreq,
   input  logic                                     pl_prime_surprise_lnk_down,
   input  logic                                     pl_prime_trainerror,
   input  logic                                     pl_prime_wake_ack
   );


    localparam LP_DATA_FLOW_WID =
                                   // LPIF_VALID_WIDTH      + // lp_valid
                                   // 1                     + // lp_irdy
                                   // 1                     + // pl_trdy
                                   LPIF_DATA_WIDTH*8     + // lp_data
                                   LPIF_CRC_WIDTH        + // lp_crc
                                   8                     + // lp_stream
                                   1                     + // lp_crc_valid
                                   LPIF_VALID_WIDTH      ; // lp_valid (duplicate)

    localparam LP_DATA_DELAY_WID =
                                   1                     + // lp_irdy (duplicate ... used to qualify lp_pri)    [24]
                                   2                     + // lp_pri                                            [23:22]
                                   4                     + // lp_state_req                                      [21:18]
                                   8                     + // lp_cfg                                            [17:10]
                                   1                     + // lp_cfg_vld                                        [9]
                                   1                     + // lp_clk_ack                                        [8]
                                   1                     + // lp_device_present                                 [7]
                                   1                     + // lp_exit_cg_ack                                    [6]
                                   1                     + // lp_flushed_all                                    [5]
                                   1                     + // lp_force_detect                                   [4]
                                   1                     + // lp_linkerror                                      [3]
                                   1                     + // lp_rcvd_crc_err                                   [2]
                                   1                     + // lp_stallack                                       [1]
                                   1                     ; // lp_wake_req                                       [0]

    localparam PL_DATA_DELAY_WID =
                                   LPIF_VALID_WIDTH      + // pl_valid                
                                   LPIF_CRC_WIDTH        + // pl_crc                  
                                   LPIF_DATA_WIDTH*8     + // pl_data                 
                                   3                     + // pl_clr_lnkeqreq         [56:54]
                                   3                     + // pl_lnk_cfg              [53:51]
                                   3                     + // pl_protocol             [50:48]
                                   3                     + // pl_set_lnkeqreq         [47:45]
                                   3                     + // pl_speedmode            [44:42]
                                   4                     + // pl_state_sts            [42:39]
                                   8                     + // pl_cfg                  [38:31]
                                   8                     + // pl_stream               [30:23]
                                   1                     + // pl_crc_valid            [22]
                                   1                     + // pl_cerror               [21]
                                   1                     + // pl_cfg_vld              [20]
                                   1                     + // pl_clk_req              [19]
                                   1                     + // pl_error                [18]
                                   1                     + // pl_err_pipestg          [17]
                                   1                     + // pl_exit_cg_req          [16]
                                   1                     + // pl_inband_pres          [15]
                                   1                     + // pl_lnk_up               [14]
                                   1                     + // pl_phyinl1              [13]
                                   1                     + // pl_phyinl2              [12]
                                   1                     + // pl_phyinrecenter        [11]
                                   1                     + // pl_portmode             [10]
                                   1                     + // pl_portmode_val         [9]
                                   1                     + // pl_protocol_vld         [8]
                                   1                     + // pl_quiesce              [7]
                                   1                     + // pl_rxframe_errmask      [6]
                                   1                     + // pl_setlabs              [5]
                                   1                     + // pl_setlbms              [4]
                                   1                     + // pl_stallreq             [3]
                                   1                     + // pl_surprise_lnk_down    [2]
                                   1                     + // pl_trainerror           [1]
                                   1                     ; // pl_wake_ack             [0]




//////////////////////////////////////////////////////////////////////
// LP Delay
    logic [LP_DATA_DELAY_WID-1:0] lp_delay_data_pipeline [0:LPIF_PIPELINE_STAGES+1-1];

    assign lp_delay_data_pipeline [0] = {lp_irdy           ,
                                         lp_pri            ,
                                         lp_state_req      ,
                                         lp_cfg            ,
                                         lp_cfg_vld        ,
                                         lp_clk_ack        ,
                                         lp_device_present ,
                                         lp_exit_cg_ack    ,
                                         lp_flushed_all    ,
                                         lp_force_detect   ,
                                         lp_linkerror      ,
                                         lp_rcvd_crc_err   ,
                                         lp_stallack       ,
                                         lp_wake_req       };

    assign {lp_prime_irdy           ,
            lp_prime_pri            ,
            lp_prime_state_req      ,
            lp_prime_cfg            ,
            lp_prime_cfg_vld        ,
            lp_prime_clk_ack        ,
            lp_prime_device_present ,
            lp_prime_exit_cg_ack    ,
            lp_prime_flushed_all    ,
            lp_prime_force_detect   ,
            lp_prime_linkerror      ,
            lp_prime_rcvd_crc_err   ,
            lp_prime_stallack       ,
            lp_prime_wake_req       } = lp_delay_data_pipeline [LPIF_PIPELINE_STAGES];


  genvar   i_lp_delay_pipeline;
  generate

    for (i_lp_delay_pipeline = 0; i_lp_delay_pipeline < LPIF_PIPELINE_STAGES; i_lp_delay_pipeline++)
      begin : gen_blk_lp_delay_stage

          always_ff @(posedge lclk or negedge reset)
            begin
              if (~reset)
                begin
                  lp_delay_data_pipeline        [i_lp_delay_pipeline+1] <= {LP_DATA_DELAY_WID{1'b0}};
                end
              else
                begin
                  lp_delay_data_pipeline        [i_lp_delay_pipeline+1] <= lp_delay_data_pipeline        [i_lp_delay_pipeline];
                end // else: !if(~reset)
            end // always_ff @ (posedge lclk or negedge reset)

      end
  endgenerate

// LP Delay
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// PL Delay
    logic [PL_DATA_DELAY_WID-1:0] pl_delay_data_pipeline [0:LPIF_PIPELINE_STAGES+1-1];

    assign pl_delay_data_pipeline [0] = {pl_prime_valid             ,
                                         pl_prime_crc               ,
                                         pl_prime_data              ,
                                         pl_prime_clr_lnkeqreq      ,
                                         pl_prime_lnk_cfg           ,
                                         pl_prime_protocol          ,
                                         pl_prime_set_lnkeqreq      ,
                                         pl_prime_speedmode         ,
                                         pl_prime_state_sts         ,
                                         pl_prime_cfg               ,
                                         pl_prime_stream            ,
                                         pl_prime_crc_valid         ,
                                         pl_prime_cerror            ,
                                         pl_prime_cfg_vld           ,
                                         pl_prime_clk_req           ,
                                         pl_prime_error             ,
                                         pl_prime_err_pipestg       ,
                                         pl_prime_exit_cg_req       ,
                                         pl_prime_inband_pres       ,
                                         pl_prime_lnk_up            ,
                                         pl_prime_phyinl1           ,
                                         pl_prime_phyinl2           ,
                                         pl_prime_phyinrecenter     ,
                                         pl_prime_portmode          ,
                                         pl_prime_portmode_val      ,
                                         pl_prime_protocol_vld      ,
                                         pl_prime_quiesce           ,
                                         pl_prime_rxframe_errmask   ,
                                         pl_prime_setlabs           ,
                                         pl_prime_setlbms           ,
                                         pl_prime_stallreq          ,
                                         pl_prime_surprise_lnk_down ,
                                         pl_prime_trainerror        ,
                                         pl_prime_wake_ack          };

    assign {pl_valid             ,
            pl_crc               ,
            pl_data              ,
            pl_clr_lnkeqreq      ,
            pl_lnk_cfg           ,
            pl_protocol          ,
            pl_set_lnkeqreq      ,
            pl_speedmode         ,
            pl_state_sts         ,
            pl_cfg               ,
            pl_stream            ,
            pl_crc_valid         ,
            pl_cerror            ,
            pl_cfg_vld           ,
            pl_clk_req           ,
            pl_error             ,
            pl_err_pipestg       ,
            pl_exit_cg_req       ,
            pl_inband_pres       ,
            pl_lnk_up            ,
            pl_phyinl1           ,
            pl_phyinl2           ,
            pl_phyinrecenter     ,
            pl_portmode          ,
            pl_portmode_val      ,
            pl_protocol_vld      ,
            pl_quiesce           ,
            pl_rxframe_errmask   ,
            pl_setlabs           ,
            pl_setlbms           ,
            pl_stallreq          ,
            pl_surprise_lnk_down ,
            pl_trainerror        ,
            pl_wake_ack          } = pl_delay_data_pipeline [LPIF_PIPELINE_STAGES];


  genvar   i_pl_delay_pipeline;
  generate

    for (i_pl_delay_pipeline = 0; i_pl_delay_pipeline < LPIF_PIPELINE_STAGES; i_pl_delay_pipeline++)
      begin : gen_blk_pl_delay_stage

          always_ff @(posedge lclk or negedge reset)
            begin
              if (~reset)
                begin
                  pl_delay_data_pipeline        [i_pl_delay_pipeline+1] <= {PL_DATA_DELAY_WID{1'b0}};
                end
              else
                begin
                  pl_delay_data_pipeline        [i_pl_delay_pipeline+1] <= pl_delay_data_pipeline        [i_pl_delay_pipeline];
                end // else: !if(~reset)
            end // always_ff @ (posedge lclk or negedge reset)

      end
  endgenerate

// PL Delay
//////////////////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////////////////
// LP Flow Control

  genvar   i_lp_pipeline;
  generate

    if (LPIF_PIPELINE_STAGES == 0)
    begin
        assign pl_trdy            = pl_prime_trdy;
        assign lp_prime_valid     = lp_irdy ? lp_valid : {LPIF_VALID_WIDTH{1'b0}} ;

        assign lp_prime_data      = lp_data      ;
        assign lp_prime_stream    = lp_stream    ;
        assign lp_prime_crc       = lp_crc       ;
        assign lp_prime_crc_valid = lp_crc_valid ;
        assign lp_prime_trans_valid = lp_irdy & (|lp_valid) ;
    end
    else
    begin

      logic [0:0]                  lp_pipeline_valid     [0: LPIF_PIPELINE_STAGES+1];
      logic [0:0]                  lp_pipeline_ready     [0: LPIF_PIPELINE_STAGES+1];
      logic [0:0]                  lp_pipeline_push      [0: LPIF_PIPELINE_STAGES+1];
      logic [0:0]                  lp_pipeline_pop       [0: LPIF_PIPELINE_STAGES+1];
      logic [LP_DATA_FLOW_WID-1:0] lp_pipeline_wrdata    [0: LPIF_PIPELINE_STAGES+1];
      logic [LP_DATA_FLOW_WID-1:0] lp_pipeline_rddata    [0: LPIF_PIPELINE_STAGES+1];
      logic [0:0]                  lp_pipeline_empty     [0: LPIF_PIPELINE_STAGES+1];

      logic [LPIF_VALID_WIDTH-1:0] lp_prime_valid_raw;

      assign pl_trdy               = lp_pipeline_ready [0] & (pl_state_sts [3:0] == 4'h1);

      assign lp_pipeline_valid [0] = lp_irdy & (|lp_valid) ;
      assign lp_pipeline_ready [0] = (lp_pipeline_empty [0] | lp_pipeline_pop [0]);

      assign lp_pipeline_push  [0] = (lp_pipeline_empty [0] | lp_pipeline_pop [0]) & lp_pipeline_valid [0] ;
      assign lp_pipeline_pop   [0] = lp_pipeline_push [0+1] ;

      assign lp_pipeline_wrdata [0] = {lp_data      ,    
                                       lp_crc       ,    
                                       lp_stream    ,    
                                       lp_crc_valid ,    
                                       lp_valid     };   


       lpif_pipe_stage #(.DATA_WIDTH(LP_DATA_FLOW_WID)) lpif_pipe_stage_lp_i0 (
        .lclk   (lclk),
        .reset  (reset),
        .empty  (lp_pipeline_empty  [0]) ,
        .rddata (lp_pipeline_rddata [0]) ,
        .pop    (lp_pipeline_pop    [0]) ,
        .wrdata (lp_pipeline_wrdata [0]) ,
        .push   (lp_pipeline_push   [0]) ) ;


      for (i_lp_pipeline = 1; i_lp_pipeline < LPIF_PIPELINE_STAGES; i_lp_pipeline++)
        begin : gen_blk_lp_flow_stage

           if (i_lp_pipeline != 0)
           begin
             assign lp_pipeline_valid [i_lp_pipeline] = ~lp_pipeline_empty [i_lp_pipeline-1];
             assign lp_pipeline_ready [i_lp_pipeline] = (lp_pipeline_empty [i_lp_pipeline] | lp_pipeline_pop [i_lp_pipeline]) ;

             assign lp_pipeline_push  [i_lp_pipeline] = (lp_pipeline_empty [i_lp_pipeline] | lp_pipeline_pop [i_lp_pipeline]) & lp_pipeline_valid [i_lp_pipeline] ;
             assign lp_pipeline_pop   [i_lp_pipeline] = lp_pipeline_push [i_lp_pipeline+1] ;

             assign lp_pipeline_wrdata [i_lp_pipeline] = lp_pipeline_rddata [i_lp_pipeline-1] ;
           end

           lpif_pipe_stage #(.DATA_WIDTH(LP_DATA_FLOW_WID)) lpif_pipe_stage_lp (
            .lclk   (lclk),
            .reset  (reset),
            .empty  (lp_pipeline_empty  [i_lp_pipeline]) ,
            .rddata (lp_pipeline_rddata [i_lp_pipeline]) ,
            .pop    (lp_pipeline_pop    [i_lp_pipeline]) ,
            .wrdata (lp_pipeline_wrdata [i_lp_pipeline]) ,
            .push   (lp_pipeline_push   [i_lp_pipeline]) ) ;

        end


      assign lp_pipeline_valid  [LPIF_PIPELINE_STAGES] = ~lp_pipeline_empty [LPIF_PIPELINE_STAGES-1];

      assign lp_pipeline_push   [LPIF_PIPELINE_STAGES] = lp_pipeline_valid [LPIF_PIPELINE_STAGES] & pl_prime_trdy;

      assign lp_pipeline_wrdata [LPIF_PIPELINE_STAGES] = lp_pipeline_rddata [LPIF_PIPELINE_STAGES-1] ;

      assign { lp_prime_data      ,
               lp_prime_crc       ,
               lp_prime_stream    ,
               lp_prime_crc_valid ,
               lp_prime_valid_raw } = lp_pipeline_wrdata [LPIF_PIPELINE_STAGES];


      assign lp_prime_valid = lp_pipeline_valid [LPIF_PIPELINE_STAGES] ? lp_prime_valid_raw : {LPIF_VALID_WIDTH{1'b0}} ;

      assign lp_prime_trans_valid = lp_pipeline_valid [LPIF_PIPELINE_STAGES] ;


    end
  endgenerate

// LP Flow Control
//////////////////////////////////////////////////////////////////////


endmodule // lpif_pipeline //

////////////////////////////////////////////////////////////
//Module:	lpif_pipeline
//$Id$
////////////////////////////////////////////////////////////
