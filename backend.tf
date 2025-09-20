terraform {
  backend "s3" {
    bucket = "mydev-project-terraform-sample-batch-aws-devops-azure-29"
    key = "main"
    region = "us-east-1"
    dynamodb_table = "my-dynamodb-table"
  }
}
