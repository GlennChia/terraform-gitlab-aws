# Gitaly Module

## Issues and fixes

<b>Issue 1: Connection failed when I run the check</b>

Reason: When I terraform apply, sometimes the new public dns name of the GitLab instance does not update.

Fix: Manually check the file to see if it updates and ensure that there is either http or https prefixed. Alternatively, run `terraform refresh` before apply

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| bastion\_security\_group\_id | The id of the bastion security group | `string` | n/a | yes |
| custom\_ingress\_security\_group\_id | The security group id of the security group that is allowed ingress on custom port 8075 | `string` | n/a | yes |
| delete\_on\_termination | Whether the volume should be destroyed on instance termination | `bool` | `true` | no |
| gitaly\_token | The token authenticate gRPC requests to Gitaly | `string` | n/a | yes |
| iam\_instance\_profile | IAM instance profile to associate with the Gitaly instance | `string` | n/a | yes |
| instance\_dns\_name | Domain that users will reach to access GitLab if using a public instance | `string` | n/a | yes |
| instance\_type | Instance type for the Gitaly instance | `string` | `"c5.xlarge"` | no |
| iops | The amount of provisioned IOPS. You can provision up to 50 IOPS per GiB. | `number` | `1000` | no |
| key\_name | The key name of a key that has already been created that will be attached to the Gitaly instance | `string` | n/a | yes |
| lb\_dns\_name | Domain that users will reach to access GitLab if using a load balancer | `string` | n/a | yes |
| private\_ip | Assigned private ip to gitaly instance | `string` | n/a | yes |
| secret\_token | The token for authentication callbacks from GitLab Shell to the GitLab internal API | `string` | n/a | yes |
| subnet\_id | Private subnet id | `string` | n/a | yes |
| visibility | Determines if the instance is private (behind a loadbalancer) or public (using its own dns) | `string` | `"private"` | no |
| volume\_size | The size of the volume in gibibytes (GiB) | `number` | `20` | no |
| volume\_type | The type of volume. Can be standard, gp2, io1, sc1 or st1 | `string` | `"io1"` | no |
| vpc\_id | The id of the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| private\_ip | The internal ip associated with the gitlay instance. Used when configuring the GitLab instance |
| security\_group\_id | The id of the security group associated with the gitaly instance |

