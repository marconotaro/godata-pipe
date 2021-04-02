#!/usr/bin/perl

use strict;
use warnings;
use Time::HiRes qw(time);

my $start= time;

## goal
## - build the string p2p network and the matrix of the most specific annotation (from GOA db).
## - map the annotation from uniprotAC to stringID by using mapping file provided by GOA db
## - limit as much as possible the number of the unmapped identifiers, we blast the unmapped
##   identifiers against swiss and trembl db and we recover the identifiers having 100% of similarity.
##   the couple of identifiers retrieved must not exist in the mapping file provided by GOA db.

## organism nomenclature link: http://www.uniprot.org/help/taxonomy#organism-denomination
##    taxon: ncbi taxon ID. It can be one of the following values: 3702, 6239, 9031, 7955, 44689, 7227, 9606, 10090, 10116, 559292
##    org: the organism identification code of at most 5 alphanumeric characters used as entry species name in th UniProtKB database.
##       It can be one of the following values: arath, caeel, chick, danre, dicdi, drome, human, mouse, rat, yeast
##    release: date of the *latest* UniProt-GOA release as reported in 'https://www.ebi.ac.uk/GOA#news'
##       It can be written in the following format: <DD><MMM><YY> (eg: 20dec17);
##    stringv: the *current* release version of STRING DB as reported in 'https://string-db.org/cgi/access.pl?footer_active_subpage=archive'
##       It can be written in the following format: v<string.version> (eg: v10.5);

## NOTA: obviously 'taxon' 'org' parameters can be related each other. So just the following parameters combinations are possible:
##  3702 arath
##  6239 caeel
##  9031 chick
##  7955 danre
##  44689 dicdi
##  7227 drome
##  9606 human
##  10090 mouse
##  10116 rat
##  559292 yeast

## How to call the perl script, an example: perl call_pipe.pl 6239 caeel 16jun20 v11.0

my $taxon= shift;
my $org= shift;
my $release= shift;
my $stringv= shift;
my $prefix= "$taxon"."_"."$org";
my $pf= "../orgs_data/"."$prefix"."/"; ## note: do not touch the path

print "start data construction: $prefix\n";

print "step_0\n goal: extract experimental go annotation\n\n";
system "perl extract_exp_goan.pl $pf"."$prefix"."_uniprot_goan_$release.gaf.gz";
print "output file: $pf"."$prefix"."_uniprot_goan_$release.txt\n";
print "step_0 done\n\n";

print "step_1\n goal: map protein having at least an experimental go term annotation from uniprot-ac to string-id\n\n";
system "perl uniprot_2_string_goan.pl $pf"."$prefix"."_idmapping_$release.dat.gz $pf"."$prefix"."_uniprot_goan_$release.txt";
print "output files\n 1) $pf"."$prefix"."_string_2_uniprot_goan_$release.txt;\n 2) $pf"."$prefix"."_uniprot_unmapped_$release.txt\n";
print "step_1 done\n\n";

## steps 2.1 and 2.2 take a while (especially the latter)
print "step_2\n goal: annotation file enrichment: map the unmapped go-annotated string proteins blasting them against swiss and trembl dbs\n\n";
print "2.1) extract fasta sequence from swiss db of unmapped protein\n";
system "perl extract_fasta_by_header.pl $pf"."$prefix"."_uniprot_unmapped_$release.txt ../uniprot/uniprot_sprot.fasta.gz swiss";
print "output file: $pf"."$prefix"."_swiss_unmapped_$release".".fasta\n\n";

print "2.2) extract fasta sequence from trembl db of unmapped protein not found in swiss db\n";
system "perl extract_fasta_by_header.pl $pf"."$prefix"."_uniprot_unmapped_$release.txt ../uniprot/uniprot_trembl.fasta.gz trembl";
print "output file: $pf"."$prefix"."_trembl_unmapped_$release.fasta\n\n";

