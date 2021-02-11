#!/usr/bin/perl

use strict;
use warnings;
no warnings 'uninitialized'; ## avoid warnings in fastafile
use PerlIO::gzip;
use Time::HiRes qw(time);

my $start= time;

my $fileheader=shift;
my $filefasta=shift;
my $uniprotkb=shift; ## swiss or trembl

my %header=();
open IN, $fileheader;
while(<IN>){
    chop $_;
    $header{$_}=1;
}
close IN;
# foreach my $k (keys %header){print "$k $header{$k}\n";}

my $prefix= ($fileheader=~/\/orgs_data\/(.*?)\//)[0]; ## match taxon_orgs
my $pf= "../orgs_data/"."$prefix"."/";
my $date= ($fileheader=~/unmapped_(.*?)\./)[0]; ## match date

my $status=0;
my %headerescued=();

open IN, "<:gzip", $filefasta;
open OUT, "> $pf"."$prefix"."_"."$uniprotkb"."_unmapped_"."$date.fasta";
while(<IN>){
    my @letters= split(//,$_);
    my @vals= split(/\>/,$_);
    my @prac= split(/\|/, $vals[1]);
    if($letters[0] eq '>' && $header{$prac[1]}){
    	$status=1;
    	$headerescued{$prac[1]}=1;
    }
    if($letters[0] eq '>' && !$header{$prac[1]}){
    	$status=0;
    }
    if($status==1){
    	print OUT "$_";
    }
}
close IN;
close OUT;
# foreach my $k (keys %headerescued){print "$k $headerescued{$k}\n";}

open IN, "> $fileheader";
foreach my $k (sort{$a cmp $b} keys %header){
    if(!$headerescued{$k}){
    	print IN "$k\n";
    }
}
close IN;

my $span= time - $start;
my $sec= sprintf("%.4f", $span);
my $min= sprintf("%.4f", $sec/60);
my $hou= sprintf("%.4f", $min/60);
print "elapsed Time:\t$sec seconds | $min minutes | $hou hours\n";

