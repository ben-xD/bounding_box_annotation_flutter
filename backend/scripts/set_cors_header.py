import boto3
import os

# This script exists because Cloudflare R2 doesn't currently support changing CORS permissions without using the
# S3 API: `PutBucketCors`: https://docs.aws.amazon.com/AmazonS3/latest/API/API_PutBucketCors.html
# This only needs to run when a new bucket is created.

# These are set in environment variables.
# Generate your credentials following https://developers.cloudflare.com/r2/data-access/s3-api/tokens/
accountId = os.environ["CLOUDFLARE_ACCOUNT_ID"]
keyId = os.environ["CLOUDFLARE_S3_KEY_ID"]
secretAccessKey = os.environ["CLOUDFLARE_S3_SECRET_ACCESS_KEY"]

s3 = boto3.resource('s3',
                    endpoint_url=f"https://{accountId}.r2.cloudflarestorage.com",
                    aws_access_key_id=keyId,
                    aws_secret_access_key=secretAccessKey
                    )

print('Buckets:')
for bucket in s3.buckets.all():
    print(' - ', bucket.name)

bucket_name = "banananator"
bucket = s3.Bucket(bucket_name)
print(bucket)

cors_configuration = {
    'CORSRules': [{
        'AllowedHeaders': ['Authorization'],
        'AllowedMethods': ['GET', 'PUT'],
        'AllowedOrigins': ['*'],
        'ExposeHeaders': [],
        'MaxAgeSeconds': 3000
    }]
}

s3.BucketCors(bucket_name).put(CORSConfiguration=cors_configuration)