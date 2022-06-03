19-05-2022 - Readme.txt


This readme file contains procedure to run AXI-ST Dual simulation with AIB Model.


===================================
Test bench(top_tb.sv) description
===================================

				---------------	    ---------------        ---------------      -----------------	
               		TX ---->|             |	    |             |        |             |      |               |----> RX	
                   Random data  | AXIST-Leader|	    | AIB_master  |        | AIB_slave   |      | AXIST-Follower|	  Random data	
          	generator	|   Dual     |<---->|             |<======>|             |<---->|   Dual     	|	  checker
	 	        RX <----|             |	    |             |        |             |      |               |<---- TX		    
                   Random data  |             |	    |             |        |             |      |               |	  Random data  
          	checker		---------------	    ---------------        ---------------      -----------------	  generator
						

AXIST Dual simulation requires AIB Model(aib-phy-hardware-master.zip) and AXI Stream(aib-protocols-main.zip) 
to be obtained from github.

aib-phy-hardware-master.zip : https://github.com/chipsalliance/aib-phy-hardware

aib-protocols-main.zip : https://github.com/chipsalliance/aib-protocols

1. Unzip both the files in same hierarchy 

		|			
		|--- aib-protocols-main
		|
		|--- aib-phy-hardware-master
		
2. Navigate to ./aib-protocols-main/axi4-st/full_examples/sims/tb_mf2.1_sh1_d256_dual.
	
		tb_mf2.1_sh1_d256_dual - AXIST dual test case.

3. open makefile and set $PROJ_DIR to aib-protocols-main path.

Commands to run simulation :

To run complete simulation execute :

	 > make run
	
	The above command will perform clean, generate config files, compile, elaborate and simulate.
	
To run test step by step execute following commands:

	To clean output files execute :
		
		>make clean 
	
	To generate config files:
		
		>make gen_cfg
	
	To compile source files execute :
		
		>make compile
	
	To run simulation execute:
		
		>make sim
	
