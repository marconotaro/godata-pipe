#!/usr/bin/perl

use strict;
use warnings;
use PerlIO::gzip;
use File::Copy;
use Time::HiRes qw(time);

my $start= time;

## here we check that the picked couple of identifiers blast recovered does not exist in the GOA mapping file
my $fileblasthacked=shift;
open IN, "$fileblasthacked";
my %uniac2string=();
while(<IN>){
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
close IN;
# foreach my $k (sort{$a cmp $b} keys %uniac2string){print "$k\t$uniac2string{$k}\n";}

my $filemap=shift;
my $prefix= ($filemap=~/\/orgs_data\/(.*?)\//)[0]; ## match taxon_orgs
my $pf= "../orgs_data/"."$prefix"."/";
my $date= ($filemap=~/idmapping_(.*?)\./)[0]; ## match date
my $filein= "$pf"."$prefix"."_idmapping_"."$date.dat.gz";
my $fileout= "$pf"."$prefix"."_idmapping_enriched_"."$date.dat.gz";

copy($filein, $fileout); # or system "cp $filein $fileout";
open OUT, ">>:gzip", $fileout; ## or "| gzip -c >> $fileout";
foreach my $k (sort{$a cmp $b} keys %uniac2string){
    print OUT "$k\tSTRING\t$uniac2string{$k}\n";
}
close OUT;

my $span= time - $start;
$span = sprintf("%.4f", $span);
print "elapsed time:\t$span seconds\n";

