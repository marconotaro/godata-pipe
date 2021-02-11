#!/bin/sh
## call: bash make_graph.sh > out 2> /dev/null &

start=$(date +%s)

## NB: to download old go.obo file see http://release.geneontology.org/

echo "download the latest release of go obo file"
wget http://purl.obolibrary.org/obo/go/go-basic.obo -a log

echo "extract edges from obo file"
perl extract_go_edges.pl

echo "build go graph as object of class graphNEL"
Rscript build_go.R

end=$(date +%s)
printf "total elapsed time:\t$((end-start)) seconds\n"

