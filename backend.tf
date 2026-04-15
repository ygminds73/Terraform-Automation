terraform {
  backend "s3" {
    bucket = "mandar-app-project-terraform-state-123"
    key = "main"
    region = "us-east-1"
    dynamodb_table = "my-dynamodb-table"
  }
}
