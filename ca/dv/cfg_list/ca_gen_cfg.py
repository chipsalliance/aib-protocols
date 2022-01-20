from argparse import ArgumentParser
import os
import re
import shutil
import subprocess
import sys
import math
import pprint
from collections import namedtuple
from operator import itemgetter
import random
from itertools import chain


MAX_SAILROCK_TO_GEN = 999
ENABLE_DISPLAY_WHY_ILLEGAL = False

def create_entry(master, name, range, valid=True):
    entry = dict()
    entry ['name'] = name
    entry ['range'] = range
    entry ['valid'] = valid
    master[name] = entry


def is_config_illegal(target_param, local_config):
    illegal_config = False
    if local_config["tx_dbi"] == 1 and (local_config["tx_strobe_loc"] % 40 == 38 or
                                        local_config["tx_strobe_loc"] % 40 == 39 or
                                        local_config["tx_marker_loc"] % 40 == 38 or
                                        local_config["tx_marker_loc"] % 40 == 39):
        illegal_config = True
        if ENABLE_DISPLAY_WHY_ILLEGAL:
            print "tx strobe or tx marker overlaps with DBI"
    if local_config["rx_dbi"] == 1 and (local_config["rx_strobe_loc"] % 40 == 38 or
                                        local_config["rx_strobe_loc"] % 40 == 39 or
                                        local_config["rx_marker_loc"] % 40 == 38 or
                                        local_config["rx_marker_loc"] % 40 == 39):
        illegal_config = True
        if ENABLE_DISPLAY_WHY_ILLEGAL:
            print "rx strobe or rx marker overlaps with DBI"

    # This is slightly overconstrained. For Gen2, this could be %80, but %40 is good enough and the odds of a conflict are rare already
    if local_config["tx_strobe_loc"] % 40 == local_config["tx_marker_loc"] % 40 :
        illegal_config = True
        if ENABLE_DISPLAY_WHY_ILLEGAL:
            print "tx strobe overlaps with tx marker"
    if local_config["rx_strobe_loc"] % 40 == local_config["rx_marker_loc"] % 40 :
        illegal_config = True
        if ENABLE_DISPLAY_WHY_ILLEGAL:
            print "rx strobe overlaps with rx marker"

   
    ### If we are focusing on marker, make sure we are a configuration that uses markers
    if (target_param == "tx_marker_loc"   or
        target_param == "rx_marker_loc"   or
        target_param == "tx_perst_marker" or
        target_param == "rx_perst_marker" or
        target_param == "tx_user_marker"  or
        target_param == "rx_user_marker"  ):
        if local_config['testbench'] == "tb_mf2_sf2":
            illegal_config = True
        elif local_config['testbench'] == "tb_mf1_sf2.1":
            illegal_config = True
            if ENABLE_DISPLAY_WHY_ILLEGAL:
                print "targeting to test markers in symm_mf1_sf2.1 TB which doesn't use markers (bad configuration)"
        elif re.search("dyn_tb_mf1_sf2.1", local_config['testbench']):
            illegal_config = True
            if ENABLE_DISPLAY_WHY_ILLEGAL:
                print "targeting to test markers in dyn_tb_mf1_sf2.1 TB which doesn't use markers (bad configuration)"

    return illegal_config


g_manifest_file=0;

