from __future__ import absolute_import

import logging
import argparse


from pipeline import word_count


if __name__ == '__main__':
    logging.getLogger().setLevel(logging.INFO)

    parser = argparse.ArgumentParser()
    parser.add_argument('--input', help='Path for the input files',
                        dest='input')
    parser.add_argument('--output', help='Path for the output',
                        dest='output')

    word_count_args, pipeline_args = parser.parse_known_args()
    word_count.run(word_count_args, pipeline_args)
