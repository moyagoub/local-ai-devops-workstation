# Beginner Replication Guide: Local AI DevOps & Cloud Workstation

This step-by-step guide covers setting up a local AI-assisted DevOps, cloud, and SRE workstation using Windows 11, WSL2, Docker, Ollama, VS Code, and a containerized Jenkins server.

---

## Key Steps Covered in the Guide

1. **Local AI Setup (PowerShell):** Install and configure Ollama to serve local coding models (`qwen2.5-coder` and `qwen3-coder`) in GPU VRAM.
2. **Repository Clone (WSL2):** Clone the workstation repository in `WSL: Ubuntu` and optionally constrain WSL2 memory via `.wslconfig`.
3. **VS Code & Continue:** Connect VS Code to WSL and configure the Continue extension with local dual-model YAML settings.
4. **CLI Tools:** Install host utilities including `kubectl`, `kind`, `make`, `tree`, and `ansible-lint`.
5. **Jenkins Controller:** Build and launch the local Jenkins container environment and retrieve the initial administrator password.
6. **Labs 01–06 Execution:** Set up and run pipeline jobs spanning AWS Trivy scans, local Kubernetes (K3s/kind), Azure Azurite, Ansible hardening, and Prometheus/Grafana monitoring.
7. **Maintenance:** Use provided Makefile targets (`make jenkins-up`, `make clean`) to manage local services.

