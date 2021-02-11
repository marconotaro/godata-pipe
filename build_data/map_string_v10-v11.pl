#!/usr/bin/perl

use strict;
use warnings;
use PerlIO::gzip;

my $start= time;

my $stringmapfile= shift;
my %stringmap=();

## map string id, from v10 --> v11
open FH, "<:gzip", $stringmapfile;
while(<FH>){
    chomp;
    my @vals= split(/\t/,$_);
    my $stringv10=(split(/\./,$vals[1],2))[1]; ## array slices on-the-fly
    my $stringv11=(split(/\./,$vals[2],2))[1]; ## array slices on-the-fly
    $stringmap{$stringv10}=$stringv11; ## v10 --> v11 map
}
close FH;
# foreach my $k (keys %stringmap){ print "$k\t$stringmap{$k}\n";}

## replace in the historical goa file string id, from v10 --> v11
my $goaoldfile= shift;
open FH, $goaoldfile;
while(<FH>){
    chomp;
    my @vals= split(/\t/,$_);
    if($stringmap{$vals[0]}){
        print join ("\t", $stringmap{$vals[0]}, @vals[1..$#vals]), "\n";  ## long form: print "$stringmap{$vals[0]}\t$vals[1]\t$vals[2]\t$vals[3]\n";
    }else{
        print "$_\n";
    }
}
close FH;

