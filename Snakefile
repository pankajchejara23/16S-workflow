# Snakemake file - input quality controlled fastq reads to generate asv
# Pankaj chejara

# Base snakefile: https://github.com/shu251/tagseq-qiime2-snakemake/blob/master/Snakefile-asv

configfile: "config.yaml"


import io
import os
import pandas as pd
import pathlib

##########################################################
#                 SET CONFIG VARS
##########################################################

PROJ = config["project"]
SCRATCH = config["scratch"]
INPUTDIR = config["raw_data"]
OUTPUTDIR = config['outputDIR']
METADATA = config["metadata"]
SAMPLING_DEPTH= config['sampling_depth']

# Fastq files naming config
SUF = config['suffix']
R1_SUF = str(config["r1_suf"])
R2_SUF = str(config["r2_suf"])

# Trimmomatic config
TRIMM_PARAMS = config['trimm_params']

# global wild cards of sample and pairpair list
(SAMPLES,NUMS) = glob_wildcards(SCRATCH+"/" + INPUTDIR +"/"+"{sample}_L001_{num}" + SUF)

SAMPLES = set(SAMPLES)
NUMS = set(NUMS)

# Database information
DB = config["database"]
DB_classifier = config["database_classifier"]
DB_tax = config["database_tax"]

# global wild cards of sample and pairpair list
(SAMPLES,NUMS) = glob_wildcards(SCRATCH+"/" + INPUTDIR +"/"+"{sample}_L001_{num}" + SUF)

SAMPLES = set(SAMPLES)
NUMS = set(NUMS)



rule all:
  input:
    # Fastqc
    expand(SCRATCH + "/" + OUTPUTDIR + "/fastqc/" + "{sample}_L001_{num}_fastqc.html",sample=SAMPLES,num=NUMS),
    expand(SCRATCH + "/" + OUTPUTDIR + "/fastqc/" + "{sample}_L001_{num}_fastqc.zip",sample=SAMPLES,num=NUMS),
    # Multiqc
    SCRATCH + "/" + OUTPUTDIR + "/multiqc/multiqc_report.html",
    # Trimmomatic
    expand(SCRATCH + "/" + OUTPUTDIR + "/trim/" +"{sample}_R1_paired.fastq.gz",sample=SAMPLES),
    expand(SCRATCH + "/" + OUTPUTDIR + "/trim/" +"{sample}_R2_paired.fastq.gz",sample=SAMPLES),
    # Manifest file
    SCRATCH + "/" + OUTPUTDIR + "/" + "manifest.csv",
    # Qiime2 artifact
    q2_import = SCRATCH + "/" + OUTPUTDIR +"/" +  PROJ + "-PE-demux.qza",
    # Qiime2 primer removal
    q2_primerRM = SCRATCH + "/" + OUTPUTDIR +"/" +  PROJ + "-PE-demux-noprimer.qza",
    # Visualization
    raw = SCRATCH + "/" + OUTPUTDIR + "/viz/" + PROJ + "-PE-demux.qzv",
    primer = SCRATCH + "/" + OUTPUTDIR + "/viz/" + PROJ + "-PE-demux-noprimer.qzv",
    # Dada2 results
    table = SCRATCH + "/" + OUTPUTDIR + "/asv/" + PROJ + "-asv-table.qza",
    rep = SCRATCH + "/" + OUTPUTDIR + "/asv/" + PROJ + "-rep-seqs.qza",
    stats = SCRATCH + "/" + OUTPUTDIR + "/asv/" + PROJ + "-stats-dada2.qza",
    stats_viz = SCRATCH + "/" + OUTPUTDIR + "/viz/" + PROJ + "-stats-dada2.qzv",
    # Taxonomic table
    sklearn = SCRATCH + "/" + OUTPUTDIR + "/asv/" +  PROJ + "-tax_sklearn.qza",
    table_biom = SCRATCH + "/" + OUTPUTDIR + "/asv/" + "feature-table.biom",
    table_tsv = SCRATCH + "/" + OUTPUTDIR + "/asv/" + PROJ + "-asv-table.tsv",
    table_tax = SCRATCH + "/" + OUTPUTDIR + "/asv/"  + "taxonomy.tsv",
    # Phylogenetic outputs
    aligned_seqs = SCRATCH + "/" + OUTPUTDIR + "/asv/" + "tree/" + PROJ + "-aligned-rep-seqs.qza",
    aligned_masked = SCRATCH + "/" + OUTPUTDIR + "/asv/" + "tree/" + PROJ + "-masked-aligned-rep-seqs.qza",
    unrooted_tree = SCRATCH + "/" + OUTPUTDIR + "/asv/" + "tree/" + PROJ + "-unrooted-tree.qza",
    rooted_tree = SCRATCH + "/" + OUTPUTDIR + "/asv/" + "tree/" + PROJ + "-rooted-tree.qza",
    # Relative frequency 
    table_phyla = SCRATCH + "/" + OUTPUTDIR + "/asv/" +  PROJ + "-phyla-table.qza",
    rel_table = SCRATCH + "/" + OUTPUTDIR + "/asv/" +  PROJ + "-rel-phyla-table.qza",
    biom_table = SCRATCH + "/" + OUTPUTDIR + "/asv/rel-table/feature-table.biom",
    rel_table_tsv = SCRATCH + "/" + OUTPUTDIR + "/asv/" +  PROJ + "-rel-freq-table.tsv",
    # Diversity metrics
    output_dir = SCRATCH + "/" + OUTPUTDIR + "/diversity"

