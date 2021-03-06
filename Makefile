# Your GCP Project Name
PROJECT=my-sample-gcp-project

# Region you want to run your Dataflow jobs
REGION=europe-west4
USER=ppeiris

# GCP Bucket where the flex templates are uploaded
TEMPLATE_BUCKET=flex-templates-$(USER)
TEMPLATE_PATH=gs://$(TEMPLATE_BUCKET)/$(USER)/python_command_spec.json

# Name for your GCR repo
TEMPLATE_IMAGE=gcr.io/$(PROJECT)/word-count-example-$(USER):latest

# Don't change this! This must be as is for Dataflow to trigger the main.py file.
DOCKER_WORKDIR=/dataflow/template
TARGET=demo

init:
	python3 -m venv .venv
	@echo Please run "source .venv/bin/activate" to activate the Python environment.

build:
	pip install --upgrade pip
	pip install -r requirements.txt

template-spec:
	gcloud dataflow flex-template build $(TEMPLATE_PATH) --image "$(TEMPLATE_IMAGE)" --sdk-language "PYTHON" --metadata-file src/$(TARGET)/spec/template_metadata

build-template:
	mkdir -p _tmp/src/$(TARGET)
	cp -R src/$(TARGET) _tmp/src
	
	# Starting string substitution
	cat resources/image_spec.json | TEMPLATE_IMAGE=$(TEMPLATE_IMAGE) envsubst > _tmp/src/$(TARGET)/spec/image_spec.json
	cat resources/python_command_spec.json | WORKDIR=$(DOCKER_WORKDIR) envsubst > _tmp/src/$(TARGET)/spec/python_command_spec.json
	cat Dockerfile | COMPONENT=$(TARGET) WORKDIR=$(DOCKER_WORKDIR) envsubst > _tmp/Dockerfile
	# Ending string substitution
	
	gcloud builds submit --project=${PROJECT} --tag ${TEMPLATE_IMAGE} _tmp/

template: template-spec build-template

local:
	PYTHONPATH=./src python src/$(TARGET)/main.py \
	--input gs://dataflow-samples/shakespeare/kinglear.txt \
	--output gs://word-count-output-ppeiris/output/out \
	--temp_location gs://word-count-output-ppeiris/temp/output \
	--runner DirectRunner \
	--project $(PROJECT) \
	--max_num_workers 100    \
	--region $(REGION)        \
	--setup_file src/$(TARGET)/setup.py \
	--job_name demo-$(TIMESTAMP_IN_SECONDS)

run:
	PROJECT=$(PROJECT) REGION=$(REGION) USER=ppeiris python run_dataflow.py

.PHONY: run local template template-spec build-template build init
