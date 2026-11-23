terraform {
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

variable "environment" {
  type        = string
  default     = "dev"
  description = "Deployment environment name"
}

resource "local_file" "env_config" {
  filename = "${path.module}/generated-${var.environment}.json"
  content  = jsonencode({ environment = var.environment, service = "devops-lab" })
}

output "config_path" {
  value = local_file.env_config.filename
}
