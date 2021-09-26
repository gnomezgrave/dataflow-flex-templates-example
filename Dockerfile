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

COPY src/$COMPONENT/pipeline ${WORKDIR}/pipeline

COPY src/$COMPONENT/spec/python_command_spec.json ${WORKDIR}/python_command_spec.json

ENV DATAFLOW_PYTHON_COMMAND_SPEC ${WORKDIR}/python_command_spec.json


COPY src/$COMPONENT/setup.py ${WORKDIR}/setup.py
COPY src/$COMPONENT/main.py ${WORKDIR}/main.py
COPY src/$COMPONENT/requirements.txt ${WORKDIR}/requirements.txt

RUN pip install --upgrade --user pip
RUN pip install -r ${WORKDIR}/requirements.txt

# Entry point for the Dataflow job.
# If you set this, there's no need to set DATAFLOW_PYTHON_COMMAND_SPEC
ENV FLEX_TEMPLATE_PYTHON_PY_FILE="${WORKDIR}/main.py"
