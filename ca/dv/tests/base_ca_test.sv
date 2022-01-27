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

`ifndef _BASE_CA_TEST_
`define _BASE_CA_TEST_

`define open_mon_logfile(testname)
`ifdef CA_YELLOW_OVAL
`include "intel_aib_init_base_test.sv"
/////////////////////////////////////////////////////////////
class base_ca_test_c extends intel_aib_init_base_test;
`else
class base_ca_test_c extends uvm_test;
`endif
    // UVM Factory Registration Macro
    `uvm_component_utils(base_ca_test_c)
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    virtual ca_reset_if    vif;
    virtual ca_gen_if      gen_if;
    ca_cfg_c               ca_cfg;  
    uvm_report_server      server;
    bit                    test_end;   
    bit                    base_test;   
    int                    tx_stb_intv_bkp;
    //------------------------------------------
    // Component Members
    //------------------------------------------
    // The environment class
    ca_top_env_c           ca_top_env; 

    //------------------------------------------
    // Methods
    //------------------------------------------
    // Standard UVM Methods:
    //------------------------------------------
    extern function new(string name = "base_ca_test_c", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void end_of_elaboration_phase( uvm_phase phase );
    extern function void connect_phase( uvm_phase phase );
    extern task shutdown_phase( uvm_phase phase );
    extern function void start_of_simulation( );
    extern task run_phase( uvm_phase phase);
    //------------------------------------------
    // Standard UVM Methods:
    //------------------------------------------
    extern task global_timer( );
    extern function void ck_global_err_cnt( );
    extern function bit ck_xfer_cnt_a(bit show);
    extern function bit ck_xfer_cnt_b(bit show);
    extern task ck_eot( uvm_phase phase );
    extern task sbd_counts_clear( );
    extern task sbd_counts_only_clear( );
 
endclass: base_ca_test_c

////////////////////////////////////////////////////////////
function base_ca_test_c::new(string name = "base_ca_test_c", uvm_component parent = null);
    
    super.new(name, parent);

endfunction

//------------------------------------------
function void base_ca_test_c::end_of_elaboration_phase(uvm_phase phase);
  `uvm_info(get_type_name(), ">>>>>>>>> BENCH TOPOLOGY <<<<<<<<<", UVM_NONE)
  uvm_top.print_topology();
endfunction : end_of_elaboration_phase

//------------------------------------------
// Build the env, create the env configuration
// including any sub configurations and assigning virtual interfaces
//------------------------------------------
function void base_ca_test_c::build_phase( uvm_phase phase );
    
    `uvm_info("base_ca_test_c::build_phase", "START base build_phase...", UVM_LOW); 
`ifdef CA_YELLOW_OVAL
    super.build_phase(phase);
`endif
    ca_cfg     = ca_cfg_c::type_id::create("ca_cfg");
    if(!(ca_cfg.randomize())) `uvm_fatal("base_ca_test_c", $sformatf("ca_cfg randomize FAILED!!"));
    ca_cfg.configure();
    uvm_config_db# (ca_cfg_c)::set(this, "*", "ca_cfg", ca_cfg);
    // die A
    uvm_config_db# (ca_tx_tb_out_cfg_c)::set(this, "*.ca_die_a_tx_tb_out_agent*", "ca_tx_tb_out_cfg", ca_cfg.ca_die_a_tx_tb_out_cfg);
    uvm_config_db# (ca_tx_tb_in_cfg_c)::set(this, "*.ca_die_a_tx_tb_in_agent*", "ca_tx_tb_in_cfg", ca_cfg.ca_die_a_tx_tb_in_cfg); // same as out
    uvm_config_db# (ca_rx_tb_in_cfg_c)::set(this, "*.ca_die_a_rx_tb_in_agent*", "ca_rx_tb_in_cfg", ca_cfg.ca_die_a_rx_tb_in_cfg);
    // die B
    uvm_config_db# (ca_tx_tb_out_cfg_c)::set(this, "*.ca_die_b_tx_tb_out_agent*", "ca_tx_tb_out_cfg", ca_cfg.ca_die_b_tx_tb_out_cfg);
    uvm_config_db# (ca_tx_tb_in_cfg_c)::set(this, "*.ca_die_b_tx_tb_in_agent*", "ca_tx_tb_in_cfg", ca_cfg.ca_die_b_tx_tb_in_cfg); // same as out
    uvm_config_db# (ca_rx_tb_in_cfg_c)::set(this, "*.ca_die_b_rx_tb_in_agent*", "ca_rx_tb_in_cfg", ca_cfg.ca_die_b_rx_tb_in_cfg);

    for(int i = 0; i < `MAX_NUM_CHANNELS; i++) begin
        uvm_config_db# (chan_delay_cfg_c)::set(this, $sformatf("*.chan_delay_die_b_agent_%0d*", i), "chan_delay_cfg", ca_cfg.ca_die_b_delay_cfg[i]);
    end

    for(int i = 0; i < `MAX_NUM_CHANNELS; i++) begin
        uvm_config_db# (chan_delay_cfg_c)::set(this, $sformatf("*.chan_delay_die_a_agent_%0d*", i), "chan_delay_cfg", ca_cfg.ca_die_a_delay_cfg[i]);
    end

    uvm_config_db# (ca_reset_cfg_c)::set(this, "*", "reset_cfg", ca_cfg.reset_cfg);

    if( !uvm_config_db #( virtual ca_reset_if )::get(this, "" , "reset_vif", vif) )
        `uvm_fatal("build_phase", "unable to get reset vif")
    
    if( !uvm_config_db #( virtual ca_gen_if)::get(this, "" , "gen_vif", gen_if) )
        `uvm_fatal("build_phase", "unable to get gen vif")

    server = uvm_report_server::get_server();

    // create the env
    ca_top_env = ca_top_env_c::type_id::create("ca_top_env", this);

    `uvm_info("base_ca_test_c::build_phase", "END base build_phase...\n", UVM_LOW); 

endfunction: build_phase


//------------------------------------------
function void base_ca_test_c::connect_phase( uvm_phase phase );
    
    //

endfunction: connect_phase


//------------------------------------------
function void base_ca_test_c::start_of_simulation( );

    //

endfunction: start_of_simulation 

//------------------------------------------
task base_ca_test_c::run_phase(uvm_phase phase);

`ifdef CA_YELLOW_OVAL
    $display("\n CA_BASE_TEST :: run phase calling super at  %0t",$time);
   super.run_phase(phase);
    $display("\n CA_BASE_TEST :: run phase done call to super at %0t",$time);
`endif
endtask : run_phase
//------------------------------------------
task base_ca_test_c::sbd_counts_only_clear();

     ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_a  = 0;
     ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_b  = 0;
     ca_cfg.ca_die_b_rx_tb_in_cfg.drv_tfr_complete_a  = 0;
     ca_cfg.ca_die_b_rx_tb_in_cfg.drv_tfr_complete_b  = 0;
     ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab = 0;
     ca_cfg.ca_die_a_tx_tb_in_cfg.drv_tfr_complete_ab = 0;
     ca_cfg.ca_die_b_rx_tb_in_cfg.drv_tfr_complete_ab = 0;
     ca_cfg.ca_die_b_tx_tb_in_cfg.drv_tfr_complete_ab = 0;
     ca_top_env.ca_scoreboard.rx_out_cnt_die_a        = 0;
     ca_top_env.ca_scoreboard.rx_out_cnt_die_b        = 0;
     ca_top_env.ca_scoreboard.tx_out_cnt_die_a        = 0;
     ca_top_env.ca_scoreboard.tx_out_cnt_die_b        = 0;
     ca_top_env.ca_scoreboard.beat_cnt_a              = 0;
     ca_top_env.ca_scoreboard.beat_cnt_b              = 0;

endtask : sbd_counts_only_clear

task base_ca_test_c::sbd_counts_clear();
     
     ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_a  = 0;
     ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_b  = 0;
     ca_cfg.ca_die_b_rx_tb_in_cfg.drv_tfr_complete_a  = 0;
     ca_cfg.ca_die_b_rx_tb_in_cfg.drv_tfr_complete_b  = 0;
     ca_cfg.ca_die_a_rx_tb_in_cfg.drv_tfr_complete_ab = 0;
     ca_cfg.ca_die_a_tx_tb_in_cfg.drv_tfr_complete_ab = 0;
     ca_cfg.ca_die_b_rx_tb_in_cfg.drv_tfr_complete_ab = 0;
     ca_cfg.ca_die_b_tx_tb_in_cfg.drv_tfr_complete_ab = 0;
     ca_top_env.ca_scoreboard.rx_out_cnt_die_a        = 0;
     ca_top_env.ca_scoreboard.rx_out_cnt_die_b        = 0;
     ca_top_env.ca_scoreboard.tx_out_cnt_die_a        = 0;
     ca_top_env.ca_scoreboard.tx_out_cnt_die_b        = 0;
     ca_top_env.ca_scoreboard.beat_cnt_a              = 0;
     ca_top_env.ca_scoreboard.beat_cnt_b              = 0;
     ca_top_env.ca_scoreboard.tx_xfer_cnt_a           = 0;
     ca_top_env.ca_scoreboard.tx_xfer_cnt_b           = 0;
     ca_top_env.ca_scoreboard.die_a_tx_din_q.delete();
     ca_top_env.ca_scoreboard.die_b_tx_din_q.delete();
     ca_top_env.ca_scoreboard.die_a_exp_rx_dout_q.delete();
     ca_top_env.ca_scoreboard.die_b_exp_rx_dout_q.delete();

endtask : sbd_counts_clear 
//------------------------------------------
task base_ca_test_c::global_timer();

    
    int local_cnt = 0;
    bit result_a = 0;
    bit result_b = 0;

    `uvm_info("GLOBAL_TIMER", "Global timer START!\n", UVM_LOW);       
    
    fork
       begin
         #30us; ///GEN1 needs more time for (online and then align_done)
         if((gen_if.die_a_align_done == 0)  && (gen_if.die_b_align_done == 0)) begin
             `uvm_fatal("NO_ALIGN_DONE TIMER", $sformatf("\n ***> [DIE_A/DIE_B] ALIGN_DONE is not asserted within expected time [25usec] %0t <***\n", $time));
         end
       end
    join_none
 
    forever begin
        repeat(1)@(posedge vif.clk); 
        ck_global_err_cnt();
        local_cnt++;
        if(local_cnt % 5000 == 0) begin
           if(ca_cfg.ca_knobs.traffic_enb_ab[0]) begin
              result_a = ck_xfer_cnt_a(1);
           end
           if(ca_cfg.ca_knobs.traffic_enb_ab[1]) begin
              result_b = ck_xfer_cnt_b(1);
           end

           /////COMPARE local_cnt to clk-time with knobs.GLOBAL_TIMEOUT ... then next line can be FATAL or INFO based on comparison
           if (local_cnt >= ca_cfg.ca_knobs.GLOBAL_TIMEOUT) begin
             `uvm_fatal("GLOBAL_TIMER", $sformatf("\n ***> TEST ENDS with GLOBAL TIMEOUT at %0t <***\n", $time));
           end else begin
            `uvm_info("GLOBAL_TIMER", $sformatf("....sim heartbeat %0d cycles....",local_cnt), UVM_NONE);
          end
        end
    end //forever
    
endtask : global_timer 

//------------------------------------------
function bit base_ca_test_c::ck_xfer_cnt_a(bit show);

    ck_xfer_cnt_a = 1;

      if(ca_cfg.ca_knobs.tx_xfer_cnt_die_a != ca_top_env.ca_scoreboard.rx_out_cnt_die_b) ck_xfer_cnt_a = 0; 

    if(show == 1) begin
        if(ca_cfg.ca_knobs.tx_xfer_cnt_die_a != ca_top_env.ca_scoreboard.rx_out_cnt_die_b) begin
            `uvm_info("ck_xfer_cnt", $sformatf(">>> DIE_A tx_din: %0d != DIE_B rx_dout: %0d <<<",
                ca_cfg.ca_knobs.tx_xfer_cnt_die_a, ca_top_env.ca_scoreboard.rx_out_cnt_die_b), UVM_NONE);
        end
        else begin
            `uvm_info("ck_xfer_cnt", $sformatf("DIE_A tx_din: %0d == DIE_B rx_dout: %0d",
                ca_cfg.ca_knobs.tx_xfer_cnt_die_a, ca_top_env.ca_scoreboard.rx_out_cnt_die_b), UVM_NONE);
        end
    end

    return ck_xfer_cnt_a;

endfunction : ck_xfer_cnt_a

//------------------------------------------
function bit base_ca_test_c::ck_xfer_cnt_b(bit show);

    ck_xfer_cnt_b = 1;

    if(ca_cfg.ca_knobs.tx_xfer_cnt_die_b != ca_top_env.ca_scoreboard.rx_out_cnt_die_a) ck_xfer_cnt_b = 0; 

    if(show == 1) begin
        if(ca_cfg.ca_knobs.tx_xfer_cnt_die_b != ca_top_env.ca_scoreboard.rx_out_cnt_die_a) begin
            `uvm_info("ck_xfer_cnt", $sformatf(">>> DIE_B tx_din: %0d != DIE_A rx_dout: %0d <<<",
                ca_cfg.ca_knobs.tx_xfer_cnt_die_b, ca_top_env.ca_scoreboard.rx_out_cnt_die_a), UVM_NONE);
        end
        else begin
            `uvm_info("ck_xfer_cnt", $sformatf("DIE_B tx_din: %0d == DIE_A rx_dout: %0d",
                ca_cfg.ca_knobs.tx_xfer_cnt_die_b, ca_top_env.ca_scoreboard.rx_out_cnt_die_a), UVM_NONE);
        end
    end
    
    return ck_xfer_cnt_b;

endfunction : ck_xfer_cnt_b

//------------------------------------------
function void base_ca_test_c::ck_global_err_cnt( );

    bit result_a = 0;
    bit result_b = 0;

         if(server.get_severity_count(UVM_ERROR) >= ca_cfg.ca_knobs.stop_err_cnt) begin
               if(ca_cfg.ca_knobs.traffic_enb_ab[0]) begin
                  result_a = ck_xfer_cnt_a(1);
               end
               if(ca_cfg.ca_knobs.traffic_enb_ab[1]) begin
                  result_b = ck_xfer_cnt_b(1);
               end
             `uvm_fatal("STOP_ERROR_CNT", $sformatf("base test: MAX error %0d reached.  Ending sim...", ca_cfg.ca_knobs.stop_err_cnt));
         end

endfunction : ck_global_err_cnt

//------------------------------------------
task base_ca_test_c::ck_eot( uvm_phase phase );

    bit result_a = 0;
    bit result_b = 0;

    phase.raise_objection(this);
    if((ca_cfg.ca_die_a_tx_tb_in_cfg.no_external_stb_test == 0) && 
       (ca_cfg.ca_die_a_tx_tb_in_cfg.stb_error_test       == 0) && 
       (ca_cfg.ca_die_a_rx_tb_in_cfg.align_error_test     == 0) &&
       (ca_cfg.ca_die_a_tx_tb_in_cfg.ca_toggle_test       == 0) &&
       (ca_cfg.ca_die_a_tx_tb_in_cfg.ca_tx_online_test    == 0) &&
       (ca_cfg.ca_die_a_tx_tb_in_cfg.ca_afly1_stb_incorrect_intv_test == 0))begin
     if(ca_cfg.ca_knobs.traffic_enb_ab[0]) begin
        while(ck_xfer_cnt_a(0) == 0) begin
            repeat (10) @(posedge vif.clk);
        end
     end 
     if(ca_cfg.ca_knobs.traffic_enb_ab[1]) begin
        while(ck_xfer_cnt_b(0) == 0) begin
            repeat (10) @(posedge vif.clk);
        end
     end
    end
   if(base_test == 0)begin 
     wait(test_end == 1); 
   end
    $display("inside_base_ca_test : test_end,%0d",test_end);
         repeat (10) @(posedge vif.clk);
    phase.drop_objection(this);
    `uvm_info("ck_eot", $sformatf("DROPPING objection... test ending gracefully "), UVM_NONE);
    if((ca_cfg.ca_die_a_tx_tb_in_cfg.no_external_stb_test == 0) &&
       (ca_cfg.ca_die_a_tx_tb_in_cfg.stb_error_test       == 0) &&
       (ca_cfg.ca_die_a_rx_tb_in_cfg.align_error_test     == 0) &&
       (ca_cfg.ca_die_a_tx_tb_in_cfg.ca_toggle_test       == 0) &&
       (ca_cfg.ca_die_a_tx_tb_in_cfg.ca_tx_online_test    == 0) &&
       (ca_cfg.ca_die_a_tx_tb_in_cfg.ca_afly1_stb_incorrect_intv_test == 0))begin
        uvm_test_done.set_drain_time(this, 10ps);
        if(ca_cfg.ca_knobs.traffic_enb_ab[0]) begin
            result_a = ck_xfer_cnt_a(1);
        end
        if(ca_cfg.ca_knobs.traffic_enb_ab[1]) begin
            result_b = ck_xfer_cnt_b(1);
        end
    end
endtask : ck_eot

//------------------------------------------
task base_ca_test_c::shutdown_phase( uvm_phase phase );
    

endtask: shutdown_phase
/////////////////////////////////////////////////////////////////////////
`endif
