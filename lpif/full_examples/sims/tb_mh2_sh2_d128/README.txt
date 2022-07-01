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
	

3. open makefile and set $PROJ_DIR to aib-protocols-main path.

Commands to run simulation :

To run complete simulation execute :

	 > make run
