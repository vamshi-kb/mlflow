resource "aws_s3_bucket" "mlflow_artifact_store" {
  bucket = "${var.name}2-s3"

  tags = {
    Name        = "${var.name}2-s3"
    Environment = "Dev"
  }
}

resource "aws_s3_bucket_acl" "bucket_acl" {
  bucket = aws_s3_bucket.mlflow_artifact_store.id
  acl    = "private"
}