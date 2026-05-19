# Complete NGINX Instance Manager (NIM) 2.22 + AKS + NGINX OSS Agent Lab Guide

# Objective

This guide is designed for:
- NGINX consultants
- Kubernetes engineers
- Platform engineers
- F5/NGINX SMEs
- API Gateway architects
- Professional Services consultants

The goal is to:

1. Deploy NGINX Instance Manager (NIM) 2.22 on AKS
2. Understand NIM architecture deeply
3. Learn enterprise-grade Helm troubleshooting
4. Understand image registry architecture
5. Understand imagePullSecrets and private registries
6. Deploy containerized NGINX OSS instances
7. Onboard NGINX OSS into NIM using the NIM-provided Agent
8. Learn how to replicate the environment across projects
9. Learn operational troubleshooting patterns used in the field

---

# VERY IMPORTANT ARCHITECTURAL UNDERSTANDING

## NIM is NOT the data plane

NIM is the:

```text
Operational Control Plane
```

NGINX instances still process traffic.

NIM provides:
- inventory
- visibility
- telemetry
- lifecycle management
- certificate visibility
- metrics
- fleet governance
- config management
- monitoring
- operational management

---

# High-Level Architecture

```text
                           +----------------------+
                           |  NGINX Instance      |
                           |  Manager (AKS)       |
                           +----------+-----------+
                                      |
                             Agent Communication
                                  gRPC / TLS
                                      |
      ----------------------------------------------------------------
      |                                                              |
+------------------+                                  +----------------------+
| NGINX OSS        |                                  | NGINX Plus           |
| Docker Container |                                  | VM / Container       |
+------------------+                                  +----------------------+
```

---

# IMPORTANT: Licensing vs Registry Access

Many engineers confuse these.

## Licensing

NIM 2.22 changed licensing behavior.

NIM usage reporting no longer follows the older JWT workflow.

HOWEVER...

## Registry Access

NIM images are still hosted in:

```text
private-registry.nginx.com
```

Meaning:

Kubernetes STILL requires:

```text
imagePullSecrets
```

This is separate from licensing.

---

# WHY THE EARLIER INSTALL FAILED

The Helm chart intentionally uses image repositories like:

```yaml
repository: apigw
```

NOT:

```yaml
repository: private-registry.nginx.com/nms/apigw
```

Why?

Because enterprise charts are designed to support:
- disconnected environments
- Harbor
- ACR
- ECR
- Artifactory
- mirrored registries
- airgapped deployments

Without overriding repository values:

Kubernetes defaults to:

```text
docker.io/library/apigw
```

which causes:

```text
ErrImagePull
ImagePullBackOff
```

---

# PART 1 — Deploy NIM 2.22 on AKS

---

# STEP 1 — Create AKS Cluster

```bash
az login
```

```bash
az group create \
  --name rg-nim-lab \
  --location southeastasia
```

```bash
az aks create \
  --resource-group rg-nim-lab \
  --name aks-nim-lab \
  --node-count 2 \
  --enable-managed-identity \
  --generate-ssh-keys
```

Get cluster credentials:

```bash
az aks get-credentials \
  --resource-group rg-nim-lab \
  --name aks-nim-lab
```

Validate:

```bash
kubectl get nodes
```

---

# STEP 2 — Install Helm

Validate:

```bash
helm version
```

If missing:

```bash
curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
```

---

# STEP 3 — Add NGINX Helm Repository

```bash
helm repo add nginx-stable https://helm.nginx.com/stable
```

```bash
helm repo update
```

Validate:

```bash
helm search repo nim
```

Expected:

```text
nginx-stable/nim
```

---

# STEP 4 — Create Namespace

```bash
kubectl create namespace nim
```

---

# STEP 5 — Create Registry Pull Secret

Use your MyF5 JWT.

```bash
kubectl create secret docker-registry regcred \
  --docker-server=private-registry.nginx.com \
  --docker-username='<YOUR_JWT>' \
  --docker-password=none \
  -n nim
```

Validate:

```bash
kubectl get secret regcred -n nim
```

---

# STEP 6 — Create nim-values.yaml

```bash
vim nim-values.yaml
```

Paste:

```yaml
imagePullSecrets:
  - name: regcred

nmsClickhouse:
  mode: disabled

networkPolicies:
  enabled: false

log:
  level: info

apigw:
  service:
    type: LoadBalancer
    httpsPort: 443

  image:
    repository: private-registry.nginx.com/nms/apigw
    tag: 2.22.0

core:
  image:
    repository: private-registry.nginx.com/nms/core
    tag: 2.22.0

dpm:
  image:
    repository: private-registry.nginx.com/nms/dpm
    tag: 2.22.0

ingestion:
  image:
    repository: private-registry.nginx.com/nms/ingestion
    tag: 2.22.0

integrations:
  image:
    repository: private-registry.nginx.com/nms/integrations
    tag: 2.22.0

secmon:
  image:
    repository: private-registry.nginx.com/nms/secmon
    tag: 2.22.0
```

---

# STEP 7 — Validate Helm Rendering BEFORE Deployment

