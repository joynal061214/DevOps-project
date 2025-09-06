terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_s3_bucket" "deel_test_app_bucket" {
  bucket = "deel-test-app-bucket-${var.environment}"
  tags = {
    Name            = "deel-test-app-bucket"
    Environment     = var.environment
    resourcecreator = "joynal.abedin@gmx.co.uk"
    environment     = var.environment
  }
}

resource "aws_s3_bucket_public_access_block" "deel_test_app_bucket" {
  bucket = aws_s3_bucket.deel_test_app_bucket.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "deel_test_app_bucket" {
  bucket = aws_s3_bucket.deel_test_app_bucket.id

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "deel_test_app_bucket" {
  bucket = aws_s3_bucket.deel_test_app_bucket.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_lifecycle_configuration" "deel_test_app_bucket" {
  bucket = aws_s3_bucket.deel_test_app_bucket.id

  rule {
    id     = "delete_old_versions"
    status = "Enabled"

    filter {
      prefix = ""
    }

    noncurrent_version_expiration {
      noncurrent_days = 30
    }
  }
}

resource "aws_s3_bucket_policy" "deel_test_app_bucket" {
  bucket = aws_s3_bucket.deel_test_app_bucket.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          AWS = "arn:aws:iam::652711504416:root"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.deel_test_app_bucket.arn}/alb-logs/*"
      },
      {
        Effect = "Allow"
        Principal = {
          Service = "delivery.logs.amazonaws.com"
        }
        Action   = "s3:PutObject"
        Resource = "${aws_s3_bucket.deel_test_app_bucket.arn}/alb-logs/*"
      }
    ]
  })
}
      
    

# ECR Repository
resource "aws_ecr_repository" "deel_test_ip_app" {
  tags = {
    resourcecreator = "joynal.abedin@gmx.co.uk"
    environment     = var.environment
  }
  name                 = "deel-test-app"
  image_tag_mutability = "IMMUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }

  encryption_configuration {
    encryption_type = "AES256"
  }
}

# Data source for existing VPC

data "aws_vpc" "default" {
  default = true
}

data "aws_internet_gateway" "default" {
  filter {
    name   = "attachment.vpc-id"
    values = [data.aws_vpc.default.id]
  }
}


# Data source for existing subnets
data "aws_subnet" "public" {
  count = length(var.subnet_ids)
  id    = var.subnet_ids[count.index]
}

# Security Group
resource "aws_security_group" "ecs_tasks" {
  tags = {
    resourcecreator = "joynal.abedin@gmx.co.uk"
    environment     = var.environment
  }
  name_prefix = "deel-test-app-ecs-tasks"
  description = "Security group for ECS tasks"
  vpc_id      = var.app_vpc_id

  ingress {
    description     = "Allow traffic from ALB"
    protocol        = "tcp"
    from_port       = 8080
    to_port         = 8080
    security_groups = [aws_security_group.alb.id]
  }

  egress {
    description = "Allow all outbound traffic"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

# ECS Cluster
resource "aws_ecs_cluster" "main" {
  tags = {
    resourcecreator = "joynal.abedin@gmx.co.uk"
    environment     = var.environment
  }
  name = "deel-test-app-cluster"

  setting {
    name  = "containerInsights"
    value = "enabled"
  }
}

# ECS Task Definition
resource "aws_ecs_task_definition" "deel_ip_app" {
  family                   = "deel-test-app"
  execution_role_arn       = aws_iam_role.ecs_task_execution_role.arn
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = 256
  memory                   = 512

  container_definitions = jsonencode([
    {
      name      = "deel-test-app"
      image     = var.image_uri
      essential = true
      readonlyRootFilesystem = true

      portMappings = [
        {
          containerPort = 8080
          hostPort      = 8080
        }
      ]

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.ecs_log_group.name
          awslogs-region        = var.aws_region
          awslogs-stream-prefix = "deel-test-app"
        }
      }
    }
  ])
}

# ECS Service
resource "aws_ecs_service" "deel_ip_app" {
  tags = {
    resourcecreator = "joynal.abedin@gmx.co.uk"
    environment     = var.environment
  }
  name            = "deel-test-app"
  cluster         = aws_ecs_cluster.main.id
  task_definition = aws_ecs_task_definition.deel_ip_app.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    security_groups  = [aws_security_group.ecs_tasks.id]
    subnets          = var.subnet_ids
    assign_public_ip = true
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.deel_ip_app.arn
  container_name   = "deel-test-app"
    container_port   = 8080
  }

  depends_on = [aws_lb_listener.deel_ip_app]
}

# Application Load Balancer
resource "aws_lb" "deel_ip_app_lb" {
  tags = {
    resourcecreator = "joynal.abedin@gmx.co.uk"
    environment     = var.environment
  }
  name                       = "deel-test-app-alb"
  internal                   = false
  load_balancer_type         = "application"
  security_groups            = [aws_security_group.alb.id]
  subnets                    = var.subnet_ids
  drop_invalid_header_fields = true

  enable_deletion_protection = true

  access_logs {
    bucket  = aws_s3_bucket.deel_test_app_bucket.id
    prefix  = "alb-logs"
    enabled = true
  }
}

resource "aws_security_group" "alb" {
  tags = {
    resourcecreator = "joynal.abedin@gmx.co.uk"
    environment     = var.environment
  }
  name_prefix = "deel-test-app-alb"
  description = "Security group for Application Load Balancer"
  vpc_id      = var.app_vpc_id

  ingress {
    description      = "Allow HTTP traffic from internet"
    protocol         = "tcp"
    from_port        = 80
    to_port          = 80
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }

  egress {
    description = "Allow all outbound traffic"
    protocol    = "-1"
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_lb_target_group" "deel_ip_app" {
  tags = {
    resourcecreator = "joynal.abedin@gmx.co.uk"
    environment     = var.environment
  }
  name        = "deel-test-app-tg"
  port        = 8080
  protocol    = "HTTP"
  vpc_id      = var.app_vpc_id
  target_type = "ip"

  health_check {
    enabled             = true
    healthy_threshold   = 2
    interval            = 30
    matcher             = "200"
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    timeout             = 5
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener" "deel_ip_app" {
  load_balancer_arn = aws_lb.deel_ip_app_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.deel_ip_app.arn
  }
}

# CloudWatch Log Group
resource "aws_cloudwatch_log_group" "ecs_log_group" {
  tags = {
    resourcecreator = "joynal.abedin@gmx.co.uk"
    environment     = var.environment
  }
  name              = "/ecs/deel-test-app"
  retention_in_days = 365
}

# IAM Role for ECS Task Execution
resource "aws_iam_role" "ecs_task_execution_role" {
  tags = {
    resourcecreator = "joynal.abedin@gmx.co.uk"
    environment     = var.environment
  }
  name = "deel-test-app-ecs-task-execution-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_task_execution_role_policy" {
  role       = aws_iam_role.ecs_task_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

data "aws_availability_zones" "available" {
  state = "available"
}
