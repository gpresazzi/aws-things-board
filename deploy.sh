#!/bin/bash

# define credentials
export AWS_PROFILE=default

# Deploy cloud formation
aws cloudformation deploy --template-file ec2-vpc.yml --stack-name ec2-http-stack

# wait some time before deploying script
sleep 5

# Retrieve instance ID
instance_id=`aws ec2 describe-instances --filters "Name=tag-value,Values=instance-server" --query "Reservations[*].Instances[*].[InstanceId]" --output text`

# Set parameter using SSM
aws ssm put-parameter --name "duck-token-id" \
    --description "Duck DNS token id" \
    --value "1e595702-b998-4df6-835b-c0d3a0d48bf9" \
    --type "String"

# Send command using SSM
aws ssm send-command --document-name "AWS-RunShellScript" --instance-ids "$instance_id" --cli-input-json file://install-thinger.json