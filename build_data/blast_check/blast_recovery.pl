#!/usr/bin/perl

use strict;
use warnings;

my $fileblasthacked=shift;
open FH, "$fileblasthacked";

my %uniac2string=();
while(<FH>){
    chomp;
    my @vals=split(/\t/,$_);
    my @uniprot=split(/\|/,$vals[0]);
    my $ac=$uniprot[1];
    my $sid=$vals[1];
    if($vals[2] eq "100.000"){
        next if exists $uniac2string{$ac};
        $uniac2string{$ac}=$sid;
    }
}
close FH;
foreach my $k (sort{$a cmp $b} keys %uniac2string){print "$k\t$uniac2string{$k}\n";}

