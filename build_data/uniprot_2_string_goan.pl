#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(time);

my $start=time;

my $filemapping=shift;
## NB: we cannot use PerlIO::gzip here. From docs: PerlIO::gzip provides a PerlIO layer that manipulates files in the format used by the gzip program. Compression and Decompression are implemented, but not together. If you attempt to open a file for reading and writing the open will fail. This means that if we appended lines to a zipped file these lines are *ignored* by PerlIO::gzip, unless we unzipped and zipped again the file. Conclusion: PerlIO::gzip is dummy.. To avoid this issue we must use gunzip instead ..
if($filemapping=~/.gz$/){open IN, "gunzip -c $filemapping |";}else{open IN, "$filemapping";}

my %uniprac2stringid=();
while(<IN>){
    chop $_;
    my @vals= split(/\t/,$_);
    my $ac=$vals[0];
    my $db=$vals[1];
    my $id= $vals[2];
    if($db eq 'STRING'){
        $uniprac2stringid{$ac}=$id;
    }
}
close IN;
# foreach my $k (keys %uniprac2stringid){print "$k $uniprac2stringid{$k}\n";}

my $filegoa=shift;
if($filegoa=~/.gz$/){open IN, "<:gzip", $filegoa;}else{open IN, $filegoa;} ## "gunzip -c $filegoa |"
my $prefix= ($filegoa=~/\/orgs_data\/(.*?)\//)[0]; ## match taxon_orgs
my $pf= "../orgs_data/"."$prefix"."/";
my $date= ($filegoa=~/goan_(.*?)\./)[0]; ## match date

open OUT, "> $pf"."$prefix"."_string_2_uniprot_goan_"."$date.txt";
my $pr="";
my %acseen=();
my %prmapped=();
my %GOterms=();
my %GOmapped=();
while(<IN>){
    chomp;
    my @vals=split(/\t/,$_);
    my $ac=$vals[0];
    $GOterms{$vals[1]}=1;
    if($uniprac2stringid{$ac}){
        $pr=$uniprac2stringid{$ac};
    }else{
        $pr= "NOTSEEN";
    }
    if($pr ne "NOTSEEN"){
        print OUT "$pr\t$ac\t$vals[1]\t$vals[2]\t$vals[3]\n";
        $prmapped{$pr}=1;
        $GOmapped{$vals[1]}=1;
    }
    # print OUT "$pr\t$ac\t$vals[1]\t$vals[2]\t$vals[3]\n";
    $acseen{$ac}=$pr;
}
close IN;
close OUT;

my $totACseen= keys %acseen;
my $totPRmapped= 0;
# may verify a multiple mapping between stringID 2 uniprotAC.. more secure counting as below
# my $totPRmapped= keys %prmapped;
# my $totACnotseen= $totACseen - $totPRmapped;
open OUT, "> $pf"."$prefix"."_uniprot_unmapped_"."$date.txt";
foreach my $k (sort{$a cmp $b} keys %acseen){
    if($acseen{$k} eq "NOTSEEN"){
        print OUT "$k\n";
    }elsif($acseen{$k} ne "NOTSEEN"){
        $totPRmapped++;
    }
}
close OUT;

my $totACnotseen= $totACseen - $totPRmapped;
my $totGOterms= keys %GOterms;
my $totGOmapped= keys %GOmapped;

print "tot. uniprot-ac associated with an exp. go term:\t$totACseen\n";
print "tot. unique exp. go terms associated with uniprot-ac protein:\t$totGOterms\n";
print "tot. unique exp. go terms associated with a string mapped protein:\t$totGOmapped\n";
print "tot. string proteins mapped with uniprot-ac:\t$totPRmapped\n";
print "tot. string proteins not-mapped with uniprot-ac:\t$totACnotseen\n";

my $span= time - $start;
$span = sprintf("%.4f", $span);
print "elapsed time:\t$span seconds\n";

