output "s3_bucket_id" {
  value       = aws_s3_bucket.artifacts.id
  description = "Provisioned LocalStack S3 bucket ID"
}

output "s3_bucket_arn" {
  value       = aws_s3_bucket.artifacts.arn
  description = "Provisioned LocalStack S3 bucket ARN"
}
