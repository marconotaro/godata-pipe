#!/usr/bin/perl

use strict;
use warnings;
use obogaf::parser;
use Time::HiRes qw(time);

my $start= time;

my $rfile= shift;
my ($annref, $stat)= obogaf::parser::gene2biofun($rfile, 0, 1);

my $prefix= ($rfile=~/\/orgs_data\/(.*?)\//)[0];
my $pf= "../orgs_data/"."$prefix"."/";
my $date= ($rfile=~/goan_(.*?)\./)[0];

## dereference the ref to the hash
my %ann = %{$annref};

my $fileout= "$pf"."$prefix"."_spec_ann_"."$date.txt";

open OUT, "> $fileout";
foreach my $g (sort{$a cmp $b} keys %ann){
    print OUT "$g $ann{$g}\n";
}

print "\n";
print "gene-term stat\n";
print "${$stat}\n";

my $span= time - $start;
$span = sprintf("%.4f", $span);
print "elapsed time:\t$span seconds\n";

