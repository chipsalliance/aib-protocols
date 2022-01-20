#! /usr/bin/perl

$DEBUG       = 0;
$ECHO        = 0;
$SERIAL_RUN  = 0;
$SLEEP       = 30;
$VERBOSE     = 1;
$MAXOUTSTANDING = 10;
$RESOURCE = "";


$CMD_FILE_DIR = "./submit_group_cmd_files";


# @RANDARRAY=localtime(time);
# $RANDNUM =join ("", $RANDARRAY[3],$RANDARRAY[2],$RANDARRAY[1],$RANDARRAY[0]);
## This is used to provide a unique qjob name
$RANDOM = `date +"%m%d%H%M%S"`;
chomp($RANDOM);


############################################################
## Store of command
############################################################
if (-e "submit_group.log")
{
  printf STDOUT ("\n WARN::submit_group.log file already exists. Moving it as submit_group_OLD.log in same path\n");
  system ("mv submit_group.log  submit_group_OLD.log ");
}
open (LOGFILE, ">", "submit_group.log" ) || die "Couldnt find submit_group.log to open for read";
print LOGFILE ("$0 ");
foreach (@ARGV)
{
  print LOGFILE ("\"",$_,"\" ");
}
print LOGFILE ("\n");
printf LOGFILE  ("# To kill everything, stop script and excecute:\nqdel ");


############################################################
## Process Arguments
############################################################
process_argv();

############################################################
## Sanity Checks
############################################################
$USER = $ENV{USER};
if ($USER eq "")
{
  printf STDERR ("ERROR:   \$\USER does not seem to be defined.\n");
  printf STDERR ("         Define it.\n");
  exit (1);
}

if ( -e $CMD_FILE_DIR)
{
  #system ("rm -Rf $CMD_FILE_DIR");
  system ("rm -Rf ${CMD_FILE_DIR}_OLD");
  printf STDOUT ("\n WARN:: $CMD_FILE_DIR directory already exists. Moving it as ${CMD_FILE_DIR}_OLD in same path\n");
  system ("mv $CMD_FILE_DIR ${CMD_FILE_DIR}_OLD");
}

system ("mkdir $CMD_FILE_DIR");
############################################################
## Begin
############################################################

if ((open (JOB_FILE, $JOBFILE)) == 1) {
  printf STDERR ("Successfully opened $JOBFILE for inputs\n") if ($DEBUG);
  @CMD_ARRAY = <JOB_FILE>;
  close (JOB_FILE);

  if ((length (@CMD_ARRAY)) == 0) {
    printf STDERR ("ERROR:  $JOBFILE is empty.\n");
    exit (1);
  }
}
else{
  printf STDERR ("ERROR:  Could not open $JOBFILE.\n");
  exit (1);
}


$NUMBER_TOTAL_CMD=@CMD_ARRAY;
$NUMBER_PROCESSED_CMD=0;
$NUMBER_TOTAL_PENDING=0;
foreach (@CMD_ARRAY)
{
  $CMDFILE=$_;

  if ($NUMBER_PROCESSED_CMD%10 == 0)
  {
    printf STDOUT ("Processing $NUMBER_PROCESSED_CMD out of $NUMBER_TOTAL_CMD\n");
  }
  process_command ($CMDFILE, $NUMBER_PROCESSED_CMD);
  $NUMBER_PROCESSED_CMD++;

  ## Hold back to max outstanding
  $NUMBER_TOTAL_PENDING=0;
  foreach $blk (keys %PENDING)
  {
    $NUMBER_TOTAL_PENDING++ if ($PENDING{$blk});
  }

  if ($NUMBER_TOTAL_PENDING >= $MAXOUTSTANDING)
  {
    printf STDERR ("    Reached max outstanding jobs (%s)... waiting for one to finish.\n", $MAXOUTSTANDING) if ($VERBOSE);
    while ($NUMBER_TOTAL_PENDING >= $MAXOUTSTANDING)
    {
      $NUMBER_TOTAL_PENDING = update_num_pending();
    }
  }
}


$NUMBER_TOTAL_PENDING=0;
foreach $blk (keys %PENDING)
{
  $NUMBER_TOTAL_PENDING++ if ($PENDING{$blk});
}

printf STDERR ("    All jobs submitted. %s pending. Waiting for finish.\n", $NUMBER_TOTAL_PENDING) if ($VERBOSE);


