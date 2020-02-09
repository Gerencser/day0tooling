output "address" {
  value = aws_elb.web.dns_name
}

output "application_address" {
  value = aws_instance.application.public_ip
}

output "db_address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.default.address
}