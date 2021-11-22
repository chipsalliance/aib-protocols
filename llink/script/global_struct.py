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
## global_struct.py
## Contains varioous global variables and structures used by llink_gen.py.


g_REMOVEME = False ## Placeholders for some temp code that will likely be removed later

g_CFG_DEBUG    = False
g_SIGNAL_DEBUG = False
g_PACKET_DEBUG = False

g_USE_SYSTEMV_INDEXING  = True  ## If True, use [lsb +: width] format. If False, use [msb:lsb] format
USE_SPARE_VECTOR        = False ## If True, unused bits will be assigned to [TX|rx]_spare_data. If False, they are tied to 1'b0


g_PACKETIZATION_PACKING_EN = False

g_info_print = list()
g_llink_vector_print_tx = list()
g_llink_vector_print_rx = list()
g_debug_raw_data_vector_print_tx = list()
g_debug_raw_data_vector_print_rx = list()
g_concat_code_vector_master_tx = list()
g_concat_code_vector_master_rx = list()
g_concat_code_vector_slave_tx = list()
g_concat_code_vector_slave_rx = list()
g_dv_vector_print = list()
g_dv_tx_dbi_vector_print = list()
g_dv_rx_dbi_vector_print = list()
g_dv_tx_strobe_vector_print = list()
g_dv_rx_strobe_vector_print = list()
g_dv_tx_marker_vector_print = list()
g_dv_rx_marker_vector_print = list()

g_tx_packet_info = list()
g_rx_packet_info = list()
g_packet_print_tx = list()
g_packet_print_rx = list()
g_packet_code_master_data_tx = list()
g_packet_code_master_req_tx = list()
g_packet_code_master_ovrd_tx = dict()

g_packet_code_slave_data_tx = list()
g_packet_code_slave_req_tx = list()
g_packet_code_slave_ovrd_tx = dict()


def clear_global_variables():
    global g_info_print
    global g_llink_vector_print_tx
    global g_llink_vector_print_rx
    global g_debug_raw_data_vector_print_tx
    global g_debug_raw_data_vector_print_rx
    global g_concat_code_vector_master_tx
    global g_concat_code_vector_master_rx
    global g_concat_code_vector_slave_tx
    global g_concat_code_vector_slave_rx
    global g_dv_vector_print
    global g_dv_tx_dbi_vector_print
    global g_dv_rx_dbi_vector_print
    global g_dv_tx_strobe_vector_print
    global g_dv_rx_strobe_vector_print
    global g_dv_tx_marker_vector_print
    global g_dv_rx_marker_vector_print

    global g_tx_packet_info
    global g_rx_packet_info
    global g_packet_print_tx
    global g_packet_print_rx
    global g_packet_code_master_data_tx
    global g_packet_code_master_req_tx
    global g_packet_code_master_ovrd_tx

    global g_packet_code_slave_data_tx
    global g_packet_code_slave_req_tx
    global g_packet_code_slave_ovrd_tx

    g_info_print = list()
    g_llink_vector_print_tx = list()
    g_llink_vector_print_rx = list()
    g_debug_raw_data_vector_print_tx = list()
    g_debug_raw_data_vector_print_rx = list()
    g_concat_code_vector_master_tx = list()
    g_concat_code_vector_master_rx = list()
    g_concat_code_vector_slave_tx = list()
    g_concat_code_vector_slave_rx = list()
    g_dv_vector_print = list()
    g_dv_tx_dbi_vector_print = list()
    g_dv_rx_dbi_vector_print = list()
    g_dv_tx_strobe_vector_print = list()
    g_dv_rx_strobe_vector_print = list()
    g_dv_tx_marker_vector_print = list()
    g_dv_rx_marker_vector_print = list()

    g_tx_packet_info = list()
    g_rx_packet_info = list()
    g_packet_print_tx = list()
    g_packet_print_rx = list()
    g_packet_code_master_data_tx = list()
    g_packet_code_master_req_tx = list()
    g_packet_code_master_ovrd_tx = dict()

    g_packet_code_slave_data_tx = list()
    g_packet_code_slave_req_tx = list()
    g_packet_code_slave_ovrd_tx = dict()



##########################################################################################
## common functions
## These are simple, common features including:
##   print routines
##   standardizing on signal names
##   standard method of indicating indicies


