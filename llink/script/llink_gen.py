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
import packetization
import galt

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



##########################################################################################
## Major Structures:
# configuration - dictionary
#               - Contains all configuration and calculated data.
#               - One element is 'LL_LIST' which points to list_logic_links
#
# list_logic_links - list
#                  - List of logiclink
#
# logiclink - dictionary
#           - contains details about a single Logic Link (name, direction, width, etc).
#
# The code has many options (configurations). The "base" code should be the
# logic link without packetization, GALT, Asymmetric Modes. This mode is known as
# "Fixed Allocation" mode
#
# Note internal to this script, we rename several features to shorter names. Specifically:
#
# RSTRUCT = Replicated Struct which is used for Asymmetric Modes
#
# GALT = Alternate Gen - This is used when we have a LLINK that can "dynamically" switch
#                        between Gen2 and Gen1 operations.
#
# Packetizing is ... packetizing (no rename there)
##########################################################################################



## FIXME, add marker or strobe disable for GALT mode




##########################################################################################
## parse_config_file
## As the name implies, we parse the configuration file with this function.
## The result is the configuration dictionary has all of the configuration info in it
## This also builds up the raw information for the logic link.

def parse_config_file(cfgfile):
    if not os.path.exists(cfgfile):
        print("ERROR: File {0} does not exists!!!\n".format(cfgfile))
        sys.exit(1)
    cf = open(cfgfile, "r")

    ## Initialize variables
    linkname = 'null'
    mux_mode = 'MAIN'
    ll_sig_lsb = 0

    configuration = dict()
    list_logic_links = list()

    # Configure Defaults
    configuration["TX_RATE"] = 'Full'
    configuration["RX_RATE"] = 'Full'

    configuration["TX_DBI_PRESENT"] = False
    configuration["RX_DBI_PRESENT"] = False

    configuration['TX_USER_MARKER']           = False
    configuration['TX_USER_STROBE']           = False
    configuration['RX_USER_MARKER']           = False
    configuration['RX_USER_STROBE']           = False

    configuration['TX_ENABLE_MARKER']         = False
    configuration['TX_ENABLE_STROBE']         = False
    configuration['RX_ENABLE_MARKER']         = False
    configuration['RX_ENABLE_STROBE']         = False

    configuration['TX_PERSISTENT_MARKER']     = False
    configuration['RX_PERSISTENT_MARKER']     = False
    configuration['TX_PERSISTENT_STROBE']     = False
    configuration['RX_PERSISTENT_STROBE']     = False

    configuration['TX_STROBE_GEN2_LOC']       = 77
    configuration['RX_STROBE_GEN2_LOC']       = 77
    configuration['TX_MARKER_GEN2_LOC']       = 4
    configuration['RX_MARKER_GEN2_LOC']       = 4
    configuration['TX_STROBE_GEN1_LOC']       = 38
    configuration['RX_STROBE_GEN1_LOC']       = 38
    configuration['TX_MARKER_GEN1_LOC']       = 39
    configuration['RX_MARKER_GEN1_LOC']       = 39

    configuration['TX_STROBE_GEN2_LOC_USER_SPECIFY'] = False
    configuration['RX_STROBE_GEN2_LOC_USER_SPECIFY'] = False
    configuration['TX_MARKER_GEN2_LOC_USER_SPECIFY'] = False
    configuration['RX_MARKER_GEN2_LOC_USER_SPECIFY'] = False
    configuration['TX_STROBE_GEN1_LOC_USER_SPECIFY'] = False
    configuration['RX_STROBE_GEN1_LOC_USER_SPECIFY'] = False
    configuration['TX_MARKER_GEN1_LOC_USER_SPECIFY'] = False
    configuration['RX_MARKER_GEN1_LOC_USER_SPECIFY'] = False

    configuration['RX_REG_PHY']               = False
    configuration['TX_REG_PHY']               = False

    configuration['TX_ENABLE_PACKETIZATION']  = False
    configuration['RX_ENABLE_PACKETIZATION']  = False
    configuration['TX_PACKET_MAX_SIZE']       = 0
    configuration['RX_PACKET_MAX_SIZE']       = 0

    configuration['GEN2_AS_GEN1_EN']                 = False

    configuration['TX_SPARE_WIDTH'] = 0
    configuration['RX_SPARE_WIDTH'] = 0

    configuration['GEN1_USER_CONFIG'] = False
    configuration['GEN2_USER_CONFIG'] = False

    configuration['REPLICATED_STRUCT'] = False
    configuration['RSTRUCT_MULTIPLY_FACTOR'] = 1


    for line_no, line in enumerate(cf):
        ## Remove spaces, empty lines, etc.
        line = line.strip("\n")
        line = re.sub('\t', ' ', line)
        line = re.sub('\s+', ' ', line)
        line = re.sub(' *$', '', line)
        line = re.sub('//.*', '', line)
        line = line.lstrip()
        if re.search("^\s*//", line):
            continue

        if re.search("^\s*$", line):
            continue

        if (global_struct.g_CFG_DEBUG):
            print ("CFGINPUT " , line)

        # Specify defaults for variables
        key   = 'null'
        value = 'null'
        width = 'null'
        lsbit = '0'

        ## Each line should be 4 or fewer fields
        ## This section splits out the fields into 4 values.
        if len(line.split(' ')) > 4:
            print("ERROR: File {0} has more than 4 arguments on line ".format(cfgfile, repr(line_no+1)))
            print (line, line.split(' '))
            sys.exit(1)
        elif len(line.split(' ')) is 0:
            #empty line. Drop
            continue
        elif len(line.split(' ')) is 1:
            key = line
            value = 'null'
            width = 'null'
            lsbit = '0'
        elif len(line.split(' ')) is 2:
            key,value = line.split(' ')
            width = 'null'
            lsbit = '0'
        elif len(line.split(' ')) is 3:
            key,value,width = line.split(' ')
            lsbit = '0'
        elif len(line.split(' ')) is 4:
            key,value,width,lsbit = line.split(' ')

        if (global_struct.g_CFG_DEBUG):
            print ("NEW: key,value,width,lsbit", key,value,width,lsbit)

        if key == "MODULE" or key == "module" :
            configuration[key.upper()] = value.lower()
            continue

        if key == "LLINK" or key == "llink" or key == "name":
            linkname = value.lower()
            mux_mode = 'MAIN'
            continue

        if key == "NUM_CHAN" or key == "NUM_PHY": ## NUM_PHY is deprecated but maintained for backware compatablity
            if key == "NUM_PHY":
                print ("WARNING: NUM_PHY is deprecated. Use NUM_CHAN instead.")
                key = "NUM_CHAN"
            if int(value) > 24:
                print("ERROR: Key {} value {} exceeds max of 24 ".format(key,value))
                sys.exit(1)
            configuration[key] = int(value)
            continue

        if key == "CHAN_TYPE" or key == "PHY_TYPE": ## PHY_TYPE is deprecated but maintained for backware compatablity
            if key == "PHY_TYPE":
                print ("WARNING: PHY_TYPE is deprecated. Use CHAN_TYPE instead.")
                key = "CHAN_TYPE"
            if value != "Gen1Only" and value != "Gen2Only" and value != "Gen2" and value != "AIBO" and value != "Tiered" :
              print("ERROR: Key {} value {} is not Gen1Only or Gen2Only or Gen2 or AIBO or Tiered".format(key,value))
              sys.exit(1)
            configuration[key] = value
            continue

        if key == "TX_RATE" or key == "RX_RATE":
            if value != "Full" and value != "Half" and value != "Quarter" :
              print("ERROR: Key {} value {} is not Full or Half or Quarter ".format(key,value))
              sys.exit(1)
            configuration[key] = value
            continue

        if (  key == "PACKETIZATION_PACKING_EN" )  :

            if value.lower() != "true" and value.lower() != "false" and value.lower() != "yes" and value.lower() != "no" :
              print("ERROR: Key {} value {} is not True or False ".format(key,value))
              sys.exit(1)
            if value.lower() == "true" or value.lower() == "yes" :
              global_struct.g_PACKETIZATION_PACKING_EN = True
            else:
              global_struct.g_PACKETIZATION_PACKING_EN = False
            continue

        if (  key == "REPLICATED_STRUCT" or key == "SUPPORT_ASYMMETRIC")  :
            key = "REPLICATED_STRUCT"
            if value.lower() != "true" and value.lower() != "false" and value.lower() != "yes" and value.lower() != "no" :
              print("ERROR: Key {} value {} is not True or False ".format(key,value))
              sys.exit(1)
            if value.lower() == "true" or value.lower() == "yes" :
              configuration[key] = True
            else:
              configuration[key] = False
            continue

        if (  key == "TX_DBI_PRESENT"             or key == "RX_DBI_PRESENT"             or
              key == "TX_ENABLE_PACKETIZATION"    or key == "RX_ENABLE_PACKETIZATION"    or
              key == "TX_PERSISTENT_STROBE"       or key == "RX_PERSISTENT_STROBE"       or
              key == "TX_PERSISTENT_MARKER"       or key == "RX_PERSISTENT_MARKER"       or
              key == "TX_USER_MARKER"             or key == "RX_USER_MARKER"             or
              key == "TX_USER_STROBE"             or key == "RX_USER_STROBE"             or
              key == "TX_ENABLE_MARKER"           or key == "RX_ENABLE_MARKER"           or
              key == "TX_ENABLE_STROBE"           or key == "RX_ENABLE_STROBE"           or
              key == "TX_REG_PHY"                 or key == "RX_REG_PHY"                 )  :

            if value.lower() != "true" and value.lower() != "false" and value.lower() != "yes" and value.lower() != "no" :
              print("ERROR: Key {} value {} is not True or False ".format(key,value))
              sys.exit(1)
            if value.lower() == "true" or value.lower() == "yes" :
              configuration[key] = True
            else:
              configuration[key] = False
            continue

        if (  key == "TX_PACKET_MAX_SIZE" or key == "RX_PACKET_MAX_SIZE" ):

            configuration[key] = int(value)
            continue

        if (  key == "TX_STROBE_GEN2_LOC" or key == "RX_STROBE_GEN2_LOC" or
              key == "TX_MARKER_GEN2_LOC" or key == "RX_MARKER_GEN2_LOC" ):
            configuration[key+'_USER_SPECIFY'] = True
            configuration[key] = int(value)
            continue

        if (  key == "TX_STROBE_GEN1_LOC" or key == "RX_STROBE_GEN1_LOC" or
              key == "TX_MARKER_GEN1_LOC" or key == "RX_MARKER_GEN1_LOC" ):

            configuration[key+'_USER_SPECIFY'] = True
            configuration[key] = int(value)
            continue

        if key == "{": ## Begin of a Logic LInk
            if linkname == 'null':
                print("ERROR: File {0} is missing link name ".format(cfgfile, repr(line_no+1)))
                sys.exit(1)

            mux_mode = 'MAIN'; ## Default unless told otherwise. Note, Gen1Only will still be called Gen2
            ll_sig_lsb = 0;
            logiclink = {'NAME':linkname,
                         'DIR':'null',
                         'WIDTH_MAIN':0,
                         'WIDTH_GALT':0,
                         'HASVALID':False,
                         'HASREADY':False,
                         'SIGNALLIST_MAIN':[],
                         'SIGNALLIST_GALT':[] }
            continue

        if key.upper() == "GEN2_AS_GEN1" or key.upper() == "MAIN": ## Begin of a GALT Section
            mux_mode = key.upper()
            if mux_mode == "GEN2_AS_GEN1":
                mux_mode = 'GALT'

            if mux_mode == 'GALT' and logiclink['WIDTH_MAIN'] == 0:
                print("ERROR: File {0} is has mux_mode GALT on line {1} before defining MAIN first.".format(cfgfile, repr(line_no+1)))
                sys.exit(1)

            if configuration['CHAN_TYPE'] != 'Gen2' :
                print("ERROR: File {0} is has mux_mode GEN2_AS_GEN1 for MAIN or GALT support on line {1}, but CHAN_TYPE is {2}. CHAN_TYPE must be Gen2 for this feature".format(cfgfile, repr(line_no+1), configuration['CHAN_TYPE']))
                sys.exit(1)

            ll_sig_lsb = 0;
            continue

        if key == '}': ## End of a Logic LInk
            ## Create enables as the last entry of rep struct LL
            if configuration['REPLICATED_STRUCT']:
                onesignal = {'NAME':"user_enable",
                             'DIR':logiclink['DIR'],
                             'TYPE':'rstruct_enable',
                             'SIGWID':1,
                             'MSB':0,
                             'LSB':0 }
                logiclink['WIDTH_RX_RSTRUCT'] = logiclink['WIDTH_MAIN'] + onesignal['SIGWID']   #WIDTH_MAIN WIDTH_GALT assigned here

                onesignal['LLINDEX_MAIN_LSB'] = ll_sig_lsb * configuration['RSTRUCT_MULTIPLY_FACTOR']
                onesignal['LLINDEX_GALT_LSB'] = ll_sig_lsb ## Fixme, maybe we can comibine?
                ll_sig_lsb += onesignal['SIGWID']
                logiclink['SIGNALLIST_'+mux_mode].append(onesignal) # SIGNALLIST_GALT and SIGNALLIST_MAIN assigned here

            list_logic_links.append(logiclink);
            continue


        if key == "TX_FIFO_DEPTH" or key == "RX_FIFO_DEPTH":
            if int(value) > 255:
               print("ERROR: Key {} value {} exceeds max of 255 ".format(key,value))
               sys.exit(1)
            logiclink[key] = value
            continue

        if key == "output" or key == "input": # signals
            if width == "valid":
                logiclink['HASVALID'] = True
                onesignal = {'NAME':value,
                             'DIR':key,
                             'TYPE':'valid',
                             'LLINDEX_'+mux_mode:'null',
                             'SIGWID':1,
                             'MSB':0,
                             'LLINDEX_MAIN_LSB':-1,
                             'LLINDEX_GALT_LSB':-1,
                             'LSB':-1 }

            elif width == "ready":
                logiclink['HASREADY'] = True
                onesignal = {'NAME':value,
                             'DIR':key,
                             'TYPE':'ready',
                             'LLINDEX_'+mux_mode:'null',
                             'SIGWID':1,
                             'MSB':0,
                             'LLINDEX_MAIN_LSB':-1,
                             'LLINDEX_GALT_LSB':-1,
                             'LSB':-1 }
            else:
                if (width == '0'):
                    print("ERROR: File {0} on line {1} has invalid width.".format(cfgfile, repr(line_no+1)))
                    sys.exit(1)

                ## Convert scalers to busses in replciated struct mode
                if configuration['REPLICATED_STRUCT'] and (width == 'null'):
                    width = 1

                if (width == 'null'): # This is for scalers
                    width = 1
                    onesignal = {'NAME':value,
                                 'DIR':key,
                                 'TYPE':'signal',
                                 'SIGWID':1,
                                 'MSB':0,
                                 'LSB':-1 }
                else:
                   width = int(width) - int(lsbit)
                   onesignal = {'NAME':value,
                                'DIR':key,
                                'TYPE':'bus',
                                'SIGWID':width,
                                'MSB':width -1 + int(lsbit),
                                'LSB':int(lsbit) }

                ## If llink direction is not defined, we'll use the first non-valid or ready to determine direction and check the rest after.
                if (logiclink['DIR'] == 'null'):
                    logiclink['DIR'] = key
                elif (logiclink['DIR'] != key):
                    print("ERROR: File {0} on line {1} has mix of inputs or outputs on same logic link.".format(cfgfile, repr(line_no+1)))
                    sys.exit(1)

                logiclink['WIDTH_'+mux_mode] += onesignal['SIGWID']   #WIDTH_MAIN WIDTH_GALT assigned here

                onesignal['LLINDEX_MAIN_LSB'] = ll_sig_lsb
                onesignal['LLINDEX_GALT_LSB'] = ll_sig_lsb ## Fixme, maybe we can comibine?
                ll_sig_lsb += onesignal['SIGWID']

                if (mux_mode == 'GALT'):
                    configuration['GEN2_AS_GEN1_EN'] = True


            logiclink['SIGNALLIST_'+mux_mode].append(onesignal) # SIGNALLIST_GALT and SIGNALLIST_MAIN assigned here

            continue

        print("ERROR: Unknown Key '{}' on line {}\n".format(key,int(line_no)+1))
        sys.exit(1)

    cf.close()
    configuration['LL_LIST'] = list_logic_links
    return configuration

## parse_config_file
##########################################################################################

##########################################################################################
## calc_total_llink_data
## Calculates the Needed Logic Link Data

def calc_total_llink_data(configuration, mux_mode, enable):
    TX_LLINK_DATA = 0
    RX_LLINK_DATA  = 0

    if mux_mode == "RSTRUCT":
        loc_mux_mode = "MAIN"
        loc_print_mux_mode = "RSTRUCT"
    else:
        loc_mux_mode = mux_mode
        loc_print_mux_mode = mux_mode

    if enable :
        for llink in configuration['LL_LIST']:
            current_tx_signals = 0
            current_rx_signals  = 0
            if llink['DIR'] == 'output':
                current_tx_signals += llink['WIDTH_'+loc_mux_mode]
                if llink['HASVALID']:
                    current_tx_signals += 1
                if llink['HASREADY']:
                    current_rx_signals += 1
            else:
                current_rx_signals += llink['WIDTH_'+loc_mux_mode]
                if llink['HASVALID']:
                    current_rx_signals += 1
                if llink['HASREADY']:
                    current_tx_signals += 1

            global_struct.g_info_print.append ("    LogicLink {:8} {:8} TX {:4}  RX {:4}\n".format(loc_print_mux_mode, llink['NAME'], current_tx_signals, current_rx_signals))
            TX_LLINK_DATA += current_tx_signals
            RX_LLINK_DATA += current_rx_signals

        if mux_mode == "RSTRUCT":
            if (configuration['TX_RATE'] == "Full"):
                configuration['RSTRUCT_MULTIPLY_FACTOR'] = 1
            elif (configuration['TX_RATE'] == "Half"):
                configuration['RSTRUCT_MULTIPLY_FACTOR'] = 2
            elif (configuration['TX_RATE'] == "Quarter"):
                configuration['RSTRUCT_MULTIPLY_FACTOR'] = 4

            global_struct.g_info_print.append ("    {:25}        x{}       x{}\n".format("RepStruct in {} Mode".format(configuration['TX_RATE']), configuration['RSTRUCT_MULTIPLY_FACTOR'], configuration['RSTRUCT_MULTIPLY_FACTOR']))

            global_struct.g_info_print.append ("                                -------  -------\n")
            global_struct.g_info_print.append ("    Total     {:8}          TX {:4}  RX {:4}\n".format(loc_print_mux_mode, TX_LLINK_DATA*configuration['RSTRUCT_MULTIPLY_FACTOR'], RX_LLINK_DATA*configuration['RSTRUCT_MULTIPLY_FACTOR']))
        else:
            global_struct.g_info_print.append ("                                -------  -------\n")
            global_struct.g_info_print.append ("    Total     {:8}          TX {:4}  RX {:4}\n".format(loc_print_mux_mode, TX_LLINK_DATA, RX_LLINK_DATA))
        global_struct.g_info_print.append ("\n")

    if mux_mode == "RSTRUCT":
        configuration['TOTAL_TX_LLINK_DATA_'+"RSTRUCT"] = TX_LLINK_DATA # TOTAL_TX_LLINK_DATA_RSTRUCT
        configuration['TOTAL_RX_LLINK_DATA_'+"RSTRUCT"] = RX_LLINK_DATA # TOTAL_RX_LLINK_DATA_RSTRUCT
        configuration['TOTAL_TX_LLINK_DATA_'+loc_mux_mode] = TX_LLINK_DATA * configuration['RSTRUCT_MULTIPLY_FACTOR']# TOTAL_TX_LLINK_DATA_MAIN  TOTAL_TX_LLINK_DATA_GALT
        configuration['TOTAL_RX_LLINK_DATA_'+loc_mux_mode] = RX_LLINK_DATA * configuration['RSTRUCT_MULTIPLY_FACTOR']# TOTAL_RX_LLINK_DATA_MAIN  TOTAL_RX_LLINK_DATA_GALT
    else:
        configuration['TOTAL_TX_LLINK_DATA_'+loc_mux_mode] = TX_LLINK_DATA # TOTAL_TX_LLINK_DATA_MAIN  TOTAL_TX_LLINK_DATA_GALT
        configuration['TOTAL_RX_LLINK_DATA_'+loc_mux_mode] = RX_LLINK_DATA # TOTAL_RX_LLINK_DATA_MAIN  TOTAL_RX_LLINK_DATA_GALT
    return configuration

## calc_total_llink_data
##########################################################################################

##########################################################################################
## calc_raw_1phydata
## Calculates the amount of data that can be placed on a single channel, ignoring any overhead (markers, strobes, DBI, etc)

def calc_raw_1phydata(configuration, mux_mode, enable, use_cfg_rate):

    TX_RAW1PHY_DATA = 0
    RX_RAW1PHY_DATA = 0

    RSTRUCT_RAW1PHY_DATA = 0

    if mux_mode == "RSTRUCT":
        loc_mux_mode = "MAIN"
        loc_print_mux_mode = "RSTRUCT"
    else:
        loc_mux_mode = mux_mode
        loc_print_mux_mode = mux_mode

    if enable :
        if mux_mode == 'RSTRUCT':
            tx_rate = configuration['TX_RATE']
            rx_rate = configuration['RX_RATE']
        elif mux_mode == 'MAIN':
            tx_rate = configuration['TX_RATE']
            rx_rate = configuration['RX_RATE']
        else:
            tx_rate = galt.covert_rate_gen2_as_gen1(configuration['TX_RATE'])
            rx_rate = galt.covert_rate_gen2_as_gen1(configuration['RX_RATE'])

        ## Calculate Channel Width
        if loc_mux_mode == 'MAIN' :
            if configuration['CHAN_TYPE'] == 'Gen2Only' or configuration['CHAN_TYPE'] == 'Gen2':
                TX_RAW1PHY_DATA = 80
            elif configuration['CHAN_TYPE'] == 'Gen1Only' :
                TX_RAW1PHY_DATA = 40
            elif configuration['CHAN_TYPE'] == 'AIBO' :
                TX_RAW1PHY_DATA = 20
            elif configuration['CHAN_TYPE'] == 'Tiered' :
                TX_RAW1PHY_DATA = 9999
        elif loc_mux_mode == 'GALT' :
            if configuration['CHAN_TYPE'] == 'Gen2':
                TX_RAW1PHY_DATA = 40
            else :
                print("ERROR: Unsupported Option for GALT (Gen2asGen1) PhyType = "+configuration['CHAN_TYPE'])
                sys.exit(1)

        if loc_mux_mode == 'MAIN' :
            if configuration['CHAN_TYPE'] == 'Gen2Only' or configuration['CHAN_TYPE'] == 'Gen2':
                RSTRUCT_RAW1PHY_DATA = 80
            elif configuration['CHAN_TYPE'] == 'Gen1Only' :
                RSTRUCT_RAW1PHY_DATA = 40
            elif configuration['CHAN_TYPE'] == 'AIBO' :
                RSTRUCT_RAW1PHY_DATA = 20
            elif configuration['CHAN_TYPE'] == 'Tiered' :
                RSTRUCT_RAW1PHY_DATA = 9999
        elif loc_mux_mode == 'GALT' :
            if configuration['CHAN_TYPE'] == 'Gen2':
                RSTRUCT_RAW1PHY_DATA = 40
            else :
                print("ERROR: Unsupported Option for GALT (Gen2asGen1) PhyType = "+configuration['CHAN_TYPE'])
                sys.exit(1)


        ## By definition, RX PHY = TX PHY
        RX_RAW1PHY_DATA = TX_RAW1PHY_DATA

        configuration['CHAN_TX_RAW1PHY_BEAT_'+loc_mux_mode] = TX_RAW1PHY_DATA  # CHAN_TX_RAW1PHY_BEAT_MAIN or CHAN_TX_RAW1PHY_BEAT_GALT
        configuration['CHAN_RX_RAW1PHY_BEAT_'+loc_mux_mode] = RX_RAW1PHY_DATA  # CHAN_RX_RAW1PHY_BEAT_MAIN or CHAN_RX_RAW1PHY_BEAT_GALT

        if mux_mode == 'RSTRUCT':
            configuration['CHAN_TX_RAW1PHY_BEAT_'+'RSTRUCT'] = TX_RAW1PHY_DATA  # CHAN_TX_RAW1PHY_DATA_RSTRUCT
            configuration['CHAN_RX_RAW1PHY_BEAT_'+'RSTRUCT'] = RX_RAW1PHY_DATA  # CHAN_RX_RAW1PHY_DATA_RSTRUCT

        if tx_rate == 'Full' :
            TX_RAW1PHY_DATA *= 1
        elif tx_rate == 'Half' :
            TX_RAW1PHY_DATA *= 2
        elif tx_rate == 'Quarter' :
            TX_RAW1PHY_DATA *= 4

        if rx_rate == 'Full' :
            RX_RAW1PHY_DATA *= 1
        elif rx_rate == 'Half' :
            RX_RAW1PHY_DATA *= 2
        elif rx_rate == 'Quarter' :
            RX_RAW1PHY_DATA *= 4

    configuration['CHAN_TX_RAW1PHY_DATA_'+loc_mux_mode] = TX_RAW1PHY_DATA  # CHAN_TX_RAW1PHY_DATA_MAIN or CHAN_TX_RAW1PHY_DATA_GALT
    configuration['CHAN_RX_RAW1PHY_DATA_'+loc_mux_mode] = RX_RAW1PHY_DATA  # CHAN_RX_RAW1PHY_DATA_MAIN or CHAN_RX_RAW1PHY_DATA_GALT

    if mux_mode == 'RSTRUCT':
        configuration['CHAN_TX_RAW1PHY_DATA_'+'RSTRUCT'] = configuration['CHAN_TX_RAW1PHY_BEAT_'+'RSTRUCT']  # CHAN_TX_RAW1PHY_DATA_RSTRUCT
        configuration['CHAN_RX_RAW1PHY_DATA_'+'RSTRUCT'] = configuration['CHAN_RX_RAW1PHY_BEAT_'+'RSTRUCT']  # CHAN_RX_RAW1PHY_DATA_RSTRUCT

    if enable :
        if mux_mode == 'RSTRUCT':
            global_struct.g_info_print.append ("  RSTRUCT Sub Channel Info\n")
            global_struct.g_info_print.append ("  Note: RSTRUCT describes the Replicated Struct on a Full rate channel.\n")
            global_struct.g_info_print.append ("        RSTRUCT will be replicated for {} rate per configuration and that is known as MAIN channel\n".format(configuration['TX_RATE']))
            global_struct.g_info_print.append ("\n")
            global_struct.g_info_print.append ("    {}: Each channel is {} PHY running at {} Rate with {} bits\n".format(loc_print_mux_mode, configuration['CHAN_TYPE'] if loc_mux_mode == 'MAIN' else 'Gen1', "Full", RSTRUCT_RAW1PHY_DATA))
            global_struct.g_info_print.append ("    {}: {}x channels\n".format(loc_print_mux_mode, configuration['NUM_CHAN']))
            global_struct.g_info_print.append ("    {}: Total AIB bits is {} bits\n".format(loc_print_mux_mode, configuration['NUM_CHAN'] * RSTRUCT_RAW1PHY_DATA))
            global_struct.g_info_print.append("\n")
            global_struct.g_info_print.append ("  MAIN Channel Info\n")

            global_struct.g_info_print.append ("    {}: Each channel is {} PHY running at {} Rate with {} bits\n".format('MAIN', configuration['CHAN_TYPE'] if loc_mux_mode == 'MAIN' else 'Gen1', tx_rate, configuration['CHAN_TX_RAW1PHY_DATA_'+loc_mux_mode]))
            global_struct.g_info_print.append ("    {}: {}x channels\n".format('MAIN', configuration['NUM_CHAN']))
            global_struct.g_info_print.append ("    {}: Total AIB bits is {} bits\n".format('MAIN', configuration['NUM_CHAN'] * configuration['CHAN_TX_RAW1PHY_DATA_'+loc_mux_mode]))
        else:
            if mux_mode == 'MAIN':
                global_struct.g_info_print.append ("  Channel Info\n")
            else:
                global_struct.g_info_print.append ("  Gen2asGen1 (aka GALT)\n")

            if configuration['CHAN_TX_RAW1PHY_DATA_'+loc_mux_mode] != configuration['CHAN_RX_RAW1PHY_DATA_'+loc_mux_mode]:
                global_struct.g_info_print.append ("    TX:  Each channel is {} PHY running at {} Rate is {} bits\n".format(configuration['CHAN_TYPE'], tx_rate, configuration['CHAN_TX_RAW1PHY_DATA_'+loc_mux_mode]))
                global_struct.g_info_print.append ("    RX:  Each channel is {} PHY running at {} Rate is {} bits\n".format(configuration['CHAN_TYPE'], rx_rate, configuration['CHAN_RX_RAW1PHY_DATA_'+loc_mux_mode]))
            else:
                global_struct.g_info_print.append ("    {}: Each channel is {} PHY running at {} Rate with {} bits\n".format(loc_print_mux_mode, configuration['CHAN_TYPE'] if loc_mux_mode == 'MAIN' else 'Gen1', tx_rate, configuration['CHAN_TX_RAW1PHY_DATA_'+loc_mux_mode]))
                global_struct.g_info_print.append ("    {}: {}x channels\n".format(loc_print_mux_mode, configuration['NUM_CHAN']))
                global_struct.g_info_print.append ("    {}: Total AIB bits is {} bits\n".format(loc_print_mux_mode, configuration['NUM_CHAN'] * configuration['CHAN_TX_RAW1PHY_DATA_'+loc_mux_mode]))
        global_struct.g_info_print.append("\n")

    return configuration

