#!/usr/bin/perl
##############
#
# analyzeDeployedAPs.pl
# Determine the types and quantities of access points in a Cisco account
# input file: .csv export from CiscoReady (with line item detail)
# output: terminal (no files)
# usage: wireless.pl <ACCOUNT NAME>
#
##############



use strict;
#use Number::Format;



my $inputFile = "sample-data-sled-heartland.csv";   #This is the CSV 
my $lineInput;
#my @account;
#my @productID;
#my @quantity;
my ($account, $businessEntity, $businessSubEntity, $productID, $grandTotalQty, $grandTotalValue, $qty2005, $value2005, $qty2006, $value2006, $qty2007, $value2007, $qty2008, $value2008, $qty2009, $value2009, $qty2010, $value2010, $qty2011, $value2011, $qty2012, $value2012, $qty2013, $value2013, $qty2014, $value2014, $qty2015, $value2015, $qty2016, $value2016) = 0;
my $APFamily;
my $APac2 = 0;   #just orderable now, but I want to capture
my $APac1 = 0;
my $APn = 0;
my $APg = 0;
my $totalAPs = 0;




if ($#ARGV != 0) {  #should be 1 argument on CLI
print "usage is analyzeDeployedAPs.pl ACCOUNT_NAME\nTry something like wireless.pl \"OK-UNIVERSITY OF OKLAHOMA\"\nNotice the quotes around the account name\n";
exit;
}


my $accountIn = $ARGV[0];

open (INPUTFILE, "<$inputFile") or die "$! error trying to open $inputFile\n Make sure it in in the same directory as this script. \n This file needs to be csv formatted output from CiscoReady\n Also, It needs the specific columns and formats shown in the youtube video.\nLink here\n";
for $lineInput (<INPUTFILE>) {

($account, $productID, $grandTotalQty, $grandTotalValue) = (split /,/, $lineInput);
#todo - make that line work regardless how many years of data is input

#print "$account   -  $productID   -  $grandTotalQty\n";
#Is the $grandTotalQty >1000?  If so, will need to format it correctly
#actually I can't.  The CSV needs to unformat it before sending.




if ($account eq $accountIn) {
#print "$account   -  $productID   -  $grandTotalQty\n";


#Match the product ID to an AP part number
my $APFamily = '';
my $PIDsuffix = '';
$productID =~ m/AIR-.AP(\d\d\d)(.+?)(\w$)/;  #capture the last character of the PID.  
$APFamily = $1;
$PIDsuffix = $3;


#Is this an AP?
if ($APFamily ne '')  {   #Only continue if this PID is an AP
if ($PIDsuffix eq '9' || $PIDsuffix eq 'K'){  #PIDsuffix has to end in "K" or "9" to be counted.  Otherwise, it is a bundle part that will end up being double counted with -BULK suffixes (example -AK910 or -WLC)

#print "$account   -  $productID   -  $grandTotalQty\n";

#count up my 802.11ac wave 2 APs
if ($APFamily eq '380' || $APFamily eq '280' || $APFamily eq '180') {
$APac2 = $APac2 + $grandTotalQty;
}

#count up my 802.11ac wave 1 APs
if ($APFamily eq '370' || $APFamily eq '270' || $APFamily eq '170' || $APFamily eq '157') {
$APac1 = $APac1 + $grandTotalQty;
}

#count up my 802.11n APs
if ($APFamily eq '360' || $APFamily eq '260' || $APFamily eq '160' || $APFamily eq '350' || $APFamily eq '702' || $APFamily eq '155' || $APFamily eq '153' || $APFamily eq '126' || $APFamily eq '125' || $APFamily eq '114')
 {
$APn = $APn + $grandTotalQty;
}

#count up my 802.11g APs
if ($APFamily eq '521' || $APFamily eq '242' || $APFamily eq '152' || $APFamily eq '151' || $APFamily eq '131' || $APFamily eq '124' || $APFamily eq '123' || $APFamily eq '122' || $APFamily eq '113' || $APFamily eq '112' || $APFamily eq '104' || $APFamily eq '103' || $APFamily eq '101') {
$APg = $APg + $grandTotalQty;
}


}
}
}
}


$totalAPs = $APac2 + $APac1 + $APn + $APg;

my $percentAC2 = $APac2 / $totalAPs;
$percentAC2 = sprintf '%.0f%%', 100 * $percentAC2;
my $percentAC1 = $APac1 / $totalAPs;
$percentAC1 = sprintf '%.0f%%', 100 * $percentAC1;
my $percentN = $APn / $totalAPs;
$percentN = sprintf '%.0f%%', 100 * $percentN;
my $percentG = $APg / $totalAPs;
$percentG = sprintf '%.0f%%', 100 * $percentG;


print "total 802.11ac2 APs: $APac2 ($percentAC2) \n";
print "total 802.11ac1 APs: $APac1 ($percentAC1)\n";
print "total 802.11n APs:   $APn ($percentN) \n";
print "total 802.11g APs:   $APg ($percentG) \n";
print "\n";
print "Total APs: $totalAPs\n";




