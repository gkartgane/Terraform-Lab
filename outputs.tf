output "vpc_id" {
  description = "ID of the shared VPC"
  value       = aws_vpc.shared_vpc.id
}

output "instances_public_ips" {
  description = "Public IPs of the created EC2 instances"
  value       = [for i in aws_instance.shared_ec2 : i.public_ip]
}

