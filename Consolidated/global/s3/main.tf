provider "aws" {
  region = "eu-west-3"
}

terraform {
  backend "s3" {
    bucket = "eg2-s3bucket-for-shared-terraform-tfstate"
    key    = "global/s3/terraform.tfstate"
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

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "aws:kms"
      }
    }
  }
}

/*
resource "aws_s3_bucket" "mybucket" {
  bucket = "mybucket"

  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        kms_master_key_id = "${aws_kms_key.mykey.arn}"
        sse_algorithm     = "aws:kms"
      }
    }
  }
}

*/