##########################################################
#                 FASTQC - QUALITY REPORTS
##########################################################
rule fastqc:
    input:
        SCRATCH + "/" + INPUTDIR + "/" + "{sample}_L001_{num}" + SUF
    output:
        html = SCRATCH + "/" + OUTPUTDIR + "/fastqc/" + "{sample}_L001_{num}_fastqc.html",
        zip = SCRATCH + "/" + OUTPUTDIR + "/fastqc/" + "{sample}_L001_{num}_fastqc.zip",
    log:
        SCRATCH + "/" + OUTPUTDIR + "/logs/" + "fastqc/fastqc_{sample}_{num}.log",
    threads: 20
    resources:
        mem_mb = 1024
    wrapper:
        "v5.5.2/bio/fastqc"


##########################################################
#                 MULTIQC - QUALITY REPORTS MERGE
##########################################################
rule multiqc:
    input:
        expand(SCRATCH + "/" + OUTPUTDIR + "/fastqc/" + "{sample}_L001_{num}_fastqc.zip", sample=SAMPLES,num=NUMS)
    output:
        SCRATCH + "/" + OUTPUTDIR + "/multiqc/multiqc_report.html"
    log:
        SCRATCH + "/logs" + "/multiqc/multiqc.log"
    params:
        report_dir = SCRATCH + "/" + OUTPUTDIR + "/multiqc/" 
    wrapper:
        "v1.31.1/bio/multiqc"

##########################################################
#                 TRIMMOMATIC
##########################################################
rule trimmomatic:
    input:
        r1 = SCRATCH + "/" + INPUTDIR + "/" + "{sample}_L001_R1_001.fastq.gz",
        r2 = SCRATCH + "/" + INPUTDIR + "/" + "{sample}_L001_R2_001.fastq.gz",
    output:
        r1 = SCRATCH + "/" + OUTPUTDIR + "/trim/" +"{sample}_R1_paired.fastq.gz",
        r2 = SCRATCH + "/" + OUTPUTDIR + "/trim/" +"{sample}_R2_paired.fastq.gz",

        r1_unpaired = SCRATCH + "/" + OUTPUTDIR + "/trim/" +"{sample}_R1_unpaired.fastq.gz",
        r2_unpaired = SCRATCH + "/" + OUTPUTDIR + "/trim/" +"{sample}_R2_unpaired.fastq.gz",
    threads: 20
    log:
        SCRATCH + "/" + OUTPUTDIR + "/logs/" + "trimmomatic/{sample}.log"
    params:
        trimmer=[str(config['trimm_params'])]
    wrapper:
        "v5.5.2/bio/trimmomatic/pe"



