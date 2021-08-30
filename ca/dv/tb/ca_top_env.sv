`ifndef _CA_TOP_ENV_
`define _CA_TOP_ENV_

////////////////////////////////////////////////////////////

class ca_top_env_c extends uvm_env; 

    `uvm_component_utils(ca_top_env_c) 

    //------------------------------------------
    // Data Members
    //------------------------------------------
    //
    // die A
    ca_tx_tb_out_agent_c     #(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS)) ca_die_a_tx_tb_out_agent;
    ca_tx_tb_in_agent_c      #(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS)) ca_die_a_tx_tb_in_agent;
    ca_rx_tb_in_agent_c      #(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS)) ca_die_a_rx_tb_in_agent;
    chan_delay_agent_c       #(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH))                                        chan_delay_die_a_agent[`MAX_NUM_CHANNELS];
    //
    // die B
    ca_tx_tb_out_agent_c     #(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS)) ca_die_b_tx_tb_out_agent;
    ca_tx_tb_in_agent_c      #(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS)) ca_die_b_tx_tb_in_agent;
    ca_rx_tb_in_agent_c      #(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS)) ca_die_b_rx_tb_in_agent;
    chan_delay_agent_c       #(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH))                                        chan_delay_die_b_agent[`MAX_NUM_CHANNELS];


    reset_agent_c         reset_agent;
    ca_scoreboard_c       ca_scoreboard;
    virt_seqr_c           virt_seqr;

    //------------------------------------------
    // Constraints
    //------------------------------------------
 
    //------------------------------------------
    // Methods
    //------------------------------------------
 
    // Standard UVM Methods:
    extern function new(string name = "ca_top_env", uvm_component parent = null);
    extern function void build_phase( uvm_phase phase );
    extern function void connect_phase( uvm_phase phase );
 
endclass : ca_top_env_c 
////////////////////////////////////////////////////////////

//----------------------------------------
function ca_top_env_c::new(string name = "ca_top_env", uvm_component parent = null); 
    super.new(name, parent); 
endfunction : new

//----------------------------------------
function void ca_top_env_c::build_phase( uvm_phase phase ); 

    uvm_report_info("ca_top_env_c::build_phase" ,"START env build...", UVM_LOW); 

    // tx die A --> rx die B
    // rx die A <-- tx die B 

    // die A 
    ca_die_a_tx_tb_out_agent = ca_tx_tb_out_agent_c#(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS))::type_id::create("ca_die_a_tx_tb_out_agent", this);
    ca_die_a_tx_tb_in_agent  = ca_tx_tb_in_agent_c#(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS))::type_id::create("ca_die_a_tx_tb_in_agent", this);
    ca_die_a_rx_tb_in_agent  = ca_rx_tb_in_agent_c#(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_A_NUM_CHANNELS))::type_id::create("ca_die_a_rx_tb_in_agent", this);
    for(int i = 0; i < `MAX_NUM_CHANNELS; i++) begin
        chan_delay_die_a_agent[i]   = chan_delay_agent_c#(.BUS_BIT_WIDTH(`TB_DIE_A_BUS_BIT_WIDTH))::type_id::create($sformatf("chan_delay_die_a_agent_%0d", i), this);
    end

    // die B
    ca_die_b_tx_tb_out_agent = ca_tx_tb_out_agent_c#(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS))::type_id::create("ca_die_b_tx_tb_out_agent", this);
    ca_die_b_tx_tb_in_agent  = ca_tx_tb_in_agent_c#(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS))::type_id::create("ca_die_b_tx_tb_in_agent", this);
    ca_die_b_rx_tb_in_agent  = ca_rx_tb_in_agent_c#(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH), .NUM_CHANNELS(`TB_DIE_B_NUM_CHANNELS))::type_id::create("ca_die_b_rx_tb_in_agent", this);
    for(int i = 0; i < `MAX_NUM_CHANNELS; i++) begin
        chan_delay_die_b_agent[i]   = chan_delay_agent_c#(.BUS_BIT_WIDTH(`TB_DIE_B_BUS_BIT_WIDTH))::type_id::create($sformatf("chan_delay_die_b_agent_%0d", i), this);
    end

    reset_agent = reset_agent_c::type_id::create("reset_agent", this);
        
    virt_seqr = virt_seqr_c::type_id::create("virt_seqr", this);
    
    ca_scoreboard = ca_scoreboard_c::type_id::create("ca_scoreboard", this);

    uvm_report_info("ca_top_env_c::build_phase" ,"END env build...\n", UVM_LOW); 
endfunction : build_phase

//----------------------------------------
function void ca_top_env_c::connect_phase( uvm_phase phase ); 

    uvm_report_info("ca_top_env_c::connect_phase","START Connect phase...", UVM_LOW); 

    ca_die_a_tx_tb_out_agent.set_my_name("DIE_A");
    ca_die_a_tx_tb_in_agent.set_my_name("DIE_A");

    ca_die_b_tx_tb_out_agent.set_my_name("DIE_B");
    ca_die_b_tx_tb_in_agent.set_my_name("DIE_B");

    ca_die_a_rx_tb_in_agent.set_my_name("DIE_A");
    ca_die_b_rx_tb_in_agent.set_my_name("DIE_B");

    reset_agent.aport.connect(ca_scoreboard.ca_reset_export);
    // tb tx >>> rtl 
    ca_die_a_tx_tb_in_agent.aport.connect(ca_scoreboard.tx_tb_in_export);
    ca_die_a_tx_tb_out_agent.aport.connect(ca_scoreboard.ca_tx_tb_out_export);
    ca_die_b_tx_tb_in_agent.aport.connect(ca_scoreboard.tx_tb_in_export);
    ca_die_b_tx_tb_out_agent.aport.connect(ca_scoreboard.ca_tx_tb_out_export);
    // tb rx <<< rtl 
    ca_die_b_rx_tb_in_agent.aport.connect(ca_scoreboard.rx_tb_in_export);
    ca_die_a_rx_tb_in_agent.aport.connect(ca_scoreboard.rx_tb_in_export);

    virt_seqr.reset_seqr               = reset_agent.reset_seqr;
    virt_seqr.ca_die_a_tx_tb_out_seqr  = ca_die_a_tx_tb_out_agent.seqr;
    virt_seqr.ca_die_b_tx_tb_out_seqr  = ca_die_b_tx_tb_out_agent.seqr;

    uvm_report_info("ca_top_env_c::connect_phase","END Connect phase...\n", UVM_LOW); 

endfunction : connect_phase
/////////////////////////////////////////////////////////////////////////////////////
`endif
