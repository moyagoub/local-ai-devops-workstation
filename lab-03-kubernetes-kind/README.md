# Lab 03: Local Kubernetes CI/CD Pipeline (Kind + Trivy + kubectl + Jenkins)

End-to-end Kubernetes deployment pipeline running locally on Kind (Kubernetes in Docker) with zero cloud costs and zero Docker Hub dependencies.

## Pipeline Stages

1. **Trivy Kubernetes Misconfiguration Scan (`ghcr.io/aquasecurity/trivy`):** Enforces pod security hardening (`runAsNonRoot`, `readOnlyRootFilesystem`, dropped Linux capabilities, `RuntimeDefault` seccomp profile, CPU/memory limits, and liveness/readiness probes).
2. **Container Build:** Builds `devops-lab-api:v1.0.0` from `starter-lab/`.
3. **Ephemeral Kind Cluster (`public.ecr.aws/eks-distro/kubernetes-sigs/kind/node`):** Spins up a single-node Kubernetes cluster, rewrites `kubeconfig` to the control-plane bridge IP so containerized Jenkins can communicate with the API server, and side-loads the local image via `kind load docker-image`.
4. **Rollout & In-Cluster Smoke Test:** Applies Namespace, Deployment (2 replicas), and ClusterIP Service manifests, waits for rollout completion, and verifies `/health` via internal cluster DNS (`devops-lab-api-svc.devops-lab.svc.cluster.local`).
5. **Automated Teardown (`post { always }`):** Deletes the Kind cluster, removes temporary kubeconfig files, and wipes the Jenkins workspace.
