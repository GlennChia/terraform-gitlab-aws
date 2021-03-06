# Storage module

Contains the buckets for the following:

* Access logs for elb
* All GitLab related buckets

For Prod, consider setting `force_destroy` to `false`

For S3 bucket policies, if we want to restrict to certain actions use the following

```json
{
  "Version": "2012-10-17",
  "Id": "GitLabVPCE",
  "Statement": [
    {
      "Sid": "AccessToSpecificVPCEOnly1",
      "Effect": "Allow",
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObjectAcl"
      ],
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Resource": [
        "arn:aws:s3:::${var.gitlab_buckets[count.index]}/*"
      ],
      "Condition": {
        "StringEquals": {
          "aws:sourceVpce": "${var.vpce_id}"
        }
      }
    },
    {
      "Sid": "AccessToSpecificVPCEOnly2",
      "Effect": "Allow",
      "Action": [
        "s3:ListBucket"
      ],
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Resource": [
        "arn:aws:s3:::${var.gitlab_buckets[count.index]}"
      ],
      "Condition": {
        "StringEquals": {
          "aws:sourceVpce": "${var.vpce_id}"
        }
      }
    }
  ]
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| acl | The canned ACL to apply. Options are `private`, `public-read`, `public-read-write` among others | `string` | `"private"` | no |
| force\_destroy | Indicates that all objects should be deleted from the bucket so that it can be destroyed without error | `bool` | `true` | no |
| gitlab\_buckets | List of gitlab buckets to create | `list(string)` | <pre>[<br>  "gl-aws-artifacts",<br>  "gl-aws-external-diffs",<br>  "gl-aws-lfs-objects",<br>  "gl-aws-uploads",<br>  "gl-aws-packages",<br>  "gl-aws-dependency-proxy",<br>  "gl-aws-terraform-state",<br>  "gl-aws-runner-cache"<br>]</pre> | no |
| load\_balancer\_bucket | Bucket for the load balancer | `string` | `"gl-entry"` | no |
| vpce\_id | Id of the VPCE to associate with bucket policy | `string` | n/a | yes |

## Outputs

| Name | Description |
|------|-------------|
| elb\_log\_s3\_bucket\_id | The bucket id of the bucket meant for elb logs |

