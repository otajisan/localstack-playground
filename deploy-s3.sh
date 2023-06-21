#!/bin/bash

echo \
  "my-test-bucket" |\
xargs -r -n 1 bash -c 'aws s3api delete-bucket --bucket ${0} --endpoint-url http://localhost:14566 --profile localstack'

BUCKET_CREATED_RESULT=$(echo \
  "my-test-bucket" |\
xargs -r -n 1 bash -c 'aws s3api create-bucket --bucket ${0} --endpoint-url http://localhost:14566 --profile localstack --create-bucket-configuration LocationConstraint=ap-northeast-1')

echo "Bucket created result: ${BUCKET_CREATED_RESULT}"

aws s3 ls --endpoint-url=http://localhost:14566 --profile localstack