---
tags:
  - devops
  - sre
  - ai-setup
  - ollama
  - vscode
  - continue
  - jenkins
  - docker
  - terraform
  - kubernetes
  - k3s
  - ansible
  - prometheus
  - grafana
  - trivy
  - localstack
  - azurite
  - aws
  - azure
hardware: Lenovo Legion 7 (2021) - RTX 3080 (16GB VRAM) / 32GB RAM
os: Windows 11 + WSL2 (Ubuntu 24.04)
repo: https://github.com/moyagoub/local-ai-devops-workstation
---

# Complete Local AI DevOps, Cloud & SRE Workstation Guide

A comprehensive, step-by-step engineering guide covering the full setup of a **100% local AI-assisted DevOps, Cloud & SRE workstation** on Windows 11 + WSL2 (Ubuntu)—including every real-world infrastructure fix and all **6 verified CI/CD labs**.

---

## 1. Runtime & Model Architecture (RTX 3080 16GB VRAM / 32GB RAM)

- **Selected Runtime:** **Ollama** (runs quietly as a Windows background service with minimal idle overhead and native WSL2/VS Code support).
- **Model Strategy:**

| Model Tag | Size | VRAM Fit | Role |
| :--- | :--- | :--- | :--- |
| `qwen2.5-coder:1.5b` | ~1.0 GB | **100% GPU** | Ultra-fast inline ghost-text autocomplete (Continue). |
| `qwen2.5-coder:14b` | ~9.0 GB | **100% GPU** | Primary daily driver for Chat, Agent edits, Terraform, K8s, Docker, and Jenkins. |
| `qwen3-coder:30b` | ~18.0 GB | GPU + ~3GB RAM | Heavy multi-file architecture and deep troubleshooting. |

---

## 2. Windows Host Setup (PowerShell)

