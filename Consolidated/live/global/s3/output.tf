output "s3_bucket_arn" {
  description = "Print S3 Bucket name"
  value       = "${aws_s3_bucket.terraform_state.arn}"
}