## calc_raw_1phydata
##########################################################################################

##########################################################################################
## calc_overhead_1phydata
## Calculate up the overhead needed for the design (DBI, Markers, etc)

def calc_overhead_1phydata(configuration, mux_mode, enable):
    TX_OVERHEAD_BITS = 0
    RX_OVERHEAD_BITS  = 0
    TX_OVERHEAD_BITS_RSTRUCT = 0
    RX_OVERHEAD_BITS_RSTRUCT  = 0

    if enable :
        if configuration['TX_DBI_PRESENT'] and (mux_mode == 'MAIN' or mux_mode == 'RSTRUCT') and (configuration['CHAN_TYPE'] == 'Gen2Only' or configuration['CHAN_TYPE'] == 'Gen2'):
            TX_OVERHEAD_BITS += configuration['CHAN_TX_RAW1PHY_DATA_'+mux_mode] // 20
            global_struct.g_info_print.append ("       TX: DBI enabled adds {} overhead bits per channel\n".format(configuration['CHAN_TX_RAW1PHY_DATA_'+mux_mode] // 20))
        else:
            global_struct.g_info_print.append ("       TX: No DBI\n")

        if configuration['TX_PERSISTENT_STROBE'] and configuration['TX_ENABLE_STROBE']:
            TX_OVERHEAD_BITS += 1
            global_struct.g_info_print.append ("       TX: Persistent Strobe adds {} overhead bits per channel\n".format(1))
        else:
            global_struct.g_info_print.append ("       TX: Strobe is Recoverable or non-existent\n")

        if configuration['TX_PERSISTENT_MARKER'] and configuration['TX_ENABLE_MARKER']:
            TX_OVERHEAD_BITS += configuration['CHAN_TX_RAW1PHY_DATA_'+mux_mode] // configuration['CHAN_TX_RAW1PHY_BEAT_'+mux_mode]
            global_struct.g_info_print.append ("       TX: Persistent Marker adds {} overhead bits per channel\n".format(configuration['CHAN_TX_RAW1PHY_DATA_'+mux_mode] // configuration['CHAN_TX_RAW1PHY_BEAT_'+mux_mode]))
        else:
            global_struct.g_info_print.append ("       TX: Marker is Recoverable or non-existent\n")

        if mux_mode == 'RSTRUCT':
            global_struct.g_info_print.append ("       TX: Total RSTRUCT overhead bits across {} Full Rate channels is {}\n".format(configuration['NUM_CHAN'], configuration['NUM_CHAN'] * TX_OVERHEAD_BITS))
            global_struct.g_info_print.append ("       TX: Total RSTRUCT data bits available {}\n".format(configuration['NUM_CHAN'] * (configuration['CHAN_TX_RAW1PHY_DATA_'+mux_mode] - TX_OVERHEAD_BITS)))
            global_struct.g_info_print.append ("       TX: Total MAIN overhead bits across {} {} channels is {}\n".format(configuration['NUM_CHAN'], configuration['TX_RATE'], configuration['NUM_CHAN'] * TX_OVERHEAD_BITS * configuration['RSTRUCT_MULTIPLY_FACTOR']))
            global_struct.g_info_print.append ("       TX: Total MAIN data bits available {}\n".format(configuration['NUM_CHAN'] * (configuration['CHAN_TX_RAW1PHY_DATA_'+'MAIN'] - (TX_OVERHEAD_BITS* configuration['RSTRUCT_MULTIPLY_FACTOR']))))
            configuration['CHAN_TX_OVERHEAD_BITS_'+'MAIN'] = TX_OVERHEAD_BITS * configuration['RSTRUCT_MULTIPLY_FACTOR']
        else:
            global_struct.g_info_print.append ("       TX: Total overhead bits across {} channels is {}\n".format(configuration['NUM_CHAN'], configuration['NUM_CHAN'] * TX_OVERHEAD_BITS))
            global_struct.g_info_print.append ("       TX: Total data bits available {}\n".format(configuration['NUM_CHAN'] * (configuration['CHAN_TX_RAW1PHY_DATA_'+mux_mode] - TX_OVERHEAD_BITS)))
        global_struct.g_info_print.append("\n")

    configuration['CHAN_TX_OVERHEAD_BITS_'+mux_mode] = TX_OVERHEAD_BITS

    if enable :
        if configuration['RX_DBI_PRESENT'] and (mux_mode == 'MAIN' or mux_mode == 'RSTRUCT') and (configuration['CHAN_TYPE'] == 'Gen2Only' or configuration['CHAN_TYPE'] == 'Gen2'):
            RX_OVERHEAD_BITS += configuration['CHAN_RX_RAW1PHY_DATA_'+mux_mode] // 20
            global_struct.g_info_print.append ("       RX: DBI enabled adds {} overhead bits per channel\n".format(configuration['CHAN_RX_RAW1PHY_DATA_'+mux_mode] // 20))
        else:
            global_struct.g_info_print.append ("       RX: No DBI\n")

        if configuration['RX_PERSISTENT_STROBE'] and configuration['RX_ENABLE_STROBE']:
            RX_OVERHEAD_BITS += 1
            global_struct.g_info_print.append ("       RX: Persistent Strobe adds {} overhead bits per channel\n".format(1))
        else:
            global_struct.g_info_print.append ("       RX: Strobe is Recoverable or non-existent\n")

        if configuration['RX_PERSISTENT_MARKER'] and configuration['RX_ENABLE_MARKER']:
            RX_OVERHEAD_BITS += configuration['CHAN_RX_RAW1PHY_DATA_'+mux_mode] // configuration['CHAN_RX_RAW1PHY_BEAT_'+mux_mode]
            global_struct.g_info_print.append ("       RX: Persistent Marker adds {} overhead bits per channel\n".format(configuration['CHAN_RX_RAW1PHY_DATA_'+mux_mode] // configuration['CHAN_RX_RAW1PHY_BEAT_'+mux_mode]))
        else:
            global_struct.g_info_print.append ("       RX: Marker is Recoverable or non-existent\n")

        if mux_mode == 'RSTRUCT':
            global_struct.g_info_print.append ("       RX: Total RSTRUCT overhead bits across {} Full Rate channels is {}\n".format(configuration['NUM_CHAN'], configuration['NUM_CHAN'] * RX_OVERHEAD_BITS))
            global_struct.g_info_print.append ("       RX: Total RSTRUCT data bits available {}\n".format(configuration['NUM_CHAN'] * (configuration['CHAN_RX_RAW1PHY_DATA_'+mux_mode] - RX_OVERHEAD_BITS)))
            global_struct.g_info_print.append ("       RX: Total MAIN overhead bits across {} {} channels is {}\n".format(configuration['NUM_CHAN'], configuration['RX_RATE'], configuration['NUM_CHAN'] * RX_OVERHEAD_BITS * configuration['RSTRUCT_MULTIPLY_FACTOR']))
            global_struct.g_info_print.append ("       RX: Total MAIN data bits available {}\n".format(configuration['NUM_CHAN'] * (configuration['CHAN_RX_RAW1PHY_DATA_'+'MAIN'] - (RX_OVERHEAD_BITS* configuration['RSTRUCT_MULTIPLY_FACTOR']))))
            configuration['CHAN_RX_OVERHEAD_BITS_'+'MAIN'] = RX_OVERHEAD_BITS * configuration['RSTRUCT_MULTIPLY_FACTOR']
        else:
            global_struct.g_info_print.append ("       RX: Total overhead bits across {} channels is {}\n".format(configuration['NUM_CHAN'], configuration['NUM_CHAN'] * RX_OVERHEAD_BITS))
            global_struct.g_info_print.append ("       RX: Total data bits available {}\n".format(configuration['NUM_CHAN'] * (configuration['CHAN_RX_RAW1PHY_DATA_'+mux_mode] - RX_OVERHEAD_BITS)))
        global_struct.g_info_print.append("\n")

    configuration['CHAN_RX_OVERHEAD_BITS_'+mux_mode] = RX_OVERHEAD_BITS


    configuration['CHAN_TX_USEABLE1PHY_DATA_'+mux_mode] = configuration['CHAN_TX_RAW1PHY_DATA_'+mux_mode] - configuration['CHAN_TX_OVERHEAD_BITS_'+mux_mode] ## CHAN_TX_USEABLE1PHY_DATA_MAIN
    configuration['CHAN_RX_USEABLE1PHY_DATA_'+mux_mode] = configuration['CHAN_RX_RAW1PHY_DATA_'+mux_mode] - configuration['CHAN_RX_OVERHEAD_BITS_'+mux_mode] ## CHAN_RX_USEABLE1PHY_DATA_MAIN
    configuration['TOTAL_TX_USABLE_RAWDATA_'+mux_mode] = configuration['NUM_CHAN'] * configuration['CHAN_TX_USEABLE1PHY_DATA_'+mux_mode] ## TOTAL_TX_USABLE_RAWDATA_MAIN
    configuration['TOTAL_RX_USABLE_RAWDATA_'+mux_mode] = configuration['NUM_CHAN'] * configuration['CHAN_RX_USEABLE1PHY_DATA_'+mux_mode] ## TOTAL_RX_USABLE_RAWDATA_MAIN
    configuration['TOTAL_TX_ROUNDUP_BIT_'+mux_mode] = configuration['TOTAL_TX_USABLE_RAWDATA_'+mux_mode] - configuration['TOTAL_TX_LLINK_DATA_'+mux_mode] ## TOTAL_TX_ROUNDUP_BIT_MAIN, TOTAL_TX_ROUNDUP_BIT_GALT, TOTAL_TX_ROUNDUP_BIT_RSTRUCT defined here
    configuration['TOTAL_RX_ROUNDUP_BIT_'+mux_mode] = configuration['TOTAL_RX_USABLE_RAWDATA_'+mux_mode] - configuration['TOTAL_RX_LLINK_DATA_'+mux_mode] ## TOTAL_RX_ROUNDUP_BIT_MAIN, TOTAL_RX_ROUNDUP_BIT_GALT, TOTAL_RX_ROUNDUP_BIT_RSTRUCT defined here

    if mux_mode == 'RSTRUCT':
        configuration['CHAN_TX_USEABLE1PHY_DATA_'+'MAIN'] = configuration['CHAN_TX_RAW1PHY_DATA_'+'MAIN'] - configuration['CHAN_TX_OVERHEAD_BITS_'+'MAIN']
        configuration['CHAN_RX_USEABLE1PHY_DATA_'+'MAIN'] = configuration['CHAN_RX_RAW1PHY_DATA_'+'MAIN'] - configuration['CHAN_RX_OVERHEAD_BITS_'+'MAIN']
        configuration['TOTAL_TX_USABLE_RAWDATA_'+'MAIN'] = configuration['NUM_CHAN'] * configuration['CHAN_TX_USEABLE1PHY_DATA_'+'MAIN']
        configuration['TOTAL_RX_USABLE_RAWDATA_'+'MAIN'] = configuration['NUM_CHAN'] * configuration['CHAN_RX_USEABLE1PHY_DATA_'+'MAIN']
        configuration['TOTAL_TX_ROUNDUP_BIT_'+'MAIN'] = configuration['TOTAL_TX_USABLE_RAWDATA_'+'MAIN'] - configuration['TOTAL_TX_LLINK_DATA_'+'MAIN'] ## TOTAL_TX_ROUNDUP_BIT_MAIN
        configuration['TOTAL_RX_ROUNDUP_BIT_'+'MAIN'] = configuration['TOTAL_RX_USABLE_RAWDATA_'+'MAIN'] - configuration['TOTAL_RX_LLINK_DATA_'+'MAIN'] ## TOTAL_RX_ROUNDUP_BIT_MAIN

    if mux_mode == "MAIN":
        if global_struct.USE_SPARE_VECTOR:
            configuration['TX_SPARE_WIDTH'] = configuration['TOTAL_TX_ROUNDUP_BIT_MAIN']
            configuration['RX_SPARE_WIDTH'] = configuration['TOTAL_RX_ROUNDUP_BIT_MAIN']
        else:
            configuration['TX_SPARE_WIDTH'] = 0
            configuration['RX_SPARE_WIDTH'] = 0

    return configuration

## calc_overhead_1phydata
##########################################################################################

##########################################################################################
## check_configuration
## Runs some basic sanity checks on the stated configuration looking for errors
## or inconsistencies.

def check_configuration(configuration, mux_mode):

    err_found = False

    if configuration['CHAN_TYPE'] == "Gen1Only" and configuration['TX_RATE'] == "Quarter":
        print("ERROR: Gen1Only does not support TX_RATE = Quarter")
        err_found = True

    if configuration['CHAN_TYPE'] == "Gen1Only" and configuration['RX_RATE'] == "Quarter":
        print("ERROR: Gen1Only does not support TX_RATE = Quarter")
        err_found = True

    if configuration['CHAN_TYPE'] == "Gen2Only" and configuration['TX_STROBE_GEN1_LOC_USER_SPECIFY'] and not configuration['TX_STROBE_GEN2_LOC_USER_SPECIFY'] :
        print("WARNING: Detected configuration for TX_STROBE_GEN1_LOC but not one for TX_STROBE_GEN2_LOC and Channel Type is Gen2Only.\n         Ignoring Gen1 settings and using default Gen2 settings.\n")

    if configuration['CHAN_TYPE'] == "Gen2Only" and configuration['RX_STROBE_GEN1_LOC_USER_SPECIFY'] and not configuration['RX_STROBE_GEN2_LOC_USER_SPECIFY'] :
        print("WARNING: Detected configuration for RX_STROBE_GEN1_LOC but not one for RX_STROBE_GEN2_LOC and Channel Type is Gen2Only.\n         Ignoring Gen1 settings and using default Gen2 settings.\n")

    if configuration['CHAN_TYPE'] == "Gen1Only" and configuration['TX_STROBE_GEN2_LOC_USER_SPECIFY'] and not configuration['TX_STROBE_GEN1_LOC_USER_SPECIFY'] :
        print("WARNING: Detected configuration for TX_STROBE_GEN2_LOC but not one for TX_STROBE_GEN1_LOC and Channel Type is Gen1Only.\n         Ignoring Gen2 settings and using default Gen1 settings.\n")

    if configuration['CHAN_TYPE'] == "Gen1Only" and configuration['RX_STROBE_GEN2_LOC_USER_SPECIFY'] and not configuration['RX_STROBE_GEN1_LOC_USER_SPECIFY'] :
        print("WARNING: Detected configuration for RX_STROBE_GEN2_LOC but not one for RX_STROBE_GEN1_LOC and Channel Type is Gen1Only.\n         Ignoring Gen2 settings and using default Gen1 settings.\n")


    if configuration['CHAN_TYPE'] == "Gen2Only" and configuration['TX_MARKER_GEN1_LOC_USER_SPECIFY'] and not configuration['TX_MARKER_GEN2_LOC_USER_SPECIFY'] :
        print("WARNING: Detected configuration for TX_MARKER_GEN1_LOC but not one for TX_MARKER_GEN2_LOC and Channel Type is Gen2Only.\n         Ignoring Gen1 settings and using default Gen2 settings.\n")

    if configuration['CHAN_TYPE'] == "Gen2Only" and configuration['RX_MARKER_GEN1_LOC_USER_SPECIFY'] and not configuration['RX_MARKER_GEN2_LOC_USER_SPECIFY'] :
        print("WARNING: Detected configuration for RX_MARKER_GEN1_LOC but not one for RX_MARKER_GEN2_LOC and Channel Type is Gen2Only.\n         Ignoring Gen1 settings and using default Gen2 settings.\n")

    if configuration['CHAN_TYPE'] == "Gen1Only" and configuration['TX_MARKER_GEN2_LOC_USER_SPECIFY'] and not configuration['TX_MARKER_GEN1_LOC_USER_SPECIFY'] :
        print("WARNING: Detected configuration for TX_MARKER_GEN2_LOC but not one for TX_MARKER_GEN1_LOC and Channel Type is Gen1Only.\n         Ignoring Gen2 settings and using default Gen1 settings.\n")

    if configuration['CHAN_TYPE'] == "Gen1Only" and configuration['RX_MARKER_GEN2_LOC_USER_SPECIFY'] and not configuration['RX_MARKER_GEN1_LOC_USER_SPECIFY'] :
        print("WARNING: Detected configuration for RX_MARKER_GEN2_LOC but not one for RX_MARKER_GEN1_LOC and Channel Type is Gen1Only.\n         Ignoring Gen2 settings and using default Gen1 settings.\n")


    if configuration['REPLICATED_STRUCT'] and (configuration['TX_ENABLE_PACKETIZATION'] or configuration['RX_ENABLE_PACKETIZATION']):
        print("ERROR: REPLICATED_STRUCT and TX_ENABLE_PACKETIZATION or RX_ENABLE_PACKETIZATION both enabled. This is not supported.\n")
        err_found = True

    ## This looks odd, but we use "GEN2" below, so if we are in Gen1Only, mark the GEN2 strobe with the Gen1 locations
    if configuration['CHAN_TYPE'] == "Gen1Only":
        configuration['TX_STROBE_GEN2_LOC'] = configuration['TX_STROBE_GEN1_LOC']
        configuration['RX_STROBE_GEN2_LOC'] = configuration['RX_STROBE_GEN1_LOC']
        configuration['TX_MARKER_GEN2_LOC'] = configuration['TX_MARKER_GEN1_LOC']
        configuration['RX_MARKER_GEN2_LOC'] = configuration['RX_MARKER_GEN1_LOC']

    if configuration['CHAN_TYPE'] == "Gen1Only" and configuration ['TX_DBI_PRESENT']:
        print("INFO: DBI not supported in Gen1. Setting TX_DBI_PRESENT to False\n")
        configuration['TX_DBI_PRESENT'] = False

    if configuration['CHAN_TYPE'] == "Gen1Only" and configuration ['RX_DBI_PRESENT']:
        print("INFO: DBI not supported in Gen1. Setting RX_DBI_PRESENT to False\n")
        configuration['RX_DBI_PRESENT'] = False

    if err_found:
        print("Fix above errors and re-run to continue.")
        sys.exit(1)


    ## We shouldn't have a faiure if packetization is chosen.
    if configuration['TX_ENABLE_PACKETIZATION'] == 0 :
        if (configuration['TOTAL_TX_USABLE_RAWDATA_'+mux_mode] < configuration['TOTAL_TX_LLINK_DATA_'+mux_mode]):
            print("ERROR: Not enough TX {} AIB Data bits {} for Fixed Allocation of Logic Link TX Data {} bits.\n".format(mux_mode, configuration['TOTAL_TX_USABLE_RAWDATA_'+mux_mode],configuration['TOTAL_TX_LLINK_DATA_'+mux_mode]))
            sys.exit(1)

        global_struct.g_info_print.append ("  "+mux_mode+" TX needs {:4} bits of data and has {:4} bits available across {}x {} {:} Rate channels so {:4} spare bits\n".format(configuration['TOTAL_TX_LLINK_DATA_'+mux_mode], configuration['TOTAL_TX_USABLE_RAWDATA_'+mux_mode], configuration['NUM_CHAN'], configuration['CHAN_TYPE'], configuration['TX_RATE'], configuration['TOTAL_TX_ROUNDUP_BIT_'+mux_mode] ))
        if (configuration['TOTAL_TX_USABLE_RAWDATA_'+mux_mode] - configuration['TOTAL_TX_LLINK_DATA_'+mux_mode]) > (configuration['CHAN_TX_RAW1PHY_DATA_'+mux_mode] - configuration['CHAN_TX_OVERHEAD_BITS_'+mux_mode]):
            global_struct.g_info_print.append ("  INFORMATION: At least one full channel unused for TX\n")

    if configuration['RX_ENABLE_PACKETIZATION'] == 0 :
        if (configuration['TOTAL_RX_USABLE_RAWDATA_'+mux_mode] < configuration['TOTAL_RX_LLINK_DATA_'+mux_mode]):
            print("ERROR: Not enough RX {} AIB Data bits {} for Fixed Allocation of Logic Link RX Data {} bits.\n".format(mux_mode, configuration['TOTAL_RX_USABLE_RAWDATA_'+mux_mode],configuration['TOTAL_RX_LLINK_DATA_'+mux_mode]))
            sys.exit(1)

        global_struct.g_info_print.append ("  "+mux_mode+" RX needs {:4} bits of data and has {:4} bits available across {}x {} {:} Rate channels so {:4} spare bits\n".format(configuration['TOTAL_RX_LLINK_DATA_'+mux_mode], configuration['TOTAL_RX_USABLE_RAWDATA_'+mux_mode], configuration['NUM_CHAN'], configuration['CHAN_TYPE'], configuration['RX_RATE'], configuration['TOTAL_RX_ROUNDUP_BIT_'+mux_mode] ))
        if (configuration['TOTAL_RX_USABLE_RAWDATA_'+mux_mode] - configuration['TOTAL_RX_LLINK_DATA_'+mux_mode]) > (configuration['CHAN_RX_RAW1PHY_DATA_'+mux_mode] - configuration['CHAN_RX_OVERHEAD_BITS_'+mux_mode]):
            global_struct.g_info_print.append ("  INFORMATION: At least one full channel unused for RX\n")
        global_struct.g_info_print.append("\n")


    if mux_mode == "RSTRUCT":
        if configuration['TX_ENABLE_PACKETIZATION'] == 0 :
            if (configuration['TOTAL_TX_USABLE_RAWDATA_'+'MAIN'] < configuration['TOTAL_TX_LLINK_DATA_'+'MAIN']):
                print("ERROR: Not enough TX {} AIB Data bits {} for Fixed Allocation of Logic Link TX Data {} bits.\n".format('MAIN', configuration['TOTAL_TX_USABLE_RAWDATA_'+'MAIN'],configuration['TOTAL_TX_LLINK_DATA_'+'MAIN']))
                sys.exit(1)

            global_struct.g_info_print.append ("  "+'MAIN'+" TX needs {:4} bits of data and has {:4} bits available across {}x {} {:} Rate channels so {:4} spare bits\n".format(configuration['TOTAL_TX_LLINK_DATA_'+'MAIN'], configuration['TOTAL_TX_USABLE_RAWDATA_'+'MAIN'], configuration['NUM_CHAN'], configuration['CHAN_TYPE'], configuration['TX_RATE'], configuration['TOTAL_TX_ROUNDUP_BIT_'+'MAIN'] ))

        if configuration['RX_ENABLE_PACKETIZATION'] == 0 :
            if (configuration['TOTAL_RX_USABLE_RAWDATA_'+'MAIN'] < configuration['TOTAL_RX_LLINK_DATA_'+'MAIN']):
                print("ERROR: Not enough RX {} AIB Data bits {} for Fixed Allocation of Logic Link RX Data {} bits.\n".format('MAIN', configuration['TOTAL_RX_USABLE_RAWDATA_'+'MAIN'],configuration['TOTAL_RX_LLINK_DATA_'+'MAIN']))
                sys.exit(1)

            global_struct.g_info_print.append ("  "+'MAIN'+" RX needs {:4} bits of data and has {:4} bits available across {}x {} {:} Rate channels so {:4} spare bits\n".format(configuration['TOTAL_RX_LLINK_DATA_'+'MAIN'], configuration['TOTAL_RX_USABLE_RAWDATA_'+'MAIN'], configuration['NUM_CHAN'], configuration['CHAN_TYPE'], configuration['RX_RATE'], configuration['TOTAL_RX_ROUNDUP_BIT_'+'MAIN'] ))
            global_struct.g_info_print.append("\n")

    # Perform Checks
    ############################################################

    ############################################################
    # Check Strobe // Marker placement

    if configuration['TX_ENABLE_MARKER'] == False:
        configuration['TX_PERSISTENT_MARKER'] = True
        configuration['TX_USER_MARKER']       = False
        configuration['TX_MARKER_GEN2_LOC']   = 0
        configuration['TX_MARKER_GEN1_LOC']   = 0

    if configuration['RX_ENABLE_MARKER'] == False:
        configuration['RX_PERSISTENT_MARKER'] = True
        configuration['RX_USER_MARKER']       = False
        configuration['RX_MARKER_GEN2_LOC']   = 0
        configuration['RX_MARKER_GEN1_LOC']   = 0

    if configuration['TX_ENABLE_STROBE'] == False:
        configuration['TX_PERSISTENT_STROBE'] = True
        configuration['TX_USER_STROBE']       = False
        configuration['TX_STROBE_GEN2_LOC']   = 0
        configuration['TX_STROBE_GEN1_LOC']   = 0

    if configuration['RX_ENABLE_STROBE'] == False:
        configuration['RX_PERSISTENT_STROBE'] = True
        configuration['RX_USER_STROBE']       = False
        configuration['RX_STROBE_GEN2_LOC']   = 0
        configuration['RX_STROBE_GEN1_LOC']   = 0

    if int(configuration['TX_STROBE_GEN2_LOC']) >= int(configuration['CHAN_TX_RAW1PHY_DATA_MAIN']) and configuration['TX_ENABLE_STROBE']:
        print ("ERROR TX_STROBE_GEN_LOC = {} is outside TX Channel Width 0-{}".format(configuration['TX_STROBE_GEN2_LOC'], configuration['CHAN_TX_RAW1PHY_DATA_MAIN']-1))
        sys.exit(1)

    if int(configuration['RX_STROBE_GEN2_LOC']) >= int(configuration['CHAN_RX_RAW1PHY_DATA_MAIN']) and configuration['RX_ENABLE_STROBE']:
        print ("ERROR RX_STROBE_GEN_LOC = {} is outside RX Channel Width 0-{}".format(configuration['RX_STROBE_GEN2_LOC'], configuration['CHAN_RX_RAW1PHY_DATA_MAIN']-1))
        sys.exit(1)

    if int(configuration['TX_MARKER_GEN2_LOC']) >= int(configuration['CHAN_TX_RAW1PHY_BEAT_MAIN']) and configuration['TX_ENABLE_MARKER']:
        print ("ERROR TX_MARKER_GEN_LOC = {} is outside TX Full Rate data word which is 0-{}".format(configuration['TX_MARKER_GEN2_LOC'], configuration['CHAN_TX_RAW1PHY_BEAT_MAIN']-1))
        sys.exit(1)

    if int(configuration['RX_MARKER_GEN2_LOC']) >= int(configuration['CHAN_RX_RAW1PHY_BEAT_MAIN']) and configuration['RX_ENABLE_MARKER']:
        print ("ERROR RX_MARKER_GEN_LOC = {} is outside RX Full Rate data word which is 0-{}".format(configuration['RX_MARKER_GEN2_LOC'], configuration['CHAN_RX_RAW1PHY_BEAT_MAIN']-1))
        sys.exit(1)

    # Check Strobe // Marker placement
    ############################################################

    ############################################################
    # Check Strobe // Marker placement / DBI Placement dont' overlap.

    if configuration['TX_ENABLE_MARKER'] and configuration['TX_DBI_PRESENT']:
        if ((configuration['TX_MARKER_GEN2_LOC'] % 80) == 38 or
            (configuration['TX_MARKER_GEN2_LOC'] % 80) == 39 or
            (configuration['TX_MARKER_GEN2_LOC'] % 80) == 78 or
            (configuration['TX_MARKER_GEN2_LOC'] % 80) == 79):
            print ("ERROR TX_MARKER_GEN2_LOC = {} overlaps with DBI".format(configuration['TX_MARKER_GEN2_LOC']))
            sys.exit(1)

    if configuration['RX_ENABLE_MARKER'] and configuration['RX_DBI_PRESENT']:
        if ((configuration['RX_MARKER_GEN2_LOC'] % 80) == 38 or
            (configuration['RX_MARKER_GEN2_LOC'] % 80) == 39 or
            (configuration['RX_MARKER_GEN2_LOC'] % 80) == 78 or
            (configuration['RX_MARKER_GEN2_LOC'] % 80) == 79):
            print ("ERROR RX_MARKER_GEN2_LOC = {} overlaps with DBI".format(configuration['RX_MARKER_GEN2_LOC']))
            sys.exit(1)

    if configuration['TX_ENABLE_STROBE'] and configuration['TX_DBI_PRESENT']:
        if ((configuration['TX_STROBE_GEN2_LOC'] % 80) == 38 or
            (configuration['TX_STROBE_GEN2_LOC'] % 80) == 39 or
            (configuration['TX_STROBE_GEN2_LOC'] % 80) == 78 or
            (configuration['TX_STROBE_GEN2_LOC'] % 80) == 79):
            print ("ERROR TX_STROBE_GEN2_LOC = {} overlaps with DBI".format(configuration['TX_STROBE_GEN2_LOC']))
            sys.exit(1)

    if configuration['RX_ENABLE_STROBE'] and configuration['RX_DBI_PRESENT']:
        if ((configuration['RX_STROBE_GEN2_LOC'] % 80) == 38 or
            (configuration['RX_STROBE_GEN2_LOC'] % 80) == 39 or
            (configuration['RX_STROBE_GEN2_LOC'] % 80) == 78 or
            (configuration['RX_STROBE_GEN2_LOC'] % 80) == 79):
            print ("ERROR RX_STROBE_GEN2_LOC = {} overlaps with DBI".format(configuration['RX_STROBE_GEN2_LOC']))
            sys.exit(1)


    if configuration['TX_ENABLE_MARKER'] and configuration['TX_ENABLE_STROBE'] and (configuration['CHAN_TYPE'] == "Gen2Only" or configuration['CHAN_TYPE'] == "Gen2"):
        if ((configuration['TX_MARKER_GEN2_LOC'] % 80) == (configuration['TX_STROBE_GEN2_LOC'] % 80)):
            print ("ERROR TX_MARKER_GEN2_LOC = {} overlaps with TX_STROBE_GEN2_LOC = {}".format(configuration['TX_MARKER_GEN2_LOC'], configuration['TX_STROBE_GEN2_LOC']))
            sys.exit(1)

    if configuration['RX_ENABLE_MARKER'] and configuration['RX_ENABLE_STROBE'] and (configuration['CHAN_TYPE'] == "Gen2Only" or configuration['CHAN_TYPE'] == "Gen2"):
        if ((configuration['RX_MARKER_GEN2_LOC'] % 80) == (configuration['RX_STROBE_GEN2_LOC'] % 80)):
            print ("ERROR RX_MARKER_GEN2_LOC = {} overlaps with RX_STROBE_GEN2_LOC = {}".format(configuration['RX_MARKER_GEN2_LOC'], configuration['RX_STROBE_GEN2_LOC']))
            sys.exit(1)

    if configuration['TX_ENABLE_MARKER'] and configuration['TX_ENABLE_STROBE'] and (configuration['CHAN_TYPE'] == "Gen1Only" or configuration['CHAN_TYPE'] == "Gen1"):
        if ((configuration['TX_MARKER_GEN1_LOC'] % 80) == (configuration['TX_STROBE_GEN1_LOC'] % 80)):
            print ("ERROR TX_MARKER_GEN1_LOC = {} overlaps with TX_STROBE_GEN1_LOC = {}".format(configuration['TX_MARKER_GEN1_LOC'], configuration['TX_STROBE_GEN1_LOC']))
            sys.exit(1)

    if configuration['RX_ENABLE_MARKER'] and configuration['RX_ENABLE_STROBE'] and (configuration['CHAN_TYPE'] == "Gen1Only" or configuration['CHAN_TYPE'] == "Gen1"):
        if ((configuration['RX_MARKER_GEN1_LOC'] % 80) == (configuration['RX_STROBE_GEN1_LOC'] % 80)):
            print ("ERROR RX_MARKER_GEN1_LOC = {} overlaps with RX_STROBE_GEN1_LOC = {}".format(configuration['RX_MARKER_GEN1_LOC'], configuration['RX_STROBE_GEN1_LOC']))
            sys.exit(1)

    # Check Strobe // Marker placement
    ############################################################

## check_configuration
##########################################################################################

##########################################################################################
## calculate_bit_locations
## This is the branching point for Packetization, GALT, RSTRUCT or "normal" Logic Link

def calculate_bit_locations(configuration):

    if global_struct.g_SIGNAL_DEBUG:
        print ("SIGNAL_DEBUG: Before calculate_bit_loc")
        pprint.pprint (configuration)

    if configuration['TX_ENABLE_PACKETIZATION']:
        configuration = packetization.calculate_bit_loc_packet(True, configuration)
    elif configuration['GEN2_AS_GEN1_EN']:
        configuration = galt.calculate_bit_loc_galt(True, configuration)
    elif configuration['REPLICATED_STRUCT']:
        configuration = calculate_bit_loc_repstruct(True, configuration)
    else:
        configuration = calculate_bit_loc_fixed_alloc(True, configuration)

    if configuration['RX_ENABLE_PACKETIZATION']:
        configuration = packetization.calculate_bit_loc_packet(False, configuration)
    elif configuration['GEN2_AS_GEN1_EN']:
        configuration = galt.calculate_bit_loc_galt(False, configuration)
    elif configuration['REPLICATED_STRUCT']:
        configuration = calculate_bit_loc_repstruct(False, configuration)
    else:
        configuration = calculate_bit_loc_fixed_alloc(False ,configuration)

    return configuration

## calculate_bit_locations
##########################################################################################

##########################################################################################
## calculate_channel_parameters
## Claculate and print the high level parameters of the channel / logic link data.

def calculate_channel_parameters(configuration):

    ############################################################
    # Reduce No Ready case to data only
    for llink in configuration['LL_LIST']:
        if llink['HASVALID'] and not llink['HASREADY']:
            llink['HASVALID'] = False

            ## First, lets find the LLINDEX of the last data bit
            ll_sig_lsb = 0
            for sig in llink['SIGNALLIST_MAIN']:
                if sig['LLINDEX_MAIN_LSB'] > ll_sig_lsb:
                    ll_sig_lsb = sig['LLINDEX_MAIN_LSB']

            ## Then lets turn the Valid into data
            for sig in llink['SIGNALLIST_MAIN']:
                if sig['TYPE'] == 'valid':
                   sig['TYPE'] = 'signal'
                   llink['WIDTH_MAIN'] += 1
                   sig['LLINDEX_MAIN_LSB'] = ll_sig_lsb+1

    # Reduce No Ready case to data only
    ############################################################

    ############################################################
    # Calculate Channel Parameters

    global_struct.g_info_print.append ("  Logic Link Data Info\n")

    enable_main = 1 # default, even for Gen1Only
    enable_galt = 1
    if configuration['CHAN_TYPE'] == 'Gen2Only' or configuration['CHAN_TYPE'] == 'Gen1Only' or configuration['CHAN_TYPE'] == 'AIBO':
        enable_galt = 0
    if configuration['GEN2_AS_GEN1_EN'] != True:
        enable_galt = 0

    if configuration['REPLICATED_STRUCT']:
        configuration = calc_total_llink_data (configuration, 'RSTRUCT', 1)

        configuration = calc_raw_1phydata (configuration, 'RSTRUCT', 1, 1)
        configuration = calc_overhead_1phydata (configuration, 'RSTRUCT', 1)
    else:
        configuration = calc_total_llink_data (configuration, 'MAIN', enable_main)
        configuration = calc_total_llink_data (configuration, 'GALT', enable_galt)

        if configuration['CHAN_TYPE'] == 'Tiered':

            if configuration['TX_PACKET_MAX_SIZE'] == 0:
                configuration['CHAN_TX_RAW1PHY_BEAT_MAIN'] = configuration['TOTAL_TX_LLINK_DATA_MAIN']
                configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] = configuration['TOTAL_TX_LLINK_DATA_MAIN']
            else:
                configuration['CHAN_TX_RAW1PHY_BEAT_MAIN'] = configuration['TX_PACKET_MAX_SIZE']
                configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] = configuration['TX_PACKET_MAX_SIZE']

            if configuration['RX_PACKET_MAX_SIZE'] == 0:
                configuration['CHAN_RX_RAW1PHY_BEAT_MAIN'] = configuration['TOTAL_RX_LLINK_DATA_MAIN']
                configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] = configuration['TOTAL_RX_LLINK_DATA_MAIN']
            else:
                configuration['CHAN_RX_RAW1PHY_BEAT_MAIN'] = configuration['RX_PACKET_MAX_SIZE']
                configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] = configuration['RX_PACKET_MAX_SIZE']

            global_struct.g_info_print.append ("  Channel Info\n")

            if configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] != configuration['CHAN_RX_RAW1PHY_DATA_MAIN']:
                global_struct.g_info_print.append ("    TX:  Each channel is Tiered Mode is {} bits\n".format(configuration['CHAN_TX_RAW1PHY_DATA_MAIN']))
                global_struct.g_info_print.append ("    RX:  Each channel is Tiered Mode is {} bits\n".format(configuration['CHAN_RX_RAW1PHY_DATA_MAIN']))
            else:
                global_struct.g_info_print.append ("    {}: Each channel is Tiered Mode with {} bits\n".format('MAIN', configuration['CHAN_TX_RAW1PHY_DATA_MAIN']))
                global_struct.g_info_print.append ("    {}: {}x channels\n".format('MAIN', configuration['NUM_CHAN']))
                global_struct.g_info_print.append ("    {}: Total AIB bits is {} bits\n".format('MAIN', configuration['NUM_CHAN'] * configuration['CHAN_TX_RAW1PHY_DATA_MAIN']))
            global_struct.g_info_print.append("\n")

            global_struct.g_info_print.append ("       TX: No DBI\n")
            global_struct.g_info_print.append ("       TX: Strobe is Recoverable or non-existent\n")
            global_struct.g_info_print.append ("       TX: Marker is Recoverable or non-existent\n")
            global_struct.g_info_print.append ("       TX: Total overhead bits across {} channels is {}\n".format(configuration['NUM_CHAN'], configuration['NUM_CHAN'] * 0))
            global_struct.g_info_print.append ("       TX: Total data bits available {}\n".format(configuration['NUM_CHAN'] * (configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] - 0)))
            global_struct.g_info_print.append("\n")

            global_struct.g_info_print.append ("       RX: No DBI\n")
            global_struct.g_info_print.append ("       RX: Strobe is Recoverable or non-existent\n")
            global_struct.g_info_print.append ("       RX: Marker is Recoverable or non-existent\n")
            global_struct.g_info_print.append ("       RX: Total overhead bits across {} channels is {}\n".format(configuration['NUM_CHAN'], configuration['NUM_CHAN'] * 0))
            global_struct.g_info_print.append ("       RX: Total data bits available {}\n".format(configuration['NUM_CHAN'] * (configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] - 0)))
            global_struct.g_info_print.append("\n")


            configuration['CHAN_TX_OVERHEAD_BITS_MAIN'] = 0
            configuration['CHAN_RX_OVERHEAD_BITS_MAIN'] = 0


            configuration['CHAN_TX_USEABLE1PHY_DATA_MAIN'] = configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] - configuration['CHAN_TX_OVERHEAD_BITS_MAIN'] ## CHAN_TX_USEABLE1PHY_DATA_MAIN
            configuration['CHAN_RX_USEABLE1PHY_DATA_MAIN'] = configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] - configuration['CHAN_RX_OVERHEAD_BITS_MAIN'] ## CHAN_RX_USEABLE1PHY_DATA_MAIN
            configuration['TOTAL_TX_USABLE_RAWDATA_MAIN'] = configuration['NUM_CHAN'] * configuration['CHAN_TX_USEABLE1PHY_DATA_MAIN'] ## TOTAL_TX_USABLE_RAWDATA_MAIN
            configuration['TOTAL_RX_USABLE_RAWDATA_MAIN'] = configuration['NUM_CHAN'] * configuration['CHAN_RX_USEABLE1PHY_DATA_MAIN'] ## TOTAL_RX_USABLE_RAWDATA_MAIN
            configuration['TOTAL_TX_ROUNDUP_BIT_MAIN'] = configuration['TOTAL_TX_USABLE_RAWDATA_MAIN'] - configuration['TOTAL_TX_LLINK_DATA_MAIN'] ## TOTAL_TX_ROUNDUP_BIT_MAIN, TOTAL_TX_ROUNDUP_BIT_GALT, TOTAL_TX_ROUNDUP_BIT_RSTRUCT defined here
            configuration['TOTAL_RX_ROUNDUP_BIT_MAIN'] = configuration['TOTAL_RX_USABLE_RAWDATA_MAIN'] - configuration['TOTAL_RX_LLINK_DATA_MAIN'] ## TOTAL_RX_ROUNDUP_BIT_MAIN, TOTAL_RX_ROUNDUP_BIT_GALT, TOTAL_RX_ROUNDUP_BIT_RSTRUCT defined here
            configuration['TX_SPARE_WIDTH'] = 0
            configuration['RX_SPARE_WIDTH'] = 0


        else:
           configuration = calc_raw_1phydata (configuration, 'MAIN', enable_main, 1)
           configuration = calc_overhead_1phydata (configuration, 'MAIN', enable_main)

           configuration = calc_raw_1phydata (configuration, 'GALT', enable_galt, 0)
           configuration = calc_overhead_1phydata (configuration, 'GALT', enable_galt)


    # Calculate Channel Parameters
    ############################################################

    ############################################################
    # Perform Checks

    if configuration['REPLICATED_STRUCT']:
        check_configuration(configuration, 'RSTRUCT')
    else:
        if enable_main:
            check_configuration(configuration, 'MAIN')

        if enable_galt:
            check_configuration(configuration, 'GALT')

    return configuration

