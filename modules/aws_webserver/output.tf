output "public_webservers_ip_address" {
  value = aws_instance.public_webservers[*].public_ip
}

output "private_webservers_ip_address" {
  value = aws_instance.private_webservers[*].private_ip
}

output "ebs_volume_name" {
  value = aws_ebs_volume.web_ebs[*].tags
}

output "ebs_volume_size" {
  value = aws_ebs_volume.web_ebs[*].size
}
