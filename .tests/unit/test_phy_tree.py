import os
import sys

import subprocess as sp
from tempfile import TemporaryDirectory
import shutil
from pathlib import Path, PurePosixPath

sys.path.insert(0, os.path.dirname(__file__))

import common


def test_phy_tree():

    with TemporaryDirectory() as tmpdir:
        workdir = Path(tmpdir) / "workdir"
        data_path = PurePosixPath(".tests/unit/phy_tree/data")
        expected_path = PurePosixPath(".tests/unit/phy_tree/expected")

        # Copy data to the temporary workdir.
        shutil.copytree(data_path, workdir)

        config_path = PurePosixPath(".tests/unit/config")
        shutil.copytree(config_path, workdir / "config")

        # dbg
        print("results/asv/tree/trial-aligned-rep-seqs.qza results/asv/tree/trial-masked-aligned-rep-seqs.qza results/asv/tree/trial-unrooted-tree.qza results/asv/tree/trial-rooted-tree.qza", file=sys.stderr)

        # Run the test job.
        sp.check_output([
            "python",
            "-m",
            "snakemake", 
            "results/asv/tree/trial-aligned-rep-seqs.qza",
            "results/asv/tree/trial-masked-aligned-rep-seqs.qza",
            "results/asv/tree/trial-unrooted-tree.qza",
            "results/asv/tree/trial-rooted-tree.qza",
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
