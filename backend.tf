terraform {
  backend "s3" {
    bucket = "mydev-tf-state-bucket-project-terraproject-01"
    key = "main/terraform.tfstate"
    region = "us-east-1"
    dynamodb_table = "my-dynamodb-table_01"
  }
}
