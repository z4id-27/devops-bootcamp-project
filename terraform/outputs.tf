output "web_eip" { value = aws_eip.web_eip.public_ip }
output "web_private_ip" { value = aws_instance.web.private_ip }
output "ansible_controller_private_ip" { value = aws_instance.ansible_controller.private_ip }
output "monitoring_private_ip" { value = aws_instance.monitoring.private_ip }
