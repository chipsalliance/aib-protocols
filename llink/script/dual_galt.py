############################################################
##
##        Copyright (C) 2021 Eximius Design
##
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##     http:##www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
############################################################

from argparse import ArgumentParser
import os
import re
from shutil import copyfile
from shutil import rmtree
import subprocess
import sys
import math
import pprint
from collections import namedtuple
from operator import itemgetter



import llink_dv_packet_postproc
import global_struct

gen_llink_concat_credit     = global_struct.gen_llink_concat_credit
gen_llink_concat_fifoname   = global_struct.gen_llink_concat_fifoname
gen_llink_concat_ovrd       = global_struct.gen_llink_concat_ovrd
gen_llink_concat_pushbit    = global_struct.gen_llink_concat_pushbit
gen_llink_debug_status      = global_struct.gen_llink_debug_status
gen_llink_user_enable       = global_struct.gen_llink_user_enable
gen_llink_user_fifoname     = global_struct.gen_llink_user_fifoname
gen_llink_user_ready        = global_struct.gen_llink_user_ready
gen_llink_user_valid        = global_struct.gen_llink_user_valid
print_verilog_assign        = global_struct.print_verilog_assign
print_verilog_io_line       = global_struct.print_verilog_io_line
print_verilog_logic_line    = global_struct.print_verilog_logic_line
print_verilog_regnb         = global_struct.print_verilog_regnb
sprint_verilog_assign       = global_struct.sprint_verilog_assign
sprint_verilog_case         = global_struct.sprint_verilog_case
sprint_verilog_logic_line   = global_struct.sprint_verilog_logic_line









##########################################################################################
## covert_rate_gen2_as_gen1
## Simple function to convert the Gen2 specified TX/RX Rates into the Gen1 version
## when using GALT functionality.

def covert_rate_gen2_as_gen1(gen2_rate):
    if gen2_rate == 'Full' :
        print("ERROR: TX or RX_RATE cannot be Full for Gen2 as Gen1 operation")
        sys.exit(1)
    elif gen2_rate == 'Half' :
        gen1_rate = 'Full'
    elif gen2_rate == 'Quarter' :
        gen1_rate = 'Half'
    return gen1_rate

## covert_rate_gen2_as_gen1
##########################################################################################

##########################################################################################
## calculate_bit_loc_galt
## Calculate the bit locations for GALT (Gen2 and Gen1) feature.