while ($NUMBER_TOTAL_PENDING != 0)
{
  $FOREVER_TIMEOUT = 72000/$SLEEP ;  ## We timeout after 20 hour.
  $FOREVER_COUNT = 0;

  ## After submitting everything, we wait until one finishes.
  $NUMBER_TOTAL_PENDING = update_num_pending();
  $FOREVER_COUNT ++;

  if ($FOREVER_TIMEOUT == $FOREVER_COUNT)
  {
    printf STDERR ("ERROR:  Internal timeout triggered.  I sat in this loop for $FOREVER_TIMEOUT times, each loop was $SLEEP seconds.\n");
    exit (1);
  }

}

exit (0);


sub update_num_pending
{
  last if ($DEBUG);

  foreach $blk (keys %PENDING)
  {
    $PENDING{$blk}=0;## Temp Clear CMD Pending (we set again in WAIT loop)
  }
  $NUMBER_CURR_PENDING=0;
  sleep ($SLEEP);
#     open(TEMP,"qstat -r | grep \"Full jobname\"|" );
  open(TEMP,"qstat -r |" );
  while (<TEMP>)
  {
    if (/Full jobname:\s+(q_job_([0-9_]+)_${USER}_${RANDOM}_)/)
    {
      $JOB_FOUND = 1;
      $JOB_NAME = $1;
      #printf STDERR ("Block $JOB_NAME is still pending on a machine\n") if ($VERBOSE);
    }
    elsif (/Master Queue:\s+(.+)/ && $JOB_FOUND)
    {
      $JOB_FOUND = 0;
      printf STDERR ("        $JOB_NAME is still pending on $1\n") if ($VERBOSE);
      $NUMBER_CURR_PENDING++;
      $PENDING{$JOB_NAME}=1;  ## Set CMD Pending
    }
  }

  foreach $blk (keys %PENDING)
  {
    if ($PENDING{$blk}==0)
    {
      printf STDERR ("        $blk finished.\n") if ($VERBOSE);
    }
  }

  printf STDERR ("    %s tasks out of %s completed\n", $NUMBER_TOTAL_PENDING - $NUMBER_CURR_PENDING, $NUMBER_TOTAL_PENDING) if ($VERBOSE);
  $DATA = `date`;
  printf STDERR ("    $DATA") if ($VERBOSE);

  foreach $blk (keys %PENDING)
  {
    if (!$PENDING{$blk})
    {
#      check_cmd ($blk);
      delete $PENDING{$blk};
    }
  }

  return $NUMBER_CURR_PENDING;
}

sub process_command
{
  my ($LOC_CMD, $LOC_NUMBER_CMD) = @_;

  $QNAME = "q_job_${LOC_NUMBER_CMD}_${USER}_${RANDOM}_";
  $QFILE = "${CMD_FILE_DIR}/${QNAME}";

  open (CMD_FILE, ">", "$QFILE" ) || die "Couldnt open $QFILE for writing";
  print CMD_FILE ("$LOC_CMD");
  close (CMD_FILE);

  $PENDING{$QNAME} = 1;
  $QSUB = sprintf ("qsub -cwd -V -o $CMD_FILE_DIR -e $CMD_FILE_DIR $RESOURCE -N $QNAME $QFILE");
  printf ("$QSUB\n")    if ( $ECHO) ;
  system ("$QSUB")      if (!$DEBUG);


  ######### Wait for new ones to learn jobid.

  ($JOBID) = get_jobid($QNAME);
  printf LOGFILE  (" $JOBID ");

};

