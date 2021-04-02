#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(time);

my $start=time;

my $hfile=shift;
my %prsold=();
open IN, $hfile;
while(<IN>){
    chomp;
    my @vals=split(/\t/,$_);
    $prsold{$vals[0]}=$vals[0];
}
close IN;

my $rfile=shift;
my %prs=();
my %prsbp=();
my %prsmf=();
my %prscc=();

my $prefix= ($rfile=~/\/orgs_data\/(.*?)\//)[0]; ## match taxon_orgs
my $pf= "../orgs_data/"."$prefix"."/";
## recent date
my $rdate= ($hfile=~/\-(.*?)\./)[0]; ## or my $rdate= (split(/[\-,\.]/,$hfile))[3];

open FH, $rfile;
open OUT, "> $pf"."$prefix"."_string_goan_noknowledge_"."$rdate".".txt";
while(<FH>){
    my @vals=split(/\s+/,$_);
    unless($prsold{$vals[0]}){
        $prs{$vals[0]}=1;
        print OUT $_;
        if($vals[3] eq "P"){
            $prsbp{$vals[0]}=1;
        }
        if($vals[3] eq "F"){
            $prsmf{$vals[0]}=1;
        }
        if($vals[3] eq "C"){
            $prscc{$vals[0]}=1;
        }
    }
}
close FH;
close OUT;

my $totprs= keys %prs;
my $totprbp= keys %prsbp;
my $totprmf= keys %prsmf;
my $totprcc= keys %prscc;

print "tot unique prs: $totprs\n";
print "prs bp: $totprbp\n";
print "prs mf: $totprmf\n";
print "prs cc: $totprcc\n";


my $span= time - $start;
$span = sprintf("%.4f", $span);
print "elapsed time:\t$span seconds\n";

