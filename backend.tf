terraform {
  backend "s3" {
    bucket = "batch2-app-nikita"
    key = "main"
    region = "us-east-1"
    dynamodb_table = "my-dynamodb-table"
  }
}
