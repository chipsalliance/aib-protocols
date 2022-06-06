#!/bin/sh -f

for ((i=0; i<7; i++))
do
for ((j=0; j<40; j++))
	do
		x=`expr 2 \* ${i} \+ 1`
	#	if [ ${j} -gt ${x} ]
	#	then
		n=`expr 39 \- ${x}`
	#	fi
	       # printf "n=%x" $n	
	if [ $j -eq 0 ] && [ $i -eq 0 ]
	then
		printf " "
	elif [ $j -lt 10 ] && [ $i -eq 0 ] 
	then
		k=`expr ${j} \+ 1`
		#printf "j=%x k= %x" $j $k
		#sed -i "s/ assign tx_phy_preflop_${i} \[   ${j}\]\ = tx_st_data          \[   ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}]=  tx_stb_userbit 	  ;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
		sed -i "s/ = rx_phy_postflop_${i} \[   ${j}\]\;/ = rx_phy_postflop_${i} \[\ ${k}\]\;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_half_slave_concat.sv
	elif [ $j -lt 38 ] && [ $i -eq 0 ]
	then	
		k=`expr ${j} \+ 1`
		#printf "j=%x k= %x" $j $k
		#sed -i "s/ assign tx_phy_preflop_${i} \[   ${j}\]\ = tx_st_data          \[   ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}]=  tx_stb_userbit 	  ;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
		sed -i "s/ = rx_phy_postflop_${i} \[  ${j}\]\;/ = rx_phy_postflop_${i} \[\ ${k}\]\;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_half_slave_concat.sv
	elif [ $j -eq 38 ] && [ $i -eq 0 ]
	then 
		s=`expr ${j} \- 38`
		l=`expr ${i} \+ 1`
		sed -i "s/ = rx_phy_postflop_${i} \[  ${j}\]\;/ = rx_phy_postflop_${l} \[\ ${s}\]\;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_half_slave_concat.sv

	elif [ $j -eq 39 ] && [ $i -eq 0 ]
	then 
		s=`expr ${j} \- 37`
		l=`expr ${i} \+ 1`
		sed -i "s/ = rx_phy_postflop_${i} \[  ${j}\]\;/ = rx_phy_postflop_${l} \[\ ${s}\]\;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_half_slave_concat.sv
	elif [ $j -lt 10 ] && [ $i -gt 0 ] && [ $i -lt 7 ]
	then
		k=`expr ${i} \* 2`
		l=`expr ${k} \+ 1 \+ ${j}`
		k=`expr ${j} \+ 1`
		#printf "j=%x k= %x" $j $k
		#sed -i "s/ assign tx_phy_preflop_${i} \[   ${j}\]\ = tx_st_data          \[   ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}]=  tx_stb_userbit 	  ;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
		sed -i "s/ = rx_phy_postflop_${i} \[   ${j}\]\;/ = rx_phy_postflop_${i} \[\ ${l}\]\;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_half_slave_concat.sv
	
	elif [ $j -lt ${n} ] && [ $i -gt 0 ] && [ $i -lt 7 ]
	then	
		k=`expr ${i} \* 2`
		l=`expr ${k} \+ 1 \+ ${j}`
		#printf "j=%x k= %x" $j $k
		#sed -i "s/ assign tx_phy_preflop_${i} \[   ${j}\]\ = tx_st_data          \[   ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}]=  tx_stb_userbit 	  ;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
		sed -i "s/ = rx_phy_postflop_${i} \[  ${j}\]\;/ = rx_phy_postflop_${i} \[\ ${l}\]\;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_half_slave_concat.sv
	
	elif [ $j -eq ${n} ] && [ $i -gt 0 ] && [ $i -lt 7 ]
	then 
		s=`expr ${j} \- ${n}`
		l=`expr ${i} \+ 1`
		sed -i "s/ = rx_phy_postflop_${i} \[  ${j}\]\;/ = rx_phy_postflop_${l} \[\ ${s}\]\;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_half_slave_concat.sv
	
	elif [ $j -lt 40 ] && [ $i -gt 0 ] && [ $i -lt 7 ]
	then 
		s=`expr ${j} \- ${n}`
		m=`expr ${s} \+ 1`
		l=`expr ${i} \+ 1`
		sed -i "s/ = rx_phy_postflop_${i} \[  ${j}\]\;/ = rx_phy_postflop_${l} \[\ ${m}\]\;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_half_slave_concat.sv
	fi
done
done

