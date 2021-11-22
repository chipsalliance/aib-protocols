############################################################
##
##        Copyright (C) 2021 Eximius Design
##                All Rights Reserved
##
## This entire notice must be reproduced on all copies of this file
## and copies of this file may only be made by a person if such person is
## permitted to do so under the terms of a subsisting license agreement
## from Eximius Design
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
import llink_gen

gen_index_msb               = global_struct.gen_index_msb
gen_direction               = global_struct.gen_direction
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

print_aib_mapping_text      = llink_gen.print_aib_mapping_text







def split_packets(orig_packet_list, max_data_width):

    new_pkt_list = list()
    for packet_entry in orig_packet_list:
       current_size = packet_entry['WIDTH_W_PUSH']
       iteration=int(math.ceil(float(current_size) / max_data_width)) - 1

       if ( iteration >= 99):
           print ("ERROR:  Packetization routine has upper limit of 100 packets.")
           print ("        Increase [TX|RX]_PACKET_MAX_SIZE or set to 0 for max available size.")
           print ("        If that does not fix the issue, we may not be able to pack everything into available space.")
           if global_struct.g_PACKET_DEBUG:
               print ("  Original Packets were constrained to {} bit size".format(max_data_width))
               print ("  Error found in split_packet. Original Packet list and New Packet List as follows:")
               pprint.pprint (orig_packet_list, indent=4)
               pprint.pprint (new_pkt_list    , indent=4)
           else:
               print ("  Specifics of this error are available if you re-run with --packet_debug option.")
           sys.exit(1)

       #iteration=0
       first_chunk = True
       packet_packing_lsb=0
       while current_size:
           current_chunk = (max_data_width) if current_size > (max_data_width) else current_size
           current_size -= current_chunk
           new_pkt_dict = dict (packet_entry)
           new_pkt_dict['PKT_INDEX']    = iteration
           new_pkt_dict['LLINK_LSB']    = packet_packing_lsb
           new_pkt_dict['FIRST_PKT']    = True if iteration == 0 else False
           new_pkt_dict['LAST_PKT']     = True if first_chunk else False
           #new_pkt_dict['PREV_PKT']     = "Null" if new_pkt_dict['LAST_PKT'] else prev_pkt_dict
           new_pkt_dict['HASVALID']     = True if packet_entry['HASVALID'] and new_pkt_dict['FIRST_PKT'] else False
           new_pkt_dict['WIDTH_W_PUSH'] = current_chunk
           new_pkt_dict['WIDTH']        = (current_chunk -1) if new_pkt_dict['HASVALID'] else current_chunk
           new_pkt_dict['CHUNK_NAME']   = new_pkt_dict['NAME'] + "{0:02d}".format(new_pkt_dict['PKT_INDEX'])
           new_pkt_dict['ENC']          = -1
           new_pkt_dict['LAST_PKT_ENC'] = -1
           new_pkt_dict['LAST_PKT_INDEX'] = -1

           prev_pkt_dict = new_pkt_dict

           packet_packing_lsb += current_chunk
           iteration -= 1
           #iteration += 1
           first_chunk = False
           new_pkt_list.append (prev_pkt_dict)

    if global_struct.g_PACKET_DEBUG:
        print ("  Splitting large packets to fit data size {}. Added {} entries".format(max_data_width, int(len(new_pkt_list) - int(len(orig_packet_list)))))
        pprint.pprint (orig_packet_list, indent=4)
        pprint.pprint (new_pkt_list    , indent=4)
    return new_pkt_list


def packetize_algorithm(packet_size_optimized_list, packet_max_size):
    ## First we'll try to get multiple packets
    potential_packet_list       = list()

    for new_chunk in packet_size_optimized_list:
        copy_of_cur_pkt_list = list (potential_packet_list)

        if global_struct.g_PACKETIZATION_PACKING_EN:
            ## This adds the new chunk to all existing chunk combos (i.e. doubles existing combos)
            for existing_packet_dict in copy_of_cur_pkt_list:
                #print ("Existing PotPacket: {}  new_chunk {}".format(existing_packet_dict['PKT_NAME'], new_chunk['CHUNK_NAME']))

                ## Make a copy of the Packet List and add the new chunk
                potential_packet_entry = list(existing_packet_dict['LIST'])
                potential_packet_entry.append (dict(new_chunk))

                ## Make a copy of the existing Dict
                potential_packet_dict = dict(existing_packet_dict)
                potential_packet_dict['PKT_NAME']     = "___".join(potential_packet_dict['PKT_NAME'].split("___") + [new_chunk['CHUNK_NAME']])
                potential_packet_dict['SIZE']         = potential_packet_dict['SIZE'] + new_chunk['WIDTH_W_PUSH']
                potential_packet_dict['LIST']         = potential_packet_entry
                potential_packet_dict['NUM_NOT_LAST'] += 0 if new_chunk['LAST_PKT'] else 1

                ## Only push entry if it is within size and if this is the "first" of at most one full channel data (i.e. it is not the last of 1 or fewer)
                if potential_packet_dict['SIZE'] <= packet_max_size and potential_packet_dict['NUM_NOT_LAST'] < 2:
                    #print ("New PotPacket: {}".format(potential_packet_dict['PKT_NAME']))
                    potential_packet_list.append (potential_packet_dict)

        ## This is a new entry of the new chunk by itself
        potential_packet_entry = list()
        potential_packet_entry.append (new_chunk)

        potential_packet_dict = dict()
        potential_packet_dict['PKT_NAME'] = new_chunk['CHUNK_NAME']
        potential_packet_dict['SIZE'] = new_chunk['WIDTH_W_PUSH']
        potential_packet_dict['LIST'] = potential_packet_entry
        potential_packet_dict['NUM_NOT_LAST'] = 0 if new_chunk['LAST_PKT'] else 1

        ## Only push entry if it is within size and if this is the "first" of at most one full channel data (i.e. it is not the last of 1 or fewer)
        if potential_packet_dict['SIZE'] <= packet_max_size and potential_packet_dict['NUM_NOT_LAST'] < 2:
            #print ("New PotPacket: {}".format(potential_packet_dict['PKT_NAME']))
            potential_packet_list.append (potential_packet_dict)



