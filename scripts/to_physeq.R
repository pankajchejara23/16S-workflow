# Script to convert qiime2 artifacts into phyloseq object for later processing

# Import packages
library('qiime2R')
library('speedyseq')

## set command line arguments ----
args <- commandArgs(trailingOnly = TRUE)

# test if there is at least one argument: if not, return an error
if (length(args)<5) {
  stop("Specify feature_table, rooted_tree, taxonomy, and metadata files", call.=FALSE)
} 

# Output file name
output <- args[4]

# Create a Phyloseq object
physeq <-qza_to_phyloseq(
    features = args[0],
    tree = args[1],
    args[2],
    args[3])

# Converting counts to relative abundace
sc1  = transform_sample_counts(physeq, function(x) x / sum(x) )

# Save phyloseq object 
saveRDS(physeq,'phyloseq_object.RDS')
saveRDS(physeq,'phyloseq_rel_object.RDS')