This is a senior engineer best practice.

```bash
helm template nim nginx-stable/nim \
  -n nim \
  -f nim-values.yaml \
  --set adminPasswordHash="$(openssl passwd -6 'YourPassword123#')" \
  --version 2.2.0 \
  --debug | grep "image:"
```

You WANT to see:

```text
image: private-registry.nginx.com/nms/apigw:2.22.0
```

You DO NOT want:

```text
image: apigw:2.22.0
```

---

# STEP 8 — Install NIM

```bash
helm upgrade --install nim nginx-stable/nim \
  -n nim \
  --create-namespace \
  -f nim-values.yaml \
  --set adminPasswordHash="$(openssl passwd -6 'YourPassword123#')" \
  --version 2.2.0 \
  --debug \
  --wait \
  --timeout 20m
```

---

# Understanding the Helm Flags

## --debug

Shows:
- rendered manifests
- values
- chart operations
- hooks

## --wait

Waits until:
- pods ready
- deployments available
- jobs completed

## --timeout 20m

Important because:
- image pulls
- PVC provisioning
- startup jobs
- migrations

can take time.

---

# STEP 9 — Real-Time Troubleshooting

Open 3 terminals.

## Terminal 1

```bash
kubectl get pods -n nim -w
```

## Terminal 2

```bash
kubectl get events -n nim --sort-by=.lastTimestamp -w
```

## Terminal 3

Run Helm install.

---

# Common Failure States

## Image Pull Failure

```text
ErrImagePull
ImagePullBackOff
```

Usually:
- wrong repository
- missing imagePullSecret
- invalid JWT

---

## PVC Issues

```text
Pending
```

Usually:
- storageclass issue
- provisioning issue

---

## CrashLoopBackOff

Container started then crashed.

Check:

```bash
kubectl logs <pod> -n nim
```

---

# STEP 10 — Validate NIM UI

Get services:

```bash
kubectl get svc -n nim
```

Find:

```text
EXTERNAL-IP
```

Open:

```text
https://<EXTERNAL-IP>
```

---

# PART 2 — Containerized NGINX OSS + NIM Agent

---

# IMPORTANT LESSON LEARNED

Do NOT install:

```text
latest nginx-agent from packages.nginx.org
```

Why?

Because that installed:

```text
Agent 3.x / NGINX One style agent
```

which caused:

```text
unknown field "server"
unknown field "nginx"
unknown field "tags"
```

The correct NIM onboarding approach is:

```text
Install the Agent directly from the NIM endpoint.
```

This gives:
- NIM-compatible Agent
- generated config
- correct onboarding workflow

Equivalent to the VM onboarding flow:

```bash
curl -k https://<NIM_ENDPOINT>/install/nginx-agent | sh
```

---

# Containerized OSS Architecture

```text
Docker Container
  ├── nginx OSS
  ├── NIM-provided nginx-agent
  ├── nginx.conf
  └── startup script
        ├── start nginx
        └── start nginx-agent
```

---

# STEP 11 — Create Lab Folder

```bash
rm -rf nginx-oss-nim-agent-lab
mkdir -p nginx-oss-nim-agent-lab/conf
cd nginx-oss-nim-agent-lab
```

---

# STEP 12 — Dockerfile

Replace:

```text
52.139.255.212
```

with your NIM external IP.

```Dockerfile
FROM nginx:stable-bookworm

RUN apt-get update && apt-get install -y \
    curl \
    ca-certificates \
    procps \
    psmisc \
    gnupg2 \
    lsb-release \
    && rm -rf /var/lib/apt/lists/*

COPY conf/nginx.conf /etc/nginx/nginx.conf
COPY entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 80 8081

ENTRYPOINT ["/entrypoint.sh"]
```

---

# STEP 13 — nginx.conf

```nginx
user nginx;
worker_processes auto;

error_log /var/log/nginx/error.log info;
pid /var/run/nginx.pid;

events {
    worker_connections 1024;
}

http {
    log_format main '$remote_addr - $request_id [$time_local] '
                    '"$request" $status $body_bytes_sent '
                    'rt=$request_time ua="$http_user_agent"';

    access_log /var/log/nginx/access.log main;

    server {
        listen 80;

        add_header X-Request-ID $request_id always;

        location / {
            default_type text/plain;
            return 200 "Hello from NGINX OSS onboarded to NIM via NIM-provided Agent\nrequest_id=$request_id\n";
        }
    }

    server {
        listen 8081;

        location /nginx_status {
            stub_status;
            allow 127.0.0.1;
            allow 172.16.0.0/12;
            allow 10.0.0.0/8;
            deny all;
        }
    }
}
```

---

# STEP 14 — entrypoint.sh