#
#
#
#
#   for chunk1 in packet_size_optimized_list:
#       working_packet_list.append (chunk1)
#       if chunk1['LAST_PKT'] and working_packet_num_LAST_PKT > 0:
#           continue
#       else:
#           working_packet_num_LAST_PKT += 1
#       if [x for x in working_packet_list if working_packet_list.count(x) > 1]:
#           continue
#
#       if chunk1['WIDTH_W_PUSH'] <= packet_max_size:
#           potential_packet_entry = list()
#           potential_packet_entry.append (chunk1)
#
#           potential_packet_dict = dict()
#           potential_packet_dict['PKT_NAME'] = chunk1['CHUNK_NAME']
#           potential_packet_dict['SIZE'] = chunk1['WIDTH_W_PUSH']
#           potential_packet_dict['LIST'] = potential_packet_entry
#           potential_packet_list.append (potential_packet_dict)
#
#           if global_struct.g_PACKETIZATION_PACKING_EN == False:
#              continue
#
#           for chunk2 in packet_size_optimized_list:
#               working_packet_list.append (chunk2)
#               if chunk2['LAST_PKT'] and working_packet_num_LAST_PKT > 0:
#                   continue
#               else:
#                   working_packet_num_LAST_PKT += 1
#               if [x for x in working_packet_list if working_packet_list.count(x) > 1]:
#                   continue
#               if chunk1['WIDTH_W_PUSH'] + chunk2['WIDTH_W_PUSH'] <= packet_max_size:
#                   potential_packet_entry = list()
#                   potential_packet_entry.append (chunk1)
#                   potential_packet_entry.append (chunk2)
#
#                   potential_packet_dict = dict()
#                   potential_packet_dict['PKT_NAME'] = chunk1['CHUNK_NAME'] + "___" + chunk2['CHUNK_NAME']
#                   potential_packet_dict['SIZE'] = chunk1['WIDTH_W_PUSH'] + chunk2['WIDTH_W_PUSH']
#                   potential_packet_dict['LIST'] = potential_packet_entry
#                   potential_packet_list.append (potential_packet_dict)
#
#                   for chunk3 in packet_size_optimized_list:
#                       working_packet_list.append (chunk3)
#                       if chunk3['LAST_PKT'] and working_packet_num_LAST_PKT > 0:
#                           continue
#                       else:
#                           working_packet_num_LAST_PKT += 1
#                       if [x for x in working_packet_list if working_packet_list.count(x) > 1]:
#                           continue
#
#                       if chunk1['WIDTH_W_PUSH'] + chunk2['WIDTH_W_PUSH'] + chunk3['WIDTH_W_PUSH'] <= packet_max_size:
#                           potential_packet_entry = list()
#                           potential_packet_entry.append (chunk1)
#                           potential_packet_entry.append (chunk2)
#                           potential_packet_entry.append (chunk3)
#
#                           potential_packet_dict = dict()
#                           potential_packet_dict['PKT_NAME'] = chunk1['CHUNK_NAME'] + "___" + chunk2['CHUNK_NAME'] + "___" + chunk3['CHUNK_NAME']
#                           potential_packet_dict['SIZE'] = chunk1['WIDTH_W_PUSH'] + chunk2['WIDTH_W_PUSH'] + chunk3['WIDTH_W_PUSH']
#                           potential_packet_dict['LIST'] = potential_packet_entry
#                           potential_packet_list.append (potential_packet_dict)
#
#                           for chunk4 in packet_size_optimized_list:
#                               working_packet_list.append (chunk4)
#                               if chunk4['LAST_PKT'] and working_packet_num_LAST_PKT > 0:
#                                   continue
#                               else:
#                                   working_packet_num_LAST_PKT += 1
#                               if [x for x in working_packet_list if working_packet_list.count(x) > 1]:
#                                   continue
#                               if chunk1['WIDTH_W_PUSH'] + chunk2['WIDTH_W_PUSH'] + chunk3['WIDTH_W_PUSH'] + chunk4['WIDTH_W_PUSH'] <= packet_max_size:
#                                   potential_packet_entry = list()
#                                   potential_packet_entry.append (chunk1)
#                                   potential_packet_entry.append (chunk2)
#                                   potential_packet_entry.append (chunk3)
#                                   potential_packet_entry.append (chunk4)
#
#                                   potential_packet_dict = dict()
#                                   potential_packet_dict['PKT_NAME'] = chunk1['CHUNK_NAME'] + "___" + chunk2['CHUNK_NAME'] + "___" + chunk3['CHUNK_NAME'] + "___" + chunk4['CHUNK_NAME']
#                                   potential_packet_dict['SIZE'] = chunk1['WIDTH_W_PUSH'] + chunk2['WIDTH_W_PUSH'] + chunk3['WIDTH_W_PUSH'] + chunk4['WIDTH_W_PUSH']
#                                   potential_packet_dict['LIST'] = potential_packet_entry
#                                   potential_packet_list.append (potential_packet_dict)
#
#                               working_packet_list.pop()
#                               if chunk4['LAST_PKT']:
#                                   working_packet_num_LAST_PKT -= 1
#                       working_packet_list.pop()
#                       if chunk3['LAST_PKT']:
#                           working_packet_num_LAST_PKT -= 1
#               working_packet_list.pop()
#               if chunk2['LAST_PKT']:
#                   working_packet_num_LAST_PKT -= 1
#       working_packet_list.pop()
#       if chunk1['LAST_PKT']:
#           working_packet_num_LAST_PKT -= 1

    if global_struct.g_PACKET_DEBUG:
        print ("List of all possible chunktimized combinations");
        pprint.pprint (potential_packet_list)
        print ("Sorted list of all possible chunktimized combinations");
        for thing in sorted (potential_packet_list, key=itemgetter('SIZE', 'PKT_NAME'), reverse=True):
            print (thing)








