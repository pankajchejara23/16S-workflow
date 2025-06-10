# Setup
We start by setting up our machine with required tools and packages to get it ready for executing the workflow. We primarily need the following tools

* Miniconda
* Qiime2 (2025.4.0)
* Snakemake
* Snakemake wrapper utils
* Pytest


To speed up the installation, we will use an `environment.yml` file exported from a conda environment that successfully executed the workflow. . 

You can create a new environment using the following command. This will create a environment with name **qiime2_amplicon_snakemake**.

```
conda env create -f ../envs/environment.yml
```
!!! note

    To execute this command you need to have either Miniconda or Anaconda installed on your system. 

