output "elb_log_s3_bucket_id" {
  description = "The bucket id of the bucket meant for elb logs"
  value       = aws_s3_bucket.loadbalancer_access_logs.id
}