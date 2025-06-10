# Diversity metrics
This step computes multiple alpha and beta diversity measures to assess the bacterial composition identified in the sequencing reads.

* **Alpha diversity measures:** These metrics estimate the richness (number of species) and evenness (distribution of species) within a single sample, providing insights into the diversity of microbial communities.

* **Beta diversity measures:** These metrics assess the similarity or dissimilarity of microbial compositions between different samples, offering insights into how microbial communities vary across samples.
## Phylogenetic tree generation
``` python
rule phy_tree:
  input:
     rep = SCRATCH + "/" + OUTPUTDIR + "/asv/" + PROJ + "-rep-seqs.qza",
  output:
    aligned_seqs = SCRATCH + "/" + OUTPUTDIR + "/asv/" + "tree/" + PROJ + "-aligned-rep-seqs.qza",
    aligned_masked = SCRATCH + "/" + OUTPUTDIR + "/asv/" + "tree/" + PROJ + "-masked-aligned-rep-seqs.qza",
    unrooted_tree = SCRATCH + "/" + OUTPUTDIR + "/asv/" + "tree/" + PROJ + "-unrooted-tree.qza",
    rooted_tree = SCRATCH + "/" + OUTPUTDIR + "/asv/" + "tree/" + PROJ + "-rooted-tree.qza",
  log:
    SCRATCH + "/" + OUTPUTDIR + "/logs/" + PROJ + "_phylogeneticTREE_q2.log"

  shell:
    """qiime phylogeny align-to-tree-mafft-fasttree \
        --i-sequences {input.rep} \
        --o-alignment {output.aligned_seqs} \
        --o-masked-alignment {output.aligned_masked} \
        --o-tree {output.unrooted_tree} \
        --o-rooted-tree {output.rooted_tree}"""
```


## Diversity metrics computation
``` python
rule div_met:
  input:
     rooted_tree = SCRATCH + "/" + OUTPUTDIR + "/asv/" + "tree/" + PROJ + "-rooted-tree.qza",
     table = SCRATCH + "/" + OUTPUTDIR + "/asv/" + PROJ + "-asv-table.qza"
  output:
     output_dir = directory(SCRATCH + "/" + OUTPUTDIR + "/diversity")
  
  log:
    SCRATCH + "/" + OUTPUTDIR + "/logs/" + PROJ + "_phylogeneticTREE_q2.log"

  shell:
    """qiime diversity core-metrics-phylogenetic \
        --i-phylogeny {input.rooted_tree} \
        --i-table {input.table} \
        --p-sampling-depth {SAMPLING_DEPTH} \
        --m-metadata-file {METADATA} \
        --output-dir {output.output_dir}"""
```