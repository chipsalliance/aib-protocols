import sys
import os
import re
import random
import csv
import numpy as np
import array as ack_array
import argparse

## if sys.version_info < (3,):
##     print("=======================================================================")
##     print(" Error :: Python version sys.version_info. Should be > 3")
##     print("=======================================================================")
##     sys.exit()

parser = argparse.ArgumentParser()
parser.add_argument("--filename","-f", help = " Input filename")
parser.add_argument("--aibfilename","-aib_cfg", help = " AIB Default Input filename")
parser.add_argument("--aibofilename","-o", help = " AIB Config Output filename")
args = parser.parse_args()

if args.filename is not None:
    input_file = os.path.join(os.getcwd(), args.filename)
    aib_default_file = os.path.join(os.getcwd(), args.aibfilename)
    aib_out_file = os.path.join(os.getcwd(), args.aibofilename)
    if os.path.exists(input_file) :
      print(' == Working on the input config filename :: {}'.format(args.filename))
    else :
      print("=======================================================================")
      print("    Error: -f Cannot find input file name %s." %args.filename)
      print("=======================================================================")
      sys.exit()

else:
    print("=======================================================================")
    print("    Error: Please specify input file name ")
    print("=======================================================================")
    parser.print_help()
    sys.exit()

cfgfile = open(aib_default_file,"r")
Regoutfile = open(aib_out_file,"w")
ack_array = []
wfile = open(input_file,"r")
cfgfiles = cfgfile.readlines()
wfilelist = wfile.readlines()
Regoutfile.write("interface_0  master  slave\n")

for cfgfile in cfgfiles :
  if not cfgfile.strip() : continue
  ip_fields = re.findall(r'\S+', cfgfile, re.IGNORECASE)
  cfgname = ip_fields[0].replace("aib_","",1)
  for wlist in wfilelist :
    if not wlist.strip() : continue
    wfields = re.findall(r'\S+', wlist, re.IGNORECASE)
    wname = wfields[0]
    if cfgname.lower() in wname.lower() :
      wmvalue = wfields[1]
      wsvalue = wfields[2]
      Regoutfile.write( "aib_" + cfgname.lower() + "  " + wmvalue + "  " + wsvalue + "\n")

print(" == Finished AIB parser File :: " + aib_out_file + "\n")

