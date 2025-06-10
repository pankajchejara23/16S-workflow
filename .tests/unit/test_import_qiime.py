import os
import sys

import subprocess as sp
from tempfile import TemporaryDirectory
import shutil
from pathlib import Path, PurePosixPath

sys.path.insert(0, os.path.dirname(__file__))
import pandas as pd
import common

def to_absolute(workdir, path):
    """Convert relative paths to absolute paths within the working directory"""
    path = Path(path)
    if not path.is_absolute():
        return (workdir / path).resolve()
    return path

def test_import_qiime():

    with TemporaryDirectory() as tmpdir:
        workdir = Path(tmpdir) / "workdir"
        data_path = PurePosixPath(".tests/unit/import_qiime/data")
        expected_path = PurePosixPath(".tests/unit/import_qiime/expected")

        config_path = PurePosixPath(".tests/unit/config")


        # Copy data to the temporary workdir.
        shutil.copytree(data_path, workdir)
        shutil.copytree(config_path, workdir / "config")
        
        
        manifest = workdir / "results/manifest.csv"

        print(str(manifest))

        df = pd.read_csv(manifest)

        # Convert all paths in manifest to absolute temp paths
        df['absolute-filepath'] = df['absolute-filepath'].apply(
            lambda x: str(to_absolute(workdir, x))
        )
        df.to_csv(manifest, index=False)

        # dbg
        print("results/trial-PE-demux.qza", file=sys.stderr)

        # Run the test job.
        sp.check_output([
            "python",
            "-m",
            "snakemake", 
            "results/trial-PE-demux.qza",
            "-f", 
            "-j1",
            "--keep-target-files",
    
            "--directory",
            workdir,
        ])

        # Check the output byte by byte using cmp.
        # To modify this behavior, you can inherit from common.OutputChecker in here
        # and overwrite the method `compare_files(generated_file, expected_file), 
        # also see common.py.
        common.OutputChecker(data_path, expected_path, workdir).check()
