# Taxonomy generation
This step assigns taxonomic labels to the amplicon sequence variants (ASVs) obtained from the denoising step. To accomplish this, a prebuilt **taxonomy classifier**, trained on a reference dataset, is used. Multiple reference datasets are available for this task, such as Greengenes and Silva.

The taxonomy classifier assigns taxonomic labels to each ASV, providing information on hierarchical levels such as Domain, Phylum, Class, Order, Genus, and Species.

!!! important
    16S rRNA sequence analysis typically supports taxonomic resolution only up to the genus level.

## Classify taxonomies
``` python
##########################################################
#                 TAXONOMIC ASSIGNMENT
##########################################################

rule assign_tax:
  input:
    rep =  OUTPUTDIR + "/asv/" +  PROJ + "-rep-seqs.qza",
    db_classified = DB_classifier
  output:
    sklearn =  OUTPUTDIR + "/asv/" +  PROJ + "-tax_sklearn.qza"
  log:
     OUTPUTDIR + "/logs/" + PROJ +  "_sklearn_q2.log"
  shell:
    """qiime feature-classifier classify-sklearn \
	  --i-classifier {input.db_classified} \
	  --i-reads {input.rep} \
	  --o-classification {output.sklearn}"""

```
## Convert Qiime2 artifact to table

``` python
##########################################################
#                 TAXONOMIC TABLE GENERATION
##########################################################
rule gen_table:
  input:
    table =  OUTPUTDIR + "/asv/" + PROJ + "-asv-table.qza"
  output:
    table_biom =  OUTPUTDIR + "/asv/" + "feature-table.biom"
  log:
     OUTPUTDIR + "/logs/" + PROJ + "_exportBIOM_q2.log"
  params:
    directory( OUTPUTDIR + "/asv/")
  shell:
    "qiime tools export --input-path {input.table} --output-path {params}"

rule convert:
  input:
    table_biom =  OUTPUTDIR + "/asv/" + "feature-table.biom"
  output:
     OUTPUTDIR + "/asv/" + PROJ + "-asv-table.tsv"
  log:
     OUTPUTDIR + "/logs/" + PROJ + "_exportTSV_q2.log"
  shell:
    "biom convert -i {input} -o {output} --to-tsv"

rule gen_tax:
  input:
    sklearn =  OUTPUTDIR + "/asv/" +  PROJ + "-tax_sklearn.qza"
  output:
     table_tax =  OUTPUTDIR + "/asv/"  + "taxonomy.tsv",
  log:
     OUTPUTDIR + "/logs/" + PROJ + "_exportTAXTSV_q2.log"
  params:
    directory( OUTPUTDIR + "/asv/")
  shell:
    "qiime tools export --input-path {input.sklearn} --output-path {params}"

```