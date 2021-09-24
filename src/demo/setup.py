"""
Setup.py module for the workflow's worker utilities.
All the workflow related code is gathered in a package that will be built as a
source distribution, staged in the staging area for the workflow being run and
then installed in the workers when they start running.
This behavior is triggered by specifying the --setup_file command line option
when running the workflow for remote execution.
https://beam.apache.org/documentation/sdks/python-pipeline-dependencies/#multiple-file-dependencies
https://github.com/apache/beam/blob/master/sdks/python/apache_beam/examples/complete/juliaset/setup.py
"""

import setuptools

setuptools.setup(
    packages=setuptools.find_packages(),
    install_requires=[
        'apache-beam[gcp]==2.24.0',
        'google-cloud-storage'
    ]
)
