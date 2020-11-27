# Systems manager automation

Purpose: Uses SSM documents to automate the creation of AMIs needed for different components of GitLab

# 1. Pre-Requisites

Setting up VPC endpoints needed to allow systems manager automation to recognise when a command has been completed

* Run cloudformation-pre-requisites/cfn-vpce.yaml

Setting up Instance profile needed to use session manager to connect to the instance and allow the instances to send logs to CloudWatch

* Run cloudformation-pre-requisites/cfn-instance-profile.yaml

# 2. Preparing the base GitLab image

This image installs the SSM agent and then GitLab. This base image can be used as a base to build GitLab, Praefect and Gitaly.

1. First run entrypoint-gitlab-base.sh to generate the user data
2. Then run gitlab-base.yaml in SSM documents and execute automation