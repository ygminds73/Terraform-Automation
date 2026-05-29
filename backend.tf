terraform {
  backend "s3" {
    bucket = "amezon-s3-odc"
    key = "main"
    region = "ap-south-1"
    dynamodb_table = "my-dynamodb-table"
  }
}
