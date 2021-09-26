import os

from googleapiclient.discovery import build
from oauth2client.client import GoogleCredentials

credentials = GoogleCredentials.get_application_default()
# cache_discovery should be set to False to avoid errors
dataflow = build('dataflow', 'v1b3', credentials=credentials, cache_discovery=False)

project_id = os.getenv('PROJECT')
dataflow_region = os.getenv('REGION')


request = dataflow.projects().locations().flexTemplates().launch(
        projectId=project_id,
        location=dataflow_region,
        body={
            'launch_parameter': {
                'jobName': 'my-job-name-12',
                'parameters': {
                    'input': 'gs://dataflow-samples/shakespeare/kinglear.txt',
                    'output': 'gs://wordcount_output_ppeiris/output/out',
                    'temp_location': 'gs://wordcount_output_ppeiris/temp/output',
                    'subnetwork': 'subnet_uri_to_run_dataflow',
                    'setup_file': '/dataflow/template/setup.py'
                },
                'environment': {
                    'additionalUserLabels': {
                        'name': 'flex_templates_example'
                    }
                },
                'containerSpecGcsPath': 'gs://flex-templates-ppeiris/ppeiris/python_command_spec.json',
            }
        }
    )

request.execute()
