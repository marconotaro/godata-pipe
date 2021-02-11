#!/usr/bin/perl

use strict;
use warnings;
use PerlIO::gzip;
use Time::HiRes qw(time);

my $start=time;

my $filenet= shift;
if($filenet=~/.gz$/){open IN, "<:gzip", $filenet;}else{open IN, $filenet;}

my $prefix= ($filenet=~/\/orgs_data\/(.*?)\//)[0]; ## match taxon_orgs
my $pf= "../orgs_data/"."$prefix"."/";
my $stringv= ($filenet=~/links_(.*?)\.txt/)[0]; ## match stringv
my $fileout= "$pf"."$prefix"."_string_"."$stringv.txt.gz";

open OUT, ">:gzip", $fileout;
while(<IN>){
    chomp;
    if($.<2){next;}
    my @vals=split(/\s+/,$_);
    my @prsA=split(/\./,$vals[0],2);
    my @prsB=split(/\./,$vals[1],2);
    my $intA=$prsA[1];
    my $intB=$prsB[1];
    print OUT "$intA\t$intB\t$vals[2]\n";
}
close IN;
close OUT;

my $span= time - $start;
$span = sprintf("%.4f", $span);
print "elapsed time:\t$span seconds\n";

