output "vpc_id" {
  description = "The id of the created VPC"
  value       = aws_vpc.this.id
}

output "this_subnet_public_ids" {
  description = "A list of all public subnet ids"
  value       = aws_subnet.public.*.id
}

output "this_subnet_private_ids" {
  description = "A list of all private subnet ids"
  value       = aws_subnet.private.*.id
}

output "vpce_id" {
  description = "Id of the VPCE"
  value       = aws_vpc_endpoint.this.id
}