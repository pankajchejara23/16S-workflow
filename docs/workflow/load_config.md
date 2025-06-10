# Loading configuration data in the workflow
This is the first step for creating our 16S amplicon processing workflow. We will first import our configuration file and extract project-related information. 

We simply specify our config file in a `key:value` format with key as `configfile`. Snakemake takes care of loading the file and extraction of all configuration in a `config` dictionary. 

``` python

import os
import pathlib

# Specify config file
configfile: "config.yaml"

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

# Database information
DB = config["database"]
DB_classifier = config["database_classifier"]
DB_tax = config["database_tax"]
```
