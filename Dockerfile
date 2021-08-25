#
# Copyright (C) 2019 Google Inc.
#
# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License. You may obtain a copy of
# the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the
# License for the specific language governing permissions and limitations under
# the License.
#

FROM gcr.io/dataflow-templates-base/python3-template-launcher-base

RUN mkdir -p ${WORKDIR}
WORKDIR ${WORKDIR}

COPY src/pipeline ${WORKDIR}/pipeline
COPY src/setup.py ${WORKDIR}/setup.py
COPY src/main.py ${WORKDIR}/main.py

COPY src/requirements.txt ${WORKDIR}/requirements.txt
COPY src/spec/python_command_spec.json ${WORKDIR}/python_command_spec.json

ENV DATAFLOW_PYTHON_COMMAND_SPEC ${WORKDIR}/python_command_spec.json

RUN pip install -r ${WORKDIR}/requirements.txt

ENV FLEX_TEMPLATE_PYTHON_PY_FILE="${WORKDIR}/main.py"
ENV FLEX_TEMPLATE_PYTHON_REQUIREMENTS_FILE="${WORKDIR}/requirements.txt"

