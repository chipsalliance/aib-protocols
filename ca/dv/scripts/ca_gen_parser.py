import sys
import os
import re
import random
import csv
import numpy as np
import array as ack_array
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--filename","-f", help = " sailrock.txt Input filename")
parser.add_argument("--cfgfilename","-cfg", help = " Default CFG filename")
parser.add_argument("--ofilename","-o", help = " Config Output filename")
args = parser.parse_args()

if args.filename is not None:
    input_file = os.path.join(os.getcwd(), args.filename)
    cfg_default_file = os.path.join(os.getcwd(), args.cfgfilename)
    out_file = os.path.join(os.getcwd(), args.ofilename)
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

cfgfile = open(cfg_default_file,"r")
Regoutfile = open(out_file,"w")
ack_array = []
wfile = open(input_file,"r")
cfgfiles = cfgfile.readlines()
wfilelist = wfile.readlines()

for cfgfile in cfgfiles :
  if not cfgfile.strip() : continue
  ip_fields = re.findall(r'\S+', cfgfile)
  cfgname = ip_fields[0]
  for wlist in wfilelist :
    if not wlist.strip() : continue
    wfields = re.findall(r'\S+', wlist)
    wname = wfields[0]
    if cfgname in wname :
      wmvalue = wfields[1]
      wsvalue = wfields[2]
      Regoutfile.write( "`define " + cfgname + "  " + wmvalue + "\n")

print(" == Finished parser File :: " + out_file + "\n")

