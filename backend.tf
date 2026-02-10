terraform {
  backend "s3" {
    bucket = "young-minds-app-project-terraform-state-latest"
    key = "main"
    region = "us-east-1"
    dynamodb_table = "my-dynamodb-table"
  }
}
