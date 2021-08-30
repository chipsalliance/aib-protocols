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





def generate_dv_packet(info_fname, outdir):

    master_dv = open("{}/{}".format(outdir, re.sub("info.txt", "master_rawdata_map.svi", os.path.basename(info_fname))), "w+")
    slave_dv  = open("{}/{}".format(outdir, re.sub("info.txt", "slave_rawdata_map.svi",  os.path.basename(info_fname))), "w+")

    ## Get Grant, Credits, DBI, Marker, Strobe for Transmit
    found_begin_of_section        = False
    found_end_of_section          = False

    tx_packet_offset = 0
    rx_packet_offset = 0

    tx_dbi    = "0";
    tx_strobe = "0";
    tx_marker = "0";
    info_file = open(info_fname, "r")
    for line_no, line in enumerate(info_file):
        if re.search("// AXI to PHY IF Mapping AXI Manager Transmit", line) and found_begin_of_section == False:
            found_begin_of_section = True
            continue

        if re.search("// AXI to PHY IF Mapping AXI Manager Transmit", line) and found_begin_of_section == True:
            found_end_of_section = True
            continue

        if found_begin_of_section == False:
            continue

        if found_end_of_section == False:
            ## Search for Markers
            match = re.search("Channel 0 TX\s+\[\s*([0-9]+)\s*\]\s*=.*// MARKER", line)
            if match:
                tx_marker = "(1<<{}) | ".format(match.group(1)) + tx_marker

            ## Search for Stobes
            match = re.search("Channel 0 TX\s+\[\s*([0-9]+)\s*\]\s*=.*// STROBE", line)
            if match:
                tx_strobe = "(1<<{}) | ".format(match.group(1)) + tx_strobe

            ## Search for DBI
            match = re.search("Channel 0 TX\s+\[\s*([0-9]+)\s*\]\s*=.*// DBI", line)
            if match:
                tx_dbi = "(1<<{}) | ".format(match.group(1)) + tx_dbi

            ## Search for Grant Encode
            match = re.search("Channel 0 TX\s+\[\s*([0-9]+)\s*\]\s*= tx_(grant_enc)(.*)", line)
            if match:
                master_dv.write ("tx_{0}_f {1} = {2};\n".format(match.group(2), match.group(3), match.group(1)));
                slave_dv.write ("rx_{0}_f {1} = {2};\n".format(match.group(2), match.group(3), match.group(1)));
                tx_packet_offset = int(match.group(1))

            ## Search for Credit
            match = re.search("Channel 0 TX\s+\[\s*([0-9]+)\s*\]\s*= tx_([^_]+_credit)(.*)", line)
            if match:
                master_dv.write ("tx_{0}_f {1} = {2};\n".format(match.group(2), match.group(3), match.group(1)));
                slave_dv.write ("rx_{0}_f {1} = {2};\n".format(match.group(2), match.group(3), match.group(1)));

    master_dv.write ("tx_dbi_bit_f    = {};\n".format(tx_dbi));
    master_dv.write ("tx_strobe_bit_f = {};\n".format(tx_strobe));
    master_dv.write ("tx_marker_bit_f = {};\n".format(tx_marker));
    master_dv.write ("\n");

    slave_dv.write ("rx_dbi_bit_f    = {};\n".format(tx_dbi));
    slave_dv.write ("rx_strobe_bit_f = {};\n".format(tx_strobe));
    slave_dv.write ("rx_marker_bit_f = {};\n".format(tx_marker));
    slave_dv.write ("\n");


    ## Get Grant, Credits, DBI, Marker, Strobe for Receive
    found_begin_of_section        = False
    found_end_of_section          = False

    tx_dbi    = "0";
    tx_strobe = "0";
    tx_marker = "0";
    info_file = open(info_fname, "r")
    for line_no, line in enumerate(info_file):
        if re.search("// AXI to PHY IF Mapping AXI Manager Receive", line) and found_begin_of_section == False:
            found_begin_of_section = True
            continue

        if re.search("// AXI to PHY IF Mapping AXI Manager Receive", line) and found_begin_of_section == True:
            found_end_of_section = True
            continue

        if found_begin_of_section == False:
            continue

        if found_end_of_section == False:

            ## Search for Markers
            match = re.search("Channel 0 RX\s+\[\s*([0-9]+)\s*\]\s*=.*// MARKER", line)
            if match:
                tx_marker = "(1<<{}) | ".format(match.group(1)) + tx_marker

            ## Search for Stobes
            match = re.search("Channel 0 RX\s+\[\s*([0-9]+)\s*\]\s*=.*// STROBE", line)
            if match:
                tx_strobe = "(1<<{}) | ".format(match.group(1)) + tx_strobe

            ## Search for DBI
            match = re.search("Channel 0 RX\s+\[\s*([0-9]+)\s*\]\s*=.*// DBI", line)
            if match:
                tx_dbi = "(1<<{}) | ".format(match.group(1)) + tx_dbi

            ## Search for Grant Encode
            match = re.search("Channel 0 RX\s+\[\s*([0-9]+)\s*\]\s*= tx_(grant_enc)(.*)", line)
            if match:
                master_dv.write ("rx_{0}_f {1} = {2};\n".format(match.group(2), match.group(3), match.group(1)));
                slave_dv.write ("tx_{0}_f {1} = {2};\n".format(match.group(2), match.group(3), match.group(1)));
                rx_packet_offset = int(match.group(1))

            ## Search for Credit
            match = re.search("Channel 0 RX\s+\[\s*([0-9]+)\s*\]\s*= rx_([^_]+_credit)(.*)", line)
            if match:
                master_dv.write ("rx_{0}_f {1} = {2};\n".format(match.group(2), match.group(3), match.group(1)));
                slave_dv.write ("tx_{0}_f {1} = {2};\n".format(match.group(2), match.group(3), match.group(1)));

    master_dv.write ("rx_dbi_bit_f    = {};\n".format(tx_dbi));
    master_dv.write ("rx_strobe_bit_f = {};\n".format(tx_strobe));
    master_dv.write ("rx_marker_bit_f = {};\n".format(tx_marker));
    master_dv.write ("\n");

    slave_dv.write ("tx_dbi_bit_f    = {};\n".format(tx_dbi));
    slave_dv.write ("tx_strobe_bit_f = {};\n".format(tx_strobe));
    slave_dv.write ("tx_marker_bit_f = {};\n".format(tx_marker));
    slave_dv.write ("\n");



    packet = -1
    found_begin_of_section        = False
    found_end_of_section          = False

    info_file = open(info_fname, "r")
    for line_no, line in enumerate(info_file):

        if re.search("// Master to Slave Packetization", line) and found_begin_of_section == False:
            found_begin_of_section = True
            continue

        if re.search("// Master to Slave Packetization", line) and found_begin_of_section == True:
            found_end_of_section = True
            continue

        if found_begin_of_section == False:
            continue

        if re.match("\s*tx_packet_data", line) == False:
            continue

        match = re.search("\s*tx_packet_data\s*([0-9]+)\s+\[([^\]]+)\] = ([^\[\]\s]+)\s*\[?([^\[\]]*)\]?\s*//", line)
        if match:
            packet = int(match.group(1))
            aib_index  = match.group(2)
            signal_name = match.group(3)
            signal_index = match.group(4)

            if re.search("\+:", aib_index): ## System V
                aib_lsb = int(re.sub("\s*\+:.*", "", aib_index))
                aib_wid = int(re.sub(".*\+:", "", aib_index))
            else:
                aib_lsb = int(re.sub(".*:", "", aib_index))
                aib_wid = int(re.sub("\s*:", "", aib_index)) - aib_lsb + 1

            if re.search("\+:", signal_index): ## System V
                sig_lsb = int(re.sub("\s*\+:.*", "", signal_index))
                sig_wid = int(re.sub(".*\+:", "", signal_index))
            elif re.search(":", signal_index): ## Normal Index
                sig_lsb = int(re.sub(".*:", "", signal_index))
                sig_wid = int(re.sub("\s*:", "", signal_index)) - sig_lsb + 1
            else:
                sig_lsb = -1
                sig_wid = 1


            ## Skip unused signals
            if re.search("pushbit", signal_name):
                signal_name = re.sub (r'^tx_', "", signal_name);
                signal_name = re.sub (r'^rx_', "", signal_name);

            if signal_name == '0':
                continue

            for iteration in list (range (0, aib_wid)):
                master_dv.write ("tx_{0}_g {1:4} = {2};  ".format(signal_name, ("["+str(sig_lsb + iteration)+"]") if (sig_lsb != -1) else "", packet))
                master_dv.write ("tx_{0}_f {1:4} = {2};".format(signal_name, ("["+str(sig_lsb + iteration)+"]") if (sig_lsb != -1) else "", aib_lsb + iteration + tx_packet_offset))
                master_dv.write ("\n")

                slave_dv.write ("rx_{0}_g {1:4} = {2};  ".format(signal_name, ("["+str(sig_lsb + iteration)+"]") if (sig_lsb != -1) else "", packet))
                slave_dv.write ("rx_{0}_f {1:4} = {2};".format(signal_name, ("["+str(sig_lsb + iteration)+"]") if (sig_lsb != -1) else "", aib_lsb + iteration + tx_packet_offset))
                slave_dv.write ("\n")

    master_dv.write ("\n")
    slave_dv.write ("\n")

    packet = -1
    found_begin_of_section        = False
    found_end_of_section          = False

    info_file = open(info_fname, "r")
    for line_no, line in enumerate(info_file):

        if re.search("// Slave to Master Packetization", line) and found_begin_of_section == False:
            found_begin_of_section = True
            continue

        if re.search("// Slave to Master Packetization", line) and found_begin_of_section == True:
            found_end_of_section = True
            continue

        if found_begin_of_section == False:
            continue

        if re.match("\s*rx_packet_data", line) == False:
            continue

        match = re.search("\s*rx_packet_data\s*([0-9]+)\s+\[([^\]]+)\] = ([^\[\]\s]+)\s*\[?([^\[\]]*)\]?\s*//", line)
        if match:
            packet = int(match.group(1))
            aib_index  = match.group(2)
            signal_name = match.group(3)
            signal_index = match.group(4)

            if re.search("\+:", aib_index): ## System V
                aib_lsb = int(re.sub("\s*\+:.*", "", aib_index))
                aib_wid = int(re.sub(".*\+:", "", aib_index))
            else:
                aib_lsb = int(re.sub(".*:", "", aib_index))
                aib_wid = int(re.sub("\s*:", "", aib_index)) - aib_lsb + 1

            if re.search("\+:", signal_index): ## System V
                sig_lsb = int(re.sub("\s*\+:.*", "", signal_index))
                sig_wid = int(re.sub(".*\+:", "", signal_index))
            elif re.search(":", signal_index): ## Normal Index
                sig_lsb = int(re.sub(".*:", "", signal_index))
                sig_wid = int(re.sub("\s*:", "", signal_index)) - sig_lsb + 1
            else:
                sig_lsb = -1
                sig_wid = 1


            ## Skip unused signals
            if re.search("pushbit", signal_name):
                signal_name = re.sub (r'^tx_', "", signal_name);
                signal_name = re.sub (r'^rx_', "", signal_name);

            if signal_name == '0':
                continue

            for iteration in list (range (0, aib_wid)):
                master_dv.write ("rx_{0}_g {1:4} = {2};  ".format(signal_name, ("["+str(sig_lsb + iteration)+"]") if (sig_lsb != -1) else "", packet))
                master_dv.write ("rx_{0}_f {1:4} = {2};".format(signal_name, ("["+str(sig_lsb + iteration)+"]") if (sig_lsb != -1) else "", aib_lsb + iteration + tx_packet_offset))
                master_dv.write ("\n")

                slave_dv.write ("tx_{0}_g {1:4} = {2};  ".format(signal_name, ("["+str(sig_lsb + iteration)+"]") if (sig_lsb != -1) else "", packet))
                slave_dv.write ("tx_{0}_f {1:4} = {2};".format(signal_name, ("["+str(sig_lsb + iteration)+"]") if (sig_lsb != -1) else "", aib_lsb + iteration + tx_packet_offset))
                slave_dv.write ("\n")

    master_dv.write ("\n")
    slave_dv.write ("\n")





def main():

    parser = ArgumentParser(description='Logic Link Generation Script.')
    parser.add_argument('--info', type=str, required=True, help='info file output from llink_gen.py')
    parser.add_argument('--odir', type=str, required=False, help='location to write output files (default is same as info directory)')

    args = parser.parse_args()

    if not os.path.exists(args.info):
        print("ERROR: File {0} does not exists!!!\n".format(args.info))
        sys.exit(1)

    if args.odir == None:
        args.odir = os.path.dirname(os.path.abspath(args.info))

    generate_dv_packet(args.info, args.odir)

if __name__ == "__main__":
    main()
