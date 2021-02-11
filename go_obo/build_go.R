#!/usr/bin/Rscript

# script to construct the GO graph and to build the list of ancestors

library("HEMDAG");

## build go graph
edges.file <- "go.edges.txt";
go.edges <- read.csv(edges.file, sep='\t');
go.edges <- go.edges[,2:3];
tmpdir <- paste0(tempdir(),"/");
write.table(go.edges, file=paste0(tmpdir, "go.edges.tmp.txt"), quote=FALSE, row.names=FALSE, col.names=FALSE);
edges.file <- paste0(tmpdir, "go.edges.tmp.txt")
g <- read.graph(edges.file);
save(g, file=paste0("go.univ.rda"), compress=TRUE);

## build go bp, mf, cc graph
subontos <- c("bp","mf","cc");
for(subonto in subontos){
    edges.file <- paste0("go.edges.",subonto,".txt");
    go.edges <- read.csv(edges.file, sep='\t');
    go.edges <- go.edges[,1:2];
    write.table(go.edges, file=paste0(tmpdir,"go.edges.",subonto,".tmp.txt"), quote=FALSE, row.names=FALSE, col.names=FALSE);
    edges.file <- paste0(tmpdir, "go.edges.",subonto,".tmp.txt");
    g <- read.graph(edges.file);
    save(g, file=paste0("go.",subonto,".univ.rda"), compress=TRUE);
}

## build list of ancestors for each go domain
for(subonto in subontos){
    go.univ <- get(load(paste0("go.",subonto,".univ.rda")));
    goanc <- build.ancestors(go.univ);
    save(goanc, file=paste0("go.",subonto,".ancestor.rda"), compress=TRUE);
}

quit(save="no");

