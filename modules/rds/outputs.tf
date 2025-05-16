output "db_instance_id" {
  description = "RDS 인스턴스 ID"
  value       = aws_db_instance.main.id
}

output "db_instance_address" {
  description = "RDS 인스턴스 주소"
  value       = aws_db_instance.main.address
}

output "db_instance_endpoint" {
  description = "RDS 인스턴스 엔드포인트 (주소:포트)"
  value       = aws_db_instance.main.endpoint
}

output "db_instance_arn" {
  description = "RDS 인스턴스 ARN"
  value       = aws_db_instance.main.arn
}

output "db_instance_name" {
  description = "RDS 인스턴스 이름"
  value       = aws_db_instance.main.db_name
}

output "db_instance_username" {
  description = "RDS 마스터 사용자 이름"
  value       = aws_db_instance.main.username
}

output "db_instance_port" {
  description = "RDS 인스턴스 포트"
  value       = aws_db_instance.main.port
}

output "db_subnet_group_id" {
  description = "RDS 서브넷 그룹 ID"
  value       = aws_db_subnet_group.main.id
}

output "db_subnet_group_arn" {
  description = "RDS 서브넷 그룹 ARN"
  value       = aws_db_subnet_group.main.arn
}

output "db_parameter_group_id" {
  description = "RDS 파라미터 그룹 ID"
  value       = var.create_parameter_group ? aws_db_parameter_group.main[0].id : var.parameter_group_name
}

output "db_security_group_id" {
  description = "RDS 보안 그룹 ID"
  value       = aws_security_group.rds.id
}

output "kms_key_id" {
  description = "RDS 암호화에 사용된 KMS 키 ID"
  value       = var.storage_encrypted ? (var.kms_key_id != "" ? var.kms_key_id : try(aws_kms_key.rds[0].id, null)) : null
}

output "jdbc_connection_string" {
  description = "JDBC 연결 문자열"
  value       = "${var.engine == "postgres" ? "jdbc:postgresql://" : (var.engine == "mysql" ? "jdbc:mysql://" : "jdbc:")}${aws_db_instance.main.endpoint}/${aws_db_instance.main.db_name}"
}

output "connection_command" {
  description = "데이터베이스 접속 명령어 (PostgreSQL/MySQL)"
  value       = var.engine == "postgres" ? "psql -h ${aws_db_instance.main.address} -p ${aws_db_instance.main.port} -U ${aws_db_instance.main.username} -d ${aws_db_instance.main.db_name}" : (var.engine == "mysql" ? "mysql -h ${aws_db_instance.main.address} -P ${aws_db_instance.main.port} -u ${aws_db_instance.main.username} -p${aws_db_instance.main.db_name}" : "")
} 