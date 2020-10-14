/**
* # Gitlab Image Module
*
* ## Issues and fixes
*
* <b>Issue 1: Finding the `owner` of the image</b>
*
* This [link](https://www.terraform.io/docs/configuration/data-sources.html) mentions that the `owners` tag is compulsory. To find which is the correct value, use the console to get the ami-id and then run the following command. In this case I use the ami-id of a gitlab AMI. The first command is Gitlab EE 12.9.2.The second command is Gitlab EE 13.1.4.
*
* ```bash
* aws ec2 describe-images --image-id ami-056524c0a8b3d1d92
* aws ec2 describe-images --image-id ami-099fef660cf8719e1
* ```
*
* <b>Issue 2: Configuring storage requires Gitlab 13.2 but no AMI exists</b>
*
* Begin installation from source - source only reaches to 13.1.4. Hence instead of Consolidated form, we use Storage-specific form
*
* <b>Issue 3: `sed` command was giving the correct output but the file was unchanged</b>
*
* Fix: [Link](https://stackoverflow.com/questions/14387163/linux-sed-command-does-not-change-the-target-file). Just add `-i` flag
*
* Also there is an online editor that helps test commands at this [link](https://sed.js.org/)
*
* Tip: When dealing with URLs and we need to identify the `/`, we can use `+` as the separator
*
* <b>Issue 4: Passing paramaters into a bash file</b>
*
* Refer to this [link about passing](https://github.com/terraform-providers/terraform-provider-aws/issues/5498)
*
* The [Terraform documentation](https://registry.terraform.io/providers/hashicorp/template/latest/docs/data-sources/file) shows how to pass and receive parameters 
*
* <b>Issue 5: `Error: InvalidAMIName.Duplicate: AMI name GitLab-Source is already in use by AMI ami-<id>`</b>
*
* Reproduing the error: When I run the terraform script the second name, since the image name of `GitLab-Source` already exists, it throws an error
* 
* Fix:
* * Generate a random 8 length byte that will be appended to the name to have high confidence that the name will not be duplicated. Here is the [link](https://registry.terraform.io/providers/hashicorp/random/latest/docs/resources/id)
* * Add `uuid()` to introduce randomness on each run. [Link](https://www.reddit.com/r/Terraform/comments/abtsq3/how_to_generate_a_new_random_string_everytime_i/)
* * Terraform preserves the random value each run to maintain state. [Link](https://registry.terraform.io/providers/hashicorp/random/latest/docs)
*
* ## Additional details
*
* <b>Detail 1: Manual step needed to get the private IP of the Gitaly instance</b>
*
* Since there is a cicrcular dependency, we have to manually add in the gitaly private IP. This is the helper command. Remember to change the IP
*
* ```bash
* sed -i "s/gitaly_internal_ip/10.0.3.50/" gitlab.rb
* ```
*
* <b>Detail 2: Install an SSM agent</b>
*
* Install an ssm agent to ssh directly. The image is based on Ubuntu16.04.1 LTS Xenial but I use the install for the Ubuntu16.04 (deb) as this was the one that worked with bash. [Installation link](https://docs.aws.amazon.com/systems-manager/latest/userguide/agent-install-ubuntu.html#agent-install-ubuntu-tabs)
*
* For the Grafana setup, make sure to reset the password internally. Somehow this step can't be automated. Access Grafana at `https://<dns_name>/-/grafana`
*
* ```bash
* gitlab-ctl set-grafana-password
* ${grafana_password}
* ${grafana_password}
* ```
*
* <b>Detail 3: Checking GitLab version</b>
*
* ```bash
* sudo gitlab-rake gitlab:env:info
* ```
*
*/

data "aws_iam_policy" "ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "s3" {
  name        = "gl-s3-policy"
  path        = "/"
  description = "gitlab s3 policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "s3:AbortMultipartUpload",
        "s3:CompleteMultipartUpload",
        "s3:List*",
        "s3:PutObject",
        "s3:GetObject",
        "s3:DeleteObject",
        "s3:PutObjectAcl"
      ],
      "Effect": "Allow",
      "Resource": [
        "*"
      ]
    }
  ]
}
EOF
}

