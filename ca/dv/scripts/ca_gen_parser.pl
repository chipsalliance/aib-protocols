use Getopt::Long qw(GetOptions);
# TODO
#print "-------------------USAGE-------------------------\n";
#print "$0 -f <filename> [-rand]\n";
#print "-------------------------------------------------\n";

my $filename = '';
my $randEnable=0;
GetOptions( 'f=s' => \$filename,
		'rand' =>\$randEnable );

my $randFile = $filename;
$randFile =~ s/\.txt/_rand\.txt/;

# TODO :print $randEnable ? "Randomizing\n" : "No Randomize\n";
if($randEnable) {
	open (OP3, '>', $randFile) or die $!;
}
my @contentArr;
my $NumChannel,$ChanType,$TxRate,$RxRate,$TxDBI,$RxDBI;
my $Asymmetric;

my $randVal,$randTxStrobeLoc, $randRxStrobeLoc;
my @chanTypeArr = ("Gen2Only","Gen1Only");
my @Gen1ModeArr = ("Full", "Half");
my @Gen2ModeArr = ("Full", "Half", "Quarter");
my @rxFifoDepArr = (8,16,32);
my @DataArr = (8,16,32,64,128,256,512);
my @AddrArr = (32,48);
my @DBI_locArr = (38,39,78,79);
my $fKey, $fVal1,$fVal2, $fVal3, $fVal4, $rxFifoDepRand = 0, $txFifoDepRand =0; 

my $CaTxStbWdSel,$CaRxStbWdSel,$CaTxStbBitSel,$CaRxStbBitSel,$CaTxStbEn,$CaRxStbEn,$CaFifoDepth,$CaFifoPFull ;
my @randKeyArr= ("GLOBAL_GEN2_MODE","GLOBAL_TX_MODE","GLOBAL_RX_MODE","AXIST_ASYMMETRIC_SUPPORT",
		"GLOBAL_TX_WMARKER_EN","GLOBAL_TX_DBI_EN","GLOBAL_RX_DBI_EN","LLINK_TX_ENABLE_STROBE",
		"LLINK_RX_ENABLE_STROBE","LLINK_TX_PERSISTENT_STROBE",
		"LLINK_RX_PERSISTENT_STROBE","LLINK_TX_USER_STROBE","LLINK_RX_USER_STROBE",
		"LLINK_TX_STROBE_LOC","LLINK_RX_STROBE_LOC","LLINK_TX_PERSISTENT_MARKER",
		"LLINK_RX_PERSISTENT_MARKER","LLINK_TX_USER_MARKER","LLINK_RX_USER_MARKER","GLOBAL_TX_MARKER_LOC","GLOBAL_RX_MARKER_LOC",
		"AXIST_RX_FIFO_DEPTH","AXIST_USER_TDATA","AXIST_USER_TKEEP","AXIST_USER_TLAST",
		"AXIST_USER_TVALID","AXIST_USER_TREADY");

sub writeToFile {
	($fKey,$fVal1,$fVal2,$fVal3, $fVal4) = @_;
	select(OP3);
	$~ = "MYFORMAT";
	write;
}

format MYFORMAT = 
@<<<<<<<<<<<<<<<<<<<<<<<<<<<<    @<<<<<<<<<<<<<<<<<<<<<<   @<<<<<<<<<<<<<<<<<<<<   @<<<<<<<<<<<<<<<<<<<<<  @<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
$fKey, $fVal1, $fVal2, $fVal3, $fVal4
.

