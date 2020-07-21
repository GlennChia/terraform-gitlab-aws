output "id" {
  description = "The id of the created GitLab AMI"
  value       = aws_ami_from_instance.this.id
}