## calculate_channel_parameters
##########################################################################################

##########################################################################################
## calculate_bit_loc_repstruct
## Bit location calculation for Asymmetric mode (replicated struct, rstruct)

def calculate_bit_loc_repstruct(this_is_tx, configuration):

    if this_is_tx:
      localdir = "output"
      otherdir = "input"
    else:
      localdir = "input"
      otherdir = "output"

    local_index_wid = 0;
    tx_print_index_lsb = 0;
    tx_local_index_lsb = 0;

    config_raw1phy_beat = configuration['CHAN_TX_RAW1PHY_BEAT_MAIN'] if this_is_tx else configuration['CHAN_RX_RAW1PHY_BEAT_MAIN']
    config_raw1phy_data = configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if this_is_tx else configuration['CHAN_RX_RAW1PHY_DATA_MAIN']

    ## Define individual replicated struct push or credits
    for llink in configuration['LL_LIST']:
        if llink['DIR'] == localdir:
            if llink['HASVALID']:
                for rstruct_iteration in list (range (0, configuration['RSTRUCT_MULTIPLY_FACTOR'])):
                    global_struct.g_concat_code_vector_master_tx.append ( sprint_verilog_logic_line (gen_llink_concat_pushbit (llink['NAME'],otherdir)+"_r"+str(rstruct_iteration)) )
                    global_struct.g_concat_code_vector_slave_rx.append  ( sprint_verilog_logic_line (gen_llink_concat_pushbit (llink['NAME'],localdir)+"_r"+str(rstruct_iteration)) )
                global_struct.g_concat_code_vector_master_tx.append ( "\n" )
                global_struct.g_concat_code_vector_slave_rx.append  ( "\n" )
        else:
            if llink['HASREADY']:
                for rstruct_iteration in list (range (0, 4)):
                    global_struct.g_concat_code_vector_master_rx.append ( sprint_verilog_logic_line (gen_llink_concat_credit (llink['NAME'],localdir)+"_r"+str(rstruct_iteration)) )
                    global_struct.g_concat_code_vector_slave_tx.append  ( sprint_verilog_logic_line (gen_llink_concat_credit (llink['NAME'],otherdir)+"_r"+str(rstruct_iteration)) )
                global_struct.g_concat_code_vector_master_rx.append ( "\n" )
                global_struct.g_concat_code_vector_slave_tx.append  ( "\n" )

    for llink in configuration['LL_LIST']:
        if llink['DIR'] == localdir:
            if llink['HASVALID']:
                for rstruct_iteration in list (range (0, configuration['RSTRUCT_MULTIPLY_FACTOR'])):
                    global_struct.g_concat_code_vector_master_tx.append ( sprint_verilog_assign (gen_llink_concat_pushbit (llink['NAME'],otherdir)+"_r"+str(rstruct_iteration), (gen_llink_concat_pushbit (llink['NAME'],otherdir)) ))
                global_struct.g_concat_code_vector_master_tx.append ( "\n" )

                global_struct.g_concat_code_vector_slave_rx.append ( "  assign {:20} = ".format(gen_llink_concat_pushbit (llink['NAME'],localdir)))
                for rstruct_iteration in list (range (0, configuration['RSTRUCT_MULTIPLY_FACTOR'])):
                    global_struct.g_concat_code_vector_slave_rx.append ( "{:20}".format(gen_llink_concat_pushbit (llink['NAME'],localdir)+"_r"+str(rstruct_iteration)) )
                    if rstruct_iteration != configuration['RSTRUCT_MULTIPLY_FACTOR']-1:
                        global_struct.g_concat_code_vector_slave_rx.append ( "|\n         {:20}   ".format(""))
                    else:
                        global_struct.g_concat_code_vector_slave_rx.append ( ";\n")
                global_struct.g_concat_code_vector_slave_rx.append ( "\n" )


        else:
            if llink['HASREADY']:
                global_struct.g_concat_code_vector_master_rx.append ("  // Asymmetric Credit Logic\n")
                for rstruct_iteration in list (range (0, 4)):
                    if rstruct_iteration < configuration['RSTRUCT_MULTIPLY_FACTOR'] and localdir == "input":
                        global_struct.g_concat_code_vector_master_rx.append ( sprint_verilog_assign (gen_llink_concat_credit (llink['NAME'],localdir), gen_llink_concat_credit (llink['NAME'],localdir)+"_r"+str(rstruct_iteration), index1=gen_index_msb(1, rstruct_iteration)   ))
                    else:
                        global_struct.g_concat_code_vector_master_rx.append ( sprint_verilog_assign (gen_llink_concat_credit (llink['NAME'],localdir), "1'b0", index1=gen_index_msb(1, rstruct_iteration)   ))
                global_struct.g_concat_code_vector_master_rx.append ( "\n" )

                global_struct.g_concat_code_vector_slave_tx.append ("  // Asymmetric Credit Logic\n")
                for rstruct_iteration in list (range (0, 4)):
                    if rstruct_iteration < configuration['RSTRUCT_MULTIPLY_FACTOR']:
                       global_struct.g_concat_code_vector_slave_tx.append ( sprint_verilog_assign (gen_llink_concat_credit (llink['NAME'],otherdir)+"_r"+str(rstruct_iteration), (gen_llink_concat_credit (llink['NAME'],otherdir)), index2=gen_index_msb(1, rstruct_iteration) ))
                    #if rstruct_iteration == 0:
                    #    global_struct.g_concat_code_vector_slave_tx.append ( sprint_verilog_assign (gen_llink_concat_credit (llink['NAME'],otherdir)+"_r"+str(rstruct_iteration), "|"+(gen_llink_concat_credit (llink['NAME'],otherdir)) ))
                    else:
                        global_struct.g_concat_code_vector_slave_tx.append ( sprint_verilog_assign (gen_llink_concat_credit (llink['NAME'],otherdir)+"_r"+str(rstruct_iteration), "1'b0") )
                global_struct.g_concat_code_vector_slave_tx.append ( "\n" )


    for rstruct_iteration in list (range (0, configuration['RSTRUCT_MULTIPLY_FACTOR'])):
        tx_print_index_lsb = rstruct_iteration * config_raw1phy_beat

        for llink in configuration['LL_LIST']:
            if llink['DIR'] == localdir:
                if llink['HASVALID']:
                    tx_local_index_lsb += 1
                    tx_print_index_lsb = print_aib_mapping_text(configuration, localdir, gen_llink_concat_pushbit (llink['NAME'],otherdir)+"_r"+str(rstruct_iteration), wid1=1, lsb1=tx_print_index_lsb)

                    if (tx_print_index_lsb % config_raw1phy_beat) == 0:
                        tx_print_index_lsb += config_raw1phy_data - config_raw1phy_beat


                for sig in llink['SIGNALLIST_MAIN']:
                    if sig['TYPE'] == 'valid' or sig['TYPE'] == 'ready':
                        continue
                    if sig['TYPE'] == 'rstruct_enable':
                        continue
                    llink_lsb = sig['LLINDEX_MAIN_LSB'] + (rstruct_iteration * llink['WIDTH_MAIN'])
                    lsb2 = sig['LSB'] + (rstruct_iteration * sig['SIGWID'])
                    for unused1 in list (range (0, sig['SIGWID'])):
                        #lsb2=sig['LSB'] + (sig['SIGWID']*iteration)
                        #llink_lsb=sig['LLINDEX_MAIN_LSB'] + (llink['WIDTH_MAIN']*iteration)
                        tx_local_index_lsb += 1
                        tx_print_index_lsb = print_aib_mapping_text(configuration, localdir, sig['NAME'], wid1=1, lsb1=tx_print_index_lsb,  lsb2=lsb2, llink_lsb=llink_lsb, llink_name=llink['NAME'])
                        if (tx_print_index_lsb % config_raw1phy_beat) == 0:
                            tx_print_index_lsb += config_raw1phy_data - config_raw1phy_beat
                        llink_lsb += 1
                        lsb2 += 1
            else:
                if llink['HASREADY']:
                    #global_struct.g_dv_vector_print.append ("assign {}_f = {};\n".format(gen_llink_concat_credit (llink['NAME'],localdir), tx_local_index_lsb))
                    tx_local_index_lsb += 1
                    tx_print_index_lsb = print_aib_mapping_text(configuration, localdir, gen_llink_concat_credit (llink['NAME'],localdir)+"_r"+str(rstruct_iteration), wid1=1, lsb1=tx_print_index_lsb)
                    if (tx_print_index_lsb % config_raw1phy_beat) == 0:
                        tx_print_index_lsb += config_raw1phy_data - config_raw1phy_beat

        ## This fills in the unused data space
        if this_is_tx:
          local_index_wid = configuration['TOTAL_TX_ROUNDUP_BIT_RSTRUCT']
          tx_local_index_lsb += local_index_wid
          configuration['TX_SPARE_WIDTH'] = 0
        else:
          local_index_wid = configuration['TOTAL_RX_ROUNDUP_BIT_RSTRUCT']
          tx_local_index_lsb += local_index_wid
          configuration['RX_SPARE_WIDTH'] = 0

        for unused1 in list (range (0, local_index_wid)):
            tx_local_index_lsb += 1
            tx_print_index_lsb= print_aib_mapping_text(configuration, localdir,"1'b0", wid1=1, lsb1=tx_print_index_lsb, lsb2=-1)
            if (tx_print_index_lsb % config_raw1phy_beat) == 0:
                tx_print_index_lsb += config_raw1phy_data - config_raw1phy_beat

        ## This fills in the empty space after the data but before the end of the channel (e.g. DBI)
        local_index_wid = config_raw1phy_beat - tx_local_index_lsb
        tx_local_index_lsb += local_index_wid

        for unused1 in list (range (0, local_index_wid)):
            print ("HELLO {}".format(unused1))
            tx_local_index_lsb += 1
            tx_print_index_lsb= print_aib_mapping_text(configuration, localdir,"1'b0", wid1=1, lsb1=tx_print_index_lsb, lsb2=-1)
            if (tx_print_index_lsb % config_raw1phy_beat) == 0:
                tx_print_index_lsb += config_raw1phy_data - config_raw1phy_beat

         #   local_lsb1 = print_aib_assign_text_check_for_aib_bit (configuration, local_lsb1, use_tx, sysv)


    ## The print vectors were messed up by bit blasting. We'll correct it here
    use_tx = True if localdir == "output" else False
    if use_tx:
        #global_struct.g_llink_vector_print_tx.clear()
        del global_struct.g_llink_vector_print_tx [:]
    else:
        #global_struct.g_llink_vector_print_rx.clear()
        del global_struct.g_llink_vector_print_rx [:]

    for rstruct_iteration in list (range (0, configuration['RSTRUCT_MULTIPLY_FACTOR'])):

        tx_print_index_lsb = rstruct_iteration * config_raw1phy_beat

        for llink in configuration['LL_LIST']:
            if llink['DIR'] == localdir:
                use_tx = True if localdir == "output" else False

                for sig in llink['SIGNALLIST_MAIN']:
                    if sig['TYPE'] == 'valid' or sig['TYPE'] == 'ready':
                        continue
                    if use_tx:
                        if llink_lsb != -1:
                            global_struct.g_llink_vector_print_tx.append ("  assign {0:20} {1:13} = {2:20} {3:13}\n".format(gen_llink_concat_fifoname (llink['NAME'],"input" ), gen_index_msb (sig['SIGWID'], sig['LLINDEX_MAIN_LSB'] + (rstruct_iteration * llink['WIDTH_MAIN'])), sig['NAME'], gen_index_msb (sig['SIGWID'], sig['LSB'] + (rstruct_iteration * sig['SIGWID']))))
                    else:
                        if llink_lsb != -1:
                            global_struct.g_llink_vector_print_rx.append ("  assign {0:20} {1:13} = {2:20} {3:13}\n".format(gen_llink_concat_fifoname (llink['NAME'],"output"), gen_index_msb (sig['SIGWID'], sig['LLINDEX_MAIN_LSB'] + (rstruct_iteration * llink['WIDTH_MAIN'])), sig['NAME'], gen_index_msb (sig['SIGWID'], sig['LSB'] + (rstruct_iteration * sig['SIGWID']))))

    return configuration

