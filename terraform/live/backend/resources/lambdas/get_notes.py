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
            'body': json.dumps({'error': 'Notes not found'})
        }
    return {
        'statusCode': 200,
        'body': json.dumps(response['Items'])
    }