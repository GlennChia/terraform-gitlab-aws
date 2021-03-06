# Gitaly Cluster Module

Creates a HA Gitaly cluster with Praefect nodes behind a loadbalancer

For dev, set `deletion_protection` to `false` and `skip_final_snapshot` to `true`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allocated\_storage | Allocated storage in gibibytes | `number` | `100` | no |
| auto\_minor\_version\_upgrade | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window | `bool` | `false` | no |
| backup\_retention\_period | Number of days to retain backups for. 0-35 range | `number` | `7` | no |
| custom\_ingress\_security\_group\_id | The id of the security group allowed to communicate with Praefect | `string` | `""` | no |
| deletion\_protection | Database cannot be deleted if set to true. Override to `false` for dev | `bool` | `true` | no |
| engine | The database engine to use | `string` | `"postgres"` | no |
| engine\_version | The engine version to use | `string` | `"11.6"` | no |
| gitaly\_key\_name | The key name of a key that has already been created that will be attached to the gitaly instance | `string` | n/a | yes |
| iam\_instance\_profile | IAM instance profile to associate with the Gitaly and Praefect instance | `string` | n/a | yes |
| ingress\_security\_group\_ids | The list security group id of the security group that is allowed ingress | `list(string)` | n/a | yes |
| instance\_class | The instance type of the RDS instance | `string` | `"db.m4.large"` | no |
| instance\_dns\_name | Domain that users will reach to access GitLab if using a public instance | `string` | n/a | yes |
| lb\_dns\_name | Domain that users will reach to access GitLab if using a load balancer | `string` | n/a | yes |
| multi\_az | Specifies if the RDS instance is multi-AZ | `bool` | `true` | no |
| praefect\_external\_token | Token needed by clients outside the cluster (like GitLab Shell) to communicate with the Praefect cluster | `string` | n/a | yes |
| praefect\_instance\_type | Instance type for the praefect instance | `string` | `"c5.xlarge"` | no |
| praefect\_internal\_token | Token needed by to communicate with the Gitaly cluster | `string` | n/a | yes |
| praefect\_key\_name | The key name of a key that has already been created that will be attached to the praefect instance | `string` | n/a | yes |
| praefect\_sql\_password | Password for the praefect db user | `string` | n/a | yes |
| private\_ips\_gitaly | Assigned private ips to gitaly instances | `list(string)` | n/a | yes |
| private\_ips\_praefect | Assigned private ips to praefect instances | `list(string)` | n/a | yes |
| prometheus\_ingress\_security\_group\_id | The id of the security group allowed to hit prometheus endpoint | `string` | `""` | no |
| publicly\_accessible | Determines  the instance is publicly accessible | `bool` | `false` | no |
| rds\_name | The name of the database to create when the DB instance is created. | `string` | `"gitalyhq_production"` | no |
| rds\_password | Password for the master DB user | `string` | n/a | yes |
| rds\_username | Username for the master DB user | `string` | n/a | yes |
| secret\_token | The token for authentication callbacks from GitLab Shell to the GitLab internal API | `string` | n/a | yes |
| skip\_final\_snapshot | Determines whether a final DB snapshot is created before the DB instance is deleted. Override to `true` for dev | `bool` | `false` | no |
| ssh\_ingress\_security\_group\_id | The id of the security group allowed to ssh | `string` | `""` | no |
| storage\_type | Choose between `standard` (magnetic), `gp2` (general purpose SSD), or `io1` (provisioned IOPS SSD) | `string` | `"gp2"` | no |
| subnet\_ids | The list of private subnet ids | `list(string)` | n/a | yes |
| visibility | Determines if the instance is private (behind a loadbalancer) or public (using its own dns) | `string` | `"private"` | no |
| vpc\_cidr | VPC Cidr Range used to allow Praefect NLB healthcheck to reach instances | `string` | `"10.0.0.0/16"` | no |
| vpc\_id | The id of the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| gitaly\_security\_group\_id | The id of the security group associated with the Gitaly instance |
| prafect\_loadbalancer\_dns\_name | The dns name associated with the Praefect loadbalancer |

