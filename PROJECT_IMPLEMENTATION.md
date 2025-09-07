# Deel IP Application - AWS ECS Fargate Implementation

Please note: I have developed this on Windows using VS code so you might have an issue with LF will be replaced by CRLF in all terraform file if you test this on any Linux.

## Project Overview
A containerised web application that displays client IP addresses in reversed format, deployed on AWS ECS Fargate with complete CI/CD automation.

## Architecture

### AWS Infrastructure
- **Compute**: AWS ECS Fargate cluster (`deel-test-app-cluster`)
- **Load Balancer**: Application Load Balancer for high availability
- **Container Registry**: Amazon ECR for Docker image storage
- **Networking**: Default VPC with public subnets
- **Storage**: S3 bucket for ALB access logs
- **Monitoring**: CloudWatch logs for application monitoring

### Application Stack
- **Runtime**: Python Flask application
- **Container**: Docker containerised deployment
- **Port**: Application runs on port 8080
- **Health Check**: `/health` endpoint for load balancer monitoring

## Deployment Architecture

```
GitHub → CI/CD Pipeline → ECR → ECS Fargate → ALB → Internet
```

### Infrastructure as Code
- **Terraform**: Complete infrastructure provisioning with modular architecture
- **State Management**: S3 backend with DynamoDB locking
- **Environment**: Parameterised for dev/staging/prod
- **Modular Design**: Enterprise-grade module structure

### Terraform Modules Architecture
- **S3 Module**: Bucket with encryption, versioning, lifecycle policies, and ALB access logging
- **ECR Module**: Container registry with vulnerability scanning and encryption
- **IAM Module**: Task execution roles with least privilege access
- **ALB Module**: Load balancer, target groups, listeners, and security groups
- **ECS Module**: Cluster, service, task definitions, and CloudWatch integration

**Module Benefits:**
- **Reusability**: Modules can be deployed across multiple environments
- **Maintainability**: Single responsibility principle for each component
- **Testability**: Independent validation and testing of modules
- **Scalability**: Easy extension and modification of individual components
- **Code Organization**: Clean separation of concerns and dependencies
- **Version Control**: Individual module versioning and lifecycle management

## Implementation Details

### 1. Containerisation
- Docker image built from Python Flask application
- Multi-stage build for optimised image size
- Security hardening with non-root user

### 2. AWS ECS Fargate Deployment
- **Cluster**: `deel-test-app-cluster`
- **Service**: `deel-test-app` with desired count of 1
- **Task Definition**: 256 CPU, 512 MB memory
- **Network Mode**: `awsvpc` for enhanced security

### 3. Load Balancing & Networking
- **ALB**: `deel-test-app-alb` for traffic distribution
- **Target Group**: Health checks on `/health` endpoint
- **Security Groups**: Restricted access (ALB → ECS on port 8080)

### 4. CI/CD Pipeline
- **Trigger**: Push to `deel_ip_test` or `main` branch
- **Security Scanning**: TFSec, Trivy, and Checkov integration
- **Build Process**: Docker build → ECR push → ECS deployment
- **Infrastructure**: Terraform plan and apply automation

## Security Implementation

### Container Security
- **Image Scanning**: ECR automatic vulnerability scanning
- **Read-only Root Filesystem**: Enhanced container security
- **Secrets Management**: Not implemented for a test app

### Network Security
- **Security Groups**: Minimal required access
- **ALB**: Drop invalid header fields enabled
- **S3**: Public access blocked, encryption enabled

### Infrastructure Security
- **IaC Scanning**: Checkov for Terraform misconfigurations
- **Vulnerability Scanning**: Trivy for code and dependencies
- **Access Logs**: ALB logs stored in encrypted S3 bucket

## Monitoring & Logging

### CloudWatch Integration
- **Log Group**: `/ecs/deel-test-app`
- **Retention**: 365 days
- **Container Insights**: Enabled for cluster monitoring

### Health Monitoring
- **ALB Health Checks**: HTTP 200 on `/health`
- **ECS Service**: Automatic task replacement on failure
- **Metrics**: CPU, memory, and network monitoring

## Deployment Process

### Automated Deployment
1. Code push triggers GitHub Actions
2. Security scans (continue on error for non-blocking)
3. Docker image build and ECR push
4. Terraform infrastructure deployment
5. ECS service update with new image

### Manual Operations
- **Destroy Infrastructure**: Workflow dispatch trigger
- **Resource Import**: Existing resources integration
- **State Management**: Force unlock capabilities

## Access Information

### Application Access
- **Public URL**: Via ALB DNS name
- **Health Check**: `http://<alb-dns>/health`
- **Main App**: `http://<alb-dns>/` (returns reversed IP)

### AWS Resources
- **Region**: eu-west-2 (London)
- **ECR Repository**: `deel-test-app`
- **ECS Cluster**: `deel-test-app-cluster`
- **Load Balancer**: `deel-test-app-alb`

## Key Features Implemented

### High Availability
- ECS Fargate for serverless container management
- ALB for traffic distribution and health monitoring
- Multi-AZ deployment across public subnets

### Scalability
- ECS service auto-scaling capabilities
- Fargate serverless compute scaling
- Load balancer for traffic distribution

### Security
- Container image vulnerability scanning
- Infrastructure security scanning
- Network security with security groups
- Encrypted storage and logging

### Observability
- CloudWatch logs and metrics
- ALB access logging
- Container insights monitoring
- Health check endpoints

## Environment Configuration

### Variables
- `environment`: dev/staging/prod
- `aws_region`: eu-west-2
- `image_uri`: Dynamic from ECR push
- `subnet_ids`: Public subnet configuration

### Secrets
- `AWS_ACCESS_KEY_ID`: GitHub Actions secret for Simplicity
- `AWS_SECRET_ACCESS_KEY`: GitHub Actions secret

## Success Metrics
-  Application containerised and deployed on ECS Fargate
-  Complete infrastructure automation with Terraform
-  CI/CD pipeline with security scanning
-  High availability with load balancer
-  Monitoring and logging implementation
-  Security best practices implementation

## Future Enhancements

A separate document provided for further improvement called "IMPROVEMENTS.md"