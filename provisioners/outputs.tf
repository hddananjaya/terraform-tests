
output "web_instance_ip" {
  description = "public ip address of web instance"
  value       = aws_instance.web.public_ip
}