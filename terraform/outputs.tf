output "load_balancer_dns" {
  description = "DNS name of the load balancer"
  value       = aws_lb.deel_ip_app_lb.dns_name
}

output "s3_bucket_name" {
  description = "Name of the S3 bucket created for deel-test-app"
  value       = aws_s3_bucket.deel_test_app_bucket.bucket
}