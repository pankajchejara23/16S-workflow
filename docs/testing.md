# Testing
This section provides intructions to run unit and integration tests to ensure a proper functioning of the workflow. These tests can be further used as a validation step upon any changes to the workflow. 

## Running the tests
The following command executes unit tests, one for each rule in the workflow. An integration test is also configured to run with a small real-world dataset from Zackular et al. (2014). In that way, the tests check each rule and overall workflow.

## Go to the workflow repository
```
cd 16S-workflow
```
## Activate Qiime2 environment
```
conda activate <your env name>
```

## Run the tests
```
pytest .tests
```


## Reference
Zackular, J. P., Rogers, M. A., Ruffin IV, M. T., & Schloss, P. D. (2014). The human gut microbiome as a screening tool for colorectal cancer. Cancer prevention research, 7(11), 1112-1121.