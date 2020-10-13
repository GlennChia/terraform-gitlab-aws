/**
* # Loadbalancer module
*
* Application Load Balancer
*
* ## Issues and fixes
*
* <b>Issue 1: Cannot get an SSL certificate verified</b>
* 
* Fix: Temporarily comment out the listener for HTTPs
*/

resource "aws_lb" "this" {
  name            = "gitlab-loadbalancer"
  internal        = false
  subnets         = var.subnet_ids
  security_groups = [aws_security_group.this.id]
  idle_timeout    = var.idle_timeout

  access_logs {
    bucket  = var.elb_log_s3_bucket_id
    enabled = true
  }

  tags = {
    Name = "gitlab-loadbalancer"
  }
}

resource "aws_lb_target_group" "this" {
  name     = "gitlab-lb-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    enabled             = true
    interval            = 30
    path                = "/explore"
    port                = "80"
    protocol            = "HTTP"
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

# resource "aws_lb_listener" "https" {
#   load_balancer_arn = aws_lb.this.arn
#   port              = "80"
#   protocol          = "HTTP"

#   default_action {
#     type = "redirect"

#     redirect {
#       port        = "443"
#       protocol    = "HTTPS"
#       status_code = "HTTP_301"
#     }
#   }
# }

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
    description     = "Allow ingress for HTTP, port 80 (TCP), thru the ELB"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = var.whitelist_ip
    security_groups = var.http_ingress_security_group_ids
    self            = true
  }

  ingress {
    description = "Allow ingress for Prometheus"
    from_port   = 9090
    to_port     = 9090
    protocol    = "tcp"
    cidr_blocks = var.whitelist_ip
    self        = true
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