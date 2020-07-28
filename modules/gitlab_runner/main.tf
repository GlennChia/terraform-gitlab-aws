/**
* # GitLab Runner Module
*
* ## Issues and fixes
*
* <b>Issue 1: Getting a token for a shared runner</b>
* 
* The documentation did not specify where to get a shared runner token. After clicking around, it is Admin area -> Overview -> Runners -> Set up Shared Runner manually -> Grab token from here
*
* <b>Issue 2: `status=couldn't execute POST against` reason is `dial tcp 52.221.35.242:80: i/o timeout`</b>
*
* Solution: use the Docker version for registering runners [here](https://docs.gitlab.com/runner/register/index.html#docker)
*
* ## Additional details
*
* For a one liner to install the runners
*
* ```bash
* sudo gitlab-runner register \
*   --non-interactive \
*   --url "GITLAB_URL" \
*   --registration-token "PROJECT_REGISTRATION_TOKEN" \
*   --executor "docker+machine" \
*   --docker-image alpine:latest \
*   --description "docker-runner" \
*   --tag-list "docker,aws" \
*   --run-untagged="true" \
*   --locked="false" \
*   --access-level="not_protected"
* ```
*
*/

data "aws_iam_policy" "ssm" {
  arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

resource "aws_iam_policy" "ec2_s3" {
  name        = "gl-runner-policy"
  path        = "/"
  description = "gitlab runner policy"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
        "Action": "ec2:*",
        "Effect": "Allow",
        "Resource": "*"
    },
    {
        "Action": "s3:*",
        "Effect": "Allow",
        "Resource": "*"
    },
    {
        "Action": "iam:PassRole",
        "Effect": "Allow",
        "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "this" {
  name               = "gitlab-runner-role"
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

resource "aws_iam_role_policy_attachment" "ec2_s3" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.ec2_s3.arn
}

resource "aws_iam_instance_profile" "this" {
  name = "gitlab-runner-profile"
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
  template = "${file("../../modules/gitlab_runner/gitlab_runner_install.sh")}"

  vars = {

  }
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.this.id
  instance_type          = var.instance_type
  iam_instance_profile   = aws_iam_instance_profile.this.name
  vpc_security_group_ids = [aws_security_group.this.id]
  subnet_id              = var.subnet_id
  key_name               = var.key_name
  user_data              = data.template_file.this.rendered

  tags = {
    Name = "Gitlab-runner"
  }
}

resource "aws_security_group" "this" {
  name        = "gitlab-runner-sec-group"
  vpc_id      = var.vpc_id
  description = "Security group for the GitLab Runner Manager instance"

  tags = {
    Name = "gitlab-runner-sec-group"
  }
}

resource "aws_security_group_rule" "ingress_ssh" {
  description              = "Allow ingress for Git over SSH, port 22 (TCP), thru to gitlab runner"
  security_group_id        = aws_security_group.this.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  type                     = "ingress"
  source_security_group_id = var.bastion_security_group_id
}

resource "aws_security_group_rule" "ingress_http" {
  description              = "Allow ingress for Git over HTTP, port 80 (TCP), thru to gitlab runner"
  security_group_id        = aws_security_group.this.id
  from_port                = 80
  to_port                  = 80
  protocol                 = "tcp"
  type                     = "ingress"
  source_security_group_id = var.http_ingress_security_group_id
}

resource "aws_security_group_rule" "egress_all" {
  description       = "Allow all egress traffic"
  security_group_id = aws_security_group.this.id
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  type              = "egress"
  cidr_blocks       = ["0.0.0.0/0"]
}