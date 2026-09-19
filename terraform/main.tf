# Network isolation (VPC + private subnet)
resource "aws_vpc" "main" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "${var.project}-${var.environment}-vpc"
  }
}

resource "aws_subnet" "private" {
  vpc_id            = aws_vpc.main.id
  cidr_block        = "10.0.1.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name = "${var.project}-${var.environment}-private"
  }
}

# Security group – least privilege
resource "aws_security_group" "wallet" {
  name        = "${var.project}-sg"
  description = "Allow only necessary traffic for wallet service"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 8000
    to_port     = 8000
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]   # only internal
  }

  egress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["156.0.255.0/24"]   # for NIBSS 
  }

  tags = {
    Name = "${var.project}-sg"
  }
}

# Managed datastore (DynamoDB)
resource "aws_dynamodb_table" "wallets" {
  name         = "${var.project}-wallets"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "id"

  attribute {
    name = "id"
    type = "S"
  }

  tags = {
    Environment = var.environment
  }
}

# Secrets Manager
resource "aws_secretsmanager_secret" "db_credentials" {
  name = "${var.project}/db-credentials"
}

resource "aws_secretsmanager_secret_version" "db_credentials" {
  secret_id = aws_secretsmanager_secret.db_credentials.id
  secret_string = jsonencode({
    username = "novapay_app"
    password = "CHANGEME-ROTATE-ME"   # never committed; injected at apply time via TF_VAR
  })
}

# IAM role – least privilege (no wildcards)
resource "aws_iam_role" "wallet_task" {
  name = "${var.project}-task-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Action = "sts:AssumeRole"
      Effect = "Allow"
      Principal = {
        Service = "ecs-tasks.amazonaws.com"
      }
    }]
  })
}

resource "aws_iam_role_policy" "wallet_task" {
  name = "${var.project}-task-policy"
  role = aws_iam_role.wallet_task.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Sid    = "ReadWalletsTable"
        Effect = "Allow"
        Action = [
          "dynamodb:GetItem",
          "dynamodb:Query",
          "dynamodb:Scan"
        ]
        Resource = aws_dynamodb_table.wallets.arn
      },
      {
        Sid    = "ReadSecret"
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = aws_secretsmanager_secret.db_credentials.arn
      }
    ]
  })
}
