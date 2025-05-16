# RDS용 보안 그룹
resource "aws_security_group" "rds" {
  name        = "${var.project_name}-${var.identifier}-sg"
  description = "Security group for RDS instance"
  vpc_id      = var.vpc_id

  # 데이터베이스 포트 접근 허용 (VPC 내부에서만)
  ingress {
    from_port       = var.port
    to_port         = var.port
    protocol        = "tcp"
    security_groups = var.allowed_security_group_ids
    cidr_blocks     = var.allowed_cidr_blocks
    description     = "Database access from allowed security groups and CIDRs"
  }

  # 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-${var.identifier}-sg"
    Environment = var.environment
  }
}

# RDS 파라미터 그룹
resource "aws_db_parameter_group" "main" {
  count = var.create_parameter_group ? 1 : 0
  name   = "${var.project_name}-${var.identifier}-pg"
  family = var.parameter_group_family

  dynamic "parameter" {
    for_each = var.parameters
    content {
      name  = parameter.value.name
      value = parameter.value.value
    }
  }

  tags = {
    Name        = "${var.project_name}-${var.identifier}-pg"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# RDS 서브넷 그룹
resource "aws_db_subnet_group" "main" {
  name       = "${var.project_name}-${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids

  tags = {
    Name        = "${var.project_name}-${var.identifier}-subnet-group"
    Environment = var.environment
  }
}

# KMS 키 (암호화 활성화 시)
resource "aws_kms_key" "rds" {
  count                   = var.storage_encrypted && var.kms_key_id == "" ? 1 : 0
  description             = "KMS key for RDS ${var.identifier} encryption"
  deletion_window_in_days = 10
  enable_key_rotation     = true

  tags = {
    Name        = "${var.project_name}-${var.identifier}-kms"
    Environment = var.environment
  }
}

resource "aws_kms_alias" "rds" {
  count         = var.storage_encrypted && var.kms_key_id == "" ? 1 : 0
  name          = "alias/${var.project_name}-${var.identifier}-key"
  target_key_id = aws_kms_key.rds[0].key_id
}

# RDS 인스턴스
resource "aws_db_instance" "main" {
  identifier             = "${var.project_name}-${var.identifier}"
  engine                 = var.engine
  engine_version         = var.engine_version
  instance_class         = var.instance_class
  allocated_storage      = var.allocated_storage
  max_allocated_storage  = var.max_allocated_storage
  storage_type           = var.storage_type
  storage_encrypted      = var.storage_encrypted
  kms_key_id             = var.storage_encrypted ? (var.kms_key_id != "" ? var.kms_key_id : aws_kms_key.rds[0].arn) : null
  
  db_name                = var.db_name
  username               = var.username
  password               = var.password
  port                   = var.port

  vpc_security_group_ids = [aws_security_group.rds.id]
  db_subnet_group_name   = aws_db_subnet_group.main.name
  parameter_group_name   = var.create_parameter_group ? aws_db_parameter_group.main[0].name : var.parameter_group_name

  multi_az               = var.multi_az
  publicly_accessible    = var.publicly_accessible
  skip_final_snapshot    = var.skip_final_snapshot
  final_snapshot_identifier = var.skip_final_snapshot ? null : "${var.project_name}-${var.identifier}-final-${formatdate("YYYYMMDDhhmmss", timestamp())}"
  
  backup_retention_period = var.backup_retention_period
  backup_window           = var.backup_window
  maintenance_window      = var.maintenance_window

  apply_immediately       = var.apply_immediately
  auto_minor_version_upgrade = var.auto_minor_version_upgrade
  
  deletion_protection     = var.deletion_protection
  
  # 성능 인사이트 (옵션)
  performance_insights_enabled = var.performance_insights_enabled
  performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null
  performance_insights_kms_key_id = var.performance_insights_enabled ? (var.performance_insights_kms_key_id != "" ? var.performance_insights_kms_key_id : (var.storage_encrypted && var.kms_key_id == "" ? aws_kms_key.rds[0].arn : null)) : null
  
  # 증분 백업 활성화 (옵션)
  enabled_cloudwatch_logs_exports = var.enabled_cloudwatch_logs_exports
  
  # 태그
  tags = {
    Name        = "${var.project_name}-${var.identifier}"
    Environment = var.environment
  }

  # 라이프사이클
  lifecycle {
    prevent_destroy = var.prevent_destroy
  }
} 