#!/usr/bin/perl

## fetch fasta from header. Header can be either string or uniprotac

## call:
## perl fasta-fetcher.pl string.header 6239_caeel_protein_sequences_v11.0.fa > string.fasta
## perl fasta-fetcher.pl uniprot.header 6239_caeel_uniprot_unmapped_16jun20.fasta > uniprot.fasta

use strict;
use warnings;
no warnings 'uninitialized';

my $fileheader=shift;
my $filefasta=shift;

my %header=();;
open FH, $fileheader;
while(<FH>){
    if($fileheader=~/uniprot/){chomp;} ## that's weird but necessary to make
    $header{$_}=1;
}
close FH;

my $status=0;
my $id="";
open FH, $filefasta;
while(<FH>){
    my @letters= split(//,$_);
    my @vals= split(/\>/,$_);
    if($vals[1]=~/^\d+./){  ## string header starts with digit, uniprotac not
        $id= $vals[1];
    }else{
        $id=(split(/[\|,\s+]/,$vals[1]))[1];
    }
    if($letters[0] eq '>' && $header{$id}){
        $status=1;
    }
    if($letters[0] eq '>' && !$header{$id}){
        $status=0;
    }
    if($status==1){
       if($_=~/>/){
            if($vals[1]!~/^\d+./){
                my @tmp= split(/[\|,\s+]/, $vals[1]);
                print ">$tmp[1]\n";
            }else{
                print "$_";
            }
        }else{
            print "$_";
        }
    }
}
close FH;

