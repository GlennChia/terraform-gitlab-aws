/**
* # Gitaly Image Module
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
  template = "${file("../../modules/gitaly_cluster/gitaly/gitaly_install_13_2_3.sh")}"

  vars = {
    praefect_internal_token = var.praefect_internal_token,
    secret_token            = var.secret_token,
    visibility              = var.visibility,
    lb_dns_name             = var.lb_dns_name,
    instance_dns_name       = var.instance_dns_name
  }
}

resource "aws_instance" "this" {
  count = length(var.private_ips_gitaly)

  ami                    = data.aws_ami.this.id
  iam_instance_profile   = var.iam_instance_profile
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.this.id]
  subnet_id              = var.subnet_ids[count.index]
  private_ip             = var.private_ips_gitaly[count.index]
  key_name               = var.gitaly_key_name
  user_data              = data.template_file.this.rendered

  tags = {
    Name = "Gitaly-${1 + count.index}"
  }
}

resource "aws_security_group" "this" {
  name        = "gitaly-sec-group"
  vpc_id      = var.vpc_id
  description = "Security group for the gitaly instance"

  tags = {
    Name = "gitaly-sec-group"
  }
}

resource "aws_security_group_rule" "ingress_ssh" {
  description              = "Allow ingress over SSH, port 22 (TCP), thru to gitaly"
  security_group_id        = aws_security_group.this.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  type                     = "ingress"
  source_security_group_id = var.ssh_ingress_security_group_id
}

resource "aws_security_group_rule" "ingress_gitaly" {
  description              = "Allow custom ingress for praefect to communicate with Gitaly"
  security_group_id        = aws_security_group.this.id
  from_port                = 8075
  to_port                  = 8075
  protocol                 = "tcp"
  type                     = "ingress"
  source_security_group_id = var.custom_ingress_security_group_id
}

resource "aws_security_group_rule" "ingress_prometheus" {
  description              = "Allow prometheus metrics access to praefect"
  security_group_id        = aws_security_group.this.id
  from_port                = 9236
  to_port                  = 9236
  protocol                 = "tcp"
  type                     = "ingress"
  source_security_group_id = var.prometheus_ingress_security_group_id
}

resource "aws_security_group_rule" "ingress_prometheus_self" {
  description       = "Allow prometheus metrics access to gitaly"
  security_group_id = aws_security_group.this.id
  from_port         = 9236
  to_port           = 9236
  protocol          = "tcp"
  type              = "ingress"
  self              = true
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