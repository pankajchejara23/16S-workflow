# Quality check
The first step of the workflow is to perform quality check of raw sequence data. This check provides insights into the quality of reads which facilitate deciding over parameters such as length to trim. 

Here, we use `Fastqc` and `Multiqc` tools. Fastqc generates a report in html format for each sequence file. Multiqc summarises all those reports into a single file making it easier to comprehend various quality metrics for the entire dataset.

## File names
To execute Fastqc for each sequence file, we need a way to have access to all filenames. It can be done manually. But Snakemake provides a wonderful utility called `glob_wildcards`. This utility automatically scans and fetch all file names following a given naming convention.

For example, our dataset has filenames in a specific format (e.g., `Cancer1-2355_S61_L001_R1_001.fastq.gz`). Here, `Cancer1-2355_S61` is the sample identifier and `R1` is the direction of read. 

We can represent all those files using a single syntax `<sampleid>_L001_<read>_001.fastq.gz`. Here, `sampleid` is the identifier for the read; `read` is identifier for direction of read, i.e., R1, R2. 

To extract all sampleid and read, we simply write a single statement using `glob_wildcards` The following statement in our workflow scans the directory and fetch all sample and num information in two lists - SAMPLES AND NUMS.

``` python
# global wild cards of sample and pairpair list
(SAMPLES,NUMS) = glob_wildcards("/{sample}_L001_{num}_001.fastq.gz")

```
## Fastqc rule

``` python
##########################################################
#                 FASTQC - QUALITY REPORTS
##########################################################
rule fastqc_before:
    input:
        INPUTDIR + "/" + FILE_NAME_PATTERN + EXT
    output:
        html =  OUTPUTDIR + "/fastqc/before_trim/" + "{sample}_{num}_fastqc.html",
        zip =  OUTPUTDIR + "/fastqc/before_trim/" + "{sample}_{num}_fastqc.zip",
    log:
        OUTPUTDIR + "/logs/" + "fastqc/fastqc_{sample}_{num}.log",
    threads: 20
    resources:
        mem_mb = 1024
    wrapper:
        "v5.5.2/bio/fastqc"
```

## Multiqc rule
``` python
##########################################################
#                 MULTIQC - QUALITY REPORTS MERGE
##########################################################
rule multiqc_before:
    input:
        expand( OUTPUTDIR + "/fastqc/before_trim/" + "{sample}_{num}_fastqc.zip", sample=SAMPLES,num=NUMS)
    output:
        OUTPUTDIR + "/multiqc/before_trim/" + "multiqc_report.html",
    log:
         OUTPUTDIR + "/logs" + "/multiqc/multiqc.log",
    params:
        use_input_files_only=True,
    wrapper:
        "v6.2.0/bio/multiqc"
```

## References
1. Andrews, S. (2010). FastQC:  A Quality Control Tool for High Throughput Sequence Data [Online]. Available online at: http://www.bioinformatics.babraham.ac.uk/projects/fastqc/
2. Ewels, P., Magnusson, M., Lundin, S., & Käller, M. (2016). MultiQC: summarize analysis results for multiple tools and samples in a single report. Bioinformatics, 32(19), 3047-3048.