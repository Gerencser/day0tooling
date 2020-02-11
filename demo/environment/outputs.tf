output "address" {
  value = aws_elb.demo.dns_name
}

output "application_address" {
  value = aws_instance.application.public_ip
}

output "database_address" {
  value = aws_instance.db.public_ip
}