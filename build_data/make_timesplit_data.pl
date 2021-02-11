#!/usr/bin/perl

## before running this script put in the organism folder the needed data:
## 1. text file of the old annotations
## 2. text file of the old annotations
## 3. string network

## example of call: perl make_timesplit_data.pl 6239 caeel 20dec17 16jun20 v10.5 v11.0

use strict;
use warnings;
use Time::HiRes qw(time);

my $start= time;

my $taxon= shift;
my $org= shift;
my $historical= shift;
my $recent= shift;
my $stringold= shift;
my $stringnew= shift;
my $prefix= "$taxon"."_"."$org";
my $pf= "../orgs_data/"."$prefix"."/"; ## note: do not touch the path

## only for step 0 -> string for mapping file use v10 and v11 and not v10.5 and v11.0 as in protein links file and fasta file ...
my $soldtrk= (split(/\./,$stringold))[0];
my $snewtrk= (split(/\./,$stringnew))[0];

print "start construction hold-out data:\n";
print "organism: $prefix\n\n";

print "step_0: map string id, from $stringold --> $stringnew\n";
system "perl map_string_v10-v11.pl ../orgs_data/string_map/goexp_orgs_"."$soldtrk"."_"."$snewtrk.tsv.gz $pf"."$prefix"."_string_goan_"."$historical.txt > $pf"."$prefix"."_string_goan_"."$historical"."_string_"."$stringold"."-"."$stringnew.txt";
print "output file: $pf"."$prefix"."_string_goan_"."$historical"."_string_"."$stringold"."-"."$stringnew.txt\n";
print "step_0: done\n\n";

print "step_1: map go term between release -- from historical to recent\n";
system "perl map_historical_2_recent.pl ../go_obo/go-basic.obo $pf"."$prefix"."_string_goan_"."$historical"."_string_"."$stringold"."-"."$stringnew.txt $historical $recent";
print "output file: $pf"."$prefix"."_string_goan_"."$historical"."-"."$recent".".txt\n";
print "step_1: done\n\n";

print "step_2: isolate new annotated proteins\n";
system "perl recent_proteins.pl $pf"."$prefix"."_string_goan_"."$historical"."-"."$recent".".txt $pf"."$prefix"."_string_goan_$recent.txt";
print "output file: $pf"."$prefix"."_string_goan_noknowledge_"."$recent".".txt\n";
print "step_2: done\n\n";

print "step_3: build most specific annotations list for historical annotations\n\n";
system "perl build_spec_ann_list_historical.pl $pf"."$prefix"."_string_goan_"."$historical"."-"."$recent".".txt";
print "output file: $pf"."$prefix"."_spec_ann_"."$historical"."-"."$recent".".txt\n";
print "step_3: done\n\n";

print "step_4: build most specific annotations list for recent annotations\n\n";
system "perl build_spec_ann_list_recent.pl $pf"."$prefix"."_string_goan_noknowledge_"."$recent".".txt";
print "output file: $pf"."$prefix"."_spec_ann_noknowledge_"."$recent.txt\n";
print "step_4: done\n\n";

print "step_5: build time splitting data: training on $historical annotation and test on $recent annotation\n";
system "Rscript build_timesplit_data.R $taxon $org $historical $recent $stringnew\n";
print "in $pf"."$prefix for each go sub-ontology (bp,mf,cc):\n";
print "1) dag file: $taxon"."_"."$org"."_go_<onto>_dag_"."$stringnew"."_"."$historical"."_"."$recent".".rda\n";
print "2) annotation file: $taxon"."_"."$org"."_go_<onto>_ann_"."$stringnew"."_"."$historical"."_"."$recent".".rda\n";
print "3) string file: $taxon"."_"."$org"."_go_<onto>_string_"."$stringnew"."_"."$historical"."_"."$recent".".rda\n";
print "4) testindex file: $taxon"."_"."$org"."_go_<onto>_testindex_"."$stringnew"."_"."$historical"."_"."$recent".".rda\n";
print "step_5: done\n\n";

my $span= time - $start;
my $sec= sprintf("%.4f", $span);
my $min= sprintf("%.4f", $sec/60);
my $hou= sprintf("%.4f", $min/60);
print "$prefix elapsed time:\t$sec seconds | $min minutes | $hou hours\n";

print "job done\n";
print "end data construction: $prefix\n\n";

