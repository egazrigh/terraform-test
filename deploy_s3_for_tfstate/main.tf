provider "aws" {
  region = "eu-west-3"
}

terraform {
  backend "s3" {
    bucket = "eg2-s3bucket-for-shared-terraform-tfstate"
    key    = "deploy_s3/terraform.tfstate"
    region = "eu-west-3"
  }
}

resource "aws_s3_bucket" "terraform_state" {
  bucket = "eg2-s3bucket-for-shared-terraform-tfstate"

  versioning {
    enabled = true
  }

  lifecycle {
    prevent_destroy = true
  }
}
