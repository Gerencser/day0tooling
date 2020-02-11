output "address1" {
  value = aws_elb.demo1.dns_name
}

output "address2" {
  value = aws_elb.demo2.dns_name
}

output "address3" {
  value = aws_elb.demo3.dns_name
}

output "application_address1" {
  value = aws_instance.application1.public_ip
}

output "application_address2" {
  value = aws_instance.application2.public_ip
}

output "application_address3" {
  value = aws_instance.application3.public_ip
}

output "database_address" {
  value = aws_instance.db.public_ip
}