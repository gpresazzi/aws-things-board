# Summary
This package is used to build a basic AWS infrastructure with thingsboard.io deployed on a single EC2 instance.

## Requirements
- AWS CLI installed
- AWS profile configured
- SSM parameter for token id in DuckDNS


## Execute

To create the AWS stack (single EC2 instance in VPC public reachable)
```bash
./deploy.sh create_stack
```

Run a command to initialize the host with docker container
```bash
./deploy.sh init_instance
```