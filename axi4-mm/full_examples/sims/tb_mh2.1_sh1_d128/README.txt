19-05-2022 - Readme.txt


This readme file contains procedure to run AXI-MM simulation with AIB Model.


===================================
Test bench(top_tb.sv) description
===================================

				---------------	    ---------------        ---------------      -----------------	  ---------------
	AXIMM  ---->|             |	    |             |        |             |      |               |---->|     		| 
    Write       | AXIMM-Leader|	    | AIB_master  |		   | AIB_slave   |      | AXIMM-Follower|	  |   AXIMM     |
	        	|       	  |<--->|             |<======>|             |<---->|           	|	  | to memory   |
	AXIMM  <----|             |	    |             |        |             |      |               |<----|             |
    Read  		|             |	    |             |        |             |      |               |	  |             |
				---------------	    ---------------        ---------------      -----------------	  ---------------
						

AXIMM simulation requires AIB Model(aib-phy-hardware-master.zip) and AXI Memory mapped(aib-protocols-main.zip) 
to be obtained from github.

aib-phy-hardware-master.zip : https://github.com/chipsalliance/aib-phy-hardware

aib-protocols-main.zip : https://github.com/chipsalliance/aib-protocols

1. Unzip both the files in same hierarchy as shown. And Rename aib-phy-hardware-master to aib-phy-hardware.

Make sure to maintain directory names as below or it will throw error during compilation. 

		|			
		|--- aib-protocols-main
		|
		|--- aib-phy-hardware
		
2. Navigate to ./aib-protocols-main/axi4-mm/full_examples/sims/tb_mh2.1_sh1_d128.
	
		tb_mh2.1_sh1_d128 - AXIMM test case.


Commands to run simulation :

To run complete simulation execute :

	 > make run
	
	The above command will perform clean, generate config files, compile, elaborate and simulate.
	
To run test step by step execute following commands:

	To clean output files, execute :
		
		>make clean 
	
	To generate config files:
		
		>make gen_cfg
	
	To compile source files, execute :
		
		>make compile
	
	To run simulation, execute:
		
		>make sim
	