def main():

    global g_manifest_file
    g_manifest_file       = open("manifest.txt", "w+")

    if os.path.exists("./sailrock_array"):
        shutil.rmtree("./sailrock_array")

    test_num=0;
    ##for testbench in ["tb_mf2_sf2", "tb_mh2_sh2", "tb_mq2_sq2", "tb_mf2_sh2", "tb_mh2_sf2", "tb_mf2_sq2", "tb_mq2_sf2", "tb_mq2_sh2", "tb_mh2_sq2", "tb_mf2.1_sf1", "tb_mh2.1_sh1", "tb_mf2.1_sh1", "tb_mh2.1_sf1"]:
    for testbench in ["tb_mf2_sf2", "tb_mh2_sh2", "tb_mq2_sq2", "tb_mf2_sh2", "tb_mh2_sf2", "tb_mf2_sq2", "tb_mq2_sf2", "tb_mq2_sh2", "tb_mh2_sq2", "tb_mf1_sf2.1", "tb_mh2.1_sh1", "tb_mf2.1_sh1", "tb_mh2.1_sf1"]:
        master_dict = dict()

        create_entry (master_dict , "align_fly"    , [0,1]    )
        create_entry (master_dict , "rden_dly"     , [0,1,2,3,4,5,6,7]    )
        create_entry (master_dict , "stb_en"       , [0,1]    )
        create_entry (master_dict , "stb_loc"      , range (0,40)   )
        create_entry (master_dict , "marker_loc"   , [76,77,78,79]  )

        #constrained_dict = master_dict.copy.deepcopy()
        constrained_dict = dict(master_dict)

        for target_param in sorted(constrained_dict.keys()):
            if constrained_dict[target_param]['valid'] == False:
                continue

            for value in sorted(constrained_dict[target_param]['range']):

                illegal_config = True
                illegal_iteration_count = 0
                while illegal_config:
                    illegal_config = False
                    local_config = dict()
                    local_config['testbench']=testbench
                    for other_name in constrained_dict.keys():
                        if other_name == target_param:
                            local_config[other_name]=value
                        else:
                            local_config[other_name]=random.choice(constrained_dict[other_name]['range'])

                      #  if other_name == "tx_strobe_loc" or other_name == "rx_strobe_loc":
                      #      local_config[other_name] += random.randrange(0, 9)


                    ## Calculate Channel number. Note, this is dominated by TX, so we are only constraining TX.
               #     axi_width = (2*local_config["addr_width"]) + local_config["data_width"] + 18+18+22
               #     if local_config['testbench'] == "tb_mf2_sf2":
               #         per_chan_wid = 80 -1 - local_config["tx_perst_marker"]*0
               #     elif local_config['testbench'] == "tb_mh2_sh2":
               #         per_chan_wid = 80*2 -1 - local_config["tx_perst_marker"]*2
               #     elif local_config['testbench'] == "tb_mq2_sq2":
               #         per_chan_wid = 80*4 -1 - local_config["tx_perst_marker"]*4
               #     elif local_config['testbench'] == "tb_mf1_sf2.1":
               #         per_chan_wid = 40 -1 - local_config["tx_perst_marker"]*0
               #     elif local_config['testbench'] == "tb_mh2.1_sh1":
               #         per_chan_wid = 40*2 -1 - local_config["tx_perst_marker"]*2
               #     max_chan = (axi_width + per_chan_wid - 1)/ per_chan_wid

               #     local_config["num_channel"] = random.randrange(1, max_chan+1)

                    ## If we are focusing on strobe, make sure we are multi-channel
               #     if (target_param == "tx_strobe_loc"   or
               #         target_param == "rx_strobe_loc"   or
               #         target_param == "tx_perst_strobe" or
               #         target_param == "rx_perst_strobe" or
               #         target_param == "tx_user_strobe"  or
               #         target_param == "rx_user_strobe"  ) and local_config["num_channel"] < 2:
               #             local_config["num_channel"] = 2


               #     ## If we are targeting persistent markers, make sure they come from LLINK
               #     if target_param == "tx_perst_marker" == 1 and local_config['tx_perst_marker'] == 0 and local_config['tx_user_marker'] == 0:
               #         local_config['tx_user_marker'] = 1
               #     if target_param == "rx_perst_marker" == 1 and local_config['rx_perst_marker'] == 0 and local_config['rx_user_marker'] == 0:
               #         local_config['rx_user_marker'] = 1


                   # illegal_config = is_config_illegal(target_param, local_config)

                    ## Check for while loop timeout
                    illegal_iteration_count +=1
                    if illegal_iteration_count > 1000:
                        print("ERROR: Iteration timeout. Last config was:")
                        pprint.pprint (local_config)
                        sys.exit(1)

                local_config["test_num"] = test_num
                local_config["target_param"] = target_param
                test_num+=1

                print_config_to_manifest (local_config)
                generate_sailrock (local_config)

                if (test_num == MAX_SAILROCK_TO_GEN):
                    exit(1);
                #pprint.pprint (local_config)

        g_manifest_file.write("\n")
    print ("Generated {} tests.".format(test_num))
    print ("Manifest of tests is in manifest.txt")
    exit(1);

g_sail_file=0;
def print_to_sail (a,b,c=""):
    if c == "":
      g_sail_file.write("{:<30} {:>30}\n".format(a,b))
    else:
      g_sail_file.write("{:<30} {:>30} {:>30}\n".format(a,b,c))


