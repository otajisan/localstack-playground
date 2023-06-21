#!/bin/bash

#LAMBDA_ARN=arn:aws:lambda:ap-northeast-1:123456789000:function:greeting
LAMBDA_ARN=$(aws lambda get-function \
  --function-name greeting \
  --endpoint-url=http://localhost:14566 \
  --region ap-northeast-1 \
  --profile localstack --query 'Configuration.FunctionArn')

LAMBDA_ARN=arn:aws:lambda:ap-northeast-1:000000000000:function:greeting
echo "Lambda ARN: ${LAMBDA_ARN}"

REST_API_IDS=$(aws apigateway get-rest-apis \
  --endpoint-url=http://localhost:14566 \
  --region ap-northeast-1 \
  --profile localstack | jq -r '.items[].id')

# shellcheck disable=SC2068
for REST_API_ID in ${REST_API_IDS[@]}; do
  echo "Deleting previous REST API. ID: ${REST_API_ID}"
  aws apigateway delete-rest-api \
    --endpoint-url=http://localhost:14566 \
    --rest-api-id "${REST_API_ID}" \
    --region ap-northeast-1 \
    --profile localstack
done

API_GATEWAY_ID=$(aws apigateway create-rest-api \
  --endpoint-url=http://localhost:14566 \
  --name greeting \
  --region ap-northeast-1 \
  --profile localstack | jq -r '.id')

echo "API Gateway ID: ${API_GATEWAY_ID}"

ROOT_RESOURCE_ID=$(aws apigateway get-resources \
  --endpoint-url=http://localhost:14566 \
  --rest-api-id "${API_GATEWAY_ID}" \
  --region ap-northeast-1 \
  --profile localstack | jq -r '.items[].id')

echo "Root Resource ID: ${ROOT_RESOURCE_ID}"

RESOURCE_ID=$(aws apigateway create-resource \
  --endpoint-url=http://localhost:14566 \
  --rest-api-id "${API_GATEWAY_ID}" \
  --parent-id "${ROOT_RESOURCE_ID}" \
  --path-part {proxy+} \
  --region ap-northeast-1 \
  --profile localstack | jq -r '.id')

echo "Resource ID: ${RESOURCE_ID}"

CREATED_METHOD=$(aws apigateway put-method \
  --endpoint-url=http://localhost:14566 \
  --rest-api-id "${API_GATEWAY_ID}" \
  --resource-id "${RESOURCE_ID}" \
  --http-method ANY \
  --authorization-type NONE \
  --region ap-northeast-1 \
  --profile localstack)

echo "Created Method: ${CREATED_METHOD}"

CREATED_INTEGRATION=$(aws apigateway put-integration \
  --endpoint-url=http://localhost:14566 \
  --rest-api-id "${API_GATEWAY_ID}" \
  --resource-id "${RESOURCE_ID}" \
  --http-method ANY \
  --type AWS_PROXY \
  --integration-http-method POST \
  --uri arn:aws:apigateway:ap-northeast-1:lambda:path/2015-03-31/functions/${LAMBDA_ARN}/invocations \
  --credentials arn:aws:iam::000000000000:role/apigAwsProxyRole \
  --passthrough-behavior WHEN_NO_MATCH \
  --region ap-northeast-1 \
  --profile localstack)

echo "Created Integration: ${CREATED_INTEGRATION}"

CREATED_DEPLOYMENT=$(aws apigateway create-deployment \
  --endpoint-url=http://localhost:14566 \
  --rest-api-id "${API_GATEWAY_ID}" \
  --stage-name local \
  --region ap-northeast-1 \
  --profile localstack)

echo "Created Deployment: ${CREATED_DEPLOYMENT}"

TEST_RESULT=$(aws apigateway test-invoke-method \
  --endpoint-url=http://localhost:14566 \
  --rest-api-id "${API_GATEWAY_ID}" \
  --resource-id "${RESOURCE_ID}" \
  --http-method ANY \
  --path-with-query-string '' \
  --body '{"name": "otajisan"}' \
  --headers 'Content-Type=application/json' \
  --region ap-northeast-1 \
  --profile localstack)

echo "Test Result: ${TEST_RESULT}"

API_GATEWAY_URL="http://localhost:14566/restapis/${API_GATEWAY_ID}/local/_user_request_/greeting"

echo "API Gateway URL: ${API_GATEWAY_URL}"

TEST_CMD="curl -i -X POST \
  -H 'content-type: application/json' \
  ${API_GATEWAY_URL} \
  -d '{\"name\": \"otajisan\"}'"

echo "Test command:"
echo "${TEST_CMD}"