### Step 1: Install Ollama & Set Environment Variables
1. Download and install **Ollama for Windows** from [ollama.com](https://ollama.com).
2. Open **Windows PowerShell** and run:
   ```powershell
   # Support long Terraform/Kubernetes/Jenkins files
   setx OLLAMA_CONTEXT_LENGTH 16384

   # Expose Ollama to WSL2 and Docker containers
   setx OLLAMA_HOST 0.0.0.0

   # Keep both autocomplete (1.5b) and daily chat (14b) loaded in VRAM simultaneously
   setx OLLAMA_MAX_LOADED_MODELS 2
   ```
   > **Important:** Quit Ollama from the Windows system tray and reopen it from the Start Menu so these variables take effect.

3. Pull your models in PowerShell:
   ```powershell
   ollama pull qwen2.5-coder:1.5b
   ollama pull qwen2.5-coder:14b
   ollama pull qwen3-coder:30b
   ```

4. Verify GPU offloading anytime:
   ```powershell
   ollama ps
   ```
   *(Both `qwen2.5-coder:1.5b` and `qwen2.5-coder:14b` should show `100% GPU`).*

### Step 2: Cap WSL2 Memory (`C:\Users\<YourUsername>\.wslconfig`)
Create or edit `.wslconfig` so Docker, Jenkins, and Kubernetes labs never starve Windows or your GPU:

```ini
[wsl2]
memory=14GB
processors=6
swap=4GB
```

Apply in PowerShell:
```powershell
wsl --shutdown
```

---

## 3. VS Code + Continue Configuration

### Step 1: Configure Continue (`~/.continue/config.yaml`)
Copy `configs/continue-config.yaml` to `~/.continue/config.yaml` (or open Continue Settings → `config.yaml`, paste below, and press `Ctrl + S`):

```yaml
name: Main Config
version: 1.0.0
schema: v1

models:
  - name: Qwen 2.5 Coder 14B
    provider: ollama
    model: qwen2.5-coder:14b
    apiBase: http://localhost:11434
    roles:
      - chat
      - edit
      - apply

  - name: Qwen 3 Coder 30B
    provider: ollama
    model: qwen3-coder:30b
    apiBase: http://localhost:11434
    roles:
      - chat
      - edit

  - name: Qwen2.5-Coder 1.5B
    provider: ollama
    model: qwen2.5-coder:1.5b
    apiBase: http://localhost:11434
    roles:
      - autocomplete

  - name: Autodetect
    provider: ollama
    model: AUTODETECT
    apiBase: http://localhost:11434
```

### Step 2: Prevent Autocomplete Overlap
- Click the **Copilot status icon** in the bottom-right VS Code status bar and uncheck **Completions** so **Continue (`qwen2.5-coder:1.5b`)** handles 100% of inline ghost-text suggestions cleanly.

### Step 3: Connect VS Code to WSL2 & Install Extensions
1. Click the **`><` remote icon** (bottom-left of VS Code) → **Connect to WSL**.
2. Install these extensions inside your **`WSL: Ubuntu`** window (`Ctrl + Shift + X`):
   - **Containers & K8s:** `Docker` (`ms-azuretools.vscode-docker`), `Kubernetes` (`ms-kubernetes-tools.vscode-kubernetes-tools`)
   - **IaC:** `HashiCorp Terraform` (`HashiCorp.terraform`)
   - **Cloud:** `AWS Toolkit`, `Azure Tools`
   - **CI/CD (Jenkins):** `Jenkins Pipeline Linter Connector`, `Groovy Lint`

---

## 4. WSL2 Docker Permissions, Buildx & Key Infrastructure Fixes (`WSL: Ubuntu`)

### Step 1: Configure Docker Permissions & Buildx
```bash
# 1. Add your user to the docker group
sudo usermod -aG docker $USER
newgrp docker

# 2. Install Buildx plugin and essential CLI tools
sudo apt-get update && sudo apt-get install -y docker-buildx-plugin make curl tree jq || sudo apt-get install -y docker-buildx make curl tree jq
```

### Step 2: Install `kubectl` and `kind` on the WSL2 Host
Because the containerized Jenkins controller mounts `/usr/local/bin/kubectl` and `/usr/local/bin/kind` read-only from the host, install both once in WSL2:
```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"
sudo install -o root -g root -m 0755 kubectl /usr/local/bin/kubectl && rm -f kubectl

curl -Lo ./kind https://kind.sigs.k8s.io/dl/v0.25.0/kind-linux-amd64
sudo install -o root -g root -m 0755 kind /usr/local/bin/kind && rm -f kind
```

### Step 3: Critical Real-World Engineering Fixes Applied Across All Labs
1. **Zero Docker Hub (`docker.io`) CDN Dependency:** Docker Hub CloudFront CDN can block blob downloads with `403 Forbidden`. Every Dockerfile and pipeline pulls exclusively from resilient mirrors:
   - `public.ecr.aws/docker/library/...` & `public.ecr.aws/localstack/...` & `public.ecr.aws/hashicorp/...`
   - `mcr.microsoft.com/azure-storage/azurite` & `mcr.microsoft.com/azure-cli`
   - `ghcr.io/aquasecurity/trivy`
   - `quay.io/prometheus/...` & `quay.io/argoproj/...`
   - `registry.k8s.io/pause:3.10`
2. **Sibling Container Networking (`docker inspect` Bridge IP):** Inside a containerized Jenkins controller (`jenkins-local`), `localhost` refers to the Jenkins container itself—not sibling containers started via `/var/run/docker.sock`. Every lab dynamically inspects the target container's Docker bridge IP (`docker inspect -f '{{range.NetworkSettings.Networks}}{{.IPAddress}}{{end}}'`) or attaches `jenkins-local` to the lab's bridge network (`docker network connect`).
3. **Dynamic Host Bind-Mount Path Resolution (`REPO_ROOT`):** Instead of hardcoding `/home/<username>/...` inside `Jenkinsfile`s, each pipeline resolves the host bind mount dynamically via `docker inspect` on `jenkins-local` so the repository is 100% portable across any user or directory.
4. **Offline Terraform Provider Caching (`TF_PLUGIN_CACHE_DIR`):** Pre-populating `~/.terraform.d/plugin-cache` with the `hashicorp/aws` and `hashicorp/azurerm` providers lets `terraform init` finish offline in `< 1 second` without re-downloading ~200 MB binaries on every pipeline run.

---

## 5. Custom AI Guardrails (`.github/copilot-instructions.md`)

The repository includes `.github/copilot-instructions.md` so Ollama automatically enforces security and reliability standards across every prompt:
- Avoid `docker.io`; use `public.ecr.aws`, `mcr.microsoft.com`, `ghcr.io`, `quay.io`, or `registry.k8s.io`.
- Use multi-stage Docker builds, pinned tags, and non-root container users (`USER appuser`).
- Enforce AWS KMS CMK encryption with key rotation and S3 public access blocks in Terraform.
- Enforce `runAsNonRoot`, `readOnlyRootFilesystem`, dropped `ALL` capabilities, `RuntimeDefault` seccomp, resource requests/limits, and health probes in Kubernetes manifests.
- Write Declarative Jenkinsfiles (`pipeline { agent any ... }`) with `set -e` and `post { always { cleanWs() } }`.

---

## 6. Containerized Jenkins Controller Setup (`Makefile`)

### Step 1: Clone the Repository & Pre-Cache Terraform Providers
```bash
cd ~
git clone https://github.com/moyagoub/local-ai-devops-workstation.git
cd ~/local-ai-devops-workstation

# Pre-populate offline Terraform provider cache (AWS + AzureRM)
mkdir -p ~/.terraform.d/plugin-cache
for dir in lab-02-aws-terraform-trivy/terraform lab-04-azure-terraform-azurite/terraform; do
  docker run --rm \
    -v "$PWD/$dir:/infra" \
    -v "$HOME/.terraform.d/plugin-cache:/plugin-cache" \
    -e TF_PLUGIN_CACHE_DIR=/plugin-cache \
    -w /infra \
    public.ecr.aws/hashicorp/terraform:1.9 init -backend=false -input=false
done
```

### Step 2: Download Jenkins WAR & Build `local-jenkins-docker:lts`
*(Uses `ftp.belnet.be` mirror to bypass CloudFront `403` blocks and installs full `openjdk-21-jre` + `libharfbuzz0b` + `docker.io`)*:
```bash
cd ~/local-ai-devops-workstation/jenkins
curl -fL "https://ftp.belnet.be/mirror/ftp.jenkins-ci.org/war-stable/latest/jenkins.war" -o jenkins.war
cd ~/local-ai-devops-workstation
make jenkins-build
```

### Step 3: Launch Jenkins & Unlock Web UI
```bash
make jenkins-up
make jenkins-password
```
1. Open **`http://localhost:8080`** in your browser.
2. Paste the password printed by `make jenkins-password`.
3. Click **Install suggested plugins**, create your admin user, and reach the Jenkins Dashboard.

*(Useful `Makefile` commands anytime: `make jenkins-up`, `make jenkins-password`, `make clean`)*

---

## 7. Step-by-Step Guide to All 6 CI/CD & DevSecOps Labs

For every lab below, create a **Pipeline** job in Jenkins (`http://localhost:8080`):
1. Click **New Item** → enter the job name → select **Pipeline** → click **OK**.
2. Under **Pipeline**, set **Definition** to **Pipeline script from SCM** → **SCM**: **Git**.
3. Set **Repository URL** to `/workspace/local-ai-devops-workstation` and **Branch Specifier** to `*/main`.
4. Set **Script Path** to the lab's `Jenkinsfile` listed below, click **Save**, and click **Build Now**.

---

### Lab 01: Container Build & Bridge Health Check (`starter-lab/`)
- **Script Path:** `starter-lab/Jenkinsfile`
- **What It Does:**
  1. Builds a multi-stage, non-root Python 3.12 Flask API image (`devops-lab-api:local`) from `starter-lab/`.
  2. Starts `test-api` on the Docker bridge network, inspects its dynamic container IP (`docker inspect`), and verifies `http://<CONTAINER_IP>:8080/health` returns `{"env":"local-lab","status":"ok"}`.
  3. Cleans up `test-api` in `post { always }`.

---

### Lab 02: AWS DevSecOps Pipeline (`lab-02-aws-terraform-trivy/`)
- **Script Path:** `lab-02-aws-terraform-trivy/Jenkinsfile`
- **What It Does:**
  1. **Trivy IaC Security Scan (`ghcr.io/aquasecurity/trivy`):** Scans `terraform/` with `--severity HIGH,CRITICAL --exit-code 1`, enforcing KMS Customer Managed Key encryption (`enable_key_rotation = true`), bucket versioning, and S3 public access blocks (`AWS-0132`).
  2. **LocalStack Cloud Emulator (`public.ecr.aws/localstack/localstack:3.8.1`):** Launches LocalStack (`SERVICES=s3,iam,sts,kms`) on bridge network `lab02-net`.
  3. **Terraform Provisioning (`public.ecr.aws/hashicorp/terraform:1.9`):** Uses the shared offline `TF_PLUGIN_CACHE_DIR`, runs `fmt -check`, `validate`, `plan`, and `apply -auto-approve`.
  4. **AWS CLI Verification (`public.ecr.aws/aws-cli/aws-cli`):** Uploads `artifact.txt` to the KMS-encrypted S3 bucket and verifies `s3api get-bucket-encryption`.

---

### Lab 03: Hardened Local Kubernetes CI/CD Pipeline (`lab-03-kubernetes-kind/`)
- **Pre-requisite (Run once in WSL2):**
  ```bash
  docker build -f lab-03-kubernetes-kind/Dockerfile.k3s -t local-k3s-node:v1.31.2 lab-03-kubernetes-kind
  ```
- **Script Path:** `lab-03-kubernetes-kind/Jenkinsfile`
- **What It Does:**
  1. **Trivy Kubernetes Manifest Scan:** Validates `k8s/` manifests (`runAsNonRoot`, `readOnlyRootFilesystem`, dropped `ALL` capabilities, `RuntimeDefault` seccomp, resource requests/limits, liveness/readiness probes).
  2. **App Image Build:** Builds `devops-k8s-api:v1.0.0`.
  3. **Self-Contained K3s Cluster Bootstrap:** Starts `local-k3s-node:v1.31.2` with `--pause-image=registry.k8s.io/pause:3.10`, extracts and rewrites `kubeconfig` to the K3s container IP, and side-loads `devops-k8s-api:v1.0.0` via `docker save | k3s ctr images import -`.
  4. **Rollout & Pod Smoke Test:** Applies `namespace.yaml`, `deployment.yaml` (2 replicas), and `service.yaml`, waits for rollout completion, and queries `/health` directly on the Pod IP.

---

### Lab 04: Azure DevSecOps & Storage Pipeline (`lab-04-azure-terraform-azurite/`)
- **Script Path:** `lab-04-azure-terraform-azurite/Jenkinsfile`
- **What It Does:**
  1. **Trivy AzureRM Security Scan:** Enforces `min_tls_version = "TLS1_2"`, `https_traffic_only_enabled = true`, private blob access, and deny-by-default network ACLs (`AZU-0011`, `AZU-0012`).
  2. **Terraform Validation:** Runs offline `init` (via `TF_PLUGIN_CACHE_DIR`), `fmt -check`, and `validate` against `hashicorp/azurerm` v4.
  3. **Azurite & Azure CLI Integration (`mcr.microsoft.com`):** Spins up Azurite Blob Storage on `lab04-net`, creates the `jenkins-artifacts` container, uploads `azure-build.txt`, and verifies via `az storage blob list -o table`.

---

### Lab 05: Ansible Server Hardening & Idempotency Pipeline (`lab-05-ansible-hardening/`)
- **Pre-requisite (Run once in WSL2):**
  ```bash
  docker build -f lab-05-ansible-hardening/Dockerfile.ansible -t local-ansible-runner:latest lab-05-ansible-hardening
  ```
- **Script Path:** `lab-05-ansible-hardening/Jenkinsfile`
- **What It Does:**
  1. **Lint & Syntax Check:** Runs `ansible-lint` (production profile) and `ansible-playbook --syntax-check`.
  2. **Server Hardening & Web Deployment:** Launches a minimal Ubuntu target container, bootstraps `python3` via `ansible.builtin.raw`, creates a non-root `devops` user, hardens `/etc/ssh/sshd_config` (`PermitRootLogin no`, `PasswordAuthentication no`), and deploys hardened Nginx on port `8085`.
  3. **Idempotency & Security Header Gates:** Re-runs the playbook and asserts **`changed=0`**, then verifies `X-Frame-Options: DENY` and `X-Content-Type-Options: nosniff` via `curl -I`.

---

### Lab 06: Prometheus & Grafana Observability Pipeline (`lab-06-prometheus-grafana/`)
- **Script Path:** `lab-06-prometheus-grafana/Jenkinsfile`
- **What It Does:**
  1. **Prometheus Config & Alert Validation:** Runs `promtool check config /etc/prometheus/prometheus.yml` and validates `alert-rules.yml`.
  2. **Multi-Container Observability Stack (`lab06-monitoring`):** Starts the instrumented Python `/metrics` API, `node-exporter`, `prometheus` (`:9090`), and `grafana` (`:3000`) with auto-provisioned Prometheus datasource YAML, temporarily attaching `jenkins-local` to `lab06-monitoring`.
  3. **Telemetry & Provisioning Verification:** Generates traffic on `/health`, scrapes `/metrics`, verifies all 3 Prometheus scrape targets are `"health":"up"`, and confirms Grafana's provisioned Prometheus datasource via REST API.

---

## 8. Terminal Log Debugger Helper (`scripts/explain-log.sh`)

Add this helper to `~/.bashrc` (or run `./scripts/explain-log.sh`) to diagnose failed Jenkins, Terraform, or Kubernetes logs straight from your terminal using your local RTX 3080 GPU:

```bash
explain-log() {
  curl -s http://localhost:11434/api/generate \
    -d "\$(jq -n --arg log "\$1" '{model: "qwen2.5-coder:14b", prompt: ("Diagnose this Jenkins/DevOps error and give the exact fix:\n\n" + \$log), stream: false}')" \
    | jq -r '.response'
}
```
