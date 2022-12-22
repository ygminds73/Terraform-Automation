terraform {
  backend "s3" {
    bucket = "s3-bucket-project-100"
    key = "main"
    region = "ap-south-1"
    dynamodb_table = "my-dynamodb-table"
  }
}