```bash
cat > entrypoint.sh <<'EOF'
#!/bin/sh
set -e

: "${NIM_ENDPOINT:?NIM_ENDPOINT env var is required}"

if ! command -v nginx-agent >/dev/null 2>&1; then
  echo "[INFO] Installing NIM-compatible nginx-agent from https://${NIM_ENDPOINT}/install/nginx-agent"

  curl -k "https://${NIM_ENDPOINT}/install/nginx-agent" \
       -o /tmp/install-nginx-agent.sh

  chmod +x /tmp/install-nginx-agent.sh
  sh /tmp/install-nginx-agent.sh
fi

echo "[INFO] NGINX version:"
nginx -v || true

echo "[INFO] NGINX Agent version:"
nginx-agent -v || true

echo "[INFO] Effective Agent config:"
cat /etc/nginx-agent/nginx-agent.conf || true

echo "[INFO] Starting NGINX OSS..."
nginx

sleep 2

echo "[INFO] Starting NGINX Agent..."
exec nginx-agent
EOF

chmod +x entrypoint.sh
```

---

# STEP 15 — Build Image

```bash
docker build -t nginx-oss-nim-agent:lab .
```

---

# STEP 16 — Run Container

```bash
docker rm -f nginx-oss-nim-agent-lab 2>/dev/null || true
```

```bash
docker run -d \
  --name nginx-oss-nim-agent-lab \
  -e NIM_ENDPOINT=52.139.255.212 \
  -p 8088:80 \
  -p 8089:8081 \
  nginx-oss-nim-agent:lab
```

---

# STEP 17 — Validate

## Check Container

```bash
docker ps
```

## Logs

```bash
docker logs -f nginx-oss-nim-agent-lab
```

## Test NGINX

```bash
curl -i http://localhost:8088/
```

## Test stub_status

```bash
curl http://localhost:8089/nginx_status
```

---

# IMPORTANT Container Learning

Traditional Linux services:

```text
daemonize into background
```

Containers require:

```text
foreground process lifecycle
```

That is why:

```bash
nginx -g 'daemon off;'
```

is commonly used in containers.

---

# OSS vs Plus Capability Differences

## OSS

You get:
- inventory
- visibility
- metrics
- agent communication
- some management

But:
- no Plus API
- no active health checks
- fewer runtime stats
- fewer advanced API gateway features

---

## Plus

You additionally get:
- upstream runtime API
- active health checks
- keyval
- JWT auth
- advanced telemetry
- richer NIM integration

---

# MOST IMPORTANT TROUBLESHOOTING COMMANDS

## Kubernetes

### Pods

```bash
kubectl get pods -n nim
```

### Events

```bash
kubectl get events -n nim --sort-by=.lastTimestamp
```

### Describe Pod

```bash
kubectl describe pod <pod> -n nim
```

### Logs

```bash
kubectl logs <pod> -n nim
```

### Helm Status

```bash
helm status nim -n nim
```

### Rendered Manifests

```bash
helm get manifest nim -n nim
```

---

# Docker Troubleshooting

## Container State

```bash
docker ps -a
```

## Logs

```bash
docker logs nginx-oss-nim-agent-lab
```

## Shell Access

```bash
docker exec -it nginx-oss-nim-agent-lab sh
```

## Validate Agent

```bash
nginx-agent -v
```

## Validate NGINX

```bash
nginx -T
```

---

# Enterprise Best Practices

## DO NOT initially:

- enable HA
- enable ClickHouse immediately
- deploy disconnected mode first
- deploy WAF integration immediately

First:
- understand architecture
- understand Helm rendering
- understand image registry handling
- understand agent onboarding
- understand Kubernetes runtime troubleshooting

---

# Future Evolution Path

## Phase 1

NIM + OSS Agent

## Phase 2

NGINX Plus onboarding

## Phase 3

OpenTelemetry integration

## Phase 4

NGINX App Protect WAF

## Phase 5

Fleet governance + GitOps

---

# CLEANUP SECTION

This section helps fully reset the environment.

---

# Cleanup Docker Lab

## Stop and Remove Container

```bash
docker rm -f nginx-oss-nim-agent-lab
```

## Remove Image

```bash
docker rmi nginx-oss-nim-agent:lab
```

## Remove All Unused Containers/Images

```bash
docker system prune -af
```

---

# Cleanup NIM from AKS

## Uninstall Helm Release

```bash
helm uninstall nim -n nim
```

## Delete Namespace

```bash
kubectl delete namespace nim
```

## Verify Cleanup

```bash
kubectl get pods -A
```

---

# Cleanup AKS Cluster

## Delete AKS Cluster

```bash
az aks delete \
  --resource-group rg-nim-lab \
  --name aks-nim-lab \
  --yes \
  --no-wait
```

## Delete Resource Group

```bash
az group delete \
  --name rg-nim-lab \
  --yes \
  --no-wait
```

---

# Final Key Learnings

This lab teaches:

- NIM architecture
- control plane vs data plane
- enterprise Helm troubleshooting
- image registry architecture
- AKS operational troubleshooting
- container lifecycle behavior
- OSS vs Plus operational differences
- NGINX Agent onboarding patterns
- Kubernetes events debugging
- enterprise operational workflows

---

# Final SME Perspective

The installation itself is not the hard part.

The real expertise comes from understanding:

```text
How the operational control plane interacts with the data plane.
```

and:

```text
How enterprise fleet ma