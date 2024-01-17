import json
import os
import boto3

dynamodb = boto3.resource('dynamodb')
table_name = os.environ['DYNAMODB_TABLE']
table = dynamodb.Table(table_name)

def lambda_handler(event, context):
    note_id = event['pathParameters']['note_id']
    response = table.delete_item(Key={'note_id': note_id})
    if 'Item' not in response:
        return {
            'statusCode': 404,
            'body': json.dumps({'error': 'Note not found'})
        }
    return {
        'statusCode': 204,
        'body': ''
    }