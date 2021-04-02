#!/usr/bin/perl

use strict;
use warnings;
use File::Path qw(make_path);  ## recursively create directories ([-p] mkdir option in perl does not work T_T)
use File::Copy qw(move);
use IO::Uncompress::Gunzip qw(gunzip $GunzipError) ;
use Time::HiRes qw(time);

my $start= time;

## organism nomenclature link: http://www.uniprot.org/help/taxonomy#organism-denomination
##    taxon: NCBI taxonID. It can be one of the following:
##         3702, 6239, 9031, 7955, 44689, 7227, 9606, 10090, 10116, 559292
##    org: the organism identification code of at most 5 alphanumeric characters used as entry species name in the UniProtKB database.
##       It can be one of the following:
##       arath, caeel, chick, danre, dicdi, drome, human, mouse, rat, yeast
##    com: common organism name. It can be one of the following:
##       arabidopsis, worm, chicken, zebrafish, dicty, fly, human, mouse, rat, yeast
##    release: date of the *latest* release of the gene annotation file and the corresponding UniProtKB identifier mapping file
##       It can be written in the following format: <DD><MMM><YY> (eg: 20dec17);
##    stringv: the *current* release version of STRING DB as reported in 'https://string-db.org/cgi/access.pl?footer_active_subpage=archive'
##       It can be written in the following format: v<string.version> (eg: v11.0);

##    NB: 'taxon', 'org' and 'com' parameters must be related. In other words, the following combinations are possible:
##  3702 arath arabidopsis
##  6239 caeel worm
##  9031 chick chicken
##  7955 danre zebrafish
##  44689 dicdi dicty
##  7227 drome fly
##  9606 human human
##  10090 mouse mouse
##  10116 rat rat
##  559292 yeast yeast

## call the perl script, an example: perl download_data.pl 6239 caeel worm 16jun20 v11.0
my $taxon= shift;
my $org= shift;
my $com= shift;
my $release= shift;
my $stringv= shift;
my $prefix= "$taxon"."_"."$org";
my $pf= "../orgs_data/$prefix/";

## create a folder for storing data if it does not exist
make_path($pf) unless(-d $pf);

## download files
print "start download files "."$prefix\n";

## download uniprot id-mapping
system "wget ftp://ftp.ebi.ac.uk/pub/databases/uniprot/current_release/knowledgebase/idmapping/by_organism/".uc($org)."_"."$taxon"."_idmapping.dat.gz -O $pf"."$prefix"."_idmapping_$release".".dat.gz -a log";

## download uniprot-go annotation file
system "wget ftp://ftp.ebi.ac.uk/pub/databases/GO/goa/".uc($com)."/goa_"."$com.gaf.gz -O $pf"."$prefix"."_uniprot_goan_$release".".gaf.gz -a log ";

## download string network and string fasta file
if($taxon eq "559292"){$taxon = "4932"};
system "wget --wait=10 --random-wait https://stringdb-static.org/download/protein.links.$stringv/$taxon".".protein.links.$stringv.txt.gz -O $pf"."$prefix"."_protein_links_"."$stringv.txt.gz -a log";
system "wget --wait=10 --random-wait https://stringdb-static.org/download/protein.sequences.$stringv/$taxon".".protein.sequences.$stringv.fa.gz -O $pf"."$prefix"."_protein_sequences_"."$stringv.fa.gz -a log";

# create a db folder and unzip fasta file
make_path("$pf"."db/") unless(-d "$pf"."db/");
move("$pf"."$prefix"."_protein_sequences_"."$stringv.fa.gz", "$pf"."db/");
chdir("$pf"."db/");
gunzip "$prefix"."_protein_sequences_"."$stringv.fa.gz" => "$prefix"."_protein_sequences_"."$stringv.fa";

print "end downlaod files "."$prefix\n";

my $span= time - $start;
my $sec= sprintf("%.4f", $span);
my $min= sprintf("%.4f", $sec/60);
my $hou= sprintf("%.4f", $min/60);
print "$prefix elapsed time:\t$sec seconds | $min minutes | $hou hours\n";

