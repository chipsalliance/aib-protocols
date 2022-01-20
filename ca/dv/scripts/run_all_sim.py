#! /p/psg/ctools/python/3.8.10/8/linux64/suse11/bin/python3
import sys
import os
import subprocess
import re
import random
import csv
import array as ack_array
import argparse
import shutil
import fileinput


default_cfgname = "sailrock_cfg.txt"
default_changelist = "index_table_list.txt"
default_runsim_name = "run_sim"
default_mname = "makefile"
out_mname ="makefile_temp"

def replace_string(list, toRetVal, random_v, rnum):
  r_fields = re.findall(r'\S+', list)
  range = r_fields[3]
  pcount = 0
##  toRetVal = []
  if (range.find(',') != -1):
    wnfields = range.split(",")
    if (random_v == 'random') :
      num = 1
      while num < (rnum+1) :
        new_line = ""
        mrand_val=random.choice(wnfields)
        srand_val=random.choice(wnfields)
        r_fields[1] = mrand_val
        r_fields[2] = srand_val
        for nl in r_fields:
          new_line=" ".join([new_line, nl])
        new_line=" ".join([new_line, '\n'])
        toRetVal.append(new_line)
        num += 1
      print (' Master RandomValue :: {}'.format(mrand_val) + ' Slave RandomValue :: {}'.format(srand_val))
    else :
      for mlist in wnfields:
        for slist in wnfields:
          new_line = ""
          ## new_line = list.replace(r_fields[1], rlist)
          r_fields[1] = mlist
          r_fields[2] = slist
          for nl in r_fields:
            new_line=" ".join([new_line, nl])
          new_line=" ".join([new_line, '\n'])

          print("oldline: ",list, "newline: ", new_line)
          toRetVal.append(new_line)
          pcount += 1
    print (' Total number of Value {}'.format(pcount))

  elif (range.find('-') != -1):
    wnfields = range.split("-")
    min_val = wnfields[0]
    max_val = wnfields[1]
    pcount = int(max_val) - int(min_val) + 1
    if (random_v == 'random'):
      num = 1
      while num < (rnum+1) :
        mrand_val=random.randrange(int(min_val), int(max_val), 1)
        srand_val=random.randrange(int(min_val), int(max_val), 1)
        new_line = ""
        r_fields[1] = str(mrand_val)
        r_fields[2] = str(srand_val)
        for nl in r_fields:
          new_line=" ".join([new_line, nl])
        new_line=" ".join([new_line, '\n'])
        toRetVal.append(new_line)
        num += 1
    else :
      mnum = int(min_val)
      while mnum < int(max_val) :
        new_line = ""
        ## new_line = list.replace(r_fields[1], rlist)
        r_fields[1] = str(mnum)
        r_fields[2] = str(mnum)
        for nl in r_fields:
          new_line=" ".join([new_line, nl])
        new_line=" ".join([new_line, '\n'])

        print("oldline: ",list, "newline: ", new_line)
        toRetVal.append(new_line)
        mnum += 1

      print (' Total number of Value {}'.format(mnum))
  else :
      print (" **** Pattern not found :: ", range)

  return toRetVal;

def writeToFile(cfgfiles, permutations, replaceLine, output_dir, default_cfgname):
  tmpcfg = cfgfiles.copy()
  pcount = 0;
  Listout_file = os.path.join(output_dir, default_changelist)
  Listoutfile = open(Listout_file,"w")
  for permute in permutations:
    Listoutfile.write(str(pcount) + " Replace :: " + permute)
    for i, line in enumerate(cfgfiles):
      if line == replaceLine:
        tmpcfg[i] = permute
    new_dirname = os.path.join(output_dir, str(pcount))
##    new_dirname = output_dir+ str(pcount)
    Listoutfile.write("Directory :: " + new_dirname + "\n")
    gd = os.makedirs(new_dirname,exist_ok=True)
    nout_file = os.path.join(new_dirname, default_cfgname)
    print('Write to file :: ', nout_file)
    Cfgoutfile = open(nout_file,"w")
    for line_tmpcfg in tmpcfg:
      Cfgoutfile.write(line_tmpcfg)
    Cfgoutfile.close()
    tmpcfg = cfgfiles.copy()
    shutil.copy2(out_mname,new_dirname+"/makefile")
    shutil.copy2(default_runsim_name,new_dirname)
    pcount += 1

def ReplaceStringInFile(file,searchExp,replaceExp):
    for line in fileinput.input(file, inplace=1):
        if searchExp in line:
            ## line = line.replace(searchExp,replaceExp)
            line = replaceExp
        sys.stdout.write(line)


################################################################################################
###### Main
################################################################################################
parser = argparse.ArgumentParser()
p_parser = argparse.ArgumentParser(add_help=False)
subparsers = parser.add_subparsers(dest='command')
# group = parser.add_mutually_exclusive_group()
p_parser.add_argument("--dirname","-d", required=True,action="store", help = " Directory Name")


