/**
* # Gitaly Module
*
*/

data "aws_ami" "this" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-bionic-18.04-amd64-server-20200611"]
  }

  owners = ["099720109477"]
}

data "template_file" "this" {
  template = "${file("../../modules/gitaly/gitaly_install.sh")}"

  vars = {
    gitaly_token      = var.gitaly_token,
    secret_token      = var.secret_token,
    lb_dns_name       = var.lb_dns_name,
    instance_dns_name = var.instance_dns_name,
    visibility        = var.visibility
  }
}

resource "aws_instance" "this" {
  ami                  = data.aws_ami.this.id
  instance_type        = var.instance_type
  iam_instance_profile = var.iam_instance_profile
  security_groups      = [aws_security_group.this.id]
  subnet_id            = var.subnet_id
  key_name             = var.key_name
  user_data            = data.template_file.this.rendered

  root_block_device {
    volume_type           = var.volume_type
    volume_size           = var.volume_size
    iops                  = var.iops
    delete_on_termination = var.delete_on_termination
  }

  tags = {
    Name = "Gitaly"
  }
}

resource "aws_security_group" "this" {
  name        = "gitlab-gitaly-sec-group"
  vpc_id      = var.vpc_id
  description = "Security group for the gitaly instance"

  ingress {
    description     = "Allow ingress for custom, port 8075 (TCP), thru the ELB"
    from_port       = 8075
    to_port         = 8075
    protocol        = "tcp"
    security_groups = var.ingress_security_group_ids
  }

  ingress {
    description     = "Allow ingress for Git over SSH, port 22 (TCP), thru to gitaly"
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [var.bastion_security_group_id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "gitlab-gitaly-sec-group"
  }
}