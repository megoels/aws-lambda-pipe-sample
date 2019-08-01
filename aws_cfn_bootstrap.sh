#!/bin/bash -e

STACK_NAME="create-digit-count-pipeline"
TEMPLATE_URL="file://create_pipeline.yml"
LAMBDA_FUNC_NAME="digit-count out"

if [ -z ${1} ]
then
	echo "PIPELINE CREATION FAILED!"
        echo "Pass your Github OAuth token as the first argument"
	exit 1
fi

#aws configure
if [[ "$*" == *-d* ]]
then
        echo "Will delete the stack $STACK_NAME ..."
        aws cloudformation delete-stack --stack-name $STACK_NAME 
        exit $?
fi

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
echo "Waiting until stack $STACK_NAME updated..."
aws cloudformation wait stack-create-complete --stack-name $STACK_NAME
# returns description for the created stack
aws cloudformation describe-stacks --stack-name $STACK_NAME

echo "Waiting for Lambda fuction to be created..."
aws lambda wait function-exists --function-name $LAMBDA_FUNC_NAME
echo "Executing Lambda function $LAMBDA_FUNC_NAME ..."
aws lambda invoke --function-name $LAMBDA_FUNC_NAME out --log-type Tail --query 'LogResult' --output text |  base64 -di