parser_rand = subparsers.add_parser('random', parents=[p_parser], help='Run Randomization')
parser_rand.add_argument("--random_num","-rn", required=True, type=int, action="store", help = " Generate how many cases.")
parser_rand.add_argument("--tcfgfile","-t", required=True, action="store", help = " Target_Config_File")
parser_rand.add_argument("--cfgfilename","-cfg", type=str, required=True, action="store", default = default_cfgname, help = " Default CFG filename")

parser_reg = subparsers.add_parser('regression', parents=[p_parser], help='Run Regression')
parser_reg.add_argument("--random_num","-rn", required=False, type=int, action="store", help = " Generate how many cases.")
parser_reg.add_argument("--tcfgfile","-t", required=True, action="store", help = " Target_Config_File")
parser_reg.add_argument("--cfgfilename","-cfg", type=str, required=True, action="store", default = default_cfgname, help = " Default CFG filename")

parser_copy = subparsers.add_parser('copy', parents=[p_parser], help='Run Same setting as default')
parser_copy.add_argument("--cfgfilename","-cfg", type=str, required=True, action="store", default = default_cfgname, help = " Default CFG filename")

parser_good = subparsers.add_parser('good', parents=[p_parser], help='Run all good cfg in config/good directory')
parser_good.add_argument("--run","-run", required=False, action="store_true", help = " run simulation in each directory.")

args = parser.parse_args()

output_dir = os.path.join(os.getcwd(), '..', args.dirname)
default_cfgname = os.path.join(os.getcwd(), '..', args.cfgfilename)

## check directory
if not os.path.isdir(output_dir):
  print(' Generate Directory %s' %output_dir)
  gd = os.makedirs(output_dir,exist_ok=True)
else:
  print(' Delete Directory %s' %output_dir)
  shutil.rmtree(output_dir)
  print(' Generate Directory %s' %output_dir)
  gd = os.makedirs(output_dir,exist_ok=True)

  ## change makefile proj_dir
  #three_up = os.path.normpath(os.path.join(os.getcwd(), *([".."] * 4)) )
  #old_string = 'PROJ_DIR	= '
  #new_string = old_string + three_up + '\n'
  ## print(new_string)
shutil.copy2(default_mname,out_mname)
  #ReplaceStringInFile(out_mname,old_string,new_string)

if (args.command == 'copy') :
  print(' Using config file %s' %default_cfgname)
  print(' Using output_dir %s' %output_dir)
  gd = os.makedirs(output_dir,exist_ok=True)
  shutil.copy2(default_cfgname,output_dir+"/sailrock_cfg.txt")
  shutil.copy2(out_mname,output_dir+"/makefile")
  shutil.copy2(default_runsim_name,output_dir)

elif (args.command == 'good') :
  arr_list = os.listdir('./config/good')
  for wlist in arr_list :
    wnlist = wlist.split("-")
    woldname = os.path.join('./config/good', wlist)
    wndir = os.path.join(output_dir,wnlist[1])
    wnewname = os.path.join(wndir,default_cfgname)
    print(wndir)
    wngd = os.makedirs(wndir,exist_ok=True)
    shutil.copy2(woldname,wnewname)
    shutil.copy2(out_mname,wndir+"/makefile")
    shutil.copy2(default_runsim_name,wndir)
    if args.run :
      cwdpath = os.getcwd()
      print(' Running the simulation')
      os.chdir(wndir)
      path = os.getcwd()
      print(path)
      ## os.system("./run_sim &")
      subprocess.Popen(["./run_sim"])
      os.chdir(cwdpath)

else :
  if args.tcfgfile is not None:
    cfg_default_file = os.path.join(os.getcwd(), args.cfgfilename)
    out_file = os.path.join(output_dir, args.cfgfilename)
    input_file = os.path.join(os.getcwd(), args.tcfgfile)
    if os.path.exists(input_file) :
      print(' == Working on the input config filename :: {}'.format(args.cfgfilename))
      print(' == Do Ramdom and the output dir :: {}'.format(out_file))
    else :
      print("=======================================================================")
      print("    Error: -f Cannot find input filename %s." %args.filename)
      print("=======================================================================")
      sys.exit()

  else:
    print("=======================================================================")
    print("    Error: Please specify input file name ")
    print("=======================================================================")
    parser.print_help()
    sys.exit()

  cfgfile = open(cfg_default_file,"r")
  ack_array = []
  wfile = open(input_file,"r")
  cfgfiles = cfgfile.readlines()
  wfilelist = wfile.readlines()
  truePoint = 0

## Need to use this function to support mutiple regression
## def loop_rec (y,number):

  toRetVal = []
  for wlist in wfilelist :
    if not wlist.strip() : continue
    wfields = re.findall(r'\S+', wlist)
    wname = wfields[0]
    for cfgfile in cfgfiles :
      truePoint += 1
      if not cfgfile.strip() : continue
      ip_fields = re.findall(r'\S+', cfgfile)
      cfgname = ip_fields[0]
      if wname in cfgname :
        print(" ----- Working on ", cfgname, " workname ", wname, " loop : ", len(wfilelist))
        new_lines = replace_string(cfgfile, toRetVal, args.command, args.random_num)

  print(" Total Number of list :: ", len(new_lines))
  writeToFile(cfgfiles, new_lines, cfgfile, output_dir, default_cfgname)

print(" == Finished == \n")

