# RDS Module

Creates an RDS Instance with a security group that allows ingress from a specified security group

For dev, set `deletion_protection` to `false` and `skip_final_snapshot` to `true`

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| allocated\_storage | Allocated storage in gibibytes | `number` | `100` | no |
| auto\_minor\_version\_upgrade | Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window | `bool` | `false` | no |
| backup\_retention\_period | Number of days to retain backups for. 0-35 range | `number` | `7` | no |
| deletion\_protection | Database cannot be deleted if set to true. Override to `false` for dev | `bool` | `true` | no |
| engine | The database engine to use | `string` | `"postgres"` | no |
| engine\_version | The engine version to use | `string` | `"11.6"` | no |
| ingress\_security\_group\_ids | The list security group id of the security group that is allowed ingress | `list(string)` | n/a | yes |
| instance\_class | The instance type of the RDS instance | `string` | `"db.m4.large"` | no |
| multi\_az | Specifies if the RDS instance is multi-AZ | `bool` | `true` | no |
| password | Password for the master DB user | `string` | n/a | yes |
| publicly\_accessible | Determines  the instance is publicly accessible | `bool` | `false` | no |
| rds\_name | The name of the database to create when the DB instance is created. | `string` | `"gitlabhq_production"` | no |
| skip\_final\_snapshot | Determines whether a final DB snapshot is created before the DB instance is deleted. Override to `true` for dev | `bool` | `false` | no |
| storage\_type | Choose between `standard` (magnetic), `gp2` (general purpose SSD), or `io1` (provisioned IOPS SSD) | `string` | `"gp2"` | no |
| subnet\_ids | The list of public subnet ids | `list(string)` | n/a | yes |
| username | Username for the master DB user | `string` | n/a | yes |
| vpc\_id | The id of the VPC | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| rds\_address | The hostname of the RDS instance which does not have `port` |

