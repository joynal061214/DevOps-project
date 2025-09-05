# deel IP Application

A simple web application that displays the client's public IP address in deel order.

## Features

- Returns client IP address deeld (e.g., 1.2.3.4 becomes 4.3.2.1)
- Health check endpoint
- Containerized with Docker
- Deployed on AWS ECS with Terraform
- CI/CD pipeline with security scanning

## Local Development

```bash
pip install -r requirements.txt
python app.py
```

Visit `http://localhost:8080` to see your deeld IP.

## Deployment

The application is automatically deployed via GitHub Actions when code is pushed to the `main` branch.

### Prerequisites

1. AWS Account with appropriate permissions
2. GitHub repository with the following secrets:
   - `AWS_ACCESS_KEY_ID`
   - `AWS_SECRET_ACCESS_KEY`

### Infrastructure

The Terraform configuration creates:
- VPC with public subnets
- Application Load Balancer
- ECS Fargate cluster and service
- ECR repository
- CloudWatch logs
- Security groups with minimal required access

### Security Features

- **IaC Security Scanning**: Checkov scans Terraform files for misconfigurations
- **Vulnerability Scanning**: Trivy scans for secrets and vulnerabilities
- **Container Scanning**: ECR automatically scans pushed images
- **Network Security**: Security groups restrict access to required ports only

## CI/CD Pipeline

The pipeline includes:
1. Security scanning (Trivy for secrets/vulnerabilities, Checkov for IaC)
2. Docker image build and push to ECR
3. Infrastructure deployment with Terraform
4. Application deployment to ECS

## Architecture

```
Internet → ALB → ECS Fargate → Application
```

The application runs on AWS ECS Fargate behind an Application Load Balancer for high availability and scalability.