# Local AI DevOps & Cloud Workstation

A production-style, **100% local AI-assisted DevOps & Cloud engineering workstation** running on Windows 11 + WSL2 (Ubuntu).

This repository provides tested configurations, Dockerfiles, and CI/CD templates to run local LLMs on an NVIDIA GPU alongside **VS Code**, **Continue**, **Docker**, **Terraform**, **Kubernetes**, and a containerized **Jenkins** controller—with zero cloud API costs and zero Docker Hub (`docker.io`) CDN dependency.

## Key Features

- **Dual-Model GPU Residency (`Ollama`):** Runs `qwen2.5-coder:1.5b` for sub-second inline autocomplete alongside `qwen2.5-coder:14b` for daily DevOps chat/agent tasks simultaneously in VRAM (`100% GPU`), with `qwen3-coder:30b` available for heavy architectural refactoring.
- **IDE Integration (`VS Code + Continue`):** Pre-configured `continue-config.yaml` and `.github/copilot-instructions.md` guardrails enforcing least-privilege IAM, multi-stage non-root Dockerfiles, resource limits, and Declarative Jenkinsfiles.
- **Self-Contained Jenkins + Docker CI/CD:** Custom OpenJDK 21 Jenkins controller (`local-jenkins-docker:lts`) with Docker socket access, local Git SCM checkout support, and container bridge IP health checks.
- **CDN-Resilient Registry Mirrors:** Uses `public.ecr.aws` and `://microsoft.com` mirrors to avoid Docker Hub CloudFront rate limits and regional `403 Forbidden` blocks.

## Reference Hardware & Stack

| Component | Specification / Tool |
| :--- | :--- |
| **Host OS** | Windows 11 + WSL2 (Ubuntu 24.04) |
| **Reference Hardware** | NVIDIA RTX 3080 (16 GB VRAM) / 32 GB System RAM *(adaptable to 8GB+ VRAM)* |
| **LLM Runtime** | Ollama (`localhost:11434`) |
| **IDE & Extensions** | VS Code + Continue, Docker, Kubernetes, HashiCorp Terraform, AWS/Azure Toolkits |
| **CI/CD** | Jenkins LTS (OpenJDK 21 + Docker CLI) |

## Quick Start Guide

### 1. Configure Ollama on Windows (PowerShell)
Install Ollama, set the environment variables below, and restart Ollama from the system tray:

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
(Optional) Copy configs/.wslconfig to C:\Users\<YourUsername>\.wslconfig and run wsl --shutdown to cap WSL2 memory at 14 GB.

2. Configure VS Code + Continue (WSL: Ubuntu)

1. Copy configs/continue-config.yaml to ~/.continue/config.yaml.
2. Disable GitHub Copilot inline completions (bottom-right status bar) so Continue handles ghost-text suggestions without UI overlap.
3. Connect VS Code to WSL: Ubuntu and copy .github/copilot-instructions.md into your repositories to enforce infrastructure best practices automatically.

3. Build & Launch the Local Jenkins Controller

```bash
cd jenkins/
HOST="ftp.belnet.be"
PATH_WAR="mirror/ftp.jenkins-ci.org/war-stable/latest/jenkins.war"
curl -fL "https://${HOST}/${PATH_WAR}" -o jenkins.war
docker build -t local-jenkins-docker:lts .
```
Start the container with host Docker socket access and local Git SCM checkout enabled:
```bash
DOCKER_GID=$(stat -c '%g' /var/run/docker.sock)
docker run -d 
--name jenkins-local 
--restart unless-stopped 
-p 8080:8080 
-p 50000:50000 
--group-add "$DOCKER_GID" 
-v jenkins_home:/var/jenkins_home 
-v /var/run/docker.sock:/var/run/docker.sock 
-v "$HOME/devops-lab:/workspace/devops-lab:ro" 
local-jenkins-docker:lts 
java -Djava.awt.headless=true -Dhudson.plugins.git.GitSCM.ALLOW_LOCAL_CHECKOUT=true -jar /usr/share/jenkins/jenkins.war
```
Retrieve the initial admin password and open http://localhost:8080:
bash docker exec jenkins-local cat /var/jenkins_home/secrets/initialAdminPassword 

4. Run the Starter DevOps Lab

1. Trust your mounted local Git directory inside Jenkins:
   bash docker exec jenkins-local git config --global --add safe.directory /workspace/devops-lab/.git docker exec jenkins-local git config --global --add safe.directory /workspace/devops-lab    
2. In Jenkins (http://localhost:8080), create a Pipeline job using Pipeline script from SCM pointing to /workspace/devops-lab and click Build Now.

Post-Build Verification Checklist

• GPU Offloading: Run ollama ps in PowerShell and verify 1.5b and 14b both report 100% GPU.
• Artifact Built: Run docker images devops-lab-api in WSL2 to confirm the image tagged local exists.
• Container Cleanup: Run docker ps -a to confirm ephemeral test containers (test-api) were removed by post { always }.
• Workspace Hygiene: Verify in Jenkins that cleanWs() wiped the build workspace upon completion.

License

MIT License
