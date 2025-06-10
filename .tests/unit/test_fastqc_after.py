import os
import sys

import subprocess as sp
from tempfile import TemporaryDirectory
import shutil
from pathlib import Path, PurePosixPath

sys.path.insert(0, os.path.dirname(__file__))

import common


def test_fastqc_after():

    with TemporaryDirectory() as tmpdir:
        workdir = Path(tmpdir) / "workdir"
        data_path = PurePosixPath(".tests/unit/fastqc_after/data")
        expected_path = PurePosixPath(".tests/unit/fastqc_after/expected")
        config_path = PurePosixPath(".tests/unit/config")

        # Copy data to the temporary workdir.
        shutil.copytree(data_path, workdir) # this is where raw_data will be available and results will be stored
        shutil.copytree(config_path, workdir / "config")

        # dbg
        print("results/fastqc/after_trim/Healthy2-2779_S32_R1_fastqc.html results/fastqc/after_trim/Healthy2-2779_S32_R1_fastqc.zip", file=sys.stderr)

        # Run the test job.
        sp.check_output([
            "python",
            "-m",
            "snakemake", 
            "results/fastqc/after_trim/Healthy2-2779_S32_R1_fastqc.html",
            "results/fastqc/after_trim/Healthy2-2779_S32_R1_fastqc.zip",
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
        common.OutputChecker(data_path, expected_path, workdir).validate_fastqc_output()
