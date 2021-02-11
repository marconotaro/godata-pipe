#!/usr/bin/perl

use strict;
use warnings;
use obogaf::parser;
use Time::HiRes qw(time);

my $start= time;

my $obofile= shift;
my $oldgoa= shift;
my $historical= shift; ## compatibility with make_timesplit_dta.pl
my $recent= shift; ## compatibility with make_timesplit_dta.pl
my $classindex= 1;

my $prefix= ($oldgoa=~/\/orgs_data\/(.*?)\//)[0]; ## match taxon_orgs
my $pf= "../orgs_data/"."$prefix"."/";

my ($res, $stat)= obogaf::parser::map_OBOterm_between_release($obofile, $oldgoa, $classindex);

my $mapfile= "$pf"."$prefix"."_string_goan_"."$historical"."-"."$recent".".txt";

open  OUT, "> $mapfile";
print OUT "${$res}";
close OUT;

print "${$stat}";

my $span= time - $start;
$span = sprintf("%.4f", $span);
print "elapsed time:\t$span seconds\n";

