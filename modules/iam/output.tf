output "ssm_instance_profile" {
  description = "The name of the instance profile to associate"
  value       = aws_iam_instance_profile.ssm.name
}