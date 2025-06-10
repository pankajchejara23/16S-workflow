import os
import sys

import subprocess as sp
from tempfile import TemporaryDirectory
import shutil
from pathlib import Path, PurePosixPath

sys.path.insert(0, os.path.dirname(__file__))

import common


def test_dada2_stats():

    with TemporaryDirectory() as tmpdir:
        workdir = Path(tmpdir) / "workdir"
        data_path = PurePosixPath(".tests/unit/dada2_stats/data")
        expected_path = PurePosixPath(".tests/unit/dada2_stats/expected")

        # Copy data to the temporary workdir.
        shutil.copytree(data_path, workdir)

        config_path = PurePosixPath(".tests/unit/config")
        shutil.copytree(config_path, workdir / "config")

        # dbg
        print("results/viz/trial-stats-dada2.qzv", file=sys.stderr)

        # Run the test job.
        sp.check_output([
            "python",
            "-m",
            "snakemake", 
            "results/viz/trial-stats-dada2.qzv",
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
