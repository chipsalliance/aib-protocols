27-09-2023 - Readme.txt


This readme file contains procedure to run AXI-ST simulation with GPIO PHY.


===================================
Test bench(top_tb.sv) description
===================================

 		      ---------------        -----------------	
 		      |             |        |               |	
 		      | AXIST-Leader|  GPIO  | AXIST-Follower|	
 TX ----> |   		      |<======>|   		        |----> RX
Random    |             |        |               |     Random   
pattern   |             |        |               |     pattern  
generator ---------------        -----------------     checker
						

AXIST simulation requires AXI Stream(aib-protocols-main.zip) to be obtained from github.

aib-protocols-main.zip : https://github.com/chipsalliance/aib-protocols

1. Unzip the file - aib-protocols-main.zip as aib-protocols-main
		
2. Navigate to ./aib-protocols-main/axi4-st/full_examples_gpio/sims/tb_40bit_gpio_d256.
	
		tb_40bit_gpio_d256 - AXIST 256 bits with GPIO phy.


Commands to run simulation :

To run complete simulation execute :

	 > make run
	
	The above command will perform clean, generate config files,  elaborates and simulate.


	
To run test step by step execute following commands:

	To clean output files execute :
		
		>make clean 
	
	To generate config files:
		
		>make gen_cfg
	
	To compile  source files execute :
		
		>make compile
	
	To run simulation execute:
		
		>make sim


Changing AXI data width:

1. Edit axist_ll.cfg
	a.open aib-protocols-main/axi4-st/full_examples_gpio/sims/tb_40bit_gpio_d256/axist_ll.cfg file .
	b.update 'output user_tdata' field to target datawidth(in multiples of 64).

2. Edit AXI_CHNL_NUM parameter
	a. open aib-protocols-main/axi4-st/full_examples_gpio/sims/tb_40bit_gpio_d256/top_tb.v
	b. Edit AXI_CHNL_NUM in multiples of 64 bits. Example : For 256 datawidth AXI_CHN_NUM = 4.

3. Run 'make run' command.

Register map :

	  Address	  Register Name 	    	   Description
	======================================================================               
	0x50001000	|  REG_TX_PKT_CTRL_ADDR	     | AXIST transmit control register
	0x50001004	|  REG_RX_CKR_STS_ADDR	     | AXIST receive status register 
	0x50001008	|  REG_LINKUP_STS_ADDR	     | Linkup status register
	0x50003000	|  REG_AXI_CTRL_ADDR	     | AXI control register
	0x50004000	|  REG_DOUT_FIRST1_ADDR	     | First data transmitted register
	0x50004100	|  REG_DOUT_LAST1_ADDR	     | Last data transmitted register
	0x50004300	|  REG_DIN_LAST1_ADDR	     | Last data received register
