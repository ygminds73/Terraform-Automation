terraform {
  backend "s3" {
    bucket = "shubhbucket123"
    key = "main"
    region = "us-east-1"
    
  }
}