def print_config_to_manifest (local_config):
    global g_manifest_file
    g_manifest_file.write("test:{:4}  ".format (local_config["test_num"]) )
    g_manifest_file.write("{:28}  ".format("{:}:{:}  ".format ("testbench", local_config["testbench"]) ))
    g_manifest_file.write("{:30}  ".format("{:}:{:}={}".format ("target_param", local_config["target_param"], local_config[local_config["target_param"]])))
    for config_value in sorted(local_config.keys()):
        if config_value == "test_num" or config_value == "target_param" or config_value == "testbench":
            continue
        g_manifest_file.write("{:19}".format("{:}:{:}  ".format (config_value, local_config[config_value]) ))

    g_manifest_file.write("\n")


def generate_sailrock(local_config):

    if not os.path.exists("./sailrock_array"):
        os.makedirs("./sailrock_array")

    sailrock_name = ("test_{:03}_{}_{}_{}".format (local_config["test_num"], local_config["testbench"], local_config["target_param"], local_config[local_config["target_param"]] ) )
    sailrock_name   = "./sailrock_array/"+sailrock_name + "_sailrock_cfg.txt"
    global g_sail_file
    g_sail_file       = open(sailrock_name, "w+")


    ## Display config at the top of the flie
    g_sail_file.write("\n")
    g_sail_file.write("// {:20}        {:03}\n".format ("test_num", local_config["test_num"]) )
    g_sail_file.write("// {:20} {:10}\n".format ("testbench", local_config["testbench"]) )
    g_sail_file.write(   "// {:20} {:10}={}\n".format ("target_param", local_config["target_param"], local_config[local_config["target_param"]]) )
    for config_value in sorted(local_config.keys()):
        if config_value == "test_num" or config_value == "target_param" or config_value == "testbench":
            continue
        g_sail_file.write(   "// {:20} {:10}\n".format (config_value, local_config[config_value]) )

    g_sail_file.write("\n")

    number_list   = [2, 4, 8]
    number_list_1 = [1, 2, 4, 8, 16]
    if (local_config['testbench'] == "tb_mf2_sf2" or
        local_config['testbench'] == "tb_mh2_sh2" or
        local_config['testbench'] == "tb_mq2_sq2" or
        local_config['testbench'] == "tb_mf2_sh2" or
        local_config['testbench'] == "tb_mh2_sf2" or
        local_config['testbench'] == "tb_mf2_sq2" or
        local_config['testbench'] == "tb_mq2_sf2" or
        local_config['testbench'] == "tb_mq2_sh2" or
        local_config['testbench'] == "tb_mh2_sq2"):
        number_of_channel=random.choice(number_list)
    else:
        number_of_channel=random.choice(number_list_1)



    g_sail_file.write("//\n")
    print_to_sail("interface_0", "master", "slave")
    print_to_sail("GLOBAL_NUM_OF_CHANNEL", number_of_channel, number_of_channel)

    if local_config['testbench'] == "tb_mf2_sf2":
        print_to_sail("GLOBAL_TX_MODE"         , "fifo_1x", "fifo_1x")
        print_to_sail("GLOBAL_RX_MODE"         , "fifo_1x", "fifo_1x")
        print_to_sail("GLOBAL_GEN2_MODE"       , "1", "1")
        print_to_sail("GLOBAL_TX_WMARKER_EN"   , "1", "1")
        print_to_sail("GLOBAL_TX_MARKER_LOC"   , local_config["marker_loc"], local_config["marker_loc"])
        print_to_sail("GLOBAL_RX_MARKER_LOC"   , local_config["marker_loc"], local_config["marker_loc"])
        print_to_sail("GLOBAL_TX_DBI_EN"       , "0", "0")
        print_to_sail("GLOBAL_RX_DBI_EN"       , "0", "0")
        print_to_sail("////aib setting"        , "", "")
        print_to_sail("aib_ver"                , "2", "2")
        print_to_sail("aib_tx_bit_per_channel" , "40", "40")
        print_to_sail("aib_rx_bit_per_channel" , "40", "40")
        print_to_sail("ASYMMETRIC_CA"          , "0" , "0")

    elif local_config['testbench'] == "tb_mh2_sh2":
        print_to_sail("GLOBAL_TX_MODE"         , "fifo_2x", "fifo_2x")
        print_to_sail("GLOBAL_RX_MODE"         , "fifo_2x", "fifo_2x")
        print_to_sail("GLOBAL_GEN2_MODE"       , "1", "1")
        print_to_sail("GLOBAL_TX_WMARKER_EN"   , "1", "1")
        print_to_sail("GLOBAL_TX_MARKER_LOC"   , local_config["marker_loc"], local_config["marker_loc"])
        print_to_sail("GLOBAL_RX_MARKER_LOC"   , local_config["marker_loc"], local_config["marker_loc"])
        print_to_sail("GLOBAL_TX_DBI_EN"       , "0", "0")
        print_to_sail("GLOBAL_RX_DBI_EN"       , "0", "0")
        print_to_sail("////aib setting"        , "", "")
        print_to_sail("aib_ver"                , "2", "2")
        print_to_sail("aib_tx_bit_per_channel" , "40", "40")
        print_to_sail("aib_rx_bit_per_channel" , "40", "40")
        print_to_sail("ASYMMETRIC_CA"          , "0" , "0")

    elif local_config['testbench'] == "tb_mq2_sq2":
        print_to_sail("GLOBAL_TX_MODE"         , "fifo_4x", "fifo_4x")
        print_to_sail("GLOBAL_RX_MODE"         , "fifo_4x", "fifo_4x")
        print_to_sail("GLOBAL_GEN2_MODE"       , "1", "1")
        print_to_sail("GLOBAL_TX_WMARKER_EN"   , "1", "1")
        print_to_sail("GLOBAL_TX_MARKER_LOC"   , local_config["marker_loc"], local_config["marker_loc"])
        print_to_sail("GLOBAL_RX_MARKER_LOC"   , local_config["marker_loc"], local_config["marker_loc"])
        print_to_sail("GLOBAL_TX_DBI_EN"       , "0", "0")
        print_to_sail("GLOBAL_RX_DBI_EN"       , "0", "0")
        print_to_sail("////aib setting"        , "", "")
        print_to_sail("aib_ver"                , "2", "2")
        print_to_sail("aib_tx_bit_per_channel" , "40", "40")
        print_to_sail("aib_rx_bit_per_channel" , "40", "40")
        print_to_sail("ASYMMETRIC_CA"          , "0" , "0")

    elif local_config['testbench'] == "tb_mf2_sh2":
        print_to_sail("GLOBAL_TX_MODE"         , "fifo_1x", "fifo_2x")
        print_to_sail("GLOBAL_RX_MODE"         , "fifo_1x", "fifo_2x")
        print_to_sail("GLOBAL_GEN2_MODE"       , "1", "1")
        print_to_sail("GLOBAL_TX_WMARKER_EN"   , "0", "0")
        print_to_sail("GLOBAL_TX_MARKER_LOC"   , local_config["marker_loc"], local_config["marker_loc"])
        print_to_sail("GLOBAL_RX_MARKER_LOC"   , local_config["marker_loc"], local_config["marker_loc"])
        print_to_sail("GLOBAL_TX_DBI_EN"       , "0", "0")
        print_to_sail("GLOBAL_RX_DBI_EN"       , "0", "0")
        print_to_sail("////aib setting"        , "", "")
        print_to_sail("aib_ver"                , "2", "2")
        print_to_sail("aib_tx_bit_per_channel" , "40", "40")
        print_to_sail("aib_rx_bit_per_channel" , "40", "40")
        print_to_sail("ASYMMETRIC_CA"          , "1" , "1")


    elif local_config['testbench'] == "tb_mh2_sf2":
        print_to_sail("GLOBAL_TX_MODE"         , "fifo_2x", "fifo_1x")
        print_to_sail("GLOBAL_RX_MODE"         , "fifo_2x", "fifo_1x")
        print_to_sail("GLOBAL_GEN2_MODE"       , "1", "1")
        print_to_sail("GLOBAL_TX_WMARKER_EN"   , "0", "0")
        print_to_sail("GLOBAL_TX_MARKER_LOC"   , local_config["marker_loc"], local_config["marker_loc"])
        print_to_sail("GLOBAL_RX_MARKER_LOC"   , local_config["marker_loc"], local_config["marker_loc"])
        print_to_sail("GLOBAL_TX_DBI_EN"       , "0", "0")
        print_to_sail("GLOBAL_RX_DBI_EN"       , "0", "0")
        print_to_sail("////aib setting"        , "", "")
        print_to_sail("aib_ver"                , "2", "2")
        print_to_sail("aib_tx_bit_per_channel" , "40", "40")
        print_to_sail("aib_rx_bit_per_channel" , "40", "40")
        print_to_sail("ASYMMETRIC_CA"          , "1" , "1")
   
    elif local_config['testbench'] == "tb_mf2_sq2":
        print_to_sail("GLOBAL_TX_MODE"         , "fifo_1x", "fifo_4x")
        print_to_sail("GLOBAL_RX_MODE"         , "fifo_1x", "fifo_4x")
        print_to_sail("GLOBAL_GEN2_MODE"       , "1", "1")
        print_to_sail("GLOBAL_TX_WMARKER_EN"   , "0", "0")
        print_to_sail("GLOBAL_TX_MARKER_LOC"   , local_config["marker_loc"], local_config["marker_loc"])
        print_to_sail("GLOBAL_RX_MARKER_LOC"   , local_config["marker_loc"], local_config["marker_loc"])
        print_to_sail("GLOBAL_TX_DBI_EN"       , "0", "0")
        print_to_sail("GLOBAL_RX_DBI_EN"       , "0", "0")
        print_to_sail("////aib setting"        , "", "")
        print_to_sail("aib_ver"                , "2", "2")
        print_to_sail("aib_tx_bit_per_channel" , "40", "40")
        print_to_sail("aib_rx_bit_per_channel" , "40", "40")
        print_to_sail("ASYMMETRIC_CA"          , "1" , "1")
   
    elif local_config['testbench'] == "tb_mq2_sf2":
        print_to_sail("GLOBAL_TX_MODE"         , "fifo_4x", "fifo_1x")
        print_to_sail("GLOBAL_RX_MODE"         , "fifo_4x", "fifo_1x")
        print_to_sail("GLOBAL_GEN2_MODE"       , "1", "1")
        print_to_sail("GLOBAL_TX_WMARKER_EN"   , "0", "0")
        print_to_sail("GLOBAL_TX_MARKER_LOC"   , local_config["marker_loc"], local_config["marker_loc"])
        print_to_sail("GLOBAL_RX_MARKER_LOC"   , local_config["marker_loc"], local_config["marker_loc"])
        print_to_sail("GLOBAL_TX_DBI_EN"       , "0", "0")
        print_to_sail("GLOBAL_RX_DBI_EN"       , "0", "0")
        print_to_sail("////aib setting"        , "", "")
        print_to_sail("aib_ver"                , "2", "2")
        print_to_sail("aib_tx_bit_per_channel" , "40", "40")
        print_to_sail("aib_rx_bit_per_channel" , "40", "40")
        print_to_sail("ASYMMETRIC_CA"          , "1" , "1")
   
    elif local_config['testbench'] == "tb_mq2_sh2":
        print_to_sail("GLOBAL_TX_MODE"         , "fifo_4x", "fifo_2x")
        print_to_sail("GLOBAL_RX_MODE"         , "fifo_4x", "fifo_2x")
        print_to_sail("GLOBAL_GEN2_MODE"       , "1", "1")
        print_to_sail("GLOBAL_TX_WMARKER_EN"   , "0", "0")
        print_to_sail("GLOBAL_TX_MARKER_LOC"   , local_config["marker_loc"], local_config["marker_loc"])
        print_to_sail("GLOBAL_RX_MARKER_LOC"   , local_config["marker_loc"], local_config["marker_loc"])
        print_to_sail("GLOBAL_TX_DBI_EN"       , "0", "0")
        print_to_sail("GLOBAL_RX_DBI_EN"       , "0", "0")
        print_to_sail("////aib setting"        , "", "")
        print_to_sail("aib_ver"                , "2", "2")
        print_to_sail("aib_tx_bit_per_channel" , "40", "40")
        print_to_sail("aib_rx_bit_per_channel" , "40", "40")
        print_to_sail("ASYMMETRIC_CA"          , "1" , "1")
   
    elif local_config['testbench'] == "tb_mh2_sq2":
        print_to_sail("GLOBAL_TX_MODE"         , "fifo_2x", "fifo_4x")
        print_to_sail("GLOBAL_RX_MODE"         , "fifo_2x", "fifo_4x")
        print_to_sail("GLOBAL_GEN2_MODE"       , "1", "1")
        print_to_sail("GLOBAL_TX_WMARKER_EN"   , "0", "0")
        print_to_sail("GLOBAL_TX_MARKER_LOC"   , local_config["marker_loc"], local_config["marker_loc"])
        print_to_sail("GLOBAL_RX_MARKER_LOC"   , local_config["marker_loc"], local_config["marker_loc"])
        print_to_sail("GLOBAL_TX_DBI_EN"       , "0", "0")
        print_to_sail("GLOBAL_RX_DBI_EN"       , "0", "0")
        print_to_sail("////aib setting"        , "", "")
        print_to_sail("aib_ver"                , "2", "2")
        print_to_sail("aib_tx_bit_per_channel" , "40", "40")
        print_to_sail("aib_rx_bit_per_channel" , "40", "40")
        print_to_sail("ASYMMETRIC_CA"          , "1" , "1")

    ##### GEN1
    elif local_config['testbench'] == "tb_mf2.1_sf1":
        print_to_sail("GLOBAL_TX_MODE"         , "reg", "fifo_1x")
        print_to_sail("GLOBAL_RX_MODE"         , "reg", "fifo_1x")
        print_to_sail("GLOBAL_GEN2_MODE"       , "0", "0")
        print_to_sail("GLOBAL_TX_WMARKER_EN"   , "1", "1")
        print_to_sail("GLOBAL_TX_MARKER_LOC"   , "39", "39")
        print_to_sail("GLOBAL_RX_MARKER_LOC"   , "39", "39")
        print_to_sail("GLOBAL_TX_DBI_EN"       , "0", "0")
        print_to_sail("GLOBAL_RX_DBI_EN"       , "0", "0")
        print_to_sail("////aib setting"        , "", "")
        print_to_sail("aib_ver"                , "1", "2")
        print_to_sail("aib_tx_bit_per_channel" , "20", "40")
        print_to_sail("aib_rx_bit_per_channel" , "20", "40")
        print_to_sail("ASYMMETRIC_CA"          , "0" , "0")

    elif local_config['testbench'] == "tb_mh2.1_sh1":
        print_to_sail("GLOBAL_TX_MODE"         , "fifo_2x", "fifo_2x")
        print_to_sail("GLOBAL_RX_MODE"         , "fifo_2x", "fifo_2x")
        print_to_sail("GLOBAL_GEN2_MODE"       , "0", "0")
        print_to_sail("GLOBAL_TX_WMARKER_EN"   , "1", "1")
        print_to_sail("GLOBAL_TX_MARKER_LOC"   , "39", "39")
        print_to_sail("GLOBAL_RX_MARKER_LOC"   , "39", "39")
        print_to_sail("GLOBAL_TX_DBI_EN"       , "0", "0")
        print_to_sail("GLOBAL_RX_DBI_EN"       , "0", "0")
        print_to_sail("////aib setting"        , "", "")
        print_to_sail("aib_ver"                , "2", "1")
        print_to_sail("aib_tx_bit_per_channel" , "40", "20")
        print_to_sail("aib_rx_bit_per_channel" , "40", "20")
        print_to_sail("ASYMMETRIC_CA"          , "0" , "0")


    elif local_config['testbench'] == "tb_mf2.1_sh1":
        print_to_sail("GLOBAL_TX_MODE"         , "reg", "fifo_2x")
        print_to_sail("GLOBAL_RX_MODE"         , "reg", "fifo_2x")
        print_to_sail("GLOBAL_GEN2_MODE"       , "0", "0")
        print_to_sail("GLOBAL_TX_WMARKER_EN"   , "0", "0")
        print_to_sail("GLOBAL_TX_MARKER_LOC"   , "39", "39")
        print_to_sail("GLOBAL_RX_MARKER_LOC"   , "39", "39")
        print_to_sail("GLOBAL_TX_DBI_EN"       , "0", "0")
        print_to_sail("GLOBAL_RX_DBI_EN"       , "0", "0")
        print_to_sail("////aib setting"        , "", "")
        print_to_sail("aib_ver"                , "1", "2")
        print_to_sail("aib_tx_bit_per_channel" , "20", "40")
        print_to_sail("aib_rx_bit_per_channel" , "20", "40")
        print_to_sail("ASYMMETRIC_CA"          , "1" , "1")

    elif local_config['testbench'] == "tb_mh2.1_sf1":
        print_to_sail("GLOBAL_TX_MODE"         , "fifo_2x", "fifo_1x")
        print_to_sail("GLOBAL_RX_MODE"         , "fifo_2x", "fifo_1x")
        print_to_sail("GLOBAL_GEN2_MODE"       , "0", "0")
        print_to_sail("GLOBAL_TX_WMARKER_EN"   , "0", "0")
        print_to_sail("GLOBAL_TX_MARKER_LOC"   , "39", "39")
        print_to_sail("GLOBAL_RX_MARKER_LOC"   , "39", "39")
        print_to_sail("GLOBAL_TX_DBI_EN"       , "0", "0")
        print_to_sail("GLOBAL_RX_DBI_EN"       , "0", "0")
        print_to_sail("////aib setting"        , "", "")
        print_to_sail("aib_ver"                , "2", "2")
        print_to_sail("aib_tx_bit_per_channel" , "40", "40")
        print_to_sail("aib_rx_bit_per_channel" , "40", "40")
        print_to_sail("ASYMMETRIC_CA"          , "1" , "1")

    ch_en_vector = 0
    for i in range(1,number_of_channel+1):
        ch_en_vector = (ch_en_vector*2) + 1

    print_to_sail("aib_channel_enable"     ,"{}".format(hex(ch_en_vector)), "{}".format(hex(ch_en_vector)))
    if local_config['testbench'] == "tb_mf1_sf2.1":
        print_to_sail("aib_reg_to_reg_channel"     ,"{}".format(hex(ch_en_vector)), "{}".format(hex(ch_en_vector)))
    else:
        print_to_sail("aib_reg_to_reg_channel"     ,"{}".format(hex(0)), "{}".format(hex(0)))

    print_to_sail("aib_rx_walign_en"              , 1, 1)
    print_to_sail("aib_tx_swap_en"                , 0, 0)
    print_to_sail("aib_rx_swap_en"                , 0, 0)
    print_to_sail("aib_tx_rd_delay"               , 6, 6)
    print_to_sail("aib_rx_rd_delay"               , 6, 6)
    print_to_sail("aib_loop_back_mode"            , 0, 0)
    print_to_sail("// Channel Alignment setting"  , "", "")
    print_to_sail("CA_ALIGN_FLY"                  , local_config["align_fly"], local_config["align_fly"]) 
    print_to_sail("CA_RDEN_DLY"                   , local_config["rden_dly"], local_config["rden_dly"]) 
    print_to_sail("CA_TX_STB_EN"                  , local_config["stb_en"], local_config["stb_en"]) 
    print_to_sail("CA_RX_STB_EN"                  , local_config["stb_en"], local_config["stb_en"]) 
    print_to_sail("CA_TX_STB_LOC"                 , local_config["stb_loc"], local_config["stb_loc"]) 
    print_to_sail("CA_RX_STB_LOC"                 , local_config["stb_loc"], local_config["stb_loc"]) 


    g_sail_file.write("")

    ca_sync_fifo = 1;   ##### change to '0' for CA ASYNC FIFO mode

    ## This look complex, but we are just hitting our three windows evenly, skew <8, <16, <32
    skew_range = random.randrange(0, 2)
    if skew_range == 0:
        inter_ch_skew = random.randrange(0, 7)
    elif skew_range == 1:
        inter_ch_skew = random.randrange(8, 15)
    elif skew_range == 2:
        inter_ch_skew = random.randrange(16, 31)

    if skew_range == 0:  
        ca_fifo_depth = 8
    elif skew_range == 1:   
        ca_fifo_depth = 16
    else:
        ca_fifo_depth = 32

    ca_stb_intv = random.randrange(ca_fifo_depth * 3, ca_fifo_depth *6)

    print_to_sail("CA_SYNC_FIFO"     , ca_sync_fifo,  ca_sync_fifo)
    print_to_sail("CA_FIFO_DEPTH"    , ca_fifo_depth, ca_fifo_depth)
    print_to_sail("CA_TX_STB_INTV"   , ca_stb_intv, ca_stb_intv)
    print_to_sail("CA_RX_STB_INTV"   , ca_stb_intv, ca_stb_intv)
    print_to_sail("GLOBAL_MAX_INTER_CH_SKEW"   , inter_ch_skew)

    g_sail_file.write("")


if __name__ == '__main__':
    main()
