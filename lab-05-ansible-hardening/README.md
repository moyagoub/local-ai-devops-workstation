# Lab 05: Ansible Server Hardening & Configuration Management Pipeline

Idempotent Linux server hardening and web service deployment pipeline using Ansible, `ansible-lint`, and Jenkins with zero cloud costs and zero Docker Hub dependencies.

## Pipeline Stages

1. **Ansible Lint & Syntax Validation (`local-ansible-runner:latest`):** Enforces YAML and Ansible best practices via `ansible-lint` and `ansible-playbook --syntax-check`.
2. **Ephemeral Target Server (`public.ecr.aws/docker/library/ubuntu:24.04`):** Spins up an isolated Ubuntu 24.04 container managed via Ansible's `docker` connection plugin.
3. **Hardening Playbook & Idempotency Gate (`harden_and_deploy.yml`):**
   - Creates a non-root `devops` administrative user.
   - Hardens `/etc/ssh/sshd_config` (`PermitRootLogin no`, `PasswordAuthentication no`, `X11Forwarding no`).
   - Deploys Nginx on port `8085` with `server_tokens off` and strict security headers (`X-Frame-Options: DENY`, `X-Content-Type-Options: nosniff`, `Referrer-Policy: no-referrer`).
   - Runs a second pass and asserts `changed=0` to prove full idempotency.
4. **Compliance & HTTP Header Verification:** Inspects HTTP response headers over the Docker bridge IP and validates SSH config and user creation inside the target container.
5. **Automated Teardown (`post { always }`):** Destroys the target container and wipes the Jenkins workspace.
