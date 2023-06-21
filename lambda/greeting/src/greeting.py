import json


def handler(event, context):
    print(event)
    print(context)

    parameters = json.loads(event['body'])

    error_response = validate_request_params(parameters)

    if error_response is not None:
        return error_response

    name = parameters['name']
    message = f'Hello {name}!'

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