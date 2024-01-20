import boto3
import os

# Initialize CloudFront client
cloudfront = boto3.client('cloudfront')

# Initialize S3 client
s3 = boto3.client('s3')

# Initialize Codepipeline client
codepipeline = boto3.client('codepipeline')

cloudfront_distribution_id = os.environ['CLOUDFRONT_DISTRIBUTION_ID']

def lambda_handler(event, context):
    print(event)
    try:
        bucket_name = os.getenv('FE_BUCKET_NAME')
        object_key = os.getenv('FE_OBJECT_KEY', 'index.html')
        api_endpoint = os.getenv('API_ENDPOINT')

        # Read the HTML content from S3
        response = s3.get_object(Bucket=bucket_name, Key=object_key)
        html_content = response['Body'].read().decode('utf-8')
        content_type = response.get('ContentType', 'text/html')

        # Replace the placeholder with the environment variable value
        updated_html_content = html_content.replace('{{API_ENDPOINT}}', api_endpoint)

        # Write back the updated HTML content to S3
        s3.put_object(
            Bucket=bucket_name,
            Key=object_key,
            Body=updated_html_content.encode('utf-8'),
            ContentType=content_type  # preserve the Content-Type
        )

        caller_reference = event['CodePipeline.job']['id']

        # Create Invalidation Request
        response = cloudfront.create_invalidation(
            DistributionId=cloudfront_distribution_id,
            InvalidationBatch={
                'Paths': {
                    'Quantity': 1,
                    'Items': [
                        '/*'
                    ]
                },
                'CallerReference': caller_reference
            }
        )

        print(response)

        codepipeline.put_job_success_result(jobId=event['CodePipeline.job']['id'])
    except Exception as e:
        codepipeline.put_job_failure_result(
    jobId=event['CodePipeline.job']['id'],
    failureDetails={
        'type': 'JobFailed',
        'message': str(e)
    }
)