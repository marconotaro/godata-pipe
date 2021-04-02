#!/usr/bin/perl

## call: perl fasta-length.pl | sort -nk 2 | cut 2-

use strict;
use warnings;

my $curlen=0;
my @vals=();
while(<>){
    chop $_;
    if($.==1){ print "$_\t"; next;}
    @vals=split(//,$_);
    if($vals[0] eq '>'){
        if($curlen>0){
            print "$curlen\n";
            $curlen=0;
            print "$_\t";
        }
    }else{
        $curlen+= ($#vals+1);
    }
}
if($curlen!=0){ print "$curlen\n"; }

