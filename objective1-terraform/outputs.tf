

output "instance_id" {
  description = "EC2 Instance ID"
  value       = aws_instance.web.id
}

output "public_ip" {
  description = "Public IP address of the web server"
  value       = aws_instance.web.public_ip
}

output "public_dns" {
  description = "Public DNS name of the web server"
  value       = aws_instance.web.public_dns
}

output "health_endpoint" {
  description = "URL of the /health endpoint"
  value       = "http://${aws_instance.web.public_ip}/health"
}

output "version_endpoint" {
  description = "URL of the /version endpoint"
  value       = "http://${aws_instance.web.public_ip}/version"
}

output "ssh_command" {
  description = "SSH command to connect (only if key_name is set)"
  value       = var.key_name != "" ? "ssh -i ~/.ssh/${var.key_name}.pem ec2-user@${aws_instance.web.public_ip}" : "No key pair configured"
}

output "ssm_command" {
  description = "Connect securely via AWS Systems Manager (no SSH key or port 22 required)"
  value       = "aws ssm start-session --target ${aws_instance.web.id} --region ${var.aws_region}"
}
