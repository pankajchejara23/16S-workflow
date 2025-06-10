# Trimmomatic
This is the step where the read sequences are trimmed to ensure a high-quality data for subsequent analysis. More details on trimmomatic can be found [here](http://www.usadellab.org/cms/index.php?page=trimmomatic).

We use Snakemake wrapper for trimmomatic.

``` python

##########################################################
#                 TRIMMOMATIC
##########################################################
rule trimmomatic:
    input:
        r1 =  INPUTDIR + "/{sample}_L001_R1_001.fastq.gz",
        r2 =  INPUTDIR + "/{sample}_L001_R2_001.fastq.gz",
    output:
        r1 =  OUTPUTDIR + "/trim/{sample}_L001_R1_001.fastq.gz",
        r2 =  OUTPUTDIR + "/trim/{sample}_L001_R2_001.fastq.gz",

        r1_unpaired =  OUTPUTDIR + "/trim/{sample}_L001_R1_001_unpaired.fastq.gz",
        r2_unpaired =  OUTPUTDIR + "/trim/{sample}_L001_R2_001_unpaired.fastq.gz",
    threads: 20
    log:
         OUTPUTDIR + "/logs/" + "trimmomatic/{sample}.log"
    params:
        trimmer=[str(config['trimm_params'])]
    wrapper:
        "v5.5.2/bio/trimmomatic/pe"
```

!!! note

    Quality check is also performed on trimmed files to provide insights on sequence quality before actual processing.




## References
1. Bolger, A. M., Lohse, M., & Usadel, B. (2014). Trimmomatic: a flexible trimmer for Illumina sequence data. Bioinformatics, 30(15), 2114-2120.