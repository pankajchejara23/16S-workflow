# Snakemake file - input quality controlled fastq reads to generate asv
# Pankaj chejara

# Base snakefile: https://github.com/shu251/tagseq-qiime2-snakemake/blob/master/Snakefile-asv

configfile: "config/config.yaml"


import io
import os
import pandas as pd
import pathlib

##########################################################
#                 SET CONFIG VARS
##########################################################

PROJ = config["project"]
INPUTDIR = config["raw_data"]
OUTPUTDIR = config['outputDIR']
METADATA = config["metadata"]
MANIFEST = config["manifest"]


SAMPLING_DEPTH= config['sampling_depth']

# Fastq files naming config
FILE_NAME_PATTERN = config['file_name_pattern']
EXT = config['extension']
R1_SUF = str(config["r1_suf"])
R2_SUF = str(config["r2_suf"])


# Trimmomatic config
TRIMM_R1 = config['file_r1']
TRIMM_R2 = config['file_r2']
TRIMM_PARAMS = config['trimm_params']

# global wild cards of sample and pairpair list
(SAMPLES,NUMS) = glob_wildcards(INPUTDIR +"/"+ FILE_NAME_PATTERN + EXT)

SAMPLES = set(SAMPLES)
NUMS = set(NUMS)

print('Samples:',SAMPLES)
print('NUMS',NUMS)

# Database information
DB = config["database"]
DB_classifier = config["database_classifier"]
DB_tax = config["database_tax"]

rule all:
  input:
    # Before trim Fastqc results
    expand( OUTPUTDIR + "/fastqc/before_trim/" + "{sample}_{num}_fastqc.html",sample=SAMPLES,num=NUMS),
    expand(OUTPUTDIR + "/fastqc/before_trim/" + "{sample}_{num}_fastqc.zip",sample=SAMPLES,num=NUMS),

    # Before trim Multiqc results
    OUTPUTDIR + "/multiqc/before_trim/" + "multiqc_report.html", 

    expand(OUTPUTDIR + "/trim/{sample}_L001_R1_001.fastq.gz",sample=SAMPLES),
    expand(OUTPUTDIR + "/trim/{sample}_L001_R2_001.fastq.gz",sample=SAMPLES),

    expand(OUTPUTDIR + "/trim/{sample}_L001_R1_001_unpaired.fastq.gz",sample=SAMPLES),
    expand(OUTPUTDIR + "/trim/{sample}_L001_R2_001_unpaired.fastq.gz",sample=SAMPLES), 

    # After trim Fastqc results
    expand(OUTPUTDIR + "/fastqc/after_trim/" + "{sample}_{num}_fastqc.html",sample=SAMPLES,num=NUMS),
    expand(OUTPUTDIR + "/fastqc/after_trim/" + "{sample}_{num}_fastqc.zip",sample=SAMPLES,num=NUMS),

    # After trim Multiqc results
    OUTPUTDIR + "/multiqc/after_trim/multiqc_report.html",

    # Updated manifest file
    OUTPUTDIR + "/" + "manifest.csv",

    # Qiime2 artifact
    q2_import =   OUTPUTDIR +"/" +  PROJ + "-PE-demux.qza",
    # Qiime2 primer removal
    q2_primerRM =   OUTPUTDIR +"/" +  PROJ + "-PE-demux-noprimer.qza",
    # Visualization
    raw =   OUTPUTDIR + "/viz/" + PROJ + "-PE-demux.qzv",
    primer =   OUTPUTDIR + "/viz/" + PROJ + "-PE-demux-noprimer.qzv",
    # Dada2 results
    table =   OUTPUTDIR + "/asv/" + PROJ + "-asv-table.qza",
    rep =   OUTPUTDIR + "/asv/" + PROJ + "-rep-seqs.qza",
    stats =   OUTPUTDIR + "/asv/" + PROJ + "-stats-dada2.qza",
    stats_viz =   OUTPUTDIR + "/viz/" + PROJ + "-stats-dada2.qzv",
    # Taxonomic table
    sklearn =   OUTPUTDIR + "/asv/" +  PROJ + "-tax_sklearn.qza",
    table_biom =   OUTPUTDIR + "/asv/" + "feature-table.biom",
    table_tsv =   OUTPUTDIR + "/asv/" + PROJ + "-asv-table.tsv",
    table_tax =   OUTPUTDIR + "/asv/"  + "taxonomy.tsv",
    # Phylogenetic outputs
    aligned_seqs =   OUTPUTDIR + "/asv/" + "tree/" + PROJ + "-aligned-rep-seqs.qza",
    aligned_masked =   OUTPUTDIR + "/asv/" + "tree/" + PROJ + "-masked-aligned-rep-seqs.qza",
    unrooted_tree =   OUTPUTDIR + "/asv/" + "tree/" + PROJ + "-unrooted-tree.qza",
    rooted_tree =   OUTPUTDIR + "/asv/" + "tree/" + PROJ + "-rooted-tree.qza",
    # Relative frequency 
    table_phyla =   OUTPUTDIR + "/asv/" +  PROJ + "-phyla-table.qza",
    rel_table =   OUTPUTDIR + "/asv/" +  PROJ + "-rel-phyla-table.qza",
    biom_table =   OUTPUTDIR + "/asv/rel-table/feature-table.biom",
    rel_table_tsv =   OUTPUTDIR + "/asv/" +  PROJ + "-rel-freq-table.tsv",
    # Diversity metrics
    output_dir =   OUTPUTDIR + "/diversity"


 

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


