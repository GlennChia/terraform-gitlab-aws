# Loadbalancer module

Application Load Balancer

## Issues and fixes

<b>Issue 1: Cannot get an SSL certificate verified</b>

Fix: Temporarily comment out the listener for HTTPs

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bastion\_security\_group\_id | The id of the bastion security group | `string` | n/a | yes |
| elb\_log\_s3\_bucket\_id | The bucket id of the bucket meant for elb logs | `string` | n/a | yes |
| http\_ingress\_security\_group\_ids | The ids of the security groups allows to hit HTTP endpoint | `list(string)` | n/a | yes |
| idle\_timeout | The time in seconds that the connection is allowed to be idle | `number` | `60` | no |
| subnet\_ids | The list of public subnet ids | `list(string)` | n/a | yes |
| vpc\_id | The id of the VPC | `string` | n/a | yes |
| whitelist\_ip | Whitelist of IPs that can reach the load balancer via HTTP or HTTPs | `list(string)` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| dns\_name | The endpoint of the load balancer |
| security\_group\_id | The id of the security group associated with the load balancer |
| target\_group\_arn | The ARN of the Target Group |

