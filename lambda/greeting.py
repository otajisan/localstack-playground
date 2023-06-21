import json


def handler(event, context):
    print(event)
    print(context)

    parameters = json.loads(event['body'])

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
