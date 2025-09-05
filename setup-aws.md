# AWS Setup Guide

## Prerequisites

1. AWS CLI installed and configured
2. Terraform installed
3. GitHub repository created

## Initial Setup

### 1. Create S3 Bucket for Terraform State

```bash
aws s3 mb s3://deel-ip-terraform-state --region eu-west-2
aws s3api put-bucket-versioning --bucket deel-ip-terraform-state --versioning-configuration Status=Enabled
```

### 2. Create IAM User for GitHub Actions

```bash
aws iam create-user --user-name github-actions-deel-ip
aws iam attach-user-policy --user-name github-actions-deel-ip --policy-arn arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess
aws iam attach-user-policy --user-name github-actions-deel-ip --policy-arn arn:aws:iam::aws:policy/AmazonECS_FullAccess
aws iam attach-user-policy --user-name github-actions-deel-ip --policy-arn arn:aws:iam::aws:policy/AmazonVPCFullAccess
aws iam attach-user-policy --user-name github-actions-deel-ip --policy-arn arn:aws:iam::aws:policy/ElasticLoadBalancingFullAccess
aws iam attach-user-policy --user-name github-actions-deel-ip --policy-arn arn:aws:iam::aws:policy/IAMFullAccess
aws iam attach-user-policy --user-name github-actions-deel-ip --policy-arn arn:aws:iam::aws:policy/CloudWatchLogsFullAccess

aws iam create-access-key --user-name github-actions-deel-ip
```

### 3. Configure GitHub Secrets

Add these secrets to your GitHub repository:
- `AWS_ACCESS_KEY_ID`: From the access key created above
- `AWS_SECRET_ACCESS_KEY`: From the access key created above

### 4. Initial Terraform Setup (Optional - for manual deployment)

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Security Considerations

- The IAM user has broad permissions for demo purposes
- In production, use more restrictive policies
- Consider using OIDC instead of long-lived access keys
- Enable CloudTrail for audit logging