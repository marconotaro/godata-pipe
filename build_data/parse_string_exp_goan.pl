#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(time);

my $start=time;

my $file=shift;

my $prefix= ($file=~/\/orgs_data\/(.*?)\//)[0]; ## match taxon_orgs
my $pf= "../orgs_data/"."$prefix"."/";
my $date= ($file=~/goan_(.*?)\./)[0]; ## match date
my $fileout= "$pf"."$prefix"."_string_goan_"."$date".".txt";

open IN, "$file";
open OUT, "> $fileout";
while(<IN>){
    chomp;
    my @vals=split(/\t/,$_);
    my @ids=split(/\./,$vals[0],2); ## remove taxonID
    my $prs=$ids[1];
    print OUT "$prs\t$vals[2]\t$vals[3]\t$vals[4]\n";
}
close IN;

my $span= time - $start;
$span = sprintf("%.4f", $span);
print "elapsed time:\t$span seconds\n";

