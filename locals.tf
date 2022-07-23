locals {
  service_port            = 80
  db_port                 = 3306
  artifact_bucket_id      = aws_s3_bucket.mlflow_artifact_store.bucket
  
}
