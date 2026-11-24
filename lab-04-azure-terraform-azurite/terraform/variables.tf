variable "location" {
  type        = string
  default     = "eastus"
  description = "Azure region for resource deployment"
}

variable "resource_group_name" {
  type        = string
  default     = "rg-legion7-devops-lab04"
  description = "Azure Resource Group name"
}

variable "storage_account_name" {
  type        = string
  default     = "stlegion7devops04"
  description = "Globally unique lowercase alphanumeric Azure Storage Account name"
}
