output "resource_group_id" {
  value       = azurerm_resource_group.lab.id
  description = "Azure Resource Group ID"
}

output "storage_account_primary_blob_endpoint" {
  value       = azurerm_storage_account.artifacts.primary_blob_endpoint
  description = "Primary Azure Blob Storage endpoint"
}
