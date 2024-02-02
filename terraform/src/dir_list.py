import boto3
import os
import json

def handler(event, context):

    bucket_name = os.getenv("BUCKET_NAME")
    s3 = boto3.client('s3')
    exclude_files = ["index.html", "_"]

    try:
        response = s3.list_objects_v2(Bucket=bucket_name, Delimiter='/')
        
        all_objects = []
        
        if 'Contents' in response:
            for obj in response['Contents']:
                key = obj['Key']
                if not any(key.startswith(exclude) for exclude in exclude_files):
                    all_objects.append(key)

        if 'CommonPrefixes' in response:
            for prefix in response['CommonPrefixes']:
                directory = prefix['Prefix']
                if not any(directory.startswith(exclude) for exclude in exclude_files):
                    all_objects.append(directory)
                    
        response_body = {
            'objects': all_objects,
        }

    except Exception as e:
        print(f"An error occurred: {str(e)}")
        response_body = {
            'error': f"An error occurred: {str(e)}",
        }

    return {
        'statusCode': 200,
        'body': json.dumps(response_body),
    }
