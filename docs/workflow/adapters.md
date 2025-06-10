# Adapter removal
This step removes adapter sequences from the sequencing reads. Adapter sequences are short DNA fragments added during library preparation to facilitate sequencing and indexing. Removing these adapters, along with other unwanted sequences such as primers, improves data quality and ensures accurate downstream analysis.

To achieve this, the **Cutadapt** plugin in Qiime2 is used. Cutadapt efficiently trims adapter sequences, filters low-quality reads, and removes unwanted fragments, ensuring cleaner and more reliable sequencing data for further processing.


``` python
##########################################################
#                 REMOVE PRIMERS
##########################################################
rule rm_primers:
  input:
    q2_import =  OUTPUTDIR +"/" + PROJ + "-PE-demux.qza"
  output:
    q2_primerRM =  OUTPUTDIR +"/" + PROJ +  "-PE-demux-noprimer.qza"
  log:
      OUTPUTDIR + "/logs/" + PROJ + "_primer_q2.log"

  shell:
    """qiime cutadapt trim-paired \
       --i-demultiplexed-sequences {input.q2_import} \
       --p-front-f {config[primerF]} \
       --p-front-r {config[primerR]} \
       --p-error-rate {config[primer_err]} \
       --p-overlap {config[primer_overlap]} \
       --o-trimmed-sequences {output.q2_primerRM}"""
```

## References
1. Martin, M. (2011). Cutadapt removes adapter sequences from high-throughput sequencing reads. EMBnet. journal, 17(1), 10-12.