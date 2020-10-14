/**
* # Autoscaling group module
*
*/

resource "aws_launch_configuration" "this" {
  iam_instance_profile = var.iam_instance_profile
  image_id             = var.image_id
  instance_type        = var.instance_type
  name_prefix          = var.launch_configuration_name_prefix
  security_groups      = var.security_groups

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "this" {
  name                      = var.autoscaling_group_name
  max_size                  = 4
  min_size                  = 2
  desired_capacity          = 2
  health_check_grace_period = 300
  health_check_type         = "ELB"
  vpc_zone_identifier       = var.subnet_ids
  launch_configuration      = aws_launch_configuration.this.name
  target_group_arns         = var.target_group_arns

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_policy" "scale-up" {
  name                   = "scale-up"
  scaling_adjustment     = 1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.this.name
}

resource "aws_autoscaling_policy" "scale-down" {
  name                   = "scale-down"
  scaling_adjustment     = -1
  adjustment_type        = "ChangeInCapacity"
  cooldown               = 300
  autoscaling_group_name = aws_autoscaling_group.this.name
}

resource "aws_cloudwatch_metric_alarm" "cpu-high" {
  alarm_name          = "terraform-cpu-metric-high"
  comparison_operator = "GreaterThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "60"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  alarm_description = "This metric monitors ec2 cpu high utilization"
  alarm_actions     = [aws_autoscaling_policy.scale-up.arn]
}

resource "aws_cloudwatch_metric_alarm" "cpu-low" {
  alarm_name          = "terraform-cpu-metric-low"
  comparison_operator = "LessThanOrEqualToThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "45"

  dimensions = {
    AutoScalingGroupName = aws_autoscaling_group.this.name
  }

  alarm_description = "This metric monitors ec2 cpu low utilization"
  alarm_actions     = [aws_autoscaling_policy.scale-down.arn]
}