def calculate_bit_loc_galt(use_master, configuration):

    # For this calculation, we assign a single vector which is a linear range of TOTAL_[T|R]X_USABLE_RAWDATA_GEN[2|1]
    # The later processes will split this into per channel
    # Gen1 signals are assigned first and MAIN SIGWID are reduced to account for these being in "GALT" then
    # the remaining Gen2 signals are assigned

    if use_master:
      localdir = "output"
      otherdir = "input"
    else:
      localdir = "input"
      otherdir = "output"

    local_gen2_index_wid    = 0 ;
    local_gen2_index_lsb    = 0 ;
    local_gen2_llink_lsb    = 0 ;
    tx_print_gen2_index_lsb = 0 ;
    rx_print_gen2_index_lsb = 0 ;
    tx_local_gen2_index_lsb = 0 ;
    rx_local_gen2_index_lsb = 0 ;

    local_gen1_index_wid    = 0 ;
    local_gen1_index_lsb    = 0 ;
    local_gen1_llink_lsb    = 0 ;
    tx_print_gen1_index_lsb = 0 ;
    rx_print_gen1_index_lsb = 0 ;
    tx_local_gen1_index_lsb = 0 ;
    rx_local_gen1_index_lsb = 0 ;


    main_list=list()
    galt_list=list()

    #signal index (-1 if scaler)  llindex llname

    main_index_lsb = 0
    galt_index_lsb = 0

    #pprint.pprint (configuration)

    ## List out Main Signals
    for llink in configuration['LL_LIST']:
        if llink['DIR'] == localdir:
            if llink['HASVALID']:
                main_list, main_index_lsb = check_for_aib_overhead_signal_galt(configuration, main_list, main_index_lsb, use_master, "MAIN")

                sig_element=dict()
                if llink['NAME'] == "ST_S2M":
                    sig_element['SIG_NAME']  = gen_llink_concat_pushbit (llink['NAME'],localdir)
                else:
                    sig_element['SIG_NAME']  = gen_llink_concat_pushbit (llink['NAME'],otherdir)
                sig_element['SIG_INDEX'] = -1 ## indicate a scaler
                sig_element['LL_INDEX']  = -1 ## indicate not part of LLink Data
                sig_element['LL_NAME']   = llink['NAME'] ## unused, but lets be consistent
                sig_element['AIB_INDEX'] = main_index_lsb
                if llink['NAME'] == "ST_S2M":
                    sig_element['COMMENT']   = "{}".format ( gen_llink_concat_pushbit (llink['NAME'],localdir))
                else:
                    sig_element['COMMENT']   = "{}".format ( gen_llink_concat_pushbit (llink['NAME'],otherdir))
                main_list.append(sig_element)
                main_index_lsb += 1

                main_list, main_index_lsb = check_for_aib_overhead_signal_galt(configuration, main_list, main_index_lsb, use_master, "MAIN")

            for sig in llink['SIGNALLIST_MAIN']:
                if sig['TYPE'] == 'valid' or sig['TYPE'] == 'ready':
                    continue

                sig_index_lsb   = sig['LSB']
                sig_llindex_lsb = sig['LLINDEX_MAIN_LSB']
                for each_bit in list (range (0,  sig['SIGWID'])):
                    main_list, main_index_lsb = check_for_aib_overhead_signal_galt(configuration, main_list, main_index_lsb, use_master, "MAIN")

                    sig_element=dict()
                    sig_element['SIG_NAME']  = sig['NAME']
                    sig_element['SIG_INDEX'] = sig_index_lsb
                    sig_element['LL_INDEX']  = sig_llindex_lsb
                    sig_element['LL_NAME']   = llink['NAME']
                    sig_element['AIB_INDEX'] = main_index_lsb
                    sig_element['COMMENT']   = "{}{}".format (sig['NAME'], ("["+str(sig_index_lsb)+"]") if sig_index_lsb != -1 else "")
                    main_list.append(sig_element)
                    main_index_lsb += 1
                    sig_index_lsb += 1
                    sig_llindex_lsb += 1

                    main_list, main_index_lsb = check_for_aib_overhead_signal_galt(configuration, main_list, main_index_lsb, use_master, "MAIN")
        else:
            if llink['HASREADY']:
                main_list, main_index_lsb = check_for_aib_overhead_signal_galt(configuration, main_list, main_index_lsb, use_master, "MAIN")

                sig_element=dict()
                if llink['NAME'] == "ST_S2M":
                    sig_element['SIG_NAME']  = gen_llink_concat_credit (llink['NAME'],localdir)
                else:
                    sig_element['SIG_NAME']  = gen_llink_concat_credit (llink['NAME'],otherdir)
                sig_element['SIG_INDEX'] = -1 ## indicate a scaler
                sig_element['LL_INDEX']  = -1 ## indicate not part of LLink Data
                sig_element['LL_NAME']   = llink['NAME'] ## unused, but lets be consistent
                sig_element['AIB_INDEX'] = main_index_lsb
                if llink['NAME'] == "ST_S2M":
                    sig_element['COMMENT']   = "{}".format ( gen_llink_concat_credit (llink['NAME'],localdir))
                else:
                    sig_element['COMMENT']   = "{}".format ( gen_llink_concat_credit (llink['NAME'],otherdir))
                main_list.append(sig_element)
                main_index_lsb += 1

                main_list, main_index_lsb = check_for_aib_overhead_signal_galt(configuration, main_list, main_index_lsb, use_master, "MAIN")

    sig_index_lsb   = 0
    for each_bit in list (range (0,  configuration['TOTAL_TX_ROUNDUP_BIT_MAIN'] if use_master else configuration['TOTAL_RX_ROUNDUP_BIT_MAIN'])):
        main_list, main_index_lsb = check_for_aib_overhead_signal_galt(configuration, main_list, main_index_lsb, use_master, "MAIN")

        sig_element=dict()
        if global_struct.USE_SPARE_VECTOR:
            sig_element['SIG_NAME']  = "spare_"+localdir
            sig_element['SIG_INDEX'] = sig_index_lsb
            sig_element['LL_INDEX']  = -1
            sig_element['LL_NAME']   = "NO_LLDATA"
            sig_element['AIB_INDEX'] = main_index_lsb
            sig_element['COMMENT']   = "SPARE"
        else:
            sig_element['SIG_NAME']  = "1'b0"
            sig_element['SIG_INDEX'] = -1
            sig_element['LL_INDEX']  = -1
            sig_element['LL_NAME']   = "NO_LLDATA"
            sig_element['AIB_INDEX'] = main_index_lsb
            sig_element['COMMENT']   = "SPARE"
        main_list.append(sig_element)
        main_index_lsb += 1
        sig_index_lsb += 1

        main_list, main_index_lsb = check_for_aib_overhead_signal_galt(configuration, main_list, main_index_lsb, use_master, "MAIN")


    ## List out Galt Signals
    ## Note there are subtle differences with MAIN version, specifically the GALT uses the Main LLINK offsets
    for llink in configuration['LL_LIST']:
        if llink['DIR'] == localdir:
            if llink['HASVALID']:
                galt_list, galt_index_lsb = check_for_aib_overhead_signal_galt(configuration, galt_list, galt_index_lsb, use_master, "GALT")

                sig_element=dict()
                if llink['NAME'] == "ST_S2M":
                    sig_element['SIG_NAME']  = gen_llink_concat_pushbit (llink['NAME'],localdir)
                else:
                    sig_element['SIG_NAME']  = gen_llink_concat_pushbit (llink['NAME'],otherdir)
                sig_element['SIG_INDEX'] = -1 ## indicate a scaler
                sig_element['LL_INDEX']  = -1 ## indicate not part of LLink Data
                sig_element['LL_NAME']   = llink['NAME'] ## unused, but lets be consistent
                sig_element['AIB_INDEX'] = galt_index_lsb
                if llink['NAME'] == "ST_S2M":
                    sig_element['COMMENT']   = "{}".format ( gen_llink_concat_pushbit (llink['NAME'],localdir))
                else:
                    sig_element['COMMENT']   = "{}".format ( gen_llink_concat_pushbit (llink['NAME'],otherdir))
                galt_list.append(sig_element)
                galt_index_lsb += 1

                galt_list, galt_index_lsb = check_for_aib_overhead_signal_galt(configuration, galt_list, galt_index_lsb, use_master, "GALT")

            for sig in llink['SIGNALLIST_GALT']:
                for sig2 in llink['SIGNALLIST_MAIN']:
                    if sig['NAME'] == sig2['NAME']:
                        if sig['TYPE'] == 'valid' or sig['TYPE'] == 'ready':
                            continue
                        sig_index_lsb   = sig['LSB']
                        sig_llindex_lsb = sig2['LLINDEX_MAIN_LSB']
                        for each_bit in list (range (0,  sig['SIGWID'])):
                            galt_list, galt_index_lsb = check_for_aib_overhead_signal_galt(configuration, galt_list, galt_index_lsb, use_master, "GALT")

                            sig_element=dict()
                            sig_element['SIG_NAME']  = sig['NAME']
                            sig_element['SIG_INDEX'] = sig_index_lsb
                            sig_element['LL_INDEX']  = sig_llindex_lsb
                            sig_element['LL_NAME']   = llink['NAME']
                            sig_element['AIB_INDEX'] = galt_index_lsb
                            sig_element['COMMENT']   = "{}{}".format (sig['NAME'], ("["+str(sig_index_lsb)+"]") if sig_index_lsb != -1 else "")
                            galt_list.append(sig_element)
                            galt_index_lsb += 1
                            sig_index_lsb += 1
                            sig_llindex_lsb += 1

                            galt_list, galt_index_lsb = check_for_aib_overhead_signal_galt(configuration, galt_list, galt_index_lsb, use_master, "GALT")

        else:
            if llink['HASREADY']:
                galt_list, galt_index_lsb = check_for_aib_overhead_signal_galt(configuration, galt_list, galt_index_lsb, use_master, "GALT")

                sig_element=dict()
                if llink['NAME'] == "ST_S2M":
                    sig_element['SIG_NAME']  = gen_llink_concat_credit (llink['NAME'],localdir)
                else:
                    sig_element['SIG_NAME']  = gen_llink_concat_credit (llink['NAME'],otherdir)
                sig_element['SIG_INDEX'] = -1 ## indicate a scaler
                sig_element['LL_INDEX']  = -1 ## indicate not part of LLink Data
                sig_element['LL_NAME']   = llink['NAME'] ## unused, but lets be consistent
                sig_element['AIB_INDEX'] = galt_index_lsb
                if llink['NAME'] == "ST_S2M":
                    sig_element['COMMENT']   = "{}".format ( gen_llink_concat_credit (llink['NAME'],localdir))
                else:
                    sig_element['COMMENT']   = "{}".format ( gen_llink_concat_credit (llink['NAME'],otherdir))
                galt_list.append(sig_element)
                galt_index_lsb += 1

                galt_list, galt_index_lsb = check_for_aib_overhead_signal_galt(configuration, galt_list, galt_index_lsb, use_master, "GALT")

    sig_index_lsb   = 0
    for each_bit in list (range (0,  configuration['TOTAL_TX_ROUNDUP_BIT_GALT'] if use_master else configuration['TOTAL_RX_ROUNDUP_BIT_GALT'])):
        galt_list, galt_index_lsb = check_for_aib_overhead_signal_galt(configuration, galt_list, galt_index_lsb, use_master, "GALT")

        sig_element=dict()
        if global_struct.USE_SPARE_VECTOR:
            sig_element['SIG_NAME']  = "spare_"+localdir
            sig_element['SIG_INDEX'] = sig_index_lsb
            sig_element['LL_INDEX']  = -1
            sig_element['LL_NAME']   = "NO_LLDATA"
            sig_element['AIB_INDEX'] = galt_index_lsb
            sig_element['COMMENT']   = "SPARE"
        else:
            sig_element['SIG_NAME']  = "1'b0"
            sig_element['SIG_INDEX'] = -1
            sig_element['LL_INDEX']  = -1
            sig_element['LL_NAME']   = "NO_LLDATA"
            sig_element['AIB_INDEX'] = galt_index_lsb
            sig_element['COMMENT']   = "SPARE"
        galt_list.append(sig_element)
        galt_index_lsb += 1
        sig_index_lsb += 1

        galt_list, galt_index_lsb = check_for_aib_overhead_signal_galt(configuration, galt_list, galt_index_lsb, use_master, "GALT")


    #print ("\n\n\n")
    #pprint.pprint (configuration)

    #print ("Total Main TX Elements={}  Total GALT Tx Elements={} for {}".format(len(main_list) , len(galt_list), "master" if use_master else "slave"))

    main_index_lsb   = 0 ;
    galt_index_lsb   = 0 ;
    main_array_index = 0 ;
    galt_array_index = 0 ;
    enable_main      = True ;
    enable_galt      = True ;

    while enable_main or enable_galt:
        if enable_main and enable_galt:
            #print ("Processing Main:{} and Galt:{}".format(main_array_index, galt_array_index))
            main_index_lsb, galt_index_lsb = print_aib_mapping_galt_tx(configuration, use_master=use_master, wid1=1, lsb1=main_index_lsb, lsb3=galt_index_lsb,
                                                                    signal2=main_list[main_array_index]['SIG_NAME'], lsb2=main_list[main_array_index]['SIG_INDEX'], llink_lsb=main_list[main_array_index]['LL_INDEX'],   llink_name=main_list[main_array_index]['LL_NAME'],   comment2=main_list[main_array_index]['COMMENT'],
                                                                    signal4=galt_list[galt_array_index]['SIG_NAME'], lsb4=galt_list[galt_array_index]['SIG_INDEX'], llink_lsb4=galt_list[galt_array_index]['LL_INDEX'],  llink_name4=galt_list[galt_array_index]['LL_NAME'],  comment4=galt_list[galt_array_index]['COMMENT'])
        elif enable_main:
            #print ("Processing Only Main:{}".format(main_array_index,))
            main_index_lsb, galt_index_lsb = print_aib_mapping_galt_tx(configuration, use_master=use_master, wid1=1, lsb1=main_index_lsb, lsb3=galt_index_lsb,
                                                                    signal2=main_list[main_array_index]['SIG_NAME'], lsb2=main_list[main_array_index]['SIG_INDEX'], llink_lsb=main_list[main_array_index]['LL_INDEX'],  llink_name=main_list[main_array_index]['LL_NAME'],  comment2=main_list[main_array_index]['COMMENT'],
                                                                    signal4="1'b0", lsb4=-1, llink_lsb4=-1,  llink_name4="NONE",  comment4="NONE")
        elif enable_galt:
            #print ("Processing Only Galt:{}".format(galt_array_index))
            main_index_lsb, galt_index_lsb = print_aib_mapping_galt_tx(configuration, use_master=use_master, wid1=1, lsb1=main_index_lsb, lsb3=galt_index_lsb,
                                                                    signal2="1'b0", lsb2=-1, llink_lsb=-1,  llink_name="NONE",  comment2="NONE",
                                                                    signal4=galt_list[galt_array_index]['SIG_NAME'], lsb4=galt_list[galt_array_index]['SIG_INDEX'], llink_lsb4=galt_list[galt_array_index]['LL_INDEX'],  llink_name4=galt_list[galt_array_index]['LL_NAME'],  comment4=galt_list[galt_array_index]['COMMENT'])
        #print ("TX Data main_index_lsb, enable_main , enable_galt = {} , {} , {}".format(main_index_lsb, enable_main , enable_galt))

        if enable_main:
            main_array_index   += 1
            if main_array_index >= len(main_list):
                enable_main      = False

        if enable_galt:
            galt_array_index   += 1
            if galt_array_index >= len(galt_list):
                enable_galt      = False



    main_index_lsb   = 0 ;
    galt_index_lsb   = 0 ;
    main_array_index = 0 ;
    galt_array_index = 0 ;
    enable_main      = True ;
    enable_galt      = True ;

    for main_array_index in list (range (0, len(main_list))):
        found_galt       = False ;
        for galt_array_index in list (range (0, len(galt_list))):
            if (main_list[main_array_index]['SIG_NAME'] == galt_list[galt_array_index]['SIG_NAME']) and (main_list[main_array_index]['SIG_INDEX'] == galt_list[galt_array_index]['SIG_INDEX']) and (main_list[main_array_index]['SIG_NAME'] != "1'b0"):
                #print ("RX main_array_index, galt_array_index = {} , {}".format(main_array_index, galt_array_index))
                #print ("RX (main_list[main_array_index]['SIG_NAME'] == galt_list[galt_array_index]['SIG_NAME']) and (main_list[main_array_index]['SIG_INDEX'] == galt_list[galt_array_index]['SIG_INDEX']) {} {} {} {}".format( main_list[main_array_index]['SIG_NAME'], galt_list[galt_array_index]['SIG_NAME'], main_list[main_array_index]['SIG_INDEX'], galt_list[galt_array_index]['SIG_INDEX']))
                print_aib_mapping_galt_rx(configuration, use_master=use_master, wid1=1, lsb1=main_list[main_array_index]['AIB_INDEX'], lsb3=galt_list[galt_array_index]['AIB_INDEX'],
                                       signal2=main_list[main_array_index]['SIG_NAME'], lsb2=main_list[main_array_index]['SIG_INDEX'], llink_lsb=main_list[main_array_index]['LL_INDEX'],   llink_name=main_list[main_array_index]['LL_NAME'],   comment2=main_list[main_array_index]['COMMENT'],
                                       signal4=galt_list[galt_array_index]['SIG_NAME'], lsb4=galt_list[galt_array_index]['SIG_INDEX'], llink_lsb4=galt_list[galt_array_index]['LL_INDEX'],  llink_name4=galt_list[galt_array_index]['LL_NAME'],  comment4=galt_list[galt_array_index]['COMMENT'])
                #del galt_list[galt_array_index]
                found_galt = True
                break
        if found_galt == False:
            #print ("RX main_array_index, no galt_array_index = {} , {}".format(main_array_index, "NONE"))
            #print ("RX (main_list[main_array_index]['SIG_NAME'] == ) and (main_list[main_array_index]['SIG_INDEX'] == ) {} {}".format( main_list[main_array_index]['SIG_NAME'], main_list[main_array_index]['SIG_INDEX']))
            print_aib_mapping_galt_rx(configuration, use_master=use_master, wid1=1, lsb1=main_list[main_array_index]['AIB_INDEX'], lsb3=-1,
                                   signal2=main_list[main_array_index]['SIG_NAME'], lsb2=main_list[main_array_index]['SIG_INDEX'], llink_lsb=main_list[main_array_index]['LL_INDEX'],   llink_name=main_list[main_array_index]['LL_NAME'],   comment2=main_list[main_array_index]['COMMENT'],
                                   signal4="1'b0", lsb4=-1, llink_lsb4=-1,  llink_name4="GEN2ONLY",  comment4="GEN2ONLY")


    return configuration

