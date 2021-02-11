#!/usr/bin/perl

use strict;
use warnings;
use obogaf::parser;
use Time::HiRes qw(time);

my $start= time;

my $annfile= shift;
my $prefix= ($annfile=~/\/orgs_data\/(.*?)\//)[0]; ## match taxon_orgs
my $pf= "../orgs_data/"."$prefix"."/";
my $date= ($annfile=~/goan_(.*?)\./)[0]; ## match date

my ($annref, $stat)= obogaf::parser::gene2biofun($annfile, 0, 1);

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

