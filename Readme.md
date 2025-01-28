# From raw reads to relative abundance data: 16S amplicon processing workflow using Snakemake

This repository contains a Snakemake-based workflow designed to process 16S rRNA sequencing data. The workflow includes various steps from quality control, trimming, to taxonomic assignment, diversity metrics and relative abundance computation.

## Workflow Overview

This Snakemake pipeline processes 16S rRNA sequencing data from raw FASTQ files to taxonomic classification. It incorporates several key steps, including:

- **Quality Control**: Filtering and trimming of raw sequences.
- **Denoising**: Denoising using `DADA2` and generating amplicon sequence variants.
- **Taxonomy Assignment**: Assigning taxonomic classifications to the reads using `QIIME2`.
- **Diversity Metrics**: Generating various alpha and beta diversity metrics for subsequent analysis.
- **Relative Abundance**: Computing relative abundance measures.


## Features

- **Reproducibility**: The workflow is built using Snakemake, ensuring a reproducible and scalable analysis pipeline.
- **Modular**: Each step of the workflow is modular, allowing for easy customization and extensions.
- **Integrated Tools**: Supports common microbiome analysis tools such as `QIIME2`, `Kraken2`, and `BLAST`.
- **Reports & Visualizations**: Generate summary reports and visualizations for easier interpretation of results.

## Requirements

- **Snakemake**: The primary workflow manager.
- **Conda**: To manage the dependencies.
- **QIIME2** (or other alignment and taxonomy tools): For processing 16S data.
- **Other Dependencies**: Listed in the `environment.yaml` file.

## Installation

Clone the repository and create a conda environment to run the workflow:

```bash
git clone https://github.com/pankajchejara23/16S-workflow.git
cd 16S-workflow
conda env create -f envs/environment.yaml
conda activate qiime2-snakemake
```

## Usage
### Running the Workflow
1. Prepare your input data: Make sure your FASTQ files are ready for processing.
2. Edit configuration files: Customize the configuration files to specify the paths to your data and any specific parameters you want to adjust.
3. Run Snakemake: Execute the workflow by running Snakemake from the command line.

``` sh
snakemake --cores <number_of_cpu_cores> 
```

### Customizing the Workflow

You can modify specific parts of the workflow by adjusting the following configuration files:

* config.yaml: Defines the paths and parameters for the analysis.
* Snakefile: Contains the main workflow and steps involved in processing the data.

## File Structure
```
16S-workflow/
│
├── Snakefile              # Main Snakemake workflow file
├── config.yaml            # Configuration file for input paths and parameters
├── metadata.csv            # Metadata file for example dataset
├── envs/environment.yaml       # Conda environment file for dependencies
├── reference_db/               # Directory for reference db, taxonomy and pre-built classifier
└── scripts/               # Custom scripts for specific tasks


```

## Citation
```
Chejara, P. (2023). From raw reads to relative abundance data: 16S amplicon processing workflow using Snakemake. GitHub repository. https://github.com/pankajchejara23/16S-workflow

```

## License
License

This repository is licensed under the MIT License. See the LICENSE file for more information.