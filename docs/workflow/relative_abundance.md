# Relative abundance computation
This step transforms Qiime2 artifacts containing ASVs (Amplicon Sequence Variants) and their associated taxonomies into TSV (Tab-Separated Values) format for downstream analysis. This conversion makes the data compatible with other analysis tools and workflows.
``` python
##########################################################
#                 RELATIVE FREQUENCY TABLE GENERATION
##########################################################
rule taxa_collapse:
  input:
    table =  OUTPUTDIR + "/asv/" + PROJ + "-asv-table.qza",
    sklearn =  OUTPUTDIR + "/asv/" +  PROJ + "-tax_sklearn.qza"
  output:
    table_phyla =  OUTPUTDIR + "/asv/" +  PROJ + "-phyla-table.qza"
  log:
     OUTPUTDIR + "/logs/" + PROJ +  "_taxa_collapse_q2.log"
  shell:
    """qiime taxa collapse \
	  --i-table {input.table} \
	  --i-taxonomy {input.sklearn} \
    --p-level 6 \
	  --o-collapsed-table {output.table_phyla}"""


rule rel_freq_table:
  input:
    table =  OUTPUTDIR + "/asv/" +  PROJ + "-phyla-table.qza"
  output:
    rel_table =  OUTPUTDIR + "/asv/" +  PROJ + "-rel-phyla-table.qza"
  log:
     OUTPUTDIR + "/logs/" + PROJ +  "_rel_freq_q2.log"
  shell:
    """qiime feature-table relative-frequency \
     --i-table {input.table} \
     --o-relative-frequency-table {output.rel_table}"""

rule rel_freq_table_biom:
  input:
    rel_table =  OUTPUTDIR + "/asv/" +  PROJ + "-rel-phyla-table.qza"
  output:
    biom_table =  OUTPUTDIR + "/asv/" + "rel-table/feature-table.biom"
  params:
    directory( OUTPUTDIR + "/asv/" + "rel-table/")
  log:
     OUTPUTDIR + "/logs/" + PROJ +  "_rel_freq_biom_q2.log"
  shell:"""qiime tools export \
     --input-path {input.rel_table} \
     --output-path {params}
  """

rule biom_tsv:
  input:
    biom_table =  OUTPUTDIR + "/asv/" + "rel-table/feature-table.biom"
  output:
    rel_table_tsv =  OUTPUTDIR + "/asv/" +  PROJ + "-rel-freq-table.tsv"
  log:
     OUTPUTDIR + "/logs/" + PROJ +  "_rel_tsv_q2.log"
  shell:
    "biom convert -i {input.biom_table} -o {output.rel_table_tsv} --to-tsv"
```
