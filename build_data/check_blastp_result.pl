#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(time);

my $start= time;

# issue1: we may have more uniprot-ac for a string-id with 100% of identity
# solution: we can use string-id as key to map all the uniprot-ac
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

# issue2: the final goal is to map uniprot-ac towards string-id, then we should use uniprot-ac as key. which string-id we should consider?
# solution: we can associate the uniprot-ac with the "GO unannotated" string-id. to this end we 'hacked' the blastp results file adding a star
# to each "100.00" every time that the string-id already exists in the GOA annotation file. in this way we consider the second choice at 100% of
# identity if the first already exist, or the third if the first two already exist (and so on)
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

## NB: in `blast_enrichment.pl` we check that the picked couple of identifiers blast recovered does not exist in the GOA mapping file
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

