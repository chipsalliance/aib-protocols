`ifndef _CA_TX_TB_IN_CFG_
`define _CA_TX_TB_IN_CFG_

////////////////////////////////////////////////////////////
class ca_tx_tb_in_cfg_c extends uvm_object;
 
    //------------------------------------------
    // Data Members
    //------------------------------------------
    // Whether env analysis components are used:
    bit         agent_active  = UVM_PASSIVE;
    bit         has_func_cov  = 0;
    bit [7:0]   tx_stb_intv = 0;
    bit [7:0]   tx_stb_wd_sel  = 0;
    bit [39:0]  tx_stb_bit_sel = 0;
    bit [39:0]  tx_stb_en = 0;
    bit         tx_en_stb_check   = 1;

    string           my_name = "";

    //------------------------------------------
    // UVM Factory Registration Macro
    //------------------------------------------
    `uvm_object_utils_begin(ca_tx_tb_in_cfg_c)
        `uvm_field_int(agent_active,     UVM_DEFAULT);
        `uvm_field_int(has_func_cov,     UVM_DEFAULT);
        `uvm_field_int(tx_stb_intv,      UVM_DEFAULT);
        `uvm_field_int(tx_stb_bit_sel,   UVM_DEFAULT);
        `uvm_field_int(tx_stb_wd_sel,    UVM_DEFAULT);
        `uvm_field_int(tx_stb_en,        UVM_DEFAULT);
        `uvm_field_int(tx_en_stb_check,  UVM_DEFAULT);
    `uvm_object_utils_end
 
    //------------------------------------------
    // constraints 
    //------------------------------------------

    //------------------------------------------
    // Methods
    //------------------------------------------

    // Standard UVM Methods:
    extern function new(string name = "ca_tx_tb_in_cfg");
    extern function void build_phase( uvm_phase phase );
    extern virtual function void cp( ca_tx_tb_out_pkg::ca_tx_tb_out_cfg_c  out_cfg);
    extern virtual function void configure( );
 
endclass: ca_tx_tb_in_cfg_c
////////////////////////////////////////////////////////////

function ca_tx_tb_in_cfg_c::new(string name = "ca_tx_tb_in_cfg");
    super.new(name);
endfunction
 
//
//------------------------------------------
function void ca_tx_tb_in_cfg_c::build_phase( uvm_phase phase );


endfunction: build_phase
    
//------------------------------------------
function void ca_tx_tb_in_cfg_c::cp( ca_tx_tb_out_pkg::ca_tx_tb_out_cfg_c  out_cfg);
    
    tx_stb_wd_sel  = out_cfg.tx_stb_wd_sel;
    tx_stb_bit_sel = out_cfg.tx_stb_bit_sel;
    tx_stb_en      = out_cfg.tx_stb_en;    
    tx_stb_intv    = out_cfg.tx_stb_intv;

endfunction : cp

//------------------------------------------
function void ca_tx_tb_in_cfg_c::configure( );
   

endfunction: configure 
////////////////////////////////////////////////////////////
`endif
