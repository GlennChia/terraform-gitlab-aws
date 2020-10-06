output "rds_address" {
  description = "The hostname of the RDS instance which does not have `port`"
  value       = aws_db_instance.this.address
}