sub printRandVal {
	my $keyStr = shift;
	my $index = shift;
	my $valStr1="", $valStr2="",$randVal;
	if($keyStr eq "GLOBAL_GEN2_MODE") {
		$valStr1 = $chanTypeArr[rand @chanTypeArr]; #same
			$valStr2 = $valStr1;
		$ChanType = $valStr1; 
	}
	elsif($keyStr eq "AXIST_ASYMMETRIC_SUPPORT" ) {
		$valStr1 = $Asymmetric;
	}
	elsif($keyStr eq "GLOBAL_TX_MODE") {
		if ( grep( /^AXIST_ASYMMETRIC_SUPPORT/, @contentArr ) ) { #check
			$Asymmetric = int(rand(2));
		}
		if($ChanType eq "Gen1" || $ChanType eq "Gen1Only") { 
			if($Asymmetric == 1) {
				$TxRate = $Gen1ModeArr[rand @Gen1ModeArr] ;
				$RxRate = $Gen1ModeArr[rand @Gen1ModeArr] ;
			}
			else {
				$TxRate = $Gen1ModeArr[rand @Gen1ModeArr] ;
				$RxRate = $TxRate;
			}
		}
		elsif($ChanType eq "Gen2" || $ChanType eq "Gen2Only") {
			if($Asymmetric == 1) {
				$TxRate = $Gen2ModeArr[rand @Gen2ModeArr] ;
				$RxRate = $Gen2ModeArr[rand @Gen2ModeArr] ;
			}
			else {
				$TxRate = $Gen2ModeArr[rand @Gen2ModeArr] ;
				$RxRate = $TxRate;
			}
		}
		$valStr1 = $TxRate;
		$valStr2 = $RxRate;

		if($valStr1 eq "Full") {
			$dataBit = 80;
		}
		elsif($valStr1 eq "Half") {
			$dataBit = 160;
		}
		elsif($valStr1 eq "Quarter") {
			$dataBit = 320;
		}
	}
	elsif($keyStr eq "GLOBAL_RX_MODE") {
		$valStr1 = $TxRate;
		$valStr2 = $RxRate;
	}
	elsif($keyStr eq "GLOBAL_TX_DBI_EN") {
		$TxDBI = int(rand(2));
		$valStr1 = $TxDBI;
	}
	elsif($keyStr eq "LLINK_TX_STROBE_LOC") {
		if($TxDBI == 1) {
			while(1) {
				$randVal = int(rand(320));
				last if(!(grep(/^$randVal$/, @DBI_locArr))); 
			}
			$valStr1 = $randVal ;
		}
		else {
			$randVal = int(rand(320));
		}
		$randTxStrobeLoc = $randVal;
	}
	elsif($keyStr eq "GLOBAL_RX_STROBE_LOC") {
		while(1) {
			$randVal = int(rand(320));
			last if(!(grep(/^$randVal$/, @DBI_locArr))); 
		}
		$valStr1 = $randVal ;
		$randRxStrobeLoc = $randVal;
	}
	elsif($keyStr eq "GLOBAL_TX_MARKER_LOC") {
		if($ChanType eq "Gen1" || $ChanType eq "Gen1Only") { 
			$randVal = 39;	
		}
		else {
			while(1){
				$randVal = int(rand(4)) + 76;
				last if($randVal != $randTxStrobeLoc); #TODO check
			}
		}
		$txMarkerTemp = $randVal;
		return;
	}
	elsif($keyStr eq "GLOBAL_RX_MARKER_LOC") {
		if($ChanType eq "Gen1" || $ChanType eq "Gen1Only") {
			$randVal = 39;	
		}
		else {
			while(1){
				$randVal = int(rand(4)) + 76;
				last if($randVal != $randRxStrobeLoc); #TODO check
			}
		}
		writeToFile("GLOBAL_TX_MARKER_LOC", $txMarkerTemp, $randVal);
		$valStr1 = $randVal ;
		$valStr2 = $txMarkerTemp;
	}
	elsif($keyStr eq "GLOBAL_TX_WMARKER_EN") {
		$valStr1 = int(rand(2))."\t\t".int(rand(2));
	}
	else {
		if($index == 1) {
			$valStr1 = int(rand(2));
			$valStr2 = "";
		}
		if($index == 2) {
			$valStr1 = int(rand(2));
			$valStr2 = int(rand(2));
		}
	}
	writeToFile($keyStr, $valStr1, $valStr2);
}

my %masterHash, %slaveHash;
#: this loop is for randEnable, takes i/p file and randomize
if($randEnable){
	open $IP, '<', $filename or die $!; #opening a file in read mode.
		@contentArr = <$IP>;
	close($IP);
	foreach $line (@contentArr){
		next if ($line =~ /\/\/.*/);
		next if ($line =~/^interface_0.*/);
		chomp($line);
		if ($line ne ""){

			($key, $master, $slave, $val, @commentArr) = split ' ', $line;
			$comment = join(' ', @commentArr);
			if ( grep( /^$key$/, @randKeyArr ) ) {
				if($slave eq  "") {
					printRandVal($key,1);
				}
				else {
					printRandVal($key,2);
				}
			}
			else {
				next if($key eq "AXIST_TX_FIFO_DEPTH");
				writeToFile($key, $master, $slave, $val, $comment);
			}
		}
	}
#TODO
#calculate NUM_CHAN and print
#writeToFile("NUM_CHAN", $valNumChan);
	close(OP3);
	$filename = $randFile; 
	select(STDOUT);
	print "Generated Rand file : $randFile\n";
}

