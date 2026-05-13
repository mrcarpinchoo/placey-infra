output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.main.id
}

output "app_subnet_id" {
  description = "ID of the private app subnet"
  value       = aws_subnet.app.id
}

output "data_subnet_ids" {
  description = "IDs of the private data subnets"
  value       = [aws_subnet.data_a.id, aws_subnet.data_b.id]
}
