#!/bin/bash

echo '# configure aws profile for local'
aws configure --profile localstack set region ap-northeast-1
aws configure --profile localstack set aws_access_key_id localstack
aws configure --profile localstack set aws_secret_access_key localstack