## calculate_bit_loc_repstruct
##########################################################################################

##########################################################################################
## calculate_bit_loc_fixed_alloc
## Calculate fixed allocation bit locations

def calculate_bit_loc_fixed_alloc(this_is_tx, configuration):

    # For this calculation, we assign a single vector which is a linear range of TOTAL_[T|R]X_USABLE_RAWDATA_GEN[2|1]
    # The later processes will split this into per channel
    # Gen1 signals are assigned first and MAIN SIGWID are reduced to account for these being in "GALT" then
    # the remaining Gen2 signals are assigned

    if this_is_tx:
      localdir = "output"
      otherdir = "input"
    else:
      localdir = "input"
      otherdir = "output"

    local_index_wid = 0;
    tx_print_index_lsb = 0;
    rx_print_index_lsb = 0;
    tx_local_index_lsb = 0;
    rx_local_index_lsb = 0;

    for llink in configuration['LL_LIST']:
        if llink['DIR'] == localdir:
            if llink['HASVALID']:
                local_index_wid = 1
                llink['PUSH_RAW_INDEX_MAIN'] = gen_index_msb(local_index_wid, tx_local_index_lsb)
                llink['PUSH_RAW_LSB_MAIN']   = tx_local_index_lsb

                tx_local_index_lsb += local_index_wid
                tx_print_index_lsb = print_aib_mapping_text(configuration, localdir, gen_llink_concat_pushbit (llink['NAME'],otherdir), wid1=1, lsb1=tx_print_index_lsb)

            local_index_wid = llink['WIDTH_MAIN']
            llink['DATA_RAW_INDEX_MAIN'] = gen_index_msb(local_index_wid, tx_local_index_lsb)
            llink['DATA_RAW_LSB_MAIN']   = tx_local_index_lsb
            tx_local_index_lsb += local_index_wid
            for sig in llink['SIGNALLIST_MAIN']:
                if sig['TYPE'] == 'valid' or sig['TYPE'] == 'ready':
                    continue
                tx_print_index_lsb = print_aib_mapping_text(configuration, localdir, sig['NAME'], wid1=sig['SIGWID'], lsb1=tx_print_index_lsb,  lsb2=sig['LSB'], llink_lsb=sig['LLINDEX_MAIN_LSB'], llink_name=llink['NAME'])
        else:
            if llink['HASREADY']:
                local_index_wid = 1
                llink['CREDIT_RAW_INDEX_MAIN'] = gen_index_msb(local_index_wid, tx_local_index_lsb)
                llink['CREDIT_RAW_LSB_MAIN']   = tx_local_index_lsb
                #global_struct.g_dv_vector_print.append ("assign {}_f = {};\n".format(gen_llink_concat_credit (llink['NAME'],localdir), tx_local_index_lsb))
                tx_local_index_lsb += local_index_wid
                tx_print_index_lsb = print_aib_mapping_text(configuration, localdir, gen_llink_concat_credit (llink['NAME'],localdir), wid1=1, lsb1=tx_print_index_lsb)

    if this_is_tx:
      local_index_wid = configuration['TOTAL_TX_ROUNDUP_BIT_MAIN']
      tx_local_index_lsb += local_index_wid
      if configuration['TOTAL_TX_ROUNDUP_BIT_MAIN'] :
          if global_struct.USE_SPARE_VECTOR:
              tx_print_index_lsb= print_aib_mapping_text(configuration, localdir,"spare_"+localdir, wid1=configuration['TOTAL_TX_ROUNDUP_BIT_MAIN'], lsb1=tx_print_index_lsb, lsb2=0, llink_lsb=0, llink_name="spare")
              configuration['TX_SPARE_WIDTH'] = configuration['TOTAL_TX_ROUNDUP_BIT_MAIN']
          else:
              tx_print_index_lsb= print_aib_mapping_text(configuration, localdir,"1'b0", wid1=configuration['TOTAL_TX_ROUNDUP_BIT_MAIN'], lsb1=tx_print_index_lsb, lsb2=-1)
              configuration['TX_SPARE_WIDTH'] = 0
    else:
      local_index_wid = configuration['TOTAL_RX_ROUNDUP_BIT_MAIN']
      tx_local_index_lsb += local_index_wid
      if configuration['TOTAL_RX_ROUNDUP_BIT_MAIN'] :
          if global_struct.USE_SPARE_VECTOR:
              tx_print_index_lsb= print_aib_mapping_text(configuration, localdir,"spare_"+localdir, wid1=configuration['TOTAL_RX_ROUNDUP_BIT_MAIN'], lsb1=tx_print_index_lsb, lsb2=0, llink_lsb=0, llink_name="spare")
              configuration['RX_SPARE_WIDTH'] = configuration['TOTAL_RX_ROUNDUP_BIT_MAIN']
          else:
              tx_print_index_lsb= print_aib_mapping_text(configuration, localdir,"1'b0", wid1=configuration['TOTAL_RX_ROUNDUP_BIT_MAIN'], lsb1=tx_print_index_lsb, lsb2=-1)
              configuration['RX_SPARE_WIDTH'] = 0

    return configuration

## calculate_bit_loc_fixed_alloc
##########################################################################################

##########################################################################################
## make_name_file
## Generate name files

def make_name_file(configuration):

    for direction in ['master', 'slave']:
        name_file_name   = "{}_{}_name".format(configuration['MODULE'], direction)
        file_name       = open("{}/{}.sv".format(configuration['OUTPUT_DIR'], name_file_name), "w+")
        print_verilog_header(file_name)
        file_name.write("module {}  (\n".format(name_file_name))

        first_line = True;

        # List User Signals
        for llink in configuration['LL_LIST']:
           #if (llink['WIDTH_GALT'] != 0) and (llink['WIDTH_MAIN'] != 0):
           #    file_name.write("\n  // {0} channel\n".format(llink['NAME']))
           #    for sig_gen2 in llink['SIGNALLIST_MAIN']:
           #        found_gen1_match = 0;
           #        for sig_gen1 in llink['SIGNALLIST_GALT']:
           #            if sig_gen2['NAME'] == sig_gen1['NAME']:
           #                found_gen1_match = 1
           #                localdir = gen_direction(name_file_name, sig_gen2['DIR'])
           #                print_verilog_io_line(file_name, localdir, sig_gen2['NAME'], index=gen_index_msb(sig_gen2['SIGWID'] + sig_gen1['SIGWID'],sig_gen1['LSB'], sysv=False))
           #        if found_gen1_match == 0:
           #            localdir = gen_direction(name_file_name, sig_gen2['DIR'])
           #            print_verilog_io_line(file_name, localdir, sig_gen2['NAME'], index=gen_index_msb(sig_gen2['SIGWID'],sig_gen2['LSB'], sysv=False))
           #
           #else:
                localdir = gen_direction(name_file_name, llink['DIR'], True)
                file_name.write("\n  // {0} channel\n".format(llink['NAME']))
                for sig_gen2 in llink['SIGNALLIST_MAIN']:
                    if sig_gen2['TYPE'] == "rstruct_enable" and localdir == 'output':
                        continue
                    localdir = gen_direction(name_file_name, sig_gen2['DIR'])
                    print_verilog_io_line(file_name, localdir, sig_gen2['NAME'], index=gen_index_msb(sig_gen2['SIGWID'] * configuration['RSTRUCT_MULTIPLY_FACTOR'],sig_gen2['LSB'], sysv=False))

        # List Logic Link Signals
        file_name.write("\n  // Logic Link Interfaces\n")
        for llink in configuration['LL_LIST']:
            if first_line:
                first_line = False
            else:
                file_name.write("\n")

            localdir = gen_direction(name_file_name, llink['DIR'], True)

            if llink['HASVALID']:
                print_verilog_io_line(file_name, gen_direction(name_file_name, llink['DIR'], True),  gen_llink_user_valid    (llink['NAME']         ))

            if localdir == 'output':
                print_verilog_io_line(file_name, gen_direction(name_file_name, llink['DIR'], True),  gen_llink_user_fifoname (llink['NAME'],localdir), gen_index_msb(llink['WIDTH_MAIN']       * configuration['RSTRUCT_MULTIPLY_FACTOR'], sysv=False))
            else:
                if configuration['REPLICATED_STRUCT']:
                    print_verilog_io_line(file_name, gen_direction(name_file_name, llink['DIR'], True),  gen_llink_user_fifoname (llink['NAME'],localdir), gen_index_msb(llink['WIDTH_RX_RSTRUCT'] * configuration['RSTRUCT_MULTIPLY_FACTOR'], sysv=False))
                else:
                    print_verilog_io_line(file_name, gen_direction(name_file_name, llink['DIR'], True),  gen_llink_user_fifoname (llink['NAME'],localdir), gen_index_msb(llink['WIDTH_MAIN'] * configuration['RSTRUCT_MULTIPLY_FACTOR'], sysv=False))
            if llink['HASREADY']:
                print_verilog_io_line(file_name, gen_direction(name_file_name, llink['DIR'], False), gen_llink_user_ready    (llink['NAME']         ))

        file_name.write("\n")
        print_verilog_io_line(file_name, "input", "m_gen2_mode", comma=False)
        file_name.write("\n);\n")

        file_name.write("\n  // Connect Data\n")
        for llink in configuration['LL_LIST']:
          file_name.write("\n")

          localdir = gen_direction(name_file_name, llink['DIR'], True);

          if localdir == 'output':
              if llink['HASVALID']:
                  for sig in llink['SIGNALLIST_MAIN']:
                      if sig['TYPE'] == 'valid':
                          print_verilog_assign(file_name, gen_llink_user_valid (llink['NAME']), sig['NAME'])
              else:
                  print_verilog_assign(file_name, gen_llink_user_valid (llink['NAME']), "1'b1", comment=gen_llink_user_valid (llink['NAME'])  + " is unused" )

              if llink['HASREADY']:
                  for sig in llink['SIGNALLIST_MAIN']:
                      if sig['TYPE'] == 'ready':
                          print_verilog_assign(file_name, sig['NAME'], gen_llink_user_ready (llink['NAME']))
              else:
                  file_name.write("  // "+ gen_llink_user_ready (llink['NAME']) +" is unused\n")

              for rstruct_iteration in list (range (0, configuration['RSTRUCT_MULTIPLY_FACTOR'])):
                  for sig in llink['SIGNALLIST_MAIN']:
                      if sig['TYPE'] == 'signal' or sig['TYPE'] == 'bus':
                          print_verilog_assign(file_name, gen_llink_user_fifoname (llink['NAME'], localdir), sig['NAME'], index1=gen_index_msb (sig['SIGWID'], sig['LLINDEX_MAIN_LSB'] + (rstruct_iteration * llink['WIDTH_MAIN'])), index2=gen_index_msb(sig['SIGWID'], sig['LSB'] + (rstruct_iteration * sig['SIGWID'])))
                      #if sig['TYPE'] == 'rstruct_enable' and localdir == 'input':
                      #    print_verilog_assign(file_name, gen_llink_user_fifoname (llink['NAME'], localdir), sig['NAME'], index1=gen_index_msb (sig['SIGWID'], sig['LLINDEX_MAIN_LSB'] + rstruct_iteration + (configuration['RSTRUCT_MULTIPLY_FACTOR'] * llink['WIDTH_MAIN'])), index2=gen_index_msb(sig['SIGWID'], sig['LSB'] + (rstruct_iteration * sig['SIGWID'])))

              #print_verilog_assign(file_name, gen_llink_user_fifoname (llink['NAME'], localdir), "'0", index1=gen_index_msb(llink['WIDTH_MAIN']-llink['WIDTH_GALT'], llink['WIDTH_GALT']))
              #file_name.write("  assign "+gen_llink_user_fifoname (llink['NAME'], localdir)+" = m_gen2_mode ? "+gen_llink_user_fifoname (llink['NAME'], localdir)+" : "+gen_llink_user_fifoname (llink['NAME'], localdir)+";\n")

          else: # if llink['DIR'] == 'output':

              if llink['HASVALID']:
                  for sig in llink['SIGNALLIST_MAIN']:
                      if sig['TYPE'] == 'valid':
                          print_verilog_assign(file_name, sig['NAME'], gen_llink_user_valid (llink['NAME']))
              else:
                  file_name.write("  // "+ gen_llink_user_valid (llink['NAME']) +" is unused\n")

              if  llink['HASREADY']:
                    for sig in llink['SIGNALLIST_MAIN']:
                       if sig['TYPE'] == 'ready':
                            print_verilog_assign(file_name, gen_llink_user_ready (llink['NAME']), sig['NAME'])
              else:
                  print_verilog_assign(file_name, gen_llink_user_ready (llink['NAME']), "1'b1", comment=gen_llink_user_ready (llink['NAME'])  + " is unused" )

              for rstruct_iteration in list (range (0, configuration['RSTRUCT_MULTIPLY_FACTOR'])):
                  for sig in llink['SIGNALLIST_MAIN']:
                      if sig['TYPE'] == 'signal' or sig['TYPE'] == 'bus':
                          print_verilog_assign(file_name, sig['NAME'], gen_llink_user_fifoname (llink['NAME'], localdir), index1=gen_index_msb(sig['SIGWID'], sig['LSB'] + (rstruct_iteration * sig['SIGWID'])), index2=gen_index_msb (sig['SIGWID'], sig['LLINDEX_MAIN_LSB'] + (rstruct_iteration * llink['WIDTH_MAIN'])))
                      if sig['TYPE'] == 'rstruct_enable' and localdir == 'input':
                          print_verilog_assign(file_name, sig['NAME'], gen_llink_user_fifoname (llink['NAME'], localdir), index1=gen_index_msb(sig['SIGWID'], sig['LSB'] + rstruct_iteration) , index2=gen_index_msb (sig['SIGWID'], (sig['LLINDEX_MAIN_LSB'] * configuration['RSTRUCT_MULTIPLY_FACTOR']) + rstruct_iteration))

####            for sig in llink['SIGNALLIST_MAIN']:
####                if sig['TYPE'] == 'signal' or sig['TYPE'] == 'bus':
####                    print_verilog_assign(file_name, gen_llink_user_fifoname (llink['NAME'], localdir), sig['NAME'], index1=sig['LLINDEX_MAIN'], index2=gen_index_msb(sig['SIGWID'],sig['LSB']))
####
####            for sig in llink['SIGNALLIST_GALT']:
####                if sig['TYPE'] == 'signal' or sig['TYPE'] == 'bus':
####                    print_verilog_assign(file_name, gen_llink_user_fifoname (llink['NAME'], localdir), sig['NAME'], index1=sig['LLINDEX_GALT'], index2=gen_index_msb(sig['SIGWID'],sig['LSB']))
####            print_verilog_assign(file_name, gen_llink_user_fifoname (llink['NAME'], localdir), "'0", index1=gen_index_msb(llink['WIDTH_MAIN']-llink['WIDTH_GALT'], llink['WIDTH_GALT']))
####            file_name.write("  assign "+gen_llink_user_fifoname (llink['NAME'], localdir)+" = m_gen2_mode ? "+gen_llink_user_fifoname (llink['NAME'], localdir)+" : "+gen_llink_user_fifoname (llink['NAME'], localdir)+";\n")
####        else: # if llink['DIR'] == 'output':
####
####            if llink['HASVALID']:
####                for sig in llink['SIGNALLIST_MAIN']:
####                    if sig['TYPE'] == 'valid':
####                        print_verilog_assign(file_name, sig['NAME'], gen_llink_user_valid (llink['NAME']))
####            else:
####                file_name.write("  // "+ gen_llink_user_valid (llink['NAME']) +" is unused\n")
####
####            if  llink['HASREADY']:
####                  for sig in llink['SIGNALLIST_MAIN']:
####                     if sig['TYPE'] == 'ready':
####                          print_verilog_assign(file_name, gen_llink_user_ready (llink['NAME']), sig['NAME'])
####            else:
####                print_verilog_assign(file_name, gen_llink_user_ready (llink['NAME']), "1'b1", comment=gen_llink_user_ready (llink['NAME'])  + " is unused" )
####
####            for sig in llink['SIGNALLIST_MAIN']:
####                if sig['TYPE'] == 'signal' or sig['TYPE'] == 'bus':
####                    print_verilog_assign(file_name, sig['NAME'], gen_llink_user_fifoname (llink['NAME'], localdir), index1=gen_index_msb(sig['SIGWID'],sig['LSB']), index2=sig['LLINDEX_MAIN'])
####
####            for sig in llink['SIGNALLIST_GALT']:
####                if sig['TYPE'] == 'signal' or sig['TYPE'] == 'bus':
####                      print_verilog_assign(file_name, sig['NAME'], gen_llink_user_fifoname (llink['NAME'], localdir), index1=gen_index_msb(sig['SIGWID'],sig['LSB']), index2=sig['LLINDEX_GALT'])



        file_name.write("\n")
        file_name.write("endmodule\n")
        file_name.close()
    return

## make_name_file
##########################################################################################

##########################################################################################
## make_concat_file
## Generate concat file

