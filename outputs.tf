output "web_server_public_ip" {
  description = "Public IP address of web server assigned to the instance"
  value       = aws_instance.web_server.public_ip
}

output "web_server_public_dns" {
  description = "Public DNS name of web server assigned to the instance"
  value       = aws_instance.web_server.public_dns
}

output "data_server_public_ip" {
  description = "Public IP address of data server assigned to the instance"
  value       = aws_instance.data_server.public_ip
}

output "data_server_public_dns" {
  description = "Public DNS name of data server assigned to the instance"
  value       = aws_instance.data_server.public_dns
}