## calculate_bit_loc_galt
##########################################################################################

##########################################################################################
## print_aib_mapping_galt_tx
## Used to print AIB mapping signals for GALT

## This is a big function.
## configuration, direction are obvious
## signal2 = user signal
## wid1 = width of signal (may be less than entire signal)
## lsb1 = lsbit position of AIB line when viewed as long data vector
## lsb2 = lsbit position of signal2 (-1 means it is a scaler)
## llink_lsb = starting position inside the Logic Link (-1 means not part of logic link data)
## llink_name = logic link name (.e.g AR, awbus, etc)
def print_aib_mapping_galt_tx(configuration, use_master, signal2, wid1, lsb1, lsb3, lsb2, signal4, lsb4, llink_lsb, llink_name, llink_lsb4, llink_name4, comment2, comment4):

    sysv = global_struct.g_USE_SYSTEMV_INDEXING
    use_tx = use_master

    signal2 = re.sub ("___MAIN", "", signal2)
    signal4 = re.sub ("___GALT", "", signal4)

    local_aib_index = lsb1
    local_lsb2 = lsb2
    local_lsb3 = lsb3
    local_lsb4 = lsb4

    tx_chan_width = configuration['CHAN_TX_RAW1PHY_DATA_MAIN']
    rx_chan_width = configuration['CHAN_RX_RAW1PHY_DATA_MAIN']

    for each_bit in list (range (0, wid1)):

        if use_tx:
            ## TX and RX Section for RTL
            ## Update, 2 DBI bits so we need to do it twice in both place.
            #local_aib_index = print_aib_assign_text_check_for_aibbit_galt (configuration, local_aib_index, use_tx, sysv)
            #local_aib_index = print_aib_assign_text_check_for_aibbit_galt (configuration, local_aib_index, use_tx, sysv)

            if llink_lsb == -1:
                global_struct.g_concat_code_vector_master_tx.append("  assign tx_phy_preflop_{0} [{1:4}] = m_gen2_mode ? {2:20}      : ".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, signal2, llink_lsb))
            elif local_lsb2 == -1:
                global_struct.g_concat_code_vector_master_tx.append("  assign tx_phy_preflop_{0} [{1:4}] = m_gen2_mode ? {2:20}[{3:4}] : ".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, gen_llink_concat_fifoname (llink_name,"input" ), llink_lsb))
            else:
                global_struct.g_concat_code_vector_master_tx.append("  assign tx_phy_preflop_{0} [{1:4}] = m_gen2_mode ? {2:20}[{3:4}] : ".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, gen_llink_concat_fifoname (llink_name,"input" ), llink_lsb))

            if llink_lsb4 == -1:
                global_struct.g_concat_code_vector_master_tx.append(" {2:20}      ;".format(int(local_lsb3) // tx_chan_width, local_lsb3 % tx_chan_width, signal4, llink_lsb4))
            elif local_lsb2 == -1:
                global_struct.g_concat_code_vector_master_tx.append(" {2:20}[{3:4}];".format(int(local_lsb3) // tx_chan_width, local_lsb3 % tx_chan_width, gen_llink_concat_fifoname (llink_name4,"input" ), llink_lsb4))
            else:
                global_struct.g_concat_code_vector_master_tx.append(" {2:20}[{3:4}];".format(int(local_lsb3) // tx_chan_width, local_lsb3 % tx_chan_width, gen_llink_concat_fifoname (llink_name4,"input" ), llink_lsb4))

            global_struct.g_concat_code_vector_master_tx.append("  // Gen2 ? {:20} : {:20}\n".format(comment2, comment4))

        #   ## DV Vectors
        #   if signal2 != "1'b0":
        #       if llink_lsb == -1:
        #           global_struct.g_dv_vector_print.append ("{:20}      = {:4};\n".format( "tx_{}_f".format(signal2), local_aib_index))
        #       elif local_lsb2 == -1:
        #           global_struct.g_dv_vector_print.append ("{0:20}      = {2:4};  {3:20}[{4:4}] = {2:4};\n".format("tx_{}_f".format(signal2), local_lsb2, local_aib_index, gen_llink_concat_fifoname (llink_name,"input") +"_f", llink_lsb))
        #       else:
        #           global_struct.g_dv_vector_print.append ("{0:20}[{1:4}] = {2:4};  {3:20}[{4:4}] = {2:4};\n".format("tx_{}_f".format(signal2), local_lsb2, local_aib_index, gen_llink_concat_fifoname (llink_name,"input") +"_f", llink_lsb))
        #           llink_lsb+=1


            ## AXI to PHY IF Mapping AXI Manager Transmit
            global_struct.g_debug_raw_data_vector_print_tx.append("{0:15} [{1:4}] = Gen2 ? ".format("  Channel {} TX  ".format(local_aib_index // tx_chan_width), local_aib_index % tx_chan_width))
            if local_lsb2 != -1:
                global_struct.g_debug_raw_data_vector_print_tx.append("{0:20} [{1:4}] : ".format(comment2, local_lsb2))
                local_lsb2 += 1
            else:
                global_struct.g_debug_raw_data_vector_print_tx.append("{0:26} : ".format(comment2, local_lsb2))
            local_aib_index += 1

            if local_lsb4 != -1:
                global_struct.g_debug_raw_data_vector_print_tx.append("{0:20} [{1:4}]\n".format(comment4, local_lsb4))
                local_lsb4 += 1
            else:
                global_struct.g_debug_raw_data_vector_print_tx.append("{0:26}\n".format(comment4, local_lsb4))
            local_lsb3 += 1

        else:

            if llink_lsb == -1:
                global_struct.g_concat_code_vector_slave_tx.append("  assign tx_phy_preflop_{0} [{1:4}] = m_gen2_mode ? {2:20}      : ".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, signal2, llink_lsb))
            elif local_lsb2 == -1:
                global_struct.g_concat_code_vector_slave_tx.append("  assign tx_phy_preflop_{0} [{1:4}] = m_gen2_mode ? {2:20}[{3:4}] : ".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, gen_llink_concat_fifoname (llink_name,"input" ), llink_lsb))
            else:
                global_struct.g_concat_code_vector_slave_tx.append("  assign tx_phy_preflop_{0} [{1:4}] = m_gen2_mode ? {2:20}[{3:4}] : ".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, gen_llink_concat_fifoname (llink_name,"input" ), llink_lsb))

            if llink_lsb4 == -1:
                global_struct.g_concat_code_vector_slave_tx.append("{2:20}      ;".format(int(local_lsb3) // tx_chan_width, local_lsb3 % tx_chan_width, signal4, llink_lsb4))
            elif local_lsb2 == -1:
                global_struct.g_concat_code_vector_slave_tx.append("{2:20}[{3:4}];".format(int(local_lsb3) // tx_chan_width, local_lsb3 % tx_chan_width, gen_llink_concat_fifoname (llink_name4,"input" ), llink_lsb4))
            else:
                global_struct.g_concat_code_vector_slave_tx.append("{2:20}[{3:4}];".format(int(local_lsb3) // tx_chan_width, local_lsb3 % tx_chan_width, gen_llink_concat_fifoname (llink_name4,"input" ), llink_lsb4))

            global_struct.g_concat_code_vector_slave_tx.append("  // Gen2 ? {:20} : {:20}\n".format(comment2, comment4))


      #     ## DV Vectors
      #     if signal2 != "1'b0":
      #         if local_lsb2 != -1:
      #             global_struct.g_dv_vector_print.append ("{0:20}[{1:4}] = {2:4};  {3:20}[{4:4}] = {2:4};\n".format("rx_{}_f".format(signal2), local_lsb2, local_aib_index, gen_llink_concat_fifoname (llink_name,"output"), llink_lsb))
      #             llink_lsb+=1
      #         else:
      #             global_struct.g_dv_vector_print.append ("{:20}      = {:4};\n".format( "rx_{}_f".format(signal2), local_aib_index))


            ## AXI to PHY IF Mapping AXI Manager Receive
            global_struct.g_debug_raw_data_vector_print_rx.append("{0:15} [{1:4}] = Gen2 ? ".format("  Channel {} RX  ".format(local_aib_index // rx_chan_width), local_aib_index % rx_chan_width))
            if local_lsb2 != -1:
                global_struct.g_debug_raw_data_vector_print_rx.append("{0:20} [{1:4}] : ".format(comment2, local_lsb2))
                local_lsb2 += 1
            else:
                global_struct.g_debug_raw_data_vector_print_rx.append("{0:26} : ".format(comment2, local_lsb2))
            local_aib_index += 1

            if local_lsb4 != -1:
                global_struct.g_debug_raw_data_vector_print_rx.append("{0:20} [{1:4}]\n".format(comment4, local_lsb4))
                local_lsb4 += 1
            else:
                global_struct.g_debug_raw_data_vector_print_rx.append("{0:26}\n".format(comment4, local_lsb4))
            local_lsb3 += 1

    return local_aib_index, local_lsb3


## print_aib_mapping_galt_tx
##########################################################################################

##########################################################################################
## print_aib_mapping_galt_rx

## Used to print AIB mapping signals for GALT

## This is a big function.
## configuration, direction are obvious
## signal2 = user signal
## wid1 = width of signal (may be less than entire signal)
## lsb1 = lsbit position of AIB line when viewed as long data vector
## lsb2 = lsbit position of signal2 (-1 means it is a scaler)
## llink_lsb = starting position inside the Logic Link (-1 means not part of logic link data)
## llink_name = logic link name (.e.g AR, awbus, etc)
def print_aib_mapping_galt_rx(configuration, use_master, signal2, wid1, lsb1, lsb3, lsb2, signal4, lsb4, llink_lsb, llink_name, llink_lsb4, llink_name4, comment2, comment4):

    sysv = global_struct.g_USE_SYSTEMV_INDEXING
    use_tx = use_master

    signal2 = re.sub ("tx_mrk_userbit___MAIN.*", "1'b0", signal2)
    signal4 = re.sub ("tx_mrk_userbit___GALT.*", "1'b0", signal4)
    signal2 = re.sub ("tx_stb_userbit___MAIN.*", "1'b0", signal2)
    signal4 = re.sub ("tx_stb_userbit___GALT.*", "1'b0", signal4)

    local_aib_index = lsb1
    local_lsb2 = lsb2
    local_lsb3 = lsb3
    local_lsb4 = lsb4

    tx_chan_width = configuration['CHAN_TX_RAW1PHY_DATA_MAIN']
    rx_chan_width = configuration['CHAN_RX_RAW1PHY_DATA_MAIN']

    for each_bit in list (range (0, wid1)):

        if use_tx:

            if local_lsb3 == -1: ## Corner case where Gen1 does not drive signal, so remove the mux and assign directly from Gen2 size.

                if llink_lsb == -1:
                    if signal2 != "1'b0":
                        global_struct.g_concat_code_vector_slave_rx.append("  assign {2:20}      =               rx_phy_postflop_{0} [{1:4}]                           ;".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, re.sub("^tx_", "rx_", signal2), llink_lsb))
                    else:
                        global_struct.g_concat_code_vector_slave_rx.append("//       {2:20}      =               rx_phy_postflop_{0} [{1:4}]                           ;".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, "nc", llink_lsb))
                elif local_lsb2 == -1:
                    if signal2 != "1'b0":
                        global_struct.g_concat_code_vector_slave_rx.append("  assign {2:20}[{3:4}] =               rx_phy_postflop_{0} [{1:4}]                           ;".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, gen_llink_concat_fifoname (llink_name,"output" ), llink_lsb))
                else:
                    if signal2 != "1'b0":
                        global_struct.g_concat_code_vector_slave_rx.append("  assign {2:20}[{3:4}] =               rx_phy_postflop_{0} [{1:4}]                           ;".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, gen_llink_concat_fifoname (llink_name,"output" ), llink_lsb))




            else:
                if llink_lsb == -1:
                    if signal2 != "1'b0":
                        global_struct.g_concat_code_vector_slave_rx.append("  assign {2:20}      = m_gen2_mode ? rx_phy_postflop_{0} [{1:4}] : ".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, re.sub("^tx_", "rx_", signal2), llink_lsb))
                    else:
                        global_struct.g_concat_code_vector_slave_rx.append("//       {2:20}      = m_gen2_mode ? rx_phy_postflop_{0} [{1:4}] : ".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, "nc", llink_lsb))
                elif local_lsb2 == -1:
                    if signal2 != "1'b0":
                        global_struct.g_concat_code_vector_slave_rx.append("  assign {2:20}[{3:4}] = m_gen2_mode ? rx_phy_postflop_{0} [{1:4}] : ".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, gen_llink_concat_fifoname (llink_name,"output" ), llink_lsb))
                else:
                    if signal2 != "1'b0":
                        global_struct.g_concat_code_vector_slave_rx.append("  assign {2:20}[{3:4}] = m_gen2_mode ? rx_phy_postflop_{0} [{1:4}] : ".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, gen_llink_concat_fifoname (llink_name,"output" ), llink_lsb))


                if llink_lsb4 == -1:
                    if signal4 != "1'b0":
                        global_struct.g_concat_code_vector_slave_rx.append("rx_phy_postflop_{0} [{1:4}] ;".format(int(local_lsb3) // tx_chan_width, local_lsb3 % tx_chan_width, re.sub("^tx_", "rx_", signal4), llink_lsb4))
                    else:
                        global_struct.g_concat_code_vector_slave_rx.append("rx_phy_postflop_{0} [{1:4}] ;".format(int(local_lsb3) // tx_chan_width, local_lsb3 % tx_chan_width, "nc", llink_lsb4))
                elif local_lsb2 == -1:
                    if signal4 != "1'b0":
                        global_struct.g_concat_code_vector_slave_rx.append("rx_phy_postflop_{0} [{1:4} ];".format(int(local_lsb3) // tx_chan_width, local_lsb3 % tx_chan_width, gen_llink_concat_fifoname (llink_name4,"output" ), llink_lsb4))
                else:
                    if signal4 != "1'b0":
                        global_struct.g_concat_code_vector_slave_rx.append("rx_phy_postflop_{0} [{1:4}] ;".format(int(local_lsb3) // tx_chan_width, local_lsb3 % tx_chan_width, gen_llink_concat_fifoname (llink_name4,"output" ), llink_lsb4))

            global_struct.g_concat_code_vector_slave_rx.append("  // Gen2 ? {:20} : {:20}\n".format(comment2, comment4))


       #    ## DV Vectors
       #    if signal2 != "1'b0":
       #        if llink_lsb == -1:
       #            global_struct.g_dv_vector_print.append ("{:20}      = {:4};\n".format( "tx_{}_f".format(signal2), local_aib_index))
       #        elif local_lsb2 == -1:
       #            global_struct.g_dv_vector_print.append ("{0:20}      = {2:4};  {3:20}[{4:4}] = {2:4};\n".format("tx_{}_f".format(signal2), local_lsb2, local_aib_index, gen_llink_concat_fifoname (llink_name,"input") +"_f", llink_lsb))
       #        else:
       #            global_struct.g_dv_vector_print.append ("{0:20}[{1:4}] = {2:4};  {3:20}[{4:4}] = {2:4};\n".format("tx_{}_f".format(signal2), local_lsb2, local_aib_index, gen_llink_concat_fifoname (llink_name,"input") +"_f", llink_lsb))
       #            llink_lsb+=1

        else:

            if local_lsb3 == -1: ## Corner case where Gen1 does not drive signal, so remove the mux and assign directly from Gen2 size.

                if llink_lsb == -1:
                    if signal2 != "1'b0":
                        global_struct.g_concat_code_vector_master_rx.append("  assign {2:20}      =               rx_phy_postflop_{0} [{1:4}]                           ;".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, re.sub("^tx_", "rx_", signal2), llink_lsb))
                    else:
                        global_struct.g_concat_code_vector_master_rx.append("//       {2:20}      =               rx_phy_postflop_{0} [{1:4}]                           ;".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, "nc", llink_lsb))
                elif local_lsb2 == -1:
                    if signal2 != "1'b0":
                        global_struct.g_concat_code_vector_master_rx.append("  assign {2:20}[{3:4}] =               rx_phy_postflop_{0} [{1:4}]                           ;".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, gen_llink_concat_fifoname (llink_name,"output" ), llink_lsb))
                else:
                    if signal2 != "1'b0":
                        global_struct.g_concat_code_vector_master_rx.append("  assign {2:20}[{3:4}] =               rx_phy_postflop_{0} [{1:4}]                           ;".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, gen_llink_concat_fifoname (llink_name,"output" ), llink_lsb))

            else:
                if llink_lsb == -1:
                    if signal2 != "1'b0":
                        global_struct.g_concat_code_vector_master_rx.append("  assign {2:20}      = m_gen2_mode ? rx_phy_postflop_{0} [{1:4}] : ".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, re.sub("^tx_", "rx_", signal2), llink_lsb))
                    else:
                        global_struct.g_concat_code_vector_master_rx.append("//       {2:20}      = m_gen2_mode ? rx_phy_postflop_{0} [{1:4}] : ".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, "nc", llink_lsb))
                elif local_lsb2 == -1:
                    if signal2 != "1'b0":
                        global_struct.g_concat_code_vector_master_rx.append("  assign {2:20}[{3:4}] = m_gen2_mode ? rx_phy_postflop_{0} [{1:4}] : ".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, gen_llink_concat_fifoname (llink_name,"output" ), llink_lsb))
                else:
                    if signal2 != "1'b0":
                        global_struct.g_concat_code_vector_master_rx.append("  assign {2:20}[{3:4}] = m_gen2_mode ? rx_phy_postflop_{0} [{1:4}] : ".format(int(local_aib_index) // tx_chan_width, local_aib_index % tx_chan_width, gen_llink_concat_fifoname (llink_name,"output" ), llink_lsb))


                if llink_lsb4 == -1:
                    if signal4 != "1'b0":
                        global_struct.g_concat_code_vector_master_rx.append("rx_phy_postflop_{0} [{1:4}] ;".format(int(local_lsb3) // tx_chan_width, local_lsb3 % tx_chan_width, re.sub("^tx_", "rx_", signal4), llink_lsb4))
                    else:
                        global_struct.g_concat_code_vector_master_rx.append("rx_phy_postflop_{0} [{1:4}] ;".format(int(local_lsb3) // tx_chan_width, local_lsb3 % tx_chan_width, "nc", llink_lsb4))
                elif local_lsb2 == -1:
                    if signal4 != "1'b0":
                        global_struct.g_concat_code_vector_master_rx.append("rx_phy_postflop_{0} [{1:4} ];".format(int(local_lsb3) // tx_chan_width, local_lsb3 % tx_chan_width, gen_llink_concat_fifoname (llink_name4,"output" ), llink_lsb4))
                else:
                    if signal4 != "1'b0":
                        global_struct.g_concat_code_vector_master_rx.append("rx_phy_postflop_{0} [{1:4}] ;".format(int(local_lsb3) // tx_chan_width, local_lsb3 % tx_chan_width, gen_llink_concat_fifoname (llink_name4,"output" ), llink_lsb4))

            global_struct.g_concat_code_vector_master_rx.append("  // Gen2 ? {:20} : {:20}\n".format(comment2, comment4))


       #    ## DV Vectors
       #    if signal2 != "1'b0":
       #        if local_lsb2 != -1:
       #            global_struct.g_dv_vector_print.append ("{0:20}[{1:4}] = {2:4};  {3:20}[{4:4}] = {2:4};\n".format("rx_{}_f".format(signal2), local_lsb2, local_aib_index, gen_llink_concat_fifoname (llink_name,"output"), llink_lsb))
       #            llink_lsb+=1
       #        else:
       #            global_struct.g_dv_vector_print.append ("{:20}      = {:4};\n".format( "rx_{}_f".format(signal2), local_aib_index))


    return local_aib_index, local_lsb3

## print_aib_mapping_galt_rx
##########################################################################################

##########################################################################################
## check_for_aib_overhead_signal_galt
## This routine checks the current AIB bit position to see if there is an overhead bit
## like DBI, markers, etc. that needs to be inserted.
##
## Note, for GALT, we drive "UNUSED" signals to 0 (i.e. upper bits)

def check_for_aib_overhead_signal_galt(configuration, signal_list, current_lsb, use_master, gen="MAIN"):

    bit_added = True

    while bit_added:
        bit_added = False

        ## This stops us from rolling over into the next region
        if current_lsb == (configuration['NUM_CHAN'] * (configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if use_master else configuration['CHAN_RX_RAW1PHY_DATA_MAIN'])):
              #print ("stopping current_lsb {} =  NUM_CHAN:{}  * CHAN_/RXTX_RAW1PHY_DATA_MAIN:{}  use_master:{}".format(current_lsb, configuration['NUM_CHAN'], (configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if use_master else configuration['CHAN_RX_RAW1PHY_DATA_MAIN']), use_master))
              continue

        #print ("going    current_lsb {} =  NUM_CHAN:{}  * CHAN_/RXTX_RAW1PHY_DATA_MAIN:{}  use_master:{}".format(current_lsb, configuration['NUM_CHAN'], (configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if use_master else configuration['CHAN_RX_RAW1PHY_DATA_MAIN']), use_master))

        if ( (gen=="GALT" and (current_lsb % configuration['CHAN_TX_RAW1PHY_DATA_MAIN']) >= configuration['CHAN_TX_RAW1PHY_DATA_GALT'] and use_master == True ) or
             (gen=="GALT" and (current_lsb % configuration['CHAN_RX_RAW1PHY_DATA_MAIN']) >= configuration['CHAN_RX_RAW1PHY_DATA_GALT'] and use_master == False) ):
            sig_element=dict()
            sig_element['SIG_NAME']  = "1'b0"
            sig_element['SIG_INDEX'] = -1 ## indicate a scaler
            sig_element['LL_INDEX']  = -1 ## indicate not part of LLink Data
            sig_element['LL_NAME']   = "NO_LLDATA" ## unused, but lets be consistent
            sig_element['AIB_INDEX'] = current_lsb
            sig_element['COMMENT']   = "{}".format ("UNUSED")
            signal_list.append(sig_element)
            current_lsb += 1
            bit_added = True
            continue

        if ( ((configuration['TX_DBI_PRESENT'] if use_master else configuration['TX_DBI_PRESENT']) and gen=="MAIN" and use_master == True)  or
             ((configuration['RX_DBI_PRESENT'] if use_master else configuration['RX_DBI_PRESENT']) and gen=="MAIN" and use_master == False) ):
            if ((current_lsb + 1) % 40) == 0 or ((current_lsb + 1) % 40 == 39):
                sig_element=dict()
                sig_element['SIG_NAME']  = "1'b0"
                sig_element['SIG_INDEX'] = -1 ## indicate a scaler
                sig_element['LL_INDEX']  = -1 ## indicate not part of LLink Data
                sig_element['LL_NAME']   = "NO_LLDATA" ## unused, but lets be consistent
                sig_element['AIB_INDEX'] = current_lsb
                sig_element['COMMENT']   = "{}".format ("DBI")
                signal_list.append(sig_element)
                current_lsb += 1
                bit_added = True
                continue

        if configuration['TX_ENABLE_STROBE'] and configuration['TX_PERSISTENT_STROBE'] and use_master == True :
            if ( (current_lsb % configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] == configuration['TX_STROBE_GEN2_LOC'] and gen=="MAIN") or
                 (current_lsb % configuration['CHAN_TX_RAW1PHY_DATA_GALT'] == configuration['TX_STROBE_GEN1_LOC'] and gen=="GALT") ):
                sig_element=dict()
                sig_element['SIG_NAME']  = "tx_stb_userbit___"+gen
                sig_element['SIG_INDEX'] = -1 ## indicate a scaler
                sig_element['LL_INDEX']  = -1 ## indicate not part of LLink Data
                sig_element['LL_NAME']   = "NO_LLDATA" ## unused, but lets be consistent
                sig_element['AIB_INDEX'] = current_lsb
                sig_element['COMMENT']   = "{}".format ("STROBE")
                signal_list.append(sig_element)
                current_lsb += 1
                bit_added = True
                continue

        if configuration['RX_ENABLE_STROBE'] and configuration['RX_PERSISTENT_STROBE'] and use_master == False :
            if ( (current_lsb % configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] == configuration['RX_STROBE_GEN2_LOC'] and gen=="MAIN") or
                 (current_lsb % configuration['CHAN_RX_RAW1PHY_DATA_GALT'] == configuration['RX_STROBE_GEN1_LOC'] and gen=="GALT") ):
                sig_element=dict()
                sig_element['SIG_NAME']  = "tx_stb_userbit___"+gen
                sig_element['SIG_INDEX'] = -1 ## indicate a scaler
                sig_element['LL_INDEX']  = -1 ## indicate not part of LLink Data
                sig_element['LL_NAME']   = "NO_LLDATA" ## unused, but lets be consistent
                sig_element['AIB_INDEX'] = current_lsb
                sig_element['COMMENT']   = "{}".format ("STROBE")
                signal_list.append(sig_element)
                current_lsb += 1
                bit_added = True
                continue

        if configuration['TX_ENABLE_MARKER'] and configuration['TX_PERSISTENT_MARKER'] and use_master == True :
            if ( (current_lsb % configuration['CHAN_TX_RAW1PHY_BEAT_MAIN'] == configuration['TX_MARKER_GEN2_LOC'] and gen=="MAIN") ):
                sig_element=dict()
                sig_element['SIG_NAME']  = "tx_mrk_userbit___"+gen+"[{}]".format ( (int(current_lsb) % configuration['CHAN_TX_RAW1PHY_DATA_MAIN']) // configuration['CHAN_TX_RAW1PHY_BEAT_MAIN'])
                sig_element['SIG_INDEX'] = -1 ## indicate a scaler
                sig_element['LL_INDEX']  = -1 ## indicate not part of LLink Data
                sig_element['LL_NAME']   = "NO_LLDATA" ## unused, but lets be consistent
                sig_element['AIB_INDEX'] = current_lsb
                sig_element['COMMENT']   = "{}".format ("MARKER")
                signal_list.append(sig_element)
                current_lsb += 1
                bit_added = True
                continue

        if configuration['TX_ENABLE_MARKER'] and configuration['TX_PERSISTENT_MARKER'] and use_master == True :
            if ( (current_lsb % configuration['CHAN_TX_RAW1PHY_BEAT_GALT'] == configuration['TX_MARKER_GEN1_LOC'] and gen=="GALT") ):
                sig_element=dict()
                sig_element['SIG_NAME']  = "tx_mrk_userbit___"+gen+"[{}]".format ( (int(current_lsb) % configuration['CHAN_TX_RAW1PHY_DATA_GALT']) // configuration['CHAN_TX_RAW1PHY_BEAT_GALT'])
                sig_element['SIG_INDEX'] = -1 ## indicate a scaler
                sig_element['LL_INDEX']  = -1 ## indicate not part of LLink Data
                sig_element['LL_NAME']   = "NO_LLDATA" ## unused, but lets be consistent
                sig_element['AIB_INDEX'] = current_lsb
                sig_element['COMMENT']   = "{}".format ("MARKER")
                signal_list.append(sig_element)
                current_lsb += 1
                bit_added = True
                continue

        if configuration['RX_ENABLE_MARKER'] and configuration['RX_PERSISTENT_MARKER'] and use_master == False :
            if ( (current_lsb % configuration['CHAN_RX_RAW1PHY_BEAT_MAIN'] == configuration['RX_MARKER_GEN2_LOC'] and gen=="MAIN") ):
                sig_element=dict()
                sig_element['SIG_NAME']  = "tx_mrk_userbit___"+gen+"[{}]".format ( (int(current_lsb) % configuration['CHAN_RX_RAW1PHY_DATA_MAIN']) // configuration['CHAN_RX_RAW1PHY_BEAT_MAIN'])
                sig_element['SIG_INDEX'] = -1 ## indicate a scaler
                sig_element['LL_INDEX']  = -1 ## indicate not part of LLink Data
                sig_element['LL_NAME']   = "NO_LLDATA" ## unused, but lets be consistent
                sig_element['AIB_INDEX'] = current_lsb
                sig_element['COMMENT']   = "{}".format ("MARKER")
                signal_list.append(sig_element)
                current_lsb += 1
                bit_added = True
                continue

        if configuration['RX_ENABLE_MARKER'] and configuration['RX_PERSISTENT_MARKER'] and use_master == False :
            if ( (current_lsb % configuration['CHAN_RX_RAW1PHY_BEAT_GALT'] == configuration['RX_MARKER_GEN1_LOC'] and gen=="GALT") ):
                sig_element=dict()
                sig_element['SIG_NAME']  = "tx_mrk_userbit___"+gen+"[{}]".format ( (int(current_lsb) % configuration['CHAN_RX_RAW1PHY_DATA_GALT']) // configuration['CHAN_RX_RAW1PHY_BEAT_GALT'])
                sig_element['SIG_INDEX'] = -1 ## indicate a scaler
                sig_element['LL_INDEX']  = -1 ## indicate not part of LLink Data
                sig_element['LL_NAME']   = "NO_LLDATA" ## unused, but lets be consistent
                sig_element['AIB_INDEX'] = current_lsb
                sig_element['COMMENT']   = "{}".format ("MARKER")
                signal_list.append(sig_element)
                current_lsb += 1
                bit_added = True
                continue


    return signal_list, current_lsb

## check_for_aib_overhead_signal_galt
##########################################################################################

