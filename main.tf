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

resource "aws_vpc" "main" {
  cidr_block           = var.vpc_cidr
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project_name}-vpc"
  }
}

# Internet Gateway 생성
resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.project_name}-igw"
  }
}

# Public 서브넷 생성
resource "aws_subnet" "public" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = var.public_subnet_cidrs[count.index]
  availability_zone       = var.availability_zones[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "${var.project_name}-public-subnet-${count.index + 1}"
  }
}

# Private 서브넷 생성
resource "aws_subnet" "private" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = var.private_subnet_cidrs[count.index]
  availability_zone = var.availability_zones[count.index]

  tags = {
    Name = "${var.project_name}-private-subnet-${count.index + 1}"
  }
}

# Elastic IP for NAT Gateway
resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name = "${var.project_name}-nat-eip"
  }
}

# NAT Gateway 생성 - 비용 고려하여 1개만 생성
resource "aws_nat_gateway" "main" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.public[0].id # 첫 번째 퍼블릭 서브넷에 배치

  tags = {
    Name = "${var.project_name}-nat-gw"
  }

  depends_on = [aws_internet_gateway.main]
}

# Public 라우팅 테이블 생성
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-public-rt"
  }
}

# Private 라우팅 테이블 생성
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.main.id
  }

  tags = {
    Name = "${var.project_name}-private-rt"
  }
}

# Public 서브넷과 라우팅 테이블 연결
resource "aws_route_table_association" "public" {
  count          = length(var.public_subnet_cidrs)
  subnet_id      = aws_subnet.public[count.index].id
  route_table_id = aws_route_table.public.id
}

# Private 서브넷과 라우팅 테이블 연결
resource "aws_route_table_association" "private" {
  count          = length(var.private_subnet_cidrs)
  subnet_id      = aws_subnet.private[count.index].id
  route_table_id = aws_route_table.private.id
} 