for ((i=0; i<7; i++))
do
for ((j=40; j<80; j++))
	do
		x=`expr 2 \* ${i} \+ 1`
	#	if [ ${j} -gt ${x} ]
	#	then
		n=`expr 79 \- ${x}`
	#	fi
	       #printf "n=%x" $n	
	if [ $j -eq 40 ] && [ $i -eq 0 ]
	then
		printf " "
	elif [ $j -lt 50 ] && [ $i -eq 0 ] 
	then
		k=`expr ${j} \+ 1`
		#printf "j=%x k= %x" $j $k
		#sed -i "s/ assign tx_phy_preflop_${i} \[   ${j}\]\ = tx_st_data          \[   ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}]=  tx_stb_userbit 	  ;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
		sed -i "s/ = rx_phy_postflop_${i} \[  ${j}\]\;/ = rx_phy_postflop_${i} \[\ ${k}\]\;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_half_slave_concat.sv
	elif [ $j -lt 78 ] && [ $i -eq 0 ]
	then	
		k=`expr ${j} \+ 1`
		#printf "j=%x k= %x" $j $k
		#sed -i "s/ assign tx_phy_preflop_${i} \[   ${j}\]\ = tx_st_data          \[   ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}]=  tx_stb_userbit 	  ;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
		sed -i "s/ = rx_phy_postflop_${i} \[  ${j}\]\;/ = rx_phy_postflop_${i} \[\ ${k}\]\;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_half_slave_concat.sv
	elif [ $j -eq 78 ] && [ $i -eq 0 ]
	then 
		s=`expr ${j} \- 38`
		l=`expr ${i} \+ 1`
		sed -i "s/ = rx_phy_postflop_${i} \[  ${j}\]\;/ = rx_phy_postflop_${l} \[\ ${s}\]\;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_half_slave_concat.sv

	elif [ $j -eq 79 ] && [ $i -eq 0 ]
	then 
		s=`expr ${j} \- 37`
		l=`expr ${i} \+ 1`
		sed -i "s/ = rx_phy_postflop_${i} \[  ${j}\]\;/ = rx_phy_postflop_${l} \[\ ${s}\]\;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_half_slave_concat.sv
	elif [ $j -lt 50 ] && [ $i -gt 0 ] && [ $i -lt 7 ]
	then
		k=`expr ${i} \* 2`
		l=`expr ${k} \+ 1 \+ ${j}`
		k=`expr ${j} \+ 1`
		#printf "j=%x k= %x" $j $k
		#sed -i "s/ assign tx_phy_preflop_${i} \[   ${j}\]\ = tx_st_data          \[   ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}]=  tx_stb_userbit 	  ;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
		sed -i "s/ = rx_phy_postflop_${i} \[  ${j}\]\;/ = rx_phy_postflop_${i} \[\ ${l}\]\;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_half_slave_concat.sv
	
	elif [ $j -lt ${n} ] && [ $i -gt 0 ] && [ $i -lt 7 ]
	then	
		k=`expr ${i} \* 2`
		l=`expr ${k} \+ 1 \+ ${j}`
		#printf "j=%x k= %x" $j $k
		#sed -i "s/ assign tx_phy_preflop_${i} \[   ${j}\]\ = tx_st_data          \[   ${t}\] ;/ assign tx_phy_preflop_${i} [   ${j}]=  tx_stb_userbit 	  ;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_full_master_concat.sv
		sed -i "s/ = rx_phy_postflop_${i} \[  ${j}\]\;/ = rx_phy_postflop_${i} \[\ ${l}\]\;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_half_slave_concat.sv
	
	elif [ $j -eq ${n} ] && [ $i -gt 0 ] && [ $i -lt 7 ]
	then 
		s=`expr ${j} \- ${n} \+ 40`
		l=`expr ${i} \+ 1`
		sed -i "s/ = rx_phy_postflop_${i} \[  ${j}\]\;/ = rx_phy_postflop_${l} \[\ ${s}\]\;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_half_slave_concat.sv
	
	elif [ $j -lt 80 ] && [ $i -gt 0 ] && [ $i -lt 7 ]
	then 
		s=`expr ${j} \- ${n} \+ 40`
		m=`expr ${s} \+ 1`
		l=`expr ${i} \+ 1`
		sed -i "s/ = rx_phy_postflop_${i} \[  ${j}\]\;/ = rx_phy_postflop_${l} \[\ ${m}\]\;/g" axi_st_d256_multichannel/axi_st_d256_multichannel_half_slave_concat.sv
	fi
done
done
