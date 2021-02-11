## call: Rscript build_spec_ann_matrix.R ../orgs_data/6239_caeel/6239_caeel_spec_ann_20dec17.txt

library(HEMDAG);
args <- commandArgs(trailingOnly=TRUE);

filename <- strsplit(args[1],"[/,_,.]");
taxon <- filename[[1]][6];
org <-  filename[[1]][7];
date <- filename[[1]][12];
pf <- paste0("../orgs_data/",taxon,"_",org,"/");

start <- proc.time();
spec.ann.file <- args[1];
spec.ann <- specific.annotation.matrix(spec.ann.file);
save(spec.ann, file=paste0(pf,taxon,"_",org,"_spec_ann_",date,".rda"), compress=TRUE);
end <- proc.time() - start;

cat("done: annotation matrix built\n");
cat("elapsed time:", end["elapsed"],"\n");
quit(save="no");

