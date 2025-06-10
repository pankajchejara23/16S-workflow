# Denoising and ASV
Sequencing data undergoes multiple processing steps before reaching the taxonomic analysis stage. Each of these steps can introduce a certain percentage of errors. This step focuses on correcting those sequencing errors and inferring exact amplicon sequence variants (ASVs) to improve data accuracy.

Additionally, this step filters out low-quality reads and removes chimeric sequences, which are artifacts generated during PCR amplification.

To achieve this, the **DADA2** plugin in Qiime2 is used. DADA2 applies an error model-based approach to denoise reads, ensuring high-resolution and reliable microbiome analysis.
``` python
##########################################################
#                 DENOISE & ASVs
##########################################################

rule dada2:
  input:
    q2_primerRM =  OUTPUTDIR +"/" + PROJ + "-PE-demux-noprimer.qza"
  output:
    table =  OUTPUTDIR + "/asv/" + PROJ + "-asv-table.qza",
    rep =  OUTPUTDIR + "/asv/" + PROJ + "-rep-seqs.qza",
    stats =  OUTPUTDIR + "/asv/" + PROJ + "-stats-dada2.qza"
  log:
     OUTPUTDIR + "/logs/" + PROJ + "_dada2_q2.log"
  shell:
    """qiime dada2 denoise-paired \
        --i-demultiplexed-seqs {input.q2_primerRM} \
        --p-trunc-q {config[truncation_err]} \
        --p-trunc-len-f {config[truncation_len-f]} \
        --p-trunc-len-r {config[truncation_len-r]} \
        --o-table {output.table} \
        --o-representative-sequences {output.rep} \
        --o-denoising-stats {output.stats}"""


rule dada2_stats:
  input:
    stats =  OUTPUTDIR + "/asv/" + PROJ + "-stats-dada2.qza"
  output:
    stats_viz =  OUTPUTDIR + "/viz/" + PROJ + "-stats-dada2.qzv"
  log:
     OUTPUTDIR + "/logs/" + PROJ + "_dada2-stats_q2.log"
  shell:
   """qiime metadata tabulate \
       --m-input-file {input.stats} \
       --o-visualization {output.stats_viz}"""


```

## References
1. Callahan, B. J., McMurdie, P. J., Rosen, M. J., Han, A. W., Johnson, A. J. A., & Holmes, S. P. (2016). DADA2: High-resolution sample inference from Illumina amplicon data. Nature methods, 13(7), 581-583.