/**
* # Storage module
*
* Contains the buckets for the following:
*
* * Access logs for elb
* * All GitLab related buckets
*
* For Prod, consider setting `force_destroy` to `false`
*/

data "aws_elb_service_account" "classicLB" {}

resource "aws_s3_bucket" "loadbalancer_access_logs" {
  bucket        = "gl-entry"
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
      "Resource": "arn:aws:s3:::gl-entry/AWSLogs/*",
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