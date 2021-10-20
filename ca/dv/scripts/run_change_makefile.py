import sys
import os
import re
import argparse
import fileinput
import csv
import numpy as np
import array as ack_array

default_mname = "makefile_default"
out_mname ="makefile"

def replaceAll(file,searchExp,replaceExp):
    for line in fileinput.input(file, inplace=1):
        if searchExp in line:
            ## line = line.replace(searchExp,replaceExp)
            line = replaceExp
        sys.stdout.write(line)


parser = argparse.ArgumentParser()
parser.add_argument("--filename","-f", type=str, required=False, action="store", default = default_mname, help = " Input filename")
parser.add_argument("--dirname","-d", type=str, required=True, action="store", help = " Directory Name")
args = parser.parse_args()


if args.filename is not None:
  make_file = os.path.join(os.getcwd(), args.filename)
else:
    print("=======================================================================")
    print("    Error: Please specify input file name ")
    print("=======================================================================")
    parser.print_help()
    sys.exit()

three_up = os.path.normpath(os.path.join(os.getcwd(), *([".."] * 4)) )
old_string = 'PROJ_DIR	= '
new_string = old_string + three_up + '\n'
print(new_string)
replaceAll(make_file,old_string,new_string)
