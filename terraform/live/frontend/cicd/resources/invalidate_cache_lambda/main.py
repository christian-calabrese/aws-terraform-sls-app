import boto3
import os

# Initialize CloudFront client
cloudfront = boto3.client('cloudfront')

cloudfront_distribution_id = os.environ['CLOUDFRONT_DISTRIBUTION_ID']

def lambda_handler(event, context):
    print(event)

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