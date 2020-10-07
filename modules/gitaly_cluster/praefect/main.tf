/**
* # Praefect Image Module
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
  template = "${file("../../modules/gitaly_cluster/praefect/praefect_install_13_2_3.sh")}"

  vars = {
    rds_address             = var.rds_address,
    rds_name                = var.rds_name,
    rds_username            = var.rds_username,
    rds_password            = var.rds_password,
    praefect_sql_password   = var.praefect_sql_password
    praefect_external_token = var.praefect_external_token
    praefect_internal_token = var.praefect_internal_token
    gitaly_address1         = var.private_ips_gitaly[0]
    gitaly_address2         = var.private_ips_gitaly[1]
    gitaly_address3         = var.private_ips_gitaly[2]
  }
}

resource "aws_instance" "this" {
  ami                    = data.aws_ami.this.id
  iam_instance_profile   = var.iam_instance_profile
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.this.id]
  subnet_id              = var.subnet_ids[0]
  private_ip             = var.private_ips_praefect[0]
  key_name               = var.praefect_key_name
  user_data              = data.template_file.this.rendered

  tags = {
    Name = "Praefect"
  }
}

resource "aws_security_group" "this" {
  name        = "praefect-sec-group"
  vpc_id      = var.vpc_id
  description = "Security group for the praefect instance"

  tags = {
    Name = "praefect-sec-group"
  }
}

resource "aws_security_group_rule" "ingress_ssh" {
  description              = "Allow ingress over SSH, port 22 (TCP), thru to praefect"
  security_group_id        = aws_security_group.this.id
  from_port                = 22
  to_port                  = 22
  protocol                 = "tcp"
  type                     = "ingress"
  source_security_group_id = var.ssh_ingress_security_group_id
}

resource "aws_security_group_rule" "ingress_custom" {
  description              = "Allow custom ingress for praefect to communicate with GitLab"
  security_group_id        = aws_security_group.this.id
  from_port                = 2305
  to_port                  = 2305
  protocol                 = "tcp"
  type                     = "ingress"
  source_security_group_id = var.custom_ingress_security_group_id
}

# resource "aws_security_group_rule" "ingress_gitaly" {
#   description              = "Allow custom ingress for praefect to communicate with Gitaly"
#   security_group_id        = aws_security_group.this.id
#   from_port                = 8075
#   to_port                  = 8075
#   protocol                 = "tcp"
#   type                     = "ingress"
#   source_security_group_id = var.gitaly_ingress_security_group_id
# }

resource "aws_security_group_rule" "ingress_prometheus" {
  description              = "Allow prometheus metrics access to praefect"
  security_group_id        = aws_security_group.this.id
  from_port                = 9652
  to_port                  = 9652
  protocol                 = "tcp"
  type                     = "ingress"
  source_security_group_id = var.prometheus_ingress_security_group_id
}

resource "aws_security_group_rule" "ingress_prometheus_self" {
  description       = "Allow prometheus metrics access to praefect"
  security_group_id = aws_security_group.this.id
  from_port         = 9652
  to_port           = 9652
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