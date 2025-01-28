## This script downloads raw sequence data 
## Date: 28 Jan 2025

# Download compressed sequence data
curl  -o zackular2014.gz.tar https://mothur.s3.us-east-2.amazonaws.com/data/MicrobiomeBiomarkerCRC/Zackular_EDRN_fastq_files.gz.tar

# Decompress 
tar -xvzf zackular2014 -C raw_data

# Delete tar file
rm zackular2014.gz.tar