# here the i/p file is randfile if randEnable, else the original i/p file
#and the usual process continues here..
print "i/p file is: $filename\n";
open(FH, '<', $filename) or die $!; #opening a file in read mode.
open (OP4, '>', "ca_config_define.svi") or die $!;
while(<FH>) {    
	$str = $_;  
	next if ($line =~ /\/\/.*/);
	next if ($line =~/^interface_0.*/);
	$str =~ s/\/\/.*/ /g;
	chomp($str);
	if ($str ne ""){

		($key, $master,$slave) = split ' ', $str;
		if ($key =~ m/^CA_.*/) {
			print OP4 "`define $key\t\t$master\n";
		}
		$masterHash{$key}=$master;
		$slaveHash{$key}=$slave;

	}
	if(exists($masterHash{"CA_FIFO_DEPTH"})) {
		$CaFifoDepth= $masterHash{"CA_FIFO_DEPTH"} ;
	}
}

close(FH);

my $TxEnableStrobe,$RxEnableStrobe,$TxPersistentStrobe,$RxPersistentStrobe,$TxUserStrobe,$RxUserStrobe,$TxStrobeGenLoc,$RxStrobeGenLoc;
my $TxEnableMarker,$RxEnableMarker, $TxPersistentMarker, $RxPersistentMarker,$TxUserMarker,$RxUserMarker,$TxMarkerGenLoc,$RxMarkerGenLoc;

if(exists($masterHash{"GLOBAL_NUM_OF_CHANNEL"})) {
	$NumChannel= $masterHash{"GLOBAL_NUM_OF_CHANNEL"} ;
}

if(exists($masterHash{"GLOBAL_GEN2_MODE"})){

	$ChanType = $masterHash{"GLOBAL_GEN2_MODE"};
	if ($ChanType == 0 ){
		$ChanType = "Gen1Only"; 
	}
	elsif ($ChanType == 1 ){
		$ChanType = "Gen2Only"; 
	}
	else{
		print OP2 "CHAN_TYPE\t\t\t\tNot Valid\n";
		exit;
	}
}

if(exists($masterHash{"GLOBAL_TX_MODE"})){
	$TxRate = $masterHash{"GLOBAL_TX_MODE"};
	$RxRate = $slaveHash{"GLOBAL_TX_MODE"};

	$TxRate = "Full" if ($TxRate eq "fifo_1x");
	$TxRate = "Full" if ($TxRate eq "reg");
	$TxRate = "Half" if ($TxRate eq "fifo_2x");
	$TxRate = "Quarter" if ($TxRate eq "fifo_4x");

	$RxRate = "Full" if ($RxRate eq "fifo_1x");
	$RxRate = "Full" if ($RxRate eq "reg");
	$RxRate = "Half" if ($RxRate eq "fifo_2x");
	$RxRate = "Quarter" if ($RxRate eq "fifo_4x");

	if ($ChanType eq "Gen1Only") {
		if (($TxRate ne "Full") and ($TxRate ne "Half")){
			print OP4 "TX_RATE\t\t\t\tNot Valid\n";
			exit;
		}
		elsif (($RxRate ne "Full") and ($RxRate ne "Half")){
			print OP4 "RX_RATE\t\t\t\tNot Valid\n";
			exit;
		}
	}
	else { #Gen2
		if (($TxRate ne "Full") and ($TxRate ne "Half") and ($TxRate ne "Quarter")){
			print OP4 "TX_RATE\t\t\t\tNot Valid\n";
			exit;
		}
		elsif (($RxRate ne "Full") and ($RxRate ne "Half") and ($RxRate ne "Quarter")){
			print OP4 "RX_RATE\t\t\t\tNot Valid\n";
			exit;
		}
	}

}
if(exists($masterHash{'AXIST_ASYMMETRIC_SUPPORT'})) {
	$Asymmetric= ($masterHash{'AXIST_ASYMMETRIC_SUPPORT'} == 1) ? "True" : "False";
}

if(exists($masterHash{'GLOBAL_TX_WMARKER_EN'})){         #If AIB marker is enabled, LLINK USER marker will be disabled.
	$TxEnableMarker= ($masterHash{'GLOBAL_TX_WMARKER_EN'} == 1) ? "True" : "False";
	$RxEnableMarker= ($slaveHash{'GLOBAL_TX_WMARKER_EN'} == 1) ? "True" : "False";
	if ($Asymmetric eq "True"){
		$TxEnableMarker=  "True";
		$RxEnableMarker=  "True";
	}
}

if(exists($masterHash{"GLOBAL_TX_DBI_EN"})){
	$TxDBI = ($masterHash{"GLOBAL_TX_DBI_EN"}== 1) ? "True" : "False";
}

if(exists($masterHash{"GLOBAL_RX_DBI_EN"})){
	$RxDBI = ($masterHash{"GLOBAL_RX_DBI_EN"}== 1) ? "True" : "False";
}

