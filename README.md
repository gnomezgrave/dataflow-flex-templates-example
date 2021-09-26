# Dataflow Flex Templates Example
This repo holds a sample code required to deploy a Dataflow job using Flex templates.

## What is Dataflow?

[Dataflow](https://cloud.google.com/dataflow) is a fully managed [Apache Beam](https://beam.apache.org/) service provided by [Google Cloud Platform (GCP)](https://cloud.google.com/). You only have to pay for the resources it uses for your pipeline and the rest (spawning, scaling, and teardown) is handled by GCP.

![Dataflow example](https://i0.wp.com/gnomezgrave.com/wp-content/uploads/2020/11/WordCount-Graph.png?w=744&ssl=1)

## What are Flex Templates?

Flex templates for metadata definition method for our Apache Beam pipeline to allow us passing dynamic parameters because the Directed Acyclic Graph (DAG) for the pipeline is created on-the-fly.

To know more about Flex Templates, please read [my blog article](https://gnomezgrave.com/2020/11/21/dataflow-flex-templates-and-how-to-use-them/).

## Repo Structure

Here is the structure of this repo.

### Source code

The source code of the pipeline is stored inside `src` folder, where it will have `demo` folder for our sample pipeline. If we need to have multiple pipelines in the same repo, we can add it inside `src`.

Each pipline (i.e. `demo`) ideally has the folder structure as below.

```
├── Dockerfile
├── resources
│   ├── image_spec.json
│   └── python_command_spec.json
└── src
    ├── demo
    │   ├── __init__.py
    │   ├── main.py
    │   ├── pipeline
    │   │   ├── __init__.py
    │   │   └── word_count.py
    │   ├── requirements.txt
    │   ├── setup.py
    │   └── spec
    │       └── template_metadata
```
* `Dockerfile`  
This contains the Docker image definition for our pipeline. There are several important values to be set, and they're mentioned inside the Dockerfile.

* `resources/image_spec.json`  
This file declares the Docker Image from Google Container Registry (GCR) that contains the source code for the pipeline. So, we must push our pipeline as an image to GCR before triggering the pipeline.

* `resources/python_command_spec`  
This contains the main file for the pipeline. Usually this directs to `/dataflow/pipeline/main.py`. This file can be skipped if we set `FLEX_TEMPLATE_PYTHON_PY_FILE` inside the `Dockerfile`.

* `main.py`  
The entry point for the pipeline. This extracts arguments for the pipeline and triggers it.

* `pipeline/*`  
This folder contains the source code for our pipeline. We usually create a `pipeline.py` with a `run()` functions which triggers the beam pipeline. However, feel free to have any structure as long as you call the `pipeline.run()` (or a function which does it) from `main.py`. Please note that have `word_count.py` to define our pipeline in this example.

* `setup.py`  
This file contains the deployment instructions for the pipeline source code package. It also contains the third-party dependencies for our pipeline, including `apache-beam`.

* `requirements.txt`  
This file contains the requirements for our pipeline to run locally. It most probably will have the same dependencies as mentioned in the setup file.

* `spec/template_metadata`  
This file specifies the metadata for the pipeline as a template. This file also includes the parameters for our pipeline, and should be built as a flex template before using.

## How to build?

### Prerequisites

* First of all, we need to point to the GCP project we're going to use by setting the `PROJECT` variable in the `Makefile`. 

* Make sure that you have a Google Cloud Storage (GCS) bucket defined with `TEMPLATE_BUCKET` in the project and you have access with the current Service Account. 

* Make sure to update the region you want Dataflow to run by setting `REGION` value in the `Makefile`.

* Check whether you have Docker client running.

* Make sure you can push to GCR.  
    * Authenticate for GCP: `gcloud auth login`
    * Authenticate for Docker: `gcloud auth configure-docker`

If this is the first time you're using the project with Dataflow, you might need to enable Dataflow API for the project.

### Steps

1. Create a virtual environment for the project and enable it.  
    ```shell
    make init
    source ./.venv/bin/activate
    ```
2. Install the dependencies.  
    ```shell
    make build
    ```
3. Build the Flex Template.  
    ```shell
    make template
    ```  
    This command will run the `build-template` recipe and it will replace some variables defined in the `Dockerfile` to create a new `Dockerfile` inside `_tmp` folder. Then this new `Dockerfile` is used to build the pipeline code.

With these steps, we have built a Docker image with our pipeline source code and pushed to GCR. Now we can trigger it using the Dataflow API.

## Running the pipeline

### Prerequisites

* Make sure the GCS paths defined in the pipeline parameters are present.
* Make sure your project has access to the subnet defined in the `subnetwork` parameter to run dataflow jobs.

### Run

You have simply run the `run_dataflow.py` file that already has the basic code for triggering the Dataflow pipeline using Flex Templates.

```shell
make run
```

Or, you can use the `gcloud beta dataflow flex-template run` command to trigger the pipeline as well. You can read more on how to do it at the [docs](https://cloud.google.com/sdk/gcloud/reference/beta/dataflow/flex-template/run).

## CI/CD

You can use the `Makefile` recipes in any CI/CD framework you prefer, however you need to define `GOOGLE_APPLICATION_CREDENTIALS` with a proper Service Account.