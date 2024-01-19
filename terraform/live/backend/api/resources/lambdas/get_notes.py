import json
import os
import boto3

dynamodb = boto3.resource('dynamodb')
table_name = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    response = table.scan(Limit=10)
    if 'Items' not in response:
        return {
            'statusCode': 404,
            'body': json.dumps({'error': 'Notes not found'}),
            'headers': {
                'Access-Control-Allow-Headers': 'Content-Type',
                'Access-Control-Allow-Origin': os.environ['CUSTOM_DOMAIN_NAME'] if os.environ.get('CUSTOM_DOMAIN_NAME', '') != '' else '*',
                'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
            }
        }
    return {
        'statusCode': 200,
        'body': json.dumps(response['Items']),
        'headers': {
            'Access-Control-Allow-Headers': 'Content-Type',
            'Access-Control-Allow-Origin': os.environ['CUSTOM_DOMAIN_NAME'] if os.environ.get('CUSTOM_DOMAIN_NAME', '') != '' else '*',
            'Access-Control-Allow-Methods': 'OPTIONS,POST,GET'
        }
    }