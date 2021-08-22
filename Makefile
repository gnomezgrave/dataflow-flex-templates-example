# Your GCP Project Name
PROJECT=github-stats-dashboard

# Region you want to run your Dataflow jobs
REGION=europe-west4

# GCP Bucket where the flex templates are uploaded
TEMPLATE_BUCKET=dataflow-flex-templates-$(USER)
TEMPLATE_PATH=gs://$(TEMPLATE_BUCKET)/$(USER)/python_command_spec.json

# Name for your GCR repo
TEMPLATE_IMAGE=gcr.io/$(PROJECT)/word-count-example-$(USER):latest

# Don't change this! This must be as is for Dataflow to trigger the main.py file.
DOCKER_WORKDIR=/dataflow/template

init:
	python3 -m venv .venv
	@echo Please run "source .venv/bin/activate" to activate the Python environment.

build:
	pip install --upgrade pip
	pip install -r requirements.txt

template-spec:
	gcloud dataflow flex-template build $(TEMPLATE_PATH) --image "$(TEMPLATE_IMAGE)" --sdk-language "PYTHON" --metadata-file src/spec/template_metadata

build-template:
	mkdir -p _tmp/src
	cp -R src/ _tmp/src

	# Starting environment variable substitution
	cat resources/image_spec.json | TEMPLATE_IMAGE=$(TEMPLATE_IMAGE) envsubst > _tmp/src/spec/image_spec.json
	cat resources/python_command_spec.json | WORKDIR=$(DOCKER_WORKDIR) envsubst > _tmp/src/spec/python_command_spec.json
	cat Dockerfile | WORKDIR=$(DOCKER_WORKDIR) envsubst > _tmp/Dockerfile
	# End of substitution

	gcloud builds submit --project=${PROJECT} --tag ${TEMPLATE_IMAGE} _tmp/
	#rm -r _tmp

template: template-spec build-template

run:
	PYTHONPATH=./src python src/main.py \
	--input gs://dataflow-samples/shakespeare/kinglear.txt \
	--output gs://word-count-output-ppeiris/output/out \
	--temp_location gs://word-count-output-ppeiris/temp/output \
	--runner DirectRunner \
	--project $(PROJECT) \
	--max_num_workers 100    \
	--region $(REGION)        \
	--setup_file src/setup.py \
	--job_name demo-$(TIMESTAMP_IN_SECONDS)

.PHONY: run template template-spec build-template build init