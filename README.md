# Local AI DevOps & Cloud Workstation

A production-style, **100% local AI-assisted DevOps & Cloud engineering workstation** running on Windows 11 + WSL2 (Ubuntu).

This repository provides tested configurations, Dockerfiles, and CI/CD labs to run local LLMs on an NVIDIA GPU alongside **VS Code**, **Continue**, **Docker**, **Terraform**, **Kubernetes**, **Trivy**, **LocalStack**, and a containerized **Jenkins** controller—with zero cloud API costs and zero Docker Hub (`docker.io`) CDN dependency.

## Architecture Overview

```mermaid
flowchart LR
    subgraph Windows["Windows 11 Host (RTX 3080 16GB VRAM / 32GB RAM)"]
        Ollama["Ollama Server (:11434)<br/>• qwen2.5-coder:1.5b (Autocomplete)<br/>• qwen2.5-coder:14b (DevOps Agent)<br/>• qwen3-coder:30b (Architecture)"]
    end

    subgraph WSL["WSL2: Ubuntu 24.04"]
        VSCode["VS Code + Continue<br/>(.github/copilot-instructions.md)"]
        GitRepo["Local Git Repos<br/>(/workspace/*)"]
        Jenkins["Jenkins LTS Container (:8080)<br/>OpenJDK 21 + Docker CLI"]
        DockerEngine["Docker Engine<br/>(public.ecr.aws / ghcr.io mirrors)"]
        Lab01["Lab 01: Container Build & Health Check"]
        Lab02["Lab 02: Trivy + Terraform + LocalStack AWS"]
    end

    VSCode <-->|"HTTP API"| Ollama
    Jenkins -->|"Local Git SCM"| GitRepo
    Jenkins -->|"docker.sock"| DockerEngine
    DockerEngine --> Lab01
    DockerEngine --> Lab02
```

## Repository Structure

| Path | Description |
| :--- | :--- |
| `.github/copilot-instructions.md` | AI engineering guardrails enforcing least-privilege IAM, KMS encryption, non-root containers, and Declarative Jenkinsfiles. |
| `configs/` | `.wslconfig` resource cap and `continue-config.yaml` dual-model VRAM setup. |
| `jenkins/Dockerfile` | Custom OpenJDK 21 + Docker CLI Jenkins controller built without Docker Hub dependencies. |
| `starter-lab/` | **Lab 01:** Multi-stage Python API image build + Docker bridge IP health check pipeline. |
| `lab-02-aws-terraform-trivy/` | **Lab 02:** DevSecOps AWS pipeline with Trivy IaC scanning, LocalStack S3/KMS emulation, Terraform provisioning, and AWS CLI verification. |
| `scripts/explain-log.sh` | CLI helper to diagnose failed Jenkins/Terraform logs using your local GPU Ollama server. |

## Quick Start Guide

### 1. Configure Ollama on Windows (PowerShell)
Install [Ollama](https://ollama.com), set the environment variables below, and restart Ollama from the system tray:

```powershell
setx OLLAMA_CONTEXT_LENGTH 16384
setx OLLAMA_HOST 0.0.0.0
setx OLLAMA_MAX_LOADED_MODELS 2
```

Pull the models:
```powershell
ollama pull qwen2.5-coder:1.5b   # Inline autocomplete (~1 GB)
ollama pull qwen2.5-coder:14b    # Daily DevOps Chat/Agent (~9 GB)
ollama pull qwen3-coder:30b      # Deep architecture & refactoring (~18 GB)
```

*(Optional)* Copy `configs/.wslconfig` to `C:\Users\<YourUsername>\.wslconfig` and run `wsl --shutdown` to cap WSL2 memory at 14 GB.

### 2. Configure VS Code + Continue (`WSL: Ubuntu`)
1. Copy `configs/continue-config.yaml` to `~/.continue/config.yaml`.
2. Disable GitHub Copilot inline completions (bottom-right status bar) so **Continue** handles ghost-text suggestions without UI overlap.
3. Connect VS Code to **WSL: Ubuntu** and copy `.github/copilot-instructions.md` into your repositories to enforce infrastructure best practices automatically.

### 3. Build & Launch the Local Jenkins Controller
```bash
cd jenkins/

HOST="ftp.belnet.be"
PATH_WAR="mirror/ftp.jenkins-ci.org/war-stable/latest/jenkins.war"
curl -fL "https://HOST/{PATH_WAR}" -o jenkins.war

docker build -t local-jenkins-docker:lts .
```

Start the container with host Docker socket access and local Git SCM checkout enabled:
```bash
DOCKER_GID=\$(stat -c '%g' /var/run/docker.sock)

docker run -d \
  --name jenkins-local \
  --restart unless-stopped \
  -p 8080:8080 \
  -p 50000:50000 \
  --group-add "\$DOCKER_GID" \
  -v jenkins_home:/var/jenkins_home \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v "\$HOME/local-ai-devops-workstation:/workspace/local-ai-devops-workstation:ro" \
  local-jenkins-docker:lts \
  java -Djava.awt.headless=true -Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true -jar /usr/share/jenkins/jenkins.war
```

Trust the mounted Git repository inside Jenkins and retrieve the initial admin password:
```bash
docker exec jenkins-local git config --global --add safe.directory /workspace/local-ai-devops-workstation/.git
docker exec jenkins-local git config --global --add safe.directory /workspace/local-ai-devops-workstation
docker exec jenkins-local cat /var/jenkins_home/secrets/initialAdminPassword
```

### 4. Available Jenkins Labs
- **Lab 01 (`starter-lab/Jenkinsfile`):** Builds a multi-stage Python container from `public.ecr.aws` and verifies its `/health` endpoint via Docker bridge IP.
- **Lab 02 (`lab-02-aws-terraform-trivy/Jenkinsfile`):** Runs Trivy IaC security scanning (`--exit-code 1`), spins up LocalStack (`s3,iam,sts,kms`), provisions a KMS-encrypted S3 bucket with Terraform, uploads a test artifact, verifies bucket encryption via AWS CLI, and cleans up all ephemeral containers/networks.

## License
MIT License
