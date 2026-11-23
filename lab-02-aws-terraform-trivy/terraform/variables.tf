variable "aws_region" {
  type        = string
  default     = "us-east-1"
  description = "Target AWS region"
}

variable "localstack_endpoint" {
  type        = string
  default     = "http://localhost:4566"
  description = "LocalStack AWS emulator endpoint"
}

variable "bucket_name" {
  type        = string
  default     = "legion7-devops-artifacts-lab02"
  description = "S3 bucket name for CI/CD artifacts"
}
