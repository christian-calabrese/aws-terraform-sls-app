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
            'body': json.dumps({'error': 'title is required'})
        }
    note = {
        'note_id': str(uuid.uuid4()),
        'title': data['title'],
        'content': data.get('content', ''),
    }
    table.put_item(Item=note)
    return {
        'statusCode': 201,
        'body': json.dumps(note)
    }