# Summary
This package is used to build a basic AWS infrastructure with thingsboard.io deployed on a single EC2 instance.

## Requirements
- AWS CLI installed
- AWS profile configured
- SSM parameter for token id in DuckDNS


## Execute

```bash
./deploy.sh
```

This script execute the following steps:

1 - Create the infrastructure (single EC2 instance in VPC public reachable)
2 - Run a command to initialize the host