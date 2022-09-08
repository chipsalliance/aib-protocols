08-09-2022 - README.txt


This readme file contains procedure to run AXI-MM simulation with AIB Model.


===================================
Test bench(top_tb.sv) description
===================================

		    ---------------	    ---------------        ---------------      -----------------	  ---------------
	AXIMM  ---->|             |	    |             |        |             |      |               |---->    |     	| 
        Write       | AXIMM-Leader|	    | AIB_master  |	   | AIB_slave   |      | AXIMM-Follower|	  |   AXIMM     |
	            |       	  |<------> |             |<======>|             |<---->|           	|	  | to memory   |
	AXIMM  <----|             |	    |             |        |             |      |               |<----    |             |
        Read  	    |             |	    |             |        |             |      |               |	  |             |
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
		
2. Navigate to ./aib-protocols-main/axi4-mm/full_examples/sims/tb_mh2.1_sh1_d64.
	
		tb_mh2.1_sh1_d128 - AXIMM test case.


Commands to run simulation :

To run complete simulation with AIB2v1.0/MAIBv1.0 execute :

	 > make run

To run complete simulation with AIB2v1.1/MAIBv1.1 execute :

	 > make run_aibrtl
	
	The above command will perform clean, generate config files, compile, elaborate and simulate.
	
To run test step by step execute following commands:

	To clean output files, execute :
		
		>make clean 
	
	To generate config files:
		
		>make gen_cfg
	
	To compile source files for AIB2v1.0/MAIBv1.0, execute :
		
		>make compile
	
	To compile source files for AIB2v1.1/MAIBv1.1, execute :
		
		>make compile_aibrtl

	
	To run simulation, execute:
		
		>make sim

Register map :

	  Address	  Register Name 	    Description
	======================================================================               
	0x50001000	| REG_MM_WR_CFG_ADDR	 | AXIMM write configuration register 
	0x50001010	| REG_MM_RD_CFG_ADDR	 | AXIMM read configuration register	
	0x50001004	| REG_MM_WR_RD_ADDR	 | AXIMM write/Read address register
	0x50001008	| REG_MM_BUS_STS_ADDR	 | AXIMM bus status register
	0x5000100C	| REG_LINKUP_STS_ADDR	 | Linkup status register
	0x50004000	| REG_DOUT_FIRST1_ADDR	 | First data written to memory 
	0x50004010	| REG_DOUT_LAST1_ADDR	 | Last data written to memory
	0x50004020	| REG_DIN_FIRST1_ADDR	 | First data read from memory
	0x50004030	| REG_DIN_LAST1_ADDR	 | Last data read from memory	
