#
# Licensed to the Apache Software Foundation (ASF) under one or more
# contributor license agreements.  See the NOTICE file distributed with
# this work for additional information regarding copyright ownership.
# The ASF licenses this file to You under the Apache License, Version 2.0
# (the "License"); you may not use this file except in compliance with
# the License.  You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

"""A word-counting workflow."""

# pytype: skip-file

# Original Source: https://github.com/apache/beam/blob/master/sdks/python/apache_beam/examples/wordcount.py

import re

import apache_beam as beam
from apache_beam.io import ReadFromText
from apache_beam.io import WriteToText
from apache_beam.options.pipeline_options import PipelineOptions
from apache_beam.options.pipeline_options import SetupOptions


class WordExtractingDoFn(beam.DoFn):
    """Parse each line of input text into words."""

    def process(self, element):
        """Returns an iterator over the words of this element.

        The element is a line of text.  If the line is blank, note that, too.

        Args:
          element: the element being processed

        Returns:
          The processed element.
        """
        return re.findall(r'[\w\']+', element, re.UNICODE)


def run(known_args, pipeline_args):

    with beam.Pipeline(options=PipelineOptions(pipeline_args)) as p:
        # Read the text file[pattern] into a PCollection.
        lines = p | 'Read' >> ReadFromText(known_args.input)

        counts = (
                    lines
                    | 'Split' >> (beam.ParDo(WordExtractingDoFn()).with_output_types(str))
                    | 'PairWIthOne' >> beam.Map(lambda x: (x, 1))
                    | 'GroupAndSum' >> beam.CombinePerKey(sum)
                 )

        # Format the counts into a PCollection of strings.
        def format_result(word, count):
            return '%s: %d' % (word, count)

        output = counts | 'Format' >> beam.MapTuple(format_result)

        # Write the output using a "Write" transform that has side effects.
        # pylint: disable=expression-not-assigned
        output | 'Write' >> WriteToText(known_args.output)

        p.run()