#   ## Rebuild List so Only packets are first, First Packets for specific LL element are second followed by Middle, Last Packets for that same LL element
#   ordered_pkt_combo_only = list()
#   for potential_pkt in sorted (packet_combos, key=packet_combos.get, reverse=True):
#
#       pprint.pprint (potential_pkt)
#       if potential_pkt.count("pktidx_last_pktFalse") > 1: ## We only support 1 non-zero index per packet
#           print ("dropping combination: {} due to too many pktidx_last_pktFalse".format(potential_pkt))
#
#       pkt_is_only = 1
#       for element in sorted(potential_pkt.split(g_PKT_JOIN)):
#           packet_entry = dict()
#           packet_entry['NAME'],packet_entry['PKT_INDEX'],packet_entry['LLINK_LSB'],packet_entry['LAST_PKT'],packet_entry['FIRST_PKT'] = element.split(g_PKT_INDEX)
#           if packet_entry['FIRST_PKT'] == "first_pkt_False" or packet_entry['LAST_PKT'] == "last_pkt_False":
#              pkt_is_only=0
#
#       if pkt_is_only:
#           ordered_pkt_combo_only.append (potential_pkt)
#
#   ordered_pkt_combo_llink_ordered = list()
#   for potential_pkt in sorted (packet_combos, key=packet_combos.get, reverse=True):
#
#       pprint.pprint (potential_pkt)
#       pkt_is_first = 1
#       pkt_is_middle = 1
#       pkt_is_last = 1
#       curr_ll_name_list = list()
#       for element in sorted(potential_pkt.split(g_PKT_JOIN)):
#           packet_entry = dict()
#           packet_entry['NAME'],packet_entry['PKT_INDEX'],packet_entry['LLINK_LSB'],packet_entry['LAST_PKT'],packet_entry['FIRST_PKT'] = element.split(g_PKT_INDEX)
#           if packet_entry['FIRST_PKT'] == "first_pkt_False":
#              pkt_is_first=0
#           if packet_entry['FIRST_PKT'] == "first_pkt_True" or packet_entry['LAST_PKT'] == "last_pkt_True":
#              pkt_is_middle=0
#           if packet_entry['LAST_PKT'] == "last_pkt_False":
#              pkt_is_last=0
#
#       if pkt_is_first:
#           ordered_pkt_combo_first.append (potential_pkt)
#

    local_packet_info = list()
    already_allocated_pkt = list()
    for potential_pkt_dict in sorted (potential_packet_list, key=itemgetter('SIZE','PKT_NAME'), reverse=True) :

        all_chunks_already_allocated = 1 ## Default that everything is already allocated

        for chunk in potential_pkt_dict['LIST']:
            chunk_name = chunk['CHUNK_NAME']

            if chunk_name not in already_allocated_pkt:
                all_chunks_already_allocated = 0 ## But say 0 if it is not already allocated

        if all_chunks_already_allocated == 0:
            for chunk in potential_pkt_dict['LIST']:
                chunk_name = chunk['CHUNK_NAME']
                already_allocated_pkt.append (chunk_name)
            potential_pkt_dict['ENC'] = -1;
            local_packet_info.append (potential_pkt_dict)

    if global_struct.g_PACKET_DEBUG:
        print ("List of final optimized combination without encoding.  {} packets so {} bit encoding".format(len(local_packet_info), int.bit_length(len(local_packet_info)-1)))
        pprint.pprint (local_packet_info)



    ## This creates the encoding for the various chunks and makes sure they are in order
    encoding = 0
    cur_pkt_num = 0
    for entire_packet in sorted (local_packet_info, key=itemgetter('PKT_NAME')):
        if entire_packet['ENC'] == -1:

            entire_packet['ENC'] = encoding;
            encoding += 1;
            #for chunk in sorted (entire_packet['LIST'], key=itemgetter('CHUNK_NAME')):
            #   chunk['ENC'] = entire_packet['ENC'];

              # if chunk['PKT_INDEX'] != 0:
              #     for ent_pkt in sorted (local_packet_info, key=itemgetter('PKT_NAME')):
              #         for cnk in sorted (ent_pkt['LIST'], key=itemgetter('CHUNK_NAME')):
              #             if cnk['NAME'] == chunk['NAME'] and cnk['PKT_INDEX'] == (chunk['PKT_INDEX']-1) and ent_pkt['ENC'] == -1:
              #                 ent_pkt['ENC'] = encoding;
              #                 cnk['ENC']     = encoding;
              #                 encoding += 1;



