terraform {
  backend "s3" {
    bucket = "bucketpro"
    key = "main"
    region = "ap-south-1"
    dynamodb_table = "my-dynamodb-table"
  }
}
