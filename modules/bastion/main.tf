/**
* # Bastion Module
*
* Creates a Bastion Instance with an Elastic IP in an Auto Scaling Group across all the provided public subnets of a VPC.
*
* Best practices for Bastion Hosts. [AWS documentation: Bastion architecture](https://docs.aws.amazon.com/quickstart/latest/linux-bastion/architecture.html)
*
* Implementation for an EIP with ASG can be tricky and I found this article [medium:Resilient AWS instances using Auto Scaling Groups and Terraform](https://medium.com/@tech_phil/resilient-aws-instances-using-auto-scaling-groups-and-terraform-c7bbe43de521) useful. I had to modify the ami part and the bash script (There was also an additional line in the comments that was useful).
*  
* ## Issues and fixes
*
* <b>Issue 1: Cannot use the AMI from the Launch Instance page</b>
* 
* Fix: I used the [AWS Quick Start document about bastion hosts](https://docs.aws.amazon.com/quickstart/latest/linux-bastion/step2.html), under "Option 2: Parameters for deploying Linux bastion hosts into an existing VPC" to retrieve the correct AMI from the provided template
* 
* <b>Issue 2: Finding out who is the `owner` of the ami since I did not want to hardcode an AMI but search it by its name</b>
* 
* This [link](https://www.terraform.io/docs/configuration/data-sources.html) mentions that the `owners` tag is compulsory. To find which is the correct value, use the console to get the ami-id and then run the following command. In this case I use the ami-id of a Amazon Linux2 AMI
*
* ```bash
* aws ec2 describe-images --image-id ami-0ec225b5e01ccb706
* ```
* 
* <b>Issue 3: Configuring the region in the bash script</b>
*
* Running `aws configure` forced one to type "enter" for the Access Key ID and Secret Access Key (even though I was attaching an IAM role). The bash script couldn't handle that. I needed a way to just set the region. Refer to the `aws configure set` command and leave out the `--profile`. Refer to [aws docs: Configuration and credential file settings](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-files.html)
*
* ## Additional details
*
* Read [Getting credentials from EC2 instance metadata](https://docs.aws.amazon.com/cli/latest/userguide/cli-configure-metadata.html) for a better understanding of how IAM roles work with EC2 instances
*
* In this module I assume the user already has a key in AWS. However, if the user intends to create the key, the following block can be added instead.
* ```
* resource "aws_key_pair" "bastion" {
*   key_name   = var.bastion_key_name
*   public_key = file(var.bastion_public_key)
* }
* ```
*/

resource "aws_eip" "this" {
  vpc = true

  tags = {
    Name = "gitlab-eip-bastion"
  }
}

resource "aws_iam_policy" "this" {
  name        = "bastion-eip-association"
  path        = "/"
  description = "permissions to associate an eip to a bastion instance"

  policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": [
        "ec2:DescribeAddresses",
        "ec2:AllocateAddress",
        "ec2:DescribeInstances",
        "ec2:AssociateAddress"
      ],
      "Effect": "Allow",
      "Resource": "*"
    }
  ]
}
EOF
}

resource "aws_iam_role" "this" {
  name               = "bastion-eip-association"
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

resource "aws_iam_role_policy_attachment" "this" {
  role       = aws_iam_role.this.name
  policy_arn = aws_iam_policy.this.arn
}

resource "aws_iam_instance_profile" "this" {
  name = "bastion-eip-association"
  role = aws_iam_role.this.name
}

data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-2.0.20200406.0-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["137112412989"]
}

data "template_file" "this" {
  template = "${file("../../modules/bastion/associate_eip.sh")}"

  vars = {
    eip    = aws_eip.this.id,
    region = var.region
  }

}

resource "aws_launch_configuration" "this" {
  name_prefix                 = "Bastion"
  image_id                    = data.aws_ami.this.id
  instance_type               = var.instance_type
  associate_public_ip_address = true
  iam_instance_profile        = aws_iam_instance_profile.this.name
  key_name                    = var.bastion_key_name
  security_groups             = [aws_security_group.this.id]
  user_data                   = data.template_file.this.rendered

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  name                 = "gitlab-bastion"
  health_check_type    = "EC2"
  launch_configuration = aws_launch_configuration.this.name
  max_size             = 1
  min_size             = 1
  vpc_zone_identifier  = var.subnet_ids

  lifecycle {
    create_before_destroy = true
  }

  tag {
    key                 = "Name"
    value               = "gitlab-bastion"
    propagate_at_launch = true
  }
}

resource "aws_security_group" "this" {
  name        = "bastion-sec-group"
  vpc_id      = var.vpc_id
  description = "Security group for the gitlab bastion"

  ingress {
    description = "Allow ingress over SSH, port 22 (TCP)"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.whitelist_ssh_ip
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "bastion-sec-group"
  }
}