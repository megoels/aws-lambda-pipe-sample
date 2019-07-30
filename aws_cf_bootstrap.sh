#!/bin/bash -e

STACK_NAME="create-digit-count-pipeline"
TEMPLATE_URL="file://create_pipeline.yml"

if [ -z ${1} ]
then
	echo "PIPELINE CREATION FAILED!"
        echo "Pass your Github OAuth token as the first argument"
	exit 1
fi

#aws configure

if [[ "$*" == *-u* ]]
then
        aws cloudformation update-stack \
                --stack-name $STACK_NAME \
                --template-body $TEMPLATE_URL \
                --capabilities CAPABILITY_IAM \
                --parameters ParameterKey=GitHubOAuthToken,ParameterValue=${1}
else
        aws cloudformation create-stack \
                --stack-name $STACK_NAME \
                --template-body $TEMPLATE_URL \
                --capabilities CAPABILITY_IAM \
                --parameters ParameterKey=GitHubOAuthToken,ParameterValue=${1}
fi

aws cloudformation wait stack-create-complete --stack-name $STACK_NAME
aws cloudformation describe-stacks --stack-name $STACK_NAME

# execute the lambda function
aws lambda invoke --function-name digit-count out --log-type Tail --query 'LogResult' --output text |  base64 -d
