#!/usr/bin/perl

use strict;
use warnings;
use PerlIO::gzip;
use Time::HiRes qw(time);

## extract GO Experimental Evidence Codes (http://geneontology.org/docs/guide-go-evidence-codes/)
my $start= time;

## file name: goa_worm.gaf
my $filegoa=shift;
if($filegoa=~/.gz$/){open IN, "<:gzip", $filegoa;}else{open IN, $filegoa;}

my $prefix= ($filegoa=~/\/orgs_data\/(.*?)\//)[0]; ## match taxon_orgs
my $pf= "../orgs_data/"."$prefix"."/";
my $date= ($filegoa=~/goan_(.*?)\./)[0]; ## match date
my $filetmp= "$pf"."$prefix"."_exp_goan_tmp.txt";
my $fileout= "$pf"."$prefix"."_uniprot_goan_"."$date.txt";

open OUT, "> $filetmp";
while (<IN>){
    if($.<13){next;}
    chop $_;
    my @vals= split(/\t/,$_);
    my $uniprotAC= $vals[1];
    my $GOterm= $vals[4];
    my $GOev= $vals[6];
    my $ontology= $vals[8];
    if($GOev=~ /^EXP$|^IDA$|^IPI$|^IMP$|^IGI$|^IEP$|^HTP$|^HDA$|^HMP$|^HGI$|^HEP$/){ ## evidence codes starts with H* are news
        print OUT "$uniprotAC\t$GOterm\t$GOev\t$ontology\n";
    }
}
close IN;
close OUT;

my %seen=();
open IN, "$filetmp";
open OUT, "> $fileout";
while(<IN>){
    $seen{$_}++;
    next if $seen{$_} > 1;
    print OUT;
}
close IN;
close OUT;
unlink $filetmp; ## or system "rm $filetmp";

my $span= time - $start;
$span = sprintf("%.4f", $span);
print "elapsed time:\t$span seconds\n";