def print_verilog_assign(file_name, signal1, signal2, index1 = "", index2 = "",  comment = "", semicolon = True):
    newline = "\n" if semicolon else ""
    if len(comment) != 0:
        comment = " // " + comment
    file_name.write("  assign ")
    file_name.write("{0:20} {1:13} = ".format(signal1, index1))
    file_name.write("{0:20} {1:13} ".format(signal2, index2))
    file_name.write("{0}{1}{2}".format(";" if semicolon else "", comment, newline))

def sprint_verilog_assign(signal1, signal2, index1 = "", index2 = "",  comment = "", semicolon = True):
    string = ""
    newline = "\n" if semicolon else ""
    if len(comment) != 0:
        comment = " // " + comment
    string += "  assign "
    string += "{0:20} {1:13} = ".format(signal1, index1)
    string += "{0:20} {1:13} ".format(signal2, index2)
    string += "{0}{1}{2}".format(";" if semicolon else "", comment, newline)
    return string

def sprint_verilog_case(decode, width, signal1, signal2, index1 = "", index2 = "",  comment = ""):
    string = ""
    if len(comment) != 0:
        comment = " // " + comment
    string += "    "
    string += "    {0}'d{1:<4} : {2:20} {3:13} = ".format(width, decode, signal1, index1)
    string += "{0:20} {1:13};".format(signal2, index2)
    string += "{0}\n".format(comment)
    return string

def print_verilog_regnb(file_name, signal1, signal2, index1 = "", index2 = "",  comment = ""):
    newline = "\n"
    if len(comment) != 0:
        comment = " // " + comment
    file_name.write("    ")
    file_name.write("{0:25} {1:13} <= ".format(signal1, index1))
    file_name.write("{0:25} {1:13} ".format(signal2, index2))
    file_name.write("{0}{1}{2}".format(";", comment, newline))

def print_verilog_io_line(file_name, direction, signal,  index = "",  comment = "", comma = True):
    if len(comment) != 0:
      comment = " // " + comment
    file_name.write("  {0:6} logic {1:13} {2:20}{3}{4}\n".format(direction, index, signal, "," if comma else "", comment))

def print_verilog_logic_line(file_name, signal,  index = "",  comment = ""):
    if len(comment) != 0:
      comment = " // " + comment
    file_name.write("  logic {0:40} {1:30};{2}\n".format(index, signal, comment))

def sprint_verilog_logic_line(signal,  index = "",  comment = ""):
    if len(comment) != 0:
      comment = " // " + comment
    string = "  logic {0:40} {1:30};{2}\n".format(index, signal, comment)
    return string

def gen_direction(fname, sigdir, invert=False):
    retval = "output" if invert else "input"

    if (  ("master" in fname and "name"   in fname and sigdir == "input"  ) or
          ("master" in fname and "top"    in fname and sigdir == "input"  ) or
          ("master" in fname and "concat" in fname and sigdir == "output" ) or
          ("slave"  in fname and "name"   in fname and sigdir == "output" ) or
          ("slave"  in fname and "top"    in fname and sigdir == "output" ) or
          ("slave"  in fname and "concat" in fname and sigdir == "input"  ) ):
        retval = "input" if invert else "output"

    return retval

def gen_llink_user_fifoname(llink_name, dir ):
    return ("rxfifo_"if dir=="input" else "txfifo_")+llink_name+"_data"

def gen_llink_user_valid(llink_name):
    return "user_"+llink_name+"_vld"

def gen_llink_user_enable(llink_name):
    return "user_"+llink_name+"_enable"

def gen_llink_user_ready(llink_name):
    return "user_"+llink_name+"_ready"

def gen_index_msb(width, lsb=0, sysv=g_USE_SYSTEMV_INDEXING):
    if lsb == -1 or width == 0:
        return ""
    else:
        return "[{0:4} +:{1:4}]".format(lsb, int(width) ) if sysv else "[{0:4}:{1:4}]".format(int(width) - 1 + lsb, lsb)

def gen_llink_concat_fifoname(llink_name, dir ):
    return ("tx_"if dir=="input" else "rx_")+llink_name+"_data"

def gen_llink_concat_pushbit(llink_name, dir):
    return ("tx_"if dir=="input" else "rx_")+llink_name+"_pushbit"

def gen_llink_concat_credit(llink_name, dir):
    return ("rx_"if dir=="input" else "tx_")+llink_name+"_credit"

def gen_llink_concat_ovrd(llink_name, dir):
    return ("tx_"if dir=="input" else "rx_")+llink_name+("_pop_ovrd"if dir=="input" else "_push_ovrd")

def gen_llink_debug_status(llink_name, dir):
    return ("rx_"if dir=="input" else "tx_")+llink_name+"_debug_status"

## common functions
##########################################################################################
