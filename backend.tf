terraform {
  backend "s3" {
    bucket = "mydev-project-terraform-batch-24-shubh-bucket-123"
    key = "main"
    region = "us-east-1"
    
  }
}
