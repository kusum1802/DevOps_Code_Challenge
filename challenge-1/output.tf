# Output the DNS name of the Application Load Balancer
output "alb_dns_name" {
  description = "The DNS name of the Application Load Balancer"
  value       = aws_lb.web_alb.dns_name
}

# Output the public IP address of the EC2 instance
output "apache_server_public_ip" {
  description = "The public IP address of the Apache server instance"
  value       = aws_instance.apache_server.public_ip
}

# Output the ARN of the Application Load Balancer
output "alb_arn" {
  description = "The ARN of the Application Load Balancer"
  value       = aws_lb.web_alb.arn
}

# Output the ARN of the Target Group
output "target_group_arn" {
  description = "The ARN of the Target Group for the ALB"
  value       = aws_lb_target_group.web_tg.arn
}

# Output the security group ID associated with the EC2 instances
output "web_sg_id" {
  description = "The security group ID for the EC2 instances"
  value       = aws_security_group.web_sg.id
}

# Output the Auto Scaling Group ID
output "asg_id" {
  description = "The ID of the Auto Scaling Group"
  value       = aws_autoscaling_group.web_asg.id
}

# Output the Launch Template ID
output "launch_template_id" {
  description = "The ID of the Launch Template"
  value       = aws_launch_template.web_launch_template.id
}
