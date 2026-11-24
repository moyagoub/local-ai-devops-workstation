# Lab 04: Azure DevSecOps & Storage CI/CD Pipeline (Trivy + Terraform AzureRM + Azurite + Azure CLI)

Zero-cost, offline-capable Azure Infrastructure-as-Code validation and Azure Blob Storage pipeline running in Jenkins using Microsoft Artifact Registry (`://microsoft.com`) images.

## Pipeline Stages

1. **Trivy Azure IaC Security Scan (`ghcr.io/aquasecurity/trivy`):** Enforces TLS 1.2 minimum, HTTPS-only traffic, private blob access, blob versioning, and deny-by-default network rules on `azurerm_storage_account`.
2. **Terraform AzureRM Format & Validate (`public.ecr.aws/hashicorp/terraform:1.9`):** Runs `terraform fmt -check`, `terraform init -backend=false`, and `terraform validate` offline against the `hashicorp/azurerm` v4 provider schema.
3. **Azurite Emulator & Azure CLI Verification (`://microsoft.com/azure-storage/azurite` + `://microsoft.com/azure-cli`):** Starts an isolated Azurite Blob emulator on `lab04-net`, creates a private container (`jenkins-artifacts`), uploads a build artifact, and lists it via `az storage blob list`.
4. **Automated Teardown (`post { always }`):** Removes `azurite-lab04`, deletes `lab04-net`, and wipes the Jenkins workspace.
