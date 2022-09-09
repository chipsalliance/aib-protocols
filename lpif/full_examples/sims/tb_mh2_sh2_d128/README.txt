This readme file contains procedure to run LPIF adapter IP simulation with AIB Model.


===================================
Test bench(tb_top.sv) description
===================================

				---------------	    ---------------        ---------------      -----------------	
               		TX ---->|             |	    |             |        |             |      |               |----> RX	
                   Write Flit   | LPIF-DieA   |	    | AIB_master  |        | AIB_slave   |      | LPIF-DieB     |	  Flits from Host to 
          	         	|   Host      |<----| (Gen2 Half) |<======>|  (Gen2 Half |<---->|    Device   	|	  storage
	 	        RX <----|             |	    |             |        |             |      |               |<---- TX		    
                   Read Flit    |             |	    |             |        |             |      |               |	  From storage to Host  
          	checker		---------------	    ---------------        ---------------      -----------------	  
						

1. Unzip both the files in same hierarchy 

		|			
		|--- aib-protocols-main
		|
		|--- aib-phy-hardware
		
2. Navigate to ./aib-protocols-main/lpif/full_examples/sims/tb_mh2_sh2_d128
	

Commands to run simulation :

1. To run complete simulation with AIB model execute :

	 > make run
The above command will perform clean, generate config files, compile aib model, elaborates and simulate.

2. TO run complete simulation with AIB RTL execute :
	> make run_aibrtl

The above command will perform clean, generate config files, compile aib rtl, elaborates and simulate.

To run test step by step execute following commands:

	To clean output files execute :
		
		>make clean 
	
	To generate config files:
		
		>make gen_cfg
	
	To compile aib model source files execute :
		
		>make compile
	
	To compile aib rtl source files execute :
		
		>make compile_aibrtl

	To run simulation execute:
		
		>make sim


Register map :

	  Address	  Register Name 	    Description
	======================================================================               
	0x50001000	| REG_DIE_A_CTRL_ADDR 	 | LPIF DIE A configuration register
	0x50001008	| REG_LINKUP_STS_ADDR	 | Linkup status register
	0x50001004	| REG_DIE_A_STS_ADDR	 | LPIF DIE A status register

