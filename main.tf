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
  create_key_pair        = var.bastion_create_key_pair
  key_name               = var.bastion_key_name
  ssh_public_key         = var.bastion_ssh_public_key
  allowed_ssh_cidr_blocks = var.bastion_allowed_ssh_cidr_blocks
} 