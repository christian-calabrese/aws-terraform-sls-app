import json
import os
import uuid
import boto3

dynamodb = boto3.resource('dynamodb')
table_name = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    data = json.loads(event['body'])
    if 'title' not in data:
        return {
            'statusCode': 400,
            'body': json.dumps({'error': 'title is required'}),
            'headers': {
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': os.environ['CUSTOM_DOMAIN_NAME'] if os.environ.get('CUSTOM_DOMAIN_NAME', '') != '' else '*',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            }
        }
    note = {
        'note_id': str(uuid.uuid4()),
        'title': data['title'],
        'content': data.get('content', ''),
    }
    table.put_item(Item=note)
    return {
        'statusCode': 201,
        'body': json.dumps(note),
        'headers': {
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': os.environ['CUSTOM_DOMAIN_NAME'] if os.environ.get('CUSTOM_DOMAIN_NAME', '') != '' else '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        }
    }