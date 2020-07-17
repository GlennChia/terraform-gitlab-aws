output "vpc_id" {
  description = "The id of the created VPC"
  value       = aws_vpc.this.id
}

output "this_subnet_public_ids" {
  description = "A list of all public subnet ids"
  value       = aws_subnet.public.*.id
}