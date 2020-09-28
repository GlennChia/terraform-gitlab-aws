/**
* # Storage module
*
* Contains the buckets for the following:
*
* * Access logs for elb
* * All GitLab related buckets
*
* For Prod, consider setting `force_destroy` to `false`
*
* For S3 bucket policies, if we want to restrict to certain actions use the following
*
* ```json
* {
*   "Version": "2012-10-17",
*   "Id": "GitLabVPCE",
*   "Statement": [
*     {
*       "Sid": "AccessToSpecificVPCEOnly1",
*       "Effect": "Allow",
*       "Action": [
*         "s3:AbortMultipartUpload",
*         "s3:PutObject",
*         "s3:GetObject",
*         "s3:DeleteObject",
*         "s3:PutObjectAcl"
*       ],
*       "Principal": {
*         "Service": "ec2.amazonaws.com"
*       },
*       "Resource": [
*         "arn:aws:s3:::${var.gitlab_buckets[count.index]}/*"
*       ],
*       "Condition": {
*         "StringEquals": {
*           "aws:sourceVpce": "${var.vpce_id}"
*         }
*       }
*     },
*     {
*       "Sid": "AccessToSpecificVPCEOnly2",
*       "Effect": "Allow",
*       "Action": [
*         "s3:ListBucket"
*       ],
*       "Principal": {
*         "Service": "ec2.amazonaws.com"
*       },
*       "Resource": [
*         "arn:aws:s3:::${var.gitlab_buckets[count.index]}"
*       ],
*       "Condition": {
*         "StringEquals": {
*           "aws:sourceVpce": "${var.vpce_id}"
*         }
*       }
*     }
*   ]
* }
* ```
*
*/

data "aws_elb_service_account" "classicLB" {}

resource "aws_s3_bucket" "loadbalancer_access_logs" {
  bucket        = var.load_balancer_bucket
  acl           = var.acl
  force_destroy = var.force_destroy

  policy = <<POLICY
{
  "Id": "Policy",
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:PutObject"
      ],
      "Effect": "Allow",
      "Resource": "arn:aws:s3:::${var.load_balancer_bucket}/AWSLogs/*",
      "Principal": {
        "AWS": [
          "${data.aws_elb_service_account.classicLB.arn}"
        ]
      }
    }
  ]
}
POLICY

  tags = {
    Name = "gl-entry"
  }
}

resource "aws_s3_bucket" "this" {
  count = length(var.gitlab_buckets)

  bucket        = var.gitlab_buckets[count.index]
  acl           = var.acl
  force_destroy = var.force_destroy

  tags = {
    Name = "${var.gitlab_buckets[count.index]}"
  }
}

resource "aws_s3_bucket_policy" "this" {
  count = length(var.gitlab_buckets)

  bucket = aws_s3_bucket.this[count.index].id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Id": "GitLabVPCE",
  "Statement": [
    {
      "Sid": "AccessToSpecificVPCEOnly1",
      "Effect": "Allow",
      "Action": "s3:*",
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
    }
  ]
}
POLICY
}