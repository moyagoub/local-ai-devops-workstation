# Lab 03: Local Kubernetes CI/CD Pipeline (K3s + Trivy + kubectl + Jenkins)

End-to-end Kubernetes deployment pipeline running locally inside a self-contained K3s node container with zero cloud costs and zero Docker Hub (`docker.io`) dependencies.

## Pipeline Stages

1. **Trivy Kubernetes Misconfiguration Scan (`ghcr.io/aquasecurity/trivy`):** Enforces pod security hardening (`runAsNonRoot`, `readOnlyRootFilesystem`, dropped Linux capabilities, `RuntimeDefault` seccomp profile, CPU/memory limits, and liveness/readiness probes).
2. **Container Build:** Builds `devops-lab-api:v1.0.0` from `starter-lab/`.
3. **Self-Contained K3s Cluster (`Dockerfile.k3s` + `registry.k8s.io/pause:3.10`):** Boots a single-node Kubernetes v1.31 cluster built from `public.ecr.aws/docker/library/ubuntu:24.04` and official GitHub K3s release binaries, rewrites `kubeconfig` to the container bridge IP, and imports the local image directly into K3s `containerd` (`docker save | k3s ctr images import -`).
4. **Rollout & Pod Health Smoke Test:** Applies Namespace, Deployment (2 hardened replicas), and ClusterIP Service manifests, waits for rollout completion, and verifies `/health` via `curl` against the Pod IP.
5. **Automated Teardown (`post { always }`):** Removes the K3s container, deletes temporary kubeconfig files, and wipes the Jenkins workspace.
