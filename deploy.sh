#!/bin/bash

# define credentials
export AWS_PROFILE=default

# Deploy cloud formation
aws cloudformation deploy --template-file ec2-vpc.yml --stack-name ec2-http-stack

# wait some time before deploying script
sleep 5

instance_id=`aws ec2 describe-instances --filters "Name=tag-value,Values=instance-server" --query "Reservations[*].Instances[*].[InstanceId]" --output text`
aws ssm send-command --document-name "AWS-RunShellScript" --instance-ids "$instance_id" --cli-input-json file://install-thinger.json