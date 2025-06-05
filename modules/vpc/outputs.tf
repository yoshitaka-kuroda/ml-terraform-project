output "vpc_id" {
  value       = aws_vpc.this.id
  description = "作成された VPC の ID"
}

output "public_subnet_id" {
  value       = aws_subnet.public.id
  description = "作成されたパブリックサブネットの ID"
}
