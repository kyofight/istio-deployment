// Create S3 for Kops State
resource "aws_s3_bucket" "k8-state" {
  bucket = "${local.s3_kops_state}"
  acl = "private"
  force_destroy = true
  tags = "${merge(local.tags)}"
}
