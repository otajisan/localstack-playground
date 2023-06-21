#!/bin/bash

echo '# configure aws profile for local'
aws configure --profile localstack set region ap-northeast-1
aws configure --profile localstack set aws_access_key_id localstack
aws configure --profile localstack set aws_secret_access_key localstack

#echo '# compress lambda'
#rm -f greeting.zip
#zip greeting.zip lambda/greeting.py


echo '# delete previous lambda'
aws lambda delete-function \
  --endpoint-url=http://localhost:14566 \
  --function-name greeting \
  --region ap-northeast-1 \
  --profile localstack

echo '# create lambda'
LAMBDA_CREATED_RESULT=$(aws lambda create-function \
  --endpoint-url=http://localhost:14566 \
  --function-name greeting \
  --runtime python3.9 \
  --zip-file fileb://greeting.zip \
  --handler greeting.handler \
  --role 'arn:aws:iam::123456789000:role/irrelevant' \
  --region ap-northeast-1 \
  --profile localstack)

echo "Lambda created result: ${LAMBDA_CREATED_RESULT}"

echo '# execute lambda'
LAMBDA_INVOCATION_RESULT=$(aws lambda invoke \
  --endpoint-url=http://localhost:14566 \
  --function-name greeting \
  --invocation-type RequestResponse \
  --log-type Tail \
  --payload file://lambda-input.json \
  --profile localstack \
  --region ap-northeast-1 \
  --cli-binary-format raw-in-base64-out \
  lambda-result.log)

echo "Lambda invocation result: ${LAMBDA_INVOCATION_RESULT}"

echo "=== Result ==="
cat lambda-result.log | jq