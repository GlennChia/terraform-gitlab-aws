#! /bin/bash

aws configure set region ${region}
aws ec2 wait instance-running --instance-id $(curl http://169.254.169.254/latest/meta-data/instance-id)
aws ec2 associate-address --instance-id $(curl http://169.254.169.254/latest/meta-data/instance-id) --allocation-id ${eip} --allow-reassociation