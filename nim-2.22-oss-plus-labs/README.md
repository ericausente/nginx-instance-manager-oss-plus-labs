# NIM 2.22 OSS + Plus Labs

This section contains modern enterprise-grade deployment patterns for:

- NGINX Instance Manager 2.22
- AKS deployments
- Helm troubleshooting
- OSS onboarding
- NGINX Plus onboarding
- NIM-provided nginx-agent onboarding
- Kubernetes operational debugging

---

# Major Concepts

## Control Plane vs Data Plane

NIM acts as:
- operational control plane
- fleet governance layer
- telemetry platform

NGINX instances remain:
- traffic processing data plane

---

# Key Lessons

- Why imagePullBackOff occurs
- Why enterprise Helm charts omit full registry paths
- Why imagePullSecrets matter
- Why NGINX One agent configs differ
- Why NIM-provided onboarding is preferred
- How Kubernetes runtime troubleshooting works

---

# Included Components

- AKS deployment guide
- Docker onboarding examples
- OSS onboarding
- Troubleshooting workflows
- Runtime onboarding examples