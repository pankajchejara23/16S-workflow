import os
import sys

import subprocess as sp
from tempfile import TemporaryDirectory
import shutil
from pathlib import Path, PurePosixPath

sys.path.insert(0, os.path.dirname(__file__))

import common


def test_multiqc_before():

    with TemporaryDirectory() as tmpdir:
        workdir = Path(tmpdir) / "workdir"
        data_path = PurePosixPath(".tests/unit/multiqc_before/data")
        expected_path = PurePosixPath(".tests/unit/multiqc_before/expected")
        config_path = PurePosixPath(".tests/unit/config")

        # Copy data to the temporary workdir.
        shutil.copytree(data_path, workdir) # this is where raw_data will be available and results will be stored
        shutil.copytree(config_path, workdir / "config")

        # dbg
        print("results/multiqc/before_trim/multiqc_report.html", file=sys.stderr)

        # Run the test job.
        sp.check_output([
            "python",
            "-m",
            "snakemake", 
            "results/multiqc/before_trim/multiqc_report.html",
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
