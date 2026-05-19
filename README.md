# NGINX Instance Manager Labs

Enterprise-grade operational labs and onboarding patterns for:

- NGINX Instance Manager (NIM)
- NGINX OSS
- NGINX Plus
- Kubernetes onboarding
- AKS deployments
- Containerized nginx-agent workflows
- Future NGINX One onboarding evolution

---

# Repository Structure

| Folder | Purpose |
|---|---|
| legacy-container-agent-build | Older containerized nginx-agent build workflows |
| nim-2.22-oss-plus-labs | Modern NIM 2.22 enterprise deployment and onboarding |
| future-nginx-one | Reserved for future NGINX One onboarding experiments |

---

# Evolution of Architectures

## Phase 1 — Legacy Agent Container Builds

- Static containerized nginx-agent builds
- Embedded NGINX Plus licensing
- Older NMS assumptions
- Manual onboarding patterns

## Phase 2 — NIM 2.22 Operational Workflows

- AKS deployment
- Helm-based installation
- Modern OSS onboarding
- Runtime NIM-provided agent onboarding
- Operational troubleshooting methodology

## Phase 3 — Future NGINX One

Reserved for:
- Agent 3.x
- SaaS telemetry
- Fleet governance
- OpenTelemetry integrations
- Modern SaaS operational workflows

---

# Key Learning Areas

- Control plane vs data plane architecture
- Enterprise Helm troubleshooting
- Image registry handling
- Kubernetes operational debugging
- OSS vs Plus capability differences
- Container lifecycle management
- Fleet onboarding workflows

---

# Recommended Learning Flow

1. Start with:
   `legacy-container-agent-build`

2. Continue with:
   `nim-2.22-oss-plus-labs`

3. Future:
   `future-nginx-one`

---

Author: Eric Ausente