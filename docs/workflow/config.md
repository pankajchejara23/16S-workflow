# Config file
A configuration file specifies all project-related inforamation in a yml file. This configuration file is all which needs to be updated in order to execute the workflow for another project. This makes bioinfomatician's file easier. Just think chaning your workflow every time you run it for a different project. In this cases, there is a high likelihood of human error. 

To avoid this situation, all project-related information are kept in a yml file. Our workflow uses the following configuration file.


The table provides information on each key and thier meaning. 


| **Key**                  | **Description**                                                                                      |
|--------------------------|------------------------------------------------------------------------------------------------------|
| **project**              | Name of the project; serves as an identifier for the analysis.                                      |
| **scratch**              | Path to the scratch or working directory where outputs will be stored.       |
| **raw_data**             | Directory containing raw input data files (e.g., raw FASTQ files).                                  |
| **outputDIR**            | Directory where final pipeline outputs will be stored.                                              |
| **metadata**             | Path to the QIIME2 metadata file containing sample information such as groups or treatments.        |
| **manifest**             | Path to the manifest file containing fastq files path.        |
| **tmp_dir**              | Temporary directory for QIIME2 operations (e.g., caching files during execution).                   |
| **file_name_pattern**    | File name pattern to parse sampleid and read direction information.                           |
| **prefix**               | File prefix used in raw FASTQ file naming (e.g., `_L001_`).                                         |
| **r1_suf**               | Identifier used for forward read files (R1) in paired-end sequencing data.                                   |
| **r2_suf**               | Identifier used for reverse read files (R2) in paired-end sequencing data.                                   |
| **file_r1**               | File name pattern to saved trimmomatic forward direction output file.                                   |
| **file_r2**               | File name pattern to saved trimmomatic backward direction output file.                                        |
| **trimm_params**         | Parameters for trimming raw sequences with Trimmomatic (e.g., cropping sequences to a length of 200).|
| **primerF**              | Forward primer sequence used for amplifying the 16S rRNA region.                                   |
| **primerR**              | Reverse primer sequence used for amplifying the 16S rRNA region.                                   |
| **primer_err**           | Maximum allowable primer error rate during sequence matching.                                       |
| **primer_overlap**       | Minimum overlap between primer and sequence for matching.                                           |
| **database**             | Path to the QIIME2 reference database sequences file (e.g., SILVA 138.1).                           |
| **database_classifier**  | Path to the QIIME2 pre-trained classifier for taxonomic classification.                             |
| **database_tax**         | Path to the QIIME2 taxonomy file associated with the reference database.                            |
| **truncation_err**       | Maximum allowable error for sequence truncation in DADA2 (used for quality filtering).              |
| **truncation_len-f**     | Length to truncate forward reads (R1) in DADA2 analysis.                                            |
| **truncation_len-r**     | Length to truncate reverse reads (R2) in DADA2 analysis.                                            |
| **quality_err**          | Maximum allowable quality error for sequence processing in DADA2.                                   |
| **sampling_depth**       | Depth of subsampling used for diversity analysis to ensure consistency across samples.              |


The following is the configuration file used for the workflow.

``` yaml
# Basic setup
project: trial
raw_data: 'raw_data'
outputDIR: results
metadata: metadata.tsv
manifest: manifest.csv

# Temp directory
tmp_dir: ./

# File naming pattern
# This pattern will be used to specify input files for the first step
# For example: Dataset with files having name such as "Healthy3-3021_S33_L001_R2_001.fastq.gz" will 
#    Fetch 'Healthy3-3021_S33' as sample and 'R2' as num
file_name_pattern: "{sample}_L001_{num}_001"


# Fastq file naming config
extension: .fastq.gz
prefix: _L001_
r1_suf: R1
r2_suf: R2

# Trimmomatic config
file_r1: "{sample}_L001_R1_001"
file_r2: "{sample}_L001_R2_001"
threads: 20
trimm_params: CROP:200

## 16S adapters from Zackular et al., 2014
primerF: GTGCCAGCMGCCGCGGTAA
primerR: GGACTACHVGGGTWTCTAAT
primer_err: 0.4
primer_overlap: 3

## Reference database
database: reference_db/silva-138.1-ssu-nr99-seqs-515f-806r.qza
database_classifier: reference_db/silva_classifier.qza
database_tax: reference_db/silva-138.1-ssu-nr99-tax.qza

## DADA2 - ASV flags
truncation_err: 2
truncation_len-f: 150
truncation_len-r: 140
truncation_err: 2
quality_err: 2

## Diversity metrics
sampling_depth: 500



```