def make_concat_file(configuration):

    for direction in ['master', 'slave']:
        name_file_name   = "{}_{}_concat".format(configuration['MODULE'], direction)
        file_name       = open("{}/{}.sv".format(configuration['OUTPUT_DIR'], name_file_name), "w+")
        print_verilog_header(file_name)
        file_name.write("module {}  (\n".format(name_file_name))

        # Logic Link Signaling
        file_name.write("\n// Data from Logic Links\n")
        if direction == 'master':
            localdir = 'output';
        else:
            localdir = 'input';

        for llink in configuration['LL_LIST']:
            if configuration['REPLICATED_STRUCT'] and gen_direction(name_file_name, llink['DIR'], False) == "input":
                print_verilog_io_line(file_name, gen_direction(name_file_name, llink['DIR'], True),  gen_llink_concat_fifoname (llink['NAME'],gen_direction(name_file_name, llink['DIR'], True)), gen_index_msb(llink['WIDTH_RX_RSTRUCT'] * configuration['RSTRUCT_MULTIPLY_FACTOR'], sysv=False))
            else:
                print_verilog_io_line(file_name, gen_direction(name_file_name, llink['DIR'], True),  gen_llink_concat_fifoname (llink['NAME'],gen_direction(name_file_name, llink['DIR'], True)), gen_index_msb(llink['WIDTH_MAIN'] * configuration['RSTRUCT_MULTIPLY_FACTOR'], sysv=False))
            print_verilog_io_line(file_name, "output",                                           gen_llink_concat_ovrd     (llink['NAME'],gen_direction(name_file_name, llink['DIR'], True)))
            if llink['HASVALID']:
                print_verilog_io_line(file_name, gen_direction(name_file_name, llink['DIR'], True),  gen_llink_concat_pushbit  (llink['NAME'],gen_direction(name_file_name, llink['DIR'], True)) )
            if llink['HASREADY']:
                if configuration['REPLICATED_STRUCT']:
                    print_verilog_io_line(file_name, gen_direction(name_file_name, llink['DIR'], False), gen_llink_concat_credit   (llink['NAME'],gen_direction(name_file_name, llink['DIR'], True)), gen_index_msb(4, sysv=False))
                else:
                    print_verilog_io_line(file_name, gen_direction(name_file_name, llink['DIR'], False), gen_llink_concat_credit   (llink['NAME'],gen_direction(name_file_name, llink['DIR'], True)))
            file_name.write("\n")

        file_name.write("// PHY Interconnect\n")
        # Logic Link Inputs
        for phy in range(configuration['NUM_CHAN']):
            print_verilog_io_line(file_name, "output", "tx_phy{}".format(phy), gen_index_msb(configuration['CHAN_TX_RAW1PHY_DATA_MAIN'], sysv=False))
            print_verilog_io_line(file_name, "input",  "rx_phy{}".format(phy), gen_index_msb(configuration['CHAN_RX_RAW1PHY_DATA_MAIN'], sysv=False))

        file_name.write("\n")
        print_verilog_io_line(file_name, "input",  "clk_wr")
        print_verilog_io_line(file_name, "input",  "clk_rd")
        print_verilog_io_line(file_name, "input",  "rst_wr_n")
        print_verilog_io_line(file_name, "input",  "rst_rd_n")
        file_name.write("\n")
        print_verilog_io_line(file_name, "input",  "m_gen2_mode")
        print_verilog_io_line(file_name, "input",  "tx_online")
        file_name.write("\n")
        #print_verilog_io_line(file_name, "output",  "rx_stb_userbit", gen_index_msb(configuration['NUM_CHAN'], sysv=False))
        #print_verilog_io_line(file_name, "output",  "rx_mrk_userbit", gen_index_msb(configuration['NUM_CHAN'], sysv=False))
        print_verilog_io_line(file_name, "input",  "tx_stb_userbit")
        print_verilog_io_line(file_name, "input",  "tx_mrk_userbit", gen_index_msb(configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] // configuration['CHAN_RX_RAW1PHY_BEAT_MAIN'], sysv=False), comma=False)
        file_name.write("\n);\n")
        file_name.write("\n")




        if (configuration['TX_ENABLE_PACKETIZATION'] and direction == 'master') or (configuration['RX_ENABLE_PACKETIZATION'] and direction == 'slave') :

            file_name.write("//////////////////////////////////////////////////////////////////\n")
            file_name.write("// TX Packet Section")
            file_name.write("\n")

            if direction == 'master':
                loc_packet_info       = global_struct.g_tx_packet_info
                loc_packet_code_req   = global_struct.g_packet_code_master_req_tx
                loc_packet_code_data  = global_struct.g_packet_code_master_data_tx
            else:
                loc_packet_info       = global_struct.g_rx_packet_info
                loc_packet_code_req   = global_struct.g_packet_code_slave_req_tx
                loc_packet_code_data  = global_struct.g_packet_code_slave_data_tx

            print_verilog_logic_line (file_name , "tx_requestor"       , index = gen_index_msb  ( configuration['TX_PACKET_NUMBER']    if direction == 'master' else configuration['RX_PACKET_NUMBER']    , sysv=False) )
            print_verilog_logic_line (file_name , "tx_grant_onehotish" , index = gen_index_msb  ( configuration['TX_PACKET_NUMBER']    if direction == 'master' else configuration['RX_PACKET_NUMBER']    , sysv=False) )
            print_verilog_logic_line (file_name , "tx_grant_enc_data"  , index = gen_index_msb  ( configuration['TX_PACKET_ID_WIDTH']  if direction == 'master' else configuration['RX_PACKET_ID_WIDTH']  , sysv=False) )
            print_verilog_logic_line (file_name , "tx_packet_data"     , index = gen_index_msb  ( configuration['TX_PACKET_DATAWIDTH'] if direction == 'master' else configuration['RX_PACKET_DATAWIDTH'] , sysv=False) )
            for enc_index,entire_packet in enumerate(sorted (loc_packet_info, key=itemgetter('SIZE','PKT_NAME'), reverse=False)):
                print_verilog_logic_line(file_name, "tx_packet_data{}".format(enc_index), index = gen_index_msb  ( configuration['TX_PACKET_DATAWIDTH'] if direction == 'master' else configuration['RX_PACKET_DATAWIDTH'] , sysv=False) )
            file_name.write("\n")

            buff_max_value = 0
            for enc_index,entire_packet in enumerate(sorted (loc_packet_info, key=itemgetter('SIZE','PKT_NAME'), reverse=False)):
                for packet_chunk in entire_packet['LIST']:
                    if global_struct.g_PACKET_DEBUG:
                        print ("packet_chunk ***************")
                        pprint.pprint (packet_chunk)
                    if packet_chunk['FIRST_PKT'] == False:
                        print_verilog_logic_line (file_name , gen_llink_concat_pushbit  (packet_chunk['CHUNK_NAME'],"input"))
                        buff_max_value += 1
            if buff_max_value>0:
                file_name.write("\n")

            if int(configuration['TX_PACKET_NUMBER'] if direction == 'master' else configuration['RX_PACKET_NUMBER']) == 1:
                file_name.write("  // Corner case of 1 packet, so no meaninful encoding or arbitration\n")
                file_name.write("  // Removing round robin arbiter, replacing with single vector.\n")
                file_name.write("  assign tx_grant_onehotish = tx_requestor;\n")
                file_name.write("  assign tx_grant_enc_data  = 1'd0;\n")
            else:
                file_name.write("  rrarb #(.REQUESTORS({})) rrarb_itx\n".format (int(configuration['TX_PACKET_NUMBER'] if direction == 'master' else configuration['RX_PACKET_NUMBER']) ))
                file_name.write("          (// Outputs\n")
                file_name.write("           .grant                     (tx_grant_onehotish),\n")
                file_name.write("           // Inputs\n")
                file_name.write("           .clk_core                  (clk_wr),\n")
                file_name.write("           .rst_core_n                (rst_wr_n),\n")
                file_name.write("           .requestor                 (tx_requestor),\n")
                file_name.write("           .advance                   (1'b1));\n")
                file_name.write("\n")

                file_name.write("  // This converts from one-hot-ish rrarb output to encoded value\n")
                file_name.write("  always_comb\n")
                file_name.write("  begin\n")
                file_name.write("    case(tx_grant_onehotish)\n")
                for enc_index,entire_packet in enumerate(sorted (loc_packet_info, key=itemgetter('SIZE','PKT_NAME'), reverse=False)):
                    if (configuration['TX_PACKET_ID_WIDTH']  if direction == 'master' else configuration['RX_PACKET_ID_WIDTH']) == 0:
                        file_name.write("      {0:2}'b{1:<4} : tx_grant_enc_data ={2:2}'d{1:<4};\n".format(1, 0, 1, 0))
                    else:
                        file_name.write("      {0:2}'b{1:0{0}b} : tx_grant_enc_data = {2:2}'d{3:<4};\n".format(configuration['TX_PACKET_NUMBER']   if direction == 'master' else configuration['RX_PACKET_NUMBER']   , 2**enc_index,
                                                                                                               configuration['TX_PACKET_ID_WIDTH'] if direction == 'master' else configuration['RX_PACKET_ID_WIDTH'] ,   enc_index ))
                file_name.write("      {0:{1}} : tx_grant_enc_data = {2:2}'d{3:<4};\n".format("default", 4+(configuration['TX_PACKET_NUMBER']   if direction == 'master' else configuration['RX_PACKET_NUMBER']) ,
                                                                                                         configuration['TX_PACKET_ID_WIDTH']   if direction == 'master' else configuration['RX_PACKET_ID_WIDTH'],   0 ))
                file_name.write("    endcase\n")
                file_name.write("  end\n")
            file_name.write("\n")

            file_name.write("  // This assigns the data portion of packetizing\n")
            file_name.write("  always_comb\n")
            file_name.write("  begin\n")
            file_name.write("    case(tx_grant_enc_data)\n")
            for enc_index,entire_packet in enumerate(sorted (loc_packet_info, key=itemgetter('SIZE','PKT_NAME'), reverse=False)):
                if (configuration['TX_PACKET_ID_WIDTH']  if direction == 'master' else configuration['RX_PACKET_ID_WIDTH']) == 0:
                    file_name.write("      {0:2}'d{1:<4} : tx_packet_data = tx_packet_data{1};\n".format(1, 0))
                else:
                    file_name.write("      {0:2}'d{1:<4} : tx_packet_data = tx_packet_data{1};\n".format(configuration['TX_PACKET_ID_WIDTH']  if direction == 'master' else configuration['RX_PACKET_ID_WIDTH'], enc_index))
            file_name.write("      default  : tx_packet_data = tx_packet_data{1};\n".format(configuration['TX_PACKET_ID_WIDTH']  if direction == 'master' else configuration['RX_PACKET_ID_WIDTH'], enc_index))
            file_name.write("    endcase\n")
            file_name.write("  end\n")
            file_name.write("\n")

            file_name.write("  // This controls if we can pop the TX FIFO\n")
            for llink in configuration['LL_LIST']:
                if llink['DIR'] == localdir:
                    file_name.write("  assign "+gen_llink_concat_ovrd (llink['NAME'],"input")+" = ")
                    for enc_index,entire_packet in enumerate(sorted (loc_packet_info, key=itemgetter('SIZE','PKT_NAME'), reverse=False)):
                        for packet_chunk in entire_packet['LIST']:
                            if llink['NAME'] == packet_chunk['NAME'] and packet_chunk['LAST_PKT'] == True:
                                if (configuration['TX_PACKET_ID_WIDTH']  if direction == 'master' else configuration['RX_PACKET_ID_WIDTH']) == 0:
                                    file_name.write("(tx_grant_enc_data == {}'d{}) ? 1'b0 : ".format(1, 0))
                                else:
                                    file_name.write("(tx_grant_enc_data == {}'d{}) ? 1'b0 : ".format(configuration['TX_PACKET_ID_WIDTH']  if direction == 'master' else configuration['RX_PACKET_ID_WIDTH'], packet_chunk['ENC']))
                    file_name.write("1'b1;\n")
            file_name.write("\n")

            file_name.write("  // Request to Arbitrate\n")
            for string in loc_packet_code_req:
                file_name.write (string)
            file_name.write("\n")

            add_dly_module = False
            for entire_packet in loc_packet_info:
                for packet_chunk in entire_packet['LIST']:
                    if (packet_chunk['PKT_INDEX'] != 0):
                        add_dly_module = True

            if add_dly_module:

                file_name.write("  // This adds delay in secondary packets to prevent arbitration corner case\n")
                file_name.write("  always_ff @(posedge clk_wr or negedge rst_wr_n)\n")
                file_name.write("  if (~rst_wr_n)\n")
                file_name.write("  begin\n")
                for entire_packet in loc_packet_info:
                    for packet_chunk in entire_packet['LIST']:
                        if packet_chunk['PKT_INDEX'] != 0:
                            file_name.write("    {:20}<= 1'b0;\n".format (gen_llink_concat_pushbit  (packet_chunk['CHUNK_NAME'],"input")))
                file_name.write("  end\n")
                file_name.write("  else\n")
                file_name.write("  begin\n")
                for entire_packet in loc_packet_info:
                    for packet_chunk in entire_packet['LIST']:
                        if packet_chunk['PKT_INDEX'] != 0:
                            ##file_name.write("    {:20}<= {:20};\n".format (gen_llink_concat_pushbit  (packet_chunk['CHUNK_NAME'],"input"), gen_llink_concat_pushbit  (packet_chunk['NAME'] + str ((packet_chunk['PKT_INDEX']-1) if packet_chunk['PKT_INDEX'] > 1 else "")     ,"input")))
                            file_name.write("    {:20}<= (tx_grant_enc_data == {}'d{}) & {};\n".format(gen_llink_concat_pushbit  (packet_chunk['CHUNK_NAME'],"input"), configuration['TX_PACKET_ID_WIDTH']  if direction == 'master' else configuration['RX_PACKET_ID_WIDTH'], packet_chunk['ENC']-1, gen_llink_concat_pushbit  (packet_chunk['NAME'] + (str ("{0:02d}".format(packet_chunk['PKT_INDEX']-1)) if packet_chunk['PKT_INDEX'] > 1 else "")     ,"input")))
                file_name.write("  end\n")
                file_name.write("\n")

            file_name.write("  // Data to Transmit\n")
            for string in loc_packet_code_data:
                file_name.write (string)

            file_name.write("// TX Packet Section\n")
            file_name.write("//////////////////////////////////////////////////////////////////\n")
            file_name.write("\n")


        else: ## No packetizing
            # Logic Link Signaling
            if direction == 'master':
                localdir = 'output';
            else:
                localdir = 'input';

            file_name.write("// No TX Packetization, so tie off packetization signals\n")
            for llink in configuration['LL_LIST']:
                if llink['DIR'] == localdir:
                    print_verilog_assign(file_name, gen_llink_concat_ovrd (llink['NAME'],"input"), "1'b0")
            file_name.write("\n")


        if (configuration['TX_ENABLE_PACKETIZATION'] and direction == 'slave') or (configuration['RX_ENABLE_PACKETIZATION'] and direction == 'master') :

            file_name.write("//////////////////////////////////////////////////////////////////\n")
            file_name.write("// RX Packet Section\n")
            file_name.write("\n")

            if direction == 'master':
                loc_packet_info       = global_struct.g_rx_packet_info
            else:
                loc_packet_info       = global_struct.g_tx_packet_info

            print_verilog_logic_line (file_name , "rx_grant_enc_data"  , index = gen_index_msb  ( configuration['TX_PACKET_ID_WIDTH']  if direction == 'slave' else configuration['RX_PACKET_ID_WIDTH']  , sysv=False) )
            print_verilog_logic_line (file_name , "rx_packet_data"     , index = gen_index_msb  ( configuration['TX_PACKET_DATAWIDTH'] if direction == 'slave' else configuration['RX_PACKET_DATAWIDTH'] , sysv=False) )

            if (configuration['TX_PACKET_ID_WIDTH'] if direction == 'slave' else configuration['RX_PACKET_ID_WIDTH']) == 0:
                file_name.write("\n")
                file_name.write("  // Corner case of 1 packet, so no meaninful encoding\n")
                file_name.write("  assign rx_grant_enc_data = 1'd0;\n")

            ## Fist, we'll check if we need any buffering and the max buffering needed
            rx_buffer_size = 0
            for enc_index,entire_packet in enumerate(sorted (loc_packet_info, key=itemgetter('SIZE','PKT_NAME'), reverse=False)):
                for packet_chunk in entire_packet['LIST']:
                    if packet_chunk['PKT_INDEX'] > rx_buffer_size:
                        rx_buffer_size = packet_chunk['PKT_INDEX']

            if rx_buffer_size != 0:
                for buff in range(rx_buffer_size):
                    print_verilog_logic_line (file_name , "rx_grant_enc_dly{}_reg".format(buff), index = gen_index_msb  ( configuration['TX_PACKET_ID_WIDTH']  if direction == 'slave' else configuration['RX_PACKET_ID_WIDTH']  , sysv=False) )
                for buff in range(rx_buffer_size):
                    print_verilog_logic_line (file_name , "rx_buffer_dly{}_reg".format(buff), index = gen_index_msb  ( configuration['TX_PACKET_DATAWIDTH'] if direction == 'slave' else configuration['RX_PACKET_DATAWIDTH'] , sysv=False) )
            file_name.write("\n")


            file_name.write("  // This controls if we override the RX Push Bit (if the signal is 0, that is only time Push Bit could be valid)\n")
            for llink in configuration['LL_LIST']:
                if llink['DIR'] != localdir:
                    file_name.write("  assign {:20} = ".format(gen_llink_concat_ovrd (llink['NAME'],"output")))
                    for enc_index,entire_packet in enumerate(sorted (loc_packet_info, key=itemgetter('SIZE','PKT_NAME'), reverse=False)):
                        for packet_chunk in entire_packet['LIST']:
                            if llink['NAME'] == packet_chunk['NAME'] and packet_chunk['LAST_PKT'] == True:
                                if (configuration['TX_PACKET_ID_WIDTH'] if direction == 'slave' else configuration['RX_PACKET_ID_WIDTH']) == 0:
                                    file_name.write("(rx_grant_enc_data == {}'d{}) ? 1'b0 : ".format(1, 0))
                                else:
                                    file_name.write("(rx_grant_enc_data == {}'d{}) ? 1'b0 : ".format(configuration['TX_PACKET_ID_WIDTH']  if direction == 'slave' else configuration['RX_PACKET_ID_WIDTH'], packet_chunk['ENC']))
                    file_name.write("1'b1;\n")
            file_name.write("\n")


            ## It is used for PUSHBIT
            rx_data_dict = dict()
            rx_pushbit_dict = dict()

            for entire_packet in sorted (loc_packet_info, key=itemgetter('ENC')):
                for packet_chunk in entire_packet['LIST']:
                    delay_value = packet_chunk['LAST_PKT_INDEX']-packet_chunk['PKT_INDEX']-1

                    if packet_chunk['NAME'] in rx_pushbit_dict:
                        if packet_chunk['HASVALID']:
                            string = rx_pushbit_dict [packet_chunk['NAME']] + " ||\n                               "
                            if delay_value == -1: # -1 means live value
                                string += " ((rx_grant_enc_data == {}'d{}) &&".format(configuration['TX_PACKET_ID_WIDTH']  if direction == 'slave' else configuration['RX_PACKET_ID_WIDTH'], packet_chunk['LAST_PKT_ENC'])
                                string += " ({} [{}] == 1'b1))".format("rx_packet_data", packet_chunk['PUSHBIT_LOC'])
                            else:
                                string += " ((rx_grant_enc_data == {}'d{}) &&".format(configuration['TX_PACKET_ID_WIDTH']  if direction == 'slave' else configuration['RX_PACKET_ID_WIDTH'], packet_chunk['LAST_PKT_ENC'])
                                string += " (rx_grant_enc_dly{}_reg == {}'d{}) &&".format(delay_value, configuration['TX_PACKET_ID_WIDTH']  if direction == 'slave' else configuration['RX_PACKET_ID_WIDTH'], packet_chunk['ENC'])
                                string += " ({} [{}] == 1'b1))".format("rx_buffer_dly{}_reg".format(delay_value), packet_chunk['PUSHBIT_LOC'])
                            rx_pushbit_dict [packet_chunk['NAME']] = string

                    else: ## New entry
                        rx_element_dict = dict()
                        if packet_chunk['HASVALID']:
                            string = ""
                            if delay_value == -1: # -1 means live value
                                string += " ((rx_grant_enc_data == {}'d{}) &&".format(configuration['TX_PACKET_ID_WIDTH']  if direction == 'slave' else configuration['RX_PACKET_ID_WIDTH'], packet_chunk['LAST_PKT_ENC'])
                                string += " ({} [{}] == 1'b1))".format("rx_packet_data", packet_chunk['PUSHBIT_LOC'] )
                            else:
                                string += " ((rx_grant_enc_data == {}'d{}) &&".format(configuration['TX_PACKET_ID_WIDTH']  if direction == 'slave' else configuration['RX_PACKET_ID_WIDTH'], packet_chunk['LAST_PKT_ENC'])
                                string += " (rx_grant_enc_dly{}_reg == {}'d{}) &&".format(delay_value, configuration['TX_PACKET_ID_WIDTH']  if direction == 'slave' else configuration['RX_PACKET_ID_WIDTH'], packet_chunk['ENC'])
                                string += " ({} [{}] == 1'b1))".format("rx_buffer_dly{}_reg".format(delay_value), packet_chunk['PUSHBIT_LOC'])
                            rx_pushbit_dict [packet_chunk['NAME']] = string

            if global_struct.g_PACKET_DEBUG:
                pprint.pprint (rx_pushbit_dict)


            file_name.write("  // This is RX Push Bit\n")
            for rx_pushbit_key in sorted (rx_pushbit_dict.keys()) :
                file_name.write("  assign {:20} ={};\n".format(gen_llink_concat_pushbit (rx_pushbit_key,"output"), rx_pushbit_dict[rx_pushbit_key]))
            file_name.write("\n")






###         for llink in configuration['LL_LIST']:
###             if llink['DIR'] != localdir:
###                 num_whole_assignment = 0
###                 for enc_index,entire_packet in enumerate(sorted (loc_packet_info, key=itemgetter('SIZE','PKT_NAME'), reverse=False)):
###                     for packet_chunk in entire_packet['LIST']:
###                         if llink['NAME'] == packet_chunk['NAME']:
###                             if packet_chunk['HASVALID'] == True:
###                                 num_whole_assignment += 1
###
###                 if global_struct.g_PACKET_DEBUG:
###                     print("RX pushbit llink {}  num_whole_assignment = {}\n".format(llink['NAME'], num_whole_assignment))
###
###                 if num_whole_assignment > 1 :
###                     file_name.write("  assign {:20} = ".format(gen_llink_concat_pushbit(llink['NAME'],'output')))
###                     for enc_index,entire_packet in enumerate(sorted (loc_packet_info, key=itemgetter('SIZE','PKT_NAME'), reverse=False)):
###                         for packet_chunk in entire_packet['LIST']:
###                             if llink['NAME'] == packet_chunk['NAME']:
###                                 if packet_chunk['HASVALID'] == True:
###                                     if num_whole_assignment > 1:
###                                         file_name.write("(rx_grant_enc_data == {}'d{}) ? ".format(configuration['TX_PACKET_ID_WIDTH']  if direction == 'slave' else configuration['RX_PACKET_ID_WIDTH'], packet_chunk['ENC']))
###                                     file_name.write("rx_packet_data[{}] ".format(packet_chunk['PUSHBIT_LOC']))
###                                     num_whole_assignment -= 1
###                                     if (num_whole_assignment != 0):
###                                         file_name.write(": ")
###                 else:
###                     file_name.write("  assign {:20} = ".format(gen_llink_concat_pushbit(llink['NAME'],'output')))
###                     for enc_index,entire_packet in enumerate(sorted (loc_packet_info, key=itemgetter('SIZE','PKT_NAME'), reverse=False)):
###                         for packet_chunk in entire_packet['LIST']:
###                             if llink['NAME'] == packet_chunk['NAME']:
###                                 if packet_chunk['LAST_PKT'] == True :
###                                     max_pkt_index = packet_chunk['PKT_INDEX']
###
###                         for packet_chunk in entire_packet['LIST']:
###                             if llink['NAME'] == packet_chunk['NAME']:
###                                 if packet_chunk['FIRST_PKT'] == True and packet_chunk['LAST_PKT'] == True and packet_chunk['HASVALID'] == True:
###                                     file_name.write("rx_packet_data[{}] ".format(packet_chunk['PUSHBIT_LOC']))
###                                 elif packet_chunk['FIRST_PKT'] == True and packet_chunk['HASVALID'] == True:
###                                     file_name.write("(rx_buffer_dly{}_reg[{}] & (rx_grant_enc_dly{}_reg == {}'d{})) & ".format(packet_chunk['LAST_PKT_INDEX'] - packet_chunk['PKT_INDEX'] -1, packet_chunk['PUSHBIT_LOC'], packet_chunk['LAST_PKT_INDEX'] - packet_chunk['PKT_INDEX'] -1, configuration['TX_PACKET_ID_WIDTH']  if direction == 'slave' else configuration['RX_PACKET_ID_WIDTH'], packet_chunk['ENC']))
###                                 elif packet_chunk['LAST_PKT'] == True :
###                                     file_name.write("(rx_grant_enc_data == {}'d{}) ".format(configuration['TX_PACKET_ID_WIDTH']  if direction == 'slave' else configuration['RX_PACKET_ID_WIDTH'], packet_chunk['ENC']))
###                 file_name.write(";\n")
###         file_name.write("\n")














            ## This section builds a dict of LL Data, with possibly multiple sources.
            ## It is used for and RX Data later on.
            for entire_packet in sorted (loc_packet_info, key=itemgetter('SIZE','PKT_NAME'), reverse=False):
                for packet_chunk in entire_packet['LIST']:
                    rx_data_key = "{}".format(packet_chunk['CHUNK_NAME'])
                    if rx_data_key in rx_data_dict:
                        rx_data_dict[rx_data_key] ['ENC'] = rx_data_dict[rx_data_key] ['ENC']+"_"+str(entire_packet['ENC'])
                    else: ## New entry
                        rx_element_dict = dict()
                        rx_element_dict ['ENC']            = str(entire_packet['ENC'])
                        rx_element_dict ['NAME']           = packet_chunk['NAME']
                        rx_element_dict ['WIDTH']          = packet_chunk['WIDTH']
                        rx_element_dict ['LLINK_LSB']      = packet_chunk['LLINK_LSB']
                        rx_element_dict ['DELAY']          = packet_chunk['LAST_PKT_INDEX'] - packet_chunk['PKT_INDEX']-1 # -1 means live
                        rx_element_dict ['FIFODATA_LOC']   = packet_chunk['FIFODATA_LOC']
                        rx_data_dict[rx_data_key] = rx_element_dict

            if global_struct.g_PACKET_DEBUG:
                pprint.pprint (rx_data_dict)






            file_name.write("  // This is RX Data\n")
            for rx_data_key in sorted (rx_data_dict.keys()) :
                enc_list = rx_data_dict[rx_data_key]['ENC'].split("_")
                enc_index = len(enc_list)
                total_encoding = len(enc_list)-1

                file_name.write("  assign {:20} {:13} =".format(gen_llink_concat_fifoname (rx_data_dict[rx_data_key]['NAME'],"output") , gen_index_msb  (rx_data_dict[rx_data_key]['WIDTH'], rx_data_dict[rx_data_key]['LLINK_LSB']) ))
                for encoding_index, encoding in enumerate(enc_list):
                    if total_encoding > 0:
                        if encoding_index != total_encoding:
                            if (rx_data_dict[rx_data_key]['DELAY'] == -1):
                                file_name.write(" (rx_grant_enc_data == {}'d{}) ?".format(configuration['TX_PACKET_ID_WIDTH']  if direction == 'slave' else configuration['RX_PACKET_ID_WIDTH'], encoding))
                            else:
                                file_name.write(" (rx_grant_enc_dly{}_reg == {}'d{}) ?".format(rx_data_dict[rx_data_key]['DELAY'], configuration['TX_PACKET_ID_WIDTH']  if direction == 'slave' else configuration['RX_PACKET_ID_WIDTH'], encoding))
                        else:
                            file_name.write("                                  ")
                    if rx_data_dict[rx_data_key]['DELAY'] == -1: # -1 means live value
                        file_name.write(" {:20} ".format("rx_packet_data" ))
                    else:
                        file_name.write(" {:20} ".format("rx_buffer_dly{}_reg".format(rx_data_dict[rx_data_key]['DELAY']) ))
                    file_name.write("{:13}".format(gen_index_msb(rx_data_dict[rx_data_key]['WIDTH'], rx_data_dict[rx_data_key]['FIFODATA_LOC']) ))

                    if total_encoding > 0:
                        if encoding_index != total_encoding:
                            file_name.write(" :\n                                           ")
                        else:
                            file_name.write(" ;\n")
                    else:
                        file_name.write(";\n")


            if rx_buffer_size != 0:
                file_name.write("\n")
                file_name.write("  // This is Buffer and Encoding Delay\n")
                file_name.write("  always_ff @(posedge clk_wr or negedge rst_wr_n)\n")
                file_name.write("  if (~rst_wr_n)\n")
                file_name.write("  begin\n")
                for buff in range(rx_buffer_size):
                    print_verilog_regnb (file_name , "rx_grant_enc_dly{}_reg".format(buff) , "'0")
                for buff in range(rx_buffer_size):
                    print_verilog_regnb (file_name , "rx_buffer_dly{}_reg".format(buff) , "'0")
                file_name.write("  end\n")
                file_name.write("  else\n")
                file_name.write("  begin\n")
                for buff in range(rx_buffer_size):
                    if buff == 0:
                        print_verilog_regnb (file_name , "rx_grant_enc_dly{}_reg".format(buff) , "rx_grant_enc_data")
                    else:
                        print_verilog_regnb (file_name , "rx_grant_enc_dly{}_reg".format(buff) , "rx_grant_enc_dly{}_reg".format(buff-1))
                for buff in range(rx_buffer_size):
                    if buff == 0:
                        print_verilog_regnb (file_name , "rx_buffer_dly{}_reg".format(buff) , "rx_packet_data")
                    else:
                        print_verilog_regnb (file_name , "rx_buffer_dly{}_reg".format(buff) , "rx_buffer_dly{}_reg".format(buff-1))
                file_name.write("  end\n")

            file_name.write("\n")
            file_name.write("// RX Packet Section\n")
            file_name.write("//////////////////////////////////////////////////////////////////\n")
            file_name.write("\n")
        else:
            if direction == 'master':
                localdir = 'input';
            else:
                localdir = 'output';

            file_name.write("// No RX Packetization, so tie off packetization signals\n")
            for llink in configuration['LL_LIST']:
                if llink['DIR'] == localdir:
                    print_verilog_assign(file_name, gen_llink_concat_ovrd (llink['NAME'],"output"), "1'b0")
            file_name.write("\n")



        file_name.write("//////////////////////////////////////////////////////////////////\n")
        file_name.write("// TX Section\n")
        file_name.write("\n")
        file_name.write("//   TX_CH_WIDTH           = {}; // {} running at {} Rate\n".format(configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if direction == 'master' else configuration['CHAN_RX_RAW1PHY_DATA_MAIN'], configuration['CHAN_TYPE'], configuration['TX_RATE'] if direction == 'master' else configuration['RX_RATE']))
        file_name.write("//   TX_DATA_WIDTH         = {}; // Usable Data per Channel\n".format(configuration['CHAN_TX_USEABLE1PHY_DATA_MAIN'] if direction == 'master' else configuration['CHAN_RX_USEABLE1PHY_DATA_MAIN'] ))
        file_name.write("//   TX_PERSISTENT_STROBE  = 1'b{};\n".format(int(configuration['TX_PERSISTENT_STROBE'])))
        file_name.write("//   TX_PERSISTENT_MARKER  = 1'b{};\n".format(int(configuration['TX_PERSISTENT_MARKER'])))
        file_name.write("//   TX_STROBE_GEN2_LOC    = 'd{};\n".format(int(configuration['TX_STROBE_GEN2_LOC'])))
        file_name.write("//   TX_MARKER_GEN2_LOC    = 'd{};\n".format(int(configuration['TX_MARKER_GEN2_LOC'])))
        file_name.write("//   TX_STROBE_GEN1_LOC    = 'd{};\n".format(int(configuration['TX_STROBE_GEN1_LOC'])))
        file_name.write("//   TX_MARKER_GEN1_LOC    = 'd{};\n".format(int(configuration['TX_MARKER_GEN1_LOC'])))
        file_name.write("//   TX_ENABLE_STROBE      = 1'b{};\n".format(int(configuration['TX_ENABLE_STROBE'])))
        file_name.write("//   TX_ENABLE_MARKER      = 1'b{};\n".format(int(configuration['TX_ENABLE_MARKER'])))
        file_name.write("//   TX_DBI_PRESENT        = 1'b{};\n".format(int(configuration['TX_DBI_PRESENT'])))
        file_name.write("//   TX_REG_PHY            = 1'b{};\n".format(int(configuration['TX_REG_PHY'])))
        file_name.write("\n")
        file_name.write("  localparam TX_REG_PHY    = 1'b{};  // If set, this enables boundary FF for timing reasons\n".format(int(configuration['TX_REG_PHY'])))
        file_name.write("\n")


        for phy in range(configuration['NUM_CHAN']):
            print_verilog_logic_line (file_name , "tx_phy_preflop_{}".format(phy) , index = gen_index_msb  ( configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if direction == 'master' else configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] , sysv=False) )

        use_recov_strobe = False
        if ((configuration['TX_ENABLE_STROBE']     if direction == 'master' else configuration['RX_ENABLE_STROBE'])     == True  and
            (configuration['TX_PERSISTENT_STROBE'] if direction == 'master' else configuration['RX_PERSISTENT_STROBE']) == False ) :
            use_recov_strobe = True

        use_recov_marker = False
        if ((configuration['TX_ENABLE_MARKER']     if direction == 'master' else configuration['RX_ENABLE_MARKER'])     == True  and
            (configuration['TX_PERSISTENT_MARKER'] if direction == 'master' else configuration['RX_PERSISTENT_MARKER']) == False ) :
            use_recov_marker = True

        if use_recov_strobe :
            for phy in range(configuration['NUM_CHAN']):
                print_verilog_logic_line (file_name , "tx_phy_preflop_recov_strobe_{}".format(phy) , index = gen_index_msb  ( configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if direction == 'master' else configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] , sysv=False) )
        if use_recov_marker:
            for phy in range(configuration['NUM_CHAN']):
                print_verilog_logic_line (file_name , "tx_phy_preflop_recov_marker_{}".format(phy) , index = gen_index_msb  ( configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if direction == 'master' else configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] , sysv=False) )

        for phy in range(configuration['NUM_CHAN']):
            print_verilog_logic_line (file_name , "tx_phy_flop_{}_reg".format(phy) , index = gen_index_msb  ( configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if direction == 'master' else configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] , sysv=False) )

        if configuration['TX_SPARE_WIDTH'] if direction == 'master' else configuration['RX_SPARE_WIDTH'] > 0:
            print_verilog_logic_line (file_name , "tx_spare_data", index = gen_index_msb (configuration['TX_SPARE_WIDTH'] if direction == 'master' else configuration['RX_SPARE_WIDTH'], sysv=False) )

        file_name.write("\n")
        file_name.write("  always_ff @(posedge clk_wr or negedge rst_wr_n)\n")
        file_name.write("  if (~rst_wr_n)\n")
        file_name.write("  begin\n")
        for phy in range(configuration['NUM_CHAN']):
            print_verilog_regnb (file_name , "tx_phy_flop_{}_reg".format(phy) , "{}'b0".format(configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if direction == 'master' else configuration['CHAN_RX_RAW1PHY_DATA_MAIN']))
        file_name.write("  end\n")
        file_name.write("  else\n")
        file_name.write("  begin\n")
        for phy in range(configuration['NUM_CHAN']):
            if use_recov_marker:
                print_verilog_regnb (file_name , "tx_phy_flop_{}_reg".format(phy) , "tx_phy_preflop_recov_marker_{}".format(phy))
            elif use_recov_strobe and not use_recov_marker:
                print_verilog_regnb (file_name , "tx_phy_flop_{}_reg".format(phy) , "tx_phy_preflop_recov_strobe_{}".format(phy))
            else:
                print_verilog_regnb (file_name , "tx_phy_flop_{}_reg".format(phy) , "tx_phy_preflop_{}".format(phy))
        file_name.write("  end\n")
        file_name.write("\n")

        for phy in range(configuration['NUM_CHAN']):
            if use_recov_marker:
                print_verilog_assign(file_name, "tx_phy{}".format(phy), "TX_REG_PHY ? tx_phy_flop_{}_reg : tx_phy_preflop_recov_marker_{}".format(phy,phy))
            elif use_recov_strobe and not use_recov_marker:
                print_verilog_assign(file_name, "tx_phy{}".format(phy), "TX_REG_PHY ? tx_phy_flop_{}_reg : tx_phy_preflop_recov_strobe_{}".format(phy,phy))
            else:
                print_verilog_assign(file_name, "tx_phy{}".format(phy), "TX_REG_PHY ? tx_phy_flop_{}_reg : tx_phy_preflop_{}".format(phy,phy))
        file_name.write("\n")

        if use_recov_strobe:
            for phy in range(configuration['NUM_CHAN']):
                if configuration['TX_STROBE_GEN2_LOC'] != 0:
                    print_verilog_assign(file_name, "tx_phy_preflop_recov_strobe_{0}".format(phy), "                                tx_phy_preflop_{0}".format(phy),
                                                                                                                              index1=gen_index_msb (configuration['TX_STROBE_GEN2_LOC'], 0) ,
                                                                                                                              index2=gen_index_msb (configuration['TX_STROBE_GEN2_LOC'], 0) )
                print_verilog_assign(file_name, "tx_phy_preflop_recov_strobe_{0}".format(phy), "(~tx_online) ? tx_stb_userbit : tx_phy_preflop_{0}".format(phy),
                                                                                                                              index1=gen_index_msb (1, configuration['TX_STROBE_GEN2_LOC']),
                                                                                                                              index2=gen_index_msb (1, configuration['TX_STROBE_GEN2_LOC']))

                if configuration['TX_STROBE_GEN2_LOC'] != configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if direction == 'master' else configuration['CHAN_RX_RAW1PHY_DATA_MAIN']:
                    print_verilog_assign(file_name, "tx_phy_preflop_recov_strobe_{0}".format(phy), "                                tx_phy_preflop_{0}".format(phy),
                                                                        index1=gen_index_msb ((configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if direction == 'master' else configuration['CHAN_RX_RAW1PHY_DATA_MAIN'])-configuration['TX_STROBE_GEN2_LOC']-1, configuration['TX_STROBE_GEN2_LOC']+1) ,
                                                                        index2=gen_index_msb ((configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if direction == 'master' else configuration['CHAN_RX_RAW1PHY_DATA_MAIN'])-configuration['TX_STROBE_GEN2_LOC']-1, configuration['TX_STROBE_GEN2_LOC']+1) )

            file_name.write("\n")

        ##Note, this is intended to be if, not elif
        if use_recov_marker and not use_recov_strobe:
            marker_count = 1
            if (configuration['TX_RATE'] if direction == 'master' else configuration['RX_RATE']) == 'Half':
                marker_count = 2
            if (configuration['TX_RATE'] if direction == 'master' else configuration['RX_RATE']) == 'Quarter':
                marker_count = 4

            for phy in range(configuration['NUM_CHAN']):
                for bus_index in range(marker_count):
                    beat_size  = (configuration['CHAN_TX_RAW1PHY_BEAT_MAIN'] if direction == 'master' else configuration['CHAN_RX_RAW1PHY_BEAT_MAIN']) * bus_index
                    beat_msb   = ((configuration['CHAN_TX_RAW1PHY_BEAT_MAIN'] if direction == 'master' else configuration['CHAN_RX_RAW1PHY_BEAT_MAIN']) * (bus_index+1)) - 1
                    if configuration['TX_MARKER_GEN2_LOC'] != 0:
                        print_verilog_assign(file_name, "tx_phy_preflop_recov_marker_{0}".format(phy), "                                   tx_phy_preflop_{0}".format(phy),
                                                                                                                                  index1=gen_index_msb (configuration['TX_MARKER_GEN2_LOC'] , beat_size) ,
                                                                                                                                  index2=gen_index_msb (configuration['TX_MARKER_GEN2_LOC'] , beat_size) )

                    print_verilog_assign(file_name, "tx_phy_preflop_recov_marker_{0}".format(phy), "(~tx_online) ? tx_mrk_userbit[{1}] : tx_phy_preflop_{0}".format(phy, bus_index),
                                                                                                                                  index1=gen_index_msb (1, configuration['TX_MARKER_GEN2_LOC'] + beat_size) ,
                                                                                                                                  index2=gen_index_msb (1, configuration['TX_MARKER_GEN2_LOC'] + beat_size) )

                    if configuration['TX_MARKER_GEN2_LOC'] != (beat_msb - beat_size):
                        print_verilog_assign(file_name, "tx_phy_preflop_recov_marker_{0}".format(phy), "                                   tx_phy_preflop_{0}".format(phy),
                                                                            index1=gen_index_msb (beat_msb - (configuration['TX_MARKER_GEN2_LOC'] + beat_size), configuration['TX_MARKER_GEN2_LOC'] + beat_size + 1) ,
                                                                            index2=gen_index_msb (beat_msb - (configuration['TX_MARKER_GEN2_LOC'] + beat_size), configuration['TX_MARKER_GEN2_LOC'] + beat_size + 1) )

            file_name.write("\n")

        elif use_recov_marker and use_recov_strobe:
            marker_count = 1
            if (configuration['TX_RATE'] if direction == 'master' else configuration['RX_RATE']) == 'Half':
                marker_count = 2
            if (configuration['TX_RATE'] if direction == 'master' else configuration['RX_RATE']) == 'Quarter':
                marker_count = 4

            for phy in range(configuration['NUM_CHAN']):
                for bus_index in range(marker_count):
                    beat_size  = (configuration['CHAN_TX_RAW1PHY_BEAT_MAIN'] if direction == 'master' else configuration['CHAN_RX_RAW1PHY_BEAT_MAIN']) * bus_index
                    beat_msb   = ((configuration['CHAN_TX_RAW1PHY_BEAT_MAIN'] if direction == 'master' else configuration['CHAN_RX_RAW1PHY_BEAT_MAIN']) * (bus_index+1)) - 1
                    if configuration['TX_MARKER_GEN2_LOC'] != 0:
                        print_verilog_assign(file_name, "tx_phy_preflop_recov_marker_{0}".format(phy), "                                   tx_phy_preflop_recov_strobe_{0}".format(phy),
                                                                                                                                  index1=gen_index_msb (configuration['TX_MARKER_GEN2_LOC'] , beat_size) ,
                                                                                                                                  index2=gen_index_msb (configuration['TX_MARKER_GEN2_LOC'] , beat_size) )

                    print_verilog_assign(file_name, "tx_phy_preflop_recov_marker_{0}".format(phy), "(~tx_online) ? tx_mrk_userbit[{1}] : tx_phy_preflop_recov_strobe_{0}".format(phy, bus_index),
                                                                                                                                  index1=gen_index_msb (1, configuration['TX_MARKER_GEN2_LOC'] + beat_size) ,
                                                                                                                                  index2=gen_index_msb (1, configuration['TX_MARKER_GEN2_LOC'] + beat_size) )

                    if configuration['TX_MARKER_GEN2_LOC'] != (beat_msb - beat_size):
                        print_verilog_assign(file_name, "tx_phy_preflop_recov_marker_{0}".format(phy), "                                   tx_phy_preflop_recov_strobe_{0}".format(phy),
                                                                            index1=gen_index_msb (beat_msb - (configuration['TX_MARKER_GEN2_LOC'] + beat_size), configuration['TX_MARKER_GEN2_LOC'] + beat_size + 1) ,
                                                                            index2=gen_index_msb (beat_msb - (configuration['TX_MARKER_GEN2_LOC'] + beat_size), configuration['TX_MARKER_GEN2_LOC'] + beat_size + 1) )

            file_name.write("\n")



        if configuration['TX_SPARE_WIDTH'] if direction == 'master' else configuration['RX_SPARE_WIDTH'] > 0:
            print_verilog_assign(file_name, "tx_spare_data", "{}'b0".format(configuration['TX_SPARE_WIDTH'] if direction == 'master' else configuration['RX_SPARE_WIDTH']))
            file_name.write("\n")

        if direction == 'master':
            for string in global_struct.g_concat_code_vector_master_tx:
                file_name.write (string)
        else:
            for string in global_struct.g_concat_code_vector_slave_tx:
                file_name.write (string)

        file_name.write("// TX Section\n")
        file_name.write("//////////////////////////////////////////////////////////////////\n")
        file_name.write("\n")
        file_name.write("//////////////////////////////////////////////////////////////////\n")
        file_name.write("// RX Section\n")
        file_name.write("\n")
        file_name.write("//   RX_CH_WIDTH           = {}; // {} running at {} Rate\n".format(configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if direction == 'slave' else configuration['CHAN_RX_RAW1PHY_DATA_MAIN'], configuration['CHAN_TYPE'], configuration['TX_RATE'] if direction == 'slave' else configuration['RX_RATE']))
        file_name.write("//   RX_DATA_WIDTH         = {}; // Usable Data per Channel\n".format(configuration['CHAN_TX_USEABLE1PHY_DATA_MAIN'] if direction == 'slave' else configuration['CHAN_RX_USEABLE1PHY_DATA_MAIN'] ))
        file_name.write("//   RX_PERSISTENT_STROBE  = 1'b{};\n".format(int(configuration['RX_PERSISTENT_STROBE'])))
        file_name.write("//   RX_PERSISTENT_MARKER  = 1'b{};\n".format(int(configuration['RX_PERSISTENT_MARKER'])))
        file_name.write("//   RX_STROBE_GEN2_LOC    = 'd{};\n".format(int(configuration['RX_STROBE_GEN2_LOC'])))
        file_name.write("//   RX_MARKER_GEN2_LOC    = 'd{};\n".format(int(configuration['RX_MARKER_GEN2_LOC'])))
        file_name.write("//   RX_STROBE_GEN1_LOC    = 'd{};\n".format(int(configuration['RX_STROBE_GEN1_LOC'])))
        file_name.write("//   RX_MARKER_GEN1_LOC    = 'd{};\n".format(int(configuration['RX_MARKER_GEN1_LOC'])))
        file_name.write("//   RX_ENABLE_STROBE      = 1'b{};\n".format(int(configuration['RX_ENABLE_STROBE'])))
        file_name.write("//   RX_ENABLE_MARKER      = 1'b{};\n".format(int(configuration['RX_ENABLE_MARKER'])))
        file_name.write("//   RX_DBI_PRESENT        = 1'b{};\n".format(int(configuration['RX_DBI_PRESENT'])))
        file_name.write("//   RX_REG_PHY            = 1'b{};\n".format(int(configuration['RX_REG_PHY'])))
        file_name.write("\n")
        file_name.write("  localparam RX_REG_PHY    = 1'b{};  // If set, this enables boundary FF for timing reasons\n".format(int(configuration['RX_REG_PHY'])))
        file_name.write("\n")


        for phy in range(configuration['NUM_CHAN']):
            print_verilog_logic_line (file_name , "rx_phy_postflop_{}".format(phy) , index = gen_index_msb  ( configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if direction == 'slave' else configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] , sysv=False) )

        for phy in range(configuration['NUM_CHAN']):
            print_verilog_logic_line (file_name , "rx_phy_flop_{}_reg".format(phy) , index = gen_index_msb  ( configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if direction == 'slave' else configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] , sysv=False) )

        if configuration['TX_SPARE_WIDTH'] if direction == 'slave' else configuration['RX_SPARE_WIDTH'] > 0:
            print_verilog_logic_line (file_name , "rx_spare_data", index = gen_index_msb (configuration['TX_SPARE_WIDTH'] if direction == 'slave' else configuration['RX_SPARE_WIDTH'], sysv=False) )

        file_name.write("\n")
        file_name.write("  always_ff @(posedge clk_rd or negedge rst_rd_n)\n")
        file_name.write("  if (~rst_rd_n)\n")
        file_name.write("  begin\n")
        for phy in range(configuration['NUM_CHAN']):
            print_verilog_regnb (file_name , "rx_phy_flop_{}_reg".format(phy) , "{}'b0".format(configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if direction == 'slave' else configuration['CHAN_RX_RAW1PHY_DATA_MAIN']))
        file_name.write("  end\n")
        file_name.write("  else\n")
        file_name.write("  begin\n")
        for phy in range(configuration['NUM_CHAN']):
            print_verilog_regnb (file_name , "rx_phy_flop_{}_reg".format(phy) , "rx_phy{}".format(phy))
        file_name.write("  end\n")
        file_name.write("\n")
        file_name.write("\n")
        for phy in range(configuration['NUM_CHAN']):
            print_verilog_assign(file_name, "rx_phy_postflop_{}".format(phy), "RX_REG_PHY ? rx_phy_flop_{}_reg : rx_phy{}".format(phy,phy))
        file_name.write("\n")

        if direction == 'master':
            for string in global_struct.g_concat_code_vector_master_rx:
                file_name.write (string)
        else:
            for string in global_struct.g_concat_code_vector_slave_rx:
                file_name.write (string)


            if configuration['REPLICATED_STRUCT']:
                for llink in configuration['LL_LIST']:
                    for sig in llink['SIGNALLIST_MAIN']:
                        if sig['TYPE'] == "rstruct_enable":
                            llink_lsb = sig['LLINDEX_MAIN_LSB'] * configuration['RSTRUCT_MULTIPLY_FACTOR']
                            for rstruct_iteration in list (range (0, configuration['RSTRUCT_MULTIPLY_FACTOR'])):
                                file_name.write("  assign {0:20}[{1:4}] = {2};\n".format(gen_llink_concat_fifoname (llink['NAME'],"output" ), llink_lsb, gen_llink_concat_pushbit (llink['NAME'],llink['DIR'])+"_r"+str(rstruct_iteration) ))
                                llink_lsb += 1




        file_name.write("\n")
        file_name.write("// RX Section\n")
        file_name.write("//////////////////////////////////////////////////////////////////\n")
        file_name.write("\n")

        file_name.write("\n")
        file_name.write("endmodule\n")
        file_name.close()
    return

