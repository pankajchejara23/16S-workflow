# Phylogenetic tree
This step generates phylogenetic tree of representative sequences obtained from denoising step. This tree is used for computations of a variety of diversity metrics.


```python

##########################################################
#                 PHYLOGENETIC TREE 
##########################################################
rule phy_tree:
  input:
     rep =  OUTPUTDIR + "/asv/" + PROJ + "-rep-seqs.qza",
  output:
    aligned_seqs =  OUTPUTDIR + "/asv/" + "tree/" + PROJ + "-aligned-rep-seqs.qza",
    aligned_masked =  OUTPUTDIR + "/asv/" + "tree/" + PROJ + "-masked-aligned-rep-seqs.qza",
    unrooted_tree =  OUTPUTDIR + "/asv/" + "tree/" + PROJ + "-unrooted-tree.qza",
    rooted_tree =  OUTPUTDIR + "/asv/" + "tree/" + PROJ + "-rooted-tree.qza",
  log:
     OUTPUTDIR + "/logs/" + PROJ + "_phylogeneticTREE_q2.log"

  shell:
    """qiime phylogeny align-to-tree-mafft-fasttree \
        --i-sequences {input.rep} \
        --o-alignment {output.aligned_seqs} \
        --o-masked-alignment {output.aligned_masked} \
        --o-tree {output.unrooted_tree} \
        --o-rooted-tree {output.rooted_tree}"""



##########################################################
#                 DIVERSITY METRICS 
##########################################################
rule div_met:
  input:
     rooted_tree =  OUTPUTDIR + "/asv/" + "tree/" + PROJ + "-rooted-tree.qza",
     table =  OUTPUTDIR + "/asv/" + PROJ + "-asv-table.qza"
  output:
     output_dir = directory( OUTPUTDIR + "/diversity")
  
  log:
     OUTPUTDIR + "/logs/" + PROJ + "_phylogeneticTREE_q2.log"

  shell:
    """qiime diversity core-metrics-phylogenetic \
        --i-phylogeny {input.rooted_tree} \
        --i-table {input.table} \
        --p-sampling-depth {SAMPLING_DEPTH} \
        --m-metadata-file {METADATA} \
        --output-dir {output.output_dir}"""
```