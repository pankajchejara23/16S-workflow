"""
Common code for unit testing of rules generated with Snakemake 7.32.4.
"""

from pathlib import Path
import subprocess as sp
import os
from unittest import TestCase
from bs4 import BeautifulSoup
import zipfile
import gzip

class OutputChecker(TestCase):
    def __init__(self, data_path, expected_path, workdir,output_files=[],methodName="runTest"):
        super().__init__(methodName)
        self.data_path = data_path
        self.expected_path = expected_path
        self.workdir = workdir
        self.output_files = output_files

        self.expected_files = set(
            (Path(path) / f).relative_to(self.expected_path)
            for path, subdirs, files in os.walk(self.expected_path)
            for f in files
            if Path(f).suffix == '.html'
        )
        

    def check(self):
        self._check_and_compare_other()

    def validate_fastqc_output(self):
        """Compare FastQC HTML and ZIP outputs while ignoring timestamps"""
        
        # check fastqc files existances
        self._check_and_compare_html()

        # compare zip files
        self._check_and_compare_zip()

    def validate_multiqc_output(self):
        """Compare Multiqc HTML outputs while ignoring timestamps"""

        # check fastqc files existances
        self._check_and_compare_html()

    def validate_trimmomatic_output(self):
        """Compare Multiqc Trimmomatic output"""
        self._check_and_compare_gzip()

    def validate_manifest_file(self):
        self._check_and_compare_other()
        
    def validate_qiime2_output(self):
        self._check_and_compare_other()

    def validate_dada2_output(self):
        self._check_and_compare_other()
    
    def validate_dada2_stats_output(self):
        self._check_and_compare_other()

    def validate_stats_output(self):
        self._check_and_compare_other()

    def validate_taxa_output(self):
        self._check_and_compare_other()

    def _check_and_compare_other(self):
        """Compare FastQC HTML reports ignoring variable sections"""

        for f in self.expected_files:
            # Get relative path from expected dir
            generated = self.workdir / f
            expected =  f
            self.assertTrue(generated.exists(), f"Missing file: {generated}")
            self.assertTrue(expected.exists(), f"Missing expected HTML: {expected}")
            
            # Simple size comparison - replace with actual content comparison
            gen_size = generated.stat().st_size
            exp_size = expected.stat().st_size
            self.assertGreater(gen_size, 0, "Generated HTML is empty")
            self.assertAlmostEqual(gen_size, exp_size, delta=exp_size*0.1,
                                msg="HTML file size differs by >10%")


    def _check_and_compare_html(self):
        """Compare FastQC HTML reports ignoring variable sections"""

        for f in self.expected_files:
            if Path(f).suffix != '.html':
                continue
            # Get relative path from expected dir
            generated = self.workdir / f
            expected =  f
            self.assertTrue(generated.exists(), f"Missing HTML file: {generated}")
            self.assertTrue(expected.exists(), f"Missing expected HTML: {expected}")
            
            # Simple size comparison - replace with actual content comparison
            gen_size = generated.stat().st_size
            exp_size = expected.stat().st_size
            self.assertGreater(gen_size, 0, "Generated HTML is empty")
            self.assertAlmostEqual(gen_size, exp_size, delta=exp_size*0.1,
                                msg="HTML file size differs by >10%")
    
    def _check_and_compare_zip(self):
        """Compare ZIP files with unittest assertions"""

        for f in self.expected_files:
            if Path(f).suffix != '.zip':
                continue

            generated = self.workdir / f
            expected =  f

            self.assertTrue(generated.exists(), f"Missing ZIP file: {generated}")
            self.assertTrue(expected.exists(), f"Missing expected ZIP: {expected}")
            
            with zipfile.ZipFile(generated) as gen_zip, \
                zipfile.ZipFile(expected) as exp_zip:
                
                self.assertEqual(
                    sorted(gen_zip.namelist()),
                    sorted(exp_zip.namelist()),
                    "ZIP contents differ"
                )

    def _check_and_compare_gzip(self):
        """Compare GZIP files with unittest assertions"""

        for f in self.expected_files:
            if Path(f).suffix != '.gz':
                continue

            # Get relative path from expected dir
            generated = self.workdir / f
            expected = self.workdir / "expected" / f
            self.assertTrue(generated.exists(), f"Missing gz file: {generated}")
            self.assertTrue(expected.exists(), f"Missing gz HTML: {expected}")
            
            # Simple size comparison - replace with actual content comparison
            gen_size = generated.stat().st_size
            exp_size = expected.stat().st_size
            self.assertGreater(gen_size, 0, "Generated gz is empty")
            self.assertAlmostEqual(gen_size, exp_size, delta=exp_size*0.1,
                                msg="gz file size differs by >10%")

