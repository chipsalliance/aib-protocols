27-09-2023 - README.txt


This readme file contains procedure to run AXI-MM simulation with gpio phy .


===================================
Test bench(top_tb.sv) description
===================================

		          ---------------	    -----------------	      ---------------
	AXIMM  ---->|             |	    |               |<----->|     	      | 
  Write       | AXIMM-Leader|	    | AXIMM-Follower|	      |   AXIMM     |
	            |       	    |<--->|               |	      | to memory   |
	AXIMM  <----|             |	    |               |<----->|             |
   Read  	    |             |	    |               |	      |             |
		          ---------------	    -----------------	      ---------------
						

AXIMM with gpio phy simulation requires AXI Memory mapped(aib-protocols-main.zip) to be obtained from github.

aib-protocols-main.zip : https://github.com/chipsalliance/aib-protocols

1. Unzip the file - aib-protocols-main.zip as aib-protocols-main

2. Navigate to ./aib-protocols-main/axi4-mm/full_examples_gpio/sims/tb_20bit_gpio_d128.
	
		tb_mh2.1_sh1_d128_gpiophy - AXIMM test case with 128 bits datawidth and gpio phy loopback.


Commands to run simulation :

To run complete simulation execute :

	 > make run

	The above commands will perform clean, generate config files, compile, elaborate and simulate.
	
To run test step by step execute following commands:

	To clean output files, execute :
		
		>make clean 
	
	To generate config files:
		
		>make gen_cfg
	
	To compile source files execute :
		
		>make compile
	
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
