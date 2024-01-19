import json
import os
import boto3

dynamodb = boto3.resource('dynamodb')
table_name = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    note_id = event['pathParameters']['note_id']
    response = table.get_item(Key={'note_id': note_id})
    if 'Item' not in response:
        return {
            'statusCode': 404,
            'body': json.dumps({'error': 'Note not found'}),
            'headers': {
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': os.environ['CUSTOM_DOMAIN_NAME'] if os.environ.get('CUSTOM_DOMAIN_NAME', '') != '' else '*',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            }
        }
    return {
        'statusCode': 200,
        'body': json.dumps(response['Item']),
        'headers': {
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': os.environ['CUSTOM_DOMAIN_NAME'] if os.environ.get('CUSTOM_DOMAIN_NAME', '') != '' else '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        }
    }