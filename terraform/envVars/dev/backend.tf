terraform {
  backend "s3" {
    bucket         = "deel-test-app-bucket"
    key            = "eu-west-2/dev/infrastructure/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "deel-test-app-bucket-locks"
    encrypt        = true
  }
}
