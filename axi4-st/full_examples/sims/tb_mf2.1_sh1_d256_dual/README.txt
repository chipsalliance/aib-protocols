15-02-2024 - Readme.txt


This readme file contains procedure to run AXI-ST F2H simulation with AIB Model and AIB rtl.


===================================
Test bench(top_tb.sv) description
===================================

 		   ---------------	    ---------------        ---------------      -----------------	
 		   |             |	    |             |        |             |      |               |	
 		   | AXIST-Leader|	    | AIB_master  |        | AIB_slave   |      | AXIST-Follower|	
          TX ----> |   		 |----->    |             |<======>|             |----->|   		|----> RX
         Random    |             |	    |             |        |             |      |               |     Random   
         pattern   |             |	    |             |        |             |      |               |     pattern  
         generator ---------------	    ---------------        ---------------      -----------------     checker
						

AXIST simulation requires AIB Model(aib-phy-hardware-master.zip) and AXI Stream(aib-protocols-main.zip) 
to be obtained from github.

aib-phy-hardware-master.zip : https://github.com/chipsalliance/aib-phy-hardware

aib-protocols-main.zip : https://github.com/chipsalliance/aib-protocols

1. Unzip both the files in same hierarchy as shown. And Rename aib-phy-hardware-master to aib-phy-hardware.

Make sure to maintain directory names as below or it will throw error during compilation. 

		|			
		|--- aib-protocols-main
		|
		|--- aib-phy-hardware
		
2. Navigate to ./aib-protocols-main/axi4-st/full_examples/sims/tb_mf2.1_sh1_d256_dual.
	
		tb_mf2.1_sh1_d256_dual - AXIST full to half seven channel dual transfer test case.


Commands to run simulation :

To run complete simulation execute :

	> make run
	
	The above command will perform clean, generate config files, configures CA module in synchronous mode(SYNC_FIFO=1), compile aib model, elaborates and simulate.

	> make run_aibrtl

	The above command will perform clean, generate config files, configures CA module in synchronous mode(SYNC_FIFO=1), compile aib rtl, elaborates and simulate.

	> make run_asyncfifo

	The above command will perform clean, generate config files, configures CA module in asynchronous mode(SYNC_FIFO=0), compile aib model, 
	elaborates and simulate.
	
To run test step by step execute following commands:

	To clean output files execute :
		
		>make clean 
	
	To generate config files:
		
		>make gen_cfg
	
	To compile aib model source files execute :
		
		>make compile
	
	To compile aib rtl source files execute :
		
		>make compile_aibrtl
	
	To compile aib model source files with CA in asynchronous mode

		>make compile_asyncfifo

	To run simulation execute:
		
		>make sim

Register map :

	  Address	  Register Name 	    	   Description
	======================================================================               
	0x50003000	| REG_AXI_CTRL_ADDR		| AXI control register 
	0x50001000	| REG_TX_PKT_CTRL_ADDR 		| L2F transmit control register
	0x50001004	| REG_RX_CKR_STS_ADDR	 	| L2F receive status register
	0x50001008	| REG_F2L_TX_PKT_CTRL_ADDR	| F2L transmit transmit control register
	0x5000100C	| REG_F2L_RX_CKR_STS_ADDR	| F2L receive status register
	0x50001010	| REG_LINKUP_STS_ADDR		| Linkup status register
	0x50004000	| REG_DOUT_FIRST1_ADDR		| L2F first data transmitted register
	0x50004100	| REG_DOUT_LAST1_ADDR		| L2F last data transmitted register
        0x50004200	| REG_DIN_FIRST1_ADDR		| L2F first data recieved register	
        0x50004300	| REG_DIN_LAST1_ADDR		| L2F last data recieved register
        0x50005000	| REG_FOLLR_DOUT_FIRST1_ADDR	| F2L first data transmitted register
        0x50005100	| REG_FOLLR_DOUT_LAST1_ADDR	| F2L last data transmitted register
        0x50005200	| REG_FOLLR_DIN_FIRST1_ADDR	| F2L first data recieved register
        0x50005300	| REG_FOLLR_DIN_LAST1_ADDR	| F2L last data recieved register