resource "aws_iam_role" "this" {
  name               = "ec2-s3-ssm-association"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "ssm" {
  role       = aws_iam_role.this.name
  policy_arn = data.aws_iam_policy.ssm.arn
}

resource "aws_iam_role_policy_attachment" "s3" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.s3.arn
}

resource "aws_iam_instance_profile" "this" {
  name = "gitlab-profile"
  role = aws_iam_role.this.name
  provisioner "local-exec" {
    command = "echo ${aws_iam_instance_profile.this.arn}"
  }
}

data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20200611"]
  }

  owners = ["099720109477"]
}

data "template_file" "this" {
  template = "${file("../../modules/images/gitlab/gitlab_install_13_2_3.sh")}"

  vars = {
    rds_address                   = var.rds_address,
    redis_address                 = var.redis_address,
    rds_name                      = var.rds_name,
    rds_username                  = var.rds_username,
    rds_password                  = var.rds_password,
    dns_name                      = var.dns_name,
    visibility                    = var.visibility
    region                        = var.region,
    artifacts_bucket              = var.gitlab_artifacts_bucket_name,
    lfs_objects_bucket            = var.gitlab_lfs_bucket_name,
    uploads_bucket                = var.gitlab_uploads_bucket_name,
    packages_bucket               = var.gitlab_packages_bucket_name,
    external_diffs_bucket         = var.gitlab_external_diffs_bucket_name,
    dependency_proxy_bucket       = var.gitlab_dependency_proxy_bucket_name,
    terraform_state_bucket        = var.gitlab_terraform_state_bucket_name,
    gitaly_config                 = var.gitaly_config
    gitaly_address1               = var.private_ips_gitaly[0],
    gitaly_address2               = var.private_ips_gitaly[1],
    gitaly_address3               = var.private_ips_gitaly[2],
    praefect_address1             = var.private_ips_praefect[0],
    praefect_address2             = var.private_ips_praefect[1],
    praefect_address3             = var.private_ips_praefect[2],
    gitaly_token                  = var.gitaly_token,
    secret_token                  = var.secret_token
    praefect_external_token       = var.praefect_external_token
    prafect_loadbalancer_dns_name = var.prafect_loadbalancer_dns_name
    grafana_password              = var.grafana_password
  }
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.this.id
  iam_instance_profile   = aws_iam_instance_profile.this.name
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.this.id]
  subnet_id              = var.subnet_id
  private_ip             = var.private_ip_gitlab
  key_name               = var.gitlab_key_name
  user_data              = data.template_file.this.rendered

  tags = {
    Name = "Gitlab"
  }
}

resource "aws_security_group" "this" {
  name        = "gitlab-sec-group"
  vpc_id      = var.vpc_id
  description = "Security group for the gitlab instance"

  ingress {
    description = "Allow ingress for HTTPS, port 443 (TCP)"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.whitelist_ip
  }

  ingress {
    description     = "Allow ingress for HTTP, port 80 (TCP)"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = var.whitelist_ip
    security_groups = var.http_ingress_security_group_ids
    self            = true
  }

  ingress {
    description     = "Allow ingress for Prometheus"
    from_port       = 9090
    to_port         = 9090
    protocol        = "tcp"
    cidr_blocks     = var.whitelist_ip
    security_groups = var.prometheus_ingress_security_group_ids
    self            = true
  }

  ingress {
    description     = "Allow ingress for Git over SSH, port 22 (TCP)"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = var.ssh_ingress_security_group_ids
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gitlab-sec-group"
  }
}

resource "random_id" "this" {
  keepers = {
    uuid = "${uuid()}"
  }

  byte_length = 8
}

resource "aws_ami_from_instance" "this" {
  name               = "GitLab-source-${random_id.this.hex}"
  source_instance_id = aws_instance.this.id
}