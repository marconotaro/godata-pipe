## script to prepare data for cv experiments. More precisely, this script build the GO graph for each domain (BP, MF, CC) and the corresponding annotation matrix respect to a STRING p2p network

library(HEMDAG);   ## graph utils
library(RBGL);     ## dijkstra's shortest paths
library(optparse); ## input argument parser

## eg call: Rscript make_cv_data.R -t 6239 -o caeel -g 12dec20 -s v11.0

outerstart <- proc.time();

optionList <- list(
    make_option(c("-t", "--taxon"), type="integer", default="6239", help="NCBI taxonID"),
    make_option(c("-o", "--org"), type="character", default="caeel", help="organism identification code used as entry name in the UniProtKB database"),
    make_option(c("-g", "--release"), type="character", default="12dec20", help="release of GOA db"),
    make_option(c("-s", "--stringv"), type="character", default="v11.0", help="version of STRING db"),
    make_option(c("-f", "--filter"), type="logical", default=FALSE, action="store_true",
        help="should the string network and the annotation matrix be shrunken only to proteins having at least one annotation? (def. false)")
);

optParser <- OptionParser(option_list=optionList);
opt <- parse_args(optParser);
if(length(opt)<6){
    print_help(optParser);
    stop("at least 5 argument must be supplied");
}

taxon <- opt$taxon;
org <- opt$org;
release <- opt$release;
stringv <- opt$stringv;
filter <- opt$filter;
prefix <- paste0(taxon,"_",org);
pf <- paste0("../orgs_data/",prefix,"/");

# loading full GO dag
g.univ <- get(load("../go_obo/go.univ.rda"));

# loading STRING p2p net
K <- get(load(paste0(pf,prefix,"_string_",stringv,".rda")));

# loading spec ann matrix
spec.ann <- get(load(paste0(pf,prefix,"_spec_ann_",release,".rda")));

# names of three sub-ontologies and roots (NB: ontology domain and roots must be in the same order)
godivs <- c("bp","mf","cc");
roots <- c("GO:0008150","GO:0003674","GO:0005575");

for(i in 1:length(godivs)){
    start <- proc.time();
    cat("__start__", godivs[i], roots[i], sep="\t", "\n");
    ## transitive closure annotation matrix
    anc <- get(load(paste0("../go_obo/go.",godivs[i],".ancestor.rda")));
    ann <- full.annotation.matrix(K, anc, spec.ann);
    cat("status annotation matrix:", sep="\t", "\n");
    check.annotation.matrix.integrity(anc, spec.ann, ann);
    ## full graph
    nd <- colnames(ann);
    g <- build.subgraph(nd, g.univ);
    ## check if there are inconsistent node in the graph =>
    ## nodes belonging to a different ontology =>
    ## the lines below are useful for go.obo.. with go-basic.obo everything should be safe ..
    if(length(root.node(g))>1){
        cat(godivs[i], "inconsistent nodes found and removed", "\n");
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
    ## cv data
    if(filter){
        allprs <- names(which(rowSums(ann)!=0));
        ann <- ann[allprs,];
        W <- K[allprs, allprs];
        # remove proteins without features (if any)
        prs_nofeat <- which(rowSums(W)==0);
        if(length(prs_nofeat)>=1){
            W <- W[-prs_nofeat, -prs_nofeat];
            ann <- ann[-prs_nofeat,];
            cat("genes without features found and removed", "\n");
        }
        ## storing
        sv <- strsplit(stringv, split="[.,v]")[[1]][2];
        save(W, file=paste0(pf, prefix, "_go_", godivs[i], "_string", sv, "_", release, ".rda"), compress=TRUE);
        save(g, file=paste0(pf, prefix, "_go_", godivs[i], "_dag_", release, ".rda"));
        save(ann, file=paste0(pf, prefix, "_go_", godivs[i], "_ann_", release, ".rda"));
    }else{
        ## storing
        save(g, file=paste0(pf, prefix, "_go_", godivs[i], "_dag_", release,".rda"));
        save(ann, file=paste0(pf, prefix, "_go_", godivs[i], "_ann_", release,".rda"));
    }
    cat("ann:", dim(ann), "\n");
    cat("W:", dim(W), "\n");
    cat("nd:", numNodes(g), "ed:", numEdges(g), "\n");
    end <- proc.time() - start;
    cat("__end__", godivs[i], roots[i], "done", "elapsed time:", end["elapsed"], sep="\t","\n\n");
}

end <- proc.time() - outerstart;
cat("__outerend__",  "job done", "elapsed time:", end["elapsed"], sep="\t", "\n\n");

