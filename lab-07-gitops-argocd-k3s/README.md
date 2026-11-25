# Lab 07: GitOps Continuous Delivery Pipeline (ArgoCD + K3s + Trivy + Jenkins)

Declarative GitOps continuous delivery pipeline running ArgoCD on a local K3s cluster with automated drift detection, self-healing (`selfHeal: true`), Trivy security scanning, and zero Docker Hub (`docker.io`) dependencies.

## Pipeline Stages

1. **Trivy GitOps Security Scan (`ghcr.io/aquasecurity/trivy`):** Validates both the target workload manifests (`apps/`) and the ArgoCD `Application` manifest (`argocd/`) against `HIGH` and `CRITICAL` misconfigurations.
2. **App Image Build:** Builds `devops-gitops-api:v1.0.0` from `starter-lab/`.
3. **K3s & ArgoCD Control Plane Bootstrap:** Boots K3s with the local Git repository mounted read-only, installs ArgoCD v2.13.2 (replacing `docker.io/redis` with `public.ecr.aws/docker/library/redis:7.2-alpine`), and waits for `argocd-repo-server` and `argocd-application-controller` readiness.
4. **ArgoCD Automated Sync & Health Verification:** Applies `argocd/application.yaml`, waits for ArgoCD to converge to `Sync=Synced` and `Health=Healthy`, and verifies the live `/health` endpoint on the reconciled pods.
5. **Automated Teardown (`post { always }`):** Destroys the ephemeral K3s cluster and temporary `kubeconfig`.