##  for entire_packet in sorted (local_packet_info, key=itemgetter('PKT_NAME')):
##      for chunk in sorted (entire_packet['LIST'], key=itemgetter('CHUNK_NAME')):
##          if entire_packet['ENC'] == -1:
##              entire_packet['ENC'] = encoding;
##              chunk['ENC']         = encoding;
##              encoding += 1;
##              if chunk['PKT_INDEX'] != 0 and entire_packet['ENC'] == -1:
##                  for ent_pkt in sorted (local_packet_info, key=itemgetter('PKT_NAME')):
##                      for cnk in sorted (ent_pkt['LIST'], key=itemgetter('CHUNK_NAME')):
##                          if cnk['NAME'] == chunk['NAME'] and cnk['PKT_INDEX'] == (chunk['PKT_INDEX']-1) and ent_pkt['ENC'] == -1:
##                              ent_pkt['ENC'] = encoding;
##                              cnk['ENC']     = encoding;
##                              encoding += 1;

    for entire_packet in sorted (local_packet_info, key=itemgetter('PKT_NAME')):
        for chunk in sorted (entire_packet['LIST'], key=itemgetter('NAME','PKT_INDEX')):
            if chunk['ENC'] == -1:
                #print ("{} {} = {}".format(entire_packet['PKT_NAME'], chunk['NAME'], chunk['ENC']))
                chunk['ENC'] = entire_packet['ENC'];
                #print ("{} {} = {}".format(entire_packet['PKT_NAME'], chunk['NAME'], chunk['ENC']))

    # Populate LAST_PKT_INDEX and LAST_PKT_ENC
    max_pkt_index = 0
    max_pkt_enc = 0
    for entire_packet in sorted (local_packet_info, key=itemgetter('ENC'), reverse=True):
        for chunk in sorted (entire_packet['LIST'], key=itemgetter('NAME','PKT_INDEX')):
            if chunk['LAST_PKT']:
                #print ("Upper: chunk {}   pkt {}".format(chunk['NAME'], entire_packet['PKT_NAME']))
                max_pkt_index = chunk['PKT_INDEX']
                max_pkt_enc   = entire_packet['ENC']
                chunk['LAST_PKT_INDEX'] = max_pkt_index;
                chunk['LAST_PKT_ENC']   = max_pkt_enc;

                for ent_pkt in sorted (local_packet_info, key=itemgetter('ENC'), reverse=True):
                    if entire_packet['PKT_NAME'] != ent_pkt['PKT_NAME']:
                        for cnk in sorted (ent_pkt['LIST'], key=itemgetter('NAME','PKT_INDEX')):
                            #print ("lower: cnk {}   pkt {}".format(cnk['NAME'], ent_pkt['PKT_NAME']))
                            if cnk['NAME'] == chunk['NAME'] and not cnk['LAST_PKT']: # If we have W in multiple packed packets, they will have different encodings // last packet encodings.
                                #print ("inside: cnk {}   pkt {}".format(cnk['NAME'], ent_pkt['PKT_NAME']))
                                cnk['LAST_PKT_INDEX'] = max_pkt_index;
                                cnk['LAST_PKT_ENC']   = max_pkt_enc;

    if global_struct.g_PACKET_DEBUG:
        print ("List of final optimized combination with encodings.  {} packets so {} bit encoding".format(len(local_packet_info), int.bit_length(len(local_packet_info)-1)))
        pprint.pprint (local_packet_info)
        for entire_packet in sorted (local_packet_info, key=itemgetter('ENC')):
            print ("Enc {} PktName {}".format(entire_packet['ENC'], entire_packet['PKT_NAME']))

    return local_packet_info


