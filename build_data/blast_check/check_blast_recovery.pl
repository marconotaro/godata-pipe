#!/usr/bin/perl

use strict;
use warnings;

my $filestringaa=shift;
my $fileuniprotgaa=shift;
my $fileblasthacked=shift;

## string => aa
my %stringaa;
open FH, "$filestringaa";
while(<FH>){
    chomp;
    my @vals=split(/\s+/,$_);
    $stringaa{$vals[0]}=$vals[1];
}
close FH;
# foreach my $k (keys %stringaa){print "$k $stringaa{$k}\n";}

## uniprot => aa
my %uniprotgaa;
open FH, "$fileuniprotgaa";
while(<FH>){
    chomp;
    my @vals=split(/\s+/,$_);
    $uniprotgaa{$vals[0]}=$vals[1];
}
close FH;
# foreach my $k (keys %uniprotgaa){print "$k $uniprotgaa{$k}\n";}

## retrieve map uniprot => string
open FH, "$fileblasthacked";
my %uniac2string=();
my %uniid2string=();
while(<FH>){
    chomp;
    my @vals=split(/\t/,$_);
    my @uniprot=split(/\|/,$vals[0]);
    my $ac=$uniprot[1];
    my $id=$uniprot[2];
    my $sid=$vals[1];
    if($vals[2] eq "100.000"){
        next if exists $uniac2string{$ac};
        $uniac2string{$ac}=$sid;
        $uniid2string{$ac}=$id;
    }
}
close FH;

my $tot=0;
my $mistake=0;
foreach my $k (sort{$a cmp $b} keys %uniac2string){
    if($uniprotgaa{$k} ne $stringaa{$uniac2string{$k}}){
        $mistake++;
        print "$k|$uniid2string{$k}\t$uniprotgaa{$k}\t$uniac2string{$k}\t$stringaa{$uniac2string{$k}}\t!mismatch!\n";
    }else{
        print "$k|$uniid2string{$k}\t$uniprotgaa{$k}\t$uniac2string{$k}\t$stringaa{$uniac2string{$k}}\n";
    }
    $tot++;
}
my $right= $tot-$mistake;

print "\n\n";
print "recovered blasted proteins with 100\% of similarity:\t$tot\n";
print "recovered blasted proteins with a shift in aa     :\t$mistake\n";
print "recovered blasted proteins without a shift in aa  :\t$right\n";