sub check_cmd
{
  my ($LOC_DIR) = @_;

  my $LOC_CMD;
  my $ERROR_TEXT;
  my $STATE_ERROR=0;

  if (1)
  {
    $LOC_CMD = sprintf ("cd $LOC_DIR ; grep -i error SYN_$LOC_DIR\_$RANDNUM.o* SYN_$LOC_DIR\_$RANDNUM.e*  | grep -vi -e \"No errors\" -e \"0 error\" -e \"Number of errors\" -e \"DRC detected 0 errors\" -e \"FLEXlm error\" -e \"error\(s\) encountered while translating PrimeTime\" ");

    printf LOGFILE ("%20s ...  ",$LOC_DIR);

    open(TEMP,"$LOC_CMD |" );
    while (<TEMP>)
    {
      if ((/error/i) && (!$STATE_ERROR))
      {
        $ERROR_TEXT = $_;
        chomp ($ERROR_TEXT);
        printf STDERR ("*** Found this error in $LOC_DIR \n$ERROR_TEXT\n");
        $STATE_ERROR=1;
      }
    }
    close (TEMP);

###    if (!$STATE_ERROR)
###    {
###
###      if (-e "$LOC_DIR/$LOC_DIR.gate.v")
###      {
###          $LOC_CMD = "cd $LOC_DIR ; $CVSCOPATH/bin/find_clk.pl $LOC_DIR.gate.v; ";
###          system ("$LOC_CMD > /dev/null");
###      }
###      elsif ((-e "rru/rr.gate.v") && ($LOC_DIR eq "rru"))
###      {
###          $LOC_CMD = "cd $LOC_DIR ; $CVSCOPATH/bin/find_clk.pl rr.gate.v; ";
###          system ("$LOC_CMD > /dev/null");
###      }
###      else
###      {
###          $STATE_ERROR=1;
###          $ERROR_TEXT = "No $LOC_DIR/$LOC_DIR.gate.v file created.\n";
###          printf STDERR ("*** Found this error in stage $ERROR_TEXT\n");
###      }
###    }

    if ($STATE_ERROR)
    {
      printf LOGFILE  ("FAILED...  ErrorInfo:  $LOC_DIR/$ERROR_TEXT\n");
    }
    else
    {
      printf LOGFILE  ("success.\n");
    }
  }
};

sub get_jobid
{
  my ($LOC_NAME) = @_;
    open(TEMP,"qstat -r|" );
    while (<TEMP>)
    {
      if (/([0-9]+)\s+([\.0-9]+)\s+$LOC_NAME\s+$USER\s+/)
      {
        $JOBID = $1;
      }
      elsif (/Full jobname:\s+$LOC_NAME/)
      {
        return ($JOBID);
      }
    }

};

############################################################
## Process Arguments
############################################################
sub process_argv
{
  my @ARRAY = @ARGV;
  if ($#ARRAY == -1)
  {
     print_help();
     exit (1);
  };

  while ($#ARRAY >= 0)
  {
    $_ = @ARRAY[0];
    #printf  ("$_\n");
    if (/^--?h(elp)?$/)
    {
      print_help();
      exit (1);
    }
    elsif (/^echo$/)
    {
      $ECHO = 1;
      shift @ARRAY; next;
    }
    elsif (/^verbose$/)
    {
      $VERBOSE = 1;
      shift @ARRAY; next;
    }
    elsif (/^sleep=([0-9]+)$/)
    {
      $SLEEP = $1;
      shift @ARRAY; next;
    }
    elsif (/^max=([0-9]+)$/)
    {
      $MAXOUTSTANDING = $1;
      shift @ARRAY; next;
    }
    elsif (/^-l$/)
    {
      shift @ARRAY;
      $RESOURCE = "-l @ARRAY[0]";
      printf STDOUT  ("Using grid resource: $RESOURCE.\n");
      shift @ARRAY; next;
    }
    elsif (/^-?-?d(ebug)?$/)
    {
      $ECHO = 1;
      $DEBUG = 1;
      $SLEEP = 2;
      shift @ARRAY; next;
    }
    else
    {
      if (!(-e $_))
      {
        printf STDERR ("Possible command file but cannot find it. \:$_\:\n");
        print_help();
        exit (1);
      }
      else
      {
        $JOBFILE = $_;
      }
      shift @ARRAY; next;
    }
    printf STDERR ("Something terrible happened.\n");
    print_help();
    exit (1);

  }
}

sub print_help
{
  printf STDOUT ("\n");
  printf STDOUT ("This script submits multiple qsub-esque commands to the grid, polls for a completion, and\n");
  printf STDOUT ("only then will it submit a new command.  In this way, load balancing is ensured.\n");
  printf STDOUT ("\n");
  printf STDOUT ("Usage:  submit_group.pl [Options] jobfile\n");
  printf STDOUT (" Options: \n");
  printf STDOUT ("  sleep=NN   : In parllel mode, how often to check if qsub completed.  (default = 30 sec) \n");
  printf STDOUT ("  max=NN     : Sets max number of parrallel commands. (default = 5)\n");
  printf STDOUT ("  -l resrc=1 : Sets resource requirement on qsub command.  Use -l full=1 for regression. (default = -l syn=1)\n");
  printf STDOUT ("  echo       : Echos commands to screen.  (default = 0) \n");
  printf STDOUT ("  -d | debug : Enables debug (no commands actually executed).  Sets echo. (default = 0)\n");
  printf STDOUT ("  verbose    : Sets verbose echos back to screen about multirun state. (default = 0)\n");
  printf STDOUT ("  jobfile is a list of commands seperated by newlines. Each newline is its own command.\n");
};







