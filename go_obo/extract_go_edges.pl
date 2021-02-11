#!/usr/bin/perl

use obogaf::parser;

my $obofile= "go-basic.obo";
my $goedges= "go.edges.txt";

my $gores= obogaf::parser::build_edges($obofile);
open OUT, "> $goedges";
print OUT "${$gores}"; ## dereferencing
close OUT;

my ($goedges, $parentIndex, $childIndex)= ("go.edges.txt", 1, 2);
my $res= obogaf::parser::make_stat($goedges, $parentIndex, $childIndex);
print "$res";

my @domains= qw(biological_process molecular_function cellular_component);
my %aspects=(biological_process => "bp", molecular_function => "mf", cellular_component => "cc");

foreach my $domain (@domains){
    my $outfile= "go.edges."."$aspects{$domain}".".txt";
    open OUT, "> $outfile";
    my $domainres= obogaf::parser::build_subonto($goedges, $domain);
    print OUT "${$domainres}";
    close OUT;
}