## make_concat_file
##########################################################################################

##########################################################################################
## make_top_file
## Make the top level file
def make_top_file(configuration):

    for direction in ['master', 'slave']:
        name_file_name   = "{}_{}_top".format(configuration['MODULE'], direction)
        file_name       = open("{}/{}.sv".format(configuration['OUTPUT_DIR'], name_file_name), "w+")
        print_verilog_header(file_name)
        file_name.write("module {}  (\n".format(name_file_name))

        print_verilog_io_line(file_name, "input", "clk_wr")
        print_verilog_io_line(file_name, "input", "rst_wr_n")
        file_name.write("\n")
        file_name.write("  // Control signals\n")
        print_verilog_io_line(file_name, "input", "tx_online")
        print_verilog_io_line(file_name, "input", "rx_online")
        file_name.write("\n")

        if direction == 'master':
            localdir = 'output';
        else:
            localdir = 'input';

        for llink in configuration['LL_LIST']:
            if llink['DIR'] == localdir:
                print_verilog_io_line(file_name, "input", "init_{}_credit".format(llink['NAME']), "[7:0]")

        file_name.write("\n")
        file_name.write("  // PHY Interconnect\n")
        for phy in range(configuration['NUM_CHAN']):
            print_verilog_io_line(file_name, "output", "tx_phy{0}".format(phy), gen_index_msb(configuration['CHAN_TX_RAW1PHY_DATA_MAIN'], sysv=False))
            print_verilog_io_line(file_name, "input",  "rx_phy{0}".format(phy), gen_index_msb(configuration['CHAN_TX_RAW1PHY_DATA_MAIN'], sysv=False))

        # List User Signals
        for llink in configuration['LL_LIST']:
           #if (llink['WIDTH_GALT'] != 0) and (llink['WIDTH_MAIN'] != 0):
           #    file_name.write("\n  // {0} channel\n".format(llink['NAME']))
           #    for sig_gen2 in llink['SIGNALLIST_MAIN']:
           #        found_gen1_match = 0;
           #        for sig_gen1 in llink['SIGNALLIST_GALT']:
           #            if sig_gen2['NAME'] == sig_gen1['NAME']:
           #                found_gen1_match = 1
           #                localdir = gen_direction(name_file_name, sig_gen2['DIR'])
           #                print_verilog_io_line(file_name, localdir, sig_gen2['NAME'], index=gen_index_msb(sig_gen2['SIGWID'] + sig_gen1['SIGWID'],sig_gen1['LSB'], sysv=False))
           #        if found_gen1_match == 0:
           #            localdir = gen_direction(name_file_name, sig_gen2['DIR'])
           #            print_verilog_io_line(file_name, localdir, sig_gen2['NAME'], index=gen_index_msb(sig_gen2['SIGWID'],sig_gen2['LSB'], sysv=False))
           #
           #else:
                file_name.write("\n  // {0} channel\n".format(llink['NAME']))
                for sig_gen2 in llink['SIGNALLIST_MAIN']:
                    if sig_gen2['TYPE'] == "rstruct_enable" and localdir == 'output':
                        continue
                    localdir = gen_direction(name_file_name, sig_gen2['DIR'])
                    print_verilog_io_line(file_name, localdir, sig_gen2['NAME'], index=gen_index_msb(sig_gen2['SIGWID'] * configuration['RSTRUCT_MULTIPLY_FACTOR'],sig_gen2['LSB'], sysv=False))

        file_name.write("\n")


        file_name.write("  // Debug Status Outputs\n")
        for llink in configuration['LL_LIST']:
            localdir = gen_direction(name_file_name, llink['DIR'], True)
            print_verilog_io_line(file_name, "output", gen_llink_debug_status(llink['NAME'],localdir), "[31:0]")

        file_name.write("\n  // Configuration\n")
        print_verilog_io_line(file_name, "input", "m_gen2_mode")
        file_name.write("\n")
        #if configuration['RX_USER_MARKER']:
        #    print_verilog_io_line(file_name, "output", "rx_mrk_userbit", gen_index_msb(configuration['NUM_CHAN'], sysv=False))
        #if configuration['RX_USER_STROBE']:
        #    print_verilog_io_line(file_name, "output", "rx_stb_userbit", gen_index_msb(configuration['NUM_CHAN'], sysv=False))
        if configuration['TX_USER_MARKER'] if direction == 'master' else configuration['RX_USER_MARKER']:
            print_verilog_io_line(file_name, "input",  "tx_mrk_userbit", gen_index_msb(configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] // configuration['CHAN_RX_RAW1PHY_BEAT_MAIN'], sysv=False))
        if configuration['TX_USER_STROBE'] if direction == 'master' else configuration['RX_USER_STROBE']:
            print_verilog_io_line(file_name, "input",  "tx_stb_userbit")

        file_name.write("\n")

        print_verilog_io_line(file_name, "input",  "delay_x_value",  "[7:0]", "In single channel, no CA, this is Word Alignment Time. In multie-channel, this is 0 and RX_ONLINE tied to channel_alignment_done")
        print_verilog_io_line(file_name, "input",  "delay_xz_value", "[7:0]")
        print_verilog_io_line(file_name, "input",  "delay_yz_value", "[7:0]",comma=False)
        file_name.write("\n);\n")
        file_name.write("\n")
        file_name.write("//////////////////////////////////////////////////////////////////\n")
        file_name.write("// Interconnect Wires\n")

        for llink in configuration['LL_LIST']:
            if llink['HASVALID']:
                print_verilog_logic_line (file_name , gen_llink_concat_pushbit  (llink['NAME'], gen_direction(name_file_name, llink['DIR'], False)))
                print_verilog_logic_line (file_name , gen_llink_user_valid      (llink['NAME'] ))
            if configuration['REPLICATED_STRUCT'] and gen_direction(name_file_name, llink['DIR'], False) == "output":
                print_verilog_logic_line (file_name , gen_llink_concat_fifoname (llink['NAME'], gen_direction(name_file_name, llink['DIR'], False)), gen_index_msb(llink['WIDTH_RX_RSTRUCT'] * configuration['RSTRUCT_MULTIPLY_FACTOR'], sysv=False))
                print_verilog_logic_line (file_name , gen_llink_user_fifoname   (llink['NAME'], gen_direction(name_file_name, llink['DIR'], True)),  gen_index_msb(llink['WIDTH_RX_RSTRUCT'] * configuration['RSTRUCT_MULTIPLY_FACTOR'], sysv=False))
            else:
                print_verilog_logic_line (file_name , gen_llink_concat_fifoname (llink['NAME'], gen_direction(name_file_name, llink['DIR'], False)), gen_index_msb(llink['WIDTH_MAIN']       * configuration['RSTRUCT_MULTIPLY_FACTOR'], sysv=False))
                print_verilog_logic_line (file_name , gen_llink_user_fifoname   (llink['NAME'], gen_direction(name_file_name, llink['DIR'], True)),  gen_index_msb(llink['WIDTH_MAIN']       * configuration['RSTRUCT_MULTIPLY_FACTOR'], sysv=False))
            if llink['HASREADY']:
                if configuration['REPLICATED_STRUCT'] and gen_direction(name_file_name, llink['DIR'], False) == "input":
                    print_verilog_logic_line (file_name , gen_llink_concat_credit   (llink['NAME'], gen_direction(name_file_name, llink['DIR'], False)), gen_index_msb(4, sysv=False))
                else:
                    print_verilog_logic_line (file_name , gen_llink_concat_credit   (llink['NAME'], gen_direction(name_file_name, llink['DIR'], False)))
                print_verilog_logic_line (file_name , gen_llink_user_ready      (llink['NAME'] ))
            print_verilog_logic_line (file_name , gen_llink_concat_ovrd     (llink['NAME'], gen_direction(name_file_name, llink['DIR'], False)))
            file_name.write("\n")

        print_verilog_logic_line (file_name , "tx_auto_mrk_userbit", gen_index_msb(configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] // configuration['CHAN_RX_RAW1PHY_BEAT_MAIN'], sysv=False) )
        print_verilog_logic_line (file_name , "tx_auto_stb_userbit" )
        print_verilog_logic_line (file_name , "tx_online_delay"     )
        print_verilog_logic_line (file_name , "rx_online_delay"     )

        #if configuration['RX_USER_MARKER'] == False:
        #    print_verilog_logic_line (file_name ,"rx_mrk_userbit", gen_index_msb(configuration['NUM_CHAN'], sysv=False), comment="No RX User Marker, so no connect")
        #if configuration['RX_USER_STROBE'] == False:
        #    print_verilog_logic_line (file_name ,"rx_stb_userbit", gen_index_msb(configuration['NUM_CHAN'], sysv=False), comment="No RX User Strobe, so no connect")
        if (configuration['TX_USER_MARKER'] if direction == 'master' else configuration['RX_USER_MARKER']) == False:
            print_verilog_logic_line (file_name ,"tx_mrk_userbit", gen_index_msb(configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] // configuration['CHAN_RX_RAW1PHY_BEAT_MAIN'], sysv=False), comment="No TX User Marker, so tie off")
        if (configuration['TX_USER_STROBE'] if direction == 'master' else configuration['RX_USER_STROBE']) == False:
            print_verilog_logic_line (file_name ,"tx_stb_userbit", comment="No TX User Strobe, so tie off")

        if (configuration['TX_USER_MARKER'] if direction == 'master' else configuration['RX_USER_MARKER']) == False:
            print_verilog_assign(file_name, "tx_mrk_userbit", "'0")
        if (configuration['TX_USER_STROBE'] if direction == 'master' else configuration['RX_USER_STROBE']) == False:
            print_verilog_assign(file_name, "tx_stb_userbit", "'1") ## Modest value in driving a 1.


        file_name.write("\n")
        file_name.write("// Interconnect Wires\n")
        file_name.write("//////////////////////////////////////////////////////////////////\n")
        file_name.write("\n")
        file_name.write("//////////////////////////////////////////////////////////////////\n")
        file_name.write("// Auto Sync\n")
        file_name.write("\n")
        file_name.write("   ll_auto_sync #(.MARKER_WIDTH({}),\n".format(configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] // configuration['CHAN_RX_RAW1PHY_BEAT_MAIN']))
        if configuration['TX_PERSISTENT_MARKER'] if direction == 'master' else configuration['RX_PERSISTENT_MARKER']:
            file_name.write("                  .PERSISTENT_MARKER(1'b1),\n")
        else:
            file_name.write("                  .PERSISTENT_MARKER(1'b0),\n")

        if configuration['TX_PERSISTENT_STROBE'] if direction == 'master' else configuration['RX_PERSISTENT_STROBE']:
            file_name.write("                  .PERSISTENT_STROBE(1'b1)) ll_auto_sync_i\n")
        else:
            file_name.write("                  .PERSISTENT_STROBE(1'b0)) ll_auto_sync_i\n")
        file_name.write("     (// Outputs\n")
        file_name.write("      .tx_online_delay                  (tx_online_delay),\n")
        file_name.write("      .tx_auto_mrk_userbit              (tx_auto_mrk_userbit),\n")
        file_name.write("      .tx_auto_stb_userbit              (tx_auto_stb_userbit),\n")
        file_name.write("      .rx_online_delay                  (rx_online_delay),\n")
        file_name.write("      // Inputs\n")
        file_name.write("      .clk_wr                           (clk_wr),\n")
        file_name.write("      .rst_wr_n                         (rst_wr_n),\n")
        file_name.write("      .tx_online                        (tx_online),\n")
        file_name.write("      .delay_xz_value                   (delay_xz_value[7:0]),\n")
        file_name.write("      .delay_yz_value                   (delay_yz_value[7:0]),\n")
        file_name.write("      .tx_mrk_userbit                   (tx_mrk_userbit),\n")
        file_name.write("      .tx_stb_userbit                   (tx_stb_userbit),\n")
        file_name.write("      .rx_online                        (rx_online),\n")
        file_name.write("      .delay_x_value                    (delay_x_value[7:0]));\n")
        file_name.write("\n")
        file_name.write("// Auto Sync\n")
        file_name.write("//////////////////////////////////////////////////////////////////\n")
        file_name.write("\n")
        file_name.write("//////////////////////////////////////////////////////////////////\n")
        file_name.write("// Logic Link Instantiation\n")
        file_name.write("\n")

        if direction == 'master':
            localdir = 'output';
        else:
            localdir = 'input';

        for llink in configuration['LL_LIST']:
            if not llink['HASREADY'] and not llink['HASVALID']:
                file_name.write("  // No AXI Valid or Ready, so bypassing main Logic Link FIFO and Credit logic.\n")
                if llink['DIR'] == localdir:
                    print_verilog_assign(file_name, "tx_{0}_data".format(llink['NAME']), "txfifo_{0}_data".format(llink['NAME']), index1=gen_index_msb (llink['WIDTH_MAIN']) * configuration['RSTRUCT_MULTIPLY_FACTOR'], index2=gen_index_msb (llink['WIDTH_MAIN']))
                    print_verilog_assign(file_name, "tx_{0}_debug_status".format(llink['NAME']), "32'h0", index1=gen_index_msb (32))
                else:
                    if configuration['REPLICATED_STRUCT']:
                        print_verilog_assign(file_name, "rxfifo_{0}_data".format(llink['NAME']), "rx_{0}_data".format(llink['NAME']), index1=gen_index_msb (llink['WIDTH_RX_RSTRUCT'] * configuration['RSTRUCT_MULTIPLY_FACTOR']), index2=gen_index_msb (llink['WIDTH_MAIN']))
                    else:
                        print_verilog_assign(file_name, "rxfifo_{0}_data".format(llink['NAME']), "rx_{0}_data".format(llink['NAME']), index1=gen_index_msb (llink['WIDTH_MAIN']       * configuration['RSTRUCT_MULTIPLY_FACTOR']), index2=gen_index_msb (llink['WIDTH_MAIN']))
                    print_verilog_assign(file_name, "rx_{0}_debug_status".format(llink['NAME']), "32'h0", index1=gen_index_msb (32))
            else:
                if llink['DIR'] == localdir:
                    if configuration['REPLICATED_STRUCT']:
                        file_name.write("      ll_transmit #(.WIDTH({1}), .DEPTH(8'd{2}), .TX_CRED_SIZE(3'h{3}), .ASYMMETRIC_CREDIT(1'b1), .DEFAULT_TX_CRED(8'd{4})) ll_transmit_i{0}\n".format(llink['NAME'], llink['WIDTH_MAIN'] * configuration['RSTRUCT_MULTIPLY_FACTOR'], llink['TX_FIFO_DEPTH'], configuration['RSTRUCT_MULTIPLY_FACTOR'], llink['RX_FIFO_DEPTH']))
                    else:
                        file_name.write("      ll_transmit #(.WIDTH({1}), .DEPTH(8'd{2}), .TX_CRED_SIZE(3'h{3}), .ASYMMETRIC_CREDIT(1'b0), .DEFAULT_TX_CRED(8'd{4})) ll_transmit_i{0}\n".format(llink['NAME'], llink['WIDTH_MAIN'] * configuration['RSTRUCT_MULTIPLY_FACTOR'], llink['TX_FIFO_DEPTH'], "1", llink['RX_FIFO_DEPTH']))
                    file_name.write("        (// Outputs\n")
                    if llink['HASREADY']:
                        file_name.write("         .user_i_ready                     (user_{0}_ready),\n".format(llink['NAME']))
                    else:
                        file_name.write("         .user_i_ready                     (),\n")
                    file_name.write("         .tx_i_data                        (tx_{0}_data[{1}:0]),\n".format(llink['NAME'], (llink['WIDTH_MAIN'] * configuration['RSTRUCT_MULTIPLY_FACTOR'])-1))
                    file_name.write("         .tx_i_pushbit                     (tx_{0}_pushbit),\n".format(llink['NAME']))
                    file_name.write("         .tx_i_debug_status                (tx_{0}_debug_status[31:0]),\n".format(llink['NAME']))
                    file_name.write("         // Inputs\n")
                    file_name.write("         .clk_wr                           (clk_wr),\n")
                    file_name.write("         .rst_wr_n                         (rst_wr_n),\n")
                    if configuration['REPLICATED_STRUCT']:
                        file_name.write("         .end_of_txcred_coal               (tx_mrk_userbit[{}]),\n".format((configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] // configuration['CHAN_RX_RAW1PHY_BEAT_MAIN']) - 1))
                    else:
                        file_name.write("         .end_of_txcred_coal               (1'b1),\n")
                    file_name.write("         .tx_online                        (tx_online_delay),\n")
                    file_name.write("         .init_i_credit                    (init_{0}_credit[7:0]),\n".format(llink['NAME']))
                    file_name.write("         .tx_i_pop_ovrd                    (tx_{0}_pop_ovrd),\n".format(llink['NAME']))
                    file_name.write("         .txfifo_i_data                    (txfifo_{0}_data[{1}:0]),\n".format(llink['NAME'], (llink['WIDTH_MAIN'] * configuration['RSTRUCT_MULTIPLY_FACTOR'])-1))
                    file_name.write("         .user_i_valid                     (user_{0}_valid),\n".format(llink['NAME']))
                    if llink['HASREADY']:
                        if configuration['REPLICATED_STRUCT'] and gen_direction(name_file_name, llink['DIR'], False) == "input":
                            file_name.write("         .rx_i_credit                      (rx_{0}_credit[3:0]));\n".format(llink['NAME']))
                        else:
                            file_name.write("         .rx_i_credit                      ({{3'b0,rx_{0}_credit}}));\n".format(llink['NAME']))
                    else:
                        file_name.write("         .rx_i_credit                      (4'b1));\n")
                else:
                    if configuration['REPLICATED_STRUCT']:
                        file_name.write("      ll_receive #(.WIDTH({1}), .DEPTH(8'd{2})) ll_receive_i{0}\n".format(llink['NAME'], llink['WIDTH_RX_RSTRUCT'] * configuration['RSTRUCT_MULTIPLY_FACTOR'], (int(llink['RX_FIFO_DEPTH']) + configuration['RSTRUCT_MULTIPLY_FACTOR'] - 1) // configuration['RSTRUCT_MULTIPLY_FACTOR']))
                        file_name.write("        (// Outputs\n")
                        file_name.write("         .rxfifo_i_data                    (rxfifo_{0}_data[{1}:0]),\n".format(llink['NAME'], (llink['WIDTH_RX_RSTRUCT'] * configuration['RSTRUCT_MULTIPLY_FACTOR'])-1))
                    else:
                        file_name.write("      ll_receive #(.WIDTH({1}), .DEPTH(8'd{2})) ll_receive_i{0}\n".format(llink['NAME'], llink['WIDTH_MAIN']       * configuration['RSTRUCT_MULTIPLY_FACTOR'], llink['RX_FIFO_DEPTH']))
                        file_name.write("        (// Outputs\n")
                        file_name.write("         .rxfifo_i_data                    (rxfifo_{0}_data[{1}:0]),\n".format(llink['NAME'], (llink['WIDTH_MAIN'] * configuration['RSTRUCT_MULTIPLY_FACTOR'])-1))
                    file_name.write("         .user_i_valid                     (user_{0}_valid),\n".format(llink['NAME']))
                    if llink['HASREADY']:
                        file_name.write("         .tx_i_credit                      (tx_{0}_credit),\n".format(llink['NAME']))
                    else:
                        file_name.write("         .tx_i_credit                      (),\n")
                    file_name.write("         .rx_i_debug_status                (rx_{0}_debug_status[31:0]),\n".format(llink['NAME']))
                    file_name.write("         // Inputs\n")
                    file_name.write("         .clk_wr                           (clk_wr),\n")
                    file_name.write("         .rst_wr_n                         (rst_wr_n),\n")
                    file_name.write("         .rx_online                        (rx_online_delay),\n")
                    file_name.write("         .rx_i_push_ovrd                   (rx_{0}_push_ovrd),\n".format(llink['NAME']))
                    if configuration['REPLICATED_STRUCT']:
                        file_name.write("         .rx_i_data                        (rx_{0}_data[{1}:0]),\n".format(llink['NAME'], (llink['WIDTH_RX_RSTRUCT'] * configuration['RSTRUCT_MULTIPLY_FACTOR'])-1))
                    else:
                        file_name.write("         .rx_i_data                        (rx_{0}_data[{1}:0]),\n".format(llink['NAME'], (llink['WIDTH_MAIN'] * configuration['RSTRUCT_MULTIPLY_FACTOR'])-1))
                    file_name.write("         .rx_i_pushbit                     (rx_{0}_pushbit),\n".format(llink['NAME']))
                    if llink['HASREADY']:
                        file_name.write("         .user_i_ready                     (user_{0}_ready));\n".format(llink['NAME']))
                    else:
                        file_name.write("         .user_i_ready                     (1'b1));\n")
            file_name.write("\n")
        file_name.write("// Logic Link Instantiation\n")
        file_name.write("//////////////////////////////////////////////////////////////////\n")
        file_name.write("\n")
        file_name.write("//////////////////////////////////////////////////////////////////\n")
        file_name.write("// User Interface\n")
        file_name.write("\n")
        file_name.write("      {0}_{1}_name {0}_{1}_name\n".format(configuration['MODULE'], direction))
        file_name.write("      (\n")


        # List User Signals
        for llink in configuration['LL_LIST']:
            for sig in llink['SIGNALLIST_MAIN']:
                if sig['TYPE'] == "rstruct_enable" and localdir == "output":
                    continue
                file_name.write("         .{2:30}   ({2}{1}),\n".format(localdir, gen_index_msb(sig['SIGWID'] * configuration['RSTRUCT_MULTIPLY_FACTOR'], sig['LSB'], sysv=False), sig['NAME']))

        file_name.write("\n")
        # List Logic Link Signals
        for llink in configuration['LL_LIST']:
            localmsb = str (int(llink['WIDTH_MAIN']) - 1);

            prefix = 'rx';
            if llink['DIR'] == 'output' and direction == 'master':
                prefix = 'tx';
            if llink['DIR'] == 'input' and direction == 'slave':
                prefix = 'tx';

            if llink['HASVALID']:
                file_name.write("         .{0:30}   ({0}),\n".format("user_{}_valid".format(llink['NAME'])))
            if configuration['REPLICATED_STRUCT'] and localdir == "input":
                file_name.write("         .{0:30}   ({0}{1}),\n".format("{}fifo_{}_data".format(prefix,llink['NAME']), gen_index_msb(llink['WIDTH_RX_RSTRUCT'] * configuration['RSTRUCT_MULTIPLY_FACTOR'], sysv=False)))
            else:
                file_name.write("         .{0:30}   ({0}{1}),\n".format("{}fifo_{}_data".format(prefix,llink['NAME']), gen_index_msb(llink['WIDTH_MAIN'] * configuration['RSTRUCT_MULTIPLY_FACTOR'], sysv=False)))
            if llink['HASREADY']:
                file_name.write("         .{0:30}   ({0}),\n".format("user_{}_ready".format(llink['NAME'])))
        file_name.write("\n")
        file_name.write("         .{0:30}   ({0}{1})\n".format("m_gen2_mode", ""))
        file_name.write("\n      );")
        file_name.write("\n")
        file_name.write("// User Interface                                                 \n")
        file_name.write("//////////////////////////////////////////////////////////////////\n")
        file_name.write("\n")
        file_name.write("//////////////////////////////////////////////////////////////////\n")
        file_name.write("// PHY Interface\n")
        file_name.write("\n")
        file_name.write("      {0}_{1}_concat {0}_{1}_concat\n".format(configuration['MODULE'], direction))
        file_name.write("      (\n")

        # Logic Link Signaling
        if direction == 'master':
            localdir   = 'output';
            prefix_tx  = 'tx';
            prefix_rx  = 'rx';
        else:
            localdir   = 'input';
            prefix_tx  = 'tx';
            prefix_rx  = 'rx';

        for llink in configuration['LL_LIST']:
            if llink['DIR'] == localdir:
                file_name.write("         .{0:30}   ({0}{1}),\n".format("{0}_{1}_data".format(prefix_tx,llink['NAME']), gen_index_msb(llink['WIDTH_MAIN'] * configuration['RSTRUCT_MULTIPLY_FACTOR'])))
                file_name.write("         .{0:30}   ({0}),\n".format("{0}_{1}_pop_ovrd".format(prefix_tx,llink['NAME'])))
                if llink['HASVALID']:
                    file_name.write("         .{0:30}   ({0}),\n".format("{0}_{1}_pushbit".format(prefix_tx,llink['NAME'])))
                if llink['HASREADY']:
                    if configuration['REPLICATED_STRUCT']:
                       file_name.write("         .{0:30}   ({0}{1}),\n".format("{0}_{1}_credit".format(prefix_rx,llink['NAME']), gen_index_msb(4)))
                    else:
                       file_name.write("         .{0:30}   ({0}{1}),\n".format("{0}_{1}_credit".format(prefix_rx,llink['NAME']), "" ))
            else:
                if configuration['REPLICATED_STRUCT']:
                    file_name.write("         .{0:30}   ({0}{1}),\n".format("{0}_{1}_data".format(prefix_rx,llink['NAME']), gen_index_msb(llink['WIDTH_RX_RSTRUCT'] * configuration['RSTRUCT_MULTIPLY_FACTOR'])))
                else:
                    file_name.write("         .{0:30}   ({0}{1}),\n".format("{0}_{1}_data".format(prefix_rx,llink['NAME']), gen_index_msb(llink['WIDTH_MAIN'] * configuration['RSTRUCT_MULTIPLY_FACTOR'])))
                file_name.write("         .{0:30}   ({0}),\n".format("{0}_{1}_push_ovrd".format(prefix_rx,llink['NAME'])))
                if llink['HASVALID']:
                    file_name.write("         .{0:30}   ({0}),\n".format("{0}_{1}_pushbit".format(prefix_rx,llink['NAME'])))
                if llink['HASREADY']:
                    if configuration['REPLICATED_STRUCT']:
                        if configuration['RSTRUCT_MULTIPLY_FACTOR'] == 1:
                            vector = "1"
                        if configuration['RSTRUCT_MULTIPLY_FACTOR'] == 2:
                            vector = "3"
                        if configuration['RSTRUCT_MULTIPLY_FACTOR'] == 4:
                            vector = "f"

                        file_name.write("         .{0:30}   ({1}),\n".format("{0}_{1}_credit".format(prefix_tx,llink['NAME']) , "{0}_{1}_credit ? 4'h{2} : 4'h0".format(prefix_tx, llink['NAME'], vector) ))
                    else:
                        file_name.write("         .{0:30}   ({0}),\n".format("{0}_{1}_credit".format(prefix_tx,llink['NAME'])))


        file_name.write("\n")
        # Logic Link Inputs
        for phy in range(configuration['NUM_CHAN']):
            localindex = "[{0}:0]".format(configuration['CHAN_TX_RAW1PHY_DATA_MAIN']-1)
            file_name.write("         .{0:30}   ({0}{1}),\n".format("tx_phy{}".format(phy), localindex))
            file_name.write("         .{0:30}   ({0}{1}),\n".format("rx_phy{}".format(phy), localindex))

        file_name.write("\n")
        file_name.write("         .{0:30}   ({1}),\n".format("clk_wr", "clk_wr"))
        file_name.write("         .{0:30}   ({1}),\n".format("clk_rd", "clk_wr"))
        file_name.write("         .{0:30}   ({1}),\n".format("rst_wr_n", "rst_wr_n"))
        file_name.write("         .{0:30}   ({1}),\n".format("rst_rd_n", "rst_wr_n"))
        file_name.write("\n")
        file_name.write("         .{0:30}   ({0}{1}),\n".format("m_gen2_mode", ""))
        file_name.write("         .{0:30}   ({1}),\n".format("tx_online", "tx_online_delay"))
        file_name.write("\n")
        file_name.write("         .{0:30}   ({1}),\n".format("tx_stb_userbit", "tx_auto_stb_userbit"))
        file_name.write("         .{0:30}   ({1})\n".format("tx_mrk_userbit", "tx_auto_mrk_userbit"))
        file_name.write("\n")

        file_name.write("      );\n")
        file_name.write("\n")
        file_name.write("// PHY Interface\n")
        file_name.write("//////////////////////////////////////////////////////////////////\n")
        file_name.write("\n")
        file_name.write("\n")
        file_name.write("endmodule\n")
        file_name.close()
    return

## make_top_file
##########################################################################################

##########################################################################################
## make_list_files
## Make the .f files

def make_list_files(configuration):

    cwd = os.getcwd()

    path = os.path.realpath(configuration['OUTPUT_DIR'])
    proj_dir = os.getenv("PROJ_DIR")
    path = path.replace (proj_dir,"${PROJ_DIR}")

    for direction in ['master', 'slave']:
        name_file_name   = "{}_{}".format(configuration['MODULE'], direction)
        file_name       = open("{}/{}.f".format(configuration['OUTPUT_DIR'], name_file_name), "w+")

        file_name.write("// Generated Files\n")
        file_name.write("{}/{}_{}_top.sv   \n".format(path,configuration['MODULE'], direction))
        file_name.write("{}/{}_{}_concat.sv\n".format(path,configuration['MODULE'], direction))
        file_name.write("{}/{}_{}_name.sv  \n".format(path,configuration['MODULE'], direction))
        file_name.write("\n")
        file_name.write("// Logic Link files\n")
        file_name.write("-f ${PROJ_DIR}/llink/rtl/llink.f\n")
        file_name.write("\n")
        file_name.write("// Common Files\n")
        file_name.write("-f ${PROJ_DIR}/common/rtl/common.f\n")
        file_name.close()
    return

## make_list_files
##########################################################################################

##########################################################################################
## make_info_file
## this makes the INFO file, but most of the information has been
## generated elsewhere (e.g. in the g_info_print list)

def make_info_file(configuration):

    name_file_name   = "{}_info".format(configuration['MODULE'])
    file_name        = open("{}/{}.txt".format(configuration['OUTPUT_DIR'], name_file_name), "w+")
    print_verilog_header(file_name)

    file_name.write ("//////////////////////////////////////////////////////////////////////\n")
    file_name.write ("// Data and Channel Size\n")
    for string in global_struct.g_info_print:
        file_name.write (string)
    file_name.write ("// Data and Channel Size\n")
    file_name.write ("//////////////////////////////////////////////////////////////////////\n")
    file_name.write ("\n")

    if (not configuration ['TX_ENABLE_PACKETIZATION'] or not configuration ['RX_ENABLE_PACKETIZATION']) and not configuration['GEN2_AS_GEN1_EN']:
        file_name.write ("//////////////////////////////////////////////////////////////////////\n")
        file_name.write ("// AXI to Logic Link Data Mapping\n")
        file_name.write ("// This AXI Data FIFO packing\n")
        for string in global_struct.g_llink_vector_print_tx:
            file_name.write (string)
        file_name.write ("\n")

        for string in global_struct.g_llink_vector_print_rx:
            file_name.write (string)

        file_name.write ("// AXI to Logic Link Data Mapping\n")
        file_name.write ("//////////////////////////////////////////////////////////////////////\n")
        file_name.write ("\n")

    if configuration ['TX_ENABLE_PACKETIZATION']:
        file_name.write ("//////////////////////////////////////////////////////////////////////\n")
        file_name.write ("// Master to Slave Packetization\n")
        for string in global_struct.g_packet_print_tx:
            file_name.write (string)
        file_name.write ("\n")

        file_name.write ("// Master to Slave Packetization\n")
        file_name.write ("//////////////////////////////////////////////////////////////////////\n")
        file_name.write ("\n")

    if configuration ['RX_ENABLE_PACKETIZATION']:
        file_name.write ("//////////////////////////////////////////////////////////////////////\n")
        file_name.write ("// Slave to Master Packetization\n")
        for string in global_struct.g_packet_print_rx:
            string = re.sub('tx_packet_enc',    'rx_packet_enc',    string)
            string = re.sub('tx_packet_data',   'rx_packet_data',   string)
            string = re.sub('tx_packet_common', 'rx_packet_common', string)
            string = re.sub('= tx_', '= rx_', string)
            file_name.write (string)
        file_name.write ("\n")

        file_name.write ("// Slave to Master Packetization\n")
        file_name.write ("//////////////////////////////////////////////////////////////////////\n")
        file_name.write ("\n")

    file_name.write ("//////////////////////////////////////////////////////////////////////\n")
    file_name.write ("// AXI to PHY IF Mapping AXI Manager Transmit\n")
    for string in global_struct.g_debug_raw_data_vector_print_tx:
        file_name.write (string)

    file_name.write ("// AXI to PHY IF Mapping AXI Manager Transmit\n")
    file_name.write ("//////////////////////////////////////////////////////////////////////\n")
    file_name.write ("\n")

    file_name.write ("//////////////////////////////////////////////////////////////////////\n")
    file_name.write ("// AXI to PHY IF Mapping AXI Manager Receive\n")
    for string in global_struct.g_debug_raw_data_vector_print_rx:
        file_name.write (string)
    file_name.write ("// AXI to PHY IF Mapping AXI Manager Receive\n")
    file_name.write ("//////////////////////////////////////////////////////////////////////\n")

    file_name.close()
    return

## make_info_file
##########################################################################################

##########################################################################################
## print_aib_assign_text_check_for_aib_bit
## Common functioned used to insert DBI, Markers, etc.

def print_aib_assign_text_check_for_aib_bit(configuration, local_lsb1, use_tx,  sysv = True):

    check_for_more_bit = True
    starting_lsb = local_lsb1

    if global_struct.g_SIGNAL_DEBUG:
        print ("entering       print_aib_assign_text_check_for_aib_bit for {} for lsb {}".format("TX" if use_tx else "RX", local_lsb1))
    while (check_for_more_bit):

        if global_struct.g_SIGNAL_DEBUG:
            print ("    executing  print_aib_assign_text_check_for_aib_bit for {} for lsb {}".format("TX" if use_tx else "RX", local_lsb1))

        check_for_more_bit = False


        ## This stops us from rolling over into the next region
        if configuration ['REPLICATED_STRUCT']:
          if ((local_lsb1   // (configuration['CHAN_TX_RAW1PHY_BEAT_MAIN'] if use_tx else configuration['CHAN_RX_RAW1PHY_BEAT_MAIN'])) !=
              (starting_lsb // (configuration['CHAN_TX_RAW1PHY_BEAT_MAIN'] if use_tx else configuration['CHAN_RX_RAW1PHY_BEAT_MAIN'])) ):
              check_for_more_bit = False
              continue

        if local_lsb1 == (configuration['NUM_CHAN'] * (configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] if use_tx else configuration['CHAN_RX_RAW1PHY_DATA_MAIN'])):
              check_for_more_bit = False
              continue

        if use_tx:
            if configuration['TX_DBI_PRESENT']:
                if ((local_lsb1 + 1) % 40) == 0 or ((local_lsb1 + 1) % 40 == 39):
                    global_struct.g_debug_raw_data_vector_print_tx.append("{0:15} [{1:4}] = 1'b0 // DBI\n".format("  Channel {} TX  ".format(int(local_lsb1) // configuration['CHAN_TX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_TX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_concat_code_vector_master_tx.append("{0:20} [{1:4}] = 1'b0                       ; // DBI\n".format("  assign tx_phy_preflop_{}".format(int(local_lsb1) // configuration['CHAN_TX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_TX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_concat_code_vector_slave_rx.append("//       DBI                        = {0:17} [{1:4}];\n".format("rx_phy_postflop_{}".format(int(local_lsb1) // configuration['CHAN_TX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_TX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_dv_tx_dbi_vector_print.append ("(1<<{}) | ".format(local_lsb1))
                    local_lsb1 += 1
                    check_for_more_bit = True
                    continue

            if configuration['TX_ENABLE_STROBE'] and configuration['TX_PERSISTENT_STROBE'] :
                if ((                                        local_lsb1 % configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] == configuration['TX_STROBE_GEN2_LOC']) or
                    (configuration ['REPLICATED_STRUCT'] and local_lsb1 % configuration['CHAN_TX_RAW1PHY_DATA_MAIN'] == configuration['TX_STROBE_GEN2_LOC']) ):
                    global_struct.g_debug_raw_data_vector_print_tx.append("{0:15} [{1:4}] = 1'b1 // STROBE\n".format("  Channel {} TX  ".format(int(local_lsb1) // configuration['CHAN_TX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_TX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_concat_code_vector_master_tx.append("{0:20} [{1:4}] = tx_stb_userbit             ; // STROBE\n".format("  assign tx_phy_preflop_{}".format(int(local_lsb1) // configuration['CHAN_TX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_TX_RAW1PHY_DATA_MAIN'], int(local_lsb1) // configuration['CHAN_TX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_concat_code_vector_slave_rx.append("//       STROBE                     = {0:17} [{1:4}]\n".format("rx_phy_postflop_{}".format(int(local_lsb1) // configuration['CHAN_TX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_TX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_dv_tx_strobe_vector_print.append ("(1<<{}) | ".format(local_lsb1))
                    local_lsb1 += 1
                    check_for_more_bit = True
                    continue
                elif ((configuration ['REPLICATED_STRUCT'] and local_lsb1 % configuration['CHAN_TX_RAW1PHY_BEAT_MAIN'] == configuration['TX_STROBE_GEN2_LOC']) ):
                    global_struct.g_debug_raw_data_vector_print_tx.append("{0:15} [{1:4}] = 1'b1 // STROBE\n".format("  Channel {} TX  ".format(int(local_lsb1) // configuration['CHAN_TX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_TX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_concat_code_vector_master_tx.append("{0:20} [{1:4}] = 1'b0                       ; // STROBE (unused)\n".format("  assign tx_phy_preflop_{}".format(int(local_lsb1) // configuration['CHAN_TX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_TX_RAW1PHY_DATA_MAIN'], int(local_lsb1) // configuration['CHAN_TX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_concat_code_vector_slave_rx.append("//       STROBE                     = {0:17} [{1:4}]\n".format("rx_phy_postflop_{}".format(int(local_lsb1) // configuration['CHAN_TX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_TX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_dv_tx_strobe_vector_print.append ("(1<<{}) | ".format(local_lsb1))
                    local_lsb1 += 1
                    check_for_more_bit = True
                    continue

            if configuration['TX_ENABLE_MARKER'] and configuration['TX_PERSISTENT_MARKER'] :
                if local_lsb1 % configuration['CHAN_TX_RAW1PHY_BEAT_MAIN'] == configuration['TX_MARKER_GEN2_LOC']:
                    global_struct.g_debug_raw_data_vector_print_tx.append("{0:15} [{1:4}] = 1'b0 // MARKER\n".format("  Channel {} TX  ".format(int(local_lsb1) // configuration['CHAN_TX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_TX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_concat_code_vector_master_tx.append("{0:20} [{1:4}] = tx_mrk_userbit[{2}]          ; // MARKER\n".format("  assign tx_phy_preflop_{}".format(int(local_lsb1) // configuration['CHAN_TX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_TX_RAW1PHY_DATA_MAIN'], (int(local_lsb1) % configuration['CHAN_TX_RAW1PHY_DATA_MAIN']) // configuration['CHAN_TX_RAW1PHY_BEAT_MAIN']))
                    global_struct.g_concat_code_vector_slave_rx.append("//       MARKER                     = {0:17} [{1:4}]\n".format("rx_phy_postflop_{}".format(int(local_lsb1) // configuration['CHAN_TX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_TX_RAW1PHY_DATA_MAIN'], (int(local_lsb1) % configuration['CHAN_TX_RAW1PHY_DATA_MAIN']) // configuration['CHAN_TX_RAW1PHY_BEAT_MAIN']))
                    global_struct.g_dv_tx_marker_vector_print.append ("(1<<{}) | ".format(local_lsb1))
                    local_lsb1 += 1
                    check_for_more_bit = True
                    continue
        else:
            if configuration['RX_DBI_PRESENT'] :
                if ((local_lsb1 + 1) % 40) == 0 or ((local_lsb1 + 1) % 40 == 39):
                    global_struct.g_debug_raw_data_vector_print_rx.append("{0:15} [{1:4}] = 1'b0 // DBI\n".format("  Channel {} RX  ".format(int(local_lsb1) // configuration['CHAN_RX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_RX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_concat_code_vector_master_rx.append("//       DBI                        = {0:17} [{1:4}];\n".format("rx_phy_postflop_{}".format(int(local_lsb1) // configuration['CHAN_RX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_RX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_concat_code_vector_slave_tx.append("{0:20} [{1:4}] = 1'b0                       ; // DBI\n".format("  assign tx_phy_preflop_{}".format(int(local_lsb1) // configuration['CHAN_RX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_RX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_dv_rx_dbi_vector_print.append ("(1<<{}) | ".format(local_lsb1))
                    local_lsb1 += 1
                    check_for_more_bit = True
                    continue

            if configuration['RX_ENABLE_STROBE'] and configuration['RX_PERSISTENT_STROBE'] :
                if ((                                        local_lsb1 % configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] == configuration['RX_STROBE_GEN2_LOC']) or
                    (configuration ['REPLICATED_STRUCT'] and local_lsb1 % configuration['CHAN_RX_RAW1PHY_DATA_MAIN'] == configuration['RX_STROBE_GEN2_LOC']) ):
                    global_struct.g_debug_raw_data_vector_print_rx.append("{0:15} [{1:4}] = 1'b1 // STROBE\n".format("  Channel {} RX  ".format(int(local_lsb1) // configuration['CHAN_RX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_RX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_concat_code_vector_master_rx.append("//       STROBE                     = {0:17} [{1:4}]\n".format("rx_phy_postflop_{}".format(int(local_lsb1) // configuration['CHAN_RX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_RX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_concat_code_vector_slave_tx.append("{0:20} [{1:4}] = tx_stb_userbit             ; // STROBE\n".format("  assign tx_phy_preflop_{}".format(int(local_lsb1) // configuration['CHAN_RX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_RX_RAW1PHY_DATA_MAIN'], int(local_lsb1) // configuration['CHAN_RX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_dv_rx_strobe_vector_print.append ("(1<<{}) | ".format(local_lsb1))
                    local_lsb1 += 1
                    check_for_more_bit = True
                    continue
                elif ((configuration ['REPLICATED_STRUCT'] and local_lsb1 % configuration['CHAN_RX_RAW1PHY_BEAT_MAIN'] == configuration['RX_STROBE_GEN2_LOC']) ):
                    global_struct.g_debug_raw_data_vector_print_rx.append("{0:15} [{1:4}] = 1'b1 // STROBE\n".format("  Channel {} RX  ".format(int(local_lsb1) // configuration['CHAN_RX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_RX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_concat_code_vector_master_rx.append("//       STROBE                     = {0:17} [{1:4}]\n".format("rx_phy_postflop_{}".format(int(local_lsb1) // configuration['CHAN_RX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_RX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_concat_code_vector_slave_tx.append("{0:20} [{1:4}] = 1'b0                       ; // STROBE (unused)\n".format("  assign tx_phy_preflop_{}".format(int(local_lsb1) // configuration['CHAN_RX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_RX_RAW1PHY_DATA_MAIN'], int(local_lsb1) // configuration['CHAN_RX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_dv_rx_strobe_vector_print.append ("(1<<{}) | ".format(local_lsb1))
                    local_lsb1 += 1
                    check_for_more_bit = True
                    continue

            if configuration['RX_ENABLE_MARKER'] and configuration['RX_PERSISTENT_MARKER'] :
                if local_lsb1 % configuration['CHAN_RX_RAW1PHY_BEAT_MAIN'] == configuration['RX_MARKER_GEN2_LOC']:
                    global_struct.g_debug_raw_data_vector_print_rx.append("{0:15} [{1:4}] = 1'b0 // MARKER\n".format("  Channel {} RX  ".format(int(local_lsb1) // configuration['CHAN_RX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_RX_RAW1PHY_DATA_MAIN']))
                    global_struct.g_concat_code_vector_master_rx.append("//       MARKER                     = {0:17} [{1:4}]\n".format("rx_phy_postflop_{}".format(int(local_lsb1) // configuration['CHAN_RX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_RX_RAW1PHY_DATA_MAIN'], (int(local_lsb1) % configuration['CHAN_RX_RAW1PHY_DATA_MAIN']) // configuration['CHAN_RX_RAW1PHY_BEAT_MAIN']))
                    global_struct.g_concat_code_vector_slave_tx.append("{0:20} [{1:4}] = tx_mrk_userbit[{2}]          ; // MARKER\n".format("  assign tx_phy_preflop_{}".format(int(local_lsb1) // configuration['CHAN_RX_RAW1PHY_DATA_MAIN']), local_lsb1 % configuration['CHAN_RX_RAW1PHY_DATA_MAIN'], (int(local_lsb1) % configuration['CHAN_RX_RAW1PHY_DATA_MAIN']) // configuration['CHAN_RX_RAW1PHY_BEAT_MAIN']))
                    global_struct.g_dv_rx_marker_vector_print.append ("(1<<{}) | ".format(local_lsb1))
                    local_lsb1 += 1
                    check_for_more_bit = True
                    continue

    return local_lsb1

## print_aib_assign_text_check_for_aib_bit
##########################################################################################


##########################################################################################
## print_aib_mapping_text

## Prints out AIB signaling

## This is a big function.
## configuration, direction are obvious
## signal2 = user signal
## wid1 = width of signal (may be less than entire signal)
## lsb1 = lsbit position of AIB line when viewed as long data vector
## lsb2 = lsbit position of signal2 (-1 means it is a scaler)
## llink_lsb = starting position inside the Logic Link (-1 means not part of logic link data)
## llink_name = logic link name (.e.g AR, awbus, etc)
def print_aib_mapping_text(configuration, direction, signal2, wid1, lsb1, lsb2 = -1, llink_lsb=-1, llink_name=""):

    sysv = global_struct.g_USE_SYSTEMV_INDEXING
    use_tx = True if direction == "output" else False

    ## This section prints:
    ## // AXI to Logic Link Data Mapping
    if use_tx:
        if llink_lsb != -1:
            global_struct.g_llink_vector_print_tx.append ("  assign {0:20} {1:13} = {2:20} {3:13}\n".format(gen_llink_concat_fifoname (llink_name,"input" ), gen_index_msb (wid1, llink_lsb, sysv), signal2, gen_index_msb (wid1, lsb2, sysv)))
    else:
        if llink_lsb != -1:
            global_struct.g_llink_vector_print_rx.append ("  assign {0:20} {1:13} = {2:20} {3:13}\n".format(gen_llink_concat_fifoname (llink_name,"output"), gen_index_msb (wid1, llink_lsb, sysv), signal2, gen_index_msb (wid1, lsb2, sysv)))

    local_lsb1 = lsb1
    local_lsb2 = lsb2

    if configuration ['REPLICATED_STRUCT'] and 0:
        tx_chan_width = configuration['CHAN_TX_RAW1PHY_DATA_RSTRUCT']
        rx_chan_width = configuration['CHAN_RX_RAW1PHY_DATA_RSTRUCT']
    else:
        tx_chan_width = configuration['CHAN_TX_RAW1PHY_DATA_MAIN']
        rx_chan_width = configuration['CHAN_RX_RAW1PHY_DATA_MAIN']

    enable_galt = configuration['GEN2_AS_GEN1_EN']

    for each_bit in list (range (0, int(wid1))):

        if use_tx:
            ## TX and RX Section for RTL
            ## Update, 2 DBI bits so we need to do it twice in both place.
            local_lsb1 = print_aib_assign_text_check_for_aib_bit (configuration, local_lsb1, use_tx, sysv)

            if llink_lsb == -1:
                global_struct.g_concat_code_vector_master_tx.append("  assign tx_phy_preflop_{0} [{1:4}] = {2:20}       ;\n".format(int(local_lsb1) // tx_chan_width, local_lsb1 % tx_chan_width, signal2, llink_lsb))
                if signal2 != "1'b0":
                    global_struct.g_concat_code_vector_slave_rx.append("  assign {2:20}       = rx_phy_postflop_{0} [{1:4}];\n".format(int(local_lsb1) // tx_chan_width, local_lsb1 % tx_chan_width, re.sub("^tx_", "rx_", signal2), llink_lsb))
                else:
                    global_struct.g_concat_code_vector_slave_rx.append("//       {2:20}       = rx_phy_postflop_{0} [{1:4}];\n".format(int(local_lsb1) // tx_chan_width, local_lsb1 % tx_chan_width, "nc", llink_lsb))
            elif local_lsb2 == -1:
                global_struct.g_concat_code_vector_master_tx.append("  assign tx_phy_preflop_{0} [{1:4}] = {2:20}[{3:4}] ;\n".format(int(local_lsb1) // tx_chan_width, local_lsb1 % tx_chan_width, gen_llink_concat_fifoname (llink_name,"input" ), llink_lsb))
                if signal2 != "1'b0":
                    global_struct.g_concat_code_vector_slave_rx.append("  assign {2:20}[{3:4}] = rx_phy_postflop_{0} [{1:4}];\n".format(int(local_lsb1) // tx_chan_width, local_lsb1 % tx_chan_width, gen_llink_concat_fifoname (llink_name,"output" ), llink_lsb))
            else:
                global_struct.g_concat_code_vector_master_tx.append("  assign tx_phy_preflop_{0} [{1:4}] = {2:20}[{3:4}] ;\n".format(int(local_lsb1) // tx_chan_width, local_lsb1 % tx_chan_width, gen_llink_concat_fifoname (llink_name,"input" ), llink_lsb))
                if signal2 != "1'b0":
                    global_struct.g_concat_code_vector_slave_rx.append("  assign {2:20}[{3:4}] = rx_phy_postflop_{0} [{1:4}];\n".format(int(local_lsb1) // tx_chan_width, local_lsb1 % tx_chan_width, gen_llink_concat_fifoname (llink_name,"output" ), llink_lsb))



            ## DV Vectors
            if signal2 != "1'b0":
                if llink_lsb == -1:
                    global_struct.g_dv_vector_print.append ("{:20}      = {:4};\n".format( "tx_{}_f".format(signal2), local_lsb1))
                elif local_lsb2 == -1:
                    global_struct.g_dv_vector_print.append ("{0:20}      = {2:4};  {3:20}[{4:4}] = {2:4};\n".format("tx_{}_f".format(signal2), local_lsb2, local_lsb1, gen_llink_concat_fifoname (llink_name,"input") +"_f", llink_lsb))
                else:
                    global_struct.g_dv_vector_print.append ("{0:20}[{1:4}] = {2:4};  {3:20}[{4:4}] = {2:4};\n".format("tx_{}_f".format(signal2), local_lsb2, local_lsb1, gen_llink_concat_fifoname (llink_name,"input") +"_f", llink_lsb))
                    llink_lsb+=1


            ## AXI to PHY IF Mapping AXI Manager Transmit
            rec_strobe_or_marker_str = ""
            if configuration['TX_ENABLE_STROBE'] and configuration['TX_PERSISTENT_STROBE'] == False and configuration['TX_STROBE_GEN2_LOC'] == local_lsb1 % tx_chan_width:
               rec_strobe_or_marker_str = " // RECOVERED_STROBE"

            if configuration['TX_ENABLE_MARKER'] and configuration['TX_PERSISTENT_MARKER'] == False and configuration['TX_MARKER_GEN2_LOC'] == local_lsb1 % configuration['CHAN_TX_RAW1PHY_BEAT_MAIN']:
               rec_strobe_or_marker_str = " // RECOVERED_MARKER [{0}]".format((local_lsb1 % tx_chan_width) // configuration['CHAN_TX_RAW1PHY_BEAT_MAIN'])

            global_struct.g_debug_raw_data_vector_print_tx.append("{0:15} [{1:4}] = ".format("  Channel {} TX  ".format(local_lsb1 // tx_chan_width), local_lsb1 % tx_chan_width))
            if local_lsb2 != -1:
                global_struct.g_debug_raw_data_vector_print_tx.append("{0:20} [{1:4}]{2}\n".format(signal2, local_lsb2,rec_strobe_or_marker_str))
                local_lsb2 += 1
            else:
                global_struct.g_debug_raw_data_vector_print_tx.append("{0:20}{2}\n".format(signal2, local_lsb2, rec_strobe_or_marker_str))
            local_lsb1 += 1

            ## There is wierd corner case where all the "valid" data is sent, but there are still strobes, markers, dbis. So we have to do this "twice" once before and once after the data.
            ## Update, 2 DBI bits so we need to do it twice in both place.
            local_lsb1 = print_aib_assign_text_check_for_aib_bit (configuration, local_lsb1, use_tx, sysv)

        else:
            ## RX and TX Section for RTL
            ## Update, 2 DBI bits so we need to do it twice in both place.
            local_lsb1 = print_aib_assign_text_check_for_aib_bit (configuration, local_lsb1, use_tx, sysv)

            if llink_lsb == -1:
                global_struct.g_concat_code_vector_slave_tx.append("  assign tx_phy_preflop_{0} [{1:4}] = {2:20}       ;\n".format(int(local_lsb1) // rx_chan_width, local_lsb1 % rx_chan_width, re.sub("^rx_", "tx_", signal2), llink_lsb))
                if signal2 != "1'b0":
                    global_struct.g_concat_code_vector_master_rx.append("  assign {2:20}       = rx_phy_postflop_{0} [{1:4}];\n".format(int(local_lsb1) // rx_chan_width, local_lsb1 % rx_chan_width, signal2, llink_lsb))
                else:
                    global_struct.g_concat_code_vector_master_rx.append("//       {2:20}       = rx_phy_postflop_{0} [{1:4}];\n".format(int(local_lsb1) // rx_chan_width, local_lsb1 % rx_chan_width, "nc", llink_lsb))
            elif local_lsb2 == -1:
                global_struct.g_concat_code_vector_slave_tx.append("  assign tx_phy_preflop_{0} [{1:4}] = {2:20}[{3:4}] ;\n".format(int(local_lsb1) // rx_chan_width, local_lsb1 % rx_chan_width, gen_llink_concat_fifoname (llink_name,"input" ), llink_lsb))
                if signal2 != "1'b0":
                    global_struct.g_concat_code_vector_master_rx.append("  assign {2:20}[{3:4}] = rx_phy_postflop_{0} [{1:4}];\n".format(int(local_lsb1) // rx_chan_width, local_lsb1 % rx_chan_width, gen_llink_concat_fifoname (llink_name,"output" ), llink_lsb))
            else:
                global_struct.g_concat_code_vector_slave_tx.append("  assign tx_phy_preflop_{0} [{1:4}] = {2:20}[{3:4}] ;\n".format(int(local_lsb1) // rx_chan_width, local_lsb1 % rx_chan_width, gen_llink_concat_fifoname (llink_name,"input" ), llink_lsb))
                if signal2 != "1'b0":
                    global_struct.g_concat_code_vector_master_rx.append("  assign {2:20}[{3:4}] = rx_phy_postflop_{0} [{1:4}];\n".format(int(local_lsb1) // rx_chan_width, local_lsb1 % rx_chan_width, gen_llink_concat_fifoname (llink_name,"output" ), llink_lsb))



            ## DV Vectors
            if signal2 != "1'b0":
                if local_lsb2 != -1:
                    global_struct.g_dv_vector_print.append ("{0:20}[{1:4}] = {2:4};  {3:20}[{4:4}] = {2:4};\n".format("rx_{}_f".format(signal2), local_lsb2, local_lsb1, gen_llink_concat_fifoname (llink_name,"output") +"_f", llink_lsb))
                    llink_lsb+=1
                else:
                    global_struct.g_dv_vector_print.append ("{:20}      = {:4};\n".format( "rx_{}_f".format(signal2), local_lsb1))



            rec_strobe_or_marker_str = ""
            if configuration['RX_ENABLE_STROBE'] and configuration['RX_PERSISTENT_STROBE'] == False and configuration['RX_STROBE_GEN2_LOC'] == local_lsb1 % rx_chan_width:
               rec_strobe_or_marker_str = " // RECOVERED_STROBE"

            if configuration['RX_ENABLE_MARKER'] and configuration['RX_PERSISTENT_MARKER'] == False and configuration['RX_MARKER_GEN2_LOC'] == local_lsb1 % configuration['CHAN_RX_RAW1PHY_BEAT_MAIN']:
               rec_strobe_or_marker_str = " // RECOVERED_MARKER [{0}]".format((local_lsb1 % rx_chan_width) // configuration['CHAN_RX_RAW1PHY_BEAT_MAIN'])

            global_struct.g_debug_raw_data_vector_print_rx.append("{0:15} [{1:4}] = ".format("  Channel {} RX  ".format(local_lsb1 // rx_chan_width), local_lsb1 % rx_chan_width))
            if local_lsb2 != -1:
                global_struct.g_debug_raw_data_vector_print_rx.append("{0:20} [{1:4}]{2}\n".format(signal2, local_lsb2, rec_strobe_or_marker_str))
                local_lsb2 += 1
            else:
                global_struct.g_debug_raw_data_vector_print_rx.append("{0:20}{2}\n".format(signal2, local_lsb2, rec_strobe_or_marker_str))
            local_lsb1 += 1

            ## There is wierd corner case where all the "valid" data is sent, but there are still strobes, markers, dbis. So we have to do this "twice" once before and once after the data.
            ## Update, 2 DBI bits so we need to do it twice in both place.
            local_lsb1 = print_aib_assign_text_check_for_aib_bit (configuration, local_lsb1, use_tx, sysv)


    return local_lsb1

## print_aib_mapping_text
##########################################################################################

##########################################################################################
## make_dv_file

#deprecated

def make_dv_file(configuration):

    for direction in ['master', 'slave']:

        name_file_name   = "{}_{}_rawdata_map".format(configuration['MODULE'], direction)
        file_name        = open("{}/{}.svi".format(configuration['OUTPUT_DIR'], name_file_name), "w+")
        print_verilog_header(file_name)

        for string in global_struct.g_dv_vector_print:
            string = re.sub('^tx_tx_', 'tx_', string)
            string = re.sub('^rx_rx_', 'rx_', string)
            if direction == 'slave':
                string = re.sub('^tx_', 'UnL1ke1ySt!nG', string)
                string = re.sub(' tx_', ' UnL1ke1ySt!nG', string)
                string = re.sub('^rx_', 'tx_', string)
                string = re.sub(' rx_',  'tx_', string)
                string = re.sub('UnL1ke1ySt!nG', 'rx_', string)
            file_name.write (string)

        file_name.write ("\n")
        if direction == 'master':
            file_name.write ("tx_dbi_bit_f = ")
        else:
            file_name.write ("rx_dbi_bit_f = ")
        for string in global_struct.g_dv_tx_dbi_vector_print:
            file_name.write (string)
        file_name.write ("0;\n")

        if direction == 'master':
            file_name.write ("rx_dbi_bit_f = ")
        else:
            file_name.write ("tx_dbi_bit_f = ")
        for string in global_struct.g_dv_rx_dbi_vector_print:
            file_name.write (string)
        file_name.write ("0;\n")


        if direction == 'master':
            file_name.write ("tx_strobe_bit_f = ")
        else:
            file_name.write ("rx_strobe_bit_f = ")
        for string in global_struct.g_dv_tx_strobe_vector_print:
            file_name.write (string)
        file_name.write ("0;\n")

        if direction == 'master':
            file_name.write ("rx_strobe_bit_f = ")
        else:
            file_name.write ("tx_strobe_bit_f = ")
        for string in global_struct.g_dv_rx_strobe_vector_print:
            file_name.write (string)
        file_name.write ("0;\n")


        if direction == 'master':
            file_name.write ("tx_marker_bit_f = ")
        else:
            file_name.write ("rx_marker_bit_f = ")
        for string in global_struct.g_dv_tx_marker_vector_print:
            file_name.write (string)
        file_name.write ("0;\n")

        if direction == 'master':
            file_name.write ("rx_marker_bit_f = ")
        else:
            file_name.write ("tx_marker_bit_f = ")
        for string in global_struct.g_dv_rx_marker_vector_print:
            file_name.write (string)
        file_name.write ("0;\n")

        file_name.close()

    return

## make_dv_file
##########################################################################################

##########################################################################################
## print_logic_links
## Prints out information about the data structure inside the logic links

def print_logic_links(configuration):
    for llink in configuration['LL_LIST']:
        print ("")
        print ("Logic Link: {0}   master {1}   data {2} bits".format(llink['NAME'], llink['DIR'], llink['WIDTH_MAIN']))

        if llink['HASVALID'] == False:
            print ("          : No Valid")
        else:
            for sig in llink['SIGNALLIST_MAIN']:
                if sig['TYPE'] == 'valid':
                    print ("          : VALID {0}".format(sig['NAME']))

        if llink['HASREADY'] == False:
            print ("          : No Ready")
        else:
            for sig in llink['SIGNALLIST_MAIN']:
                if sig['TYPE'] == 'ready':
                    print ("          : READY {0}".format(sig['NAME']))

        if len(llink['SIGNALLIST_MAIN']) != 0 and len(llink['SIGNALLIST_GALT']) != 0:
            print ("        MAIN Signaling data width {} bits".format (llink['WIDTH_MAIN']))
        for sig in llink['SIGNALLIST_MAIN']:
            if sig['TYPE'] == 'signal':
                print ("          : {0:20} {1:<8}  {2}_data {3}".format(sig['NAME'], " ", llink['NAME'], gen_index_msb (sig['SIGWID'], sig['LLINDEX_MAIN_LSB'])))
            elif sig['TYPE'] == 'bus':
                print ("          : {0:20} {1:<8}  {2}_data {3}".format(sig['NAME'], "[{}:{}]".format(sig['MSB'],sig['LSB']), llink['NAME'], gen_index_msb (sig['SIGWID'], sig['LLINDEX_MAIN_LSB'])))

        if len(llink['SIGNALLIST_MAIN']) != 0 and len(llink['SIGNALLIST_GALT']) != 0:
            print ("        GALT Signaling data width {} bits".format (llink['WIDTH_GALT']))
        for sig in llink['SIGNALLIST_GALT']:
            if sig['TYPE'] == 'signal':
                print ("          : {0:20} {1:<8}  {2}_data {3}".format(sig['NAME'], " ", llink['NAME'], gen_index_msb (sig['SIGWID'], sig['LLINDEX_GALT_LSB'])))
            elif sig['TYPE'] == 'bus':
                print ("          : {0:20} {1:<8}  {2}_data {3}".format(sig['NAME'], "[{}:{}]".format(sig['MSB'],sig['LSB']), llink['NAME'], gen_index_msb (sig['SIGWID'], sig['LLINDEX_GALT_LSB'])))

    print ("\n")
    return

## print_logic_links
##########################################################################################

##########################################################################################
## print_verilog_header

def print_verilog_header(file_name):
    file_name.write ("////////////////////////////////////////////////////////////\n")
    file_name.write ("// Proprietary Information of Eximius Design\n")
    file_name.write ("//\n")
    file_name.write ("//        (C) Copyright 2021 Eximius Design\n")
    file_name.write ("//                All Rights Reserved\n")
    file_name.write ("//\n")
    file_name.write ("// This entire notice must be reproduced on all copies of this file\n")
    file_name.write ("// and copies of this file may only be made by a person if such person is\n")
    file_name.write ("// permitted to do so under the terms of a subsisting license agreement\n")
    file_name.write ("// from Eximius Design\n")
    file_name.write ("//\n")
    file_name.write ("// Licensed under the Apache License, Version 2.0 (the \"License\");\n")
    file_name.write ("// you may not use this file except in compliance with the License.\n")
    file_name.write ("// You may obtain a copy of the License at\n")
    file_name.write ("//\n")
    file_name.write ("//     http://www.apache.org/licenses/LICENSE-2.0\n")
    file_name.write ("//\n")
    file_name.write ("// Unless required by applicable law or agreed to in writing, software\n")
    file_name.write ("// distributed under the License is distributed on an \"AS IS\" BASIS,\n")
    file_name.write ("// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.\n")
    file_name.write ("// See the License for the specific language governing permissions and\n")
    file_name.write ("// limitations under the License.\n")
    file_name.write ("////////////////////////////////////////////////////////////\n")
    file_name.write ("\n")

## print_verilog_header
##########################################################################################


def main():

    ## Initialize Global Variables / Structs
    global_struct.clear_global_variables()

    parser = ArgumentParser(description='Logic Link Generation Script.')
    parser.add_argument('--cfg', type=str, required=True, help='config file for logic link')
    parser.add_argument('--odir', type=str, required=False, help='location to write output files (default is ./module_name)')
    parser.add_argument('--cfg_debug',    required=False, help='print config file debug info', action="store_true")
    parser.add_argument('--signal_debug', required=False, help='print signal processing debug info', action="store_true")
    parser.add_argument('--packet_debug', required=False, help='print copious packet debug info', action="store_true")
    parser.add_argument('--sysv_indexing', default=True, required=False, help='Set to True to use SystemVerilog indexing. Set to False to use traditional bus indexing.')

    args = parser.parse_args()

    if (args.cfg_debug):
        global_struct.g_CFG_DEBUG = True
    if (args.signal_debug):
        global_struct.g_SIGNAL_DEBUG = True
    if (args.packet_debug):
        global_struct.g_PACKET_DEBUG = True

    configuration = parse_config_file(args.cfg)

    if configuration['REPLICATED_STRUCT']:
        orig_module = configuration['MODULE']

        for rate in ['Full', 'Half', 'Quarter']:
            global_struct.clear_global_variables()
            configuration = parse_config_file(args.cfg)

            ## Skip quarter rate versions if we are in Gen1
            if configuration['CHAN_TYPE'] == "Gen1Only" and rate == "Quarter":
                continue

            if args.odir == None:
                args.odir = configuration['MODULE']

            configuration['TX_RATE'] = rate
            configuration['RX_RATE'] = rate
            configuration['MODULE'] = orig_module +"_"+rate.lower()

            if not os.path.exists(args.odir):
                os.makedirs(args.odir)

            configuration['OUTPUT_DIR'] = args.odir

            configuration = calculate_channel_parameters(configuration)

            if global_struct.g_SIGNAL_DEBUG:
                print_logic_links(configuration)

            configuration = calculate_bit_locations(configuration)

            make_name_file(configuration)

            make_concat_file(configuration)

            make_top_file(configuration)

            make_list_files(configuration)

            make_info_file(configuration)

            make_dv_file(configuration)

            print ("Asymmetric Master and Slave with {:10} rate generated with base module name {:30} in this directory {}".format(rate, configuration['MODULE'], args.odir))

    else:

        if args.odir == None:
            args.odir = configuration['MODULE']

        if not os.path.exists(args.odir):
            os.makedirs(args.odir)

        configuration['OUTPUT_DIR'] = args.odir

        configuration = calculate_channel_parameters(configuration)

        if global_struct.g_SIGNAL_DEBUG:
            print_logic_links(configuration)

        configuration = calculate_bit_locations(configuration)

        make_name_file(configuration)

        make_concat_file(configuration)

        make_top_file(configuration)

        make_list_files(configuration)

        make_info_file(configuration)

        make_dv_file(configuration)

        print ("Files generated here: {}".format(args.odir))


    if (configuration['TX_ENABLE_PACKETIZATION'] or configuration['RX_ENABLE_PACKETIZATION']):
        llink_dv_packet_postproc.generate_dv_packet("{}/{}_info.txt".format(args.odir,configuration['MODULE']), args.odir)


if __name__ == "__main__":
    main()
