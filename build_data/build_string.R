library(HEMDAG);

args <- commandArgs(trailingOnly=TRUE);

file <- args[1];     #eg: "../orgs_data/6239_caeel/6239_caeel_string_v11.0.txt.gz";
x <- strsplit(file,"[/,_,.]");
taxon <- x[[1]][6];
org <- x[[1]][7];
stringv <- paste0(x[[1]][11],".",x[[1]][12]);
basefolder <- paste0("../orgs_data/",taxon,"_",org,"/");

if (!dir.exists(basefolder)){dir.create(basefolder);}
fileout <- paste0(basefolder,taxon,"_",org,"_string_",stringv,".rda");

start <- proc.time();
W <- weighted.adjacency.matrix(file=file);
save(W, file=paste0(fileout), compress=TRUE);
end <- proc.time() - start;

cat("done: string built\n");
cat("elapsed time:", end["elapsed"],"\n");
quit(save="no");

