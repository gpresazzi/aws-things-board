#!/bin/bash

# exit when any command fails
set -e

# define credentials
export AWS_PROFILE=default
export AWS_PAGER=""

create_stack () {
    # Deploy cloud formation
    aws cloudformation deploy --template-file ec2-vpc.yml --stack-name ec2-http-stack --capabilities CAPABILITY_IAM
    echo "Stack created"

    
    # Set parameter using SSM
    aws ssm put-parameter --name "duck-token-id" \
        --description "Duck DNS token id" \
        --value "1e595702-b998-4df6-835b-c0d3a0d48bf9" \
        --type "String" \
        --overwrite
    echo "Parameter created"
}


execute_init_command () {
    # Retrieve instance ID
    instance_id=`aws ec2 describe-instances --filters Name=tag-value,Values=instance-server Name=instance-state-name,Values=running --query "Reservations[*].Instances[*].[InstanceId]" --output text`

    # Send command using SSM
    aws ssm send-command --document-name "AWS-RunShellScript" --instance-ids "$instance_id" --cli-input-json file://install-thinger.json
}

if [ "$1" = "create_stack" ]; then
    create_stack
elif [ "$1" = "init_instance" ]; then
    execute_init_command
else
    echo "Use the arguments 'create_stack' or 'init_instance' to create the stack or initialize the instance"
fi