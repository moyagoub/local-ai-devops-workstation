# Lab 06: Prometheus & Grafana Observability Pipeline

Automated SRE monitoring stack built with Docker Compose, Prometheus (`quay.io/prometheus`), Grafana (`public.ecr.aws/ubuntu/grafana`), Node Exporter, and an instrumented Python microservice—validated in Jenkins with zero Docker Hub dependencies.

## Pipeline Stages

1. **Prometheus Config & Alert Rule Validation (`promtool check config`):** Validates `prometheus.yml` and `alert-rules.yml` syntax before deployment.
2. **Observability Stack Spin-Up (`docker compose up -d --build`):** Launches the instrumented Flask API (`:8086`), `node-exporter`, `prometheus` (`:9090`), and `grafana` (`:3000`) with auto-provisioned Prometheus datasource.
3. **End-to-End Telemetry Verification:** Generates traffic on `/health` and `/metrics`, confirms Prometheus scrape targets are `up`, and verifies Grafana's `/api/health` and provisioned Prometheus datasource via REST API.
4. **Automated Teardown (`post { always }`):** Tears down all containers, networks, and volumes cleanly.

## Interactive Local Exploration
To keep the dashboards running locally so you can explore Prometheus (`http://localhost:9090`) and Grafana (`http://localhost:3000`, login `admin` / `admin`) in your browser:
```bash
cd lab-06-prometheus-grafana
docker compose up -d --build
```
