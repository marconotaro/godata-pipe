The scripts in this folder check the sequence's length of the retrieved couple of identifiers UniProt-AC versus STRING-ID. It is worth to reminding that the [pipeline](../../README.md#overview) blasts *aminoacidic* (aa) and not nucleotidic sequence (nt) and more important that

> 100% of identity does not mean that two sequences are the same.

Indeed sometimes it may happen that there is a mismatch between the aa length of the two rescued identifiers, but the couple of identifier recovered is right. This fact can easily checked by querying the STRING and UniProt website for the protein of interest. For instance, by visiting the STRING website and looking for the protein of interest, it is easy to reach the corresponding UniProt-AC/ID since STRING points directly to it. Few examples are reported below:

1. 6239.C01F6.6b|mpz-2            (608aa)  &rarr; G5EDM4|NHRF1_CAEEL (467aa) ([link](https://version-11-0b.string-db.org/cgi/network?networkId=bXAVp8kfwf4w));
1. 10090.ENSMUSP00000067418|Smim4 (102aa)  &rarr; Q8C1Q6|SMIM4_MOUSE (80)    ([link](https://version-11-0b.string-db.org/cgi/network?networkId=bAMWKmOCbT1e));
1. 10090.ENSMUSP00000105007|Hdac1 (1189aa) &rarr; G5E8P1|BRD1_MOUSE (1058aa) ([link](https://version-11-0b.string-db.org/cgi/network?networkId=b4qm2xJDn3UH));
1. 9606.ENSP00000415207|NPIPB7    (414aa)  &rarr; O75200|NPIB7_HUMAN (421aa) ([link](https://version-11-0b.string-db.org/cgi/network?networkId=bmJVhyE4SH27));

> NOTE: before calling the scripts below you must have already run the script ``../call_pipe.pl``, because the required input files are returned by this script.

```
prefix=<taxon>_<org>
path=../../orgs_data/$prefix

## recover header
perl blast_recovery.pl $path/$prefix"_blastp_results.out.hacked" | cut -f1 > $prefix"_uniprot.header"
perl blast_recovery.pl $path/$prefix"_blastp_results.out.hacked" | cut -f2 > $prefix"_string.header"

# recover fasta by header
perl fasta_fetcher.pl $prefix"_uniprot.header" $path/$prefix"_uniprot_unmapped_16jun20.fasta" > $prefix"_uniprot.fasta"
perl fasta_fetcher.pl $prefix"_string.header" $path/db/$prefix"_protein_sequences_v11.0.fa" > $prefix"_string.fasta"

## calculate aa length of each sequence
perl fasta_length.pl $prefix"_uniprot.fasta" | sort -nk 2 | cut -c 2- > $prefix"_uniprot.seqlen"
perl fasta_length.pl $prefix"_string.fasta"  | sort -nk 2 | cut -c 2- > $prefix"_string.seqlen"

## check 100% blast similarity results
perl check_blast_recovery.pl $prefix"_string.seqlen" $prefix"_uniprot.seqlen" $path/$prefix"_blastp_results.out.hacked"
```

where ``prefix=<taxon>_<org>`` can be one of the following values:

```
3702_arath
6239_caeel
9031_chick
7955_danre
44689_dicdi
7227_drome
9606_human
10090_mouse
10116_rat
559292_yeast
```

The last command prints on the shell the aa sequence length for each identifier of the retrieved couple UniProt-STRING.

