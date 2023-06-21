import boto3
import json

from io import BytesIO
from datetime import datetime as dt

s3 = boto3.resource('s3', region_name='ap-northeast-1', endpoint_url='http://localstack:4566')
minio = boto3.resource('s3', region_name='ap-northeast-1', endpoint_url='http://minio:9000',
                       aws_access_key_id='minioadmin', aws_secret_access_key='minioadmin')


def handler(event, context):
    print(event)
    print(context)

    parameters = json.loads(event['body'])
    error_response = validate_request_params(parameters)
    if error_response is not None:
        upload_result_to_s3(error_response)
        upload_result_to_minio(error_response)
        return error_response

    name = parameters['name']
    message = f'Hello {name}!'

    success_response = create_success_response(message, parameters)
    upload_result_to_s3(success_response)
    upload_result_to_minio(success_response)

    return success_response


def upload_result_to_s3(result):
    bucket = s3.Bucket('my-test-bucket')
    key = f'{dt.now().strftime("%Y%m%d%H%M%S")}.json'

    with BytesIO(json.dumps(result).encode('utf-8')) as filebytes:
        bucket.upload_fileobj(filebytes, key)


def upload_result_to_minio(result):
    bucket = minio.Bucket('my-minio-bucket')
    key = f'{dt.now().strftime("%Y%m%d%H%M%S")}.json'

    with BytesIO(json.dumps(result).encode('utf-8')) as filebytes:
        bucket.upload_fileobj(filebytes, key)


def create_success_response(message, parameters):
    return {
        'statusCode': 200,
        'headers': {
            'content-type': 'application/json',
        },
        'isBase64Encoded': False,
        'body': {
            'message': message,
            'parameters': parameters,
        }
    }


def validate_request_params(parameters):
    if 'name' not in parameters:
        return {
            'statusCode': 400,
            'headers': {
                'content-type': 'application/json',
            },
            'isBase64Encoded': False,
            'body': {
                'message': 'name is required.',
            }
        }

    return None
