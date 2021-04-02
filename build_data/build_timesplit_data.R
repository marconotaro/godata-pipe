## script to prepare raw hold out dataset

library(HEMDAG); ## graph utils functions
library(RBGL); ## dijkstra's shortest paths
library(plyr); ## rbind.fill.matrix

outerstart <- proc.time();

## input data
args <- commandArgs(trailingOnly=TRUE);
taxon <- args[1];
org <- args[2];
historical <- args[3];
recent <- args[4]
stringv <- args[5];
prefix <- paste0(taxon,"_",org);
pf <- paste0("../orgs_data/",prefix,"/");

## for testing
# taxon <- "6239";
# org <- "caeel";
# historical <- "20dec17";
# recent <- "16jun20";
# stringv <- "v11.0";
# prefix <- paste0(taxon,"_",org);
# pf <- paste0("../orgs_data/",prefix,"/");

## loading data ##
## loading full go dag including all subontologies
g.univ <- get(load("../go_obo/go.univ.rda"));
## specific annotation list with GO term mapped from old to new release (T)
T.ann.file <- paste0(pf,prefix,"_spec_ann_",historical,"-",recent,".txt");
## specific annotation list of the newest GO release (S)
S.ann.file <- paste0(pf,prefix,"_spec_ann_noknowledge_",recent,".txt");
## string p2p network
K <- get(load(paste0(pf,prefix,"_string_",stringv,".rda")));
cat("data loaded","\n");

## build T and S specific annotations matrix
T.ann <- specific.annotation.matrix(T.ann.file);
S.ann <- specific.annotation.matrix(S.ann.file);

## merge T and S annotation matrix
TS.ann <- rbind.fill.matrix(T.ann , S.ann);
rownames(TS.ann) <- c(rownames(T.ann), rownames(S.ann));
TS.ann[is.na(TS.ann)] <- 0;

## build full annotation matrix
# names of three sub-ontologies (NB: ontology domain and roots must be in the same order)
godivs <- c("bp","mf","cc");
roots <- c("GO:0008150","GO:0003674","GO:0005575");

for(i in 1:length(godivs)){
    start <- proc.time();
    cat("__start__", godivs[i], roots[i], sep="\t", "\n");
    ## transitive closure annotation matrix
    anc <- get(load(paste0("../go_obo/go.",godivs[i],".ancestor.rda")));
    ann <- full.annotation.matrix(K, anc, TS.ann);
    cat("status annotation matrix:", sep="\t", "\n");
    check.annotation.matrix.integrity(anc, TS.ann, ann);
    ## full graph
    nd <- colnames(ann);
    g <- build.subgraph(nd, g.univ);
    ## check if there are inconsistent node in the graph =>
    ## nodes belonging to a different ontology =>
    ## the lines below are useful for go.obo.. with go-basic.obo everything should be safe ..
    if(length(root.node(g))>1){
        cat("inconsistent nodes found and removed", "\n");
        dk.sp <- dijkstra.sp(g, start=roots[i])$distance;
        nd <- nd[which(dk.sp!=Inf)];
        g <- build.subgraph(nd, g.univ);
        ## remove inconsistent node to annotation matrix;
        ann <- ann[,nodes(g)];
    }
    cat("status graph:", sep="\t", "\n");
    check.dag.integrity(g, roots[i]);
    supercheck <- numNodes(g) == ncol(ann);
    if(!supercheck){
        stop("supercheck: failed, number of nodes and number of class mismatch", "\n");
    }else{
        cat("supercheck: ok!", "\n");
    }

    ## hold out data
    ## we remove all the proteins without annotations
    allprs <- names(which(rowSums(ann)!=0));
    ann <- ann[allprs,];
    ## proteins of training and test set
    Tprs <- allprs[allprs %in% rownames(T.ann)];
    Sprs <- allprs[allprs %in% rownames(S.ann)];
    ## index of protein of test set
    testindex <- which(allprs %in% Sprs);
    testindex_name <- allprs[testindex];
    ## shrink string matrix to protein having at least one annotations..
    W <- K[allprs, allprs];
    # remove proteins without features (if any)
    prs_nofeat <- which(rowSums(W)==0);
    if(length(prs_nofeat)>=1){
        W <- W[-prs_nofeat, -prs_nofeat];
        ann <- ann[-prs_nofeat,];
        testindex <- which(rownames(ann) %in% testindex_name);
        cat("genes without features found and removed", "\n");
    }
    ## storing
    sv <- strsplit(stringv,split="[.,v]")[[1]][2];
    save(W, file=paste0(pf, prefix, "_go_", godivs[i], "_string", sv, "_", historical,"_", recent, ".rda"), compress=TRUE);
    save(g, file=paste0(pf, prefix, "_go_", godivs[i], "_dag_", historical, "_", recent, ".rda"), compress=TRUE);
    save(ann, file=paste0(pf, prefix, "_go_", godivs[i], "_ann_", historical, "_", recent, ".rda"), compress=TRUE);
    save(testindex, file=paste0(pf, prefix, "_go_", godivs[i], "_testindex_", historical, "_", recent, ".rda"), compress=TRUE);
    end <- proc.time() - start;
    cat("__end__", godivs[i], roots[i], "done", "elapsed time:", end["elapsed"], sep="\t", "\n\n");
}

end <- proc.time() - outerstart;
cat("__outerend__",  "job done", "elapsed time:", end["elapsed"], sep="\t", "\n\n");

