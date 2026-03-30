terraform {
  backend "s3" {
    bucket         = "tanuj bucket "
    key            = "env/dev/terraform.tfstate"
    region         = "us-east-1"

    # Enable state locking
    dynamodb_table = "terraform-state-lock"

    # Security best practices
    encrypt        = true

    # Optional but recommended
    versioning     = true

    # Optional: for multi-account / profile usage
    # profile      = "default"

    # Optional: custom endpoint (if using localstack/minio)
    # endpoint     = "s3.amazonaws.com"
  }
}