##########################################################
#                   CREATE MANIFEST FILE
##########################################################
rule create_manifest:
    input:
        r1 = expand(SCRATCH + "/" + OUTPUTDIR + "/trim/" +"{sample}_R1_paired.fastq.gz",sample=SAMPLES),
        r2 = expand(SCRATCH + "/" + OUTPUTDIR + "/trim/" +"{sample}_R2_paired.fastq.gz",sample=SAMPLES),
    output:
        SCRATCH + "/" + OUTPUTDIR + "/" + "manifest.csv"
    params:
        trim_dir = SCRATCH + "/" + OUTPUTDIR + "/trim/",
        out_dir = SCRATCH + "/" + OUTPUTDIR + "/",
        num_chars = 12
    log:
        SCRATCH + "/" + OUTPUTDIR + "/logs/" + "qiime2/manifest.log"

    shell:
        """
        python3 ./scripts/create_manifest.py --input {params.trim_dir} \
            --output {params.out_dir} \
            --num_chars {params.num_chars}
        """

##########################################################
#                 LOAD DATA 
##########################################################
rule import_qiime:
  input:
    SCRATCH + "/" + OUTPUTDIR + "/" + "manifest.csv"
  output:
    q2_import = SCRATCH + "/" + OUTPUTDIR +"/" + PROJ + "-PE-demux.qza"
  log:
    SCRATCH + "/" + OUTPUTDIR + "/logs/" + PROJ + "_q2.log"
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
    q2_import = SCRATCH + "/" + OUTPUTDIR +"/" + PROJ + "-PE-demux.qza"
  output:
    q2_primerRM = SCRATCH + "/" + OUTPUTDIR +"/" + PROJ +  "-PE-demux-noprimer.qza"
  log:
     SCRATCH + "/" + OUTPUTDIR + "/logs/" + PROJ + "_primer_q2.log"

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
    q2_import = SCRATCH + "/" + OUTPUTDIR +"/" +  PROJ + "-PE-demux.qza",
    q2_primerRM = SCRATCH + "/" + OUTPUTDIR +"/" +  PROJ + "-PE-demux-noprimer.qza"
  output:
    raw = SCRATCH + "/" + OUTPUTDIR + "/viz/" + PROJ + "-PE-demux.qzv",
    primer = SCRATCH + "/" + OUTPUTDIR + "/viz/" + PROJ + "-PE-demux-noprimer.qzv"
  log:
    SCRATCH + "/" + OUTPUTDIR + "/logs/" + PROJ +  "_getviz_q2.log"
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
    q2_primerRM = SCRATCH + "/" + OUTPUTDIR +"/" + PROJ + "-PE-demux-noprimer.qza"
  output:
    table = SCRATCH + "/" + OUTPUTDIR + "/asv/" + PROJ + "-asv-table.qza",
    rep = SCRATCH + "/" + OUTPUTDIR + "/asv/" + PROJ + "-rep-seqs.qza",
    stats = SCRATCH + "/" + OUTPUTDIR + "/asv/" + PROJ + "-stats-dada2.qza"
  log:
    SCRATCH + "/" + OUTPUTDIR + "/logs/" + PROJ + "_dada2_q2.log"
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
    stats = SCRATCH + "/" + OUTPUTDIR + "/asv/" + PROJ + "-stats-dada2.qza"
  output:
    stats_viz = SCRATCH + "/" + OUTPUTDIR + "/viz/" + PROJ + "-stats-dada2.qzv"
  log:
    SCRATCH + "/" + OUTPUTDIR + "/logs/" + PROJ + "_dada2-stats_q2.log"
  shell:
   """qiime metadata tabulate \
       --m-input-file {input.stats} \
       --o-visualization {output.stats_viz}"""


##########################################################
#                 TAXONOMIC ASSIGNMENT
##########################################################

rule assign_tax:
  input:
    rep = SCRATCH + "/" + OUTPUTDIR + "/asv/" +  PROJ + "-rep-seqs.qza",
    db_classified = DB_classifier
  output:
    sklearn = SCRATCH + "/" + OUTPUTDIR + "/asv/" +  PROJ + "-tax_sklearn.qza"
  log:
    SCRATCH + "/" + OUTPUTDIR + "/logs/" + PROJ +  "_sklearn_q2.log"
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
    table = SCRATCH + "/" + OUTPUTDIR + "/asv/" + PROJ + "-asv-table.qza"
  output:
    table_biom = SCRATCH + "/" + OUTPUTDIR + "/asv/" + "feature-table.biom"
  log:
    SCRATCH + "/" + OUTPUTDIR + "/logs/" + PROJ + "_exportBIOM_q2.log"
  params:
    directory(SCRATCH + "/" + OUTPUTDIR + "/asv/")
  shell:
    "qiime tools export --input-path {input.table} --output-path {params}"

