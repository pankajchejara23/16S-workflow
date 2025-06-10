# Update manifest 
This step prepares a manifest file with paths pointing to the `trimmomatic` output files.



``` python

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
```
