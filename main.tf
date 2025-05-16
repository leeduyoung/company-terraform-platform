terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
  required_version = ">= 1.2.0"
}

provider "aws" {
  region = var.aws_region
}

# 키 페어 모듈 호출 (조건부)
module "keypair" {
  source   = "./modules/keypair"
  count    = var.create_key_pairs && length(var.key_pairs) > 0 ? length(var.key_pairs) : 0
  
  project_name = var.project_name
  environment  = var.environment
  create       = true
  key_name     = var.key_pairs[count.index].name
  public_key   = var.key_pairs[count.index].public_key
}

# 네트워크 모듈 호출
module "network" {
  source = "./modules/network"

  project_name         = var.project_name
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
}

# IAM 모듈 호출
module "iam" {
  source = "./modules/iam"

  project_name       = var.project_name
  policy_name_prefix = var.environment != "" ? "${var.environment}-" : ""
  group_name_prefix  = var.environment != "" ? "${var.environment}-" : ""
}

# EKS 모듈 호출 (조건부)
module "eks" {
  source = "./modules/eks"
  count  = var.create_eks ? 1 : 0

  project_name       = var.project_name
  vpc_id             = module.network.vpc_id
  subnet_ids         = module.network.private_subnet_ids # 프라이빗 서브넷에 노드 배치
  kubernetes_version = var.kubernetes_version
  node_instance_type = var.eks_node_instance_type
  node_disk_size     = var.eks_node_disk_size
  node_desired_size  = var.eks_node_desired_size
  node_min_size      = var.eks_node_min_size
  node_max_size      = var.eks_node_max_size
  # 키페어 모듈에서 생성한 키 사용 (생성한 경우) 또는 지정된 키 사용
  key_name           = var.create_key_pairs && length(var.key_pairs) > 0 ? module.keypair[0].key_pair_name : var.eks_key_name
}

# SQS 모듈 호출 (조건부)
module "sqs" {
  source   = "./modules/sqs"
  count    = var.create_sqs && length(var.sqs_queues) > 0 ? length(var.sqs_queues) : 0
  
  project_name                = var.project_name
  environment                 = var.environment
  queue_name                  = var.sqs_queues[count.index].name
  fifo_queue                  = var.sqs_queues[count.index].fifo_queue
  content_based_deduplication = var.sqs_queues[count.index].content_based_deduplication
  delay_seconds               = var.sqs_queues[count.index].delay_seconds
  max_message_size            = var.sqs_queues[count.index].max_message_size
  message_retention_seconds   = var.sqs_queues[count.index].message_retention_seconds
  receive_wait_time_seconds   = var.sqs_queues[count.index].receive_wait_time_seconds
  visibility_timeout_seconds  = var.sqs_queues[count.index].visibility_timeout_seconds
  create_queue_policy         = var.sqs_queues[count.index].create_queue_policy
  dead_letter_queue_arn       = var.sqs_queues[count.index].dead_letter_queue_arn
  max_receive_count           = var.sqs_queues[count.index].max_receive_count
}

# Bastion 서버 모듈 호출 (조건부)
module "bastion" {
  source = "./modules/bastion"
  count  = var.create_bastion ? 1 : 0

  project_name           = var.project_name
  environment            = var.environment
  vpc_id                 = module.network.vpc_id
  subnet_id              = module.network.public_subnet_ids[0] # 첫 번째 퍼블릭 서브넷에 배치
  instance_type          = var.bastion_instance_type
  volume_size            = var.bastion_volume_size
  create_eip             = var.bastion_create_eip
  # 키페어 모듈에서 생성한 키 사용 (생성한 경우) 또는 지정된 키 사용
  key_name               = var.create_key_pairs && length(var.key_pairs) > 0 ? module.keypair[0].key_pair_name : var.bastion_key_name
  allowed_ssh_cidr_blocks = var.bastion_allowed_ssh_cidr_blocks
}

# RDS 모듈 호출 (조건부)
module "rds" {
  source   = "./modules/rds"
  count    = var.create_rds && length(var.rds_instances) > 0 ? length(var.rds_instances) : 0

  project_name              = var.project_name
  environment               = var.environment
  identifier                = var.rds_instances[count.index].identifier
  vpc_id                    = module.network.vpc_id
  subnet_ids                = module.network.private_subnet_ids # 프라이빗 서브넷에 배치
  
  # 보안 설정
  allowed_security_group_ids = concat(
    var.rds_instances[count.index].allowed_security_groups,
    var.create_bastion ? [module.bastion[0].bastion_security_group_id] : []
  )
  allowed_cidr_blocks      = var.rds_instances[count.index].allowed_cidr_blocks
  
  # 인스턴스 설정
  engine                   = var.rds_instances[count.index].engine
  engine_version           = var.rds_instances[count.index].engine_version
  instance_class           = var.rds_instances[count.index].instance_class
  allocated_storage        = var.rds_instances[count.index].allocated_storage
  max_allocated_storage    = var.rds_instances[count.index].max_allocated_storage
  storage_type             = var.rds_instances[count.index].storage_type
  storage_encrypted        = var.rds_instances[count.index].storage_encrypted
  
  # 데이터베이스 설정
  db_name                  = var.rds_instances[count.index].db_name
  username                 = var.rds_instances[count.index].username
  password                 = var.rds_instances[count.index].password
  port                     = var.rds_instances[count.index].port
  
  # 파라미터 그룹 설정
  create_parameter_group   = var.rds_instances[count.index].create_parameter_group
  parameter_group_family   = var.rds_instances[count.index].parameter_group_family
  parameters               = var.rds_instances[count.index].parameters
  
  # 가용성 설정
  multi_az                 = var.rds_instances[count.index].multi_az
  publicly_accessible      = var.rds_instances[count.index].publicly_accessible
  
  # 백업 및 유지보수 설정
  backup_retention_period  = var.rds_instances[count.index].backup_retention_period
  skip_final_snapshot      = var.rds_instances[count.index].skip_final_snapshot
  
  # 보안 설정
  deletion_protection      = var.rds_instances[count.index].deletion_protection
  
  # 모니터링 설정
  performance_insights_enabled = var.rds_instances[count.index].performance_insights_enabled
  enabled_cloudwatch_logs_exports = var.rds_instances[count.index].enabled_cloudwatch_logs_exports
} 