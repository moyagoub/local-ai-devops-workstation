# DevOps & Cloud Engineering Rules
- Always target current stable versions for Terraform providers (AWS, AzureRM), Kubernetes APIs, and Jenkins plugins.
- Follow least-privilege IAM/RBAC principles; never output wildcard (`*`) permissions without explaining why.
- For Dockerfiles: avoid `docker.io` (Docker Hub); use `public.ecr.aws/docker/library/` or `://microsoft.com` mirror base images instead. Use multi-stage builds, pin tags, and run as a non-root user.
- For Terraform: separate `providers.tf`, `variables.tf`, `main.tf`, and `outputs.tf` with variable descriptions and types.
- For Kubernetes: always define `resources.requests`, `resources.limits`, `livenessProbe`, and `readinessProbe`.
- For Jenkins: always write Declarative Pipelines (`pipeline { agent any ... }`), use `withCredentials(...)` for secrets, wrap shell steps in `sh '''...'''` with `set -e`, and include `post { always { cleanWs() } }`.
- Warn before destructive CLI commands (`terraform destroy`, `kubectl delete`) and suggest `--dry-run` or `plan` first.
