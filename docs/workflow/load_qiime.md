# Import in Qiime2
Our workflow uses the **Qiime2** tool for processing read sequences. Qiime2 has its file formatting (.qza or .qzv), which requires storing read sequences in the Qiime2 file format. Qiime provides an interface for loading read sequences from different protocols (e.g., FASTQ data with the EMP protocol, Multiplexed FASTQ data). Each of these protocols stores files in a specific format.

This step uses "Fastq manifest" format. it requires It requires a tab-separated values (TSV) file, known as a manifest file, which includes three columns:"

* `sample-id` – Unique sample identifier
* `forward-absolute-filepath` – Full file path to forward reads
* `reverse-absolute-filepath` – Full file path to reverse reads


## Loading into qiime2
This part of the workflow utilizes the manifest file created by the above rule and load the trimmed read sequences in Qiime2 artifict (i.e., `.qza`). 


``` python
##########################################################
#                 LOAD DATA 
##########################################################
rule import_qiime:
  input:
     OUTPUTDIR + "/" + "manifest.csv"
  output:
    q2_import =  OUTPUTDIR +"/" + PROJ + "-PE-demux.qza"
  log:
     OUTPUTDIR + "/logs/" + PROJ + "_q2.log"
  params:
    type="SampleData[PairedEndSequencesWithQuality]",
    input_format="PairedEndFastqManifestPhred33",
  shell:
    """
    export TMPDIR={config[tmp_dir]}
    qiime tools import \
    --type {params.type} \
    --input-path {input} \
    --output-path {output.q2_import} \
    --input-format {params.input_format} 
    """
```

## References
1. Bolyen, E., Rideout, J. R., Dillon, M. R., Bokulich, N. A., Abnet, C. C., Al-Ghalith, G. A., ... & Caporaso, J. G. (2019). Reproducible, interactive, scalable and extensible microbiome data science using QIIME 2. Nature biotechnology, 37(8), 852-857.