rule convert:
  input:
    table_biom = SCRATCH + "/" + OUTPUTDIR + "/asv/" + "feature-table.biom"
  output:
    SCRATCH + "/" + OUTPUTDIR + "/asv/" + PROJ + "-asv-table.tsv"
  log:
    SCRATCH + "/" + OUTPUTDIR + "/logs/" + PROJ + "_exportTSV_q2.log"
  shell:
    "biom convert -i {input} -o {output} --to-tsv"

rule gen_tax:
  input:
    sklearn = SCRATCH + "/" + OUTPUTDIR + "/asv/" +  PROJ + "-tax_sklearn.qza"
  output:
     table_tax = SCRATCH + "/" + OUTPUTDIR + "/asv/"  + "taxonomy.tsv",
  log:
    SCRATCH + "/" + OUTPUTDIR + "/logs/" + PROJ + "_exportTAXTSV_q2.log"
  params:
    directory(SCRATCH + "/" + OUTPUTDIR + "/asv/")
  shell:
    "qiime tools export --input-path {input.sklearn} --output-path {params}"


##########################################################
#                 RELATIVE FREQUENCY TABLE GENERATION
##########################################################
rule taxa_collapse:
  input:
    table = SCRATCH + "/" + OUTPUTDIR + "/asv/" + PROJ + "-asv-table.qza",
    sklearn = SCRATCH + "/" + OUTPUTDIR + "/asv/" +  PROJ + "-tax_sklearn.qza"
  output:
    table_phyla = SCRATCH + "/" + OUTPUTDIR + "/asv/" +  PROJ + "-phyla-table.qza"
  log:
    SCRATCH + "/" + OUTPUTDIR + "/logs/" + PROJ +  "_taxa_collapse_q2.log"
  shell:
    """qiime taxa collapse \
	  --i-table {input.table} \
	  --i-taxonomy {input.sklearn} \
    --p-level 6 \
	  --o-collapsed-table {output.table_phyla}"""


rule rel_freq_table:
  input:
    table = SCRATCH + "/" + OUTPUTDIR + "/asv/" +  PROJ + "-phyla-table.qza"
  output:
    rel_table = SCRATCH + "/" + OUTPUTDIR + "/asv/" +  PROJ + "-rel-phyla-table.qza"
  log:
    SCRATCH + "/" + OUTPUTDIR + "/logs/" + PROJ +  "_rel_freq_q2.log"
  shell:
    """qiime feature-table relative-frequency \
     --i-table {input.table} \
     --o-relative-frequency-table {output.rel_table}"""

rule rel_freq_table_biom:
  input:
    rel_table = SCRATCH + "/" + OUTPUTDIR + "/asv/" +  PROJ + "-rel-phyla-table.qza"
  output:
    biom_table = SCRATCH + "/" + OUTPUTDIR + "/asv/" + "rel-table/feature-table.biom"
  params:
    directory(SCRATCH + "/" + OUTPUTDIR + "/asv/" + "rel-table/")
  log:
    SCRATCH + "/" + OUTPUTDIR + "/logs/" + PROJ +  "_rel_freq_biom_q2.log"
  shell:"""qiime tools export \
     --input-path {input.rel_table} \
     --output-path {params}
  """

rule biom_tsv:
  input:
    biom_table = SCRATCH + "/" + OUTPUTDIR + "/asv/" + "rel-table/feature-table.biom"
  output:
    rel_table_tsv = SCRATCH + "/" + OUTPUTDIR + "/asv/" +  PROJ + "-rel-freq-table.tsv"
  log:
    SCRATCH + "/" + OUTPUTDIR + "/logs/" + PROJ +  "_rel_tsv_q2.log"
  shell:
    "biom convert -i {input.biom_table} -o {output.rel_table_tsv} --to-tsv"

##########################################################
#                 PHYLOGENETIC TREE 
##########################################################
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


##########################################################
#                 DIVERSITY METRICS 
##########################################################
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