def calculate_bit_loc_packet(this_is_tx, configuration):

    if this_is_tx:
        if int(configuration['TX_PACKET_MAX_SIZE']) == 0 :
            configuration['TX_PACKET_MAX_SIZE'] = configuration['TOTAL_TX_USABLE_RAWDATA_MAIN']
        local_direction = "output"
    else:
        if int(configuration['RX_PACKET_MAX_SIZE']) == 0 :
            configuration['RX_PACKET_MAX_SIZE'] = configuration['TOTAL_RX_USABLE_RAWDATA_MAIN']
        local_direction = "input"

    ### First, lets figure out how we are going to pack.
    packet_raw_list = list()
    return_credit = 0;
    for llink in configuration['LL_LIST']:
        if llink['DIR'] == local_direction:
            packet_entry = dict()
            packet_entry['NAME']  = llink['NAME']
            packet_entry['WIDTH'] = llink['WIDTH_MAIN']
            if llink['HASVALID']:
                packet_entry['HASVALID'] = True
                packet_entry['WIDTH_W_PUSH'] = llink['WIDTH_MAIN'] + 1
            packet_raw_list.append(packet_entry)
        else:
            if llink['HASREADY']:
                return_credit += 1

    ## We do this twice to hone in on the right packet size // encoding
    iteration = 1
    prev_enc_width = 999999
    current_enc_width = 0
    current_max_data_width = (configuration['TX_PACKET_MAX_SIZE'] if this_is_tx else configuration['RX_PACKET_MAX_SIZE']) - return_credit - current_enc_width

    if current_max_data_width <= 0:
         print("ERROR: Internal Error 2: current_max_data_width is {}. This is a possible artifact of over constraining PACKET_MAX_SIZE\n".format(current_max_data_width))
         sys.exit(1)

    while (current_enc_width != prev_enc_width) :
        if global_struct.g_PACKET_DEBUG:
           print (" Split #{}  current_enc_width:{}  current_max_data_width:{}".format(iteration,current_enc_width,current_max_data_width))
        prev_enc_width = current_enc_width
        packet_size_optimized_list = split_packets(packet_raw_list,current_max_data_width)
        current_enc_width = int.bit_length(len(packet_size_optimized_list)- 1)
        current_max_data_width = (configuration['TX_PACKET_MAX_SIZE'] if this_is_tx else configuration['RX_PACKET_MAX_SIZE']) - return_credit - current_enc_width

        if current_max_data_width <= 0:
            print("ERROR: Internal Error 3: current_max_data_width is {}. This is a possible artifact of over constraining PACKET_MAX_SIZE\n".format(current_max_data_width))
            sys.exit(1)

        iteration += 1
        if iteration > 100:
           print("ERROR: Internal Error 1: packet_packing_lsb:{} != signal_packing_lsb:{}. This is a possible artifact of over constraining PACKET_MAX_SIZE\n".format(packet_packing_lsb, signal_packing_lsb))
           sys.exit(1)

        if global_struct.g_PACKET_DEBUG:
            print (" Try {} Avail Data {} - RetCredits {} = Target PktSize {} + Enc {}".format(iteration, (configuration['TX_PACKET_MAX_SIZE'] if this_is_tx else configuration['RX_PACKET_MAX_SIZE']), return_credit, current_max_data_width, current_enc_width))

    temp_packet_info_list = packetize_algorithm(packet_size_optimized_list, current_max_data_width)

    current_enc_width = int.bit_length(len(temp_packet_info_list) - 1)
    if global_struct.g_PACKET_DEBUG:
       print (" Last Split.  NumEntries={}  BitLen = {}".format (len(temp_packet_info_list), current_enc_width))
    current_max_data_width = (configuration['TX_PACKET_MAX_SIZE'] if this_is_tx else configuration['RX_PACKET_MAX_SIZE']) - return_credit - current_enc_width
    packet_size_optimized_list = split_packets(packet_raw_list,current_max_data_width)
    if global_struct.g_PACKET_DEBUG:
        print (" Last Try Avail Data {} - RetCredits {} = Target PktSize {} + Enc {}".format((configuration['TX_PACKET_MAX_SIZE'] if this_is_tx else configuration['RX_PACKET_MAX_SIZE']), return_credit, current_max_data_width, current_enc_width))

    if this_is_tx:
        global_struct.g_tx_packet_info = packetize_algorithm(packet_size_optimized_list, current_max_data_width)
    else:
        global_struct.g_rx_packet_info = packetize_algorithm(packet_size_optimized_list, current_max_data_width)


    if this_is_tx:
        configuration['TX_PACKET_ID_WIDTH'] = current_enc_width
        configuration['TX_PACKET_NUMBER']   = len(global_struct.g_tx_packet_info)
        configuration['TX_PACKET_OVERHEAD'] = return_credit
        configuration['TX_PACKET_DATAWIDTH'] = current_max_data_width;

        global_struct.g_packet_print_tx.append ("  TX: Total data bits available   {:4}\n".format(configuration['NUM_CHAN'] * (configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] - configuration['CHAN_TX_OVERHEAD_BITS_MAIN'])))

        if int(configuration['TX_PACKET_MAX_SIZE']) != configuration['TOTAL_TX_USABLE_RAWDATA_MAIN'] :
            global_struct.g_packet_print_tx.append ("  TX: Constrained Packet Size     {:4}\n".format(configuration['TX_PACKET_MAX_SIZE']))
        global_struct.g_packet_print_tx.append ("    TX: Header Size               {:4}\n".format(configuration['TX_PACKET_ID_WIDTH']))
        global_struct.g_packet_print_tx.append ("    TX: Packet Data Size          {:4}\n".format(configuration['TX_PACKET_DATAWIDTH']))
        global_struct.g_packet_print_tx.append ("    TX: Common (credit return)    {:4}\n".format(configuration['TX_PACKET_OVERHEAD']))

    else:
        configuration['RX_PACKET_ID_WIDTH'] = current_enc_width
        configuration['RX_PACKET_NUMBER']   = len(global_struct.g_rx_packet_info)
        configuration['RX_PACKET_OVERHEAD'] = return_credit
        configuration['RX_PACKET_DATAWIDTH'] = current_max_data_width;

        global_struct.g_packet_print_rx.append ("  RX: Total data bits available   {:4}\n".format(configuration['NUM_CHAN'] * (configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] - configuration['CHAN_RX_OVERHEAD_BITS_MAIN'])))

        if int(configuration['RX_PACKET_MAX_SIZE']) != configuration['TOTAL_RX_USABLE_RAWDATA_MAIN'] :
            global_struct.g_packet_print_rx.append ("  RX: Constrained Packet Size     {:4}\n".format(configuration['RX_PACKET_MAX_SIZE']))
        global_struct.g_packet_print_rx.append ("    RX: Header Size               {:4}\n".format(configuration['RX_PACKET_ID_WIDTH']))
        global_struct.g_packet_print_rx.append ("    RX: Packet Data Size          {:4}\n".format(configuration['RX_PACKET_DATAWIDTH']))
        global_struct.g_packet_print_rx.append ("    RX: Common (credit return)    {:4}\n".format(configuration['RX_PACKET_OVERHEAD']))


    if global_struct.g_PACKET_DEBUG:
        if this_is_tx:
            print ("global_struct.g_tx_packet_info ************************")
            pprint.pprint (global_struct.g_tx_packet_info)
        else:
            print ("global_struct.g_rx_packet_info ************************")
            pprint.pprint (global_struct.g_rx_packet_info)

    if this_is_tx:
        local_packet_info   = global_struct.g_tx_packet_info
        local_packet_print  = global_struct.g_packet_print_tx
        packet_code_req_tx  = global_struct.g_packet_code_master_req_tx
        packet_code_data_tx = global_struct.g_packet_code_master_data_tx
    else:
        local_packet_info   = global_struct.g_rx_packet_info
        local_packet_print  = global_struct.g_packet_print_rx
        packet_code_req_tx  = global_struct.g_packet_code_slave_req_tx
        packet_code_data_tx = global_struct.g_packet_code_slave_data_tx


    for entire_packet in sorted (local_packet_info, key=itemgetter('ENC')):
        common_lsb=0;
        signal_packing_lsb=0;
        packet_packing_lsb=0;

        local_packet_print.append (" Packet {}:".format(entire_packet['ENC']))
        local_packet_print.append (" "+entire_packet['PKT_NAME'])
        local_packet_print.append ("\n")


        if (configuration['TX_PACKET_ID_WIDTH'] if this_is_tx else configuration['RX_PACKET_ID_WIDTH']) == 0:
            local_packet_print.append ("    no tx_packet_enc {:13} = {:<3}                               // Encoding\n".format("", ""))
        else:
            local_packet_print.append ("    tx_packet_enc    {:13} = {:<3}                               // Encoding\n".format(gen_index_msb((configuration['TX_PACKET_ID_WIDTH'] if this_is_tx else configuration['RX_PACKET_ID_WIDTH']), sysv=global_struct.g_USE_SYSTEMV_INDEXING), entire_packet['ENC']))

        packet_code_req_tx.append ("  assign tx_requestor [{}] = ".format(entire_packet['ENC']))

        if global_struct.g_PACKET_DEBUG:
            print ("entire_packet ************************")
            pprint.pprint (entire_packet)
        first_pushbit = True;
        for chunk in sorted (entire_packet['LIST'], key=itemgetter('WIDTH_W_PUSH','NAME'), reverse=True):
            if global_struct.g_PACKET_DEBUG:
                print ("chunk ************************")
                pprint.pprint (chunk)

            chunk['ENC'] = entire_packet['ENC']

            if first_pushbit == False:
                packet_code_req_tx.append (" | ")

            first_pushbit = False
            if chunk['HASVALID']:
                packet_code_req_tx.append ("{} ".format(gen_llink_concat_pushbit  (chunk['NAME'],"input")))
            else:
                #packet_code_req_tx.append ("({} & {}) | ".format(gen_llink_concat_pushbit  (llink['NAME'],"input"), gen_llink_concat_pushbit  (llink['NAME']+chunk['PKT_INDEX'],"input")))
                packet_code_req_tx.append ("{} ".format(gen_llink_concat_pushbit  (chunk['CHUNK_NAME'],"input")))


            for llink in configuration['LL_LIST']:
                if llink['NAME'] == chunk['NAME']:

                    chunk_wid = chunk['WIDTH']
                    curr_llink_index = int(chunk['LLINK_LSB'])
                    if global_struct.g_PACKET_DEBUG:
                        print (" curr_llink_index {}".format(curr_llink_index))

                    for sig in llink['SIGNALLIST_MAIN']:
                        if sig['TYPE'] == 'valid' or sig['TYPE'] == 'ready':
                            continue

                        if (sig['SIGWID'] + sig['LLINDEX_MAIN_LSB']) < (curr_llink_index) : ## If curr_llink_index is above this signals reach, we don't print the signal
                            if global_struct.g_PACKET_DEBUG:
                                print ("    sig['NAME'] {}  sig['SIGWID'] {} + sig['LLINDEX_MAIN_LSB'] {} = < (curr_llink_index) {} ".format(sig['NAME'], sig['SIGWID'], sig['LLINDEX_MAIN_LSB'], (curr_llink_index)))
                            continue

                        sig_width = min (sig['SIGWID'], sig['SIGWID'] + sig['LLINDEX_MAIN_LSB'] - (curr_llink_index), chunk_wid)
                        if global_struct.g_PACKET_DEBUG:
                            print ("    sig_width {} = min (sig['SIGWID'] {}, sig['SIGWID'] {} + sig['LLINDEX_MAIN_LSB'] {} - (curr_llink_index) {}, chunk_wid {}) ".format(sig_width, sig['SIGWID'], sig['SIGWID'], sig['LLINDEX_MAIN_LSB'], (curr_llink_index), chunk_wid))
                        if sig_width <= 0 :
                            if global_struct.g_PACKET_DEBUG:
                                print ("    sig['NAME'] {}  sig_width{} <= 0".format(sig['NAME'], sig_width))
                            continue

                        sig_lsb = (curr_llink_index) - sig['LLINDEX_MAIN_LSB'] + sig['LSB']
                        if global_struct.g_PACKET_DEBUG:
                            print ("    sig_lsb {} = (curr_llink_index) {} - sig['LLINDEX_MAIN_LSB'] {} + sig['LSB'] {}".format(sig_lsb, (curr_llink_index), sig['LLINDEX_MAIN_LSB'], sig['LSB'] ))

                        local_packet_print.append ("    tx_packet_data{:2} {:13} = {:20}{:13} // Llink Data\n".format(entire_packet['ENC'], gen_index_msb(sig_width, signal_packing_lsb, sysv=global_struct.g_USE_SYSTEMV_INDEXING), sig['NAME'], gen_index_msb(sig_width, sig_lsb, sysv=global_struct.g_USE_SYSTEMV_INDEXING)))
                        if global_struct.g_PACKET_DEBUG:
                            print ("    tx_packet_data{:2} {:13} = {:20}{:13}    // Llink Data\n".format(entire_packet['ENC'], gen_index_msb(sig_width, signal_packing_lsb, sysv=global_struct.g_USE_SYSTEMV_INDEXING), sig['NAME'], gen_index_msb(sig_width, sig_lsb, sysv=global_struct.g_USE_SYSTEMV_INDEXING)))
                        signal_packing_lsb += sig_width
                        curr_llink_index += sig_width
                        chunk_wid -= sig_width

            chunk['FIFODATA_LOC']=packet_packing_lsb
            if chunk['WIDTH'] > 0:
                packet_code_data_tx.append (sprint_verilog_assign ("tx_packet_data"+str(entire_packet['ENC']), gen_llink_concat_fifoname(chunk['NAME'],'input'), gen_index_msb(chunk['WIDTH'], packet_packing_lsb, sysv=global_struct.g_USE_SYSTEMV_INDEXING), gen_index_msb(chunk['WIDTH'], int (chunk['LLINK_LSB']), sysv=global_struct.g_USE_SYSTEMV_INDEXING), comment="Llink Data"))
                if global_struct.g_PACKET_DEBUG:
                    print (sprint_verilog_assign ("tx_packet_data"+str(entire_packet['ENC']), gen_llink_concat_fifoname(chunk['NAME'],'input'), gen_index_msb(chunk['WIDTH'], packet_packing_lsb, sysv=global_struct.g_USE_SYSTEMV_INDEXING), gen_index_msb(chunk['WIDTH'], int (chunk['LLINK_LSB']), sysv=global_struct.g_USE_SYSTEMV_INDEXING), comment="Llink Data"))
                packet_packing_lsb += chunk['WIDTH']

            #if chunk['PKT_INDEX'] == '0': ## Push bits go at bit 0 of LLINK data
            if chunk['HASVALID']:

            #if chunk['FIRST_PKT'] == True:
                local_packet_print.append            ("    tx_packet_data{:2} {:13} = {:20}{:13} // Push Bit\n".format(entire_packet['ENC'], gen_index_msb(1, signal_packing_lsb, sysv=global_struct.g_USE_SYSTEMV_INDEXING), gen_llink_concat_pushbit(chunk['NAME'],local_direction), gen_index_msb(1, -1)))
                packet_code_data_tx.append (sprint_verilog_assign ("tx_packet_data"+str(entire_packet['ENC']), gen_llink_concat_pushbit(chunk['NAME'],'input'), gen_index_msb(1, packet_packing_lsb, sysv=global_struct.g_USE_SYSTEMV_INDEXING), gen_index_msb(1, -1), comment="Push Bit"))
                if global_struct.g_PACKET_DEBUG:
                    print          ("    tx_packet_data{:2} {:13} = {:20}{:13} // Push Bit\n".format(entire_packet['ENC'], gen_index_msb(1, signal_packing_lsb, sysv=global_struct.g_USE_SYSTEMV_INDEXING), gen_llink_concat_pushbit(chunk['NAME'],local_direction), gen_index_msb(1, -1)))
                    print          (sprint_verilog_assign ("tx_packet_data"+str(entire_packet['ENC']), gen_llink_concat_pushbit(chunk['NAME'],'input'), gen_index_msb(1, packet_packing_lsb, sysv=global_struct.g_USE_SYSTEMV_INDEXING), gen_index_msb(1, -1), comment="Push Bit"))
                chunk['PUSHBIT_LOC'] = packet_packing_lsb
                signal_packing_lsb += 1
                packet_packing_lsb += 1

            if packet_packing_lsb != signal_packing_lsb :
                print("ERROR: Internal Error 2: packet_packing_lsb:{} != signal_packing_lsb:{}\n".format(packet_packing_lsb, signal_packing_lsb))
                sys.exit(1)

        packet_code_req_tx.append ("; \n") ## Finish up tx_requestor

        if signal_packing_lsb < (configuration['TX_PACKET_DATAWIDTH'] if this_is_tx else configuration['RX_PACKET_DATAWIDTH']):
            local_packet_print.append ("    tx_packet_data{:2} {:13} = 0                                 // Spare\n".format(entire_packet['ENC'], gen_index_msb((configuration['TX_PACKET_DATAWIDTH'] if this_is_tx else configuration['RX_PACKET_DATAWIDTH']) - signal_packing_lsb, signal_packing_lsb, sysv=global_struct.g_USE_SYSTEMV_INDEXING)))
            signal_packing_lsb += (configuration['TX_PACKET_DATAWIDTH'] if this_is_tx else configuration['RX_PACKET_DATAWIDTH']) - signal_packing_lsb

        if packet_packing_lsb < (configuration['TX_PACKET_DATAWIDTH'] if this_is_tx else configuration['RX_PACKET_DATAWIDTH']):
            packet_code_data_tx.append (sprint_verilog_assign ("tx_packet_data"+str(entire_packet['ENC']), "{}'b0".format((configuration['TX_PACKET_DATAWIDTH'] if this_is_tx else configuration['RX_PACKET_DATAWIDTH']) - packet_packing_lsb), gen_index_msb((configuration['TX_PACKET_DATAWIDTH'] if this_is_tx else configuration['RX_PACKET_DATAWIDTH']) - packet_packing_lsb, packet_packing_lsb, sysv=global_struct.g_USE_SYSTEMV_INDEXING), comment="Spare"))
            packet_packing_lsb += (configuration['TX_PACKET_DATAWIDTH'] if this_is_tx else configuration['RX_PACKET_DATAWIDTH']) - packet_packing_lsb

        for llink in configuration['LL_LIST']:
           if llink['DIR'] != local_direction:
               if llink['HASREADY']:
                   local_packet_print.append ("    tx_packet_common {:13} = {:20}              // Return Credit\n".format(gen_index_msb(1, common_lsb, sysv=global_struct.g_USE_SYSTEMV_INDEXING), gen_llink_concat_credit(llink['NAME'], 'output') ))
                   common_lsb += 1
                   packet_packing_lsb += 1

        remaining_bits_outside_packet = (configuration['NUM_CHAN'] * ((configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if this_is_tx else configuration['CHAN_RX_RAW1PHY_DATA_MAIN']) - (configuration['CHAN_TX_OVERHEAD_BITS_MAIN'] if this_is_tx else configuration['CHAN_RX_OVERHEAD_BITS_MAIN']))) - (configuration['TX_PACKET_ID_WIDTH'] if this_is_tx else configuration['RX_PACKET_ID_WIDTH'])
        if packet_packing_lsb < remaining_bits_outside_packet:
            local_packet_print.append ("    tx_packet_common {:13} = 0                                 // Spare (outside packet)\n".format(gen_index_msb(remaining_bits_outside_packet - packet_packing_lsb, common_lsb, sysv=global_struct.g_USE_SYSTEMV_INDEXING)))
            common_lsb += remaining_bits_outside_packet-1 - packet_packing_lsb
            packet_packing_lsb += remaining_bits_outside_packet-1 - packet_packing_lsb

        packet_code_data_tx.append ("\n")

    ## This generates the fixed allocation info to drive the packet data.
    local_index_wid = 0;
    tx_print_index_lsb = 0;
    rx_print_index_lsb = 0;
    tx_local_index_lsb = 0;
    rx_local_index_lsb = 0;

    tx_print_index_lsb = print_aib_mapping_text(configuration, local_direction, "tx_grant_enc", wid1=(configuration['TX_PACKET_ID_WIDTH'] if this_is_tx else configuration['RX_PACKET_ID_WIDTH']), lsb1=tx_print_index_lsb,  lsb2=0, llink_lsb=0, llink_name="grant_enc")
    local_index_wid += (configuration['TX_PACKET_ID_WIDTH'] if this_is_tx else configuration['RX_PACKET_ID_WIDTH'])
    tx_print_index_lsb = print_aib_mapping_text(configuration, local_direction, "tx_packet_data", wid1=(configuration['TX_PACKET_DATAWIDTH'] if this_is_tx else configuration['RX_PACKET_DATAWIDTH']), lsb1=tx_print_index_lsb,  lsb2=0, llink_lsb=0, llink_name="packet")
    local_index_wid += (configuration['TX_PACKET_DATAWIDTH'] if this_is_tx else configuration['RX_PACKET_DATAWIDTH'])

    for llink in configuration['LL_LIST']:
        if llink['DIR'] != local_direction:
            if llink['HASREADY']:
               local_index_wid += 1
               tx_print_index_lsb = print_aib_mapping_text(configuration, local_direction, gen_llink_concat_credit (llink['NAME'],local_direction), wid1=1, lsb1=tx_print_index_lsb)

    remaining_bits = configuration['NUM_CHAN'] * ((configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if this_is_tx else configuration['CHAN_RX_RAW1PHY_DATA_MAIN']) - (configuration['CHAN_TX_OVERHEAD_BITS_MAIN'] if this_is_tx else configuration['CHAN_RX_OVERHEAD_BITS_MAIN']))
    if (local_index_wid) < remaining_bits:
        if global_struct.USE_SPARE_VECTOR:
            tx_print_index_lsb = print_aib_mapping_text(configuration, local_direction, "spare_"+local_direction, wid1=(remaining_bits) - (local_index_wid), lsb1=tx_print_index_lsb, lsb2=0, llink_lsb=0, llink_name="spare")
            if this_is_tx:
                configuration['TX_SPARE_WIDTH'] = (remaining_bits) - (local_index_wid)
            else:
                configuration['RX_SPARE_WIDTH'] = (remaining_bits) - (local_index_wid)
        else:
            tx_print_index_lsb = print_aib_mapping_text(configuration, local_direction, "1'b0", wid1=(remaining_bits) - (local_index_wid), lsb1=tx_print_index_lsb, lsb2=-1)
            if this_is_tx:
                configuration['TX_SPARE_WIDTH'] = 0
            else:
                configuration['RX_SPARE_WIDTH'] = 0

    if this_is_tx:
        configuration['TOTAL_TX_LLINK_DATA_MAIN'] = configuration['TX_PACKET_MAX_SIZE']
    else:
        configuration['TOTAL_RX_LLINK_DATA_MAIN'] = configuration['RX_PACKET_MAX_SIZE']

    return configuration


