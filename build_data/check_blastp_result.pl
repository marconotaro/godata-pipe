#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(time);

my $start= time;

# issue1: we may have more uniprot-ac for a string-id with 100% of identity (isoform);
# solution: we can use string ID as key to map all the uniprot-ac
my $fileblast=shift;
open IN, "$fileblast";
my %string2uniac=();
while(<IN>){
    chomp;
    my @vals=split(/\t/,$_);
    my @uniprot=split(/\|/,$vals[0]);
    my $ac=$uniprot[1];
    my $sid=$vals[1];
    if($vals[2] eq "100.000"){
        $string2uniac{$sid}=$ac;
    }
}
close IN;
# foreach my $k (keys %string2uniac){print "$k\t$string2uniac{$k}\n";}

# issue2: at the end we need to map uniprot-ac 2 string-id, then we should use uniprot-ac as key.. so which string-id we should consider?
# if we have more string-id (issue1) for the same uniprot-ac might happen that one of those string-id is already annotated
# for a GO term and then we already have a corresponding uniprot-ac.. the idea is to associate the uniprot-ac with the "unannotated" string-id.
# to this end we hacked the blastp results file adding a star to each "100.00" every time that the string-id already exists in the annotation file.
# in this way we consider the second choice at 100% of identity if the first already exist, or the third if the first two already exist (and so on)
my $filegoa= shift;
my %stringan=();
open IN, "$filegoa";
while(<IN>){
    chomp;
    my @vals=split(/\t/,$_);
    $stringan{$vals[0]}=1;
}
close IN;
# foreach my $k (keys %stringan){print "$k\t$stringan{$k}\n"};

my %stringstr=();
foreach my $k (keys %string2uniac){
    if($stringan{$k}){
        $stringstr{$k}=1;
    }
}
# foreach my $k (keys %stringstr){print "$k $stringstr{$k}\n"};

open IN, "$fileblast";
open OUT, "> $fileblast."."hacked";
while(<IN>){
    chomp;
    my @vals=split(/\t/,$_);
    if($vals[2] eq "100.000" && $stringstr{$vals[1]}){
        my $tmp="*100.000";
        print OUT "$vals[0]\t$vals[1]\t$tmp\t$vals[3]\t$vals[4]\t$vals[5]\n";
    }else{
        print OUT "$_\n";
    }
}
close IN;

my $span= time - $start;
$span = sprintf("%.4f", $span);
print "elapsed time:\t$span seconds\n";

