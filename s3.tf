/**
 * S3
 */
// Create S3 bucket for store Config log

resource "aws_s3_bucket" "main" {
  bucket = "${var.config_logs_bucket}-${md5(var.md5)}"
  region = "${var.region}"
  acl    = "private"
}
