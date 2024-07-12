terraform {
  backend "s3" {
    bucket = "shubhbucket123"
    key = "main"
    region = "ap-south-1"
    dynamodb_table = "mangodb"
  }
}
