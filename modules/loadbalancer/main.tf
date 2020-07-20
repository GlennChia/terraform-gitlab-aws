/**
* # Loadbalancer module
*
* Classic Load Balancer
*
* ## Issues and fixes
*
* <b>Issue 1: Cannot get an SSL certificate verified</b>
* 
* Fix: Temporarily comment out the listener for HTTPs
*/

resource "aws_elb" "classic" {
  name            = "gitlab-loadbalancer"
  subnets         = var.subnet_ids
  security_groups = [aws_security_group.this.id]

  access_logs {
    bucket   = var.elb_log_s3_bucket_id
    interval = 60
  }

  listener {
    instance_port     = 22
    instance_protocol = "tcp"
    lb_port           = 22
    lb_protocol       = "tcp"
  }

  listener {
    instance_port     = 80
    instance_protocol = "http"
    lb_port           = 80
    lb_protocol       = "http"
  }

  # listener {
  #   instance_port      = 80
  #   instance_protocol  = "http"
  #   lb_port            = 443
  #   lb_protocol        = "https"
  #   ssl_certificate_id = var.aws_acm_certificate_id
  # }

  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 5
    target              = "HTTP:80/explore"
    interval            = 30
  }

  cross_zone_load_balancing   = var.cross_zone_load_balancing
  idle_timeout                = var.idle_timeout
  connection_draining         = var.connection_draining
  connection_draining_timeout = var.connection_draining_timeout

  tags = {
    Name = "gitlab-loadbalancer"
  }
}

resource "aws_security_group" "this" {
  name        = "gitlab-loadbalancer-sec-group"
  vpc_id      = var.vpc_id
  description = "Security group for the gitlab ELB"

  ingress {
    description = "Allow ingress for HTTPS, port 443 (TCP), thru the ELB"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = var.whitelist_ip
  }

  ingress {
    description = "Allow ingress for HTTP, port 80 (TCP), thru the ELB"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = var.whitelist_ip
  }

  ingress {
    description     = "Allow ingress for Git over SSH, port 22 (TCP), thru the ELB"
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
    Name = "gitlab-loadbalancer-sec-group"
  }
}