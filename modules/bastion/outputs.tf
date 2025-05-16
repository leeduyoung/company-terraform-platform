output "bastion_id" {
  description = "Bastion 서버 인스턴스 ID"
  value       = aws_instance.bastion.id
}

output "bastion_public_ip" {
  description = "Bastion 서버 퍼블릭 IP (EIP가 없는 경우)"
  value       = aws_instance.bastion.public_ip
}

output "bastion_elastic_ip" {
  description = "Bastion 서버에 할당된 Elastic IP (있는 경우)"
  value       = var.create_eip ? aws_eip.bastion[0].public_ip : null
}

output "bastion_private_ip" {
  description = "Bastion 서버 프라이빗 IP"
  value       = aws_instance.bastion.private_ip
}

output "bastion_security_group_id" {
  description = "Bastion 서버 보안 그룹 ID"
  value       = aws_security_group.bastion.id
}

output "ssh_command" {
  description = "Bastion 서버 SSH 접속 명령어"
  value       = "ssh -i <private_key_path> ec2-user@${var.create_eip ? aws_eip.bastion[0].public_ip : aws_instance.bastion.public_ip}"
} 