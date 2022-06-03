set strb_loc = 1
BWIDTH=40
k=0
for ((i=0; i<7; i++))
do
	for ((j=0; j<40; j++))
	do
			if [ $j -eq 0 ] && [ $i -eq 0 ] 
			then
				printf " "
			elif [ $j -eq 1 ] && [ $i -eq 0 ] 
			then
				t=`expr ${i} \* ${BWIDTH}`
				s=`expr ${t} \+ ${j}`
				sed -i "s/ assign tx_phy_preflop_${i} \[   ${j}\]\ = tx_st_data          \[   ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}]=  tx_stb_userbit 	  ;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
			elif [ $j -eq 1 ] && [ $i -lt 3 ]
			then
				t=`expr ${i} \* ${BWIDTH}`
				s=`expr ${t} \+ ${j}`
				sed -i "s/ assign tx_phy_preflop_${i} \[   ${j}\]\ = tx_st_data          \[  ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}]=  tx_stb_userbit 	  ;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
			elif [ $j -eq 1 ]
			then
				t=`expr ${i} \* ${BWIDTH}`
				s=`expr ${t} \+ ${j}`
				sed -i "s/ assign tx_phy_preflop_${i} \[   ${j}\]\ = tx_st_data          \[ ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}]=  tx_stb_userbit 	    ;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
			elif [ $j -eq 39 ] && [ $i -lt 2 ]
			then
				t=`expr ${i} \* ${j}`
				s=`expr ${t} \+ 38 \+ ${i}`
				sed -i "s/ assign tx_phy_preflop_${i} \[  ${j}\]\ = tx_st_data          \[  ${s}\] ;/ assign tx_phy_preflop_${i} [   ${j}]=  tx_mrk_userbit 	  ;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
			elif [ $j -eq 39 ] && [ $i -eq 6 ]
			then
				sed -i "s/ assign tx_phy_preflop_${i} \[  ${j}\]\ = 1'b0                       ;/ assign tx_phy_preflop_${i} [   ${j}]=  tx_mrk_userbit 	;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
				# sed -i "s/ assign tx_phy_preflop_${i} \[  ${j}\]\ = 1'b0                       ;/ assign tx_phy_preflop_${i} [   ${j}]=  tx_mrk_userbit 		;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
			elif [ $j -eq 39 ]
			then
				t=`expr ${i} \* ${j}`
				s=`expr ${t} \+ 38 \+ ${i}`
				sed -i "s/ assign tx_phy_preflop_${i} \[  ${j}\]\ = tx_st_data          \[ ${s}\] ;/ assign tx_phy_preflop_${i} [   ${j}]=  tx_mrk_userbit 	;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
			elif [ $i -eq 0 ] && [ $j -lt 10 ]
			then
					t=`expr ${j} \- 1`
					sed -i "s/ assign tx_phy_preflop_${i} \[   ${j}\]\ = tx_st_data          \[   ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}] =  tx_st_data       [  ${k}] ;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
					k=`expr ${k} \+ 1`
			elif [ $i -eq 0 ] && [ $j -eq 10 ]
			then
					t=`expr ${j} \- 1`
					sed -i "s/ assign tx_phy_preflop_${i} \[  ${j}\]\ = tx_st_data          \[   ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}] =  tx_st_data       [  ${k}] ;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
					k=`expr ${k} \+ 1`
			elif [ $i -eq 1 ] && [ $j -lt 10 ]
			then
					t=`expr ${j} \+ 39 `
					sed -i "s/ assign tx_phy_preflop_${i} \[   ${j}\]\ = tx_st_data          \[  ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}] =  tx_st_data       [  ${k}] ;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
					k=`expr ${k} \+ 1`
			elif [ $i -eq 1 ] && [ $j -gt 9 ]
			then
					t=`expr ${j} \+ 39 `
					sed -i "s/ assign tx_phy_preflop_${i} \[  ${j}\]\ = tx_st_data          \[  ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}] =  tx_st_data       [  ${k}] ;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
					k=`expr ${k} \+ 1`
			elif [ $i -eq 2 ] && [ $j -lt 10 ]
			then
					t=`expr ${j} \+ 79 `
					sed -i "s/ assign tx_phy_preflop_${i} \[   ${j}\]\ = tx_st_data          \[  ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}] =  tx_st_data       [  ${k}] ;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
					k=`expr ${k} \+ 1`
			elif [ $i -eq 2 ] && [ $j -lt 21 ]
			then
					t=`expr ${j} \+ 79 `
					sed -i "s/ assign tx_phy_preflop_${i} \[  ${j}\]\ = tx_st_data          \[  ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}] =  tx_st_data       [  ${k}] ;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
					k=`expr ${k} \+ 1`
			elif [ $i -eq 2 ] && [ $j -gt 20 ]
			then
					t=`expr ${j} \+ 79 `
					sed -i "s/ assign tx_phy_preflop_${i} \[  ${j}\]\ = tx_st_data          \[ ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}] =  tx_st_data       [  ${k}] ;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
					k=`expr ${k} \+ 1`
			elif [ $i -gt 2 ] && [ $j -lt 10 ] && [ $i -lt 6 ]
			then	
					s=`expr ${i} \* 40 \- 1`
					t=`expr ${j} \+ ${s} `
					sed -i "s/ assign tx_phy_preflop_${i} \[   ${j}\]\ = tx_st_data          \[ ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}] =  tx_st_data       [ ${k}] ;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
					k=`expr ${k} \+ 1`
			elif [ $i -gt 2 ] && [ $j -gt 9 ] && [ $i -lt 6 ]
			then
					# t=`expr ${j} \+ 119 `
					s=`expr ${i} \* 40 \- 1`
					t=`expr ${j} \+ ${s} `
					sed -i "s/ assign tx_phy_preflop_${i} \[  ${j}\]\ = tx_st_data          \[ ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}] =  tx_st_data       [ ${k}] ;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
					k=`expr ${k} \+ 1`
			elif [ $i -eq 6 ] && [ $j -lt 10 ]
			then
					t=`expr ${j} \+ 239 `
					sed -i "s/ assign tx_phy_preflop_${i} \[   ${j}\]\ = tx_st_data          \[ ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}] =  tx_st_data       [ ${k}] ;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
					k=`expr ${k} \+ 1`

			elif [ $i -eq 6 ] && [ $j -lt 17 ]
			then
					t=`expr ${j} \+ 239 `
					sed -i "s/ assign tx_phy_preflop_${i} \[  ${j}\]\ = tx_st_data          \[ ${t}\] ;/ assign tx_phy_preflop_${i} [  ${j}] =  tx_st_data       [ ${k}] ;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
					k=`expr ${k} \+ 1`
			elif [ $j -gt 16 ] && [ $i -eq 6 ]
			then
				if [ $j -lt 30 ]
				then
					t=`expr ${j} \+ 239 `
					sed -i "s/ assign tx_phy_preflop_${i} \[.*${j}\]\ = 1'b0                       ;/ assign tx_phy_preflop_${i} [  ${j}]=   tx_st_data       [ ${k}] ;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
					k=`expr ${k} \+ 1`
				fi
			else
					t=`expr ${j} \- 1`
					sed -i "s/ assign tx_phy_preflop_${i} \[  ${j}\]\ = tx_st_data          \[  ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}] =  tx_st_data       [  ${k}] ;/g" ./axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
					k=`expr ${k} \+ 1`
			
			fi			
	done
done