if(exists($masterHash{"LLINK_TX_ENABLE_STROBE"})){
	$TxEnableStrobe = ($masterHash{"LLINK_TX_ENABLE_STROBE"}== 1) ? "True" : "False";
}

if(exists($masterHash{"LLINK_RX_ENABLE_STROBE"})){
	$RxEnableStrobe = ($masterHash{"LLINK_RX_ENABLE_STROBE"}== 1) ? "True" : "False";
}

if(exists($masterHash{"LLINK_TX_PERSISTENT_STROBE"})){
	$TxPersistentStrobe= ($masterHash{"LLINK_TX_PERSISTENT_STROBE"}== 1) ? "True" : "False";
}

if(exists($masterHash{"LLINK_RX_PERSISTENT_STROBE"})){
	$RxPersistentStrobe= ($masterHash{"LLINK_RX_PERSISTENT_STROBE"}== 1) ? "True" : "False";
}

if(exists($masterHash{"LLINK_TX_USER_STROBE"})){
	$TxUserStrobe = ($masterHash{"LLINK_TX_USER_STROBE"}== 1) ? "True" : "False";
}
if(exists($masterHash{"LLINK_RX_USER_STROBE"})){
	$RxUserStrobe = ($masterHash{"LLINK_RX_USER_STROBE"}== 1) ? "True" : "False";
}

if(exists($masterHash{"LLINK_TX_STROBE_LOC"})){
	$TxStrobeGenLoc = $masterHash{"LLINK_TX_STROBE_LOC"};
}

if(exists($masterHash{"LLINK_RX_STROBE_LOC"})){
	$RxStrobeGenLoc = $masterHash{"LLINK_RX_STROBE_LOC"};
}

if(exists($masterHash{"GLOBAL_TX_MARKER_LOC"})){
	$TxMarkerGenLoc= $masterHash{"GLOBAL_TX_MARKER_LOC"};
}

if(exists($masterHash{"GLOBAL_RX_MARKER_LOC"})){
	$RxMarkerGenLoc= $masterHash{"GLOBAL_RX_MARKER_LOC"};
}


############################################################################

if ($ChanType eq "Gen2Only") {
	print OP4 "`define GEN2\n\n";
}
else {
	print OP4 "`define GEN1\n";
}

if ($TxRate eq "Full") {

	print OP4 "`define TX_RATE_F\n";
}

elsif ($TxRate eq "Half") {

	print OP4 "`define TX_RATE_H\n";
}
elsif ($TxRate eq "Quarter") {

	print OP4 "`define TX_RATE_Q\n";
}
else  {

	print OP4 "Not Defined\n";
}

if ($RxRate eq "Full") {

	print OP4 "`define RX_RATE_F\n";
}

elsif ($RxRate eq "Half") {

	print OP4 "`define RX_RATE_H\n";
}
elsif ($RxRate eq "Quarter") {

	print OP4 "`define RX_RATE_Q\n";
}
else  {

	print OP4 "Not Defined\n";
}

## Printing CA calculated values
$CaTxStbWdSel  = (1 << ($TxStrobeGenLoc/32));
$CaTxStbBitSel = (1<< ($TxStrobeGenLoc%32));
$CaRxStbWdSel  = (1 << ($RxStrobeGenLoc/32));
$CaRxStbBitSel = (1<< ($RxStrobeGenLoc%32));
$CaTxStbEn     = ($TxEnableStrobe= 1) ? 0 : 1;
$CaRxStbEn     = ($RxEnableStrobe= 1) ? 0 : 1;
$CaFifoPFull   = $CaFifoDepth-4;
print OP4 "`define CA_FIFO_DEPTH		$CaFifoDepth\n";
print OP4 "`define CA_FIFO_FULL		$CaFifoDepth\n";
print OP4 "`define CA_FIFO_PFULL		$CaFifoPFull\n";
print OP4 "`define CA_FIFO_EMPTY		0\n";
print OP4 "`define CA_FIFO_PEMPTY		2\n";
print OP4 "`define CA_TX_STB_EN		$CaTxStbEn\n";
print OP4 "`define CA_RX_STB_EN		$CaRxStbEn\n";

printf (OP4 "`define CA_TX_STB_WD_SEL	%0x\n",$CaTxStbWdSel);
printf (OP4 "`define CA_RX_STB_WD_SEL	%0x\n",$CaRxStbWdSel);
printf (OP4 "`define CA_TX_STB_BIT_SEL	40'h%x\n",$CaTxStbBitSel);
printf (OP4 "`define CA_RX_STB_BIT_SEL	40'h%x\n",$CaRxStbBitSel);

close(OP4);