##########################################################
#                 FASTQC - QUALITY REPORTS AFTER TRIMMING
##########################################################
rule fastqc_after:
    input:
        OUTPUTDIR + "/trim/" +  FILE_NAME_PATTERN + EXT
    output:
        html =  OUTPUTDIR + "/fastqc/after_trim/" + "{sample}_{num}_fastqc.html",
        zip =  OUTPUTDIR + "/fastqc/after_trim/" + "{sample}_{num}_fastqc.zip",
    log:
        OUTPUTDIR + "/logs/" + "fastqc/fastqc_after-trim_{sample}_{num}.log",
    threads: 20
    resources:
        mem_mb = 1024
    wrapper:
        "v5.5.2/bio/fastqc"


##########################################################
#                 MULTIQC - QUALITY REPORTS MERGE AFTER TRIMMING
##########################################################
rule multiqc_after:
    input:
        expand( OUTPUTDIR + "/fastqc/after_trim/" + "{sample}_{num}_fastqc.zip", sample=SAMPLES,num=NUMS)
    output:
         OUTPUTDIR + "/multiqc/after_trim/multiqc_report.html"
    log:
         OUTPUTDIR + "/logs" + "/multiqc/multiqc_after-trim.log"
    params:
        report_dir =  OUTPUTDIR + "/multiqc/after_trim/" 
    wrapper:
        "v1.31.1/bio/multiqc"


##########################################################
#                   UPDATE MANIFEST FILE
##########################################################
rule create_manifest:
    input:
        MANIFEST
    output:
         OUTPUTDIR + "/" + "manifest.csv"
    log:
         OUTPUTDIR + "/logs/" + "qiime2/manifest.log"
    params:
          OUTPUTDIR

    shell:
        """
        python3 ./scripts/update_manifest.py --input {input} \
            --output {output} \
            --file-dir {params}
        """

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


##########################################################
#                 QC STATS
##########################################################

rule get_stats:
  input:
    q2_import =  OUTPUTDIR +"/" +  PROJ + "-PE-demux.qza",
    q2_primerRM =  OUTPUTDIR +"/" +  PROJ + "-PE-demux-noprimer.qza"
  output:
    raw =  OUTPUTDIR + "/viz/" + PROJ + "-PE-demux.qzv",
    primer =  OUTPUTDIR + "/viz/" + PROJ + "-PE-demux-noprimer.qzv"
  log:
     OUTPUTDIR + "/logs/" + PROJ +  "_getviz_q2.log"
  shell:
    """
     qiime demux summarize --i-data {input.q2_import} --o-visualization {output.raw}
     qiime demux summarize --i-data {input.q2_primerRM} --o-visualization {output.primer}
    """

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
