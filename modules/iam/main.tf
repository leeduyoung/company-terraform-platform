# IAM 정책: 백엔드 개발자용 정책
resource "aws_iam_policy" "backend_dev_policy" {
  name        = "${var.policy_name_prefix}BackendDeveloperPolicy"
  description = "백엔드 개발자를 위한 IAM 정책"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid      = "VPCReadOnly"
        Effect   = "Allow"
        Action   = ["ec2:Describe*"]
        Resource = "*"
      },
      {
        Sid    = "EC2LimitedControl"
        Effect = "Allow"
        Action = [
          "ec2:StartInstances",
          "ec2:StopInstances",
          "ec2:Describe*",
          "ec2:AttachVolume"
        ]
        Resource = "*"
      },
      {
        Sid    = "ECRPushPull"
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:PutImage",
          "ecr:InitiateLayerUpload",
          "ecr:CompleteLayerUpload"
        ]
        Resource = "*"
      },
      {
        Sid    = "EKSAccess"
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:List*",
          "eks:AccessKubernetesApi"
        ]
        Resource = "*"
      },
      {
        Sid    = "S3ArtifactAccess"
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject",
          "s3:ListBucket"
        ]
        Resource = "*"
      },
      {
        Sid    = "SQSAccess"
        Effect = "Allow"
        Action = [
          "sqs:SendMessage",
          "sqs:ReceiveMessage",
          "sqs:DeleteMessage"
        ]
        Resource = "*"
      },
      {
        Sid      = "RDSReadOnly"
        Effect   = "Allow"
        Action   = ["rds:Describe*"]
        Resource = "*"
      },
      {
        Sid      = "ELBReadOnly"
        Effect   = "Allow"
        Action   = ["elasticloadbalancing:Describe*"]
        Resource = "*"
      }
    ]
  })

  tags = {
    Name = "${var.project_name}-backend-dev-policy"
  }
}

# 백엔드 개발자 그룹
resource "aws_iam_group" "backend_devs" {
  name = "${var.group_name_prefix}BackendDevelopers"
}

# 정책을 그룹에 연결
resource "aws_iam_group_policy_attachment" "attach_policy" {
  group      = aws_iam_group.backend_devs.name
  policy_arn = aws_iam_policy.backend_dev_policy.arn
} 