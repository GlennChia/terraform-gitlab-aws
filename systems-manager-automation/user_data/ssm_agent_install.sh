#!/bin/bash -xe
sudo dnf install -y https://s3.ap-southeast-1.amazonaws.com/amazon-ssm-ap-southeast-1/latest/linux_amd64/amazon-ssm-agent.rpm
sudo systemctl enable amazon-ssm-agent
sudo systemctl start amazon-ssm-agent