# Bastion 서버 보안 그룹
resource "aws_security_group" "bastion" {
  name        = "${var.project_name}-bastion-sg"
  description = "Security group for Bastion host"
  vpc_id      = var.vpc_id

  # SSH 접속 허용
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = var.allowed_ssh_cidr_blocks
    description = "SSH access from allowed IPs"
  }

  # 모든 아웃바운드 트래픽 허용
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    description = "Allow all outbound traffic"
  }

  tags = {
    Name        = "${var.project_name}-bastion-sg"
    Environment = var.environment
  }
}

# Bastion 서버 EC2 인스턴스
resource "aws_instance" "bastion" {
  ami                    = var.ami_id != "" ? var.ami_id : data.aws_ami.amazon_linux_2.id
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.bastion.id]
  subnet_id              = var.subnet_id
  associate_public_ip_address = true

  root_block_device {
    volume_size           = var.volume_size
    volume_type           = "gp3"
    delete_on_termination = true
    encrypted             = true
  }

  # 사용자 데이터 스크립트 (선택적)
  user_data = var.user_data != "" ? var.user_data : <<-EOF
    #!/bin/bash
    yum update -y
    yum install -y amazon-ssm-agent
    systemctl start amazon-ssm-agent
    systemctl enable amazon-ssm-agent
  EOF

  tags = {
    Name        = "${var.project_name}-${var.environment}-bastion"
    Environment = var.environment
  }

  lifecycle {
    create_before_destroy = true
  }
}

# 최신 Amazon Linux 2 AMI 가져오기
data "aws_ami" "amazon_linux_2" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

# Elastic IP 연결 (선택적)
resource "aws_eip" "bastion" {
  count    = var.create_eip ? 1 : 0
  domain   = "vpc"
  instance = aws_instance.bastion.id

  tags = {
    Name        = "${var.project_name}-${var.environment}-bastion-eip"
    Environment = var.environment
  }
} 