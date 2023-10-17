
resource "aws_dynamodb_table" "dynamodb-terraform-lock" {
   name = "terraform-lock"
   hash_key = "LockID"
   read_capacity = 20
   write_capacity = 20

   attribute {
      name = "LockID"
      type = "S"
   }
}
terraform {
  backend "s3" {
    bucket = "grafana-json-collector"
    region = "us-west-2"
    key = "terraform.tfstate"
    dynamodb_table = "terraform-lock"
    encrypt = true
  }
}

provider "aws" {
  region = "us-west-2"
}