print "2.3) join swiss and trembl fasta sequence\n";
system "cat $pf"."$prefix"."_swiss_unmapped_$release.fasta $pf"."$prefix"."_trembl_unmapped_$release.fasta > $pf"."$prefix"."_uniprot_unmapped_$release.fasta";
print "output file: $pf"."$prefix"."_uniprot_$release.fasta\n\n";

print "2.4) make string fasta sequences as blast db..";
system "makeblastdb -in $pf"."db/$prefix"."_protein_sequences_"."$stringv.fa -dbtype 'prot' -parse_seqids -hash_index -out $pf"."/db/$org -title $pf"."db/$org";
print "string db in $pf"."db folder\n\n";

print "2.5) blast to rescue unmapped string proteins..\n";
system "blastp -query $pf"."$prefix"."_uniprot_unmapped_$release".".fasta -db $pf"."/db/$org -outfmt '6 qseqid sseqid pident evalue bitscore score' -num_threads 8 -out $pf"."$prefix"."_blastp_results.out";
print "output file: $pf"."$prefix"."_blastp_results.out\n\n";

print "2.6) check if the best returned blast hit already exists in the annotation file. if exists we take the second best hit (and so on)\n";
system "perl check_blastp_result.pl $pf"."$prefix"."_blastp_results.out $pf"."$prefix"."_string_2_uniprot_goan_$release.txt";
print "output file: $pf"."$prefix"."_blastp_results.out.hacked\n\n";

print "2.7) blast enrichment\n";
system "perl blast_enrichment.pl $pf"."$prefix"."_blastp_results.out.hacked $pf"."$prefix"."_idmapping_$release.dat.gz";
print "output file: $pf"."$prefix"."_idmapping_enriched_$release.dat.gz\n";
print "step_2 done\n\n";

print "step_3\ngoal: map protein having an experimental go term annotation from uniprot-ac to string-id using the enriched mapping file\n\n";
system "perl uniprot_2_string_goan.pl $pf"."$prefix"."_idmapping_enriched_$release.dat.gz $pf"."$prefix"."_uniprot_goan_$release.txt";
print "output file\n 1) $pf"."$prefix"."_string_2_uniprot_goan_$release".".txt;\n 2) $pf"."$prefix"."_uniprot_unmapped_$release".".txt\n";
print "step_3 done\n\n";

print "step_4: parse annotation file splitting taxon from string id\n";
system "perl parse_string_exp_goan.pl $pf"."$prefix"."_string_2_uniprot_goan_$release.txt";
print "output file: $pf"."$prefix"."_string_goan_$release.txt\n";
print "step_4 done\n\n";

print "step_5: build specific annotation list. for each protein we associate all its go terms. input file format to build the specific annotation matrix\n";
system "perl build_spec_ann_list.pl $pf"."$prefix"."_string_goan_$release.txt";
print "output file: $pf"."$prefix"."_spec_ann_$release".".txt\n";
print "step_5 done\n\n";

print "step_6: build the specific annotation matrix\n";
system "Rscript build_spec_ann_matrix.R $pf"."$prefix"."_spec_ann_$release.txt";
print "output file: $pf"."$prefix"."_spec_ann_$release".".rda\n";
print "step_6 done\n\n";

print "step_7: make string net: we split taxon from string id\n";
system "perl remove_string_taxon.pl $pf"."$prefix"."_protein_links_"."$stringv.txt.gz";
print "output file: $pf"."$prefix"."_string_"."$stringv.txt.gz\n";
print "step_7 done\n\n";

print "step_8: build $prefix string network\n";
system "Rscript build_string.R $pf"."$prefix"."_string_"."$stringv.txt.gz";
print "output file: $pf"."$prefix"."_string_"."$stringv.rda\n";
print "step_8 done\n\n";

my $span= time - $start;
my $sec= sprintf("%.4f", $span);
my $min= sprintf("%.4f", $sec/60);
my $hou= sprintf("%.4f", $min/60);
print "$prefix elapsed time:\t$sec seconds | $min minutes | $hou hours\n";

print "job done\n";
print "end data construction: $prefix\n\n";

