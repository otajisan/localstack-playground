import sys

import boto3

minio = boto3.resource('s3', region_name='ap-northeast-1', endpoint_url='http://localhost:19000',
                       aws_access_key_id='minioadmin', aws_secret_access_key='minioadmin')

if __name__ == '__main__':
    for bucket in minio.buckets.all():
        print(bucket.name)

    if len(sys.argv) < 2:
        print('usage: minio_test.py <filename>')
        sys.exit(1)
    filename = sys.argv[1]

    bucket = minio.Bucket('my-minio-bucket')
    bucket.download_file(filename, filename)
